# Physics specification — Milestone 01 implementation

The controller is implemented and measured in Godot 4.7.2 at 60 Hz. Defaults are **provisional**, not production game-feel approval. Future difficulty modes must share this physics model. Default air control is disabled. No coyote time, jump buffering, double/wall jump, dash or moving platform exists.

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
| GROUNDED | Armed Space press on solver floor | CHARGING; vx=0 |
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

safe_margin=0.02px, floor_snap_length=1px, floor_max_angle≈45°. Downward pressure refreshes grounded contact each tick. The solver removes blocked velocity at walls/ceilings; there are no extra bounces/impulses. Landing clears horizontal momentum and charge. Tests cover rising/falling wall contact, ceilings, 24px platforms, edge landings and terminal-speed falls onto ordinary solids. Slopes and moving-platform carry remain unimplemented/unvalidated.

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

Manual checklist: boot button; A/D positioning; tap/medium/full hold-release; left/right/neutral/A+D; airborne press/release; hold through landing; edge charging; walls/ceilings; climb/fall/recover; W/S framing; HUD/state feedback; F3/F6; Esc during charge/flight; focus loss; reset during charge/air; repeated attempts at varied rendering frame rates. Automated semantic input is tested. Physical held-key timing, subjective feel/camera comfort, Linux and exports remain unverified. Computer Use was stopped by the user's physical Escape key during the brief window inspection; this was not a completed playthrough.
