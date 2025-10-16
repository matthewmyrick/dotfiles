---
description: "Update or create CLAUDE.md file based on codebase analysis"
argument-hint: "[optional: dependencies|architecture|commands|all]"
---

First, check if a CLAUDE.md file exists in the current repository root.

**If CLAUDE.md does NOT exist:**
- Run the `/init` command to create an initial CLAUDE.md file
- Then proceed with any additional analysis based on the provided arguments

**If CLAUDE.md exists:**
- Check when it was last modified
- Analyze the current codebase for changes made after that date
- Update the CLAUDE.md file to reflect the current state

**Focus areas based on arguments:**
- If "dependencies" specified: Focus on package.json, requirements.txt, go.mod/go.sum, or similar dependency files
- If "architecture" specified: Focus on structural and architectural changes
- If "commands" specified: Focus on new scripts, build processes, or development commands
- If "all" or no argument: Comprehensive analysis of all changes

$ARGUMENTS

Always preserve the existing CLAUDE.md structure and format when updating. Ensure the file accurately reflects the current state of the repository for future Claude Code instances.
