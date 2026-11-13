# Level design

## Milestone 03B architectural traversal

Compose an entire spatial problem around a visible machine or opening before tuning a jump. Put reachable roof edges on the physical silhouettes, and use broad approaches to introduce mechanics before combining them. The new route begins with a right-side service climb, uses a fan column and an exhaust recovery loop in ventilation, then rises through opposing transformer piers. All three sections have optional paths or transfers.

The [challenge library and section map](regions/01-arasaka-substructure.md) describe progression and recovery. The [route measurements](validation/milestone-03b.md) record the anti-monotony audit and controller results. The 03A staircase below is historical.

## Milestone 03A opening route

The main entry uses OpeningRoute and OpeningAscent for 10 corporate, 12 ventilation and 14 transformer destinations. Base-to-summit rise is 1,760 pixels. Widths range from 32–64 pixels, and full casing depth participates in the solver. Four return faces exercise deliberate rebounds. Recessed braces attach the foreground housings to the structure. Section boundaries at y−313 and y−881 classify the player without moving it.

The [region document](regions/01-arasaka-substructure.md) records architecture and fall design. The [measurement report](validation/milestone-03a.md) records the final continuous replay and nearby-input probes. The older four-floor route below remains a regression prototype.

## Forced-slide obstacle placement

Use committed slides as readable penalties below a missed landing. Give the player a visible recovery destination and enough headroom for the shared collider. A chute or inclined service panel provides a physical reason for the descent. Give its top face a consistent hazard treatment and distinguish normal inclined floors and ice visually.

Place a ForcedSlide route with strictly descending connected faces and a clear exit beyond the final face. Test both entry from above and the approach edge. Confirm the authored exit velocity and the lower catch point with the shared controller. Inspect seams and remove blockers or overlapping colliders before making a route playable. Lab R–V demonstrate the patterns with temporary geometry.

## Environmental geometry standard

The environment provides much of the traversable geometry. Build routes from surfaces that serve an architectural or industrial purpose. Use visually supported building ledges, balconies, escalators, billboard mounts, walkways, pipes, vents, elevator frames, security booth roofs, beams and broken stairs. Generic floating pads are an exception for explicit training or an authored suspension mechanism.

- Show how load-bearing surfaces attach to the tower. Preserve readable silhouettes against deeper scenery.
- Match collider edges and ramp angles to visible surfaces. Reserve consistent edge highlights and material cues for solid landings, slick patches and intentional rebound faces. Keep decorative meshes and sprites free of surprise collision.
- Derive difficulty from spacing, approach direction, ledge width, slope, material and rebound angles. Make intended options readable before the jump.
- Use each floor's architecture to explain its mechanics. A service pipe can be a ramp, a frozen rail can carry ice, and an elevator frame can provide a rebound face. Keep connections visible across seams.
- Maintain coherent vertical relationships through long falls. Earlier floors should be recognizable and offer recovery landings.
- Measure jump reach with the actual controller and verify intended landings, slopes, rebounds and recovery paths. Use the approved jump envelope before drawing the final platform shape.

The following progression is provisional. Palette, height, mechanics and route language are planning directions for a later art and layout pass.

| Region | Architecture and traverse vocabulary | Background and palette | Mechanic and progression |
| --- | --- | --- | --- |
| Corporate Plaza | Entrance canopy, building ledges, security booth roofs | Open facade with pale concrete, navy recesses and warm signage | Teach short charge jumps with wide landings and a plaza recovery route |
| Neon Atrium | Escalators, balconies, glass walkway frames and suspended billboards | Layered concourse with cyan, violet and amber | Introduce inclined transitions and longer gaps above interconnected balconies |
| Corporate Offices | Office mullions, service bridges and architectural beams | Repeating glass grids with slate and cold white | Tighten landings and test vertical planning with recoverable office tiers |
| Industrial Spine | Pipe runs, ventilation units, elevator machinery and catwalks | Ribbed shafts with steel blue and hazard yellow | Link sustained slopes and rebound surfaces over maintenance catch points |
| Cryogenic Research | Cryogenic vessels, insulated pipe braces and containment lips | Frosted machinery with pale cyan and dark cobalt | Emphasize braking and ice-to-dry transitions with wide recovery bays |
| Security & Data Core | Booth roofs, rack frames, cable trays and shaft braces | Dense server layers with magenta and terminal teal | Chain controlled rebounds and narrow drops across reachable structural tiers |
| Executive Citadel | Broad roofs, hanging signs and glass support frames | Open atria with charcoal, gold and cool glass | Combine precise charge and ricochet routes with visible lower balconies |
| The Summit | Roof parapets, antenna mounts and rooftop equipment | Exposed skyline with blue-gray and warm beacons | Test the widest approved jumps and vertical commitment with recoverable falls into the citadel |

