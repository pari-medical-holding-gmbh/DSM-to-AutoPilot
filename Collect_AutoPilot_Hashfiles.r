!***************************************************************************************************
!Autor: FaserF
!Datum: 14.09.2022 - 14:19:37
!---------------------------------------------------------------------------------------------------------------------------
!Beschreibung:
!Dieses Paket sammelt die AutoPilot Hashfiles und legt sie auf einem Netzlaufwerk ab. 
!---------------------------------------------------------------------------------------------------------------------------
!Änderungen:
!14.09.2022: rev V001: fseitz: Paket erstellt
!***************************************************************************************************
!
!Define Variables
Set('_RV','0')
Set('_LogPath','\\servernetworkdrive\enteo$\Log\AutoPilot')
Set('_CSVPath','C:\temp\autopilot_%CurrentComputer.Object.Name%.csv')
!
If not CheckInstallMode(imUninstall)
! Installation
 Copy('.\Extern$\Get-WindowsAutopilotInfos.ps1','C:\ProgramData')/TS
 CallScript('C:\ProgramData\Get-WindowsAutopilotInfos.ps1','')/x64/TS
!
 If %_RV%='0'
!  If Exist('%_LogPath%')
!   If Exist('%_CSVPath%')
!    Copy('%_CSVPath%','%_LogPath%')/U/TS
!    ExitProcEx(Done,'CSV Hardware Hash abgelegt unter %_LogPath%_%CurrentComputer.Object.Name%.csv')
!   Else
!    ExitProcEx(Failed,'CSV Datei nicht gefunden')
!  Else
!   ExitProcEx(Undone,'Netzlaufwerk nicht verfügbar. Versuche es später erneut.')
  ExitProcEx(Done,'CSV Hardware Hash abgelegt unter %_LogPath%_%CurrentComputer.Object.Name%.csv')
 If %_RV%='9'
  ExitProcEx(Undone,'Netzlaufwerk nicht verfügbar. Versuche es später erneut.')
 Else
  ExitProcEx(Failed,'Fehler %_RV% bei der Installation.')
