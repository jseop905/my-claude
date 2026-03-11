# Agent Orchestration

> 에이전트 선택, 병렬 실행, 다중관점 분석 가이드.

## Available Agents

`.claude/agents/` 에 위치 (프로젝트 루트 기준):

### 개발 에이전트

| Agent | Purpose | Model | When to Use |
|-------|---------|-------|-------------|
| planner | 구현 계획 수립 | opus | 복잡한 기능, 리팩토링 |
| architect | 시스템 설계 & 분석 | opus | 아키텍처 결정 |
| tdd-guide | 테스트 주도 개발 | opus | 새 기능, 버그 수정 |
| code-reviewer | 코드 리뷰 | opus | 코드 작성 직후 |
| security-reviewer | 보안 분석 | opus | 커밋 전 |
| build-error-resolver | 빌드 에러 수정 | opus | 빌드 실패 시 |
| refactor-cleaner | 데드코드 정리 | sonnet | 코드 유지보수 |
| verify-agent | 검증 파이프라인 | sonnet | 변경사항 검증 |

## Immediate Agent Usage

사용자 프롬프트 없이 선제적으로 사용:

1. 복잡한 기능 요청 → **planner** 에이전트
2. 코드 작성/수정 직후 → **code-reviewer** 에이전트
3. 버그 수정 또는 새 기능 → **tdd-guide** 에이전트
4. 아키텍처 결정 → **architect** 에이전트

## Parallel Task Execution

독립적인 작업은 **항상** 병렬로 실행하라:

```markdown
# GOOD: 병렬 실행
3개 에이전트를 동시에 실행:
1. Agent 1: auth.ts 보안 분석
2. Agent 2: cache 시스템 성능 리뷰
3. Agent 3: utils.ts 타입 검사

# BAD: 불필요한 순차 실행
Agent 1 완료 → Agent 2 → Agent 3
```

## Multi-Perspective Analysis

복잡한 문제에는 역할을 나눈 서브에이전트를 사용:

- **사실 검증자** — 코드와 스펙의 일치 확인
- **시니어 엔지니어** — 설계 품질과 유지보수성 평가
- **보안 전문가** — 취약점과 위험 요소 식별
- **일관성 검토자** — 코드베이스 전체와의 일관성 확인
- **중복 검사자** — 불필요한 중복 코드 탐지

## Subagents vs Agent Teams

통신 필요 여부에 따라 선택:

| | Subagents | Agent Teams |
|---|---|---|
| 컨텍스트 | 자체 윈도우; 결과만 호출자에 반환 | 자체 윈도우; 완전 독립 |
| 통신 | 메인 에이전트에게만 보고 | 리더 경유 (hub-and-spoke) |
| 조율 | 메인 에이전트가 관리 | 리더가 조율 + 공유 작업 목록 |
| 최적 용도 | 결과만 중요한 집중 작업 | 논의/협업이 필요한 복잡한 작업 |
| 토큰 비용 | 낮음 (결과 요약) | 높음 (각 팀원 별도 인스턴스) |
