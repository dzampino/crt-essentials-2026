# Tool manifest for Install-DfirTools.ps1.
# EXAMPLE ENTRIES ONLY. The tool list and versions are an open decision (README.md);
# these show the format with package IDs that were confirmed to exist in winget.
# Pin Version for a repeatable build; leave it empty to take the current release.
@{
	ToolRoot = 'C:\Tools'

	Packages = @(
		@{ Name = '7-Zip'; Id = '7zip.7zip'; Version = '' }
		@{ Name = 'Sysinternals Suite'; Id = 'Microsoft.Sysinternals.Suite'; Version = '' }
		@{ Name = 'PowerShell 7'; Id = 'Microsoft.PowerShell'; Version = '' }
	)

	# Eric Zimmerman's tools via his Get-ZimmermanTools.ps1 (-Dest, -NetVersion).
	ZimmermanTools = @{
		Enabled    = $true
		NetVersion = 9
		Url        = 'https://download.ericzimmermanstools.com/Get-ZimmermanTools.zip'
	}
}
