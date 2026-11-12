# Game design

## Milestone 03A opening

David now starts outside Arasaka Tower. The first production route joins Corporate Plaza and Service Entrance, Ventilation Galleries and Transformer Hall in one continuous ascent. Corporate and industrial infrastructure provide 36 intended destinations. Side shafts preserve recoverable setbacks into earlier sections. The owner approved the current character presentation and movement before this milestone. Route pacing and environmental art await review.

## Milestone 02E presentation and traversal

David Martinez is the current playable character prototype. Idle, gait, charge compression, extension, airborne poses, landing, slide and impact expose cues from the shared controller. Charge poses track actual stored charge. Try the revised gravity ramps directly from Lab O–Q.

Future Arasaka Tower routes take their platform vocabulary from architecture and machinery. Use the provisional eight-region progression and measured traversal rules in [Level design](level-design.md).

## Milestone 02D implementation status

The current playable prototype is one continuous four-floor, 60-landing ascent with controllable moderate ice, polygon ramps and configurable ordinary wall/platform-side ricochets. Space charge/release, committed air motion and consequential recoverable falls remain the core loop. Floor tints/signage are temporary, not final campaign art. The eight-region narrative below remains a future design target. No story scenes, combat, cyberware, saves or automatic checkpoint teleportation were added. The owner approved the 02D movement. Route pacing and art direction still need human review; see level-design and the 02D validation report.


Status: approved direction from the briefs unless labeled **proposal**. This is a campaign design target, not an implementation inventory. M01 implements a standalone physics lab (see physics-spec.md), not campaign content. It resolves charge timing, neutral direction, wall response and landing policy for the provisional prototype; later campaign/assist/ability designs remain proposals.

M02A update: the user has manually approved the M01 movement. One playable Emergency Power Chamber now demonstrates Neon Industrial Decay art, machinery scale, layered atmosphere, improved placeholder/UI and an upward service route. This is a visual slice of the beginning of Sublevel Zero, not a completed tutorial region or narrative implementation. WASD and arrow keys share the same actions. Await user artistic approval before 02B.

## Premise and campaign

David Martinez starts in the basement of Arasaka Tower, cut off from the city and the crew. Escape requires climbing through eight connected industrial, corporate, and experimental regions. The setting is an alternate universe inspired by Edgerunners: established events may diverge intentionally. David and Rebecca survive the final escape and reach the moon together. One linear campaign and one primary ending keep narrative scope manageable.

Act I (Sublevel Zero, Maintenance Shaft, Chrome Foundry) teaches commitment, falling, recovery, and the cost of augmentation. Act II (Security Grid, Data Spire, Blackwall Labs) reunites the crew, introduces unreliable systems, and makes timing mastery central. Act III (Executive Citadel, The Summit) tests learned traversal with situational power, a platforming boss, and the final escape. Exact scenes, dialogue, and pacing remain proposals for later narrative validation.

## Core loop and jumping

Read the geometry and hazard cycle, choose a launch position, hold Space, select A/D direction, release, observe the committed arc, land, then reassess. Charge controls launch magnitude in both axes. Air correction is disabled by default or extremely limited after playtesting. There is no animation-driven displacement. Physics uses a fixed timestep with shared constants across difficulty modes.

Falling is the primary punishment. Routes should make lost progress understandable and give the player a useful view of recovery opportunities. Normal traversal has no conventional health bar. Hazards primarily interrupt charge, displace the player, or cause knockback; instant death is not the baseline. Exact charge curve, charge-duration cap, neutral jumps, wall response and input buffering are unresolved tuning decisions; see physics-spec.md.

## Difficulty and accessibility

Assisted is the default: automatic region checkpoints, optional trajectory assistance, forgiving hazard timing, and deliberately placed recovery platforms. Classic removes automatic region checkpoints and supports longer, more punishing falls. Both modes share the same launch equations, collision dimensions, gravity and physics tick rate. Difficulty is resource data, not scattered mode-name branches.

