# Running in each coding agent

One folder in the open Agent Skills format (agentskills.io), no agent-specific code. Agents differ
only in where they look, how you invoke a skill, and how questions are asked.

## Where it is installed

One real folder per skill at **`.claude/skills/<skill>/`** in the repository, with no symlinks and
no second copy.

| Agent | Reads `.claude/skills/` in the repo | Invoke explicitly |
|---|---|---|
| Claude Code | Yes (its project skills folder) | `/consult` |
| GitHub Copilot: VS Code agent mode, Copilot CLI, cloud agent | Yes (alongside `.github/skills/`, `.agents/skills/`) | `/consult` |
| Cursor | Yes (alongside `.agents/skills/`, `.cursor/skills/`) | `/consult` |
| Devin (cloud) | Yes (it scans `.claude/`, `.agents/`, `.github/`, `.cursor/` and other skills folders) | `@skills:consult` |
| Devin for Terminal (CLI) | No: it reads `.agents/`, `.devin/`, `.windsurf/` skills | `/consult` after the personal install below |

Why one folder: every agent above except Devin CLI also reads `.agents/skills/`, so a second copy
there is listed twice; symlinks become plain text files in Windows checkouts, where Claude Code
would then find nothing.

Devin for Terminal users run the installer with `--devin-cli`, which adds a personal copy at
`~/.config/devin/skills/<skill>` (`%APPDATA%\devin\skills\<skill>` on Windows). Only Devin CLI
reads that folder, so nothing is duplicated.

Skills are also picked up automatically when a request matches their `description`.

## Asking the user

Use the agent's question tool when it has one (Claude Code: `AskUserQuestion`; Copilot CLI: its
ask-user tool); otherwise ask in chat with a numbered list. Cloud agents started from a ticket or
schedule (Copilot cloud agent, Devin sessions) cannot wait for an answer: load the folders the task
names, or all folders, and say which at the top of the reply.

## Tools the skill needs

Read files, list directories, and run one Python command. `allowed-tools` is not declared: its
syntax differs between agents (space-separated in the open spec, comma-separated in Devin) and
support is experimental.

## Manual path (no Python)

1. List top-level folders under `docs/`; count `.md` files in each. Ask which to load.
2. Grep every `.md` under `docs/` (all folders, not only the chosen ones) for
   `^(type|title|description|status|stale_after|tags):` and `^#{1,3} ` to build the map; open the
   top of a file for `generated`, `verified` and `sources`.
3. Derive status, trust tier and staleness by hand with `okf-consumer-rules.md`; note files with no
   frontmatter or no `type` as non-conformant.
4. If the chosen files are small (under roughly 240 KB together), read them all; otherwise read per
   question. Always read the newest decision on the subject. Then follow `answer-protocol.md`.
