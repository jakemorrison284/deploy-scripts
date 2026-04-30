# deploy-scripts

CI/CD pipeline scripts for NovaPay deployments.

## Overview

This repository contains shell scripts used for deploying the NovaPay application, handling failover procedures, and managing PostgreSQL database restores. It also includes testing scripts to validate backup and restore operations. These scripts aim to streamline and automate key deployment and disaster recovery tasks.

## Prerequisites

Before using the scripts, ensure you have the following installed on your system:

- [Git](https://git-scm.com/) 
- [Node.js](https://nodejs.org/) 
required for some scripts (please check individual script requirements)
- [Docker](https://www.docker.com/) 
required if deploying within containerized environments

## Repository Contents

- `deploy.sh` 

 Main deployment script to deploy the NovaPay application to specified environments.
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

### Cloning the Repository

```bash
git clone https://github.com/jakemorrison284/deploy-scripts.git
cd deploy-scripts
```

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

Some scripts may require configuration through environment variables or configuration files. Please refer to individual script headers or the `docs/` directory for specific configuration details.

## Backup Strategy Compliance

### Retention Policies

- Backup files used with restore scripts should adhere to defined retention policies as per infrastructure guidelines.
- Retain backups for the required duration to ensure data integrity and compliance.

### Testing Procedures

- Restore scripts include automated testing to validate backup integrity and successful restoration.
- Regularly update and run tests to comply with evolving backup and restoration policies.

## Troubleshooting

- Review script output logs for errors.
- Verify environment variables and configurations are correctly set.
- Check backup file validity before restoration.
- Consult the `runbook/` directory for operational procedures and troubleshooting steps.

## Contribution Guidelines

We welcome contributions! Please submit a pull request or open an issue to discuss enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
