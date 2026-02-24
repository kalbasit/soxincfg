{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.soxincfg.programs.claude-code;

  get-code-scanning-alert = pkgs.writeShellScript "get-code-scanning-alert.sh" ''
    set -euo pipefail

    if [[ "$#" -lt 1 ]]; then
      echo "Error: No alert number provided." >&2
      echo "Usage: $0 <alert-number>" >&2
      exit 1
    fi

    ALERT_NUMBER=$1

    # Infer repo owner and name
    REPO_INFO=$(${lib.getExe pkgs.gh} repo view --json owner,name)
    OWNER=$(echo "$REPO_INFO" | jq -r .owner.login)
    NAME=$(echo "$REPO_INFO" | jq -r .name)

    # Fetch alert and format output
    ${lib.getExe pkgs.gh} api "repos/$OWNER/$NAME/code-scanning/alerts/$ALERT_NUMBER" | \
      jq '{
        number: .number,
        state: .state,
        rule: .rule.description,
        severity: .rule.security_severity_level,
        file: .most_recent_instance.location.path,
        start_line: .most_recent_instance.location.start_line,
        end_line: .most_recent_instance.location.end_line,
        message: .most_recent_instance.message.text
      }'
  '';

  resolve-code-scanning-alert = pkgs.writeShellScript "resolve-code-scanning-alert.sh" ''
    set -euo pipefail

    if [[ "$#" -lt 2 ]]; then
      echo "Error: Missing arguments." >&2
      echo "Usage: $0 <alert-number> <dismissed-reason>" >&2
      echo "Valid reasons: 'false positive', 'won't fix', 'used in tests'" >&2
      exit 1
    fi

    ALERT_NUMBER=$1
    REASON=$2

    # Validate reason
    if [[ "$REASON" != "false positive" && "$REASON" != "won't fix" && "$REASON" != "used in tests" ]]; then
      echo "Error: Invalid dismissed reason '$REASON'." >&2
      echo "Valid reasons: 'false positive', 'won't fix', 'used in tests'" >&2
      exit 1
    fi

    # Infer repo owner and name
    REPO_INFO=$(${lib.getExe pkgs.gh} repo view --json owner,name)
    OWNER=$(echo "$REPO_INFO" | jq -r .owner.login)
    NAME=$(echo "$REPO_INFO" | jq -r .name)

    # Patch the alert state to dismissed
    ${lib.getExe pkgs.gh} api --method PATCH "repos/$OWNER/$NAME/code-scanning/alerts/$ALERT_NUMBER" \
      -f state=dismissed \
      -f dismissed_reason="$REASON" \
      --silent

    echo "Successfully dismissed alert $ALERT_NUMBER as '$REASON'."
  '';

  skillFile = ''
    ---
    name: address-code-scanning-alert
    description: Fetch details for a specific code scanning alert and resolve it
    ---

    # Address Code Scanning Alert

    This workflow guides the agent through fetching the details of a specific GitHub code scanning alert, addressing the underlying vulnerability, and dismissing or resolving the alert on GitHub.

    ## Workflow Steps

    ### 1. Fetch Alert Details

    Use the helper script to fetch the context of a specific code scanning alert. You must provide the alert number.

    ```bash
    # Fetch details for alert number 123
    ${get-code-scanning-alert} 123
    ```

    The script outputs a JSON object containing the alert's `number`, `state`, `rule` (description), `severity`, and the `most_recent_instance` details including `file`, `start_line`, `end_line`, and the `message`.

    ### 2. Address the Alert

    Using the data retrieved:

    1. **Locate the vulnerability**: Examine the `file` and `start_line`/`end_line` provided in the JSON output.
    2. **Analyze and fix**: Understand the `rule` and `message` to implement the necessary security fix or determine if it is a false positive.
    3. **Verify**: Run tests, linters, or build commands to ensure the fix is correct.
    4. **Commit**: Once the fix is verified, commit the change using a descriptive commit message referencing the alert.

    ```bash
    git commit -am "fix: address security alert regarding <vulnerability context>"
    ```

    ### 3. Resolve or Dismiss on GitHub

    If you fixed the code, pushing the commit to the PR or default branch will automatically resolve the alert during the next code scanning run.

    However, if you determined the alert is a false positive, won't be fixed, or is used in tests, you must dismiss it using the resolution helper script:

    ```bash
    # Dismiss an alert. Valid reasons: "false positive", "won't fix", or "used in tests"
    ${resolve-code-scanning-alert} 123 "false positive"
    ```

    ### 4. Final Review

    Ensure the changes are pushed and monitor the GitHub Actions or code scanning status to confirm the alert drops off the open list.

    ## Internal details

    The script `${get-code-scanning-alert}` uses the `gh api` to fetch a specific alert via the REST API endpoint `/repos/{owner}/{repo}/code-scanning/alerts/{alert_number}`.
    The script `${resolve-code-scanning-alert}` uses the `gh api` with the `PATCH` method to update the alert state to `dismissed` with a specified `dismissed_reason`.
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.file.".claude/skills/address-code-scanning-alert/SKILL.md".text = skillFile;
  };
}
