# Development log

## 2026-11-12 - Cinematic David sprite and jump animation

Started on bfbe80b with a clean tree. Reviewed the 02G atlas, standing and head crops, takeoff and descent strips, plus the earlier full-body illustration. Redrew the upright dark-brown crown, compact face, planted charge, launch and landing. Removed the airborne jacket tails and kept the 40×40 grid, (20, 38) pivot and nearest filtering. After the first Godot render, folded the deep-pose jacket hem to expose the knee, sharpened the crown, brightened the planted hand and lowered the fastest descent arms.

The existing visual controller now selects a hard or soft landing from floor-normal impact speed. The hard impact starts with a three-point pose and can finish recovering during idle. A charge or movement allowed by the player controller takes priority immediately. Charge compression is indexed by the existing charge fraction. Physics sources, collider, camera and scenes are identical to the starting revision.

Godot 4.7.2 passed import, boot, smoke and chamber, Lab and Tower startup. Regression totals were 191 animation, 177 movement, 168 visual/input, 665 surface, 115 refinement, 55 slope and 393 tower checks, covering all 60 route landings. The 30, 60 and 120 FPS probes passed, including 53 forced-slide checks per cadence. Static validation passed 260 checks. The review package includes native and 4× comparisons and a real Lab A jump capture. Final art approval is pending.

## 2026-11-11 - Milestone 02G David anatomy and airborne animation

Started on a21851c with the existing editor reorder in project.godot. Used the attached full-body David illustration for the compact face, swept crown, jacket opening and knee folds. Used the 02F atlas as the before image. Reused the ground poses and made the export function reusable. Regenerating 02F reproduced its PNG and SpriteFrames byte for byte.

The new 40×40 cells leave space for air poses at the existing character height and feet origin. Refined the shirt overlap and widened each trouser leg through the thigh and knee. Added three launch keys, three rise keys, an apex key and three fall bands. Downward speed selects normal at 75 px/s and fast at 315 px/s. Hysteresis is 24 px/s. Spread arms and two layered jacket tails widen and lift across the descent. During the first review the far sleeve read as detached and a raised near sleeve interrupted the face. Connected the shoulder fold and composited the head over the sleeve.

Captured the native and enlarged before/after, anatomy, takeoff and descent strips. Godot Compatibility rendered the character in the tower and each fall band in Lab A. The art remains open for owner approval.

Godot 4.7.2 passed import, smoke and boot, chamber, lab and tower startup. The runner passed 176 animation checks including frame padding, pivot, a real fall, hysteresis and impact recovery. Existing suites passed 177 movement, 168 visual/input, 665 surface, 115 refinement, 55 slope and 393 tower checks, including all 60 continuous landings. The forced-slide checks passed 53 per render cadence at 30, 60 and 120 FPS, with normal movement cadence probes passing as well. Static validation passed 254 checks.

## 2026-11-11 - Milestone 02F forced slides and David redraw

Started on 0e52ae0 with the existing editor reorder in project.godot. The earlier ramp code integrated gravity with ordinary input and braking. Added a separate ForcedSlide polyline component and committed controller state. Real polygon contacts gate entry and the authored tangent keeps movement coherent across both faces and brief support loss. An explicit exit plane restores control, with a separate warning and escape path for obstructed geometry.

Lab R–V cover passive travel, walking and reversal attempts, jump lock, two connected faces, and a missed jump followed by open-end recovery. From commitment to exit they took 64, 69, 64, 65 and 31 physics ticks respectively at all three render cadences. The deliberate obstruction fixture warned and returned control. The gap fixture lost and reacquired floor support at a 3 px step without releasing the slide.

Inspected the three user attachments and redrew the 24×40 sprite in a 32×40 cell. The new 28 keys use a compact face, broader jacket, separated sleeves, two baggy legs, planted idle bob and athletic crouch. The dedicated forced-slide pose follows the gameplay state. Reworked the far shoulder connection and facial edge after inspecting the first render. Captured native and enlarged atlas, tower and connected-route evidence in the 02F review package.

On Godot 4.7.2, 248 static checks and the full validation runner passed. The runner recorded 177 movement, 168 visual/input, 665 surface, 115 refinement, 55 slope, 109 animation, and 393 tower checks, including all 60 tower landings. Forced-slide checks passed 53 per cadence at 30, 60 and 120 FPS. Import, smoke, boot, lab, chamber and tower startup passed. The obstruction warning is intentional test evidence. Owner motion and art approval remain pending.


