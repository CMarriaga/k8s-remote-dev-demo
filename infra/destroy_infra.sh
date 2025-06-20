#!/usr/bin/env bash

set -euo pipefail

CLUSTER_DIR="cluster"
DASHBOARDS_DIR="dashboards"
GRAFANA_NAMESPACE="monitoring"
GRAFANA_SERVICE_NAME="grafana"
GRAFANA_PORT=3000
LOCAL_PORT=3000

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for DIR in "$CLUSTER_DIR" "$DASHBOARDS_DIR"; do
  if [ ! -d "$SCRIPT_DIR/$DIR" ]; then
    echo "Error: '$DIR' directory not found in $SCRIPT_DIR"
    exit 1
  fi
done

# TODO: Validate that if destroy fails but dashboard resources have already been remove
#       not to try again some steps
echo "---------------------------------------------------------"
cd "$SCRIPT_DIR/$CLUSTER_DIR"
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
echo "[1/5] Updating kubeconfig for cluster: $CLUSTER_NAME (region: $REGION)"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "---------------------------------------------------------"
echo "[2/5] Waiting for Grafana to become ready..."
kubectl rollout status deployment/"$GRAFANA_SERVICE_NAME" -n "$GRAFANA_NAMESPACE" --timeout=120s

echo "Port-forwarding Grafana on localhost:$LOCAL_PORT"
kubectl port-forward svc/"$GRAFANA_SERVICE_NAME" "$LOCAL_PORT":"$GRAFANA_PORT" -n "$GRAFANA_NAMESPACE" > /dev/null 2<&1 &
PORT_FWD_PID=$!

wait_for_grafana_ready() {
  echo "Waiting for Grafana to respond at http://localhost:$LOCAL_PORT..."

  local retries=12  # 120 seconds
  local delay=10

  for ((i=1; i<=retries; i++)); do
    if curl -sSf "http://localhost:$LOCAL_PORT/login" >/dev/null; then
      echo "Grafana is up!"
      return 0
    fi
    echo "Attempt $i/$retries: Grafana not ready, retrying in $delay seconds..."
    sleep "$delay"
  done

  echo "Error: Grafana did not become ready at http://localhost:$LOCAL_PORT after $((retries * delay)) seconds"
  exit 1
}

wait_for_grafana_ready

echo "---------------------------------------------------------"
echo "[3/5] Destroying Terraform in '$DASHBOARDS_DIR'..."
cd "$SCRIPT_DIR/$DASHBOARDS_DIR"
terraform init
terraform destroy
#terraform destroy -auto-approve

echo "---------------------------------------------------------"
echo "[4/5] Cleaning up port-forward (PID $PORT_FWD_PID)..."
kill "$PORT_FWD_PID" >/dev/null 2>&1 || true


echo "---------------------------------------------------------"
echo "[5/5] Destroying Terraform in '$CLUSTER_DIR'..."
cd "$SCRIPT_DIR/$CLUSTER_DIR"
terraform init
terraform destroy
#terraform destroy -auto-approve

echo "Destroy completed successfully!"