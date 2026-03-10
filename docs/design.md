# my-claude 최종 설계 문서

어떤 프로젝트에서든 Claude Code 환경을 빠르게 세팅할 수 있도록 돕는 오픈소스 도구.

---

## 1. 프로젝트 개요

### 목표

Claude Code CLI를 사용하는 개발자가 프로젝트마다 반복하는 설정 작업(규칙 정의, 명령어 등록, 보안 훅 구성 등)을 모듈화하여, 필요한 것만 골라 즉시 적용할 수 있게 한다.

### 핵심 가치

- **모듈화**: 각 모듈이 독립적. 필요한 것만 골라 쓴다.
- **수동 설치**: clone → 복사로 끝. 빌드/설치 스크립트 불필요.
- **범용성**: 특정 언어/프레임워크/서비스에 종속되지 않는다.

### 대상 환경

| 항목 | 값 |
|------|-----|
| OS | Windows (Git Bash / MINGW) |
| 셸 | bash (Git Bash 기본 제공) |
| 필수 도구 | Claude Code CLI, Git |
| 선택 도구 | Python 3 (훅 실행용), gh CLI (PR 자동화) |

> 크로스 플랫폼(macOS/Linux)은 추후 고려. 현재는 Windows 전용으로 설계한다.

### Windows 환경 주의사항

- 훅 스크립트는 Git Bash에서 실행됨 (bash 문법 사용 가능)
- Python 호출 시 `python3` 대신 `python` 명령어가 기본일 수 있음 → 훅 내부에서 분기 처리
- 경로 구분자는 `/` 사용 (Git Bash 환경)
- 심링크 대신 파일 복사 방식 사용

---

## 2. 디렉터리 구조

```
my-claude/
├── modules/
│   ├── agents/                  # 에이전트 정의 (.md)
│   │   ├── planner.md
│   │   ├── code-reviewer.md
│   │   └── verify-agent.md
│   ├── commands/                # 슬래시 명령어 (.md)
│   │   ├── plan.md
│   │   ├── code-review.md
│   │   └── commit.md
│   ├── hooks/                   # 이벤트 훅 (.sh)
│   │   ├── secret-filter.sh
│   │   └── security-auto-trigger.sh
│   ├── rules/                   # 자동 로드 규칙 (.md)
│   │   ├── golden-principles.md
│   │   ├── coding-style.md
│   │   └── git-workflow.md
│   └── skills/                  # 멀티스텝 스킬 (추후)
├── templates/
│   ├── CLAUDE.md.tmpl           # CLAUDE.md 템플릿
│   └── settings.json.tmpl       # settings.json 템플릿
├── docs/
│   └── design.md                # 본 문서
├── catalog.json                 # 전체 모듈 카탈로그
└── README.md
```

### 사용자 프로젝트에 복사된 후 구조

```
my-project/
├── .claude/
│   ├── agents/
│   │   └── planner.md
│   ├── commands/
│   │   └── plan.md
│   ├── rules/
│   │   └── golden-principles.md
│   └── settings.json
├── CLAUDE.md
└── (프로젝트 소스 코드)
```

---

## 3. 설치 방법

```bash
# 1. 저장소 클론
git clone https://github.com/{user}/my-claude.git

# 2. 내 프로젝트에 필요한 모듈만 복사
cp my-claude/modules/rules/golden-principles.md   my-project/.claude/rules/
cp my-claude/modules/agents/planner.md             my-project/.claude/agents/
cp my-claude/modules/commands/plan.md              my-project/.claude/commands/

# 3. settings.json 템플릿 복사 (훅 사용 시)
cp my-claude/templates/settings.json.tmpl          my-project/.claude/settings.json

# 4. CLAUDE.md 템플릿 복사 (선택)
cp my-claude/templates/CLAUDE.md.tmpl              my-project/CLAUDE.md
```

### 업데이트

```bash
cd my-claude && git pull
# 변경된 모듈만 다시 복사
```

### 추후 확장 (요구 시)

- npx CLI: 대화형으로 모듈 선택 + 자동 복사
- 프리셋: 모듈 조합을 프리셋 단위로 일괄 복사

---

## 4. 모듈 카탈로그

