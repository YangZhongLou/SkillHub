# Phase Details

## Phase 1: Plan

**Skill: `/pm`**

### Plan
- Define goal: one sentence. What changes for the user?
- Explicit scope boundary: what's IN, what's NOT
- Task breakdown (<1 day each, clear done condition)
- Estimate: S(hours) / M(1-2d) / L(3-5d) / XL(must split)
- Priority: P0/P1/P2/P3
- Update `docs/plan/current-status.md`

### Review
- Each task <1 day? Binary done criteria?
- NOT-in-scope explicit?
- Riskiest items first?
- **Gate:** Any XL task or fuzzy scope → back to Plan

### Work
- Use `TaskCreate` to build task list
- Output: task list (priority, estimate, exit criteria)

## Phase 2: Architect

**Skill: `/architect`**

### Plan
- Affected files and modules
- API params and return types
- C++ ↔ Rust JSON protocol (field names, types)

### Review
- UE Editor API supports required functionality?
- Architecture conflicts with existing code?
- Correct Commands.cpp file?
- **Gate:** API unsupported or conflict → back to Plan

### Work
- Output: API signatures + data flow + file change manifest

## Phase 3: Implement

**Skill: `/programmer`**

### Plan
- Function skeleton: signatures, param parsing, return format
- Identify the 3 target files

### Review
- Signatures match architecture design?
- JSON naming: C++ camelCase, Rust snakeCase→camelCase?
- `send_command` name matches C++ dispatch?
- All responses have `"success"`? Optional params use `HasField()`?
- No dangling pointers? Correct error format?
- **Gate:** Mismatches found → fix before Work

### Work
- Fill core logic (UE Editor API calls)
- Modify all 3 files:
  1. `<Category>Commands.cpp` — C++ handler
  2. `MCPCommandServer.cpp` — forward decl + dispatch case
  3. `server.rs` — `#[tool]` async fn
- `cd MCP_Server && cargo build`
- Mark each task completed

## Phase 4: Test

**Skill: `/qa-engineer`**

### Plan
- Test cases: required params, optional params, invalid params, edge cases
- Verification method: unit test / cargo build / UE Editor / `/verify`

### Review
- All param combinations covered? Error paths?
- **Gate:** Coverage gaps → back to Plan

### Work
- `cargo build` (must pass) + `cargo test` (if any)
- C++: UE plugin compilation check
- Functional: missing required → error, invalid → error, valid → expected
- UI validation: use `/verify` if needed

## Phase 5: Document

**Skill: `/md-writer`**

### Plan
- Which docs need updating?

### Review
- Doc list complete? Any gaps?
- **Gate:** Missing docs → back to Plan

### Work

| Document | Update |
|----------|--------|
| `README.md` | Tool count, new tool in category table |
| `docs/plan/10-milestones.md` | Phase progress, tool distribution |
| `docs/plan/01-overview.md` | Capability table if category changed |
| `docs/plan/03-directory-structure.md` | If files added/renamed |
| `docs/plan/09-risks.md` | New or mitigated risks |
| `docs/plan/current-status.md` | Current phase, workflow step, blockers |
| `CLAUDE.md` | If workflow or conventions changed |

- `/md-lint` on all .md files

## Phase 6: Commit

**Skill: `/git-flow`**

### Plan
- `git status`, `git diff --stat`

### Review
- Unexpected files? Secrets? Large binaries?
- **Gate:** Suspicious diff → back to Plan

### Work
- `git add` by exact file (never `-A`)
- Commit: `feat: Complete Phase <N> - <Description>`
- `git push` (auto, no confirmation needed)
