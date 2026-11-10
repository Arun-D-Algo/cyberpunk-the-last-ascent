# Source-contract checks only. This is not a Godot parser or runtime test.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$checkCount = 0
function Assert-Source([bool]$Condition, [string]$Message) {
    $script:checkCount++
    if (-not $Condition) { $script:failures.Add($Message) }
}

$requiredFiles = @(
    'project.godot', 'README.md', 'AGENTS.md', '.gitignore', '.gitattributes',
    'scenes/main/boot.tscn', 'tests/smoke_test.gd', 'tests/physics_test.gd',
    'scenes/levels/physics_lab.tscn', 'scenes/player/player.tscn',
    'scenes/ui/lab_hud.tscn', 'resources/physics/default_player_physics.tres',
    'docs/game-design.md', 'docs/technical-design.md', 'docs/physics-spec.md',
    'docs/level-design.md', 'docs/art-direction.md', 'docs/development-log.md',
    'docs/roadmap.md'
)
foreach ($file in $requiredFiles) {
    $path = Join-Path $projectRoot $file
    Assert-Source (Test-Path -LiteralPath $path -PathType Leaf) "Missing file: $file"
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        Assert-Source ((Get-Item -LiteralPath $path).Length -gt 0) "Empty file: $file"
    }
}
$settings = Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw -Encoding UTF8
Assert-Source ($settings -match '(?m)^config_version=5$') 'Unexpected project format'
$sceneMatch = [regex]::Match($settings, '(?m)^run/main_scene="res://([^"]+)"$')
Assert-Source $sceneMatch.Success 'Missing res:// main scene'
if ($sceneMatch.Success) {
    Assert-Source (Test-Path -LiteralPath (Join-Path $projectRoot $sceneMatch.Groups[1].Value)) 'Main scene path missing'
}
$expectedSettings = @(
    'window/size/viewport_width=320', 'window/size/viewport_height=180',
    'window/size/window_width_override=960', 'window/size/window_height_override=540',
    'window/stretch/mode="viewport"',
    'window/stretch/scale_mode="integer"',
    'renderer/rendering_method="gl_compatibility"',
    'textures/canvas_textures/default_texture_filter=0'
)
foreach ($line in $expectedSettings) {
    Assert-Source ($settings -match ('(?m)^' + [regex]::Escape($line) + '$')) "Setting missing: $line"
}
Assert-Source ($settings -notmatch '(?m)^common/physics_ticks_per_second=(?!60\s*$)') 'Physics tick must be 60 (explicit or engine default)'
$bindings = [ordered]@{
    move_left = @(65, 0); move_right = @(68, 0)
    look_up = @(87, 0); look_down = @(83, 0); jump_charge = @(32, 0)
    cyberware_primary = @(4194325, 1); cyberware_secondary = @(4194326, 1)
    interact = @(69, 0); pause_game = @(4194305, 0); retry_boss = @(82, 0)
    debug_toggle_overlay = @(4194334, 0); debug_reset_lab = @(4194337, 0)
}
$inputSection = [regex]::Match($settings, '(?ms)^\[input\]\s*(.*?)(?=^\[|\z)').Groups[1].Value
Assert-Source (([regex]::Matches($inputSection, '(?m)^\w+=\{')).Count -eq 12) 'Expected ten gameplay and two lab-debug input actions'
# Godot omits default-valued settings when saving from its editor.
Assert-Source ($settings -notmatch '(?m)^window/stretch/aspect="(?!keep")[^"]+"') 'Aspect must remain keep (explicit or engine default)'
foreach ($action in $bindings.Keys) {
    $block = [regex]::Match($inputSection, '(?ms)^' + [regex]::Escape($action) + '=\{(.*?)^\}')
    Assert-Source $block.Success "Action missing: $action"
    $events = [regex]::Matches($block.Value, 'Object\(InputEventKey,[^)]*\)')
    $expectedEvents = if ($action -in @('move_left','move_right','look_up','look_down')) { 2 } else { 1 }
    Assert-Source ($events.Count -eq $expectedEvents) "Expected physical keyboard events: $action"
    if ($events.Count -gt 0) {
        $key = [regex]::Match($events[0].Value, '"physical_keycode":(\d+)')
        Assert-Source ($key.Success -and [int]$key.Groups[1].Value -eq $bindings[$action][0]) "Wrong key: $action"
        $location = 0
        $locationMatch = [regex]::Match($events[0].Value, '"location":(\d+)')
        if ($locationMatch.Success) { $location = [int]$locationMatch.Groups[1].Value }
        Assert-Source ($location -eq $bindings[$action][1]) "Wrong key location: $action"
    }
}
$scene = Get-Content -LiteralPath (Join-Path $projectRoot 'scenes/main/boot.tscn') -Raw -Encoding UTF8
foreach ($label in @('CYBERPUNK: THE LAST ASCENT', 'Milestone 02B / Precision Mechanics', 'Project initialized successfully.', 'Enter Physics Lab 2.0', 'Enter Power Chamber')) {
    Assert-Source ($scene.Contains($label)) "Boot text missing: $label"
}
$ignore = Get-Content -LiteralPath (Join-Path $projectRoot '.gitignore') -Raw -Encoding UTF8
Assert-Source ($ignore -match '(?m)^\.godot/$') 'Godot cache must be ignored'
# All literal res:// references must resolve to local source files/directories.
foreach ($file in Get-ChildItem -LiteralPath $projectRoot -Recurse -File | Where-Object {
    $_.Extension -in @('.godot', '.tscn', '.gd', '.tres') -and
    $_.FullName -notmatch '[\\/]\.(git|godot)[\\/]'
}) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    foreach ($reference in [regex]::Matches($content, 'res://[a-zA-Z0-9_./-]+')) {
        if ($reference.Value.StartsWith('res://.godot/')) { continue } # Generated measurement output.
        Assert-Source (Test-Path -LiteralPath (Join-Path $projectRoot $reference.Value.Substring(6))) "Missing reference: $($reference.Value)"
    }
}
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "FAIL: $_" }
    Write-Output "FAIL: $($failures.Count) / $checkCount source checks"
    exit 1
}
Write-Output "PASS: $checkCount source checks (not engine/runtime validation)"
exit 0
