# Enhanced README Additions for deploy-scripts

This document provides enhancements to the main README for better user guidance, including:

- Direct links to key runbooks for operational procedures.
- More detailed descriptions of environment variables used by the scripts.

---

## Runbook Links

For detailed operational procedures, refer to the following runbooks located in the `runbook/` directory:

- [Deployment Runbook](runbook/deployment_runbook.md) - Step-by-step instructions for deploying the NovaPay application.
- [Failover Runbook](runbook/failover_runbook.md) - Procedures to initiate and manage failover during system failures.
- [PostgreSQL Restore Runbook](runbook/restore_postgres_runbook.md) - Guidance on restoring PostgreSQL databases from backups.
- [Testing Runbook](runbook/testing_runbook.md) - Instructions for running tests on backup and restore functionalities.

*Note: If any of these files are missing, please coordinate with the operations team to create or update them.*

## Detailed Environment Variables

The following environment variables are commonly used by the deployment and maintenance scripts. Please ensure they are set appropriately before running the scripts.

| Variable Name    | Description                                                | Example Value           |
|------------------|------------------------------------------------------------|------------------------|
| `DEPLOY_ENV`     | Specifies the deployment environment (e.g., production, staging, development). | `production`           |
| `PG_BACKUP_PATH` | The filesystem path where PostgreSQL backup files are stored. | `/var/backups/postgres` |
| `FAILOVER_CONFIG`| Path to the configuration file or parameters controlling failover behavior. | `/etc/failover/config.yaml` |
| `PGHOST`         | PostgreSQL server hostname or IP address.                  | `localhost`            |
| `PGPORT`         | PostgreSQL server port.                                     | `5432`                 |
| `PGUSER`         | Username for PostgreSQL authentication.                    | `postgres`             |
| `PGPASSWORD`     | Password for the PostgreSQL user (consider using secure vaults). | `password123`          |

*Note: Some variables can be overridden on the command line or in script parameters as noted in individual script headers.*

---

Please consider merging these additions into the main README or linking to this file for enhanced developer and operator experience.