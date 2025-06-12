#!/usr/bin/env bash

# Script used for removing tfstate files after Cloud-guru sandbox is destroyed

# TODO: Do a complete cleanup
# TODO: Validate cloud environments

set -euo pipefail

CLUSTER_DIR="cluster"
DASHBOARDS_DIR="dashboards"
APPLICATION_DIR="application"
OPERATOR_DIR="operator"
STATE_FILE="terraform.tfstate"
BACKUP_STATE_FILE="terraform.tfstate.backup"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for DIR in "$CLUSTER_DIR" "$DASHBOARDS_DIR"; do
  if [ ! -d "$SCRIPT_DIR/$DIR" ]; then
    echo "Error: '$DIR' directory not found in $SCRIPT_DIR"
    exit 1
  fi
done

CLUSTER_STATE_FILE="$SCRIPT_DIR/$CLUSTER_DIR/$STATE_FILE"
CLUSTER_BACKUP_STATE_FILE="$SCRIPT_DIR/$CLUSTER_DIR/$BACKUP_STATE_FILE"
DASHBOARD_STATE_FILE="$SCRIPT_DIR/$DASHBOARDS_DIR/$STATE_FILE"
DASHBOARD_BACKUP_STATE_FILE="$SCRIPT_DIR/$DASHBOARDS_DIR/$BACKUP_STATE_FILE"
APPLICATION_STATE_FILE="$SCRIPT_DIR/$APPLICATION_DIR/$STATE_FILE"
APPLICATION_BACKUP_STATE_FILE="$SCRIPT_DIR/$APPLICATION_DIR/$BACKUP_STATE_FILE"
OPERATOR_STATE_FILE="$SCRIPT_DIR/$OPERATOR_DIR/$STATE_FILE"
OPERATOR_BACKUP_STATE_FILE="$SCRIPT_DIR/$OPERATOR_DIR/$BACKUP_STATE_FILE"


echo -e "Are you sure you want to delete the following files?\n"
echo "- $CLUSTER_STATE_FILE"
echo "- $CLUSTER_BACKUP_STATE_FILE"
echo "- $APPLICATION_STATE_FILE"
echo "- $APPLICATION_BACKUP_STATE_FILE"
echo "- $OPERATOR_STATE_FILE"
echo "- $OPERATOR_BACKUP_STATE_FILE"
echo "- $DASHBOARD_STATE_FILE"
echo -e "- $DASHBOARD_BACKUP_STATE_FILE\n"

echo -e "WARNING: Only run if you know what you're doing, else you will lose all of your state\n"

read -p "Please confirm (yes/no): " response

response=$(echo $response | tr '[:upper:]' '[:lower:]')

[ "$response" != "yes" ] && echo -e "\nCanceling operation" && exit 1

echo "[1/4] Removing tfstate in '$CLUSTER_DIR'..."
cd "$SCRIPT_DIR/$CLUSTER_DIR"
[ -e  "$CLUSTER_STATE_FILE" ] && rm "$CLUSTER_STATE_FILE"
[ -e  "$CLUSTER_BACKUP_STATE_FILE" ] && rm "$CLUSTER_BACKUP_STATE_FILE"

echo "[2/4] Removing tfstate in '$DASHBOARDS_DIR'..."
[ -e  "$DASHBOARD_STATE_FILE" ] && rm "$DASHBOARD_STATE_FILE"
[ -e  "$DASHBOARD_BACKUP_STATE_FILE" ] && rm "$DASHBOARD_BACKUP_STATE_FILE"

echo "[3/4] Removing tfstate in '$APPLICATION_DIR'..."
[ -e  "$APPLICATION_STATE_FILE" ] && rm "$APPLICATION_STATE_FILE"
[ -e  "$APPLICATION_BACKUP_STATE_FILE" ] && rm "$APPLICATION_BACKUP_STATE_FILE"

echo "[4/4] Removing tfstate in '$OPERATOR_DIR'..."
[ -e  "$OPERATOR_STATE_FILE" ] && rm "$OPERATOR_STATE_FILE"
[ -e  "$OPERATOR_BACKUP_STATE_FILE" ] && rm "$OPERATOR_BACKUP_STATE_FILE"