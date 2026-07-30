# Persist moves as their own records, not a flattened board column

A `Game` could store its board as a single serialized column (a 9-char string or array), mutated in place on each move — simpler, and enough to satisfy the rules of tic-tac-toe. We chose instead to give each move its own `Move` record (`game_id`, `player`, `position`, `created_at`), with the board always derived by replaying them.

This is deliberately more normalized than the problem strictly requires, so it's worth explaining: recording moves individually gives an audit trail for debugging and a natural foundation for a future move-history view, without needing to redesign the data model later. The cost is that board state and win/draw status are never stored directly — every read replays the `Move` sequence (see [ADR-0002](./0002-board-logic-as-a-poro.md)).
