# Code Review Report

> 리뷰 일자: 2026-03-11 | 대상: my-claude v0.2.0 전체 모듈 (36개)

모듈별 코드리뷰 결과. 의존성 흐름(상위→하위) 순서로 7라운드 진행.

## 리뷰 기준

1. **명세 완성도** — 필수 섹션 누락 없는지
2. **내부 일관성** — 규칙 간 모순/중복 없는지
3. **참조 정합성** — 다른 모듈 참조가 정확한지 (이름, 경로)
4. **실행 가능성** — 실제 Claude Code에서 동작 가능한 구조인지
5. **간결성** — 불필요한 중복/과잉 설계가 없는지

## 진행 결과

| Round | 카테고리 | 모듈 수 | 이슈 | 상태 |
|-------|----------|---------|------|------|
| 1 | Rules (기반 규칙) | 7 | 5건 | ✅ |
| 2 | Core Agents (핵심 에이전트) | 3 | 3건 | ✅ |
| 3 | Extended Agents (확장 에이전트) | 5 | 4건 | ✅ |
| 4 | Core Commands (핵심 명령어) | 4 | 1건 | ✅ |
| 5 | Extended Commands (확장 명령어) | 6 | 2건 | ✅ |
| 6 | Hooks (훅) | 6 | 1건 (CRITICAL) | ✅ |
| 7 | Skills + Templates + catalog.json | 5+README | 2건 | ✅ |
| 8+ | Deferred | - | 없음 | ✅ |

---

## Round 1: Rules (7개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/rules/golden-principles.md` | ✅ | 이슈 없음 |
| `modules/rules/coding-style.md` | ✅ | 불변성 중복 의도적 유지 |
| `modules/rules/git-workflow.md` | ✅ | /verify 단계 추가 |
| `modules/rules/testing.md` | ✅ | 이슈 없음 |
| `modules/rules/security.md` | ✅ | 이슈 없음 |
| `modules/rules/interaction.md` | ✅ | 이슈 없음 |
| `modules/rules/agents-v2.md` | ✅ | 경로 변경, 모델 변경 |

### 수정 내역

**IMPROVE 통일 (MEDIUM)**: `golden-principles.md`는 RED → GREEN → IMPROVE이나, catalog.json/README/CLAUDE.md.tmpl에서 REFACTOR 사용. IMPROVE로 통일. tdd-guide.md(R3), tdd.md(R5)에서 추가 수정.

**git-workflow /verify 누락 (HIGH)**: Feature Implementation Workflow가 `/plan → 구현 → /code-review → /commit`으로 `/verify` 빠짐. 5단계로 수정.

**agents-v2 경로 (MEDIUM)**: `~/.claude/agents/`(글로벌) → `.claude/agents/`(프로젝트 루트) 변경.

**build-error-resolver 모델 (LOW)**: sonnet → opus 변경. 빌드 에러 분석 복잡도에 적합.

**coding-style 불변성 중복 (LOW)**: golden-principles와 역할 분리됨 (원칙 vs 코드 예시). 의도적 유지.

---

## Round 2: Core Agents (3개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/agents/planner.md` | ✅ | Write 불필요 확인 |
| `modules/agents/code-reviewer.md` | ✅ | 이슈 없음 |
| `modules/agents/verify-agent.md` | ✅ | loop 재시도 3회 통일 |

### 수정 내역

**재시도 횟수 불일치 (MEDIUM)**: verify-agent Constraints "3 attempts"이나 Modes 테이블 "max 5 rounds". 3회로 통일. verify-loop.md도 선수정.

**planner Write 도구 (LOW)**: 서브에이전트는 읽기 전용 + 메시지 반환이 원칙. 파일 저장은 /plan command 책임. Write 불필요 확인.

---

