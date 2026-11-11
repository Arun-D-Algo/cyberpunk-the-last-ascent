# Physics specification

## Milestone 02F forced downhill obstacles

The earlier gravity ramps apply downhill drive while still accepting braking, uphill travel and charge input. That remains useful for ordinary traversal. A ForcedSlide node opts a specific static route into a separate committed player state. Normal ground, ordinary slopes and controllable ice use their own existing surface rules.

The node builds solid polygon faces from an ordered, strictly downhill polyline. A solver-confirmed top contact enters the state, cancels charge and uses the greater of configured entry speed and incoming downhill momentum, capped at maximum speed. Side-only and underside contacts use their normal collision responses. After entry the fixed tick integrates downhill speed and follows the authored tangent. The controller selects each face using the uphill edge of the rectangular collider. The physics solver resolves all movement and the existing floor snap. Brief support loss across a seam retains commitment and applies downward pressure while reacquiring the route. Connected faces share one route and one speed.

| Setting | Lab default |
| --- | --- |
| Direction | Right. A left-descending route uses decreasing X points |
| Entry speed | 58 px/s |
| Minimum speed | 45 px/s |
| Acceleration | 145 px/s² |
| Maximum speed | 156 px/s |
| Exit velocity | 74 px/s downhill, 0 vertical |
| Exit clearance | 6 px beyond the final face |
| Optional tangent smoothing | 0 s, immediate change at the authored seam |

Charge duration stays zero and directional input has no effect on speed or facing. At the exit plane the controller applies the configured exit velocity and resumes grounded or airborne movement. Space must be released before another charge. Pause retains the state and reset clears it. A route stalled against an obstruction for 0.25 s logs a geometry warning and restores control with re-entry suppressed until the player leaves support or contacts another slide. Test scenes exercise this recovery. Author static, unscaled routes under 45 degrees with clear headroom and a tested runout or lower catch surface. The gap fixture covers a 3 px drop. Larger gaps, moving slides and branching paths require separate design and validation.

Lab R–V cover passive descent, walking entry and reverse input, Space lock, connected faces and a missed-jump penalty. Section V exits into a lower recovery floor. Existing production ramps remain traversable comparison surfaces.

## Milestone 02E slope movement

At 60 Hz the former integrator applied a full flat drag step, then a downhill gravity step. On the controlled ramp, drag was 144 px/s² while gravity projected to 37.95 px/s² at 18.435 degrees. Drag erased the previous tick's gain and left roughly 0.632 px/s every tick. On a 12-degree slope the 0.5 px/s rest cutoff erased even that gain. The character always moved in fractional world coordinates. Slow movement made physical pixel steps conspicuous despite interpolation.

On designated slopes at or above their minimum angle, drive is the configured downhill acceleration times the signed slope sine. With no directional input and with motion downhill or at rest, drag is capped at 75% of the drive magnitude. This leaves at least 25% available to build speed after the first tick. The flat rest cutoff applies when downhill drive is zero. Uphill motion and active braking use their existing rules. Supported movement derives the slide condition and charging excludes it.

After the solver confirms floor contact on a gravity-slide polygon, a nearby authored edge with a closely matching normal supplies the movement tangent. The solver decides contacts and seams with its existing floor snap. The controller falls back to the reported normal if no matching edge is nearby.

Nearest-filtered canvas_items rendering preserves fractional movement at the window's physical resolution. The sprite follows the interpolated player transform. At 320×180 the raster advances a physical pixel at a time. Even 3× rendering can repeat a raster position at very low speed.

| Controlled fixture | Before, peak in 12 s | After, first tick | After, peak | Time to flat after fix |
| --- | ---: | ---: | ---: | ---: |
| 12°, 36 px, joined runout | 0.000 px/s | 0.416 px/s | 20.999 px/s | 3.333 s |
| 18.435°, 24 px, joined runout | 0.633 px/s | 0.632 px/s | 21.345 px/s | 2.217 s |
| 35°, 180 px, separate platform | 1.148 px/s | 1.147 px/s | 86.324 px/s | 4.983 s |
| 30°, 720 px, separate platform | 1.001 px/s | 1.000 px/s | 120.000 px/s | 10.867 s |

