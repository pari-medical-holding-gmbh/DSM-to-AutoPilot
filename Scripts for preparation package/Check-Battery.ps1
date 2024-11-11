<#	
	.NOTES
	===========================================================================
	 Created on:   	13.08.2024
	 Created by:   	FaserF
	===========================================================================
	.DESCRIPTION
		Dieses Script prüft, ob das Gerät mit einem Netzteil verbunden ist und wie viel Akku vorhanden ist.
#>
$powerStatus = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine

# Den aktuellen Akkustand ermitteln
$batteryLevel = (Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining

# Ausgabe des Netzteilstatus
if ($powerStatus -eq $true) {
    Write-NiReport "Device is connected with a powersupply and has $batteryLevel% battery left."
    Set-NIVar "_powerStatus" "$powerStatus"
    Set-NIVar "_batteryLevel" "$batteryLevel"
} else {
    Write-NiReport "Device is NOT connected with a powersupply and has $batteryLevel% battery left."
    Set-NIVar "_powerStatus" "$powerStatus"
    Set-NIVar "_batteryLevel" "$batteryLevel"
}