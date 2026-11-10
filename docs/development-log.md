# Development log

## 2026-11-10 — Milestone 02A: Neon Industrial Decay visual prototype

### Status, inspection and authorization

Implementation complete for user visual review; artistic approval is pending. M02B has not begun. The user's 02A brief explicitly records satisfactory manual testing/approval of M01 movement. Inspected instructions, design/physics/level/technical/art/roadmap docs, player/lab/camera/HUD, renderer/InputMap, test infrastructure and Git history. Verified project path and Godot 4.7.2.stable.official.ed1daf0bf. Starting tree was clean at cb1ce10; no user modifications were discarded.

### Art direction and original pipeline

Established Neon Industrial Decay: navy/steel/slate architecture, selective cyan powered systems, yellow service/warning emphasis and sparse magenta faults. Interpreted the requested high-level Edgerunners/Katana ZERO/SANABI/The Last Night influences without importing their assets. Added visual-style-guide.md, asset-manifest.md, a GIMP palette and tools/generate_art.gd as editable original integer-pixel source. The generator produces a 256×256 industrial atlas with 23 named regions, two 320×512 depth layers, a 128×64 effects atlas, six 16×32 humanoid placeholder cells, and an original bitmap diagnostic font. No external asset/font/software dependency or paid API.

### Implemented composition

- One emergency_power_chamber.tscn under scenes/regions/sublevel_zero, composing the unchanged player/camera and styled existing HUD. Floor plus six service ledges, including a 24px landing, enclosed recovery space and a marked upper-relay exit placeholder. No complete region, transition system, checkpoint, hazard, cyberware, combat, dialogue or save logic.
- Reusable IndustrialPlatform and IndustrialFixture scenes; IndustrialArt atlas vocabulary; ChamberBackdrop with rounded finite-layer parallax; lightweight ChamberAtmosphere. Decorative machinery/animation has no collision or hazards. Geometry remains independent from its tile/sprite appearance.
- Generator housings, wall/support structure, pipes, actuators, console, monitors, damaged panels, cable runs, warning signs, vents, lamps, fan, sparks and steam. No bloom/full-screen shader/renderer switch. Animated clocks pause with gameplay.
- Presentation-only humanoid sprite selection, facing and pixel rounding replace the debug rectangle. Collider/body coordinates, approved physics Resource, launch math, controller and LabCamera source are unchanged. Visual suite verifies all five protected source hashes.
- Original bitmap font and industrial Theme improve boot/HUD. Preserved charge/direction/state/debug feedback and Physics Lab button; added Power Chamber entry and a brief nonblocking room title. F3/F6/Esc work in the chamber; R remains reserved.
- Added Left/Right/Up/Down physical events to move_left/move_right/look_up/look_down. Existing WASD and all other action names/keys remain. Mixed A+Right and Left+D are neutral through the unchanged controller's semantic intent path.

### Actual validation and iteration

