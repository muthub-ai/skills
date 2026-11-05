# OKF v0.2 consumer rules (hard constraint)

What a **consumer** of Open Knowledge Format v0.2 must and should do, as this skill applies it.
Source of truth: `okf/SPEC.md` in GoogleCloudPlatform/knowledge-catalog (Apache-2.0); section
numbers refer to it. Only the public spec applies: no organisation extensions and no invented fields.

## Structure (§3, §6, §8, §9)

- A bundle is a directory tree of `.md` files. Here `docs/` is the bundle root: bundle-absolute
  links (`/architecture/x.md`) resolve from `docs/`. *(Skill heuristic, not OKF: when a target is
  missing there, the script also tries the link's own top-level folder, because some teams write
  folder-rooted links.)*
- **Concept ID** = file path inside the bundle without `.md`. Cite by path.
- Reserved filenames at any level: `index.md` (directory listing) and `log.md` (change history).
  They are never concepts. Every other `.md` file is a concept, including a `README.md` (§3.1).
- `index.md` carries no frontmatter, except the bundle-root `docs/index.md`, which may declare
  `okf_version` (§8, §12). Entries are `* [Title](link) - description` under headings. Index files
  are optional; consumers must not reject a bundle that lacks them.
- `log.md` is date-grouped, newest first, headings `## YYYY-MM-DD`; entries are prose (§9). Its
  newest entries are the freshest statement of what changed.

## Conformance (§11)

A bundle is conformant when:

1. every non-reserved `.md` has a parseable YAML frontmatter block between `---` lines;
2. every frontmatter block has a non-empty `type`;
3. reserved files follow §8 and §9.

Consumers MUST treat a bare `verified` mapping as a one-element list, MUST NOT reject a concept for
missing optional families, SHOULD derive trust tiers and staleness only from the spec's fields, and
SHOULD surface (never silently drop) a failing attestation. Consumers SHOULD treat all other
constraints as soft guidance, and MUST NOT reject a bundle for missing optional fields, unknown
`type` values, unknown extra keys, broken links, or missing `index.md` files.

So: report non-conformant files, still read them, and mark every claim drawn from one.

## Frontmatter (§4.1, §5, §10)

| Field | Meaning | How to use it |
|---|---|---|
| `type` (required, string) | Kind of concept, producer-defined: no central registry | Routing. Unknown types are generic concepts. *(Skill heuristic, not OKF: a type containing "decision(s)" or "ADR(s)" is treated as a decision record.)* |
| `title`, `description` | Display name, one-line summary | Candidate selection only; never cite a description as evidence. |
| `resource` | URI of the underlying asset | Two current concepts with one `resource` describe the same thing: compare them. |
| `tags` | List of short strings | Cross-cutting selection; shared tags mark related concepts. |
| `sources[]` | Provenance. Each entry: `resource` (required), optional `id`, `title`, `author`, `usage_count`, `last_modified`; sibling `usage_window` | Resolve `[^id]` footnotes by `sources[].id`, never by position. `author` = authority, `last_modified` = source recency, `usage_count` = liveness and trend, not a score. A `resource` pointing at another concept is lineage you may follow. Paths are absolute URL, bundle-absolute (`/…`) or relative to the file (§6.2). |
| `generated` `{by, at}` | Who produced the current content, and its last meaningful change | `at` is the concept's content date. `by` follows the actor convention. v0.1 `timestamp` is the fallback when `generated` is absent (§13.1). |
| `verified` | List of `{by, at}` confirmations; a bare mapping is one entry | Derive the trust tier (below). Independent of `generated.at`: a re-verification confirms content; it does not make it newer. |
| `status` | `draft`, `stable` (also when absent), `deprecated` | Draft = provisional. Deprecated = kept for links and history, not current. The spec defines no other values: report any other value verbatim, never treat it as stable or current, and read the body to learn what the producer meant. |
| `stale_after` | Absolute instant | Stale when now ≥ `stale_after`. Still readable; flag it and look for corroboration. |
| `runtime`, `parameters`, `computation`, `executor`, `attester` | Attested Computation contract (§10), on `type: Attested Computation` | Spec fields, not extensions. Report the contract; never author or edit the computation; a value is attested only when an attester has checked a run's receipt. Stale computation: warn before any value (§10.5). |
| Any other key | Producer extension | Preserve and show; never reject; never invent a meaning for it. |

All timestamps are ISO 8601 datetimes with an explicit UTC offset; compare them as instants, in UTC.
Date-only or offset-less values are tolerated and flagged.

## Actors and trust tiers (§5.3, §7)

- Actors: `<producer>/<version>` for agents and tools, `human:<id>` for people, `process:<id>` for
  automated processes.
- Trust tier, lowest to highest: no `verified` → **unverified**; verified only by non-`human:` actors →
  **machine-confirmed**; any `human:<id>` verifier → **human-reviewed**.
- Tiers are advisory, never access control. Derive trust from nothing else (`generated.by: human:x`
  is authorship, not verification).

## Body (§4.2, §5.1, §6)

- Standard markdown. Conventional headings: `# Schema`, `# Examples`, `# Computation`.
- Per-claim attribution: footnote `[^id]` whose label matches a `sources[].id`. v0.1 bodies may carry
  a `# Citations` list instead; read it as provenance.
- Links are untyped relationships; the surrounding prose says what kind. A link to a missing `.md`
  is not an error: it usually marks knowledge not yet written, so report it as a gap. Links to
  non-markdown files (code under `references/`, diagrams) are assets, not concepts.