## 2026-11-11 - Milestone 02E ramp movement, David prototype and environment rules

Started at bd8e87c on main. The working tree already contained an editor reorder of the physics section in project.godot. That edit is preserved outside the milestone commit. Godot reported 4.7.2.stable.official.ed1daf0bf.

Measured four controlled-ramp fixtures before touching the controller. The 12-degree fixture stalled. The 18.435-, 35- and 30-degree fixtures peaked at 0.633, 1.148 and 1.001 px/s and failed to reach their runouts within 12 seconds. The flat drag step erased downhill gains each tick. The rest threshold compounded the problem on shallow inclines.

Capped unforced downhill drag relative to projected drive and kept the rest cutoff for zero-drive surfaces. The floor solver still owns support. Long-ramp testing exposed reported normal drift and a speed drop on a constant face. The integrator now uses a closely matching nearby authored face after confirmed ramp contact. All four fixtures slide on their first supported tick, reach the runouts in 2.217–10.867 seconds, and show zero airborne ticks. Added a mirrored ramp and Lab O–Q. Full measurements are in physics-spec.md.

Created a 25-key palette-indexed David prototype and SpriteFrames generator. The shared visual controller observes movement steps and jump, rebound and reset signals. Charge and landing poses follow gameplay progress. The sprite follows the existing interpolated transform. Inspected the first atlas and refined the hair silhouette, shoes and reaching arm. Captured actual 320×180 and 960×540 tower frames and a four-frame ramp sequence using the Compatibility renderer. Character art guide records what reference material was accessible and the remaining likeness and motion review.

Documented environment-integrated architecture as the default platform vocabulary and recorded the provisional eight-region progression in level-design.md.

Verified 239 static source checks and the full Godot validation runner. Import, smoke and boot, chamber and tower startup passed. The suite recorded 177 physics, 168 visual/input, 645 surface, 115 refinement, 55 slope, 96 animation and 393 tower checks. All 60 tower landings and the 30/60/120 fps cadence probes passed. Graphical review used tools/capture_david_review.gd on Intel Arc. Owner slope feel and visual approval are pending.


## 2026-11-11 - Physics acceptance and GitHub repository preparation

The project owner manually tested and explicitly approved the current physics: "the physics is working perfectly fine now." The owner then requested a new GitHub repository using the game name, the full project/history and proper README/documentation, and selected public visibility. This authorizes the repository creation and push for this task.

Updated the README to distinguish the implemented four-floor prototype from future campaign scope; added feature/milestone summaries, a real engine screenshot, portable clone/run instructions and a documentation index. Added docs/session-summary-2026-11-11.md covering delivered milestones, mechanics, measured before/after ice control, floor lengths, validation, approval and remaining scope. Roadmap and physics/validation status now distinguish accepted physics from remaining route/art/platform work. No gameplay, tuning or source assets changed.

Created the public repository https://github.com/Arun-D-Algo/cyberpunk-the-last-ascent under the verified owner account, with a project description and Godot/platformer topics. README/session-summary local links, tracked credential-marker checks, 226 static checks, Godot headless import, startup and smoke all passed for this documentation update.

Existing implementation validation remains the measured baseline (226 static; 177 physics; 168 visual/input; 633 surface; 115 refinement; 393 tower checks; startup and cadence probes). Publication documentation receives source/link checks plus the project-required import/startup/smoke checks. GitHub publication is verified separately against the pushed main SHA and repository visibility. Generated caches/logs/exports and credentials remain excluded.


## 2026-11-11 - Milestone 02D: refined contacts and continuous vertical gameplay

Inspected the user brief, existing instructions/design docs, controller/state/config/surfaces, collision/moving-platform policy, lab/chamber/camera/UI/tests and Git. Starting tree was clean on main at c77edf4. Verified the installed 4.7.2.stable.official.ed1daf0bf. The complete baseline runner passed before edits (177 physics, 169 visual/input, 608 surface checks and render-cadence probes). The latest brief authorizes camera refinement and a main-game route; no missing 02C work was inferred.

