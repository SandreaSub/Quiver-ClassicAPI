Quiver 3.1.5-Octo5-Diag1
=========================

Requires ClassicAPI 1.14.0+.
Diagnostics are ON automatically. You do not need to start them.

If a bug happens, type as soon as possible:
  /qdiag mark short description of what happened

Optional:
  /qdiag snapshot
  /qdiag status
  /qdiag selftest

After testing, /reload or exit WoW normally, then send this file to the addon maintainer:
  WTF\Account\<account folder>\SavedVariables\Quiver.lua

The diagnostic trace is stored as Quiver_Diagnostics in that file.
It may contain in-game character names/combat text. It does not contain your account password and Quiver does not upload the trace anywhere.

/qdiag stop pauses only the current session. Diagnostics automatically resume after /reload or a client restart.
