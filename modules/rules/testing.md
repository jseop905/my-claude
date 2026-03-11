# Testing Requirements

> 테스트 커버리지와 TDD 워크플로우. 핵심 원칙은 golden-principles.md §3 참조.

## Minimum Test Coverage: 80%

테스트 유형 (모두 필요):

1. **Unit Tests** — 개별 함수, 유틸리티, 컴포넌트
2. **Integration Tests** — API 엔드포인트, 데이터베이스 연산
3. **E2E Tests** — 핵심 사용자 플로우

## Test-Driven Development

필수 워크플로우:

```
1. 테스트 먼저 작성 (RED)
2. 테스트 실행 → 실패 확인
3. 최소한의 구현 작성 (GREEN)
4. 테스트 실행 → 통과 확인
5. 리팩토링 (IMPROVE)
6. 커버리지 확인 (80%+)
```

### 언제 TDD를 적용하는가

| 상황 | TDD | 이유 |
|------|-----|------|
| 새 기능 구현 | 필수 | 요구사항을 테스트로 명확화 |
| 버그 수정 | 필수 | 재현 테스트 먼저 작성 |
| 리팩토링 | 기존 테스트 유지 | 동작 변경 없음을 보장 |
| 프로토타입/탐색 | 선택 | 방향 확정 후 테스트 추가 |

## Troubleshooting Test Failures

1. **tdd-guide 에이전트 사용** — 테스트 실패 분석 전문
2. **테스트 격리 확인** — 다른 테스트의 부작용이 영향을 주는지
3. **Mock 정확성 검증** — 실제 동작과 Mock이 일치하는지
4. **구현을 수정하라, 테스트를 수정하지 마라** — 테스트 자체가 틀린 경우만 예외

## Test Naming Convention

테스트 이름은 **무엇을 검증하는지** 명확히 드러내야 한다:

```
# BAD
test_user()
test_error()

# GOOD
test_create_user_with_valid_email_returns_201()
test_create_user_with_duplicate_email_returns_409()
test_delete_user_without_auth_returns_401()
```

## Anti-Patterns

| 패턴 | 문제 | 대안 |
|------|------|------|
| 구현 후 테스트 | 통과하는 테스트만 작성하게 됨 | TDD: 실패 테스트 먼저 |
| 테스트 간 상태 공유 | 실행 순서에 의존하는 불안정한 테스트 | 각 테스트에서 독립 setup/teardown |
| 과도한 Mocking | 실제 동작과 괴리 | 통합 테스트로 실제 의존성 테스트 |
| 스냅샷 남용 | 무의미한 변경에 매번 업데이트 | 핵심 출력만 assertion |
