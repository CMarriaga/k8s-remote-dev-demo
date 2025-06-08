#!/usr/bin/env bash

# Script used for removing tfstate files after Cloud-guru sandbox is destroyed
# Only use in that scenario, else you will loose all of your state

# TODO: Do a complete cleanup
# TODO: Validate cloud environments

set -euo pipefail

CLUSTER_DIR="cluster"
DASHBOARDS_DIR="dashboards"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for DIR in "$CLUSTER_DIR" "$DASHBOARDS_DIR"; do
  if [ ! -d "$SCRIPT_DIR/$DIR" ]; then
    echo "Error: '$DIR' directory not found in $SCRIPT_DIR"
    exit 1
  fi
done

echo "[1/2] Removing tfstate in '$CLUSTER_DIR'..."
cd "$SCRIPT_DIR/$CLUSTER_DIR"
rm "$SCRIPT_DIR/$CLUSTER_DIR/*.tfstate*"

echo "[2/2] Removing tfstate in '$DASHBOARDS_DIR'..."
cd "$SCRIPT_DIR/$DASHBOARDS_DIR"
rm "$SCRIPT_DIR/$DASHBOARDS_DIR/*.tfstate*"