# Quiver - ClassicAPI

ClassicAPI adaptation of [SabineWren's Quiver](https://github.com/SabineWren/Quiver) for the Vanilla 1.12.1 client, with a focus on OctoWoW/Turtle WoW reliability.

**Current build:** `3.1.5-Octo5-Diag1`  
**Requires:** [ClassicAPI](https://github.com/brues-code/ClassicAPI) **1.14.0 or newer**

Use `/quiver` or `/qq` to open the configuration menu.

> [!NOTE]
> This fork replaces several Vanilla-era inference methods with ClassicAPI's spellcast, movement, aura, and range APIs. It is currently distributed with automatic diagnostics enabled so intermittent player reports can be investigated from SavedVariables.

<img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Config_UI_0f9e20.jpg" height="400px">

## Features

- [Aspect Tracker](#aspect-tracker)
- [Auto Shot Timer](#auto-shot-timer)
- [Castbar](#castbar)
- [Range Indicator](#range-indicator)
- [Tranq Shot Announcer](#tranq-shot-announcer)
- [Trueshot Aura Alarm](#trueshot-aura-alarm)
- [Macro API](#macro-api)
- [Automatic Diagnostics](#automatic-diagnostics)

### Aspect Tracker

Never lose track of your current aspect.

<table>
   <tr>
      <td>None</td>
      <td>Pack</td>
      <td>Cheetah</td>
   </tr>
   <tr>
      <td><img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Aspect_None.png" height="64px"></td>
      <td><img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Aspect_Pack.png" height="64px"></td>
      <td><img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Aspect_Cheetah.jpg" height="64px"></td>
   </tr>
</table>

- No warning UI while the normal Hawk state is active.
- Displays the Hawk texture when no aspect is enabled.
- Highlights Aspect of the Pack.
- Hides appropriately while travelling by taxi when frames are locked.
- Aura state is read through ClassicAPI rather than tooltip/texture guessing.

### Auto Shot Timer

<figure>
   <figcaption>Shooting</figcaption>
   <img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Bar_1_Shooting.jpg" height="180px">
</figure>
<figure>
   <figcaption>Reloading</figcaption>
   <img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Bar_2_Reloading.jpg" height="180px">
</figure>

Tracks the Auto Shot aim and reload phases from confirmed ClassicAPI spellcast events and real player movement speed.

This fork no longer relies on `ITEM_LOCK_CHANGED`, map-coordinate movement checks, action-icon matching, or instant-shot guessing to determine when an Auto Shot fired.

Inspired by:
- [HunterSwissKnife](https://github.com/anstellaire/HunterSwissKnife)
- [YaHT](https://github.com/Aviana/YaHT/tree/1.12.1)

### Castbar

<img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Bar_3_Casting.jpg" height="180px">

Shows:
- Aimed Shot
- Multi-Shot
- Steady Shot

Cast timing comes from `C_Spell.UnitCastingInfo("player")` and ClassicAPI cast GUIDs, so macros, corrected server cast durations, failed casts, and interruptions do not depend on Quiver replacing `CastSpell`, `CastSpellByName`, or `UseAction`.

### Range Indicator

[<img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Range_Indicator_Thumbnail.jpg" height="180px">](https://youtu.be/UxLJJ1ne52E)

Based on [Egnar](https://github.com/Medeah/Egnar).

The ClassicAPI build checks range directly by numeric spell ID with `C_Spell.IsSpellInRange`.

- No dedicated copy of Wing Clip, Hunter's Mark, Auto Shot, Scare Beast, or Scatter Shot is required on an action bar.
- Abilities can be used through macros without breaking the range display.
- Wing Clip can be used as the melee-distance probe even before it has been learned.

### Tranq Shot Announcer

<img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Tranq_UI.png">

Shows the Tranquilizing Shot cooldown of hunters and can announce Tranq casts and failures.

Announcements obey the configured **None / Say / Raid** channel. The ClassicAPI build correlates failures with a recent confirmed Tranq instead of treating unrelated combat failures as a Tranq miss.

### Trueshot Aura Alarm

<table>
   <tr>
      <td>None</td>
      <td>Expiring</td>
   </tr>
   <tr>
      <td><img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Trueshot_None.png" height="64px"></td>
      <td><img src="https://raw.githubusercontent.com/SabineWren/Quiver/main/Media/Trueshot_Low.png" height="64px"></td>
   </tr>
</table>

If Trueshot Aura is talented, Quiver tracks the real aura and remaining duration and warns when it needs to be recast.

### Macro API

Quiver exposes several helpers for hunter macros.

#### Auto Shot timing

- `Quiver.GetSecondsRemainingReload()`
- `Quiver.GetSecondsRemainingShoot()`
- `Quiver.PredMidShot()`
- `Quiver.CastNoClip(spellName)`

Example:

```lua
/run local a,b=Quiver.GetSecondsRemainingShoot(); local c=a and b < -0.25; local f=c and CastSpellByName or Quiver.CastNoClip; f("Steady Shot")
```

#### CastPetAction

Find and cast a pet action if possible.

```lua
/run Quiver.CastPetAction("Furious Howl"); CastSpellByName("Multi-Shot")
```

#### FdPrepareTrap

Spammable Feign Death / trap preparation helper. It checks Feign Death cooldown, trap cooldown, player combat, and pet combat, then handles Feign Death and pet passive/follow state.

```lua
/run CastSpellByName("Frost Trap"); Quiver.FdPrepareTrap()
```

> [!WARNING]
> `FdPrepareTrap()` can pull your pet back even while your character is stunned or otherwise unable to act.

> [!NOTE]
> The macro examples above use English spell names. Use your client's localized spell names where a macro calls `CastSpellByName` directly.

## Automatic Diagnostics

`3.1.5-Octo5-Diag1` records a bounded diagnostic trace automatically. Players do **not** need to enable debugging before an intermittent issue occurs.

If something visibly goes wrong, add a marker as soon as possible:

```text
/qdiag mark short description of what happened
```

Useful commands:

- `/qdiag status`
- `/qdiag mark <description>`
- `/qdiag snapshot`
- `/qdiag selftest`
- `/qdiag stop`
- `/qdiag start`
- `/qdiag clear`

After testing, use `/reload` or exit WoW normally so SavedVariables are written, then send:

```text
WTF\Account\<account folder>\SavedVariables\Quiver.lua
```

The trace is stored in `Quiver_Diagnostics`. It records Quiver/ClassicAPI runtime state such as spellcast events, cast timing, movement speed, range decisions, aura state, FPS/latency snapshots, and Quiver module transitions.

> [!IMPORTANT]
> The diagnostic trace may contain in-game character names and combat text. It does **not** contain the account password and Quiver does not upload the trace anywhere.

The recorder keeps the newest evidence in a rolling buffer, so a bug that occurs late in a long play session can still be captured.

## ClassicAPI changes in this fork

The current stabilization pass also includes fixes for:

- ClassicAPI startup/version validation.
- Correct `C_Spell.UnitCastingInfo` namespace use.
- Auto Shot event-order/FPS issues.
- Aimed Shot macro and incorrect-duration behavior.
- Same-icon spell/action collisions.
- Aspect taxi visibility.
- Trueshot and Tranq event handling.
- Disabled configuration buttons still accepting clicks.
- Border-style callback dispatch.
- UI-scale CVar parsing.
- Trinket bag/item identity handling.
- SavedVariables migration spelling.

See [Changelog.md](Changelog.md) for version history and [AUDIT-OCTOWOW.md](AUDIT-OCTOWOW.md) for the stabilization audit.

## Credits

- Original addon and design: [SabineWren/Quiver](https://github.com/SabineWren/Quiver)
- ClassicAPI: [brues-code/ClassicAPI](https://github.com/brues-code/ClassicAPI)
- OctoWoW / ClassicAPI compatibility work: this fork

The screenshots above are from the original Quiver repository and are used here to document the inherited UI/features.

## Test status

`3.1.5-Octo5-Diag1` is the current **player-test candidate**. Static validation and the ClassicAPI interface audit are complete for this branch, while automatic diagnostics remain enabled specifically to capture server/runtime behavior that cannot be proven from static inspection alone.