Each fixture starts from rest after acquiring support near the upper edge. None reached the runout in 12 seconds before the fix. All four began sliding in 16.7 ms afterward, with zero airborne ticks. The 18.435-degree left-descending mirror matched the right-descending speed and traversal time. The first tick shows projected drive from rest. Subsequent downhill acceleration is approximately 6.24, 9.49, 17.21 and 15.00 px/s² respectively until the cap or runout.

| Degrees | Speed at tick 6 | Tick 12 | Tick 30 | Tick 60 |
| --- | ---: | ---: | ---: | ---: |
| 12 | 0.936 | 1.559 | 3.431 | 6.549 |
| 18.435 | 1.423 | 2.372 | 5.218 | 9.961 |
| 35 | 2.581 | 4.302 | 9.464 | 18.068 |
| 30 | 2.250 | 3.750 | 8.250 | 15.750 |

Speeds are in px/s. The measured movement normal was constant on each straight face until the runout. The long fixture previously reported 29.977–30.028 degrees while creeping. An intermediate full-speed trial with the raw solver normal reported 26.565–31.607 degrees and recorded a speed drop on the same face. The final movement tangent follows the authored 30-degree face.

Playtest Lab O **Shallow**, P **Tower Ramp** and Q **Steep** with no input, then brake or walk against the descent and charge after coming to rest. Use F3 to check support and slide status. Compare 320×180 with 960×540. The [render sequence](visual-review/milestone-02e/ramp_timeline.png) shows the controller moving through successive slope positions. Motion feel remains open for human playtesting.

## Milestone 02D — current authoritative behavior

Owner playtest acceptance, 11 November 2026: the current physics is explicitly approved. The detailed checklist below remains useful for future regression/route reviews; it no longer represents a pending physics approval gate.

The 02D brief supersedes older camera/rendering freezes and the 02B experimental ice default. Normal launch equations, impulse Resource, 10x24 collider, fixed 60Hz simulation and no default air steering remain unchanged. Older sections below describe the historical milestones where they differ.

### Ice diagnosis and tuning

02B ice retained 92% of landing momentum, used acceleration 198 px/s² and released drag 30 px/s². Reverse input had no separate braking gain. A full landing retained 151.8 px/s while charging required <=8 px/s: this forced long approaches and coasts, making small pads frustrating. Profiles now distinguish mild, moderate (`ice.tres`, tower default), and optional extreme (the preserved 02B coefficients).

| Profile | acceleration scale | reverse multiplier | drag scale | landing retention | charge threshold |
|---|---:|---:|---:|---:|---:|
| Mild | .65 | 2 | .25 | .45 | 12 px/s |
| Moderate | .45 | 2 | .12 | .68 | 12 px/s |
| Extreme / old 02B | .22 | 1 | .025 | .92 | 8 px/s |

Moderate acceleration is 405 px/s², opposite-input braking 810 px/s², released drag 144 px/s². Moderate/mild snap residual speeds below 1 px/s to exact zero; normal/extreme retain .5. Reverse braking multiplies acceleration only while input opposes momentum, then ordinary acceleration takes over. Fresh Space presses below the profile threshold enter stationary charging and zero velocity; tiny fluctuations do not cancel it. Rejected holds never buffer a later launch. Ice seams preserve velocity and apply destination coefficients on the following integration.

| Actual 60Hz measurement from 65 px/s | Old/extreme | Moderate | Mild |
|---|---:|---:|---:|
| Released stop distance | 69.875 px | 14.127 px | 6.500 px |
| Released stop time | 2.167 s | .450 s | .217 s |
| Opposite-input reversal distance | 10.117 px | 2.042 px | 1.083 px |
| First negative velocity | .333 s | .083 s | .067 s |
| Full-jump landing coast after recovery | 372.748 px | 35.700 px | 4.458 px |
| Time for that remaining coast | 4.983 s | .717 s | .183 s |

Landing coast is measured after the same .06s landing recovery, without corrective input. It excludes travel during recovery; it is not the reverse-braking distance. Real solver reports and all route recipes are in [02D validation](validation/milestone-02d.md).

### Smooth slopes and deliberate rendering compromise

Physics already used floating-point position/velocity and real polygons, not stair colliders. Visual.global_position.round(), camera.round(), and a strict 320x180 `viewport` framebuffer quantized the display. Removing only physics rounding would not have fixed this because there was no physics rounding.

