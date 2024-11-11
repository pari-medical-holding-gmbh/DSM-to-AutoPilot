<#	
	.NOTES
	===========================================================================
	 Created on:   	23.07.2021
	 Created by:   	FaserF
	===========================================================================
	.DESCRIPTION
		Dieses Script ließt den letzten Neustart aus um zu prüfen ob der Smart Shutdown funktional war.
#>

$LastRestartTime = (Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} -MaxEvents 1).TimeCreated
$CalculateTime = ((Get-Date) - (get-date $LastRestartTime))
Set-NIVar "_LastRestartHours" "$($CalculateTime.Hours)"
Set-NIVar "_LastRestartMinutes" "$($CalculateTime.Minutes)"

try {
	$userloggedin = Get-WmiObject -Class win32_computersystem -ComputerName localhost | Select-Object -ExpandProperty username -ErrorAction Stop 
	Set-NIVar "_UserLoggedIn" "$userloggedin" 
	} 
catch { 
	Set-NIVar "_UserLoggedIn" "none" 
} 
