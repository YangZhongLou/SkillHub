# UnrealMCP 真实 UE 环境测试指南

> QA Skill 测试阶段必读。每新增一个 MCP tool，必须通过 Mock + 真实 UE 双层测试。

## 为什么必须真实 UE 环境测试

Mock 测试只能验证 Rust→TCP→JSON 链路，以下问题 **只有真实 UE Editor 才能暴露**：

| 坑 | 症状 | 发现手段 |
|----|------|----------|
| **GameThread 限制** | UE API (SpawnActor, NewLevel, Destroy, etc.) 必须在 GameThread 调用。从 MCP 子线程直接调用 → `Assertion failed: IsInGameThread()` 崩溃 | 真实 UE 编译运行 |
| **API 兼容性** | UE 5.4→5.7 间 `ANY_PACKAGE`→`FindFirstObject`、`bIsArray`→`ContainerType`、`FConsoleObjectVisitor` lambda→delegate 等 API 变化 | 真实 UE 编译 |
| **弹窗死锁** | `NewLevel` 内部调 `SaveDirtyPackages(bPromptUserToSave=true)` → 弹出「是否保存」对话框 → GameThread 阻塞 → MCP 线程永久等待 GameThread → 死锁 | 真实启动 Editor |
| **模块依赖** | 链接时才知道缺少 `BlueprintGraph` 等模块 | 真实 UE 编译链接 |
| **线程调度死锁** | `FFunctionGraphTask::WaitUntilTaskCompletes` 从非 TaskGraph 注册线程调用时会永久阻塞 | 真实 UE 运行 |

## 测试工程

```
D:\Playground\UEMCPTest\
├── UEMCPTest.uproject              # UE 5.7 最小工程
├── Source/UEMCPTest/               # 最小 C++ module（编译插件必须）
│   ├── UEMCPTest.Target.cs
│   ├── UEMCPTestEditor.Target.cs
│   └── UEMCPTest/
│       ├── UEMCPTest.Build.cs
│       ├── UEMCPTest.h
│       └── UEMCPTest.cpp
└── Plugins/
    └── UnrealMCP/                   # ← Junction → repo UnrealPlugin/
                                    #    改源码即时生效，无需复制
```

如果 `D:\Playground\UEMCPTest\` 不存在，测试前自动创建。

## 真实 UE 测试流程

```bash
# 1. 编译插件
UnrealBuildTool.exe UEMCPTestEditor Win64 Development ^
  -project="D:\Playground\UEMCPTest\UEMCPTest.uproject"

# 2. 启动 UE Editor — 必须是窗口化！
#    最小化会导致 Slate 事件循环异常，AsyncTask 无法被 GameThread 处理
UnrealEditor.exe D:\Playground\UEMCPTest\UEMCPTest.uproject

# 3. 等待 TCP 13377 就绪后跑测试
cargo test --test test_real_ue -- --ignored --nocapture --test-threads=1

# 4. 验证通过后关闭编辑器
```

## 线程派发模式（C++ 侧）

所有写操作的 C++ Handler **必须** 用此模式包装 GameThread API：

```cpp
#include "Async/Async.h"

AActor* SpawnedActor = nullptr;
FEvent* DoneEvent = FPlatformProcess::GetSynchEventFromPool();

AsyncTask(ENamedThreads::GameThread, [&]()
{
    // 所有 UE 写 API 调用
    SpawnedActor = World->SpawnActor<AActor>(...);
    DoneEvent->Trigger();
});

DoneEvent->Wait();
FPlatformProcess::ReturnSynchEventToPool(DoneEvent);
```

## 防弹窗模式

调用会内部弹窗的 API（如 `NewLevel`）前，先保存所有脏包：

```cpp
// 在 GameThread lambda 内，API 调用之前
FEditorFileUtils::SaveDirtyPackages(false, true, true);
// 以 bPromptUserToSave=false 保存 → NewLevel 内部不再弹窗
ULevelEditorSubsystem* LS = GEditor->GetEditorSubsystem<ULevelEditorSubsystem>();
LS->NewLevel(Path);
```

## UE 5.4→5.7 API 适配清单

| 旧 API (5.4) | 新 API (5.7) | 影响范围 |
|--------------|-------------|----------|
| `FindObject<T>(ANY_PACKAGE, *Name)` | `FindFirstObject<T>(*Name)` | ActorCommands, BlueprintCommands |
| `FEdGraphPinType::bIsArray` | `ContainerType = EPinContainerType::Array` | BlueprintCommands |
| `FBlueprintEditorUtils::AddFunctionGraph(..., nullptr)` | `AddFunctionGraph(..., (UFunction*)nullptr)` | BlueprintCommands |
| 直接传 lambda 给 `ForEachConsoleObjectThatStartsWith` | 先创建 `FConsoleObjectVisitor` delegate，再 `BindLambda` | EditorCommands |
| Plugin 依赖 `Kismet` 不够 | 需额外添加 `BlueprintGraph` 模块 | UnrealMCP.Build.cs |

## 测试文件约定

```rust
// tests/test_real_ue.rs — 所有测试 #[ignore]，手动跑
//
// 每个新 tool 至少 1 个测试函数
// 函数名: test_real_ue_<tool_name>
// 用时间戳生成唯一名称避免冲突
// 测试完必须清理（spawn → destroy）

#[tokio::test]
#[ignore]
async fn test_real_ue_<tool_name>() {
    let mut client = UnrealClient::new("127.0.0.1:13377");
    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH).unwrap().as_secs();
    // ...
}
```

## 常见陷阱

1. **并行测试会互相阻塞** — MCP Server 单线程处理连接。必须 `--test-threads=1`
2. **最小化窗口会死锁** — Slate 事件循环异常，GameThread 不处理 AsyncTask
3. **关卡残留** — 上轮测试崩溃后编辑器可能处于坏状态，务必 `Stop-Process -Force` 并清 `Saved/`
4. **CrashReportClient 锁 DLL** — 编辑器崩溃后该进程保持 DLL 文件句柄，导致下次链接失败。必须同时杀掉
5. **端口 TIME_WAIT** — 杀编辑器后等 3-5 秒等端口释放
