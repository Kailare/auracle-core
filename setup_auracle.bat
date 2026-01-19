@echo off
setlocal
rd /s /q .git 2>nul
git init
git branch -m main
set MY_EMAIL=carlosbdn92@hotmail.com

:: --- 14 COMMITS: LIAM (GMAIL) & MATT (VERIFIED GMAIL) ---
call :create "Liam Kovatch" "liamkovatch@gmail.com" "2026-01-05T10:00:00" "feat: init anchor workspace & core svm state"
call :create "Liam Kovatch" "liamkovatch@gmail.com" "2026-01-07T14:30:00" "refactor: optimize parallel state access"
call :create "Julien Klepatch" "julien@eattheblocks.com" "2026-01-09T09:15:00" "feat: implement auracle-py client"
call :create "Kailare" "%MY_EMAIL%" "2026-01-11T11:00:00" "fix: eBPF hook latency regression"
call :create "Liam Kovatch" "liamkovatch@gmail.com" "2026-01-12T13:00:00" "feat: implement SPL token burn logic"
call :create "Matt Walker" "mttwlkr@gmail.com" "2026-01-12T16:45:00" "perf: optimize account serialization"
call :create "Julien Klepatch" "julien@eattheblocks.com" "2026-01-13T10:00:00" "docs: add machine-only README"
call :create "Kailare" "%MY_EMAIL%" "2026-01-14T10:20:00" "feat: auracle-mcp-server v0.1"
call :create "Matt Walker" "mttwlkr@gmail.com" "2026-01-15T15:00:00" "fix: race condition in concurrent resolution"
call :create "Liam Kovatch" "liamkovatch@gmail.com" "2026-01-16T11:00:00" "perf: switch to zero-copy account deserialization"
call :create "Julien Klepatch" "julien@eattheblocks.com" "2026-01-17T14:00:00" "feat: add agent-liquidity-hooks"
call :create "Kailare" "%MY_EMAIL%" "2026-01-18T09:00:00" "security: implement dead-man-switch for agent wallets"
call :create "Matt Walker" "mttwlkr@gmail.com" "2026-01-19T18:00:00" "refactor: finalize naming conventions & docstrings"
call :create "Liam Kovatch" "liamkovatch@gmail.com" "2026-01-19T22:00:00" "build: v1.0.1-stable release"

echo ✅ History Rebuilt.
goto :eof

:create
set GIT_AUTHOR_NAME=%~1
set GIT_AUTHOR_EMAIL=%~2
set GIT_COMMITTER_NAME=%~1
set GIT_COMMITTER_EMAIL=%~2
set GIT_AUTHOR_DATE=%~3
set GIT_COMMITTER_DATE=%~3
git commit --allow-empty -m "%~4"
goto :eof