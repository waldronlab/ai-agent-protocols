# 0005. Protocol History and Reviews

- **Status:** Accepted
- **Date:** 2026-09-11
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

Protocols in this repository are executed by AI agents and used by researchers to process scientific
data. Two facts about a protocol are needed at execution time and are not currently recorded anywhere:

1. **What changed between releases.** Tool versions, parameters, and HPC recommendations change over
   time. An agent or user reading version 1.2.0 has no way to learn what it does differently from
   1.1.0 without reading raw git logs, which capture implementation noise rather than scientific
   intent.
2. **Whether a human expert vetted this release.** Trust tiers in `registry.yaml` operate at
   repository granularity. They cannot express that a specific protocol version was read, or
   executed and benchmarked, by a named domain expert.

The second is harder than it looks, because reviews and releases are decoupled. A version may be
published and then reviewed by several experts over subsequent months without the protocol changing
at all, and a protocol may be revised after a review, leaving the newest release unreviewed while an
older one carries approvals.

## Decision

We add a `## History & Reviews` section to every `protocol.md`, together with an optional `reviews`
array in the YAML frontmatter. The full format is specified in `PROTOCOL_STANDARD.md` and enforced by
`scripts/validate-protocol.R`.

### 1. An in-file feed, not sidecar files

The history and reviews live at the end of `protocol.md`, ordered reverse-chronologically with
newest versions at the top. This preserves the single-file portability established in ADR 0001: a
protocol remains one document containing everything an agent needs to execute, cite, and assess it.

### 2. Dual representation: markdown plus frontmatter

Reviews are recorded twice — as prose blocks under their version heading, and as structured entries
in the frontmatter `reviews` array. The prose carries peer-review-style detail for human readers; the
frontmatter lets the registry generator expose reviews in `PROTOCOLS.yaml` so that agents can query
them without parsing markdown. Because `scripts/generate-protocols-yaml.R` copies the entire
frontmatter object, this required no change to the generator.

The cost of duplication is drift, so the validator enforces that the two representations describe
exactly the same set of reviews.

### 3. `protocol_version` decouples reviews from releases

Each review entry declares the `protocol_version` it applies to, which is frequently older than the
current `version:`. A machine reader compares the two: when no review carries a `protocol_version`
equal to `version:`, the current release is unreviewed even though earlier releases were approved.

### 4. A controlled review status vocabulary

`approved`, `verified-with-benchmark`, `changes-requested`, and `deprecated`, so that an agent can
interpret a review from a federated repository it has never seen before. This is distinct from the
protocol-level `status:` field, which describes the protocol's own lifecycle.

There is deliberately no "unreviewed" status. Every status is a claim made by a named reviewer, and a
version nobody has reviewed has no entry to carry one; it is marked `*No reviews yet.*` in the
markdown instead.

### 5. Enforcement rather than convention

`scripts/validate-protocol.R` checks ordering, alignment of the top entry with `version:`, the status
vocabulary, ORCID format, that every `protocol_version` names a documented version, and that the
markdown and frontmatter agree. Contributors are not asked to memorize the conventions.

## Alternatives Considered

- **Git history as the sole record.** Rejected: git captures implementation noise rather than
  scientific intent, is unavailable to an agent that fetched only the raw `protocol.md`, and has
  nowhere to record a review that happens months after a release.
- **A separate `REVIEWS.yaml` per protocol or per repository.** Rejected: it breaks the single-file
  portability of ADR 0001 for the same reason ADR 0001 rejected splitting metadata from content, and
  it separates a review from the prose explaining it.
- **Frontmatter only, with no markdown section.** Rejected: reviewer notes are the substance of a
  review, and a YAML scalar is a poor home for several paragraphs of peer-review detail.
- **A `draft-unreviewed` status value**, as in the original proposal. Rejected: a review status is
  only ever a claim made by a named reviewer, so an unreviewed version has no entry to put it on.
  Expressing "unreviewed" requires either a synthetic nameless entry that every machine reader must
  filter out, or the structural absence we adopted.
- **Requiring ORCIDs for reviewers.** Rejected: real reviews arrive from experts whose ORCID the
  author does not have. `orcid` is optional for reviewers exactly as it already is for authors, and
  is validated against the ORCID pattern only when present.

## Consequences

- **Assessable trust at version granularity.** An agent can tell whether the exact version it is
  about to execute was vetted, by whom, and whether the expert merely read it or executed and
  benchmarked it.
- **Reviews survive revision.** Approvals of older versions are retained and remain correctly
  attributed rather than being silently inherited by new releases.
- **Authoring overhead.** Every version bump now requires a corresponding history entry, and every
  review must be recorded in two places. Both are enforced by CI, so the failure mode is a clear
  validation error rather than silent drift.
- **`PROTOCOLS.yaml` grows.** Review metadata is published in the registry index for every protocol,
  which federated consumers fetch in full.
