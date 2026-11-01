#!/usr/bin/env python3
"""End-to-end matrix for require-post-approval.py: feed it hook payloads, assert allow/deny."""
import json
import os
import subprocess
import sys
import tempfile

HOOK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "require-post-approval.py")
TMP = tempfile.mkdtemp()
TRANSCRIPT = os.path.join(TMP, "t.jsonl")

# An example config: one publishing MCP tool and one extra shell pattern.
PUB = "mcp__example__"
CONFIG = os.path.join(TMP, "config.json")
with open(CONFIG, "w") as fh:
    json.dump(
        {
            "tools": [PUB + "publish"],
            "bash": [
                {
                    "pattern": r"wiki\.example\.com/api/(?=[^\n;&|]*(?:-X\s*(?:POST|PUT|DELETE)|--data|-d\s))",
                    "label": "wiki REST write",
                }
            ],
        },
        fh,
    )
ENV = dict(os.environ, REQUIRE_POST_APPROVAL_CONFIG=CONFIG)


def write_transcript(last_user_text):
    """Last genuine user message, followed by meta + tool_result noise that must be skipped."""
    rows = [
        {"type": "user", "message": {"content": "something earlier"}},
        {"type": "assistant", "message": {"content": [{"type": "text", "text": "draft shown"}]}},
        {"type": "user", "message": {"content": last_user_text}},
        {"type": "user", "isMeta": True,
         "message": {"content": "<system-reminder>noise</system-reminder>"}},
        {"type": "user", "message": {"content": [{"type": "tool_result", "content": "x"}]}},
    ]
    with open(TRANSCRIPT, "w") as fh:
        fh.write("\n".join(json.dumps(r) for r in rows) + "\n")


def run(tool, tool_input):
    payload = json.dumps(
        {"tool_name": tool, "transcript_path": TRANSCRIPT, "tool_input": tool_input}
    )
    out = subprocess.run(
        [sys.executable, HOOK], input=payload, capture_output=True, text=True, env=ENV
    ).stdout.strip()
    return "DENY" if out else "ALLOW"


SLACK = "mcp__plugin_slack_Slack__"

# (label, tool, tool_input, expected when NOT approved, expected when approved)
CASES = [
    ("configured publish",   PUB + "publish",                     {"owner": "o"},                  "DENY", "ALLOW"),
    # draft-only, read-only and unconfigured tools are never gated
    ("slack DRAFT",          SLACK + "slack_send_message_draft",  {"text": "hi"},                  "ALLOW", "ALLOW"),
    ("unconfigured draft",   PUB + "draft",                       {"k": "1"},                      "ALLOW", "ALLOW"),
    ("unconfigured list",    PUB + "list",                        {},                              "ALLOW", "ALLOW"),
]

BASH_CASES = [
    ("gh pr comment",        "gh pr comment 1 --body hi",                                    "DENY", "ALLOW"),
    ("gh issue comment",     "gh issue comment 5 --body hi",                                 "DENY", "ALLOW"),
    ("gh pr review",         "gh pr review 1 --approve",                                     "DENY", "ALLOW"),
    ("gh gist create",       "gh gist create notes.md",                                      "DENY", "ALLOW"),
    ("gh api POST comment",  "gh api -X POST repos/o/r/issues/1/comments -f body=hi",         "DENY", "ALLOW"),
    ("slack webhook curl",   "curl -X POST https://hooks.slack.com/services/x -d @p.json",    "ALLOW", "ALLOW"),
    ("chained gh comment",   "cd /tmp && gh pr comment 1 --body hi",                          "DENY", "ALLOW"),
    ("wiki REST POST",       "curl -X POST https://wiki.example.com/api/content -d @p.json",  "DENY", "ALLOW"),
    ("wiki REST GET",        "curl https://wiki.example.com/api/content/1",                   "ALLOW", "ALLOW"),
    # read-only / unrelated / quoted-mention must always pass
    ("gh api GET comments",  "gh api repos/o/r/issues/1/comments",                            "ALLOW", "ALLOW"),
    ("gh pr view",           "gh pr view 555447 --json number",                              "ALLOW", "ALLOW"),
    ("plain ls",             "ls -la",                                                        "ALLOW", "ALLOW"),
    ("git push",             "git push origin HEAD",                                          "ALLOW", "ALLOW"),
    ("quoted mention",       "echo 'run gh pr comment later' > notes.txt",                    "ALLOW", "ALLOW"),
    ("grep for the string",  "grep -rn 'gh gist create' docs/",                               "ALLOW", "ALLOW"),
]

NOT_APPROVED = [
    "add a hook to ensure drafts are approved before posting things anywhere",
    "operation approved? no, wait",
]
APPROVED = ["post it", "operation approved", "operation approvate", "Operation Approvd, thanks"]
MESSAGES = [(m, 3) for m in NOT_APPROVED] + [(m, 4) for m in APPROVED]

failures = 0
for msg, col in MESSAGES:
    write_transcript(msg)
    print("\n=== last user message: %r ===" % (msg[:60],))
    for case in CASES:
        label, tool, tool_input = case[0], case[1], case[2]
        want, got = case[col], run(tool, tool_input)
        failures += got != want
        print("  %-4s %-22s got=%-5s want=%s" % ("ok" if got == want else "FAIL", label, got, want))
    for case in BASH_CASES:
        label, command = case[0], case[1]
        want, got = case[col - 1], run("Bash", {"command": command})
        failures += got != want
        print("  %-4s %-22s got=%-5s want=%s" % ("ok" if got == want else "FAIL", label, got, want))

# transcript unreadable -> fail closed
print("\n=== transcript missing (must fail closed) ===")
payload = json.dumps(
    {"tool_name": PUB + "publish", "transcript_path": "/nope.jsonl",
     "tool_input": {"text": "hi"}}
)
out = subprocess.run(
    [sys.executable, HOOK], input=payload, capture_output=True, text=True, env=ENV
).stdout.strip()
got = "DENY" if out else "ALLOW"
failures += got != "DENY"
print("  %-4s %-22s got=%-5s want=DENY" % ("ok" if got == "DENY" else "FAIL", "no transcript", got))

total = len(MESSAGES) * (len(CASES) + len(BASH_CASES)) + 1
print("\n%d/%d passed" % (total - failures, total))
sys.exit(1 if failures else 0)
