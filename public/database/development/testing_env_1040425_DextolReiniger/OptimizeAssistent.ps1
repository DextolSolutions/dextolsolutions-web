# Hardware Settings Import
. "$PSScriptRoot/hardware/NVIDIA_GPU.ps1"

# System Performance Functions

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "
=== $Title ===" -ForegroundColor Cyan
}

function Write-Progress {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Yellow
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Red
}

function Optimize-MemoryManagement {
    Write-Progress "Optimizing Memory Management Settings..."
    
    try {
        # Registry path for memory management
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        
        # Optimize memory management settings
        Set-ItemProperty -Path $regPath -Name "LargeSystemCache" -Value 0
        Write-Progress "Configured Large System Cache"
        
        Set-ItemProperty -Path $regPath -Name "DisablePagingExecutive" -Value 1
        Write-Progress "Disabled Paging Executive"
        
        # Write-Complete "Memory Management Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize memory management: $_"
    }
}

function Optimize-CPUScheduling {
    Write-Progress "Optimizing CPU Scheduling..."
    
    try {
        # Registry path for CPU scheduling
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        
        # Optimize CPU priority settings
        Set-ItemProperty -Path $regPath -Name "Win32PrioritySeparation" -Value 26
        Write-Progress "Configured CPU Priority Settings"
        
        # Write-Complete "CPU Scheduling Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize CPU scheduling: $_"
    }
}

function Optimize-DiskIO {
    Write-Progress "Optimizing Disk I/O Performance..."
    
    try {
        # Disable disk performance counters
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Disk"
        Set-ItemProperty -Path $regPath -Name "DisablePerformanceCounter" -Value 1
        Write-Progress "Disabled Disk Performance Counters"
        
        # Enable write caching
        Get-Disk | ForEach-Object {
            Set-Disk -Number $_.Number -IsReadOnly $false
            Write-Progress "Enabled Write Caching for Disk $($_.Number)"
        }
        
        # Write-Complete "Disk I/O Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize disk I/O: $_"
    }
}

function Optimize-PagefileVRAM {
    try {
        Write-Progress "Fetching VRAM size..." -ForegroundColor Cyan
        $vram = (Get-WmiObject -Namespace "root\CIMv2" -Class Win32_VideoController | 
            Select-Object -ExpandProperty AdapterRAM | Measure-Object -Sum).Sum / 1MB

        if (-not $vram) {
            Write-Warning "Unable to fetch VRAM size. Ensure you have a GPU installed."
            return
        }

        # Validate VRAM value
        if ($vram -le 0) {
            Write-Warning "Invalid VRAM size detected: $vram MB"
            return
        }

        # Calculate recommended sizes
        $recommendedSize = [math]::Round($vram * 1.5)
        $maxSize = [math]::Round($vram * 2)

        Write-Progress "Setting pagefile size to Initial: $recommendedSize MB, Maximum: $maxSize MB" -ForegroundColor Green

        # Disable automatic pagefile management
        try {
            $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
            $computerSystem | Set-CimInstance -Property @{AutomaticManagedPagefile = $false }
        }
        catch {
            Write-Warning "Failed to disable automatic pagefile management: $_"
            return
        }

        # Remove existing pagefile configuration
        try {
            $existingPagefile = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object { $_.Name -eq "C:\\pagefile.sys" }
            if ($existingPagefile) {
                $existingPagefile | Remove-CimInstance
            }
        }
        catch {
            Write-Warning "Failed to remove existing pagefile configuration: $_"
            return
        }

        # Create a new pagefile configuration
        try {
            $pagefilePath = "C:\\pagefile.sys"
            $newPagefile = ([wmiclass]"\\.\root\cimv2:Win32_PageFileSetting").CreateInstance()
            $newPagefile.Name = $pagefilePath
            $newPagefile.InitialSize = $recommendedSize
            $newPagefile.MaximumSize = $maxSize
            $newPagefile.Put()
        }
        catch {
            Write-Warning "Failed to create new pagefile configuration: $_"
            return
        }

        Write-Progress "Pagefile size optimized successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "An unexpected error occurred: $_"
    }
}

function Set-CustomTimerResolution {
    Write-Progress "Setting Custom Timer Resolution..."
    
    try {
        # Set timer resolution to 0.5ms
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
        Set-ItemProperty -Path $regPath -Name "GlobalTimerResolutionRequests" -Value 1
        
        # Write-Complete "Timer Resolution Optimization Complete"
    }
    catch {
        Write-Warning "Failed to set custom timer resolution: $_"
    }
}

