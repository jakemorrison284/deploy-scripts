#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <database_name> <backup_file> [username] [--dry-run]"
    exit 1
}

# Function to restore a PostgreSQL database
restore_database() {
    local db_name=$1
    local backup_file=$2
    local username=${3:-postgres}
    local dry_run=${4:-false}

    if [[ $dry_run == true ]]; then
        echo "Dry run: Restoring database '$db_name' from backup file '$backup_file' as user '$username'."
        return
    fi

    echo "Restoring database '$db_name' from backup file '$backup_file' as user '$username'..."

    # Restore the database
    psql -U "$username" -d "$db_name" -f "$backup_file"

    echo "Database '$db_name' restored successfully from '$backup_file'."
}

# Check for the correct number of arguments
if [ "$#" -lt 2 ]; then
    usage
fi

DATABASE_NAME=$1
BACKUP_FILE=$2
USERNAME=${3:-postgres}

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
restore_database "$DATABASE_NAME" "$BACKUP_FILE" "$USERNAME" "$4"

# Log the restoration process
LOG_FILE="restore_log_$(date +%Y%m%d_%H%M%S).log"
echo "Restoration of database '$DATABASE_NAME' from '$BACKUP_FILE' on $(date)" >> "$LOG_FILE"