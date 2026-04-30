# Runbook Entry for PostgreSQL Restoration

## Overview
This runbook outlines the procedure for restoring a PostgreSQL database using the `restore_postgres.sh` script.

## Script Location
- [restore_postgres.sh](https://github.com/jakemorrison284/deploy-scripts/blob/main/restore_postgres.sh)

## Usage
To use the `restore_postgres.sh` script, follow the instructions below:

### Command:
```bash
./restore_postgres.sh <database_name> <backup_file>
```

### Parameters:
- **database_name**: The name of the PostgreSQL database to restore.
- **backup_file**: The path to the SQL backup file that contains the database dump.

### Example:
```bash
./restore_postgres.sh my_database /path/to/backup_file.sql
```

## Key Features
- Configurable PostgreSQL connection parameters (host, port, user).
- Optional notification support through an external script.
- Checksum validation for backup file integrity.
- Support for various backup file formats including .sql, .dump, .gz, and .zip.
- Dry-run mode to simulate the restore process without making any changes.
- Detailed logging of restore operations.

## Important Notes:
- Ensure that the PostgreSQL server is running and accessible.
- The script requires that the user has the necessary permissions to restore the database.
- Backup files should be verified for integrity before restoration.

## Troubleshooting:
- If you encounter issues, check the PostgreSQL logs for more details on the failure.
- Ensure that the provided backup file exists and is a valid SQL dump.

## Potential Improvements
- Add support for additional checksum algorithms beyond sha256 for flexibility.
- Implement enhanced error handling for network or authentication failures.
- Include automatic backup file decompression for additional compression formats.
- Provide more granular logging levels and options.
- Add support for parallel restoration to speed up large database restores.
- Integrate with centralized monitoring or alerting systems for notifications.

## Conclusion
This script provides a straightforward method for restoring PostgreSQL databases as part of disaster recovery procedures. For any questions or further assistance, please contact the database administrator.