Diagnosed 02B ice: 30 px/s2 released drag, 198 px/s2 acceleration, .92 landing retention and 8px/s charge threshold. Added separate reverse braking and mild/moderate/extreme Resources; extreme preserves the old coefficients. Moderate uses .45 acceleration, 2x opposite-input braking, .12 drag, .68 landing retention, 12px/s charge threshold and 1px/s exact-rest cutoff. Solver measurements from 65px/s: released stop 69.875px/2.167s -> 14.127px/.450s; reversal 10.117px/.333s -> 2.042px/.083s. Uncorrected full-landing coast after the same recovery: 372.748px/4.983s -> 35.700px/.717s. Charging remains stationary and fresh-press only. Updated H1 to position, brake and charge; changed the runoff fixture and driven seam approach to exercise intended transitions with stronger drag instead of relying on the obsolete long coast. Fixed outward floor-edge contacts incorrectly zeroing a slider's velocity.

Diagnosed visible ramp steps in sprite rounding, camera rounding and the native viewport framebuffer, not integer physics or staircase geometry. Selected canvas_items at physical window resolution with nearest textures/integer scaling, fractional inherited player transforms, 2D interpolation and interpolation resets. The physics tick remains 60Hz. Removed only the explicitly obsolete camera SHA guard; normal launch formulas/config/collider keep original hashes. At 320x180 physical output, pixel quantization remains unavoidable. Nine actual 960x540 Compatibility captures on Intel Arc were inspected for layout/crispness; subjective moving-image comfort is pending human testing.

Ordinary untagged walls/platform sides now use .6 restitution above 30px/s horizontal relative impact. Vertical motion is preserved. One side contact is selected, persistent collider+normal identities suppress duplicates, ceilings win at corners, supported walking corners stop and moving collider velocity is applied once. Optional diagonal response redirects bounded horizontal energy into rise only once per rising jump; default is disabled. Optional top restitution defaults to zero and ordinary landings remain stable. Added I-N lab fixtures, real mirrored/high-speed/moving-side/diagonal/persistent-contact/top-pad tests and recorder/F3 rebound/zone/height/landing data.

Added TowerAscent, shared player/camera/HUD, authored TowerRoute and replaceable FloorTheme Resources. Four floors contain 15 required landing destinations each: Public Access 720px, Commercial Atrium 736px, Restricted Infrastructure 732px, Maintenance Ascent 820px; total 3008px from y144 to y-2864. Eight reference ricochets, six moderate-ice destinations and two controlled ramp/runout destinations reuse existing shaft/platform art. No source asset PNG was changed, no checkpoint teleport/loading boundary/streaming manager/story/final art/combat/save system was introduced. Zone display formatting updates only on transitions.

Validation used actual final-geometry solver motion. Discovery trials were followed by a separate continuous walk/brake/charge replay of all 60 landings, including collision-sequence assertions, without inter-platform teleports. Ideal simulation time 115.467s; human multi-minute pacing is unmeasured. Walking off the summit produced a 1263.750px fall into floor 3, peak 600px/s, 2.417s, with camera visibility, solid landing, recovery charge, pause/cancel and explicit base reset verified. Early geometry failures (overheads, future walls obstructing approaches, marginal side/edge landings) were corrected rather than hidden by weaker checks.

Final executed commands from project root:

```powershell
.\tests\validate_static.ps1
.\tests\run_validation.ps1 -GodotExe 'C:\Users\Arunangshu Dasgupta\Tools\Godot\godot_console.exe'
# Graphical QA with process-local AppData/cache isolation and an absolute ignored log:
& $GodotExe --path . --script res://tools/capture_refinement_review.gd --log-file $CaptureLog
```

Results: 226 static source checks; headless import, boot/chamber/tower startup and smoke; 177 physics, 168 visual/input, 633 surface, 115 refinement and 393 tower checks; 30/60/120 render-cadence probes all passed. The visual count drops one because the authorized camera hash is replaced by behavior coverage. The static checker now handles CRLF anchors and explicit floor Resource paths. Capture command passed on the Compatibility renderer; git diff --check passed. Generated engine logs/cache remain ignored; measured ice/ricochet/60-pad recipes and the manual checklist are committed documentation.

Implementation criteria are engine-verified. Remaining acceptance: human feel, interpolation comfort, physical input timing, route variety/difficulty/pacing and long-session hardware performance; Linux/exports are untested. A perfect reference run is under two minutes, so several-minute human duration is a design intention rather than a fabricated measurement. Alternative charges may bypass some banks. The final eight-region campaign and final floor art remain future work. No push was performed.


## 2026-11-10 — Milestone 02B: precision physics and surface mechanics

### Inspection, authorization and preservation

