param([string]$GameRoot)
$ErrorActionPreference = 'Stop'
try {
    Write-Host 'Five Car Call - ScriptHook prototype (offline story mode only)'
    Write-Host 'Requires an existing WD2 ScriptHook installation. No native arrest patch is included.'
    if (!$GameRoot) { $GameRoot = Read-Host 'Enter the Watch Dogs 2 folder containing bin and data_win64' }
    $root = (Get-Item -LiteralPath ($GameRoot.Trim().Trim('"'))).FullName
    if (!(Test-Path -LiteralPath (Join-Path $root 'bin/WatchDogs2.exe') -PathType Leaf)) {
        throw 'Game not found. Select the game root, not bin or the unpacked data folder.'
    }
    $scripts = Join-Path $root 'data/scripts'
    if (!(Test-Path -LiteralPath $scripts -PathType Container)) {
        throw 'ScriptHook scripts folder not found. No files installed.'
    }
    $dest = Join-Path $scripts 'five_car_call'
    if (Test-Path -LiteralPath $dest) { throw "Already present: $dest. Back it up and move it before reinstalling." }
    $source = Join-Path (Split-Path $PSScriptRoot -Parent) 'five_car_call'
    # Stage beside the destination so the final directory move cannot leave a half-install.
    $stage = Join-Path $scripts ([guid]::NewGuid().ToString())
    [IO.Directory]::CreateDirectory($stage) | Out-Null
    try {
        foreach ($name in 'main.lua','manifest.json') {
            [IO.File]::Copy((Join-Path $source $name), (Join-Path $stage $name))
        }
        [IO.Directory]::Move($stage, $dest)
    } finally {
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
    }
    Write-Host "Installed to $dest. To uninstall, close the game and remove that folder only."
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
