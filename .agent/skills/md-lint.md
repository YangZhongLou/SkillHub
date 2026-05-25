---
name: md-lint
description: Lint markdown files for formatting issues. Checks heading hierarchy, code block language tags, link quality, filler words, paragraph length, and structural problems. Use when reviewing .md files for quality.
metadata:
  type: skill
  trigger: manual
---

Check the given `.md` file(s) for formatting issues. Report each issue with file path, line number, and a one-line fix suggestion. Group by severity.

## Checklist

### Critical (must fix)
- [ ] **Skipped heading level.** e.g. `##` followed by `####` — no `###` in between
- [ ] **Missing code block language.** ` ``` ` without a language tag
- [ ] **Broken relative link.** Link target file doesn't exist in the repo

### Warning (should fix)
- [ ] **Long paragraph.** >4 sentences in a single paragraph
- [ ] **Filler words.** "very", "just", "actually", "really", "basically", "note that", "it is worth mentioning"
- [ ] **Bare link.** Link text is "here", "link", "this", or the raw URL itself
- [ ] **CAPS emphasis.** ALL CAPS used for emphasis instead of **bold**
- [ ] **Multiple h1.** More than one `# ` heading in a single file
- [ ] **Empty section.** A heading with no content before the next heading

### Info (consider improving)
- [ ] **Nested list without blank line.** Lists nested without a blank line above may render incorrectly
- [ ] **Table missing alignment.** Tables without `:--` alignment markers
- [ ] **Trailing whitespace.** Lines ending with spaces or tabs

## Output Format

```text
## Lint Report: <filename>

### Critical (N)
- L<line>: <issue> → <fix>

### Warning (N)
- L<line>: <issue> → <fix>

### Info (N)
- L<line>: <issue> → <fix>

**Summary:** X critical, Y warning, Z info — <verdict: clean / needs fixes / needs major rework>
```

If no issues found, report: `## Lint Report: <filename> — clean ✓`
