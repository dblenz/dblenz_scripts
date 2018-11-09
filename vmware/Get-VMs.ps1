#Variables
$creds = Get-Credential
$viserver = Read-Host -Prompt "Which vCenter server?"

connect-viserver $viserver -Credential $creds

Get-VM