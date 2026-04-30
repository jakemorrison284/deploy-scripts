# deploy-scripts

CI/CD pipeline scripts for NovaPay deployments.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Repository Contents](#repository-contents)
- [Usage Instructions](#usage-instructions)
  - [Running Deployment Scripts](#running-deployment-scripts)
  - [Failover Process](#failover-process)
  - [Restoring PostgreSQL Database](#restoring-postgresql-database)
  - [Running Tests](#running-tests)
- [Configuration and Environment Variables](#configuration-and-environment-variables)
- [Backup Strategy Compliance](#backup-strategy-compliance)
- [Troubleshooting](#troubleshooting)
- [Getting Help](#getting-help)
- [Contribution Guidelines](#contribution-guidelines)
- [License](#license)

## Overview

This repository contains shell scripts used for deploying the NovaPay application, handling failover procedures, and managing PostgreSQL database restores. It also includes testing scripts to validate backup and restore operations. These scripts aim to streamline and automate key deployment and disaster recovery tasks.

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/jakemorrison284/deploy-scripts.git
   cd deploy-scripts
   ```

2. Install prerequisites (see [Prerequisites](#prerequisites) below).

3. Set required environment variables. For example:
   ```bash
   export DEPLOY_ENV=production
   export PG_BACKUP_PATH=/path/to/backup
   ```

4. Run deployment or other scripts as needed (see [Usage Instructions](#usage-instructions)).

## Prerequisites

Before using the scripts, ensure the following tools are installed:

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/)  
  Required by `deploy.sh` for build or deployment tasks involving Node.js.
- [Docker](https://www.docker.com/)  
  Required if deploying within containerized environments using `deploy.sh`.

Check script headers for any script-specific dependencies.

## Repository Contents

- `deploy.sh`: Main deployment script for deploying NovaPay to specified environments.
- `failover.sh`: Script to initiate and manage failover processes.
- `restore_postgres.sh`: Script to restore PostgreSQL databases from backup files.
- `test_restore_postgres.sh`: Automated tests for validating database restore operations.
- `restore_postgres_diff.patch`: Patch file related to PostgreSQL restore.
- `release_yaml_improvements.md`: Documentation and proposals for improving deployment YAML.
- `docs/`: Additional documentation resources.
- `runbook/`: Runbooks for operational procedures.
- `tests/`: Test scripts and data.

## Usage Instructions

### Running Deployment Scripts

Run the deployment script with the environment option:

```bash
bash deploy.sh --env production
```

Replace `production` with your target environment (e.g., staging, development).

**Expected output:** Confirmation message indicating successful deployment.

### Failover Process

Initiate failover procedures by running:

```bash
bash failover.sh
```

**Note:** Check the output for any error messages.

### Restoring PostgreSQL Database

Restore a PostgreSQL database backup with:

```bash
bash restore_postgres.sh --backup-file /path/to/backup/file
```

Refer to the script header or `runbook/` documentation for detailed parameters.

### Running Tests

Validate restore process with:

```bash
bash test_restore_postgres.sh
```

Ensure backup files used for testing comply with retention policies.

## Configuration and Environment Variables

Common environment variables:

- `DEPLOY_ENV`: Deployment environment (e.g., production, staging).
- `PG_BACKUP_PATH`: Path to PostgreSQL backup files.
- `FAILOVER_CONFIG`: Failover configuration file or parameters.

Set variables via:

```bash
export VAR_NAME=value
```

For detailed configuration, see the [docs/](docs/) directory.

## Backup Strategy Compliance

- Backup files must follow retention policies as per [Infrastructure Backup Guidelines](docs/backup_guidelines.md).
- Retain backups for the required duration to ensure compliance.
- Restore scripts include automated tests to validate backup integrity.

## Troubleshooting

- Check script output logs for errors.
- Verify environment variables and configurations are set correctly.
- Validate backup file integrity before restoration.
- Common issues and resolutions are documented in the `runbook/` directory.
- Enable verbose mode by adding `-v` to scripts where supported.

## Getting Help

- For further assistance, open an issue in this repository.
- Consult the team or communication channels for support.

## Contribution Guidelines

We welcome contributions! Please submit pull requests or open issues for enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
