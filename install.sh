#!/bin/bash

# Claude Bootstrap Installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Bootstrap..."
echo ""

# Save bootstrap directory location for other scripts
echo "$SCRIPT_DIR" > "$HOME/.claude/.bootstrap-dir"

# Create directories
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/plugins"

# Copy all commands
cp "$SCRIPT_DIR/commands/"*.md "$CLAUDE_DIR/commands/"
echo "✓ Installed commands:"
ls -1 "$CLAUDE_DIR/commands/" | sed 's/^/  - \//' | sed 's/\.md$//'

# Copy skills (folder structure with SKILL.md)
echo ""
echo "Installing skills..."
# First, remove old skills to ensure clean state
rm -rf "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/skills"
skill_count=0
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        # Remove trailing slash and copy the folder itself
        cp -r "${skill_dir%/}" "$CLAUDE_DIR/skills/"
        skill_count=$((skill_count + 1))
    fi
done
echo "✓ Installed $skill_count skills (folder/SKILL.md structure)"

# Copy hooks
cp "$SCRIPT_DIR/hooks/"* "$CLAUDE_DIR/hooks/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/hooks/"* 2>/dev/null || true
echo "✓ Installed git hooks (templates)"

# Copy hook installer script
cp "$SCRIPT_DIR/scripts/install-hooks.sh" "$CLAUDE_DIR/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/install-hooks.sh" 2>/dev/null || true

# Copy graph tools installer
cp "$SCRIPT_DIR/scripts/install-graph-tools.sh" "$CLAUDE_DIR/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/install-graph-tools.sh" 2>/dev/null || true

# Check for Ralph Loop plugin
echo ""
if [ -d "$CLAUDE_DIR/plugins/marketplaces/claude-plugins-official/plugins/ralph-loop" ]; then
    echo "✓ Ralph Loop plugin available in marketplace"
    echo "  To install: /plugin install ralph-loop@claude-plugins-official"
else
    echo "⚠ Ralph Loop plugin not found in marketplace"
    echo "  Update marketplace: /plugin update (in Claude Code)"
    echo "  Then install: /plugin install ralph-loop@claude-plugins-official"
fi

# Run validation
echo ""
echo "Running validation..."
if [ -f "$SCRIPT_DIR/tests/validate-structure.sh" ]; then
    if "$SCRIPT_DIR/tests/validate-structure.sh" --quick; then
        echo ""
    else
        echo ""
        echo "⚠ Validation found issues. Run full validation:"
        echo "  $SCRIPT_DIR/tests/validate-structure.sh --full"
    fi
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Installation complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Usage:"
echo "  1. Open any project folder"
echo "  2. Run: claude"
echo "  3. Type: /initialize-project"
echo ""
echo "Commands installed:"
echo "  /initialize-project   - Full project setup"
echo "  /spawn-team           - Spawn agent team for parallel development"
echo "  /check-contributors   - Team coordination"
echo "  /update-code-index    - Regenerate code index"
echo ""
echo "Git Hooks (per-project):"
echo "  cd your-project && ~/.claude/install-hooks.sh"
echo ""
echo "Code Graph Tools:"
echo "  ~/.claude/install-graph-tools.sh            - Install Tier 1 (default)"
echo "  ~/.claude/install-graph-tools.sh --joern     - Also install Tier 2 (CPG)"
echo "  ~/.claude/install-graph-tools.sh --codeql    - Also install Tier 3 (security)"
echo "  ~/.claude/install-graph-tools.sh --all       - Install all tiers"
echo ""
echo "Validation:"
echo "  $SCRIPT_DIR/tests/validate-structure.sh --full"
echo ""
