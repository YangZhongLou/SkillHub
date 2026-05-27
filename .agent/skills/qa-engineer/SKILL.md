---
name: qa-engineer
description: Invoke when planning tests, designing test cases, or investigating quality issues.
metadata:
  type: skill
  trigger: manual
---

# QA Engineer

## Test Strategy

- **Risk-driven.** Test the most dangerous things first. Money, data loss, auth, privacy.
- **Pyramid, not ice cream.** Unit > Integration > E2E. 70/20/10 split.
- **Shift left.** Find bugs at the lowest-cost stage. Review designs, not just code.
- **Traceability.** Every test maps to a requirement or a known failure mode.

## Test Case Design

| Technique | When | Example |
| --- | --- | --- |
| Boundary value | Numeric inputs | `min-1`, `min`, `max`, `max+1` |
| Equivalence class | Partitionable input | Valid email formats → one test covers the class |
| Pairwise | Many interacting options | 5 fields × 3 values → don't test all 243 combos |
| Decision table | Business rules | Permissions matrix: role × action |
| State transition | Workflows, status machines | Order: pending → paid → shipped → delivered |
| Error guessing | Experience-based | Unicode in names, negative amounts, concurrent edits |

## Test Types

### Unit
- Fast, isolated, deterministic. One concept per test.
- `method_scenario_expected` naming. AAA structure.
- Mock adapters, not third-party code. Wrap external deps first.

### Integration
- Test real wiring between modules. Real database, real queue, real HTTP (or in-memory fakes).
- Focus on: serialization, schema mismatches, timeout/retry, partial failures.
- One happy path + each failure mode.

### E2E
- Critical user journeys only: signup, login, checkout, payment, delete account.
- Page object pattern for UI. API-level E2E when UI is unstable.
- Assert on user-visible outcomes, not DOM structure.

### Regression
- Record every production bug as a regression test. Bug → test → fix → verify.
- Full suite before every release. Smoke subset for every commit.

### Performance (when applicable)
- Set thresholds: p50 < 200ms, p99 < 1s. Fail the build if exceeded.
- Ramp tests, not spike. Find the breaking point, not just "it's fast."

## Bug Report

```text
Severity: <critical/high/medium/low>
Title: <component> <symptom> when <condition>

Steps:
1. <precise action>
2. <precise action>

Expected: <what should happen>
Actual:   <what actually happens>
Notes:    <env, branch, commit, logs, screenshots>
```

No "it doesn't work." No "sometimes." Be specific enough that anyone can reproduce.

## Quality Gates

- [ ] All tests pass (unit, integration, e2e smoke)
- [ ] No critical or high-severity open bugs
- [ ] Regression suite green
- [ ] New code has corresponding tests
- [ ] Coverage on changed files ≥ baseline

---

## UnrealMCP 专项规则 (MUST)

### 两层测试体系

每个新 MCP tool **必须通过两层测试**，缺一不可：

| 层 | 位置 | 说明 | Gate |
|----|------|------|------|
| **Mock 集成测试** | `MCP_Server/tests/test_unreal_client.rs` | 用 `mock_unreal_server.rs` 模拟 UE 端 TCP 响应，验证 Rust→JSON 链路。每个新 tool 追加 1 个测试函数。 | 全部通过 |
| **真实 UE 环境测试** | `MCP_Server/tests/test_real_ue.rs` | 编译 UnrealMCP 插件为 DLL，启动真实 `UnrealEditor.exe`（窗口化），Rust `UnrealClient` 直连 `127.0.0.1:13377`，验证 Rust→TCP→C++→UE API 完整链路。 | `#[ignore]` 标记，**每 tool 必须手跑通过** |

### 真实 UE 测试流程

```
1. 确保测试工程存在（不存在则自动创建）
   → D:\Playground\UEMCPTest\UEMCPTest.uproject (UE 5.7)
   → Plugins/UnrealMCP 为 Junction → repo UnrealPlugin

2. 编译插件
   UnrealBuildTool.exe UEMCPTestEditor Win64 Development -project="D:\Playground\UEMCPTest\UEMCPTest.uproject"

3. 启动 UE Editor（非最小化！最小化会导致 Slate 事件阻塞死锁）
   UnrealEditor.exe D:\Playground\UEMCPTest\UEMCPTest.uproject

4. 等待 TCP:13377 就绪后跑测试
   cargo test --test test_real_ue -- --ignored --nocapture

5. 验证通过后关闭编辑器
```

### 为什么必须真机测试

- **GameThread 限制** — UE API (NewLevel, SaveLevel, SpawnActor 等) 只能在 GameThread 调用。MCP Server 运行在独立线程，C++ 代码能不能正确处理线程派发，Mock 测不出来。
- **API 兼容性** — 不同 UE 版本 API 不同（ANY_PACKAGE→FindFirstObject, bIsArray→ContainerType, delegate vs lambda 等）。Mock 不涉及真实 UE 编译。
- **弹窗死锁** — 某些 UE API 内部会弹出保存/确认对话框，导致 GameThread 阻塞死锁。只有真实启动 Editor 才能发现。
- **编译才是真实 gate** — Mock 测试只验证了 Rust 侧 TCP 通信，C++ 侧代码只有在 UE Editor 中编译并运行才能确认正确。

### 真实测试模板

```rust
// tests/test_real_ue.rs
#[tokio::test]
#[ignore]  // 必须标记 #[ignore]，不在 CI 自动运行
async fn test_real_ue_<tool_name>() {
    let mut client = UnrealClient::new("127.0.0.1:13377");

    let response = client.send_command("<method>", json!({
        "<param>": "<value>"
    })).await.unwrap();

    assert_eq!(response["success"], true);
    // ... further assertions
}
```

## Anti-Patterns

- **Testing the framework.** Don't verify that libraries work.
- **Flaky tests.** Fix them immediately or quarantine. A flaky test is worse than no test.
- **Test duplication.** Same behavior tested at multiple layers → pick the lowest layer that covers it.
- **Over-mocking.** If your test is 80% mocks, it tests mocks, not code.
- **Ice cream cone.** More E2E than unit tests. Slow, flaky, hard to debug.
