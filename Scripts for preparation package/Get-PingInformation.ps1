<#	
	.NOTES
	===========================================================================
	 Created on:   	25.07.2021
	 Created by:   	FaserF
	===========================================================================
	.DESCRIPTION
		Dieses Script pingt den Netlaufwerksserver an, um herauszufinden ob User im Homeoffice oder im Office ist.
#>

$Ping = Test-Connection networkdrivefolder -Quiet -Count 2
Set-NIVar "_Ping" "$Ping"

