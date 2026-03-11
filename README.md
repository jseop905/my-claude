# my-claude

Claude Code CLI를 위한 범용 설정 모듈 모음. 복사해서 바로 사용할 수 있는 규칙, 에이전트, 명령어, 훅을 제공한다.

## 모듈 목록

### Rules (자동 로드 규칙)

| 이름 | 설명 | 버전 |
|------|------|:----:|
| golden-principles | 11개 핵심 원칙 (불변성, TDD, 증거 기반 완료 등) | v1 |
| coding-style | 코딩 스타일 규칙 (파일 구조, 에러 처리, Pre-Completion 체크리스트) | v1 |
| git-workflow | Git 워크플로우 (Conventional Commits, 파이프라인 정의) | v1 |
| agents-v2 | 에이전트 오케스트레이션 규칙, 다중관점 분석 프로토콜 | v2 |
| interaction | 비유 우선 설명, 결론 우선 커뮤니케이션 패턴 | v2 |
| security | OWASP Top 10 기반 보안 체크리스트 및 대응 프로토콜 | v2 |
| testing | TDD 워크플로우 (RED → GREEN → REFACTOR), 커버리지 80%+ | v2 |

### Agents (에이전트)

| 이름 | 모델 | 설명 | 버전 |
|------|:----:|------|:----:|
| planner | opus | 구현 계획 수립 (코드 작성 금지, 계획만 수립) | v1 |
| code-reviewer | opus | 2단계 코드 리뷰 (스펙 준수 → 코드 품질) | v1 |
| verify-agent | sonnet | 검증 파이프라인 (TypeCheck → Lint → Build → Test) | v1 |
| architect | opus | 시스템 설계 & 아키텍처 분석 (읽기 전용) | v2 |
| build-error-resolver | sonnet | 빌드/타입 에러 자동 수정 (최소 diff) | v2 |
| refactor-cleaner | sonnet | 데드코드 정리 & 코드 통합 | v2 |
| security-reviewer | opus | OWASP Top 10 보안 취약점 전문 탐지 | v2 |
| tdd-guide | opus | TDD 워크플로우 가이드 (RED → GREEN → REFACTOR) | v2 |

### Commands (슬래시 명령어)

| 이름 | 설명 | 버전 |
|------|------|:----:|
| /plan | planner 에이전트 호출, prompt_plan.md 저장 | v1 |
| /code-review | code-reviewer 에이전트 호출, 심각도 분류 | v1 |
| /verify | verify-agent 스폰, fresh-context 검증 | v1 |
| /commit | Conventional Commits 형식 커밋 생성 | v1 |
| /auto | 원버튼 자동화 (plan → tdd → review → verify → commit) | v2 |
| /build-fix | build-error-resolver로 점진적 빌드 에러 수정 | v2 |
| /next-task | prompt_plan.md에서 우선순위 기반 다음 태스크 추천 | v2 |
| /orchestrate | Agent Teams 병렬 오케스트레이션 | v2 |
| /quick-commit | 작은 변경용 간소화 커밋 (3파일/20줄 초과 시 경고) | v2 |
| /tdd | tdd-guide 에이전트로 TDD 워크플로우 실행 | v2 |
| /verify-loop | verify-agent 반복 스폰 (최대 3회 재시도 + 자동수정) | v2 |

### Hooks (이벤트 훅)

| 이름 | 이벤트 | 설명 | 버전 |
|------|--------|------|:----:|
| secret-filter | PostToolUse | 도구 출력에서 시크릿 감지 및 마스킹 (3계층 탐지) | v1 |
| security-auto-trigger | PostToolUse (Edit/Write) | 보안 파일 수정 시 /code-review 실행 권장 | v1 |
| code-quality-reminder | PostToolUse (Edit/Write) | 코드 파일 수정 후 품질 체크 리마인더 | v2 |
| db-guard | PreToolUse (Bash) | 위험 SQL 차단 (DROP, TRUNCATE, WHERE 없는 DELETE) | v2 |
| remote-command-guard | PreToolUse (Bash) | 원격 세션에서 위험 명령어 차단 | v2 |
| session-wrap-suggest | Stop | 세션 종료 시 /session-wrap 실행 제안 | v2 |