### catalog.json

모든 모듈의 메타데이터를 관리한다. 1차 개발에서는 참조용이며, CLI 개발 시 자동화에 활용한다.

```json
{
  "modules": [
    {
      "id": "rule-golden-principles",
      "type": "rule",
      "name": "golden-principles",
      "description": "11개 핵심 원칙 (불변성, TDD, 증거 기반 완료 등)",
      "path": "modules/rules/golden-principles.md",
      "tags": ["core"]
    },
    {
      "id": "agent-planner",
      "type": "agent",
      "name": "planner",
      "description": "구현 계획 수립 에이전트. 코드를 작성하지 않고 계획만 세운다.",
      "path": "modules/agents/planner.md",
      "tags": ["planning", "core"]
    }
  ]
}
```

> `depends` 필드는 1차 개발에서 사용하지 않는다. 모듈 간 의존 관계는 README에 텍스트로 명시한다.

---

## 5. 모듈 상세 설계

---

### 5.1 Rules (자동 로드 규칙)

`.claude/rules/` 디렉터리에 배치하면 매 세션마다 자동 로드된다.

#### golden-principles.md

11개 핵심 원칙. 모든 에이전트와 작업의 행동 기준.

| # | 원칙 | 핵심 |
|---|------|------|
| 1 | 불변성 | spread로 새 객체 생성, 원본 수정 금지 |
| 2 | 시크릿 환경변수화 | process.env로만 접근, 미설정 시 throw |
| 3 | TDD | RED → GREEN → IMPROVE, 커버리지 80% |
| 4 | 결론 우선 | 첫 문장에 결론, 이유는 그 다음 |
| 5 | 작은 파일/함수 | 파일 800줄, 함수 50줄, 중첩 4단계 |
| 6 | 시스템 경계 검증 | 사용자 입력/외부 API는 스키마로 검증 |
| 7 | 비유로 설명 | 기술 설명 전 일상 비유 1-2문장 |
| 8 | 컨텍스트 50% 규칙 | 50% 넘으면 새 세션 분리 |
| 9 | HARD-GATE | 3파일 이상 변경 시 /plan 먼저 |
| 10 | 증거 기반 완료 | 테스트 결과 + 빌드 성공 증거 필수 |
| 11 | SDD 리뷰 강제 | 서브에이전트 작업 후 스펙 리뷰 필수 |

#### coding-style.md

| 규칙 | 내용 |
|------|------|
| 불변성 | 새 객체 생성, 뮤테이션 금지 |
| 파일 구조 | 200-400줄 일반, 800줄 최대. 도메인별 조직 |
| 에러 처리 | 항상 try-catch, 사용자 친화적 메시지 |
| 입력 검증 | zod 등 스키마로 검증 |
| 체크리스트 | 함수 <50줄, 파일 <800줄, 중첩 <4, console.log 없음, 하드코딩 없음 |

#### git-workflow.md

| 항목 | 내용 |
|------|------|
| 커밋 포맷 | `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci) |
| 워크플로우 | /plan → TDD → /code-review → 커밋 |
| PR | 전체 커밋 히스토리 분석, 테스트 계획 포함 |

---

### 5.2 Agents (에이전트)

`.claude/agents/` 디렉터리에 배치. YAML frontmatter + 마크다운 프롬프트로 정의.

#### 에이전트 정의 포맷

```markdown
---
name: agent-name
description: 트리거 조건 설명
tools: ["Read", "Grep", "Glob"]
model: opus
color: blue
---

<Agent_Prompt>
  <Role>역할과 책임</Role>
  <Constraints>제약 조건</Constraints>
  <Investigation_Protocol>작업 절차</Investigation_Protocol>
  <Output_Format>출력 형식</Output_Format>
  <Failure_Modes_To_Avoid>피해야 할 실패 패턴</Failure_Modes_To_Avoid>
  <Final_Checklist>완료 전 체크리스트</Final_Checklist>
