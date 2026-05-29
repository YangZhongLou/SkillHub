"""Markdown linter hook — calls markdownlint-cli2, formats output for Claude Code."""
import re, sys, json, os, subprocess

data = json.load(sys.stdin)
filepath = data.get('tool_input', {}).get('file_path', '')

if not filepath.endswith('.md'):
    sys.exit(0)

result = subprocess.run(
    f'npx markdownlint-cli2 "{filepath}" --no-banner --no-progress',
    capture_output=True, text=True, timeout=30, shell=True
)

output = result.stderr.strip() if result.stderr else ''
if result.returncode == 0 or not output:
    rpt = f'## Lint: {os.path.basename(filepath)} — clean ✓'
else:
    basename = os.path.basename(filepath)
    lines = []
    for line in output.split('\n'):
        # Replace any path variant ending with the filename
        line = re.sub(r'\S*' + re.escape(basename), basename, line)
        lines.append(line)
    rpt = f'## Lint: {os.path.basename(filepath)}\n\n{chr(10).join(lines)}'

print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': rpt
    }
}))