Trajectory assistance must remain optional and use the actual launch model once implemented. Show charge state without relying on color alone. Plan remapping and an alternative charge interaction for players who cannot comfortably hold a key; neither exists yet. Provide readable high-contrast text, independent audio controls, reduced flashes/shake, clear hazard telegraphs and no mandatory rapid tapping. Accessibility must preserve readable timing and geometry; verify with users rather than assuming assistance works.

## Earlier campaign outline

The table below records the original campaign concept. The current provisional region order is in [Level design](level-design.md#environmental-geometry-standard).

| Order | Region | Gameplay / narrative role |
| --- | --- | --- |
| 1 | Sublevel Zero | Tutorial, basic charge mastery, first recovery routes |
| 2 | Maintenance Shaft | Moving platforms, steam vents, pistons |
| 3 | Chrome Foundry | Manufacturing hazards, Sandevistan Mk I |
| 4 | Security Grid | Drones, lasers, Rebecca reunion |
| 5 | Data Spire | Electronic platforms, timing puzzles, scanner |
| 6 | Blackwall Labs | Illusions, gravity fields, Sandevistan upgrade |
| 7 | Executive Citadel | Elite security, cyberskeleton acquisition |
| 8 | The Summit | Adam Smasher, final escape |

These are regions of one continuous vertical world. A fall can cross back into earlier regions; it must not hit an artificial loading barrier. Do not create eight playable regions during foundation work.

## Characters and content boundaries

David is the player and emotional anchor. Lucy supplies narrative guidance and a connection to the moon; Rebecca is reunited with David in Security Grid and participates in the escape; Falco supports extraction/logistics. Other crew members may appear in dialogue or environmental interactions only when their production cost serves the route. Adam Smasher is the final obstacle. Specific dialogue, portraits, cameos and recorded voices are unapproved production work.

Use stable internal IDs such as player_protagonist, ally_reunion and summit_boss, with display names in content data. These are proposed IDs, not existing resources. Avoid coupling code to fan names so original identities can replace them.

## Cyberware

The system is hybrid: permanent unlock ownership persists, while temporary activations consume energy or have cooldowns. Mk I arrives in Chrome Foundry, scanner in Data Spire, upgraded Sandevistan in Blackwall Labs, and cyberskeleton in Executive Citadel. Exact energy capacities, cooldowns, scanner affordances and acquisition scenes require prototypes.

Sandevistan slows eligible hazards and enemies through their own time domain, never by globally slowing player physics. Cyberware must not silently change base jump reach and invalidate earlier geometry. The cyberskeleton is a late-game situational mechanic with explicitly authored encounters; its precise effect is a proposal to test. Avoid adding movement multipliers before measuring their level-design consequences.

## Summit boss and ending

Adam Smasher is a multi-phase platforming encounter, not a conventional damage-trading battle. **Proposal:** phase one tests telegraphed displacement and safe ledges; phase two adds environmental timing pressure; phase three requires executing a traversal route to open escape. Phase counts, attack patterns, victory triggers, retry anchors and difficulty timing need a separate boss design. Do not add a player health bar by assumption. R requests a retry only within an active boss context and should have an explicit confirmation policy to prevent accidental progress loss.

After victory, a scripted escape reunites David and Rebecca and concludes on the moon. One ending is the scope; branching endings are not required.

## Art, audio and future ideas

Detailed pixel art at a provisional 320×180 internal viewport, strong silhouettes, neon accents, dark industrial backgrounds, distinct region palettes and restrained effects. Animation expresses physics state and never determines it. See art-direction.md for scales and asset policy.

Audio should clarify release, landing, charging thresholds, hazard warnings and cyberware state. Plan separate master/music/SFX controls, layered region ambience and original music with deliberate silence during demanding jumps. Avoid audio-only essential cues and unlicensed soundtrack references in shipped files. No audio is implemented.

Future ideas: optional challenge routes, practice tools, replay/ghost assists and additional accessibility settings. These are proposals outside the current roadmap acceptance criteria; do not implement them incidentally.
