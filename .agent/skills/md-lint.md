---
name: md-lint
description: Lint .md files for format issues: heading hierarchy, code blocks, links, filler words, paragraph length. Report by severity.
metadata:
  type: skill
  trigger: manual
---

## Critical

- [ ] Skipped heading level (`##` → `####`)
- [ ] Code block without language tag
- [ ] Broken relative link
- [ ] Heading without blank line above or below

## Warning

- [ ] First non-frontmatter line is not a heading (MD041)
- [ ] Paragraph >4 sentences
- [ ] Fillers: very, just, actually, really, basically, note that
- [ ] Bare link text ("here", "link", raw URL)
- [ ] CAPS for emphasis (use **bold**)
- [ ] Multiple h1 in file
- [ ] Empty section (heading, no content)

## Info

- [ ] List without blank line above or below (MD032)
- [ ] Table missing alignment markers
- [ ] Trailing whitespace

## Output

```text
## Lint: <file>

### Critical (N)
- L<line>: <issue> → <fix>

### Warning (N)
- L<line>: <issue> → <fix>

### Info (N)
- L<line>: <issue> → <fix>

**Summary:** X critical, Y warning, Z info — clean / needs fixes / major rework
```

No issues: `## Lint: <file> — clean ✓`
