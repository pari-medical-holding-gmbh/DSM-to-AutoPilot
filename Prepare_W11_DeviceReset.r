!***************************************************************************************************
!Autor: FaserF
!Datum: 26.07.2024
!---------------------------------------------------------------------------------------------------------------------------
!Beschreibung:
!Dieses Paket informiert den Anwender über ein Upgarde auf Windows 11 und setzt in der Registry einen Hilfskey
!---------------------------------------------------------------------------------------------------------------------------
!Änderungen:
!26.07.2024 rev V001: FaserF: Paket erstellt
!***************************************************************************************************
!
!#If device is currently (re)installing - skip preperations
RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Reboot','StagingPhase','_StagingPhase',reUseX64Hive)
If not %_StagingPhase%='100'
! #This package will be marked as uninstalled on reinstallation by the Package "(System) Reset Driver Category to its Default & Mark InplaceUpgrade as Uninstalled (x64) 1.0"
! ChangeSwAssignment('{7669BF33-40BF-432C-9B92-196F051FF5C3}',csaUninstall)/F
 ExitProcEx(Done,'PC wird gerade (re)installiert. Reset wird übersprungen.')
!
Set('_InstallationPostponementsInitial','20')
!#Starte Installation NICHT über Smart Shutdown - außer User wollte es so
If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart',)
 RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart','_StartResetOnRestart',)
Else
 Set('_StartResetOnRestart','0')
If IsProcessRunning('Shutdownscreen.exe',procByFileName)
 If %_StartResetOnRestart%='0'
  ExitProcEx(Undone,'Installation kann nicht über Smart Shutdown gestartet werden.')
Else
 If not %_StartResetOnRestart%='0'
  RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Reboot','RebootFlag','2',mrdwSet+reUseX64Hive)/TS
  CallScript('.\Extern$\Get-LastShutdownInfo.ps1','')/X/x64/TS
  If %_LastRestartHours%<'1'
   If %_LastRestartMinutes%<'20'
    If %_UserLoggedIn%='none' or %_UserLoggedIn%=''
     RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart','9',mrReplace)/TS
     Set('_StartResetOnRestart','9')
    Else
     RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements','%_InstallationPostponementsInitial%',mrReplace)/TS
     RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart','8',mrReplace)/TS
     Set('_StartResetOnRestart','8')
    goto Set_Variables
  ExitProcEx(Undone,'Kein Smart Shutdown - User will Reset bei nächstem Herunterfahren/Neustart starten.')
!  
: Set_Variables
!#Define Variables
Set('_RV','0')
Set('_RV_DL','0')
Set('_RV_CV','0')
Set('_RV_DISM','0')
Set('_RV_SFC','0')
Set('_RV_DCU','0')
Set('_RV_TM','0')
Set('_RV_OD','0')
Set('_RV_reg','0')
Set('_RV_WinFeatures','1')
Set('_RV_msgbox','not_set')
Set('_SataMode','unknown')
Set('_DLVersion','99999')
Set('_VersionTM','99999')
Set('_Ping','false')
Set('_powerStatus','true')
Set('_batteryLevel','100')
Set('_InstallationPostponements','%_InstallationPostponementsInitial%')
If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements',)
 RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements','_InstallationPostponements',)
 DecrementVar('_InstallationPostponements','1')
