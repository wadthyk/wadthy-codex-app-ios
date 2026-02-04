#!/usr/bin/env bash
set -euo pipefail

if [[ ${#} -lt 1 ]]; then
  echo "Usage: ./checkpoint.sh \"commit message\""
  exit 1
fi

message="$*"

if [[ -n $(git status --porcelain) ]]; then
  git add -A
  git commit -m "$message"
  git log -1 --oneline
else
  echo "No changes to commit."
fi
