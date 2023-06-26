function Get-OSInfo2 {
    [CmdletBinding()]
    param ()

	Write-PSFMessage -Level Host -Message "Reading OS Infos"
    Get-CimInstance win32_OperatingSystem
}