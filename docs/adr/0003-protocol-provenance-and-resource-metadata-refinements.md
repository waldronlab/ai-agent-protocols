# 0003. Protocol Provenance and Resource Metadata Refinements

- **Status:** Accepted
- **Date:** 2026-08-18
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

The initial protocol standard ([ADR 0001](0001-protocol-standard.md)) established a baseline format for agent-executable protocols. However, as protocols for complex bioinformatics database construction pipelines (e.g., HUMAnN 4 / MetaPhlAn 4.2 SGBs) were drafted, several limitations in the original specification emerged:

1. **Redundancy and Drift in Citations:** The template mandated both a `citation` field in the YAML frontmatter and a `## References` section in the markdown body. Maintaining duplicate bibliography entries created synchronization overhead and parsing ambiguity.
2. **Citation Dilution:** When protocols cited multiple peripheral software tools alongside the foundational methodology in `citations`, the primary intellectual provenance of the protocol became ambiguous.
3. **Missing Metadata for Upstream Code & Database Artifacts:** Complex protocols frequently rely on upstream open-source code repositories (e.g., GitHub) and pre-computed database builds/archives (e.g., ChocoPhlAn, UniRef DIAMOND indexes, SGB catalogs). The initial schema lacked machine-readable fields to capture these resources.
4. **R-Centric Materials Section:** The original standard prescribed `## Materials (R Packages)` and `key_packages` as R/Bioconductor-specific, whereas many protocols involve CLI utilities, Python environments, and external databases.

## Decision

We refine the protocol standard and schema with the following architectural rules:

1. **Single Primary Literature Citation per Protocol (`citation`):**
   - The `citation` scalar string in YAML frontmatter is constrained to reference *only* the single primary literature DOI/PMID that proposed the protocol method.
2. **Elimination of the `## References` Markdown Section:**
   - The markdown body will no longer include a `## References` section. The YAML `citation` field serves as the sole, machine-readable source of truth for citations.
3. **Structured Upstream & Database Metadata in YAML:**
   - Add `upstream_repositories` (Array of Strings): Direct URLs to source code repositories containing upstream tools or pipeline implementations.
   - Add `database_urls` (Array of Strings): Direct URLs for pre-computed, reference, or previous versions of database artifacts.
4. **Generalization of `## Materials`:**
   - Broaden `## Materials` to include structured subsections for **Software & Repositories** and **Databases & Reference Data**, linking directly to upstream tools and data distributions.

## Alternatives Considered

- **Retaining `## References` in Markdown:** Rejected because dual entry of citations invites formatting inconsistencies and provides no machine-parseable benefit beyond the YAML frontmatter.
- **Allowing Multi-Citation Arrays:** Rejected in favor of strict 1-to-1 method attribution using a singular `citation` field, ensuring that protocol provenance remains unambiguous for automated citation generators.
- **Documenting Repository and Database URLs Solely in Markdown:** Rejected because AI agents (e.g., `bioc-protocol-runner`) need structured YAML keys to programmatically resolve and download upstream database assets.

## Consequences

- **Machine-Parseable Asset Discovery:** AI agents can discover both the code repository and baseline database distribution endpoints directly from YAML metadata without scraping markdown text.
- **Unambiguous Attribution:** Protocol citations map directly to the seminal methodology papers.
- **Lower Authoring Overhead:** Protocol authors only maintain citations in one location.
