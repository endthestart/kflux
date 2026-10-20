# 0006: AI-assisted contributions

Date: 2026-10-20. Status: accepted.

## Context

kflux is built with AI agents under the maintainer's direction. Agents can
write more than one person can review, test on real hardware and support.
Some upstreams, labwc among them, ban AI-generated contributions.

## Decision

- AI-assisted contributions are allowed. No disclosure trailer is required.
- The rule for every contribution, however it was written: a human has built
  it, run it, and can explain it.
- Contributors sign off under the DCO (`git commit -s`).
- kflux never sends AI-generated content to a project that bans it.

## Consequences

- Review and testing, not writing, set the pace; scope stays capped.
- labwc patches stay in `labwc-kflux` ([0003](0003-tabs-as-optional-labwc-patch.md)).
