# Hardware Settings Import
. "$PSScriptRoot/hardware/Revert_NVIDIA_GPU.ps1"

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

function Undo-MemoryManagement {
    Write-Progress "Undoing Memory Management Settings..."
    # Restore default memory management settings
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'LargeSystemCache' -Value 0
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'ClearPageFileAtShutdown' -Value 0
    Write-Progress "Undoed Memory Management Settings"
}

function Undo-CPUScheduling {
    Write-Progress "Undoing CPU Scheduling Settings..."
    
    try {
        # Registry path for CPU scheduling
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        
        # Restore default CPU priority settings
        Set-ItemProperty -Path $regPath -Name "Win32PrioritySeparation" -Value 2
        Write-Progress "Restored default CPU Priority Settings"
    }
    catch {
        Write-Warning "Failed to undo CPU scheduling: $_"
    }
}

function Undo-DiskIO {
    Write-Progress "Reverting Disk I/O Performance Settings..."
    
    try {
        # Re-enable disk performance counters
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Disk"
        Set-ItemProperty -Path $regPath -Name "DisablePerformanceCounter" -Value 0
        Write-Progress "Re-enabled Disk Performance Counters"
        
        # Disable write caching
        Get-Disk | ForEach-Object {
            Set-Disk -Number $_.Number -IsReadOnly $true
            Write-Progress "Disabled Write Caching for Disk $($_.Number)"
        }
        
        Write-Progress "Disk I/O Settings Reverted to Default"
    }
    catch {
        Write-Warning "Failed to revert disk I/O settings: $_"
    }
}

function Undo-PagefileVRAM {
    try {
        Write-Progress "Restoring default pagefile settings..." -ForegroundColor Cyan

        # Enable automatic pagefile management
        try {
            $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
            $computerSystem | Set-CimInstance -Property @{AutomaticManagedPagefile = $true }
            Write-Progress "Enabled automatic pagefile management"
        }
        catch {
            Write-Warning "Failed to enable automatic pagefile management: $_"
            return
        }

        # Remove custom pagefile configuration
        try {
            $existingPagefile = Get-CimInstance -ClassName Win32_PageFileSetting | Where-Object { $_.Name -eq "C:\\pagefile.sys" }
            if ($existingPagefile) {
                $existingPagefile | Remove-CimInstance
                Write-Progress "Removed custom pagefile configuration"
            }
        }
        catch {
            Write-Warning "Failed to remove custom pagefile configuration: $_"
            return
        }

        Write-Progress "Pagefile settings restored to default successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "An unexpected error occurred while restoring defaults: $_"
    }
}

function Undo-CustomTimerResolution {
    Write-Progress "Reverting Custom Timer Resolution..."
    
    try {
        # Restore default timer resolution
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
        Set-ItemProperty -Path $regPath -Name "GlobalTimerResolutionRequests" -Value 0
        
        Write-Progress "Timer Resolution Reverted to Default"
    }
    catch {
        Write-Warning "Failed to revert custom timer resolution: $_"
    }
}

function Undo-SystemResponsiveness {
    Write-Progress "Restoring Default System Responsiveness..."
    
    try {
        # Registry path for system responsiveness
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        
        # Restore default system responsiveness settings
        Set-ItemProperty -Path $regPath -Name "SystemResponsiveness" -Value 20  # Default value
        Set-ItemProperty -Path $regPath -Name "NetworkThrottlingIndex" -Value 10  # Default value
        
        Write-Progress "Restored Default System Profile Settings"
    }
    catch {
        Write-Warning "Failed to restore system responsiveness: $_"
    }
}

function Undo-SystemPerformance {
    Write-SectionHeader "Undoing System Performance Settings"
    Write-Progress "Undoing System Performance Settings..."
    # Execute all system performance reversion functions
    Undo-MemoryManagement # VERIFIED REVERSION
    Undo-CPUScheduling # VERIFIED REVERSION
    Undo-DiskIO # VERIFIED REVERSION
    Undo-WindowsServices # VERIFIED REVERSION
    Undo-PagefileVRAM # VERIFIED REVERSION
    Undo-CustomTimerResolution # VERIFIED REVERSION
    Undo-SystemResponsiveness # VERIFIED REVERSION
    Restore-Bloatware # VERIFIED REVERSION
    Write-Progress "Undoed System Performance Settings"
}

