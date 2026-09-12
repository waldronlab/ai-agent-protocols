# 0013. `stable` Is an Assertion by the Authors

- **Status:** Accepted
- **Date:** 2026-09-12
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

`status: stable` was named in the controlled vocabulary in `PROTOCOL_STANDARD.md`, and the protocol runner
ranks candidate protocols preferring it ([`skills/protocol-runner/SKILL.md`](../../skills/protocol-runner/SKILL.md)).
No document said how a protocol becomes stable.

The consequence was not theoretical. Every one of the seven protocols in the federation was `draft`, so the
runner warned on every protocol it could ever select, and its preference for `stable` was dead code. A
warning that fires on everything is one users learn to ignore, which is the opposite of what the status
vocabulary exists to do.

This had to be settled before the `status` enum could be enforced at all: validating a value whose meaning
is undefined only makes the undefined meaning mandatory.

## Decision

**`stable` means the authors have reasonable confidence in the protocol and plan no immediate further
changes.** It is an assertion by the authors about the protocol's readiness.

The two status vocabularies stay independent and say different things:

* `status:` — what the authors intend. One value, asserted by the people who wrote the protocol.
* `reviews:` — what other people think of it. Many entries, each attributed to a named reviewer.

The full lifecycle is therefore: `draft`, still being worked out; `stable`, as above; `deprecated`, should
not be used, and the runner refuses to execute it; `superseded`, replaced by another protocol, which
`## Notes` should name.

All seven existing protocols are marked `stable` in the content repository, in a companion pull request.

## Alternatives Considered

- **Compute `stable` from the review feed** — promote a protocol once its current version carries an
  `approved` or `verified-with-benchmark` review. This was the proposal on the table and was rejected for
  two reasons. It makes the authors' judgement about readiness a side effect of someone else's reading,
  when the two are genuinely different claims. And it would immediately have promoted the six HUMAnN 4
  protocols on the strength of review entries this project's own code review flags as overstated — meeting
  comments recorded as formal `approved` reviews under named third parties. A definition whose first act is
  to amplify a known overstatement is the wrong definition.
- **Leave `stable` undefined and enforce only the enum.** Rejected: it would make an undefined value
  mandatory and leave every protocol `draft` indefinitely.
- **Drop `stable` from the vocabulary.** Rejected: the runner's ranking needs something to prefer, and
  "the authors consider this ready" is a claim worth being able to make.

## Consequences

`stable` becomes reachable, and the runner's preference for it stops being dead code. Once the seven
protocols are marked, a `draft` warning means something again.

Because `stable` is an assertion rather than a computed property, nothing prevents an author from asserting
it prematurely. That is accepted: the `reviews:` feed is where an independent claim belongs, and conflating
the two would make neither trustworthy.

This decision is independent of what the six HUMAnN 4 protocols' `approved` review entries should say. That
question is open, and settling it does not require revisiting this record.
