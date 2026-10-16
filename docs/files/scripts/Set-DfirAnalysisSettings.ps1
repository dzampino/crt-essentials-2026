<#
.SYNOPSIS
	Applies analysis-VM-specific Windows settings: UAC prompt behavior and Defender exclusions.

.DESCRIPTION
	These are decisions specific to a disposable, nonpersistent analysis VM, not
	general recommendations. Normally we don't disable security features; on this
	machine, reducing friction for tools that need to run as administrator matters.

	-UacMode NoPrompt keeps UAC (Admin Approval Mode) on but elevates
	administrators without prompting (ConsentPromptBehaviorAdmin = 0).
	-UacMode Disabled turns off Admin Approval Mode (EnableLUA = 0) and needs a restart.
	-UacMode Default restores EnableLUA = 1 and ConsentPromptBehaviorAdmin = 5.

	Which mode, and whether Defender should scan evidence and tool folders,
	are open decisions recorded in README.md. Run as administrator.

.PARAMETER UacMode
	NoPrompt, Disabled or Default.

.PARAMETER DefenderExclusionPath
	Optional folders to exclude from Microsoft Defender scanning, for example the tool folder.

.EXAMPLE
	.\Set-DfirAnalysisSettings.ps1 -UacMode NoPrompt -WhatIf

.EXAMPLE
	.\Set-DfirAnalysisSettings.ps1 -UacMode NoPrompt -DefenderExclusionPath C:\Tools -Verbose
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
	[Parameter(Mandatory)]
	[ValidateSet('NoPrompt', 'Disabled', 'Default')]
	[string]$UacMode,

	[string[]]$DefenderExclusionPath
)

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
	[Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin -and -not $WhatIfPreference) {
	throw 'Run this script from an elevated PowerShell session.'
}

$PolicyKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Values = switch ($UacMode) {
	'NoPrompt' { @{ EnableLUA = 1; ConsentPromptBehaviorAdmin = 0 } }
	'Disabled' { @{ EnableLUA = 0; ConsentPromptBehaviorAdmin = 0 } }
	'Default' { @{ EnableLUA = 1; ConsentPromptBehaviorAdmin = 5 } }
}

foreach ($Name in $Values.Keys) {
	$Current = (Get-ItemProperty -Path $PolicyKey -Name $Name -ErrorAction SilentlyContinue).$Name
	if ($Current -eq $Values[$Name]) {
		Write-Verbose "$Name is already $Current"
		continue
	}
	if ($PSCmdlet.ShouldProcess("$PolicyKey\$Name", "Set from $Current to $($Values[$Name])")) {
		Set-ItemProperty -Path $PolicyKey -Name $Name -Value $Values[$Name] -Type DWord
		if ($Name -eq 'EnableLUA') {
			Write-Warning 'EnableLUA changed; restart Windows for it to take effect.'
		}
	}
}

foreach ($Path in $DefenderExclusionPath) {
	if ($PSCmdlet.ShouldProcess($Path, 'Add Microsoft Defender exclusion')) {
		Add-MpPreference -ExclusionPath $Path
	}
}
