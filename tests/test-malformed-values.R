# Property tests for malformed frontmatter values, sourced by tests/run-tests.R.
#
# YAML gives a field whatever shape the author wrote. Every check in the validator needs the same
# question answered — is this one string? — and the one-fixture-per-rule suite only ever asked it
# with well-shaped input. That is how `name: ~`, `name: [a, b]` and `type: [atomic, composite]`
# each reached an `if` of the wrong length in turn and aborted the whole run: one field at a time,
# three review passes apart.
#
# So this asserts a property rather than a message. For every frontmatter field, against every
# shape YAML can produce, the validator must:
#
#   1. exit non-zero — the value is not a conforming one;
#   2. report through the accumulated `[ERROR]` path; and
#   3. not crash. An uncaught R error aborts `sapply()` over every protocol, so one malformed file
#      takes down the report for all the others.
#
# Condition 3 is the one that keeps being violated, and it is invisible to a test that only greps
# for an expected message.

malformed_dir <- file.path(tempdir(), "malformed-values")

# The shapes a YAML scalar field can arrive as, other than the string it should be.
bad_values <- list(
  "null"    = "~",
  "list"    = "[alpha, beta]",
  "mapping" = "{value: alpha}",
  "empty"   = '""'
)

# Every scalar frontmatter field the validator reads, and the line in the fixture it replaces.
scalar_fields <- list(
  name            = "name: example-protocol",
  description     = NULL,   # filled in below from the fixture
  version         = NULL,
  status          = "status: draft",
  type            = "type: atomic",
  method_citation = 'method_citation: "10.1000/example"'
)

template_path <- file.path(fixtures_dir, "valid", "basic", "protocols", "example-protocol", "protocol.md")
template <- readLines(template_path, warn = FALSE)
for (field in names(scalar_fields)) {
  if (is.null(scalar_fields[[field]])) {
    hit <- grep(sprintf("^%s:", field), template, value = TRUE)
    scalar_fields[[field]] <- if (length(hit) > 0) hit[1] else NA_character_
  }
}

for (field in names(scalar_fields)) {
  original <- scalar_fields[[field]]
  if (is.na(original) || !any(template == original)) {
    check(sprintf("malformed %s: fixture line found", field), FALSE,
          sprintf("no line '%s' in the basic fixture; the matrix cannot substitute it", original))
    next
  }
  for (shape in names(bad_values)) {
    dir <- file.path(malformed_dir, paste0(field, "-", shape), "protocols", "example-protocol")
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    lines <- template
    lines[lines == original] <- sprintf("%s: %s", field, bad_values[[shape]])
    writeLines(lines, file.path(dir, "protocol.md"))

    result <- run_validator(dirname(dir))
    crashed <- grepl("(^|\n)Error|Execution halted", result$output)
    reported <- grepl("[ERROR]", result$output, fixed = TRUE)

    check(sprintf("malformed %s: %s does not crash the validator", field, shape),
          !crashed, sprintf("uncaught R error:\n%s", result$output))
    check(sprintf("malformed %s: %s is reported and fails", field, shape),
          result$status != 0 && reported,
          sprintf("status %d, output:\n%s", result$status, result$output))
  }
}

# An author ORCID is optional, so it is not in the matrix above, but a malformed one must behave
# the same way rather than reaching grepl() as a list.
for (shape in c("list", "mapping")) {
  dir <- file.path(malformed_dir, paste0("author-orcid-", shape), "protocols", "example-protocol")
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  lines <- template
  lines[grepl("^    orcid: 0000-0002-1825-0097$", lines)] <-
    sprintf("    orcid: %s", bad_values[[shape]])
  writeLines(lines, file.path(dir, "protocol.md"))

  result <- run_validator(dirname(dir))
  check(sprintf("malformed author orcid: %s does not crash the validator", shape),
        !grepl("(^|\n)Error|Execution halted", result$output),
        sprintf("uncaught R error:\n%s", result$output))
  check(sprintf("malformed author orcid: %s is reported and fails", shape),
        result$status != 0 && grepl("[ERROR]", result$output, fixed = TRUE),
        sprintf("status %d, output:\n%s", result$status, result$output))
}