## Round 3: Extended Agents (5개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/agents/architect.md` | ✅ | 이슈 없음 |
| `modules/agents/tdd-guide.md` | ✅ | REFACTOR→IMPROVE 전체 수정 |
| `modules/agents/build-error-resolver.md` | ✅ | model sonnet→opus |
| `modules/agents/refactor-cleaner.md` | ✅ | sonnet 유지 (의도) |
| `modules/agents/security-reviewer.md` | ✅ | 이슈 없음 |

### 수정 내역

**tdd-guide REFACTOR 잔여 (MEDIUM)**: Round 1 IMPROVE 통일 결정 후 미수정. frontmatter + 본문 12곳+ 전체 치환.

**build-error-resolver frontmatter (MEDIUM)**: Round 1에서 agents-v2.md만 opus로 변경, 실제 에이전트 frontmatter 미수정. `model: sonnet` → `model: opus`.

**refactor-cleaner 모델 (LOW)**: sonnet 유지. 사용 빈도 낮고 점진적 context 압축으로 운영.

### 에이전트 도구/모델 정리

| Agent | Model | Write/Edit | 역할 |
|-------|-------|-----------|------|
| planner | opus | ❌ | 읽기 전용 → 출력 반환 |
| architect | opus | ❌ | 읽기 전용 → 출력 반환 |
| security-reviewer | opus | ❌ | 읽기 전용 → 출력 반환 |
| code-reviewer | opus | ❌ | 읽기 전용 → 출력 반환 |
| tdd-guide | opus | ✅ | 직접 코드 작성 |
| build-error-resolver | opus | ✅ | 직접 코드 수정 |
| refactor-cleaner | sonnet | ✅ | 직접 코드 수정 |
| verify-agent | sonnet | ✅ | 직접 코드 수정 (auto-fix) |

---

## Round 4: Core Commands (4개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/commands/plan.md` | ✅ | 이슈 없음 |
| `modules/commands/code-review.md` | ✅ | 이슈 없음 |
| `modules/commands/verify.md` | ✅ | loop 라운드 5→3 수정 |
| `modules/commands/commit.md` | ✅ | 이슈 없음 |

### 수정 내역

**verify.md loop 라운드 (MEDIUM)**: Round 2에서 verify-agent(3), verify-loop(3) 수정했으나, verify.md 모드 테이블만 "최대 5라운드" 잔존. 3으로 수정.

---

## Round 5: Extended Commands (6개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/commands/auto.md` | ✅ | 이슈 없음 |
| `modules/commands/tdd.md` | ✅ | REFACTOR→IMPROVE 수정 |
| `modules/commands/build-fix.md` | ✅ | 이슈 없음 |
| `modules/commands/verify-loop.md` | ✅ | 예시/출력 5→3 수정 |
| `modules/commands/next-task.md` | ✅ | 이슈 없음 |
| `modules/commands/orchestrate.md` | ✅ | 이슈 없음 |

### 수정 내역

**tdd.md REFACTOR 잔여 (MEDIUM)**: Round 1 파급 메모. frontmatter + Step 4 제목 + 출력 예시 전체 IMPROVE로 치환.

**verify-loop.md 예시 5회 잔존 (MEDIUM)**: Round 2에서 설명/기본값은 3으로 수정했으나, 예시 출력(시도 N/5)과 비교표(최대 5회) 6곳 누락. 전체 3으로 수정.

---

## Round 6: Hooks (6개)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/hooks/secret-filter.sh` | ✅ | pipe+heredoc 충돌 수정 |
| `modules/hooks/security-auto-trigger.sh` | ✅ | 이슈 없음 |
| `modules/hooks/db-guard.sh` | ✅ | pipe+heredoc 충돌 수정 |
| `modules/hooks/remote-command-guard.sh` | ✅ | pipe+heredoc 충돌 수정 |
| `modules/hooks/code-quality-reminder.sh` | ✅ | 이슈 없음 |
| `modules/hooks/session-wrap-suggest.sh` | ✅ | 이슈 없음 |

### 수정 내역