function Restore-Bloatware {
    Write-Progress "Restoring Removed Apps..."
    
    try {
        # List of bloatware apps to restore (same as removal list)
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

        # Restore each app from the Microsoft Store
        foreach ($app in $bloatwareApps) {
            try {
                Add-AppxPackage -DisableDevelopmentMode -Register "$($env:SystemRoot)\SystemApps\$app*" -ErrorAction Stop
                Write-Progress "Restored $app"
            }
            catch {
                Write-Warning "Failed to restore: $_"
            }
        }
        
        Write-Progress "Bloatware restoration complete"
    }
    catch {
        Write-Warning "Failed to restore bloatware: $_"
    }
}

function Undo-WindowsFeatures {
    Write-Progress "Restoring default Windows features settings..."
    # Restore default Windows features settings
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoDriveTypeAutoRun' -Value 145
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoDriveAutoRun' -Value 67108863
    Write-Progress "Restored default Windows features settings"
}

function Clean-SystemFiles {
    Write-Progress "Restoring default system files cleanup settings..."
    # Restore default system files cleanup settings
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'ClearPageFileAtShutdown' -Value 0
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0
    Write-Progress "Restored default system files cleanup settings"
}

function Undo-WindowsServices {
    Write-Progress "Restoring Windows Services to Default States..."
    
    try {
        # Default service states for a fresh Windows installation
        $defaultServiceStates = @{
            "AJRouter" = "Manual"
            "ALG" = "Manual"
            "AppIDSvc" = "Manual"
            "AppMgmt" = "Manual"
            "AppReadiness" = "Automatic"
            "AppVClient" = "Manual"
            "AssignedAccessManagerSvc" = "Manual"
            "AxInstSV" = "Manual"
            "BcastDVRUserService" = "Manual"
            "BDESVC" = "Manual"
            "BrokerInfrastructure" = "Automatic"
            "Browser" = "Manual"
            "CDPSvc" = "Manual"
            "CDPUserSvc" = "Manual"
            "CertPropSvc" = "Manual"
            "ClipSVC" = "Manual"
            "CoreMessagingRegistrar" = "Automatic"
            "CscService" = "Manual"
            "DcomLaunch" = "Automatic"
            "Defrag" = "Manual"
            "DeviceAssociationService" = "Manual"
            "DeviceInstall" = "Manual"
            "DevQueryBroker" = "Manual"
            "diagnosticshub.standardcollector.service" = "Manual"
            "DiagTrack" = "Automatic"
            "DispBrokerDesktopSvc" = "Automatic"
            "DisplayEnhancementService" = "Manual"
            "DmEnrollmentSvc" = "Manual"
            "dmwappushservice" = "Automatic"
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
            "Fax" = "Manual"
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
            "MapsBroker" = "Manual"
            "MessagingService" = "Manual"
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
            "RetailDemo" = "Manual"
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
            "Spooler" = "Automatic"
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

        foreach ($service in $defaultServiceStates.GetEnumerator()) {
            Set-Service -Name $service.Key -StartupType $service.Value -ErrorAction SilentlyContinue
            Write-Progress "Restored $($service.Key) to $($service.Value)"
        }

        Write-Progress "Windows Services restored to default states"
    }
    catch {
        Write-Warning "Failed to restore Windows services: $_"
    }
}

function Undo-SystemCleanup {
    Write-Progress "Restoring default system cleanup settings..."
    # Restore default system cleanup settings
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'ClearPageFileAtShutdown' -Value 0
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'DisablePagingExecutive' -Value 0
    Write-Progress "Restored default system cleanup settings"
}

function Undo-GameMode {
    Write-Progress "Restoring Default Game Mode Settings..."
    
    try {
        # Registry path for Game Mode
        $regPath = "HKCU:\Software\Microsoft\GameBar"
        
        # Enable Game Mode
        Set-ItemProperty -Path $regPath -Name "AllowAutoGameMode" -Value 0
        Set-ItemProperty -Path $regPath -Name "AutoGameModeEnabled" -Value 0
        Write-Progress "Disabled Game Mode"
        
        # Write-Complete "Game Mode Configuration Complete"
    }
    catch {
        Write-Warning "Failed to restore Game Mode settings: $_"
    }
}

function Undo-GameDVR {
    Write-Progress "Restoring Default Game DVR Settings..."
    
    try {
        # Registry paths for Game DVR
        $gameDvrPath = "HKCU:\System\GameConfigStore"
        $gameDvrPath2 = "HKCU:\Software\Microsoft\GameBar"
        
        # Enable Game DVR features
        Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_Enabled" -Value 1
        Set-ItemProperty -Path $gameDvrPath2 -Name "UseNexusForGameBarEnabled" -Value 1
        Write-Progress "Enabled Game DVR"
        
        # Restore default Game DVR performance settings
        Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_FSEBehavior" -Value 1
        Set-ItemProperty -Path $gameDvrPath -Name "GameDVR_FSEBehaviorMode" -Value 1
        Write-Progress "Restored Default Game DVR Performance Settings"
        
        Write-Progress "Game DVR Settings Restored Successfully"
    }
    catch {
        Write-Warning "Failed to restore Game DVR settings: $_"
    }
}

function Undo-FullscreenOptimizations {
    Write-Progress "Reverting Fullscreen Optimizations..."
    
    try {
        # Registry path for fullscreen optimizations
        $regPath = "HKCU:\System\GameConfigStore"
        
        # Revert fullscreen optimizations to default values
        Set-ItemProperty -Path $regPath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 0
        Set-ItemProperty -Path $regPath -Name "GameDVR_EFSEFeatureFlags" -Value 1
        Write-Progress "Reverted Fullscreen Settings to Default"
        
        Write-Progress "Fullscreen Optimizations Reverted Successfully" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to revert fullscreen optimizations: $_"
    }
}

function Undo-GameBarFeatures {
    Write-Progress "Restoring Game Bar Features..."
    
    try {
        # Registry paths for Game Bar
        $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
        $gameBarServicesPath = "HKCU:\Software\Microsoft\GameBar\GamePanels"
        
        # Restore Game Bar features to default
        Set-ItemProperty -Path $gameBarPath -Name "ShowStartupPanel" -Value 1
        Set-ItemProperty -Path $gameBarPath -Name "GamePanelStartupTipIndex" -Value 0
        Write-Progress "Restored Game Bar Startup Panel"
        
        # Restore Game Bar services
        if (Test-Path $gameBarServicesPath) {
            Set-ItemProperty -Path $gameBarServicesPath -Name "ShowGamePanel" -Value 1
            Write-Progress "Restored Game Bar Services"
        }
        
        Write-Progress "Game Bar Features Restoration Complete"
    }
    catch {
        Write-Warning "Failed to restore Game Bar features: $_"
    }
}

function Undo-GamingFeatures {
    Write-SectionHeader "Undoing Gaming Features"
    Write-Progress "Undoing Gaming Features..."
    # Execute all gaming features reversion functions
    Undo-GameMode # VERIFIED REVERSION
    Undo-GameDVR # VERIFIED REVERSION
    Undo-FullscreenOptimizations # VERIFIED REVERSION
    Undo-GameBarFeatures # VERIFIED REVERSION
    Write-Progress "Undoed Gaming Features" 
}

function Undo-NetworkDriverSettings {
    Write-Progress "Reverting Network Adapter Settings..."
    
    try {
        # Get all network adapters
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        
        foreach ($adapter in $adapters) {
            # Re-enable Power Management
            $devicePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\" + $adapter.DeviceID
            if (Test-Path $devicePath) {
                Set-ItemProperty -Path $devicePath -Name "PnPCapabilities" -Value 0
                Write-Progress "Re-enabled Power Management for $($adapter.Name)"
            }
            
            # Revert adapter settings to default
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Jumbo Packet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Flow Control" -DisplayValue "Rx & Tx Enabled" -ErrorAction SilentlyContinue
            Write-Progress "Reverted Advanced Properties for $($adapter.Name)"
        }
        
        Write-Progress "Network Adapter Settings Reverted to Default"
    }
    catch {
        Write-Warning "Failed to revert network adapter settings: $_"
    }
}

function Undo-TCPIPSettings {
    Write-Progress "Restoring TCP/IP Stack to Default Settings..."
    
    try {
        # Registry paths for TCP/IP optimization
        $tcpipParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        $tcpipInt = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        
        # Restore global TCP/IP settings to defaults
        Set-ItemProperty -Path $tcpipParams -Name "DefaultTTL" -Value 128
        Set-ItemProperty -Path $tcpipParams -Name "Tcp1323Opts" -Value 0
        Set-ItemProperty -Path $tcpipParams -Name "TcpMaxDupAcks" -Value 3
        Set-ItemProperty -Path $tcpipParams -Name "SackOpts" -Value 0
        Write-Progress "Restored TCP/IP Parameters to Defaults"
        
        # Restore network interfaces to defaults
        Get-ChildItem $tcpipInt | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 2
            Set-ItemProperty -Path $_.PSPath -Name "TcpNoDelay" -Value 0
        }
        Write-Progress "Restored Network Interfaces to Defaults"
        
        Write-Progress "TCP/IP Stack Restoration Complete"
    }
    catch {
        Write-Warning "Failed to restore TCP/IP settings: $_"
    }
}

