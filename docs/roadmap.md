# Roadmap

## Current art review — Cinematic David

The upright crown, charge, takeoff, fall and landing poses are ready for owner review in the [cinematic comparison and playtest package](visual-review/cinematic/README.md).

## Mechanics review — Milestone 02F

Forced-slide lab routes and the revised David sprite are ready for owner playtesting. Review the connected slide, fall recovery, native-resolution anatomy and the planted full-charge crouch before placing a committed chute in a production route.

## Previous prototype — Milestone 02E

The slope correction, animated David prototype and environmental platforming rules are ready for owner playtesting and art review. Record feedback on ramp entry, braking, air and landing pose readability and player scale before building the first environment-integrated route slice. The eight-region plan is provisional.

## Accepted physics baseline — Milestone 02D

02D supersedes the previous stop-at-02B scope: implement and validate ice control, fractional/interpolated presentation, ordinary side rebounds, six ricochet lab fixtures and a continuous four-zone/60-landing main ascent. Implementation and engine validation are complete; physics/game feel was manually approved by the project owner on 11 November 2026; full-route pacing and remaining art/platform acceptance are separate. See docs/validation/milestone-02d.md and physics-spec manual checklist. No 02C implementation is inferred from the numbering.

Next: preserve the accepted physics baseline and review full-route difficulty/variety, pacing and remaining art/platform scope. Then agree on the next production/art/content milestone. Do not begin cutscenes, final artwork, hazards, abilities, saves or full eight-region production from the historical roadmap alone.

## Historical milestone plan


M00–M02A foundations are preserved. The user's detailed M02B prompt now explicitly authorizes collision/surface refinement, superseding the earlier controller freeze and pending-authorization gate for this scope. M02B implements mechanics and selectable test fixtures only; no new production environment, art or narrative. Automated validation and measured comparisons do not establish subjective feel; new surface mechanics require user acceptance before further production work.

| Milestone | Deliverables | Dependencies | Acceptance criteria |
| --- | --- | --- | --- |
| 00 — Foundation | Boot scene, InputMap, project settings, directories, design/technical docs, validation tools, local Git baseline | Verified destination and engine discovery | Main scene/settings valid; ten specified physical-key bindings; documentation complete; import/startup/smoke checks reported; boot visible; caches ignored; remaining checks disclosed |
| 01 — Jump-physics prototype | CharacterBody2D player, minimal state handling, pure jump calculation, tuning Resource, greybox lab | M00; separate detailed prompt | Repeatable charge arcs measured; wall/ceiling/landing edge cases tested; no default air control; fixed-step animation-independent motion; documented provisional tuning and open issues |
| 02A — Visual direction | Neon Industrial Decay style guide, original assets/pipeline, one playable Emergency Power Chamber, UI/placeholder, review package, arrow input | User-approved M01 movement | Physics preserved; both input sets tested; chamber route/renderer/resources pass; real screenshots and refinement documented; user approves visual identity before 02B |
| 02B — Precision physics and surfaces | Resource-based contact/ice/slope/ramp rules, minimal moving support, selectable Lab 2.0, expanded recorder/debug/tests | Existing playable controller/lab/chamber and explicit 02B brief | Normal envelope preserved; surfaces/collisions/carry/reset verified; all test areas directly accessible; actual comparisons and manual checklist documented; user accepts new mechanics before next stage |
| 03 — Early regions and hazards | Sublevel Zero and Maintenance Shaft greyboxes, moving platforms/vents/pistons, reusable hazard timing | M02; carry/knockback specification | Learnable tutorial; predictable platform collisions; charging interruption/recovery tested; both difficulty policies validated without changing jump constants |
| 04 — Cyberware and middle regions | Chrome Foundry/Security Grid, unlock model, Sandevistan Mk I, drone/laser interactions | M03; ability clock-domain contract | Eligible hazards slow while player arcs stay unchanged; energy/cooldown and repeated grants tested; Rebecca reunion trigger integrated when dialogue runner is available |
| 05 — Narrative, persistence and Data Spire | Dialogue/interaction flow, versioned settings/save strategy, scanner and electronic platforms, crew beats | M04; save/content ID schema | Linear story survives revisit; unlock/checkpoint save/restore tested; corrupt/interrupted save handled; scanner and timed-platform routes work in both modes |
| 06 — Late tower | Blackwall Labs/Executive Citadel, bounded gravity/illusion mechanics, Sandevistan upgrade and situational cyberskeleton | M05; dedicated gravity/ability prototypes | New rules visibly telegraphed; base geometry stays valid; no unlock softlocks; checkpoint/load boundaries tested; late-game production scope reviewed |
| 07 — Summit and escape | Platforming boss phases, explicit R retry context, final escape, David/Rebecca moon ending | M06; separate boss design and narrative content | Complete linear campaign; telegraphs readable; retries reset all encounter/transient state; permanent progress retained correctly; victory/escape cannot softlock |
| 08 — Polish and release assessment | Original/licensed assets and audio, accessibility pass, performance work, Windows/Linux exports, IP/distribution review | Validated M07 campaign; matching export templates and permissions | Exported campaign smoke/soak tests on both systems; input/scaling/saves verified; credits/provenance complete; known issues documented; public release only after separate rights decision |

Stop at each gate to measure and revise. Favor one validated representative mechanic over bulk content. A milestone is not complete merely because its source files exist; record failures and unavailable tooling separately from passes. Deferred/rejected ideas belong in design notes, not incidental scope expansion.

Stop after 02B for user testing of ice braking, charge eligibility, ramp control, rebounds, carrier behavior and combined fixtures. No subjective or artistic approval is inferred from automated tests. Next scope should be separately agreed after acceptance; production routes/regions/checkpoints and future hazard mechanics are not authorized by this roadmap alone.