- Godot --version: confirmed 4.7.2.stable.official.ed1daf0bf.
- `--headless --path . --script res://tools/generate_art.gd`: clean PASS after correcting background-line canvas clipping. Initial unbounded raster lines logged out-of-bounds errors; these were fixed rather than ignored. A subsequent rebuild produced byte-identical PNG/FNT hashes.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate_static.ps1`: PASS, 167 source checks at final implementation review.
- `tests/run_validation.ps1 -GodotExe <confirmed Godot console path>`: headless import, configured boot startup and foundation smoke PASS; original 177 physics/integration checks PASS with exactly unchanged measured jump envelope and twelve-platform lab route. New visual-prototype suite initially passed 162 checks, then was extended to 170 checks for actual fixture frame changes, chamber pause, frozen decorative clocks and fall recovery. Final runner PASS: import, boot startup, direct chamber startup, foundation smoke, 177 physics/integration checks and 170 visual/input checks.
- `--headless --fixed-fps 60 --path . --script res://tests/visual_prototype_test.gd`: PASS 170 visual/input checks. Covers all eight physical movement/look key mappings/releases, mixed opposites, baseline source hashes, loaded texture pixels/import settings/no mipmaps, atlas bounds, real rectangular collision/contact alignment, initialized/advancing animations, HUD charge/state, boot navigation, six actual platform landings, look coverage at three heights, reset/pause and fall recovery.
- Chamber route landed approximately (101.717,111.981), (210.301,63.981), (83.884,11.981), (212.467,-40.019), (94.717,-92.019), (204.883,-144.019), using unchanged approved impulses/gravity/charge settings. No teleport between route jumps. Full reference launch table is in level-design.md.
- First physical input test arrived before the initial viewport/focus flush and failed only its first A press. Added an explicit two-frame startup wait before physical-event injection; all eight mappings then pass. No movement or InputMap rule was changed to hide that test failure.
- Actual OpenGL Compatibility capture via `--path . --script res://tools/capture_visual_review.gd -- --initial-art`, then without that flag. A first overview attempt used a nonexistent SubViewport property; corrected it to an explicit World2D before the successful package capture. Final capture logs have no reported errors/warnings.
- Inspected initial start, refined start, full-room, mid-climb and upper-room PNGs. Initial weakness: similar contrast on machinery and landings. Refined with warning end caps, subdued midground, faint warm/cyan spill, a segmented vertical power trunk, additional framing and route hints. Before/after retained as an actual-scene reproducible comparison.
- Review package: docs/visual-review/milestone-02a, with 320×180 native gameplay views, 3× previews, 320×420 native-density overview, HUD crop, atlas preview and 2× before/after. Player positions are staged for composition; no human playthrough or user artistic approval is claimed. No desktop input/Computer Use was performed in 02A.
- Git diff whitespace/source review and ignore checks run before commit. Imported cache/logs/reports remain under ignored .godot; PNG/FNT source/import metadata and review images are intentionally versioned. Nothing pushed; prior milestone history preserved.

### Limitations and next gate

No known critical automated regressions. This is one visual slice and an initial art library, not final character animation or the full Sublevel Zero region. Upper exit is a placeholder. Font is intentionally tiny ASCII diagnostic lettering; localization/large-type UI and global reduced-effects settings are future work. Lighting is painted pixels/alpha spill, not physically shadowed lights. Finite parallax is tested for this chamber only. New chamber human playfeel/physical arrow-key feel, resize/high-DPI, long-session performance, Linux and exports remain unverified. OneDrive local access worked; cloud sync state remains unknown.

Wait for the user's visual approval of palette, scale, atmosphere, route/player readability, typography and depth before any 02B implementation. Keep M01 movement locked; future 02B scope requires a separate prompt.

## 2026-11-10 — Milestone 01: playable physics laboratory

### Status and scope

Implementation, tuning and automated acceptance pass. Full manual playtesting remains pending. M02 has not begun. Existing M00 boot/project/Git history remain intact. Initial Git status had an editor-generated project.godot rewrite (expanded key events and omitted defaults); it was preserved, not discarded. Current prompt resolves the older provisional charge formula and movement policy in physics-spec.md.

### Files and systems

- Added player.tscn, PlayerController with five enum states and semantic input, PlayerPhysicsConfig plus default .tres, shared JumpPhysics, procedural original Player Visual, and JumpRecorder.
- Added physics_lab.tscn with authored solid geometry and lab-owned pause/reset; LabCamera with vertical follow/look/pixel rounding/visibility guard; lab_hud.tscn and LabHUD with separate charge and debug panels.
- Added boot navigation script/button while retaining original title/status; updated subtitle/version to M01/0.1.0. Added F3/F6 actions without changing retry_boss.
- Extended existing static/smoke tests and added physics_test.gd plus run_validation.ps1. No test framework, plugins, downloaded assets, autoloads, production regions, saves, abilities, dialogue or combat.
- Updated README, AGENTS, game/technical/physics/level design and roadmap. Commit source .uid metadata; ignore editor caches, reports, logs and rendered frames.

### Architecture and behavior

One reusable CharacterBody2D owns movement; UI/visual/camera/recorder never alter physics. Configuration is authored Resource data and runtime state stays on the player. Ground acceleration/deceleration are configurable; charging is stationary; taps launch minimum strength; both A+D/neither are neutral; capped full charge waits for release; no default air steering or double jump. Physics runs at 60 Hz and calls move_and_slide once per tick. Solid rectangular collision uses world layer 1 / player layer 2. Reset reacquires floor support next tick, clears motion/charge/measurements and resets the camera without a scene reload. Pause/focus loss cancels stale charge.

