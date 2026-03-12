---
description: 기획 문서를 읽고 prompt_plan.md로 변환합니다.
---

# /plan-from-spec

> 기획 문서(spec, PRD, 기획서)를 읽어 prompt_plan.md 형식의 구현 계획으로 변환.
> 변환 후 `/auto`, `/orchestrate`, `/next-task`로 바로 연결 가능.

## 사용법

```
/plan-from-spec <file-path>
/plan-from-spec <file-path> --scope <section-name>
/plan-from-spec <file-path> --milestone-only
```

- `file-path`: 기획 문서 경로 (md, pdf, txt 등)
- `--scope`: 특정 섹션만 변환 (예: "사용자 인증")
- `--milestone-only`: 마일스톤 목록만 추출, 상세 계획은 생략

## 입력 검증

Step 1 진입 전에 반드시 수행:

1. **경로 누락**: `file-path`가 없으면 → 안내 후 중단
   ```
   ❌ 기획 문서 경로가 필요합니다.
   사용법: /plan-from-spec <file-path>
   예시: /plan-from-spec docs/spec.md
   ```

2. **파일 존재 확인**: Read로 파일 읽기 시도 → 실패하면 중단
   ```
   ❌ 파일을 찾을 수 없습니다: docs/spec.md
   현재 디렉토리: /workspace/my-project

   유사한 파일:
   - docs/specification.md
   - docs/prd.md
   ```
   - Glob으로 `**/*spec*`, `**/*prd*`, `**/*plan*`, `**/*기획*` 패턴 검색하여 유사 파일 제안

3. **지원 형식 확인**: 확장자가 읽을 수 없는 형식이면 → 안내 후 중단
   - 지원: `.md`, `.txt`, `.pdf`, `.mdx`, `.rst`, `.adoc`, `.ipynb`
   - 미지원: `.docx`, `.pptx`, `.xlsx`, `.hwp` 등
   ```
   ❌ 지원하지 않는 파일 형식입니다: plan.docx
   지원 형식: md, txt, pdf, mdx, rst, adoc, ipynb
   💡 마크다운이나 텍스트로 변환 후 다시 시도해주세요.
   ```

4. **빈 파일 확인**: 파일은 존재하지만 내용이 비어있으면 → 안내 후 중단
   ```
   ❌ 파일이 비어있습니다: docs/spec.md
   기획 내용이 작성된 문서를 지정해주세요.
   ```

5. **`--scope` 섹션 미발견**: 파일은 정상이지만 지정한 섹션이 없으면 → 존재하는 섹션 목록 제안
   ```
   ❌ "사용자 인증" 섹션을 찾을 수 없습니다.

   발견된 섹션:
   - 1. 프로젝트 개요
   - 2. 회원 관리
   - 3. 결제 시스템
   - 4. 알림 기능
   ```

## 실행 절차

### Step 1: 문서 읽기 & 구조 파악

1. 지정된 파일을 Read로 읽기 (PDF는 pages 파라미터 활용)
2. 문서 구조 파악: 목차, 섹션, 요구사항 목록, 우선순위 표시 등
3. `--scope` 지정 시 해당 섹션만 추출

### Step 2: 요구사항 추출

문서에서 다음을 식별:

- **기능 요구사항**: 구현해야 할 기능 목록
- **비기능 요구사항**: 성능, 보안, 접근성 등 제약 조건
- **우선순위**: 문서에 명시된 우선순위 (MVP/Phase 1/P0 등)
- **의존성**: 기능 간 선후 관계
- **기술 제약**: 문서에 명시된 기술 스택, 라이브러리 등

### Step 3: 코드베이스 매핑

1. `project-overview.md` 존재 시 인덱스 읽어 모듈 목록/의존성/진입점 파악
2. 기획서 요구사항과 인덱스의 모듈을 매칭
3. 매칭된 모듈의 `.overview/{module}.md` 로드하여 상세 파일/인터페이스 확인:
   - 이미 존재하는 기능 → 스킵 또는 수정으로 표시
   - 신규 기능 → 생성 대상 파일/모듈 추정
