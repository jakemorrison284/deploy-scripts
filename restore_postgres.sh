#!/bin/bash
set -euo pipefail

# Configuration (can be overridden by environment variables)
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:-postgres}
NOTIFY_SCRIPT=${NOTIFY_SCRIPT:-} # Path to a script for notifications (optional)
VERBOSE=${VERBOSE:-false} # Verbose logging
LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-7} # Days to keep log files

LOG_FILE="restore_log_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages with timestamp and level
log() {
    local level=$1
    local message=$2
    if [[ "$VERBOSE" == true || "$level" != "DEBUG" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
    fi
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
    echo "Usage: $0 <database_name> <backup_file> [--checksum=<checksum>] [--checksum-type=<type>] [--dry-run] [--host=<host>] [--port=<port>] [--user=<user>] [--verbose]"
    exit 1
}

# Function to clean old log files
clean_old_logs() {
    find . -maxdepth 1 -type f -name 'restore_log_*.log' -mtime +$LOG_RETENTION_DAYS -exec rm -f {} +
    if [[ $? -eq 0 ]]; then
        log "INFO" "Old log files older than $LOG_RETENTION_DAYS days have been removed."
    else
        log "WARN" "Failed to clean old log files."
    fi
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
        sha1)
            if ! command -v sha1sum &> /dev/null; then
                log "ERROR" "sha1sum command not found. Cannot validate checksum."
                exit 1
            fi
            checksum_actual=$(sha1sum "$file" | awk '{print $1}')
            ;;
        md5)
            if ! command -v md5sum &> /dev/null; then
                log "ERROR" "md5sum command not found. Cannot validate checksum."
                exit 1
            fi
            checksum_actual=$(md5sum "$file" | awk '{print $1}')
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
        if [[ "$VERBOSE" == true ]]; then
            gunzip -c "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" 2>&1 | tee -a "$LOG_FILE"
            local status=${PIPESTATUS[1]}
        else
            gunzip -c "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" 2>> "$LOG_FILE"
            local status=${PIPESTATUS[1]}
        fi
    elif [[ "$backup_file" =~ \.zip$ ]]; then
        if [[ "$VERBOSE" == true ]]; then
            unzip -p "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" 2>&1 | tee -a "$LOG_FILE"
            local status=${PIPESTATUS[1]}
        else
            unzip -p "$backup_file" | psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" 2>> "$LOG_FILE"
            local status=${PIPESTATUS[1]}
        fi
    else
        if [[ "$VERBOSE" == true ]]; then
            psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" -f "$backup_file" 2>&1 | tee -a "$LOG_FILE"
            local status=${PIPESTATUS[0]}
        else
            psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db_name" -f "$backup_file" 2>> "$LOG_FILE"
            local status=$?
        fi
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
CHECKSUM_TYPE="sha256"
DRY_RUN=false

while (( "$#" )); do
    case "$1" in
        --checksum=*)
            CHECKSUM="${1#*=}"
            shift
            ;;
        --checksum-type=*)
            CHECKSUM_TYPE="${1#*=}"
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

clean_old_logs

validate_backup_file "$BACKUP_FILE" "$CHECKSUM" "$CHECKSUM_TYPE"

# Start restoration
{
    restore_database "$DATABASE_NAME" "$BACKUP_FILE" "$DRY_RUN"
} 2>&1 | tee -a "$LOG_FILE"
