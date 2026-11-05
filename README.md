# Architect skills: consult and grill-me

Two Agent Skills for architects, written to the open Agent Skills format so they run unchanged in
Claude Code, GitHub Copilot, Cursor and Devin.

| Skill | What it does | Say |
|---|---|---|
| `consult` | Loads your team's architecture knowledge from a local `docs/` tree in Open Knowledge Format v0.2, asks which folders to load, and answers questions with citations, trust and freshness. Flags stale, draft, deprecated, conflicting and non-conformant knowledge. | "What did we decide about the event bus?" · `/consult` |
| `grill-me` | Stress-tests a plan, design or idea one question at a time, each with a recommended answer. Grounds itself in your docs (through consult), a file, or just the idea; challenges the plan against existing decisions; can save the outcome as an OKF v0.2 draft. | "Grill me about moving the ledger to active-active" · `/grill-me` |

## Install

```sh
./install.sh /path/to/repo                 # macOS, Linux, WSL, Git Bash
./install.sh /path/to/repo --devin-cli     # also for Devin for Terminal users
```
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Repo C:\path\to\repo
```

Each skill lands in `REPO/.claude/skills/<skill>/` as one real folder, which Claude Code, Copilot
(VS Code, CLI, cloud agent), Cursor and Devin cloud all read. No symlinks (they break in Windows
checkouts) and no second copy (agents that read several skills folders would list it twice).
Re-running replaces the skills and keeps the previous copy in `REPO/.kos/install/backup/`. Commit
`.claude/skills/` so the whole team and cloud agents get the skills; add `.kos/` to `.gitignore`.

Optionally paste `AGENTS-snippet.md` into the repository's `AGENTS.md` (read by Copilot, Cursor and
Devin) and reference it from `CLAUDE.md` with a line `@AGENTS.md` (Claude Code reads `CLAUDE.md`),
so agents reach for the skills unprompted.

`grill-me` here is the interview skill. It is unrelated to the KF `grill-me` ceremony agent; the
skill writes drafts with the producer id `grill-me-interview`, so OKF provenance keeps the two apart.

## Requirements

- `consult` needs Python 3.8 or later and no packages. PyYAML is used when installed; without it, a
  strict built-in parser reads the YAML subset OKF uses and reports anything it cannot read instead
  of guessing.
- `grill-me` needs nothing for file and idea mode; team-knowledge mode uses `consult`.

## CI

```sh
pip install pyyaml
python3 .claude/skills/consult/scripts/okf_map.py validate --docs docs --strict-yaml
```

Exit code 3 means an OKF v0.2 hard-conformance failure (§11): a `.md` file without frontmatter or
without `type`, or a malformed `index.md` or `log.md`. `--strict-yaml` makes the check identical
everywhere by requiring PyYAML.

## Layout

```
consult/
  SKILL.md                         choose -> load -> answer
  references/okf-consumer-rules.md public OKF v0.2 consumer contract
  references/answer-protocol.md    retrieval, precedence, answer format
  references/agents.md             per-agent notes, manual path without Python
  scripts/okf_map.py               folders | map | bodies | search | validate
grill-me/
  SKILL.md                         grounding -> design tree -> one question at a time -> summary
  references/okf-draft.md          writing the outcome as an OKF v0.2 draft
  assets/decision-draft.md         draft template
  LICENSE, NOTICE                  MIT, adapted from mattpocock/skills
install.sh, install.ps1            installers
AGENTS-snippet.md                  optional AGENTS.md section
```
