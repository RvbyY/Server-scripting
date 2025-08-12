.\smbv1checker.ps1

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

function CheckSpooler
{
    $PrintNames = Get-ADComputer -Filter {ServicePrincipalName -like "PRINT/*"}

    "=== Disabled Spoolers ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($PrintName in $PrintNames) {
        $Spooler = Get-Service -Name Spooler -ComputerName $PrintName.Name -ErrorAction silentlyContinue
        if ($Spooler.StartType -eq 'Disabled') {
            "$($PrintName.Name): $($Spooler.Status)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
        }
    }
}

function CheckLSA
{
    $infos = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Lsa"

    "=== LSA ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    "$($infos.EnabledLsa)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
}

function CheckNTLM
{
}