# my-claude Phase 1 구현 체크리스트

> design.md + claude-forge-extract 기반 작업 순서.
> 각 단계는 이전 단계에 의존하므로 순서대로 진행.
>
> **작업 규칙**:
> 1. 각 Step 완료 시 반드시 이 체크리스트를 업데이트할 것. 체크 표시(`[x]`)와 함께 어떻게 반영했는지 간략히 기록한다.
> 2. 각 Step 완료 후 작성된 파일을 사용자와 함께 리뷰한다. 리뷰 통과 후 다음 Step으로 진행.

---

## Step 0: 프로젝트 초기화

- [x] 저장소 디렉터리 구조 생성 — `modules/{agents,commands,hooks,rules,skills}`, `templates/` 생성. 각 디렉터리에 `.gitkeep` 추가.
  ```
  modules/agents/
  modules/commands/
  modules/hooks/
  modules/rules/
  modules/skills/       # Phase 2용 placeholder
  templates/
  docs/
  ```
- [x] `.gitignore` 작성 — OS(`.DS_Store`, `Thumbs.db`), 에디터(`.vscode/`, `.idea/`), 임시파일, `claude-forge-extract/` 제외
- [x] git 초기화 — 기존 `.git/` 사용 (이미 초기화됨)

---

## Step 1: Rules 작성

> 모든 에이전트/명령어의 행동 기준. 가장 먼저 작성.
> 참고: `claude-forge-extract/rules/`

### 1-1. golden-principles.md
- [x] claude-forge `rules/golden-principles.md` (104줄) 기반 작성
- [x] 11개 원칙 정의 (불변성, TDD, HARD-GATE 등)
- [x] anti-rationalization 테이블 포함
- [x] 특정 스택 종속 제거 — `process.env` → "환경 변수", `zod` → "스키마 기반 검증"으로 범용화
- [x] Windows 환경 고려사항 반영 — OS 특정 내용 없이 범용적으로 작성 (훅에서 별도 대응)

### 1-2. coding-style.md
- [x] claude-forge `rules/coding-style.md` (70줄) 기반 작성
- [x] 불변성, 파일 구조, 에러 처리, 입력 검증 규칙
- [x] 코드 예시는 범용적으로 — JS 전용 예시를 Python 예시로 교체, 언어별 도구 목록 제공
- [x] pre-completion 체크리스트 포함 (8항목)

### 1-3. git-workflow.md
- [x] claude-forge `rules/git-workflow-v2.md` (63줄) 기반 작성
- [x] Conventional Commits 포맷 정의 — type 테이블 + 규칙 + 예시
- [x] 워크플로우: /plan → 구현(TDD) → /code-review → /commit
- [x] PR 작성 가이드 — 4단계 절차

### Step 1 완료 검증
- [x] 3개 파일 모두 `modules/rules/`에 위치
- [x] 특정 서비스(Supabase, Next.js 등) 종속 없음 — grep 검증 통과
- [x] 한국어/영어 혼용 정리 완료 — 한국어 설명 + 영어 키워드/코드 방식 통일

---

## Step 2: Agents 작성

> XML 프롬프트 패턴(`<Agent_Prompt>`) 사용. MCP 의존성 제거.
> 참고: `claude-forge-extract/agents/`

### 2-1. planner.md
- [x] claude-forge `agents/planner.md` (134줄) 기반 작성
- [x] YAML frontmatter: name, description, tools(Read/Grep/Glob), model(opus), color(blue)
- [x] Role: 구현 계획 수립만 (코드 작성 절대 금지) — Write/Edit 도구 명시적 금지
- [x] 의도 분류 → 코드베이스 조사(Read/Grep/Glob 직접) → 질문(한 번에 하나) → 3-6단계 계획
- [x] 출력: `prompt_plan.md`에 저장 — Final_Checklist에 명시
- [x] MCP 도구 참조 제거 — sequential-thinking, context7, AskUserQuestion 제거
- [x] `<Agent_Prompt>` XML 구조 적용 — Role/Constraints/Investigation_Protocol/Output_Format/Failure_Modes/Final_Checklist

