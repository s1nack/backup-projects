.386
.model flat,stdcall
option casemap:none

include Patcher2.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	mov		CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.elseif eax==IDM_TestBoutonMarc
				invoke GetPEInfos
		.endif
;	.elseif eax==WM_SIZE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp


GetPEInfos proc uses edi
	invoke GetDlgItemText, hWnd, 1003, addr pFile, 256d
	
	
	invoke CreateFile,addr pFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,NULL
	mov hMapping, eax
	;.if eax==;bug!
	;	invoke Erreur,1
	;	ret
	;.endif

 	invoke CreateFileMapping,hMapping,NULL,PAGE_READONLY,0,0,addr NomObjetMappe
 	mov pMapping, eax
	;mov ebx, ;bug!
	;xor eax,ebx
 	;.if eax==0
 	;	invoke Erreur,2
 	;	ret
 	;.endif
 		       
    invoke MapViewOfFile, pMapping, FILE_MAP_READ, 0, 0, 0
    mov pMapping2, eax
    
    mov edi, pMapping2
    assume edi: ptr IMAGE_DOS_HEADER

    add edi, [edi].e_lfanew
    assume edi: ptr IMAGE_NT_HEADERS
    
	xor eax,eax
	
    mov ax, [edi].FileHeader.NumberOfSections
    mov NumberOfSections, eax
    invoke SetDlgItemInt,hWnd,1001,NumberOfSections,TRUE
    
    mov eax, [edi].OptionalHeader.AddressOfEntryPoint
    mov AddressOfEntryPoint, eax
    invoke SetDlgItemInt,hWnd,1004,AddressOfEntryPoint,TRUE
    
    mov eax, [edi].OptionalHeader.SectionAlignment
    mov SectionAlignment, eax
    invoke SetDlgItemInt,hWnd,1009,SectionAlignment,TRUE

    mov eax, [edi].OptionalHeader.ImageBase
    mov ImageBase, eax
    invoke SetDlgItemInt,hWnd,1011,ImageBase,TRUE

    invoke CloseHandle,hMapping
    invoke CloseHandle,pMapping
    invoke UnmapViewOfFile,pMapping2
	xor eax,eax
	ret
GetPEInfos endp

Erreur proc CodeErreur:DWORD
	
	xor eax,eax
	.if CodeErreur==1
		invoke MessageBox,hWnd,addr Erreur1,ErreurTitre,MB_OK
		ret
	.elseif CodeErreur==2
		invoke MessageBox,hWnd,addr Erreur2,ErreurTitre,MB_OK
		ret
	.elseif CodeErreur==3
		invoke MessageBox,hWnd,addr Erreur3,ErreurTitre,MB_OK
		ret
	.endif			
	ret

Erreur endp

end start