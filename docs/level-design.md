# Level design

This document records intended content and proposed authoring rules. There are no playable regions in M00. Implement and validate the jump prototype before placing production gaps.

## Region plan

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
