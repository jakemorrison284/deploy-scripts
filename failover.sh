#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <service>"
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
    local full_message="[NOTIFICATION] [$timestamp] Rollback Status: $status - $message"
    
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
        echo "Failed to send notification for status: $status on $(date)" >> notification_errors.log
    else
        echo "Notification sent successfully."
    fi
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
if kubectl rollout undo deployment/$SERVICE -n novapay; then
    LOG_FILE="rollback.log"
    echo "Rollback of $SERVICE to the previous stable version succeeded at $(date)" >> $LOG_FILE
    send_notification "SUCCESS" "Rollback of $SERVICE succeeded."
else
    send_notification "FAILURE" "Rollback of $SERVICE failed."
    echo "Rollback failed for $SERVICE."
    exit 1
fi

# Enhanced error handling, logging, and safety checks

# Define log file and backup directory
LOG_FILE="/var/log/failover.log"
BACKUP_DIR="/backup/failover"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Function to log messages with timestamps
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to handle errors
handle_error() {
  local error_message=$1
  local exit_code=$2
  log_message "ERROR: $error_message"
  exit $exit_code
}

# Check if user wants to proceed with rollback
read -p "Are you sure you want to perform a rollback? (y/n) " -n 1 -r
if [[ $REPLY != "y" ]]; then
  log_message "Rollback cancelled by user."
  exit 0
fi

# Backup current deployment configuration
log_message "Creating backup of current deployment configuration..."
if ! cp -r /path/to/deployment/config $BACKUP_DIR; then
  handle_error "Failed to create backup of deployment configuration." 1
fi

# Perform rollback
log_message "Starting rollback process..."
if ! kubectl rollout undo deployment/my-deployment; then
  handle_error "Rollback failed. Check logs for details." 1
fi

# Test if the previous stable version is functioning correctly
log_message "Testing previous stable version..."
if ! kubectl rollout status deployment/my-deployment; then
  handle_error "Previous stable version is not functioning correctly." 1
fi

# Notify user of successful rollback
log_message "Rollback completed successfully."

exit 0