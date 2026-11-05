# grill-me

A relentless, one-question-at-a-time interview that stress-tests a plan, design, decision or idea,
grounded in context you pick:

- **Team knowledge**: your OKF v0.2 docs in `docs/`, loaded through the `consult` skill, so the
  grilling challenges the plan against existing decisions and cites them.
- **A file**: a design doc, RFC, ADR or code path.
- **Just the idea** you type.

Each question comes with a recommended answer. Settled decisions are recorded as you go; anything
you delegate is marked "assumed". At the end you get a summary to confirm, and an offer to save the
outcome as an OKF v0.2 draft decision (status draft, unverified) for your normal review.

Invoke with "grill me about …" or `/grill-me` (Devin web: `@skills:grill-me`). A grilling runs
over many messages; every question carries its header and an "Also open" line so the protocol
survives long sessions. If an agent drifts from it mid-interview (for example after Cursor drops a
manually attached skill from context), say "keep grilling me" or invoke `/grill-me` again.

Say "batch" to get the whole current round of questions at once, "skip" to leave a question open,
"you decide" to accept the recommendation (marked assumed), and "stop" for the summary.

Not the grill-me ceremony agent: drafts are written with the producer id `grill-me-interview`.

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock); see
`LICENSE` and `NOTICE` for what changed.
