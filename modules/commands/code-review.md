---
description: 변경된 코드를 보안+품질 리뷰합니다.
---

# /code-review

code-reviewer 에이전트를 호출하여 커밋되지 않은 변경사항을 리뷰한다.

## 실행 절차

1. **변경 파일 수집**
   ```bash
   git diff --name-only HEAD
   ```

2. **Stage 1 — 스펙 준수 (필수 먼저)**
   - 요구사항을 모두 구현했는가?
   - 올바른 문제를 해결했는가?
   - 누락되거나 불필요한 것은?

3. **Stage 2 — 코드 품질**
   각 파일에 대해 체크:

   **Security (CRITICAL):**
   - 하드코딩된 자격증명 (API 키, 비밀번호, 토큰)
   - SQL 인젝션 취약점
   - XSS 취약점
   - 누락된 입력 검증
   - Path traversal 위험

   **Code Quality (HIGH):**
   - 50줄 초과 함수
   - 800줄 초과 파일
   - 4단계 초과 중첩
   - 누락된 에러 처리
   - 디버그 출력문
   - 뮤테이션 패턴

   **Best Practices (MEDIUM):**
   - 새 코드에 테스트 누락
   - 비효율적 알고리즘

4. **리포트 생성**
   - 심각도: CRITICAL / HIGH / MEDIUM / LOW
   - 파일 위치와 라인 번호
   - 이슈 설명
   - 수정 제안

5. **판정**
   - **APPROVE**: CRITICAL/HIGH 이슈 없음
   - **REQUEST CHANGES**: CRITICAL/HIGH 이슈 발견
   - **COMMENT**: MEDIUM 이슈만 (주의하여 진행 가능)

## 핵심 규칙

- CRITICAL/HIGH 이슈가 있으면 커밋 차단
- 보안 취약점이 있는 코드는 절대 승인하지 않음
- Stage 1(스펙 준수)을 건너뛰고 스타일 지적부터 하지 않음

## 다음 단계

| 리뷰 후 | 명령어 |
|:--------|:-------|
| 커밋 | `/commit` |
