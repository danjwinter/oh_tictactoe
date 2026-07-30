# 03 — Make moves, see outcome, start a new game after it ends

**What to build:** Players can take turns placing marks by submitting moves; the board updates after each move; invalid moves (occupied cell, game already over) are rejected with a clear error; once a player wins or the board fills up in a draw, the outcome is displayed and further moves are blocked; a "New Game" link is available to start again.

**Blocked by:** 02 — Start a game and view an empty board

**Status:** done

- [x] `Move` model + migration exist (per ADR-0001) — `belongs_to :game`, records `player` and `position`
- [x] `Move` validations reject an occupied cell and reject any move once the game is already over
- [x] `Board` PORO correctly derives whose turn is next (from move count parity) and computes the winner/draw across all 8 winning lines
- [x] `MovesController#create` determines the player server-side from `Board#next_turn` (never client-supplied) and creates the `Move`
- [x] A successful move redirects back to `games#show`, displaying the updated board
- [x] A rejected move re-renders `games#show` with a flash/error message, board unchanged
- [x] Once a game is won or drawn, `games#show` displays the outcome ("X wins!" / "Draw!") and further move submissions are rejected
- [x] A "New Game" link/button is reachable from a finished game's show page
- [x] Request specs cover: a valid move updates the board; an occupied-cell move is rejected; a move after game-over is rejected; a winning move displays the winner; a board-filling move with no winner displays a draw
- [x] `Move` validation specs directly cover the occupied-cell and game-already-over cases (dedicated seam per spec.md's testing decisions)
- [x] `Board` unit specs cover all 8 winning lines and the draw case

**Beyond the checklist, added during code review:**
- A rescue for `ActiveRecord::RecordNotUnique` in `MovesController#create`, so a genuine race between two near-simultaneous requests for the same cell degrades to the same clean 422/flash behavior instead of an unhandled 500 (the uniqueness validation alone only protects the non-racing case).
- `Board#next_turn` unit specs beyond the zero-move case (odd/even move counts), since only the empty-board case had direct unit coverage before.
- `Game#board` reloads the `moves` association on every call — fixes a real bug caught while writing the `Move` "already over" validation spec: a `Game` Ruby object reused across several `Move.create!` calls (as in the specs) would otherwise see a stale, pre-move association result.
