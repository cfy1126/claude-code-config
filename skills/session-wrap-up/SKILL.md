---
name: session-wrap-up
description: "会话收尾时自动更新项目知识库。当用户说'更新笔记'、'记录工作'、'会话总结'、'wrap up'时触发。也适用于用户表示要结束当前工作会话、准备离开的场景。此技能会从 git 变更和会话上下文中提取工作内容，更新 .claude/NOTES.md、CHANGELOG.md、TODO.md 和 memory 文件。"
---

# 会话收尾 — 更新项目知识库

此技能在每次工作会话结束时运行，将本次会话的工作成果沉淀到本地知识库，形成"第二大脑"的持续积累。

## 知识库文件位置

所有文件都在项目根目录的 `.claude/` 下（不进入 git 仓库）：

| 文件 | 用途 | 更新频率 |
|------|------|---------|
| `.claude/NOTES.md` | 工作笔记（按时间倒序） | 每次会话 |
| `.claude/CHANGELOG.md` | 变更日志 | 有新功能/修复时 |
| `.claude/TODO.md` | 日常待办 | 发现新待办时 |
| `memory/` 目录 | 设计模式、架构决策、反馈 | 发现重要知识时 |

## 执行流程

### 第一步：收集变更信息

执行以下命令获取本次会话的变更：

```bash
git diff --stat
git log --oneline -10
git status -s
```

同时读取当前知识库文件：
- `.claude/NOTES.md`
- `.claude/CHANGELOG.md`
- `.claude/TODO.md`

### 第一步半：NOTES.md 归档检查

读取 `.claude/NOTES.md`，检查总行数。如果超过 200 行：

1. 找出超过 30 天的日期条目（`## YYYY-MM-DD` 格式的章节）
2. 将这些条目移到 `.claude/archive/NOTES-YYYY-MM.md`（按月归档，同一个月的条目合并到一个文件）
3. 如果归档文件已存在，将条目追加到末尾
4. **不要归档** `## 长期记忆` 部分（核心模式、易踩坑点始终保留）
5. 归档后 NOTES.md 应控制在 150 行以内
6. 输出归档摘要：归档了 N 个条目到 archive/NOTES-YYYY-MM.md

### 第二步：更新 NOTES.md

在 `---` 分隔线之后、第一条日期记录之前，插入或更新今日条目：

```markdown
## YYYY-MM-DD

### 完成的工作
- （从 git diff 和会话上下文提取，每项一行，**标注涉及的文件路径**）
  例：`FlowProcess/index.vue` 按钮布局调整：标题栏右侧放置操作按钮

### 关键决策
- （从会话上下文中提取非显而易见的技术选择）

### 发现的问题
- （会话中遇到的 bug、异常行为）

### 待验证
- [ ] （需要手动测试确认的功能点）
```

如果今日条目已存在，合并新旧内容（去重），不重复插入日期标题。

### 第三步：按需更新 CHANGELOG.md

判断标准：如果有 git 提交或未提交但已完成的新功能/修复，在文件顶部插入条目：

```markdown
## YYYY-MM-DD

### 新增
- xxx

### 修复
- xxx

### 优化
- xxx

### 注释
- xxx（仅保留原有注释但不删除时记录）
```

如果当日条目已存在，合并到已有条目中。

### 第四步：按需更新 TODO.md

TODO.md 采用三段式结构：**In Progress / Backlog / Completed**。

#### In Progress — 从 git status 生成

将 `git status -s` 中的变更文件按逻辑分组为待提交项，每组是一个 TODO，关联文件嵌套列出：

```markdown
## In Progress (from git status)

- [ ] 提交 xxx 改动
  - src/path/to/file1.ts
  - src/path/to/file2.vue
  - src/path/to/file3.ts (new)
- [ ] 提交 yyy 修改
  - src/path/to/file4.ts
```

分组原则：按功能模块或逻辑关联归类，而非一个文件一个 TODO。新文件标注 `(new)`。

#### Backlog — 新发现的待办

会话中用户提到的非即时待办追加到此处：

```markdown
## Backlog

- [ ] 待办描述
```

#### Completed — 已完成事项

已完成的待办从 In Progress 或 Backlog 移到此处，标注日期：

```markdown
## Completed

- [x] 完成的事项（YYYY-MM-DD）
```

### 第五步：按需更新 Memory 文件

如果会话中发现了以下类型的知识，创建或更新对应的 memory 文件：

| 知识类型 | 文件命名 | 创建条件 |
|---------|---------|---------|
| 反馈/踩坑 | `memory/feedback_xxx.md` | 用户纠正了 Claude 的行为或发现了陷阱 |
| 设计模式 | `memory/pattern_xxx.md` | 理解了一个可复用的代码模式或架构 |
| 架构决策 | `memory/decision_xxx.md` | 做了非显而易见的技术选择 |

每个 memory 文件必须包含 frontmatter：

```yaml
---
name: xxx
description: 一句话描述
type: feedback | pattern | decision | reference
---
```

**重要**：新增 memory 文件后，必须同步更新 `memory/MEMORY.md` 索引，在对应分类下添加一行链接。MEMORY.md 总行数不能超过 200 行。

**Memory 与 NOTES 分工原则**：
- **Memory**（feedback/pattern/decision）：3 个月后仍有用的可复用知识（行为约束、架构模式、技术选型理由）
- **NOTES 关键决策**：当时为什么这样做的时间上下文（了解历史决策背景时有用）
- 判断标准：如果一条知识在新会话中仍可能指导行为 → Memory；如果只在理解历史时有用 → NOTES
- 如果某条知识同时满足两者标准，NOTES 中保留简要提及并注明"详见 memory/xxx.md"，详细内容放在 Memory

### 第六步：输出更新摘要

完成所有更新后，向用户输出简洁摘要：

```
知识库已更新：
- NOTES.md：+N 条工作记录
- CHANGELOG.md：+N 条变更
- TODO.md：+N 条待办
- Memory：新增/更新了 xxx
```

## 注意事项

- NOTES.md 中的"长期记忆"部分（核心模式、易踩坑点）是跨时间有效的，不要在每次更新时删除，只在确实有新内容时追加
- 遵循"最少改动"原则：只添加新内容，不重构已有条目的格式
- 所有内容使用中文
- 如果 git 没有任何变更且会话中没有特殊发现，只输出"本次会话无需更新知识库"
