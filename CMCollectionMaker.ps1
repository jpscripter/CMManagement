
$MinCount = 3
$Folder = 'Models'
$NamingStandard = ''

Import-module SQLPS
$SiteCode = "CHQ" # Site code 
$ProviderMachineName = "CM1.corp.contoso.com" # SMS Provider machine name
$initParams = @{}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

$Query = "
WITH ModelCTE As (
	Select Manufacturer0, MODEL0 , Count(*) as 'DeviceCount', 'v_GS_COMPUTER_SYSTEM' 'View'
		from v_GS_COMPUTER_SYSTEM
		Where Manufacturer0 not in ('LENOVO','HP')
		Group By Manufacturer0, Model0 

	Union All

	Select Vendor0, Version0 , Count(*) as 'DeviceCount', 'v_GS_COMPUTER_SYSTEM_PRODUCT' 'View'
		from v_GS_COMPUTER_SYSTEM_PRODUCT
		Where Vendor0 in ('LENOVO','HP')
		Group By Vendor0, Version0 
)


Select Manufacturer0, MODEL0 , [DeviceCount], [View]
from ModelCTE
where  DeviceCount > $MinCount"

$NeedsEnforcementDeployments = Invoke-Sqlcmd -ServerInstance CM1 -Database ConfigMgr_CHQ -Query $query


