$Current = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$Current.name



#Impersonation
[System.Security.Principal.WindowsIdentity]::Impersonate
Get-ChildItem HKLM:\SECURITY
$MachineToken = Get-MachineToken 
Set-Impersonation -Token $MachineToken
Get-ChildItem HKLM:\SECURITY
Set-Impersonation

Invoke-DbaQuery -SqlInstance CM1 -Database ConfigMgr_chq -Query 'select suser_name()'
$Lab = get-Credential -UserName 'corp\labadmin' -Message 'lab admin'
Set-impersonation -credential $lab 
Invoke-DbaQuery -SqlInstance CM1 -Database ConfigMgr_chq -Query 'select suser_name()'
Set-Impersonation 



#working Cross domain
ping gw1
Get-ChildItem -Path \\gw1\c$
$Lab = get-Credential -UserName 'corp\labadmin' -Message 'lab admin'
Set-impersonation -credential $lab -netonly



<#
Pros
1 - Flexibility
2 - Cross domain

cons
1 - Impersonation only works with current thread
2 - does not pass to child processes
3 - whoami and some other features get weird
4 - You have to be aware of your environment 
    (if your thread also reaches out to other systems, those can accidentally be impacted)
#>