</Agent_Prompt>
```

#### planner (구현 계획 수립)

| 항목 | 내용 |
|------|------|
| 모델 | opus |
| 도구 | Read, Grep, Glob (읽기 전용) |
| 색상 | blue |
| 역할 | 복잡한 기능의 구현 계획 수립. **절대 코드를 작성하지 않음.** |

핵심 동작:
1. 의도 분류 (단순 / 리팩터링 / 처음부터 구축 / 중간 규모)
2. 코드베이스 조사는 explore 에이전트 사용 (사용자에게 묻지 않음)
3. 사용자에게는 우선순위/범위/리스크만 질문 (한 번에 하나씩)
4. 3-6단계 계획 생성 (과하지 않게)
5. 사용자가 "yes" 할 때까지 대기 → 확인 후 `prompt_plan.md`에 저장

출력:
```
# Implementation Plan: [기능명]
## Overview / Requirements / Architecture Changes
## Implementation Steps (Phase별)
## Testing Strategy / Risks / Success Criteria
```

#### code-reviewer (코드 리뷰)

| 항목 | 내용 |
|------|------|
| 모델 | opus |
| 도구 | Read, Grep, Glob, Bash |
| 색상 | blue |
| 역할 | git diff 기반 체계적 코드 리뷰 |

핵심 동작:
1. `git diff`로 변경 파일 확인
2. **Stage 1 — 스펙 준수 (필수 먼저)**: 요구사항을 모두 구현했는가?
3. **Stage 2 — 코드 품질**: 보안, 품질, 성능 체크리스트 적용
4. 심각도별 이슈 분류 + 수정 제안

심각도 등급:

| 등급 | 의미 | 커밋 허용 |
|------|------|:---------:|
| CRITICAL | 보안 취약점, 데이터 손실 | 차단 |
| HIGH | 기능 장애, 중요 품질 문제 | 차단 |
| MEDIUM | 모범 사례 위반, 유지보수성 | 경고 |
| LOW | 스타일, 가독성 | 허용 |

판정: **APPROVE** / **REQUEST CHANGES** / **COMMENT**

#### verify-agent (빌드/테스트/린트 검증)

| 항목 | 내용 |
|------|------|
| 모델 | sonnet |
| 도구 | Read, Write, Edit, Bash, Grep, Glob |
| 색상 | cyan |
| 역할 | fresh-context에서 빌드/테스트/린트 검증. 서브에이전트로 스폰됨. |

검증 파이프라인 순서:
```
TypeCheck → Lint → Build → Test
```

에러 분류:
- **수정 가능 (Fixable)**: 누락 import, 린트 포맷, 단순 타입 에러, 미사용 import
- **수정 불가 (Non-Fixable)**: 로직 에러, 아키텍처 이슈, 런타임 에러

동작 모드:

| 모드 | 설명 |
|------|------|
| loop | 수정 + 재시도 (기본, 최대 5회) |
| once | 단일 패스 |
| extract | 에러 목록만 추출 |
| coverage | 테스트 커버리지 분석 |

출력:
```
RESULT: PASS | FAIL | EXTRACT | COVERAGE
VERIFIED_SHA: <hash>
DETAILS: TypeCheck/Lint/Build/Test 각 단계 결과
```

#### 에이전트 자동 판단 규칙

| 상황 | 자동 사용 에이전트 |
|------|:------------------:|
| 복잡한 기능 요청 | planner |
| 코드 작성/수정 직후 | code-reviewer |

---

### 5.3 Commands (슬래시 명령어)

`.claude/commands/` 디렉터리에 배치. 사용자가 `/명령어`로 직접 호출.

#### 명령어 정의 포맷

```markdown
---
description: 명령어 한 줄 설명
---

# 명령어 이름