**pipe + heredoc stdin 충돌 (CRITICAL)**: 3개 훅이 `echo "$INPUT" | $PYTHON_CMD << 'HEREDOC'` 패턴 사용. bash에서 heredoc가 pipe보다 stdin 우선순위가 높아, Python의 `sys.stdin.read()`가 항상 빈 문자열 반환. 결과적으로:
- `db-guard.sh` — 위험 SQL **차단 불가**
- `remote-command-guard.sh` — 위험 명령 **차단 불가**
- `secret-filter.sh` — 시크릿 **마스킹 불가**

수정: heredoc를 임시 파일에 저장 후 pipe로 INPUT 전달.

```bash
# Before (broken)
echo "$INPUT" | $PYTHON_CMD << 'SCRIPT'
...
SCRIPT

# After (fixed)
_SCRIPT_FILE=$(mktemp "${TMPDIR:-/tmp}/hook-XXXXXX.py")
trap 'rm -f "$_SCRIPT_FILE"' EXIT
cat > "$_SCRIPT_FILE" << 'SCRIPT'
...
SCRIPT
echo "$INPUT" | $PYTHON_CMD "$_SCRIPT_FILE"
```

나머지 3개(`security-auto-trigger`, `code-quality-reminder`, `session-wrap-suggest`)는 `$PYTHON_CMD -c "..."` 패턴으로 정상 동작.

---

## Round 7: Skills + Templates + catalog.json (5개 + README)

| 파일 | 상태 | 비고 |
|------|------|------|
| `modules/skills/session-wrap/SKILL.md` | ✅ | 이슈 없음 |
| `modules/skills/team-orchestrator/SKILL.md` | ✅ | 이슈 없음 |
| `templates/settings.json.tmpl` | ✅ | 이슈 없음 |
| `templates/global.settings.json.tmpl` | ✅ | 이슈 없음 |
| `templates/CLAUDE.md.tmpl` + `catalog.json` | ✅ | catalog /verify 추가 |
| `README.md` (통합 점검) | ✅ | build-error-resolver 모델 수정 |

### 수정 내역

**catalog.json git-workflow description (MEDIUM)**: Round 1에서 /verify 추가 후 catalog 미반영. `/plan → /code-review → /commit` → `/plan → /code-review → /verify → /commit`.

**README.md build-error-resolver 모델 (MEDIUM)**: Round 1/3에서 opus 변경 후 README만 미반영. `sonnet` → `opus`.

---

## 통합 정합성 점검

### 재시도 횟수 3회

| 파일 | 값 | 수정 Round |
|------|-----|-----------|
| `modules/agents/verify-agent.md` | max 3 rounds | R2 |
| `modules/commands/verify.md` | 최대 3라운드 | R4 |
| `modules/commands/verify-loop.md` | 기본 3, 예시 N/3 | R2+R5 |
| `catalog.json` | 최대 3회 | 원본 OK |
| `README.md` | 최대 3회 | 원본 OK |
| `templates/CLAUDE.md.tmpl` | 최대 3회 | 원본 OK |

### REFACTOR → IMPROVE

| 파일 | 수정 Round |
|------|-----------|
| `modules/rules/golden-principles.md` | 원본 (IMPROVE) |
| `modules/rules/testing.md` | 원본 OK |
| `modules/agents/tdd-guide.md` | R3 |
| `modules/commands/tdd.md` | R5 |
| `catalog.json` | R1 |
| `README.md` | R1 |
| `templates/CLAUDE.md.tmpl` | R1 |

### 에이전트 모델

| Agent | agents-v2 | frontmatter | README |
|-------|-----------|-------------|--------|
| planner | opus | opus | opus |
| code-reviewer | opus | opus | opus |
| verify-agent | sonnet | sonnet | sonnet |
| architect | opus | opus | opus |
| build-error-resolver | opus (R1) | opus (R3) | opus (R7) |
| refactor-cleaner | sonnet | sonnet | sonnet |
| security-reviewer | opus | opus | opus |
| tdd-guide | opus | opus | opus |
