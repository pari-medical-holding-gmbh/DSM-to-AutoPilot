!***************************************************************************************************
!Autor: FaserF
!Datum: 29.07.2024
!---------------------------------------------------------------------------------------------------------------------------
!Beschreibung:
!Dieses Paket löscht den Client über ein Powershell Script und startet einen Reset mit dem W11 Setup an
!---------------------------------------------------------------------------------------------------------------------------
!Änderungen:
!29.07.2024 rev V001: FaserF: Paket erstellt
!***************************************************************************************************
!
!#Define Variables
If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried',)
 RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried','_ResetTried',)
Else
 Set('_ResetTried','0')
!
!#Installation
If not CheckInstallMode(imUninstall)
! #If device is currently (re)installing - skip post actions
 RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Reboot','StagingPhase','_StagingPhase',reUseX64Hive)
 If not %_StagingPhase%='100'
  ExitProcEx(Done,'PC wird gerade (re)installiert. Reset wird übersprungen.')
!  
 If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultUsername',)
  RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultUserName',)/TS
  If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultPassword',)
   RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultPassword',)/TS
  If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','AutoAdminLogon',)
   RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','AutoAdminLogon',)/TS
  ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 5 /c "Restarting"','','')/?/TS
  System_Reset/?/TW
  ExitProcEx(Undone,'Autologin Entfernung Neustart ausstehend. Reset wird nach einem Neustart fortgesetzt.')
! #Starte Installation NICHT über Smart Shutdown - außer User wollte es so
 If IsProcessRunning('Shutdownscreen.exe',procByFileName)
  ExitProcEx(Undone,'Installation kann nicht über Smart Shutdown gestartet werden.')
!  
 If IsRestartFlagSet
  System_Reset/?/TW
  ExitProcEx(Undone,'Neustart ausstehend. Reset wird nach einem Neustart fortgesetzt.')
! 
 If %_ResetTried%='0' or %_ResetTried%='1' or %_ResetTried%='2'
  IncrementVar('_ResetTried','1')
  RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried','%_ResetTried%',mrReplace)/TS
  ExecuteEx('"C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe" --SecureBoot=Enabled --TpmActivation=Enabled --TpmSecurity=Enabled --EmbSataRaid=Ahci --ValSetupPwd=YourBIOSPassword','_RV_CCTK','7')/?/X/TS
  Set('_Language','%CurrentComputer.CustomClientProperties.TargetLanguage1%')
  If %_Language%='de-DE' or %_Language%='de-CH'
   ExecuteEx('.\Extern$\windows11DE\setup.exe /auto clean /migratedrivers none /resizerecoverypartition enable /dynamicupdate disable /eula accept /quiet /uninstall disable /compat ignorewarning /copylogs C:\Install\WinSetup.log','_RV_W11','15')/?/X/TS
  Else
   ExecuteEx('.\Extern$\windows11\setup.exe /auto clean /migratedrivers none /resizerecoverypartition enable /dynamicupdate disable /eula accept /quiet /uninstall disable /compat ignorewarning /copylogs C:\Install\WinSetup.log','_RV_W11','15')/?/X/TS
  System_Reset/?/TW
  EndInstallerSession/TW
  ExitProcEx(Undone,'Reset via W11 IMG angestoßen. Wenn dies erfolgreich war wird das die letzte DSM Meldung sein.')
 If %_ResetTried%='3'
  IncrementVar('_ResetTried','1')
  RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried','%_ResetTried%',mrReplace)/TS
  ExecuteEx('"C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe" --SecureBoot=Enabled --TpmActivation=Enabled --TpmSecurity=Enabled --EmbSataRaid=Ahci --ValSetupPwd=YourBIOSPassword','_RV_CCTK','7')/?/X/TS
  Copy('.\Extern$\pstools','C:\ProgramData\CustomScripts\pstools')/S/TS
  Copy('.\Extern$\Reset-ComputerLocally.ps1','C:\ProgramData\CustomScripts\Reset-ComputerLocally.ps1')/TS
  Copy('.\Extern$\reset.ps1','C:\ProgramData\CustomScripts\reset.ps1')/TS
  Copy('.\Extern$\start.ps1','C:\ProgramData\CustomScripts\start.ps1')/TS
!  CallScript('C:\ProgramData\CustomScripts\Reset-ComputerLocally.ps1','')/X/x64/TS
  ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 20 /c "Neustart notwendig für Inplace Upgrade Paket."','','')/?/TS
  System_Reset/?/TW
  EndInstallerSession/TW
  ExitProcEx(Undone,'W11 IMG Reset erfolglos! Neuer Versuch mit W10 Script Reset. Wenn erfolgrerich wird dies die letzte Meldung sein.')
 Else
!  #Disable NWC Credential Provider
  RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','IsEnabled','_IsEnabled',reUseX64Hive)
  If %_IsEnabled%='1'
   RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','IsEnabled','0',mrdwSet+reUseX64Hive)/TS
  IncrementVar('_ResetTried','1')
  RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried','%_ResetTried%',mrReplace)/TS
  ExitProcEx(Failed,'Reset mehrmals erfolglos angestoßen. Computer muss manuell uminstalliert werden!')
!  
: $BeginUninstallScript
!#Uninstallation