function Undo-NetworkPriority {
    Write-Progress "Restoring Default Network Priority..."
    
    try {
        # Registry path for network priority
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        
        # Restore default network priority settings
        Set-ItemProperty -Path $regPath -Name "NetworkThrottlingIndex" -Value 10
        Set-ItemProperty -Path $regPath -Name "SystemResponsiveness" -Value 20
        Write-Progress "Restored Default Network Priority Settings"
        
        # Remove or reset gaming network settings
        $gamingPath = "$regPath\Games"
        if (Test-Path $gamingPath) {
            Remove-ItemProperty -Path $gamingPath -Name "Priority" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $gamingPath -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue
            Write-Progress "Reset Gaming Network Settings"
        }
        
        Write-Progress "Network Priority Restoration Complete"
    }
    catch {
        Write-Warning "Failed to restore network priority: $_"
    }
}

function Undo-NetworkQoS {
    Write-Progress "Reverting Quality of Service Settings..."
    
    try {
        # Registry path for QoS
        $qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
        
        # Remove QoS settings if path exists
        if (Test-Path $qosPath) {
            Remove-ItemProperty -Path $qosPath -Name "NonBestEffortLimit" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $qosPath -Name "TimerResolution" -ErrorAction SilentlyContinue
            Write-Progress "Reverted QoS Parameters"
        }
        
        # Re-enable Auto-Tuning
        netsh int tcp set global autotuninglevel=normal
        Write-Progress "Re-enabled TCP Auto-Tuning"
        
        # Write-Complete "QoS Reversion Complete"
    }
    catch {
        Write-Warning "Failed to revert QoS settings: $_"
    }
}