function Optimize-SystemResponsiveness {
    Write-Progress "Enhancing System Responsiveness..."
    
    try {
        # Registry path for system responsiveness
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        
        # Optimize system responsiveness settings
        Set-ItemProperty -Path $regPath -Name "SystemResponsiveness" -Value 0
        Set-ItemProperty -Path $regPath -Name "NetworkThrottlingIndex" -Value 4294967295
        
        Write-Progress "Configured System Profile Settings"
        # Write-Complete "System Responsiveness Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize system responsiveness: $_"
    }
}

function Optimize-SystemPerformance {
    Write-SectionHeader "System Performance Optimization"
    
    Write-Progress "Starting System Performance Optimization..."
    
    # Execute all system performance optimizations
    Optimize-MemoryManagement
    Optimize-CPUScheduling
    Optimize-DiskIO
    Optimize-PagefileVRAM
    Set-CustomTimerResolution
    Optimize-SystemResponsiveness
    
    # Write-Complete "System Performance Optimization Complete!"
    Write-Host ""
}

# System Cleanup Functions

function Remove-Bloatware {
    Write-Progress "Removing Non-Essential Apps for Gaming..."
    
    try {
        # List of bloatware apps to remove
        $bloatwareApps = @(
            "Microsoft.3DBuilder",
            "Microsoft.BingNews",
            "Microsoft.BingWeather",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MixedReality.Portal",
            "Microsoft.People",
            "Microsoft.SkypeApp",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.WindowsMaps",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo"
        )

        # Create backup data structure
        $backupData = @{
            "RemovalDate" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            "RemovedApps" = @()
        }

        # Remove apps and record in backup
        foreach ($app in $bloatwareApps) {
            $packageFullName = (Get-AppxPackage $app -ErrorAction SilentlyContinue).PackageFullName
            if ($packageFullName) {
                Remove-AppxPackage -Package $packageFullName -ErrorAction SilentlyContinue
                $backupData.RemovedApps += @{
                    "Name"            = $app
                    "PackageFullName" = $packageFullName
                }
                Write-Progress "Removed $app"
            }
        }

        # Save backup to JSON file
        $backupPath = "$PSScriptRoot/../../database/bloatware_backup.json"
        $backupData | ConvertTo-Json -Depth 4 | Out-File -FilePath $backupPath -Force
        Write-Progress "Saved backup to $backupPath"

        # Write-Complete "Bloatware Removal Complete"
    }
    catch {
        Write-Warning "Failed to remove bloatware: $_"
    }
}

function Optimize-WindowsFeatures {
    Write-Progress "Optimizing Windows Features..."
    
    try {
        # List of features to disable
        $featuresToDisable = @(
            "WindowsMediaPlayer",
            "Printing-XPSServices-Features",
            "Printing-PrintToPDFServices-Features",
            "Internet-Explorer-Optional-amd64"
        )

        foreach ($feature in $featuresToDisable) {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
            Write-Progress "Disabled feature: $feature"
        }

        # Write-Complete "Windows Features Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize Windows features: $_"
    }
}

function Clean-SystemFiles {
    Write-Progress "Cleaning System Files..."
    
    try {
        # Clean Windows Temp folder
        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Progress "Cleaned Windows Temp folder"

        # Clean User Temp folder
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Progress "Cleaned User Temp folder"

        # Clean Windows Update files
        # $updateCleaner = New-Object -ComObject Microsoft.Update.Session
        # $updateSearcher = $updateCleaner.CreateUpdateSearcher()
        # $updates = $updateSearcher.Search("IsInstalled=0")
        # foreach ($update in $updates.Updates) {
        #     $update.AcceptEula()
        #     $update.Install()
        # }
        # Write-Progress "Cleaned Windows Update files"

        # Clean DNS Cache
        Clear-DnsClientCache
        Write-Progress "Cleared DNS Cache"

        # Write-Complete "System Files Cleanup Complete"
    }
    catch {
        Write-Warning "Failed to clean system files: $_"
    }
}

