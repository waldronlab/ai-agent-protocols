#!/usr/bin/env Rscript

# Usage: Rscript generate-protocols-yaml.R [protocols-dir] [output-file]
#
# Defaults to 'protocols' and 'PROTOCOLS.yaml'. Run from the root of the repository holding the
# protocols: the protocols directory is used verbatim in the generated 'protocol_url' values, so it
# must be a repository-relative path.

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown", repos = "https://cloud.r-project.org")
}
if (!requireNamespace("yaml", quietly = TRUE)) {
  install.packages("yaml", repos = "https://cloud.r-project.org")
}

local({
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  script_dir <- if (length(file_arg) > 0) dirname(sub("^--file=", "", file_arg[1])) else "."
  source(file.path(script_dir, "repo-utils.R"))
})

args <- commandArgs(trailingOnly = TRUE)
protocols_dir <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "protocols"
output_file <- if (length(args) >= 2 && nzchar(args[2])) args[2] else "PROTOCOLS.yaml"

# An empty index is never the right answer. The action that runs this script commits its output by
# default, so silently writing 'protocols: []' because of a mistyped path would replace a populated
# federation index with nothing.
if (!dir.exists(protocols_dir)) {
  stop(sprintf("No '%s' directory found. Pass the protocols directory as the first argument.",
               protocols_dir), call. = FALSE)
}

protocol_files <- list.files(protocols_dir, pattern = "protocol\\.md$", recursive = TRUE,
                             full.names = TRUE)
if (length(protocol_files) == 0) {
  stop(sprintf("No 'protocol.md' files found under '%s'.", protocols_dir), call. = FALSE)
}

repository_name <- detect_repository()
if (is.na(repository_name)) {
  stop(
    "Could not determine which repository these protocols belong to. Set GITHUB_REPOSITORY to ",
    "'owner/name', or run this script inside a git checkout whose 'origin' remote points at the ",
    "repository hosting them.",
    call. = FALSE
  )
}
repository_ref <- detect_ref()

protocols_list <- list()
unreadable <- character(0)

for (file_path in protocol_files) {
  frontmatter <- tryCatch({
    rmarkdown::yaml_front_matter(file_path)
  }, error = function(e) {
    cat(sprintf("  [ERROR] Failed to parse YAML frontmatter in %s: %s\n", file_path, e$message))
    return(NULL)
  })

  if (is.null(frontmatter)) {
    unreadable <- c(unreadable, file_path)
    next
  }

  # Add protocol URL to the metadata
  frontmatter$protocol_url <- sprintf(
    "https://raw.githubusercontent.com/%s/%s/%s", repository_name, repository_ref, file_path)
  protocols_list[[length(protocols_list) + 1]] <- frontmatter
}

# Skipping an unreadable protocol would publish an index that silently omits it — the protocol
# exists in the repository, but no agent can discover it, and the run still reports success.
if (length(unreadable) > 0) {
  stop(sprintf("Could not read %d protocol(s): %s. Refusing to write an index that omits them.",
               length(unreadable), paste(unreadable, collapse = ", ")),
       call. = FALSE)
}

index <- list(
  spec_version = "0.1.0",
  repository = repository_name,
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  protocols = protocols_list
)

yaml_output <- yaml::as.yaml(index)
writeLines(yaml_output, output_file)

cat(sprintf("Successfully generated %s with %d protocols.\n", output_file, length(protocols_list)))
