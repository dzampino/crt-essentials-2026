function Get-CertificateInfo {
	<#
	.SYNOPSIS
		Shows the main fields of a certificate file (PEM or DER), including the DNS names in its SAN.
	.EXAMPLE
		Get-CertificateInfo -Path .\training-leaf.pem
	.EXAMPLE
		Get-ChildItem *.pem, *.cer | Get-CertificateInfo
	#>
	[CmdletBinding()]
	param(
		# The certificate file; also accepts files piped from Get-ChildItem
		[Parameter(Mandatory, ValueFromPipelineByPropertyName)]
		[Alias('FullName')]
		[string]$Path
	)

	process {
		# .NET needs a full path, so resolve relative paths like .\leaf.pem first
		$FullPath = (Resolve-Path -Path $Path).ProviderPath
		$Cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($FullPath)

		# The SAN extension (OID 2.5.29.17) formats as "DNS Name=a.example, DNS Name=b.example"
		$San = $Cert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.17' }
		$DnsNames = if ($San) {
			$San.Format($false) -split ',\s*' |
				Where-Object { $_ -like 'DNS Name=*' } |
				ForEach-Object { $_ -replace '^DNS Name=', '' }
		}

		[pscustomobject]@{
			Subject      = $Cert.Subject
			Issuer       = $Cert.Issuer
			NotBefore    = $Cert.NotBefore
			NotAfter     = $Cert.NotAfter
			DnsNames     = $DnsNames
			Thumbprint   = $Cert.Thumbprint
			SerialNumber = $Cert.SerialNumber
		}
	}
}
