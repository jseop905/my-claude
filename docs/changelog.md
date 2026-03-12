# 변경 이력

## v0.3.1

- settings.json.tmpl 훅 경로를 `bash "$CLAUDE_PROJECT_DIR/..."` 형식으로 변경 (Windows 호환)
- prompt_plan.md 출력 경로를 `docs/plans/prompt_plan.md`로 변경
- secret-filter 로그 경로를 프로젝트 내부(`$CLAUDE_PROJECT_DIR/.claude/security.log`)로 변경
- architect, code-reviewer, security-reviewer, refactor-cleaner에 overview 컨텍스트 로드 단계 추가

## v0.3.0

- Commands 2개 추가 (/overview, /plan-from-spec)
- Hooks 1개 추가 (notify — Notification 이벤트 알림)
- /plan, planner 에이전트에 overview 기반 3단계 탐색 적용
- settings.json.tmpl에 Notification 훅 등록
- catalog.json v0.3.0 (모듈 36개 + 템플릿 3개)

## v0.2.0

- Rules 4개 추가 (agents-v2, interaction, security, testing)
- Agents 5개 추가 (architect, build-error-resolver, refactor-cleaner, security-reviewer, tdd-guide)
- Commands 6개 추가 (/auto, /build-fix, /next-task, /orchestrate, /tdd, /verify-loop)
- Hooks 4개 추가 (code-quality-reminder, db-guard, remote-command-guard, session-wrap-suggest)
- Skills 2개 추가 (session-wrap, team-orchestrator)
- settings.json.tmpl에 PreToolUse/Stop 훅 등록
- catalog.json v0.2.0 (모듈 33개 + 템플릿 3개)

## v0.1.0

- 초기 릴리스. Rules 3 + Agents 3 + Commands 4 + Hooks 2 = 12개 모듈.
- 기본 파이프라인: /plan → /code-review → /verify → /commit
