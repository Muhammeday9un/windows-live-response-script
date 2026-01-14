# --------------------------------------------------
# Windows Live Forensics Report Script
# Developed by Muhammed AYGUN
# --------------------------------------------------

# HTML raporu için başlangıç
$OutputFile = ".\Windows_Live_Forensics_Report.html"
$HtmlContent = @"
<html>
<head>
    <title>Windows Live Forensics Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f9f9f9; color: #333; }
        h2 { 
            color: #2a5d84; 
            border-bottom: 2px solid #2a5d84; 
            padding-bottom: 5px; 
            font-size: 28px; /* Başlık boyutu */
            margin-bottom: 20px;
        }
        h3 { color: #444; font-size: 18px; margin-top: 15px; }
        pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
        .section { margin-bottom: 30px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #2a5d84; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .highlight { color: #d9534f; font-weight: bold; }
        hr { border: 2px solid #2a5d84; margin: 30px 0; }
    </style>
</head>
<body>
"@

Write-Host "--- Analysis is initiating ... ---" -ForegroundColor Green

# **1. External IP Address** $HtmlContent += "<div class='section'><h2>1. External IP Address</h2>"
try {
    # https://www.ipify.org kullanılarak dış IP alınıyor
    $externalIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim()
    if ($externalIP) {
        $HtmlContent += "<p>External IP Address: <b>$externalIP</b></p>"
    } else {
        $HtmlContent += "<p>External IP Address bilgisi alınamadı.</p>"
    }
} catch {
    $HtmlContent += "<p>An error occurred while retrieving an external IP address: $_</p>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **2. Basic System Information**
$HtmlContent += "<div class='section'><h2>2. Basic System Information</h2>"
$HtmlContent += (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, InstallDate, LastBootUpTime | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model, Domain | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_Product | Select-Object Name, Version | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_QuickFixEngineering | Select-Object Description, HotFixID, InstalledOn | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **3. System Version and Build Number**
$HtmlContent += "<div class='section'><h2>3. System Version and Build Number</h2>"
$osInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object ProductName, ReleaseId, CurrentBuild, BuildLabEx
$HtmlContent += ($osInfo | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **4. Disk Drives Information**
$HtmlContent += "<div class='section'><h2>4. Disk Drives Information</h2>"
$diskDrives = Get-WmiObject Win32_DiskDrive | Select-Object Model, InterfaceType, MediaType, Size, SerialNumber
$HtmlContent += ($diskDrives | ConvertTo-Html -Fragment)
$HtmlContent += "<p>Note: Information about the plugging time or which user plugged it in may require Windows Event Log or custom hardware reporting.</p>"
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# ** Encryption Analysis **
Write-Host "--- Encryption analysis is being performed. ---" -ForegroundColor Cyan
$HtmlContent += "<div class='section'><h2>Encryption Analysis (BitLocker & 3rd Party)</h2>"

# BitLocker Kontrolü
$HtmlContent += "<h3>BitLocker Status</h3>"
try {
    $bitlockerStatus = Get-BitLockerVolume -ErrorAction SilentlyContinue | Select-Object MountPoint, VolumeStatus, EncryptionMethod, ProtectionStatus
    if ($bitlockerStatus) {
        $HtmlContent += ($bitlockerStatus | ConvertTo-Html -Fragment)
    } else {
        $HtmlContent += "<p>BitLocker is not enabled or inaccessible..</p>"
    }
} catch {
    $HtmlContent += "<p>The BitLocker command could not be executed on this system..</p>"
}

# Checking Third-Party Encryption Services
$HtmlContent += "<h3>Security & Encryption Services Found</h3>"
$secServices = Get-Service -DisplayName *VeraCrypt*,*McAfee*,*Symantec*,*Endpoint*,*PGP*,*CheckPoint*,*Sophos*,*TrueCrypt* -ErrorAction SilentlyContinue | Select-Object DisplayName, Status
if ($secServices) {
    $HtmlContent += ($secServices | ConvertTo-Html -Fragment)
} else {
    $HtmlContent += "<p>Listed target security services (VeraCrypt, McAfee, Symantec vb.) not found to be working.</p>"
}

# Encryption Drivers Control
$HtmlContent += "<h3>Encryption Drivers (Kernel Level)</h3>"
$drivers = Get-CimInstance Win32_SystemDriver | Where-Object PathName -match "veracrypt|mfe|symc|pgp|endpoint|truecrypt" | Select-Object DisplayName, State, PathName
if ($drivers) {
    $HtmlContent += ($drivers | ConvertTo-Html -Fragment)
} else {
    $HtmlContent += "<p>No system driver related to encryption was detected.</p>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **5. Clipboard Content**
$HtmlContent += "<div class='section'><h2>5. Clipboard Content</h2>"
try {
    $clipboardContent = Get-Clipboard -Format Text -ErrorAction Stop
    if ($clipboardContent -eq "") { $clipboardContent = "Clipboard boş." }
} catch {
    $clipboardContent = "Get-Clipboard The command is not supported or inaccessible."
}
$HtmlContent += "<pre>$clipboardContent</pre>"
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **6. Command History**
$HtmlContent += "<div class='section'><h2>6. Command History</h2>"
$commandHistory = Get-History | Select-Object Id, CommandLine
$HtmlContent += ($commandHistory | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **7. Mapped Drive Information**
$HtmlContent += "<div class='section'><h2>7. Mapped Drive Information</h2>"
$mappedDrives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -like "\\*" }
if ($mappedDrives) {
    $HtmlContent += ($mappedDrives | Select-Object Name, DisplayRoot | ConvertTo-Html -Fragment)
} else {
    $HtmlContent += "<pre>" + (net use | Out-String) + "</pre>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **8. Shared Directories (File Sharing)**
$HtmlContent += "<div class='section'><h2>8. Shared Directories</h2>"
$sharedDirs = Get-WmiObject -Class Win32_Share | Select-Object Name, Path, Description, Status
$HtmlContent += ($sharedDirs | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **9. Process Analysis**
$HtmlContent += "<div class='section'><h2>9. Process Analysis</h2>"
$HtmlContent += (Get-CimInstance Win32_Process | Select-Object Name, ProcessId, CommandLine, ExecutablePath | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **10. Network Connections Analysis**
$HtmlContent += "<div class='section'><h2>10. Network Connections Analysis</h2>"
$HtmlContent += (Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | ConvertTo-Html -Fragment)
$HtmlContent += (Get-DnsClientCache | ConvertTo-Html -Fragment)
$HtmlContent += (Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **11. Active Network Interfaces**
$HtmlContent += "<div class='section'><h2>11. Active Network Interfaces</h2>"
$HtmlContent += (Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **12. Network Share**
$HtmlContent += "<div class='section'><h2>12. Network Share</h2>"
$HtmlContent += (Get-SmbShare | Select-Object Name, Path, Description | ConvertTo-Html -Fragment)
$HtmlContent += (Get-SmbOpenFile | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **13. Services**
$HtmlContent += "<div class='section'><h2>13. Services</h2>"
$HtmlContent += (Get-Service | Select-Object DisplayName, Status, StartType | ConvertTo-Html -Fragment)
$HtmlContent += (Get-WmiObject -Class Win32_Service | Select-Object Name, PathName, StartMode, State | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **14. Scheduled Tasks**
$HtmlContent += "<div class='section'><h2>14. Scheduled Tasks</h2>"
$HtmlContent += (Get-ScheduledTask | Select-Object TaskName, TaskPath, State, Actions | ConvertTo-Html -Fragment)
$HtmlContent += "<pre>" + (schtasks /query /fo LIST /v | Out-String) + "</pre>"
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **15. Users Analysis**
$HtmlContent += "<div class='section'><h2>15. Users Analysis</h2>"
$Users = Get-LocalUser | Select-Object Name, Enabled, LastLogon
foreach ($User in $Users) {
    $User | Add-Member -MemberType NoteProperty -Name CreationDate -Value "Not Available"
}
$HtmlContent += ($Users | Select-Object Name, Enabled, LastLogon, CreationDate | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **16. Startup Programs**
$HtmlContent += "<div class='section'><h2>16. Startup Programs</h2>"
$StartupPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$HtmlContent += (Get-ItemProperty -Path $StartupPath | Select-Object PSChildName, Value | ConvertTo-Html -Fragment)
$HtmlContent += (Get-WmiObject -Class Win32_StartupCommand | Select-Object Caption, Command, Location | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **17. Recycle Bin Files**
$HtmlContent += "<div class='section'><h2>17. Recycle Bin Files</h2>"
$recycleBin = New-Object -ComObject Shell.Application
$recycleBin = $recycleBin.Namespace('shell:::{645FF040-5081-101B-9F08-00AA002F954E}')
$recycleBin.Items() | ForEach-Object {
    $HtmlContent += "<p>File: $($_.Name) - Path: $($_.Path)</p>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **18. Files Created in the Last 36 Hours**
$HtmlContent += "<div class='section'><h2>18. Files Created in the Last 36 Hours</h2>"

$RecentFiles = Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -gt (Get-Date).AddHours(-36) } | Select-Object -First 200
$HtmlContent += ($RecentFiles | Select-Object FullName, CreationTime | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **19. Temporary Files**
$HtmlContent += "<div class='section'><h2>19. Temporary Files</h2>"
$TempFiles = Get-ChildItem -Path $env:TEMP -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, Length, CreationTime | Select-Object -First 100
$HtmlContent += ($TempFiles | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **20. Active Directory Users and Groups**
try {
    $HtmlContent += "<div class='section'><h2>20. Active Directory Users and Groups</h2>"
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        Import-Module ActiveDirectory
        $adUsers = Get-ADUser -Filter * -Properties Name, SamAccountName, Enabled | Select-Object Name, SamAccountName, Enabled -First 50
        $HtmlContent += "<h3>Users (First 50)</h3>"
        $HtmlContent += ($adUsers | ConvertTo-Html -Fragment)
        $adGroups = Get-ADGroup -Filter * -Properties Name | Select-Object Name -First 50
        $HtmlContent += "<h3>Groups (First 50)</h3>"
        $HtmlContent += ($adGroups | ConvertTo-Html -Fragment)
    } else {
        $HtmlContent += "<p>The Active Directory module is not installed.</p>"
    }
    $HtmlContent += "</div>"
} catch {
    $HtmlContent += "<p>An error occurred while retrieving Active Directory information.</p>"
}
$HtmlContent += "<hr>"

# The "Developed by" information is added to the end of the HTML report.
$HtmlContent += "<p style='text-align:center; font-weight:bold;'>Developed by Muhammed AYGUN</p>"

# Close and save the HTML report.
$HtmlContent += "</body></html>"
$HtmlContent | Out-File -FilePath $OutputFile -Encoding utf8

Write-Host "Report created: $OutputFile" -ForegroundColor Green

# --------------------------------------------------
# Running the autorunsc64.exe Process
if (Test-Path ".\autorunsc64.exe") {
    Write-Host "Executing autorunsc64.exe command..."
    try {
        .\autorunsc64.exe -accepteula -a * -s -h -c > .\autoruns-citadeldc01.csv
        Write-Host "autorunsc64.exe executed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error executing autorunsc64.exe: $_" -ForegroundColor Red
    }
}
