#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "사용법: $0 GitHub_ID/tf-k8s-ci GitHub_ID/tf-k8s-cd" >&2
  exit 1
fi

CI_REPOSITORY="${1//\\//}"
CD_REPOSITORY="${2//\\//}"

if ! command -v gh >/dev/null 2>&1; then
  echo "[ERROR] GitHub CLI(gh)가 필요합니다." >&2
  exit 1
fi

gh auth status

gh variable set CD_REPOSITORY \
  --repo "${CI_REPOSITORY}" \
  --body "${CD_REPOSITORY}"

TOKEN="${CD_REPOSITORY_TOKEN:-}"

if [[ -z "${TOKEN}" ]]; then
  read -r -s -p "tf-k8s-cd Write Token: " TOKEN
  echo
fi

if [[ -z "${TOKEN}" ]]; then
  echo "[ERROR] Token이 비어 있습니다." >&2
  exit 1
fi

printf '%s' "${TOKEN}" | gh secret set CD_REPOSITORY_TOKEN \
  --repo "${CI_REPOSITORY}"

unset TOKEN CD_REPOSITORY_TOKEN

echo "[OK] ${CI_REPOSITORY}에 CD_REPOSITORY 변수와 CD_REPOSITORY_TOKEN Secret을 등록했습니다."
