# UTF-8 + OpenSSH env. Helpers: Import-Module QuotingNightmare (user Modules path).
$ErrorActionPreference = 'Continue'

try {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [Console]::InputEncoding = $utf8
    [Console]::OutputEncoding = $utf8
    $global:OutputEncoding = $utf8
} catch {}
try { chcp 65001 | Out-Null } catch {}

if ($PSVersionTable.PSVersion.Major -ge 7) {
    try { $PSNativeCommandArgumentPassing = 'Standard' } catch {}
}

if (-not $env:PYTHONUTF8) { $env:PYTHONUTF8 = '1' }
if (-not $env:PYTHONIOENCODING) { $env:PYTHONIOENCODING = 'utf-8' }
$ssh = Join-Path $env:SystemRoot 'System32\OpenSSH\ssh.exe'
if (Test-Path -LiteralPath $ssh) {
    $env:GIT_SSH = $ssh
    $fwd = ($ssh -replace '\\', '/')
    $env:GIT_SSH_COMMAND = "$fwd -o BatchMode=yes -o IdentitiesOnly=yes"
}
$env:GIT_TERMINAL_PROMPT = '0'
if (-not $env:COLORTERM) { $env:COLORTERM = 'truecolor' }

$modRoot = Join-Path $PSScriptRoot 'Modules'
if (Test-Path -LiteralPath $modRoot) {
    if ($env:PSModulePath -notlike "*$modRoot*") {
        $env:PSModulePath = $modRoot + ';' + $env:PSModulePath
    }
}

if (-not (Get-Command Invoke-SshScript -ErrorAction SilentlyContinue)) {
    $psd1 = Join-Path $modRoot 'QuotingNightmare\QuotingNightmare.psd1'
    if (Test-Path -LiteralPath $psd1) {
        Import-Module $psd1 -Force -ErrorAction SilentlyContinue
    } else {
        Import-Module QuotingNightmare -ErrorAction SilentlyContinue
    }
}
