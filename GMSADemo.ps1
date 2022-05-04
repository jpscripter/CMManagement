$Path = 'OU=Groups,OU=CORP,DC=corp,DC=contoso,DC=com'
$adGroup = New-ADGroup -Name GMSATest -GroupCategory Security -Path $Path -GroupScope Global -PassThru
Add-ADGroupMember -Identity GMSATest -Members $env:USERNAME
klist.exe purge # may refresh ad groups. If it doesnt logout and relogin.
Try{
    $Path = 'OU=SERVICE ACCOUNTS,OU=CORP,DC=corp,DC=contoso,DC=com'
    $MyGMSA = New-ADServiceAccount -Name MyGMSA -Path $path -PrincipalsAllowedToRetrieveManagedPassword $adGroup -DNSHostName MyGMSA -Passthru
}Catch{
    Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))
    $MyGMSA = New-ADServiceAccount -Name MyGMSA -Path $path -PrincipalsAllowedToRetrieveManagedPassword $adGroup -DNSHostName MyGMSA -Passthru
}



#Get GMSA
Import-module RunAsImpersonation -Force
$GMSA = Get-GMSACredential -Identity MyGMSA
Test-Credential $gmsa
$GMSA.GetNetworkCredential()
$GMSA.GetNetworkCredential().password

Get-WmiObject -Class win32_computersystem -ComputerName cm1 -Credential $gmsa
invoke-command -ScriptBlock {whoami} -ComputerName cm1 -Credential $GMSA
<#
1- 
#>