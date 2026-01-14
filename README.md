<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Windows Live Response Automation Script</title>
<style>
    body { font-family: Arial, sans-serif; background-color: #f9f9f9; color: #333; margin: 20px; line-height: 1.6; }
    h1 { color: #2a5d84; text-align: center; font-size: 36px; margin-bottom: 5px; }
    h2 { color: #2a5d84; border-bottom: 2px solid #2a5d84; padding-bottom: 5px; margin-top: 40px; }
    h3 { color: #444; margin-top: 25px; }
    p { margin: 10px 0; }
    ul { margin: 10px 0 20px 20px; }
    code, pre { background-color: #f4f4f4; padding: 5px 10px; border-radius: 5px; display: block; overflow-x: auto; }
    .badge { display: inline-block; margin: 10px 0; }
    hr { border: 1px solid #2a5d84; margin: 30px 0; }
    .footer { text-align: center; font-weight: bold; margin-top: 50px; }
</style>
</head>
<body>

<h1>🖥️ Windows Live Response Automation Script</h1>
<p><strong>Developed by Muhammed AYGUN</strong></p>
<p class="badge">
    <img src="https://img.shields.io/badge/PowerShell-Forensics-blue" alt="PowerShell Badge">
</p>
<hr>

<h2>Overview</h2>
<p>This PowerShell script automates the collection of essential artifacts during <strong>live response on Windows systems</strong>.  
It simplifies forensic investigations by gathering key system data and generating a comprehensive <strong>HTML report</strong> for analysis.</p>

<hr>
<h2>Features</h2>
<ul>
    <li><strong>System Information:</strong> Collects basic system details such as OS version, hostname, and uptime.</li>
    <li><strong>Process Analysis:</strong> Extracts a list of running processes.</li>
    <li><strong>Network Connections:</strong> Captures active network connections and open ports.</li>
    <li><strong>Active Network Interfaces:</strong> Lists all active network adapters.</li>
    <li><strong>Network Shares:</strong> Identifies shared network resources.</li>
    <li><strong>Services:</strong> Provides details on running services.</li>
    <li><strong>Scheduled Tasks:</strong> Retrieves scheduled tasks for potential persistence mechanisms.</li>
    <li><strong>User Analysis:</strong> Lists all users, including privileges and login statuses.</li>
    <li><strong>Startup Programs:</strong> Identifies applications configured to start on boot.</li>
    <li><strong>File Creation Analysis:</strong> Finds files created in the last 36 hours.</li>
    <li><strong>Recycle Bin Analysis:</strong> Extracts files stored in the recycle bin.</li>
    <li><strong>Active Directory Information:</strong> Collects AD objects and configurations (if the AD module is available).</li>
</ul>

<hr>
<h2>Usage</h2>
<h3>Clone the repository:</h3>
<pre><code>git clone https://github.com/Muhammeday9un/windows-live-response-script.git
cd windows-live-response-script
</code></pre>
<p>OR download the PowerShell script directly to the target machine.</p>

<h3>Run the script as Administrator:</h3>
<pre><code>powershell -ExecutionPolicy Bypass -File .\liveresponse.ps1
</code></pre>
<p>The script generates an HTML report named <code>Windows_Live_Forensics_Report.html</code> in the current directory.  
Optionally executes <code>autorunsc64.exe</code> if present for autorun analysis.</p>

<hr>
<h2>Requirements</h2>
<ul>
    <li>PowerShell 5.0 or higher</li>
    <li>Administrative privileges</li>
</ul>

<hr>
<h2>Disclaimer</h2>
<p>This script is provided <strong>"as-is"</strong> without any warranty.  
Use it responsibly and test in a controlled environment before deploying in production.</p>

<div class="footer">
    Developed by Muhammed AYGUN
</div>

</body>
</html>