Set('_ReturnMessage','')
Set('_TargetVersion','22000')
!#19041=2004; 19042=20H2; 19043 = Win10 21H1
Set('_NewBuildNumber','22000')
RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion','CurrentBuildNumber','_BuildNumber',)
Set('_Language','%CurrentComputer.CustomClientProperties.TargetLanguage1%')
!#Default language = English
Set('_Message','IMPORTANT: Your system needs to be reinstalled to Client 2.0 with Windows 11. This can take up to 3 hours. During the reinstallation, your device will have to restart several times to complete it. Start Reset now/at next reboot? Available postponements: %_InstallationPostponements%')
Set('_Message_Alternative','IMPORTANT: Your system needs to be reinstalled to Client 2.0 with Windows 11. This can take up to 3 hours. During the reinstallation, your device will have to restart several times to complete it. Start Reset now/at next reboot? Available postponements: %_InstallationPostponements%')
Set('_Message_2','The Reinstallation to Windows 11 is starting because the maximum delay has been used up. This can take up to three hours and all data will be deleted!')
Set('_Message3','IMPORTANT: Please make sure that your important files are backed up in OneDrive / a network drive before reinstalling.')
Set('_Message4','Start reinstallation now (yes) or on restart (no)?')
Set('_MessageRestart','Preparation done - Restart required to start the reinstallation')
Set('_MessageDeviceModel','Your device is not Windows 11 compatible. Please contact the IT-Support soon, to replace your device. ')
Set('_chkdsk_command','echo y | chkdsk C: /F /R')
If %_Language%='de-DE' or %_Language%='de-CH'
 Set('_Message','WICHTIG: Dein System muss auf Client 2.0 mit Windows 11 neuinstalliert werden. Dies kann bis zu 3 Stunden in Anspruch nehmen. Während der Neuinstallation wird dein Gerät mehrmals neustarten. Neuinstallation jetzt/beim nächsten Neustart starten? Verfügbare Aufschübe: %_InstallationPostponements%')
 Set('_Message_Alternative','WICHTIG: Dein System muss auf Client 2.0 mit Windows 11 neuinstalliert werden. Dies kann bis zu 3 Stunden in Anspruch nehmen. Während der Neuinstallation wird dein Gerät mehrmals neustarten. Neuinstallation jetzt/beim nächsten Neustart starten? Verfügbare Aufschübe: %_InstallationPostponements%')
 Set('_Message_2','Die Windows 11 Neuinstallation wird gestartet, da die maximalen Aufschübe aufgebraucht wurden. Dies kann bis zu drei Stunden dauern und alle Daten werden gelöscht!')
 Set('_Message3','WICHTIG: Bitte stelle sicher, dass deine wichtige Dateien in OneDrive/ einem Netzlaufwerk vor dem Upgrade gesichert sind.')
 Set('_Message4','Neuinstallation jetzt (Ja) oder bei Neustart (Nein) starten?')
 Set('_MessageRestart','Vorbereitung abgeschlossen - Neustart benötigt um den Prozess zu starten')
 Set('_MessageDeviceModel','Dein Gerät ist nicht Windows 11 kompatibel. Bitte kontaktiere den IT-Support zeitnah zum Austauschen deines Gerätes!')
 Set('_chkdsk_command','echo j | chkdsk C: /F /R')
If %_Language%='es-ES'
 Set('_Message','IMPORTANTE: Es necesario reinstalar su sistema en Client 2.0 con Windows 11. Esto puede tardar hasta 3 horas. Durante la reinstalación, su dispositivo deberá reiniciarse varias veces para completarla. ¿Iniciar la actualización ahora/en el próximo reinicio? Aplazamientos disponibles: %_InstallationPostponements%')
 Set('_Message_Alternative','IMPORTANTE: Es necesario reinstalar su sistema en Client 2.0 con Windows 11. Esto puede tardar hasta 3 horas. Durante la reinstalación, su dispositivo deberá reiniciarse varias veces para completarla. ¿Iniciar la actualización ahora/en el próximo reinicio? Aplazamientos disponibles: %_InstallationPostponements%')
 Set('_Message_2','La reinstalación de Windows 11 está comenzando porque se ha agotado el retraso máximo. ¡Esto puede tardar hasta tres horas y se eliminarán todos los datos!')
 Set('_Message3','IMPORTANTE: asegúrese de que sus archivos importantes tengan una copia de seguridad en OneDrive/una unidad de red antes de reinstalar.')
 Set('_Message4','¿Iniciar la actualización ahora (sí) o al reiniciar (no)?')
 Set('_MessageRestart','Preparación realizada: se requiere reinicio para iniciar la reinstalación')
 Set('_MessageDeviceModel','Su dispositivo no es compatible con Windows 11. Comuníquese con el soporte de TI pronto para reemplazar su dispositivo.')
 Set('_chkdsk_command','echo s | chkdsk C: /F /R')
