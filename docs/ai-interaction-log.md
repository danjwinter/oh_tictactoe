# AI Interaction Log

A running record of points during this exercise where Claude's recommendation was corrected or overridden, and why the alternative was the better call. Only disagreements are logged here — points where the recommendation was accepted as-is aren't listed individually; see `CONTEXT.md` and `docs/adr/` for the resulting architecture.

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