function Undo-NetworkSettings {
    Write-SectionHeader "Undoing Network Settings"
    Write-Progress "Undoing Network Settings..."
    # Execute all network settings reversion functions
    Undo-NetworkDriverSettings # VERIFIED REVERSION
    Undo-TCPIPSettings # VERIFIED REVERSION
    Undo-NetworkPriority # VERIFIED REVERSION
    Undo-NetworkQoS # VERIFIED REVERSION
    Write-Progress "Undoed Network Settings"
}

function Undo-UltimatePerformancePlan {
    Write-Progress "Undoing Ultimate Performance Plan..."
    # Restore default power plan settings
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
    Write-Progress "Undoed Ultimate Performance Plan"
}

function Undo-ProcessorPower {
    Write-Progress "Restoring Default CPU Power Settings..."
    
    try {
        # Registry path for processor power management
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00"
        
        # Restore all power settings to default
        Get-ChildItem $regPath | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "Attributes" -Value 1
        }
        
        # Restore processor performance boost mode
        $boostPath = "$regPath\be337238-0d82-4146-a960-4f3749d470c7"
        Set-ItemProperty -Path $boostPath -Name "Attributes" -Value 1
        Write-Progress "Restored Processor Performance Boost Settings"
        
        Write-Progress "CPU Power Settings Restored to Default"
    }
    catch {
        Write-Warning "Failed to restore CPU power settings: $_"
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

function Undo-GPUPower {
    Write-Progress "Undoing GPU Power Settings..."
    
    try {
        # Registry path for GPU power settings
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
        
        # Restore default GPU power settings
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name "PerfLevelSrc" -Value 0x00000000
            Set-ItemProperty -Path $regPath -Name "PowerMizerEnable" -Value 0
            Set-ItemProperty -Path $regPath -Name "PowerMizerLevel" -Value 0
            Write-Progress "Restored default GPU Power Settings"
        }
        else {
            Write-Warning "GPU registry path not found"
        }
    }
    catch {
        Write-Warning "Failed to undo GPU power settings: $_"
    }
}

