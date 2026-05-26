---
name: pipeline
description: 代码质量流水线 — 功能开发完成后自动执行 simplify → code-review → smart-commit 三步质量关卡，自动修复问题直到审查通过再提交。当用户说"跑流水线"、"pipeline"、"质量检查"、"审查并提交"、"走流程"时使用此技能。也适用于用户刚完成一个功能/修复/重构，需要标准化的质量保障和提交流程时。
---

# Pipeline: simplify → code-review → smart-commit

功能开发完成后的标准化质量关卡，三步按序执行，每步通过后才进入下一步。

## 前置检查

执行 `git diff --stat` 和 `git status -s`。如果工作区没有任何变更，输出"工作区干净，无需执行流水线"并结束。

## Step 1/3: Simplify

使用 `Skill` 工具调用 `simplify`，执行代码复用、质量、效率三维度审查并自动修复。

```
Skill({ skill: "simplify" })
```

完成后输出：`[1/3] simplify — 完成，修复了 N 个问题`（无问题则 N=0）

## Step 2/3: Code Review + 自动修复

使用 `Skill` 工具调用 `code-review`，执行结构化审查。根据 Verdict：

```
Skill({ skill: "code-review" })
```

- **PASS** → 进入 Step 3
- **CAUTION / BLOCK** → 自动修复所有 Must fix 和 Should fix 问题，然后重新调用 `Skill({ skill: "code-review" })`
- 迭代上限 3 次。超过 3 次仍未 PASS → 暂停并输出剩余问题，由用户决定

修复原则：只修复审查发现的具体问题，不做额外重构或格式调整。

每次审查后输出：`[2/3] code-review — PASS / CAUTION / BLOCK（第 K/3 次）`

## Step 3/3: Smart Commit

确认审查通过后，使用 `Skill` 工具调用 `smart-commit`，生成提交信息。

```
Skill({ skill: "smart-commit" })
```

展示 commit message 等待用户确认，确认后执行提交。

完成后输出：`[3/3] smart-commit — 已提交 <short-hash>`

## 异常处理

- `git diff` 为空 → "工作区干净，无需执行流水线"
- simplify 无变更但 code-review 发现问题 → 正常进入修复循环
- 修复循环 3 次未通过 → 暂停并列出剩余问题，等用户指令
- 提交失败 → 报告错误信息，不重试
