function Get-EvtxSummary {
	<#
	.SYNOPSIS
		Counts the events in a collected .evtx file by provider and event ID, with the first and last time each appears.
	.EXAMPLE
		Get-EvtxSummary -Path .\Case\Logs\System.evtx | Format-Table
	.EXAMPLE
		Get-ChildItem .\Case\Logs -Filter *.evtx | Get-EvtxSummary -Id 4624, 4625, 7045
	#>
	[CmdletBinding()]
	param(
		# A saved .evtx file; also accepts files piped from Get-ChildItem
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[Alias('FullName')]
		[string]$Path,

		# Only count these event IDs
		[int[]]$Id
	)

	process {
		# Path reads the saved file instead of the live log on this machine
		$Filter = @{ Path = (Resolve-Path -Path $Path).ProviderPath }
		if ($Id) {
			$Filter.Id = $Id
		}

		# Get-WinEvent reports "no events found" as an error; SilentlyContinue turns that into no output
		Get-WinEvent -FilterHashtable $Filter -ErrorAction SilentlyContinue |
			Group-Object ProviderName, Id |
			ForEach-Object {
				$Times = $_.Group.TimeCreated | Sort-Object
				[pscustomobject]@{
					File         = Split-Path -Path $Path -Leaf
					ProviderName = $_.Group[0].ProviderName
					Id           = $_.Group[0].Id
					Count        = $_.Count
					First        = $Times[0]
					Last         = $Times[-1]
				}
			} |
			Sort-Object Count -Descending
	}
}
