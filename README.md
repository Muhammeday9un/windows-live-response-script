# Windows Live Response Automation Script

## Overview
This PowerShell script is designed to automate the collection of essential artifacts during live response on Windows systems. It simplifies forensic investigations by gathering key system data and generating a comprehensive HTML report.

## Features
- **System Information:** Collects basic system details such as OS version, hostname, and system uptime.
- **Process Analysis:** Extracts a list of running processes for analysis.
- **Network Connections:** Captures active network connections and open ports.
- **Active Network Interfaces:** Lists all active network adapters.
- **Network Shares:** Identifies shared network resources.
- **Services:** Provides details on running services.
- **Scheduled Tasks:** Retrieves scheduled tasks for potential persistence mechanisms.
- **User Analysis:** Lists all users, including their privileges and login statuses.
- **Startup Programs:** Identifies applications configured to start on boot.
- **File Creation Analysis:** Finds files created in the last 36 hours.
- **Recycle Bin Analysis:** Extracts files stored in the recycle bin.
- **Active Directory Information:** Collects data on AD objects and configurations (if applicable).

## Usage
1. Clone this repository to your local machine:
   ```
   git clone https://github.com/Muhammeday9un/windows-live-response-script.git
   ```
   OR
   Download powershell script to target machine

3. Run the script with PowerShell as an administrator:
   ```
   .\LiveResponse.ps1
   ```

4. The script generates an HTML report named `Windows_Live_Forensics_Report.html` in the current directory.

## Requirements
- PowerShell 5.0 or higher
- Administrative privileges

## Disclaimer
This script is provided "as-is" without any warranty. Use it responsibly and test in a controlled environment before deploying it in production.

---





