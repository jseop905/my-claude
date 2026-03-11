# 아키텍처 노트

## 모듈 간 관계

```
[v1 Core Pipeline]
rules/golden-principles.md ──→ 모든 에이전트/명령어의 행동 기준
rules/coding-style.md      ──→ code-reviewer가 리뷰 시 참조
rules/git-workflow.md       ──→ /commit이 커밋 포맷 참조

/plan ──→ planner 에이전트 호출 ──→ prompt_plan.md 저장
/code-review ──→ code-reviewer 에이전트 호출 ──→ 판정 출력
/verify ──→ verify-agent 서브에이전트 스폰 ──→ 검증 결과 반환
/commit ──→ git diff 분석 ──→ 커밋 메시지 생성 ──→ git commit

hooks/secret-filter.sh ──→ settings.json에 등록 ──→ PostToolUse마다 실행
hooks/security-auto-trigger.sh ──→ Edit/Write마다 보안 파일 체크

[v2 Extended Pipeline]
rules/agents-v2.md     ──→ 에이전트 간 오케스트레이션 규칙
rules/security.md      ──→ security-reviewer가 참조
rules/testing.md       ──→ tdd-guide가 참조
rules/interaction.md   ──→ 모든 에이전트의 커뮤니케이션 기준

/auto ──→ /plan → /tdd → /code-review → /verify-loop → /commit (풀 파이프라인)
/tdd ──→ tdd-guide 에이전트 호출 ──→ RED → GREEN → REFACTOR
/build-fix ──→ build-error-resolver 호출 ──→ 점진적 에러 수정
/next-task ──→ prompt_plan.md 파싱 ──→ 다음 태스크 추천
/orchestrate ──→ team-orchestrator 스킬 ──→ Agent Teams 병렬 실행
/quick-commit ──→ 간단 변경 빠른 커밋
/verify-loop ──→ verify-agent 반복 스폰 ──→ 3회 재시도 + 자동수정

hooks/code-quality-reminder.sh ──→ Edit/Write 후 품질 체크 알림
hooks/db-guard.sh ──→ Bash 실행 전 위험 SQL 차단
hooks/remote-command-guard.sh ──→ 원격 세션 위험 명령어 차단
hooks/session-wrap-suggest.sh ──→ 세션 종료 시 /session-wrap 제안

skills/session-wrap ──→ 세션 종료 시 4개 서브에이전트 병렬 실행
skills/team-orchestrator ──→ /orchestrate가 호출하는 엔진
```

## 설계 제외 항목

| 제외 항목 | 이유 |
|-----------|------|
| 키워드 자동화 | 명령어(`/xxx`)로 대체. 오탐 위험. |
| 특정 스택 종속 | Supabase, Next.js 등 특정 서비스 의존 제거 |
| MCP 서버 의존 | context7, memory 등은 사용자가 별도 설치 |
| 크로스 플랫폼 | Windows 전용. macOS/Linux는 추후 |
| Self-Evolution | 에이전트 자가 학습은 복잡도 대비 효과 불확실 |

## Phase 3 로드맵

- npx CLI (대화형 모듈 선택 + 자동 복사)
- 프리셋 시스템 (minimal, standard, full)
- 알림 훅 (OS notification)
