#!/usr/bin/env bash
# macOS/Linux에서 Docker 기반 k6 HPA 부하 테스트를 실행한다.
set -euo pipefail

# 첫 번째 인자로 테스트 대상 URL을 받는다.
TARGET_URL="${1:-}"

# URL이 없으면 사용법을 출력하고 종료한다.
if [[ -z "${TARGET_URL}" ]]; then
  echo "사용법: ./load-test/run-load-test.sh http://ALB주소/테스트경로"
  exit 1
fi

# 스크립트가 어느 위치에서 실행되어도 파일을 찾도록 현재 파일 기준 경로를 계산한다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Docker가 설치되어 있고 실행 중인지 확인한다.
if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker가 설치되어 실행 중이어야 합니다."
  exit 1
fi

# 공식 grafana/k6 이미지를 사용하고 현재 load-test 폴더를 읽기 전용으로 마운트한다.
docker run --rm \
  -e TARGET_URL="${TARGET_URL}" \
  -v "${SCRIPT_DIR}:/scripts:ro" \
  grafana/k6:latest run /scripts/hpa-test.js
