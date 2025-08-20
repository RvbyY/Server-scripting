.\smbv1checker.ps1

function AdminList
{
    $admins = Get-LocalGroupMember -Group "Administrators" | Select-Object Name

    "=== Admin Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

function AdminDisabled
{
    $admins = Get-LocalGroupMember -Group "Administrators" | Where-Object { $_.Enabled -eq $false } | Select-Object Name

    "=== Disabled Admin Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "($admin)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    }
}

function ServicesList
{
    $services = Get-Service | Where-Object { $_.DisplayName -like '*Server*' -or $_.DisplayName -like '*File*' } | Select-Object Name

    "=== Installed Services List ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($service in $services) {
        "$($service)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

function PrintersStatus
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

function RDSMain
{
    AdminList
    AdminDisabled
    ServicesList
    PrintersStatus
}

RDSMain
