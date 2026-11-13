# Technical design

## Milestone 03B route composition

OpeningRoute lists explicit world positions and silhouettes, separate from the ordered jump graph. OpeningAscent instantiates those authored objects and uses fixed section heights. OpeningMachine shares each stepped, bracket or sloped outline between rendering and CollisionPolygon2D. The condensate tray selects the existing ice resource, and the two-face exhaust chute uses the existing ForcedSlide node.

The opening test checks every graph jump with the normal controller. Continuous replays start through the menu, walk between launches and exercise the main route and each fork. Fall scenarios check the camera, catch surfaces and continuation. The audit records width distribution, contact types and repeated jump patterns. Rendered reviews use the same production scene.

## Milestone 03A composition

OpeningAscent extends TowerAscent to reuse pause, reset and input handling, and overrides composition and altitude classification. OpeningRoute supplies the three-section destination data. OpeningMachine uses the same dimensions for native sprite crops and full rectangular collisions. OpeningBackdrop owns finite architectural layers, restrained city parallax, recessed attachments, corporate typography and existing IndustrialFixture animations.

The menu routes Start Tower Ascent to opening_ascent.tscn. The original tower scene remains an independent regression fixture. opening_test.gd validates all final geometry through discovery, nearby-input probes, fall recovery and continuous replay. tools/capture_opening_review.gd captures the actual rendered scene and a separate full-height SubViewport.

## Cinematic jump and landing presentation

PlayerVisual still selects charge keys from the controller's normalized charge and starts launch playback on jump_started. The existing landed signal and last_landing_velocity supply floor-normal impact speed. At 285 px/s or above, the four-key landing starts at the three-point impact. Softer contacts enter at the two upright recovery keys. Each key lasts 50 ms. Recovery can continue while the player is stationary and grounded after the controller's 60 ms landing state ends. Walk, slide, charge, airborne transitions and reset preempt it. Top rebounds retain airborne selection, and forced-slide entry retains its committed pose. No movement state, input lock or collider data is owned by the visual controller.

## Milestone 02G airborne visuals

PlayerVisual reads PlayerController's existing state and vertical velocity on the fixed-tick signal. Launch and wall-impact timers take precedence during their visual windows. An apex key bridges rise to early fall. Two configurable downward velocity thresholds choose the normal and fast animations with a 24 px/s hysteresis band. The band continues updating during wall-impact playback and resets outside falling. Each selection changes the AnimatedSprite2D frame only.

The active atlas and SpriteFrames come from tools/generate_david_02g.py, which reuses the 02F exporter and ground key data. The renderer checks that painted pixels fit inside a padded 40×40 cell. A (20, 38) pivot keeps the same feet origin while nearest filtering and the shared player interpolation carry the artwork through the scene.

## Milestone 02F forced-slide and visual boundaries

ForcedSlide authors a static downhill polyline, generates its solid PhysicsSurface segments and provides route configuration. Each segment references its owner through metadata. PlayerController recognizes that owner after floor contact, owns the committed movement state and continues using one solver move per physics tick. A designated exit, invalid geometry recovery or reset releases commitment. Invalid configurations report their authoring error at startup.

The visual controller selects a dedicated forced-slide animation from gameplay state. The enlarged cells use the same logical pixel density and anchor around the existing feet origin. Idle moves the head, sleeves, jacket and knees through authored pixels with stationary soles. Charge frames follow the existing charge fraction. Future cyberware effects can subscribe to the existing jump_started signal using the launch origin, strength and velocity, with upgrade eligibility supplied by that future system. This milestone adds no effects subscriber.

## Milestone 02E movement and animation

PlayerController derives downhill drive from supported polygon faces and bounds coasting drag on those inclines. Godot's floor classifier and snap continue to determine support. The shared player instantiates AnimatedSprite2D from Visual at runtime and keeps its collider scene hash. Visual observes physics steps, jump, rebound and reset signals. Charge and landing frames derive from gameplay progress. Launch and impact timers affect presentation. Walk advances in proportion to ground speed. The interpolated player transform carries the sprite and its invariant feet pivot.

