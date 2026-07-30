# 04 — Finalize README for submission

**What to build:** The README accurately documents how to run the app via Docker Compose, summarizes the approach and trade-offs actually taken, describes AI tool usage, and includes a "what I'd improve with more time" section — ready as the submission's entry point.

**Blocked by:** 03 — Make moves, see outcome, start a new game after it ends

**Status:** done

- [x] "Running the app" section has accurate, verified Docker Compose commands (boot app, run migrations, run test suite)
- [x] "Approach" section reflects the MVP as actually shipped, not just the original plan
- [x] "AI tools used" section is accurate and links to `docs/ai-interaction-log.md`
- [x] "What I'd improve with more time" section is filled in, referencing the stretch-goals doc
- [x] No leftover placeholder/draft text remains

**Note:** per explicit direction, kept the README itself short (one to two paragraphs per section) and linked out to `CONTEXT.md`, `docs/adr/`, `.scratch/tic-tac-toe-mvp/spec.md`, `docs/ai-interaction-log.md`, and `.scratch/tic-tac-toe-mvp/stretch-goals.md` for depth, rather than inlining all the detail.

Revised after initial review feedback: "Approach" is now two paragraphs (game mechanics, then the AI-assisted planning/build process with why each skill was used); "what didn't go as planned" (ticket 03 sizing, the migration debugging loop, the clickable-cell bug) is now separate from "what I'd improve with more time" (forward-looking stretch goals); and `bin/docker-entrypoint.dev` was updated to run `bundle check || bundle install` automatically, so "Running the app" is now just `docker compose up web` with no manual setup steps first (verified from a truly clean clone — `vendor/bundle` and the database volume both wiped).

Revised again after a second feedback pass, per the literal "a couple of paragraphs" instruction in the assignment: condensed the whole README down to a title, a run-instructions code block, and two paragraphs total covering approach, AI process, key decisions, what didn't go as planned (explicitly framed as caught by human review, not self-corrected), and what's left for later — linking out everywhere for depth instead of inlining it. Also added [`docs/process.md`](../../../docs/process.md), a deeper narrative doc (the value of each skill, how every decision was reviewed, how tickets changed during vertical slicing, how stretch goals were scoped, and the TDD/two-axis-review mechanics in detail), linked from the README. Trimmed the AI interaction log's entry list by removing a self-check entry that wasn't actually a human-AI disagreement, and added an "At a glance" summary up top so it can be skimmed before reading all twelve entries in full.
