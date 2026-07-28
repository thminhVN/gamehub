# Hot-code upgrades (zero downtime)

GameHub uses [Castle](https://hexdocs.pm/castle)/[Forecastle](https://hexdocs.pm/forecastle)
to ship OTP **relups** — new code is loaded into the *running* BEAM node, so
deploys drop no connections and don't restart the LiveView sockets. GameHub has
no database, but it does have something worth protecting across a deploy:
players mid-game in a pass-and-play LiveView session. A hot upgrade lets you
ship a rules tweak without kicking anyone out of their board.

> **This is the opt-in path (`make deploy-hot` / `./deploy.sh --hot`), not the
> default.** A relup cannot ship changed CSS, JS or images — see the assets
> caveat below. `make deploy` (full extract + restart) is the normal deploy.

## Per-release checklist

1. **Bump the version** in `mix.exs` (`version: "0.2.0"`). Every upgrade needs a
   new, higher version.
2. **Update `appup.ex`** to describe how to go from the running version to the
   new one:
   ```elixir
   {~c"0.2.0",
    [{~c"0.1.0", [{:load_module, GameHubWeb.CoCaNgua.GameLive}]}],   # up
    [{~c"0.1.0", [{:load_module, GameHubWeb.CoCaNgua.GameLive}]}]}   # down
   ```
   - `{:load_module, Mod}` — stateless module, just reload it. Covers almost
     every change in this app (templates, helper functions, Board/Layout
     rules) since none of them are GenServers.
   - `{:update, Mod, {:advanced, []}}` — a **stateful** process (GenServer);
     this calls the module's `code_change/3` so it can migrate its state. Only
     needed here if `GameHubWeb.CoCaNgua.GameLive` ever changes the *shape* of
     `socket.assigns` in a way that would break an already-connected session.
   - `{:add_module, Mod}` / `{:delete_module, Mod}` — new / removed modules
     (e.g. adding a whole new game under `lib/game_hub/games/`).
   - An empty change `[]` reloads nothing (config-only / asset-only releases).
3. **Deploy**: `./deploy.sh`. It detects the running version, generates the
   relup `running -> new`, installs and commits it into the live node.

## What `deploy.sh` does for an upgrade

```
running v0.1.0  ──►  build v0.2.0 tar on VPS
                     mix forecastle.relup --target <new>.rel --fromto <old>.rel
                     mix release --overwrite          # embeds relup in the tar
                     bin/game_hub unpack 0.2.0
                     bin/game_hub install 0.2.0        # runs the relup, live
                     bin/game_hub commit 0.2.0         # permanent across reboots
```

No `systemctl restart`. The node keeps running; modules are swapped in place —
any board mid-game keeps its state and its LiveView socket.

## Caveats (read these)

- **Stateful processes need `code_change/3`.** GameLive's assigns (the `Board`
  struct, `pending_move`, etc.) survive a relup unchanged as long as you only
  add/adjust functions — but if you change what fields `socket.assigns` holds
  in a way old and new code disagree on, add an explicit `{:update, Mod,
  {:advanced, []}}` instruction and a `code_change/3` to migrate it, or ship
  that release as a full deploy instead.
- **Dependency version bumps** make relups harder: `systools` needs an appup for
  every changed application. If a dep upgrade breaks relup generation, ship that
  release with `./deploy.sh` (extract + restart) instead.
- **A relup CANNOT ship changed assets — this is why full is the default.**
  The new `priv/static` does ride along in the release tar, but the endpoint
  never re-reads it: `Phoenix.Endpoint` loads `cache_static_manifest` once, at
  boot, so `~p"/assets/css/app.css"` keeps rendering the digest recorded at the
  last *restart*. The stale digested file is still on disk and still served —
  with `cache-control: immutable, max-age=31536000`. Net effect: new Elixir
  code, year-old CSS in every browser, and no error anywhere to notice it by.
  Symptom to recognise: the raw `/assets/css/app.css` has your change but the
  `app-<hash>.css?vsn=d` that the HTML links does not. Any diff touching
  `assets/` or `priv/static/` needs `make deploy`.
- **It doesn't survive a wiped release root.** `commit` makes the version
  permanent (survives reboot/crash), but the upgrade history lives in
  `/opt/game_hub/app/releases/`. Keep it.

## Escape hatch

Anything goes wrong with a relup? `./deploy.sh` (the default, full) does a clean
extract-and-restart of the current version — a brief blip (any live game gets
dropped), but always works. Roll back a bad commit with
`bin/game_hub install <old> && bin/game_hub commit <old>`.
