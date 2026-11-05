# Answer protocol

Use for every question once the map is loaded.

## 1. Frame

Turn the question into the claims you need and an "as of" moment (default: now). Note any dates in
the question, and compare every date you later read (deadlines, retirements, effective dates) with it.

| Question kind | Look first at | Then check |
|---|---|---|
| What did we decide / why | Decision concepts, `log.md` entries | The sources they cite; the descriptive docs they change |
| How does X work / what is X | Concepts with a matching `resource`, title or tags | The newest decision on the same subject |
| What changed / what's latest | Map "Most recent content changes", `log.md` | The changed bodies |
| Who owns / how do we contribute | InnerSource, process and playbook concepts | Decisions that changed the process |
| Compare A and B | Both concepts and anything linking both | Decisions choosing between them |
| Is X documented properly | The concepts on X | The completeness check below |

## 2. Retrieve

- `okf_map.py search "<terms>"` searches every folder. Use the question's key nouns, then a second
  search with system names, the technology being chosen, or acronyms (DR, HA, SSO) if the first misses.
- Read every relevant hit plus the listed "Decisions on related subjects" with
  `okf_map.py bodies --paths a.md,b.md` (one call). Follow links one hop. Stop when new reads add
  no claims.
- In full mode you have read everything; still re-open what you will cite if your context has moved on.

## 3. Weigh each claim

For each claim note its path and heading, status, staleness, trust tier, content date
(`generated.at`, else `timestamp`, else git), verification date if any, OKF conformance, and the
`sources[].id` behind it when the sentence carries a footnote.

## 4. Reconcile (flag and still answer)

When current claims disagree, lead with the position these rules pick, in order, and say which rule
decided it:

1. **Lifecycle.** `deprecated` is never the current answer, and a `draft` loses to `stable`. OKF
   defines only draft, stable and deprecated: report any other status verbatim (accepted, proposed,
   rejected …), read the body to learn what the producer meant, and when it decides the conflict,
   present both claims without a lead and say which status words you relied on. A concept with
   unreadable frontmatter (`status: unknown`) is never the lead.
2. **Decisions set direction.** A newer stable decision that names the subject, or states a scope
   covering it ("all services"), beats an older descriptive doc **for what was decided**. If the
   decision takes effect or completes on a future date, answer both: "Decided: X by <date>
   (`decision path`). Documented current state: Y (`doc path`)." Never collapse a target into a fact.
   If coverage is by scope, not by name, say so in the caveats.
3. **Freshness.** A concept within its `stale_after` beats a stale one.
4. **Trust.** human-reviewed > machine-confirmed > unverified.
5. **Content date.** Newer `generated.at` beats older; a later verification only breaks a tie.
6. **Still tied:** present both without a lead and say the docs are inconsistent.

Always show the losing claim with its path, date and trust: conflicts are findings the architect
needs. Recommend which doc to update.

## 5. Answer format

```
**Answer:** <one to three sentences: the current position, as of <date> when it matters>

**Evidence**
- <claim> — `decisions/adr-031-partner-quotas.md#Decision` (stable, human-reviewed, content 2026-07-02)
- <claim> — `architecture/partner-gateway.md#Limits` (stable, machine-confirmed, STALE since 2026-09-01, content 2026-03-10)
- <claim> — `innersource/rules.md#Rules` (NON-CONFORMANT: no `type`; unverified, content 2026-09-01)

**Conflicts** (only if any)
- <doc A> says X; <doc B> says Y. Led with B by rule <n>. Recommend updating A.

**Caveats** (only if any)
- Draft, stale, unverified, non-standard or non-conformant sources; coverage by scope; unattested values.

**Gaps** (only if any)
- What the docs do not cover; links to missing concepts that mark unwritten knowledge.
```

Cite only bodies you read this session, as `path#Heading`. Quote at most a short phrase when exact
wording matters (a commitment in a decision); otherwise paraphrase.

## Completeness check ("is X documented properly")

Judge against what a reader needs to act, and list what is missing: the rule or design itself; who
owns or applies it (named people, a team, or a pointer to a roster); since when and which decision
made it so; provenance (`sources`); OKF hygiene (conformant, verified, not stale). A rule that names
a role but no people is incomplete.

## Worked example (illustrative only, not from any real bundle)

Question: "What is our partner API rate limit?"

- `search "partner rate limit"` ranks `architecture/partner-gateway.md`: 100 requests per minute,
  machine-confirmed, content 2026-03-10, stale since 2026-09-01.
- Its "Decisions on related subjects" lists `decisions/adr-031-partner-quotas.md`: tier-1 partners
  300 per minute from 2027-01-15, others 100; stable, human-reviewed, content 2026-07-02.
- Rule 2 with a future date: "Decided: 300/min for tier-1 from 2027-01-15 (ADR-031). Documented
  current state: 100/min for all partners (partner-gateway.md, stale)." Recommend refreshing the
  gateway doc; note the ADR does not say how tiers are assigned (gap).
