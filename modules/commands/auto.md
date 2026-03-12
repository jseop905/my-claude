---
description: 풀 파이프라인을 자동 실행합니다. /plan → /tdd → /code-review → /verify-loop → /commit
---

# /auto

> 단일 태스크의 순차 자동화 파이프라인. 모드별 고정 순서로 단계를 실행하고, 실패 시 중단 & 보고.
> 복수 태스크를 병렬로 처리하려면 `/orchestrate`를 사용.

## 사용법

```
/auto <mode> <description>
```

- `mode`: feature (기본) | bugfix | refactor
- `description`: 작업 설명

## 파이프라인 정의

### feature 모드

```
/plan → /tdd → /code-review → /verify-loop → /commit
```

1. **Plan**: planner 에이전트로 구현 계획 수립 → 사용자 승인 대기
2. **TDD**: tdd-guide 에이전트로 테스트 먼저 작성 → 구현 → 리팩토링
3. **Code Review**: code-reviewer 에이전트로 품질/보안 리뷰
4. **Verify Loop**: verify-agent로 빌드/테스트/린트 검증 (최대 3회 재시도)
5. **Commit**: Conventional Commits 형식으로 커밋

### bugfix 모드

```
탐색 → /tdd → /verify-loop → /commit
```

1. **Explore**: architect 에이전트로 버그 재현 및 원인 분석
2. **TDD**: 재현 테스트 작성 → 수정 → 통과 확인
3. **Verify Loop**: 전체 검증
4. **Commit**: 커밋

### refactor 모드

```
refactor-cleaner → /code-review → /verify-loop → /commit
```

1. **Refactor**: refactor-cleaner 에이전트로 코드 정리
2. **Code Review**: 리팩토링 결과 리뷰
3. **Verify Loop**: 동작 변경 없음 검증
4. **Commit**: 커밋

## 실행 규칙

- **Ultrawork 모드**: 파이프라인 진행 중 불필요한 질문 금지. CRITICAL 보안 이슈만 중단 사유.
- **단계 실패 시**: 즉시 중단하고 실패 보고서 출력. 다음 단계로 넘어가지 않음.
- **자동 수정**: Fixable 에러(import, lint, 단순 타입)는 최대 3회 자동 재시도.
- **사용자 확인 포인트**: feature 모드의 Plan 단계에서만 사용자 승인 필요.

## 출력 형식

```
## /auto 완료 보고

- 모드: feature
- 단계: 5/5 완료
- 커밋: abc1234 feat: add user authentication
- 테스트: 12 passed, 0 failed
- 커버리지: 85%

### 다음 단계
- [ ] PR 생성이 필요하면 알려주세요
```

## 핵심 규칙

- 파이프라인 진행 중 불필요한 질문 금지 (Ultrawork 모드)
- CRITICAL 보안 이슈만 파이프라인 중단 사유
- 단계 실패 시 즉시 중단, 다음 단계로 넘어가지 않음
- feature 모드의 Plan 단계에서만 사용자 승인 필요
- Fixable 에러는 최대 3회 자동 재시도
- 파이프라인 내 독립적 단계가 있다면 속도를 위해 병렬 처리 가능 (예: 린트와 타입체크 동시 실행)