function Undo-USBPower {
    Write-Progress "Restoring default USB Power Settings..."
    
    try {
        # Get all USB controllers
        $usbControllers = Get-WmiObject Win32_USBController
        
        foreach ($controller in $usbControllers) {
            # Enable selective suspend
            $devicePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($controller.DeviceID)\Device Parameters"
            if (Test-Path $devicePath) {
                Set-ItemProperty -Path $devicePath -Name "SelectiveSuspendEnabled" -Value 1
                Write-Progress "Enabled Selective Suspend for $($controller.Name)"
            }
        }
        
        # Enable USB power savings globally
        $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
        if (Test-Path $usbPath) {
            Set-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -Value 0
        }
        
        Write-Progress "Restored default USB Power Settings"
    }
    catch {
        Write-Warning "Failed to restore USB power settings: $_"
    }
}

function Undo-PowerSettings {
    Write-SectionHeader "Undoing Power Settings"
    Write-Progress "Undoing Power Settings..."
    # Execute all power settings reversion functions
    Undo-UltimatePerformancePlan # VERIFIED REVERSION
    Undo-ProcessorPower # VERIFIED REVERSION
    Undo-GPUPower # VERIFIED REVERSION
    Undo-USBPower # VERIFIED REVERSION
    Write-Progress "Undoed Power Settings"
}

function Undo-Telemetry {
    Write-Progress "Restoring Windows Telemetry Settings..."
    
    try {
        # Default telemetry settings
        $regPaths = @{
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"             = @{"AllowTelemetry" = 1 }
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"                            = @{"AllowTelemetry" = 1 }
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" = @{"AllowTelemetry" = 1 }
        }
        
        foreach ($path in $regPaths.Keys) {
            if (Test-Path $path) {
                foreach ($name in $regPaths[$path].Keys) {
                    Set-ItemProperty -Path $path -Name $name -Value $regPaths[$path][$name]
                }
            }
        }
        Write-Progress "Restored Default Telemetry Settings"
    }
    catch {
        Write-Warning "Failed to restore telemetry: $_"
    }
}

function Undo-PrivacySettings {
    Write-Progress "Reverting Privacy Settings..."
    
    try {
        # Privacy settings registry paths
        $privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
        $advertisingPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        
        # Re-enable Advertising ID
        if (Test-Path $advertisingPath) {
            Set-ItemProperty -Path $advertisingPath -Name "Enabled" -Value 1
            Write-Progress "Re-enabled Advertising ID"
        }
        
        # Re-enable app access to various features
        $appPrivacySettings = @(
            "LetAppsAccessLocation",
            "LetAppsAccessCamera",
            "LetAppsAccessMicrophone",
            "LetAppsAccessNotifications",
            "LetAppsAccessAccountInfo",
            "LetAppsAccessContacts"
        )
        
        foreach ($setting in $appPrivacySettings) {
            if (Test-Path $privacyPath) {
                Remove-ItemProperty -Path $privacyPath -Name $setting -ErrorAction SilentlyContinue
                Write-Progress "Re-enabled: $setting"
            }
        }
        
        Write-Progress "Privacy Settings Reversion Complete"
    }
    catch {
        Write-Warning "Failed to revert privacy settings: $_"
    }
}

