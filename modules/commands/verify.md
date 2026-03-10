---
description: fresh-context에서 빌드/테스트/린트를 검증합니다.
---

# /verify

verify-agent 서브에이전트를 스폰하여 fresh-context에서 코드 변경사항을 검증한다.

## 사용법

```
/verify              # 기본 모드 (loop)
/verify --once       # 단일 패스, 보고만
/verify --extract    # 에러 목록만 추출
/verify --coverage   # 테스트 커버리지 분석
```

## 실행 절차

1. **서브에이전트 스폰** — verify-agent를 fresh-context로 실행
2. **환경 감지** — 프로젝트 타입 자동 감지 (package.json, pyproject.toml, go.mod 등)
3. **파이프라인 실행** — TypeCheck → Lint → Build → Test 순서로 검증
4. **에러 처리** — Fixable 에러는 자동 수정 시도 (loop 모드), Non-Fixable은 보고만
5. **결과 반환** — 구조화된 결과 출력 (PASS / FAIL / EXTRACT / COVERAGE)

## 모드

| 모드 | 설명 |
|:-----|:-----|
| loop (기본) | 에러 수정 + 재시도 (최대 5라운드) |
| once | 단일 패스, 보고만 |
| extract | 에러 목록만 추출, 수정 없음 |
| coverage | 테스트 커버리지 분석 |

## 핵심 규칙

- **증거 없이 완료 주장 금지** — fresh test output이 유일한 증거
- 같은 에러 3회 실패 시 자동 수정 중단
- 라운드당 최대 10개 파일 수정
- Non-Fixable 에러 (로직, 아키텍처)는 수정 시도하지 않음

## 다음 단계

| 검증 결과 | 명령어 |
|:----------|:-------|
| PASS 후 커밋 | `/commit` |
| FAIL 시 수정 후 재검증 | `/verify` |
| 리뷰 필요 시 | `/code-review` |
