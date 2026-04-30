#!/bin/bash
set -euo pipefail

# Configuration (can be overridden by environment variables)
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres}
NOTIFY_SCRIPT=${NOTIFY_SCRIPT:-} # Path to a script for notifications (optional)
NOTIFY_EMAIL=${NOTIFY_EMAIL:-}   # Email address for notifications (optional)
NOTIFY_SLACK_WEBHOOK=${NOTIFY_SLACK_WEBHOOK:-} # Slack webhook URL (optional)
MAX_RETRIES=${MAX_RETRIES:-3}
RETRY_BACKOFF_SECONDS=${RETRY_BACKOFF_SECONDS:-10}

LOG_FILE="restore_log_$(date +%Y%m%d_%H%M%S).log"

# Function to send notifications (if NOTIFY_SCRIPT is set)
notify() {
    local message=$1
    echo "$message"
    if [[ -n "$NOTIFY_SCRIPT" && -x "$NOTIFY_SCRIPT" ]]; then
        "$NOTIFY_SCRIPT" "$message"
    fi
    if [[ -n "$NOTIFY_EMAIL" ]]; then
        echo "$message" | mail -s "Postgres Restore Notification" "$NOTIFY_EMAIL"
    fi
    if [[ -n "$NOTIFY_SLACK_WEBHOOK" ]]; then
        curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$NOTIFY_SLACK_WEBHOOK" >/dev/null 2>&1 || true
    fi
}

usage() {
    cat <<EOF
Usage: $0 <database_name> <backup_file> [options]

Options:
  --dry-run                 Simulate the restore operation without making changes.
  --host=<host>             PostgreSQL host (default: $PGHOST)
  --port=<port>             PostgreSQL port (default: $PGPORT)
  --user=<user>             PostgreSQL user (default: $PGUSER)
  --max-retries=<number>    Maximum retry attempts on failure (default: $MAX_RETRIES)
  --help                    Show this help message and exit

Example:
  $0 mydb backup.sql.gz --dry-run --host=db-host --user=admin

EOF
    exit 1
}

validate_backup_file() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        echo "Error: Backup file '$file' does not exist." | tee -a "$LOG_FILE"
        exit 1
    fi
    if [[ ! "$file" =~ \.sql$ ]] && [[ ! "$file" =~ \.dump$ ]] && [[ ! "$file" =~ \.gz$ ]] && [[ ! "$file" =~ \.zip$ ]]; then
        echo "Error: Backup file '$file' is not a supported format (.sql, .dump, .gz, .zip)." | tee -a "$LOG_FILE"
        exit 1
    fi
    # Checksum verification if checksum file exists
    if [[ -f "$file.sha256" ]]; then
        echo "Verifying checksum for $file ..."
        sha256sum -c "$file.sha256"
        if [[ $? -ne 0 ]]; then
            echo "Error: Checksum verification failed for $file." | tee -a "$LOG_FILE"
            exit 1
        fi
    fi
}

restore_database() {
    local db_name=$1
    local backup_file=$2
    local dry_run=$3

    notify "Starting restoration of database '$db_name' from backup file '$backup_file' on host '$PGHOST:$PGPORT' as user '$PGUSER'."

    if [[ $dry_run == true ]]; then
        notify "Dry run: Restore operation simulated. No changes made."
        return
    fi

    local attempt=0
    local status=1

    until [[ $attempt -ge $MAX_RETRIES ]]
    do
        if [[ "$backup_file" =~ \.gz$ ]]; then
            gunzip -c "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name"
        elif [[ "$backup_file" =~ \.zip$ ]]; then
            unzip -p "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name"
        else
            psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" -f "$backup_file"
        fi
        status=$?
        if [[ $status -eq 0 ]]; then
            break
        fi
        attempt=$((attempt+1))
        notify "Restore attempt $attempt/$MAX_RETRIES failed with status $status. Retrying after $RETRY_BACKOFF_SECONDS seconds..."
        sleep $RETRY_BACKOFF_SECONDS
    done

    if [[ $status -ne 0 ]]; then
        notify "Error: Database restoration failed after $MAX_RETRIES attempts."
        exit $status
    fi

    notify "Database '$db_name' restored successfully from '$backup_file'."
}

# Parse arguments
if [ "$#" -lt 2 ]; then
    usage
fi

DATABASE_NAME=$1
BACKUP_FILE=$2
shift 2

DRY_RUN=false

while (( "$#" )); do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --host=*)
            PGHOST="${1#*=}"
            shift
            ;;
        --port=*)
            PGPORT="${1#*=}"
            shift
            ;;
        --user=*)
            PGUSER="${1#*=}"
            shift
            ;;
        --max-retries=*)
            MAX_RETRIES="${1#*=}"
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$DATABASE_NAME" ]]; then
    echo "Error: DATABASE_NAME cannot be empty." | tee -a "$LOG_FILE"
    usage
fi

validate_backup_file "$BACKUP_FILE"

if [[ $DRY_RUN == true ]]; then
    notify "Dry run mode enabled. Simulating all steps."
    notify "Validating backup file format and checksum."
    # Simulate restore_database without executing commands
    notify "Restore operation would be executed here."
    notify "Notifications would be sent as configured."
else
    # Start restoration
    {
        restore_database "$DATABASE_NAME" "$BACKUP_FILE" "$DRY_RUN"
    } 2>&1 | tee -a "$LOG_FILE"
}
