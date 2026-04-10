---
name: wiki
description: Update or add project wiki documentation in docs/wiki/
---

`docs/wiki/` 문서를 갱신하거나 새로 추가한다. `.claude/skills/wiki-management.md` 규칙을 따른다.

## 실행 흐름

1. **인자가 없으면** — 어떤 문서를 어떻게 갱신할지 사용자에게 질문한다. 임의로 추측하지 않는다.
2. **인자가 있으면** — 사용자 지시에 따라 진행한다:
   - 기존 문서 갱신: 해당 문서와 관련 코드를 읽고 변경 사항 반영
   - 새 문서 추가: wiki-management 규칙의 포맷으로 생성

## 갱신 시 규칙

1. 갱신 대상 문서를 먼저 읽는다
2. 관련 코드의 현재 상태를 확인한다
3. 문서와 코드가 다르면 코드 기준으로 문서를 수정한다
4. frontmatter의 `updated` 날짜를 갱신한다
5. 변경 내용을 사용자에게 요약 보고한다

## 사용 예시

```
/wiki modules.md 업데이트해줘. 결제 모듈이 추가됐어.
/wiki data-model.md에 Order 테이블 추가 반영해줘.
/wiki 인증 관련 문서를 새로 만들어줘.
```
