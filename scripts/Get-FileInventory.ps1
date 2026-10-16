<#
.SYNOPSIS
	Inventories an existing collection of files: metadata and hashes.

.DESCRIPTION
	Walks a folder that has already been collected and returns one object per
	file with its relative path, size, timestamps (UTC) and hash. Optionally
	writes the results to CSV. This is analysis of existing files, not evidence
	acquisition: reading a file can still update its last access time on the
	analysis machine, so work on a copy.

.PARAMETER Path
	Folder to inventory.

.PARAMETER Algorithm
	Hash algorithm passed to Get-FileHash. Default SHA256.

.PARAMETER OutputPath
	Optional CSV file to write. Honors -WhatIf.

.EXAMPLE
	.\Get-FileInventory.ps1 -Path D:\Case\Collected | Sort-Object Length -Descending | Select-Object -First 10

.EXAMPLE
	.\Get-FileInventory.ps1 -Path D:\Case\Collected -OutputPath D:\Case\Output\Inventory.csv -Verbose
#>
[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[ValidateScript({ Test-Path -Path $_ -PathType Container })]
	[string]$Path,

	[ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
	[string]$Algorithm = 'SHA256',

	[string]$OutputPath
)

$Root = (Resolve-Path -Path $Path).ProviderPath.TrimEnd('\')
Write-Verbose "Inventorying $Root with $Algorithm"

$Inventory = Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable WalkErrors |
	ForEach-Object {
		$Hash = Get-FileHash -LiteralPath $_.FullName -Algorithm $Algorithm -ErrorAction SilentlyContinue
		[pscustomobject]@{
			RelativePath     = $_.FullName.Substring($Root.Length + 1)
			Extension        = $_.Extension.ToLowerInvariant()
			Length           = $_.Length
			CreationTimeUtc  = $_.CreationTimeUtc
			LastWriteTimeUtc = $_.LastWriteTimeUtc
			LastAccessTimeUtc = $_.LastAccessTimeUtc
			Algorithm        = $Algorithm
			Hash             = if ($Hash) { $Hash.Hash } else { $null }
		}
	}

foreach ($WalkError in $WalkErrors) {
	Write-Warning "Skipped: $($WalkError.TargetObject) ($($WalkError.Exception.Message))"
}
Write-Verbose "$(@($Inventory).Count) files inventoried"

if ($OutputPath) {
	if ($PSCmdlet.ShouldProcess($OutputPath, 'Write inventory CSV')) {
		$Inventory | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
		Write-Verbose "Wrote $OutputPath"
	}
}
else {
	$Inventory
}
