# Claude Code 配置

个人 Claude Code 全局 Skills、Hooks 和脚本的版本管理仓库。

## 目录结构

```
├── skills/              # 自建全局 Skills
│   ├── code-review/     # 代码审查
│   ├── grill-me/        # 辅助决策拷问
│   ├── learn-project/   # 项目架构学习
│   ├── qiuzhi-skill-creator/  # Skill 创建向导
│   ├── session-wrap-up/ # 会话收尾
│   └── smart-commit/    # 智能提交
├── hooks/               # 全局 Hooks 配置
│   └── settings.json    # hooks 片段（合并到 ~/.claude/settings.json）
├── scripts/             # Hooks 依赖脚本
│   ├── notify.ps1       # Windows 通知
│   └── statusline.js    # 状态栏显示
└── setup.sh             # 一键部署脚本
```

## 快速部署

```bash
# 克隆仓库
git clone https://github.com/cfy1126/claude-code-config.git
cd claude-code-config

# 执行部署（将 Skills、Scripts 复制到 ~/.claude/，合并 Hooks 配置）
bash setup.sh
```

## 手动部署

```bash
# 复制 Skills
cp -r skills/* ~/.claude/skills/

# 复制脚本
cp scripts/* ~/.claude/scripts/

# 将 hooks/settings.json 中的 hooks 合并到 ~/.claude/settings.json
```

## 第三方 Skills（通过 npx skills 安装）

以下 Skills 不在此仓库管理，通过 `npx skills` 安装：

- `agent-browser` — 浏览器自动化
- `find-skills` — Skill 发现
- `nano-banana` — AI 图片生成
- `skill-creator` — Skill 创建/测试
- `xlsx` — 电子表格处理

安装命令：
```bash
npx skills add <owner/repo@skill> -g -y
```