function Optimize-WindowsServices {
    Write-Progress "Optimizing Windows Services..."
    
    try {
        # Services to configure with their desired startup types
        $servicesToConfigure = @{
            "AJRouter" = "Disabled"
            "ALG" = "Manual"
            "AppIDSvc" = "Manual"
            "AppMgmt" = "Manual"
            "AppReadiness" = "Disabled"
            "AppVClient" = "Disabled"
            "AssignedAccessManagerSvc" = "Disabled"
            "AxInstSV" = "Manual"
            "BcastDVRUserService" = "Disabled"
            "BDESVC" = "Manual"
            "BrokerInfrastructure" = "Automatic"
            "Browser" = "Manual"
            "CDPSvc" = "Disabled"
            "CDPUserSvc" = "Disabled"
            "CertPropSvc" = "Manual"
            "ClipSVC" = "Disabled"
            "CoreMessagingRegistrar" = "Automatic"
            "CscService" = "Manual"
            "DcomLaunch" = "Automatic"
            "Defrag" = "Manual"
            "DeviceAssociationService" = "Manual"
            "DeviceInstall" = "Manual"
            "DevQueryBroker" = "Manual"
            "diagnosticshub.standardcollector.service" = "Disabled"
            "DiagTrack" = "Disabled"
            "DispBrokerDesktopSvc" = "Automatic"
            "DisplayEnhancementService" = "Manual"
            "DmEnrollmentSvc" = "Manual"
            "dmwappushservice" = "Disabled"
            "DoSvc" = "Manual"
            "DPS" = "Manual"
            "DsmSvc" = "Manual"
            "DsSvc" = "Manual"
            "DusmSvc" = "Manual"
            "EapHost" = "Manual"
            "EFS" = "Manual"
            "embeddedmode" = "Manual"
            "EntAppSvc" = "Manual"
            "EventSystem" = "Automatic"
            "Fax" = "Disabled"
            "fdPHost" = "Manual"
            "FDResPub" = "Manual"
            "fhsvc" = "Manual"
            "FontCache" = "Manual"
            "FontCache3.0.0.0" = "Manual"
            "FrameServer" = "Manual"
            "gpsvc" = "Automatic"
            "GraphicsPerfSvc" = "Manual"
            "hidserv" = "Manual"
            "HvHost" = "Manual"
            "icssvc" = "Manual"
            "IKEEXT" = "Manual"
            "InstallService" = "Manual"
            "KeyIso" = "Manual"
            "KtmRm" = "Manual"
            "lfsvc" = "Manual"
            "LicenseManager" = "Manual"
            "lltdsvc" = "Manual"
            "lmhosts" = "Manual"
            "LxpSvc" = "Manual"
            "MapsBroker" = "Disabled"
            "MessagingService" = "Disabled"
            "MpsSvc" = "Manual"
            "MSDTC" = "Manual"
            "MSiSCSI" = "Manual"
            "msiserver" = "Manual"
            "NaturalAuthentication" = "Manual"
            "NcaSvc" = "Manual"
            "NcbService" = "Manual"
            "NcdAutoSetup" = "Manual"
            "NetTcpPortSharing" = "Manual"
            "NgcCtnrSvc" = "Manual"
            "NgcSvc" = "Manual"
            "OneSyncSvc" = "Manual"
            "PcaSvc" = "Manual"
            "PerfHost" = "Manual"
            "PhoneSvc" = "Manual"
            "PlugPlay" = "Automatic"
            "Pnrpsvc" = "Manual"
            "PolicyAgent" = "Manual"
            "Power" = "Automatic"
            "PrintNotify" = "Manual"
            "PrintWorkflowUserSvc" = "Manual"
            "ProfSvc" = "Automatic"
            "PushToInstall" = "Manual"
            "QWAVE" = "Manual"
            "RetailDemo" = "Disabled"
            "RmSvc" = "Manual"
            "RpcLocator" = "Manual"
            "SCardSvr" = "Manual"
            "ScDeviceEnum" = "Manual"
            "Schedule" = "Automatic"
            "SCPolicySvc" = "Manual"
            "SDRSVC" = "Manual"
            "seclogon" = "Manual"
            "SEMgrSvc" = "Manual"
            "SensorDataService" = "Manual"
            "SensorService" = "Manual"
            "SensrSvc" = "Manual"
            "SessionEnv" = "Manual"
            "SgrmBroker" = "Manual"
            "SharedAccess" = "Manual"
            "smphost" = "Manual"
            "SmsRouter" = "Manual"
            "SNMPTRAP" = "Manual"
            "Spectrum" = "Manual"
            "Spooler" = "Manual"
            "sppsvc" = "Manual"
            "SSDPSRV" = "Manual"
            "ssh-agent" = "Manual"
            "SstpSvc" = "Manual"
            "StateRepository" = "Manual"
            "StorSvc" = "Manual"
            "svsvc" = "Manual"
            "swprv" = "Manual"
            "SysMain" = "Automatic"
            "SystemEventsBroker" = "Manual"
            "TabletInputService" = "Manual"
            "TapiSrv" = "Manual"
            "TermService" = "Manual"
            "Themes" = "Automatic"
            "TieringEngineService" = "Manual"
            "TimeBrokerSvc" = "Manual"
            "TokenBroker" = "Manual"
            "TrkWks" = "Manual"
            "TrustedInstaller" = "Manual"
            "tzautoupdate" = "Manual"
            "UevAgentService" = "Manual"
            "UmRdpService" = "Manual"
            "UnistoreSvc" = "Manual"
            "upnphost" = "Manual"
            "UserManager" = "Automatic"
            "UsoSvc" = "Manual"
            "VaultSvc" = "Manual"
            "vds" = "Manual"
            "vmicguestinterface" = "Manual"
            "vmicheartbeat" = "Manual"
            "vmickvpexchange" = "Manual"
            "vmicrdv" = "Manual"
            "vmicshutdown" = "Manual"
            "vmictimesync" = "Manual"
            "vmicvmsession" = "Manual"
            "vmicvss" = "Manual"
            "vmvss" = "Manual"
            "wbengine" = "Manual"
            "wcncsvc" = "Manual"
            "webthreatdefsvc" = "Manual"
            "webthreatdefusersvc_*" = "Manual"
            "wercplsupport" = "Manual"
            "wisvc" = "Manual"
            "wlidsvc" = "Manual"
            "wlpasvc" = "Manual"
            "wmiApSrv" = "Manual"
            "workfolderssvc" = "Manual"
            "wscsvc" = "Automatic"
            "wudfsvc" = "Manual"
        }

        foreach ($service in $servicesToConfigure.GetEnumerator()) {
            Stop-Service -Name $service.Key -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service.Key -StartupType $service.Value -ErrorAction SilentlyContinue
            Write-Progress "Set $($service.Key) to $($service.Value)"
        }

        # Write-Complete "Windows Services Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize Windows services: $_"
    }
}

