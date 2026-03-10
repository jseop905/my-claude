---
description: 변경 내역을 분석하여 Conventional Commits 형식으로 커밋합니다.
---

# /commit

변경사항을 분석하고 Conventional Commits 형식으로 커밋 메시지를 자동 생성한 후 커밋한다.

## 실행 절차

### 1단계: 컨텍스트 수집

```bash
git status --short
git branch --show-current
git log --oneline -3
git diff --staged --stat 2>/dev/null || git diff --stat
```

### 2단계: 사전 체크

**변경사항 없으면:**
```
커밋할 변경사항이 없습니다.
현재 브랜치: [브랜치명]
마지막 커밋: [커밋 메시지]
```
→ 중단

**main/master 브랜치면:**
```
⚠ main 브랜치에서 직접 커밋하려고 합니다.

옵션:
1. "브랜치 생성" - 새 브랜치 만들고 진행
2. "계속" - main에 직접 커밋
3. "취소" - 작업 중단
```

### 3단계: 보안 검증

변경 파일에서 시크릿 하드코딩 검사:

| 패턴 | 설명 |
|------|------|
| `sk-`, `pk_`, `AKIA` | API 키 |
| `ghp_`, `gho_`, `github_pat_` | GitHub 토큰 |
| `xoxb-`, `xoxp-` | Slack 토큰 |
| `password\s*=\s*["']` | 하드코딩 비밀번호 |
| `-----BEGIN.*PRIVATE KEY-----` | 개인 키 |

**시크릿 발견 시 → 커밋 차단:**
```
⛔ 보안 검증 실패 — 커밋 차단

발견된 시크릿:
  [파일:라인] [패턴 설명]

수정 방법:
  환경 변수로 이동하세요.
```

### 4단계: 커밋 메시지 생성

변경 내역을 분석하여 Conventional Commits 형식으로 메시지 생성:

```
<type>: <description>

<optional body>
```

**타입 결정 기준:**

| Type | 조건 |
|------|------|
| feat | 새 기능, 새 파일, 새 엔드포인트 |
| fix | 버그 수정, 에러 처리 추가 |
| refactor | 기능 변경 없는 코드 구조 개선 |
| docs | 문서, 주석 변경 |
| test | 테스트 추가/수정 |
| chore | 설정, 의존성, 빌드 도구 |
| perf | 성능 개선 |
| ci | CI/CD 설정 |

### 5단계: 스테이징 & 커밋

```bash
# 변경 파일 스테이징
git add [changed files]

# 커밋
git commit -m "<generated message>"
```

### 6단계: 결과 출력

```
✓ 커밋 완료
  브랜치: [브랜치명]
  커밋: [hash] <type>: <description>
  변경: [N] files changed, [+]insertions, [-]deletions
```

## 핵심 규칙

- **커밋만 담당** (push, PR 생성은 별도)
- 시크릿 하드코딩 발견 시 무조건 차단
- 사용자 인자로 커밋 메시지를 전달하면 해당 메시지 사용 (자동 생성 대신)
