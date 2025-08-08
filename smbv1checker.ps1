<#
.DESCRIPTION
check if smbv1 is in the device to disable it
#>
function IsSmbv1 {
    $os = (Get-CimInstance Win32_OperatingSystem).Caption

    "=== System version ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "Detected OS: $os" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($os -like "*Windows*") {
        "=== SmbV1 Check ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
        if ($feature.State -eq 'Enabled') {
            "Disabling SMBv1..." | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
        } else {
            "SMBv1 already disabled." | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    } else {
        "This script only works on Windows. Current OS is not supported." | Out-File -FilePath ".\info.txt" -Append -Encoding utf8 -Force
    }
}

<#
.DESCRIPTION
Show the last reboot time
#>
function rebootTime
{
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $csName = $os.CSName
    $lastBoot = $os.LastBootUpTime

    "=== Last reboot time ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "Computer Name     : $csName" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "Last Boot Time    : $lastBoot" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    $uptime = (Get-Date) - $lastBoot
    "System Uptime     : $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Display admin group's users
#>
function IsUserAdmin
{
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

<#
.DESCRIPTION
Test Local User Account Credentials
#>
function TestUserCredentials
{
    Write-Verbose "Prompting for password"
    $pswd = Read-Host "Type password -- VERIFY BEFORE CLICKING RETURN!!!"  -assecurestring
    $decodedpswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pswd))

    Foreach ($computer in $computers) {
        $username = "variable with local admin user"
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $computer)
        if ($obj.ValidateCredentials($username, $decodedpswd) -eq $True) {
            Write-Host "The password of UserName $($username) in Computer $($computer) it is correct" -BackgroundColor Green
        } else {
            Write-Host "The password of UserName $($username) in Computer $($computer) does not is correct" -BackgroundColor Red
        }
    }
}

<#
.DESCRIPTION
list all admin users of the machine
#>
function GetAdminUsers
{
    $groups = Get-LocalGroupMember -Group "Administrators"
    $output = "=== Administrators on this device ==="

    $output | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($group in $groups) {
        $outputString = "-> $($group.Name) [$($group.ObjectClass)]"
        $outputString | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
list all disabled admin accounts
#>
function DisabledadminCpte
{
    $admins = Get-LocalGroupMember -Group "Administrators"
    $output = "=== Disabled administrators users ==="

    $output | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        if ($admin.ObjectClass -eq "User") {
            $username = ($admin.Name -split '\\')[-1]
            $rights = Get-LocalUser -Name $username
            if ($rights.Enabled -eq $false) {
                $outputString = "-> $($username) [$($admin.ObjectClass)]"
                $outputString | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
            }
        }
    }
}

<#
.DESCRIPTION
check and display is firewall on
#>
function IsFirewallOn
{
    $profiles = Get-NetFirewallProfile
    $output = "=== Firewall Status ==="

    $output | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($profiles) {
        foreach ($profile_u in $profiles) {
            $outputString = "$($profile_u.name) -> $($profile_u.Enabled)"
            $outputString | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
display device antivirus
#>
function IsAntivirusOn
{
    $Antis = Get-CimInstance -ClassName Win32_Product | Where-Object { $_.Name -like "*antivirus*" }
    $output ="=== Antivirus ==="

    $output | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($Antis) {
        foreach ($Anti in $Antis) {
            "$($Anti.DisplayName)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    } else {
        "No antivirus products found." | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
display users last login
#>
function GetUserLastLogin
{
    $users = Get-LocalUser

    "=== Last Login ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($users) {
        foreach ($user in $users) {
            "$($user.Name) -> $($user.LastLogon)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
display users last pwd set
#>
function GetUserLastPwdSet
{
    $users = Get-LocalUser

    "=== Last pwd set ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($users) {
        foreach ($user in $users) {
            "$($user.Name) -> $($user.LastPasswordSet)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
display bitlocker w/ their status
#>
function IsBitlockerEnable
{
    $users = Get-BitLockerVolume

    "=== Bitlockers ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($users) {
        foreach ($user in $users) {
            "$($user.MountPoint) status: $($user.ProtectionStatus)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
list powershell drives
#>
function ListPsDrive
{
    $drives = Get-PSDrive -PSProvider FileSystem

    "=== Drives ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($drives) {
        foreach ($drive in $drives) {
            "$($drive.Name): free space (GB): $([math]::round($drive.Free / 1GB, 2))" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
display vvs writers
#>
function DisplayVSS
{
    $writers = vssadmin list writers

    "=== VSS ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($writer in $writers) {
        ""
    }
}

<#
.DESCRIPTION
Get processors numbers
#>
function GetProcessNbr
{
    $processors = Get-WinObject -Class Win32_Processor

    "=== Process Number ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($processors.Count)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
Get logical processor
#>
function GetLogicalProcessor
{
    $processors = Get-WinObject -Class Win32_PerfFormattedData_PerfOS_System

    "=== Logical Process Number ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($process in $processors) {
        "$($process.NumberOfLogicalProcessors)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
main function that lead all the script
#>
function main
{
    Set-Content -Path .\info.txt -Value $null
    IsSmbv1
    IsUserAdmin
    rebootTime
    TestUserCredentials
    GetAdminUsers
    DisabledadminCpte
    IsFirewallOn
    IsAntivirusOn
    GetUserLastLogin
    GetUserLastPwdSet
    IsBitlockerEnable
    ListPsDrive
    GetProcessNbr
}

main