Chosen: logical 320x180 coordinates, integer scaling, `canvas_items` rendering at the physical window resolution, nearest texture filtering, automatic Godot 2D physics interpolation, fractional sprite/camera transforms. At 960x540, translations can advance one physical pixel (one third of a source pixel), while source pixels remain crisp. The visual now inherits the body transform; camera processing is physics-driven. Teleports/reset call reset_physics_interpolation. The 60Hz physics and normal jump envelope do not change.

Alternatives: retaining `viewport` plus interpolation still quantizes the final 320x180 image; global linear filtering blurs artwork; a higher physics tick does not fix native-pixel quantization. At a 320x180 window, one physical pixel still equals a logical pixel: arbitrary continuous visual movement is impossible there. This rendering compromise introduces the usual interpolation latency and allows sub-source-pixel placements instead of a globally locked source-pixel grid.

Godot references: [multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html), [2D interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/2d_and_3d_physics_interpolation.html). Actual 960x540 Compatibility captures are in docs/visual-review/milestone-02d; static frames establish layout/crispness, not subjective motion comfort.

Slope contact pressure remains separate from tangent momentum. Grounded wall stopping now checks inward velocity against the selected wall normal; an outward floor-edge contact must not zero momentum and glue a slow slider to the edge. Controlled production ramps use .6 acceleration, 2x reverse braking, .12 drag, .5 landing retention, 120 px/s cap and downhill acceleration 120*sin(angle). The laboratory retains its stronger 150 px/s ramp for comparison.

### Universal contact response

Untagged solid walls and platform sides now use the player's default CollisionResponseProfile: REBOUND, restitution .6, minimum horizontal relative speed 30 px/s. Classification uses solver normals and floor_max_angle, never object names. Surface Resources may override the response; the old magenta fixture explicitly retains .25 as a comparison. Supported floor/wall corners stop inward walking rather than bouncing. Ordinary top contacts still land; undersides interrupt ascent and never launch upward.

For a vertical side with collider velocity u, w = incoming-u. Outgoing relative x = sign(normal.x)*abs(w.x)*restitution; relative y is preserved, then u is added once. Relative speed is bounded to the incoming relative magnitude. Moving walls may transfer their own energy in world coordinates; the bound is deliberately in the collider's frame. There is no extra engine departure carry.

At most one selected side impulse per move; collider instance plus normal identifies persistent contacts. Separation permits a legitimate new contact on the next side without a coarse timer. Simultaneous ceiling contact suppresses the side impulse; ceiling response wins. Below-threshold touches do not rebound. Reset clears contact/impulse counters. Tests cover mirrored 20/65/165/500 px/s impacts, moving sides, corners and prolonged supported pressure.

Diagonal redirect is independently opt-in (default fraction 0). Only the first rising impact of a jump may redirect a fraction f of the post-restitution horizontal energy into upward motion: transfer <= vx²*f, new |vy| <= max(old |vy|, configured vertical limit), and vx is reduced by exactly the energy used. Falling impacts stay horizontal, subsequent contacts cannot redirect again, restitution <=1 and relative speed remains bounded. Default limit 300 px/s; it never increases an already faster rise. Lab N opts in to .5; the main tower uses the ordinary horizontal response.

Optional `top_restitution` defaults to zero. Explicit special-pad profiles can reflect downward relative normal motion above 30 px/s, bounded to incoming relative speed; ordinary tower pads do not use it. No double jump, upward wall kick, random impulse or air steering was added.

### Lab routes and shared implementation

Lab I: from (126,144), .75s right, wall x200, land (176.831,96), one rebound. J uses the same measured route against the vertical side of a 24px raised pad. K: from (180,144), .75s right, shaft walls x160/208, reach the 16px exit at y80 after two opposing impacts. L: .70s right against x188, rising momentum preserved, return to y96. M repeats I from a moderate-ice launch after stopping. N uses L's geometry with the explicit diagonal override. Exact current landing coordinates/times are recorded in validation.

All use the same player.tscn/PlayerController/JumpPhysics/Resources as the tower, Classic lab and chamber. JumpRecorder adds rebound count/normal/impulse/type; F3 includes current zone, world height, maximum height and last landing body. The laboratory has CLASSIC + A-G/H1-H3 + I-N direct selector entries and optional TRACE collision/velocity/normal views.


## Manual acceptance checklist (physics approved; retain for regressions)

