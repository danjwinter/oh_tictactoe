# Oh Tic-Tac-Toe

A two-player, same-browser tic-tac-toe game built in Rails under a 2-hour scope limit — a coherent working slice, not a maximal feature set.

## Running the app

```sh
docker compose up web                    # installs gems and sets up the database automatically on first run
docker compose run --rm test bin/rspec   # run the test suite
```

No local Ruby, Postgres, or native extension toolchain needed — the app boots at [http://localhost:3000](http://localhost:3000).

A `Game` owns an ordered log of `Move`s, and a `Board` plain-Ruby object derives the grid, turn, and win/draw outcome from those moves on demand rather than caching any of it (see [`CONTEXT.md`](./CONTEXT.md) and [`docs/adr/`](./docs/adr/)). It was built with Claude Code and a set of custom "Matt Pocock" agent skills (`.claude/skills/`, dictation via Wispr): a structured planning interview and written spec before any code (`/grill-with-docs`, `/to-spec` → [`spec.md`](./.scratch/tic-tac-toe-mvp/spec.md)), a vertical-slice ticket breakdown agreed on before implementation started (`/to-tickets` → [`issues/`](./.scratch/tic-tac-toe-mvp/issues/)), and TDD plus a two-axis code review on every ticket (`/implement`). The full walkthrough of how this collaboration actually worked, ticket by ticket, is in [`docs/process.md`](./docs/process.md).

Claude wrote the first draft of every decision below; I directed, reviewed, and redirected it where it didn't hold up — most consequentially on the `Game`+`Move` data model over a flattened board column, RSpec over Minitest, and a deliberately redundant `Move` validation seam. I also caught it in a debugging loop chasing the wrong cause for a forgotten migration, and later caught a CSS bug, during my own play-testing, that left board cells barely clickable — full reasoning for all of it is in [`docs/ai-interaction-log.md`](./docs/ai-interaction-log.md). With more time I'd pick up the stretch goals in [`stretch-goals.md`](./.scratch/tic-tac-toe-mvp/stretch-goals.md) (multiplayer, a computer opponent, a games index, a Capybara end-to-end test, a JSON API) and split the moves/win-detection ticket, which in hindsight was scoped too large for one review pass.
