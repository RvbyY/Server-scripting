.\smbv1checker.ps1

<#
.DESCRIPTION
List domain admin users
#>
function listAdminUsers
{
    $admins = Get-LocalGroupMember -Group "Administrators" | Select-Object Name

    "=== Admin Users (Domain) ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
List disabled admin users
#>
function listDisabledUsers
{
    $admins = Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Enabled -eq $false } | Select-Object Name

    "=== Disabled Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
List server installed service
#>
function ServiceServer
{
    $services = Get-Service | Where-Object { $_.DisplayName -like '*Server*' -or $_.DisplayName -like '*File*' } | Select-Object Name

    "=== Server Services ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($service in $services) {
        "$($service)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
Check if line printers are enable and their status
#>
function CheckPrintersStatus
{
    $ports = Get-Printer | Select-Object PortName
    $value = "false"

    foreach ($port in $ports) {
        if ($port.PortName -like '*LPR*') {
            "LPR is active" | Out-File -FilePath "info.txt" -Append -Encoding utf8
            $value = "true"
        } elseif ($port.PortName -like '*LPD*') {
            "LPD is active" | Out-File -FilePath "info.txt" -Append -Encoding utf8
            $value = "true"
        }
    }
    if ($value -eq "false") {
        "LPR and LPD aren't used" | Out-File -FilePath "info.txt" -Append -Encoding utf8
    }
}

<#
.DESCRIPTION
Check SMB authentication rate limiter
#>
function SMBAuthRateLimiter
{
    $rateLimiter = Get-smbServerConfiguration | Format-List -Property invalidAuthenticationDelayTimeInMs

    "=== SMB authentication rate limiter ===" | Out-file -Filepath ".\info.txt" -Append -Encoding utf8
    "$($rateLimiter)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
}

<#
File server script main function
#>
function FileMain
{
    listAdminUsers
    listDisabledUsers
    ServiceServer
    CheckPrintersStatus
    SMBAuthRateLimiter
}

FileMain