(실행할 작업 지시문)
```

#### 핵심 파이프라인

```
/plan → /code-review → /verify → /commit
```

#### /plan

| 항목 | 내용 |
|------|------|
| 설명 | 구현 계획 수립. planner 에이전트 호출. |
| 동작 | 요구사항 분석 → 단계별 계획 → 사용자 확인 대기 → prompt_plan.md 저장 |
| 핵심 | **사용자가 "yes" 할 때까지 코드 작성 안 함** |

#### /code-review

| 항목 | 내용 |
|------|------|
| 설명 | git diff 기반 보안+품질 리뷰. code-reviewer 에이전트 호출. |
| 동작 | 변경 파일 수집 → 스펙 준수 → 코드 품질 → 심각도 분류 → 판정 |
| 핵심 | CRITICAL/HIGH 발견 시 커밋 차단 |

#### /verify

| 항목 | 내용 |
|------|------|
| 설명 | fresh-context에서 빌드/테스트/린트 검증. verify-agent 서브에이전트 스폰. |
| 플래그 | `--once`, `--loop N`, `--security`, `--coverage`, `--extract` |
| 핵심 | 증거 없이 완료 주장 금지 |

#### /commit

| 항목 | 내용 |
|------|------|
| 설명 | 변경 내역 분석 후 Conventional Commits 형식으로 커밋 메시지 자동 생성 |
| 동작 | 변경 파일 수집 → 커밋 메시지 생성 → 스테이징 → 커밋 |
| 커밋 타입 | feat, fix, refactor, docs, test, chore, perf, ci |

---

### 5.4 Hooks (이벤트 훅)

`.claude/hooks/` 디렉터리에 배치. `settings.json`의 `hooks` 섹션에 등록.

#### 훅 동작 원리

| 항목 | 설명 |
|------|------|
| 이벤트 | PreToolUse, PostToolUse, SessionStart, Stop, TaskCompleted |
| Exit 0 | 허용 (통과) |
| Exit 2 | 차단 (stderr에 blocked_reason 출력) |
| 입력 | stdin으로 JSON 수신 (tool_name, tool_input, tool_result 등) |

#### secret-filter.sh (출력 시크릿 마스킹)

| 항목 | 내용 |
|------|------|
| 이벤트 | PostToolUse (전체) |
| 차단 | X (마스킹만) |
| 구현 | bash 래퍼 + Python 스크립트 |

3계층 탐지:

| 계층 | 설명 |
|:----:|------|
| Layer 1 | 원본 텍스트에서 직접 패턴 매칭 |
| Layer 2 | Base64 디코딩 후 재스캔 |
| Layer 3 | URL 인코딩(%XX) 디코딩 후 재스캔 |

탐지 패턴: OpenAI(`sk-`), AWS(`AKIA`), GitHub(`ghp_`), Slack(`xoxb-`), Bearer 토큰, Private Key 등

마스킹 방식:
- 16자 초과: `앞8자***MASKED***뒤4자`
- 16자 이하: `앞4자***MASKED***`

Windows 대응:
- `python3` → `python` 또는 `py` 명령어 분기
- 스크립트 상단에 Python 경로 자동 감지 로직 추가

#### security-auto-trigger.sh (보안 파일 변경 감지)

| 항목 | 내용 |
|------|------|
| 이벤트 | PostToolUse (Edit, Write) |
| 차단 | X (제안만) |
| 구현 | bash 래퍼 + Python 스크립트 |

감지 패턴: auth, login, session, token, jwt, oauth, credential, middleware, .env, migration, api/, encrypt, decrypt, hash, crypto

동작: 보안 관련 파일 수정 감지 시 `/code-review` 실행 권장 메시지 출력 (세션당 같은 파일에 대해 1회만)

#### settings.json 훅 등록 구조

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/secret-filter.sh",
            "timeout": 5000
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/security-auto-trigger.sh"
          }
        ]
      }
    ]
  }
}
```

---

### 5.5 Skills (멀티스텝 스킬) — 추후 구현

`.claude/skills/<name>/SKILL.md`로 정의. Commands와 차이:

| 기능 | Command | Skill |
|------|:-------:|:-----:|
| 사용자가 `/xxx`로 호출 | O | O |
| Claude가 자동 판단해서 호출 | X | O |
| 보조 파일 (참조 문서, 스크립트) | X | O |
| 서브에이전트 격리 실행 | X | O |
| 도구 접근 제한 | X | O |

1차 개발 범위 밖. verification-engine, session-wrap 등은 Phase 2 이후에 구현.

---

## 6. settings.json 템플릿