Verified project root, main branch and Godot 4.7.2.stable.official.ed1daf0bf. M02A was actually committed at f2d044a, following cb1ce10 and 5460018. Read existing instructions/docs and inspected player/config/math/collider, lab, chamber, art architecture, camera/HUD/recorder, InputMap and tests. The only initial user change was project.godot's editor-expanded event serialization and omission of the default 60Hz setting; preserved it. Static validation now accepts an omitted default tick while the engine smoke verifies 60Hz. No unrelated files, source art/backgrounds, collider or camera were changed.

The new user brief explicitly authorizes controller refinement. This supersedes the 02A source-freeze instruction for this scope. Removed only the obsolete controller SHA guard, not arbitrary new hashes or behavior checks; remaining four protected launch/config/collider/camera hashes still pass. The visual suite count becomes 169 from 170 for that documented reason. No user artistic approval is inferred, and no future production work was started.

### Baseline established before implementation

Ran the complete existing validation runner before edits: import, boot/chamber startup, foundation smoke, 177 physics checks and 170 visual/input checks passed. Saved the baseline measurement report under ignored .godot and copied the original tuning to resources/physics/m01_baseline.tres for comparison. Same-height normal-ground results at 60Hz: minimum/25/50/75/full rises 11.267/21.196/33.610/50.607/69.015px and ranges 15.006/33.822/57.279/92.950/132.007px. Flight times 0.333/0.450/0.550/0.683/0.800s.

### Implemented systems and files

- SurfacePhysicsProfile and CollisionResponseProfile Resource definitions, normal/ice/gravity-ramp/rebound-wall data and default/opt-in contact response Resources. Surface coefficients modify baseline walking; no hidden jump scaling or duplicate launch formula.
- PhysicsSurface reusable AnimatableBody2D polygon scene with profile metadata and optional sinusoidal motion. Real polygon collision matches drawn fixture boundaries. World layer 1 / player layer 2 is retained. Moving fixture priority -20, live player priority 0.
- PlayerController integrates supported tangent speed, chooses actual contact profiles/normals, preserves seam momentum, applies explicit landing retention and bounded airborne wall response, and gates charging by surface speed. Normal inclines rest without drifting; only designated ramps accelerate downhill. Stop remains the ordinary wall default. Optional restitution is 0.25 on marked test walls; ceiling kick defaults zero. No default air steering, ledge grab, buffered charge or double jump.
- Explicit moving support carry/departure policy and reset handling. Passenger is carried while supported; implicit departure boost is disabled. Reset's first solve suppresses stale cached carry then reacquires real contact.
- LabSections, Physics Lab selector and LabDiagnostics. Preserved Classic climb; added A calibration, B walls/rebound, C ceilings, D ledges, E ice, F slopes, G gravity ramps, H1 ice/narrow target, H2 rebound/roof and H3 ramp/runoff/moving recovery. Direct selection, supported spawns and F6 reset are tested; no long climb required. Selector/TRACE use focus-free controls, not new keyboard checks.
- Extended JumpRecorder with collision counts, launch/landing profile/body, incoming landing velocity, slide travel/speed and capped actual trace. Landing's airborne movement tick is excluded from slide distance. F3 adds profile/friction/normal/angle/sliding/contact/eligibility/landing fields; optional TRACE shows actual body bounds, normal, velocity and history. Normal HUD retained.
- surface_physics_test.gd and frame_rate_probe.gd extend the existing dependency-free harness. Runner executes all prior regressions, new mechanics and cadence comparisons. Updated README, AGENTS, physics/technical/level docs and roadmap; boot subtitle/entry text and version identify 02B without redesigning the menu.

### Actual comparisons and deliberate tuning

The final normal jump envelope matches all five baseline rows within 0.05px; no baseline launch constant/curve, gravity, fall cap or landing recovery was retuned. The old 330→360px/s trial remains a historical M01 check, not a new tuning change.

Measured stopping from 65px/s: normal 1.250px / 0.067s; ice 69.875px / 2.167s. Reversal: normal 0.083s, ice 0.333s. Ice retains 92% of tangent impact momentum, has drag 30px/s², and requires speed ≤8px/s before a fresh stationary charge. Normal still brakes immediately when charging.

Stop wall changes incoming +165px/s horizontal to 0. Opt-in restitution 0.25 changes it to -41.25px/s without increasing incoming speed magnitude. Default ceiling response remains zero; configured 5px/s downward response is separately tested, including immediate contact.

