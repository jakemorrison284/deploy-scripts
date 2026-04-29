#!/bin/bash
set -euo pipefail

# Function to print usage
usage() {
    echo "Usage: $0 <database_name> <backup_file>"
    exit 1
}

# Function to restore a PostgreSQL database
restore_database() {
    local db_name=$1
    local backup_file=$2

    echo "Restoring database '$db_name' from backup file '$backup_file'..."

    # Restore the database
    psql -U postgres -d "$db_name" -f "$backup_file"

    echo "Database '$db_name' restored successfully from '$backup_file'."
}

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
    usage
fi

DATABASE_NAME=$1
BACKUP_FILE=$2

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

# Call the restore function
restore_database "$DATABASE_NAME" "$BACKUP_FILE"