# Basic system information
# Process Analysis
# Network connections Analysis
# Active Network Interfaces
# Network Share
# Services
# Scheduled Task
# Users Analizi
# Startup (Başlatmak)
# son 36 saate oluşturulan dosyalar
# Recycle Bin dosyaları
# Active Directory



# Windows Live Forensics için PowerShell Scripti

# HTML raporu için başlangıç
$OutputFile = ".\Windows_Live_Forensics_Report.html"
$HtmlContent = @"
<html>
<head>
    <title>Windows Live Forensics Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f9f9f9; color: #333; }
        h2 { color: #2a5d84; border-bottom: 2px solid #2a5d84; padding-bottom: 5px; }
        pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; overflow-x: auto; }
        .section { margin-bottom: 30px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #2a5d84; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .highlight { color: #d9534f; font-weight: bold; }
    </style>
</head>
<body>
"@

# **1. Basic System Information**
$HtmlContent += "<div class='section'><h2>Basic System Information</h2>"
$HtmlContent += (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, InstallDate, LastBootUpTime | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model, Domain | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_Product | Select-Object Name, Version | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_QuickFixEngineering | Select-Object Description, HotFixID, InstalledOn | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **2. Process Analysis**
$HtmlContent += "<div class='section'><h2>Process Analysis</h2>"
$HtmlContent += (Get-CimInstance Win32_Process | Select-Object Name, ProcessId, CommandLine, ExecutablePath | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **3. Network Connections Analysis**
$HtmlContent += "<div class='section'><h2>Network Connections Analysis</h2>"
$HtmlContent += (Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | ConvertTo-Html -Fragment)
$HtmlContent += (Get-DnsClientCache | ConvertTo-Html -Fragment)
$HtmlContent += (Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **4. Active Network Interfaces**
$HtmlContent += "<div class='section'><h2>Active Network Interfaces</h2>"
$HtmlContent += (Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **5. Network Share**
$HtmlContent += "<div class='section'><h2>Network Share</h2>"
$HtmlContent += (Get-SmbShare | Select-Object Name, Path, Description | ConvertTo-Html -Fragment)
$HtmlContent += (Get-SmbOpenFile | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **6. Services**
$HtmlContent += "<div class='section'><h2>Services</h2>"
$HtmlContent += (Get-Service | Select-Object DisplayName, Status, StartType | ConvertTo-Html -Fragment)
$HtmlContent += (Get-WmiObject -Class Win32_Service | Select-Object Name, PathName, StartMode, State | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **7. Scheduled Tasks**
$HtmlContent += "<div class='section'><h2>Scheduled Tasks</h2>"
$HtmlContent += (Get-ScheduledTask | Select-Object TaskName, TaskPath, State, Actions | ConvertTo-Html -Fragment)
$HtmlContent += "<pre>" + (schtasks /query /fo LIST /v | Out-String) + "</pre>"
$HtmlContent += "</div>"

# **8. Users Analysis**
$HtmlContent += "<div class='section'><h2>Users Analysis</h2>"
$Users = Get-LocalUser | Select-Object Name, Enabled, LastLogon
foreach ($User in $Users) {
    # If 'CreationDate' cannot be retrieved, we will omit it or use another relevant field
    $User | Add-Member -MemberType NoteProperty -Name CreationDate -Value "Not Available"
}
$HtmlContent += ($Users | Select-Object Name, Enabled, LastLogon, CreationDate | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **9. Startup Programs**
$HtmlContent += "<div class='section'><h2>Startup Programs</h2>"
$StartupPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$HtmlContent += (Get-ItemProperty -Path $StartupPath | Select-Object PSChildName, Value | ConvertTo-Html -Fragment)
$HtmlContent += (Get-WmiObject -Class Win32_StartupCommand | Select-Object Caption, Command, Location | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **10. Files Created in the Last 36 Hours**
$HtmlContent += "<div class='section'><h2>Files Created in the Last 36 Hours</h2>"
$RecentFiles = Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -gt (Get-Date).AddHours(-36) }
$HtmlContent += ($RecentFiles | Select-Object FullName, CreationTime | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"

# **11. Recycle Bin Files**
$HtmlContent += "<div class='section'><h2>Recycle Bin Files</h2>"
$recycleBin = New-Object -ComObject Shell.Application
$recycleBin = $recycleBin.Namespace('shell:::{645FF040-5081-101B-9F08-00AA002F954E}')
$recycleBin.Items() | ForEach-Object {
    $HtmlContent += "<p>File: $($_.Name) - Path: $($_.Path)</p>"
}
$HtmlContent += "</div>"

# **12. Active Directory Users and Groups**
try {
    $HtmlContent += "<div class='section'><h2>Active Directory Users and Groups</h2>"
    Import-Module ActiveDirectory
    $users = Get-ADUser -Filter * -Properties Name, SamAccountName, Enabled
    $HtmlContent += "<h3>Users</h3>"
    $HtmlContent += ($users | Select-Object Name, SamAccountName, Enabled | ConvertTo-Html -Fragment)
    $groups = Get-ADGroup -Filter * -Properties Name
    $HtmlContent += "<h3>Groups</h3>"
    $HtmlContent += ($groups | Select-Object Name | ConvertTo-Html -Fragment)
    $HtmlContent += "</div>"
} catch {
    $HtmlContent += "<p>Active Directory modülü yüklenemedi veya ortamda mevcut değil.</p>"
}

# HTML raporunu kaydet
$HtmlContent += "</body></html>"
$HtmlContent | Out-File -FilePath $OutputFile

Write-Host "Report created: $OutputFile"
