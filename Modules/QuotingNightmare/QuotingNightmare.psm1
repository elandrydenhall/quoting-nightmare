# Autoloads in pwsh -NoProfile from Documents\PowerShell\Modules.
# Remote $ stays on the SSH host. Host aliases come from your config file, not this repo.
$ErrorActionPreference = 'Continue'

function Get-QuotingNightmareConfigPath {
    @(
        (Join-Path $env:USERPROFILE '.quoting-nightmare.config.psd1'),
        (Join-Path $PSScriptRoot '..\..\quoting-nightmare.config.psd1')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

function Get-QuotingNightmareConfig {
    $p = Get-QuotingNightmareConfigPath
    if (-not $p) {
        return @{ WorkDirectory = ''; SshHosts = @() }
    }
    try {
        return Import-PowerShellDataFile -Path $p
    } catch {
        Write-Warning "quoting-nightmare: could not read $p : $_"
        return @{ WorkDirectory = ''; SshHosts = @() }
    }
}

function Initialize-QuotingUtf8 {
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [Console]::InputEncoding = $utf8
        [Console]::OutputEncoding = $utf8
        $global:OutputEncoding = $utf8
    } catch {}
    try { chcp 65001 | Out-Null } catch {}
}

function Get-OpenSshExe {
    $p = Join-Path $env:SystemRoot 'System32\OpenSSH\ssh.exe'
    if (Test-Path -LiteralPath $p) { return $p }
    $cmd = Get-Command ssh.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return 'ssh.exe'
}

function Invoke-SshScript {
    <#
    .SYNOPSIS
      Run a POSIX script on an SSH Host from ~/.ssh/config.
      Remote $variables are not expanded by PowerShell.
    .EXAMPLE
      Invoke-SshScript lab @'
      f=/tmp
      echo FILE=$f
      echo EXIT:$?
      '@
    #>
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$HostAlias,
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$Script
    )
    if ($HostAlias -match '[@\s/\\]' -or $HostAlias -match '^\d') {
        throw "HostAlias must be an SSH config Host name, not user@host or an IP."
    }
    $n = [string]$Script
    $n = $n -replace "`r`n", "`n" -replace "`r", "`n"
    if (-not $n.EndsWith("`n")) { $n += "`n" }
    $ssh = Get-OpenSshExe
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $ssh
    $psi.Arguments = "-o BatchMode=yes -o IdentitiesOnly=yes $HostAlias bash -s"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $false
    $psi.RedirectStandardError = $false
    $psi.StandardInputEncoding = New-Object System.Text.UTF8Encoding $false
    $p = [Diagnostics.Process]::Start($psi)
    $p.StandardInput.Write($n)
    $p.StandardInput.Close()
    $p.WaitForExit()
    return $p.ExitCode
}

function Register-QuotingNightmareHosts {
    $cfg = Get-QuotingNightmareConfig
    $hosts = @($cfg.SshHosts)
    foreach ($raw in $hosts) {
        $name = [string]$raw
        if ($name -notmatch '^[A-Za-z][A-Za-z0-9._-]*$') { continue }
        $safe = ($name -replace '[^A-Za-z0-9]', '')
        if (-not $safe) { continue }
        $fn = "Invoke-$safe"
        Invoke-Expression @"
function $fn {
    param([Parameter(Mandatory, Position = 0)][string]`$Script)
    Invoke-SshScript -HostAlias '$name' -Script `$Script
}
"@
        Export-ModuleMember -Function $fn -ErrorAction SilentlyContinue
    }
}

Initialize-QuotingUtf8
if ($PSVersionTable.PSVersion.Major -ge 7) {
    try { $PSNativeCommandArgumentPassing = 'Standard' } catch {}
}

Export-ModuleMember -Function @(
    'Get-QuotingNightmareConfig',
    'Get-QuotingNightmareConfigPath',
    'Initialize-QuotingUtf8',
    'Get-OpenSshExe',
    'Invoke-SshScript',
    'Register-QuotingNightmareHosts'
)
Register-QuotingNightmareHosts
