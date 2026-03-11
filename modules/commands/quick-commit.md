---
description: 작은 변경을 빠르게 커밋합니다. 보안 체크 유지, 메시지 자동 생성.
---

# /quick-commit

> /commit의 간소화 버전. 작은 변경(1-3 파일)에 최적화.
> 보안 검사는 유지하되, 프로세스를 최소화.

## 사용법

```
/quick-commit <message>
/quick-commit
```

- `message` 제공 시: 해당 메시지로 즉시 커밋
- `message` 없을 시: 변경 내역 분석 후 자동 생성

## 실행 절차

### Step 1: 변경 확인

1. `git diff --stat`으로 변경 범위 확인
2. 변경 파일 3개 초과 또는 변경 줄 20줄 초과 시 경고:
   ```
   ⚠ 변경이 큽니다 (N files, M lines). /commit 사용을 권장합니다.
   계속 진행할까요?
   ```

### Step 2: 보안 빠른 검사

변경된 파일에서만 시크릿 패턴 검사:
- API 키 패턴: `sk-`, `pk_`, `AKIA`, `ghp_`, `xoxb-`
- 비밀번호 패턴: `password=`, `secret=`, `token=`
- 감지 시: **즉시 중단**, 제거 후 재실행 안내

### Step 3: 커밋 실행

1. 변경 파일 스테이징 (`git add`)
2. 커밋 메시지 결정 (사용자 제공 또는 자동 생성)
3. `git commit` 실행

### Step 4: 출력

```
✅ abc1234 fix: correct validation logic

  1 file changed, 3 insertions(+), 1 deletion(-)
```

## /commit과의 차이

| 항목 | /commit | /quick-commit |
|------|---------|---------------|
| 대상 | 모든 크기의 변경 | 작은 변경 (1-3 파일) |
| 보안 검사 | 전체 패턴 검사 | 변경 파일만 빠른 검사 |
| 메시지 | 전체 분석 후 생성 | 간단 분석 또는 사용자 제공 |
| main 브랜치 경고 | 있음 (3가지 옵션) | 없음 |
| 소요 시간 | 보통 | 빠름 |
