# Quiver 3.1.5-Octo5-Diag1

This is the OctoWoW/Turtle WoW stabilization fork of SabineWren's Quiver 3.1.5.
It is intended for the Vanilla 1.12.1 client with **ClassicAPI 1.14.0 or newer**.

The ClassicAPI DLL is self-contained. You do **not** need a physical
`Interface\\AddOns\\!!!ClassicAPI` folder, and Quiver deliberately has no TOC
hard dependency on such a folder.

Use `/quiver` or `/qq` to open Quiver's configuration.

## What this build changes

The fork removes the fragile inference paths that caused most OctoWoW/Turtle
hunter bugs and uses ClassicAPI as the authoritative source instead:

- Auto Shot is detected from confirmed `UNIT_SPELLCAST_SUCCEEDED` events and
  `C_Spell.IsRangedAutoAttackSpell`, not inventory-lock events.
- Player movement comes from `GetUnitSpeed("player")`, not map coordinates.
- Aimed Shot, Multi-Shot and Steady Shot timing comes from
  `C_Spell.UnitCastingInfo("player")` and matching ClassicAPI cast GUIDs.
- Quiver does not replace or monkey-patch `CastSpell`, `CastSpellByName`, or
  `UseAction` to infer casts.
- Range checks use `C_Spell.IsSpellInRange` with numeric spell IDs. Relevant
  abilities do not have to occupy a standalone action-bar slot and can be used
  through macros.
- Operational hunter-spell matching uses stable spell IDs and ClassicAPI's
  localized spell names instead of Quiver's old enUS/zhCN reverse-name tables.
- Aspect and Trueshot aura state use `C_UnitAuras`.
- Tranq success uses confirmed ClassicAPI spellcast events. Miss/failure
  announcements follow the selected None/Say/Raid setting.
- Trinket swap resolves exact item IDs. The old texture form is accepted only
  when the texture maps to one unique bag item ID; ambiguous icons are refused.

The post-Octo4 audit fixes are also included: taxi visibility, disabled-button
click blocking, UI-scale parsing, border-style callback dispatch, migration
spelling, safe ClassicAPI startup/version validation, and stale update-notifier
behavior.

## ClassicAPI contract

Quiver requires `CLASSIC_API_VERSION >= 11400` and validates only the APIs and
custom events used by the active runtime. If the contract fails, Quiver does
not initialize its hunter modules and `/quiver` reports the missing contract
item rather than silently failing.

Custom ClassicAPI event registration by Quiver features is deferred until this
contract has passed.

## Automatic diagnostics

This test build contains an observation-only diagnostic recorder. It is **on by
default**; players do not have to enable it before reproducing a problem.

Useful commands:

- `/qdiag status`
- `/qdiag mark <what happened>` — add a marker immediately after a visible bug
- `/qdiag snapshot` — save cast/movement/target state at that moment
- `/qdiag selftest`
- `/qdiag stop` — stop further recording
- `/qdiag start` — clear the old trace and start a fresh one
- `/qdiag clear`

After playing, use `/reload` or exit WoW normally so SavedVariables are written.
Then send:

`WTF\\Account\\<account folder>\\SavedVariables\\Quiver.lua`

The trace is stored in `Quiver_Diagnostics` in that file. It records Quiver and
ClassicAPI gameplay state such as spellcast event payloads, cast timing,
movement speed, range decisions, aura state, FPS/latency snapshots and Quiver
module transitions. It can contain in-game character names/combat text. It does
not collect an account password and does not transmit anything over the
network.

The recorder keeps a rolling trace capped at 20,000 records. If the cap is
reached, it trims an older block and keeps recording the newest events so a
late-session bug is still captured. The trim count is recorded in `Dropped`.
`/qdiag stop` stops only the current session; recording automatically resumes
after `/reload` or the next client start.

## Features

### Aspect Tracker
Shows the relevant aspect warning/icon, highlights Aspect of the Pack, and hides
appropriately while on a taxi when frames are locked.

### Auto Shot Timer
Displays the 0.5-second aim phase and ranged-weapon reload phase. State comes
from ClassicAPI's real spellcast and movement information.

Quiver exposes:

- `Quiver.GetSecondsRemainingReload()`
- `Quiver.GetSecondsRemainingShoot()`
- `Quiver.PredMidShot()`
- `Quiver.CastNoClip(spellName)`

### Castbar
Shows Aimed Shot, Multi-Shot and Steady Shot using the server/client cast state
reported by ClassicAPI, including corrected cast duration and interruption.

### Range Indicator
Uses numeric spell IDs directly with ClassicAPI. No dedicated action-bar copy
of Wing Clip, Hunter's Mark, Auto Shot, Scare Beast or Scatter Shot is required
for range probing.

### Tranq Shot Announcer
Tracks hunters' Tranq cooldowns and can announce casts/failures according to the
configured None/Say/Raid channel.

### Trueshot Aura Alarm
Tracks the actual Trueshot aura and its remaining duration using ClassicAPI aura
data.

### Utility macros

`Quiver.FdPrepareTrap()` uses localized spell names resolved from spell IDs.

The WIP trinket helpers now prefer an item ID or an item link:

```lua
/run Quiver.TrinketSwap1(23041)
/run Quiver.TrinketSwap2("|Hitem:23041:0:0:0|h[Slayer's Crest]|h")
```

A legacy texture path is accepted only if it identifies exactly one item ID in
the player's bags.

## Installation

1. Keep ClassicAPI 1.14.0+ loaded as a DLL in the normal way used by your
   client/VanillaFixes setup.
2. Delete the previous `Interface\\AddOns\\Quiver` folder.
3. Extract this build so the path is exactly
   `Interface\\AddOns\\Quiver\\Quiver.toc`.
4. Restart the client.

Existing `Quiver_Store` settings are preserved.

## Test status

`3.1.5-Octo5-Diag1` is a **stabilization/diagnostic candidate**, not a declared
final baseline. The static audit and API cross-check are complete for the
changes above; player traces are kept specifically to catch runtime/server
behavior that static inspection cannot prove.