```json
{
  "permissions": {
    "allow": [
      "Bash(*)",
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Glob(*)",
      "Grep(*)",
      "Skill(*)",
      "WebSearch(*)",
      "Task(*)",
      "TaskCreate(*)",
      "TaskUpdate(*)",
      "TaskGet(*)",
      "TaskList(*)",
      "TaskOutput(*)",
      "TaskStop(*)",
      "AskUserQuestion(*)"
    ],
    "deny": [
      "Bash(rm -rf /)*",
      "Bash(rm -rf ~)*",
      "Bash(rm -rf .)*",
      "Bash(rm -rf *)*",
      "Bash(sudo:*)",
      "Bash(chmod 777:*)",
      "Bash(curl*|*sh)*",
      "Bash(wget*|*sh)*",
      "Bash(git push --force*main)*",
      "Bash(git push -f*main)*",
      "Bash(git push --force*master)*",
      "Bash(git push -f*master)*",
      "Bash(git reset --hard origin/*)*",
      "Bash(git clean -f*)*",
      "Bash(npm publish)*",
      "Bash(eval *)*",
      "Bash(bash -c *)*",
      "Bash(sh -c *)*"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/secret-filter.sh",
            "timeout": 5000
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/security-auto-trigger.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 7. CLAUDE.md 템플릿

```markdown
# {프로젝트명}

## 프로젝트 컨텍스트
- 개요: {한 줄 설명}
- 기술 스택: {언어, 프레임워크, DB}
- 아키텍처: {모노레포/마이크로서비스/단일 앱}

## 주요 명령어
- 빌드: `{npm run build}`
- 테스트: `{npm test}`
- 린트: `{npm run lint}`

## 코딩 컨벤션
- 컨벤션 문서 경로: `{docs/conventions.md}`
- import 순서: {외부 → 내부 → 타입}

## 작업 규칙
- /plan으로 계획 수립 후 구현
- /code-review로 커밋 전 리뷰
- 한 세션 = 한 작업
```

> 60줄 이하 유지. 61-80줄이면 rules/로 분리 검토. 80줄 초과 시 반드시 분리.

---

## 8. 구현 로드맵

### Phase 1: MVP

목표: 핵심 워크플로우(`/plan → /code-review → /commit`)가 동작하는 최소 구성

구현 순서:

```
1. 저장소 구조 생성
2. rules 작성
3. agents 작성
4. commands 작성
5. hooks 작성
6. settings.json 템플릿
7. CLAUDE.md 템플릿
8. catalog.json
9. README.md
```

#### 1단계: 저장소 구조 생성

```
my-claude/
├── modules/
│   ├── agents/
│   ├── commands/
│   ├── hooks/
│   └── rules/
├── templates/
├── docs/
├── catalog.json
└── README.md
```

#### 2단계: Rules 작성

| 파일 | 설명 |
|------|------|
| golden-principles.md | 11개 핵심 원칙 |
| coding-style.md | 코딩 스타일 기준 |
| git-workflow.md | Git 워크플로우, 커밋 포맷 |

Claude Forge 참고 파일을 기반으로 커스터마이징:
- 범용성 확보 (특정 스택 제거)
- Windows 환경 고려
- 한국어/영어 혼용 정리

#### 3단계: Agents 작성

| 파일 | 모델 | 설명 |
|------|------|------|
| planner.md | opus | 구현 계획 수립 (코드 작성 안 함) |
| code-reviewer.md | opus | 심각도 등급 코드 리뷰 |
| verify-agent.md | sonnet | fresh-context 빌드/테스트/린트 검증 |

Claude Forge 에이전트 구조(`<Agent_Prompt>` XML 패턴) 채용.
MCP 의존성 제거 (context7, sequential-thinking 등 제거).

#### 4단계: Commands 작성

| 파일 | 설명 |
|------|------|
| plan.md | planner 에이전트 호출, prompt_plan.md 저장 |
| code-review.md | code-reviewer 에이전트 호출, 심각도 분류 |
| commit.md | 변경 분석 → Conventional Commits 커밋 |

Claude Forge의 commit-push-pr.md(767줄)는 과도. /commit은 커밋만 담당하고, PR/머지는 별도로 분리하거나 추후 구현.

#### 5단계: Hooks 작성

| 파일 | 이벤트 | 설명 |
|------|--------|------|
| secret-filter.sh | PostToolUse | 출력 시크릿 마스킹 |
| security-auto-trigger.sh | PostToolUse(Edit/Write) | 보안 파일 변경 감지 |

Claude Forge 훅 기반, Windows 대응 추가:
- Python 경로 자동 감지 (`python3` / `python` / `py`)
- `/tmp/` 대신 `$TEMP` 또는 `$HOME/.claude/tmp/` 사용

#### 6-9단계: 템플릿, 카탈로그, README

- settings.json.tmpl: 권한 + deny 리스트 + 훅 등록
- CLAUDE.md.tmpl: 프로젝트별 커스터마이징 가이드
- catalog.json: 모듈 메타데이터
- README.md: 설치/사용법

### Phase 2: 핵심 워크플로우 확장

- agents 추가: tdd-guide (RED → GREEN → REFACTOR)
- commands 추가: /tdd, /verify, /handoff
- hooks 추가: db-guard (위험 SQL 차단)
- rules 추가: security, testing
- skills: verification-engine (검증 루프)

### Phase 3: 자동화

- npx CLI (대화형 모듈 선택 + 자동 복사)
- 프리셋 시스템 (minimal, standard, full)
- 알림 훅 (OS notification)
- skills: session-wrap (세션 종료 정리)

---

## 9. 넣지 않는 것

| 제외 항목 | 이유 |
|-----------|------|
| 키워드 자동화 | 명령어(`/xxx`)로 대체. 오탐 위험. |
| 특정 스택 종속 | Supabase, Next.js 등 특정 서비스 의존 제거 |
| MCP 서버 의존 | context7, memory 등은 사용자가 별도 설치 |
| 과도한 자동화 | `/auto` 같은 원버튼 파이프라인은 추후 검토 |
| 프리셋 (1차) | 모듈이 충분히 쌓인 후 Phase 3에서 |
| 크로스 플랫폼 (1차) | Windows 전용. macOS/Linux는 추후 |
| Agent Teams | 실험적 기능. 안정화 후 검토 |
| Self-Evolution | 에이전트 자가 학습은 복잡도 대비 효과 불확실 |

---

## 10. 모듈 간 관계

```
rules/golden-principles.md ──→ 모든 에이전트/명령어의 행동 기준
rules/coding-style.md      ──→ code-reviewer가 리뷰 시 참조
rules/git-workflow.md       ──→ /commit이 커밋 포맷 참조

