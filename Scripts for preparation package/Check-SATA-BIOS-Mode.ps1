<#	
	.NOTES
	===========================================================================
	 Created on:   	18.11.2024
	 Created by:   	FaserF
	===========================================================================
	.DESCRIPTION
		Dieses Script prüft, welcher SATA Modus im BIOS eingestellt ist (AHCI vs RAID ON)
#>
# Define the path to CCTK
$cctkPath = "C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe"
$outputFile = "C:\Temp\bios_settings.ini"

& $cctkPath --outfile=$outputFile
$SataMode = Select-String -Path $outputFile -Pattern 'EmbSataRaid=(.*)' | Select-Object -First 1 | ForEach-Object { $_.Matches.Groups[1].Value }

Write-NiReport "Detected SATA mode $SataMode from file $outputFile"
Set-NIVar "_SataMode" "$SataMode"