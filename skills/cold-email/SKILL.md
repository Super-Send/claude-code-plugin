---
name: cold-email
description: Run cold email (and LinkedIn outreach) with SuperSend from the terminal. Set up an account, get sending inboxes, write and launch a campaign, work through replies, and track results. Use when the user wants to do cold email or outbound, send an email sequence, check replies, see how a campaign is doing, or fix deliverability.
---

# Cold email with SuperSend

<!-- run-cli:start (supersend.io/agents.md replaces this block with instructions for any agent) -->
You run everything through the `supersend` CLI. Run it as:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/supersend" <command>
```

(Below, `supersend` means that.)
<!-- run-cli:end -->

Output is JSON when you run it, so parse it. `supersend docs` lists every command with an example; `supersend docs <group>` shows one group. `supersend api <path>` reaches any API endpoint the commands don't cover (always GET unless `-X`).

## Rules

- **Ask before anything that contacts people or costs money:** launching a campaign, sending a reply, running a placement test (uses credits), buying domains or inboxes. Show exactly what will happen, then wait for a yes.
- **Links:** when a command returns a link for the user (sign in, add a card, checkout, connect an inbox), give it to them exactly as returned. They open it; you can't.
- **Never ask for or paste API keys or passwords.** Sign-in is `supersend login`.
- SuperSend doesn't find leads. If the user has no list, ask for a CSV or another lead source they use.

## 1. Sign in

Run `supersend whoami`. If it fails with "Not signed in", run `supersend login`. It prints a link and a code and exits: give the user the link, ask them to approve the code shown on the page, then run `supersend login` again to finish.

## 2. Get the account ready

Run `supersend setup status`. `next_steps` lists what's missing, in order, and who does each step.

- **Card / free trial:** give the user the link (7-day free trial).
- **Inboxes:** ask whether they want to **buy new inboxes through SuperSend** or **use inboxes they already have**.
  - Buy: plan 2-3 look-alike domains (for acme.com: tryacme.com, getacme.com, never the main domain) with 2-3 inboxes each, show the cost, then `supersend setup inbox-checkout --file plan.json` and give them the checkout link. Bought inboxes arrive connected and warming up on their own (24-48 hours); nothing else to do.
  - Their own: give them the connect link from `setup status`.
- **Warmup:** inboxes need about 14 days of warmup before full volume. Start it for any inbox that isn't warming: `supersend senders update --id <id> --warm true`.
- **Sender profile:** campaigns send from a sender profile (a group of inboxes): `supersend senders create-profile --team-id <team> --name <name>`, then `supersend senders update --id <inbox> --sender-profile-id <profile>` for each inbox.

Run `supersend setup status` again after each step.

## 3. Write the campaign

Interview first: what they sell, who buys it (title, company type), the problem it solves, proof (a customer, a number), and the one thing to ask for (usually a short call).

Write 3 emails, all plain text:

- **Email 1:** 50-120 words. Personal opening (`{{first_name}}`, `{{company_name}}`, or `{{one_liner}}` when the list has it), the problem, the proof, one question as the call to action. No links or images. Short subject, 2-5 words.
- **Email 2** (wait 3 days), reply in the same thread: a new angle or a different proof.
- **Email 3** (wait 4 days), reply in thread: short and polite close.

Show the copy and adjust it with the user before creating anything.

Create it with a simple (linear) sequence. Nodes chain start → email → wait → email…; follow-ups set `"send_as_reply": true`; waits use `"wait"` and `"wait_unit": "days"`:

```json
{
  "team_id": "<team-uuid>", "name": "Fintech CTOs", "version": 3,
  "sender_profile_ids": ["<profile-uuid>"],
  "timezone": "America/New_York",
  "days": { "monday": true, "tuesday": true, "wednesday": true, "thursday": true, "friday": true },
  "hours": [{ "start": "09:00", "end": "17:00" }],
  "nodes": [
    { "id": "start", "type": "startNode", "position": { "x": 0, "y": 0 }, "data": {} },
    { "id": "e1", "type": "emailNode", "position": { "x": 0, "y": 100 }, "data": { "subject_a": "quick question", "body_a": "Hi {{first_name}}, …" } },
    { "id": "w1", "type": "waitNode", "position": { "x": 0, "y": 200 }, "data": { "wait": 3, "wait_unit": "days" } },
    { "id": "e2", "type": "emailNode", "position": { "x": 0, "y": 300 }, "data": { "send_as_reply": true, "body_a": "…" } }
  ],
  "edges": [
    { "id": "a", "source": "start", "target": "e1" },
    { "id": "b", "source": "e1", "target": "w1" },
    { "id": "c", "source": "w1", "target": "e2" }
  ]
}
```

`supersend campaigns setup-outbound --file campaign.json` creates it (not live). Import contacts with `supersend contacts bulk-import --file contacts.json` (each contact needs `email` or `linkedin_url`; extra columns go in `custom`). To A/B test, add `subject_b`/`body_b` to an email step.

## 4. Review and launch

Run `supersend campaigns review --id <id>`: the steps with their timing, who sends, contacts, schedule, daily volume, and checks. Fix anything blocking.

Then send a test of every email step to the user's own inbox: `supersend campaigns test-send --id <id>`. It goes out from one of the campaign's inboxes with the variables filled from a real contact; nothing is sent to contacts. Add `--step 2` for one step, `--variant b` for an A/B variant, or `--to` to send it to an address the user names. Ask the user to open the tests (and check spam) and fix anything they don't like before launch.

Then show the user what will happen ("starts Monday 9:00 for 400 contacts, up to 180 emails a day") and launch only after they say yes:

```bash
supersend campaigns complete --campaign-id <id>   # only if the review says it's a draft
supersend campaigns activate --id <id>
```

Pause with `supersend campaigns deactivate --id <id>`.

## 5. Every day

- `supersend status`: unread replies, campaigns, inboxes, billing, and to-dos. (The Claude Code plugin adds this brief at the start of each new session.)
- `supersend replies`: unread replies from contacts with who, company, campaign, and AI category (bounces and auto-replies are left out; `--include-other` adds them). `supersend replies show <id>` reads one.
- For each reply, draft an answer, show it, and send only after a yes: `supersend replies send <id> --message "…"` (email goes from the inbox the conversation came in on).
- Sort as you go: `supersend replies label <id> --label Interested`, and `supersend replies done <id>` (read and archived).
- Out of office or "not now": label it and mark it done; don't reply unless asked.

## 6. Results

`supersend campaigns stats --id <id>`: sent, opens, clicks, replies, bounces, outcomes (interested, meetings), and each step and A/B variant. Call a winner only when it shows a leading variant (50+ sends per variant). Good benchmarks: reply rate above 2-3%, bounce rate under 2%.

## 7. Deliverability

- `supersend diagnose deliverability --team-id <id>` and `supersend diagnose sender-health --team-id <id>` find problem inboxes and domains.
- Placement test (uses credits; ask first): `supersend placement-tests run --sender-id <inbox> --campaign-id <campaign>`, then `supersend placement-tests get --id <test>` every few minutes until it's completed. It shows inbox vs spam at each seed mailbox.
- If bounces are high, pause the campaign, validate the list (`supersend contacts bulk-action` with action `validate_emails`; ask first), and look at bounce reasons with `supersend senders bounce-insights --id <inbox>`.
