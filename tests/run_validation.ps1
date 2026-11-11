param(
    [Parameter(Mandatory = $true)][string]$GodotExe,
    [switch]$Render
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engine = (Resolve-Path -LiteralPath $GodotExe).Path
$savedValidationAppData = $env:APPDATA
$savedValidationLocalData = $env:LOCALAPPDATA
try {
    # Process-local isolation; no machine settings or installed engine are changed.
    $env:APPDATA = Join-Path $projectRoot '.godot/validation-user'
    $env:LOCALAPPDATA = Join-Path $projectRoot '.godot/validation-cache'
    New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
    function Invoke-EngineCheck([string]$Name, [string[]]$EngineArgs) {
        $logPath = Join-Path $projectRoot ".godot/$Name.log"
        & $engine @EngineArgs --log-file $logPath
        if ($LASTEXITCODE -ne 0) { throw "$Name exited $LASTEXITCODE" }
        if ((Get-Content -LiteralPath $logPath -Raw) -match '(?m)^(SCRIPT ERROR|ERROR:)') {
            throw "$Name reported engine errors; see $logPath"
        }
        Write-Output "PASS: $Name"
    }
    Invoke-EngineCheck 'import' @('--headless', '--path', $projectRoot, '--editor', '--import')
    Invoke-EngineCheck 'startup' @('--headless', '--path', $projectRoot, '--quit-after', '5')
    Invoke-EngineCheck 'chamber_startup' @('--headless', '--path', $projectRoot, '--scene', 'res://scenes/regions/sublevel_zero/emergency_power_chamber.tscn', '--quit-after', '5')
    Invoke-EngineCheck 'smoke' @('--headless', '--path', $projectRoot, '--script', 'res://tests/smoke_test.gd')
    Invoke-EngineCheck 'physics' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/physics_test.gd')
    Invoke-EngineCheck 'visual_prototype' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/visual_prototype_test.gd')
    Invoke-EngineCheck 'surfaces' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/surface_physics_test.gd')
    Invoke-EngineCheck 'refinement' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/refinement_test.gd')
    Invoke-EngineCheck 'slopes_02e' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/slope_test.gd')
    Invoke-EngineCheck 'character_animation' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/character_animation_test.gd')
    Invoke-EngineCheck 'lab_startup' @('--headless', '--path', $projectRoot, '--scene', 'res://scenes/levels/physics_lab.tscn', '--quit-after', '5')
    Invoke-EngineCheck 'tower' @('--headless', '--fixed-fps', '60', '--path', $projectRoot, '--script', 'res://tests/tower_test.gd')
    Invoke-EngineCheck 'tower_startup' @('--headless', '--path', $projectRoot, '--scene', 'res://scenes/levels/tower_ascent.tscn', '--quit-after', '5')
    foreach ($frameRate in @(30, 60, 120)) {
        Invoke-EngineCheck "forced_slide_$frameRate" @('--headless', '--fixed-fps', "$frameRate", '--path', $projectRoot, '--script', 'res://tests/forced_slide_test.gd')
        Invoke-EngineCheck "cadence_$frameRate" @('--headless', '--fixed-fps', "$frameRate", '--path', $projectRoot, '--script', 'res://tests/frame_rate_probe.gd')
    }
    if ($Render) {
        Invoke-EngineCheck 'lab_render' @('--path', $projectRoot, '--scene', 'res://scenes/levels/physics_lab.tscn', '--write-movie', (Join-Path $projectRoot '.godot/lab.png'), '--quit-after', '12')
    }
} finally {
    $env:APPDATA = $savedValidationAppData
    $env:LOCALAPPDATA = $savedValidationLocalData
}