/plan ──→ planner 에이전트 호출 ──→ prompt_plan.md 저장
/code-review ──→ code-reviewer 에이전트 호출 ──→ 판정 출력
/verify ──→ verify-agent 서브에이전트 스폰 ──→ 검증 결과 반환
/commit ──→ git diff 분석 ──→ 커밋 메시지 생성 ──→ git commit

hooks/secret-filter.sh ──→ settings.json에 등록 ──→ PostToolUse마다 실행
hooks/security-auto-trigger.sh ──→ Edit/Write마다 보안 파일 체크
```

---

## 부록: Claude Forge 참고 파일 목록

`claude-forge-extract/` 디렉터리에 원본 보관. 각 모듈 작성 시 참고.

| 참고 파일 | my-claude 대응 모듈 |
|-----------|---------------------|
| `agents/planner.md` | `modules/agents/planner.md` |
| `agents/code-reviewer.md` | `modules/agents/code-reviewer.md` |
| `agents/verify-agent.md` | `modules/agents/verify-agent.md` |
| `rules/golden-principles.md` | `modules/rules/golden-principles.md` |
| `rules/coding-style.md` | `modules/rules/coding-style.md` |
| `rules/git-workflow-v2.md` | `modules/rules/git-workflow.md` |
| `commands/plan.md` | `modules/commands/plan.md` |
| `commands/code-review.md` | `modules/commands/code-review.md` |
| `commands/commit-push-pr.md` | `modules/commands/commit.md` (축소) |
| `hooks/output-secret-filter.sh` | `modules/hooks/secret-filter.sh` |
| `hooks/security-auto-trigger.sh` | `modules/hooks/security-auto-trigger.sh` |
| `skills/verification-engine/SKILL.md` | Phase 2 참고 |
| `settings.json` | `templates/settings.json.tmpl` |
