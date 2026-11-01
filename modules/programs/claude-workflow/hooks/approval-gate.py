#!/usr/bin/env python3
"""Claude Code PreToolUse hook: block gated tool calls unless the user's own most
recent message contains that gate's approval phrase.

The phrase is read from the session transcript, so Claude cannot approve on your
behalf: only a message you typed counts (tool results, system reminders and
compaction summaries are ignored). Approval lasts for the turn that follows it.

GATES below are the built-in gates; more are read from a JSON list in approval-gate.json
next to this hook (or $APPROVAL_GATE_CONFIG). A gate fires when any of its rules matches the tool call:
  tools  regex, full match against the tool name (MCP tools are named
         mcp__<server>__<tool>, plugin MCPs mcp__plugin_<plugin>_<server>__<tool>)
  bash   list of regexes searched in a Bash command
  match  list of substrings (`~` expanded) searched in every string of the tool input
"""
import json
import os
import re
import sys

CMD = r"(?:^|[\n;&|(]|&&|\|\|)\s*(?:sudo\s+)?"
GH = CMD + r"gh\s+"

GATES = [
    {
        "name": "Slack post",
        "tools": r"mcp__plugin_slack_Slack__slack_(send_message|schedule_message|create_canvas|update_canvas)",
        "bash": [
            r"hooks\.slack\.com",
            r"slack\.com/api/(?:chat\.postMessage|chat\.scheduleMessage|files\.upload)",
        ],
        "phrase": "operation approved",
    },
]

CONFIG = os.environ.get(
    "APPROVAL_GATE_CONFIG",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "approval-gate.json"),
)
try:
    with open(CONFIG) as fh:
        GATES = GATES + json.load(fh)
except (OSError, ValueError):
    pass

STRIP = re.compile(r"<(system-reminder|local-command-\w+|command-\w+)>.*?</\1>", re.DOTALL)


def deny(reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for v in value.values():
            yield from strings(v)
    elif isinstance(value, list):
        for v in value:
            yield from strings(v)


def matches(gate, tool, tool_input):
    if gate.get("tools") and re.fullmatch(gate["tools"], tool):
        return True
    if tool == "Bash":
        command = tool_input.get("command", "")
        if any(re.search(p, command) for p in gate.get("bash", [])):
            return True
    haystack = "\n".join(strings(tool_input))
    return any(n in haystack or os.path.expanduser(n) in haystack for n in gate.get("match", []))


def message_text(entry):
    if entry.get("type") != "user" or entry.get("isMeta") or entry.get("isCompactSummary"):
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
    return STRIP.sub("", text).strip() or None


def last_user_message(path):
    try:
        with open(path, "r", errors="replace") as fh:
            lines = fh.readlines()
    except (OSError, TypeError):
        return None
    for line in reversed(lines):
        try:
            text = message_text(json.loads(line))
        except ValueError:
            continue
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
    gate = next((g for g in GATES if matches(g, tool, tool_input)), None)
    if gate is None:
        return

    latest = last_user_message(data.get("transcript_path")) or ""
    if re.search(re.escape(gate["phrase"]), latest, re.IGNORECASE):
        return

    payload = json.dumps(tool_input, indent=2)
    if len(payload) > 1500:
        payload = payload[:1500] + "\n... (truncated)"
    deny(
        "Blocked %s (%s): it requires the user's explicit \"%s\" in their own most recent "
        "message. Show the user exactly what this call would do and ask them to confirm "
        "with that exact phrase:\n\n%s" % (gate["name"], tool, gate["phrase"], payload)
    )


if __name__ == "__main__":
    main()
