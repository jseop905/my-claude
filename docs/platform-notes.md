# 플랫폼별 주의사항

---

## Python 환경

my-claude의 hook, skill 등 여러 모듈이 내부적으로 Python을 호출한다.
Python이 올바르게 설치되어 있지 않으면 **보안 hook(db-guard, secret-filter 등)이 무력화**되는 등 모듈이 정상 동작하지 않을 수 있다.

### 감지 방식

각 모듈은 아래 순서로 실제 동작하는 Python을 탐색한다:

```bash
for cmd in python3 python py; do
    if "$cmd" -c "import sys" &>/dev/null 2>&1; then
        PYTHON_CMD="$cmd"
        break
    fi
done
```

`command -v`(PATH 존재 여부)가 아니라 `import sys` 실행 성공 여부로 판별한다.
OS가 제공하는 스텁/심이 실제 Python이 아닌 경우를 걸러내기 위함이다.

### macOS

| 상황 | 증상 | 원인 |
|------|------|------|
| Xcode CLT 미설치 | 모듈 실행 시 **GUI 다이얼로그**가 뜨며 멈춤 | `/usr/bin/python3`이 CLT 설치 유도 심(shim)으로 동작 |
| Python 미설치 | 모듈이 조용히 실패 | `python3`, `python`, `py` 모두 없음 |

**해결 방법** (택 1):

```bash
# 방법 1: Homebrew (권장)
brew install python3

# 방법 2: Xcode Command Line Tools
xcode-select --install
```

**확인:**

```bash
python3 -c "import sys; print(sys.version)"
```

### Windows

| 상황 | 증상 | 원인 |
|------|------|------|
| Microsoft Store 스텁 | `python3` 실행 시 Store 페이지가 열림 (exit 49) | Windows가 등록한 앱 실행 별칭이 실제 Python이 아님 |
| Python 미설치 | 모듈이 조용히 실패 | `python3`, `python`, `py` 모두 없음 |

**해결 방법:**

1. [python.org](https://www.python.org/downloads/)에서 설치
2. 설치 시 **"Add python.exe to PATH"** 체크
3. (선택) 설정 > 앱 > 앱 실행 별칭에서 `python3` 스텁 비활성화

**확인 (Git Bash):**

```bash
python -c "import sys; print(sys.version)"
```

### Linux

일반적으로 `python3`이 기본 설치되어 있어 문제없다.

```bash
# Debian/Ubuntu에서 없는 경우
sudo apt install python3
```

### 진단

```bash
PYTHON_CMD=""
for cmd in python3 python py; do
    if "$cmd" -c "import sys" &>/dev/null 2>&1; then
        PYTHON_CMD="$cmd"
        break
    fi
done

if [ -n "$PYTHON_CMD" ]; then
    echo "[OK] Python detected: $PYTHON_CMD ($($PYTHON_CMD --version 2>&1))"
else
    echo "[FAIL] Python not found — 위 플랫폼별 해결 방법을 참고하세요"
fi
```

---

## 훅 실행 권한

### macOS / Linux

`.sh` 파일에 실행 권한이 필요하다:

```bash
chmod +x .claude/hooks/*.sh
```

### Windows

`settings.json`의 hook command가 `bash "$CLAUDE_PROJECT_DIR/..."` 형식이므로 별도 권한 부여 없이 동작한다.
