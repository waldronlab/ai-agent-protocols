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
