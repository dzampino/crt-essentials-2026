# CrtEssentials: every function from the CRT Essentials site.
# Each function is in its own file in the Functions folder; this loads them all.
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions') -Filter *.ps1 |
	ForEach-Object { . $_.FullName }
