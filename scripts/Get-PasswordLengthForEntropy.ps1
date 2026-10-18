function Get-PasswordLengthForEntropy {
	<#
	.SYNOPSIS
		How long a random password must be to reach a number of bits of entropy.
	.EXAMPLE
		Get-PasswordLengthForEntropy -AlphabetSize 26 -Bits 52.6
	#>
	[CmdletBinding()]
	param(
		# How many symbols each character is picked from
		[Parameter(Mandatory)]
		[ValidateRange(2, [int]::MaxValue)]
		[int]$AlphabetSize,

		# The entropy to match, in bits
		[Parameter(Mandatory)]
		[ValidateRange(1, 1024)]
		[double]$Bits
	)

	# Each character adds log2(alphabet) bits
	$BitsPerCharacter = [math]::Log($AlphabetSize, 2)

	# Round away tiny floating-point error, then round up: a partial character is not possible
	[math]::Ceiling([math]::Round($Bits / $BitsPerCharacter, 6))
}
