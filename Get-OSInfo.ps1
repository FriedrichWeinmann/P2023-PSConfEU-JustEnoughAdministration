function Get-OSInfo {
    [CmdletBinding()]
    param ()

    Get-CimInstance win32_OperatingSystem
}