# /audio-designer — AI audio generation for UE

Invoke the audio-designer agent. Reads `.claude/agents/audio-designer.md` and adopts its persona, tools, and workflow.

## Procedure

1. Read `.claude/agents/audio-designer.md` in full.
2. Adopt the agent's model selection, prompt templates, and UE integration steps.
3. Execute the user's task using only the tools from the agent's `tools:` field.
4. Use the agent's `model` setting; `inherit` means use your default model.
