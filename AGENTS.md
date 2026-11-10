# Instructions for future coding agents

1. Inspect the tree, Git status, current scenes, resources, and tests before editing. Preserve user changes and working behavior. This directory is the project root; never initialize Git in its parent.
2. Read README.md, docs/technical-design.md, docs/roadmap.md, the latest development-log entry, and design documents relevant to your task.
3. Implement only the requested milestone. Movement, cyberware, saves, dialogue, hazards, and bosses are future work until separately authorized. Avoid empty manager scripts and speculative abstractions.
4. Use snake_case filenames, PascalCase node/class names, snake_case methods/signals, typed GDScript where useful, and res:// resource paths. Keep scenes composable and dependencies explicit.
5. Read semantic InputMap actions. Do not scatter physical-key checks. Keep movement on fixed physics ticks, independent of animation. Both difficulty modes share physics parameters.
6. Prefer scene-local ownership and Godot Resources/signals. Add an autoload only with a documented lifetime requirement; avoid circular dependencies and global event buses without evidence.
7. Run tests appropriate to changes. At minimum run tests/validate_static.ps1, Godot headless import, startup and tests/smoke_test.gd when the engine is available. Visually verify UI changes in Godot. Report exact checks executed and distinguish failures, skipped checks, and unavailable tools.
8. Never claim an implementation or milestone is complete without relevant validation. Static text checks cannot establish engine compatibility, rendering, or gameplay correctness.
9. Document new systems, interfaces, parameter units, and architectural decisions; distinguish approved rules from untested proposals. Update docs/development-log.md after substantial changes and keep the roadmap/status accurate.
10. Keep changes focused and reviewable. Do not rewrite functioning systems gratuitously, discard user files, install software, move the project, or modify OneDrive settings without appropriate authorization.
11. Use original assets or placeholders. Do not download/extract copyrighted sprites, music, fonts, or proprietary game files without permission. Record provenance/license before importing third-party work. Narrative IDs must allow replacing fan-project names.
12. Keep .godot/, export output, credentials, logs and editor state out of Git. Preserve source .uid and .import sidecars. Do not push unless instructed.
13. Engine confirmed at initialization: Godot 4.7.2 stable (`4.7.2.stable.official.ed1daf0bf`). Recheck --version on new machines and record any agreed engine change. Under a restricted agent sandbox isolate editor/user-data and logs in ignored .godot paths as described in README; do not alter production paths to bypass tooling restrictions.
14. Keep files local and accessible under OneDrive. If synchronization/locking errors arise, report them; never silently relocate the project. See README for mitigation.
