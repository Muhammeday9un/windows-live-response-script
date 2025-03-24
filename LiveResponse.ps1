#1.External IP Address  
#2. Basic System Information
#3. System Version and Build Number
#4. Disk Drives Information
#5. Clipboard Content
#6. Command History
#7. Mapped Drive Information
#8. Shared Directories (Dosya Paylaşımları)
#9. Process Analysis
#10. Network Connections Analysis
#11. Active Network Interfaces
#12. Network Share
#13. Services
#14. Scheduled Tasks
#15. Users Analysis
#16. Startup Programs
#17. Recycle Bin Files
#18. Files Created in the Last 36 Hours
#18. Temporary Files
#20. Active Directory Users and Groups
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

# **External IP Address**  
$HtmlContent += "<div class='section'><h2>External IP Address</h2>"
try {
    # https://www.ipify.org kullanılarak dış IP alınıyor
    $externalIP = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
    if ($externalIP) {
        $HtmlContent += "<p>External IP Address: $externalIP</p>"
    } else {
        $HtmlContent += "<p>External IP Address bilgisi alınamadı.</p>"
    }
} catch {
    $HtmlContent += "<p>Dış IP adresi alınırken hata oluştu: $_</p>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **1. Basic System Information**
$HtmlContent += "<div class='section'><h2>Basic System Information</h2>"
$HtmlContent += (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, InstallDate, LastBootUpTime | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model, Domain | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_Product | Select-Object Name, Version | ConvertTo-Html -Fragment)
$HtmlContent += (Get-CimInstance -ClassName Win32_QuickFixEngineering | Select-Object Description, HotFixID, InstalledOn | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **2. System Version and Build Number**
$HtmlContent += "<div class='section'><h2>System Version and Build Number</h2>"
$osInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object ProductName, ReleaseId, CurrentBuild, BuildLabEx
$HtmlContent += ($osInfo | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **3. Disk Drives Information**
$HtmlContent += "<div class='section'><h2>Disk Drives Information</h2>"
$diskDrives = Get-WmiObject Win32_DiskDrive | Select-Object Model, InterfaceType, MediaType, Size, SerialNumber
$HtmlContent += ($diskDrives | ConvertTo-Html -Fragment)
$HtmlContent += "<p>Not: Takılma zamanı veya hangi kullanıcı tarafından takıldığı bilgisi, Windows Event Log veya özel donanım raporlaması gerektirebilir.</p>"
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **4. Clipboard Content**
$HtmlContent += "<div class='section'><h2>Clipboard Content</h2>"
try {
    $clipboardContent = Get-Clipboard -Format Text -ErrorAction Stop
    if ($clipboardContent -eq "") { $clipboardContent = "Clipboard boş." }
} catch {
    $clipboardContent = "Get-Clipboard komutu desteklenmiyor veya erişim sağlanamadı."
}
$HtmlContent += "<pre>$clipboardContent</pre>"
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **5. Command History**
$HtmlContent += "<div class='section'><h2>Command History</h2>"
$commandHistory = Get-History | Select-Object Id, CommandLine
$HtmlContent += ($commandHistory | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **6. Mapped Drive Information**
$HtmlContent += "<div class='section'><h2>Mapped Drive Information</h2>"
$mappedDrives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -like "\\*" }
if ($mappedDrives) {
    $HtmlContent += ($mappedDrives | Select-Object Name, DisplayRoot | ConvertTo-Html -Fragment)
} else {
    $HtmlContent += "<pre>" + (net use | Out-String) + "</pre>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **7. Shared Directories (Dosya Paylaşımları)**
$HtmlContent += "<div class='section'><h2>Shared Directories</h2>"
$sharedDirs = Get-WmiObject -Class Win32_Share | Select-Object Name, Path, Description, Status
$HtmlContent += ($sharedDirs | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **8. Process Analysis**
$HtmlContent += "<div class='section'><h2>Process Analysis</h2>"
$HtmlContent += (Get-CimInstance Win32_Process | Select-Object Name, ProcessId, CommandLine, ExecutablePath | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **9. Network Connections Analysis**
$HtmlContent += "<div class='section'><h2>Network Connections Analysis</h2>"
$HtmlContent += (Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | ConvertTo-Html -Fragment)
$HtmlContent += (Get-DnsClientCache | ConvertTo-Html -Fragment)
$HtmlContent += (Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **10. Active Network Interfaces**
$HtmlContent += "<div class='section'><h2>Active Network Interfaces</h2>"
$HtmlContent += (Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **11. Network Share**
$HtmlContent += "<div class='section'><h2>Network Share</h2>"
$HtmlContent += (Get-SmbShare | Select-Object Name, Path, Description | ConvertTo-Html -Fragment)
$HtmlContent += (Get-SmbOpenFile | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **12. Services**
$HtmlContent += "<div class='section'><h2>Services</h2>"
$HtmlContent += (Get-Service | Select-Object DisplayName, Status, StartType | ConvertTo-Html -Fragment)
$HtmlContent += (Get-WmiObject -Class Win32_Service | Select-Object Name, PathName, StartMode, State | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **13. Scheduled Tasks**
$HtmlContent += "<div class='section'><h2>Scheduled Tasks</h2>"
$HtmlContent += (Get-ScheduledTask | Select-Object TaskName, TaskPath, State, Actions | ConvertTo-Html -Fragment)
$HtmlContent += "<pre>" + (schtasks /query /fo LIST /v | Out-String) + "</pre>"
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **14. Users Analysis**
$HtmlContent += "<div class='section'><h2>Users Analysis</h2>"
$Users = Get-LocalUser | Select-Object Name, Enabled, LastLogon
foreach ($User in $Users) {
    $User | Add-Member -MemberType NoteProperty -Name CreationDate -Value "Not Available"
}
$HtmlContent += ($Users | Select-Object Name, Enabled, LastLogon, CreationDate | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **15. Startup Programs**
$HtmlContent += "<div class='section'><h2>Startup Programs</h2>"
$StartupPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$HtmlContent += (Get-ItemProperty -Path $StartupPath | Select-Object PSChildName, Value | ConvertTo-Html -Fragment)
$HtmlContent += (Get-WmiObject -Class Win32_StartupCommand | Select-Object Caption, Command, Location | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **16. Recycle Bin Files**
$HtmlContent += "<div class='section'><h2>Recycle Bin Files</h2>"
$recycleBin = New-Object -ComObject Shell.Application
$recycleBin = $recycleBin.Namespace('shell:::{645FF040-5081-101B-9F08-00AA002F954E}')
$recycleBin.Items() | ForEach-Object {
    $HtmlContent += "<p>File: $($_.Name) - Path: $($_.Path)</p>"
}
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **17. Files Created in the Last 36 Hours**
$HtmlContent += "<div class='section'><h2>Files Created in the Last 36 Hours</h2>"
$RecentFiles = Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -gt (Get-Date).AddHours(-36) }
$HtmlContent += ($RecentFiles | Select-Object FullName, CreationTime | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **18. Temporary Files**
$HtmlContent += "<div class='section'><h2>Temporary Files</h2>"
$TempFiles = Get-ChildItem -Path $env:TEMP -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, Length, CreationTime
$HtmlContent += ($TempFiles | ConvertTo-Html -Fragment)
$HtmlContent += "</div>"
$HtmlContent += "<hr>"

# **19. Active Directory Users and Groups**
try {
    $HtmlContent += "<div class='section'><h2>Active Directory Users and Groups</h2>"
    Import-Module ActiveDirectory
    $adUsers = Get-ADUser -Filter * -Properties Name, SamAccountName, Enabled
    $HtmlContent += "<h3>Users</h3>"
    $HtmlContent += ($adUsers | Select-Object Name, SamAccountName, Enabled | ConvertTo-Html -Fragment)
    $adGroups = Get-ADGroup -Filter * -Properties Name
    $HtmlContent += "<h3>Groups</h3>"
    $HtmlContent += ($adGroups | Select-Object Name | ConvertTo-Html -Fragment)
    $HtmlContent += "</div>"
} catch {
    $HtmlContent += "<p>Active Directory modülü yüklenemedi veya ortamda mevcut değil.</p>"
}
$HtmlContent += "<hr>"

# HTML raporunun sonuna Developed by bilgisi ekleniyor
$HtmlContent += "<p style='text-align:center; font-weight:bold;'>Developed by Muhammed AYGUN</p>"

# HTML raporunu kapat ve kaydet
$HtmlContent += "</body></html>"
$HtmlContent | Out-File -FilePath $OutputFile

Write-Host "Report created: $OutputFile"

# --------------------------------------------------
# autorunsc64.exe İşleminin Çalıştırılması
Write-Host "Executing autorunsc64.exe command..."
try {
    # Aşağıdaki satır belirtilen komutu çalıştırır ve çıktıyı CSV dosyasına yönlendirir.
    .\autorunsc64.exe -accepteula -a * -s -h -c > .\autoruns-citadeldc01.csv
    Write-Host "autorunsc64.exe executed successfully. Output saved to autoruns-citadeldc01.csv"
} catch {
    Write-Host "Error executing autorunsc64.exe: $_"
}
