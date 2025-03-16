if (!(Get-MgContext)) {Connect-MgGraph -Environment USGov -NoWelcome -TenantId (Read-Host -Prompt "Tenant Name")}

function Write-HostWithTimestamp ([string]$Message) {Write-Host ("{0}`t{1}" -f [datetime]::Now.ToString("yyyyMMdd HH:mm:ss"), $Message)}
function Get-ADDSExpiresOn ([string]$upn) {$ExpiresOn=([datetime]::FromFileTime(([adsisearcher]("(userprincipalname={0})" -f $upn)).FindOne().Properties['accountexpires'][0])); if(!($ExpiresOn -lt "1/1/1700")) {$ExpiresOn.ToString("MM/dd/yyyy")}}
function Get-LicenseAssignmentStatus ([array]$LicenseAssignmentStates) {($LicenseAssignmentStates | Where-Object {$_.SkuId -eq $subscribedSku.SkuId} | ForEach-Object {if ($_.AssignedByGroup) {$mgLicensedGroupsHash[$_.AssignedByGroup]} else {"Direct"}} | Sort-Object) -join "; "}
function Join-ServicePlanArray ([array]$ServicePlans) {$outputArray = @(); $ServicePlans | ForEach-Object {$outputArray += if (([array]::IndexOf($ServicePlans, $_)+1) % 3 -eq 0) {("{0}`n" -f $_)} else {"{0}; " -f $_}}; $outputArray -join '';}

Write-HostWithTimestamp "Getting Subscribed SKU List"
if (!(Get-MgContext)) {throw "Run Connect-MgGraph prior to executing this script.`n`tEx: Connect-MgGraph -Environment USGov -TenantId afs.com"}
$subscribedSkus = Get-MgSubscribedSku -Property SkuId, SkuPartNumber, AppliesTo, CapabilityStatus, ServicePlans, ConsumedUnits `
    | Select-Object SkuId, SkuPartNumber, AppliesTo, CapabilityStatus, ConsumedUnits, @{n="ServicePlans";e={Join-ServicePlanArray -ServicePlans ($_.ServicePlans | ForEach-Object {$_.ServicePlanName} | Sort-Object)}}
$subscribedSku = $subscribedSkus | Select-Object SkuId, SkuPartNumber, AppliesTo, CapabilityStatus, ConsumedUnits, ServicePlans | Out-GridView -Title "Select a Sku" -OutputMode Single
$subscribedSku | Format-List -Property SkuPartNumber, ConsumedUnits, ServicePlans

if ([string]::IsNullOrEmpty($subscribedSku)) {Throw "No Sku selected"}
$skuIdFilter = ("assignedLicenses/any(s:s/skuId eq {0})" -f $subscribedSku.SkuId)

Write-HostWithTimestamp "Retrieve all licensed groups"
$mgLicensesGroups = Get-MgGroup -All -Property Id, DisplayName, AssignedLicenses -Filter $skuIdFilter | Select-Object Id, DisplayName
$mgLicensedGroupsHash = @{}
$mgLicensesGroups | ForEach-Object {$mgLicensedGroupsHash[$_.Id] = $_.DisplayName}

Write-HostWithTimestamp "Retrieve all licensed users"
$mgLicensedUsers = Get-MgUser -All -Property Id, AccountEnabled, DisplayName, UserPrincipalName, Mail, Department, LicenseAssignmentStates -Filter $skuIdFilter
Write-HostWithTimestamp ("Retrieved {0} licensed users" -f $mgLicensedUsers.Count)

Write-HostWithTimestamp "Format user license details and Retrieve Expiration from AD"
$mgUsersWithLicenseDetails = $mgLicensedUsers | Select-Object Id, AccountEnabled, DisplayName, UserPrincipalName, Mail, Department `
    , @{n="LicenseAssignmentStatus";e={Get-LicenseAssignmentStatus -LicenseAssignmentStates $_.LicenseAssignmentStates}}

Write-HostWithTimestamp "Display Users List"
$mgUsersWithLicenseDetails | Select-Object Id, AccountEnabled, DisplayName, UserPrincipalName, Mail, Department, LicenseAssignmentStatus | Out-GridView -Title $subscribedSku.SkuPartNumber
