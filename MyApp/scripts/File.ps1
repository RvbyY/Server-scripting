.\smbv1checker.ps1

function listAdminUsers
{
    $admins = Get-ADGroupMember -Identity "Administrators" | Select-Object Name, SamAccountName

    "=== Admin Users (Domain) ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin.Name)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

function listDisabledUsers
{
    $admins = Get-ADGroupMember -Identity "Administrators" | Where-Object { $_.Enabled -eq $false } | Select-Object Name, SamAccountName

    "=== Disabled Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin.Name)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

function ServiceServer
{
    $services = Get-Service | Where-Object { $_.DisplayName -like '*Server*' -or $_.DisplayName -like '*File*' }

    "=== Server Services ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($service in $services) {
        "$($service.Name)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

function CheckPrintersStatus
{
    $ports = Get-Printer | Select-Object Name, PortName
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

function SMBAuthRateLimiter
{
    $rateLimiter = Get-smbServerConfiguration | Format-List -Property invalidAuthenticationDelayTimeInMs

    "=== SMB authentication rate limiter ===" | Out-file -Filepath ".\info.txt" -Append -Encoding utf8
    "$($rateLimiter)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
}

function FileMain
{
    listAdminUsers
    listDisabledUsers
    ServiceServer
    CheckPrintersStatus
    SMBAuthRateLimiter
}

FileMain
