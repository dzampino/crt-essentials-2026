function New-CaseFolder {
	<#
	.SYNOPSIS
		Creates the Collected, Output and Notes folders for a case. Supports -WhatIf.
	.EXAMPLE
		New-CaseFolder -CaseRoot E:\Cases -CaseNumber 2026-0142 -WhatIf
	#>
	[CmdletBinding(SupportsShouldProcess)]
	param(
		# Where case folders live, such as a persistent disk or share
		[Parameter(Mandatory)]
		[string]$CaseRoot,

		[Parameter(Mandatory)]
		[string]$CaseNumber
	)

	$CasePath = Join-Path -Path $CaseRoot -ChildPath $CaseNumber
	'Collected', 'Output', 'Notes' |
		ForEach-Object { Join-Path -Path $CasePath -ChildPath $_ } |
		Where-Object { -not (Test-Path -Path $_) } |
		ForEach-Object {
			# ShouldProcess returns $false under -WhatIf, and prints what would have happened
			if ($PSCmdlet.ShouldProcess($_, 'Create folder')) {
				New-Item -Path $_ -ItemType Directory | Out-Null
				Write-Verbose "Created $_"
			}
		}
}
