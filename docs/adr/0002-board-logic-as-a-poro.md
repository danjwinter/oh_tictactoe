# Encapsulate board logic in a plain Ruby object, not on Game

Board reconstruction, whose-turn-is-next, and win/draw detection could live as instance methods (or a concern) directly on the `Game` ActiveRecord model — the conventional Rails "fat model" approach. We chose instead to put this logic in a plain Ruby object built from a `Game`'s ordered `Move`s, with `Game` delegating to it.

This keeps `Game` a thin persistence wrapper and makes the one piece of real algorithmic complexity in this app — win/draw detection — unit-testable in isolation, with no database needed. "Whose turn is it" and "who won" are computed from the `Move` sequence each time rather than cached on `Game`, so there's no risk of a stored field drifting out of sync with the moves that actually happened.
