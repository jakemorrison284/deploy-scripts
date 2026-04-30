#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <database_name> <backup_file> [username] [host] [port] [--dry-run]"
    echo "  database_name: Name of the PostgreSQL database to restore"
    echo "  backup_file: Path to the backup file (.sql or .dump)"
    echo "  username: PostgreSQL username (default: 'postgres')"
    echo "  host: PostgreSQL host (default: 'localhost')"
    echo "  port: PostgreSQL port (default: 5432)"
    echo "  --dry-run: Show commands without executing"
    exit 1
}

# Function to get database password from secrets manager (placeholder)
get_db_password() {
    local user=$1
    # Placeholder: Replace this with integration to your secrets manager or environment variable
    # For example: echo $(vault kv get -field=password secret/db/$user)
    echo "${DB_PASSWORD:-}"
}

# Function to restore a PostgreSQL database
restore_database() {
    local db_name=$1
    local backup_file=$2
    local username=$3
    local host=$4
    local port=$5
    local dry_run=$6

    local db_password
    db_password=$(get_db_password "$username")

    local psql_cmd="PGPASSWORD='$db_password' psql -U \"$username\" -h \"$host\" -p \"$port\" -d \"$db_name\" -f \"$backup_file\""

    if [[ $dry_run == true ]]; then
        echo "Dry run: Would execute: $psql_cmd"
        return
    fi

    echo "Restoring database '$db_name' from backup file '$backup_file' as user '$username' on $host:$port..."

    # Execute the restore command with error handling
    if ! eval $psql_cmd; then
        echo "Error: Failed to restore database '$db_name' from '$backup_file'. Check logs for details."
        exit 1
    fi

    echo "Database '$db_name' restored successfully from '$backup_file'."
}

# Check for minimum arguments
if [ "$#" -lt 2 ]; then
    usage
fi

DATABASE_NAME=$1
BACKUP_FILE=$2
USERNAME=${3:-postgres}
HOST=${4:-localhost}
PORT=${5:-5432}
DRY_RUN=false

if [[ "${!#}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Validate the database name
if [[ -z "$DATABASE_NAME" ]]; then
    echo "Error: DATABASE_NAME cannot be empty."
    usage
fi

# Validate the backup file
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Error: Backup file '$BACKUP_FILE' does not exist."
    exit 1
fi

# Validate the backup file format (assuming .sql or .dump as valid formats)
if [[ ! "$BACKUP_FILE" =~ \.sql$ ]] && [[ ! "$BACKUP_FILE" =~ \.dump$ ]]; then
    echo "Error: Backup file '$BACKUP_FILE' is not a valid SQL or dump file."
    exit 1
fi

# Call the restore function
restore_database "$DATABASE_NAME" "$BACKUP_FILE" "$USERNAME" "$HOST" "$PORT" "$DRY_RUN"

# Log the restoration process
LOG_FILE="restore_log_$(date +%Y%m%d_%H%M%S).log"
echo "Restoration of database '$DATABASE_NAME' from '$BACKUP_FILE' on $(date)" >> "$LOG_FILE"
