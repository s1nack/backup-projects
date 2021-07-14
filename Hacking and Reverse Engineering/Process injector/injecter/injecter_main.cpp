#include "injecter_header.h"

int EnableDebugPriv( HANDLE proceso,LPCTSTR lpName )
{
   HANDLE hToken;
   LUID DebugValue;
   TOKEN_PRIVILEGES tkp;
   
   if ( OpenProcessToken(proceso, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken))
   {
      if (LookupPrivilegeValue((LPSTR) NULL,lpName,&DebugValue))
      {
                  tkp.PrivilegeCount = 1;
                tkp.Privileges[0].Luid = DebugValue;
           tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
           AdjustTokenPrivileges(hToken,FALSE, &tkp,sizeof(TOKEN_PRIVILEGES), (PTOKEN_PRIVILEGES) NULL, (PDWORD) NULL);
           if (GetLastError() == ERROR_SUCCESS)
           {
              return TRUE;
           }
      }
   }
   return FALSE;
}

void __stdcall process_ownerII(OWNER *owner)
{
   HANDLE tproceso;
   DWORD        dwLen;
   PSID pSid=0; // contains the owning user SID
   TOKEN_USER *pWork;
   SID_NAME_USE use;
   
   OpenProcessToken(OpenProcess( PROCESS_ALL_ACCESS, TRUE,owner->pid), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &tproceso);
   GetTokenInformation(tproceso, TokenUser, NULL, 0, &dwLen);
   pWork= (TOKEN_USER *)LocalAlloc( LMEM_ZEROINIT,dwLen);
   if (GetTokenInformation(tproceso, TokenUser, pWork, dwLen, &dwLen)) {
      dwLen = GetLengthSid(pWork->User.Sid);
      pSid= (PSID)LocalAlloc( LMEM_ZEROINIT,dwLen);
      CopySid(dwLen, pSid, pWork->User.Sid);
      dwLen=256;
      LookupAccountSid(NULL, pSid, &owner->username[0], &dwLen, &owner->domainname[0], &dwLen, &use);
   }
}

void __stdcall process_owner(HANDLE htoken, char *data)
{
/*
Extract information from a process Token and dumps owner information.
   */
   DWORD        dwLen;
   PSID pSid=0; // contains the owning user SID
   TOKEN_USER *pWork;
   SID_NAME_USE use;//=0;
   TCHAR username[256];
   TCHAR domainname[256];
    
   //printf(" HTOKEN: %x",&htoken);
   
   GetTokenInformation(htoken, TokenUser, NULL, 0, &dwLen);
   pWork= (TOKEN_USER *)LocalAlloc( LMEM_ZEROINIT,dwLen);
   if (GetTokenInformation(htoken, TokenUser, pWork, dwLen, &dwLen)) {
      dwLen = GetLengthSid(pWork->User.Sid);
      pSid= (PSID)LocalAlloc( LMEM_ZEROINIT,dwLen);
      CopySid(dwLen, pSid, pWork->User.Sid);
      dwLen=256;
      LookupAccountSid(NULL, pSid, &username[0], &dwLen, &domainname[0], &dwLen, &use);
      printf("%s: \\\\%s\\%s",data,domainname,username);
   }
}

void ExtractThreadTokens( DWORD dwOwnerPID )
{
   HANDLE hThreadSnap = INVALID_HANDLE_VALUE;
   THREADENTRY32 te32;
   
   if( (hThreadSnap = CreateToolhelp32Snapshot( TH32CS_SNAPTHREAD, 0 )) != INVALID_HANDLE_VALUE )
   {
      te32.dwSize = sizeof(THREADENTRY32 );
      if( Thread32First( hThreadSnap, &te32 ) == TRUE)
      {
         do
         {
            if ( te32.th32OwnerProcessID == dwOwnerPID )
            {
               HANDLE hThread;
               hThread = OpenThread(THREAD_QUERY_INFORMATION , TRUE,te32.th32ThreadID);
               if (hThread!=NULL)
               {
                  HANDLE hToken;
                  if (OpenThreadToken(hThread, TOKEN_QUERY, TRUE, &hToken )!=0)
                  {
                     printf("   %.6i", te32.th32ThreadID );
                     process_owner(hToken,"");
                     CloseHandle(hToken);
                     printf("\n");
                  } else {
                     //printf("   #%.6i\n",te32.th32ThreadID );
                     //doFormatMessage(GetLastError());
                  }
                  CloseHandle(hThread);
               }
            }
         } while( Thread32Next(hThreadSnap, &te32 ) );
         
         CloseHandle( hThreadSnap );
         return;
      }
   }   
}

