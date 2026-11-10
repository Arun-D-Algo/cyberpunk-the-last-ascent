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
    'scenes/main/boot.tscn', 'tests/smoke_test.gd',
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
    'window/stretch/mode="viewport"', 'window/stretch/aspect="keep"',
    'window/stretch/scale_mode="integer"', 'common/physics_ticks_per_second=60',
    'renderer/rendering_method="gl_compatibility"',
    'textures/canvas_textures/default_texture_filter=0'
)
foreach ($line in $expectedSettings) {
    Assert-Source ($settings -match ('(?m)^' + [regex]::Escape($line) + '$')) "Setting missing: $line"
}
$bindings = [ordered]@{
    move_left = @(65, 0); move_right = @(68, 0)
    look_up = @(87, 0); look_down = @(83, 0); jump_charge = @(32, 0)
    cyberware_primary = @(4194325, 1); cyberware_secondary = @(4194326, 1)
    interact = @(69, 0); pause_game = @(4194305, 0); retry_boss = @(82, 0)
}
$inputSection = [regex]::Match($settings, '(?ms)^\[input\]\s*(.*?)(?=^\[|\z)').Groups[1].Value
Assert-Source (([regex]::Matches($inputSection, '(?m)^\w+=\{')).Count -eq 10) 'Expected exactly ten authored input actions'
foreach ($action in $bindings.Keys) {
    $block = [regex]::Match($inputSection, '(?ms)^' + [regex]::Escape($action) + '=\{(.*?)^\}')
    Assert-Source $block.Success "Action missing: $action"
    $events = [regex]::Matches($block.Value, 'Object\(InputEventKey,"physical_keycode":(\d+)(?:,"location":(\d+))?\)')
    Assert-Source ($events.Count -eq 1) "Expected one physical keyboard event: $action"
    if ($events.Count -eq 1) {
        Assert-Source ([int]$events[0].Groups[1].Value -eq $bindings[$action][0]) "Wrong key: $action"
        $location = 0
        if ($events[0].Groups[2].Success) { $location = [int]$events[0].Groups[2].Value }
        Assert-Source ($location -eq $bindings[$action][1]) "Wrong key location: $action"
    }
}
$scene = Get-Content -LiteralPath (Join-Path $projectRoot 'scenes/main/boot.tscn') -Raw -Encoding UTF8
foreach ($label in @('CYBERPUNK: THE LAST ASCENT', ('Milestone 00 ' + [char]0x2014 + ' Project Foundation'), 'Project initialized successfully.')) {
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
