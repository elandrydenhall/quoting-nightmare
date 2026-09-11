# quoting-nightmare

Windows PowerShell expands `$` in double-quoted `ssh` remotes **before** OpenSSH runs.

```
ssh somehost "echo FILE=$f; echo EXIT:\$?"
```

You wanted the **remote** `$f` and `$?`. You get `FILE=` and `EXIT:True`. Backslashes in `GIT_SSH` become `C:WindowsSystem32…`. IBM437 turns `café` into mojibake.

This kit does **not** delete that language rule. It gives agents a first-try path around it.

## Fill in the blanks (required)

Nothing in this repo is your LAN. Copy the example and edit **your** copy:

```
copy quoting-nightmare.config.psd1.example %USERPROFILE%\.quoting-nightmare.config.psd1
notepad %USERPROFILE%\.quoting-nightmare.config.psd1
```

| Blank | What to put |
|---|---|
| `WorkDirectory` | Folder your agent should `cd` into, or `''` for `%USERPROFILE%`. Example: `'D:\projects'` |
| `SshHosts` | Names that already exist as `Host` in `%USERPROFILE%\.ssh\config`. Example: `@('lab','nas')` |

Each `SshHosts` entry named `lab` creates **`Invoke-Lab`**, which is `Invoke-SshScript lab`.

SSH config example (yours, not in git):

```
Host lab
  HostName 192.0.2.10
  User you
  IdentityFile ~/.ssh/id_ed25519
```

Then:

```
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-QuotingNightmare.ps1
```

Optional: `-Utf8Console` (HKCU code page 65001), `-Grok` (PYTHONUTF8 in `~/.grok/config.toml` if present).

Restart the agent. Test:

```
Import-Module QuotingNightmare
Invoke-SshScript lab @'
echo FILE=$HOME
echo EXIT:$?
'@
```

## Agent skill

| Product | Where to copy `SKILL.md` |
|---|---|
| Grok | `%USERPROFILE%\.grok\skills\quoting-nightmare\SKILL.md` |
| Claude Code | `~/.claude/skills/quoting-nightmare/SKILL.md` or project `.claude/skills/` |
| Cursor / Codex | keep `AGENTS.md` in the repo or paste into user rules |

## Use (generic)

```powershell
ssh lab 'echo FILE=$f; echo EXIT:$?'          # single quotes
Invoke-SshScript lab @'
f=/tmp
echo FILE=$f
echo EXIT:$?
'@
```

Wrong: `ssh lab "echo $f"`.

## Other AI

**Yes.** Any Windows agent that spawns PowerShell hits the same parser (Grok, Claude Code, Codex, Cursor, Copilot, Gemini CLI). They only get `Invoke-SshScript` after this install. They only avoid double-quoted `$` if they load the skill/rules.

## Time / tokens

Heavy Windows-ssh agent days: on the order of **30–90 min** and **50k–300k tokens** wasted on quoting retries. Not a lab benchmark. Nested `ssh` + `git pull` hangs are separate — do not nest.

## Security

See [SECURITY.md](SECURITY.md). Do not commit a filled config. Do not put IPs in this git.

## License

MIT. No portable `pwsh.exe` in this repo.