### Measurements and tuning

Measured real solver launches on a same-height floor at 60 Hz, rightward, no air control. Minimum/25/50/75/100% requested charges respectively produced rises 11.267/21.196/33.610/50.607/69.015px, signed displacements +15.006/+33.822/+57.279/+92.950/+132.007px, and flight times 0.333/0.450/0.550/0.683/0.800s. Tick-quantized effective strengths and exact hold times are in physics-spec.md. Normal play records start/landing, initial velocity, actual charge, peak rise, signed displacement, flight duration and wall/ceiling flags in memory; automated comparisons also write ignored .godot/jump_measurements.json.

Initial maximum vertical impulse 330px/s gave rise 57.765px, dx121.008px and flight0.733s: insufficient clearance margin for 56px upper gaps. Raised only this parameter to 360px/s (rise69.015px, dx132.007px, flight0.800s) and adjusted intended launch positions for solid-side clearance. Other defaults remained unchanged. The harness reproduces both configurations and completes twelve actual platform landings, from feet (45,144) to approximately (208.454,-444.019), then validates a fall to lower recovery. This establishes reachability, not enjoyable subjective feel.

### Checks actually executed

- Godot executable --version: 4.7.2.stable.official.ed1daf0bf, matching the approved target.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate_static.ps1`: PASS, 123 source-contract checks. The validator now handles compact and editor-expanded InputEventKey serialization; loaded values remain engine-tested.
- `tests/run_validation.ps1 -GodotExe <confirmed console executable>`: PASS for headless --editor --import, configured main-scene startup (--quit-after 5), smoke_test.gd, and physics_test.gd (--fixed-fps 60). Latest run: PASS foundation smoke and PASS 177 physics/integration checks. No reported engine parse/resource/startup errors. The runner isolates child-process AppData/cache/logs within ignored .godot and restores process environment afterwards.
- Physics coverage: charge formulas/clamps/curve/config validation; directions; five states; taps/caps/ground acceleration/stopping; stationary charging; air input/double-jump prevention; held key through landing; pause and reset; real walls/ceilings/narrow/edge/terminal-speed collisions; repeated and mirrored arcs; measurement output; boot button navigation; HUD/debug; camera look/follow; whole route and recovery. Live InputEventAction dispatch is tested separately from direct physics stepping.
- First integration run failed three checks: falling-wall fixture was not intersecting the falling path, S-look assertion ignored the intended bottom bound, and the upper route lacked clearance. Corrected fixtures/assertion to test the intended behavior, tuned the real physics/route, then reran successfully. No failing checks were suppressed.
- `tests/run_validation.ps1 -GodotExe <confirmed console executable> -Render`: PASS at the 163-check stage; rendered twelve 320×180 lab frames using OpenGL 3.3 Compatibility on Intel Arc. Inspected a final lab frame for player/platform/HUD layout. Later changes added live-input/recovery checks and revised boot subtitle/button ordering; final import/startup/smoke/177-check suite passed afterwards.
- Brief native-window inspection through the computer-use skill showed the running lab and pause overlay. Computer Use then reported that the user stopped it with physical Escape; no further desktop input was issued. This is not a completed interactive playthrough and no subjective game-feel claim is made.
- `git diff --check`: PASS before final documentation staging. Staged source/metadata review and cache-ignore verification are performed before the milestone commit. No push or history rewrite.

### Remaining manual acceptance / limitations

No known critical automated startup or gameplay failure remains. Physical held-key timing, extended interactive traversal, camera comfort, debug text readability during play, window resize/high-DPI behavior, varied render-FPS playtesting, Linux and exported builds are unverified. No final art/audio exists. Minimum hops are intentionally small (11.267px) and cannot clear the first16px step; review this with the user. Full manual checklist is in physics-spec.md. OneDrive sync health is not established; local files remain accessible and the destination/settings were not changed. An interactive debug window was left untouched after Computer Use was stopped.

### Next milestone gate

Before M02, collect user feedback on charge responsiveness, small-hop usefulness, ledge alignment, wall/ceiling clarity, camera look/dead zone and fall recovery. Preserve default reach unless intentionally retuning and revalidating geometry. M02 can then add connected greybox regions and checkpoint/difficulty policy using this player/camera foundation under a separate prompt.

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
