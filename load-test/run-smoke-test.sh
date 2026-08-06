#!/usr/bin/env bash
# macOS/Linux에서 Docker 기반 k6 Smoke Test를 실행한다.
set -euo pipefail

TARGET_URL="${1:-}"
if [[ -z "${TARGET_URL}" ]]; then
  echo "사용법: ./load-test/run-smoke-test.sh http://ALB주소/테스트경로"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker가 설치되어 실행 중이어야 합니다."
  exit 1
fi

docker run --rm \
  -e TARGET_URL="${TARGET_URL}" \
  -v "${SCRIPT_DIR}:/scripts:ro" \
  grafana/k6:latest run /scripts/smoke-test.js
