#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <service> <tag> [environment]"
    exit 1
}

# Function to send notifications
send_notification() {
    local status=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Define your notification channel/service
    local notification_channel="$NOTIFICATION_CHANNEL"  # Use environment variable

    # Construct the notification message
    local full_message="[NOTIFICATION] [$timestamp] Deployment Status: $status - $message"

    # Using a hypothetical command to send notifications
    if ! send_to_channel "$notification_channel" "$full_message"; then
        echo "Error: Failed to send notification for status: $status. Attempting to retry..."
        
        # Retry logic (simple example)
        for i in {1..3}; do
            if send_to_channel "$notification_channel" "$full_message"; then
                echo "Notification sent successfully on retry #$i."
                return
            fi
            echo "Retry #$i failed. Waiting before retrying..."
            sleep 2 # Wait before retrying
        done
        
        echo "Error: All retries failed. Notification was not sent."
        # Optional: Log this error to a file for further analysis
        echo "Failed to send notification for status: $status on $(date)" >> notification_errors.log
    else
        echo "Notification sent successfully."
    fi
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
    echo "Error: Invalid environment '$ENV'. Allowed environments are: ${ALLOWED_ENVS[*]}";
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
BACKUP_FILE="$SERVICE-backup-$(date +%Y%m%d%H%M%S).yaml"
kubectl get deployment "$SERVICE" -n novapay -o yaml > "$BACKUP_FILE"

# Deploy the new image
echo "Deploying $SERVICE:$TAG to $ENV"
kubectl set image deployment/$SERVICE $SERVICE=novapay/$SERVICE:$TAG -n novapay

# Check rollout status and rollback on failure
if ! kubectl rollout status deployment/$SERVICE -n novapay; then
    echo "Deployment failed. Rolling back..."
kubectl rollout undo deployment/$SERVICE -n novapay
    send_notification "FAILURE" "Deployment of $SERVICE:$TAG failed and has been rolled back."
    exit 1
fi

# Health check
if ! kubectl get pods -n novapay -l app=$SERVICE | grep -q 'Running'; then
    echo "Health check failed for $SERVICE after deployment."
    send_notification "FAILURE" "Health check failed for $SERVICE after deployment."
    exit 1
fi

# Logging deployment success
LOG_FILE="deployment.log"
echo "Deployment of $SERVICE:$TAG to $ENV succeeded at $(date)" >> $LOG_FILE
send_notification "SUCCESS" "Deployment of $SERVICE:$TAG to $ENV succeeded."

# Enhanced logging
echo "Deployment process completed for $SERVICE:$TAG to $ENV at $(date)" >> $LOG_FILE
