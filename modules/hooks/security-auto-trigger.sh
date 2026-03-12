#!/bin/bash
# security-auto-trigger.sh - PostToolUse 훅 (Edit/Write)
# 보안 관련 파일 수정 감지 시 /code-review 실행 제안
# 종료 코드 0 필수 (차단하지 않음, 제안만)

# Python 경로 자동 감지 (Windows 대응)
PYTHON_CMD=""
for cmd in python3 python py; do
    if command -v "$cmd" &>/dev/null; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [[ -z "$PYTHON_CMD" ]]; then
    exit 0
fi

INPUT=$(cat)

# 임시 파일 경로 (Windows 대응)
TEMP_BASE="${TEMP:-${TMP:-${HOME}/.claude/tmp}}"
export _MARKER_DIR="${TEMP_BASE}/security-markers"

RESULT=$(echo "$INPUT" | $PYTHON_CMD -c "
import sys, json, os, re

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool = d.get('tool_name', '')
if tool not in ('Edit', 'Write'):
    sys.exit(0)

inp = d.get('tool_input', {})
file_path = inp.get('file_path', '')
if not file_path:
    sys.exit(0)

# 보안 민감 파일 패턴
SECURITY_PATTERNS = [
    # 인증/권한
    r'auth',
    r'login',
    r'session',
    r'token',
    r'jwt',
    r'oauth',
    r'credential',
    r'permission',
    r'middleware',
    # 환경/설정
    r'\.env',
    r'config/security',
    # DB 보안
    r'migration',
    # API
    r'api/',
    # 암호화
    r'encrypt',
    r'decrypt',
    r'hash',
    r'crypto',
]

# 파일 경로 검사 (대소문자 무시)
path_lower = file_path.lower()
matched_pattern = None
for pattern in SECURITY_PATTERNS:
    if re.search(pattern, path_lower):
        matched_pattern = pattern
        break

if not matched_pattern:
    sys.exit(0)

# 세션당 같은 파일에 대해 1회만 제안
sid = d.get('session_id', 'unknown')
marker_dir = os.environ.get('_MARKER_DIR', '')
if not marker_dir:
    sys.exit(0)
os.makedirs(marker_dir, exist_ok=True)
safe_path = re.sub(r'[^a-zA-Z0-9]', '_', file_path)[:100]
marker = os.path.join(marker_dir, f'{sid}-{safe_path}')
if os.path.exists(marker):
    sys.exit(0)
open(marker, 'w').close()

# 매칭 결과를 stdout으로 출력
basename = os.path.basename(file_path)
print(f'{basename}|{matched_pattern}')
" 2>/dev/null)

if [[ -n "$RESULT" ]]; then
    BASENAME=$(echo "$RESULT" | cut -d'|' -f1)
    PATTERN=$(echo "$RESULT" | cut -d'|' -f2)
    echo "[Security] 보안 관련 파일 수정 감지: ${BASENAME} (패턴: ${PATTERN}). 커밋 전 /code-review 실행을 권장합니다." >&2
fi

exit 0
