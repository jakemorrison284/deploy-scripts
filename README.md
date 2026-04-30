# deploy-scripts

CI/CD pipeline scripts for NovaPay deployments.

## Usage Instructions

### Prerequisites
Before using the scripts, ensure you have the following installed:
- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (if applicable)
- [Docker](https://www.docker.com/) (if applicable)

### Running the Scripts
To run the deployment scripts, use the following commands:

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/jakemorrison284/deploy-scripts.git
   cd deploy-scripts
   ```

2. **Execute the Deployment Script**  
   For example, to run the `deploy.sh` script, use:  
   ```bash
   bash deploy.sh
   ```

### Example Usage
- **Deploy Application**  
   To deploy the NovaPay application, execute the following command:  
   ```bash
   bash deploy.sh --env production
   ```
   This command deploys the application in the production environment.

- **Failover Process**  
   If you need to initiate a failover, run:  
   ```bash
   bash failover.sh
   ```
   This script will handle the failover process as per the defined configurations.

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

## License
This project is licensed under the MIT License. See the LICENSE file for details.
