<#	
	.NOTES
	===========================================================================
	 Created on:   	21.07.2021
	 Created by:   	FaserF
	===========================================================================
	.DESCRIPTION
		Dieses Script deaktiviert Windows Funktionen, welche Probleme beim Inplace Upgrade verursachen können.
#>

#Status der Komponenten prüfen
$PrintToPDFStatus = (Get-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features).state
$XPSServicesStatus = (Get-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features).state

#Windows Features aktivieren
if($PrintToPDFStatus -eq 'Enabled') {
	Disable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features
}
if($XPSServicesStatus -eq 'Enabled') {
	Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features
}

#Stauts der Komponenten prüfen
$PrintToPDFStatus = (Get-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features).state
$XPSServicesStatus = (Get-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features).state

#Übergebe den String und Returncodes an DSM
if (($PrintToPDFStatus -eq 'Disabled') -and ($XPSServicesStatus -eq 'Disabled'))
{
	Write-NiReport "PrintToPDF and XPSServices Feature successfully disabled"
	Set-NIVar "_RV_WinFeatures" "0"
}
else
{
	Write-NiReport "PrintToPDF and XPSServices Feature disabling failed"
	Set-NIVar "_RV_WinFeatures" "1"
}

#Set-NIVar "_PrintToPDFStatus" "$PrintToPDFStatus"
#Set-NIVar "_XPSServicesStatus" "$XPSServicesStatus"