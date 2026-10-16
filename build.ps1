<#
.SYNOPSIS
	Renders the slide deck and the companion site.

.DESCRIPTION
	1. Renders quarto/slides.qmd to output/slides.pptx.
	2. Copies the deck, samples, scripts and images into site/files (not tracked in Git).
	3. Renders the site into docs/, which GitHub Pages serves from the main branch.

	Requires Quarto 1.4 or later. Looks for quarto on PATH, then in the default install folder.

.PARAMETER SlidesOnly
	Render only the PowerPoint.

.PARAMETER SiteOnly
	Render only the site (uses the existing output/slides.pptx).

.EXAMPLE
	.\build.ps1 -Verbose
#>
[CmdletBinding(SupportsShouldProcess)]
param(
	[switch]$SlidesOnly,

	[switch]$SiteOnly
)

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot

$Quarto = (Get-Command quarto -ErrorAction SilentlyContinue).Source
if (-not $Quarto) {
	$Quarto = Join-Path -Path $env:ProgramFiles -ChildPath 'Quarto\bin\quarto.exe'
}
if (-not (Test-Path -Path $Quarto)) {
	throw 'Quarto was not found. Install it from https://quarto.org/docs/get-started/.'
}
Write-Verbose "Using $Quarto"

if (-not $SiteOnly) {
	if ($PSCmdlet.ShouldProcess('output\slides.pptx', 'Render slides')) {
		Push-Location -Path (Join-Path -Path $Root -ChildPath 'quarto')
		try {
			& $Quarto render slides.qmd --output-dir ../output
			if ($LASTEXITCODE -ne 0) { throw "Slide render failed ($LASTEXITCODE)" }
		}
		finally {
			Pop-Location
		}
	}
}

if (-not $SlidesOnly) {
	$Files = Join-Path -Path $Root -ChildPath 'site\files'
	$Copies = @(
		@{ From = 'output\slides.pptx'; To = 'crt-essentials.pptx' }
		@{ From = 'samples\pki\*.pem'; To = 'samples\pki' }
		@{ From = 'samples\pki\*.der'; To = 'samples\pki' }
		@{ From = 'samples\pki\*.csr'; To = 'samples\pki' }
		@{ From = 'samples\email\*.eml'; To = 'samples\email' }
		@{ From = 'scripts\*'; To = 'scripts' }
		@{ From = 'assets\xkcd-936.png'; To = 'images' }
		@{ From = 'assets\diagrams\*.png'; To = 'images' }
	)
	if ($PSCmdlet.ShouldProcess($Files, 'Refresh copied files')) {
		if (Test-Path -Path $Files) {
			Remove-Item -Path $Files -Recurse -Force
		}
		$Copies | ForEach-Object {
			$Destination = Join-Path -Path $Files -ChildPath $_.To
			$Parent = if ($_.To -match '\.\w+$') { Split-Path -Path $Destination -Parent } else { $Destination }
			New-Item -Path $Parent -ItemType Directory -Force | Out-Null
			Copy-Item -Path (Join-Path -Path $Root -ChildPath $_.From) -Destination $Destination
			Write-Verbose "Copied $($_.From) to files\$($_.To)"
		}
	}

	$Docs = Join-Path -Path $Root -ChildPath 'docs'
	if ((Test-Path -Path $Docs) -and $PSCmdlet.ShouldProcess($Docs, 'Clear previous site output')) {
		# Quarto will not clean an output folder outside the site project, so stale pages would linger.
		Get-ChildItem -Path $Docs -Force | Remove-Item -Recurse -Force
	}

	if ($PSCmdlet.ShouldProcess('docs\', 'Render site')) {
		& $Quarto render (Join-Path -Path $Root -ChildPath 'site')
		if ($LASTEXITCODE -ne 0) { throw "Site render failed ($LASTEXITCODE)" }
		$NoJekyll = Join-Path -Path $Root -ChildPath 'docs\.nojekyll'
		if (-not (Test-Path -Path $NoJekyll)) {
			New-Item -Path $NoJekyll -ItemType File | Out-Null
		}
	}
}
