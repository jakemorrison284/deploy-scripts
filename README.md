# deploy-scripts

CI/CD pipeline scripts for NovaPay deployments.

## Overview

This repository contains shell scripts used for deploying the NovaPay application, handling failover procedures, and managing PostgreSQL database restores. It also includes testing scripts to validate backup and restore operations. These scripts aim to streamline and automate key deployment and disaster recovery tasks.

## Prerequisites

Before using the scripts, ensure you have the following installed on your system:

- [Git](https://git-scm.com/) (version 2.25 or higher recommended)
- [Node.js](https://nodejs.org/) (version 14 or higher, required for some scripts; check individual script headers)
- [Docker](https://www.docker.com/) (required if deploying within containerized environments)

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

## Requirements and Dependencies

- Bash shell (version 4.0 or higher)
- Access to necessary environment variables (see Configuration below)
- Network access to deployment targets and database servers
- Appropriate permissions to execute deployment and database restore operations

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

For additional options and flags, refer to the header comments in `deploy.sh`.

### Failover Process

To initiate a failover, run:

```bash
bash failover.sh
```

This script will execute the configured failover procedures.

See `runbook/failover.md` for detailed operational procedures.

### Restoring PostgreSQL Database

To restore a PostgreSQL database from a backup, use:

```bash
bash restore_postgres.sh --backup-file /path/to/backup/file
```

Refer to the script header or the `runbook/restore_postgres.md` documentation for detailed instructions and required parameters.

### Running Tests

To validate the restore process, run the test script:

```bash
bash test_restore_postgres.sh
```

Ensure that backup files used for testing comply with retention and format policies.

## Configuration and Environment Variables

Some scripts require configuration through environment variables. Example variables include:

```bash
export DEPLOY_ENV=production
export DB_HOST=your-db-host
export DB_USER=your-db-user
export DB_PASSWORD=your-db-password
```

Check the header comments of each script and the `docs/configuration.md` for detailed configuration instructions.

## Backup Strategy Compliance

### Retention Policies

- Backup files used with restore scripts should adhere to defined retention policies as per infrastructure guidelines.
- Retain backups for the required duration to ensure data integrity and compliance.

### Testing Procedures

- Restore scripts include automated testing to validate backup integrity and successful restoration.
- Regularly update and run tests to comply with evolving backup and restoration policies.

## Troubleshooting and FAQ

- Review script output logs for errors.
- Verify environment variables and configurations are correctly set.
- Check the validity of backup files before restoration.
- Consult the `runbook/` directory for operational procedures and troubleshooting steps.
- For common questions, see `docs/FAQ.md`.

## Security Considerations

- Ensure sensitive credentials are securely managed and not hardcoded.
- Run scripts in secure environments with restricted access.
- Regularly update dependencies and scripts to patch vulnerabilities.

## Contribution Guidelines

We welcome contributions! Please submit a pull request or open an issue to discuss enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
