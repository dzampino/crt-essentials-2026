<#
.SYNOPSIS
	Summarizes events in collected .evtx files.

.DESCRIPTION
	Queries exported or collected event log files (not the live logs) with
	Get-WinEvent -FilterHashtable and returns either a summary per file,
	provider and event ID, or the matching events themselves.

.PARAMETER Path
	One or more .evtx files, or a folder containing them.

.PARAMETER Id
	Optional event IDs to include, for example 4624, 4625.

.PARAMETER StartTime
	Optional earliest event time (local time, as Get-WinEvent interprets it).

.PARAMETER EndTime
	Optional latest event time.

.PARAMETER Detail
	Return the matching events (time, ID, provider, message) instead of a summary.

.EXAMPLE
	.\Get-EvtxSummary.ps1 -Path D:\Case\Collected\Logs | Format-Table

.EXAMPLE
	.\Get-EvtxSummary.ps1 -Path D:\Case\Collected\Logs\Security.evtx -Id 4624, 4625 -Detail |
		Export-Csv D:\Case\Output\Logons.csv -NoTypeInformation
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
	[Alias('FullName')]
	[string[]]$Path,

	[int[]]$Id,

	[datetime]$StartTime,

	[datetime]$EndTime,

	[switch]$Detail
)

begin {
	$Files = [System.Collections.Generic.List[string]]::new()
}

process {
	foreach ($Item in $Path) {
		if (Test-Path -Path $Item -PathType Container) {
			Get-ChildItem -Path $Item -Filter *.evtx -File -Recurse |
				ForEach-Object { $Files.Add($_.FullName) }
		}
		else {
			$Files.Add((Resolve-Path -Path $Item).ProviderPath)
		}
	}
}

end {
	foreach ($File in $Files) {
		$Filter = @{ Path = $File }
		if ($Id) { $Filter.Id = $Id }
		if ($PSBoundParameters.ContainsKey('StartTime')) { $Filter.StartTime = $StartTime }
		if ($PSBoundParameters.ContainsKey('EndTime')) { $Filter.EndTime = $EndTime }

		Write-Verbose "Querying $File"
		try {
			$Events = Get-WinEvent -FilterHashtable $Filter -ErrorAction Stop
		}
		catch [System.Exception] {
			if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') {
				Write-Verbose "No matching events in $File"
				continue
			}
			Write-Warning "Could not read ${File}: $($_.Exception.Message)"
			continue
		}

		if ($Detail) {
			$Events |
				Select-Object @{ n = 'File'; e = { Split-Path -Path $File -Leaf } },
					TimeCreated, Id, ProviderName, MachineName, RecordId,
					@{ n = 'Message'; e = { ($_.Message -split "`r?`n")[0] } }
		}
		else {
			$Events |
				Group-Object ProviderName, Id |
				ForEach-Object {
					$Times = $_.Group | Measure-Object TimeCreated -Minimum -Maximum
					[pscustomobject]@{
						File         = Split-Path -Path $File -Leaf
						ProviderName = $_.Group[0].ProviderName
						Id           = $_.Group[0].Id
						Count        = $_.Count
						First        = $Times.Minimum
						Last         = $Times.Maximum
					}
				} |
				Sort-Object Count -Descending
		}
	}
}
