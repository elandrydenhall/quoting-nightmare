# quoting-nightmare (any Windows agent)

PowerShell expands `$` in double-quoted strings **before** `ssh.exe` runs.

**Wrong:** `ssh host "echo $HOME; echo $?"`  
**Right:** `ssh host 'echo $HOME; echo $?'`  
**Right:** `Invoke-SshScript host @' echo $HOME '@` after install

`host` = a `Host` in the user's `~/.ssh/config`. This repo does not ship hostnames.

Install: copy `quoting-nightmare.config.psd1.example` → `%USERPROFILE%\.quoting-nightmare.config.psd1`, edit blanks, run `Install-QuotingNightmare.ps1`, restart the agent.
