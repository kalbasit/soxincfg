---
name: review-loop
description: @description@
argument-hint: "@argumentHint@"
---

# Review loop

Repeat **review → verify → triage → fix** on one target until a round has no surviving
**blocking** findings, or `--max` rounds (default 6) have run. The loop is built to converge:
later rounds look only at what changed, the bar rises after the first full pass, and
findings that are real but don't block v1 are deferred to tests or risks instead of growing
the target. "Review" in the user's instructions means
this loop unless they say otherwise.

You are the orchestrator. You never review or verify yourself: every round's reviewer is a
fresh sub-agent that hasn't seen earlier fixes, and every finding gets its own fresh verifier
that hasn't seen the review. You apply the fixes and keep the ledger.

## 0. Preflight

1. **Resolve the target and its kind.**
@targetKinds@
   If you can't tell, ask once with AskUserQuestion.
2. **Approval.** Fixing a @reviewedKinds@ target edits files; fixing an own `pr` makes commits.
   Follow the session's approval rules (e.g. "operation approved") before the first edit.
   Never push, post or publish without explicit approval of that action.
3. **Scratch dir.** `mktemp -d` → `$SCRATCH`. Copy [REVIEWER.md](REVIEWER.md) and
   [VERIFIER.md](VERIFIER.md) into it, and create `$SCRATCH/nits.md` (empty) and
   `$SCRATCH/ledger.md` (the round table, below), and `$SCRATCH/deferred.md` (empty). Tell
   the user the path.
4. **Evidence list.** Collect what claims should be checked against and write it into
   `$SCRATCH/evidence.md`: for a design, its notes and READMEs, PoC or
   implementation code paths, IaC repos, and which live read-only lookups are allowed
   (e.g. `gh` reads, `aws <svc> help`). Add "accepted open items"
   the reviewer must not report: open questions, intentional non-goals, behaviour marked
   "to be tested".

## Convergence

These rules are what make a design review end clean. Apply them to @reviewedKinds@
targets; for `pr` targets the PR review's own bar applies.

- **Phases.**
  - **Full rounds** (rounds 1–2; one is enough when the target has already been reviewed): the reviewer reads the whole target. Bar: high and medium.
  - **Delta rounds** (round 3 on): the reviewer gets `$SCRATCH/delta.md`, the text that the
    previous round's fixes added or changed, and reviews only that plus anything it directly
    contradicts or breaks elsewhere. Bar: **blocking only** (below).
  - **Final round**: when a delta round is clean, run one more full round with the blocking
    bar. If it is clean too, the loop is done. A finding there resets to delta rounds.
- **Blocking** means one of: it breaks a stated requirement; two sections contradict each
  other on behaviour someone would build; a claim is false against the evidence; a step can't
  be done as written (circular or missing dependency, untestable Done-when); a security or
  permission gap; a high-severity failure mode with no mitigation. Everything else is not
  blocking.
