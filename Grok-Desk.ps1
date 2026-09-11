# Optional Grok Desk prompt. Work folder comes from YOUR config, not this repo.
$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'ShellInit.ps1')

$comp = Join-Path $env:USERPROFILE '.grok\completions\powershell\grok.ps1'
if (Test-Path -LiteralPath $comp) {
    try { . $comp } catch {}
}

try {
    $cfg = Get-QuotingNightmareConfig
    $work = [string]$cfg.WorkDirectory
    if ($work -and (Test-Path -LiteralPath $work)) {
        Set-Location -LiteralPath $work
    }
} catch {}

function prompt {
    $loc = $executionContext.SessionState.Path.CurrentLocation.Path
    if ($loc.Length -gt 48) { $loc = '…' + $loc.Substring($loc.Length - 47) }
    "quoting-nightmare $loc`n> "
}

Write-Host "quoting-nightmare  UTF-8  OpenSSH  pwsh=$($PSVersionTable.PSVersion)" -ForegroundColor Yellow
Write-Host "Remote `$ : Invoke-SshScript <ssh-host> @' echo `$HOME '@" -ForegroundColor DarkGray
