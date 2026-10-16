<#
.SYNOPSIS
	Installs the analysis tools listed in a manifest onto a DFIR analysis VM.

.DESCRIPTION
	Example of automating part of the DFIR box build. Reads DfirTools.psd1,
	installs each package with winget, optionally downloads Eric Zimmerman's
	tools, and writes a tool inventory (name, ID, installed version) so the
	versions used can be recorded in case notes.

	Run inside the analysis VM before taking the clean snapshot. Use -WhatIf
	first to see what would change.

.PARAMETER ManifestPath
	Path to the tool manifest. Default: DfirTools.psd1 next to this script.

.PARAMETER InventoryPath
	CSV file for the installed tool inventory. Default: ToolInventory.csv in ToolRoot.

.EXAMPLE
	.\Install-DfirTools.ps1 -WhatIf

.EXAMPLE
	.\Install-DfirTools.ps1 -Verbose
#>
[CmdletBinding(SupportsShouldProcess)]
param(
	[string]$ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath 'DfirTools.psd1'),

	[string]$InventoryPath
)

$Manifest = Import-PowerShellDataFile -Path $ManifestPath
$ToolRoot = $Manifest.ToolRoot
if (-not $InventoryPath) {
	$InventoryPath = Join-Path -Path $ToolRoot -ChildPath 'ToolInventory.csv'
}

if (-not (Get-Command -Name winget -ErrorAction SilentlyContinue)) {
	throw 'winget was not found. Install App Installer from the Microsoft Store or use a Windows image that includes it.'
}

if (-not (Test-Path -Path $ToolRoot)) {
	if ($PSCmdlet.ShouldProcess($ToolRoot, 'Create tool folder')) {
		New-Item -Path $ToolRoot -ItemType Directory | Out-Null
	}
}

foreach ($Package in $Manifest.Packages) {
	$Arguments = @(
		'install', '--id', $Package.Id, '--exact', '--silent',
		'--accept-package-agreements', '--accept-source-agreements'
		if ($Package.Version) { '--version'; $Package.Version }
	)
	$Target = if ($Package.Version) { "$($Package.Name) $($Package.Version)" } else { $Package.Name }
	if ($PSCmdlet.ShouldProcess($Target, 'winget install')) {
		Write-Verbose "winget $($Arguments -join ' ')"
		& winget @Arguments
		if ($LASTEXITCODE -ne 0) {
			Write-Warning "winget returned $LASTEXITCODE for $($Package.Id)"
		}
	}
}

$Zimmerman = $Manifest.ZimmermanTools
if ($Zimmerman -and $Zimmerman.Enabled) {
	$Destination = Join-Path -Path $ToolRoot -ChildPath 'EZTools'
	if ($PSCmdlet.ShouldProcess($Destination, "Download Eric Zimmerman's tools (.NET $($Zimmerman.NetVersion))")) {
		New-Item -Path $Destination -ItemType Directory -Force | Out-Null
		$Zip = Join-Path -Path $Destination -ChildPath 'Get-ZimmermanTools.zip'
		Invoke-WebRequest -Uri $Zimmerman.Url -OutFile $Zip -UseBasicParsing
		Expand-Archive -Path $Zip -DestinationPath $Destination -Force
		& (Join-Path -Path $Destination -ChildPath 'Get-ZimmermanTools.ps1') -Dest $Destination -NetVersion $Zimmerman.NetVersion
	}
}

if ($PSCmdlet.ShouldProcess($InventoryPath, 'Write tool inventory')) {
	$Manifest.Packages |
		ForEach-Object {
			$Id = $_.Id
			$Line = & winget list --id $Id --exact --accept-source-agreements |
				Where-Object { $_ -match [regex]::Escape($Id) } |
				Select-Object -First 1
			[pscustomobject]@{
				Name      = $_.Name
				Id        = $Id
				Requested = $_.Version
				Installed = [bool]$Line
				WingetList = if ($Line) { ($Line -replace '\s{2,}', ' ').Trim() } else { $null }
				Recorded  = (Get-Date).ToUniversalTime().ToString('u')
			}
		} |
		Export-Csv -Path $InventoryPath -NoTypeInformation -Encoding UTF8
	Write-Verbose "Wrote $InventoryPath"
}
