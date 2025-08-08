#!/bin/sh

set -e


if ! command -v docker 1>/dev/null 2>/dev/null; then
  echo "error: docker is missing"
  exit 1
fi

if ! docker buildx --help 1>/dev/null 2>/dev/null; then
  echo "docker buildx not present (old docker?)"
  exit 1
fi

TARGET_PLATFORMS=${TARGET_PLATFORMS:-linux/amd64,linux/arm64}
BUILDX_CONTEXT=${BUILDX_CONTEXT:-ctx}
export BUILDX_BUILDER=${BUILDX_BUILDER:-builder}

# This var can be used by caller to replace or append other args
BUILDX_BUILDER_CREATE_BOOTSTRAP_ARG=${BUILDX_BUILDER_CREATE_BOOTSTRAP_ARG:-"--bootstrap"}

docker context inspect ${BUILDX_CONTEXT} >/dev/null 2>&1 \
  || docker context create ${BUILDX_CONTEXT} 1>/dev/null

docker buildx inspect ${BUILDX_BUILDER} >/dev/null 2>&1 \
  || docker buildx create \
    --name ${BUILDX_BUILDER} \
    --driver docker-container \
    ${BUILDX_BUILDER_CREATE_BOOTSTRAP_ARG} \
    --platform ${TARGET_PLATFORMS} \
    ${BUILDX_CONTEXT} 1>/dev/null

#
echo "[$(date -u '+%H:%M:%S')] Docker buildx builder [${BUILDX_BUILDER}] is ready with platforms [${TARGET_PLATFORMS}]"
cat <<EOF
> Example usage: docker buildx build --builder ${BUILDX_BUILDER} --platform linux/amd64,linux/arm64 -t \${CI_REGISTRY_IMAGE}/build:\${CI_COMMIT_SHA} .
EOF