The four-floor prototype is the current playable route. Assign production heights after reachability and recovery checks on each future region.

## Milestone 02D — continuous gameplay prototype

`scenes/levels/tower_ascent.tscn` is the main playable ascent, selected by **Start Tower Ascent**. The original chamber remains a visual slice and Classic remains a lab regression. This is four provisional floors, not the eight-region final campaign.

| Floor | Height range above base | Length | Landings | Main focus |
|---|---:|---:|---:|---|
| Public Access | 0-720 px | 720 px | 15 | Wide pads, varied rises, introductory return banks |
| Commercial Atrium | 720-1456 px | 736 px | 15 | Narrower pads, long transfers, raised side/underside clearance |
| Restricted Infrastructure | 1456-2188 px | 732 px | 15 | Moderate ice, controlled ramp/runout, rebound combinations |
| Maintenance Ascent | 2188-3008 px | 820 px | 15 | 24-40px ledges, 52-60px rises, ice/ramp/bank combinations |

Total: **60 numbered mandatory landing destinations over 3008 px**, from base feet y144 to summit y-2864. Two return banks per zone are exercised by the reference route (8 ricochets), plus 6 moderate-ice landings and 2 controlled ramp/runout pads. Ordinary pad widths progress from 48-64px to 24-40px; return ledges are 28px. Rise tables, spacing, widths and post-bank direction changes vary the rhythm. The route remains a prototype; human pacing and variety need acceptance rather than padding it with more identical jumps.

TowerRoute contains the authored rhythm/geometry data; TowerAscent composes the existing IndustrialPlatform art, shared PhysicsSurface polygons and shared player. Raised return walls have solid tops, sides and undersides. The solver caught overhead blockages, short-approach side impacts and marginal edge landings during authoring; geometry and timings were revised until the complete route passed.

All four floors occupy one continuous world: negative Y is up. Floor classification uses fixed boundaries at each previous zone's last pad minus 1px, with no reposition, velocity reset, loading screen or checkpoint teleport. Temporary FloorTheme Resources hold accent/tint/title; floor number signs and a current-zone HUD accompany preserved shaft textures. Future art can replace these Resources independently of physics. 71 solid bodies remain loaded; there is no streaming or save system.

The final replay uses the actual controller on the final complete geometry, walking/braking between launches without inter-platform resets, and checks every landing body plus every reference collision sequence. Candidate discovery uses resets in a separate pass; it is not substituted for the continuous replay. Launch recipes and measured landing positions are in [validation/milestone-02d.md](validation/milestone-02d.md).

A deterministic ideal-input replay takes about 115.47 simulation seconds, including walking, charging and ice braking. Reading geometry and recovering from mistakes will lengthen human attempts; a several-minute human completion time is a design intention, not a measured human result.

Long-fall test: physically walk off the summit, fall 1263.75px at up to 600px/s into floor 3, camera follows after its normal update, land on solid geometry, cancel/charge again, pause and explicitly reset. The normal jump envelope remains 69.015px maximum rise and 132.007px same-height range. Earlier platforms and the base remain recovery surfaces; ordinary misses never auto-retry. Alternative charge/launch choices may bypass some banks; the validated reference deliberately exercises them, while the two-wall laboratory route requires ricochets.


## Manual acceptance checklist (pending user playtest)

- Ice: enter from normal ground, coast, counter-steer, reverse, stop completely, then hold/release Space. Try an early rejected charge, release/repress after braking, and compare mild/moderate/extreme tuning. Extreme is optional and absent from the tower.
- Slides: use Lab F/G/H3 and tower pads 37/52. Observe shallow/steep/short/long polygon ramps at 960x540 and larger integer windows; counter-steer, run onto flat ground, run off, hit a wall and jump after braking. Compare 320x180, where display movement necessarily remains whole physical pixels.
- Rebounds: Lab I/J/K/L/M/N. Hit ordinary walls from both directions; hit a raised pad's side, top and underside. Complete the return jump and two-wall shaft. Verify L preserves the rise and N explicitly redirects energy. Try low-speed supported corners without jitter. Moving-side response is automated; moving fixtures remain in H3.
- Main game: Start Tower Ascent, climb all four floors and 60 numbered pads, inspect floor signage/tints, intentionally miss a transfer, fall into an earlier floor, brake/recover and continue. Reach PROTOTYPE SUMMIT. F3 shows zone/height/max/last landing/impulse; F6 explicitly resets to base, Esc/focus loss cancels charge and pauses.
- Repeat WASD/arrows, W/S or Up/Down camera look, charging/slide pause and reset, different render FPS/window sizes. Judge ice feel, timing tolerances, visual smoothness and route variety; automation does not supply human approval.


