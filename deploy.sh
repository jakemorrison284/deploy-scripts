#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <service> <tag> [environment]"
    exit 1
}

# Check for the correct number of arguments
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
fi

SERVICE=$1
TAG=$2
ENV=${3:-staging}

# Validate the SERVICE and TAG variables
if [[ -z "$SERVICE" || -z "$TAG" ]]; then
    echo "Error: SERVICE and TAG cannot be empty."
    usage
fi

# Validate environment
ALLOWED_ENVS=("staging" "production")
if [[ ! " ${ALLOWED_ENVS[@]} " =~ " ${ENV} " ]]; then
    echo "Error: Invalid environment '$ENV'. Allowed environments are: ${ALLOWED_ENVS[*]}.";
    exit 1
fi

# Check if kubectl context is set
if ! kubectl config current-context &>/dev/null; then
    echo "Error: No Kubernetes context is set."
    exit 1
fi

# Check if deployment exists
if ! kubectl get deployment "$SERVICE" -n novapay &>/dev/null; then
    echo "Error: Deployment '$SERVICE' does not exist in the 'novapay' namespace."
    exit 1
fi

# Backup current deployment
kubectl get deployment "$SERVICE" -n novapay -o yaml > "$SERVICE-backup-$(date +%Y%m%d%H%M%S).yaml"

# Deploy the new image
echo "Deploying $SERVICE:$TAG to $ENV"
kubectl set image deployment/$SERVICE $SERVICE=novapay/$SERVICE:$TAG -n novapay

# Check rollout status and rollback on failure
if ! kubectl rollout status deployment/$SERVICE -n novapay; then
    echo "Deployment failed. Rolling back..."
kubectl rollout undo deployment/$SERVICE -n novapay
    exit 1
fi

# Logging deployment success
LOG_FILE="deployment.log"
echo "Deployment of $SERVICE:$TAG to $ENV succeeded at $(date)" >> $LOG_FILE

# Notification mechanism (placeholder)
echo "Sending notification for successful deployment of $SERVICE:$TAG to $ENV"
# Here, you would implement the actual notification logic, e.g., sending an email or a message to a webhook.

# Enhanced logging
echo "Deployment process completed for $SERVICE:$TAG to $ENV at $(date)" >> $LOG_FILE
