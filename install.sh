#!/usr/bin/env sh
# Install the consult and grill-me skills into a repository.
#
# Usage: ./install.sh REPO_DIR [--skills consult,grill-me] [--devin-cli] [--dry-run]
#
#   REPO_DIR     the repository to install into (required)
#   --skills     which skills to install (default: consult,grill-me)
#   --devin-cli  also install a personal copy for Devin for Terminal (~/.config/devin/skills)
#   --dry-run    print what would happen and change nothing
#
# Each skill goes to REPO_DIR/.claude/skills/<skill>/ as one real folder (no symlinks). Claude Code,
# GitHub Copilot, Cursor and Devin cloud all read that folder. An existing copy is moved to
# REPO_DIR/.kos/install/backup/ before it is replaced.
set -eu

die() { echo "install.sh: $*" >&2; exit 2; }

SRC=$(cd -P "$(dirname "$0")" && pwd -P)
TARGET=""
SKILLS="consult,grill-me"
DEVIN=0
DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --skills) [ $# -ge 2 ] || die "--skills needs a value"; SKILLS=$2; shift ;;
    --skills=*) SKILLS=${1#--skills=} ;;
    --devin-cli) DEVIN=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    -*) die "unknown option $1 (see --help)" ;;
    *) [ -z "$TARGET" ] || die "only one REPO_DIR may be given"; TARGET=$1 ;;
  esac
  shift
done
[ -n "$TARGET" ] || die "REPO_DIR is required (see --help)"
[ -d "$TARGET" ] || die "not a directory: $TARGET"
BASE=$(cd -P "$TARGET" && pwd -P)

run() { if [ "$DRY" = 1 ]; then echo "  would: $*"; else "$@"; fi; }

copy_skill() { # $1 = source skill dir (real path), $2 = destination dir, $3 = work dir (temp + backups)
  src=$1; dest=$2; work=$3; parent=$(dirname "$dest")
  case "$src/" in "$dest/"*) die "source $src is inside $dest; run the installer from a separate checkout" ;; esac
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ ! -L "$dest" ] && [ "$(cd -P "$dest" && pwd -P)" = "$src" ]; then
      echo "  $dest is the source itself; nothing to do"; return 0
    fi
  fi
  run mkdir -p "$parent"
  if [ "$DRY" = 1 ]; then
    echo "  would: copy $src -> $dest (excluding .git, __pycache__, *.pyc, .DS_Store)"
    [ -e "$dest" ] || [ -L "$dest" ] && echo "  would: move the existing $dest to a backup first"
    return 0
  fi
  # temp copy lives outside every skills folder, so an interrupted run never leaves a second SKILL.md
  mkdir -p "$work/tmp" "$work/backup" || die "cannot create $work"
  tmp=$(mktemp -d "$work/tmp/$(basename "$dest").XXXXXX") || die "mktemp failed in $work/tmp"
  (cd "$src" && tar cf - --exclude=.git --exclude=__pycache__ --exclude='*.pyc' --exclude=.DS_Store .) \
    | (cd "$tmp" && tar xf -) || die "copy into $tmp failed"
  [ -f "$tmp/SKILL.md" ] || die "copy of $src is incomplete"
  if [ -L "$dest" ]; then
    rm -f "$dest" || die "cannot remove link $dest"   # the link itself, never its target
  elif [ -e "$dest" ]; then
    bk=$(mktemp -d "$work/backup/$(basename "$dest")-$(date +%Y%m%d%H%M%S).XXXX") || die "mktemp failed"
    rmdir "$bk" && mv "$dest" "$bk" || die "could not move $dest to $bk; nothing replaced"
    echo "  previous copy moved to $bk"
  fi
  [ ! -e "$dest" ] || die "$dest still exists; nothing replaced"
  mv "$tmp" "$dest" || die "could not move the new copy into $dest"
  chmod +x "$dest"/scripts/*.py 2>/dev/null || true
}

OLDIFS=$IFS; IFS=,
for s in $SKILLS; do
  IFS=$OLDIFS
  [ -n "$s" ] || continue
  [ -f "$SRC/$s/SKILL.md" ] || die "no skill named '$s' in $SRC"
  echo "Installing $s"
  copy_skill "$SRC/$s" "$BASE/.claude/skills/$s" "$BASE/.kos/install"
  if [ "$DEVIN" = 1 ]; then
    DV="${XDG_CONFIG_HOME:-$HOME/.config}/devin"
    copy_skill "$SRC/$s" "$DV/skills/$s" "$DV/.kos-install"
  fi
  IFS=,
done
IFS=$OLDIFS

if [ "$DRY" = 0 ]; then
  echo "Done. Skills are in $BASE/.claude/skills/ (Claude Code, Copilot, Cursor, Devin cloud)."
  [ "$DEVIN" = 1 ] && echo "Devin for Terminal copy: ${XDG_CONFIG_HOME:-$HOME/.config}/devin/skills/"
  if [ -f "$BASE/.gitignore" ] && ! grep -q '^\.kos/' "$BASE/.gitignore"; then
    echo "Tip: add '.kos/' to .gitignore (saved maps and installer backups live there)."
  fi
fi