### 2-2. code-reviewer.md
- [x] claude-forge `agents/code-reviewer.md` (143줄) 기반 작성
- [x] YAML frontmatter: tools(Read/Grep/Glob/Bash), model(opus), color(blue)
- [x] 2단계 리뷰: Stage 1(스펙 준수) → Stage 2(코드 품질)
- [x] 심각도 등급: CRITICAL / HIGH / MEDIUM / LOW
- [x] CRITICAL/HIGH 시 커밋 차단 — Approval Criteria에 명시
- [x] 보안 체크: 하드코딩 시크릿, SQL 인젝션, XSS, 입력 검증, path traversal, auth bypass
- [x] `<Agent_Prompt>` XML 구조 적용 — Review_Checklist 섹션 추가 (React 특정 항목 제거)

### 2-3. verify-agent.md
- [x] claude-forge `agents/verify-agent.md` (236줄) 기반 작성
- [x] YAML frontmatter: tools(Read/Write/Edit/Bash/Grep/Glob), model(sonnet), color(cyan)
- [x] 검증 파이프라인: TypeCheck → Lint → Build → Test
- [x] 에러 분류: Fixable vs Non-Fixable — 각각 구체적 예시 포함
- [x] 동작 모드: loop(기본) / once / extract / coverage
- [x] 서브에이전트로 스폰되는 구조 — fresh-context, parent context 접근 금지 명시
- [x] `<Agent_Prompt>` XML 구조 적용 — handoff.md 의존 제거, 다중 언어 파이프라인 (Node/Python/Go/Rust)

### Step 2 완료 검증
- [x] 3개 파일 모두 `modules/agents/`에 위치
- [x] 모든 에이전트에서 MCP 서버 의존성 없음 — grep 검증 통과
- [x] YAML frontmatter 형식 통일 — name, description, tools, model, color 순서

---

## Step 3: Commands 작성

> 사용자가 `/명령어`로 직접 호출하는 슬래시 명령어.
> 참고: `claude-forge-extract/commands/`

### 3-1. plan.md
- [x] claude-forge `commands/plan.md` (132줄) 기반 작성 — 약 45줄로 축소
- [x] planner 에이전트 호출 로직 — 5단계 실행 절차 정의
- [x] 사용자 "yes" 확인 전까지 코드 작성 금지 — 핵심 규칙에 명시
- [x] 확인 후 `prompt_plan.md`에 계획 저장 — 아카이브 정책 포함
- [x] `/tdd`, `/auto` 핸드오프 참조 제거 — 다음 단계를 `/code-review`, `/commit`으로 변경

### 3-2. code-review.md
- [x] claude-forge `commands/code-review.md` (53줄) 기반 작성
- [x] code-reviewer 에이전트 호출 — Stage 1/Stage 2 절차 명시
- [x] `git diff` 기반 변경 파일 수집
- [x] 심각도별 이슈 분류 + 판정 출력 (APPROVE / REQUEST CHANGES / COMMENT)

### 3-3. commit.md
- [x] claude-forge `commands/commit-push-pr.md` (766줄) 기반 **축소** 작성 — 약 100줄
- [x] **커밋만 담당** (push/PR/merge는 제외) — 6단계: 수집→사전체크→보안→메시지→커밋→결과
- [x] 변경 파일 수집 → Conventional Commits 메시지 자동 생성 → 스테이징 → 커밋
- [x] 보안 검증 (시크릿 하드코딩 체크) 유지 — 5개 패턴 (API키, GitHub, Slack, 비밀번호, 개인키)
- [x] MCP 알림(Gmail, Calendar, N8N) 제거
- [x] CWE 매핑 등 과도한 보안 파이프라인 축소 — 시크릿 패턴 매칭만 유지

### Step 3 완료 검증
- [x] 3개 파일 모두 `modules/commands/`에 위치
- [x] `/plan → /code-review → /commit` 파이프라인 — 각 명령어의 "다음 단계"에서 연결
- [x] 각 명령어에 YAML frontmatter(description) 포함

---

## Step 4: Hooks 작성

