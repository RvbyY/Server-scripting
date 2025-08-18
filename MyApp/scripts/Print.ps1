.\smbv1checker.ps1

function ListUsers
{
    $admins = Get-localGroupMember -Group "Administrators" | Select-Object Name

    "=== Admins Users ===" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    foreach ($admin in $admins) {
        "$($admin)" | Out-File -FilePath ".\info.txt" -Append -Encoding utf8
    }
}