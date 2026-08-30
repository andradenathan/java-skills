#!/usr/bin/env bash
#
# Install the Java skills into a Claude skills directory.
#
#   ./install.sh                  symlink every skill into ~/.claude/skills
#   ./install.sh --copy           copy instead of symlinking
#   ./install.sh --target DIR     install somewhere else (e.g. a project's .claude/skills)
#   ./install.sh --uninstall      remove the skills this repo installed
#   ./install.sh --list           show what is installed and how
#
# Symlinking is the default: a git pull then updates the installed skills.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MODE="symlink"
ACTION="install"
FORCE=0

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

while [ $# -gt 0 ]; do
    case "$1" in
        --copy)      MODE="copy" ;;
        --target)    [ $# -ge 2 ] || die "--target needs a directory"; TARGET_DIR="$2"; shift ;;
        --uninstall) ACTION="uninstall" ;;
        --list)      ACTION="list" ;;
        --force|-f)  FORCE=1 ;;
        -h|--help)   sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)           die "unknown option: $1 (try --help)" ;;
    esac
    shift
done

[ -d "$SOURCE_DIR" ] || die "no skills/ directory next to this script"

skills() {
    local d
    for d in "$SOURCE_DIR"/*/; do
        [ -f "$d/SKILL.md" ] && basename "$d"
    done
}

# A target entry belongs to us if it is a symlink into this repo, or a directory
# whose SKILL.md matches the one we would install.
is_ours() {
    local name="$1" dest="$TARGET_DIR/$name"
    if [ -L "$dest" ]; then
        case "$(readlink "$dest")" in "$SOURCE_DIR"/*) return 0 ;; esac
        return 1
    fi
    [ -f "$dest/SKILL.md" ] && cmp -s "$dest/SKILL.md" "$SOURCE_DIR/$name/SKILL.md"
}

case "$ACTION" in
list)
    printf 'source: %s\ntarget: %s\n\n' "$SOURCE_DIR" "$TARGET_DIR"
    for name in $(skills); do
        dest="$TARGET_DIR/$name"
        if [ -L "$dest" ]; then   state="linked"
        elif [ -d "$dest" ]; then state=$(is_ours "$name" && echo "copied" || echo "PRESENT (not ours)")
        else                      state="not installed"
        fi
        printf '  %-32s %s\n' "$name" "$state"
    done
    ;;

uninstall)
    removed=0
    for name in $(skills); do
        dest="$TARGET_DIR/$name"
        [ -e "$dest" ] || [ -L "$dest" ] || continue
        if is_ours "$name" || [ "$FORCE" -eq 1 ]; then
            rm -rf "$dest"
            printf 'removed  %s\n' "$name"
            removed=$((removed + 1))
        else
            printf 'skipped  %s (modified locally; use --force)\n' "$name" >&2
        fi
    done
    printf '\n%d skill(s) removed from %s\n' "$removed" "$TARGET_DIR"
    ;;

install)
    mkdir -p "$TARGET_DIR"
    installed=0
    for name in $(skills); do
        src="$SOURCE_DIR/$name"
        dest="$TARGET_DIR/$name"

        if [ -e "$dest" ] || [ -L "$dest" ]; then
            if is_ours "$name" || [ "$FORCE" -eq 1 ]; then
                rm -rf "$dest"
            else
                printf 'skipped  %s (already exists and differs; use --force)\n' "$name" >&2
                continue
            fi
        fi

        if [ "$MODE" = "symlink" ]; then
            ln -s "$src" "$dest"
        else
            cp -R "$src" "$dest"
        fi
        printf '%-8s %s\n' "$MODE" "$name"
        installed=$((installed + 1))
    done
    printf '\n%d skill(s) installed into %s\n' "$installed" "$TARGET_DIR"
    [ "$MODE" = "symlink" ] && printf 'symlinked: a git pull updates them in place.\n'
    printf 'Restart Claude Code (or start a new session) to pick them up.\n'
    ;;
esac
