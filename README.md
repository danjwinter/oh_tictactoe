# Oh Tic-Tac-Toe

_Draft — filled in as the build progresses; final pass at the end of the session._

## Running the app

_(Docker Compose instructions go here once `Dockerfile.dev`/`compose.yaml` exist.)_

## Approach

Built with Ruby on Rails, scoped as a human-vs-human hotseat game for the 2-hour limit, with stretch goals (multiplayer via Turbo Streams, a computer opponent, a games index, a Capybara end-to-end test, a JSON API) attempted only if time remains. See `CONTEXT.md` for domain vocabulary and `docs/adr/` for the architectural decisions and their reasoning.

## AI tools used

Built with [Claude Code](https://claude.com/claude-code) using a set of custom "Matt Pocock" skills (`.claude/skills/`) — notably `/grill-with-docs` (an interview-style planning session that forced explicit decisions before writing code, recorded into `CONTEXT.md`/`docs/adr/`) and `/domain-modeling` (captures domain terminology and architectural decisions as they're made). Dictation via Wispr.

See [`docs/ai-interaction-log.md`](./docs/ai-interaction-log.md) for the specific points where Claude's recommendations were corrected and why.

## What I'd improve with more time

- **Ticket 03 was scoped too big.** It bundled move submission/turn-taking together with win/draw detection into one ticket, which made for a large diff and a heavy single code-review pass. In hindsight, "make a move and see turns alternate" and "detect and display win/draw" were each substantial enough to be their own ticket — splitting them would have kept each review smaller and each step easier to verify in isolation.
- _(further notes added at the end of the session)_