- Ice: enter from normal ground, coast, counter-steer, reverse, stop completely, then hold/release Space. Try an early rejected charge, release/repress after braking, and compare mild/moderate/extreme tuning. Extreme is optional and absent from the tower.
- Slides: use Lab F/G/H3 and tower pads 37/52. Observe shallow/steep/short/long polygon ramps at 960x540 and larger integer windows; counter-steer, run onto flat ground, run off, hit a wall and jump after braking. Compare 320x180, where display movement necessarily remains whole physical pixels.
- Rebounds: Lab I/J/K/L/M/N. Hit ordinary walls from both directions; hit a raised pad's side, top and underside. Complete the return jump and two-wall shaft. Verify L preserves the rise and N explicitly redirects energy. Try low-speed supported corners without jitter. Moving-side response is automated; moving fixtures remain in H3.
- Main game: Start Tower Ascent, climb all four floors and 60 numbered pads, inspect floor signage/tints, intentionally miss a transfer, fall into an earlier floor, brake/recover and continue. Reach PROTOTYPE SUMMIT. F3 shows zone/height/max/last landing/impulse; F6 explicitly resets to base, Esc/focus loss cancels charge and pauses.
- Repeat WASD/arrows, W/S or Up/Down camera look, charging/slide pause and reset, different render FPS/window sizes. Judge ice feel, timing tolerances, visual smoothness and route variety; automation does not supply human approval.


The controller is measured in Godot 4.7.2 at 60 Hz. The user approved the earlier movement and explicitly authorized collision/surface refinement in 02B. The normal-ground launch constants and linear curve remain unchanged; new surface tuning is provisional pending playtesting. Difficulty modes must share baseline launch physics. No coyote time, jump buffering, ledge grab, double/wall jump, dash or default air steering is introduced.

## Historical 02B rules and precedence

PlayerPhysicsConfig remains the baseline. CollisionResponseProfile owns wall/ceiling/platform-departure settings; SurfacePhysicsProfile owns walking/drag/retention/slide/charge policies. PhysicsSurface is a reusable AnimatableBody2D polygon with optional sinusoidal movement. Ordinary untagged solids resolve to the normal profile, so the existing lab and chamber need no geometry changes. Authored data is not mutated by the controller.

On solver floor contacts, choose the contacted profile nearest the feet X (first solver result on a tie); update its normal and name. Apply the new coefficients on the next grounded tick. Switching profiles never multiplies velocity or grants an impulse. Landing is a separate transition that explicitly applies the destination's retention. Contact metadata is surface_physics; no name-based surface branches exist in the controller. Floor classification uses floor_max_angle (~45 degrees). A steeper plane is a wall, not a floor. Invalid Resources report errors and fall back to normal contact behavior; invalid fixture geometry/configuration reports errors rather than silently running.

| Surface parameter | Normal | Ice | Sliding ramp | Units / meaning |
| --- | --- | --- | --- | --- |
| acceleration_scale | 1 | 0.22 | 0.4 | baseline ground acceleration multiplier |
| friction | 1 | 0.025 | 0.04 | released-input drag / baseline deceleration |
| ground_speed_scale | 1 | 1 | 1 | walking target multiplier |
| landing_momentum_retention | 0 | 0.92 | 0.85 | retained incoming tangent component |
| maximum_slide_speed | 180 | 180 | 150 | px/s along tangent; cap applies on special sliding surfaces |
| stop_speed | 0.5 | 0.5 | 0.5 | px/s; smaller residuals become zero |
| charge_speed_limit | 1000 | 8 | 6 | px/s along tangent before accepting a fresh press |
| moving_charge_allowed | false | false | false | accepted charges brake to stationary |
| jump_momentum_retention | 0 | 0 | 0 | explicit opt-in only, useful with moving charge |
| gravity_slide | false | false | true | only designated ramps accelerate downhill |
| minimum_slide_angle | unused | unused | 10 | degrees |
| downhill_acceleration | unused | unused | 260 | px/s² times signed sin(slope angle) |
| input_influence | 1 | 1 | 0.65 | multiplies active-input acceleration |

friction is our kinematic dry-drag coefficient, not a Godot RigidBody PhysicsMaterial friction value. Effective released drag is 1200×friction px/s². Effective input acceleration is 900×acceleration_scale×input_influence px/s². These parameters do not duplicate a second unrelated friction/deceleration mechanism.

