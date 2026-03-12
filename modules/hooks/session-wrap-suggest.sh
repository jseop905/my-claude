#!/bin/bash
# session-wrap-suggest.sh - Stop 훅
# 세션이 충분히 진행된 후 /session-wrap 실행을 제안
# 세션당 1회만 표시
# 종료 코드 0 필수

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
export _MARKER_DIR="${TEMP_BASE}/session-wrap-markers"

echo "$INPUT" | $PYTHON_CMD -c "
import sys, json, os

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

sid = d.get('session_id', '')
if not sid:
    sys.exit(0)

# 마커 디렉터리로 세션당 1회만 제안
marker_dir = os.environ.get('_MARKER_DIR', '')
if not marker_dir:
    sys.exit(0)
os.makedirs(marker_dir, exist_ok=True)
marker = os.path.join(marker_dir, f'wrap-suggested-{sid}')
if os.path.exists(marker):
    sys.exit(0)

# 세션 통계 확인
# 통계 파일이 없으면 마커 파일 존재 여부로 대체 판단
stats_file = os.path.expanduser('~/.claude/.session-stats.json')
total_calls = 0
try:
    with open(stats_file) as f:
        stats = json.load(f)
    session = stats.get('sessions', {}).get(sid, {})
    total_calls = session.get('total_calls', 0)
except Exception:
    # 통계 파일이 없으면 마커 디렉터리 내 파일 수로 추정
    try:
        existing = [f for f in os.listdir(marker_dir) if f.startswith('wrap-')]
        total_calls = 0 if len(existing) > 0 else 30  # 첫 세션이면 제안
    except Exception:
        total_calls = 30  # 마커 디렉터리도 없으면 첫 실행 → 제안

# 최소 30회 도구 호출 후에만 제안
if total_calls < 30:
    sys.exit(0)

# 마커 생성 (세션당 1회)
open(marker, 'w').close()

# 훅 형식으로 JSON 출력
print(json.dumps({
    'continue': True,
    'systemMessage': '[Session Wrap] 이번 세션에서 상당한 작업이 진행되었습니다. '
        '세션 마무리 시 /session-wrap을 실행하면 문서 업데이트, 학습 포인트, '
        '후속 작업을 자동으로 정리할 수 있습니다.'
}))
" 2>/dev/null

exit 0