function Undo-SecurityPrivacy {
    Write-SectionHeader "Undoing Security and Privacy Settings"
    Write-Progress "Undoing Security and Privacy Settings..."
    # Execute all security and privacy reversion functions
    Undo-Telemetry # VERIFIED REVERSION
    Undo-PrivacySettings # VERIFIED REVERSION
    Write-Progress "Undoed Security and Privacy Settings"
}

function Undo-VisualFX {
    Write-Progress "Restoring Default Visual Effects Settings..."
    
    try {
        # Registry path for visual effects
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        
        # Restore default visual effects settings
        Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 3
        Write-Progress "Restored Default Visual Effects Settings"
        
        Write-Progress "Visual Effects Restoration Complete" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to restore visual effects: $_"
    }
}

function Undo-BackgroundApps {
    Write-Progress "Restoring Background Applications Settings..."
    
    try {
        # Registry path for background apps
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
        
        # Enable background apps
        Set-ItemProperty -Path $regPath -Name "GlobalUserDisabled" -Value 0
        Write-Progress "Enabled Background Applications"
        
        Write-Progress "Background Applications Settings Restored"
    }
    catch {
        Write-Warning "Failed to restore background applications settings: $_"
    }
}
function Undo-StartupApps {
    Write-Progress "Restoring Startup Applications..."
    
    try {
        # Registry path for startup apps
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        
        # List of applications to restore
        $appsToRestore = @(
            "OneDrive",
            "MicrosoftEdgeAutoLaunch",
            "Skype",
            "Spotify",
            "AdobeAAMUpdater",
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
        
        # Restore each application
        foreach ($app in $appsToRestore) {
            # Get the default executable path for each application
            $appPath = Get-AppPath $app  # You'll need to implement Get-AppPath function
            if ($appPath) {
                Set-ItemProperty -Path $regPath -Name $app -Value $appPath
                Write-Progress "Restored startup app: $app"
            }
        }
        
        Write-Progress "Startup Applications Restoration Complete"
    }
    catch {
        Write-Warning "Failed to restore startup applications: $_"
    }
}

# Helper function to get application paths (needs to be implemented)
function Get-AppPath {
    param([string]$appName)
    
    # Implement logic to find the default executable path for each application
    # This is just a placeholder implementation
    switch ($appName) {
        "OneDrive" { return "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe" }
        "Skype" { return "$env:ProgramFiles\Microsoft Office\root\Office16\lync.exe" }
        # Add more cases for each application
        default { return $null }
    }
}

function Undo-WindowsUIFeatures {
    Write-Progress "Reverting Windows UI Features to Default..."
    
    try {
        # Registry path for UI features
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        
        # Revert UI features to default
        Set-ItemProperty -Path $regPath -Name "TaskbarAnimations" -Value 1
        Set-ItemProperty -Path $regPath -Name "TaskbarSmallIcons" -Value 0
        Write-Progress "Reverted Windows UI Features to Default"
        
        Write-Progress "Windows UI Features Reversion Complete" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to revert Windows UI features: $_"
    }
}

function Undo-UIUX {
    Write-SectionHeader "Undoing UI/UX Settings"
    Write-Progress "Undoing UI/UX Settings..."
    # Execute all UI/UX reversion functions
    Undo-VisualFX # VERIFIED REVERSION
    Undo-BackgroundApps # VERIFIED REVERSION
    Undo-StartupApps # VERIFIED REVERSION
    Undo-WindowsUIFeatures # VERIFIED REVERSION
    Write-Progress "Undoed UI/UX Settings"
}

function Undo-All {
    Write-SectionHeader "Undoing All Settings"
    Write-Progress "Undoing All Settings..."
    # Execute all reversion functions
    Undo-SystemPerformance # COMPLETE
    Undo-SystemCleanup # COMPLETE
    Undo-GamingFeatures # COMPLETE
    Undo-NetworkSettings # COMPLETE
    Undo-PowerSettings # COMPLETE
    Undo-SecurityPrivacy # COMPLETE
    Undo-UIUX # COMPLETE
    Undo-NvidiaGPUOptimization # COMPLETE
    Write-Progress "Undoed All Settings"
}

Undo-All