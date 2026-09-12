# 0012. Validate What the Standard States, and Define `stable`

- **Status:** Accepted
- **Date:** 2026-09-12
- **Deciders:** Levi Waldron (User), AI Agent

## Context and Problem Statement

A `protocol.md` with no `## Materials`, no `## Steps`, and no `method_citation` — nothing but frontmatter
and a `## History & Reviews` stub — validated clean and exited 0. So did a protocol with `status: banana`,
a malformed author ORCID, a non-kebab-case `name`, `type: atomic` declaring dependencies, and
`type: composite` declaring none. One probe file exercised six of these at once and passed.

The repository's stated purpose is citable scientific protocols. Citability and content were the two
things CI did not check, while the newest feature — review bookkeeping — was enforced to the character.

Two of these gaps were not oversights in the tooling but gaps in the specification. `PROTOCOL_STANDARD.md`
said the body *should* follow a structure, so requiring `## Materials` and `## Steps` was a new rule, not
an unenforced one. And `status: stable` was named in the enum, preferred by the runner's ranking, and
defined nowhere — no document said how a protocol becomes stable, so nothing ever had.

## Decision

**The body structure is now partly mandatory.** `## Materials`, `## Steps` with at least one `### Step`,
and `## History & Reviews` last are required. The rest of the documented structure stays a recommendation.

**`stable` means the authors have reasonable confidence in the protocol and plan no immediate further
changes.** It is an assertion by the authors about readiness, not a function of the review feed. The two
vocabularies stay independent: `reviews:` records what other people think, `status:` records what the
authors intend.

**`method_citation` must be a DOI or a PMID**, and the placeholder the starter protocol ships
(`10.0000/replace-with-a-real-doi`) is rejected by name. It is DOI-shaped, so a pattern alone passes it,
and a copied template is the likeliest wrong citation there is. A new content repository's validation is
therefore red until the adopter writes a real citation — the one thing the template cannot do for them.

**An author `orcid` is recommended, not required, and validated when present.** A malformed ORCID is worse
than an absent one: it is a claim about a named person that resolves to nobody.

**The validator collects every error before failing** rather than returning on the first. With eleven new
rules, fail-fast would have turned a first contribution into one CI round-trip per mistake.

Dependency cycles and depth are deliberately **not** included. They are a graph traversal rather than a
single-condition check, the runner already catches them at execution time, and keeping this change to
single-condition checks is what makes one-fixture-per-rule reviewable.

## Alternatives Considered

- **Compute `stable` from the review feed** — promote a protocol once its current version carries an
  `approved` or `verified-with-benchmark` review. Rejected: it makes the author's readiness judgement a
  side effect of someone else's reading, and it would have promoted the six HUMAnN protocols on the
  strength of reviews the project's own code review flags as overstated.
- **Leave the new rules as warnings.** Rejected: advisory checks are ignored, and these are the rules that
  distinguish a protocol from a metadata stub.
- **Give the template a real DOI so it validates clean.** Rejected: it would ship a citation that is wrong
  for whatever the adopter actually writes, and silently. A red first build that names the one missing
  thing is better onboarding than a green one that is quietly incorrect.
- **Require `## Materials` only of atomic protocols.** Rejected as arbitrary; the one real composite has
  one, and a composite still needs to say what it runs on.

## Consequences

Eleven rules that were stated and unenforced are now enforced, with one fixture each. All seven existing
protocols pass unchanged — unlike the field rename, this needs no content migration.

Six fixtures gained a `## Materials` section they had been written without. The template's test inverts:
it now asserts the starter protocol fails with exactly the placeholder-citation error and no other, which
still catches template drift while making the placeholder meaningful.

`stable` becomes reachable, and the runner's preference for it stops being dead code. Every protocol in
the federation is `draft` today, so the runner warns on all of them and users learn to ignore the warning;
that is fixed in the content repository, not here.
