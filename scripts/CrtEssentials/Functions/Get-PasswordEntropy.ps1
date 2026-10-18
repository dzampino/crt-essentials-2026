function Get-PasswordEntropy {
	<#
	.SYNOPSIS
		Bits of entropy for a password chosen at random.
	.EXAMPLE
		Get-PasswordEntropy -AlphabetSize 95 -Length 8
	#>
	[CmdletBinding()]
	param(
		# How many symbols each character is picked from: 10 for digits, 26 for lowercase, 95 for printable ASCII
		[Parameter(Mandatory)]
		[ValidateRange(2, [int]::MaxValue)]
		[int]$AlphabetSize,

		# How many characters (or words) are in the password
		[Parameter(Mandatory)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]$Length
	)

	# Bits = log2(alphabet ^ length), which is the same as length x log2(alphabet)
	$Bits = $Length * [math]::Log($AlphabetSize, 2)
	[math]::Round($Bits, 1)
}
