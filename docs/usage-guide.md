# 사용 설명서

my-claude 모듈의 명령어, 에이전트, 훅, 스킬에 대한 사용법 안내.

---

## 목차

1. [슬래시 명령어](#슬래시-명령어)
   - [/overview](#overview) — 프로젝트 구조 분석
   - [/plan-from-spec](#plan-from-spec) — 기획 문서 → 구현 계획 변환
   - [/plan](#plan) — 구현 계획 수립
   - [/code-review](#code-review) — 코드 리뷰
   - [/verify](#verify) — 빌드/테스트/린트 검증
   - [/commit](#commit) — 커밋 생성
   - [/auto](#auto) — 풀 파이프라인 자동화
   - [/build-fix](#build-fix) — 빌드 에러 수정
   - [/next-task](#next-task) — 다음 태스크 추천
   - [/orchestrate](#orchestrate) — 병렬 에이전트 오케스트레이션
   - [/tdd](#tdd) — TDD 워크플로우
   - [/verify-loop](#verify-loop) — 반복 검증 + 자동 수정
2. [에이전트](#에이전트)
3. [훅](#훅)
4. [스킬](#스킬)
5. [파이프라인 조합 예시](#파이프라인-조합-예시)

---

## 슬래시 명령어

### /overview

프로젝트 구조를 분석하여 `docs/overview/` 하위에 인덱스 + 모듈 파일을 생성한다.

```
/overview                        # 전체 신규 생성
/overview --update               # 변경된 모듈만 재분석
/overview --module <module-name> # 특정 모듈만 재생성
```

**출력 구조:**
```
docs/overview/
├── project-overview.md    ← 인덱스 (디렉토리 구조, 모듈 요약, 의존성, 진입점)
└── modules/
    ├── auth.md            ← 모듈 상세 (파일 목록, 공개 인터페이스, 내부 흐름)
    ├── api.md
    └── ...
```

**동작 흐름:**
1. Glob으로 전체 디렉토리 트리 수집 (빌드 산출물 제외)
2. 모듈별 상세 분석 → `docs/overview/modules/{module}.md` 생성
3. 모듈 요약을 종합하여 인덱스 `project-overview.md` 생성
4. 사용자 확인 후 저장

**다른 명령어와의 연동:**
- `/plan`, `/plan-from-spec` 등이 인덱스를 먼저 읽고, 필요한 모듈 파일만 추가 로드
- overview가 없으면 기존 방식(전체 스캔)으로 폴백

**참고:**
- 코드 전체를 복사하지 않음 — 구조, 역할, 인터페이스만 기록
- `docs/overview/`는 `.gitignore`에 추가 권장 (생성된 파일)

---

### /plan-from-spec

기획 문서(spec, PRD, 기획서)를 읽어 `docs/plans/prompt_plan.md` 형식의 구현 계획으로 변환한다.

```
/plan-from-spec docs/spec.md                       # 전체 변환
/plan-from-spec docs/spec.md --scope "사용자 인증"   # 특정 섹션만
/plan-from-spec docs/spec.md --milestone-only       # 마일스톤 목록만
```

**지원 형식:** `.md`, `.txt`, `.pdf`, `.mdx`, `.rst`, `.adoc`, `.ipynb`

**동작 흐름:**
1. 기획 문서를 읽고 요구사항 추출 (기능/비기능/우선순위/의존성)
2. `docs/overview/` 있으면 인덱스 기반으로 코드베이스 매핑, 없으면 전체 스캔
3. 요구사항을 마일스톤으로 분할 (마일스톤당 3-8개 태스크)
4. `docs/plans/prompt_plan.md` 형식으로 생성
5. 사용자 확인 후 저장

**모호함 처리:**
- 해석이 불명확한 항목은 `[CLARIFY]` 태그로 표시
- 계획 출력 시 별도 Clarifications 섹션으로 질문 정리
- 사용자 답변 후 계획 업데이트

**입력 검증 (5종):**
| 검증 | 실패 시 |
|------|---------|
| 경로 누락 | 사용법 안내 후 중단 |
| 파일 미존재 | 유사 파일 제안 |
| 미지원 형식 | 지원 형식 안내 |
| 빈 파일 | 안내 후 중단 |
| `--scope` 섹션 미발견 | 존재하는 섹션 목록 제안 |

**참고:**
- 기획 문서를 충실히 반영 — 임의로 기능 추가/삭제 금지
- 기존 `docs/plans/prompt_plan.md`가 있으면 "Previous Plan" 섹션으로 아카이브

---

### /plan

구현 계획을 수립한다. planner 에이전트를 호출하여 3~6단계 계획을 작성하고 사용자 승인을 받는다.

```
/plan
```

**동작 흐름:**
1. 사용자 요청을 분석하고 코드베이스를 자동 조사
2. 우선순위/범위에 대해서만 질문 (코드베이스 관련 질문은 직접 조사)
3. 3~6단계 구현 계획 생성
4. 사용자 승인 후 `docs/plans/prompt_plan.md`에 저장

**사용 시점:** 3개 이상 파일을 변경하는 작업 전.

**참고:**
- 승인 전까지 코드 작성 없음
- 기존 `docs/plans/prompt_plan.md`가 있으면 "이전 계획" 섹션으로 아카이브
- 계획 수정 시 "modify: [내용]" 또는 "Phase 2를 먼저 진행" 등으로 요청

---

### /code-review

커밋되지 않은 변경사항을 리뷰한다. code-reviewer 에이전트가 2단계로 검사한다.

```
/code-review
```

**동작 흐름:**
1. `git diff`로 변경 파일 수집
2. **Stage 1 — 스펙 준수:** 요구사항 충족 여부 확인
3. **Stage 2 — 코드 품질:** 보안(CRITICAL), 코드 품질(HIGH), 모범 사례(MEDIUM) 검사
4. 심각도별 이슈 리포트 생성

**판정 기준:**
| 판정 | 조건 |
|------|------|
| APPROVE | CRITICAL/HIGH 이슈 없음 |
| REQUEST CHANGES | CRITICAL/HIGH 이슈 발견 |
| COMMENT | MEDIUM 이슈만 (주의하여 진행 가능) |

**참고:** CRITICAL/HIGH 이슈가 있으면 커밋을 차단한다.

---

### /verify

빌드/테스트/린트를 fresh-context에서 검증한다. verify-agent 서브에이전트를 별도 컨텍스트로 스폰한다.

```
/verify              # 기본 (loop 모드: 자동 수정 + 재시도)
/verify --once       # 단일 패스, 보고만
/verify --extract    # 에러 목록만 추출
/verify --coverage   # 테스트 커버리지 분석
```

**검증 순서:** TypeCheck → Lint → Build → Test

**모드 설명:**
| 모드 | 동작 |
|------|------|
| loop (기본) | 에러 자동 수정 + 재시도 (최대 3라운드, 에러당 1회 재시도) |
| once | 한 번 실행하고 결과만 보고 |
| extract | 에러 목록만 추출, 수정 없음 |
| coverage | 테스트 커버리지 분석 |

**자동 수정 대상:** import 오류, 린트 포맷, 미사용 변수, 단순 타입 에러
**수동 수정 필요:** 비즈니스 로직, 아키텍처 이슈

---

### /commit

변경사항을 분석하여 Conventional Commits 형식으로 커밋한다.

```
/commit              # 자동 메시지 생성
/commit fix: 로그인 버그 수정    # 직접 메시지 지정
```

**동작 흐름:**
1. `git status`, `git diff` 로 변경사항 파악
2. main/master 브랜치일 경우 경고 (브랜치 생성 제안)
3. 시크릿 패턴 검사 (API 키, 토큰, 비밀번호 등 → 발견 시 차단)
4. 변경 내역 분석하여 커밋 타입 자동 결정
5. 스테이징 및 커밋

**커밋 타입:**
| 타입 | 용도 |
|------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 구조 개선 (동작 변경 없음) |
| docs | 문서 변경 |
| test | 테스트 추가/수정 |
| chore | 설정, 의존성 |
| perf | 성능 개선 |
| ci | CI/CD |

**참고:** 커밋만 담당한다. push나 PR 생성은 별도.

---

### /auto

풀 파이프라인을 자동 실행한다. 모드에 따라 단계가 달라진다.

```
/auto feature 사용자 인증 API    # feature 모드 (기본)
/auto bugfix 로그인 실패 이슈    # bugfix 모드
/auto refactor 인증 모듈 정리    # refactor 모드
```

**모드별 파이프라인:**

| 모드 | 파이프라인 |
|------|-----------|
| feature | /plan → /tdd → /code-review → /verify-loop → /commit |
| bugfix | 탐색(architect) → /tdd → /verify-loop → /commit |
| refactor | refactor-cleaner → /code-review → /verify-loop → /commit |

**동작 규칙:**
- **Ultrawork 모드**: 진행 중 불필요한 질문 없음
- feature 모드의 Plan 단계에서만 사용자 승인 필요
- 단계 실패 시 즉시 중단 (다음 단계로 넘어가지 않음)
- Fixable 에러는 최대 3회 자동 재시도
- CRITICAL 보안 이슈만 파이프라인 중단 사유

---

### /build-fix

빌드 에러를 점진적으로 수정한다. build-error-resolver 에이전트를 호출한다.

```
/build-fix
```

**동작 흐름:**
1. 빌드 명령어 실행 후 에러 수집
2. 에러를 하나씩 분석 → 최소 변경으로 수정 → 재빌드로 확인
3. 수정 결과 보고

**중단 조건:**
- 수정 후 새로운 에러 발생 → 롤백 후 보고
- 동일 에러 3회 반복 → 수동 수정 필요로 분류
- 비즈니스 로직 변경이 필요한 에러 → 수동 수정으로 분류

**참고:** 최소 변경만 적용한다. 빌드와 무관한 코드 개선은 하지 않는다.

---

### /next-task

`docs/plans/prompt_plan.md`에서 진행 상황을 파악하고 다음 태스크를 추천한다.

```
/next-task           # 자동 추천
/next-task 3         # 3번 태스크 상세 분석
```

**동작 흐름:**
1. `docs/plans/prompt_plan.md`와 `git status`로 현재 진행 상황 파악
2. 진행률 표시 (완료/진행중/미시작)
3. 의존성이 해결된 태스크 중 다음 작업 추천
4. 복잡도(Small/Medium/Large)와 추천 워크플로우 제안

**복잡도별 추천:**
| 복잡도 | 파일 수 | 추천 워크플로우 |
|--------|---------|---------------|
| Small | 1~2개 | 직접 구현 → /commit |
| Medium | 3~5개 | /auto feature |
| Large | 6개+ | /plan 먼저 → 분할 |

**참고:** `docs/plans/prompt_plan.md`가 없으면 `/plan`으로 먼저 계획을 수립하라고 안내한다.

---

### /orchestrate

복수 태스크를 병렬로 실행한다. team-orchestrator 스킬을 호출한다.

```
/orchestrate feature          # feature 모드
/orchestrate review           # review 모드
/orchestrate --dry-run        # 실행 계획만 출력
```

**동작 흐름:**
1. `docs/plans/prompt_plan.md`에서 태스크 추출 → 의존성 그래프(DAG) 구축
2. 의존성 없는 태스크끼리 웨이브(병렬 실행 그룹)로 묶음
3. 모드별 에이전트 팀 구성 후 웨이브 단위로 병렬 실행
4. 결과 통합 및 충돌 해결

**모드별 팀 구성:**
| 모드 | 리더 | 팀원 |
|------|------|------|
| feature | planner | tdd-guide, code-reviewer |
| bugfix | architect | tdd-guide, verify-agent |
| refactor | architect | refactor-cleaner, code-reviewer |
| review | code-reviewer | security-reviewer, architect |

**안전 규칙:**
- 같은 파일을 수정하는 태스크는 같은 웨이브에 배치하지 않음
- 순환 의존성 발견 시 사용자에게 확인 후 진행
- 2개 이상 연속 실패 시 전체 중단

**`/auto`와의 차이:** `/auto`는 단일 태스크의 순차 실행, `/orchestrate`는 복수 태스크의 병렬 실행.

---

### /tdd

TDD 워크플로우를 실행한다. tdd-guide 에이전트를 호출한다.

```
/tdd 사용자 생성 API 구현
```

**TDD 사이클:**
1. **RED** — 실패하는 테스트 먼저 작성. 반드시 실패를 확인.
2. **GREEN** — 테스트를 통과하는 최소한의 코드 작성. 최적화 금지.
3. **IMPROVE** — 모든 테스트가 통과하는 상태에서만 리팩토링.

**규칙:**
- 테스트가 즉시 통과하면 원인 분석 (기능이 이미 존재하거나 테스트가 잘못됨)
- 구현 중 테스트를 수정하지 않음 (구현을 수정)
- 커버리지 80% 미만이면 테스트 추가 후 진행

---

### /verify-loop

`/verify`의 확장판. 검증 실패 시 자동 수정 후 재검증을 반복한다.

```
/verify-loop                    # 기본 (최대 3회)
/verify-loop --max-retries 5    # 최대 5회
/verify-loop --only build       # 빌드만 검증
```

**`/verify`와의 차이:**
| 항목 | /verify | /verify-loop |
|------|---------|-------------|
| 코드 리뷰 | 없음 | 검증 전 자동 코드 리뷰 포함 |
| 실패 보고 | 단순 FAIL | 반복 에러 추적 + 수동 수정 힌트 |
| 재시도 조정 | 고정 3라운드 | `--max-retries`로 조정 가능 |

**자동 수정 가능:** import, 린트 포맷, 미사용 변수/import, 단순 타입 에러
**수동 수정 필요:** 비즈니스 로직, 설계 변경 필요한 타입 에러

---

## 에이전트

에이전트는 명령어가 내부적으로 호출하는 실행 단위다. 직접 호출하지 않고 명령어를 통해 사용한다.

| 에이전트 | 모델 | 역할 | 호출하는 명령어 |
|----------|:----:|------|---------------|
| planner | opus | 구현 계획 수립 (읽기 전용, 코드 작성 금지) | /plan, /auto feature |
| code-reviewer | opus | 2단계 코드 리뷰 (스펙 준수 → 코드 품질) | /code-review, /auto |
| verify-agent | sonnet | 빌드/테스트/린트 검증 (fresh-context) | /verify, /verify-loop |
| architect | opus | 시스템 설계 & 아키텍처 분석 (읽기 전용) | /orchestrate, /auto bugfix |
| build-error-resolver | opus | 빌드 에러 최소 diff 수정 | /build-fix |
| refactor-cleaner | sonnet | 데드코드 탐지 & 안전한 정리 | /auto refactor |
| security-reviewer | opus | OWASP Top 10 보안 취약점 탐지 | /orchestrate review |
| tdd-guide | opus | RED → GREEN → IMPROVE 사이클 강제 | /tdd, /auto |

---

## 훅

훅은 자동으로 동작한다. `settings.json`에 등록하면 해당 이벤트 발생 시 실행된다.

### PreToolUse 훅 (도구 실행 전 차단)

| 훅 | 동작 |
|----|------|
| **db-guard** | 위험 SQL 차단. `DROP TABLE`, `TRUNCATE`, WHERE 없는 `DELETE`, `ALTER TABLE DROP` 명령을 Bash에서 실행하려 하면 차단. |
| **remote-command-guard** | 원격 세션(SSH)에서 위험 명령어 차단. `rm -rf`, 환경변수 노출, 민감 시스템 경로 접근, 외부 네트워크 통신, 권한 변경, 프로세스 종료 등을 차단. SSH 세션이 아니면 동작하지 않음. |

### PostToolUse 훅 (도구 실행 후 알림)

| 훅 | 동작 |
|----|------|
| **secret-filter** | 도구 출력에서 시크릿 감지 및 마스킹. API 키(OpenAI, AWS, GitHub, Slack 등), Bearer 토큰, 비밀번호, 개인 키를 3계층(원본/Base64/URL 디코딩)으로 탐지. 감지 시 마스킹 처리하고 `.claude/security.log`에 기록. |
| **security-auto-trigger** | 보안 관련 파일(auth, session, jwt, .env, migration 등) 수정 시 `/code-review` 실행을 제안. 세션당 1회만 제안. |
| **code-quality-reminder** | 코드 파일 수정 후 품질 체크 리마인더 출력. 60초 간격으로 스로틀링하여 과도한 알림 방지. |

### Notification 훅

| 훅 | 동작 |
|----|------|
| **notify** | Notification 이벤트 발생 시 Windows 토스트 알림 발송. 타입별 메시지: 권한 요청(`permission_prompt`), 유휴(`idle_prompt`), 추가 입력(`elicitation_dialog`), 작업 완료(`task_completed`). 동일 타입 5초 이내 중복 방지. Python + PowerShell 필요. |

### Stop 훅 (세션 종료 시)

| 훅 | 동작 |
|----|------|
| **session-wrap-suggest** | 세션 중 도구 사용이 30회 이상일 때 `/session-wrap` 실행을 제안. 세션당 1회만 제안. |

---

## 스킬

### /session-wrap

세션 종료 시 자동 정리를 수행한다. 4개 서브에이전트를 병렬로 실행한다.

```
/session-wrap                # 전체 실행
/session-wrap --dry-run      # 미리보기만 (실제 적용 없음)
/session-wrap --skip-docs    # 문서 업데이트 건너뛰기
```

**서브에이전트:**
| 에이전트 | 역할 |
|----------|------|
| doc-updater | 변경사항에 맞게 문서 업데이트 제안 |
| automation-scout | 반복 작업 자동화 후보 탐색 |
| learning-extractor | 세션에서 학습 포인트 추출 |
| followup-suggester | 후속 태스크 제안 |

**동작 흐름:**
1. 컨텍스트 수집 (git diff, 변경 파일, 최근 커밋)
2. 4개 서브에이전트 병렬 실행
3. 중복 제거 및 분류
4. 사용자에게 적용할 항목 선택 요청
5. 선택 항목 실행 후 보고서 생성

**플래그:** `--dry-run`, `--skip-docs`, `--skip-learning`, `--skip-scout`, `--skip-followup`

---

### team-orchestrator

`/orchestrate` 명령어가 내부적으로 호출하는 오케스트레이션 엔진이다. 직접 호출하지 않는다.

팀 규모: 리더 1명 + 팀원 1~3명 (태스크 크기에 따라 자동 조정)
파일 소유권을 분리하여 에이전트 간 충돌을 방지하고, 실패 시 최대 2회 재시도한다.

---

## 파이프라인 조합 예시

### 새 기능 개발 (수동)

```
/plan                           # 계획 수립 → 승인
# 코드 구현
/code-review                    # 리뷰
/verify                         # 검증
/commit                         # 커밋
```

### 새 기능 개발 (자동)

```
/auto feature 사용자 인증 API    # 전체 자동화
```

### 버그 수정

```
/auto bugfix 로그인 실패 이슈
```

### 빌드 깨졌을 때

```
/build-fix                      # 빌드 에러 수정
/verify-loop                    # 전체 검증
/commit                         # 커밋
```

### 기획 문서 기반 개발 (v3)

```
/overview                       # 프로젝트 구조 분석
/plan-from-spec docs/spec.md   # 기획서 → 구현 계획
/auto feature                   # 또는 /orchestrate feature
```

### 대규모 작업 (복수 태스크)

```
/plan                           # 전체 계획 수립
/orchestrate feature            # 병렬 실행
```

### 다음 뭘 해야 할지 모를 때

```
/next-task                      # 다음 태스크 추천
```

### 세션 마무리

```
/session-wrap                   # 문서 정리, 학습 추출, 후속 태스크 정리
```