- **Triage outcomes** for every finding that survives verification:
  - `fix` — blocking, and fixable without a new mechanism.
  - `test` — real but an implementation edge case: add one line to the owning step's
    Done-when (or the target's test list) instead of new design text.
  - `risk` — real, not blocking: one risk row or caveat.
  - `defer` — real, out of scope for this version: append to `$SCRATCH/deferred.md` and the
    target's open questions or follow-ups.
  - `polish` — real, not blocking, and fixable by correcting existing words (no new text
    about behaviour, no new mechanism): apply it, but it doesn't make the round dirty and
    doesn't go in `delta.md`.
  - `drop` — refuted or a nit (goes to `nits.md`).
- **Fix budget.** A fix may change at most what the finding names. If the only fix is a new
  mechanism (a new state, marker, alert, cadence, or rule), prefer `test` or `risk` unless the
  finding is high. Every new mechanism you do add is listed in `delta.md` so the next round
  checks it.
- **No re-raises.** Findings already marked `test`, `risk` or `defer` go into the exclusion
  list with the nits; the reviewer never sees them as new.
- **Stop early.** A full round with no `fix` goes straight to the final round (there is no
  delta to review). If two consecutive delta rounds produce only `test`/`risk`/`defer`/
  `polish` outcomes, skip to the final round.

## 1. One round

### 1a. Review

@prReview@
- @reviewedKinds@ → launch one reviewer sub-agent (`general-purpose`, model from `--model`,
  default `opus`) with: "This is review round N (ids RN-1...), phase <full | delta | final>,
  bar <high+medium | blocking>. Read $SCRATCH/REVIEWER.md, $SCRATCH/evidence.md and
  $SCRATCH/nits.md (and $SCRATCH/delta.md in a delta round) and follow them exactly.
  Target: <path>." Wait for its hand-back; don't poll.

If the reviewer reports `NO FINDINGS`: after a delta round, run the final round; after a
full or final round with the blocking bar, the loop is done (go to 2).

### 1b. Verify

For each finding, one verifier sub-agent (`general-purpose`, model `sonnet` is enough):
"Read $SCRATCH/VERIFIER.md, then verify this CLAIM: <finding text: path, quote, why, fix>".
Bundle two tiny findings about the same field into one verifier with "(two parts, verdict
each)". Launch them in parallel, **at most 10 per batch**. Each returns `CONFIRMED`,
`PARTLY` or `REFUTED`, `NIT: yes/no`, `BLOCKING: yes/no` (per the definition above), whether
the minimal fix adds a new mechanism, evidence, and the minimal fix.

Triage each finding (see Convergence): `REFUTED` or `NIT: yes` → `drop`; otherwise `fix` if
blocking and the fix adds no new mechanism (or the finding is high), else `test`, `risk` or
`defer`. Use only the part that held. Append every `drop`, `test`, `risk` and `defer` as one
line to `$SCRATCH/nits.md` so later reviewers don't raise it again. A non-blocking finding
whose fix only corrects existing wording is `polish`. If a verifier contradicts the
spec on a checkable fact (e.g. says an alert doesn't exist), check that one fact yourself
before acting.

A round counts as clean when no finding is triaged `fix`.

### 1c. Fix

Before editing, start `$SCRATCH/delta.md` for this round: for each `fix`, the field path and
the new text. `test` → one line in the owning step's Done-when; `risk` → one risk row;
`defer` → one line in open questions or follow-ups. Neither of those three goes in
`delta.md`.

@fixSteps@
- Record new verified facts where the target's notes live, with `(verified: <date>)`.
- A finding that needs a decision only the user can make (scope, policy, a security
  trade-off): apply the recommended default, flag it in the round report, and add it to the
  design's open questions or asks.

### 1d. Ledger and report

Append to `$SCRATCH/ledger.md`: round, phase, reviewer agent ID, each finding ID → verifier
agent ID → verdict → triage outcome. Tell the user in a few lines: found / held / nits, what
changed, and anything that needs their call. Then start the next round.

## 2. Finish

- Report the per-round table (phase, found, fix, test, risk, defer, drop) and say plainly
  whether the final round was clean or the cap stopped it. List `deferred.md` for the user.
@extraFinish@- Update the project's status notes when there are any.
- Copy `$SCRATCH/ledger.md` somewhere durable (next to the target's notes or the project
  dir) so every sub-agent transcript can be found later.

## Rules

- Sub-agents must not leave background shell commands running after they answer, and must
  never run filesystem-wide searches (`find /`); say so in every prompt.
- Read-only for every sub-agent: no edits, posts, or state changes; never read secrets,
  Vault values, or SOPS directories.
- A fresh reviewer every round. Don't pass it earlier findings, only the nit list.
- Don't re-litigate a nit a verifier already dropped, and don't treat "tested later" or
  open-question items as findings.
- If the user raises the cap mid-run ("4 more rounds"), continue the round numbering and
  phase.
- If the cap is reached without a clean final round, say which findings would have been
  `fix` and recommend whether to stop: when the last two rounds had no high findings and
  every fix was in text added by the loop itself, the loop is chasing its own edits.
