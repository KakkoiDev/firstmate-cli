#!/usr/bin/env bash
# Install firstmate-cli: make the `firstmate` and `secondmate` commands
# available from anywhere by symlinking bin/ into ~/.local/bin.
#
# Usage (from a checkout):
#   ./install.sh
#
# Usage (remote, one command):
#   curl -fsSL https://raw.githubusercontent.com/KakkoiDev/firstmate-cli/main/install.sh | bash
#
# In the remote case the two commands are downloaded from the repo's main
# branch instead of symlinked.
set -eu

BIN_DIR="$HOME/.local/bin"
RAW_BASE="https://raw.githubusercontent.com/KakkoiDev/firstmate-cli/main"
TOOLS="firstmate secondmate"

# Empty when the script is piped from curl; set to the checkout when run from one.
SRC_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

die() { echo "error: $*" >&2; exit 1; }

mkdir -p "$BIN_DIR"

for tool in $TOOLS; do
  if [ -n "$SRC_DIR" ]; then
    src="$SRC_DIR/bin/$tool"
    [ -f "$src" ] || die "missing $src (run install.sh from the firstmate-cli checkout)"
    [ -x "$src" ] || chmod +x "$src"
    ln -sf "$src" "$BIN_DIR/$tool"
    echo "linked: $BIN_DIR/$tool -> $src"
  else
    echo "downloading $tool ..."
    if ! curl -fsSL "$RAW_BASE/bin/$tool" -o "$BIN_DIR/$tool"; then
      rm -f "$BIN_DIR/$tool"
      die "download of $RAW_BASE/bin/$tool failed (is the repo published?)"
    fi
    chmod +x "$BIN_DIR/$tool"
    echo "installed: $BIN_DIR/$tool"
  fi
done

# Warn (don't fail) about missing runtime dependencies; the commands
# themselves report these with clear messages.
for dep in tmux pi; do
  command -v "$dep" >/dev/null 2>&1 || {
    echo "warning: $dep not found on PATH (firstmate needs it at runtime)" >&2
  }
done

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "warning: $BIN_DIR is not on your PATH" >&2
    echo "         add it with: export PATH=\"$BIN_DIR:\$PATH\"" >&2
    ;;
esac

echo
echo "Installed. Next steps:"
echo "  firstmate            # boot (or attach to) the firstmate tmux session"
echo "  secondmate <path>    # adopt a worktree into the firstmate fleet"