### Skills (멀티스텝 스킬)

| 이름 | 설명 | 버전 |
|------|------|:----:|
| session-wrap | 세션 자동 정리 (4개 서브에이전트 병렬 실행) | v2 |
| team-orchestrator | Agent Teams 오케스트레이션 엔진 | v2 |

## 설치 방법

### 1. 저장소 클론

```bash
git clone https://github.com/<your-username>/my-claude.git
```

### 2. 프로젝트에 모듈 복사

대상 프로젝트의 `.claude/` 디렉터리에 필요한 모듈을 복사한다.

```bash
# 대상 프로젝트로 이동
cd /path/to/your-project

# .claude 디렉터리 생성
mkdir -p .claude/{rules,agents,commands,hooks,skills}

# 전체 복사 (권장)
cp my-claude/modules/rules/*.md      .claude/rules/
cp my-claude/modules/agents/*.md     .claude/agents/
cp my-claude/modules/commands/*.md   .claude/commands/
cp my-claude/modules/hooks/*.sh      .claude/hooks/
cp -r my-claude/modules/skills/*/    .claude/skills/

# 또는 필요한 모듈만 선택 복사
cp my-claude/modules/rules/golden-principles.md .claude/rules/
```

### 3. 설정 파일 적용

```bash
# settings.json 복사
cp my-claude/templates/settings.json.tmpl .claude/settings.json

# CLAUDE.md 복사 후 플레이스홀더 편집
cp my-claude/templates/CLAUDE.md.tmpl CLAUDE.md
# {프로젝트명}, {기술 스택} 등을 실제 값으로 교체
```

### 4. 훅 실행 권한 부여

```bash
chmod +x .claude/hooks/*.sh
```

## 파이프라인

### 기본 파이프라인 (v1)

```
/plan → 구현 → /code-review → /verify → /commit
```

1. **`/plan`** — 구현 전 계획 수립. 3개 이상 파일 변경 시 필수.
2. **구현** — 계획에 따라 코드 작성.
3. **`/code-review`** — 변경사항 리뷰. CRITICAL/HIGH 이슈 시 커밋 차단.
4. **`/verify`** — fresh-context에서 빌드/테스트/린트 검증.
5. **`/commit`** — Conventional Commits 형식으로 커밋 생성.

### 확장 파이프라인 (v2)

```
/auto — 원버튼 자동화 (plan → tdd → code-review → verify-loop → commit)
```

- **`/auto`** — feature/bugfix/refactor 모드로 풀 파이프라인 자동 실행.
- **`/tdd`** — RED → GREEN → REFACTOR 워크플로우. tdd-guide 에이전트 호출.
- **`/build-fix`** — 빌드 에러를 build-error-resolver가 점진적으로 수정.
- **`/verify-loop`** — verify-agent를 최대 3회 반복하며 자동 수정.
- **`/orchestrate`** — 다중 에이전트를 병렬 실행. team-orchestrator 스킬 호출.
- **`/next-task`** — prompt_plan.md에서 다음 태스크를 추천.
- **`/quick-commit`** — 작은 변경 전용 간소화 커밋.

## 디렉터리 구조