If %_Language%='fr-FR' or %_Language%='fr-CH'
 Set('_Message','IMPORTANT : votre système doit être réinstallé sur Client 2.0 avec Windows 11. Cela peut prendre jusqu à 3 heures. Lors de la réinstallation, votre appareil devra redémarrer plusieurs fois pour la terminer. Démarrer la mise à jour maintenant/au prochain redémarrage ? Reports disponibles: %_InstallationPostponements%')
 Set('_Message_Alternative','IMPORTANT : votre système doit être réinstallé sur Client 2.0 avec Windows 11. Cela peut prendre jusqu à 3 heures. Lors de la réinstallation, votre appareil devra redémarrer plusieurs fois pour la terminer. Démarrer la mise à jour maintenant/au prochain redémarrage ? Reports disponibles: %_InstallationPostponements%')
 Set('_Message_2','La réinstallation vers Windows 11 démarre car le délai maximum est écoulé. Cela peut prendre jusqu à trois heures et toutes les données seront supprimées !')
 Set('_Message3','IMPORTANT : assurez-vous que vos fichiers importants sont sauvegardés sur OneDrive/un lecteur réseau avant de les réinstaller.')
 Set('_Message4','Démarrer la mise à jour maintenant (oui) ou au redémarrage (non) ?')
 Set('_MessageRestart','Préparation effectuée - Redémarrage nécessaire pour lancer la réinstallation')
 Set('_MessageDeviceModel','Votre appareil n''est pas compatible Windows 11. Veuillez contacter rapidement le support informatique pour remplacer votre appareil.')
 Set('_chkdsk_command','echo o | chkdsk C: /F /R')
!#Check for Inplace Upgrade Hellper Registry Key and delete them if exists
If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InplaceUpgrade',)
! #Remove Helper Reg Key
 RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InplaceUpgrade',)/TS
!#Disable NWC Credential Provider
RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','IsEnabled','_IsEnabled',reUseX64Hive)
If %_IsEnabled%='1'
 RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','IsEnabled','0',mrdwSet+reUseX64Hive)/TS
 RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Reboot','RebootFlag','2',mrdwSet+reUseX64Hive)/TS
!
!#Installation
If not CheckInstallMode(imUninstall)
! #If device is not W11 compatible, bring up a warning
 Set('_ComputerModel','unknown')
 CallScript('.\Extern$\Check-ComputerModel.ps1','')/X/x64/TS
 If %_ComputerModel%='Latitude 7480' or %_ComputerModel%='Latitude E7470' or %_ComputerModel%='OptiPlex 9020' or %_ComputerModel%='Precision WorkStation T5500' or %_ComputerModel%='Latitude E7450' or %_ComputerModel%='Precision T5810' or %_ComputerModel%='Latitude E7440' or %_ComputerModel%='OptiPlex 7040' or %_ComputerModel%='OptiPlex 7050' or %_ComputerModel%='Precision T7810' or %_ComputerModel%='Precision T7610' or %_ComputerModel%='Precision 7510' or %_ComputerModel%='Precision 7520' or %_ComputerModel%='Precision 7720'
  MsgBoxEx('%_MessageDeviceModel%','_RV_msgboxDM','',mbOK,'','')
  ExitProcEx(Undone,'Device is not W11 compatible. Bringing up a user waning now on every run on purpose.')
!  
! CallScript('.\Extern$\Check-Battery.ps1','')/X/x64/TS
 If %_powerStatus%='false'
  ExitProcEx(Undone,'device is not connected to a power supply!')
! If %_NewBuildNumber%<='%_BuildNumber%'
!  RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','NewVersionWasInstalled','1',mrReplace)/TS
!  ExitProcEx(Done,'Windows 11 %_BuildNumber% ist bereits installiert.')
!  
! #Check if new Trendmicro is installed - Otherwise Inplace Upgrade will fail
 If Exist('%ProgramFilesDir%\Trend Micro\Security Agent\PccNt.exe')
  GetFileVersion('%ProgramFilesDir%\Trend Micro\Security Agent\PccNt.exe','_VersionTM')
!  # Minimum Version of TM for 2004 is higher than 14.0.0.2087 - https://success.trendmicro.com/solution/1112083-compatibility-between-windows-10-and-officescan-apex-one
  If not %_VersionTM%>='14.0.0.8286'
   ExitProcEx(Undone,'Trendmicro ist noch nicht aktualisiert. Inplace Upgrade klappt nur mit neuester TM Version. Aktuelle TM Version: %_VersionTM%')
!  
 If %_InstallationPostponements%='%_InstallationPostponementsInitial%'
!  #Run a Dell Command Reset run to Reset all drivers
  If Exist('C:\Program Files (x86)\Dell\CommandReset\dcu-cli.exe')
   ExecuteEx('"C:\Program Files (x86)\Dell\CommandReset\dcu-cli.exe" /applyResets -silent','_RV_DCU','20')/?/X/TS
  ExecuteEx('".\Extern$\Intel-Rapid-Storage-Technology-Driver_62C56_WIN64_17.9.6.1019_A04_03.EXE" /s','_RV_DCU','20')/?/X/TS
