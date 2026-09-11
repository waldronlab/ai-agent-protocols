# Tests for scripts/generate-protocols-yaml.R, sourced by tests/run-tests.R.
#
# The generator's output is the federation index: what it writes is what every agent fetches, and
# the index-generation action commits it automatically. A wrong or empty index is therefore
# published without anyone looking at it.

generator <- normalizePath(file.path(tests_dir, "..", "scripts", "generate-protocols-yaml.R"),
                           mustWork = TRUE)

# Run the generator with the given working directory, so that relative paths in protocol_url values
# come out as they would in a real repository checkout.
run_generator <- function(wd, args = c("protocols", "PROTOCOLS.yaml"), env = character(0)) {
  old <- setwd(wd)
  on.exit(setwd(old), add = TRUE)
  output <- suppressWarnings(system2(
    "Rscript", c(shQuote(generator), shQuote(args)),
    stdout = TRUE, stderr = TRUE, env = env
  ))
  status <- attr(output, "status")
  list(status = if (is.null(status)) 0L else as.integer(status),
       output = paste(output, collapse = "\n"))
}

# A throwaway repository holding one conforming protocol, copied from the fixtures.
work <- file.path(tempdir(), "generator-roundtrip")
unlink(work, recursive = TRUE)
dir.create(file.path(work, "protocols"), recursive = TRUE, showWarnings = FALSE)
file.copy(file.path(fixtures_dir, "valid", "basic", "protocols", "example-protocol"),
          file.path(work, "protocols"), recursive = TRUE)

result <- run_generator(work, env = c("GITHUB_REPOSITORY=some-org/some-repo",
                                      "GITHUB_EVENT_NAME=push",
                                      "GITHUB_REF_NAME=trunk"))
index_file <- file.path(work, "PROTOCOLS.yaml")

if (result$status != 0 || !file.exists(index_file)) {
  check("generator writes an index", FALSE, result$output)
} else {
  index <- yaml::yaml.load_file(index_file)

  check("generated index names the detected repository",
        identical(index$repository, "some-org/some-repo"),
        sprintf("got %s", index$repository))

  check("generated index carries the spec version",
        identical(index$spec_version, "1.0.0"))

  urls <- vapply(index$protocols,
                 function(p) if (is.null(p$protocol_url)) NA_character_ else p$protocol_url,
                 character(1))
  check("protocol_url is built from the detected repository and ref",
        identical(urls, "https://raw.githubusercontent.com/some-org/some-repo/trunk/protocols/example-protocol/protocol.md"),
        paste(urls, collapse = ", "))

  # The whole frontmatter is copied through, which is how reviews reach the index without the
  # generator knowing anything about them.
  reviewers <- vapply(index$protocols[[1]]$reviews, function(r) r$name, character(1))
  check("frontmatter fields the generator has no knowledge of are copied through",
        identical(reviewers, c("Grace Hopper", "Alan Turing")),
        paste(reviewers, collapse = ", "))
}

# An empty index is never the right answer: the action commits the output, so a mistyped path would
# replace a populated federation index with nothing.
empty <- file.path(tempdir(), "generator-empty")
unlink(empty, recursive = TRUE)
dir.create(file.path(empty, "protocols"), recursive = TRUE, showWarnings = FALSE)
result <- run_generator(empty, env = "GITHUB_REPOSITORY=some-org/some-repo")
check("generator refuses to write an index when it finds no protocols",
      result$status != 0 && !file.exists(file.path(empty, "PROTOCOLS.yaml")),
      result$output)

result <- run_generator(empty, args = c("no-such-directory", "PROTOCOLS.yaml"),
                        env = "GITHUB_REPOSITORY=some-org/some-repo")
check("generator refuses to write an index when the protocols directory is missing",
      result$status != 0 && !file.exists(file.path(empty, "PROTOCOLS.yaml")),
      result$output)

# Better to fail than to publish an index whose URLs point at the wrong repository. The working
# directory is outside any git checkout, so there is no origin remote to fall back to.
result <- run_generator(work, env = "GITHUB_REPOSITORY=")
check("generator stops when the repository cannot be determined",
      result$status != 0 && grepl("Could not determine which repository", result$output, fixed = TRUE),
      result$output)