> bash 래퍼 + Python 스크립트. Windows(Git Bash) 환경 대응 필수.
> 참고: `claude-forge-extract/hooks/`

### 4-1. secret-filter.sh
- [x] claude-forge `hooks/output-secret-filter.sh` (200줄) 기반 작성
- [x] 이벤트: PostToolUse (전체)
- [x] 3계층 탐지: Layer 1(원본) → Layer 2(Base64) → Layer 3(URL 디코딩)
- [x] 탐지 패턴: sk-, AKIA, ghp_/ghs_/gho_/ghu_/github_pat_, xoxb-/xoxp-, Bearer, glpat-, npm_ 등 12종+
- [x] 마스킹: `앞8자***MASKED***뒤4자` (16자 초과) / `앞4자***MASKED***` (16자 이하)
- [x] Windows 대응: `python3` / `python` / `py` 순서로 자동 감지
- [x] `/tmp/` → `$HOME/.claude/security.log` 로그 경로 사용, `/tmp` 참조 완전 제거
- [x] 원격 세션 체크(`OPENCLAW_SESSION_ID`) 제거 → 항상 실행

### 4-2. security-auto-trigger.sh
- [x] claude-forge `hooks/security-auto-trigger.sh` (91줄) 기반 작성
- [x] 이벤트: PostToolUse (Edit, Write)
- [x] 보안 파일 패턴 감지 — 18개 패턴 (auth, login, session, .env, migration, api/, crypto 등)
- [x] 세션당 같은 파일에 대해 1회만 알림 — marker 파일 방식 유지
- [x] `/code-review` 실행 권장 메시지 출력 (원본의 `/security-review` → `/code-review`로 변경)
- [x] 비차단 (항상 exit 0)
- [x] Windows 대응: Python 자동 감지, `$TEMP`/`$TMP`/`$HOME/.claude/tmp` 폴백 체인

### Step 4 완료 검증
- [x] 2개 파일 모두 `modules/hooks/`에 위치
- [x] Git Bash `bash -n` 구문 검사 통과
- [x] Python 스크립트 인라인 방식 채택 (heredoc으로 bash 내 포함, 별도 .py 불필요)

---

## Step 5: Templates 작성

> 사용자 프로젝트에 복사할 템플릿 파일들.

### 5-1. settings.json.tmpl
- [x] claude-forge `settings.json` (238줄) 기반 **축소** 작성 — 약 60줄
- [x] permissions.allow: 핵심 도구 16개 (Bash, Read, Write, Edit, Glob, Grep, Skill, WebSearch, Task 관련, AskUserQuestion)
- [x] permissions.deny: 위험 명령어 24개 (rm -rf, sudo, force push, eval 등)
- [x] hooks 등록: secret-filter.sh (PostToolUse 전체), security-auto-trigger.sh (PostToolUse Edit|Write)
- [x] MCP 관련 설정 제거 — allow/hooks에서 mcp__ 참조 전부 제거
- [x] 실험적 기능 플래그 제거 — env 섹션 자체 제거
- [x] 커스터마이징: 유효한 JSON 그대로 복사 → `.json`으로 이름 변경하면 즉시 동작

### 5-2. CLAUDE.md.tmpl
- [x] design.md §7 기반 작성
- [x] 플레이스홀더: `{프로젝트명}`, `{기술 스택}`, `{아키텍처}`, `{OS}`, `{셸}`, `{패키지 매니저}` 등
- [x] 주요 명령어 섹션 (빌드, 테스트, 린트) + 디렉터리 구조 + 코딩 컨벤션 + 환경 참고
- [x] 작업 규칙 (/plan → /code-review → /commit) + 컨텍스트 50% 규칙
- [x] 38줄 (60줄 이하 ✓)

### Step 5 완료 검증
- [x] 2개 파일 모두 `templates/`에 위치
- [x] settings.json.tmpl이 유효한 JSON 형식 — `python -m json.tool` 통과
- [x] CLAUDE.md.tmpl 38줄 (60줄 이하)

---

## Step 6: catalog.json 작성

