include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetPEInfos			PROTO
Erreur				PROTO :DWORD
AjoutSection		PROTO
RVAToOffset 		PROTO :DWORD,:DWORD
GetExe				PROTO
DialogProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

ptest				proto
IDD_DIALOG			equ 1000
IDC_TAB1			equ 1017
IDC_STC1			equ 1018
IDD_DLG1			equ 2000
IDM_MENU			equ 10000
IDM_FILE_EXIT		equ 10001
IDM_TestBoutonMarc  equ 10002
IDM_TestAjoutMarc	equ 10003
IDM_HELP_ABOUT		equ 10101


ctxt macro Text
	local szText
	.data
	szText byte Text, 0
	.code
	exitm <offset szText>	
endm


.data

FPStruct struct
	Internal		DWORD ?
	InternalHigh	DWORD ?
	Count			DWORD ?
	OffsetHigh		DWORD ?
	hEvent			HANDLE ?
FPStruct ends

 


.const

ClassName			db 'DLGCLASS',0
AppName				db 'Bombyx Tool',0
AboutMsg			db 'Compile avec Masm32',13,10,'Copyright © BOMBYX 2006',0
NomObjetMappe		db 'Nom Objet Mappe',0
ErreurTitre			db 'Erreur',0
Erreur1				db 'Fichier Inexistant ',0
Erreur2				db 'Le Mapping du fichier a echoue',0
debug1				db 'debug juste apres test',0

ExeName				db 'Patcher2.exe',0
FileName			db 'testfile.txt',0
;NomExe				db '*.exe'


.data?

hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?
Buffer 				db 20 dup(?)


NumberOfSections    dd ?
SectionAlignment	dd ?
AddressOfEntryPoint dd ?
ImageBase			dd ?
FileAlignment		dd ?
VirtualAddress		dd ?
VirtualSize			dd ?
PointerToRawData	dd ?
SizeOfRawData 		dd ?
SizeOfImage			dd ?
PointerToRawDataCode	dd ?
SizeOfRawDataCode		dd ?
VirtualAddressCode		dd ?
TempVirtualAddress		dd ?

CodeCompile			db ?

;SearchFile			dd ?

pFile 				dd ?
hMapping			HINSTANCE ?
pMapping 			dd ?
pMapping2		    dd ?

hProc				dd ?
hFile				dd ?
nbFileRead			UINT ?
pAdresse			dd ?
nbMemoryRead		UINT ?


hTabStrip	dd	?
szTemp db 128 dup (?)
hTab	dd ?

;StFile struct
;	dwFileAttributes	DWORD ?
;    StFileParam			DWORD ?
; 	StFileParam2		DWORD ?
;	StFileParam3 		DWORD ?
;    nFileSizeHigh		DWORD ?
;    nFileSizeLow		DWORD ?
;    dwReserved0			DWORD ?
;    dwReserved1			DWORD ?
;    cFileName			TCHAR ?
;    cAlternateFileName	TCHAR ?
;StFile ends
;
;StFileParam struct
;	dwLowDateTime		DWORD ?
;    dwHighDateTime		DWORD ?
;StFileParam ends
;
;StFileParam2 struct
;	dwLowDateTime		DWORD ?
;    dwHighDateTime		DWORD ?
;StFileParam2 ends
;
;StFileParam3 struct
;	dwLowDateTime		DWORD ?
;    dwHighDateTime		DWORD ?
;StFileParam3 ends