function Optimize-SystemCleanup {
    Write-SectionHeader "System Cleanup and Optimization"
    
    Write-Progress "Starting System Cleanup..."
    
    # Execute all cleanup optimizations
    Remove-Bloatware
    Optimize-WindowsFeatures
    Optimize-WindowsServices
    
    # Write-Complete "System Cleanup Complete!"
    Write-Host ""
}

# Gaming Optimization Functions

function Optimize-GameMode {
    Write-Progress "Configuring Windows Game Mode..."
    
    try {
        # Registry path for Game Mode
        $regPath = "HKCU:\Software\Microsoft\GameBar"
        
        # Enable Game Mode
        Set-ItemProperty -Path $regPath -Name "AllowAutoGameMode" -Value 1
        Set-ItemProperty -Path $regPath -Name "AutoGameModeEnabled" -Value 1
        Write-Progress "Enabled Game Mode"
        
        # Write-Complete "Game Mode Configuration Complete"
    }
    catch {
        Write-Warning "Failed to configure Game Mode: $_"
    }
}

function Optimize-GameDVR {
    Write-Progress "Optimizing Game DVR Settings..."
    
    try {
        # Registry paths for Game DVR
        $gameDvrPath = "HKCU:\System\GameConfigStore"
        $gameDvrPath2 = "HKCU:\Software\Microsoft\GameBar"
        
        # Disable Game DVR features
        Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_Enabled" -Value 0
        Set-ItemProperty -Path $gameDvrPath2 -Name "UseNexusForGameBarEnabled" -Value 0
        Write-Progress "Disabled Game DVR"
        
        # Optimize Game DVR performance settings
        Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_FSEBehavior" -Value 2
        Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_FSEBehaviorMode" -Value 2
        Write-Progress "Optimized Game DVR Performance Settings"
        
        # Write-Complete "Game DVR Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize Game DVR settings: $_"
    }
}

