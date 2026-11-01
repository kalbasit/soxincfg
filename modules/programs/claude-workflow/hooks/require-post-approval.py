#!/usr/bin/env python3
"""Fail-closed gate on posting to GitHub and other configured tools: require fresh, user-typed approval.

Enforces ~/.claude/rules/approval-before-posting.md at the tool level. A post is allowed
only when the most recent genuine user message in the transcript is an approval -- which
the model cannot write on the user's behalf. Anything else is denied, with the payload
echoed back so the draft can be shown to the user instead.
"""
import json
import os
import re
import sys

# MCP tools that actually publish, plus extra shell patterns, are read from a JSON file
# next to this hook ({"tools": [...], "bash": [{"pattern": ..., "label": ...}]}), so each
# machine can gate its own publishing tools. Draft-only tools should stay out of it:
# drafting is the safe path.
CONFIG = os.environ.get(
    "REQUIRE_POST_APPROVAL_CONFIG",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "require-post-approval.json"),
)


def load_config(path):
    try:
        with open(path) as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return {}


_config = load_config(CONFIG)
GATED_TOOLS = set(_config.get("tools", []))

# Shell forms that create a comment, review, or gist. The gh patterns are anchored to a
# command position, so the same text quoted inside an argument, heredoc, or grep pattern
# does not trip the gate.
_CMD = r"(?:^|[\n;&|(]|&&|\|\|)\s*(?:sudo\s+)?"
_GH = _CMD + r"gh\s+"
GATED_BASH = [
    (_GH + r"(?:pr|issue)\s+comment\b", "gh pr/issue comment"),
    (_GH + r"pr\s+review\b", "gh pr review"),
    (_GH + r"gist\s+create\b", "gh gist create"),
    (
        _GH
        + r"api\b(?=[^\n;&|]*(?:comments|reviews))"
        + r"(?=[^\n;&|]*(?:-X\s*POST|--method\s*POST|-f\s|--field))",
        "gh api POST to a comments/reviews endpoint",
    ),
] + [(b["pattern"], b["label"]) for b in _config.get("bash", [])]

# Approval must appear in the user's own most recent message.
#
# DIRECTIVE: an unambiguous instruction to post; counts at any message length.
# ASSENT_ONLY: a bare assent, which counts only when it IS the whole message -- a
#   sentence that merely contains "approved" is discussion, not approval.
# VETO: checked first; withholding always wins over anything else in the message.
DIRECTIVE = re.compile(
    r"(#approve-post"
    r"|\boperation\s+approv\w*"
    r"|\b(?:post|send|publish|reply|comment)\s+(?:it|that|this|them|those|away|the\s+draft)\b"
    r"|\byes[,!]?\s+(?:post|send|publish|reply|go)\b)",
    re.IGNORECASE,
)
_FILLER = (
    r"(?:it's|that's|ok(?:ay)?|yes|yep|yeah|sure|fine|cool|great|perfect|nice|please|now|then"
    r"|thanks?|ty|and|but|to|it)"
)
_ASSENT = (
    r"(?:approved?|confirmed|publish(?:ed)?|lgtm|ship\s+it|go\s+ahead|go\s+for\s+it|do\s+it"
    r"|looks?\s+good|sounds?\s+good|send\s+it|all\s+good)"
)
_SEP = r"[\s,.!;:-]*"
ASSENT = re.compile(_ASSENT, re.IGNORECASE)
ASSENT_ONLY = re.compile(
    "%s(?:(?:%s|%s)%s)+" % (_SEP, _ASSENT, _FILLER, _SEP), re.IGNORECASE
)
VETO = re.compile(
    r"(\b(?:do\s*n[o']?t|don't|never|no)\s+(?:post|send|publish|reply|comment)"
    r"|\bnot\s+approved\b|\bhold\s+off\b|\bwait\b|\bdraft\s+(?:it|first|only)\b"
    r"|\bshow\s+me\s+first\b|\bwithout\s+(?:showing|asking)\b)",
    re.IGNORECASE,
)

STRIP = re.compile(r"<(system-reminder|local-command-\w+|command-\w+)>.*?</\1>", re.DOTALL)


def approved(text):
    if VETO.search(text):
        return False
    if DIRECTIVE.search(text):
        return True
    return bool(ASSENT_ONLY.fullmatch(text)) and bool(ASSENT.search(text))


def deny(reason):
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    sys.exit(0)


def message_text(entry):
    """Plain text of a transcript entry, or None if it is not a genuine user message."""
    if entry.get("type") != "user":
        return None
    if entry.get("isMeta") or entry.get("isCompactSummary"):
        return None
    content = (entry.get("message") or {}).get("content")
    if isinstance(content, str):
        text = content
    elif isinstance(content, list):
        if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in content):
            return None
        text = " ".join(
            b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"
        )
    else:
        return None
    text = STRIP.sub("", text).strip()
    return text or None


def last_user_message(path):
    if not path or not os.path.exists(path):
        return None
    try:
        with open(path, "r", errors="replace") as fh:
            lines = fh.readlines()
    except OSError:
        return None
    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        text = message_text(entry)
        if text is not None:
            return text
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return

    tool = data.get("tool_name", "")
    tool_input = data.get("tool_input") or {}

    if tool == "Bash":
        payload = tool_input.get("command", "")
        what = next((label for pattern, label in GATED_BASH if re.search(pattern, payload)), None)
    elif tool in GATED_TOOLS:
        what = tool.rsplit("__", 1)[-1]
        payload = json.dumps(tool_input, indent=2)
    else:
        return

    if not what:
        return

    latest = last_user_message(data.get("transcript_path"))

    if latest is None:
        deny(
            "Blocked %s: could not read the transcript to confirm the user approved this "
            "post. Show the exact text you intend to send and wait for explicit approval." % what
        )

    if not approved(latest):
        preview = payload if len(payload) <= 1500 else payload[:1500] + "\n... (truncated)"
        deny(
            "Blocked %s: the user's most recent message is not an approval of a draft, so this "
            "post has not been approved (~/.claude/rules/approval-before-posting.md -- approval "
            "is required for every post and never carries over).\n\nShow this exact content to "
            "the user and wait for them to approve it:\n\n%s" % (what, preview)
        )


if __name__ == "__main__":
    main()
