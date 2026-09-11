# Unit tests for scripts/repo-utils.R, sourced by tests/run-tests.R.
#
# These helpers decide which repository every generated protocol_url points at, so a wrong answer
# is not a crash — it is an index full of URLs that resolve to somewhere else, or to nothing.

source(file.path(tests_dir, "..", "scripts", "repo-utils.R"))

# url, expected slug (NA where the input is not a remote URL naming owner/name)
url_cases <- list(
  c("git@github.com:owner/name.git",                       "owner/name"),
  c("git@github.com:owner/name",                           "owner/name"),
  c("git@github.com:owner/name.git/",                      "owner/name"),
  c("git@gitlab.example.org:owner/name.git",               "owner/name"),
  c("https://github.com/owner/name.git",                   "owner/name"),
  c("https://github.com/owner/name",                       "owner/name"),
  c("https://github.com/owner/name/",                      "owner/name"),
  c("https://github.com/owner/name.git/",                  "owner/name"),
  c("ssh://git@github.com/owner/name.git",                 "owner/name"),
  c("https://x-access-token:secret@github.com/owner/name", "owner/name"),
  c("  https://github.com/owner/name.git  ",               "owner/name"),

  # Not remote URLs. A local path must never yield a plausible but invented slug: "/tmp/protocols"
  # parsing as "tmp/protocols" would point every generated protocol_url at a repository that does
  # not exist, and the result looks entirely reasonable in the output.
  c("/tmp/protocols",                                      NA),
  c("/Users/someone/git/protocols",                        NA),
  c("../sibling/repo",                                     NA),
  c("github.com/owner/name",                               NA),
  c("",                                                    NA),

  # A scheme alone does not make a remote: file:// URLs have an empty host, and reach the same
  # invented slug by a different route than a bare path.
  c("file:///tmp/protocols",                               NA),
  c("file:///Users/someone/git/protocols",                 NA),

  # Wrong shape even as a URL.
  c("https://github.com/owner",                            NA),
  c("https://github.com/owner/name/extra",                 NA)
)

for (case in url_cases) {
  url <- case[1]
  expected <- if (is.na(case[2])) NA_character_ else case[2]
  actual <- parse_repository_url(url)
  check(sprintf("parse_repository_url(%s)", if (nzchar(trimws(url))) url else "''"),
        identical(actual, expected),
        sprintf("expected %s, got %s", expected, actual))
}

# detect_repository() and detect_ref() read the environment, so save and restore it.
saved <- Sys.getenv(c("GITHUB_REPOSITORY", "GITHUB_REF_NAME", "GITHUB_BASE_REF", "GITHUB_EVENT_NAME"),
                    unset = NA)
restore_env <- function() {
  for (name in names(saved)) {
    if (is.na(saved[[name]])) Sys.unsetenv(name) else do.call(Sys.setenv, setNames(list(saved[[name]]), name))
  }
}
clear_env <- function() {
  Sys.unsetenv(c("GITHUB_REPOSITORY", "GITHUB_REF_NAME", "GITHUB_BASE_REF", "GITHUB_EVENT_NAME"))
}

# A throwaway checkout with an origin remote, to exercise the fallback path rather than only the
# parser it calls. Outside GitHub Actions this is the branch that decides every generated URL.
git_repo <- file.path(tempdir(), "detect-repository-fallback")
unlink(git_repo, recursive = TRUE)
dir.create(git_repo, recursive = TRUE, showWarnings = FALSE)
git_quiet <- function(...) suppressWarnings(system2("git", c("-C", shQuote(git_repo), ...),
                                                    stdout = FALSE, stderr = FALSE))
git_quiet("init")
git_quiet("remote", "add", "origin", "git@github.com:remote-org/remote-repo.git")

in_dir <- function(dir, expr) {
  old <- setwd(dir)
  on.exit(setwd(old), add = TRUE)
  force(expr)
}

clear_env()
check("detect_repository() falls back to the origin remote",
      identical(in_dir(git_repo, detect_repository()), "remote-org/remote-repo"),
      in_dir(git_repo, detect_repository()))

check("detect_repository() returns NA outside a git checkout",
      is.na(in_dir(tempdir(), detect_repository())))

Sys.setenv(GITHUB_REPOSITORY = "some-org/some-repo")
check("detect_repository() prefers GITHUB_REPOSITORY over the git remote",
      identical(in_dir(git_repo, detect_repository()), "some-org/some-repo"))

clear_env()
check("detect_ref() defaults to main", identical(detect_ref(), "main"))

Sys.setenv(GITHUB_EVENT_NAME = "push", GITHUB_REF_NAME = "devel")
check("detect_ref() uses GITHUB_REF_NAME on push", identical(detect_ref(), "devel"))

# On a pull_request, GITHUB_REF_NAME is a synthetic "<number>/merge" ref. Using it would produce
# protocol_url values nobody can fetch, so the branch the PR targets is what the index describes.
clear_env()
Sys.setenv(GITHUB_EVENT_NAME = "pull_request", GITHUB_REF_NAME = "17/merge", GITHUB_BASE_REF = "devel")
check("detect_ref() uses GITHUB_BASE_REF on pull_request", identical(detect_ref(), "devel"))

clear_env()
Sys.setenv(GITHUB_EVENT_NAME = "pull_request", GITHUB_REF_NAME = "17/merge")
check("detect_ref() falls back to main when GITHUB_BASE_REF is unset",
      identical(detect_ref(), "main"))

restore_env()
