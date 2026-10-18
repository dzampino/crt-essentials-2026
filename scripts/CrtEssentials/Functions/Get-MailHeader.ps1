function Get-MailHeader {
	<#
	.SYNOPSIS
		Splits the headers of a saved message (.eml) into one object per header, in the order they appear.
	.EXAMPLE
		Get-MailHeader -Path .\constructed-headers.eml | Where-Object Name -eq 'Received'
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$Path
	)

	$Raw = Get-Content -LiteralPath $Path -Raw

	# The headers end at the first blank line
	$HeaderBlock = ($Raw -split "\r?\n\r?\n", 2)[0]

	# A line starting with a space or tab continues the header above it ("folding"); join them back up
	$Unfolded = $HeaderBlock -replace '\r?\n[ \t]+', ' '

	# Order 0 is the top header, which the last server added
	$Order = 0
	$Unfolded -split '\r?\n' |
		ForEach-Object {
			$Name, $Value = $_ -split ':\s*', 2
			[pscustomobject]@{ Order = $Order++; Name = $Name; Value = $Value }
		}
}