function Optimize-FullscreenOptimizations {
    Write-Progress "Configuring Fullscreen Optimizations..."
    
    try {
        # Registry path for fullscreen optimizations
        $regPath = "HKCU:\System\GameConfigStore"
        
        # Configure fullscreen optimizations
        Set-ItemProperty -Path $regPath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1
        Set-ItemProperty -Path $regPath -Name "GameDVR_EFSEFeatureFlags" -Value 0
        Write-Progress "Configured Fullscreen Settings"
        
        # Write-Complete "Fullscreen Optimizations Complete"
    }
    catch {
        Write-Warning "Failed to configure fullscreen optimizations: $_"
    }
}

function Optimize-GameBarFeatures {
    Write-Progress "Optimizing Game Bar Features..."
    
    try {
        # Registry paths for Game Bar
        $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
        $gameBarServicesPath = "HKCU:\Software\Microsoft\GameBar\GamePanels"
        
        # Disable Game Bar features
        Set-ItemProperty -Path $gameBarPath -Name "ShowStartupPanel" -Value 0
        Set-ItemProperty -Path $gameBarPath -Name "GamePanelStartupTipIndex" -Value 3
        Write-Progress "Disabled Game Bar Startup Panel"
        
        # Optimize Game Bar services
        if (!(Test-Path $gameBarServicesPath)) {
            New-Item -Path $gameBarServicesPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameBarServicesPath -Name "ShowGamePanel" -Value 0
        Write-Progress "Optimized Game Bar Services"
        
        # Write-Complete "Game Bar Features Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize Game Bar features: $_"
    }
}

function Optimize-GamingFeatures {
    Write-SectionHeader "Gaming Features Optimization"
    
    Write-Progress "Starting Gaming Features Optimization..."
    
    # Execute all gaming optimizations
    Optimize-GameMode
    Optimize-GameDVR
    Optimize-FullscreenOptimizations
    Optimize-GameBarFeatures
    
    # Write-Complete "Gaming Features Optimization Complete!"
    Write-Host ""
}

# Network Optimization Functions

function Optimize-NetworkDriverSettings {
    Write-Progress "Optimizing Network Adapter Settings..."
    
    try {
        # Get all network adapters
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        
        foreach ($adapter in $adapters) {
            # Disable Power Management
            $devicePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\" + $adapter.DeviceID
            if (Test-Path $devicePath) {
                Set-ItemProperty -Path $devicePath -Name "PnPCapabilities" -Value 24
                Write-Progress "Disabled Power Management for $($adapter.Name)"
            }
            
            # Optimize adapter settings
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Jumbo Packet" -DisplayValue "9014 Bytes" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Flow Control" -DisplayValue "Rx `& Tx Enabled" -ErrorAction SilentlyContinue
            Write-Progress "Optimized Advanced Properties for $($adapter.Name)"
        }
        
        # Write-Complete "Network Adapter Settings Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize network adapter settings: $_"
    }
}

function Optimize-TCPIPSettings {
    Write-Progress "Optimizing TCP/IP Stack..."
    
    try {
        # Registry paths for TCP/IP optimization
        $tcpipParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        $tcpipInt = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        
        # Optimize global TCP/IP settings
        Set-ItemProperty -Path $tcpipParams -Name "DefaultTTL" -Value 64
        Set-ItemProperty -Path $tcpipParams -Name "Tcp1323Opts" -Value 1
        Set-ItemProperty -Path $tcpipParams -Name "TcpMaxDupAcks" -Value 2
        Set-ItemProperty -Path $tcpipParams -Name "SackOpts" -Value 1
        Write-Progress "Configured TCP/IP Parameters"
        
        # Optimize network interfaces
        Get-ChildItem $tcpipInt | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1
            Set-ItemProperty -Path $_.PSPath -Name "TcpNoDelay" -Value 1
        }
        Write-Progress "Optimized Network Interfaces"
        
        # Write-Complete "TCP/IP Stack Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize TCP/IP settings: $_"
    }
}

