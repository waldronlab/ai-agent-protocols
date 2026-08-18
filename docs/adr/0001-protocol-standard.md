# 0001. Protocol Format and Federation Standard

- **Status:** Accepted
- **Date:** 2026-08-08
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

To enable AI agents to execute reproducible, citable workflows, we need a standard format for protocols that captures domain-specific instructions alongside rich provenance, citation data, and dependency graphs. This format must be human-readable, machine-parseable, and capable of supporting complex execution dependencies without centralizing the content in a single repository.

## Decision

We will define a single-file markdown format for protocols with strict YAML frontmatter requirements (`protocol.md`).

1. **Protocol Structure**: Each protocol is housed in its own directory (e.g., `protocols/quality-control-16s/protocol.md`). The file contains both the human-readable methods and the machine-readable metadata.
2. **Metadata Schema (YAML)**:
   - Must use `snake_case` for all fields.
   - Required fields: `name`, `description`, `version`, `authors`, `date`, `status`.
   - Optional provenance fields: `protocol_doi`, `repository_doi`, `publication_doi`, `citation`.
   - Dependency references: `protocols_used` (array specifying `name`, `repository`, and pinned `version`).
   - Trust/Search metadata: `key_packages`, `category`, `tags`.
3. **Four-Field DOI Taxonomy**: We explicitly separate `protocol_doi` (the artifact itself), `repository_doi` (the parent collection), `publication_doi` (a peer-reviewed paper describing the protocol), and `citation` (paper the protocol is based on).
4. **Composability**: Protocols can declare sequential execution dependencies via `protocols_used`. The AI agent will execute these in order. (Phase 1 supports single-level dependencies only).
5. **Trust Metrics**: The schema supports assigning trust tiers (1-5) and computing popularity signals (e.g., package downloads, citation counts). Computation of these signals is deferred to a centralized CI process.

## Alternatives Considered

- **JSON or pure YAML**: We considered storing protocols as pure structured data. Rejected because protocols must remain human-readable and authorable by biologists familiar with markdown.
- **Multiple files per protocol**: We considered separating metadata (`metadata.yaml`) from content (`protocol.md`). Rejected because single-file protocols are easier to author, copy, and align with platform export tools like protocols.io.

## Consequences

- **Portability**: A single `protocol.md` contains everything an agent needs to execute and correctly cite a procedure.
- **Standardized Citations**: The strict DOI taxonomy allows runner skills to emit highly precise "Method Provenance" blocks.
- **Validation Overhead**: We require continuous integration (`validate-protocol.R`) to ensure contributors adhere strictly to the YAML schema and dependency constraints.
