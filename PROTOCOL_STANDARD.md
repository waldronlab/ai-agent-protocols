# Protocol Standard

This document defines the standard for publishing AI agent-compatible protocols in this repository. Conforming to this standard ensures that your protocol can be discovered, executed, and correctly cited by the `bioc-protocol-runner` agent skill.

## File Structure

Each protocol must be housed in its own directory under `protocols/`. The directory name must exactly match the `name` field in the protocol's YAML frontmatter.

The protocol file itself must be named `protocol.md` and placed directly within its directory.

Example:
`protocols/humann4-sgb-aggregation/protocol.md`

## The `protocol.md` Format

A protocol file consists of two parts:
1. **YAML Frontmatter**: Machine-readable metadata (provenance, DOIs, dependencies).
2. **Markdown Content**: Human-readable instructions for the procedure.

## Protocol Types: Atomic vs. Composite

Protocols follow a modular two-tier design:

1. **Atomic Protocols**:
   * Implement a single, focused methodological operation.
   * **Strictly 1 citation:** The `citation` field must contain a single DOI/PMID corresponding to the primary literature where the method was originally published.
   * Do not compose other protocols (`protocols_used: []`).
2. **Composite Protocols**:
   * Implement multi-step workflows or end-to-end pipelines by composing atomic protocols.
   * **Composition:** List all constituent atomic protocols in `protocols_used`.
   * **Provenance:** Automatically inherit and aggregate the citations of their constituent atomic protocols upon execution. An optional overarching pipeline publication may be listed in `citation` or `publication_doi`.

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
*   `type`: (String: `atomic` | `composite`) Protocol architectural type (defaults to `atomic` if `protocols_used` is empty).
*   `license`: (String) License identifier (e.g., "CC-BY-4.0").
*   `protocol_doi`: (String) DOI for this specific protocol artifact (e.g., from protocols.io).
*   `repository_doi`: (String) DOI for the entire repository/collection housing this protocol (e.g., a Zenodo record).
*   `publication_doi`: (String) DOI for the peer-reviewed publication that describes or validates this protocol.
*   `citation`: (String) DOI or PMID for the primary literature that proposed the protocol method.
*   `upstream_repositories`: (Array of Strings) URLs to source code repositories containing upstream tools or pipeline implementations.
*   `database_urls`: (Array of Strings) URLs for pre-computed, reference, or previous versions of database artifacts.
*   `protocols_used`: (Array of Objects) Sequential execution dependencies / constituent protocols (for composite workflows).
    *   `name`: (String) Name of the dependency protocol.
    *   `repository`: (String) The repository hosting the dependency.
    *   `version`: (String) Exact version required.
*   `key_packages`: (Array of Strings) Primary R/Bioconductor, Python, or software packages used.
*   `category`: (String) High-level domain category.
*   `tags`: (Array of Strings) Searchable keywords.


### Markdown Content Structure

To ensure compatibility with future export tools (like protocols.io integration), the markdown body should follow this structure:

```markdown
# [Title of Protocol]

Brief overview (1-2 sentences).

## Materials

- **Software & Repositories:**
  - `ToolName` ([Repository URL]) — Description/version.
- **Databases & Reference Data:**
  - `DatabaseName` ([Database URL]) — Baseline reference or previous build URL.

## Steps

### Step 1: [Action]
Explanation and code...

### Step 2: [Action]
Explanation and code...

## Notes

Additional context, caveats, computational/HPC requirements, or troubleshooting tips.
```

## Example Protocol

```yaml
---
name: humann4-sgb-aggregation
description: Download representative isolate genomes and MAGs for MetaPhlAn 4.2 SGBs and subsample overrepresented SGBs.
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
date: 2026-08-08
status: draft
license: CC-BY-4.0
type: atomic

protocol_doi: ~
repository_doi: ~
publication_doi: ~

citation: "10.1016/j.cell.2019.01.001"

upstream_repositories:
  - "https://github.com/biobakery/metaphlan"

database_urls:
  - "http://cmprod1.cibio.unitn.it/databases/Metaphlan/mpa_vJan21_CHOCOPhlAnSGB_202103.tar"

protocols_used: []
key_packages: []
category: metagenomics
tags: [humann, metaphlan, sgb, pangenome, mash]
---

# SGB Genome Aggregation & Subsampling

Download representative isolate genomes and MAGs for MetaPhlAn 4.2 SGBs...
```


