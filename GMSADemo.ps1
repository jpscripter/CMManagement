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
pros
1- troubleshooting 
2- Strong passwords with 30 day rotation
3- microsoft native
4- 

cons
1- Usually doesnt work with Web requests using basic auth
2- no interactive logins

#>