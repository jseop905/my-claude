# my-claude

Claude Code CLI를 위한 범용 설정 모듈 모음. 복사해서 바로 사용할 수 있는 규칙, 에이전트, 명령어, 훅을 제공한다.

## 모듈 목록

| 타입 | 이름 | 설명 | 태그 |
|------|------|------|------|
| rule | golden-principles | 11개 핵심 원칙 (불변성, TDD, 증거 기반 완료 등) | core |
| rule | coding-style | 코딩 스타일 규칙 (파일 구조, 에러 처리, Pre-Completion 체크리스트) | core, quality |
| rule | git-workflow | Git 워크플로우 (Conventional Commits, 파이프라인 정의) | core, quality |
| agent | planner | 구현 계획 수립 에이전트 (코드 작성 금지, 계획만 수립) | planning, core |
| agent | code-reviewer | 2단계 코드 리뷰 에이전트 (스펙 준수 → 코드 품질) | quality, security |
| agent | verify-agent | 검증 파이프라인 (TypeCheck → Lint → Build → Test) | quality |
| command | plan | `/plan` — planner 에이전트 호출 | planning, core |
| command | code-review | `/code-review` — code-reviewer 에이전트 호출 | quality, security |
| command | verify | `/verify` — verify-agent를 스폰하여 빌드/테스트/린트 검증 | quality |
| command | commit | `/commit` — Conventional Commits 형식 커밋 생성 | core |
| hook | secret-filter | 도구 출력에서 시크릿 감지 및 마스킹 (3계층 탐지) | security |
| hook | security-auto-trigger | 보안 파일 수정 시 `/code-review` 실행 권장 | security |

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
mkdir -p .claude/{rules,agents,commands,hooks}

# 전체 복사 (권장)
cp my-claude/modules/rules/*.md      .claude/rules/
cp my-claude/modules/agents/*.md     .claude/agents/
cp my-claude/modules/commands/*.md   .claude/commands/
cp my-claude/modules/hooks/*.sh      .claude/hooks/

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

## 핵심 파이프라인

```
/plan → 구현 → /code-review → /verify → /commit
```

1. **`/plan`** — 구현 전 계획 수립. 3개 이상 파일 변경 시 필수.
2. **구현** — 계획에 따라 코드 작성.
3. **`/code-review`** — 변경사항 리뷰. CRITICAL/HIGH 이슈 시 커밋 차단.
4. **`/verify`** — fresh-context에서 빌드/테스트/린트 검증.
5. **`/commit`** — Conventional Commits 형식으로 커밋 생성.

## 디렉터리 구조

```
my-claude/
├── modules/
│   ├── rules/                      # 자동 로드 규칙
│   │   ├── golden-principles.md
│   │   ├── coding-style.md
│   │   └── git-workflow.md
│   ├── agents/                     # 에이전트 정의
│   │   ├── planner.md
│   │   ├── code-reviewer.md
│   │   └── verify-agent.md
│   ├── commands/                   # 슬래시 명령어
│   │   ├── plan.md
│   │   ├── code-review.md
│   │   ├── verify.md
│   │   └── commit.md
│   ├── hooks/                      # PostToolUse 훅
│   │   ├── secret-filter.sh
│   │   └── security-auto-trigger.sh
│   └── skills/                     # Phase 2 예정
├── templates/
│   ├── settings.json.tmpl          # 권한/훅 설정 템플릿
│   └── CLAUDE.md.tmpl              # 프로젝트 설명 템플릿
├── catalog.json                    # 모듈 메타데이터
└── docs/
    ├── design.md                   # 설계 문서
    └── CHECKLIST.md                # 구현 체크리스트
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

## 라이선스

MIT
