# Approval required before posting to Slack or GitHub

Before sending any message to Slack (channel message, thread reply, DM) or posting any
comment on GitHub/GitHub Enterprise (PR comment, issue comment, review comment), draft the
content and show it to the user first. Do not call the send/post tool until the user has
explicitly approved that specific draft.

This applies to every post, not just the first one in a conversation — approval for one
message does not carry over to the next. If new information changes the message (e.g. a
correction, a follow-up), draft the new version and get approval again before sending.

**Scope**: Slack sends (`slack_send_message`, `slack_schedule_message`, canvas edits that
post) and GitHub/GHE comment-creating actions (PR comments, issue comments, review
comments, gists). Read-only actions (reading threads, searching, fetching issues) are not
covered and don't need approval.

**How to ask**: show the exact text you intend to send, then ask for confirmation or edits
— don't just describe what you plan to say.
