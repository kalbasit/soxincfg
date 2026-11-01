# Reviewing a design or document (one round)

You are reviewing one target for issues a reviewer would block on. Your prompt gives the
round's **phase** and **bar**:

- `full` / `final`: read the whole target.
- `delta`: review only the text listed in `delta.md` (what the last round's fixes added or
  changed) and anything elsewhere it directly contradicts or breaks. Don't review the rest.
- Bar `high+medium`: report high and medium findings. Bar `blocking`: report only findings
  that break a stated requirement, are a cross-section contradiction about behaviour someone
  would build, are a false claim against the evidence, make a step impossible as written,
  are a security or permission gap, or are a high-severity failure mode with no mitigation.

`NO FINDINGS` is the expected answer once a target is in good shape; don't pad. An edge case
that a test can catch is not a blocking finding. Read-only: do not edit,
post, or change any state. Never read secrets, Vault values, or SOPS directories. Don't start
background shell commands that outlive your answer, and never search the whole filesystem.

## Method

@reviewMethod@

1. Read the target in full.
2. Build a fact sheet of every concrete claim: IDs, API names and parameters, counts,
   dependencies between steps, who owns what.
3. Check each claim against the evidence in `evidence.md` and with the read-only lookups
   it allows.
4. Cross-check sections against each other: requirements, architecture text, sequence
   diagrams, graph, experience, changes and their dependencies, risks, open questions, asks.

## Look for

Correctness errors; contradictions between sections; claims contradicted by, or missing,
evidence; missing failure modes or requirements a reviewer would block on; change steps with
wrong or circular dependencies or untestable "Done when"; security and permission gaps.

## Don't report

Nits (wording, style, formatting, "more detail", diagrams that simplify the text); anything in
`nits.md` (including findings already deferred, turned into tests or risks); the accepted open items in `evidence.md`; behaviour the target explicitly marks
"to be tested", "unknown" or as an open question; lags between a PoC and the design.

## Output

Per finding: id (`R<N>-k`), path in the target, a short quote, why it is wrong or missing with
evidence (file:line, API response, KB fact), severity (high or medium), whether it is blocking
and which blocking criterion it meets, and the smallest concrete fix (say if it needs a new
mechanism).
At most 12, most severe first. If nothing qualifies, reply exactly `NO FINDINGS`. End with a
short list of claims you checked that held.
