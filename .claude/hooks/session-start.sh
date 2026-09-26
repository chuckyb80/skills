#!/bin/bash
# Installs dependencies for the tests/ test harness (pnpm + TypeScript) and
# the Python graders it shells out to (pylint), so `pnpm lint`, `pnpm
# typecheck`, and `pnpm test` work out of the box in a Claude Code on the
# web session. Only runs remotely -- local dev machines already manage this.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

REPO_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# Test harness: TypeScript unit tests, eslint, tsc, and the skill
# evaluation harness itself all live under tests/ with their own
# pnpm-managed package.json (see tests/README.md and
# .github/workflows/test-harness.yml).
if [ -f "$REPO_DIR/tests/package.json" ]; then
  echo "Installing tests/ dependencies (pnpm)..."
  (cd "$REPO_DIR/tests" && pnpm install)
fi

# Python graders (tests/scenarios/_shared/vally/tools/check-python-idiomatic.mjs)
# shell out to pylint; tests/requirements.txt pins the version CI uses.
if [ -f "$REPO_DIR/tests/requirements.txt" ]; then
  echo "Installing Python grader requirements (pylint)..."
  python3 -m pip install --user -q -r "$REPO_DIR/tests/requirements.txt"
fi

echo "Session start hook complete."
