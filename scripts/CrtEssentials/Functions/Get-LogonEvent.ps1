function Get-LogonEvent {
	<#
	.SYNOPSIS
		Successful logons (event 4624) from a collected Security.evtx, with the user, logon type and source address.
	.EXAMPLE
		Get-LogonEvent -Path .\Case\Logs\Security.evtx | Group-Object LogonType
	#>
	[CmdletBinding()]
	param(
		# A saved Security.evtx
		[Parameter(Mandatory)]
		[string]$Path,

		# Stop after this many events, newest first; a Security log can hold millions
		[int]$MaxEvents = 1000
	)

	$Filter = @{ Path = (Resolve-Path -Path $Path).ProviderPath; Id = 4624 }
	Get-WinEvent -FilterHashtable $Filter -MaxEvents $MaxEvents |
		ForEach-Object {
			# The named fields (TargetUserName, LogonType, IpAddress...) are in the event's XML
			$Data = @{}
			([xml]$_.ToXml()).Event.EventData.Data | ForEach-Object { $Data[$_.Name] = $_.'#text' }

			[pscustomobject]@{
				TimeCreated = $_.TimeCreated
				User        = '{0}\{1}' -f $Data.TargetDomainName, $Data.TargetUserName
				LogonType   = $Data.LogonType
				IpAddress   = $Data.IpAddress
			}
		}
}
