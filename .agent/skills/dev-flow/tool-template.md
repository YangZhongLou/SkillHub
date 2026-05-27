# New Tool Template

Every tool touches exactly 3 files. See `phases.md` Phase 3 for the implementation workflow.

## 1. C++ Handler (`Commands/<Category>Commands.cpp`)

```cpp
FString HandleXxx(const TSharedPtr<FJsonObject>& Params)
{
    TSharedPtr<FJsonObject> Response = MakeShareable(new FJsonObject);
    Response->SetBoolField(TEXT("success"), true);
    // Parse: Params->GetStringField(TEXT("camelCase"))
    // Execute: UE Editor API calls
    FString Out;
    TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&Out);
    FJsonSerializer::Serialize(Response.ToSharedRef(), Writer);
    return Out;
}
```

- Forward declare in MCPCommandServer.cpp (no header files)
- Params use camelCase: `TEXT("actorName")`
- Every response has `"success": true/false`
- Error: `{"success": false, "error": "message"}`

## 2. Register (`MCPCommandServer.cpp`)

```cpp
// Forward declaration (with all others)
FString HandleXxx(const TSharedPtr<FJsonObject>& Params);

// Dispatch case in ProcessCommand() (before final else)
else if (Method == TEXT("method_name"))
{
    ResultStr = HandleXxx(Params);
}
```

## 3. Rust Tool (`server.rs`)

```rust
#[tool(description = "...")]
async fn method_name(
    &self,
    #[tool(param)] param: String,
    #[tool(param)] optional: Option<String>,
) -> String {
    let mut params = json!({"paramName": param});
    if let Some(v) = optional { params["optionalParam"] = json!(v); }

    let mut client = self.client.lock().await;
    match client.send_command("method_name", params).await {
        Ok(response) => {
            if response["success"].as_bool().unwrap_or(false) {
                format!("Success: {}", response["result"])
            } else {
                format!("Failed: {}", response["error"])
            }
        }
        Err(e) => format!("Error: {}", e),
    }
}
```

- Rust fn: `snake_case` / JSON keys: `camelCase`
- `send_command` name must match C++ dispatch exactly
- Always lock client: `let mut client = self.client.lock().await;`

## Quick Reference

| Convention | C++ | Rust |
|------------|-----|------|
| Function names | `HandleXxx()` | `snake_case` |
| JSON keys | `TEXT("camelCase")` | `json!({"camelCase": v})` |
| String literals | `TEXT("...")` | `"..."` |
| Optional params | `HasField()` | `Option<T>` |
| Error return | `{"success":false,"error":"..."}` | `format!("Failed: {}", ...)` |
| Client access | — | `let mut client = self.client.lock().await;` |
