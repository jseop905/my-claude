# Git Workflow

> 커밋 포맷, 작업 흐름, PR 가이드.
>
> 관련: `golden-principles.md` — 원칙 9(HARD-GATE: 3파일 이상 변경 시 `/plan` 먼저)

## Commit Message Format

```
<type>: <description>

<optional body>
```

### Types

| Type | 용도 |
|------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 기능 변경 없는 코드 개선 |
| docs | 문서 변경 |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정, 의존성 등 |
| perf | 성능 개선 |
| ci | CI/CD 설정 변경 |

### 규칙

- description은 소문자로 시작, 마침표 없음
- 현재형 사용 ("add" not "added")
- 50자 이내 (description)
- body가 필요하면 빈 줄 후 작성

### 예시

```
feat: add user authentication endpoint

Implement JWT-based auth with refresh token rotation.
Includes login, logout, and token refresh endpoints.
```

## Feature Implementation Workflow

```
/plan → 구현 → /code-review → /verify → /commit
```

1. **계획 수립** (`/plan`)
   - planner 에이전트로 구현 계획 작성
   - 의존성과 리스크 파악
   - 단계별 분리
   - **사용자 승인 전까지 코드 작성 금지**

2. **구현 (TDD)**
   - 테스트 먼저 작성 (RED)
   - 최소 구현으로 통과 (GREEN)
   - 리팩토링 (IMPROVE)

3. **코드 리뷰** (`/code-review`)
   - 코드 작성 직후 실행
   - CRITICAL/HIGH 이슈 해결 필수
   - MEDIUM 이슈는 가능하면 해결

4. **검증** (`/verify`)
   - TypeCheck → Lint → Build → Test 파이프라인 실행
   - 전체 통과 확인 후 커밋 진행

5. **커밋** (`/commit`)
   - Conventional Commits 포맷
   - 변경 내역 분석 후 자동 메시지 생성

## Pull Request 가이드

PR 작성 시:
1. 전체 커밋 히스토리 분석 (최신 커밋만이 아닌 전체)
2. `git diff [base-branch]...HEAD`로 전체 변경 확인
3. 요약 + 테스트 계획 포함
4. 새 브랜치면 `-u` 플래그로 push