## M02B precision-platforming foundations (historical)

Difficulty should come from repeatable charge timing, launch placement, surface awareness, route planning and risk management. It must not come from hidden rebound rules, random impulses, misleading art, inconsistent support or unreadable recovery. The old lab and chamber routes remain reachable with the unchanged normal-ground jump envelope.

Suggested future progression: normal ledges → narrow targets → walls/overhangs → long gaps → moving supports → ice → normal slopes → gravity ramps → combinations. Introduce each rule on a forgiving, visible example before combining it with a punishing fall. Do not author production regions in this milestone. Gravity ramps are a distinct yellow/patterned surface; ordinary inclines do not auto-slide. Ice uses cyan hatching, rebound fixtures magenta outlines, and normal fixtures pale edges. Pattern/label cues supplement color. All greybox polygon edges are actual collision edges, not staircase approximations.

Physics Lab 2.0 preserves **Classic** and adds directly selectable experiments:

| Selector | Purpose / fixtures |
| --- | --- |
| A JUMPS | Clear calibration lane; rise marks at 11/21/34/51/69px for approximate minimum-to-full jumps |
| B WALLS | Stop wall, low passage and explicit controlled-rebound wall |
| C CEILING | Low ceiling, overhang and wall/roof corner |
| D LEDGES | 24/16/8px targets above a recovery floor |
| E ICE | Adjacent normal entry, ice lane and normal exit; raised 32px over recovery floor |
| F SLOPES | Genuine shallow (~14°) and steep (~34°) polygons with flat tops |
| G RAMPS | Downhill gravity ramp and brake pad; start directly on ramp |
| H1 ICE | Ice approach, narrow target, incline and overhang |
| H2 REBOUND | Rebound wall, return ledge and overhead constraint |
| H3 RUNOFF | Gravity ramp, brake pad, small ice target and minimal moving recovery support |

The selector is on the HUD at the upper right. Every section loads directly and has a tested supported spawn; F6 resets that section, moving phase and camera. TRACE toggles actual collider/normal/velocity/recorded path. F3 shows surface diagnostics. Do not require a full Classic ascent to reach another experiment. The combined setups are learning/testing challenges, not a production difficulty sequence. H3's moving recovery sits below the route (y=152, lower floor y=176), avoiding a squeeze against the ramp/brake pad.

Automated reference routes additionally verify D's 24/16/8px climb and all three H goals without inter-jump teleports. D launches from X=45 at 0.50s right, X=110 at 0.60s right, X=183 at 0.65s left. H1 launches from X=30 at 0.45s right onto ice, counter-steers until speed ≤8px/s, then charges 0.62s right onto the narrow target. H2 launches full charge from X=126 right, rebounds once off the marked wall and lands on the return ledge. H3 allows the ramp to carry the player onto the normal brake pad, walks to X=221 and jumps 0.50s right onto the ice target. These are reproducible examples, not the only valid routes or proof of subjective difficulty quality.

Reachability validation must state starting surface, charge, facing, retained velocity, normal/slope, wall mode and moving-platform phase. Same-height free-flight formulas alone cannot prove an ice approach, wall rebound or slope runoff. Use real controller traces and record the landing body, profile, pre-damping impact velocity and actual surface travel. Keep the 69.015px full normal rise / 132.007px same-height range as the control. The baseline snapshot Resource and historic Git commits remain available for comparison.

Recovery should preserve the consequence of lost altitude while returning the player to a valid route. Clearly mark unusually slippery or gravity-driven approaches before exposing the player to a narrow target. Place normal brake pads intentionally; normal landings stop, but a supported seam applies new drag without instant velocity multiplication. Moving carriers default to no departure launch boost. Avoid invisible ledge grabs and unmarked bouncing walls. User playtesting of these new mechanics is still required before production geometry or final difficulty claims.

## M02A Emergency Power Chamber

