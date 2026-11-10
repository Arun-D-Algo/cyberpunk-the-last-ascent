# Technical design

## Decisions and current implementation

Godot **4.7.2 stable**, standard GDScript build, is confirmed by the local executable (`4.7.2.stable.official.ed1daf0bf`). Target platforms are Windows and Linux desktop. M01 adds a playable physics lab to the preserved M00 boot scene. No autoload or global manager is needed. The M01 systems below are implemented; campaign interfaces in later sections remain proposals.

## Implemented M01 composition

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
