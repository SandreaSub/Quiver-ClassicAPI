# Quiver 3.1.5-Octo5-Diag1 — OctoWoW stabilization audit

## Audited baseline

- Upstream/user runtime baseline: Quiver 3.1.5 archived bundle.
- Runtime target: World of Warcraft 1.12.1 / OctoWoW/Turtle environment.
- ClassicAPI target: official ClassicAPI **v1.14.0+**.
- Audited v1.14.0 DLL SHA-256:
  `367088ccbd6486417b96b67a5384f0bc921c3174b61b5364003d8a365689f43d`.

The supplied v1.14.0 DLL matched the official release asset byte-for-byte.
ClassicAPI embeds its own `!!!ClassicAPI` compatibility addon; a physical addon
folder is not a Quiver dependency.

## ClassicAPI interface contract

Octo5 requires `CLASSIC_API_VERSION >= 11400`, then checks the active runtime
contract:

- `GetUnitSpeed`
- `C_Spell.UnitCastingInfo`
- `C_Spell.IsSpellInRange`
- `C_Spell.IsRangedAutoAttackSpell`
- `C_Spell.GetSpellName`
- `C_UnitAuras.GetAuraDataBySpellName`
- `C_CreatureInfo.GetCreatureTypeInfo`
- `C_EventUtils.IsEventValid`
- the ClassicAPI `UNIT_SPELLCAST_*` events used by Quiver

The v1.14.0 source contract was cross-checked for namespaces, return order and
event payload shape. In particular, player cast state is
`C_Spell.UnitCastingInfo`, and its cast ID is the same ClassicAPI cast GUID used
by the corresponding `UNIT_SPELLCAST_*` events.

## Corrected audit findings

1. **ClassicAPI startup** — removed the invalid physical `!!!ClassicAPI` TOC
   dependency. Runtime is gated by ClassicAPI version/features instead.
2. **Startup ordering** — feature custom-event registration occurs in module
   `OnEnable` after the ClassicAPI contract passes. The optional spellcast bus
   is side-effect-free until explicitly initialized.
3. **API namespace** — all cast-state calls use
   `C_Spell.UnitCastingInfo("player")`.
4. **Dead startup requirements** — removed unused `GetActionInfo` and aura-index
   requirements from the mandatory contract. Optional legacy code fails closed.
5. **Auto Shot** — removed `ITEM_LOCK_CHANGED`, action-icon inference and
   map-coordinate movement inference. Confirmed ranged-auto success plus
   `GetUnitSpeed` drive state.
6. **Castbar** — authoritative start/end milliseconds and cast-GUID matching
   prevent macro/failed-cast events from cancelling the real bar.
7. **Range** — direct numeric spell-ID range checks remove action-bar/macro and
   unlearned-Wing-Clip probe dependencies.
8. **Localization** — operational spell matching now resolves client-localized
   names from stable spell IDs through ClassicAPI; old reverse localization
   tables are no longer used by the combat modules.
9. **Aspect taxi visibility** — `updateUI` is the single visibility authority;
   `OnEnable` no longer re-shows a frame deliberately hidden on a taxi.
10. **Trueshot** — direct ClassicAPI success event + spell ID, with aura timing
    from `C_UnitAuras`.
11. **Tranq channel correctness** — both cast and failure announcements obey the
    configured None/Say/Raid setting; Raid is not sent while outside a raid.
12. **Tranq failure matching** — stock localized combat GlobalStrings are used
    inside a short post-Tranq correlation window, reducing unrelated failure
    false positives.
13. **Disabled UI buttons** — disabled buttons block mouse-down/up callbacks and
    the final click callback.
14. **Trinket swap identity** — item ID/item link is authoritative; a legacy
    texture request is rejected when multiple item IDs share that texture.
15. **Trinket bag/cursor completion** — the actual bag ID is preserved instead
    of always picking from bag 0, and an equipped old trinket is returned to
    the exact source bag slot instead of being left on the cursor.
16. **Feign Death trinket flow** — no same-execution equip race after Feign
    Death; the macro is intentionally retried after combat drops.
17. **Border style callbacks** — associative subscribers iterate with `pairs`,
    not `ipairs`.
18. **UI scale** — string CVar `useUiScale` is normalized with `tonumber`.
19. **Migration** — `ColourReload` migrates to `ColorReload` correctly.
20. **Updater** — stock Quiver's update notifier is not initialized by this
    compatibility fork.
21. **Documentation** — Octo2/Octo3 dependency claims, action-bar-only range
    text and old monkey-patch documentation were removed.

## Removed fragile mechanisms

The active Octo5 runtime must not depend on:

- `ITEM_LOCK_CHANGED` for Auto Shot
- `GetPlayerMapPosition` for movement
- replacing `CastSpell`, `CastSpellByName`, or `UseAction`
- action texture equality to identify hunter spells
- Quiver's enUS/zhCN `SpellReverse` table for combat decisions

## Diagnostic validation layer

`Quiver_Diagnostics` is intentionally retained in this corrected build. It is
active by default and records the ClassicAPI/Quiver boundary in a bounded
SavedVariables trace: startup contract, custom-event payloads, cast snapshots,
movement, range decisions, aura state, Auto Shot state, Tranq/Trueshot paths,
UI branch markers, Lua errors, FPS and latency. The bounded recorder is
rolling: when full it trims older records and preserves the newest evidence.

This makes player reports actionable without requiring the player to turn on a
debugger before an intermittent failure occurs.

## Remaining validation boundary

Static source/binary/API auditing cannot prove every server timing and gameplay
transition. Therefore Octo5-Diag1 is a test candidate until real player traces
cover the regression matrix. No claim of perfect runtime behavior is made before
that evidence exists.
