# Physics specification — proposal for Milestone 01

No player or physics model is implemented in M00. Approved rules are charge/release, charge-dependent launch in both axes, A/D direction selection, committed airborne motion, shared physics across modes and fixed-step updates independent of animation. Every formula and tuning choice below is provisional.

## Charge and launch

Only begin charging while grounded and when gameplay owns input. Accumulate t in physics seconds while held. Proposed normalized charge c = clamp(t / T_max, 0, 1), shaped value q = curve(c), vertical launch vy = -lerp(Vy_min, Vy_max, q), horizontal launch vx = d × lerp(Vx_min, Vx_max, q). Here d is -1, 0 or +1. curve is monotone, initially linear for measurement. Positive Y points down. T_max is seconds; launch speeds are px/s.

On release, snapshot charge and direction once, set velocity, enter airborne and clear the charge accumulator. Holding at full charge should saturate without auto-launch unless a later accessibility design explicitly changes the intent interface. Neutral direction proposes a vertical jump; A+D proposes neutral rather than order-dependent movement. Decide whether direction is sampled continuously or latched before tuning; proposal: sample at release and display it while charging. Do not switch direction midair by resampling held keys.

Ground walking speed, movement while charging, tap minimum, coyote time, release buffering, charging during landing and maximum-charge feedback remain open. Prototype them explicitly; do not silently add conventional platformer assists that change committed-jump behavior.

## Gravity and travel estimates

Proposed airborne integration: vy = min(vy + g × delta, V_fall_max), then move_and_slide once per physics tick. Start with constant positive gravity rather than variable ascent/descent curves. For a static platform and ideal constant gravity, time to apex ≈ |vy0|/g, rise ≈ vy0²/(2g), same-height flight time ≈ 2|vy0|/g, horizontal reach ≈ |vx0| × flight_time. Discrete collision/integration modifies these estimates; measure the actual controller at 60 Hz before deriving platform gaps.

Do not assign final numeric speeds or gravity before the physics lab. The configured 60 Hz itself is provisional; if altered, retest every measured arc and collision edge. No global time scaling for Sandevistan.

## Horizontal motion, walls and landings

Default airborne acceleration is zero. Ground walking and momentum retention need a separate decision. Prefer an explicit state transition to velocity changes scattered in collision callbacks.

Use a stable simple CharacterBody2D shape and move_and_slide. Define floor_max_angle, floor_snap_length, safe_margin and collision layers in the prototype with documented units. A floor is a surface classified by the body solver, not any overlap. On landing, clear downward velocity/charge and enter grounded exactly once. Test sloped and moving surfaces before approving them.

Proposed wall behavior: remove the blocked horizontal component without adding a wall jump, climb or bounce. On ceiling contact, stop upward velocity and let gravity resume. Whether walls retain a fraction of horizontal momentum is unapproved. Avoid corner-snapping that adds hidden height. Specify moving-platform carry and inherited launch velocity only after reproducible tests; do not let implicit engine defaults become unexamined design rules.

## Knockback and interruptions

Hazards request a knockback vector and interruption policy. Cancel charging when displaced off the floor; stale release must not cause a delayed jump after recovery. Proposed knockback state temporarily owns velocity before returning to falling/grounded. The duration, impulse magnitude, repeated-hit cooldown and whether horizontal steering resumes are tuning parameters. No normal-traversal health bar or default instant-kill behavior.

## Tuning inventory

| Parameter | Units / constraints | Validation purpose |
| --- | --- | --- |
| T_max | seconds, > 0 | Comfortable repeatable charge timing |
| Vy_min, Vy_max | px/s, 0 < min ≤ max | Minimum/maximum rise |
| Vx_min, Vx_max | px/s, 0 ≤ min ≤ max | Horizontal gap envelope |
| charge curve | normalized, monotone 0–1 | Predictable intermediate arcs |
| g | px/s², > 0 | Arc readability and duration |
| V_fall_max | px/s, > 0 | Fall safety, streaming horizon |
| ground speed | px/s, TBD | Launch positioning precision |
| air control | px/s², default 0 | Committed jump behavior |
| collision dimensions/margins | px, TBD | Ledges, seams and head clearance |
| knockback / recovery | px/s and seconds, TBD | Hazard readability and recovery |

Difficulty resources may change checkpoint/hazard policy but never these fundamental launch parameters. Any deliberate gravity field must be visibly bounded and separately validated; never silently alter shared baseline physics.

## Edge cases and lab acceptance

M01 should create a dedicated greybox lab with floor, height markers, short/long gaps, wall, ceiling, narrow ledge and fall capture. Add moving platforms only after static arcs are stable. Log initial condition, charge duration, direction, tick count, apex, landing displacement and collision outcomes.

Measure zero/tap, quarter/half/full/overcharge; neutral/left/right/both keys; release just before leaving a ledge; head collision; wall/ceiling corners; floor seams; repeated landing events; airborne press/release; focus loss; pause during charge; input captured by UI; knockback during charge/flight; checkpoint restore; temporary time effects; long frames and different render FPS at a fixed physics tick. Reset held intent on focus loss/restore so returning to the window cannot launch accidentally.

Acceptance: repeated identical initial conditions reproduce arcs within a documented tolerance; mirror arcs are symmetric; no tunneling across supported speeds; landing emits once; animations do not change motion; Assisted and Classic use the same launch results. Set tolerances after measuring the engine and do not claim cross-platform bitwise determinism. The lab and gameplay tests do not exist in M00.
