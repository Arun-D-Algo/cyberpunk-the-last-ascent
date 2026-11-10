# Technical design

## Decisions and current implementation

Godot **4.7.2 stable**, standard GDScript build, is confirmed by the local executable (`4.7.2.stable.official.ed1daf0bf`). Target platforms are Windows and Linux desktop. M00 implements project settings, a native Control boot scene, input bindings and validation only. No autoload, game manager or configuration manager is needed to display the boot screen. All gameplay interfaces below are plans for future milestones.

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

No Resource scripts are necessary yet. Introduce a definition when its first real consumer exists, with units, editor ranges and validation. Proposed organization:

| Scope | Future data / responsibility |
| --- | --- |
| Project/global defaults | InputMap, physics tick, viewport, renderer, audio bus layout |
| Shared authored physics | JumpTuning Resource under resources/physics; immutable gravity, charge curve and launch ranges used by player and trajectory preview |
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

tests/validate_static.ps1 checks source structure/settings/contracts without an engine. Headless editor import checks resource parsing; headless startup checks the configured entry scene; tests/smoke_test.gd inspects loaded settings, InputMap and scene content. Visual review and physical left/right keyboard tests are separate. M01 adds a physics lab and repeatable tick-based measurements. Use deterministic initial conditions and tolerances, not screenshot-only physics claims. Record actual results in development-log.md.
