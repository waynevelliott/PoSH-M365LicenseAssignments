# PoSH-M365LicenseAssignments
PowerShell Script for M365 License Assignment Analysis

I put together a PowerShell script that analyzes Microsoft 365 license assignments within a tenant. This script is designed to provide detailed information about license distribution, including both direct assignments and group-based licensing. Here's a breakdown of its functionality:

1. Authentication and Connection:
   - Verifies connection to Microsoft Graph (US Government environment).
   - Prompts for connection if not already established.

2. Utility Functions:
   - `Write-HostWithTimestamp`: Adds timestamps to console output for logging purposes.
   - `Get-ADDSExpiresOn`: Retrieves account expiration dates from Active Directory.
   - `Get-LicenseAssignmentStatus`: Determines the method of license assignment (direct or group-based).
   - `Join-ServicePlanArray`: Formats service plan information for improved readability.

3. License Inventory:
   - Retrieves all subscribed SKUs in the tenant.
   - Presents SKUs in a GridView for user selection.

4. Group License Analysis:
   - Identifies all groups with the selected license assigned.
   - Creates a hash table for efficient group name lookups.

5. User License Details:
   - Retrieves all users assigned the selected license.
   - Collects key user information: account status, display name, UPN, email, department, and license assignment method.

6. Data Presentation:
   - Compiles collected data into a structured format.
   - Displays results in a GridView for easy sorting and filtering.

Key Features:
- Utilizes Microsoft Graph PowerShell SDK for efficient data retrieval.
- Supports analysis of both direct and group-based license assignments.
- Provides clear visibility into license assignment methods for each user.

Use Cases:
- Preparation for licensing audits.
- Analysis of licensing costs and utilization.
- Identification of licensing distribution patterns across the organization.

This script is particularly useful for IT administrators and licensing managers who need to maintain an accurate overview of their Microsoft 365 license assignments. It streamlines the process of license management and provides valuable insights into the current state of license distribution within the organization.

# Select a License
![1  Select a License SKU](https://github.com/user-attachments/assets/8a096524-eaef-42c5-9a5c-05e5ae01ecee)

# Retrieving Licensed Users
![2  Retrieving Licensed Users](https://github.com/user-attachments/assets/e4f134cc-1ffa-4399-83ab-6a834384c488)

# Displaying Details for Licensed Users
![3  Displaying License Details for Users](https://github.com/user-attachments/assets/d88da6f0-56cd-4387-b34f-f41339523c84)
