---
name: dev-flow
description: UnrealMCP 6-phase development workflow. Each phase: Plan⇄Review(plan)→Work⇄Review(result), dual review gates. Mandatory pipeline: Brainstorm→Architect→Implement→Test→Document→Commit.
metadata:
  type: skill
  trigger: manual
---

# Dev Flow

## Principles

- **Phase order is mandatory.** Never skip a phase. Never skip a sub-step.
- **Sub-step cycle: Plan ⇄ Review(plan) → Work ⇄ Review(result).** Two review gates — plan review loops to Plan, result review loops to Work. Only proceed when both pass.
- **Three files per tool.** `<Category>Commands.cpp` + `MCPCommandServer.cpp` + `server.rs`.
- **JSON camelCase always.** C++ `TEXT("camelCase")`, Rust `json!({"camelCase": v})`.
- **Every response has `"success"`.** Non-negotiable.

## Pipeline

```
每个阶段: Plan ⇄ Review(计划) → 通过 → Work ⇄ Review(结果) → 通过 → 下一阶段

1.Brainstorm ─▶ 2.Architect ─▶ 3.Implement ─▶ 4.Test ─▶ 5.Document ─▶ 6.Commit
      ▲               ▲               ▲            ▲            ▲
      │               │               │            │            │
      └───────────────┴───────────────┴────────────┴────────────┘
        任一 Review 不通过 → 打回对应步骤重做 (Plan 或 Work)
```

| Phase | Skill | Plan | Review | Work | Gate |
|-------|-------|------|--------|------|------|
| 1. Plan | `/pm` | 目标+范围 | 任务拆分是否合理 | 输出任务列表 | <1天/任务，binary done |
| 2. Architect | `/architect` | 影响范围+API 设计 | UE API 是否支持 | 技术方案 | API 可用，无冲突 |
| 3. Implement | `/programmer` | 函数骨架 | 签名+命名+参数 | 实现+cargo build | 3 文件全改，编译通过 |
| 4. Test | `/qa-engineer` | 测试用例列表 | 覆盖完整性 | 执行测试 | 必填/可选/无效全测 |
| 5. Document | `/md-writer` | 确认更新文档 | 范围是否遗漏 | 更新+lint | 7 文档完整 |
| 6. Commit | `/git-flow` | git status+diff | 审查变更范围 | stage+commit+push | 推送成功 |

- 各阶段详细说明: [phases.md](phases.md)
- 新工具代码模板: [tool-template.md](tool-template.md)
