# Optional Grok TUI launcher. Work folder comes from YOUR config, not this repo.
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

$grok = Join-Path $env:USERPROFILE '.grok\bin\grok.exe'
if (-not (Test-Path -LiteralPath $grok)) {
    Write-Host "grok.exe not found at $grok"
    exit 1
}
& $grok @args
exit $LASTEXITCODE
