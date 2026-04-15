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

# Optionally, you can add more specific validation for SERVICE and TAG formats if necessary

echo "Deploying $SERVICE:$TAG to $ENV"
kubectl set image deployment/$SERVICE $SERVICE=novapay/$SERVICE:$TAG -n novapay
kubectl rollout status deployment/$SERVICE -n novapay
