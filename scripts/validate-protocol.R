#!/usr/bin/env Rscript

# Usage: Rscript validate-protocol.R

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown", repos = "https://cloud.r-project.org")
}

protocols_dir <- "protocols"
if (!dir.exists(protocols_dir)) {
  cat("No 'protocols' directory found.\n")
  quit(status = 0)
}

protocol_files <- list.files(protocols_dir, pattern = "protocol\\.md$", recursive = TRUE, full.names = TRUE)

required_fields <- c("name", "description", "version", "authors", "date", "status")

# Controlled vocabulary for review statuses (see PROTOCOL_STANDARD.md). There is deliberately no
# "unreviewed" value: a version nobody has reviewed simply has no entry.
review_statuses <- c("approved", "verified-with-benchmark", "changes-requested", "deprecated")
orcid_pattern <- "^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$"
semver_pattern <- "^[0-9]+\\.[0-9]+\\.[0-9]+$"
date_pattern <- "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
version_heading_pattern <- "^###[[:space:]]+Version[[:space:]]+([^[:space:]]+)[[:space:]]+\\(([0-9]{4}-[0-9]{2}-[0-9]{2})\\)[[:space:]]*$"

# "Jane Doe ([0000-...](https://orcid.org/0000-...))" -> "Jane Doe"
strip_orcid_suffix <- function(x) trimws(sub("[[:space:]]*\\(\\[.*\\]\\(.*\\)\\)$", "", x))

is_valid_date <- function(x) {
  if (!grepl(date_pattern, x)) return(FALSE)
  parsed <- tryCatch(as.Date(x), error = function(e) NA)
  !is.na(parsed)
}

