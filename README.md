# Cyberpunk: The Last Ascent

An unofficial, noncommercial 2D precision-platformer fan-game concept inspired by Cyberpunk: Edgerunners and Jump King. David Martinez climbs eight connected regions of Arasaka Tower through charge-and-release jumps, punishing falls, and cyberware. The alternate-universe ending has David and Rebecca escape to the moon.

## Current status

Milestone 01 implements the first playable physics laboratory: reusable player, charge/release jumps, explicit states, collision geometry, vertical camera, charge HUD, debug measurements, pause/reset and boot navigation. Automated import/startup/foundation/gameplay checks pass in Godot 4.7.2, and a rendered lab frame was inspected. A complete twelve-platform route and subsequent fall/recovery are verified automatically. Full human playtesting remains pending; a brief Computer Use inspection was stopped by the physical Escape key. No production regions, abilities, saves, dialogue, audio or boss exist.

## Prerequisites and opening

- Confirmed engine: **Godot 4.7.2 stable**, reporting `4.7.2.stable.official.ed1daf0bf` from the user's Tools/Godot installation. Verify your executable with `--version` on another machine.
- Standard Godot build (GDScript); .NET is unnecessary. Desktop Windows or Linux. Git for version control; PowerShell 7 or Windows PowerShell for the static check.
- Obtain the engine from [the official Godot download page](https://godotengine.org/download/) if needed; installation/extraction is a user action. If the requested version is unavailable, agree on a supported version before changing the target.
- In Godot's Project Manager choose **Import**, select this directory's `project.godot`, then **Import & Edit**. Press **F5**, then click **Enter Physics Lab** on the preserved boot screen. Close the game window to exit. The original foundation title/status remain, with a Milestone 01 subtitle and entry button.

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

Actions are configured centrally. Letter keys use physical positions; Shift/Ctrl require the left location. Godot's ui_* defaults support native UI and are not alternate player movement bindings. Cyberware/interact/boss actions are reserved and have no M01 behavior.

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
| F3 | debug_toggle_overlay | Toggle lab measurements (debug builds) |
| F6 | debug_reset_lab | Reset lab player, camera and measurements (debug builds) |

## Playing and tuning the lab

A/D walks while grounded. Hold Space to charge while stationary, choose A/D direction, release to jump. Neither key or A+D gives a vertical jump. Taps produce minimum strength; full charge stays capped until release. Air steering is disabled. W/S looks up/down within safe camera limits. Esc pauses/resumes; pausing or losing focus cancels charge, so release and press Space again before another attempt. F6 resets in place without a scene reload; R is not repurposed. Holding Space through landing never automatically charges another jump.

Climb the numbered platforms toward LAB COMPLETE. The first steps teach short/medium jumps; upper 52–56px rises require near-full charge. All platforms are solid, so feet must clear the destination's side before crossing it. Falling loses altitude but returns to a lower platform/floor. F3 shows state, position, velocity, support, charge and last completed jump measurements. It is a developer overlay and deliberately covers part of the arena when visible.

Open resources/physics/default_player_physics.tres to tune the exported Resource; read [physics specification](docs/physics-spec.md) for units, equations, defaults and measured envelopes. Keep future difficulty modes on the same physics. After any change, rerun the physics tests and route check; do not assume earlier platform spacing remains valid.

## Structure and architecture

```text
project.godot       Project settings and InputMap
scenes/main/       Native boot UI
scenes/player/     Reusable prototype player
scenes/levels/regions/  Future continuous-world content
scenes/hazards/    Reusable hazards
scenes/characters/ NPC scenes
scenes/bosses/     Boss scenes
scenes/ui/         Lab HUD and future UI
scripts/          core/, player/, camera/, cyberware/, regions/,
                  hazards/, dialogue/, save/, audio/, bosses/, ui/
resources/        definitions/, physics/, difficulty/, camera/,
                  cyberware/, audio/, input/, regions/
assets/           sprites/, animations/, backgrounds/, tilesets/, audio/
tests/            Static, smoke, physics/integration checks and runner
docs/             Design, technical plan, roadmap and development log
AGENTS.md         Future coding-agent instructions
```

The player, lab, camera, HUD and physics Resource directories now contain implemented systems; remaining future directories contain only .gitkeep markers. scenes/levels/physics_lab.tscn is the playable lab; scripts/player holds the controller, config definition, shared jump calculation, visual and recorder. See [technical design](docs/technical-design.md) for ownership and [roadmap](docs/roadmap.md) for the M02 traversal-framework gate. No M02 systems are implemented.

## Validation

Run from the project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\validate_static.ps1
& $GodotExe --headless --editor --path . --import
& $GodotExe --headless --path . --quit-after 5
& $GodotExe --headless --path . --script res://tests/smoke_test.gd
& $GodotExe --headless --fixed-fps 60 --path . --script res://tests/physics_test.gd
# Automated sequence with isolated writable editor/user paths and engine-error checks:
.\tests\run_validation.ps1 -GodotExe $GodotExe
# Add -Render to generate lab frame PNGs under ignored .godot/.
# Direct lab startup (same project, bypassing boot for development):
& $GodotExe --path . --scene res://scenes/levels/physics_lab.tscn
```

Check exit codes **and** all engine output. Static checks are not a Godot parser. The smoke test checks actual settings/InputMap/boot bounds. The physics harness tests real solver behavior, live semantic input, UI/camera/reset/pause, navigation and ascent/recovery; it prints `PASS: 177 physics/integration checks` for the current suite. It prints five charge measurements and writes .godot/jump_measurements.json. The 330→360 px/s tuning comparison is reproduced on each run. Read the manual checklist in physics-spec.md and visually verify resizing/scaling; human input timing, subjective feel and Linux/export behavior remain separate from headless results.

In a restricted agent workspace, normal Godot editor/user-data paths may be unwritable. M00 validation temporarily redirected process-local APPDATA/LOCALAPPDATA into ignored `.godot/validation-user` and `.godot/validation-cache`, used a copy of the installed executable in `.godot/validation-engine` with an `_sc_` marker, and supplied absolute `--log-file` paths under `.godot/`. This did not alter the installed engine or machine settings. [Godot self-contained mode](https://docs.godotengine.org/en/4.4/classes/class_editorpaths.html) isolates editor settings; user-data redirection was additionally required. Do not change production user-data settings to work around an agent sandbox.

## Constraints and OneDrive

320×180 internal viewport, 960×540 initial window, integer viewport scaling with kept aspect, nearest canvas textures, GL Compatibility renderer, and a provisional fixed 60 Hz physics tick. The `4.7` feature tag matches the confirmed engine series. Do not upgrade/downgrade the agreed engine without recording the decision.

Source writes/readbacks succeeded locally. The parent carries OneDrive attributes; sync health could not be independently established. Keep the project locally available using OneDrive's **Always keep on this device** if appropriate. Avoid concurrent edits on multiple synced machines and allow sync to settle before switching machines. Git ignores `.godot/`, but this does not exclude it from OneDrive. If cache locking/conflicts occur, close Godot and discuss pausing sync or using a user-approved nonsynced checkout. Never move this project automatically.

Physics defaults have one documented provisional tuning pass. No rebinding UI, saves, export presets/templates, dependencies, production assets, knockback, moving platforms, slopes or campaign exist. Platform exports, physical held-key timing, extended human play, camera comfort and manual resize behavior remain unverified. Debug F3/F6 are editor/debug-build controls, not release gameplay actions.

## Fan-project and asset policy

This project is unofficial, unaffiliated with and not endorsed by the Cyberpunk/Edgerunners rights holders. Noncommercial intent does not grant IP rights or publication permission. Do not use extracted game/anime art, music, logos, voices or proprietary files. The boot screen uses Godot's native controls/default font and simple colors; no third-party assets were imported. Keep content IDs separate from display names so original characters/setting/assets can replace fan content before any public release. Public distribution needs a separate rights review.
