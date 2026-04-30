# deploy-scripts

CI/CD pipeline scripts for NovaPay deployments.

## Usage Instructions

### Prerequisites
Before using the scripts, ensure you have the following installed:
- [Git](https://git-scm.com/) (version 2.20 or higher recommended)
- [Node.js](https://nodejs.org/) (version 14 or higher, required only for scripts involving Node.js tasks)
- [Docker](https://www.docker.com/) (version 20 or higher, needed if using containerized deployment scripts)

### Running the Scripts
To run the deployment scripts, use the following commands:

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/jakemorrison284/deploy-scripts.git
   cd deploy-scripts
   ```

2. **Set Environment Variables**  
   Some scripts require environment variables or configuration files to be set before execution. For example:
   ```bash
   export DEPLOY_ENV=production
   export DB_BACKUP_PATH=/path/to/backup
   ```
   Refer to individual script comments for required variables.

3. **Execute the Deployment Script**  
   For example, to run the `deploy.sh` script, use:  
   ```bash
   bash deploy.sh --env $DEPLOY_ENV
   ```

### Example Usage
- **Deploy Application**  
   To deploy the NovaPay application in production environment, execute:  
   ```bash
   bash deploy.sh --env production
   ```

- **Failover Process**  
   To initiate failover, run:  
   ```bash
   bash failover.sh
   ```

- **Restore PostgreSQL Database**  
   To restore a PostgreSQL database from backup, use:  
   ```bash
   bash restore_postgres.sh --backup /path/to/backup/file
   ```

- **Test Restore Procedure**  
   To run automated tests validating the restore process, execute:  
   ```bash
   bash test_restore_postgres.sh
   ```

## Backup Strategy Compliance

### Retention Policies
- Backup files used with restore scripts should adhere to the defined retention policies outlined in the infrastructure documentation [link to guidelines].
- Ensure backups are retained for the required duration to meet data integrity and compliance mandates.

### Testing Procedures
- Restoration scripts include automated tests (see `test_restore_postgres.sh`) to validate restore operations across supported backup formats.
- These tests check backup file validity, successful restores, and trigger notifications on outcomes.
- Regularly run and update tests to comply with evolving backup and restoration policies.

## Common Issues
- **Issue: Missing Environment Variables**  
  Resolution: Ensure all required environment variables are set before running scripts.

- **Issue: Permission Denied Errors**  
  Resolution: Verify execution permissions on script files and necessary access rights.

- **Issue: Backup File Not Found**  
  Resolution: Confirm the backup file path is correct and accessible by the script.

## Backup Strategy Compliance

### Retention Policies
- Backup files used with restore scripts should adhere to the defined retention policies as per the updated infrastructure guidelines.
- Ensure backups are retained for the required duration to meet data integrity and compliance mandates.

### Testing Procedures
- The restoration scripts include automated testing (see `test_restore_postgres.sh`) to validate restore operations across supported backup formats.
- Testing ensures backup files are valid, restores are successful, and notifications are triggered appropriately.
- Regularly run and update tests to comply with evolving backup and restoration policies.

## Contribution Guidelines
We welcome contributions! Please submit a pull request or open an issue to discuss any enhancements or bug fixes.

- Follow existing code style and conventions.
- Include tests for new features or bug fixes.
- Ensure documentation is updated alongside code changes.
- Use descriptive commit messages.
- Target pull requests to the `main` branch.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