# Validates the '## History & Reviews' section and the frontmatter 'reviews' array, including their
# consistency with each other. Collects every problem rather than stopping at the first.
validate_history <- function(file_path, frontmatter) {
  errors <- character(0)
  lines <- readLines(file_path, warn = FALSE)

  heading_idx <- grep("^##[[:space:]]+History & Reviews[[:space:]]*$", lines)
  if (length(heading_idx) == 0) {
    cat("  [ERROR] Missing required '## History & Reviews' section (see PROTOCOL_STANDARD.md).\n")
    return(FALSE)
  }
  if (length(heading_idx) > 1) {
    cat("  [ERROR] Found multiple '## History & Reviews' headings; there must be exactly one.\n")
    return(FALSE)
  }

  section <- if (heading_idx < length(lines)) lines[(heading_idx + 1):length(lines)] else character(0)

  later_section <- grep("^##[[:space:]]", section)
  if (length(later_section) > 0) {
    errors <- c(errors, sprintf(
      "'## History & Reviews' must be the last section, but '%s' appears after it",
      trimws(section[later_section[1]])))
  }

  version_idx <- grep("^###[[:space:]]+Version", section)
  if (length(version_idx) == 0) {
    cat("  [ERROR] '## History & Reviews' has no '### Version X.Y.Z (YYYY-MM-DD)' entries.\n")
    return(FALSE)
  }

  # Parse the version headings
  versions <- character(length(version_idx))
  for (k in seq_along(version_idx)) {
    heading <- section[version_idx[k]]
    if (!grepl(version_heading_pattern, heading)) {
      errors <- c(errors, sprintf(
        "Malformed version heading '%s'; expected '### Version X.Y.Z (YYYY-MM-DD)'", trimws(heading)))
      versions[k] <- NA_character_
      next
    }
    versions[k] <- sub(version_heading_pattern, "\\1", heading)
    heading_date <- sub(version_heading_pattern, "\\2", heading)
    if (!grepl(semver_pattern, versions[k])) {
      errors <- c(errors, sprintf(
        "Version '%s' in '## History & Reviews' is not semantic versioning (X.Y.Z)", versions[k]))
    }
    if (!is_valid_date(heading_date)) {
      errors <- c(errors, sprintf("Invalid date '%s' in heading '%s'", heading_date, trimws(heading)))
    }
  }

  # Entries must be strictly descending (newest first)
  parseable <- !is.na(versions) & grepl(semver_pattern, versions)
  if (length(versions) > 1) {
    for (k in seq_len(length(versions) - 1)) {
      if (!parseable[k] || !parseable[k + 1]) next
      above <- numeric_version(versions[k])
      below <- numeric_version(versions[k + 1])
      if (above == below) {
        errors <- c(errors, sprintf("Duplicate version entry '%s' in '## History & Reviews'", versions[k]))
      } else if (above < below) {
        errors <- c(errors, sprintf(
          "Version entries must be in descending order (newest at the top), but '%s' appears above '%s'",
          versions[k], versions[k + 1]))
      }
    }
  }

  fm_version <- as.character(frontmatter$version)
  if (parseable[1] && !identical(versions[1], fm_version)) {
    errors <- c(errors, sprintf(
      "Top entry in '## History & Reviews' is version '%s', but frontmatter declares version '%s'",
      versions[1], fm_version))
  }

  # Parse the review blocks under each version
  bounds <- c(version_idx, length(section) + 1)
  md_reviews <- data.frame(version = character(0), name = character(0), stringsAsFactors = FALSE)

  for (k in seq_along(version_idx)) {
    label <- if (is.na(versions[k])) trimws(section[version_idx[k]]) else versions[k]
    body <- if (bounds[k + 1] - 1 >= version_idx[k] + 1) {
      section[(version_idx[k] + 1):(bounds[k + 1] - 1)]
    } else {
      character(0)
    }

    if (!any(grepl("^####[[:space:]]+Changes[[:space:]]*$", body))) {
      errors <- c(errors, sprintf("Version %s is missing a '#### Changes' subsection", label))
    }

    reviews_idx <- grep("^####[[:space:]]+Reviews[[:space:]]*$", body)
    if (length(reviews_idx) == 0) {
      errors <- c(errors, sprintf("Version %s is missing a '#### Reviews' subsection", label))
      next
    }
    reviews_body <- if (reviews_idx[1] < length(body)) body[(reviews_idx[1] + 1):length(body)] else character(0)

    reviewer_names <- character(0)
    for (block in grep("^\\*\\*Review by", reviews_body, value = TRUE)) {
      matched <- regmatches(block, regexec("^\\*\\*Review by[[:space:]]+(.+)\\*\\*[[:space:]]*$", block))[[1]]
      if (length(matched) < 2) {
        errors <- c(errors, sprintf(
          "Malformed review heading '%s' under version %s; expected '**Review by <Name>**'",
          trimws(block), label))
        next
      }
      who <- matched[2]
      linked_orcid <- regmatches(who, regexec("\\(\\[([^]]*)\\]\\([^)]*\\)\\)[[:space:]]*$", who))[[1]]
      if (length(linked_orcid) >= 2 && !grepl(orcid_pattern, linked_orcid[2])) {
        errors <- c(errors, sprintf(
          "Invalid ORCID '%s' in review block under version %s", linked_orcid[2], label))
      }
      reviewer_names <- c(reviewer_names, strip_orcid_suffix(who))
    }

    for (status_line in grep("^-[[:space:]]+\\*\\*Status:\\*\\*", reviews_body, value = TRUE)) {
      quoted <- regmatches(status_line, regexec("`([^`]*)`", status_line))[[1]]
      if (length(quoted) < 2) {
        errors <- c(errors, sprintf(
          "Review status line '%s' under version %s must give a backtick-quoted status",
          trimws(status_line), label))
      } else if (!quoted[2] %in% review_statuses) {
        errors <- c(errors, sprintf(
          "Invalid review status '%s' under version %s. Must be one of: %s",
          quoted[2], label, paste(review_statuses, collapse = ", ")))
      }
    }

    placeholder <- any(grepl("^\\*No reviews yet\\.\\*[[:space:]]*$", reviews_body))
    if (length(reviewer_names) == 0 && !placeholder) {
      errors <- c(errors, sprintf(
        "Version %s has no review blocks; its '#### Reviews' subsection must contain '*No reviews yet.*'",
        label))
    }
    if (length(reviewer_names) > 0 && placeholder) {
      errors <- c(errors, sprintf(
        "Version %s has review blocks but is also marked '*No reviews yet.*'", label))
    }
    if (length(reviewer_names) > 0 && !is.na(versions[k])) {
      md_reviews <- rbind(md_reviews, data.frame(
        version = versions[k], name = reviewer_names, stringsAsFactors = FALSE))
    }
  }

  # Validate the frontmatter 'reviews' array. Absent or empty is valid: an unreviewed protocol
  # simply has no entries.
  fm_reviews <- data.frame(version = character(0), name = character(0), stringsAsFactors = FALSE)
  if (!is.null(frontmatter$reviews)) {
    if (!is.list(frontmatter$reviews)) {
      errors <- c(errors, "'reviews' must be a list of objects")
    } else {
      for (review in frontmatter$reviews) {
        if (!is.list(review)) {
          errors <- c(errors, "Each 'reviews' entry must be an object, not a bare value")
          next
        }
        who <- if (is.null(review$name)) "<unnamed>" else as.character(review$name)
        missing_keys <- setdiff(c("name", "date", "protocol_version", "status"), names(review))
        if (length(missing_keys) > 0) {
          errors <- c(errors, sprintf(
            "Review entry for '%s' is missing required field(s): %s",
            who, paste(missing_keys, collapse = ", ")))
          next
        }
        status <- as.character(review$status)
        if (!status %in% review_statuses) {
          errors <- c(errors, sprintf(
            "Review by '%s' has invalid status '%s'. Must be one of: %s",
            who, status, paste(review_statuses, collapse = ", ")))
        }
        if (!is.null(review$orcid) && !grepl(orcid_pattern, as.character(review$orcid))) {
          errors <- c(errors, sprintf("Review by '%s' has a malformed 'orcid': %s", who, review$orcid))
        }
        if (!is_valid_date(as.character(review$date))) {
          errors <- c(errors, sprintf(
            "Review by '%s' has an invalid 'date': %s (expected YYYY-MM-DD)", who, review$date))
        }
        reviewed_version <- as.character(review$protocol_version)
        if (!reviewed_version %in% versions[parseable]) {
          errors <- c(errors, sprintf(
            "Review by '%s' declares protocol_version '%s', which has no matching entry in '## History & Reviews'",
            who, reviewed_version))
        }
        fm_reviews <- rbind(fm_reviews, data.frame(
          version = reviewed_version, name = who, stringsAsFactors = FALSE))
      }
    }
  }

  # The markdown blocks and the frontmatter array must describe exactly the same set of reviews
  review_key <- function(df) {
    if (nrow(df) == 0) character(0) else paste0("version ", df$version, ", reviewer '", df$name, "'")
  }
  for (key in setdiff(review_key(md_reviews), review_key(fm_reviews))) {
    errors <- c(errors, sprintf("Review block for %s has no matching entry in the frontmatter 'reviews' array", key))
  }
  for (key in setdiff(review_key(fm_reviews), review_key(md_reviews))) {
    errors <- c(errors, sprintf("Frontmatter review for %s has no matching '**Review by ...**' block under that version", key))
  }

  if (length(errors) > 0) {
    for (message in errors) cat(sprintf("  [ERROR] %s\n", message))
    return(FALSE)
  }
  return(TRUE)
}

