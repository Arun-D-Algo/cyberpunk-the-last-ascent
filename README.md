# Cyberpunk: The Last Ascent

An unofficial, noncommercial 2D precision-platformer fan-game concept inspired by Cyberpunk: Edgerunners and Jump King. David Martinez climbs eight connected regions of Arasaka Tower through charge-and-release jumps, punishing falls, and cyberware. The alternate-universe ending has David and Rebecca escape to the moon.

## Current status

Milestone 00 foundation: native boot UI, central keyboard actions, pixel-oriented display settings, project structure, planning documents, and validation tools. Godot 4.7.2 import, startup and smoke checks passed; a rendered boot frame was visually inspected. No player, movement, levels, abilities, saves, dialogue, audio, or boss implementation. See docs/development-log.md for actual checks and remaining validation.

## Prerequisites and opening

- Confirmed engine: **Godot 4.7.2 stable**, reporting `4.7.2.stable.official.ed1daf0bf` from the user's Tools/Godot installation. Verify your executable with `--version` on another machine.
- Standard Godot build (GDScript); .NET is unnecessary. Desktop Windows or Linux. Git for version control; PowerShell 7 or Windows PowerShell for the static check.
- Obtain the engine from [the official Godot download page](https://godotengine.org/download/) if needed; installation/extraction is a user action. If the requested version is unavailable, agree on a supported version before changing the target.
- In Godot's Project Manager choose **Import**, select this directory's `project.godot`, then **Import & Edit**. Press **F5** (Run Project). The title, milestone subtitle and initialization message should appear. Close the window to exit; no pause/retry gameplay exists yet.

From PowerShell, with your actual executable path:

```powershell
Set-Location 'C:\Users\Arunangshu Dasgupta\OneDrive\Repositories and Projects\Cyberpunk_Game\cyberpunk-last-ascent'
$GodotExe = 'C:\Users\Arunangshu Dasgupta\Tools\Godot\godot_console.exe'
& $GodotExe --version
& $GodotExe --editor --path .
# Or run directly:
& $GodotExe --path .
```

The machine-specific locations above are opening instructions only; runtime resources use res://. On another machine replace the executable/checkout locations. On Linux, `cd` to the checkout and use `godot --editor --path .` / `godot --path .`.

## Controls

These actions are configured centrally; gameplay responses arrive in later milestones. Letter keys use physical positions; Shift/Ctrl require the left location. Godot's built-in ui_* defaults are unused by this boot screen and are not alternate gameplay bindings.

| Key | Action | Intended behavior |
| --- | --- | --- |
| A | move_left | Move/select left jump direction |
| D | move_right | Move/select right jump direction |
| W | look_up | Look upward |
| S | look_down | Look downward |
| Space | jump_charge | Hold to charge, release to jump |
| Left Shift | cyberware_primary | Primary ability |
| Left Ctrl | cyberware_secondary | Secondary ability |
| E | interact | Interact |
| Esc | pause_game | Pause |
| R | retry_boss | Request boss retry |

## Structure and architecture

```text
project.godot       Project settings and InputMap
scenes/main/       Native boot UI
scenes/player/     Future composed player scene
scenes/levels/regions/  Future continuous-world content
scenes/hazards/    Reusable hazards
scenes/characters/ NPC scenes
scenes/bosses/     Boss scenes
scenes/ui/         Future reusable UI
scripts/          core/, player/, camera/, cyberware/, regions/,
                  hazards/, dialogue/, save/, audio/, bosses/, ui/
resources/        definitions/, physics/, difficulty/, camera/,
                  cyberware/, audio/, input/, regions/
assets/           sprites/, animations/, backgrounds/, tilesets/, audio/
tests/            Static and engine smoke checks
docs/             Design, technical plan, roadmap and development log
AGENTS.md         Future coding-agent instructions
```

Future directories contain only .gitkeep markers, not empty systems. See [technical design](docs/technical-design.md) for ownership and configuration boundaries and [roadmap](docs/roadmap.md) for M00–M08 acceptance gates. M01 is the separately scoped jump-physics prototype; M02–M08 add traversal, regions, cyberware, narrative, late game, boss and release validation.

## Validation

Run from the project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\validate_static.ps1
& $GodotExe --headless --editor --path . --quit
& $GodotExe --headless --path . --quit-after 5
& $GodotExe --headless --path . --script res://tests/smoke_test.gd
```

Check exit codes **and** all engine output for parse/resource/startup errors. The static validator checks source contracts only and is not a Godot parser. The engine smoke test loads the real main scene and checks project settings, action types/keys/locations, title/status, and label bounds. It must print `PASS: foundation smoke test` and exit 0. Finally run F5 in a visible window: verify nearest/integer scaling at 960×540 and resized windows, and no debugger errors. Later verify on Linux and exported desktop builds; neither is currently tested. A headless pass cannot establish visual quality or physical left/right modifier behavior on hardware.

In a restricted agent workspace, normal Godot editor/user-data paths may be unwritable. M00 validation temporarily redirected process-local APPDATA/LOCALAPPDATA into ignored `.godot/validation-user` and `.godot/validation-cache`, used a copy of the installed executable in `.godot/validation-engine` with an `_sc_` marker, and supplied absolute `--log-file` paths under `.godot/`. This did not alter the installed engine or machine settings. [Godot self-contained mode](https://docs.godotengine.org/en/4.4/classes/class_editorpaths.html) isolates editor settings; user-data redirection was additionally required. Do not change production user-data settings to work around an agent sandbox.

## Constraints and OneDrive

320×180 internal viewport, 960×540 initial window, integer viewport scaling with kept aspect, nearest canvas textures, GL Compatibility renderer, and a provisional fixed 60 Hz physics tick. The `4.7` feature tag matches the confirmed engine series. Do not upgrade/downgrade the agreed engine without recording the decision.

Source writes/readbacks succeeded locally. The parent carries OneDrive attributes; sync health could not be independently established. Keep the project locally available using OneDrive's **Always keep on this device** if appropriate. Avoid concurrent edits on multiple synced machines and allow sync to settle before switching machines. Git ignores `.godot/`, but this does not exclude it from OneDrive. If cache locking/conflicts occur, close Godot and discuss pausing sync or using a user-approved nonsynced checkout. Never move this project automatically.

No tuned physics values, gameplay, rebinding UI, save format implementation, export presets/templates, third-party dependencies, or production assets exist. Platform exports, physical input and manual resize behavior remain unverified.

## Fan-project and asset policy

This project is unofficial, unaffiliated with and not endorsed by the Cyberpunk/Edgerunners rights holders. Noncommercial intent does not grant IP rights or publication permission. Do not use extracted game/anime art, music, logos, voices or proprietary files. The boot screen uses Godot's native controls/default font and simple colors; no third-party assets were imported. Keep content IDs separate from display names so original characters/setting/assets can replace fan content before any public release. Public distribution needs a separate rights review.
