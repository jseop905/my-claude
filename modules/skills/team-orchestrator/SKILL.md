---
name: team-orchestrator
description: Agent Teams 오케스트레이션 엔진 - 팀 구성, 작업 분배, 의존성 관리, 결과 집계
---

## Overview

team-orchestrator 스킬은 `/orchestrate` 커맨드의 핵심 엔진으로,
다중 에이전트를 구성하고 작업을 분배하며 결과를 집계하는 오케스트레이션 로직을 정의한다.

---

## Team Composition

### 팀 크기 결정

최대 팀원 수: 리더 1 + 팀원 3 (총 4명)

| 작업 규모 | 팀원 수 | 구성 |
|-----------|---------|------|
| 소 (파일 1-3개) | 1-2명 | 구현1 (+테스트1) |
| 중 (파일 4-8개) | 2-3명 | 구현1-2 + 테스트1 |
| 대 (파일 9개 이상) | 3명 | 구현2 + 테스트1 또는 패턴별 분리 |

### 역할 템플릿

**풀스택 기능 구현:**

| 역할 | subagent_type | 담당 |
|------|--------------|------|
| Frontend Dev | general-purpose | UI 구현, 컴포넌트 |
| Backend Dev | general-purpose | API, DB, 로직 |
| QA Engineer | general-purpose | 테스트, 검증 |

**리팩토링:**

| 역할 | subagent_type | 담당 |
|------|--------------|------|
| Analyzer | Explore | 코드 분석/계획 |
| Implementer | general-purpose | 리팩토링 실행 |
| Verifier | general-purpose | 테스트/검증 |

**버그 조사:**

| 역할 | subagent_type | 담당 |
|------|--------------|------|
| Investigator 1 | Explore | 코드 분석 |
| Investigator 2 | Explore | 로그/환경 분석 |
| Fixer | general-purpose | 수정 구현 |

---

## Task Distribution

### 파일 소유권 분리 (CRITICAL)

같은 파일을 2명이 편집하면 덮어쓰기가 발생한다.
반드시 팀원별로 파일 소유권을 분리한다.

```
파일 소유권 결정 로직:
  1. 변경 예상 파일 목록 생성
  2. 파일별 모듈/도메인 분류
  3. 도메인 단위로 팀원 배정
  4. 공유 파일(types, config)은 한 팀원에게 독점 배정
```

### 작업 분해 규칙

팀원당 5-6개 Task를 배정한다.

| Task 크기 | 판단 기준 | 설명 |
|-----------|----------|------|
| 너무 작음 | 조율 오버헤드 > 이점 | 하나로 합치기 |
| 적절함 | 명확한 결과물이 있는 자체 포함 단위 | 함수, 테스트 파일, 검토 |
| 너무 큼 | 체크인 없이 오래 작동 | 더 작게 분할 |

### 의존성 관리

```
의존성 그래프 생성:
  Task A (types 정의) → Task B (API 구현) → Task C (UI 연동)

  선행 Task가 완료되어야 후행 Task 시작 가능
  순환 의존성 감지 시 경고
```

---

## Context Inheritance (CRITICAL)

서브에이전트는 프로젝트 컨텍스트(CLAUDE.md, rules, skills)를 자동 로드하지만,
**리더의 대화 기록은 상속하지 않는다.**

따라서 팀원 생성 프롬프트에 반드시 다음을 포함해야 한다:
- 작업 목적과 배경
- 관련 파일 경로
- 기대하는 결과물
- 주의사항/제약사항

```
# 좋은 예시
"Review the authentication module at src/auth/ for security vulnerabilities.
Focus on token handling, session management, and input validation.
The app uses JWT tokens stored in httpOnly cookies."

# 나쁜 예시
"보안 검토 해줘"  ← 팀원은 리더가 논의한 맥락을 모름
```

---

## Execution Flow

### 1. 분석 단계

```
1. prompt_plan.md / 사용자 요청 읽기
2. 변경 필요 파일 목록 생성
3. 파일별 도메인 분류
4. 작업 복잡도 추정
```

### 2. 팀 구성 단계

```
1. 작업 규모에 따른 팀원 수 결정
2. 역할 템플릿 선택
3. 각 팀원에게 subagent_type 배정
4. 파일 소유권 분리
```

### 3. 에이전트 생성 단계

```
# Agent 도구로 팀원 생성
for member in team:
  Agent(
    subagent_type=member.type,
    prompt=member.detailed_prompt,
    description=member.role
  )
```

각 에이전트의 프롬프트에는 다음을 포함:
- 담당 파일 목록 (소유권 범위)
- 구체적 작업 지시
- 완료 기준
- 다른 팀원의 파일에 쓰지 않도록 제약

### 4. 실행 단계

```
1. 팀원 Agent들을 병렬 실행
2. 리더는 조율만 수행 (직접 구현 금지)
3. 각 팀원이 자신의 담당 파일만 수정
4. 완료 시 결과 반환
```

### 5. 결과 집계 단계

```
1. 모든 팀원의 작업 완료 확인
2. 파일 충돌 여부 검증 (git status)
3. 통합 빌드/테스트 실행
4. 결과 요약 생성
```

---

## Result Aggregation

### 성공 판단 기준

```
전체 성공 조건:
  1. 모든 에이전트가 정상 완료
  2. 빌드 성공
  3. 타입 체크 통과 (해당되는 경우)
  4. 테스트 통과
```

### 부분 실패 처리

```
부분 실패 시:
  1. 실패한 에이전트 식별
  2. 실패 원인 분석 (의존성 문제, 파일 충돌 등)
  3. 새 에이전트로 재시도 (최대 2회)
  4. 재시도 실패 시 리더가 직접 해결
```

### 집계 출력 형식

```
════════════════════════════════════════════════════
  Team Orchestration Result
════════════════════════════════════════════════════

  팀원: [N]명
  총 Task: [N]개
  완료: [N]개 | 실패: [N]개

  팀원별 결과:
    [역할 1]: [완료]/[배정] - [상태]
    [역할 2]: [완료]/[배정] - [상태]
    [역할 3]: [완료]/[배정] - [상태]

  빌드: [PASS/FAIL]
  테스트: [PASS/FAIL]

  다음 단계:
    /verify → /commit

════════════════════════════════════════════════════
```

---

## Error Recovery

### 에이전트 실패

```
1. 에러 메시지 분석
2. 같은 프롬프트로 새 에이전트 재시도 (1회)
3. 재시도 실패 시 리더에게 보고 → 수동 해결
```

### 파일 충돌 감지

```
1. git status로 충돌 감지
2. 한 에이전트에게 해당 파일 소유권 위임
3. 다른 에이전트는 충돌 파일 수정 금지
```

### 의존성 데드락

```
1. 순환 의존성 감지
2. 의존성 체인에서 가장 독립적인 Task 우선 실행
3. 리더가 수동으로 의존성 해소
```

---

## Integration

### /orchestrate 연동

`/orchestrate` 커맨드가 이 스킬을 호출하여:
1. prompt_plan.md 기반 작업 분해
2. 팀 구성 및 작업 배정
3. 실행 및 결과 집계

### /verify 연동

팀 작업 완료 후 `/verify`로 통합 검증을 수행한다.
