# gitch

Tiny, no-dependency **git shortcut commands** you can install as normal terminal commands (e.g. `gco`, `gcm`, `gst`) to speed up common workflows.

This repo ships a simple installer that symlinks the scripts in `./shortcuts/*.sh` into your PATH.

---

## What you get

The included shortcuts (from `./shortcuts`) map to common git actions:

| Command | What it does |
|--------|---------------|
| `gad ...` | `git add ...` |
| `gcm "message"` | `git commit -m "message"` |
| `gco <branch>` | Checkout branch if it exists, otherwise create it and checkout |
| `gdf` | `git diff` |
| `gmm` | `git merge origin/master` |
| `gpl` | `git pull` |
| `gps` | Push current branch; if no upstream, sets upstream to `origin/<branch>` |
| `gsh push "msg"` | `git stash push -m "msg"` |
| `gsh load <text>` | Apply a stash matched by message text (`stash^{/<text>}`) |
| `gst` | `git status` |

> Tip: open the scripts if you want to tweak behavior to your taste—they’re intentionally small.

---

## Install

From the repo root:

```sh
chmod +x install.sh
./install.sh

### Where it installs

`install.sh` chooses the most seamless location available:

* Installs to **`/usr/local/bin`** if it’s writable (or `sudo` is available).
* Otherwise installs to **`~/.local/bin`** and will add it to your PATH for:

  * current session, and
  * future shells (`~/.bashrc`, `~/.zshrc`, `fish_user_paths`, or `~/.profile`)

It symlinks `./shortcuts/*.sh` to extensionless commands (e.g. `gco.sh` → `gco`).

---

## Usage examples

```sh
gst
gad .
gcm "wip: checkpoint"
gco feature/my-branch
gpl
gps
gdf
gsh push "before refactor"
gsh load refactor
```

---

## Uninstall

Because installation is done via symlinks, uninstall is just removing those links.

If installed system-wide:

```sh
sudo rm -f /usr/local/bin/gad /usr/local/bin/gcm /usr/local/bin/gco /usr/local/bin/gdf /usr/local/bin/gmm /usr/local/bin/gpl /usr/local/bin/gps /usr/local/bin/gsh /usr/local/bin/gst
```

If installed to your user bin:

```sh
rm -f ~/.local/bin/gad ~/.local/bin/gcm ~/.local/bin/gco ~/.local/bin/gdf ~/.local/bin/gmm ~/.local/bin/gpl ~/.local/bin/gps ~/.local/bin/gsh ~/.local/bin/gst
```

(Optional) If you want to remove the PATH line the installer may have added, delete:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

from your `~/.bashrc`, `~/.zshrc`, or `~/.profile` (whichever it modified). For fish, remove `~/.local/bin` from `fish_user_paths`.

---

## Notes / compatibility

* The installer is POSIX `sh`.
* Shortcut scripts are simple shell scripts; a few use `[[ ... ]]` (bash/zsh style). If you use a strictly POSIX shell to run them directly, you may need to adjust those scripts.
* `gmm` merges from `origin/master`. If your default branch is `main`, change it to `origin/main`.

---

## Contributing

PRs welcome—especially for:

* `main` vs `master` default handling
* better help/usage output (`--help`) per command
* additional shortcuts (keep them small and obvious)

---

## License

Add a license file if you want explicit terms (MIT is a common choice for small utilities).

```
MIT License

Copyright (c) 2026 Max Delér
```
