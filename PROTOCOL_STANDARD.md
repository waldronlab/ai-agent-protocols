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
*   `reviews`: (Array of Objects) Human expert reviews of this protocol, newest first. Machine-readable
    counterpart of the review blocks in the `## History & Reviews` section; every entry must have a
    matching markdown block and vice versa. Omit the field entirely if the protocol has not been
    reviewed.
    *   `name`: (String) Reviewer's name.
    *   `orcid`: (String, Optional) Reviewer's ORCID. Optional in exactly the same way as it is for
        `authors`; when present it must match `^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$`.
    *   `date`: (Date: YYYY-MM-DD) The date the review was given.
    *   `protocol_version`: (String) The protocol version that was reviewed. This is frequently
        *older* than the current `version:` — a reviewer approves a specific release, and the
        protocol may have moved on since. It must correspond to a version documented in
        `## History & Reviews`.
    *   `status`: (String) One of the review statuses defined below.

#### Review Statuses

The `status` of a review is a controlled vocabulary, so that agents across the federation can
interpret reviews from repositories they have never seen before:

*   `approved`: A domain expert has read and vetted the protocol for scientific soundness.
*   `verified-with-benchmark`: A domain expert has actively executed the protocol and verified the
    outputs against a benchmark or expected result.
*   `changes-requested`: A domain expert has reviewed the protocol and found it broadly sound, but
    has requested revisions before it can be considered approved.
*   `deprecated`: A domain expert has reviewed the protocol and found it scientifically invalid,
    obsolete, or superseded.

Note that this vocabulary is **distinct from the protocol-level `status:` field**, which describes
the protocol's own lifecycle (`draft` | `stable` | `deprecated` | `superseded`) rather than any
individual's assessment of it.

There is deliberately no "unreviewed" status. Every status is a claim made by a named reviewer, so a
version that nobody has reviewed simply has no entry. A machine reader determines that the current
release is unreviewed when no `reviews:` entry carries a `protocol_version` equal to `version:`.


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

## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-08-08)

#### Changes
- Initial protocol creation.

#### Reviews
*No reviews yet.*
```

### History & Reviews

Every protocol must end with a `## History & Reviews` section. It is a NEWS.md-like feed serving two
purposes: recording what changed in each release, and recording which human experts vetted which
release. Keeping it inside `protocol.md` means a protocol remains a single self-contained, portable
file.

The section must be the **last** `##` section of the file, and its version entries are ordered
**reverse-chronologically, newest at the top**. Include the template comment beneath the heading so
that human authors and AI agents prepend rather than append:

```markdown
## History & Reviews
<!-- Newest versions at the top -->

### Version 1.1.0 (2026-08-18)

#### Changes
- Updated `MMseqs2` clustering parameter from `--min-seq-id 0.8` to `--min-seq-id 0.9` for UniRef90 consistency.
- Added HPC memory requirements to the Notes section.

#### Reviews
*No reviews yet.*

### Version 1.0.0 (2026-08-08)

#### Changes
- Initial protocol creation.

#### Reviews

**Review by Jane Doe ([0000-0002-1825-0097](https://orcid.org/0000-0002-1825-0097))**
- **Date:** 2026-08-10
- **Status:** `verified-with-benchmark`
- **Notes:** I ran this protocol against the new MetaPhlAn 4.2 SGB release using the mock community
  dataset. The memory footprint on our SLURM cluster peaked at 120GB, which is within expected bounds.

**Review by John Roe**
- **Date:** 2026-08-08
- **Status:** `changes-requested`
- **Notes:** The method is sound, but Step 2 needs explicit parameter values before I can recommend it.
```

Rules:

*   Every level-3 heading in the section is a **version heading**, of the form
    `### Version X.Y.Z (YYYY-MM-DD)`. The date is the **version's release date** — the value of
    frontmatter `date:` when that version was published — *not* the date the entry was written.
*   The **topmost version entry must match the frontmatter `version:` and `date:` fields**, since it
    describes the current release. Bumping `version:` therefore always means adding a new entry.
*   Each version entry has a `#### Changes` subsection listing what changed as **at least one bullet
    point**, and a `#### Reviews` subsection.
*   **Review blocks** are headed `**Review by <Name>**`, optionally followed by a linked ORCID:
    `**Review by Jane Doe ([0000-0002-1825-0097](https://orcid.org/0000-0002-1825-0097))**`. Each
    requires a `- **Date:**` line, a `- **Status:**` line (backticked, from the vocabulary above),
    and a `- **Notes:**` line. Notes are free text and peer-review-style detail is encouraged.
*   Every review block must have a corresponding entry in the frontmatter `reviews:` array whose
    `protocol_version` is the version it appears under, and every frontmatter entry must have a
    corresponding block. Where the two representations record the same fact — the date, the status,
    and the ORCID when the markdown gives one — they must agree, so that a machine reader and a human
    reader of the same protocol never draw different conclusions.

A brand-new protocol, or a release nobody has reviewed yet, still carries the section — only the
`#### Reviews` body is a placeholder, and the `reviews:` frontmatter field is omitted entirely:

```markdown
## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-08-08)

#### Changes
- Initial protocol creation.

#### Reviews
*No reviews yet.*
```

These rules are enforced by `scripts/validate-protocol.R`, which runs on every pull request.

## Example Protocol

```yaml
---
name: humann4-sgb-aggregation
description: Download representative isolate genomes and MAGs for MetaPhlAn 4.2 SGBs and subsample overrepresented SGBs.
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
reviews:
  - name: Jane Doe
    orcid: 0000-0002-1825-0097
    date: 2026-08-10
    protocol_version: 1.0.0
    status: verified-with-benchmark
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

## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-08-08)

#### Changes
- Initial protocol creation.

#### Reviews

**Review by Jane Doe ([0000-0002-1825-0097](https://orcid.org/0000-0002-1825-0097))**
- **Date:** 2026-08-10
- **Status:** `verified-with-benchmark`
- **Notes:** Executed against the MetaPhlAn 4.2 SGB release; outputs matched the expected genome counts.
```


