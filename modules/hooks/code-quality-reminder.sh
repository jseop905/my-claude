#!/bin/bash
# code-quality-reminder.sh - PostToolUse Hook (Edit/Write)
# 코드 수정 후 품질 체크 리마인더를 stderr로 출력
# Claude에게 셀프 체크를 유도하는 간결한 메시지
# exit 0 필수 (세션 방해 금지)

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

FILE_PATH=$(echo "$INPUT" | $PYTHON_CMD -c "
import sys, json
try:
    d = json.load(sys.stdin)
    tool = d.get('tool_name', '')
    if tool not in ('Edit', 'Write'):
        sys.exit(0)
    inp = d.get('tool_input', {})
    print(inp.get('file_path', ''))
except Exception:
    pass
" 2>/dev/null)

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# 코드 파일만 대상 (md, txt, json, yaml 등 제외)
case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.rs|*.java|*.rb|*.php|*.swift|*.kt|*.sh|*.c|*.cpp|*.cs)
        ;;
    *)
        exit 0
        ;;
esac

echo "[code-quality] 수정된 파일의 에러 핸들링, 불변성 패턴, 입력 검증을 확인하세요." >&2

exit 0
