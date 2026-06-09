{
  addSkill,
  enable,
  ...
}:

{
  config,
  lib,
  ...
}:

let
  skillFile = ''
    ---
    name: get-it-done
    description: 'End-to-end driver for an OpenSpec change: implement, verify, sync,
      archive, commit/branch, submit the PR, and shepherd it through review. Runs
      /opsx:apply -> /opsx:verify -> /opsx:sync -> /opsx:archive -> branch-or-commit
      -> /gs-submit -> /wait-for-coderabbit-review -> /address-gs-comments in order.
      Examples: "get it done", "take this change all the way to a reviewed PR",
      "run the full ship pipeline for <change>".'
    ---

    # Get It Done

    ## Overview

    A single command that takes an OpenSpec change from "artifacts are ready" all the
    way to "PR open and review feedback addressed." It chains the existing skills in a
    fixed order, stopping only when a step genuinely needs a human decision or when a
    step fails in a way that must be fixed before continuing.

    This is an **orchestration** skill: each numbered step below is a real skill you
    MUST invoke via the `Skill` tool (or the slash command). Do not reimplement a
    step's logic inline — call the skill so its own guardrails apply.

    ## When to Use

    - A change has all its artifacts complete (proposal/design/specs/tasks) and the
      user wants it implemented, reviewed, and merged-ready without babysitting each
      phase.
    - The user says "get it done", "ship this", "take it all the way", or invokes
      `/get-it-done`.

    ## When NOT to Use

    - The change's artifacts are not finished yet — finish them first (`/opsx:ff` or
      `/opsx:continue`).
    - The user only wants one phase (e.g. "just implement it") — call that one skill.

    ## Inputs

    - Optional change name as the argument. If omitted, infer it from conversation
      context or from `openspec list --json` (most recently modified). If ambiguous,
      ask which change before starting.

    ## Pipeline — run these in order

    Track the whole pipeline with `TodoWrite` (one todo per step) so progress is
    visible and nothing is skipped.

    ### 1. `/opsx:apply` — implement the change

    Invoke the `opsx:apply` skill to work through `tasks.md`. This implements the
    change under TDD. Let it run to completion (all tasks checked off). If it stops
    needing a decision, surface that to the user, get an answer, then continue.

    **Gate:** Do not proceed until implementation is complete and the project's
    verification (`task fmt`, `task lint`, `task test`) is green. If tests fail, fix
    them (or invoke systematic debugging) before moving on.

    ### 2. `/opsx:verify` — verify implementation matches the artifacts, then address findings

    Invoke the `opsx:verify` skill. Read every finding it reports.

    - For each finding, fix the underlying issue (code or artifact), then re-run
      `/opsx:verify`.
    - Repeat until verify reports no outstanding findings.

    **Gate:** Do not proceed while verify still reports unresolved findings.

    ### 3. `/opsx:sync` — sync delta specs into the main specs

    Invoke the `opsx:sync` skill to fold the change's delta specs into
    `openspec/specs/`.

    ### 4. `/opsx:archive` — archive the completed change

    Invoke the `opsx:archive` skill. This finalizes the change and moves it into the
    archive. (Note: per project rules, an active `openspec/changes/` entry blocks
    merge, so archiving here is required before the PR can land.)

    ### 5. Branch or commit

    Check the current branch (`git rev-parse --abbrev-ref HEAD`).

    - **If on `main`:** invoke the `gs-create` skill to create a new stacked branch
      (never commit directly to `main` — project rule).
    - **If on a feature branch already:** invoke the `git-commit` skill to commit the
      work onto the current branch.

    Either way, ensure all the change's edits (implementation + archived specs) are
    committed before submitting.

    ### 6. `/gs-submit` — open the PR

    Invoke the `gs-submit` skill to push the branch and open (or update) the pull
    request with a title and body derived from the change.

    ### 7. `/wait-for-coderabbit-review` — get the review

    Invoke the `wait-for-coderabbit-review` skill to ensure the PR receives its
    CodeRabbit (and Gemini) review, pacing through any rate limits until reviews land.

    ### 8. `/address-gs-comments` — address the feedback

    Invoke the `address-gs-comments` skill to work through every unresolved review
    comment across the stack, branch-by-branch.

    ## Rules

    - **Run steps strictly in order.** Each step depends on the previous one having
      succeeded.
    - **Each step is a real skill invocation**, not an inline reimplementation.
    - **Honor the gates.** Steps 1 and 2 have explicit completion gates — do not
      advance past a red gate.
    - **Stop for genuine decisions only.** If a step needs human input (an ambiguous
      fix, a design choice, a destructive action), pause and ask; otherwise keep the
      pipeline moving.
    - **Follow project rules throughout:** no commits to `main`, no `--no-verify`,
      TDD for production changes, and `task fmt`/`task lint`/`task test` clean before
      reporting any step complete.
    - **Report progress** after each step (which step finished, what's next) and a
      final summary when the pipeline completes or stops.
  '';
in
{
  config = lib.mkIf enable (addSkill "get-it-done" skillFile);
}