!  #Start DISM & SFC to prevent Inplace Upgrade Errors
  ExecuteEx('C:\Windows\System32\Dism.exe /Online /Cleanup-Image /CheckHealth','_RV_DISM_CH','10')/?/X/TS
  ExecuteEx('C:\Windows\System32\Dism.exe /Online /Cleanup-Image /ScanHealth','_RV_DISM_SH','10')/?/X/TS
  ExecuteEx('C:\Windows\System32\Dism.exe /Online /Cleanup-image /Restorehealth','_RV_DISM','25')/?/X/TS
  ExecuteEx('C:\Windows\System32\sfc.exe /scannow','_RV_SFC','15')/?/X/TS
!  #Run a check disk on next reboot
  ExecuteEx('C:\WINDOWS\system32\cmd.exe "%_chkdsk_command%"','_RV_chkdsk','3')/?/X/TS
!  #Allow Inplace Upgrade to Win11 even on unsupported CPUs
!  RegModifyDWord('HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup','AllowUpgradesWithUnsupportedTPMOrCPU','1',mrdwSet+reUseX64Hive)/TS
!  RegModifyDWord('HKEY_LOCAL_MACHINE\SYSTEM\Setup\LabConfig','BypassTPMCheck','1',mrdwSet+reUseX64Hive)/TS
!  RegModifyDWord('HKEY_LOCAL_MACHINE\SYSTEM\Setup\LabConfig','BypassCPUCheck','1',mrdwSet+reUseX64Hive)/TS
!    
! #Check if new DriveLock is installed
 If Exist('C:\Program Files\CenterTools\DriveLock\DriveLock.exe')
  GetFileVersion('C:\Program Files\CenterTools\DriveLock\DriveLock.exe','_DLVersion')/X
  If %_DLVersion%>='19.2.2.26599'
   goto User_Box
  Else
   ExitProcEx(Undone,'DriveLock ist noch nicht aktualisiert. Inplace Upgrade klappt nur mit neuester DL Version. Aktuelle DL Version: %_DLVersion%')
! 
 : User_Box
 If %_InstallationPostponements%>'0'
  If %_StartResetOnRestart%='0'
   If Exist('C:\Program Files\NWC Services\Smart Shutdown\ShutdownScreen.exe')
    MsgBoxEx('%_Message%','_RV_msgbox','',mbYesNo,'1200','1')
   Else
    MsgBoxEx('%_Message_Alternative%','_RV_msgbox','',mbYesNo,'1200','1')
  If %_StartResetOnRestart%='8'
   MsgBoxEx('%_Message_Alternative%','_RV_msgbox','',mbYesNo,'1200','1')
 Else
  MsgBoxEx('%_Message_2%','_RV_msgbox_2','',mbOK,'60','0')
! If %_RV_msgbox%='YES' or %_RV_msgbox%='CANCEL'
 If %_RV_msgbox%='YES' or %_InstallationPostponements%<='0' or %_StartResetOnRestart%='1' or %_StartResetOnRestart%='9'
  If %_StartResetOnRestart%='0'
   MsgBoxEx('%_Message3%','_RV_msgbox3','',mbOK,'1200','0')
   If Exist('C:\Program Files\NWC Services\Smart Shutdown\ShutdownScreen.exe')
    MsgBoxEx('%_Message4%','_RV_msgbox4','',mbYesNo,'120','0')
   If %_RV_msgbox4%='NO'
    RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements','%_InstallationPostponements%',mrReplace)/TS
    RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart','1',mrReplace)/TS
    RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Reboot','RebootFlag','2',mrdwSet+reUseX64Hive)/TS
    ExitProcEx(Undone,'User will Reset bei nächstem Herunterfahren/Neustart starten.')
!    
!  Bitlocker Status (0 = Bitlocker Aktiv - Laufwerk verschlüsselt; 1 = Bitlocker Aktiv - Laufwerk nicht verschlüsselt;  -1 = Bitlocker ist inaktiv)
  ExecuteEx('C:\Windows\System32\manage-bde.exe -status %SYSTEMDRIVE% -protectionaserrorlevel','_BitlockerStatus','1')/?/x64/TS
  If %_BitlockerStatus%='0'
   ExecuteEx('manage-bde -protectors -disable %systemdrive%','_RV','1')/?/x64/TS
   If %_RV%='-2144272383'
    goto DriveLock
   If not %_RV%='0'
    ExitProcEx(Undone,'Error %_RV% during suspending Bitlocker.')
!  
  : DriveLock