One 320px-wide, approximately 420px-tall visual slice at scenes/regions/sublevel_zero/emergency_power_chamber.tscn. Starting feet=(45,144); six service ledges end at y=-144, a 288px climb. It is not a complete Sublevel Zero region. A closed upper-relay door is explicitly a nonfunctional exit placeholder. The floor and intermediate ledges provide recovery; F6 resets prototype state. No checkpoints, hazards, region loading or story events are added.

| Destination | X span | Surface Y | Reference launch X | Hold (s) | Direction |
| --- | --- | --- | --- | --- | --- |
| 1 | 72..120 | 112 | 45 | 0.50 | right |
| 2 | 158..222 | 64 | 109 | 0.75 | right |
| 3 | 78..126 | 12 | 183 | 0.75 | left |
| 4 | 168..240 | -40 | 114 | 0.75 | right |
| 5, narrow | 94..118 | -92 | 194 | 0.75 | left |
| 6, upper relay | 170..250 | -144 | 106 | 0.75 | right |

The actual-body suite walks between launch positions and completes all six landings without teleporting during the route, using unchanged approved M01 physics. Background parallax is tested with upward/downward look at lower/middle/upper stops. Bright one-pixel ledge tops and warning end caps identify solid surfaces; subdued generator housings/railings/console/door art never imply new invisible collision. Each platform has 8px collision height, with art below the exact top contact line. Scene captures are staged views for art review, not a claimed human playthrough. Full room/screenshot review: visual-review/milestone-02a.

This document records intended content and proposed authoring rules. There are no playable regions in M00. Implement and validate the jump prototype before placing production gaps.

## Implemented M01 physics laboratory

scenes/levels/physics_lab.tscn is a standalone test arena, not any production region. It uses one table of solid rectangles for collision/drawing in scripts/core/physics_lab.gd. Walls are x=8..16 and x=304..312. Spawn feet=(45,144); floor surface y=144. Upper route ends at y=-444, a 588px climb. The camera shows one 320×180 view, not the whole arena. Ceiling-test geometry is x=224..250 at y=78; an alternative vertical-hop ledge is x=254..288 at y=88. A small side ledge at x=22..50,y=-8 supports alternate attempts. Broad floor/recovery surfaces prevent permanent traps.

The default measured envelope is 11.267px minimum rise, 33.610px near-half rise, and 69.015px full rise with 132.007px same-height horizontal displacement. Intro rises are 16/32px; upper rises 52/56px leave measured vertical clearance. Side clearance still matters because all platforms are solid. The automated harness executes the route below by walking on the previous surface, charging, releasing and landing through actual collisions; it never teleports between these jumps.

| Destination | Surface span X | Surface Y | Launch X on previous surface | Hold seconds | Direction |
| --- | --- | --- | --- | --- | --- |
| 01 TAP | 64..112 | 128 | 45 | 0.34 | right |
| 02 LOW | 136..194 | 96 | 103 | 0.58 | right |
| 03 CLIMB | 56..114 | 44 | 170 | 0.75 | left |
| 04 RECOVER | 154..242 | -8 | 105 | 0.75 | right |
| 05 CLIMB | 70..128 | -60 | 180 | 0.75 | left |
| 06 EDGE | 160..204 | -116 | 104 | 0.75 | right |
| 07 NARROW | 88..112 | -168 | 188 | 0.75 | left |
| 08 RECOVER | 166..244 | -220 | 100 | 0.75 | right |
| 09 CLIMB | 68..132 | -276 | 185 | 0.75 | left |
| 10 CLIMB | 164..212 | -332 | 108 | 0.75 | right |
| 11 CLIMB | 82..146 | -388 | 195 | 0.75 | left |
| 12 SUMMIT | 170..250 | -444 | 115 | 0.75 | right |

These are reproducible reference launches with positioning tolerance, not the only valid route. Human playtesting must assess whether the charge/position windows are understandable and enjoyable. Initial max vertical impulse 330 gave only 57.765px rise and fragile upper clearance; the 360px/s tuned value and revised launch positions pass the full route. After summit ascent, the harness walks off and lands on lower geometry to verify loss of progress and recovery without reset. No checkpoint/save/region loading is introduced here.

## Earlier region concepts

This section records the initial concept. Use the environmental geometry standard and provisional progression above for future layout work.

