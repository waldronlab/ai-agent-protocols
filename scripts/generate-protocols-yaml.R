#!/usr/bin/env Rscript

# Usage: Rscript generate-protocols-yaml.R

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown", repos = "https://cloud.r-project.org")
}
if (!requireNamespace("yaml", quietly = TRUE)) {
  install.packages("yaml", repos = "https://cloud.r-project.org")
}

protocols_dir <- "protocols"
protocol_files <- if (dir.exists(protocols_dir)) {
  list.files(protocols_dir, pattern = "protocol\\.md$", recursive = TRUE, full.names = TRUE)
} else {
  character(0)
}

repository_name <- "waldronlab/ai-agent-protocols" # Should be dynamic based on git repo or config in the future

protocols_list <- list()

for (file_path in protocol_files) {
  frontmatter <- tryCatch({
    rmarkdown::yaml_front_matter(file_path)
  }, error = function(e) {
    cat(sprintf("  [ERROR] Failed to parse YAML frontmatter: %s\n", e$message))
    return(NULL)
  })
  
  if (!is.null(frontmatter)) {
    # Add protocol URL to the metadata
    frontmatter$protocol_url <- sprintf("https://raw.githubusercontent.com/%s/main/%s", repository_name, file_path)
    protocols_list[[length(protocols_list) + 1]] <- frontmatter
  }
}

index <- list(
  spec_version = "1.0.0",
  repository = repository_name,
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  protocols = protocols_list
)

yaml_output <- yaml::as.yaml(index)
writeLines(yaml_output, "PROTOCOLS.yaml")

cat(sprintf("Successfully generated PROTOCOLS.yaml with %d protocols.\n", length(protocols_list)))
