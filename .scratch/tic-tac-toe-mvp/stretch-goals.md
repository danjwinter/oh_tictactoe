# Stretch Goals — Tic-Tac-Toe MVP

Not individually ticketed — the 2-hour time limit means these are only worth picking up if tickets 01–04 (the MVP + README) are done with time remaining. See `spec.md`'s "Out of Scope" for how each relates to the MVP. Priority order:

1. **Multiplayer across browsers (Turbo Streams)** — broadcast `Game`/`Move` updates so two separate browser sessions can play the same `Game` live, instead of hotseat in one browser.
2. **Computer opponent** — start with a random legal move; minimax (unbeatable play) as a further extension only if time remains after that.
3. **Games index page** — root route lists past games (outcome, created at) with links to each; "New Game" becomes an action on that page rather than the only thing on root.
4. **Capybara end-to-end test** — one small JS-enabled system spec driving a full game through the browser, as a demo that the whole stack works together — not a replacement for the request/model/unit specs already in place.
5. **JSON API** — `jbuilder` views alongside the existing HTML views, exposing `Game`/`Move` state as JSON for a hypothetical non-Rails frontend.

If one of these gets picked up, log it in `docs/ai-interaction-log.md` like any other AI-assisted decision, and add an ADR only if it introduces a genuinely hard-to-reverse architectural choice.