## Ground tangent integration and slopes

For floor unit normal n, rightward tangent u=(-n.y,n.x). Integrate signed speed v along u: approach the input walking target with effective input acceleration, or approach zero with effective drag. A designated ramp above its minimum angle also adds DOWN.dot(u)×downhill_acceleration×delta; clamp special-surface speed and clear tiny drift. Ordinary ramps do not receive this force and remain stationary without input. Counter-input on gravity ramps competes with the force; no new air steering compensates for sliding.

Movement uses u×v plus inward contact pressure for one move_and_slide. Godot can clear vertical velocity on supported motion; after the solve, restore the intended tangent component using the new floor normal, excluding contact pressure. Wall+floor support stops tangent motion. At a ramp runoff, keep intended tangent momentum and apply world gravity. This prevents uphill drift caused by feeding solver pressure into the next tick's momentum. floor_constant_speed is disabled because tangent motion is integrated explicitly; normal rest uses downward pressure with floor_stop_on_slope, while designated ramps disable that automatic stopping. Fixed snap remains 1px and safe_margin remains 0.02px.

Tests use genuine polygon ramps, not staircase boxes. Shallow 14.03-degree and steep 34.99-degree normal ramps show 0.0000px rest drift over 30 ticks, continuous uphill/downhill support and successful baseline-impulse jumps. Long collision polygons can return slightly varying solver normals; debug angles are measured normals, not ideal authored-angle claims. Repeated support and bounded motion are tested.

## Charge eligibility and momentum transitions

Normal ground accepts a charge immediately and brakes, retaining the familiar rule. Ice/ramp rejects a fresh press above its speed limit, sets no charge, and does not buffer the held key until the player slows. Release then press again below the limit. Once accepted, default charging is stationary even on a designated ramp. A future profile can explicitly allow moving charge and configure inherited tangent momentum; shipped profiles leave both off, so no hidden jump-distance modifier exists.

Normal landings erase relative momentum. Ice/ramp project the incoming velocity onto the destination tangent, apply retention and cap it; recovery lasts the same 0.06s while drag/slide continue. Standing on normal slopes does not slide. Crossing a seam while supported preserves velocity and applies new coefficients next tick, rather than instantly zeroing or multiplying it. Ice-to-normal ground therefore brakes strongly but continuously. Tests traverse normal→ice, ice→slope→flat and ramp→ice→normal without repeated landing events. Walking/sliding off an edge retains committed momentum; air charging remains disallowed.

## Deliberate wall and ceiling responses

Default wall mode is STOP: the solver removes blocked horizontal motion. Vertical motion follows gravity. REBOUND is opt-in on the player response or on a contacted wall profile, with per-wall response taking precedence. The supplied wall fixture uses restitution 0.25: +165px/s becomes -41.25px/s. A rebound only occurs on a new inward airborne impact, never simply from standing against a wall on a floor. Clamp response energy to at most the incoming speed magnitude. Persistent contact does not count as another impact every frame.

Ceilings interrupt ascent, keep allowed horizontal motion, and transition into falling. Default downward kick is zero. Optional ceiling_downward_speed is bounded by both its 0..100px/s configuration range and incoming vertical impact speed; the suite exercises a 5px/s response. Ceiling/wall/floor corners remain solver contacts with no ledge assistance. Eight ceiling scenarios cover neutral/diagonal low-to-near-apex hits; partial-overlap versus true-miss tests cover an 8px ledge.

CollisionResponseProfile defaults: STOP, wall_restitution=0.25 (unused by STOP), ceiling_downward_speed=0, platform_velocity_inheritance=0. Resource validation rejects nonfinite/out-of-range coefficients and restitution above one. No claim of exact proprietary Jump King mechanics or subjective rebound quality is made.

## Moving-platform policy