4. 상세 확인이 필요한 소스 파일만 Read로 정밀 탐색
5. overview가 없으면 Grep/Glob으로 전체 프로젝트 구조 조사 (기존 방식 폴백)

### Step 4: 마일스톤 분할

요구사항을 마일스톤으로 그룹핑:

```
## Milestone 1: [이름] (MVP / 핵심 기능)
- Task 1.1: ...
- Task 1.2: ...

## Milestone 2: [이름] (확장 기능)
- Task 2.1: ...
  - depends: Task 1.2
```

분할 기준:
- 문서에 명시된 Phase/단계가 있으면 그대로 사용
- 없으면: 의존성 그래프 기반으로 자동 분할
- 마일스톤당 3-8개 태스크가 적정

### Step 5: prompt_plan.md 생성

아래 형식으로 `prompt_plan.md` 작성:

```markdown
# Implementation Plan: [프로젝트/기능명]

> Source: [기획 문서 경로]
> Generated: [날짜]
> Scope: [전체 | 특정 섹션명]

## Overview
[기획서 요약 2-3줄]

## Milestones

### Milestone 1: [이름]
Priority: HIGH
Status: pending

#### Tasks

- [ ] Task 1.1: [태스크명]
  - Action: [구체적 구현 내용]
  - Files: [대상 파일 목록]
  - Acceptance: [완료 조건]
  - Depends: none

- [ ] Task 1.2: [태스크명]
  - Action: [구체적 구현 내용]
  - Files: [대상 파일 목록]
  - Acceptance: [완료 조건]
  - Depends: Task 1.1

### Milestone 2: [이름]
Priority: MEDIUM
Status: pending
...

## Constraints
- [기획서에서 추출한 비기능 요구사항]
- [기술 제약 사항]

## Out of Scope
- [기획서에 명시적으로 제외된 항목]
```

### Step 6: 사용자 확인

1. 생성된 계획 요약을 출력:
   - 마일스톤 수, 총 태스크 수
   - 각 마일스톤의 핵심 내용 1줄 요약
   - 기획서에서 해석이 모호했던 항목 (있으면)
2. 사용자 확인 대기
3. 확인되면 `prompt_plan.md`에 저장

## 모호함 처리

기획서에서 해석이 불명확한 항목 발견 시:

1. 모호한 항목을 `[CLARIFY]` 태그로 표시
2. 계획 출력 시 별도 섹션으로 질문 정리
3. 사용자 답변 후 계획 업데이트

```
## Clarifications Needed
1. [CLARIFY] "소셜 로그인 지원" → 어떤 provider? (Google, Kakao, Apple 등)
2. [CLARIFY] "실시간 알림" → WebSocket vs SSE vs Polling?
```

## 기존 prompt_plan.md가 있을 때

1. 기존 내용을 "## Previous Plan" 섹션으로 아카이브
2. 새 계획으로 덮어쓰기
3. 안내: "기존 계획이 아카이브되었습니다."

## 다음 단계

| 상황 | 추천 명령어 |
|:-----|:-----------|
| 마일스톤 1부터 순차 실행 | `/auto feature` |
| 독립 태스크 병렬 실행 | `/orchestrate` |
| 다음 태스크 확인 | `/next-task` |
| 특정 마일스톤만 상세 계획 | `/plan` |

## 핵심 규칙

- 기획 문서를 충실히 반영 — 임의로 기능 추가/삭제 금지
- 코드베이스 조사는 도구로 직접 수행 (사용자에게 묻지 않음)
- 모호한 항목은 추측하지 않고 `[CLARIFY]`로 표시
- 사용자가 확인할 때까지 prompt_plan.md에 저장하지 않음
- 마일스톤당 3-8개 태스크 유지
