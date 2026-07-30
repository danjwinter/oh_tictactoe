# 02 — Start a game and view an empty board

**What to build:** A player can click "New Game" on the root page and see a fresh, empty 3x3 tic-tac-toe board for that game.

**Blocked by:** 01 — Containerized dev/test environment

**Status:** ready-for-agent

- [ ] `Game` model + migration exist (per ADR-0001) — `has_many :moves`
- [ ] `Board` PORO exists, built from a `Game`'s moves, and correctly renders an empty grid + "X to move" when there are no moves yet
- [ ] Root page (`/`) shows a "New Game" button
- [ ] Submitting "New Game" creates a `Game` and redirects to its show page, displaying an empty board
- [ ] Reloading a game's show page re-displays the same (empty) board — no state is lost
- [ ] Request spec covers `POST /games` → redirect → empty board rendered
- [ ] `Board` unit spec covers the zero-move case (empty grid, X to move)
