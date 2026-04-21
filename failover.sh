#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <service>"
    exit 1
}

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    usage
fi

SERVICE=$1

# Validate the SERVICE variable
if [[ -z "$SERVICE" ]]; then
    echo "Error: SERVICE cannot be empty."
    usage
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

# Rollback to the previous deployment
kubectl rollout undo deployment/$SERVICE -n novapay

# Logging rollback success
LOG_FILE="rollback.log"
echo "Rollback of $SERVICE to the previous stable version succeeded at $(date)" >> $LOG_FILE

echo "Rollback completed for $SERVICE."