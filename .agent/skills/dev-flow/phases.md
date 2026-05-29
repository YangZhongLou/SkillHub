# Phase Details

> **Blackboard Protocol**: Every phase starts with **Read** `.agent/status/blackboard.md` and ends with **Update** `.agent/status/blackboard.md` if state changed.

## Phase 1: Plan

**Skill: `/pm`**

### Pre
- Read blackboard: current milestone, active phase, blockers, past decisions

### Plan
- Define goal: one sentence. What changes for the user?
- Explicit scope boundary: what's IN, what's NOT
- Task breakdown (<1 day each, clear done condition)
- Estimate: S(hours) / M(1-2d) / L(3-5d) / XL(must split)
- Priority: P0/P1/P2/P3

### Review (计划)
- Each task <1 day? Binary done criteria?
- NOT-in-scope explicit?
- Riskiest items first?
- **Gate:** Any XL task or fuzzy scope → back to Plan

### Work
- Use `TaskCreate` to build task list
- Output: task list (priority, estimate, exit criteria)

### Review (结果)
- Task list complete? All items have clear done criteria?
- Estimates reasonable? Dependencies captured?
- PM agrees on priorities?
- **Gate:** Gaps found → back to Work

### Post
- Update blackboard: set Phase 1 status → `done`, add task list summary to `Recent Changes`

## Phase 2: Architect

**Skill: `/architect`**

### Pre
- Read blackboard: task list, scope boundary, any architectural decisions already recorded

### Plan
- Affected files and modules
- API params and return types
- C++ ↔ Rust JSON protocol (field names, types)

### Review (计划)
- UE Editor API supports required functionality?
- Architecture conflicts with existing code?
- Correct Commands.cpp file?
- **Gate:** API unsupported or conflict → back to Plan

### Work
- Output: API signatures + data flow + file change manifest

### Review (结果)
- API signatures complete and self-consistent?
- Data flow covers all edge cases?
- File change manifest lists all affected files?
- **Gate:** Gaps found → back to Work

### Post
- Update blackboard: record API decisions in `Decisions`, update Phase 2 status → `done`

## Phase 3: Implement

**Skill: `/programmer`**

### Pre
- Read blackboard: architecture decisions, API signatures, target files

### Plan
- Function skeleton: signatures, param parsing, return format
- Identify the 3 target files

### Review (计划)
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

### Review (结果)
- `cargo build` passes with no errors or warnings?
- All 3 files modified? No missing dispatch case?
- JSON response format correct (always has `"success"`)?
- Code follows conventions (TEXT() macro, camelCase keys)?
- **Gate:** Issues found → back to Work

### Post
- Update blackboard: record new tools/files in `Recent Changes`, update Phase 3 status → `done`
- If bugs found: add to `Risk Board`

## Phase 4: Test

**Skill: `/qa-engineer`**

### Pre
- Read blackboard: what was implemented, known risks, test coverage expectations

### Plan
- Test cases: required params, optional params, invalid params, edge cases
- Verification method: unit test / cargo build / UE Editor / `/verify`

### Review (计划)
- All param combinations covered? Error paths?
- **Gate:** Coverage gaps → back to Plan

### Work
- `cargo build` (must pass) + `cargo test` (if any)
- C++: UE plugin compilation check
- Functional: missing required → error, invalid → error, valid → expected
- UI validation: use `/verify` if needed

### Review (结果)
- All mock tests pass? Real UE tests pass (where applicable)?
- Error cases produce correct error messages?
- Edge cases handled correctly?
- **Gate:** Failures found → back to Work

### Post
- Update blackboard: record test results, update `Risk Board` with any new findings, update Phase 4 status → `done`

## Phase 5: Document

**Skill: `/md-writer`**

### Pre
- Read blackboard: what changed, what decisions were made, what risks were found

### Plan
- Which docs need updating?

### Review (计划)
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

### Review (结果)
- All 7 docs updated and consistent?
- `/md-lint` passes with no errors?
- No stale references or outdated info?
- **Gate:** Issues found → back to Work

### Post
- Update blackboard: record docs updated in `Recent Changes`, update Phase 5 status → `done`

## Phase 6: Commit

**Skill: `/git-flow`**

### Pre
- Read blackboard: confirm all prior phases `done`, no unrecorded blockers

### Plan
- `git status`, `git diff --stat`

### Review (计划)
- Unexpected files? Secrets? Large binaries?
- **Gate:** Suspicious diff → back to Plan

### Work
- `git add` by exact file (never `-A`)
- Commit: `feat: Complete Phase <N> - <Description>`
- `git push` (auto, no confirmation needed)

### Review (结果)
- Commit pushed successfully? CI passing?
- Commit message follows convention?
- No unintended files in commit?
- **Gate:** Issues found → back to Work

### Post
- Update blackboard: set milestone/phase status → `done`, update `Recent Changes` with commit summary, final `updated` timestamp
