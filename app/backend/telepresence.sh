#!/bin/bash
set -e

# Connect to Telepresence
telepresence connect --namespace demo

# Ensure telepresence quit and kill refresher on exit (even if interrupted)
cleanup() {
  telepresence quit
  if [[ -n "$REFRESH_PID" ]]; then
    kill "$REFRESH_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# Load env vars and run your dev command
set -a
source ./src/.env

# Getting secrets
echo "Getting secrets..."
telepresence intercept "$1" --port 8000 --container "$1"
POD_IP=$(telepresence list -i | grep -A 3 $1 | tail -n 1 | awk '{print $3}')
POD_NAME=$(kubectl get -n demo --output json pods | jq '.items[] | select(.status.podIP=="'$POD_IP'")' | jq .metadata.name | tr -d '"')
telepresence leave "$1"
echo "POD_IP: $POD_IP"
echo "POD_NAME: $POD_NAME"

#kubectl exec -it -n demo "$POD_NAME" -c traffic-agent -- ln -s /var/run/secrets/eks.amazonaws.com /tel_app_mounts/var/run/secrets/
#kubectl cp  demo/$POD_NAME:/var/run/secrets/eks.amazonaws.com/serviceaccount/token /tmp/$1-irsa-token

kubectl exec -n demo --container k8s-local-remote-demo-debug $POD_NAME -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token > /tmp/$1-irsa-token

refresh_token() {
  while true; do
    kubectl exec -n demo --container k8s-local-remote-demo-debug "$POD_NAME" -- cat /var/run/secrets/eks.amazonaws.com/serviceaccount/token > /tmp/$1-irsa-token
    sleep 300  # 5 minutes
  done
}

refresh_token "$1" &
REFRESH_PID=$!

export AWS_WEB_IDENTITY_TOKEN_FILE="/tmp/$1-irsa-token"

echo "AWS_WEB_IDENTITY_TOKEN_FILE: $AWS_WEB_IDENTITY_TOKEN_FILE"
# Running apps
echo "Running Telepresence..."
telepresence replace "$1" --port 8000:8000 --container "$1" -- bash -c "AWS_WEB_IDENTITY_TOKEN_FILE=\"$AWS_WEB_IDENTITY_TOKEN_FILE\" .venv/bin/python3 -m debugpy --listen 0.0.0.0:5690 -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload"

kill $REFRESH_PID