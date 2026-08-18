# 0004. Atomic and Composite Protocols

- **Status:** Accepted
- **Date:** 2026-08-18
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

Scientific workflows range from modular, single-purpose bioinformatic tasks (e.g., calling Prodigal on a FASTA file) to complex multi-step end-to-end database builds and analysis pipelines. 

In a protocol registry, two issues arise if all protocols are treated uniformly:
1. **Citation Dilution & Ambiguity:** If a complex pipeline protocol lists dozens of citations for every tool it touches, it becomes impossible for an AI agent to trace the exact methodology back to its seminal literature.
2. **Monolithic Duplication:** If multi-step pipelines are written as giant monolithic scripts, individual reusable steps (such as subsampling SGBs or running eggNOG-mapper) cannot be independently discovered, executed, or tested by AI agents.

## Decision

We establish an **Atomic vs. Composite** architectural design pattern for all protocols in `ai-agent-protocols`:

### 1. Atomic Protocols
* **Scope:** Focused on a single, discrete methodological procedure.
* **Citation Traceability:** Strictly traceable to **at most one primary literature citation** (`citation: "<doi>"`) where the underlying method was published.
* **Dependencies:** Self-contained or referencing minimal upstream prerequisites.
* **Example:** `humann4-sgb-aggregation`, `humann4-augmented-clustering`.

### 2. Composite Protocols
* **Scope:** Higher-level pipelines or workflows that orchestrate multiple atomic protocols.
* **Composition via `protocols_used`:** List all constituent atomic protocols in `protocols_used` specifying the repository, name, and version.
* **Citation Aggregation:** A composite protocol inherits and aggregates the citations of its constituent atomic protocols. It may optionally specify a single overarching publication DOI (e.g., the benchmark or pipeline release paper) in `citation` or `publication_doi`.
* **Example:** `humann4-database-build`.

### 3. Agent Execution & Provenance Reporting
* When an AI agent executes a composite protocol, it traverses the `protocols_used` graph, executing each atomic protocol in sequence.
* When emitting provenance or generating method descriptions for manuscripts, the agent aggregates the individual DOIs of every atomic step into a structured provenance summary table.

## Alternatives Considered

- **Single-Tier Protocols (No Distinction):** Rejected because multi-step protocols either become monolithic walls of text or lose fine-grained method provenance.
- **Complex External Workflow Engines Only (Nextflow/WDL):** While workflows can be implemented in Nextflow, having agent-readable composite protocols in markdown/YAML allows the AI agent to understand, explain, debug, and execute steps interactively.

## Consequences

- **High Modularity & Reusability:** Individual bioinformatic steps can be reused across different composite pipelines.
- **Strict Provenance:** Every executed computation is directly traceable to the specific primary literature that introduced the method.
- **Automated Validation:** CI scripts can enforce that atomic protocols have at most one primary citation and that composite protocols reference valid atomic dependencies.
