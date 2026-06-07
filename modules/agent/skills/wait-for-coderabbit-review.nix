{
  addSkill,
  enable,
  ...
}:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cr-review-status = pkgs.writeShellScript "cr-review-status.sh" ''
    # Survey CodeRabbit + Gemini review state for a set of PRs and report the single
    # authoritative CodeRabbit retry deadline.
    #
    # Per PR it prints:
    #   PR <n> | gemini=<0|1> coderabbit=<0|1> | <that PR's own rate-limit window>
    #
    # Then a SHARED LIMIT summary. CodeRabbit's review limit is per-developer/org and
    # therefore SHARED across all your PRs: once ANY PR's rate-limit comment is
    # refreshed, every PR is throttled until that deadline. A PR whose own (older)
    # rate-limit comment has "elapsed" is NOT actually open if a newer trigger/review
    # has since consumed the budget. So pace off the SHARED LIMIT line (the most
    # recently refreshed rate-limit), not the per-PR windows.
    #
    # - coderabbit=1 means a real review exists (Walkthrough / "Actionable comments posted").
    # - A deadline is comment.updated_at + the stated "available in X" (the comment is
    #   edited in place on each re-trigger, so updated_at is authoritative, not created_at).
    #
    # Usage:
    #   cr-review-status.sh <owner/repo> <pr> [<pr> ...]
    #   cr-review-status.sh <owner/repo> --open          # all open PRs
    # Example:
    #   cr-review-status.sh kalbasit/ncps 1358 1359 1360
    set -euo pipefail

    repo="''${1:?usage: cr-review-status.sh <owner/repo> <pr...|--open>}"
    shift

    if [ "''${1:-}" = "--open" ]; then
      mapfile -t prs < <(${pkgs.gh}/bin/gh pr list -R "$repo" --state open --limit 100 --json number --jq '.[].number')
    else
      prs=("$@")
    fi

    now=$(${pkgs.coreutils}/bin/date -u +%s)
    echo "now (UTC): $(${pkgs.coreutils}/bin/date -u +%Y-%m-%dT%H:%M:%SZ)"

    newest_updated=0
    newest_deadline=0
    newest_pr="-"

    for pr in "''${prs[@]}"; do
      gemini=$(${pkgs.gh}/bin/gh pr view "$pr" -R "$repo" --json comments,reviews --jq \
        '((.comments + (.reviews // [])) | map(select(.author.login=="gemini-code-assist")) | length) > 0 | if . then 1 else 0 end' 2>/dev/null || echo 0)
      cr=$(${pkgs.gh}/bin/gh pr view "$pr" -R "$repo" --json comments --jq \
        '[.comments[] | select(.author.login=="coderabbitai") | select(.body|test("Walkthrough|Actionable comments posted"))] | length > 0 | if . then 1 else 0 end' 2>/dev/null || echo 0)

      window="-"
      if [ "$cr" = "0" ]; then
        # latest rate-limit comment as "updated_epoch deadline_epoch", else empty
        read -r u d < <(${pkgs.gh}/bin/gh api "repos/$repo/issues/$pr/comments" --paginate --jq \
          '.[] | select(.user.login=="coderabbitai[bot]") | select(.body|test("available in")) | {u: .updated_at, w: ((.body|capture("available in (?<w>[0-9]+ minutes and [0-9]+ seconds|[0-9]+ seconds|[0-9]+ minutes)").w) // "0")}' 2>/dev/null \
          | ${pkgs.jq}/bin/jq -rs '
              if length==0 then "0 0"
              else (sort_by(.u)|last) as $c
                | ($c.u|fromdateiso8601) as $u
                | ($c.w|[scan("[0-9]+")]|map(tonumber)) as $p
                | (if ($p|length)==2 then $p[0]*60+$p[1] elif ($c.w|test("minute")) then $p[0]*60 else ($p[0]//0) end) as $s
                | "\($u) \($u+$s)"
              end' 2>/dev/null || echo "0 0")
        if [ "''${u:-0}" != "0" ]; then
          if [ "$d" -le "$now" ]; then window="own window elapsed @ $(${pkgs.coreutils}/bin/date -u -d "@$d" +%H:%M:%SZ)"; else window="own wait $((d-now))s @ $(${pkgs.coreutils}/bin/date -u -d "@$d" +%H:%M:%SZ)"; fi
          if [ "$u" -gt "$newest_updated" ]; then newest_updated="$u"; newest_deadline="$d"; newest_pr="$pr"; fi
        fi
      fi

      printf "PR %s | gemini=%s coderabbit=%s | %s\n" "$pr" "$gemini" "$cr" "$window"
    done

    echo "----"
    if [ "$newest_updated" = "0" ]; then
      echo "SHARED LIMIT: no fresh rate-limit comment found — trigger ONE PR and re-run to learn the authoritative deadline."
    elif [ "$newest_deadline" -le "$now" ]; then
      echo "SHARED LIMIT: OPEN (newest rate-limit was PR $newest_pr, refreshed $(${pkgs.coreutils}/bin/date -u -d "@$newest_updated" +%H:%M:%SZ)). Trigger ONE PR now, then re-run."
    else
      echo "SHARED LIMIT: throttled until $(${pkgs.coreutils}/bin/date -u -d "@$newest_deadline" +%H:%M:%SZ) ($((newest_deadline-now))s) — governed by PR $newest_pr. Wait, then trigger ONE PR."
    fi
  '';

  skillFile = ''
    ---
    name: wait-for-coderabbit-review
    description: 'Use when CodeRabbit PR reviews are rate-limited ("Review limit
      reached" / "out of usage credits") and you must re-trigger @coderabbitai review
      across one or more open PRs, pacing to the wait CodeRabbit states, until every
      PR has both CodeRabbit and Gemini reviews. Examples: "wait for coderabbit to
      review the stack", "coderabbit hit the review limit, keep retrying", "loop until
      all PRs are reviewed by gemini and coderabbit".'
    ---

    # Wait For CodeRabbit Review

    ## Overview

    CodeRabbit enforces an hourly per-developer review limit. When you open many PRs
    at once (e.g. a git-spice stack), the later ones get a **"Review limit reached"**
    comment instead of a review. It is **not ignoring you** — it replies to every
    `@coderabbitai review` within seconds; it is genuinely throttled and reviews
    trickle back ~**one per window** (~10–18 min; the window grows under bursts).

    **Core insight: trigger ONE PR per open window, not all at once.** Bursting piles
    up pending requests and inflates the backoff (observed 10→14→18 min) while still
    only clearing ~1 review per window. One-at-a-time, in an open window, CodeRabbit
    replies **"Review triggered"** (accepted) instead of **"Review limit reached"**.

    This skill pairs with `/loop` dynamic mode: each iteration triggers the next PR
    and schedules the next wake to the time CodeRabbit states.

    ## When To Use

    - A PR (or stack of PRs) shows a CodeRabbit "Review limit reached" comment.
    - You need every open PR reviewed by both `coderabbitai` and `gemini-code-assist`
      before a follow-up step (e.g. `/address-gs-comments`).
    - The user asks to "wait for / keep retrying coderabbit until reviewed".

    Not for: a single PR you can just push a commit to (a push re-triggers review
    without consuming a manual trigger).

    ## Key Facts

    - **The limit is SHARED across all your PRs** (per-developer/org), not per-PR.
      Once any PR's rate-limit comment is refreshed, **every** PR is throttled until
      that one deadline. The authoritative wait is the **most recently refreshed**
      rate-limit comment across the stack — the `${cr-review-status}` **SHARED LIMIT**
      line. A PR whose own older rate-limit "elapsed" is NOT actually open if a newer
      trigger/review has since consumed the budget.
    - **Bot logins:** `coderabbitai` and `gemini-code-assist` (via `gh pr view --json`;
      via `gh api .../comments` the login is `coderabbitai[bot]`).
    - **Real review present** = a `coderabbitai` comment matching `Walkthrough` or
      `Actionable comments posted`. The rate-limit comment matches `Review limit reached`.
    - **Retry deadline** = the rate-limit comment's `updated_at` + the stated
      "More reviews will be available in **X minutes and Y seconds**". CodeRabbit
      **edits the comment in place** on each re-trigger, so use `updated_at`, NOT
      `created_at` (created_at is stale and will mislead you).
    - **The command-ack is NOT proof of a review.** A trigger gets an instant
      "Action performed: Review triggered." / "Review finished." — but if still
      throttled, CodeRabbit *also* posts/refreshes a rate-limit comment alongside it.
      Always confirm via the real-review check (above), not the ack. Only conclude a
      PR is done when `coderabbit=1`.

    ## Workflow

    1. **Survey state.** Run `${cr-review-status} <owner/repo> <pr...>` (or `--open`).
       Read the **SHARED LIMIT** line at the bottom — it is the authoritative pacing
       signal. Ignore per-PR "own window elapsed" when SHARED LIMIT says throttled.
    2. **When SHARED LIMIT is OPEN, trigger exactly ONE not-yet-reviewed PR**, then
       re-check — do not fan out:
       ```bash
       gh pr comment <pr> -R <owner/repo> --body "@coderabbitai review"
       ```
       Triggering several at once just piles up pending requests and inflates the
       backoff while still clearing ~one per window. After triggering, re-run the
       survey: either the PR's review lands (`coderabbit=1`) or a fresh rate-limit
       appears that becomes the new SHARED LIMIT.
    3. **Pace to the SHARED LIMIT deadline (dynamic `/loop`).** As the last action of
       the turn, `ScheduleWakeup` for that deadline plus a small buffer (~30–60 s).
       Slightly **over-wait** rather than under-wait: an early trigger gets re-limited
       and pushes the deadline out. There is no Monitor for GitHub comments, so polling
       on the deadline is the wake signal.
    4. **Stop condition:** every target PR has `coderabbit=1` AND `gemini=1`. Then run
       the follow-up the user asked for (commonly `/address-gs-comments`) and end the
       loop (omit `ScheduleWakeup`; `PushNotification` the outcome if unattended).

    ## Common Mistakes

    | Mistake | Fix |
    | --- | --- |
    | Trusting a PR's stale "window elapsed" | The limit is shared; pace off the SHARED LIMIT line, not per-PR windows |
    | Bursting `@coderabbitai review` on all PRs each round | One per open window; bursts inflate the backoff |
    | Taking the trigger ack as proof of review | "Review triggered/finished" can come *with* a fresh rate-limit; confirm `coderabbit=1` |
    | Computing the deadline from `created_at` | Use `updated_at` — the rate-limit comment is edited in place |
    | Re-triggering before the window opens | Wait for the SHARED LIMIT deadline; early posts reset the countdown |
    | Treating the instant reply as "ignored" | It always replies in ~4 s; read the body for limit vs accepted |
    | Concluding "stuck" on "out of usage credits" | Reviews still trickle ~1/window; only stop if truly frozen — confirm with the user |
    | Waiting on a fixed interval | Pace to the stated time; the window length drifts (often grows) |

    ## Notes

    - This is slow by design under the limit: ~1 review per ~15–18 min window, so a
      stack of N throttled PRs can take N windows (often >1 h). Confirm with the user
      before committing to a long unattended loop, and surface the
      "out of usage credits" flag so they can top up if they prefer.
    - The helper script `${cr-review-status}` surveys CodeRabbit and Gemini review
      state across one or more PRs.
  '';
in
{
  config = lib.mkIf enable (addSkill "wait-for-coderabbit-review" skillFile);
}
