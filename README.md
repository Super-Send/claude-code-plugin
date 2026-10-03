# SuperSend plugin for Claude Code

Run cold email from Claude Code: sign in, get sending inboxes, write and launch campaigns, work through replies, and track results. Everything goes through the [`supersend` CLI](https://docs.supersend.io/docs/cli).

## Install

```bash
claude plugin marketplace add Super-Send/claude-code-plugin
claude plugin install supersend@supersend
```

Then start Claude Code and say "help me with cold email". Claude signs you in with `supersend login` (a link and a code to approve in SuperSend; no API keys to copy).

## What's inside

- **`cold-email` skill:** the playbook Claude follows. It covers sign-in, account setup (card and free trial, buying inboxes through SuperSend or connecting your own, warmup), writing the sequence, review and launch, daily replies, results, and deliverability. Claude asks before anything that emails people or costs money.
- **Session brief:** when a new session starts, `supersend status` adds unread replies, campaigns, inboxes and to-dos to Claude's context. Turn it off with the plugin's **Session brief** setting in `/config`.
- **`scripts/supersend`:** runs your installed `supersend` CLI, or the npm package through `npx` when it isn't installed.

## Requirements

- Node.js 20+ (for `npx` / the CLI)
- A SuperSend account (created during `supersend login` if you don't have one)

## Develop

The same playbook, for any agent, is served at [supersend.io/agents.md](https://supersend.io/agents.md) (built from `skills/cold-email/SKILL.md`; keep its `run-cli` markers). This repository is both the plugin and its marketplace. Its source lives in SuperSend's main repository (`claude-plugin/`), next to the CLI it drives, and is published here. Validate a checkout with:

```bash
npx @anthropic-ai/claude-code plugin validate --strict .
```

Questions or problems: contact@supersend.io.
