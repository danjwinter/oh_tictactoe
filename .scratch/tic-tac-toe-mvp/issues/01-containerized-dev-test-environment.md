# 01 — Containerized dev/test environment

**What to build:** Running `docker compose up` (or a documented equivalent) boots the Rails app connected to Postgres entirely in containers, and the RSpec test suite runs in that same environment via a dedicated `test` service — no host Ruby, Postgres, or native extension toolchain required, and no one has to remember to set `RAILS_ENV=test` by hand.

**Blocked by:** None — can start immediately

**Status:** ready-for-agent

- [ ] `Dockerfile.dev` and `compose.yaml` exist, defining `web`, `db`, and `test` services (per ADR-0004)
- [ ] `docker compose up` starts the Rails server, connected to Postgres, reachable in a browser
- [ ] App code is volume-mounted so edits are reflected without rebuilding the image
- [ ] `rspec-rails` is added to the Gemfile and installed (`rails generate rspec:install`)
- [ ] The `test` service has `RAILS_ENV=test` baked into its environment (not something the runner has to pass manually), and runs against its own test database
- [ ] `docker compose run test bin/rspec` runs successfully with no extra flags or env vars needed (even against zero/placeholder specs)
- [ ] The existing production `Dockerfile` is left untouched
