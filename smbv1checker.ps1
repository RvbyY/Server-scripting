<#
.DESCRIPTION
check if smbv1 is in the device to disable it
#>
function IsSmbv1
{
    $os = (Get-CimInstance Win32_OperatingSystem).Caption

    Write-Host "Detected OS: $os"
    if ($os -like "*Windows*") {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
        if ($feature.State -eq 'Enabled') {
            Write-Host "Disabling SMBv1..."
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
        } else {
            Write-Host "SMBv1 already disabled."
        }
    } else {
        Write-Host "This script only works on Windows. Current OS is not supported." -ForegroundColor Red
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
    $lastBoot = $os.$lastBootUpTime

    Write-Output "Computer Name     : $csName"
    Write-Output "Last Boot Time    : $lastBoot"
    $uptime = (Get-Date) - $lastBoot
    Write-Output "System Uptime     : $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
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

function IsFirewallOn
{

}

function IsAntivirusOn
{

}

<#
.DESCRIPTION
main function that lead all the script
#>
function main
{
    IsSmbv1
    IsUserAdmin
    TestUserCredentials
    Set-Content -Path .\info.txt -Value $null
    GetAdminUsers
    DisabledadminCpte
}

main
