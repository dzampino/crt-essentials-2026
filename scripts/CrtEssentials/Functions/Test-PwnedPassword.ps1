function Test-PwnedPassword {
	<#
	.SYNOPSIS
		Checks a password against Have I Been Pwned's Pwned Passwords, without sending the password.
	.EXAMPLE
		Test-PwnedPassword -Password (Read-Host -AsSecureString 'Password')
	#>
	[CmdletBinding()]
	param(
		# A SecureString, so the password is not shown on screen or saved in history
		[Parameter(Mandatory)]
		[securestring]$Password
	)

	# Turn the SecureString back into text, then into bytes, and hash it with SHA-1
	$Plain = [System.Net.NetworkCredential]::new('', $Password).Password
	$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Plain)
	$HashBytes = [System.Security.Cryptography.SHA1]::Create().ComputeHash($Bytes)
	$Hash = -join ($HashBytes | ForEach-Object { $_.ToString('X2') })

	# Only the first five characters of the hash leave this machine
	$Prefix = $Hash.Substring(0, 5)
	$Suffix = $Hash.Substring(5)
	Write-Verbose "Sending only the prefix $Prefix"
	$Response = Invoke-RestMethod -Uri "https://api.pwnedpasswords.com/range/$Prefix"

	# The reply is one "SUFFIX:COUNT" per line; look for ours locally
	$Match = $Response -split "`r?`n" | Where-Object { $_.StartsWith("${Suffix}:") }
	[pscustomobject]@{
		Pwned = [bool]$Match
		Count = if ($Match) { [int]($Match -split ':')[1] } else { 0 }
	}
}
