# deploy-scripts

CI/CD pipeline scripts for NovaPay deployments.

## Overview

This repository contains shell scripts used for deploying the NovaPay application, handling failover procedures, and managing PostgreSQL database restores. It also includes testing scripts to validate backup and restore operations. These scripts aim to streamline and automate key deployment and disaster recovery tasks.

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/jakemorrison284/deploy-scripts.git
   cd deploy-scripts
   ```

2. Review prerequisites and ensure required tools are installed.

3. Run the deployment or other scripts as needed (see Usage Instructions below).

## Prerequisites

Before using the scripts, ensure you have the following installed on your system:

- [Git](https://git-scm.com/)  
- [Node.js](https://nodejs.org/)  
  - Required by: `deploy.sh` (for build or deployment tasks involving Node.js)
- [Docker](https://www.docker.com/)  
  - Required if deploying within containerized environments using `deploy.sh`

Verify the individual script headers for any additional dependencies.

## Repository Contents

- `deploy.sh`  
  Main deployment script to deploy the NovaPay application to specified environments. Requires Node.js and optionally Docker.
- `failover.sh`  
  Script to initiate and manage failover processes in case of system failures.
- `restore_postgres.sh`  
  Script to restore PostgreSQL databases from backup files.
- `test_restore_postgres.sh`  
  Automated tests to validate database restore operations.
- `restore_postgres_diff.patch`  
  Patch file related to the PostgreSQL restore process.
- `release_yaml_improvements.md`  
  Documentation and proposals related to improving deployment YAML configurations.
- `docs/`  
  Directory containing additional documentation resources.
- `runbook/`  
  Directory with runbooks for operational procedures.
- `tests/`  
  Directory containing test scripts and test data.

## Usage Instructions

### Running Deployment Scripts

To deploy the application, run:

```bash
bash deploy.sh --env production
```

Replace `production` with the desired environment (e.g., staging, development).

### Failover Process

To initiate a failover, run:

```bash
bash failover.sh
```

This script will execute the configured failover procedures.

### Restoring PostgreSQL Database

To restore a PostgreSQL database from a backup, use:

```bash
bash restore_postgres.sh --backup-file /path/to/backup/file
```

Refer to the script header or `runbook/` documentation for detailed instructions and required parameters.

### Running Tests

To validate the restore process, run the test script:

```bash
bash test_restore_postgres.sh
```

Ensure that backup files used for testing comply with retention and format policies.

## Configuration and Environment Variables

Some scripts require configuration through environment variables or configuration files. Common variables include:

- `DEPLOY_ENV`  Specifies the deployment environment (e.g., production, staging).
- `PG_BACKUP_PATH`  Path to PostgreSQL backup files.
- `FAILOVER_CONFIG`  Configuration file or parameters for failover behavior.

Please check individual script headers or the `docs/` directory for specific environment variables and configuration details.

For enhanced details on environment variables and direct links to runbooks, please see the [Enhanced README Additions](docs/enhanced_readme_additions.md) document.

## Backup Strategy Compliance

### Retention Policies

- Backup files used with restore scripts should adhere to defined retention policies as per [Infrastructure Backup Guidelines](docs/backup_guidelines.md).
- Retain backups for the required duration to ensure data integrity and compliance.

### Testing Procedures

- Restore scripts include automated testing to validate backup integrity and successful restoration.
- Regularly update and run tests to comply with evolving backup and restoration policies.

## Troubleshooting

- Review script output logs for errors and warnings.
- Verify environment variables and configurations are correctly set.
- Check backup file validity before restoration.
- Common error scenarios and resolutions can be found in the `runbook/` directory.
- For additional help, open an issue or consult the team.

## Contribution Guidelines

We welcome contributions! Please submit a pull request or open an issue to discuss enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