void ExtractProcessTokens( void )
{
   
   HANDLE hThreadSnap,SnapShot,proceso,hToken,hThread;//,phandle;
   PROCESSENTRY32               ProcessList;
   THREADENTRY32 te32; 
   DWORD i,tmp;
      
   SnapShot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   ProcessList.dwSize=sizeof(PROCESSENTRY32);
   
   if(Process32First(SnapShot, &ProcessList) == FALSE)
   {
      CloseHandle(SnapShot);    return;
   }
   
   while(1)
   {
      if(Process32Next(SnapShot, &ProcessList) == FALSE)
      {
         CloseHandle(SnapShot);
         break;
      }
      printf("PID %6i %.20s (%3i Threads) ",ProcessList.th32ProcessID,ProcessList.szExeFile,ProcessList.cntThreads);
      proceso=OpenProcess(PROCESS_QUERY_INFORMATION,TRUE,ProcessList.th32ProcessID);
      
      if (proceso!=NULL)
      {
         if(OpenProcessToken(proceso, TOKEN_QUERY, &hToken))
         {
            process_owner(hToken," USER");
            printf("\n");
            CloseHandle(hToken);
            CloseHandle(proceso);
         } else
         {
            printf("\r                                                                          \r");
         }
         ExtractThreadTokens(ProcessList.th32ProcessID);
      } else
      {
         printf("\r                                                                          \r");
      }
   }  
}

void doFormatMessage( unsigned int dwLastErr )  {
   char cadena[512];
   LPVOID lpMsgBuf;
   FormatMessage(
      FORMAT_MESSAGE_ALLOCATE_BUFFER |
      FORMAT_MESSAGE_IGNORE_INSERTS |
      FORMAT_MESSAGE_FROM_SYSTEM,
      NULL,
      dwLastErr,
      MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ),
      (LPTSTR) &lpMsgBuf,
      0,
      NULL );
   sprintf(cadena,"ERRORCODE %i: %s\n", dwLastErr, lpMsgBuf);
   printf("Error: %s\n",cadena);
   LocalFree( lpMsgBuf  );
}

void usage()
{
   wprintf(L"Usage:\n");
   wprintf(L" inject.exe -l                    (Enumerate Credentials)\n");
   wprintf(L" inject.exe -p <pid> <cmd> <port> (Inject into PID)\n");
   exit(1);
}

void main(int argc, char* argv[])
 {
    int i;
    BOOL list=0;
    BOOL PID=0;
    BOOL THREAD=1;
     
    wprintf(L"Injecter for Win32\n");
 
    if (argc==1) usage();
    
    for(i=1;i<argc;i++)
    {
       if ( (strlen(argv[i]) ==2) && (argv[i][0]=='-') )
       {
          switch(argv[i][1])
          {
 
          case 'h':
          case 'H':
          case '?':
             usage();
             break;
          case 'l':
          case 'L':
             list=TRUE;
             break;
          case 't':
          case 'T':
             break;
          case 'p':
          case 'P':
             break;
          }
       }
    }
       EnableDebugPriv(GetCurrentProcess(),SE_DEBUG_NAME);
       if (list) {
          ExtractProcessTokens();
       }
	wprintf(L"\n");
    return;
}