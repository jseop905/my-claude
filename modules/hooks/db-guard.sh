#!/bin/bash
# db-guard.sh - PreToolUse Hook (Bash)
# Bash 명령 내 위험 SQL 패턴 차단: DROP TABLE/DATABASE, TRUNCATE, DELETE without WHERE
#
# Hook trigger: PreToolUse, matcher: Bash
# Exit codes: 0 = 허용, 2 = 차단

# Python 경로 자동 감지 (Windows 대응)
PYTHON_CMD=""
for cmd in python3 python py; do
    if command -v "$cmd" &>/dev/null; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [[ -z "$PYTHON_CMD" ]]; then
    # Python 없으면 검사 불가 → 통과
    exit 0
fi

INPUT=$(cat)

# 환경변수로 전달하여 Python에서 처리
export _GUARD_INPUT="$INPUT"

$PYTHON_CMD << 'GUARD_SCRIPT'
import os
import sys
import json
import re

input_json = os.environ.get("_GUARD_INPUT", "")
if not input_json:
    sys.exit(0)

try:
    data = json.loads(input_json)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)

# Bash 명령어 추출
command = data.get("tool_input", {}).get("command", "")
if not command:
    sys.exit(0)

# 정규화: 여러 공백 → 단일 공백, 대문자 변환
cmd_upper = re.sub(r'\s+', ' ', command.strip()).upper()

blocked_reason = None

# DROP TABLE/DATABASE/SCHEMA
if re.search(r'\bDROP\s+(TABLE|DATABASE|SCHEMA)\b', cmd_upper):
    blocked_reason = "DROP TABLE/DATABASE/SCHEMA 감지"

# TRUNCATE
if not blocked_reason and re.search(r'\bTRUNCATE\b', cmd_upper):
    blocked_reason = "TRUNCATE 감지"

# DELETE without WHERE
if not blocked_reason:
    if re.search(r'\bDELETE\s+FROM\b', cmd_upper) and not re.search(r'\bWHERE\b', cmd_upper):
        blocked_reason = "WHERE 없는 DELETE 감지"

# ALTER TABLE ... DROP COLUMN (파괴적 스키마 변경)
if not blocked_reason:
    if re.search(r'\bALTER\s+TABLE\b.*\bDROP\b', cmd_upper):
        blocked_reason = "ALTER TABLE DROP 감지"

if blocked_reason:
    safe_cmd = command[:200]
    print(f"BLOCKED: {blocked_reason}", file=sys.stderr)
    print(f"Command: {safe_cmd}", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
GUARD_SCRIPT
