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
        }
        else {
            Write-Host "The password of UserName $($username) in Computer $($computer) does not is correct" -BackgroundColor Red
        }
    }
}

<#
.DESCRIPTION
Check Spooler
#>
function CheckSpooler
{
    $PrintNames = Get-ADComputer -Filter { ServicePrincipalName -like "PRINT/*" }

    "=== Disabled Spoolers ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($PrintName in $PrintNames) {
        $Spooler = Get-Service -Name Spooler -ComputerName $PrintName.Name -ErrorAction silentlyContinue
        if ($Spooler.StartType -eq 'Disabled') {
            "$($PrintName.Name): $($Spooler.Status)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

<#
.DESCRIPTION
Check LSA
#>
function CheckLSA
{
    $infos = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Lsa"

    "=== LSA ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($infos.EnabledLsa)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Check if Kerberos is disbled
#>
function CheckKerberos
{
    $users = Get-LocalUser

    "=== Kerberos ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if ($users) {
        foreach ($user in $users) {
            $kerberos = Get-ADUser -Identity $user -Properties AuthenticationPolicies
            "$($user): $($kerberos)" | Out-File -FilePath -Append utf8
        }
    }
}

<#
.DESCRIPTION
List installed service
#>
function listInstalledService
{
    $Services = Get-Service

    "=== Installed Service ===" | out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($Services)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Check if LAPS is enabled
#>
function CheckLAPS
{
    $computer = Get-ComputerInfo

    "=== LAPS ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    $laps = Get-ADComputer -Identity $computer.CSName -Properties ms-MCS-AdmPwd, ms-MCS-AdmPwdExpirationTime
    "$($laps)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Test if LAPS Password exist
#>
function GetLAPS
{
    "=== LAPS Password ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    if (Get-ADComputer -Identity "lapsAD2" -ErrorAction silentlyContinue) {
        $lapsPwd = Get-ADComputer -Identity "lapsAD2" -AsPlainText
        "The Password is enable: $($lapsPwd)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    } else {
        "LAPS password disable"
    }
}

<#
.DESCRIPTION
Hide the username of the session
#>
function HideUsername
{
    $currentUser = Get-LocalUser | Where-Object {$_.Name -eq $env:USERNAME}

    if ($currentUser) {
        Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name $currentUser.Name -Value 1
    }
}

<#
.DESCRIPTION
Display SMB authentication time out/rate limiter#>
function SMBAuthTimeOut
{
    $rateLimiter = Get-smbServerConfiguration | Format-List -Property invalidAuthenticationDelayTimeInMs

    "=== SMB authentication rate limiter ===" | Out-file -Filepath ".\info.txt" -Append -Encoding utf8
    "$($rateLimiter)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
}

<#
.DESCRIPTION
Main function of active directory script
#>
function ADMain
{
    TestUserCredentials
    CheckSpooler
    CheckLSA
    CheckKerberos
    listInstalledService
    CheckLAPS
    GetLAPS
}

ADMain
