# 0008. Flat Federation Instead of Hierarchical Registries

- **Status:** Accepted
- **Date:** 2026-09-11
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

`registry.yaml` is a flat list. Each entry names a repository, its `index_url`, and the
trust metadata that ADR 0006 established as repository-level — `trust_tier`, `approved_by`,
`registered_date`. The runner reads that file, fetches each `PROTOCOLS.yaml`, and merges the
results into one candidate list.

The proposal was to let a registry entry point at *another registry* rather than a repository —
a `type: registry` alongside `type: repository` — so that a community could maintain a curated
sub-registry and have it imported wholesale, the way an Iceberg REST gateway can proxy other
gateways. A microbiome consortium would curate its own list; the root registry would import it;
its members would appear to every consumer without each being registered centrally.

The motivation is real and will return. Central registration is a bottleneck with a human in it,
and a flat list of every repository in a growing federation is a curation burden that someone
eventually owns.

Three things make it the wrong change to make now.

**The federation has one node.** `registry.yaml` contains a single entry,
`waldronlab/agent-protocols`. There is no curation burden to relieve, no community asking to
delegate, and no second implementation to keep honest. Designing an inheritance mechanism against
a one-element list is architecture ahead of evidence, and the resulting semantics would be frozen
by the first outside adopter to depend on them.

**Trust inheritance is the hard part, and it is not specifiable yet.** The interesting question is
not how to fetch a nested registry — that is a loop. It is what `trust_tier` an imported entry
carries: its own, its importer's, the minimum of the two, or none. That question has no answer
today because `trust_tier` has no definition at all. The only value in existence is `4`, its scale
and direction are unspecified, and `skills/protocol-runner/SKILL.md:143` still calls trust scores
"reserved for a future release" while `:36` ranks by them. Inheritance cannot be defined for a
scale that means nothing; #22 must land first.

**Recursion is a supply-chain surface.** Importing a registry delegates to a third party the right
to add repositories to the set an agent will fetch and execute instructions from. It also
introduces cycle detection and unbounded fetch depth — a registry importing a registry importing a
registry, each a separate network dependency at discovery time, any one of which can be edited
after review. A protocol is a set of instructions an agent runs; the list of places those may come
from should change only when the user changes it.

This reasoning was first recorded in issue #22, which is the reason for writing it down here
instead. That issue's revisit condition is "after `trust_tier` has semantics" — which is #22's own
subject. The record would therefore have become invisible, in a closed issue, at precisely the
moment it became relevant again.

## Decision

`registry.yaml` remains a flat list of repository entries. A registry does not import another
registry.

### 1. Federation is achieved by choice of root, not by inheritance

The capability the proposal was reaching for already exists.
`skills/protocol-runner/SKILL.md:28` has the runner read `registry.yaml` from
"whatever repository the user specified", defaulting to this one. Any community can therefore
publish its own `registry.yaml`, curate it however it likes, and have its users point at it.

That is federation — multiple independently governed roots — without inheritance semantics, without
recursion, and without anyone's trust decisions being silently absorbed into anyone else's. The
user picks a root and can read it in full.

### 2. The registry schema is a list of repositories, not a union type

The schema specified in #22 defines one kind of entry. There is no `type` discriminator, and a
conforming registry that contains an unrecognised entry kind is invalid rather than
forward-compatible. Reserving a `type` field "for later" would advertise a mechanism that does not
exist and invite exactly the inheritance question this ADR defers.

### 3. Ad-hoc attachment covers the remaining use case

Private, pre-publication, and internal protocols — the cases a sub-registry is often reached for —
are addressed by #23, which lets an agent be pointed at index URLs directly, with those nodes
labelled untrusted by construction. Between choice of root and ad-hoc attachment, the use cases
hierarchical registries would serve are served, and neither mechanism requires a repository to
inherit trust it was not granted.

### 4. The revisit condition is explicit

This is deferral, not rejection on the merits. Reopen when **both** hold:

1. `trust_tier` has defined semantics — scale, direction, and assignment criteria (#22); and
2. the flat registry has become an actual curation burden, evidenced by the number of entries and
   by communities asking to delegate curation, rather than anticipated.

Reopening means superseding this ADR, not amending it.

## Alternatives Considered

- **Adopt hierarchical registries now, with `type: registry` imports.** Rejected on all three
  grounds above: no evidence from a one-node federation, trust inheritance unspecifiable against an
  undefined `trust_tier`, and a recursive fetch graph that lets a third party extend the set of
  repositories an agent will execute from.
- **Depth-1 imports only** — a root may import registries, but imported registries may not import
  further. Rejected: it bounds recursion, which is the easy problem, and leaves trust inheritance,
  which is the hard one, entirely unanswered. It also still requires the union-typed schema of §2
  for a benefit nobody has asked for yet.
- **Reserve the `type` field now, specify the semantics later.** Rejected: a field in the published
  schema is a promise. Consumers would write code branching on it and the semantics would be fixed
  by that code rather than by a decision.
- **A single global registry that every repository must join.** Rejected: it is the centralised
  gatekeeping federation exists to avoid, and it makes this project's maintainers the bottleneck
  for every community's curation choices.
- **Leave the reasoning in issue #22.** Rejected: this ADR exists because that placement fails.
  #22's closure is itself half the revisit trigger, so the argument would vanish into a closed issue
  exactly when someone needed to re-read it.

## Consequences

- **#22 has a smaller problem to solve.** `trust_tier` must define trust for directly registered
  repositories only. No inheritance rules, no composition of tiers across import depth.
- **The set of executable sources stays legible.** Every repository whose protocols an agent may run
  is named in a file the user chose to read. No third party can add to that set, and there is no
  fetch depth to reason about at discovery time.
- **Cross-community curation is manual, and duplicated entries can drift.** A consortium wanting a
  merged view of several communities must copy those entries into its own `registry.yaml` and keep
  them current. Two roots listing the same repository at different `trust_tier` values is now
  possible and is not an error — trust is the assertion of the root the user chose. This is the
  cost accepted here, and the first real instance of it is evidence toward §4.
- **There is no discovery of registries, by design.** A user must be told a root's URL out of band.
  Registry discovery would reintroduce the delegation this ADR declines.
- **Communities can federate today without asking permission.** Publishing a `registry.yaml` and a
  `PROTOCOLS.yaml` is the whole requirement; nothing in this repository needs to change for a new
  root to exist. That was true before this ADR and is now stated rather than incidental.
