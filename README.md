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

### Common Issues
- **Issue 1**: Describe common issue and how to resolve it.
- **Issue 2**: Describe another common issue and its resolution.

### Contribution Guidelines
We welcome contributions! Please submit a pull request or open an issue to discuss any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.