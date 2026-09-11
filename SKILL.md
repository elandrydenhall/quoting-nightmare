---
name: quoting-nightmare
description: >
  Windows PowerShell eats $ in double-quoted ssh remotes ($f empty, $? becomes True),
  IBM437 mojibake, GIT_SSH backslash smash. Use Invoke-SshScript or single-quoted remotes.
  Triggers: ssh quoting, FILE=, EXIT:True, C:WindowsSystem32, café, IBM437,
  Invoke-SshScript, /quoting-nightmare.
---

# quoting-nightmare

On Windows PowerShell, never:

```
ssh host "echo FILE=$f; echo EXIT:\$?"
```

`$f` is empty, `$?` becomes `True`.

## Do this

```
ssh host 'echo FILE=$f; echo EXIT:$?'
```

```
Invoke-SshScript host @'
f=/tmp
echo FILE=$f
echo EXIT:$?
'@
```

`host` is an SSH `Host` from the user's `~/.ssh/config`, not an IP and not a name from this repo.

If they configured `SshHosts` (see README), `Invoke-Lab` etc. may exist as wrappers.

Long remotes: write a `.sh`, `scp` it, `ssh host bash script`.

Do not nest `ssh` + `git pull` (stdin hang).

## Install

User runs `Install-QuotingNightmare.ps1` after filling `%USERPROFILE%\.quoting-nightmare.config.psd1`. Restart the agent. Module autoloads from `Documents\PowerShell\Modules\QuotingNightmare`.
