#!/bin/sh
# install.sh — Install git shortcut commands from ./bin
# Works for bash/zsh/fish. No arguments.
# Behavior:
# - If /usr/local/bin is writable (or sudo available), install there.
# - Else installs to ~/.local/bin and puts it on PATH.
# - Symlinks *.sh in ./bin to commands without the .sh extension.
# - Re-execs your shell so commands work immediately.

set -eu

REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
SRC_DIR="$REPO_DIR/shortcuts"

if [ ! -d "$SRC_DIR" ]; then
  echo "❌ Expected scripts in: $SRC_DIR"
  echo "   Create a ./shortcuts directory with your shortcuts (e.g., gco.sh, gcm.sh)."
  exit 1
fi

# Choose install target
USER_BIN="$HOME/.local/bin"
SYS_BIN="/usr/local/bin"
TARGET=""

can_write_dir() { [ -d "$1" ] && [ -w "$1" ]; }

# Try system-wide first if possible (more seamless: already on PATH)
if can_write_dir "$SYS_BIN"; then
  TARGET="$SYS_BIN"
elif command -v sudo >/dev/null 2>&1; then
  # Try creating the dir with sudo if not present, and set TARGET to SYS_BIN
  if [ ! -d "$SYS_BIN" ]; then
    echo "📦 Creating $SYS_BIN (sudo)…"
    sudo mkdir -p "$SYS_BIN"
  fi
  if [ -d "$SYS_BIN" ] && [ -w "$SYS_BIN" ]; then
    TARGET="$SYS_BIN"
  else
    # We may not have write access without sudo; we’ll use sudo in link step
    TARGET="$SYS_BIN"
  fi
fi

# If no system target, use user-local
if [ -z "$TARGET" ]; then
  TARGET="$USER_BIN"
  mkdir -p "$USER_BIN"
fi

echo "🔧 Installing commands from $SRC_DIR → $TARGET"

need_sudo=0
if [ "$TARGET" = "$SYS_BIN" ] && [ ! -w "$TARGET" ]; then
  need_sudo=1
fi

# Link all *.sh as extensionless commands
found_any=0
for f in "$SRC_DIR"/*.sh; do
  [ -e "$f" ] || continue
  found_any=1
  name="$(basename "$f" .sh)"
  chmod +x "$f" || true
  if [ "$need_sudo" -eq 1 ]; then
    sudo ln -sf "$f" "$TARGET/$name"
    sudo chmod +x "$TARGET/$name" || true
  else
    ln -sf "$f" "$TARGET/$name"
    chmod +x "$TARGET/$name" || true
  fi
  echo "✅ $name"
done

if [ "$found_any" -eq 0 ]; then
  echo "ℹ️  No .sh files found in $SRC_DIR"
fi

# Ensure target dir is on PATH (current session + future)
on_path_now() {
  case ":$PATH:" in *":$1:"*) return 0 ;; *) return 1 ;; esac
}

SHELL_BASENAME="$(basename "${SHELL:-}")"
persist_line='export PATH="$HOME/.local/bin:$PATH"'
persisted=0

if ! on_path_now "$TARGET"; then
  # If installing to user dir, we can adjust PATH
  if [ "$TARGET" = "$USER_BIN" ]; then
    # Add for current session
    PATH="$USER_BIN:$PATH"; export PATH
    echo "➕ Added $USER_BIN to PATH for this session."

    # Persist for future shells
    case "$SHELL_BASENAME" in
      bash)
        if [ ! -f "$HOME/.bashrc" ] || ! grep -qs '^\s*export PATH="\$HOME/.local/bin:\$PATH"' "$HOME/.bashrc"; then
          echo "$persist_line" >> "$HOME/.bashrc"; echo "📝 Persisted to ~/.bashrc"; persisted=1
        fi
        ;;
      zsh)
        if [ ! -f "$HOME/.zshrc" ] || ! grep -qs '^\s*export PATH="\$HOME/.local/bin:\$PATH"' "$HOME/.zshrc"; then
          echo "$persist_line" >> "$HOME/.zshrc"; echo "📝 Persisted to ~/.zshrc"; persisted=1
        fi
        ;;
      fish)
        if command -v fish >/dev/null 2>&1; then
          if ! fish -c 'contains -- $HOME/.local/bin $fish_user_paths' >/dev/null 2>&1; then
            fish -c 'set -U fish_user_paths $HOME/.local/bin $fish_user_paths'
            echo "📝 Persisted to fish_user_paths"; persisted=1
          fi
        fi
        ;;
      *)
        # Fallback for login shells
        if [ ! -f "$HOME/.profile" ] || ! grep -qs '^\s*export PATH="\$HOME/.local/bin:\$PATH"' "$HOME/.profile"; then
          echo "$persist_line" >> "$HOME/.profile"; echo "📝 Persisted to ~/.profile"; persisted=1
        fi
        ;;
    esac
  else
    # TARGET is /usr/local/bin; this should already be on PATH for almost everyone.
    :
  fi
fi

# Verification
echo
echo "🔎 Verifying:"
for f in "$SRC_DIR"/*.sh; do
  [ -e "$f" ] || continue
  name="$(basename "$f" .sh)"
  if command -v "$name" >/dev/null 2>&1; then
    echo "  • $name → OK ($(command -v "$name"))"
  else
    echo "  • $name → NOT FOUND on PATH"
  fi
done

# Make commands available immediately by re-execing the shell if needed
# (child cannot modify parent env; this is the standard workaround)
# Only do this for interactive shells to avoid surprising scripts/CI.
is_interactive=0
case "$-" in *i*) is_interactive=1 ;; esac

if [ "$is_interactive" -eq 1 ]; then
  # If target is user bin and wasn't on PATH at script start, re-exec
  if [ "$TARGET" = "$USER_BIN" ]; then
    # If commands still not visible, re-exec current shell as login shell
    need_reexec=0
    for f in "$SRC_DIR"/*.sh; do
      [ -e "$f" ] || continue
      name="$(basename "$f" .sh)"
      if ! command -v "$name" >/dev/null 2>&1; then
        need_reexec=1
        break
      fi
    done

    if [ "$need_reexec" -eq 1 ]; then
      echo
      echo "🔁 Reloading your shell so new commands are available now…"
      case "$SHELL_BASENAME" in
        bash|zsh) exec "$SHELL" -l ;;
        fish)     exec fish -l ;;
        *)        exec "$SHELL" -l ;;
      esac
    fi
  fi
fi

echo
echo "🎉 Done! Your git shortcuts should work now. Try:  gco --help"