!  #Uninstall DriveLock - as it creates Bluescreens
  If Exist('C:\Program Files\CenterTools\DriveLock\DriveLock.exe')
   If %_DLVersion%='19.2.2.26599' or %_DLVersion%='19.2.*'
    ExecuteEx('%WINSYSDIR%\MsiExec.exe /X{427471A3-C458-475E-8AB9-23773F4E3CFC} /log "%LogFileSettings.LogFilePath%\%CurrentPackage.Object.Name%_%_InstallationType%_DriveLockUninstall.txt" /quiet /noreboot','_RV_DL','10')/?/TS
   If %_DLVersion%='21.1.2.34715' or %_DLVersion%='21.1.*'
    ExecuteEx('%WINSYSDIR%\MsiExec.exe /X{98113425-6D53-443A-982F-261985E4791E} /log "%LogFileSettings.LogFilePath%\%CurrentPackage.Object.Name%_%_InstallationType%.txt" /quiet /noreboot','_RV_DL','10')/?/TS
!   #Errorhandling
   If %_RV_DL%='TIMEOUT'
    ExitProcEx(Failed,'Zeitüberschreitung bei der Deinstallation von Drivelock %_DLVersion%')
   If %_RV_DL%='0' or %_RV_DL%='1641' or %_RV_DL%='3010'
    goto WinFeatures
   Else
    ExitProcEx(Failed,'Fehler %_RV_DL% bei der Deinstallation von Drivelock %_DLVersion%')
!   
  : WinFeatures
!  #Disable critical Windows features
  CallScript('.\Extern$\DisableWindows10Featues.ps1','')/X/x64/TS
  If not %_RV_WinFeatures%='0'
   Set('_ReturnMessage','%_ReturnMessage% Fehler beim Deaktivieren der Windows Features.')
!   
!  #Remove AutoLogin Reg Keys if they exist
  If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultUsername',)
   RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultUserName',)/TS
   If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultPassword',)
    RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','DefaultPassword',)/TS
   If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','AutoAdminLogon',)
    RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon','AutoAdminLogon',)/TS
!    
  CallScript('.\Extern$\Get-PingInformation.ps1','')/X/x64/TS
!  #Set NWC Credential Provider
  If not Exist('%WINSYSDIR%\NwcCredentialProvider_amd64.dll')
   Copy('.\Extern$\NwcCredentialProvider_amd64.dll','%WINSYSDIR%')/X/TS
  If not RegValueExists('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}','')
   RunAsEx('%comspec%','/c reg import ".\Extern$\RegCredProv.reg"','paricorp.net\dsmsis','k2295157FDF13D771CA5577EF5E847F3388G0A','1','_RV_CV',raUseLocalSystem+WaitForExecution+raLogonWithProfile+UndoneContinueParentScript)/X/x64/TS
  RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','IsEnabled','_IsEnabled',reUseX64Hive)
  If not %_IsEnabled%='1'
   RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','IsEnabled','1',mrdwSet+reUseX64Hive)/X/TS
  RegReadValueEx('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','AllowLogon','_AllowLogon',reUseX64Hive)
  If not %_AllowLogon%='2'
   If %_Ping%='True'
    RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','AllowLogon','2',mrdwSet+reUseX64Hive)/X/TS
   Else
    RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings','AllowLogon','1',mrdwSet+reUseX64Hive)/X/TS
  RunAsEx('%WINSYSDIR%\reg.exe','REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{6945E482-393E-4989-BBC3-012291FCDD4E}\Settings" /v SmallTextMessage /t REG_SZ /d "You can''t logon during the Inplace Upgrade." /f','','','1','_reg_sz',raUseLocalSystem+WaitForExecution+raHideWindow+UndoneContinueParentScript)/X/x64/TS
!   
!  #Check for Inplace Upgrade Hellper Registry Key and delete them if exists
  If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements',)
   RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements',)/X/TS
  If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart',)
   RegDeleteKey('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','StartResetOnRestart',)/X/TS
!   
!  #Set Registry Key to prevent the autologon from the "dsmruntime" user after Upgrade
  RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Changes','NoAutoLoginAfterInplaceUpgrade','1',mrdwSet+reUseX64Hive)/X/TS
!  
  If RegValueExistsEx('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried',)
   RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','ResetTried','0',mrReplace)/TS
!  
  CallScript('.\Extern$\Check-SATA-BIOS-Mode.ps1','')/X/x64/TS
  If %_SataMode%='Raid' or %_SataMode%='Ata' or %_SataMode%='unknown'
   RegModifyDWord('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\storahci','Start','0',mrdwSet+reUseX64Hive)/TS
