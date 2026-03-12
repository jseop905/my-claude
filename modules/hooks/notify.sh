#!/bin/bash
# notify.sh - Notification 훅
# notification_type별 Windows 토스트 알림 발송
# 타입: permission_prompt, idle_prompt, elicitation_dialog, task_completed 등
# 쓰로틀링: 5초 이내 동일 타입 중복 방지
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
    printf '\a'
    exit 0
fi

INPUT=$(cat)

echo "$INPUT" | $PYTHON_CMD -c "
import sys, json, os, time, subprocess

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

notif_type = d.get('notification_type', 'unknown')
message = d.get('message', '')
title_from_input = d.get('title', '')

# 타입별 제목/메시지 매핑
TYPE_MAP = {
    'permission_prompt': {
        'title': 'Claude Code - 권한 요청',
        'message': '권한 승인이 필요합니다.',
        'icon': 'Warning',
    },
    'idle_prompt': {
        'title': 'Claude Code - 유휴 상태',
        'message': '입력을 기다리고 있습니다.',
        'icon': 'Information',
    },
    'elicitation_dialog': {
        'title': 'Claude Code - 추가 입력 필요',
        'message': '추가 정보를 입력해주세요.',
        'icon': 'Information',
    },
    'task_completed': {
        'title': 'Claude Code - 작업 완료',
        'message': '작업이 완료되었습니다.',
        'icon': 'Information',
    },
}

info = TYPE_MAP.get(notif_type, {
    'title': 'Claude Code',
    'message': message or '확인이 필요합니다.',
    'icon': 'Information',
})

notif_title = title_from_input or info['title']
notif_message = message or info['message']
notif_icon = info['icon']

# 쓰로틀링: 동일 타입 5초 이내 중복 방지
temp_base = os.environ.get('TEMP', os.environ.get('TMP', os.path.expanduser('~/.claude/tmp')))
marker_dir = os.path.join(temp_base, 'notify-markers')
os.makedirs(marker_dir, exist_ok=True)
marker_file = os.path.join(marker_dir, f'last-{notif_type}')

now = int(time.time())
if os.path.exists(marker_file):
    try:
        with open(marker_file) as f:
            last = int(f.read().strip())
        if now - last < 5:
            sys.exit(0)
    except Exception:
        pass

with open(marker_file, 'w') as f:
    f.write(str(now))

# PowerShell 경로 감지
pwsh = None
for cmd in ['pwsh', 'powershell.exe', 'powershell']:
    import shutil
    if shutil.which(cmd):
        pwsh = cmd
        break

if pwsh:
    # Windows 토스트 알림
    ps_script = f'''
Add-Type -AssemblyName System.Windows.Forms
\$notify = New-Object System.Windows.Forms.NotifyIcon
\$notify.Icon = [System.Drawing.SystemIcons]::{notif_icon}
\$notify.Visible = \$true
\$notify.ShowBalloonTip(5000, '{notif_title}', '{notif_message}', [System.Windows.Forms.ToolTipIcon]::{notif_icon})
Start-Sleep -Milliseconds 300
\$notify.Dispose()
'''
    subprocess.Popen(
        [pwsh, '-NoProfile', '-NonInteractive', '-Command', ps_script],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )

# 터미널 벨
print('\a', end='', file=sys.stderr)
" 2>/dev/null

exit 0
