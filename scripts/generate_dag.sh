#!/usr/bin/env bash

# ------------------------------------
# This script generates:
# 1. Workflow DAG
# 2. Workflow rule graph
# 3. Pipeline logs
# ------------------------------------

set -euo pipefail

DAG_DIR="$1"
LOG_DIR="$2"

mkdir -p "${DAG_DIR}"
mkdir -p "${LOG_DIR}"

# ------------------------------------
# Complete DAG: one node per job
# ------------------------------------

DAG_DOT="${DAG_DIR}/dag.dot"
DAG_PNG="${DAG_DIR}/dag.png"
DAG_SVG="${DAG_DIR}/dag.svg"
DAG_LOG="${LOG_DIR}/dag.log"

snakemake \
    --dry-run \
    --forceall \
    --dag \
    --nolock \
    > "${DAG_DOT}" \
    2> "${DAG_LOG}"

dot \
    -Tpng \
    "${DAG_DOT}" \
    -o "${DAG_PNG}"

dot \
    -Tsvg \
    "${DAG_DOT}" \
    -o "${DAG_SVG}"

# ------------------------------------
# Simplified graph: one node per rule
# ------------------------------------

RULEGRAPH_DOT="${DAG_DIR}/rulegraph.dot"
RULEGRAPH_PNG="${DAG_DIR}/rulegraph.png"
RULEGRAPH_SVG="${DAG_DIR}/rulegraph.svg"
RULEGRAPH_LOG="${LOG_DIR}/rulegraph.log"

snakemake \
    --dry-run \
    --forceall \
    --rulegraph \
    --nolock \
    > "${RULEGRAPH_DOT}" \
    2> "${RULEGRAPH_LOG}"

dot \
    -Tpng \
    "${RULEGRAPH_DOT}" \
    -o "${RULEGRAPH_PNG}"

dot \
    -Tsvg \
    "${RULEGRAPH_DOT}" \
    -o "${RULEGRAPH_SVG}"

# ------------------------------------
# Latest Snakemake execution log
# ------------------------------------

PIPELINE_LOG_DIR="logs/pipeline"

mkdir -p "${PIPELINE_LOG_DIR}"

LATEST_LOG=$(find .snakemake/log \
    -type f \
    -name "*.snakemake.log" \
    -print0 | xargs -0 ls -t | head -n 1 || true)

if [[ -n "${LATEST_LOG}" ]]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    DEST_LOG="${PIPELINE_LOG_DIR}/${TIMESTAMP}_$(basename "${LATEST_LOG}")"

    cp "${LATEST_LOG}" "${DEST_LOG}"

    echo "Snakemake execution log copied successfully:"
    echo "  ${DEST_LOG}"
else
    echo "No Snakemake execution log found in .snakemake/log"
fi


echo
echo "Pipeline documentation generated successfully:"
echo "  Workflow DAG:"
echo "    ${DAG_PNG}"
echo "    ${DAG_SVG}"
echo
echo "  Workflow rule graph:"
echo "    ${RULEGRAPH_PNG}"
echo "    ${RULEGRAPH_SVG}"
echo
echo "  Pipeline logs:"
echo "    ${PIPELINE_LOG_DIR}"