## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Development workflow

Whenever you write or edit a migration, run it (`docker compose run --rm web bin/rails db:migrate`, or let `bin/docker-entrypoint.dev`'s `db:prepare` do it) *before* trying to boot the app or otherwise exercise it against the development database. Booting a stale container against an un-migrated schema produces confusing errors that look unrelated to the real cause.
