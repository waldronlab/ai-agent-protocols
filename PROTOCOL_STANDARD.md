# Protocol Standard

This document defines the standard for publishing AI agent-compatible protocols in this repository. Conforming to this standard ensures that your protocol can be discovered, executed, and correctly cited by the `bioc-protocol-runner` agent skill.

## File Structure

Each protocol must be housed in its own directory under `protocols/`. The directory name must exactly match the `name` field in the protocol's YAML frontmatter.

The protocol file itself must be named `protocol.md` and placed directly within its directory.

Example:
`protocols/quality-control-16s/protocol.md`

## The `protocol.md` Format

A protocol file consists of two parts:
1. **YAML Frontmatter**: Machine-readable metadata (provenance, DOIs, dependencies).
2. **Markdown Content**: Human-readable instructions for the procedure.

### YAML Frontmatter Schema

All fields must use `snake_case`.

**Required Fields:**
*   `name`: (String) A unique, kebab-case identifier for the protocol.
*   `description`: (String) A brief, one-sentence summary of the protocol's purpose.
*   `version`: (String) Semantic versioning (e.g., "1.0.0").
*   `authors`: (Array of Objects) At least one author must be specified.
    *   `name`: (String) Author's name.
    *   `orcid`: (String, Optional) Author's ORCID.
*   `date`: (Date: YYYY-MM-DD) Creation or last modification date.
*   `status`: (String: `draft` | `stable` | `deprecated` | `superseded`) The current status of the protocol.

**Optional Fields:**
*   `license`: (String) License identifier (e.g., "CC-BY-4.0").
*   `protocol_doi`: (String) DOI for this specific protocol artifact (e.g., from protocols.io).
*   `repository_doi`: (String) DOI for the entire repository/collection housing this protocol (e.g., a Zenodo record).
*   `publication_doi`: (String) DOI for the peer-reviewed publication that describes or validates this protocol.
*   `citations`: (Array of Strings) DOIs or PMIDs for the primary literature the protocol relies on.
*   `protocols_used`: (Array of Objects) Sequential execution dependencies.
    *   `name`: (String) Name of the dependency protocol.
    *   `repository`: (String) The repository hosting the dependency.
    *   `version`: (String) Exact version required.
*   `key_packages`: (Array of Strings) Primary R/Bioconductor packages used.
*   `category`: (String) High-level domain category.
*   `tags`: (Array of Strings) Searchable keywords.

### Markdown Content Structure

To ensure compatibility with future export tools (like protocols.io integration), the markdown body should loosely follow this structure:

```markdown
# [Title of Protocol]

Brief overview (1-2 sentences).

## Materials (R Packages)

- `PackageName` (Source) — [DOI/Link]

## Steps

### Step 1: [Action]
Explanation and code...

### Step 2: [Action]
Explanation and code...

## Notes

Additional context, caveats, or troubleshooting tips.

## References

- List of references corresponding to the DOIs/PMIDs in the `citations` frontmatter field.
```

## Example Protocol

```yaml
---
name: quality-control-16s
description: Quality control pipeline for 16S rRNA amplicon sequencing data
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
date: 2026-08-08
status: stable
license: CC-BY-4.0

protocol_doi: ~
repository_doi: 10.5281/zenodo.XXXXXXX
publication_doi: ~

citations:
  - "10.1038/nmeth.3869"

protocols_used: []
key_packages:
  - curatedMetagenomicData
  - mia
category: metagenomics
tags: [16s, quality-control, amplicon]
---

# Quality Control for 16S rRNA Amplicon Sequencing

This protocol demonstrates how to perform initial quality control...
...
```
