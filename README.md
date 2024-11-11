# DSM to AutoPilot
Ivanti DSM packages used to migrate devices from DSM to Microsoft Intune + AutoPilot mostly automatically. Requires device reset!

# What do these packages do?
1. Collecting the AutoPilo CSV hash file and transfer it to a network drive
2. Prepare everything for a full W11 IMG wipe
3. Do the Wipe to W11 with DSM
4. AutoPilot takes over afterwards.

# Steps to do
## Create a new package for collecting the hash files: [Collect_AutoPilot_Hashfiles.r](https://github.com/pari-medical-holding-gmbh/DSM-to-AutoPilot/blob/main/Collect_AutoPilot_Hashfiles.r)
Download the latest official Get-WindowsAutoPilotInfo.ps1 script from [here](https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo/3.9/Content/Get-WindowsAutoPilotInfo.ps1).
Change the following things in the code: 
1. Change parameter ```[Parameter(Mandatory=$False)] [String] $OutputFile = "",``` to for example ```[Parameter(Mandatory=$False)] [String] $OutputFile = "\\networkserverdrive\enteo$\Log\AutoPilot\autopilot_$env:computername.csv", ```
2. For better logging and if you have the payed DSM Powershell extensions, replace every ```Write-Host``` with ```Write-NiReport```. 
3. Also add ```Set-NIVar``` for better handling of Exitcodes in DSM and check if the network drive is available: 
Change this: 
```
    if ($Append)
        {
            if (Test-Path $OutputFile)
            {
                $computers += Import-CSV -Path $OutputFile
            }
        }
```
to this: 
```
    if ($Append)
        {
            if (Test-Path $OutputFile)
            {
                $computers += Import-CSV -Path $OutputFile
            } else 
            {
                Set-NIVar "_RV" 9
                exit
            }
        }
```
For an EXAMPLE, have a look [here](https://github.com/pari-medical-holding-gmbh/DSM-to-AutoPilot/blob/main/Get-WindowsAutoPilotInfo.ps1)

## Collecting all Hashfiles
Once you have deployed the package to all clients and collected all clients, merge the CSV files into one with [this Script](https://github.com/pari-medical-holding-gmbh/DSM-to-AutoPilot/blob/main/MergeMultipleCSVFilesIntoOne.ps1). You will need to change the variables before running it! Also it is recommended to copy all CSV files to a local path and not merging them directly at the network drive. 

## Create a new package preparing the wipe and reset: [Prepare_W11_DeviceReset.r](https://github.com/pari-medical-holding-gmbh/DSM-to-AutoPilot/blob/main/Prepare_W11_DeviceReset.r)
Multiple preparations are needed and done before doing the wipe: 
- Uninstalling antivirus software
- Uninstalling tools that manage external device access like DriveLock
- Running a system health check and clean up
- Asking the user, if a wipe is okay and setting a maximum amount of postponements
- Switching Dell BIOS settings to be compatible with Windows 11
- Handling RAID On to AHCI switches, by automatically applying safe mode, signing in via AutoLogin, switching the drives and rebooting

Optionally, deploy also the helper scripts from [here](https://github.com/pari-medical-holding-gmbh/DSM-to-AutoPilot/blob/main/Scripts%20for%20preparation%20package/)

## Create a new package for the real wipe and reset: [W11_DeviceResetWithIMG.r](https://github.com/pari-medical-holding-gmbh/DSM-to-AutoPilot/blob/main/W11_DeviceResetWithIMG.r)
Download the ISO for your language from [here](https://www.microsoft.com/en-US/software-download/windows11) (IMPORTANT; you will need W11 Pro, other editions wont work!)
Extract the ISO and deploy it to your new package. 

## Create a new software set ...
... containing both packages from above in the correct order.

# Important Notes
Please note, the scripts are, as they are. We wont provide any support for this, this has been writting to work at our scenarios, but changing different lines may be necessary for your environment!