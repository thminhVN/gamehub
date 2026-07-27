# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Bé vui học** — a Phoenix LiveView site of Vietnamese family board games played *pass-and-play on one shared device*. All UI copy is Vietnamese.

`AGENTS.md` holds the Phoenix 1.8 / LiveView / Elixir framework conventions for this project; read it for anything about `Layouts.app`, `<.icon>`, streams, forms, or Tailwind import syntax. This file covers what is specific to this codebase.

## Commands

```bash
make dev                  # deps.get + mix phx.server  → http://localhost:4050
mix setup                 # deps + assets install/build (first run)
mix precommit             # REQUIRED before finishing: compile --warnings-as-errors, deps.unlock --unused, format, test
mix test                  # full suite
mix test test/game_hub/games/co_ca_ngua/board_test.exs:42   # single test by line
mix assets.build          # tailwind + esbuild (no npm — both are Mix-managed binaries, no node_modules)
make hooks                # one-time: installs the version-bump pre-commit hook
make deploy               # VPS hot-code upgrade; make deploy-full forces a restart
```

Dev port **4050** (`config/dev.exs`); prod reads `PORT` (default 4050) and `PHX_HOST`.

## Architecture

**There is no database.** No Ecto, no repo, no persistence. A game lives entirely in the LiveView socket of the one browser playing it; `Phoenix.PubSub` is started by the generator but nothing uses it. Reloading the page starts a new game.

The game code is split so rules never depend on rendering:

- `GameHub.Games.CoCaNgua.Board` — pure rules engine (releases on 1/6, extra turn on 6, triple-six forfeit, exact-landing finish, captures, safe squares, own- and enemy-horse blocking). Returns `{:ok, board, result}` / `{:error, reason}`. Its `@moduledoc` is the authoritative rules list — **change rules here, not in the LiveView.**
- `GameHub.Games.CoCaNgua.Layout` — maps a colour + position to 1-indexed `{row, col}` on the 15×15 CSS grid. Pure geometry; the only place board coordinates are decided.
- `GameHubWeb.CoCaNgua.SetupLive` — pick 2–4 players and names, then `push_navigate` to the play route with everything in query params (no server-side session).
- `GameHubWeb.CoCaNgua.GameLive` — holds the `%Board{}` in assigns plus a `history` list for undo, and renders it. Rendering/animation only; delegate every decision to `Board`.
- `GameHubWeb.HomeLive` — the marketing landing page. The `@games` module attribute drives the game cards: a game with `status: :soon` renders a "Sắp ra mắt" card with no link. **When a new game ships, flip it to `status: :ready` and set `path:`** — that is the whole wiring, plus a route in `router.ex`. Cờ vua, Cờ tướng and Cờ vây are currently advertised but not built.

## Design system

`docs/design/co_ca_ngua_toybox_brief.md` is the source of truth for anything visual (warm cream "Toy Box" look, chunky glossy 3D toy art, no casino/dark/neon). Re-read it before making a visual decision.

Styling is Tailwind v4 only, layered in `assets/css/app.css`:

- `@theme` holds the palette and radii, so they exist as real utilities — `text-ink`, `text-ink-soft`, `bg-cream`, `border-cream-deep`, `text-toy-red`, `bg-toy-green/20`, `rounded-toy-lg`. **Use utilities in templates; do not add inline `style=` attributes** (both landing and setup screens are at zero).
- `@layer components` holds the reusable multi-property patterns: `toy-btn` (+ `--red/--blue/--neutral`), `toy-card` (+ `--link/--soon`), `toy-chip`, `toy-badge`, `toy-medallion`, `toy-input`, `landing-band`, `player-panel`. Reuse these instead of re-deriving the same six utilities. Plain CSS, never `@apply`.
- `@layer utilities` holds the `animate-*` classes; keyframes live at the end of the file.
- Custom token names are prefixed (`--radius-toy-*`) so they never shadow Tailwind's own scale — an earlier `--radius-lg: 28px` silently broke `rounded-lg` everywhere. `--toy-red`, `--cream-deep`, … remain as `@layer base` aliases only because the game screen still references them via `var()`.

**No emoji as UI icons** — no screen uses them any more, and platform emoji would break the art direction anyway. Use the shared `<.toy_icon name="dice" class="h-6 w-6" />` from `CoreComponents`, backed by the generated set in `priv/static/images/ui/`. New icons must match that art direction: generate them with the `chatgpt-image` skill on a flat `#1E50FF` background and cut them out with its slicer (`--chroma blue`).

The brand mark is the **owl-with-a-book mascot**, authored as vector art in `priv/static/images/ui/logo.svg` (so it stays crisp in a 16px favicon) and used in the header, footer and closing CTA. Dice and chess pieces are deliberately *not* brand marks — they read as gambling rather than as a children's learning app; the die only ever appears where it means the game's actual die. To change the mark, edit `logo.svg`, rasterise it on a transparent background, then run `python3 tools/build_brand.py <raster.png> .` — that regenerates `favicon.ico`, every `priv/static/images/icons/*.png`, and `logo.png` (convert to `.webp`).

## Static assets & PWA

Images are WebP under `priv/static/images/{assets,ui,landing}/`. `priv/static/sw.js` precaches the app shell: when adding images that must be available offline, add them to `PRECACHE_URLS` **and bump `CACHE_NAME`**, otherwise clients keep serving the old shell. Only the `app.js` / `app.css` bundles are supported — no external CDN `src`/`href` in layouts.

## Releases and hot upgrades

Deploys are OTP hot-code upgrades (Castle/Forecastle), so a running game keeps its LiveView socket across a deploy:

- The `.githooks/pre-commit` hook auto-bumps the patch version in `mix.exs` **and** rewrites the versions in `appup.ex` on every commit to `main`. Versions in the two files must always match.
- `appup.ex` describes how to get from the previous version to this one. `GameLive` holds game state, but `:load_module` is sufficient for plain UI/rules tweaks; only use `{:update, Mod, {:advanced, []}}` when a release changes the *shape* of `socket.assigns` and needs `code_change/3` to migrate live sessions.
- See `deploy/HOT_UPGRADE.md` and the header comment in `deploy.sh`.

## Tests

Engine tests live in `test/game_hub/games/co_ca_ngua/`. `simulation_test.exs` plays full random games to completion and independently re-derives the expected outcome of every roll from raw position arithmetic before comparing it with the engine — when changing rules in `Board`, expect to update that re-derivation too. Use `Board.roll_with/2` (explicit die) for deterministic tests; `Board.roll/1` is random.
