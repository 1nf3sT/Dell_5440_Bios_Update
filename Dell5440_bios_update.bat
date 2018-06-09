::Turns Displaying commands off
@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
echo #######################################################
echo Launching Bios Update
echo Version: 1.14
echo Author: Joachim Theils
echo Date modified: 01-02-2018
echo Changelog:
echo 1.00: First release
echo 1.10: Added popup message if battery level under 10 percent
echo 1.11: Fixed the battery read loop error
echo 1.12: Updated install.bat with bcdedit /timeout 0, so we are on Standard Script 1.03b
echo 1.13: Started using variables and added check if BIOS is already greater than update.
echo ____: Updated activation script to current (1.07)
echo 1.13_2: Fixed deletion of BIOS after update
echo 1.14: Fixed reboot problem. Changed interaction with BiosUpdate. Added logic to run Activation if Bios is up to date. Cleaned up some small errors. 
echo #######################################################
:: Check current Bios Version
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

::Variables for Bios Check
SET BIOSupdateVersion=A18
SET BIOStext.Y=Bios is already updated
SET BIOStext.N=Bios Needs Update

::Get Bios Version
SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`wmic bios get smbiosbiosversion`) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)
::Display update situation
IF %var2% GEQ %BIOSupdateVersion% (echo %BIOStext.Y% & GOTO clean) ELSE (echo %BIOStext.N% & set BiosShutdown=1 & GOTO batstatus)

:: Localize variables
:batstatus
:: Variables to translate the returned BatteryStatus integer to a descriptive text
SET BatteryStatus.1=discharging
SET BatteryStatus.2=The system has access to AC so no battery is being discharged. However, the battery is not necessarily charging.
SET BatteryStatus.3=fully charged
SET BatteryStatus.4=low
SET BatteryStatus.5=critical
SET BatteryStatus.6=charging
SET BatteryStatus.7=charging and high
SET BatteryStatus.8=charging and low
SET BatteryStatus.9=charging and critical
SET BatteryStatus.10=UNDEFINED
SET BatteryStatus.11=partially charged

:: More variables
SET batteriLowest=10

:: Read the battery status
FOR /F "tokens=*" %%A IN ('WMIC Path Win32_Battery Get BatteryStatus /Format:List ^| FIND "="') DO SET %%A

:: Check the battery status, and display a warning message if running on battery power
IF NOT "%BatteryStatus%"=="2" (
    > "%~dpn0.vbs" ECHO MsgBox vbLf ^& "The laptop is currently running on its battery or needs atleast %batteriLowest% percent power." ^& vbLf ^& vbLf ^& "The battery is !BatteryStatus.%BatteryStatus%!." ^& vbLf ^& vbLf ^& "Connect the laptop to the mains voltage if possible." ^& vbLf ^& " "^, vbWarning^, "Battery Warning"
    CSCRIPT //NoLogo "%~dpn0.vbs"
    DEL "%~dpn0.vbs"
)
:: Loop until battery status is 2
IF NOT "%BatteryStatus%"=="2" GOTO batstatus

:popup
:: Read the battery percentage
FOR /F "delims=" %%i IN ('WMIC Path Win32_Battery Get EstimatedChargeRemaining /Format:List ^| FIND "="') DO set batterypercent=%%i

:: Convert to number instead of text
set batteriresult=%batterypercent:~25%

:: Check the battery percentage, and display a warning message if running under 10% battery power
IF %batteriresult% LEQ %batteriLowest% (
    > "%~dpn0.vbs" ECHO MsgBox vbLf ^& "The laptop is currently running on its battery." ^& vbLf ^& vbLf ^& "The battery percentage is under 15 percent and needs to be above." ^& vbLf ^& vbLf ^& "Connect the laptop to a charger in order to run Bios Update." ^& vbLf ^& " "^, vbWarning^, "Battery Warning"
    CSCRIPT //NoLogo "%~dpn0.vbs"
    DEL "%~dpn0.vbs"
)
:: Loop until battery value is equal or greater than percent
IF %batteriresult% LEQ %batteriLowest% (
GOTO popup
)
:: Start BIOS update without GUI
echo Updating Bios Version...
echo Current: %var2%
echo New: %BIOSupdateVersion%
start "" "%userprofile%\Desktop\E5440A18.exe" /s /f

:clean
echo Cleaning, moving and shutting down
:: Moving new bat file, from Desktop to Start folder, or if Bios was already up to date, just run activation.
IF %BiosShutdown% EQU 1 (
	MOVE "%userprofile%\Desktop\newfile.bat" "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\newfile.bat"
	) ELSE (
	START cmd /c Call "%userprofile%\Desktop\newfile.bat")
:: Delete VBS file if its still there
IF EXIST "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Dell5440_bios_update.vbs" del "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Dell5440_bios_update.vbs"
:: Shutdown if Bios update ran succesfully
IF %BiosShutdown% EQU 1 (shutdown /f /r /t 3 /c "Finishing Bios Update")
:: Delete Self
(goto) 2>nul & del "%~f0"