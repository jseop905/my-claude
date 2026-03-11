# Coding Style

> 코드 품질 기준. code-reviewer 에이전트가 리뷰 시 참조.
>
> 관련: `golden-principles.md` — 원칙 1(불변성), 5(작은 파일/함수), 6(시스템 경계 검증)

## 불변성 (CRITICAL)

새 객체/데이터를 생성하라. 원본을 직접 수정하지 마라.

```
# WRONG: Mutation
def update_user(user, name):
    user["name"] = name   # MUTATION!
    return user

# CORRECT: Immutability
def update_user(user, name):
    return {**user, "name": name}
```

> 언어에 관계없이 원칙은 동일: 원본 변경 대신 복사 후 수정.

## 파일 구조

MANY SMALL FILES > FEW LARGE FILES:
- 높은 응집도, 낮은 결합도
- 200-400줄 정상 범위, 400줄 초과 시 분리 검토, 800줄 절대 최대
- 큰 컴포넌트에서 유틸리티 추출
- 타입별이 아닌 기능/도메인별 조직

## 에러 처리

시스템 경계(사용자 입력, 외부 API, I/O)에서는 항상 에러를 처리하라:

```
try:
    result = risky_operation()
    return result
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise AppError("사용자 친화적 메시지") from e
```

- 내부 코드 간 호출에는 불필요한 try-catch를 추가하지 마라
- 에러 메시지는 사용자가 이해할 수 있게 작성하라

## 입력 검증

시스템 경계에서 사용자 입력을 검증하라:

```
# 스키마 기반 검증 (언어별 도구 사용)
# Python: pydantic, marshmallow
# TypeScript: zod, yup
# Go: validator
# Java: Bean Validation
```

- 내부 함수 간 전달에는 중복 검증하지 마라
- 시스템 경계(API 엔드포인트, CLI 입력, 파일 읽기)에서 한 번만 검증

## Pre-Completion 체크리스트

작업 완료 전 확인:
- [ ] 함수 50줄 이하
- [ ] 파일 800줄 이하
- [ ] 중첩 4단계 이하
- [ ] 디버그용 출력문 제거
- [ ] 하드코딩된 값 없음
- [ ] 불변 패턴 사용
- [ ] 시스템 경계에서 에러 처리 완료
- [ ] 코드가 읽기 쉽고 이름이 명확함
