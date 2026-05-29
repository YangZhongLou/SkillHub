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
- **Blackboard first.** Read `.agent/status/blackboard.md` before every phase. Update it after every phase that changes state.
- **Three files per tool.** `<Category>Commands.cpp` + `MCPCommandServer.cpp` + `server.rs`.
- **JSON camelCase always.** C++ `TEXT("camelCase")`, Rust `json!({"camelCase": v})`.
- **Every response has `"success"`.** Non-negotiable.

## Pipeline

```
每个阶段: 读黑板报 → Plan ⇄ Review(计划) → 通过 → Work ⇄ Review(结果) → 通过 → 更新黑板报 → 下一阶段

1.Brainstorm ─▶ 2.Architect ─▶ 3.Implement ─▶ 4.Test ─▶ 5.Document ─▶ 6.Commit
      ▲               ▲               ▲            ▲            ▲
      │               │               │            │            │
      └───────────────┴───────────────┴────────────┴────────────┘
        任一 Review 不通过 → 打回对应步骤重做 (Plan 或 Work)
```

## Blackboard Protocol

**每个阶段的入口和出口：**

1. **进入阶段前** — 读取 `.agent/status/blackboard.md`，了解当前状态、阻塞项、已有决策
2. **阶段完成后** — 更新 `.agent/status/blackboard.md`：
   - 更新 `updated` 时间戳
   - 更新当前 Phase 的 Status（`in-progress` → `done` 或 `blocked`）
   - 追加 `Recent Changes` 记录
   - 如发现新风险，更新 `Risk Board`

**如 blackboard 不存在**: 自动创建，基于当前对话上下文推断项目状态。

| Phase | Skill | Pre-step | Plan | Review | Work | Post-step | Gate |
|-------|-------|----------|------|--------|------|-----------|------|
| 1. Plan | `/pm` | 读黑板报 | 目标+范围 | 任务拆分合理？ | 输出任务列表 | 更新黑板报 Phase status | <1天/任务，binary done |
| 2. Architect | `/architect` | 读黑板报 | 影响范围+API | UE API 支持？ | 技术方案 | 更新黑板报 Decisions | API 可用，无冲突 |
| 3. Implement | `/programmer` | 读黑板报 | 函数骨架 | 签名+命名+参数 | 实现+编译 | 更新黑板报产出 | 3 文件全改，编译通过 |
| 4. Test | `/qa-engineer` | 读黑板报 | 测试用例 | 覆盖完整性 | 执行测试 | 更新黑板报风险 | 全路径通过 |
| 5. Document | `/md-writer` | 读黑板报 | 确认文档范围 | 遗漏？ | 更新+lint | 更新黑板报 Changes | 文档完整 |
| 6. Commit | `/git-flow` | 读黑板报 | diff 审查 | 变更合理？ | stage+push | 更新黑板报 Final | 推送成功 |

- 各阶段详细说明: [phases.md](phases.md)
- 新工具代码模板: [tool-template.md](tool-template.md)
