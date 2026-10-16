<#
.SYNOPSIS
	Checks the DFIR analysis VM before use and before reset.

.DESCRIPTION
	Returns one result object per check. Before a case: confirms the persistent
	case storage is present, writable and separate from the system drive, and
	that the tool folder exists. Before a reset: lists what is in the output
	folder so you can confirm results and logs were retained outside the part
	of the machine that gets reset.

	Read-only except for a small marker file written and removed to test that
	the case storage is writable.

.PARAMETER CaseRoot
	Persistent case storage (a separate virtual disk or share that survives reset).

.PARAMETER ToolRoot
	Tool folder from the manifest. Default C:\Tools.

.PARAMETER MinimumFreeSpace
	Free space to require on the system drive. Default 10GB; set it for your image.

.EXAMPLE
	.\Test-DfirBox.ps1 -CaseRoot E:\Cases | Format-Table
#>
[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[string]$CaseRoot,

	[string]$ToolRoot = 'C:\Tools',

	[long]$MinimumFreeSpace = 10GB
)

function New-CheckResult {
	param([string]$Check, [bool]$Passed, [string]$Detail)
	[pscustomobject]@{ Check = $Check; Passed = $Passed; Detail = $Detail }
}

$CaseExists = Test-Path -Path $CaseRoot -PathType Container
New-CheckResult 'Case storage exists' $CaseExists $CaseRoot

if ($CaseExists) {
	$CaseDrive = (Resolve-Path -Path $CaseRoot).Drive.Name
	$SystemDrive = $env:SystemDrive.TrimEnd(':')
	New-CheckResult 'Case storage is not on the system drive' ($CaseDrive -ne $SystemDrive) "Case drive ${CaseDrive}:, system drive ${SystemDrive}:"

	$Marker = Join-Path -Path $CaseRoot -ChildPath ".write-test-$([guid]::NewGuid())"
	try {
		Set-Content -Path $Marker -Value 'test' -ErrorAction Stop
		Remove-Item -Path $Marker -ErrorAction Stop
		New-CheckResult 'Case storage is writable' $true $CaseRoot
	}
	catch {
		New-CheckResult 'Case storage is writable' $false $_.Exception.Message
	}

	$Output = Get-ChildItem -Path $CaseRoot -Recurse -File -ErrorAction SilentlyContinue |
		Measure-Object Length -Sum
	New-CheckResult 'Files retained in case storage' ($Output.Count -gt 0) ('{0} files, {1:N1} MB' -f $Output.Count, ($Output.Sum / 1MB))
}

New-CheckResult 'Tool folder exists' (Test-Path -Path $ToolRoot -PathType Container) $ToolRoot

$Volume = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'"
New-CheckResult 'System drive free space' ($Volume.FreeSpace -gt $MinimumFreeSpace) ('{0:N1} GB free' -f ($Volume.FreeSpace / 1GB))
