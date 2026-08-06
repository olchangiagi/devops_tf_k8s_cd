#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CI_INFRA_DIR="${1:-${CI_INFRA_DIR:-${ROOT_DIR}/../tf-k8s-ci/infra}}"
IMAGE_TAG="${2:-${INITIAL_IMAGE_TAG:-dev-latest}}"
OVERLAY_FILE="${ROOT_DIR}/k8s/overlays/dev/kustomization.yaml"

for command_name in terraform python3; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "[ERROR] 필수 명령을 찾을 수 없습니다: ${command_name}" >&2
    exit 1
  fi
done

if [[ ! -d "${CI_INFRA_DIR}" ]]; then
  echo "[ERROR] tf-k8s-ci Terraform 디렉터리가 없습니다: ${CI_INFRA_DIR}" >&2
  exit 1
fi

WEB_REPO="$(terraform -chdir="${CI_INFRA_DIR}" output -raw web_ecr_repository_url)"
WAS_REPO="$(terraform -chdir="${CI_INFRA_DIR}" output -raw was_ecr_repository_url)"

python3 "${ROOT_DIR}/scripts/update_images.py" \
  --file "${OVERLAY_FILE}" \
  --web-image "${WEB_REPO}" \
  --was-image "${WAS_REPO}" \
  --tag "${IMAGE_TAG}"
