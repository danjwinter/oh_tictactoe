# AI Interaction Log

A running record of points during this exercise where Claude's recommendation was corrected or overridden, and why the alternative was the better call. Only disagreements are logged here — points where the recommendation was accepted as-is aren't listed individually; see `CONTEXT.md` and `docs/adr/` for the resulting architecture.

## At a glance

- **Architecture, decided during planning** — `Game` + `Move` records instead of a flattened board column (#1); RSpec instead of Rails' default Minitest (#2); a dedicated, deliberately redundant `Move` validation spec seam on top of request specs (#3); a separate `test` Compose service instead of relying on someone to remember `RAILS_ENV=test` (#4).
- **Security/robustness, decided during implementation** — isolating gem installs from the host via a bind-mounted `vendor/bundle` (#5); UUID game URLs instead of guessable auto-incrementing ids (#8).
- **Code-quality habits** — keeping ticket checklists honestly in sync with actual progress (#6); explicit view locals over instance variables so a mistake fails loudly instead of silently rendering `nil` (#7).
- **Bugs caught by hand, not by a test** — a debugging loop chasing the wrong cause for a forgotten migration (#9); a CSS bug leaving board cells barely clickable, caught during play-testing (#10).
- **Documentation** — making the whole Docker setup self-bootstrapping so there's nothing to remember before running it (#11); restructuring the README so process, key decisions, and retrospective notes aren't jumbled together (#12).

The full reasoning for each — what Claude proposed, what changed, and why — is below.

## Planning phase (`/grill-with-docs` session)

**1. Data model: single `Game` model vs. `Game` + `Move`**
Claude recommended a single `Game` model with board state as one column (a 9-char string/array), reasoning that a separate `Move` log was over-normalized for a 2-hour tic-tac-toe exercise.
Overridden: chose `Game` + `Move` instead. Reasoning: recording each move as its own record gives an audit trail for debugging, and sets up move-history display as a straightforward future extension — a better extendability trade-off than Claude's scope-minimalism argument accounted for. See [ADR-0001](../docs/adr/0001-game-and-move-as-separate-records.md).

**2. Test framework: Minitest vs. RSpec**
Claude recommended keeping Rails' default Minitest, reasoning that swapping frameworks costs Gemfile/bundle setup time with no functional gain under a tight time limit.
Overridden: chose RSpec instead. Reasoning: spec readability and extendability outweighed the setup-time cost. See [ADR-0003](../docs/adr/0003-rspec-over-minitest.md).

**3. Test seams: request specs only vs. adding dedicated `Move` validation specs**
Claude's `/to-spec` draft treated `Game`/`Move` model validations as covered indirectly through the request specs only, reasoning that a dedicated model-spec seam would be redundant coverage of the same behavior.
Overridden: added `Move` validation specs as a third, deliberately redundant seam. Reasoning: when a validation breaks, a failing model spec isolates the problem directly, rather than requiring the developer to rule out routing/controller/view causes behind a failing request spec first — faster fault localization outweighs the duplication.

**4. Compose services: `web` + `db` only vs. adding a dedicated `test` service**
Ticket 01, as originally drafted, defined only `web` and `db` services in `compose.yaml`, implying `RAILS_ENV=test` would be passed manually when running specs against the `web` service.
Overridden: added a third `test` service with `RAILS_ENV=test` baked into its environment and its own test database. Reasoning: relying on a human to remember to pass `RAILS_ENV=test` every time is exactly the kind of manual step that gets forgotten and produces confusing failures (or false passes) — worth one extra service definition to make running the suite a single, unambiguous command. See [ADR-0004](../docs/adr/0004-dev-only-dockerfile-and-compose.md).

## Implementation phase

**5. Ticket 01: gem install location — image default vs. isolated bind mount**
Claude's initial `Dockerfile.dev`/`compose.yaml` let Bundler install gems to its default path with no explicit isolation from the bind-mounted app code.
Overridden: added an explicit `BUNDLE_PATH=vendor/bundle`, bind-mounted from the host at `./vendor/bundle` (gitignored) separately from the rest of the app directory. Reasoning: if someone later ran `bundle install` natively on the host (e.g. macOS) in the same checkout, the container's Linux-compiled native extensions and the host's could otherwise end up sharing a gem path — worth one more explicit volume mount to make that collision structurally impossible rather than relying on it not happening.

**6. Process: ticket checklists left unchecked after ticket 01**
Claude implemented and committed ticket 01 without going back to check off its acceptance-criteria checkboxes or set its `Status` to done.
Corrected: going forward, each ticket's checklist and `Status` line get updated as work completes, not just tracked implicitly through commit history. Reasoning: the tickets under `.scratch/tic-tac-toe-mvp/issues/` are the visible record of what's actually finished — leaving them unchecked makes the tracker lie about project state.

**7. Ticket 02: instance variables vs. explicit locals in the controller/view**
Claude's initial `GamesController#show` set `@game`/`@board` and let the `show.html.erb` template pick them up implicitly.
Overridden: switched to `render locals: { game:, board: }` and plain local variables in the view. Reasoning: a forgotten instance variable silently evaluates to `nil` in the view (a quiet, hard-to-trace bug); a forgotten local raises `NameError` immediately — loud failure beats silent `nil` here.

**8. Ticket 02: game URLs — auto-incrementing id vs. UUID**
Claude's initial implementation looked games up by, and rendered URLs with, the default auto-incrementing `id`.
Overridden: added a separate `uuid` column (generated in a `before_create` callback, primary key unchanged) and overrode `Game#to_param` so URLs and lookups use the UUID instead. Reasoning: a sequential id reveals how many games have been played and lets one game's URL be predicted from another's — cheap, lightweight "security through unguessability" for something with no real auth in scope.

**9. Process: forgot to run migrations before spinning up containers**
While manually verifying ticket 02 in the browser, Claude added the UUID migration but started the `web` container without running it first, then spent several steps debugging a resulting 500 error as if it were a CSRF/token problem before the user pointed out the actual cause.
Corrected: run pending migrations explicitly before booting containers for manual verification. Reasoning: this wasted several debugging steps chasing the wrong hypothesis; the user's interjection ("we don't have the migrations run, and that's a problem") redirected straight to the real cause. Ticket 03 ran migrations proactively before booting, with no repeat of the debugging loop — and the rule is now recorded permanently in `CLAUDE.md` under "Development workflow" so it isn't just tribal knowledge from this one session.

**10. Ticket 03: clickable area only covered a fraction of each board cell**
Claude's board-cell CSS gave the `<button>` `width/height: 100%`, but that's 100% of its immediate parent — the `<form class="button_to">` Rails wraps `button_to` in — and that form, as a flex item under `align-items: center`, was only as large as its content, not the full cell. The result: only a small clickable area per square instead of the whole cell.
Corrected, after the user flagged it during manual play-testing: added `.board-cell form { width: 100%; height: 100%; }` so the form (and thus the button inside it) actually fills the cell. Reasoning: `button_to`'s form wrapper is easy to overlook when styling — the fix has to target the actual flex item, not just the element you think of as "the button."

**11. Ticket 04: "Running the app" required manual setup steps instead of being fully self-bootstrapping**
Claude's first draft of the README required running `bundle install` and `db:migrate` by hand before `docker compose up web` would work.
Corrected: updated `bin/docker-entrypoint.dev` to run `bundle check || bundle install` before `db:prepare`, so `docker compose up web` (and `docker compose run test bin/rspec`) are single, self-sufficient commands on a completely fresh clone — verified by wiping `vendor/bundle` and the database volume and running just `docker compose up web`. Reasoning: an evaluator (or any other developer) shouldn't have to remember multi-step setup instructions just to run the app. See [ADR-0004](../docs/adr/0004-dev-only-dockerfile-and-compose.md).

**12. Ticket 04: README structure — approach, process, and retrospective notes conflated**
Claude's first draft merged the game-mechanics description, the AI-assisted planning process, and retrospective notes (what went wrong vs. what's left for later) into too few sections, and named the skills used without explaining why each one helped or what it was for.
Corrected: split "Approach" into a game-mechanics paragraph and a separate paragraph naming each skill (`/grill-with-docs`, `/to-spec`, `/to-tickets`, `/implement`) with what it was for and how it helped; split the retrospective into "What didn't go as planned" (ticket 03 sizing, the migration debugging loop, the clickable-cell bug) versus "What I'd improve with more time" (the forward-looking stretch goals) as two distinct sections instead of one jumbled one.
