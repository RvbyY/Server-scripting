.\smbv1checker.ps1

function ListUsers
{
    $admins = Get-localGroupMember -Group "Administrators" | Select-Object Name

    "=== Admins Users ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    }
}

function DisabledAdminUser
{
    $admins = Get-LocalUser | Where-Object { $_.Enabled -eq $false -and $_.Name -like "*admin*" }

    "=== Disabled Admin Users ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    "$($admins)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
}

function InstalledServicesList
{
    $services = Get-Service | Sort-Object DisplayName

    "=== Installed Service ===" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    "$($services)" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
}

function CheckLinePrintersStatus
{
    $ports = Get-Printer | Select-Object Name, PortName
    $value = "false"

    foreach ($port in $ports) {
        if ($port.PortName -eq '*LPR*') {
            "LPR is active" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
            $value = "true"
        } elseif ($port.PortName -eq '*LPD*') {
            "LPD is active" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
            $value = "true"
        }
    }
    if ($value -eq "false") {
        "LPR and LPD aren't used" | Out-File -Filepath ".\info.txt" -Append -Encoding utf8
    }
}

function PrintMain
{
    ListUsers
    DisabledAdminUser
    InstalledServicesList
    CheckLinePrintersStatus
}

PrintMain
