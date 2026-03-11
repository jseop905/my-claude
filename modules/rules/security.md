# Security Guidelines

> 보안 체크리스트와 대응 프로토콜. 핵심 원칙은 golden-principles.md §2, §6 참조.

## Mandatory Security Checks

커밋 전 **반드시** 확인:

- [ ] 하드코딩된 시크릿 없음 (API 키, 비밀번호, 토큰)
- [ ] 모든 사용자 입력 검증됨
- [ ] SQL 인젝션 방지 (파라미터화된 쿼리)
- [ ] XSS 방지 (HTML 출력 이스케이프)
- [ ] CSRF 보호 활성화
- [ ] 인증/인가 검증 완료
- [ ] Rate limiting 적용
- [ ] 에러 메시지에 민감 정보 미포함

## Secret Management

```
# NEVER: 하드코딩된 시크릿
api_key = "sk-proj-xxxxx"

# ALWAYS: 환경 변수
api_key = os.environ["API_KEY"]
if not api_key:
    raise RuntimeError("API_KEY not configured")
```

환경별 시크릿 관리:
- **로컬 개발**: `.env` 파일 (`.gitignore`에 반드시 추가)
- **CI/CD**: 파이프라인 시크릿 변수
- **프로덕션**: 시크릿 매니저 (Vault, AWS Secrets Manager 등)

## OWASP Top 10:2021 체크리스트

| # | 위협 | 방어 |
|---|------|------|
| A01 | Broken Access Control | 최소 권한 원칙, RBAC, 기본 거부 정책 |
| A02 | Cryptographic Failures | 전송/저장 시 암호화, 강력한 알고리즘 사용 |
| A03 | Injection | 파라미터화된 쿼리, ORM 사용, 입력 검증 |
| A04 | Insecure Design | 위협 모델링, 보안 설계 패턴 적용 |
| A05 | Security Misconfiguration | 기본 설정 변경, 불필요한 기능 비활성화 |
| A06 | Vulnerable and Outdated Components | 의존성 정기 업데이트, 취약점 스캔 |
| A07 | Identification and Authentication Failures | 안전한 세션 관리, MFA |
| A08 | Software and Data Integrity Failures | 서명 검증, CI/CD 파이프라인 보안 |
| A09 | Security Logging and Monitoring Failures | 보안 이벤트 로깅, 침해 탐지 모니터링 |
| A10 | Server-Side Request Forgery (SSRF) | URL 허용 목록, 내부 네트워크 접근 차단 |

## Security Response Protocol

보안 이슈 발견 시:

1. **즉시 중단** — 다른 작업 진행 금지
2. **security-reviewer 에이전트 실행** — 전체 범위 분석
3. **CRITICAL 이슈 먼저 수정** — 다른 작업보다 우선
4. **노출된 시크릿 로테이션** — 커밋 히스토리에 남은 시크릿도 포함
5. **유사 패턴 전체 검색** — 같은 문제가 다른 곳에도 있는지 확인
