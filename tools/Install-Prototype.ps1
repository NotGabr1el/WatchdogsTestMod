param([string]$GameRoot, [string]$ScriptHookInstaller)
$ErrorActionPreference = 'Stop'
$downloadDir = $null
try {
    Write-Host 'Five Car Call - ScriptHook prototype (offline story mode only)'
    Write-Host 'Checks for WD2 ScriptHook and its trainer. No native arrest patch is included.'
    if (!$GameRoot) { $GameRoot = Read-Host 'Enter the Watch Dogs 2 folder containing bin and data_win64' }
    $root = (Get-Item -LiteralPath ($GameRoot.Trim().Trim('"'))).FullName
    if (!(Test-Path -LiteralPath (Join-Path $root 'bin/WatchDogs2.exe') -PathType Leaf)) {
        throw 'Game not found. Select the game root, not bin or the unpacked data folder.'
    }
    $scripts = Join-Path $root 'bin/ScriptHook/data/scripts'
    function Test-TrainerLayout {
        (Test-Path -LiteralPath (Join-Path $scripts 'trainer/manifest.json') -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $scripts 'trainer/main.lua') -PathType Leaf)
    }
    if (!(Test-TrainerLayout)) {
        if (!$ScriptHookInstaller) {
            $url = 'https://cdn.nomad-group.net/nomadapps/wd2sh/build_depot/prod/installer/Watch_Dogs2-ScriptHook-Installer_r185.exe'
            Write-Host "Missing ScriptHook trainer. Downloading the WD2 installer from $url"
            $downloadDir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
            [IO.Directory]::CreateDirectory($downloadDir) | Out-Null
            $ScriptHookInstaller = Join-Path $downloadDir 'Watch_Dogs2-ScriptHook-Installer_r185.exe'
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            try {
                Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $ScriptHookInstaller -MaximumRedirection 0 -TimeoutSec 180
            } catch {
                throw "Publisher download failed. Retry later or supply a trusted local setup with -ScriptHookInstaller. $($_.Exception.Message)"
            }
            # Reject an HTML error page before handing anything to Windows.
            $stream = [IO.File]::OpenRead($ScriptHookInstaller)
            try {
                if ($stream.ReadByte() -ne 77 -or $stream.ReadByte() -ne 90) { throw 'Publisher did not return a Windows executable.' }
            } finally { $stream.Dispose() }
            $signature = Get-AuthenticodeSignature -LiteralPath $ScriptHookInstaller
            if ($signature.Status -notin @('Valid', 'NotSigned')) { throw "Untrusted installer signature: $($signature.Status)" }
            if ($signature.Status -eq 'NotSigned') { Write-Warning 'Vendor installer is unsigned; its publisher cannot be verified by Windows.' }
            else { Write-Host "Signed by: $($signature.SignerCertificate.Subject)" }
        }
        $setup = Get-Item -LiteralPath ($ScriptHookInstaller.Trim().Trim('"'))
        if ($setup.PSIsContainer -or $setup.Name -notmatch '^Watch_Dogs2-ScriptHook-Installer(?:_r[0-9]+)?\.exe$') {
            throw 'Select the original Watch_Dogs2-ScriptHook-Installer executable.'
        }
        Write-Host "Setup: $($setup.FullName)"
        Write-Host "Select this game folder in the vendor installer and include the trainer: $root"
        if ((Read-Host 'Only run a copy obtained from the publisher. Launch setup? [y/N]') -ne 'y') {
            throw 'Setup cancelled; no mod files installed.'
        }
        $process = Start-Process -FilePath $setup.FullName -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "ScriptHook setup exited with code $($process.ExitCode). No mod files installed." }
        if (!(Test-TrainerLayout)) { throw "Setup finished but the trainer is missing under $scripts. Check the chosen game folder." }
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
} finally {
    if ($downloadDir -and (Test-Path -LiteralPath $downloadDir)) {
        Remove-Item -LiteralPath $downloadDir -Recurse -Force
    }
}
