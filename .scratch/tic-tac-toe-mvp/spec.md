Status: ready-for-agent

# Tic-Tac-Toe MVP (hotseat)

## Problem Statement

Two people who share a browser want to play a game of tic-tac-toe against each other — take alternating turns, see the board update, and find out who won (or that it was a draw) — without needing accounts, setup, or anything beyond a web page.

## Solution

A Rails web app where a player starts a new `Game` from a "New Game" button, and the two players take turns placing marks by submitting moves through plain HTML forms. The board and outcome (win/draw/in progress) are always shown reflecting the current state of the `Game`. Invalid moves (occupied cell, game already over) are rejected with a clear error rather than silently ignored.

## User Stories

1. As a player, I want to start a new game, so that I can begin playing immediately without extra setup steps.
2. As a player, I want to see an empty 3x3 board when a new game starts, so that I know play begins fresh.
3. As a player, I want to place my mark (X or O) in an empty cell on my turn, so that I can make my move.
4. As a player, I want the game to know whose turn it is without me having to specify it, so that neither player can accidentally play out of turn.
5. As a player, I want to be prevented from placing a mark in a cell that's already occupied, so that the board always stays valid.
6. As a player, I want a clear error message if my move is rejected (occupied cell, or the game has already ended), so that I understand why nothing happened.
7. As a player, I want the board to reflect the latest move immediately after I submit it, so that I can see the current state of play.
8. As a player, I want to be told when a player has won, and which mark won, so that we know the game is over.
9. As a player, I want to be told when the game ends in a draw, so that we know to stop playing this game.
10. As a player, I want to be prevented from making further moves once the game has ended (win or draw), so that the final board state is preserved.
11. As a player, I want to start a brand new game once the current one ends, so that we can play again without restarting the app.
12. As a player, I want each game to be independent of any other game, so that playing multiple games in a row doesn't carry state between them.
13. As a player, I want to reload a game's page and see its current state unchanged, so that a page refresh never loses progress.
14. As a developer, I want each move recorded as its own persisted record, so that I have an audit trail for debugging and a foundation for a future move-history view.
15. As an evaluator, I want to run the whole application (app, database, and test suite) via Docker Compose, so that I don't need Ruby, Postgres, or any native extension toolchain installed locally.
16. As a developer, I want win/draw/whose-turn-is-it logic isolated in a plain Ruby object with direct unit tests, so that the core algorithm is verified independently of the database and HTTP layer.
17. As a developer, I want request-level specs covering game creation and move submission (both valid and invalid), so that the full user-facing behavior is verified end to end without a browser.
18. As a developer, I want invalid moves rejected via ActiveRecord validations on `Move`, so that bad input is handled through standard Rails conventions rather than ad hoc controller checks.

## Implementation Decisions

- **`Game`**: represents one match. `has_many :moves`. No stored `current_player`, `winner`, or `status` column — all of that is derived from the `Move` sequence via `Board` (see [ADR-0001](../../docs/adr/0001-game-and-move-as-separate-records.md)).
- **`Move`**: `belongs_to :game`; records `player` (X or O) and `position` (cell index 0–8). Validations: `position` must be 0–8 and unoccupied within the game, and the game must not already be over at the time of creation. Moves are immutable — created only, never updated or destroyed.
- **`Board`**: a plain Ruby object (not ActiveRecord) built from a `Game`'s ordered `Move`s. Exposes the derived grid, `#next_turn` (from move count parity), `#winner`, `#draw?`, and overall outcome. `Game` delegates to it rather than implementing this logic itself (see [ADR-0002](../../docs/adr/0002-board-logic-as-a-poro.md)).
- **Routes/controllers**: resourceful. Root page shows a "New Game" button posting to `games#create`, which creates an empty `Game` and redirects to `games#show`. Moves are created via a nested `games/:game_id/moves#create`; on success, redirect to `games#show`; on a failed validation, re-render `games#show` with a flash/error message.
- **Views**: plain ERB partials, plain hand-written CSS, no CSS framework. Turbo Drive (Rails default) handles full-page navigation; a Turbo Frame around the board may be added if it stays simple, but isn't required for this spec.
- **Testing framework**: RSpec, replacing the Rails-default Minitest (see [ADR-0003](../../docs/adr/0003-rspec-over-minitest.md)).
- **Local dev/test environment**: `Dockerfile.dev` + `compose.yaml` (`web`, `db`, and a dedicated `test` service with `RAILS_ENV=test` baked in), separate from the existing production `Dockerfile` (see [ADR-0004](../../docs/adr/0004-dev-only-dockerfile-and-compose.md)).
- No authentication, no cross-browser multiplayer, no computer opponent, and no JSON API are part of this spec.

## Testing Decisions

- Good tests assert on externally observable behavior — HTTP response status/redirects and rendered content for request specs, return values for `Board` unit specs, validity/errors for model specs — not on internal implementation details.
- Three seams, confirmed with the developer:
  1. **Request specs (primary seam)**: `POST /games` and `POST /games/:game_id/moves`, covering game creation, valid moves, and each rejected-move case (occupied cell, game already over), asserting on response/rendered content.
  2. **`Board` unit specs (pure logic seam)**: `Board.new(moves)` exercised directly with plain move arrays to cover all 8 winning lines, the draw case, and turn derivation — impractical to cover exhaustively through HTTP request specs alone.
  3. **`Move` model validation specs**: exercise the occupied-cell and game-already-over validations directly against the model (`Move.new(...).valid?`), independent of the request specs. This duplicates behavior already covered at the request seam, but the duplication is deliberate: when a validation breaks, a failing model spec points straight at the broken validation, rather than requiring the developer to first rule out routing/controller/view causes behind a failing request spec.
- No system/Capybara specs in this pass — explicitly out of scope (see below).
- This is a greenfield app with no prior test suite; these specs establish the pattern for anything added later.

## Out of Scope

- Multiplayer across separate browsers/devices via Turbo Streams.
- A computer opponent (random-move or minimax).
- A games index page listing past games.
- Capybara/system end-to-end tests.
- A JSON API (`jbuilder`) alongside the HTML views.
- User accounts or authentication of any kind.

## Further Notes

Scope is deliberately tight to fit a 2-hour take-home time limit; everything in Out of Scope is a candidate stretch goal, in the priority order: multiplayer, computer opponent, games index, Capybara e2e demo, JSON API. Domain vocabulary is defined in `CONTEXT.md`; architectural rationale is in `docs/adr/0001`–`0004`. Points where the developer overrode the AI's initial recommendation (Game+Move over a single model; RSpec over Minitest) are logged in `docs/ai-interaction-log.md`.
