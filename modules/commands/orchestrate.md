---
description: Agent Teams를 구성하여 복수 태스크를 병렬 실행합니다.
---

# /orchestrate

> 여러 에이전트를 팀으로 구성하여 독립적인 태스크를 병렬로 처리.
> team-orchestrator 스킬을 호출하여 실행.

## 사용법

```
/orchestrate <mode>
/orchestrate --dry-run
```

- `mode`: feature (기본) | bugfix | refactor | review
- `--dry-run`: 실행 계획만 출력, 실제 실행 안 함

## 실행 절차

### Step 1: 태스크 파싱

1. `prompt_plan.md`에서 태스크 목록 추출
2. 각 태스크의 의존성(`depends`) 분석
3. 의존성 그래프(DAG) 구축, 순환 의존성 감지

### Step 2: 웨이브 그룹핑

의존성이 없는 태스크끼리 병렬 실행 가능한 "웨이브"로 묶음:

```
Wave 1: [Task A, Task B, Task C]  ← 의존성 없음, 동시 실행
Wave 2: [Task D, Task E]          ← Wave 1 완료 후 실행
Wave 3: [Task F]                  ← Wave 2 완료 후 실행
```

### Step 3: 팀 구성

모드별 에이전트 역할 배정:

| Mode | 팀 구성 |
|------|---------|
| feature | planner(리더) + tdd-guide + code-reviewer |
| bugfix | architect(리더) + tdd-guide + verify-agent |
| refactor | architect(리더) + refactor-cleaner + code-reviewer |
| review | code-reviewer(리더) + security-reviewer + architect |

### Step 4: 실행 & 통합

1. 웨이브 단위로 에이전트 팀 병렬 실행
2. 각 에이전트는 독립적인 컨텍스트에서 작업
3. 파일 소유권 충돌 방지: 같은 파일을 수정하는 태스크는 같은 웨이브에 배치하지 않음
4. 결과 통합 및 충돌 해결

### Step 5: 결과 보고

```
## /orchestrate 결과

- 모드: feature
- 웨이브: 3개
- 태스크: 6/6 완료
- 충돌: 0건

### 웨이브별 결과
| Wave | Tasks | Status | Duration |
|------|-------|--------|----------|
| 1    | A,B,C | ✅     | 2m 30s   |
| 2    | D,E   | ✅     | 1m 45s   |
| 3    | F     | ✅     | 1m 10s   |
```

## 실패 처리

- **태스크 실패**: 해당 태스크만 중단, 나머지 계속 진행. 의존하는 후속 태스크도 중단.
- **충돌 감지**: 같은 파일 수정 충돌 시 리더 에이전트가 수동 병합 결정.
- **전체 실패**: 2개 이상 태스크 연속 실패 시 전체 중단 & 보고.

## prompt_plan.md 없을 때

`prompt_plan.md`가 없으면:
1. 사용자에게 `/plan`으로 작업 계획을 먼저 수립하도록 안내
2. 또는 사용자의 직접 태스크 입력을 받아 진행

## 핵심 규칙

- 같은 파일을 수정하는 태스크는 같은 웨이브에 배치하지 않음 (파일 소유권 분리)
- 순환 의존성 감지 시 즉시 경고 & 중단
- 각 에이전트는 독립 컨텍스트에서 작업 (대화 기록 미상속)
- 2개 이상 태스크 연속 실패 시 전체 중단
