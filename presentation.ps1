# failsafe
return

$presentationRoot = 'C:\Presentation'

#region Utility Functions
function New-JeaLabGroup {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name
	)

	$rootOU = 'OU=Groups,OU=Contoso,DC=contoso,DC=com'
	$newGroup = New-ADGroup -Name $Name -Path $rootOU -Description 'Test Group for a JEA Demo' -PassThru
	Add-ADGroupMember -Identity $newGroup -Members ([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)
	$null = klist purge
	Write-PSFMessage -Level Host -Message "Created new test group '{0}' and added current user to it" -StringValues $Name
}
#endregion Utility Functions

#----------------------------------------------------------------------------#
#                           Laying the foundation                            #
#----------------------------------------------------------------------------#

Install-Module JEANalyzer
# Build and Export
<#
Get-WinEvent
Get-Service
Restart-Service # Limit to Spooler
New-JeaCommand -Name Restart-Service -Parameter @{ Name = 'Name'; ValidateSet = @('Spooler') }, Force

$presentationRoot
#>
New-JeaLabGroup -Name JEA-ServiceManager
$module = New-JeaModule -Name ServiceAdmin -Description "Administrate Services"
$commands = 'Get-WinEvent', 'Get-Service', (New-JeaCommand -Name Restart-Service -Parameter @{ Name = 'Name'; ValidateSet = @('Spooler') }, Force)
$commands | New-JeaRole -Module $module -Name admins -Identity 'contoso\JEA-ServiceManager'
$module | Export-JeaModule -Path $presentationRoot
Copy-Item -Path "$presentationRoot\JEA_Serviceadmin" -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse
Register-JeaEndpoint_JEA_ServiceAdmin

Enter-PSSession -ComputerName localhost -ConfigurationName JEA_Serviceadmin


# Scanning Code
#-----------------
Read-JeaScriptFile -Path C:\Presentation\Get-OSInfo2.ps1
Read-JeaScriptFile -Path C:\Presentation\this-is-a-bad-idea.ps1
Read-JeaScriptblock -ScriptCode 'Start-Process foo'
Read-JeaScriptFile -Path C:\Presentation\SCM-bootstrap.ps1

#----------------------------------------------------------------------------#
#                If you don't cheat, you are not lazy enough                 #
#----------------------------------------------------------------------------#

# Build and Install
<#
Get-LocalGroup
Get-LocalGroupMember
Get-OSInfo
#>
$module | Install-JeaModule -ComputerName (Get-ADComputer -Filter *)
Enter-PSSession -ComputerName JeaDC -ConfigurationName JEA_ServiceAdmin

$module = New-JeaModule -Name OSInfo
'C:\Presentation\Get-OSInfo.ps1' | New-JeaRole -Name OSInfo -Module $module -Identity 'contoso\JEA-ServiceManager'
$module.ModulesToImport = 'CimCmdlets'
$module | Install-JeaModule -ComputerName JeaDC
Enter-PSSession -ComputerName JeaDC -ConfigurationName JEA_OSInfo

#----------------------------------------------------------------------------#
#                              Search & Destroy                              #
#----------------------------------------------------------------------------#

Get-JeaEndpoint -ComputerName JeaDC
$ep = Get-JeaEndpoint -ComputerName JeaDC
$ep[1].Roles.VisibleCmdlets | fl *

Get-JeaEndpoint -ComputerName JeaDC | Uninstall-JeaModule -RemoveCode

#----------------------------------------------------------------------------#
#                            Bootstrap to Victory                            #
#----------------------------------------------------------------------------#

<#
Get-OSInfo2
#>
$module | Export-JeaModule -Path $presentationRoot -AsBootstrap
Invoke-Command -ComputerName JeaDC -FilePath C:\Presentation\JEA_OSInfo.ps1


#----------------------------------------------------------------------------#
#                           Hello GP my old friend                           #
#----------------------------------------------------------------------------#

# https://serverconfigurationmanager.github.io

# SCM Share: \\JeaDC\PowerShell\SCM
# PS Repository: \\JeaDC\PowerShell\Repository
& C:\Presentation\SCM-bootstrap.ps1


#----------------------------------------------------------------------------#
#                           Honorable Mention: DSC                           #
#----------------------------------------------------------------------------#
