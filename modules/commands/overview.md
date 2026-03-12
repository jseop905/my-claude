---
description: 프로젝트 구조를 분석하여 project-overview.md + .overview/ 모듈 파일을 생성합니다.
---

# /overview

> 코드베이스를 분석하여 프로젝트 지도를 생성.
> 인덱스(`project-overview.md`) + 모듈 상세(`.overview/*.md`)의 2계층 구조.
> `/plan`, `/plan-from-spec` 등이 인덱스를 먼저 읽고, 필요한 모듈 파일만 추가 로드.

## 사용법

```
/overview
/overview --update
/overview --module <module-name>
```

- 인자 없음: 전체 신규 생성 (기존 파일 있으면 덮어쓰기 확인)
- `--update`: 변경된 모듈만 재분석하여 갱신
- `--module`: 특정 모듈 파일만 재생성

## 출력 구조

```
project-overview.md          ← 인덱스 (디렉토리 구조 + 모듈 요약 + 의존성 + 진입점)
.overview/
├── auth.md                  ← 모듈 상세 (파일 목록, 공개 인터페이스, 내부 흐름)
├── api.md
├── db.md
└── utils.md
```

## 실행 절차

### Step 1: 프로젝트 구조 스캔

1. Glob으로 전체 디렉토리 트리 수집
2. `.gitignore`, `node_modules`, `dist`, `build` 등 빌드 산출물 제외
3. 디렉토리별 파일 수, 주요 파일 식별
4. 모듈 경계 판단: 독립된 디렉토리 단위로 모듈 구분

### Step 2: 모듈별 상세 분석 → `.overview/*.md`

각 모듈에 대해 `.overview/{module-name}.md` 생성:

```markdown
# Module: auth

> Path: src/auth/
> 역할: 사용자 인증 및 세션 관리

## Files

| 파일 | 역할 |
|------|------|
| login.ts | 로그인 로직 (이메일/비밀번호, OAuth) |
| token.ts | JWT 발급, 검증, 갱신 |
| middleware.ts | Express 인증 미들웨어 |
| types.ts | 인증 관련 타입 정의 |

## Public Interface

- `authenticate(email, password): Promise<Token>` — 로그인 처리
- `verifyToken(token): Promise<User>` — JWT 검증
- `authMiddleware(): RequestHandler` — 라우트 보호 미들웨어
- `refreshToken(token): Promise<Token>` — 토큰 갱신

## Internal Flow

1. login.ts → token.ts (토큰 발급)
2. middleware.ts → token.ts (토큰 검증)

## Dependencies

- **사용**: db (사용자 조회), utils/crypto (해싱)
- **사용됨**: api (미들웨어 참조)
```

분석 절차:
1. 진입점 파일 읽기 (index.ts, main.py, mod.rs 등)
2. export/공개 인터페이스 추출
3. import 문 분석으로 내부 흐름 및 의존성 파악
4. 각 파일의 역할을 1줄로 요약

### Step 3: 인덱스 생성 → `project-overview.md`

모듈 상세 파일들을 요약하여 인덱스 작성:

```markdown
# Project Overview

> Generated: [날짜]
> Last updated: [날짜]

## Directory Structure

src/
├── auth/          # 인증 모듈 (JWT, OAuth)
├── api/           # REST API 라우트
├── db/            # 데이터베이스 레이어
└── utils/         # 공통 유틸리티

## Modules

| 모듈 | 경로 | 역할 | 상세 |
|------|------|------|------|
| auth | src/auth/ | 사용자 인증 및 세션 관리 | [.overview/auth.md] |
| api | src/api/ | HTTP 요청 처리 및 응답 | [.overview/api.md] |
| db | src/db/ | 데이터베이스 스키마 및 쿼리 | [.overview/db.md] |
| utils | src/utils/ | 공통 유틸리티 | [.overview/utils.md] |

## Dependencies

auth → db (사용자 조회)
api → auth (인증 미들웨어)
api → db (데이터 CRUD)

## Entry Points

| 타입 | 파일 | 설명 |
|------|------|------|
| API 서버 | src/index.ts | Express 앱 초기화, 라우트 등록 |
| CLI | src/cli.ts | 관리자 CLI 도구 |
| 마이그레이션 | src/db/migrate.ts | DB 스키마 마이그레이션 |
| 테스트 | tests/ | Jest 테스트 루트 |
```

### Step 4: 사용자 확인

1. 생성된 overview 요약 출력:
   - 모듈 수, 총 파일 수, 의존성 수, 진입점 수
   - `.overview/` 내 생성된 파일 목록
2. 누락되거나 잘못된 부분 확인
3. 확인 후 저장

## --update 모드

1. 기존 `project-overview.md` 읽기
2. `git diff --name-only` 로 마지막 갱신 이후 변경된 파일 식별
3. 변경된 파일이 속한 모듈의 `.overview/{module}.md`만 재생성
4. 인덱스의 해당 모듈 행 갱신
5. `Last updated` 날짜 갱신
6. 변경 없는 모듈은 기존 내용 유지

## --module 모드

```
/overview --module auth
```

1. 지정한 모듈의 `.overview/auth.md`만 재분석/재생성
2. 인덱스의 해당 행도 갱신

## 다른 명령어에서의 탐색 흐름

```
/plan "인증에 2FA 추가"
  ↓
1. project-overview.md 읽기 (인덱스)
  ↓
2. "인증" → auth 모듈 매칭
  ↓
3. .overview/auth.md 읽기 (상세)
  ↓
4. auth.md의 파일 목록에서 관련 파일만 Read (login.ts, token.ts)
  ↓
5. 필요 시 의존 모듈 (.overview/db.md) 추가 로드
```

## project-overview.md 없을 때 (다른 명령어에서)

`/plan`, `/plan-from-spec` 등에서 overview가 없으면:
- 안내: "`/overview`로 프로젝트 지도를 먼저 생성하면 더 빠르게 계획을 수립할 수 있습니다."
- 기존 방식(전체 스캔)으로 폴백하여 계속 진행

## 핵심 규칙

- 코드 내용 전체를 복사하지 않음 — 구조, 역할, 인터페이스만 기록
- 인덱스(`project-overview.md`)는 모듈당 1행 요약 — 전체를 빠르게 훑는 용도
- 상세(`.overview/*.md`)는 모듈당 1파일 — 해당 모듈을 깊이 이해하는 용도
- 의존성은 내부 모듈 간 관계만 (외부 패키지 제외)
- 프로젝트 개요, 기술 스택은 CLAUDE.md 영역이므로 overview에 포함하지 않음
- `.overview/` 디렉토리는 `.gitignore`에 추가 권장 (생성된 파일이므로)
