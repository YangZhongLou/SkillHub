"""Markdown linter hook — reads file path from stdin JSON, checks rules, outputs report."""
import sys, json, re, os

def lint(filepath):
    if not filepath.endswith('.md'):
        return None

    with open(filepath, encoding='utf-8') as f:
        lines = f.read().split('\n')

    issues = []
    prev_h = 0

    # MD001: skipped heading level
    for i, line in enumerate(lines, 1):
        m = re.match(r'^(#{1,6})\s', line)
        if m:
            level = len(m.group(1))
            if level - prev_h > 1 and prev_h > 0:
                issues.append(f'L{i}: MD001 skipped heading level (h{prev_h} -> h{level})')
            prev_h = level

    # MD009: trailing whitespace
    for i, line in enumerate(lines, 1):
        if line.endswith(' ') or line.endswith('\t'):
            issues.append(f'L{i}: MD009 trailing whitespace')

    # MD012: multiple consecutive blank lines
    for i, line in enumerate(lines, 1):
        if line == '' and i < len(lines) and lines[i] == '':
            issues.append(f'L{i}: MD012 multiple consecutive blank lines')
            break

    # MD040: code block without language tag
    in_block = False
    for i, line in enumerate(lines, 1):
        if line.startswith('```') and not in_block:
            in_block = True
            if line == '```':
                issues.append(f'L{i}: MD040 code block without language tag')
        elif line.startswith('```'):
            in_block = False

    # MD022: heading not surrounded by blank lines
    for i, line in enumerate(lines, 1):
        if re.match(r'^#{1,6}\s', line):
            if i > 1 and lines[i - 2] != '':
                issues.append(f'L{i}: MD022 heading missing blank line above')
            if i < len(lines) and lines[i] != '':
                issues.append(f'L{i}: MD022 heading missing blank line below')

    # MD047: file doesn't end with single newline
    if lines and lines[-1] != '':
        issues.append(f'L{len(lines)}: MD047 file does not end with newline')

    if issues:
        rpt = f'## Lint: {os.path.basename(filepath)}\n\n'
        rpt += f'### Warning ({len(issues)})\n'
        for x in issues:
            rpt += f'- {x}\n'
    else:
        rpt = f'## Lint: {os.path.basename(filepath)} — clean ✓'

    return rpt


def main():
    data = json.load(sys.stdin)
    filepath = data.get('tool_input', {}).get('file_path', '')
    result = lint(filepath)
    if result is None:
        sys.exit(0)
    print(json.dumps({
        'hookSpecificOutput': {
            'hookEventName': 'PostToolUse',
            'additionalContext': result
        }
    }))


if __name__ == '__main__':
    main()