The editable indexed pixel clusters and pose keys live in tools/generate_david.py. The generator produces the PNG atlas and SpriteFrames resource together. The runner adds slope_test.gd and character_animation_test.gd. See [Character art guide](character-art-guide.md).

## Milestone 02D — current architecture

The current playable root is TowerAscent, opened from boot. It composes one shared PlayerController scene and LabCamera/HUD with TowerRoute data and four FloorTheme Resources. All 60 pads, 8 return banks, base and side boundaries remain loaded; this small static prototype does not need streaming, autoload managers or scene-boundary teleports. Fixed world boundaries determine current floor on both ascent and descent. No checkpoint/Assisted/Classic campaign mode existed, so none was invented.

The same player.tscn is instantiated by PhysicsLab, EmergencyPowerChamber and TowerAscent. Normal launch math/Resource/collider keep their original SHA guards. The camera SHA guard was removed under explicit 02D authorization and replaced with engine-tested fractional transforms, long-fall visibility and interpolation checks. No camera or presentation code modifies velocity.

Rendering deliberately uses canvas_items at physical window resolution, nearest textures, integer scaling and 2D physics interpolation. Visual inherits its body's floating transform; Camera2D updates in physics mode without rounding, and reset clears interpolation history. Native 320x180 output remains physically pixel-limited. See physics-spec for alternatives and Godot references.

Contacts select one wall normal/body per move. Relative moving-collider velocity is reflected once; ceiling priority prevents corner impulses, contact identity suppresses repeat impulses, and optional diagonal energy redirection has a once-per-rising-jump budget. Surface coefficients are independently configurable. No collision is inferred from artwork or collider names; decorative reused shaft layers remain collision-free.

Diagnostics add last landing, zone/height/max and rebound information to the existing 10Hz F3 readout; traces remain bounded. Runner includes refinement_test and tower_test, scene startups, existing suites and 30/60/120 cadence probes for normal jumps, moderate stopping and ordinary rebounds. Static validation normalizes CRLF before regex anchors and checks explicit resource paths; this addresses Windows line endings, not gameplay correctness. Generated engine logs/measurements stay ignored; the reviewed report lives under docs/validation.


## M02B mechanics architecture (historical)

The new prompt explicitly authorizes physics refinement and supersedes the 02A controller freeze. The old controller hash guard was removed intentionally, **not replaced with an arbitrary new hash**; its behavioral protection is the existing 177-check suite plus measured baseline arcs and new surface scenarios. JumpPhysics, default_player_physics.tres, player.tscn collider and LabCamera remain protected by their existing hashes. M02A art/background assets and chamber composition are unchanged.

PlayerController still owns one fixed-step movement/solver call. Focused helpers handle tangent integration, contact/profile selection and bounded contact response. New typed SurfacePhysicsProfile and CollisionResponseProfile Resources separate authored surface/response data from baseline launch data and live state. Profiles on collision bodies use surface_physics metadata; untagged old geometry falls back to normal. Closest floor-contact X selects a profile; a wall's response overrides the player's response only when authored. Profile changes preserve velocity and affect the next integration; landings explicitly apply destination retention.

Slopes use actual CollisionPolygon2D normals and a rightward tangent. We integrate tangent speed ourselves, disable floor_constant_speed, and keep solver pressure separate from stored momentum because Godot clears the supported vertical component. Normal rest keeps floor_stop_on_slope; gravity ramps opt out and integrate configured downhill force. After a move, reconcile the intended tangent with the new normal (or stop at a floor/wall corner). Runoff transfers intended tangent velocity into airborne gravity. No animation/HUD/camera controls motion.

PhysicsSurface is the reusable AnimatableBody2D polygon scene, with optional sinusoidal offset/period as the minimum moving test fixture. It runs at priority -20 before the live player. The engine carries the player while supported; implicit velocity inheritance on leave is disabled. Explicit inheritance is optional and defaults to zero. The first post-reset move disables old floor carry layers only for that solve to discard cached platform motion, then restores the mask and normal contact detection. Tests verify exact reset position, carry/reversal/launch/landing/pause on horizontal/vertical/ice platforms.

