---
description: TDD 워크플로우를 실행합니다. RED → GREEN → REFACTOR 사이클.
---

# /tdd

> tdd-guide 에이전트를 호출하여 테스트 주도 개발 사이클을 실행.

## 사용법

```
/tdd <description>
```

- `description`: 구현할 기능 또는 수정할 버그 설명

## 실행 절차

### Step 1: 요구사항 분석

1. 설명으로부터 테스트 가능한 요구사항 도출
2. 관련 기존 코드 탐색 (Grep/Glob)
3. 기존 테스트 확인

### Step 2: RED — 실패 테스트 작성

1. 요구사항을 테스트로 변환
2. 엣지 케이스 포함 (null, 경계값, 에러 등)
3. 테스트 실행 → **반드시 실패 확인**

```
❌ RED: 3 tests written, 3 failing
   - test_create_user_with_valid_data
   - test_create_user_with_duplicate_email
   - test_create_user_with_invalid_format
```

### Step 3: GREEN — 최소 구현

1. 테스트를 통과하는 **최소한의** 코드 작성
2. 최적화, 리팩토링 금지 — 통과만 목표
3. 테스트 실행 → **반드시 통과 확인**

```
✅ GREEN: 3/3 tests passing
```

### Step 4: REFACTOR — 개선

1. 모든 테스트가 통과하는 상태에서만 리팩토링
2. 코드 구조, 가독성, 성능 개선
3. 매 변경 후 테스트 재실행 → 통과 유지 확인

```
♻️ REFACTOR: Code improved, 3/3 tests still passing
```

### Step 5: 결과 보고

```
## /tdd 완료

- 기능: 사용자 생성 API
- 사이클: RED → GREEN → REFACTOR ✅
- 테스트: 3 written (unit: 2, integration: 1)
- 커버리지: 87%

### 다음 단계
- /code-review: 코드 리뷰
- /verify-loop: 전체 검증
- /commit: 커밋
```

## 주의사항

- 테스트가 즉시 통과하면 멈추고 원인 분석 (기능이 이미 존재하거나 테스트가 잘못됨)
- 구현 중 테스트를 수정하지 마라 (구현을 수정하라)
- 커버리지 80% 미만이면 테스트 추가 후 진행
