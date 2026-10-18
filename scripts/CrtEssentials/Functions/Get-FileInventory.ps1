function Get-FileInventory {
	<#
	.SYNOPSIS
		Lists every file under a folder with its size, UTC timestamps and hash.
	.DESCRIPTION
		For a collection of files you were given. Reading a file can update its last access
		time on the analysis machine, so work on a copy.
	.EXAMPLE
		Get-FileInventory -Path D:\Case\Collected | Sort-Object Length -Descending | Select-Object -First 10
	.EXAMPLE
		Get-FileInventory -Path D:\Case\Collected | Export-Csv D:\Case\Output\Inventory.csv -NoTypeInformation
	#>
	[CmdletBinding()]
	param(
		# The folder to inventory
		[Parameter(Mandatory)]
		[ValidateScript({ Test-Path -Path $_ -PathType Container })]
		[string]$Path,

		# Any algorithm Get-FileHash supports
		[ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA512')]
		[string]$Algorithm = 'SHA256'
	)

	# The folder's full path, so each file can be shown relative to it
	$Root = (Resolve-Path -Path $Path).ProviderPath.TrimEnd('\')

	# -Force includes hidden and system files
	Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
		ForEach-Object {
			$Hash = Get-FileHash -LiteralPath $_.FullName -Algorithm $Algorithm
			[pscustomobject]@{
				RelativePath     = $_.FullName.Substring($Root.Length + 1)
				Extension        = $_.Extension.ToLower()
				Length           = $_.Length
				CreationTimeUtc  = $_.CreationTimeUtc
				LastWriteTimeUtc = $_.LastWriteTimeUtc
				Hash             = $Hash.Hash
			}
		}
}
