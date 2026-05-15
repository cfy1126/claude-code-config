#!/bin/bash
# Claude Code 配置一键部署脚本
# 将 Skills、Scripts 复制到 ~/.claude/，合并 Hooks 到 settings.json

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Code 配置部署 ==="
echo "源目录: $SCRIPT_DIR"
echo "目标目录: $CLAUDE_DIR"
echo ""

# 1. 复制自建 Skills
echo "--- 部署 Skills ---"
mkdir -p "$CLAUDE_DIR/skills"
for skill in "$SCRIPT_DIR/skills/"*/; do
  skill_name=$(basename "$skill")
  if [ -L "$CLAUDE_DIR/skills/$skill_name" ]; then
    echo "  跳过 $skill_name（第三方符号链接）"
  else
    cp -r "$skill" "$CLAUDE_DIR/skills/"
    echo "  已部署 $skill_name"
  fi
done

# 2. 复制脚本
echo "--- 部署 Scripts ---"
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR/scripts/"* "$CLAUDE_DIR/scripts/"
echo "  已部署 $(ls "$SCRIPT_DIR/scripts/" | wc -l) 个脚本"

# 3. 合并 Hooks 到 settings.json
echo "--- 合并 Hooks ---"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOKS_FILE="$SCRIPT_DIR/hooks/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo "  ~/.claude/settings.json 不存在，跳过 hooks 合并"
  echo "  请手动将 hooks/settings.json 中的内容合并到你的 settings.json"
else
  # 使用 node 合并 JSON（保留已有配置）
  node -e "
    const fs = require('fs');
    const settings = JSON.parse(fs.readFileSync('$SETTINGS', 'utf8'));
    const hooks = JSON.parse(fs.readFileSync('$HOOKS_FILE', 'utf8'));
    settings.hooks = { ...settings.hooks, ...hooks.hooks };
    fs.writeFileSync('$SETTINGS', JSON.stringify(settings, null, 2) + '\n');
    console.log('  Hooks 已合并');
  "
fi

echo ""
echo "=== 部署完成 ==="
echo "Skills: $(ls "$CLAUDE_DIR/skills/" | wc -l) 个"
echo "Scripts: $(ls "$CLAUDE_DIR/scripts/" | wc -l) 个"
