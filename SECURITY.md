# Security

This repo must stay free of **your** machines.

## Do not commit

- `%USERPROFILE%\.quoting-nightmare.config.psd1` (filled-in hosts / work folder)
- `~/.ssh/id_*`, `known_hosts`, `config`
- LAN IPs, UNC shares, VPN names, real `Host` aliases you do not want public
- API keys, `.env`, agent transcripts

The example config is empty on purpose.

## What this installer does touch (this Windows user only)

- Copies a PowerShell module into `Documents\PowerShell\Modules\QuotingNightmare`
- Optionally appends a few lines to your PowerShell profile
- `-Utf8Console` sets **HKCU** console CodePage 65001 (not HKLM)
- `-Grok` may append `PYTHONUTF8` to `~/.grok/config.toml` if that file already exists — no paths

It does not open inbound ports, does not copy SSH keys, and does not talk to a server except when **you** run `Invoke-SshScript`.

## SSH options used

`BatchMode=yes` and `IdentitiesOnly=yes` so a hung agent does not fall back to password prompts or extra keys. Host names must be `Host` entries in **your** `~/.ssh/config` (not `user@ip` in the command line).

## History note

An earlier public commit contained a private LAN UNC. That history was replaced. If you forked before this rewrite, delete the fork and clone again.
