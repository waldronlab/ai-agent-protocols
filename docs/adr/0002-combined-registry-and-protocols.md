# 0002. Combined Registry and Protocols Repository

- **Status:** Accepted
- **Date:** 2026-08-08
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

The Bioconductor protocol federation relies on a centralized `registry.yaml` to catalog trusted, federated protocol repositories. The AI agent skill `bioc-protocol-runner` reads this registry to discover available workflows. 

We need to decide where to host this primary `registry.yaml` file. Should it be hosted in a neutral, dedicated repository (e.g., `bioconductor/protocol-registry`), or should it be combined with the Waldron Lab's initial protocol repository (`waldronlab/ai-agent-protocols`)?

## Decision

We will combine the central registry and the first set of federated protocols within the `waldronlab/ai-agent-protocols` repository.

1.  **Registry Location:** The authoritative `registry.yaml` will reside at the root of `waldronlab/ai-agent-protocols`.
2.  **Shared CI/CD:** This repository will use the same GitHub Actions validation scripts to validate both internal protocols and external registry additions.
3.  **Role:** This repository acts as both the "root" node of the federation and a standard data node hosting Tier 4 protocols.

## Alternatives Considered

- **Separate Dedicated Registry (`bioconductor/protocol-registry`)**: We considered creating a dedicated repository that would *only* house `registry.yaml`. 
  - *Why it was rejected (for now)*: While this provides clearer governance, separation of concerns (infrastructure vs. science), and distinct trust profiles, it introduces unnecessary maintenance overhead for early stages (Step 1: own protocols, Step 2: 1-2 early adopters). It is extremely easy to split later by simply moving the file and updating a single URL in the runner skill.

## Consequences

- **Lower Overhead:** Only two repositories to manage initially (`ai-agent-skills` and `ai-agent-protocols`).
- **Immediate Utility:** The registry is immediately populated with high-quality, trusted protocols alongside its infrastructure.
- **Future Migration Path:** We accept that as the federation scales (Step 3: journal publication and wider adoption), we will likely need to move `registry.yaml` to a neutral repository to support separated governance. This migration is trivial by design.
