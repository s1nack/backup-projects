#ifndef __INJECT__
#define __INJECT__

#include <stdio.h>
#include <winsock2.h>
#include <Winbase.h>
#include <process.h>
#include <Tlhelp32.h>

#ifndef __BORLANDC__
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "advapi32.lib")

#endif


typedef struct _OWNER{
   DWORD  pid;
   TCHAR  username[256];
   TCHAR domainname[256];
} OWNER;

#endif