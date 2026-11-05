# Writing the outcome as an OKF v0.2 draft

Only when the user says yes at the end of a grilling.

## 1. Ask where to save it

One question. Suggest a path that follows the folder's existing naming, which the map shows (for
example the next number when decisions are named `adr-NNN-<slug>.md`). Otherwise suggest
`docs/decisions/<yyyy-mm-dd>-<slug>.md` for a decision, or `docs/architecture/<slug>.md` for a design
note. Accept any path inside the workspace. Say in one line that a file in `docs/` joins the team
bundle and goes through their normal review (pull request), and that the change log entry
(`log.md`) belongs in that pull request; do not edit `log.md` yourself. Never write outside the
workspace and never overwrite a file: pick a new name and say so.

## 2. Fill the template

Start from [../assets/decision-draft.md](../assets/decision-draft.md).

- `type`: `Decision` for a decision, `Design Note` for a design with no single decision. If the
  map shows the team already uses a type for the same kind of document (for example
  `Architecture Decision Record`), use theirs.
- `title`, `description` (one sentence), `tags` from the subject.
- `status: draft`, always. A grilling never makes anything stable.
- `generated: { by: grill-me-interview/1.1.0, at: <now> }`. The producer id is
  `grill-me-interview`, never `grill-me`: the ceremony agent already writes `grill-me/<version>` into
  these bundles, and provenance must tell the two apart (OKF §5.2, §7). Get `<now>` from the shell
  (`date -u +%Y-%m-%dT%H:%M:%SZ`), never from memory.
- No `verified`. The user confirmed the summary, not the file, and nobody has reviewed it, so it is
  correctly unverified. Do not set `generated.by` to `human:…`: the agent wrote it.
- `sources`, by grounding mode:
  - **Team knowledge:** one entry per concept the grilling relied on: `id` a short slug, `resource`
    bundle-absolute (`/architecture/ledger-service.md`), `title` its title.
  - **A file:** one entry whose `resource` is the file's path relative to the draft (for example
    `../../design/rfc-12.md`) or its repository URL, never a bare workspace path.
  - **Just the idea:** no sources. Delete the `sources` key, the `[^<slug>]` marker after the
    Decision sentence, and the whole last line `[^<slug>]: <Concept title>`.
  Cite each source in the body with a `[^id]` footnote keyed to its `id` (OKF §5.1).
- No `stale_after` unless the user gives a review date (ISO 8601 with offset).
- Before you write, the file must contain no `<…>` placeholder and no footnote marker or definition
  without its pair. The validate step below reports both.

## 3. Body

Fill the template's sections from the session summary: decision, context, options considered,
consequences, conflicts with existing knowledge (each a link to the concept), related and superseded
documents, open questions, and assumed decisions. Plain markdown; no fact the session did not
establish.

## 4. Write and check

Write the file. If consult is installed and the file is under `docs/`, run from the workspace root:

```
python3 .claude/skills/consult/scripts/okf_map.py validate --docs docs --paths <path-inside-docs> --verbose
```

It checks only your file. Fix every error and warning it lists for your file. Problems in other
files are not yours: never touch them; if the user asks, mention them in one line.

## 5. Hand over

Tell the user the path and one next step (open the pull request).
