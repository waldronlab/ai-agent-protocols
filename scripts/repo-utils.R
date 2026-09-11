# Helpers shared by validate-protocol.R and generate-protocols-yaml.R.
#
# Both scripts need to know which repository they are running against: the generator to build
# 'protocol_url' values, the validator to recognise a local 'protocols_used' dependency. Neither can
# hardcode it, because they are distributed to federated protocol repositories via the composite
# actions under actions/. The two scripts always travel together as a checkout of this repository,
# so sourcing a sibling file is safe.

# "git@github.com:owner/name.git" or "https://github.com/owner/name.git" -> "owner/name".
# Returns NA for anything that is not a remote URL naming an owner/name pair. A local path remote
# must not be accepted: "/tmp/protocols" would otherwise yield the plausible but entirely invented
# slug "tmp/protocols".
parse_repository_url <- function(url) {
  url <- trimws(url)
  if (!nzchar(url)) {
    return(NA_character_)
  }
  # Trailing slashes first, so that a remote written "owner/name.git/" still loses its suffix.
  url <- sub("/+$", "", url)
  url <- sub("\\.git$", "", url)
  url <- sub("/+$", "", url)

  if (grepl("^[^/]+@[^/:]+:", url)) {
    url <- sub("^[^/]+@[^/:]+:", "", url) # scp-like syntax
  } else if (grepl("^[a-zA-Z][a-zA-Z0-9+.-]*://", url)) {
    url <- sub("^[a-zA-Z][a-zA-Z0-9+.-]*://", "", url) # scheme
    url <- sub("^[^/]*@", "", url) # userinfo
    # A scheme alone does not make it remote. "file:///tmp/protocols" has an empty host, and
    # stripping the leading slash would turn a local path into the invented slug "tmp/protocols"
    # by a different route than the bare-path case above.
    if (!grepl("^[^/]+/", url)) {
      return(NA_character_)
    }
    url <- sub("^[^/]+/", "", url) # host
  } else {
    return(NA_character_)
  }
  url <- sub("^/+", "", url)

  if (grepl("^[^/]+/[^/]+$", url)) url else NA_character_
}

# The "owner/name" slug of the repository being processed, or NA if it cannot be determined.
detect_repository <- function() {
  from_env <- Sys.getenv("GITHUB_REPOSITORY")
  if (nzchar(from_env)) {
    return(from_env)
  }

  url <- tryCatch(
    suppressWarnings(
      system2("git", c("remote", "get-url", "origin"), stdout = TRUE, stderr = FALSE)
    ),
    error = function(e) character(0)
  )
  if (length(url) == 0 || is.null(url)) {
    return(NA_character_)
  }
  parse_repository_url(url[1])
}

# The branch that generated URLs should point at. On GitHub Actions this is the branch being built,
# except for pull_request events, where GITHUB_REF_NAME is a synthetic "<number>/merge" ref that
# would produce URLs nobody can fetch; there the branch the PR targets is what the merged index will
# describe. "main" is only the last resort, since a repository's default branch may be named
# anything.
detect_ref <- function() {
  if (identical(Sys.getenv("GITHUB_EVENT_NAME"), "pull_request")) {
    base_ref <- Sys.getenv("GITHUB_BASE_REF")
    return(if (nzchar(base_ref)) base_ref else "main")
  }
  from_env <- Sys.getenv("GITHUB_REF_NAME")
  if (nzchar(from_env)) from_env else "main"
}
