<#	
	.NOTES
	===========================================================================
	 Created on:   	29.07.2024
	 Created by:   	FaserF
	===========================================================================
	.DESCRIPTION
		Dieses Script prüft, ob das Gerät Windows 11 kompatibel ist.
#>

# Abrufen des Computermodells
$ComputerModel = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model

Write-NiReport "Detected computer model: $ComputerModel"
Set-NIVar "_ComputerModel" "$ComputerModel"