---
name: git-flow
description: Standard git workflow: branch → commit → rebase → merge to main. Use when starting new work, preparing to merge, or managing branches.
metadata:
  type: skill
  trigger: manual
---

## Workflow

```text
main ←─── rebase ── feature/x ── commits
         (clean history)
```

1. **Branch.** `git checkout -b feature/<name>` from latest `main`.
2. **Commit.** Small, logical commits. Present tense, imperative: "Add auth middleware".
3. **Rebase.** `git fetch origin && git rebase origin/main`. Resolve conflicts per commit.
4. **Merge.** `git checkout main && git merge feature/<name>` (fast-forward only after rebase).
5. **Clean.** `git branch -d feature/<name>` after merge.

## Rules

- **Never commit directly to main.** All work starts on a branch.
- **Rebase, don't merge main into feature.** Keep history linear. `git rebase origin/main`, never `git merge main` into your branch.
- **Squash only if the commit history is noisy.** Otherwise preserve logical commits.
- **Force push only on feature branches.** `git push --force-with-lease`, never on main.
- **Pull before rebase.** `git fetch origin` first. Stale tracking branches cause bad rebases.
- **Resolve conflicts per commit during rebase.** Don't squash conflicts into one giant fixup.

## Branch Naming

| Prefix | Use |
|---|---|
| `feature/` | New functionality |
| `fix/` | Bug fixes |
| `refactor/` | Structural changes, no behavior change |
| `docs/` | Documentation only |
| `chore/` | CI, deps, config |

## Commit Messages

```
<imperative verb> <short description>

<optional body: why, not what>
```

- **50 chars max for subject.** Capitalize, no period.
- **Body wraps at 72 chars.** Explain why, not what the diff shows.
- **Separate subject and body with blank line.**

## Example

```text
git checkout -b feature/user-auth
# ... make changes ...
git add -A
git commit -m "Add user authentication middleware"
# ... more commits ...
git fetch origin
git rebase origin/main
# resolve conflicts if any
git checkout main
git merge feature/user-auth
git branch -d feature/user-auth
```
