@ECHO OFF
SETLOCAL
SET count=1
SET count2=1

ECHO.
ECHO The following profiles were found :
ECHO.

FOR /F "delims=" %%G IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Profilelist" /f S-') DO ^
call :s_do_entries "%%G"

ECHO.
SET /P nSource=Select the profile you want to retrieve (Ex: 1) : 
SET /P nDest=Select the destination profile (Ex: 2) : 
ECHO.

FOR /F "delims=" %%I IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Profilelist" /f S-') DO ^
call :s_get_source "%%I"
ECHO SRC=%src_profile%

set count2=1
FOR /F "delims=" %%I IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Profilelist" /f S-') DO ^
call :s_get_dest "%%I"
set DST=%DST:~1,-1%

echo REG DELETE "%DST%" /v ProfileImagePath
echo reg add "%DST%" /v ProfileImagePath /t REG_EXPAND_SZ /d "%src_profile%"

:s_get_source
 IF %count2% == %nSource% (
 set /a count2+=1
 FOR /F "tokens=3" %%J IN ('reg query %1 ^| Find "ProfileImagePath"') DO (set src_profile=%%J)
 GOTO:EOF
 ) ELSE (
 set /a count2+=1
 GOTO:EOF
 )

:s_get_dest
 IF %count2% == %nDest% (
 set /a count2+=1
 set DST=%1
 GOTO:EOF
 ) ELSE (
 set /a count2+=1
 GOTO:EOF
 )

:s_do_entries
 set arg=%1
 IF NOT DEFINED arg GOTO:EOF
 set _prefix=%arg:~1,4%
 IF NOT %_prefix%==HKEY GOTO:EOF
 FOR /F "tokens=3" %%H IN ('reg query %1 ^| Find "ProfileImagePath"') DO (call :s_do_profiles %%H)
 GOTO:EOF

:s_do_profiles
 echo %count% = %1
 set /a count+=1
 GOTO:EOF