function Optimize-NetworkPriority {
    Write-Progress "Setting Gaming Network Priority..."
    
    try {
        # Registry path for network priority
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        
        # Set network priority for gaming
        Set-ItemProperty -Path $regPath -Name "NetworkThrottlingIndex" -Value 4294967295
        Set-ItemProperty -Path $regPath -Name "SystemResponsiveness" -Value 0
        Write-Progress "Set Network Priority Settings"
        
        # Optimize gaming network settings
        $gamingPath = "$regPath\Games"
        if (!(Test-Path $gamingPath)) {
            New-Item -Path $gamingPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gamingPath -Name "Priority" -Value 1
        Set-ItemProperty -Path $gamingPath -Name "NetworkThrottlingIndex" -Value 4294967295
        Write-Progress "Optimized Gaming Network Settings"
        
        # Write-Complete "Network Priority Configuration Complete"
    }
    catch {
        Write-Warning "Failed to set network priority: $_"
    }
}

function Optimize-NetworkQoS {
    Write-Progress "Configuring Quality of Service Settings..."
    
    try {
        # Registry path for QoS
        $qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
        
        # Create QoS path if it doesn't exist
        if (!(Test-Path $qosPath)) {
            New-Item -Path $qosPath -Force | Out-Null
        }
        
        # Configure QoS settings
        Set-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -Value 0
        Set-ItemProperty -Path $qosPath -Name "TimerResolution" -Value 1
        Write-Progress "Set QoS Parameters"
        
        # Disable Auto-Tuning
        netsh int tcp set global autotuninglevel=disabled
        Write-Progress "Disabled TCP Auto-Tuning"
        
        # Write-Complete "QoS Configuration Complete"
    }
    catch {
        Write-Warning "Failed to configure QoS settings: $_"
    }
}

function Optimize-NetworkSettings {
    Write-SectionHeader "Network Settings Optimization"
    
    Write-Progress "Starting Network Settings Optimization..."
    
    # Execute all network optimizations
    Optimize-NetworkDriverSettings 
    Optimize-TCPIPSettings
    Optimize-NetworkPriority
    Optimize-NetworkQoS
    
    # Write-Complete "Network Settings Optimization Complete!"
    Write-Host ""
}

# Power Management Functions
# Power Management Functions

# Main Optimization Function
function Optimize-All {
    Write-SectionHeader "ZenSL Optimizer - Full System Optimization"
    
    # Execute all optimization categories
    Optimize-SystemPerformance
    Optimize-SystemCleanup
    Optimize-GamingFeatures
    Optimize-NetworkSettings
    Optimize-PowerSettings
    Optimize-SecurityPrivacy
    Optimize-VisualFX
    Optimize-BackgroundApps
    Optimize-AutostartApps
    Set-WindowsUIFeatures
    Optimize-NvidiaGPU
    
    # Write-Complete "All System Optimizations Complete!"
    Write-Host ""
}

function Optimize-VisualFX {
    Write-Progress "Optimizing Visual Effects Settings..."
    
    try {
        # Registry path for visual effects
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        
        # Optimize visual effects settings
        Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 2
        Write-Progress "Configured Visual Effects Settings"
        
        # Write-Complete "Visual Effects Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize visual effects: $_"
    }
}

function Optimize-BackgroundApps {
    Write-Progress "Optimizing Background Applications..."
    
    try {
        # Registry path for background apps
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
        
        # Disable background apps
        Set-ItemProperty -Path $regPath -Name "GlobalUserDisabled" -Value 1
        Write-Progress "Disabled Background Applications"
        
        # Write-Complete "Background Applications Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize background applications: $_"
    }
}

function Optimize-AutostartApps {
    Write-Progress "Optimizing Startup Applications..."
    
    try {
        # Registry path for startup apps
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        
        # List of unnecessary startup apps to remove
        $unnecessaryApps = @(
            "OneDrive",
            "MicrosoftEdgeAutoLaunch_*",
            "Skype",
            "Spotify",
            "AdobeAAMUpdater-*",
            "Google Update",
            "iTunesHelper",
            "QuickTime Task",
            "SunJavaUpdateSched",
            "HP Software Update",
            "DellSupportCenter",
            "Epson Status Monitor",
            "Canon Quick Menu",
            "NVIDIA Profile Loader",
            "Steam",
            "EpicGamesLauncher",
            "Dropbox Update",
            "ZoomOpener",
            "Microsoft Teams"
        )
        
        # Remove specific unnecessary startup apps
        foreach ($app in $unnecessaryApps) {
            Remove-ItemProperty -Path $regPath -Name $app -ErrorAction SilentlyContinue
            Write-Progress "Removed startup app: $app"
        }
        
        # Remove any remaining unknown startup apps
        Remove-ItemProperty -Path $regPath -Name "*" -ErrorAction SilentlyContinue
        Write-Progress "Removed unknown startup applications"
        
        # Write-Complete "Startup Applications Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize startup applications: $_"
    }
}

function Set-WindowsUIFeatures {
    Write-Progress "Configuring Windows UI Features..."
    
    try {
        # Registry path for UI features
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        
        # Configure UI features
        Set-ItemProperty -Path $regPath -Name "TaskbarAnimations" -Value 0
        Set-ItemProperty -Path $regPath -Name "TaskbarSmallIcons" -Value 1
        Write-Progress "Configured Windows UI Features"
        
        # Write-Complete "Windows UI Features Configuration Complete"
    }
    catch {
        Write-Warning "Failed to configure Windows UI features: $_"
    }
}

function Optimize-UIUX {
    Write-SectionHeader "UI/UX Optimization"
    
    Write-Progress "Starting UI/UX Optimization..."
    
    # Execute all UI/UX optimizations
    Optimize-VisualFX
    Optimize-BackgroundApps
    Optimize-AutostartApps
    Set-WindowsUIFeatures
    
    # Write-Complete "UI/UX Optimization Complete!"
    Write-Host ""
}

function Optimize-UltimatePerformancePlan {
    Write-SectionHeader "Power Plan Optimization"
    Write-Progress "Creating and Applying 'ZenSL Lite Ultimate Performance' Power Plan..."

    try {
        # Specify the GUID of the "Ultimate Performance" power plan
        $originalUltimatePerformanceGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"

        # Verify the original power plan exists
        $originalPlanExists = powercfg /list | Select-String -Pattern $originalUltimatePerformanceGuid
        if (-not $originalPlanExists) {
            Write-Warning "Ultimate Performance power plan not found. Creating base plan..."
            powercfg /duplicatescheme SCHEME_MIN
            Start-Sleep -Seconds 1
        }

        # Duplicate the "Ultimate Performance" power plan
        $duplicatedPlan = powercfg /duplicatescheme $originalUltimatePerformanceGuid 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to duplicate power plan: $duplicatedPlan"
        }

        # Extract the GUID using regex to capture any GUID format in the output
        $newPlanGuid = ($duplicatedPlan | Select-String -Pattern "\b([a-f0-9\-]{36})\b").Matches.Groups[1].Value

        # Check if the duplication was successful and GUID is valid
        if ($newPlanGuid -and $newPlanGuid -match '^[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}$') {
            Write-Progress "Power Plan created with GUID: $newPlanGuid"

            # Apply custom modifications to the new power plan
            powercfg /changename $newPlanGuid "ZenSL Lite Ultimate Performance"
            powercfg /setacvalueindex $newPlanGuid SUB_PROCESSOR PROCTHROTTLEMAX 100
            powercfg /setacvalueindex $newPlanGuid SUB_PROCESSOR PROCFREQMAX 100
            powercfg /setacvalueindex $newPlanGuid SUB_DISK DISKIDLE 0
            powercfg /setacvalueindex $newPlanGuid SUB_VIDEO VIDEOCONLOCK 0
            powercfg /setacvalueindex $newPlanGuid SUB_SLEEP STANDBYIDLE 0
            # Set the newly created plan as the active plan
            powercfg /setactive $newPlanGuid

            Write-Progress "'ZenSL Lite Ultimate Performance' Power Plan successfully configured and activated"
        }
        else {
            throw "Invalid GUID format or power plan duplication failed"
        }
    }
    catch {
        Write-Warning "Power Plan Optimization Error: $($_.Exception.Message)"
        # Attempt to clean up the failed power plan
        if ($newPlanGuid) {
            powercfg /delete $newPlanGuid -ErrorAction SilentlyContinue
        }
        return $false
    }
    return $true
}

