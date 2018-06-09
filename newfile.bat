@echo off
echo Activation script for Windows 7-10 and Office 2010-2016
echo Version 1.07c
echo Date: 01-02-2018
echo Author: Joachim Theils

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
@echo off & @setlocal enableextensions

::-------------------------------------------------
::				Internet Check
@echo off
setlocal EnableDelayedExpansion
set /a counter=0
goto SOF

::Restart jump
:_Restart
ipconfig /release
cls
echo Restart
SHUTDOWN /r /f /t 5 /c "Restarting because: No Internet"
exit

::Internet check jump
:SOF
ping -n 2 -w 700 8.8.8.8 | find "bytes="
IF %ERRORLEVEL% EQU 0 (
    SET internet=Connected
) ELSE (
    SET internet=No_internet
)
echo %internet%
if %internet% EQU Connected (
	goto SIF
) ELSE (
	set /a counter+=1
)
echo Internet test %counter%
if %counter% GEQ 60 (
	echo No Internet & goto _Restart
) ELSE (
goto SOF)
::Continue script jump
:SIF
::Runnig script
::-------------------------------------------------

@echo =========================
@echo Turn off the time service
net stop w32time
@echo ======================================================================
@echo Set the SNTP (Simple Network Time Protocol) source for the time server
w32tm /config /syncfromflags:manual /manualpeerlist:"0.dk.pool.ntp.org 1.dk.pool.ntp.org 2.dk.pool.ntp.org 3.dk.pool.ntp.org"
@echo =============================================
@echo ... and then turn on the time service back on
net start w32time
@echo =============================================
@echo Tell the time sync service to use the changes
w32tm /config /update
@echo =======================================================
@echo Reset the local computer's time against the time server
w32tm /resync /rediscover
@endlocal
cls
::Force Windows to Activate
echo ########################### Windows Activasion ###########################
cscript //nologo "%systemroot%\system32\slmgr.vbs" /ato
echo ################################### End ##################################
REM Check for office version and activate
@echo off
REM Find Office 32 or 64 bit location
echo --------------------------------------------------------------------------
echo ########################### Office Activasion ############################
:testx32_2010
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office14\OSPP.VBS" (
cscript "C:\Program Files (x86)\Microsoft Office\Office14\OSPP.VBS" /act
goto EndOfScript
) else (goto testx64_2010
)

:testx64_2010
IF EXIST "C:\Program Files\Microsoft Office\Office14\OSPP.VBS" (
cscript "C:\Program Files\Microsoft Office\Office14\OSPP.VBS" /act
goto EndOfScript
) else (goto testx32_2013
)

:testx32_2013
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS" (
cscript "C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS" /act
goto EndOfScript
) else (goto testx64_2013
)

:testx64_2013
IF EXIST "C:\Program Files\Microsoft Office\Office15\OSPP.VBS" (
cscript "C:\Program Files\Microsoft Office\Office15\OSPP.VBS" /act
goto EndOfScript
) else (goto testx32_2016
)

:testx32_2016
IF EXIST "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" (
cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /act
goto EndOfScript
) else (goto testx64_2016
)

:testx64_2016
IF EXIST "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" (
cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /act
goto EndOfScript
) else (echo Office 2010, 2013 or 2016 is not installed, correct this!
pause
exit
)

:EndOfScript
IF %ERRORLEVEL% EQU 0 (
    echo ############################ Office Activated ############################ & goto Shutoff
) ELSE (
    echo "Office activation failed, restarting" & timeout 60 & goto _Restart
)


:Shutoff
echo Vil du lukke computeren og rydde op
pause
ipconfig /release
::Delete all kinds of file history
Del /F /Q %APPDATA%\Microsoft\Windows\Recent\*
Del /F /Q %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*
Del /F /Q %APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*
REG Delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /VA /F
REG Delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths /VA /F

del "%userprofile%\Desktop\E5440A18.exe"
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f
shutdown /s /f /t 3
(goto) 2>nul & del "%~f0"
@goto :EOF