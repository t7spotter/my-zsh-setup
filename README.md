# my-zsh-setup

One-shot bootstrap script to set up my zsh + oh-my-zsh (bira theme) environment on a fresh VPS.

## Quick start

On any new server:

```bash
curl -fsSL https://raw.githubusercontent.com/t7spotter/my-zsh-setup/main/setup-shell.sh | bash
```

Then either:

```bash
exec zsh
```

or exit the session twice and reconnect over SSH:

```bash
exit
exit
ssh user@your-vps
```

You should land straight into the `bira` prompt.

## What it installs

- `zsh`, `git`, `curl` (via `apt` or `yum`, whichever is available)
- [oh-my-zsh](https://ohmyz.sh/) (unattended install, won't overwrite an existing `.zshrc`)
- Theme: `bira`
- Plugins:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
  - `fast-syntax-highlighting`
  - `zsh-autocomplete`
- Sets `zsh` as the default login shell (`chsh`)

The script is idempotent — safe to re-run on a box that already has some or all of this installed; it skips anything already present.

## Note on plugin overlap

`zsh-syntax-highlighting` and `fast-syntax-highlighting` both highlight command syntax as you type and can conflict or slow things down when both are active. The script enables both by default (matching my working config), but if you notice double-highlighting or lag, remove one from the `plugins=(...)` array in `~/.zshrc`.

Similarly, `zsh-autocomplete` and `zsh-autosuggestions` both influence tab-completion behavior. If completion feels off, try disabling one.

## VS Code Remote-SSH

VS Code's integrated terminal doesn't respect the system login shell — it needs to be told separately. On each remote host you connect to via Remote-SSH:

1. `Cmd+Shift+P` → **Preferences: Open Remote Settings (JSON)**
2. Add:

   ```json
   {
     "terminal.integrated.defaultProfile.linux": "zsh",
     "terminal.integrated.profiles.linux": {
       "zsh": { "path": "/usr/bin/zsh" }
     }
   }
   ```

   Confirm the path first with `which zsh` — it's usually `/usr/bin/zsh` on Debian/Ubuntu, but check.

3. `Cmd+Shift+P` → **Developer: Reload Window**

## Files

| File              | Purpose                                  |
|-------------------|-------------------------------------------|
| `setup-shell.sh`  | Bootstrap script, run once per new VPS   |
| `README.md`       | This file                                |

## Requirements

- One of: Debian/Ubuntu (`apt`), Fedora/RHEL 8+/Rocky/Alma (`dnf`), older RHEL/CentOS (`yum`), Arch/Manjaro (`pacman`), openSUSE (`zypper`), Alpine (`apk`), or macOS (Homebrew)
- `sudo` access (or run as root, on Linux)

## Platform notes

- **Linux**: detects your package manager (`apt`, `dnf`, `yum`, `pacman`, `zypper`, or `apk`) and installs `zsh`/`git`/`curl` accordingly, then sets the shell system-wide with `chsh`.
- **macOS**: installs [Homebrew](https://brew.sh) first if missing, then `zsh`/`git`/`curl` via `brew`. macOS has shipped zsh as the default shell since Catalina (2019), so on most Macs this mainly just gets you the oh-my-zsh + bira + plugin setup rather than changing your shell.
- **Alpine**: also installs `bash`, since Alpine's default shell is `ash` (BusyBox) and the script itself requires bash to run. Alpine's minimal images may not include `sudo` — if `sudo` isn't found, re-run the relevant commands as root directly.
