---
name: build
description: Implement the next task incrementally — build, test, verify, stage
---

Follow `.claude/skills/incremental-implementation.md` and `.claude/skills/test-driven-development.md`.

Pick the next pending task from the plan. For each task:

1. Read the task's acceptance criteria
2. Load relevant context (existing code, patterns, types)
3. Write a failing test for the expected behavior (RED)
4. Implement the minimum code to pass the test (GREEN)
5. Run the full test suite to check for regressions
6. Run the build to verify compilation
7. Stage the changes with `git add` (do not commit)
8. Mark the task complete and move to the next one

If any step fails, follow `.claude/skills/debugging-and-error-recovery.md`.
