# Install module + UTF-8 + optional agent profile hook.
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-QuotingNightmare.ps1
#   powershell ... -File .\Install-QuotingNightmare.ps1 -Grok   # also WT Grok profiles
[CmdletBinding()]
param(
    [switch]$Grok,
    [switch]$Utf8Console
)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$docs = [Environment]::GetFolderPath('MyDocuments')

Write-Host 'Installing quoting-nightmare…'

$example = Join-Path $here 'quoting-nightmare.config.psd1.example'
$userCfg = Join-Path $env:USERPROFILE '.quoting-nightmare.config.psd1'
if (-not (Test-Path -LiteralPath $userCfg)) {
    if (Test-Path -LiteralPath $example) {
        Copy-Item -LiteralPath $example -Destination $userCfg
        Write-Host "Created $userCfg  — edit WorkDirectory and SshHosts, then re-import the module."
    }
} else {
    Write-Host "Config exists: $userCfg (not overwritten)"
}

$modSrc = Join-Path $here 'Modules\QuotingNightmare'
$modDest = Join-Path $docs 'PowerShell\Modules\QuotingNightmare'
if (-not (Test-Path -LiteralPath $modSrc)) {
    throw "Missing $modSrc"
}
New-Item -ItemType Directory -Force -Path $modDest | Out-Null
Copy-Item (Join-Path $modSrc 'QuotingNightmare.psm1') (Join-Path $modDest 'QuotingNightmare.psm1') -Force
Copy-Item (Join-Path $modSrc 'QuotingNightmare.psd1') (Join-Path $modDest 'QuotingNightmare.psd1') -Force
Write-Host "Module: $modDest"

$marker = 'quoting-nightmare-init'
$snippet = @"

# >>> $marker >>>
if (-not (Get-Command Invoke-SshScript -ErrorAction SilentlyContinue)) {
    Import-Module QuotingNightmare -ErrorAction SilentlyContinue
}
# <<< $marker <<<
"@
function Install-ProfileSnippet([string]$Path) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $existing = ''
    if (Test-Path -LiteralPath $Path) {
        $existing = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    }
    if ($existing -match [regex]::Escape($marker)) {
        Write-Host "Profile already hooked: $Path"
        return
    }
    $out = ($existing.TrimEnd() + $snippet).TrimStart() + "`n"
    [System.IO.File]::WriteAllText($Path, $out, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Profile hooked: $Path"
}
Install-ProfileSnippet (Join-Path $docs 'PowerShell\Microsoft.PowerShell_profile.ps1')
Install-ProfileSnippet (Join-Path $docs 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1')

if ($Utf8Console) {
    function Set-ConsoleUtf8Key([string]$Path) {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name CodePage -Value 65001 -PropertyType DWord -Force | Out-Null
    }
    Set-ConsoleUtf8Key 'HKCU:\Console'
    Write-Host 'HKCU Console CodePage=65001 (this user, new consoles only)'
}

if ($Grok) {
    $launch = Join-Path $here 'Grok-Launch.ps1'
    $desk = Join-Path $here 'Grok-Desk.ps1'
    if ((Test-Path -LiteralPath $launch) -and (Test-Path -LiteralPath $desk)) {
        Write-Host 'Grok extras: use your existing Grok-Launch.ps1 / WT fragment if you have them.'
        Write-Host 'Set WorkDirectory in .quoting-nightmare.config.psd1 instead of a hardcoded UNC.'
    }
    $cfg = Join-Path $env:USERPROFILE '.grok\config.toml'
    if (Test-Path -LiteralPath $cfg) {
        $raw = Get-Content -LiteralPath $cfg -Raw -Encoding UTF8
        if ($raw -notmatch '(?m)^\[shell_environment_policy') {
            Add-Content -LiteralPath $cfg -Encoding UTF8 -Value @"

[shell_environment_policy.set]
PYTHONUTF8 = "1"
PYTHONIOENCODING = "utf-8"
"@
            Write-Host 'Appended PYTHONUTF8 to ~/.grok/config.toml (no paths).'
        }
    }
}

Write-Host ''
Write-Host 'Next:'
Write-Host "  1. Edit  $userCfg"
Write-Host '  2. Put Host names in SshHosts that exist in ~/.ssh/config'
Write-Host '  3. Restart the agent (Grok / Claude / Cursor / …)'
Write-Host '  4. Test:  Import-Module QuotingNightmare; Invoke-SshScript <host> @'' echo $HOME ''@'
