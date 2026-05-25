#!/usr/bin/env bash
set -euo pipefail

# SkillHub installer — copy skills and config to a target project
# Usage: ./install.sh /path/to/target-project

TARGET="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HUB_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "$TARGET" ]; then
  echo "Usage: ./install.sh <target-project-dir>"
  echo "  Copies .agent/skills, merges CLAUDE.md and .claude/settings.json into the target."
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "Error: $TARGET does not exist or is not a directory"
  exit 1
fi

echo "==> SkillHub install to $TARGET"

# 1. Copy skills
if [ -d "$HUB_DIR/.agent" ]; then
  mkdir -p "$TARGET/.agent"
  cp -r "$HUB_DIR/.agent/skills" "$TARGET/.agent/"
  echo "    .agent/skills/ copied"
fi

# 2. Merge CLAUDE.md
if [ -f "$TARGET/CLAUDE.md" ]; then
  if ! grep -q "SkillHub" "$TARGET/CLAUDE.md"; then
    echo "" >> "$TARGET/CLAUDE.md"
    echo "<!-- Managed by SkillHub -->" >> "$TARGET/CLAUDE.md"
    cat "$HUB_DIR/CLAUDE.md" >> "$TARGET/CLAUDE.md"
    echo "    CLAUDE.md merged (appended)"
  else
    echo "    CLAUDE.md already has SkillHub content, skipped"
  fi
else
  cp "$HUB_DIR/CLAUDE.md" "$TARGET/"
  echo "    CLAUDE.md created"
fi

# 3. Merge permissions
if [ -f "$HUB_DIR/.claude/settings.json" ]; then
  mkdir -p "$TARGET/.claude"
  if [ -f "$TARGET/.claude/settings.json" ]; then
    echo "    .claude/settings.json exists, merge manually to avoid overwriting"
  else
    cp "$HUB_DIR/.claude/settings.json" "$TARGET/.claude/"
    echo "    .claude/settings.json created"
  fi
fi

echo "==> Done. Skills available: $(ls "$TARGET/.agent/skills" | sed 's/\.md//g' | tr '\n' ' ')"
