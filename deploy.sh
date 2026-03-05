#!/bin/bash
set -euo pipefail
SERVICE=$1; TAG=$2; ENV=${3:-staging}
echo "Deploying $SERVICE:$TAG to $ENV"
kubectl set image deployment/$SERVICE $SERVICE=novapay/$SERVICE:$TAG -n novapay
kubectl rollout status deployment/$SERVICE -n novapay
