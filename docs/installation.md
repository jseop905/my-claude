# 설치 방법

## 1. 저장소 클론

```bash
git clone https://github.com/<your-username>/my-claude.git
```

## 2. 프로젝트에 모듈 복사

대상 프로젝트의 `.claude/` 디렉터리에 필요한 모듈을 복사한다.

```bash
# 대상 프로젝트로 이동
cd /path/to/your-project

# .claude 디렉터리 생성
mkdir -p .claude/{rules,agents,commands,hooks,skills}

# 전체 복사 (권장)
cp my-claude/modules/rules/*.md      .claude/rules/
cp my-claude/modules/agents/*.md     .claude/agents/
cp my-claude/modules/commands/*.md   .claude/commands/
cp my-claude/modules/hooks/*.sh      .claude/hooks/
cp -r my-claude/modules/skills/      .claude/skills/

# 또는 필요한 모듈만 선택 복사
cp my-claude/modules/rules/golden-principles.md .claude/rules/
```

## 3. 설정 파일 적용

```bash
# settings.json 복사
cp my-claude/templates/settings.json.tmpl .claude/settings.json

# 전역 설정 복사 (선택)
cp my-claude/templates/global.settings.json.tmpl ~/.claude/settings.json

# CLAUDE.md 복사 후 플레이스홀더 편집
cp my-claude/templates/CLAUDE.md.tmpl CLAUDE.md
# {프로젝트명}, {기술 스택} 등을 실제 값으로 교체
```

## 4. 훅 실행 권한 부여 (macOS/Linux)

```bash
chmod +x .claude/hooks/*.sh
```

> Windows(Git Bash/MINGW)에서는 `settings.json`의 hooks command가 `bash "$CLAUDE_PROJECT_DIR/..."` 형식이므로 별도 권한 부여 없이 동작한다.

## 업데이트

```bash
# my-claude 저장소에서 최신 버전 pull
cd /path/to/my-claude
git pull

# 대상 프로젝트에 변경된 모듈 다시 복사
cp modules/rules/*.md /path/to/your-project/.claude/rules/
```

> settings.json은 프로젝트별 커스터마이징이 있으므로 덮어쓰기 전 diff 확인을 권장한다.
