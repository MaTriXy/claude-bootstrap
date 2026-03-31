#!/bin/bash

# Claude Bootstrap Installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Bootstrap v3.0.0..."
echo ""

# Save bootstrap directory location for other scripts
echo "$SCRIPT_DIR" > "$HOME/.claude/.bootstrap-dir"

# Create directories
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/rules"

# Copy all commands
cp "$SCRIPT_DIR/commands/"*.md "$CLAUDE_DIR/commands/"
echo "✓ Installed commands:"
ls -1 "$CLAUDE_DIR/commands/" | sed 's/^/  - \//' | sed 's/\.md$//'

# Copy skills (folder structure with SKILL.md)
echo ""
echo "Installing skills..."
rm -rf "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/skills"
skill_count=0
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        cp -r "${skill_dir%/}" "$CLAUDE_DIR/skills/"
        skill_count=$((skill_count + 1))
    fi
done
echo "✓ Installed $skill_count skills (folder/SKILL.md structure)"

# Copy conditional rules
echo ""
echo "Installing conditional rules..."
rm -rf "$CLAUDE_DIR/rules"
mkdir -p "$CLAUDE_DIR/rules"
rule_count=0
for rule_file in "$SCRIPT_DIR/rules/"*.md; do
    if [ -f "$rule_file" ]; then
        cp "$rule_file" "$CLAUDE_DIR/rules/"
        rule_count=$((rule_count + 1))
    fi
done
echo "✓ Installed $rule_count conditional rules (with paths: frontmatter)"
ls -1 "$CLAUDE_DIR/rules/" | sed 's/^/  - /' | sed 's/\.md$//'

# Copy hooks
cp "$SCRIPT_DIR/hooks/"* "$CLAUDE_DIR/hooks/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/hooks/"* 2>/dev/null || true
echo ""
echo "✓ Installed git hooks (templates)"

# Copy templates
echo ""
echo "Installing templates..."
mkdir -p "$CLAUDE_DIR/templates"
cp "$SCRIPT_DIR/templates/"* "$CLAUDE_DIR/templates/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/templates/tdd-loop-check.sh" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/templates/pre-compact.sh" 2>/dev/null || true
echo "✓ Installed templates (CLAUDE.md, CLAUDE.local.md, settings.json, tdd-loop-check.sh, pre-compact.sh)"

# Copy hook installer script
cp "$SCRIPT_DIR/scripts/install-hooks.sh" "$CLAUDE_DIR/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/install-hooks.sh" 2>/dev/null || true

# Copy graph tools installer
cp "$SCRIPT_DIR/scripts/install-graph-tools.sh" "$CLAUDE_DIR/" 2>/dev/null || true
chmod +x "$CLAUDE_DIR/install-graph-tools.sh" 2>/dev/null || true

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
echo "  Installation complete! (v3.0.0)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "What's new in v3.0.0:"
echo "  • Stop hooks for TDD loops (replaces Ralph Wiggum plugin)"
echo "  • @include directives in CLAUDE.md"
echo "  • Conditional rules with paths: frontmatter"
echo "  • Pre-configured permissions in settings.json"
echo "  • Agent definitions with proper frontmatter"
echo "  • CLAUDE.local.md for private overrides"
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
echo "New in this version:"
echo "  Conditional rules:  ~/.claude/rules/ (auto-activate by file path)"
echo "  Settings template:  ~/.claude/templates/settings.json"
echo "  TDD loop script:    ~/.claude/templates/tdd-loop-check.sh"
echo "  Local overrides:    ~/.claude/templates/CLAUDE.local.md"
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
