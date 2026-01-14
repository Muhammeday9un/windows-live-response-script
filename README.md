# 🖥️ Windows Live Response Automation Script

**Developed by Muhammed AYGUN**  

![PowerShell](https://img.shields.io/badge/PowerShell-Forensics-blue)

---

## Overview

This PowerShell script automates the collection of essential artifacts during **live response on Windows systems**.  
It simplifies forensic investigations by gathering key system data and generating a comprehensive **HTML report** for analysis.

---

## Features

- **System Information:** Collects basic system details such as OS version, hostname, and uptime.  
- **Process Analysis:** Extracts a list of running processes.  
- **Network Connections:** Captures active network connections and open ports.  
- **Active Network Interfaces:** Lists all active network adapters.  
- **Network Shares:** Identifies shared network resources.  
- **Services:** Provides details on running services.  
- **Scheduled Tasks:** Retrieves scheduled tasks for potential persistence mechanisms.  
- **User Analysis:** Lists all users, including privileges and login statuses.  
- **Startup Programs:** Identifies applications configured to start on boot.  
- **File Creation Analysis:** Finds files created in the last 36 hours.  
- **Recycle Bin Analysis:** Extracts files stored in the recycle bin.  
- **Active Directory Information:** Collects AD objects and configurations (if the AD module is available).  

---

## Usage

### Clone the repository:

```powershell
git clone https://github.com/Muhammeday9un/windows-live-response-script.git
cd windows-live-response-script


OR download the PowerShell script directly to the target machine.

Run the script as Administrator:

powershell -ExecutionPolicy Bypass -File .\liveresponse.ps1


Generates an HTML report named Windows_Live_Forensics_Report.html in the current directory.

Optionally executes autorunsc64.exe if present for autorun analysis.

Requirements

PowerShell 5.0 or higher

Administrative privileges

Disclaimer

This script is provided "as-is" without any warranty.
Use it responsibly and test in a controlled environment before deploying in production.

Developed by Muhammed AYGUN
