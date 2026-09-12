---
# Replace every value below. The directory name must match `name` exactly.
name: example-protocol
description: One sentence saying what this protocol does.
version: 1.0.0
authors:
  - name: Your Name
    orcid: 0000-0000-0000-0000   # optional; delete the line if you do not have one
date: 2026-09-11
status: draft                     # draft | stable | deprecated | superseded

license: CC-BY-4.0
type: atomic                      # atomic | composite

# An atomic protocol carries exactly one `method_citation`: the primary literature where the
# method it implements was published. This is the field that makes the protocol citable.
method_citation: "10.0000/replace-with-a-real-doi"

# DOIs for the protocol artifact and its host collection, if they exist. Delete if not.
artifact_doi: ~
collection_doi: ~
protocol_citation: ~

# Where an agent can find the tools and reference data this protocol needs.
upstream_repositories: []
database_urls: []

protocols_used: []                # composite protocols list their constituents here
key_packages: []
category: example
tags: [example]
---

# Example Protocol

One or two sentences of overview: what this produces, and what it is for.

## Materials

- **Software & Repositories:**
  - `tool-name` (https://example.org/tool-name) — what it is, and which version this protocol assumes.
- **Databases & Reference Data:**
  - `database-name` (https://example.org/database) — which build or release.

## Steps

### Step 1: Do the first thing

Write the step as an unambiguous English-language instruction, with explicit parameter values. An
agent executing this in a different language or pipeline framework should not have to guess.

```sh
tool-name --input reads.fastq --output counts.tsv --threshold 0.9
```

### Step 2: Do the next thing

Say *why* a parameter has the value it has whenever the reason is not obvious. That is the part a
reader cannot reconstruct from the code.

## Notes

Caveats, computational and HPC requirements, and troubleshooting. Anything a Methods section would
omit but someone reproducing the work would need.

## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-09-11)

#### Changes
- Initial protocol creation.

#### Reviews
*No reviews yet.*
