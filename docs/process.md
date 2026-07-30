# How This Was Built

The point of this exercise wasn't just a working tic-tac-toe game — it was showing how to use AI tooling efficiently to get there: breaking the problem down, directing an AI collaborator rather than delegating to it, and reviewing its output critically at every step. This document is the detailed version of that; the README covers the short version.

## The shape of the collaboration

Nothing got coded until it had been decided and written down. The sequence was: a structured interview to resolve every open question (`/grill-with-docs`), a formal written spec synthesizing that conversation (`/to-spec`), a vertical-slice ticket breakdown agreed on before any implementation (`/to-tickets`), and then each ticket built test-first with an adversarial two-axis review before it was allowed to be committed (`/implement`). Each stage produced an artifact that the next stage (and the next person reading this repo) can check against, rather than relying on memory of a conversation.

## Why each skill, and what it actually did

- **`/grill-with-docs`** ran `/grilling` (an interview that asks one question at a time, always leading with a recommended answer, and won't move on without an explicit yes/no) together with `/domain-modeling` (which captures the resulting vocabulary and any hard-to-reverse decisions as they crystallize). The value: it's very easy, working solo with an AI, to let architectural decisions get made implicitly as a side effect of whatever the AI happens to write first. This forced every one of them into the open and onto the record before a single file existed.
- **`/to-spec`** took that entire conversation and synthesized it into one document — [`spec.md`](../.scratch/tic-tac-toe-mvp/spec.md): problem statement, user stories, implementation decisions, testing decisions, explicit out-of-scope. The value: a spec that can be pointed at later is worth more than a chat transcript nobody's going to re-read.
- **`/to-tickets`** broke that spec into vertical slices — tracer-bullet tickets that each cut a full path through schema/API/UI/tests, not horizontal layers — with explicit blocking edges, and quizzed me on granularity and blocking order before writing anything to the tracker. See [How tickets changed](#how-tickets-changed-and-grew) below for where I pushed back on the first draft.
- **`/implement`** built each ticket, and is covered in detail below — TDD at the seams the spec had already agreed on, then a two-axis code review before commit.

## How I reviewed every decision

Three layers of review ran throughout, not just at the end:

1. **In the moment, during planning.** Every question `/grilling` asked came with Claude's recommended answer and reasoning attached; I either took it or overrode it on the spot, and the reasoning for each override is in [`ai-interaction-log.md`](./ai-interaction-log.md).
2. **Per ticket, via two independent AI reviewers.** Detailed below — this is where most of the substantive catches happened, not in my own read of the diff.
3. **Manually, against the running app.** Automated tests passing was never treated as sufficient on its own. Every ticket was also exercised live — `docker compose up`, real HTTP requests (via `curl`, scripting full games including a win by a diagonal and a rejected post-game-over move), reading the actual rendered HTML — before I'd call it done. This is how the barely-clickable board cells got caught: the request specs never would have failed on that, because they don't check CSS layout.

## Architecture decisions made during the grilling session

Two decisions changed during the interview itself, not later:

- **`Game` + `Move` as separate records**, overriding Claude's proposal of a single `Game` with board state as one flattened column. Claude's case was scope-minimalism for a 2-hour exercise; mine was that a real audit trail and a future move-history view were worth the extra normalization. See [ADR-0001](./adr/0001-game-and-move-as-separate-records.md).
- **RSpec over Minitest**, overriding Claude's case for the zero-setup Rails default. I judged spec readability worth the setup cost, given the codebase would be read by an evaluator as much as run. See [ADR-0003](./adr/0003-rspec-over-minitest.md).

Two more architectural decisions came later, during `/to-spec` and the first ticket draft respectively, not the grilling session itself: a deliberately redundant `Move` validation spec seam on top of request specs, and a dedicated `test` Compose service instead of relying on someone to remember `RAILS_ENV=test`. Full reasoning for both, and for everything decided during implementation (UUID game URLs, explicit view locals, isolating gem installs from the host), is in [`ai-interaction-log.md`](./ai-interaction-log.md).

## How tickets changed and grew

`/to-tickets` first proposed three tickets — containerized dev/test environment, an empty board, then full gameplay — plus five candidate stretch goals. I made two changes to that proposal before anything was built: I agreed to keep the gameplay ticket merged rather than split further (in hindsight, the wrong call — see below), and I added a fourth ticket for finalizing the README, since a take-home submission's documentation is itself deliverable work, not an afterthought.

Tickets also picked up scope mid-flight, before being marked done: ticket 01 gained an explicit requirement for a dedicated `test` Compose service (rather than expecting `RAILS_ENV=test` to be passed by hand) once I saw the first draft. In hindsight, ticket 03 (moves, turn-taking, and win/draw detection, all in one) should have been split into two from the start — it produced the largest diff and the heaviest single review pass of the project. That's now recorded as the clearest process lesson from this build.

## Extensions: how stretch goals were handled

Rather than pre-writing tickets for all five stretch goals (multiplayer via Turbo Streams, a computer opponent, a games index, a Capybara end-to-end test, a JSON API), they're recorded as a single lightweight priority list in [`stretch-goals.md`](../.scratch/tic-tac-toe-mvp/stretch-goals.md) and left un-ticketed. Given the 2-hour clock, writing full tickets for work that might never get picked up was overhead without payoff — a ticket only gets written for one of these if there's actually time left to build it.

## What's next

In priority order, if more time were available: multiplayer across browsers via Turbo Streams, a computer opponent (random-move first, minimax after), a games index page, a Capybara end-to-end test, and a JSON API alongside the HTML views. If redoing the ticket breakdown, ticket 03 would be split into "make a move, turns alternate" and "detect and display the outcome" as two separate tickets from the start.

## TDD and the two-axis adversarial review, in detail

**TDD at pre-agreed seams.** The seams weren't decided ad hoc during implementation — they were negotiated with me during `/to-spec` and written into the spec before any ticket started: request specs as the primary seam (the fullest integration coverage, closest to what a player actually experiences), `Board` unit specs for the one piece of real algorithmic complexity (win/draw detection across all 8 lines), and a deliberately redundant `Move` validation spec seam so a broken validation fails at the model level directly. For each seam, in order: write the failing spec, confirm it's red for the *right* reason (a missing method or constant, not a typo), write the minimum code to make it pass, then move to the next seam. The full suite runs again at the end of every ticket, alongside `rubocop`.

**Two-axis review, adversarially.** Once a ticket's automated tests and manual verification were both green, two sub-agents reviewed the diff in parallel with no visibility into each other's context or conclusions:

- A **Standards** reviewer, checking the diff against `CLAUDE.md`, the `docs/adr/` decisions, `CONTEXT.md`'s vocabulary, and a fixed baseline of Fowler code smells.
- A **Spec** reviewer, checking the diff against the originating ticket's acceptance criteria and the broader spec — missing criteria, scope creep, and things that look done but are actually wrong or fragile.

Findings are reported side by side, never merged or re-ranked into one verdict — deliberately, because a change can cleanly pass one axis while failing the other, and averaging them together would hide exactly that. This is what actually caught, concretely: duplicated connection-config logic in `database.yml` (ticket 01); confirmed that deferring `Game#moves` until `Move` existed was a legitimate scope boundary rather than an oversight (ticket 02); and, on ticket 03, an unhandled `ActiveRecord::RecordNotUnique` race that would have surfaced as an unhandled 500 instead of a clean error, plus a gap in `Board#next_turn` unit coverage beyond the empty-board case — both fixed before that ticket was committed.
