# 0007. Host the Protocol Runner with the Standard

- **Status:** Accepted
- **Date:** 2026-09-11
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

The skill that executes protocols, `bioc-protocol-runner`, has lived in
`Bioconductor/ai-agent-skills` since it was written. Their [ADR 0002] chose that deliberately:
skills orchestrate agent behavior, protocols carry scientific content, and the two should not be
mixed. That reasoning still holds — this repository hosts no protocol content either.

What it did not anticipate is that the runner is not really a *skill* in the sense the rest of that
repository means. The other fifteen skills there encode how to do something with R, Bioconductor, or
a package. The runner encodes **the standard's own semantics**:

* how to rank candidates — `trust_tier` descending, then `status`;
* what `draft`, `superseded`, and `deprecated` oblige an agent to do, up to refusing to execute;
* which `PROTOCOLS.yaml` fields exist and what they mean;
* the shape of the two-level Method Provenance block, which is the entire point of the format.

These are federation-wide semantics. None of them is Bioconductor's to define, and each is meaningful
only in terms of the vocabulary `PROTOCOL_STANDARD.md` establishes — the `status` values, the
frontmatter schema, the index fields, the citation taxonomy.

To be precise about the current state: `PROTOCOL_STANDARD.md` defines that vocabulary, but it does
*not* yet define the execution rules built on it. Trust ranking, the obligations attached to `draft`,
`superseded`, and `deprecated`, and the shape of the Method Provenance block exist only in the
runner's own `SKILL.md`. That is itself part of the problem: a contract every federated repository
depends on lives, today, in a skill file in another organisation's repository. Co-locating the runner
with the standard is the precondition for promoting that contract into the standard proper, which is
filed as follow-up work.

Either way, a change to the standard and the corresponding change to the runner are one change split
across two repositories and two review processes — which this project has already run into more than
once while revising the standard.

The consequences of the split are asymmetric. A validator that lags the standard fails loudly. A
runner that lags it keeps working and quietly means something different: it executes a protocol
whose `deprecated` status it does not recognise, or emits a provenance block missing a citation
level. Of everything in the federation, the runner is the artifact whose drift would do the most
damage and be the hardest to notice.

## Decision

The runner moves into this repository as `skills/protocol-runner`, and is removed from
`Bioconductor/ai-agent-skills`.

### 1. Renamed `bioc-protocol-runner` → `protocol-runner`

The `bioc-` prefix and the Bioconductor attribution in the drafted Methods paragraph describe an
ownership that no longer applies, and would misattribute a protocol executed from any other
federation node. The skill never contained R or Bioconductor assumptions in its execution logic;
only its name and its citation text did.

Renaming now, while there is one known consumer, rather than after outside adopters have pinned the
name.

### 2. Frontmatter keeps Bioconductor's `SKILL_STANDARD.md` shape

`name`, `description`, `version`, `category`, `author`, `tags`. The skill should drop into a
collection following that convention without modification — the point is to stop *owning* the skill
from there, not to fork the format.

### 3. Version 2.0.0

The identifier an agent invokes has changed. That is breaking, whatever else stayed the same.

### 4. The execution record is defined here, not referenced

The skill previously ended by emitting "the standard Bioconductor skill execution citation (from
`AGENTS.md`)" — a reference to a file in the other repository, which would dangle after the move.
It is replaced by a Skill Execution Record defined inline in the SKILL.md, reading the version from
the skill's own frontmatter.

Dropping the line instead would have been the easier fix and the wrong one: recording what ran, at
what version, is the same provenance discipline this repository exists to enforce on protocols. It
should not have depended on another organisation's file to begin with.

### 5. No skill validator here

Bioconductor's `scripts/validate_skills.py` enforces frontmatter shape, global name uniqueness,
`SKILLS.md` index synchronisation, and a mandatory version bump across sixteen skills. Reproducing
that machinery for one skill is not worth it. The check actually worth having is different and does
not exist anywhere yet: the runner enumerates the `PROTOCOLS.yaml` fields it relies on, and nothing
guarantees that list still matches `PROTOCOL_STANDARD.md`. Filed as an issue.

## Alternatives Considered

- **Leave it in `Bioconductor/ai-agent-skills` and only update its registry URL.** Rejected: it
  fixes the one broken string and leaves the coupling that produced it. Every future change to the
  standard's semantics would still be a two-repository change.
- **De-brand it in place — rename to `protocol-runner`, drop the Bioconductor citation, keep it
  there.** Rejected for the same reason, and it is the worse half of both options: the skill would
  no longer be Bioconductor's in name while still being theirs to release.
- **Keep a deprecation stub at `skills/bioc-protocol-runner/`.** Rejected: a stub that still parses
  as a valid skill remains discoverable and can be invoked, which is worse than its absence. A
  pointer in their `SKILLS.md` says where it went without pretending to be a skill.
- **Fork it — a copy here, the original there.** Rejected outright. Two runners disagreeing about
  what `deprecated` obliges an agent to do is precisely the failure this decision exists to prevent.

## Consequences

- **The standard and its runner version together.** A change to the status vocabulary, the trust
  ranking, or the provenance block is one pull request.
- **Bioconductor loses a skill from its collection**, and their ADR 0002 §1 is reversed. That is a
  cross-organisation change, made by pull request with an ADR recording it on their side too.
- **Anyone with the skill installed must repoint it.** There is no package manager here; the skill
  is a directory, and installation is a symlink or a copy. The rename makes the break explicit
  rather than silent, which is the right failure mode.
- **This repository now holds a skill, which is a new kind of artifact for it.** It is deliberately
  one skill, defined by the standard. Anything a community rather than the standard defines belongs
  in that community's own collection.
- **`create-protocol` and `update-protocol` belong here too, when they exist.** They would author
  and revise files against `PROTOCOL_STANDARD.md`, which is the same lockstep argument. Neither
  exists yet; they would be written, not moved.

[ADR 0002]: https://github.com/Bioconductor/ai-agent-skills/blob/devel/docs/adr/0002-federated-protocol-repositories.md
