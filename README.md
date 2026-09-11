# agent-protocol-standard

This repository defines the standard for AI agent-compatible scientific protocols, publishes the tooling that enforces it, and hosts the central federation registry. Protocols themselves live in federated content repositories, registered in [`registry.yaml`](registry.yaml).

*   [`PROTOCOL_STANDARD.md`](PROTOCOL_STANDARD.md) — the specification a `protocol.md` must conform to.
*   [`actions/`](actions/) — composite GitHub Actions that validate protocols and generate a repository's `PROTOCOLS.yaml` index.
*   [`registry.yaml`](registry.yaml) — the federated repositories agents discover protocols from.
*   [`docs/adr/`](docs/adr/) — the decisions behind the standard.

The Waldron Lab's own protocols are being moved out to `waldronlab/agent-protocols` (see [ADR 0006](docs/adr/0006-separate-standard-from-protocol-content.md)); until that lands they remain in [`protocols/`](protocols/) here.

*This repository was named `waldronlab/ai-agent-protocols` until September 2026. GitHub redirects the old name, but please update pinned references.*

## What is an AI Agent Protocol?

An "AI Agent Protocol" is related to but different than an [AI Skill](https://github.com/bioconductor/ai-agent-skills).

*   **AI Skill**: A specific capability given to an AI agent (e.g., how to query a specific biological database, or how to use a particular R package). Skills teach the AI *how* to perform specific actions.
*   **AI Agent Protocol**: A scientific workflow, experimental plan, or analytical pipeline designed to be executed by or in collaboration with an AI agent. Protocols in this registry are **designed around provenance to published methods**. Protocols:
    - are formal records providing citation both to primary scientific literature and to publication of protocols (#4). Atomic protocols have a single purpose with a single citation to primary literature; composite protocols may be composed of multiple atomic protocols.
    - will record **human reviews** (#2)
    - will support **formal unit tests/benchmarks** (#3) to verify correct execution by different AI agents and models. 

## Utility and Core Use Cases

Some likely use cases include:

1. **Constraining Coding Agents to Established Methods**: Forces AI agents to adhere strictly to vetted, peer-reviewed analytical protocols rather than drifting, inventing parameters, or inventing plausible but untested methodology during automated script generation. Protocols are expected to create more uniform behavior by different AI agents and models.
2. **Cross-Language and Pipeline Translation**: Serves as an unambiguous English-language specification for translating computational workflows across programming languages and pipeline frameworks (e.g., Nextflow ↔ Snakemake, R ↔ Python) without losing domain-specific logic or parameter integrity.
3. **Discrepancy Auditing (Paper vs. Code vs. Protocol)**: Acts as an explicit benchmark to systematically detect inconsistencies between high-level descriptions in published manuscript Methods sections, formal protocol documentation, and actual codebase implementations. Protocols should be easier for people with domain expertise to review than codebase or even Methods sections which are less structured, can be split across main manuscript and supplementary materials, and may lack necessary details for full implementation.
4. **Filling the Methodological Reproducibility Gap**: Provides the granular operational, environment, and parameter-level details that traditional journal Methods sections often omit, facilitating computational reproducibility with less susceptbility to bitrot or dependency issues.
5. **A federated registry of AI agent-compatible protocols**: This repository serves as a central registry for AI agent-compatible protocols, designed to allow researchers to independently create their own protocol repositories and federate them into this central registry. 

## Using this standard in your own protocol repository

Protocol repositories federate into the registry here, and need no copy of the tooling: validation
and index generation are published from this repository as GitHub composite actions, so both stay in
lockstep with [`PROTOCOL_STANDARD.md`](PROTOCOL_STANDARD.md). Pin them to a release tag.

Lay your protocols out as `protocols/<name>/protocol.md`, then add two workflows.

`.github/workflows/validate.yml` — checks every protocol on each pull request:

```yaml
name: Validate Protocols
on:
  pull_request:
    paths: ['protocols/**']
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: waldronlab/agent-protocol-standard/actions/validate-protocols@v1
```

`.github/workflows/generate-index.yml` — regenerates and commits `PROTOCOLS.yaml`, the index other
agents read:

```yaml
name: Generate Protocol Index
on:
  push:
    branches: [main]
    paths: ['protocols/**']
permissions:
  contents: write
jobs:
  generate-index:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: waldronlab/agent-protocol-standard/actions/generate-index@v1
```

Both actions take a `protocols-path` input if your protocols live somewhere other than `protocols/`.
Neither hardcodes a repository name: `protocol_url` values are built from the repository the workflow
runs in.

Finally, open a pull request adding your repository to [`registry.yaml`](registry.yaml) so that
agents discover it.

## Development

*   `Rscript scripts/validate-protocol.R` validates the protocols in this repository.
*   `Rscript tests/run-tests.R` runs the validator's own test suite against the conforming and
    deliberately malformed fixtures in `tests/fixtures/`. Each invalid fixture asserts the specific
    error it is supposed to provoke, so adding a rule to the standard means adding a fixture.

## License

This repository is dual-licensed:

*   **Software & Scripts** (e.g., contents of the `scripts/` directory): [MIT License](LICENSE)
*   **Scientific Protocols & Documentation** (e.g., contents of the `protocols/` directory, unless otherwise specified in their YAML frontmatter): [Creative Commons Attribution 4.0 International (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/)