!   RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce','*DisableSafeMode','powershell.exe -ExecutionPolicy Bypass -Command \"C:\Windows\System32\bcdedit.exe /deletevalue {current} safeboot; Restart-Computer -Force\"',mrReplace)/TS
   RunAsEx('%comspec%','/c reg import ".\Extern$\DisableSafeBoot.reg"','paricorp.net\dsmsis','k2295157FDF13D771CA5577EF5E847F3388G0A','1','_RV_REG',raUseLocalSystem+WaitForExecution+raLogonWithProfile+UndoneContinueParentScript)/X/x64/TS
!   ExecuteEx('"C:\Windows\System32\bcdedit.exe" /set {current} safeboot minimal','','5')/?/X/TW
   RunAsEx('C:\Windows\System32\bcdedit.exe','/set {current} safeboot minimal','paricorp.net\dsmsis','k2295157FDF13D771CA5577EF5E847F3388G0A','2','_RV_BCD',raUseLocalSystem+WaitForExecution+raLogonWithProfile+UndoneContinueParentScript)/X/x64/TS
  ExecuteEx('"C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe" --SecureBoot=Enabled --TpmActivation=Enabled --TpmSecurity=Enabled --EmbSataRaid=Ahci --ValSetupPwd=bi0Spw','_RV_CCTK','7')/?/X/TS
!  #Trigger Reboot
  RegModifyDWord('HKEY_LOCAL_MACHINE\SOFTWARE\Pari\Reboot','RebootFlag','2',mrdwSet+reUseX64Hive)/TS
  If %_InstallationPostponements%<='0'
   ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 60 /c "%_MessageRestart%"','','')/?/TS
   ExitProcEx(Done,'%_ReturnMessage% Anwender hat mehrmals die Installation verweigert. Installation wurde nun zwanghaft gestartet.')
  If %_RV_msgbox%='YES'
   ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 60 /c "%_MessageRestart%"','','')/?/TS
   If %_StartResetOnRestart%='8'
    ExitProcEx(Done,'%_ReturnMessage% Anwender wollte Reset bei Neustart. SmartShutdown ist wohl fehlerhaft. User hat Reset jetzt zugestimmt. Reset wird jetzt durchgeführt.')
   Else
    ExitProcEx(Done,'%_ReturnMessage% Anwender hat dem Reset zugestimmt. Reset wird jetzt durchgeführt.')
  If %_StartResetOnRestart%='1'
   ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 2 /c "%_MessageRestart%"','','')/?/TS
   ExitProcEx(Done,'%_ReturnMessage% Anwender hat dem Reset im SmartShutdown zugestimmt. Reset wird jetzt durchgeführt.')
  If %_StartResetOnRestart%='9'
   ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 2 /c "%_MessageRestart%"','','')/?/TS
   ExitProcEx(Done,'%_ReturnMessage% Anwender hat dem Reset im SmartShutdown zugestimmt. SmartShutdown ist fehlerhaft und kein User ist gerade angemeldet. Reset wird jetzt durchgeführt.')
  If %_RV_msgbox%='CANCEL'
!   ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 2 /c "%_MessageRestart%"','','')/?/TS
   ExitProcEx(Undone,'%_ReturnMessage% Kein Benutzer war angemeldet.')
  ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 60 /c "%_MessageRestart%"','','')/?/TS
  ExitProcEx(Done,'%_ReturnMessage%  Reset wird bei Neustart durchgeführt.')
 If %_RV_msgbox%='NO'
  RegModify('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\NetSupport\NetInstall\InplaceUpgrades','InstallationPostponements','%_InstallationPostponements%',mrReplace)/TS
  ExitProcEx(Undone,'Anwender hat dem Reset nicht zugestimmt. Wird bei dem nächsten Suchlauf erneut versucht. Verfügbare Aufschübe: %_InstallationPostponements%')
 Else
  ExitProcEx(Undone,'Kein Benutzer war angemeldet. Reset wird daher nicht gestartet.')
 ExecuteEx('%WINSYSDIR%\cmd.exe /C shutdown.exe /r /t 60 /c "%_MessageRestart%"','','')/?/TS
 ExitProcEx(Done,'%_ReturnMessage%  Reset wird bei Neustart durchgeführt.')
 EndInstallerSession/TW
!
: $BeginUninstallScript
!#Uninstallation not needed
