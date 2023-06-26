<#
These are the connection scriptblocks for the JEA_ServiceAdmin JEA Module.
For each role there is an entry with all that is needed to connect and consume it.
Just Copy&Paste the section you need, add it to the top of your script and insert the computername.
You will always need to create the session, but whether to Import it or use Invoke-Command is up to you.
Either option will work, importing it is usually more convenient but will overwrite local copies.
Invoke-Command is the better option if you want to connect to multiple such sessions or still need access to the local copies.

Note: If a user has access to multiple roles, you still only need one session, but:
- On Invoke-Command you have immediately access to ALL commands allowed in any role the user is in.
- On Import-PSSession, you need to explicitly state all the commands you want.
#>

# Connect to JEA Endpoint for Role admins
$session = New-PSSession -ComputerName '<InsertNameHere>' -ConfigurationName 'JEA_ServiceAdmin'
Import-PSSession -AllowClobber -Session $session -DisableNameChecking -CommandName 'Get-WinEvent', 'Get-Service', 'Restart-Service'
Invoke-Command -Session $session -Scriptblock { Get-WinEvent }