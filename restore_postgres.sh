#!/bin/bash
set -euo pipefail

# Configuration (can be overridden by environment variables)
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres}
NOTIFY_SCRIPT=${NOTIFY_SCRIPT:-} # Path to a script for notifications (optional)
VERBOSE=${VERBOSE:-false} # Verbose logging

LOG_FILE="restore_log_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages with timestamp and level
log() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
}

# Function to send notifications (if NOTIFY_SCRIPT is set)
notify() {
    local message=$1
    echo "$message"
    if [[ -n "$NOTIFY_SCRIPT" && -x "$NOTIFY_SCRIPT" ]]; then
        "$NOTIFY_SCRIPT" "$message"
    fi
}

# Function to print usage
usage() {
    echo "Usage: $0 <database_name> <backup_file> [--checksum=<checksum>] [--dry-run] [--host=<host>] [--port=<port>] [--user=<user>] [--verbose]"
    exit 1
}

# Function to validate the checksum of the backup file
validate_checksum() {
    local file=$1
    local checksum_expected=$2
    local checksum_type=${3:-sha256}

    if [[ -z "$checksum_expected" ]]; then
        # No checksum provided, skip validation
        log "INFO" "No checksum provided, skipping checksum validation."
        return
    fi

    # Check checksum command availability early
    case "$checksum_type" in
        sha256)
            if ! command -v sha256sum &> /dev/null; then
                log "ERROR" "sha256sum command not found. Cannot validate checksum."
                exit 1
            fi
            checksum_actual=$(sha256sum "$file" | awk '{print $1}')
            ;;
        *)
            log "ERROR" "Unsupported checksum type '$checksum_type'."
            exit 1
            ;;
    esac

    if [[ "$checksum_actual" != "$checksum_expected" ]]; then
        log "ERROR" "Checksum verification failed for file '$file'. Expected: $checksum_expected, Actual: $checksum_actual."
        notify "Checksum verification failed for file '$file'."
        exit 1
    fi

    log "INFO" "Checksum verification passed for file '$file'."
    notify "Checksum verification passed for file '$file'."
}

# Function to validate backup file format and integrity
validate_backup_file() {
    local file=$1
    local checksum=$2
    local checksum_type=$3

    if [[ ! -f "$file" ]]; then
        log "ERROR" "Backup file '$file' does not exist."
        notify "Backup file '$file' does not exist."
        exit 1
    fi
    if [[ ! "$file" =~ \.sql$ ]] && [[ ! "$file" =~ \.dump$ ]] && [[ ! "$file" =~ \.gz$ ]] && [[ ! "$file" =~ \.zip$ ]]; then
        log "ERROR" "Backup file '$file' is not a supported format (.sql, .dump, .gz, .zip)."
        notify "Backup file '$file' is not a supported format (.sql, .dump, .gz, .zip)."
        exit 1
    fi

    # Validate checksum if provided
    validate_checksum "$file" "$checksum" "$checksum_type"

    # Additional integrity check: try listing contents for .dump files
    if [[ "$file" =~ \.dump$ ]]; then
        if ! pg_restore --list "$file" &> /dev/null; then
            log "ERROR" "Backup file '$file' integrity check failed with pg_restore --list."
            notify "Backup file '$file' integrity check failed."
            exit 1
        else
            log "INFO" "Backup file '$file' passed integrity check with pg_restore --list."
        fi
    fi
}

# Function to restore a PostgreSQL database
restore_database() {
    local db_name=$1
    local backup_file=$2
    local dry_run=$3

    notify "Starting restoration of database '$db_name' from backup file '$backup_file' on host '$PGHOST:$PGPORT' as user '$PGUSER'."

    if [[ $dry_run == true ]]; then
        notify "Dry run: Restore operation simulated. No changes made."
        return
    fi

    # Handle compressed backups
    if [[ "$backup_file" =~ \.gz$ ]]; then
        gunzip -c "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" 2>> "$LOG_FILE"
        local status=${PIPESTATUS[1]}
    elif [[ "$backup_file" =~ \.zip$ ]]; then
        unzip -p "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" 2>> "$LOG_FILE"
        local status=${PIPESTATUS[1]}
    else
        psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" -f "$backup_file" 2>> "$LOG_FILE"
        local status=$?
    fi

    if [[ $status -ne 0 ]]; then
        log "ERROR" "Database restoration failed with status $status. Check $LOG_FILE for details."
        notify "Database restoration failed with status $status."
        exit $status
    fi

    notify "Database '$db_name' restored successfully from '$backup_file'."
    log "INFO" "Database '$db_name' restored successfully from '$backup_file'."
}

# Parse arguments
if [ "$#" -lt 2 ]; then
    usage
fi

DATABASE_NAME=$1
BACKUP_FILE=$2
shift 2

CHECKSUM=""
DRY_RUN=false

while (( "$#" )); do
    case "$1" in
        --checksum=*)
            CHECKSUM="${1#*=}"
            shift
            ;;
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
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac

done

# Use checksum from environment variable if not provided as parameter
if [[ -z "$CHECKSUM" ]]; then
    CHECKSUM=${BACKUP_CHECKSUM:-}
fi

# Validate inputs
if [[ -z "$DATABASE_NAME" ]]; then
    log "ERROR" "DATABASE_NAME cannot be empty."
    usage
fi

validate_backup_file "$BACKUP_FILE" "$CHECKSUM" "sha256"

# Start restoration
{
    restore_database "$DATABASE_NAME" "$BACKUP_FILE" "$DRY_RUN"
} 2>&1 | tee -a "$LOG_FILE"