```
my-claude/
├── modules/
│   ├── rules/                      # 자동 로드 규칙 (7개)
│   │   ├── golden-principles.md         [v1] 핵심 원칙
│   │   ├── coding-style.md              [v1] 코딩 스타일
│   │   ├── git-workflow.md              [v1] Git 워크플로우
│   │   ├── agents-v2.md                 [v2] 에이전트 오케스트레이션
│   │   ├── interaction.md               [v2] 커뮤니케이션 규칙
│   │   ├── security.md                  [v2] 보안 체크리스트
│   │   └── testing.md                   [v2] 테스팅 & TDD
│   ├── agents/                     # 에이전트 정의 (8개)
│   │   ├── planner.md                   [v1] 구현 계획 수립
│   │   ├── code-reviewer.md             [v1] 코드 리뷰
│   │   ├── verify-agent.md              [v1] 빌드/테스트/린트 검증
│   │   ├── architect.md                 [v2] 시스템 설계 & 아키텍처
│   │   ├── build-error-resolver.md      [v2] 빌드 에러 자동 수정
│   │   ├── refactor-cleaner.md          [v2] 데드코드 정리
│   │   ├── security-reviewer.md         [v2] 보안 취약점 탐지
│   │   └── tdd-guide.md                 [v2] TDD 가이드
│   ├── commands/                   # 슬래시 명령어 (11개)
│   │   ├── plan.md                      [v1] /plan
│   │   ├── code-review.md               [v1] /code-review
│   │   ├── verify.md                    [v1] /verify
│   │   ├── commit.md                    [v1] /commit
│   │   ├── auto.md                      [v2] /auto
│   │   ├── build-fix.md                 [v2] /build-fix
│   │   ├── next-task.md                 [v2] /next-task
│   │   ├── orchestrate.md               [v2] /orchestrate
│   │   ├── quick-commit.md              [v2] /quick-commit
│   │   ├── tdd.md                       [v2] /tdd
│   │   └── verify-loop.md              [v2] /verify-loop
│   ├── hooks/                      # 이벤트 훅 (6개)
│   │   ├── secret-filter.sh             [v1] 시크릿 마스킹
│   │   ├── security-auto-trigger.sh     [v1] 보안 파일 변경 감지
│   │   ├── code-quality-reminder.sh     [v2] 코드 품질 리마인더
│   │   ├── db-guard.sh                  [v2] 위험 SQL 차단
│   │   ├── remote-command-guard.sh      [v2] 원격 위험 명령어 차단
│   │   └── session-wrap-suggest.sh      [v2] 세션 종료 wrap-up
│   └── skills/                     # 멀티스텝 스킬 (2개)
│       ├── session-wrap/                [v2] 세션 자동 정리
│       │   ├── SKILL.md
│       │   └── references/
│       └── team-orchestrator/           [v2] Agent Teams 엔진
│           └── SKILL.md
├── templates/
│   ├── settings.json.tmpl          # 권한/훅 설정 템플릿
│   └── CLAUDE.md.tmpl              # 프로젝트 설명 템플릿
├── catalog.json                    # 모듈 메타데이터 (34개)
└── docs/
    └── design.md                   # 설계 문서
```

## 업데이트

```bash
# my-claude 저장소에서 최신 버전 pull
cd my-claude
git pull

# 대상 프로젝트에 변경된 모듈 다시 복사
cp my-claude/modules/rules/*.md /path/to/your-project/.claude/rules/
```

> settings.json은 프로젝트별 커스터마이징이 있으므로 덮어쓰기 전 diff 확인을 권장한다.

## 설계 원칙

| 원칙 | 내용 |
|------|------|
| 범용성 | 특정 언어/프레임워크/서비스 종속 금지 |
| Windows 호환 | Git Bash 환경 기준, `/tmp` 대신 `$TEMP` 사용 |
| MCP 무의존 | 외부 MCP 서버 참조 없음 |
| 축소 지향 | 핵심 기능만 추출, 과도한 자동화 배제 |
| 수동 설치 | clone → 복사. 빌드/설치 스크립트 불필요 |

## 변경 이력

### v0.2.0

- Rules 4개 추가 (agents-v2, interaction, security, testing)
- Agents 5개 추가 (architect, build-error-resolver, refactor-cleaner, security-reviewer, tdd-guide)
- Commands 7개 추가 (/auto, /build-fix, /next-task, /orchestrate, /quick-commit, /tdd, /verify-loop)
- Hooks 4개 추가 (code-quality-reminder, db-guard, remote-command-guard, session-wrap-suggest)
- Skills 2개 추가 (session-wrap, team-orchestrator)
- settings.json.tmpl에 PreToolUse/Stop 훅 등록
- catalog.json v0.2.0 (총 34개 모듈)

### v0.1.0

- 초기 릴리스. Rules 3 + Agents 3 + Commands 4 + Hooks 2 = 12개 모듈.
- 기본 파이프라인: /plan → /code-review → /verify → /commit

## 라이선스

MIT
