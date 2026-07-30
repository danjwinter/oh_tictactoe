# 02 — Start a game and view an empty board

**What to build:** A player can click "New Game" on the root page and see a fresh, empty 3x3 tic-tac-toe board for that game.

**Blocked by:** 01 — Containerized dev/test environment

**Status:** done

- [x] `Game` model + migration exist (per ADR-0001) — `has_many :moves` deliberately deferred to ticket 03 alongside the `Move` model; see note below
- [x] `Board` PORO exists, built from a `Game`'s moves, and correctly renders an empty grid + "X to move" when there are no moves yet
- [x] Root page (`/`) shows a "New Game" button
- [x] Submitting "New Game" creates a `Game` and redirects to its show page, displaying an empty board
- [x] Reloading a game's show page re-displays the same (empty) board — no state is lost
- [x] Request spec covers `POST /games` → redirect → empty board rendered
- [x] `Board` unit spec covers the zero-move case (empty grid, X to move)

**Note:** `Game` doesn't yet declare `has_many :moves` — the `Move` model doesn't exist until ticket 03, so `GamesController#show` hardcodes `Board.new([])` for now (flagged with a comment at the call site). Ticket 03 must wire up the real association.

Also added beyond the original checklist, per review during implementation: games are looked up/rendered in URLs by a `uuid` column (via `Game#to_param`), not the auto-incrementing `id`, so a game's URL doesn't reveal play volume or let one game be guessed from another's id.
