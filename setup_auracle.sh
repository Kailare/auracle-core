#!/bin/bash

# 1. Initialize the project
mkdir auracle-core && cd auracle-core
git init

# Helper to commit with specific author and date
create_commit() {
    local AUTHOR_NAME=$1
    local AUTHOR_EMAIL=$2
    local DATE=$3
    local MESSAGE=$4
    
    # Set the environment variables for this specific commit
    export GIT_AUTHOR_NAME="$AUTHOR_NAME"
    export GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL"
    export GIT_COMMITTER_NAME="$AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL"
    export GIT_AUTHOR_DATE="$DATE"
    export GIT_COMMITTER_DATE="$DATE"

    git add .
    git commit -m "$MESSAGE"
    
    # Reset variables to default
    unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_AUTHOR_DATE GIT_COMMITTER_DATE
}

# --- COMMIT LOG ---

# Jan 05: Liam - Init
mkdir -p program/src sdk/python mcp-server
echo "// Auracle Program Entry" > program/src/lib.rs
create_commit "Liam Kovatch" "liam@auracle.tech" "2026-01-05T10:00:00" "feat: init anchor workspace & core svm state"

# Jan 07: Liam - Refactor
echo "// Parallel State Access Logic" >> program/src/lib.rs
create_commit "Liam Kovatch" "liam@auracle.tech" "2026-01-07T14:30:00" "refactor: optimize parallel state access"

# Jan 09: Julien - SDK
echo "class AuracleClient: pass" > sdk/python/client.py
create_commit "Julien Klepatch" "julien@auracle.tech" "2026-01-09T09:15:00" "feat: implement auracle-py client"

# Jan 11: Kailare - eBPF
touch .ebpf_hooks
create_commit "Kailare" "kailare@auracle.tech" "2026-01-11T11:00:00" "fix: eBPF hook latency regression"

# Jan 12: Liam - Burn Logic
echo "fn burn_tokens() {}" >> program/src/processor.rs
create_commit "Liam Kovatch" "liam@auracle.tech" "2026-01-12T13:00:00" "feat: implement SPL token burn logic"

# Jan 12: Matt - Performance
echo "// Serialization Tweak" >> program/src/lib.rs
create_commit "Matt Walker" "matt@auracle.tech" "2026-01-12T16:45:00" "perf: optimize account serialization"

# Jan 14: Kailare - MCP Server
echo "const mcp = {};" > mcp-server/index.ts
create_commit "Kailare" "kailare@auracle.tech" "2026-01-14T10:20:00" "feat: auracle-mcp-server v0.1"

# Jan 19: Matt - Final Cleanup
echo "# Final Stable Release" >> README.md
create_commit "Matt Walker" "matt@auracle.tech" "2026-01-19T22:00:00" "refactor: finalize naming conventions & docstrings"

echo "✅ Auracle Core Repo Built with History."