# Application upgrade instructions (OTP appup), in Elixir form.
# The :appup compiler (Forecastle) evaluates this file and writes
# `game_hub.appup` into the release's ebin so relups can be generated.
#
# Format: {NewVsn, [{FromVsn, UpInstructions}], [{FromVsn, DownInstructions}]}
# Versions are charlists and MUST match the `version:` in mix.exs.
#
# For each release you hot-upgrade, bump this to the new version and describe
# how to get there from the previous one. Common instructions:
#
#   {:update, MyMod, {:advanced, []}}  -> stateful process; calls code_change/3
#   {:load_module, MyMod}              -> stateless module; just reload it
#   {:add_module, MyMod}               -> brand new module
#   {:delete_module, MyMod}            -> removed module
#
# `mix castle.relup` can usually infer simple module loads for you; you mainly
# hand-write entries for GenServers/LiveViews that hold state.
#
# `GameHubWeb.CoCaNgua.GameLive` holds per-connection game state (the Board
# struct) but keeps the same struct shape across a plain UI/rules tweak, so
# `:load_module` is enough. Only reach for `{:update, Mod, {:advanced, []}}`
# if a release actually changes the *shape* of `socket.assigns` and needs
# `code_change/3` to migrate an already-connected session.
#
# Example for the next release, e.g. 0.2.0 upgrading from 0.1.0. Versions are
# charlists; the data block below uses the ~c sigil, but this example avoids it
# so the auto-bump pre-commit hook only rewrites the real version entries:
#
#   {'0.2.0',
#    [{'0.1.0', [{:load_module, GameHubWeb.CoCaNgua.GameLive}]}],
#    [{'0.1.0', [{:load_module, GameHubWeb.CoCaNgua.GameLive}]}]}

{~c"0.1.0", [], []}
