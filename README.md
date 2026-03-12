# my-claude

Claude Code CLI를 위한 범용 설정 모듈 모음. 복사해서 바로 사용할 수 있는 규칙, 에이전트, 명령어, 훅을 제공한다.

## 모듈 목록

### Rules (자동 로드 규칙)

| 이름 | 설명 |
|------|------|
| golden-principles | 11개 핵심 원칙 (불변성, TDD, 증거 기반 완료 등) |
| coding-style | 코딩 스타일 규칙 (파일 구조, 에러 처리, Pre-Completion 체크리스트) |
| git-workflow | Git 워크플로우 (Conventional Commits, 파이프라인 정의) |
| agents-v2 | 에이전트 오케스트레이션 규칙, 다중관점 분석 프로토콜 |
| interaction | 비유 우선 설명, 결론 우선 커뮤니케이션 패턴 |
| security | OWASP Top 10 기반 보안 체크리스트 및 대응 프로토콜 |
| testing | TDD 워크플로우 (RED → GREEN → IMPROVE), 커버리지 80%+ |

### Agents (에이전트)

| 이름 | 모델 | 설명 |
|------|:----:|------|
| planner | opus | 구현 계획 수립 (코드 작성 금지, 계획만 수립) |
| code-reviewer | opus | 2단계 코드 리뷰 (스펙 준수 → 코드 품질) |
| verify-agent | sonnet | 검증 파이프라인 (TypeCheck → Lint → Build → Test) |
| architect | opus | 시스템 설계 & 아키텍처 분석 (읽기 전용) |
| build-error-resolver | opus | 빌드/타입 에러 자동 수정 (최소 diff) |
| refactor-cleaner | sonnet | 데드코드 정리 & 코드 통합 |
| security-reviewer | opus | OWASP Top 10 보안 취약점 전문 탐지 |
| tdd-guide | opus | TDD 워크플로우 가이드 (RED → GREEN → IMPROVE) |

### Commands (슬래시 명령어)

| 이름 | 설명 |
|------|------|
| /overview | 프로젝트 구조 분석, docs/overview/ 하위에 인덱스 + 모듈 파일 생성 |
| /plan-from-spec | 기획 문서를 prompt_plan.md로 변환 (입력 검증 5종) |
| /plan | planner 에이전트 호출, prompt_plan.md 저장 (overview 연동) |
| /code-review | code-reviewer 에이전트 호출, 심각도 분류 |
| /verify | verify-agent 스폰, fresh-context 검증 |
| /commit | Conventional Commits 형식 커밋 생성 |
| /auto | 원버튼 자동화 (plan → tdd → review → verify → commit) |
| /build-fix | build-error-resolver로 점진적 빌드 에러 수정 |
| /next-task | prompt_plan.md에서 우선순위 기반 다음 태스크 추천 |
| /orchestrate | Agent Teams 병렬 오케스트레이션 |
| /tdd | tdd-guide 에이전트로 TDD 워크플로우 실행 |
| /verify-loop | verify-agent 반복 스폰 (최대 3회 재시도 + 자동수정) |

### Hooks (이벤트 훅)

| 이름 | 이벤트 | 설명 |
|------|--------|------|
| secret-filter | PostToolUse | 도구 출력에서 시크릿 감지 및 마스킹 (3계층 탐지) |
| security-auto-trigger | PostToolUse (Edit/Write) | 보안 파일 수정 시 /code-review 실행 권장 |
| code-quality-reminder | PostToolUse (Edit/Write) | 코드 파일 수정 후 품질 체크 리마인더 |
| db-guard | PreToolUse (Bash) | 위험 SQL 차단 (DROP, TRUNCATE, WHERE 없는 DELETE) |
| remote-command-guard | PreToolUse (Bash) | 원격 세션에서 위험 명령어 차단 |
| session-wrap-suggest | Stop | 세션 종료 시 /session-wrap 실행 제안 |
| notify | Notification | 타입별(권한요청/유휴/추가입력/완료) Windows 토스트 알림 |

### Skills (멀티스텝 스킬)

| 이름 | 설명 |
|------|------|
| session-wrap | 세션 자동 정리 (4개 서브에이전트 병렬 실행) |
| team-orchestrator | Agent Teams 오케스트레이션 엔진 |

## 설치 및 업데이트

[docs/installation.md](docs/installation.md) 참조.

## 파이프라인

```
기본:  /plan → 구현 → /code-review → /verify → /commit
자동:  /auto (원버튼 자동화)
기획:  /overview → /plan-from-spec → /auto 또는 /orchestrate
```

상세 사용법은 [docs/usage-guide.md](docs/usage-guide.md) 참조.

## 설계 원칙

| 원칙 | 내용 |
|------|------|
| 범용성 | 특정 언어/프레임워크/서비스 종속 금지 |
| Windows 호환 | Git Bash 환경 기준, `/tmp` 대신 `$TEMP` 사용 |
| MCP 무의존 | 외부 MCP 서버 참조 없음 |
| 축소 지향 | 핵심 기능만 추출, 과도한 자동화 배제 |
| 수동 설치 | clone → 복사. 빌드/설치 스크립트 불필요 |

## 변경 이력

[docs/changelog.md](docs/changelog.md) 참조.