LabSections composes isolated fixtures for A–G and three H challenges, preserving the original Classic layout. PhysicsLab owns a mouse selector, deferred geometry replacement, spawn/reset and moving-fixture resets. No new gameplay key actions or hardcoded keyboard checks were added. Focus-free selector/TRACE controls do not consume Space after a mouse selection. Scene-switch/reset clears live charge, recorder and camera state; no save or production region system is added.

JumpRecorder retains the original jump fields and adds impact counts, landing velocity/body/profile, slide travel and max slide speed. Samples are measured after actual solver moves; debug traces cap at 2048 points. LabDiagnostics optionally draws the actual collider, normal, velocity and recorded trace. F3 text updates at 10Hz only when shown and includes profile/drag/eligibility/normal/angle/contacts/landing velocity. The normal charge HUD is preserved. The debug panel is larger/opaque to fit data, intentionally covering the scene only when requested.

surface_physics_test.gd extends the existing real-tick harness; it is not a replacement framework. It tests Resource validation, baseline arcs, stop/rebound/ceilings, partial ledges, friction/reversal/eligibility, seam chains, slopes/ramps, moving platforms and every selector entry. frame_rate_probe.gd checks the same 60Hz arc at 30/60/120 render cadences. The Power Chamber's real route and arrow-input suite still run. Actual measurements and manual limits are in physics-spec.md/development-log.md.

