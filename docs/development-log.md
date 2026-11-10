# Development log

## 2026-11-10 — Milestone 00: foundation

### Implemented

- Verified the existing Cyberpunk_Game workspace, confirmed it was empty, and created only its cyberpunk-last-ascent child. Local writes/readbacks succeeded.
- Added project.godot, native boot scene, ten semantic physical-key actions, nearest texture filtering, integer viewport scaling and GL Compatibility rendering.
- Added organized scene/script/resource/asset folders with marker files rather than speculative code.
- Added README, agent instructions, design/technical/physics/level/art documents and M00–M08 roadmap.
- Added source-contract validator and headless engine smoke test; local Git setup and validation results are recorded below after execution.

### Decisions

- Scope stops at foundation; no player controller, gameplay manager, autoload or Resource class is needed yet.
- Future configuration uses typed Resources when a real consumer exists, separated by global defaults, authored shared data, session policy, per-player state, per-level content and user settings.
- Preserve continuous-world coordinates, shared physics across difficulty modes and local hazard time factors for Sandevistan.
- Provisional 320×180 internal viewport, 960×540 initial window and 60 Hz physics. Launch constants are intentionally not fabricated.
- User supplied the engine directory after initial discovery found no runnable executable. Confirmed local Tools/Godot/godot_console.exe reports `4.7.2.stable.official.ed1daf0bf`. No software was installed or extracted.

### Validation record

- Engine version command: PASS, `4.7.2.stable.official.ed1daf0bf`.
- Source validator: PASS, 89 checks, including a final Windows PowerShell run after documentation updates (structure, required documents, settings, ten physical key bindings/locations, boot text and res:// references). Generated script UID metadata is included in Git.
- Initial normal-path headless editor attempt: exited 0 **with errors**, therefore not accepted as a pass. The sandbox denied AppData editor writes, and the relative log path failed. A self-contained editor copy alone still encountered an inaccessible user:// directory.
- Resolution: used a temporary copy of the existing engine under ignored `.godot/validation-engine` with `_sc_`, redirected process-local APPDATA/LOCALAPPDATA into ignored project cache subfolders, and supplied absolute project-local log paths. Machine environment and installed engine were not changed. This follows [Godot's self-contained editor behavior](https://docs.godotengine.org/en/4.4/classes/class_editorpaths.html); process-local user-data redirection was needed in addition.
- Clean rerun: `--headless --editor --path . --import` exited 0 with no reported errors, missing resources or script parse failures. Import waits for resource scanning before quitting.
- Configured main-scene startup: `--headless --path . --quit-after 5` exited 0 without reported errors.
- Engine smoke: `--headless --path . --script res://tests/smoke_test.gd` printed `PASS: foundation smoke test` and exited 0. Checked main scene, fixed tick/display/filter settings, ten action event types/physical keys/locations/chord flags, expected UI text and on-screen label bounds.
- Compatibility rendering: `--path . --write-movie <project-cache>/boot.png --quit-after 2` exited 0, used OpenGL 3.3 on Intel Arc, and rendered two 320×180 PNG frames. Inspected the second frame: title, subtitle and success message are visible, legible and within bounds. Render/log output remains ignored under .godot/.
- Not performed: physical keyboard left/right modifier testing, manual window resize testing, Linux execution, exported desktop builds, or gameplay tests. These are distinct from configured InputMap/resource validation.
- Git review: initialized main inside the game directory only; verified .godot cache and build output are ignored; staged source review and `git diff --cached --check` passed. Baseline commit message: `Establish Milestone 00 Godot foundation and preproduction`. No remote push. The commit hash is available through `git log -1` (not embedded here to avoid a self-referencing hash).
- Cleaned the temporary validation-engine copy and empty editor-support folders produced at the project root by the failed initial editor-path attempt. Test logs and rendered frames remain ignored under .godot/.

### Environment and limitations

VS Code CLI status failed with EPERM and CIM process inspection was denied; the active VS Code window could not be independently confirmed. The supplied workspace and resolved current path agree. No pre-existing project or parent Git repository was present. OneDrive attributes were observed; no local file access problem was seen. Cloud sync state is not established. No OneDrive setting was changed or project relocated.

No player, physics lab, levels, saves, dialogue, cyberware, audio or boss exists. Windows/Linux exports and gameplay behavior are outside M00. Pixel-art assets and final typography remain future work.

### Next tasks

Use a separate M01 brief to build the jump prototype and greybox lab, measure provisional parameters, resolve wall/landing/platform/input edge cases, and record evidence before production geometry. Do not begin that work as part of M00.
