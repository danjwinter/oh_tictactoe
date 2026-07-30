# Add a dev-only Dockerfile.dev and compose.yaml alongside the production Dockerfile

Rails generates a production-oriented `Dockerfile` (`BUNDLE_WITHOUT="development"`, `BUNDLE_DEPLOYMENT=1`, asset precompile, no test gems) that can't run the test suite or hot-reload local code. Rather than adapting it with build args/targets, we added a separate `Dockerfile.dev` (installs all gem groups, no deployment/precompile flags) plus a `compose.yaml` defining `web`, `db` (Postgres), and `test` services, with the app code volume-mounted for live reload.

The `test` service exists as its own entry (rather than expecting `RAILS_ENV=test` to be passed by hand against `web`) with `RAILS_ENV=test` baked into its environment and its own test database, so running the suite is a single command (`docker compose run test bin/rspec`) that can't be run against the wrong environment by mistake.

The goal is that local development and the test suite run entirely inside containers, so the app doesn't depend on the evaluator's host Ruby version, Postgres install, or native extension toolchain. The original production `Dockerfile` is left untouched, so it still demonstrates the deploy path independently of the dev setup.