Normal 14.03° / 34.99° polygon slopes show 0.0000px drift over the measured 30-tick rest interval, with continuous uphill/downhill support. A designated ramp reaches the configured 150px/s cap. Initial new ramp input influence 0.40 left +66.222px/s downhill speed after three seconds of counter-input from the cap; increased only this new coefficient to 0.65, which regains control and reaches -63.059px/s uphill. Both trials are reproduced using a duplicated trial Resource, not by mutating authored data. Ramp drag=48px/s², effective input acceleration=234px/s², configured downhill coefficient=260px/s²×sin(angle), charge limit=6px/s.

### Failures found and corrected

- Generic old bodies have no surface metadata. An initial nullable get_meta call logged errors; changed to explicit has_meta fallback, preserving ordinary solids rather than requiring retrofitted scenes.
- Normal slopes drifted when engine constant-speed reprojection and our contact pressure interacted. Disabled the duplicate reprojection and separated pressure from intended tangent state. Godot clears supported vertical velocity; retaining that modified pressure as momentum also inverted the first ramp trial. Corrected stored tangent velocity after the solve, with real support/zero-drift tests.
- Reset from a moving carrier initially shifted the new spawn by cached engine carry. Added a first-solve carry-layer suppression and exact-position regression; horizontal, ice and vertical carrier reset cases pass.
- Immediate-ceiling test initially inspected after advancing beyond the contact tick. Corrected it to inspect the already-completed launch/contact before stepping again; no physics exception or relaxed assertion.
- Combined H3's moving recovery was placed below the transfer route to avoid a ramp/headroom pinch. Recovery floor is y=176 and carrier y=152. Real reference routes now verify D's 24/16/8px climb plus all H1/H2/H3 goals without inter-jump teleports.
- Recorder's landing tick was excluded from surface travel; a dedicated flat-runout test matches measured slide integration to actual displacement within 0.05px and verifies initial retained speed.

### Validation actually executed

- Baseline runner: clean pass before modifications, as recorded above.
- Static source checks: PASS 193 at final implementation review (not an engine parser).
- New mechanics suite: PASS 608 surface/mechanics checks in the latest direct run, including real collisions/ceilings/rebounds, partial ledges, friction/reversal/eligibility/runoff/reset, normal/ice/slope/ramp seams without extra landing events, genuine slopes, bounded ramps/control trials, horizontal/vertical/ice moving supports, paused carriers, exact reset spawn, all 11 menu entries, HUD/trace and actual combined challenge routes.
- Complete runner also verifies unchanged 177-check M01 behavior/Classic route, 169-check 02A art/input/Power Chamber route, import, boot/chamber startup and foundation smoke. Final full sequence after recorder/combined-route changes: PASS import, boot startup, chamber startup, foundation smoke, 177 physics checks, 169 visual/input checks, 608 surface checks and all three cadence probes. Final static checks: PASS 193. No engine parse/resource/startup errors were reported.
- Render cadence probes at 30/60/120 with physics fixed at 60Hz measured the same full arc: rise69.015px, dx132.007px, flight0.800s. This tests controlled simulated render cadence, not hardware performance or OS key timing.
- Graphical engine probe rendered slope section and ice F3 diagnostics into ignored .godot PNGs at 320×180 with nearest 3× enlargement. Inspected both: section selector, actual sloped polygons, actor, TRACE toggle and detailed text fit the viewport. Debug text measured 144×107px in its 312×129px panel; made debug background opaque for readability. Screenshots are engineering checks, not new art or a claimed interactive playtest.
- git diff --check, staged file/ignore review and cache exclusion before commit. Logs and reports are in ignored .godot; source Resources/scripts/.uid metadata are versioned. Nothing pushed, previous history not amended.

### Known limitations and next gate

Implementation is ready for user acceptance, with no known critical automated failures. Subjective ice/rebound/ramp feel, physical held-key timing, camera comfort under these challenges, long hardware sessions, Linux and exports remain unverified. Floor limit is still ~45°; steeper planes are walls. Very long polygons return slightly varying solver normals, so debug angle is observed rather than an ideal analytical value. Slide-distance integration is a relative tangent estimate (exact on tested flat runouts), not total world path length at every clipped corner. Traces cap at 2048 samples. Moving motion is a minimal sinusoidal fixture, not production platform routing.

Follow the explicit manual checklist in physics-spec.md, including all selectors, ice charging/braking, ramp counter-input, wall/ceiling/edge cases, combined routes, pause and carrier reset. After user acceptance, agree a separate next milestone for production traversal/region integration. No new story/art, full regions, combat, cyberware, saves or bosses were built.

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