validate_protocol <- function(file_path) {
  cat(sprintf("Validating %s...\n", file_path))
  
  # Parse YAML frontmatter
  frontmatter <- tryCatch({
    rmarkdown::yaml_front_matter(file_path)
  }, error = function(e) {
    cat(sprintf("  [ERROR] Failed to parse YAML frontmatter: %s\n", e$message))
    return(NULL)
  })
  
  if (is.null(frontmatter)) return(FALSE)
  
  # Check required fields
  missing_fields <- setdiff(required_fields, names(frontmatter))
  if (length(missing_fields) > 0) {
    cat(sprintf("  [ERROR] Missing required fields: %s\n", paste(missing_fields, collapse = ", ")))
    return(FALSE)
  }
  
  # Check directory structure matches name
  dir_name <- basename(dirname(file_path))
  if (dir_name != frontmatter$name) {
    cat(sprintf("  [ERROR] Directory name '%s' does not match protocol name '%s'\n", dir_name, frontmatter$name))
    return(FALSE)
  }
  
  # Check authors format
  if (!is.list(frontmatter$authors) || length(frontmatter$authors) == 0) {
    cat("  [ERROR] 'authors' must be a non-empty list of objects\n")
    return(FALSE)
  }
  
  for (author in frontmatter$authors) {
    if (is.null(author$name)) {
      cat("  [ERROR] All authors must have a 'name' field\n")
      return(FALSE)
    }
  }
  
  # Check type field if present
  if (!is.null(frontmatter$type)) {
    if (!frontmatter$type %in% c("atomic", "composite")) {
      cat(sprintf("  [ERROR] 'type' must be either 'atomic' or 'composite', found: '%s'\n", frontmatter$type))
      return(FALSE)
    }
  }
  
  protocol_type <- if (!is.null(frontmatter$type)) frontmatter$type else {
    if (length(frontmatter$protocols_used) > 0) "composite" else "atomic"
  }
  
  # Check citation field
  if (!is.null(frontmatter$citations)) {
    cat(sprintf("  [ERROR] Deprecated 'citations' field found in '%s'. Use 'citation' (singular string).\n", frontmatter$name))
    return(FALSE)
  }
  
  if (!is.null(frontmatter$citation)) {
    if (!is.character(frontmatter$citation) || length(frontmatter$citation) != 1) {
      cat(sprintf("  [ERROR] 'citation' must be a single string (DOI or PMID) in '%s'\n", frontmatter$name))
      return(FALSE)
    }
  }
  
  # Check protocols_used structure for composite/dependent protocols
  if (!is.null(frontmatter$protocols_used) && length(frontmatter$protocols_used) > 0) {
    for (dep in frontmatter$protocols_used) {
      if (is.null(dep$name) || is.null(dep$repository) || is.null(dep$version)) {
        cat(sprintf("  [ERROR] Each entry in 'protocols_used' must have 'name', 'repository', and 'version'\n"))
        return(FALSE)
      }
      # Check local repository dependencies
      if (dep$repository == "waldronlab/ai-agent-protocols") {
        dep_path <- file.path(protocols_dir, dep$name, "protocol.md")
        if (!file.exists(dep_path)) {
          cat(sprintf("  [ERROR] Dependent protocol '%s' not found at '%s'\n", dep$name, dep_path))
          return(FALSE)
        }
      }
    }
  }
  
  # Check the '## History & Reviews' feed and the frontmatter 'reviews' array
  if (!validate_history(file_path, frontmatter)) {
    return(FALSE)
  }

  cat("  [OK] Valid.\n")
  return(TRUE)
}

results <- sapply(protocol_files, validate_protocol)

if (any(!results)) {
  cat("\nValidation failed for some protocols.\n")
  quit(status = 1)
} else {
  cat("\nAll protocols passed validation!\n")
}
