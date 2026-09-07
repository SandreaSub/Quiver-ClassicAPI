# Quiver Octo5-Diag1 player regression matrix

Diagnostics are **already recording by default**. A tester may simply install
the addon and play. The commands below are optional but make a report easier to
correlate.

If something looks wrong, immediately run:

`/qdiag mark <short description>`

At the end, `/reload` or exit WoW normally, then send:

`WTF\\Account\\<account folder>\\SavedVariables\\Quiver.lua`

The relevant trace is `Quiver_Diagnostics` inside that file.

## Quick smoke test

1. Log in on a Hunter and run `/quiver`.
2. Run `/qdiag status` and `/qdiag selftest`.
3. Start Auto Shot while stationary; let several shots fire.
4. Move during the cycle, stop, and let Auto Shot resume.
5. Use Arcane/Concussive/other instant shots between autos.
6. Cast Aimed Shot, Multi-Shot and Steady Shot normally and through the player's
   usual macros.
7. Interrupt a cast by movement and, if possible, by an enemy interrupt.
8. Check range transitions from melee -> dead zone -> ranged -> Hunter's Mark
   -> out of range.
9. Change/toggle aspects, including Pack, and take a taxi if available.
10. Refresh/lose Trueshot Aura.
11. Use Tranq with the player's normal announce channel; capture a failure/miss
    if practical.
12. Toggle modules, lock/unlock frames, change border style, and use Reset only
    when it is enabled.

## Auto Shot / cast timing stress

For stronger coverage, test at both capped and uncapped FPS if the player uses
both modes. Include:

- start/stop Auto Shot repeatedly;
- move immediately before and after a shot fires;
- instant shot during reload;
- instant shot during the 0.5-second aim phase;
- Aimed/Multi/Steady during an Auto Shot cycle;
- spam a cast that fails because another cast is already active;
- cancel Aimed/Steady by movement;
- spell pushback if the server permits it;
- weapon-speed changes/haste effects if available.

The trace records FPS, latency, `UNIT_SPELLCAST_*`, `UnitCastingInfo`, movement
speed and Quiver's own shot/cast state so these transitions can be reconstructed.

## Range coverage

No test ability needs a dedicated action-bar slot. Test with the player's real
macro layout, including a setup where Wing Clip exists only inside a macro or is
not learned on a low-level Hunter.

Cover, where possible:

- melee;
- dead zone;
- normal short/long ranged bands;
- Hunter's Mark-only distance;
- out of range;
- Scatter Shot band when learned;
- Scare Beast on a Beast target when learned;
- target death and target change.

## Aspect / taxi

- no aspect;
- Hawk;
- Cheetah;
- Pack;
- Beast/Monkey/Wild/Viper as available;
- Turtle custom Fox/Wolf if learned;
- enter a taxi with frames locked and verify the Aspect Tracker does not
  reappear during the ride;
- lock/unlock while on/after taxi.

## Tranq

Test each configured channel if practical:

- None: no cast or failure chat announcement;
- Say: cast/failure only in Say;
- Raid: cast/failure in Raid only when actually raided.

For a miss/resist/immune/failure, use `/qdiag mark TRANQ_FAILURE` immediately
if the visible result disagrees with the configured channel.

## Trinket helper (only for players who use it)

Prefer item IDs or item links:

`/run Quiver.TrinketSwap1(ITEM_ID)`

Test a trinket in backpack and in non-zero bags. If the player has two distinct
items sharing an icon, the old texture form should refuse the ambiguous request
instead of choosing one arbitrarily.

## UI branches

- toggle every Quiver module off/on;
- lock/unlock frames;
- move/resize and reset frames;
- switch border style while Auto Shot/Castbar are visible;
- verify a visually disabled button does nothing when clicked.

## Useful diagnostic commands

- `/qdiag status`
- `/qdiag mark <text>`
- `/qdiag snapshot`
- `/qdiag selftest`
- `/qdiag stop`
- `/qdiag start` — clears existing trace and begins a fresh capture
- `/qdiag clear`

The trace may contain in-game character names and combat text. It does not
contain the account password and is not uploaded automatically.