| Region / stable proposed ID | Theme and major hazards | Story / cyberware | Difficulty goal |
| --- | --- | --- | --- |
| Sublevel Zero / sublevel_zero | Basement tutorial; static ledges and safe fall basins | Establish David's escape objective; no unlock | Learn charge/release and directional commitment with visible recovery |
| Maintenance Shaft / maintenance_shaft | Moving platforms, steam vents, pistons | Crew guidance opportunities; no required unlock | Read cycles and choose launch windows |
| Chrome Foundry / chrome_foundry | Manufacturing lines, presses, hot machinery | Sandevistan Mk I acquisition | Teach eligible hazard slowing in a forgiving demonstration |
| Security Grid / security_grid | Drones, laser corridors, surveillance | Rebecca reunion | Combine displacement threats and timing without adding normal health |
| Data Spire / data_spire | Electronic platforms, timing puzzles | Scanner unlock | Read platform state and plan sequences |
| Blackwall Labs / blackwall_labs | Illusions, bounded gravity fields | Sandevistan upgrade | Distinguish signals and adapt to explicitly telegraphed local rules |
| Executive Citadel / executive_citadel | Elite security, overlapping patrol windows | Situational cyberskeleton acquisition | Master combinations, with room to learn the new encounter tool |
| The Summit / the_summit | Multi-phase platforming arena, escape route | Adam Smasher; David and Rebecca escape to the moon | Final synthesis with readable telegraphs and defined retries |

Specific geometry, dialogue triggers, numbers of rooms, hazard speeds and encounter duration are proposals for later milestones. Region themes must not imply that all listed mechanics are implemented.

## Continuous-world coordinates and connections

Godot world units are pixels. +X is right, +Y is down; climbing means decreasing Y. Proposed starting reference is the Sublevel Zero floor near world Y = 0; exact root origins are authored after greyboxing. Region origins are shared-world transforms, not new coordinate spaces that reset the player's location. Child geometry uses local coordinates, with checkpoints resolved through the region root.

A region scene contains geometry, hazard instances, entry/exit markers, a trigger envelope, camera bounds, safe checkpoint marker(s), and metadata for neighbors. Align boundaries in shared coordinates with a small authored collision-safe overlap; ensure duplicate boundary geometry does not create snagging seams. Neighbor links are explicit IDs validated for reciprocal routes. A screen is a camera framing unit, not a loading wall or a mandatory teleport.

Falling through an upper entry must lead naturally to a lower exit. Preserve earlier collision content until return is impossible within the unload horizon. Fast falls must activate every intersected collision band before physics reaches it. Keep all early greybox regions loaded first; add streaming only when measurement warrants it. Test falls through multiple boundaries and returns after each unlock.

## Camera and readability

Proposal: vertical follow with a dead zone and modest smoothing, bounded W/S look, and authorable limits per region/room. Blend camera limits on entry; checkpoint restore may snap to a known safe view. Do not switch camera ownership in overlapping triggers without deterministic precedence. The camera should reveal landing targets and hazard telegraphs early enough to support a committed jump. Screen transitions must not move the body or hide a collision boundary. Reduced-motion settings affect presentation only.

## Recovery and checkpoints

Recovery platforms convert failure into understandable lost altitude. Use broad catch surfaces below teaching jumps, occasional side routes back toward the main path, and readable silhouettes against backgrounds. Avoid unseen pits below the first demonstration of a mechanic. Later regions can increase required precision and chain length while preserving legible fall destinations.

Assisted offers region checkpoints, more forgiving hazard timing and strategically placed recovery. Classic disables automatic region checkpoints and permits longer falls. Express differences using data/policy and explicit geometry variants if necessary; never change launch physics between modes. Validate both layouts instead of assuming the same recovery placement serves both.

Represent a checkpoint by region_id and marker_id, with a safe spawn transform resolved from authored data. Proposed marker convention: feet origin at floor contact with clear standing headroom and a safe camera view. Define neutral facing/velocity/charge on restore and validate no active hazard overlaps. A checkpoint should precede a new mechanic, not spawn inside its punishment window. Exact activation timing, save frequency and mode-switch behavior need later specification.

## Authoring acceptance

For each region: demonstrate required jumps with measured physics envelopes at minimum/intermediate/full charge; ensure no mandatory gap requires a hidden modifier; verify hazard telegraphs and recovery at default zoom; validate boundary seams and high-speed falls; test checkpoint spawns after revisit/unload; confirm unlock gates have no circular dependency or permanent softlock. Test eligible time slowdown without altering jump distances. Gravity fields require isolated entry/exit tests and visible bounds.

Collect fall distance, time to recovery, player understanding of missed jumps, and checkpoint usefulness in playtests. Assisted should be accessible without erasing commitment; Classic should punish a comprehensible mistake. Document actual observations before tuning. Boss arena retry, multi-phase reset and escape continuity have their own later acceptance gate.
