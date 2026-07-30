# Oh Tic-Tac-Toe

A Rails app where two players play tic-tac-toe by taking alternating turns in the same browser session.

## Language

**Game**:
A single tic-tac-toe match between two players, from the first move through a win, draw, or abandonment. Owns the ordered sequence of `Move`s that make it up.
_Avoid_: Match, Session, Round

**Move**:
A single placement of a mark (X or O) into one cell, made by one player during a `Game`. Persisted as its own record so the sequence of play survives as an audit trail, rather than being merged into a single board snapshot.
_Avoid_: Turn, Play, Action

**Board**:
The 3x3 grid state for a `Game` at a point in time, derived by replaying its `Move`s. Never persisted directly — always reconstructed from the `Move` sequence.
_Avoid_: Grid, State (when unqualified)

**Turn**:
Whose mark is next to be placed. Derived from the count of `Move`s already made (even → X, odd → O), never stored as a field.
_Avoid_: Current player (as a stored value)

**Outcome**:
The result of a `Game` — in progress, a win for X, a win for O, or a draw — derived from its `Board`, never stored directly.
_Avoid_: Status, Result (used loosely)
