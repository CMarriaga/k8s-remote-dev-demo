#!/usr/bin/env bash

set -euo pipefail

CLUSTER_DIR="cluster"
DASHBOARDS_DIR="dashboards"
APPLICATION_DIR="application"
OPERATOR_DIR="operator"
GRAFANA_NAMESPACE="monitoring"
GRAFANA_SERVICE_NAME="grafana"
GRAFANA_PORT=3000
LOCAL_PORT=3000

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for DIR in "$CLUSTER_DIR" "$DASHBOARDS_DIR" "$APPLICATION_DIR"; do
  if [ ! -d "$SCRIPT_DIR/$DIR" ]; then
    echo "Error: '$DIR' directory not found in $SCRIPT_DIR"
    exit 1
  fi
done

echo -e "---------------------------------------------------------"
echo "[1/7] Applying Terraform in '$CLUSTER_DIR'..."
cd "$SCRIPT_DIR/$CLUSTER_DIR"
terraform init
terraform apply -auto-approve

COMMON_NAME=$(terraform output -raw common_name)
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
SQS_QUEUE_URL=$(terraform output -raw sqs_queue_url)
RDS_DB_URL=$(terraform output -raw rds_db_url)
APP_AUTH_DB_URL=$(terraform output -raw app_auth_db_url)
APP_SERVICE_ACCOUNT_ROLE_ARN=$(terraform output -raw app_service_account_role_arn)
NODE_SECURITY_GROUP_ID=$(terraform output -raw node_security_group_id)
CLUSTER_SECURITY_GROUP_ID=$(terraform output -raw cluster_security_group_id)

echo -e "---------------------------------------------------------"
echo "[2/7] Applying Terraform in '$OPERATOR_DIR'..."
cd "$SCRIPT_DIR/$OPERATOR_DIR"
export TF_VAR_common_name="$COMMON_NAME"
export TF_VAR_node_security_group_id="$NODE_SECURITY_GROUP_ID"
export TF_VAR_cluster_security_group_id="$CLUSTER_SECURITY_GROUP_ID"
terraform init
terraform apply -auto-approve

echo -e "\n---------------------------------------------------------"
echo "[3/7] Updating kubeconfig for cluster: $CLUSTER_NAME (region: $REGION)"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo -e "\n---------------------------------------------------------"
echo "[4/7] Waiting for Grafana to become ready..."
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

echo -e "\n---------------------------------------------------------"
echo "[5/7] Applying Terraform in '$DASHBOARDS_DIR'..."
cd "$SCRIPT_DIR/$DASHBOARDS_DIR"
terraform init
terraform apply -auto-approve

echo -e "\n---------------------------------------------------------"
echo "[6/7] Cleaning up port-forward (PID $PORT_FWD_PID)..."
kill "$PORT_FWD_PID" >/dev/null 2>&1 || true

echo -e "\n---------------------------------------------------------"
echo "[7/7] Applying Terraform in '$APPLICATION_DIR'..."
cd "$SCRIPT_DIR/$APPLICATION_DIR"
terraform init
export TF_VAR_rds_db_url="$RDS_DB_URL"
export TF_VAR_sqs_queue_url="$SQS_QUEUE_URL"
export TF_VAR_app_auth_db_url="$APP_AUTH_DB_URL"
export TF_VAR_app_service_account_role_arn="$APP_SERVICE_ACCOUNT_ROLE_ARN"
terraform apply -auto-approve

echo -e "\nDeployment completed successfully!"