PhysicsSurface optionally moves by offset×sin(TAU×time/period) at physics priority -20, before the live player, with AnimatableBody2D sync_to_physics. Normal and slippery horizontal carriers and a vertical carrier are tested through reversal, launch, landing, pause and reset. While supported, Godot carries the passenger. Departure uses PLATFORM_ON_LEAVE_DO_NOTHING; no implicit launch boost. An explicit collision_response.platform_velocity_inheritance coefficient can opt in later, default zero. See [Godot CharacterBody2D](https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html) and [AnimatableBody2D](https://docs.godotengine.org/en/4.1/classes/class_animatablebody2d.html).

Reset cancels charge, motion, surface state, impacts and recorder data; the lab resets fixture phase and camera. Because Godot caches the previous support body/carry velocity, the first post-teleport movement temporarily suppresses platform floor layers, then restores them and reacquires actual contact. This fixes stale carry shifting a reset spawn. No saves or scene reload are involved. Platform collision/wall layers otherwise remain world=1/player=2 as before.

## Measured comparisons and tuning rationale

| Scenario | Control / before | Current comparison |
| --- | --- | --- |
| Normal stop from 65px/s | 1.250px / 0.067s | unchanged |
| Ice stop from 65px/s | no prior ice model | 69.875px / 2.167s |
| Reverse from +65px/s | normal 0.083s | ice 0.333s |
| Rising wall at +165px/s | STOP → 0px/s | opt-in rebound → -41.25px/s |
| Designated ramp | no prior gravity slide | reaches bounded 150px/s |
| Ramp counter-input after 3s | initial influence 0.40: still +66.222px/s downhill | influence 0.65: -63.059px/s uphill/control regained |

The ramp trial showed inadequate braking, so only its new input_influence changed from 0.40 to 0.65. The trial is reproduced with a duplicated Resource, without mutating authored data. Baseline jump constants/curve, gravity, maximum fall speed and landing recovery were not retuned. resources/physics/m01_baseline.tres preserves old values for comparison; Git cb1ce10/f2d044a retain the former controller. Existing old 330→360 M01 tuning comparisons remain historical tests, not a new 02B launch change.

## Recorder and debug contract

JumpRecorder now records impact counts, launch/landing surface type, landing body name, pre-damping landing velocity, surface travel while sliding and maximum relative slide speed, in addition to original charge/launch/rise/displacement/flight fields. Slide distance integrates absolute tangent speed×physics delta, excludes platform carry and the airborne landing tick, and includes controlled movement while the special-surface sliding flag is active; it is not airborne X displacement. Initial retained contact speed contributes to the maximum, while distance starts on the following grounded movement tick. This integral is exact within tolerance on tested flat runouts; collision clipping/curved transitions can make it an approximation rather than world path length. The last completed jump's slide fields continue updating during runout. Reset clears them. An actual sampled trace is capped at 2048 points; it is a debug history, not a theoretical trajectory or an input to movement.

F3 reports profile/friction, normal/angle, sliding/contact status, eligibility and last landing velocity without altering the normal HUD. TRACE in the lab toggles actual body bounds, normal, velocity and recorded trajectory. These are diagnostic overlays, not hidden collision assistance. Physics Lab 2.0 has direct selection of A–G and H1–H3 plus preserved Classic climb; F6 resets the selected section. tests/surface_physics_test.gd exercises actual contacts and navigation. tests/frame_rate_probe.gd compares the same 60Hz maximum arc at render cadences 30/60/120, not different physics tick rates.

## Baseline normal-ground reference

## Editable configuration

Edit resources/physics/default_player_physics.tres in Godot's Inspector. The Resource script exposes:

| Parameter | Default | Units / meaning |
| --- | --- | --- |
| ground_speed | 65 | px/s |
| ground_acceleration | 900 | px/s² |
| ground_deceleration | 1200 | px/s²; tested stop distance <3px from full speed |
| gravity | 900 | px/s², constant ascent/descent |
| maximum_fall_speed | 600 | px/s downward cap |
| minimum_charge_time | 0.06 | seconds; shorter taps launch minimum strength |
| maximum_charge_time | 0.75 | seconds; saturates until release, never auto-launches |
| minimum_jump_impulse | 150 | px/s upward magnitude |
| maximum_jump_impulse | 360 | px/s upward magnitude, tuned from 330 |
| minimum_horizontal_impulse | 45 | px/s on a directed minimum jump |
| maximum_horizontal_impulse | 165 | px/s |
| landing_recovery_time | 0.06 | seconds, quantized to physics ticks |
| air_control_factor | 0 | optional fraction of ground acceleration toward horizontal jump speed; disabled |
| charge_curve | null | linear; optional monotone Curve mapping 0→0 and 1→1 |

The controller never mutates this authored Resource. Validation reports invalid/nonfinite ranges and disables player physics rather than silently substituting values. Curves are sampled at 101 points for monotonicity/range; this practical authoring check is not a proof over arbitrary spline extrema. Keep curves simple, rerun tests and inspect intermediate measurements after tuning.

## Equations and input policy

For elapsed hold t, normalized c=clamp((t-t_min)/(t_max-t_min),0,1). Effective s=curve(c), or c without a curve. On release vx=d×lerp(Vx_min,Vx_max,s), vy=-lerp(Vy_min,Vy_max,s). Positive Y is down; positions use feet origins in world pixels. This replaces M00's provisional t/T_max formula.

d=int(right)-int(left): -1/0/+1. Neither key and both A+D mean vertical. Direction may change while charging and is sampled at release. Charging zeroes vx immediately. Ground velocity approaches d×ground_speed using configured acceleration/deceleration. Launch replaces ground velocity; it does not inherit walking momentum. Airborne A/D changes selected intent but cannot steer when air_control_factor=0.

_unhandled_input latches press/release edges once for _physics_process. A complete tap between ticks still launches minimum strength; a held key adds one physics delta per tick up to the cap. Airborne presses cannot charge; continuing to hold through landing does not start another charge. Pause/focus loss/reset discard pending edges and cancel charge, requiring release then press again. Nothing is buffered through landing recovery. Focus loss pauses; Esc resumes. R remains future boss retry.

Apply vy=min(vy+g×delta,fall_cap) before one move_and_slide each tick, including the launch tick. Velocity is px/s and is not multiplied by delta before move_and_slide. Observed arcs differ from continuous estimates height≈vy0²/(2g), flight≈2|vy0|/g and dx≈vx0×flight. Fixed ticks improve predictability without promising bitwise determinism between engines/platforms.

## Movement states

| From | Trigger | Result |
| --- | --- | --- |
| GROUNDED | Armed Space press on solver floor, profile speed eligibility passes | CHARGING; stationary for supplied profiles |
| CHARGING | Release with floor support | RISING; launch once, clear meter |
| RISING | vy≥0 or ceiling blocks ascent | FALLING |
| RISING/FALLING | Solver reports floor | LANDING; zero velocity, emit landed once |
| LANDING | Recovery timer reaches zero | GROUNDED |
| GROUNDED/CHARGING/LANDING | Floor lost | FALLING; cancel charge |
| Any | Reset | FALLING at spawn; clear velocity/charge/timers/recorder; reacquire contact next tick |
| CHARGING | Pause/focus loss | GROUNDED if supported, otherwise FALLING; fresh input required |

LANDING has a bounded timer. Ceiling contact can move RISING directly to FALLING. Physics is independent of procedural Visual feedback and the HUD. No generic state framework exists.

## Collision contract

Player layer 2 / mask 1; solid world layer 1 / mask 2. The rectangular collider is 10×24px centered at (0,-12); silhouette is 14×26px. A feet origin simplifies placement/measurements; the visible outline is slightly wider for readable edge placement. Appearance does not define collision. All platforms, walls and ceilings are solid rectangles, not one-way or pixel-perfect surfaces.

safe_margin=0.02px, floor_snap_length=1px, floor_max_angle≈45°. Normal ground preserves the original stop/landing policy; special surfaces and optional contact responses follow the 02B rules above. Tests cover walls, ceilings, narrow/partial-overlap ledges, terminal-speed falls, real polygon slopes and moving-platform carry. No automatic ledge grab or generous invisible corner correction exists.

## Measurement collection

JumpRecorder listens to jump_started, landed, physics_stepped and reset. At launch it records start feet position, charge seconds, effective strength and initial velocity. After every solver move it records maximum rise, signed endpoint X displacement and physics-tick duration, accumulating wall/ceiling contacts. Landing completes the record and stores the landing position. Duration includes launch and landing ticks and excludes landing recovery. F3 shows the last completed jump, not a prediction. Normal play retains one record in memory; the harness writes a comparison report to ignored .godot/jump_measurements.json.

## Measured jump envelope

Measured on a wide same-height floor, rightward, default Resource, no air control, 60 Hz. Requested fractions use the nearest held tick, so effective strengths need not be exact quarters. A minimum tap uses one held tick. Values are approximate observations, not analytical claims.

| Requested charge | Actual hold (s) | Effective strength | Peak rise (px) | Horizontal displacement (px) | Airborne (s) |
| --- | --- | --- | --- | --- | --- |
| Minimum tap | 0.0167 | 0.0000 | 11.267 | +15.006 | 0.333 |
| 25% | 0.2333 | 0.2512 | 21.196 | +33.822 | 0.450 |
| 50% | 0.4000 | 0.4928 | 33.610 | +57.279 | 0.550 |
| 75% | 0.5833 | 0.7585 | 50.607 | +92.950 | 0.683 |
| Maximum | 0.7500 | 1.0000 | 69.015 | +132.007 | 0.800 |

Rise=start feet Y minus minimum feet Y. Displacement=landing X minus start X, **not total distance traveled**. Neutral launches have zero X displacement. Collision margin leaves feet a few hundredths of a pixel above a surface. Repeated identical neutral jumps and mirrored arcs are tested within 0.05px. No random force exists.

## Tuning pass and geometry

Initial maximum vertical impulse 330 measured 57.765px rise, 121.008px displacement and 0.733s flight. That left only ~2px rise margin over the lab's 56px gaps and made solid-side clearance fragile. Changed only maximum vertical impulse to 360: 69.015px rise, 132.007px displacement, 0.800s flight. Other defaults were retained. The first 16px step is reachable at intermediate charge. Minimum taps remain useful for small hops/repositioning but cannot clear every step; human feedback may justify raising the minimum later.

Twelve-platform ascent uses 16/32px introductory rises then 52/56px upper rises. A solid platform requires feet above its top before the body crosses its side; a continuous reach estimate alone cannot prove a route. The harness walks to explicit launch positions and lands on all twelve platforms through actual collisions without inter-platform teleports, then walks off the summit and verifies lower recovery. The route is documented in level-design.md.

## Camera and remaining acceptance

LabCamera uses a 10px vertical dead zone, exponential tracking speed 14/s and 42px W/S look, bounded by world limits and a visibility guard. Displayed positions round to pixels, trading subpixel fluidity for pixel clarity. Camera state never changes jump physics or zoom. Normal charge UI updates per render frame; hidden debug text does not format, and visible debug text updates at 10 Hz.

Historical M01 checklist: boot button, positioning, tap/medium/full release, neutral/opposites, air input, hold through landing, edge charge, walls/ceilings, climb/fall/recover, camera/HUD/debug/reset/pause/focus behavior. The user later approved that movement. The new 02B surface feel still requires the manual checklist below; automated comparisons are not subjective approval.

## M02B manual acceptance checklist — not yet user-verified

- Launch Physics Lab from boot; select Classic and every A–G/H1–H3 entry without climbing between experiments. Confirm F6 resets the current section and moving fixture phase, not the whole game.
- A: tap/quarter/half/three-quarter/full/overcharge; left/right/neutral/mixed opposites using WASD and arrows. Observe capped meter and no air correction. Hold through landing and confirm no buffered charge.
- B/C: rising/falling stop walls, magenta rebound fixture, grounded wall/floor corners, low/diagonal/near-apex ceilings and overhangs. No extra upward motion, clipping or sticky-wall behavior.
- D: partial overlap, 24/16/8px targets, misses and long falls. Confirm failure is understandable and recovery remains possible.
- E: enter/leave ice, stop near edges, reverse direction, land with momentum, try charging while sliding, brake below the threshold, release/repress to charge, then reset during slide. Rejecting an early press must not silently launch later.
- F: rest, walk up/down both polygon slopes, reverse and jump from them; inspect no hopping/drift and transitions to flats.
- G/H: build downhill speed, counter-steer, brake and charge; distinguish intentional ramp acceleration from ice coasting; transition to normal brake pads. Try combined narrow-target, rebound/roof and ramp-runoff challenges. Check moving recovery carry/reversal/landing/reset and slippery carrier behavior in the fixtures/tests.
- Pause/focus loss during charging, sliding, ascent and a moving-platform ride. Resume without stale charge. Verify normal HUD remains clear, F3 fields are accurate and TRACE is optional.
- Review charge timing, ramp braking, surface patterns, camera comfort and recovery at different render FPS/window sizes. Linux, exports, prolonged hardware performance and human physical-key timing remain unverified.