The M01/M02A sections below describe the preceding foundation and remain historical context where 02B explicitly supersedes controller behavior. Godot API references used for carry/slope semantics: [CharacterBody2D](https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html), [engine floor-velocity handling](https://github.com/godotengine/godot/blob/master/scene/2d/physics/character_body_2d.cpp).

## Decisions and current implementation

Godot **4.7.2 stable**, standard GDScript build, is confirmed by the local executable (`4.7.2.stable.official.ed1daf0bf`). Target platforms are Windows and Linux desktop. M01 adds a playable physics lab to the preserved M00 boot scene. No autoload or global manager is needed. The M01 systems below are implemented; campaign interfaces in later sections remain proposals.

## M02A visual composition and regression boundary

The user approved M01 movement in the 02A brief. Its controller, launch formulas, default physics Resource, collider scene and LabCamera code remain byte-for-byte unchanged and are guarded by SHA256 in visual_prototype_test.gd. Player Visual changes are presentation only; InputMap adds four physical arrow events to the existing semantic actions. There is no second movement path.

EmergencyPowerChamber composes existing player/camera/HUD scenes plus IndustrialPlatform, IndustrialFixture and ChamberBackdrop. It owns its six-platform layout, boundaries and prototype-only pause/reset/entry title. It introduces no region/checkpoint system, persistent state, hazards or broad room framework. Both this chamber and the Physics Lab remain independently runnable via boot buttons.

IndustrialArt centralizes 23 integer AtlasTexture regions in a 256×256 original texture. IndustrialPlatform separates its 8px rectangular collision from tiled/cropped visual sections. IndustrialFixture reuses a small effects atlas and local animation clocks for fans/lamps/monitor/sparks/steam, without collision. ChamberBackdrop places oversized finite textures/machinery assemblies with rounded vertical parallax offsets. ChamberAtmosphere adds faint pixel-aligned color spill and a segmented power trunk. The room root assembles these parts; it is not one giant drawing script.

tools/generate_art.gd is the versioned editable source for PNGs and the bitmap FNT. Art is generated offline, not every game frame. Committed .import sidecars retain lossless/no-mipmap settings; nearest filtering is global and explicit on decorative sprites. The 320×180 viewport, integer scale and Compatibility renderer remain unchanged. No heavy shaders, bloom or plugin dependencies. resources/ui/industrial_theme.tres supplies original bitmap typography/StyleBoxes for the HUD and boot. The player Visual rounds only its presentation position and reads existing movement states.

tools/capture_visual_review.gd captures actual root viewport images at lower/middle/upper staged positions, plus an independent 320×420 SubViewport overview. It resizes only by integer nearest scaling; the overview is a wider lens, not the gameplay zoom. docs/visual-review/.gdignore prevents review PNGs becoming runtime textures. The 02A test suite reuses the existing real-tick harness and checks physical key dispatch, protected sources, actual loaded/imported art, atlas bounds, collision tops, animation initialization, HUD, boot navigation, parallax coverage and complete chamber reachability.

## M01 implementation details

- scenes/player/player.tscn: reusable CharacterBody2D, 10×24 rectangular collider at feet origin, procedural Visual and JumpRecorder component. Player layer 2/mask 1; world layer 1/mask 2. The 14×26 visual exceeds collider width for readable ledge placement; visual changes cannot affect collision.
- PlayerController owns semantic input, enum states GROUNDED/CHARGING/RISING/FALLING/LANDING, fixed-tick velocity and one move_and_slide call. No level/UI node references. State changes, launches, landings, completed physics steps and resets are signals. Tests call the same step_movement once per real physics tick; live input is separately tested through Godot's InputEventAction dispatch.
- PlayerPhysicsConfig is an editable Resource, authored in resources/physics/default_player_physics.tres. Validation rejects nonfinite values, invalid ranges and sampled nonmonotone/out-of-range curves before enabling player physics. Null curve means linear. JumpPhysics is the shared pure normalization/direction/launch model.
- JumpRecorder connects to player signals and samples after each completed move. It retains one completed jump, reports signed displacement rather than path length, and clears on reset. No disk writes during normal play. The harness exports a comparison report under ignored .godot/.
- PhysicsLab owns static geometry, spawn, pause, debug actions and reset. One PLATFORMS table supplies drawing/collision; tests climb the actual solids. The lab root runs while paused to receive Esc/F6; player/camera/geometry are pausable. HUD runs while paused to show status. No campaign/region/save responsibilities.
- LabCamera is a reusable Camera2D with exported target/dead-zone/look/tracking/world bounds. It follows physics ticks after the player, smooths an internal center, then rounds display position to pixels. A visibility guard limits look/tracking lag to keep the silhouette on screen below the HUD. This trades subpixel fluidity for pixel stability; assess at native scale.
- LabHUD receives a player reference from the lab and reads state/recorder without changing physics. The normal meter updates every rendered frame; debug text formats at 10 Hz only while visible. No UI paths in the player.
- boot.gd connects the existing boot screen's Enter Physics Lab button to a scene change and reports failures. No menu framework.

F6 reset and F3 overlay act only in debug builds; retry_boss is unchanged. Reset moves the existing player, clears transient state/measurements and resets camera tracking without reloading the scene. Floor contact is reacquired next tick because cached is_on_floor belongs to the previous transform. Pause/focus loss cancel charge and require release/repress. Minimum taps always launch. Exact rules are in physics-spec.md.

## M01 test harness

tests/physics_test.gd extends the existing dependency-free SceneTree convention. It builds real StaticBody2D fixtures, drives the production controller at 60 Hz, dispatches live semantic events separately, and tests calculations, states, taps/caps, air input, reset/pause, wall/ceiling/narrow/edge collisions, repeated arcs, camera, HUD, boot navigation, twelve-platform ascent and fall/recovery. It measures the actual solver. --fixed-fps 60 accelerates simulated ticks without changing the model; results do not establish subjective feel or cross-platform bitwise determinism.

tests/run_validation.ps1 takes -GodotExe, temporarily redirects child-process AppData/cache into .godot, runs import/startup/foundation/physics checks, and rejects engine errors even on exit 0. -Render captures actual Compatibility-rendered lab frames. The static validator accepts editor-expanded InputEventKey serialization and omitted default aspect=keep; the engine smoke verifies loaded values. This preserves the user's pre-existing editor rewrite instead of reverting it to satisfy a brittle text check.

Use snake_case paths/scripts/resources and PascalCase nodes/classes. Scene dependencies point downward to components/data; communicate upward using typed signals. Prefer scene-local ownership over singleton access. Godot Resources hold authored data; Nodes own active behavior. Do not make mutable runtime state shared by accidentally modifying a loaded Resource used by multiple scenes.

## Planned scene ownership and interfaces

| Responsibility | Owner / planned boundary |
| --- | --- |
| GameManager | Future campaign scene root; session mode and current run, not physics or dialogue internals |
| PlayerController | CharacterBody2D player root; reads intent, owns velocity and move_and_slide |
| PlayerStateMachine | Player component for grounded/charging/airborne/knockback; start with enum and transition methods, extract only if needed |
| JumpPhysics | Pure launch calculation from charge, direction and immutable tuning; no input, animation or scene lookup |
| CameraController | Scene-local camera rig follows player, applies region constraints and manual look |
| RegionManager | Campaign-owned streaming and adjacency; emits region readiness/change |
| HazardSystem | Reusable hazard components, local timing and explicit eligibility for time effects |
| CyberwareManager | Player-owned unlock/runtime energy and cooldown state; requests explicit effects from eligible targets |
| DialogueManager | Campaign/UI-owned interaction runner; data IDs, completion signal and input ownership |
| SaveManager | Future persistence service; autoload only if lifetime must outlive campaign scene |
| AudioManager | Future bus/settings and scene cues; autoload only for cross-scene continuity |
| BossController | Encounter-local phase state and retry context, not a campaign singleton |

Possible signals include landed(position), region_ready(id), checkpoint_reached(id), dialogue_finished(id), and encounter_finished(id). These names are proposals, not APIs callers can assume exist. Pass node references/data through composition rather than searching globally or building a universal event bus.

## Input and state

Project Settings InputMap is the sole source for default gameplay bindings. All ten actions use physical keys; primary/secondary cyberware additionally specify left key location. Input sampling produces semantic intent (direction, charge started/held/released); gameplay consumes it in _physics_process. Handle press/release edges once, with explicit ownership during pause, dialogue or UI focus so one event cannot both dismiss dialogue and launch a jump.

Rebinding later replaces action events using InputMap and persists overrides in user settings. Reset-to-default reconstructs the authored bindings. Alternative charge behavior should produce the same intent interface; it must not be implemented as a second set of physics rules. Godot's default ui_* actions remain engine UI defaults and are unused in M00; they are not added gameplay controls.

## Physics and camera

60 physics ticks per second is a provisional project setting. Use velocity units px/s, gravity px/s², time seconds and move_and_slide for CharacterBody2D collisions. Never integrate movement in _process or couple it to animation. Fixed ticks improve predictability; they do not promise bitwise determinism across hardware or Godot versions. See physics-spec.md for unresolved wall/platform behavior.

The future camera rig should follow vertical progress with a configurable dead zone, bounded manual W/S look, and region/room limits. **Proposal:** ease between limits over a short authored interval, snap on explicit checkpoint restore, avoid camera zoom changes that obscure reach. Camera and region triggers use world coordinates and stable IDs; no scene should reposition the player merely because the camera crosses a screen boundary. Reduced motion should suppress shake without changing gameplay.

## Regions and checkpoints

Each region is a composed scene with authored origin, local geometry, entry/exit markers, camera bounds, checkpoint markers and neighboring IDs in a future RegionDefinition Resource. Godot +Y points downward: climbing uses more negative Y. Preserve a shared world origin and place region roots at authored offsets; do not reset coordinates at transitions.

**Proposal:** keep current region plus adjacent regions instantiated; preload/load the next safety band before a body can enter it. A fall may skip several screens: determine the swept player/camera interval and ensure every intersected region is collision-ready before movement, not just the visually current one. Keep prior collision scenes until no active body can return during the unload horizon. If testing exposes stalls or missed collisions, keep the entire greybox loaded until measured evidence justifies streaming.

Checkpoint representation: stable region_id + marker_id + schema/version, resolving to an authored safe spawn transform. Store optional local fallback coordinates for migration, not NodePaths or instance IDs. Validate space above feet and reset velocity, charge and transient hazards on restore. Assisted automatically activates approved region anchors; Classic disables that policy. Persistent manual saves and mode switching semantics need later decisions. See level-design.md.

## Configuration scope

M01 introduces PlayerPhysicsConfig for its real player consumer. Introduce other definitions when their first consumer exists, with units, editor ranges and validation. Scope organization:

| Scope | Future data / responsibility |
| --- | --- |
| Project/global defaults | InputMap, physics tick, viewport, renderer, audio bus layout |
| Shared authored physics | Implemented PlayerPhysicsConfig under resources/physics; shared player/test launch model; future trajectory previews must reuse JumpPhysics |
| Per-session mode | DifficultyProfile Resource under resources/difficulty; Assisted default; checkpoint policy, hazard timing, recovery/assist flags, never jump constants |
| Per-player runtime | Charge, energy, cooldowns, unlocked IDs; separate from authored CyberwareDefinition data |
| Per-level | RegionDefinition and camera tuning/limits, spawn markers, hazard resources |
| Per-user | Audio levels, remapped actions, charge interaction, assist visibility, reduced motion; versioned settings file later |

Camera defaults may be shared, with explicit per-region overrides. Energy capacity/cost/cooldown belong to ability definitions; current values belong to player runtime state. Do not create a giant global dictionary for all scopes.

## Hazards, cyberware and dialogue

Hazards advance a local elapsed-time accumulator using physics delta multiplied by an explicit time factor. Eligible enemies/platform hazards may accept a Sandevistan factor; player motion, charge and camera never inherit it. Do not use Engine.time_scale. Define cooldown/energy clock domains explicitly; proposal: real physics time for player cooldowns, eligible time for hazard cycles. Visual telegraphs must remain synchronized with actual collision states. Moving platform support requires separate collision/carry tests.

Future cyberware definitions describe ID, permanent/temporary category, activation constraints, energy/cooldown, eligible effects and UI data. Player ownership references unlocked IDs. Regions depend on capability IDs, not display names. Keep effect application explicit and reversible on exit/unload.

Dialogue data references stable speaker IDs and localization-ready lines. Trigger nodes request a conversation; the UI runner owns focus and emits completion. Narrative state belongs to the campaign and save snapshot, not individual Label text. Linear story progression should survive revisiting regions without repeating one-time grants.

## Persistence and boss

Save implementation is later: proposed versioned JSON under user:// with separate settings and campaign snapshots. Persist mode, checkpoint IDs, unlock IDs, narrative flags and required run state. Validate types/ranges/IDs, reject unsupported future schemas gracefully, migrate older schemas explicitly, write to a temporary file then replace and retain a previous backup. Never deserialize arbitrary objects from user data. Save/restore, corrupted file and interrupted-write tests are required before claiming reliability.

Boss encounter scenes own phases, telegraphs, arena components and retry anchor. Retry requests are valid only inside active encounters. Reset hazards, phase timers, player transient state and effect factors together while preserving permanent unlocks. A phase transition must remain understandable as platforming, not invisible health arithmetic. Exact fight mechanics remain a separate design task.

## Rendering, performance and export

320×180 viewport, viewport stretch, kept aspect and integer scaling; initial window is 3×. Canvas texture filter is nearest. Compatibility renderer is sufficient for M00 and avoids requiring Vulkan. Measure pixel art and native-font readability in a real window; pixel-perfect textures do not guarantee a suitable production font. See [Godot multiple-resolution guidance](https://docs.godotengine.org/en/4.3/tutorials/rendering/multiple_resolutions.html) and [key/location enumerations](https://docs.godotengine.org/en/4.6/classes/class_%40globalscope.html).

Profile physics, collision counts, hazard updates, transparent effects, texture memory and streaming stalls before optimizing. Favor simple collision shapes and atlas reuse. Do not build custom pooling or asynchronous streaming without measured need.

Later create Windows x86_64 and Linux x86_64 export presets with matching engine export templates. Store non-secret presets in Git, credentials locally, output in ignored builds/ or exports/. Test exported startup, input, scaling, saves and platform paths on both systems. No exports/templates are installed or configured in M00.

## Validation

tests/validate_static.ps1 checks source contracts without an engine. Headless import checks parsing; startup checks the entry scene; smoke_test.gd inspects loaded settings, InputMap and boot; physics_test.gd validates actual gameplay. Physical keyboard timing, human feel and exports need separate checks. Use deterministic conditions and tolerances. Record actual results in development-log.md; M00 history does not imply M01 manual acceptance.
