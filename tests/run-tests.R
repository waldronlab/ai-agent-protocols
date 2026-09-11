#!/usr/bin/env Rscript

# Usage: Rscript tests/run-tests.R
#
# Runs scripts/validate-protocol.R against every fixture under tests/fixtures/.
#
#   tests/fixtures/valid/<case>/protocols/<name>/protocol.md    must pass (exit 0)
#   tests/fixtures/invalid/<case>/protocols/<name>/protocol.md  must fail (exit 1) AND print the
#                                                               message in <case>/expected.txt
#
# To add a case, create the directory and (for an invalid case) its expected.txt; nothing here
# needs editing.

tests_dir <- local({
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) dirname(sub("^--file=", "", file_arg[1])) else "tests"
})
validator <- normalizePath(file.path(tests_dir, "..", "scripts", "validate-protocol.R"),
                           mustWork = TRUE)
fixtures_dir <- file.path(tests_dir, "fixtures")

# Fixtures declare this as their repository, so the local 'protocols_used' dependency check
# resolves identically here and in CI, where GITHUB_REPOSITORY names the real repository.
fixture_repository <- "example-org/example-protocols"

run_validator <- function(protocols_path) {
  output <- suppressWarnings(system2(
    "Rscript", c(shQuote(validator), shQuote(protocols_path)),
    stdout = TRUE, stderr = TRUE,
    env = paste0("GITHUB_REPOSITORY=", fixture_repository)
  ))
  status <- attr(output, "status")
  list(status = if (is.null(status)) 0L else as.integer(status),
       output = paste(output, collapse = "\n"))
}

cases <- function(kind) {
  dir <- file.path(fixtures_dir, kind)
  sort(list.dirs(dir, recursive = FALSE, full.names = FALSE))
}

failures <- character(0)
passed <- 0L

for (case in cases("valid")) {
  path <- file.path(fixtures_dir, "valid", case, "protocols")
  result <- run_validator(path)
  if (result$status == 0 && !grepl("[OK] Valid.", result$output, fixed = TRUE)) {
    # The validator exits 0 when it finds no protocols at all, so a mislaid fixture would
    # otherwise pass without validating anything.
    cat(sprintf("  [FAIL] valid/%s: the validator found no protocols under %s\n", case, path))
    failures <- c(failures, sprintf("valid/%s", case))
  } else if (result$status == 0) {
    cat(sprintf("  [PASS] valid/%s\n", case))
    passed <- passed + 1L
  } else {
    cat(sprintf("  [FAIL] valid/%s: expected to pass, but the validator exited %d\n%s\n",
                case, result$status, result$output))
    failures <- c(failures, sprintf("valid/%s", case))
  }
}

for (case in cases("invalid")) {
  path <- file.path(fixtures_dir, "invalid", case, "protocols")
  expected_file <- file.path(fixtures_dir, "invalid", case, "expected.txt")
  if (!file.exists(expected_file)) {
    cat(sprintf("  [FAIL] invalid/%s: no expected.txt\n", case))
    failures <- c(failures, sprintf("invalid/%s", case))
    next
  }
  expected <- trimws(paste(readLines(expected_file, warn = FALSE), collapse = "\n"))
  result <- run_validator(path)

  if (result$status == 0) {
    cat(sprintf("  [FAIL] invalid/%s: expected the validator to fail, but it passed\n", case))
    failures <- c(failures, sprintf("invalid/%s", case))
  } else if (!grepl(expected, result$output, fixed = TRUE)) {
    cat(sprintf("  [FAIL] invalid/%s: failed as expected, but without the expected message.\n    expected: %s\n    got:\n%s\n",
                case, expected, result$output))
    failures <- c(failures, sprintf("invalid/%s", case))
  } else {
    cat(sprintf("  [PASS] invalid/%s\n", case))
    passed <- passed + 1L
  }
}

cat("\n")
if (length(failures) > 0) {
  cat(sprintf("%d passed, %d FAILED: %s\n", passed, length(failures),
              paste(failures, collapse = ", ")))
  quit(status = 1)
}
cat(sprintf("All %d validator tests passed.\n", passed))
