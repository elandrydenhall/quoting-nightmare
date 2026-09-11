@{
    RootModule        = 'QuotingNightmare.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = 'b7e4c1a0-3f8d-4c2b-9e15-6a91d0f2c8e4'
    Author            = 'quoting-nightmare'
    Description       = 'UTF-8 console + Invoke-SshScript so PowerShell does not eat $ in ssh remotes'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-QuotingNightmareConfig',
        'Get-QuotingNightmareConfigPath',
        'Initialize-QuotingUtf8',
        'Get-OpenSshExe',
        'Invoke-SshScript',
        'Register-QuotingNightmareHosts'
    )
    AliasesToExport   = @()
    CmdletsToExport   = @()
    VariablesToExport = @()
}