function Optimize-ProcessorPower {
    Write-Progress "Optimizing CPU Power Settings..."
    
    try {
        # Registry path for processor power management
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00"
        
        # Enable all power settings for modification
        Get-ChildItem $regPath | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "Attributes" -Value 0
        }
        
        # Configure processor performance boost mode
        $boostPath = "$regPath\be337238-0d82-4146-a960-4f3749d470c7"
        Set-ItemProperty -Path $boostPath -Name "Attributes" -Value 0
        Write-Progress "Enabled Processor Performance Boost"
        
        # Write-Complete "CPU Power Settings Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize CPU power settings: $_"
    }
}

function Optimize-GPUPower {
    Write-Progress "Optimizing GPU Power Settings..."
    
    try {
        # Registry path for GPU power settings
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
        
        # Configure GPU power settings
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name "PerfLevelSrc" -Value 0x00002222
            Set-ItemProperty -Path $regPath -Name "PowerMizerEnable" -Value 1
            Set-ItemProperty -Path $regPath -Name "PowerMizerLevel" -Value 1
            Write-Progress "Configured GPU Power Settings"
            
            # Write-Complete "GPU Power Settings Optimization Complete"
        }
        else {
            Write-Warning "GPU registry path not found"
        }
    }
    catch {
        Write-Warning "Failed to optimize GPU power settings: $_"
    }
}