- [x] 전체 모듈 메타데이터 정의 — 11개 모듈 (rule 3, agent 3, command 3, hook 2)
- [x] 각 모듈: id, type, name, description, path, tags — design.md §4 스키마 준수
- [x] type별 정리: rule, agent, command, hook — 타입 순서대로 배치
- [x] tags: core, planning, security, quality — 4종 태그 활용
- [x] JSON 유효성 검증 — `python -m json.tool` 통과

---

## Step 7: README.md 작성

- [x] 프로젝트 소개 (한 줄) — "Claude Code CLI를 위한 범용 설정 모듈 모음"
- [x] 모듈 목록 테이블 (타입, 이름, 설명) — 11개 모듈, 태그 컬럼 추가
- [x] 설치 방법 (clone → 복사) — 4단계: 클론 → 모듈 복사 → 설정 적용 → 훅 권한
- [x] 핵심 파이프라인 설명 (`/plan → /code-review → /commit`) — 다이어그램 + 4단계 설명
- [x] 디렉터리 구조 트리 — 전체 구조 표시
- [x] 업데이트 방법 — git pull + 재복사, settings.json diff 확인 권장
- [x] 라이선스 — MIT

---

## Step 8: 통합 테스트

### 자동 검증 (스크립트)
- [x] 테스트 프로젝트 생성 (임시 디렉터리) — mktemp으로 생성 후 정리
- [x] 모듈 복사 (rules + agents + commands + hooks) — 구조 검증 통과, 11개 모듈 확인
- [x] settings.json.tmpl → settings.json 복사 — JSON 유효성 통과
- [x] CLAUDE.md.tmpl → CLAUDE.md 복사 — 파일 존재 확인
- [x] YAML frontmatter 검증 — agents 3개, commands 3개 모두 통과
- [x] MCP 참조 없음 검증 — grep 결과 0건
- [x] hooks 경로 일치 검증 — settings.json에 등록된 2개 훅 파일 모두 존재

### 수동 검증 (별도 프로젝트에서 Claude Code 실행)
- [x] Claude Code 실행하여 규칙 로딩 확인
- [x] `/plan` 명령어 동작 확인
- [x] `/code-review` 명령어 동작 확인
- [x] `/commit` 명령어 동작 확인
- [ ] 훅 실행 확인 (secret-filter, security-auto-trigger) — 추후 확인 예정

---

## Step 9: 최종 정리

- [x] 각 모듈 파일의 일관성 검토 (포맷, 용어, 스타일) — 전 항목 OK (frontmatter, XML 구조, 명령어/에이전트 이름 통일)
- [x] 불필요한 claude-forge 잔재 제거 — forge/OPENCLAW/MCP/특정 스택 참조 0건
- [x] design.md와 실제 구현 간 차이 확인 및 문서 업데이트 — `/verify` 명령어 누락 발견 → 추가 구현 완료
- [ ] 초기 커밋 및 태그 (v0.1.0)

---

## 작업 순서 요약

```
Step 0  저장소 초기화
  ↓
Step 1  Rules (행동 기준 — 다른 모든 모듈이 참조)
  ↓
Step 2  Agents (Rules 기반으로 동작하는 에이전트)
  ↓
Step 3  Commands (에이전트를 호출하는 슬래시 명령어)
  ↓
Step 4  Hooks (보안 자동화)
  ↓
Step 5  Templates (settings.json + CLAUDE.md)
  ↓
Step 6  catalog.json (모듈 메타데이터)
  ↓
Step 7  README.md (사용자 가이드)
  ↓
Step 8  통합 테스트
  ↓
Step 9  최종 정리 + 릴리스
```

---

## 핵심 설계 원칙 (작업 중 항상 참고)

| 원칙 | 내용 |
|------|------|
| 범용성 | 특정 언어/프레임워크/서비스 종속 금지 |
| Windows 전용 | Git Bash 환경 기준, `/tmp` → `$TEMP` |
| MCP 무의존 | context7, memory 등 MCP 서버 참조 제거 |
| 축소 지향 | claude-forge의 과도한 부분은 핵심만 추출 |
| 수동 설치 | clone → 복사. 빌드/설치 스크립트 불필요 |
