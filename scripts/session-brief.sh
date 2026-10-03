#!/usr/bin/env bash
# SessionStart hook: a short SuperSend status in Claude's context at the start of a new session.
# It never blocks the session: when anything goes wrong it prints at most one line.
[ "${CLAUDE_PLUGIN_OPTION_SESSION_BRIEF:-true}" = "false" ] && exit 0
dir="$(cd "$(dirname "$0")" && pwd)"
if brief="$(SUPERSEND_OUTPUT=text "$dir/supersend" status 2>/dev/null)" && [ -n "$brief" ]; then
  printf 'SuperSend (cold email) status at session start. Bring it up only when it is relevant or the user asks:\n%s\n' "$brief"
else
  echo 'SuperSend (cold email): not signed in or not reachable. If the user wants cold email, run `supersend whoami`, and `supersend login` if needed.'
fi
exit 0