function Optimize-USBPower {
    Write-Progress "Optimizing USB Power Settings..."
    
    try {
        # Get all USB controllers
        $usbControllers = Get-WmiObject Win32_USBController
        
        foreach ($controller in $usbControllers) {
            # Disable selective suspend
            $devicePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($controller.DeviceID)\Device Parameters"
            if (Test-Path $devicePath) {
                Set-ItemProperty -Path $devicePath -Name "SelectiveSuspendEnabled" -Value 0
                Write-Progress "Disabled Selective Suspend for $($controller.Name)"
            }
        }
        
        # Disable USB power savings globally
        $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
        if (Test-Path $usbPath) {
            Set-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -Value 1
        }
        
        # Write-Complete "USB Power Settings Optimization Complete"
    }
    catch {
        Write-Warning "Failed to optimize USB power settings: $_"
    }
}

function Optimize-PowerSettings {
    Write-SectionHeader "Power Settings Optimization"
    
    Write-Progress "Starting Power Settings Optimization..."
    
    # Execute all power optimizations
    Optimize-UltimatePerformancePlan
    Optimize-ProcessorPower
    Optimize-GPUPower
    Optimize-USBPower
    
    # Write-Complete "Power Settings Optimization Complete!"
    Write-Host ""
}

# Security and Privacy Functions

function Remove-Telemetry {
    Write-Progress "Disabling Windows Telemetry..."
    
    try {
        # Disable telemetry via registry
        $regPaths = @{
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"             = @{"AllowTelemetry" = 0 }
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"                            = @{"AllowTelemetry" = 0 }
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" = @{"AllowTelemetry" = 0 }
        }
        
        foreach ($path in $regPaths.Keys) {
            if (!(Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
            foreach ($name in $regPaths[$path].Keys) {
                Set-ItemProperty -Path $path -Name $name -Value $regPaths[$path][$name]
            }
        }
        Write-Progress "Configured Registry Settings"
        
        # Write-Complete "Telemetry Removal Complete"
    }
    catch {
        Write-Warning "Failed to remove telemetry: $_"
    }
}

function Set-PrivacySettings {
    Write-Progress "Optimizing Privacy Settings..."
    
    try {
        # Privacy settings registry paths
        $privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
        $advertisingPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        
        # Create paths if they don't exist
        if (!(Test-Path $privacyPath)) {
            New-Item -Path $privacyPath -Force | Out-Null
        }
        if (!(Test-Path $advertisingPath)) {
            New-Item -Path $advertisingPath -Force | Out-Null
        }
        
        # Configure privacy settings
        Set-ItemProperty -Path $advertisingPath -Name "Enabled" -Value 0
        Write-Progress "Disabled Advertising ID"
        
        # Disable app access to various features
        $appPrivacySettings = @(
            "LetAppsAccessLocation",
            "LetAppsAccessCamera",
            "LetAppsAccessMicrophone",
            "LetAppsAccessNotifications",
            "LetAppsAccessAccountInfo",
            "LetAppsAccessContacts"
        )
        
        foreach ($setting in $appPrivacySettings) {
            Set-ItemProperty -Path $privacyPath -Name $setting -Value 0 -ErrorAction SilentlyContinue
            Write-Progress "Disabled: $setting"
        }
        
        # Write-Complete "Privacy Settings Optimization Complete"
    }
    catch {
        Write-Warning "Failed to set privacy settings: $_"
    }
}

function Optimize-SecurityPrivacy {
    Write-SectionHeader "Security and Privacy Optimization"
    
    Write-Progress "Starting Security and Privacy Optimization..."
    
    # Execute all security and privacy optimizations
    Remove-Telemetry
    Set-PrivacySettings
    
    # Write-Complete "Security and Privacy Optimization Complete!"
    Write-Host ""
}

# Call Optimization Functions for Full System Optimization
Optimize-All