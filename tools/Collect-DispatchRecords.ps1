# Read-only collector for an already unpacked WD2 archive tree (not the install folder).
param([Parameter(Mandatory=$true)][string]$UnpackedRoot,
      [string]$Output = 'wd2-dispatch-inputs.zip')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path -LiteralPath $UnpackedRoot).Path
$db = Join-Path $root 'generated/databases/generic'
$names = @('affiliationreinforcementconfig.lib','basicreinforcementconfig.lib',
    'wavereinforcementconfig.lib','reinforcementcallsettings.lib','reinforcementconfig.lib',
    'reinforcementgameplaybrick.lib','reinforcementsystemsettings_769906d0.obj',
    'felonysystemconfig_c8668c05.obj')
$files = @($names | ForEach-Object {
    $path = Join-Path $db $_
    if (Test-Path -LiteralPath $path -PathType Leaf) { Get-Item -LiteralPath $path }
    else { Write-Warning "Not found: $_" }
})
if (!$files.Count) { throw 'No matching records. Select the unpacked folder containing generated/.' }
$archive = [IO.Compression.ZipFile]::Open($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output), 'Create')
try {
    foreach ($file in $files) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName,
            ('generated/databases/generic/' + $file.Name)) | Out-Null
    }
} finally { $archive.Dispose() }
Write-Output "Collected $($files.Count) candidate records in $Output. This is not an installable mod."
