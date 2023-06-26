$labname = 'jeademo'
$domainName = 'contoso.com'
$imageUI = 'Windows Server 2022 Datacenter (Desktop Experience)'
$demoBaseFolder = Split-Path $PSScriptRoot

$modules = @(
	'String'
	'PSFramework'
	'PSUtil'
	'PSModuleDevelopment'
)

#region Default Lab Setup
New-LabDefinition -Name $labname -DefaultVirtualizationEngine HyperV

$parameters = @{
	Memory		    = 2GB
	OperatingSystem = $imageUI
	DomainName	    = $domainName
}

Add-LabMachineDefinition -Name JeaDC -Roles RootDC @parameters
Add-LabMachineDefinition -Name JeaAdminHost @parameters
Add-LabMachineDefinition -Name JeaRDP @parameters

Install-Lab

Install-LabWindowsFeature -ComputerName JeaAdminHost -FeatureName NET-Framework-Core, NET-Non-HTTP-Activ, GPMC, RSAT-AD-Tools

$allVMs = Get-LabVM

Invoke-LabCommand -ActivityName "Setting Keyboard Layout" -ComputerName $allVMs -ScriptBlock {
	Set-WinUserLanguageList -LanguageList 'de-de' -Confirm:$false -Force
	$null = New-Item -Path "C:\" -Name "Scripts" -ItemType Directory -Force
}
#endregion Default Lab Setup

#region PowerShell Resources
# Deploy Modules
$tempFolder = New-Item -Path $env:temp -Name "Jea-$(Get-Random -Minimum 1000 -Maximum 9999)" -ItemType Directory -Force
foreach ($module in $modules) { Save-Module $module -Path $tempFolder.FullName -Repository PSGallery }
foreach ($item in (Get-ChildItem -Path $tempFolder.FullName))
{
	Copy-LabFileItem -Path $item.FullName -DestinationFolderPath "C:\Program Files\WindowsPowerShell\Modules\" -ComputerName $allVMs
}
Remove-Item -Path $tempFolder.FullName -Recurse -Force
#endregion PowerShell Resources

#region Lab
# Deploy AD Configuration
Invoke-LabCommand -ComputerName JeaDC -ActivityName "Prepare OU Structure and move computer accounts" -ScriptBlock {
	$baseOU = New-ADOrganizationalUnit -Name Contoso -Path 'DC=contoso,DC=com' -PassThru
	New-ADOrganizationalUnit -Name Clients -Path $baseOU
	$servers = New-ADOrganizationalUnit -Name Servers -Path $baseOU -PassThru
	$users = New-ADOrganizationalUnit -Name Users -Path $baseOU -PassThru
	New-ADOrganizationalUnit -Name Groups -Path $baseOU
	New-ADUser -Name Max.Mustermann -SamAccountName Max.Mustermann -UserPrincipalName Max.Mustermann@contoso.com -AccountPassword ("Test1234"|ConvertTo-SecureString -AsPlainText -Force) -Path $users -Enabled $true

	'JeaAdminHost', 'JeaRDP' | Get-ADComputer | Move-ADObject -TargetPath $servers
}

Start-Sleep -Seconds 5
#endregion Lab

Write-Host "Waiting for 120 Seconds to allow processes to finish"
Start-Sleep -Seconds 120
Restart-LabVM -ComputerName $allVMs