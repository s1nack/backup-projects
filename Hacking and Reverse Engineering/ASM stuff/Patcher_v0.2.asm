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
				
		.elseif eax==IDM_TestAjoutMarc

				invoke AjoutSection

		.endif
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

 	invoke CreateFileMapping,hMapping,NULL,PAGE_READONLY,0,0,addr NomObjetMappe
 	mov pMapping, eax
 		       
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
	xor eax,eax		
	ret

Erreur endp


AjoutSection proc uses esi edi
	
	invoke GetDlgItemText, hWnd, 1013, addr pFile, 256d
	
	invoke CreateFile,addr pFile,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov hMapping, eax

 	invoke CreateFileMapping,hMapping,NULL,PAGE_READWRITE,0,0,addr NomObjetMappe
 	mov pMapping, eax
 	
 	invoke MapViewOfFile, pMapping,FILE_MAP_ALL_ACCESS, 0, 0, 0
    mov pMapping2, eax
    
    mov edi, pMapping2
    assume edi: ptr IMAGE_DOS_HEADER

    add edi, [edi].e_lfanew
    assume edi: ptr IMAGE_NT_HEADERS
    
    mov eax, [edi].OptionalHeader.SizeOfImage
    mov SizeOfImage, eax
    
    mov eax, [edi].OptionalHeader.ImageBase
    mov ImageBase, eax
    
    mov eax, [edi].OptionalHeader.AddressOfEntryPoint
    mov AddressOfEntryPoint, eax
    
    movzx eax, [edi].FileHeader.NumberOfSections    ;c'est la proc qui indique au loader
    mov NumberOfSections, eax                       ;que ta section existe
    inc NumberOfSections                            ;mais ça n'ajoute pas à proprement parler
    mov eax, NumberOfSections                       ;ta section,pour ça il faut son adresse
    mov [edi].FileHeader.NumberOfSections, ax       ;et la remplir avec ton code.
    
    mov eax, [edi].OptionalHeader.SectionAlignment
    mov SectionAlignment, eax
    
    mov eax, [edi].OptionalHeader.FileAlignment
    mov FileAlignment, eax
    
    mov esi, edi
    assume esi: ptr IMAGE_NT_HEADERS
    
    add edi, sizeof IMAGE_NT_HEADERS
    assume edi: ptr IMAGE_SECTION_HEADER
    push edi
    
    mov eax, NumberOfSections
    sub eax, 2
    mov ebx, sizeof IMAGE_SECTION_HEADER
    mul ebx
    add edi, eax
    
    mov eax, [edi].VirtualAddress
    mov VirtualAddress, eax
    
    mov eax, [edi].Misc.VirtualSize
    mov VirtualSize, eax
    
    mov eax, [edi].PointerToRawData
    mov PointerToRawData, eax

    mov eax, [edi].SizeOfRawData
    mov SizeOfRawData, eax

    add edi, sizeof IMAGE_SECTION_HEADER

    mov eax, VirtualAddress                	  ;ici on va chercher l'adresse à laquelle doit             
    mov ebx, VirtualSize               	 	  ;commencer la section qu'on ajoute
    add ebx, eax                       	    	  ;elle se trouve juste après la dernière section
    .WHILE eax<ebx                          
        add eax, SectionAlignment
    .ENDW
    mov [edi].VirtualAddress, eax
    mov VirtualAddress, eax                 	  ;voilà l'adresse de notre section (en mémoire!)

    mov eax, PointerToRawData
    mov ebx, SizeOfRawData
    add ebx, eax
    .WHILE eax<ebx
        add eax, FileAlignment
    .ENDW
    mov [edi].PointerToRawData, eax
    mov PointerToRawData, eax                     ;voilà l'adresse de notre section (en dur!)

    mov edx, 1000h                                ;pourquoi 1000h ?

    xor eax, eax
    .WHILE eax < edx
        add eax, FileAlignment
    .ENDW
    mov [edi].SizeOfRawData, eax
    mov SizeOfRawData, eax
    mov [edi].Misc.VirtualSize, eax
    assume edi: ptr IMAGE_NT_HEADERS
    mov edx, [esi].OptionalHeader.SizeOfImage
    add edx, eax
    mov [esi].OptionalHeader.SizeOfImage, edx

	assume edi: ptr IMAGE_SECTION_HEADER
    mov [edi].Characteristics, 0E0000060h

    mov dword ptr [edi], "marc"             	;"xxx" est le nom de la nouvelle section
                                          	;si la taille est > DWORD, il faut en faire plusieurs.

    invoke UnmapViewOfFile, pMapping2
    invoke CloseHandle, pMapping
    
    mov eax, PointerToRawData
    add eax, SizeOfRawData                      ;eax=la taille du fichier avec notre code ajouté
    
    invoke CreateFileMapping, hMapping, NULL, PAGE_READWRITE, 0, eax, 0
    mov pMapping, eax
    invoke MapViewOfFile, pMapping,FILE_MAP_ALL_ACCESS, 0, 0, 0
    mov pMapping2, eax
    push edi


	mov eax, [edi].VirtualAddress
	mov TempVirtualAddress, eax
    invoke RVAToOffset, pMapping2, TempVirtualAddress
    add eax, pMapping2
    mov edx, SizeOfRawData
    .WHILE edx > 0
        mov byte ptr [eax+edx-1], 16h           ;padding de la section pour que les modifications soient prises 						;en compte
        dec edx
    .ENDW
    
    mov CodeCompile, 8bh
    mov bl, CodeCompile

;	.WHILE (eax)
;		invoke ReadCode ;(ecrit le caractere lu dans un .data)
;		mov section pointer, caractere (dans le .data)
;	.endw
	
	mov edx,1
	mov byte ptr [eax+edx-1], 8Bh
	inc edx
	mov byte ptr [eax+edx-1], 0D8h
	
    pop edi
    
    mov eax, [edi].VirtualAddress
    mov TempVirtualAddress, eax                                                      
    invoke RVAToOffset, pMapping2, TempVirtualAddress
    add eax, pMapping2
    mov ebx, eax

    mov edi, pMapping2
    assume edi:ptr IMAGE_DOS_HEADER
    add edi, [edi].e_lfanew
    assume edi:ptr IMAGE_NT_HEADERS
    mov eax, VirtualAddress
    mov [edi].OptionalHeader.AddressOfEntryPoint, eax        ;EntryPoint modifié, pointe maintenant sur le début 
                                                            ;de la nouvelle section
    push eax                                                

    add edi, sizeof IMAGE_NT_HEADERS                            
    assume edi:ptr IMAGE_SECTION_HEADER
    xor eax, eax
    .WHILE eax<AddressOfEntryPoint
        add edi, sizeof IMAGE_SECTION_HEADER
        mov eax, [edi].VirtualAddress
    .ENDW
    sub edi, sizeof IMAGE_SECTION_HEADER
    
    mov eax, [edi].VirtualAddress
    mov VirtualAddressCode, eax
    
    mov eax, [edi].SizeOfRawData
    mov SizeOfRawDataCode, eax
    
    mov eax, [edi].PointerToRawData
    mov PointerToRawDataCode, eax

    mov [edi].Characteristics, 0E0000060h

    pop eax
    mov eax, ebx
	invoke UnmapViewOfFile, pMapping2
    invoke CloseHandle, pMapping
    invoke CloseHandle, hMapping
    assume edi:nothing
    assume esi:nothing
    
    xor eax,eax
    
    
	ret

AjoutSection endp


RVAToOffset proc uses edi esi edx ecx pFileMap:DWORD, RVA:DWORD ;pMapping2
	
	mov esi, pFileMap
    assume esi:ptr IMAGE_DOS_HEADER
        add esi, [esi].e_lfanew                                    
    assume esi:ptr IMAGE_NT_HEADERS                             ;on avance de structure en structure..
    mov edi, RVA
    mov edx, esi
    add edx, sizeof IMAGE_NT_HEADERS
    mov cx, [esi].FileHeader.NumberOfSections                   
    movzx ecx, cx
    assume edx:ptr IMAGE_SECTION_HEADER
    .WHILE ecx>0                                                ;tant qu'il y a une section...
        .IF edi>=[edx].VirtualAddress                            ;si la RVA est plus loin que le début de la section..
            mov eax, [edx].VirtualAddress
            add eax, [edx].SizeOfRawData                        ;et si elle est moins loin que la fin de la section..
            .IF edi<eax
                mov eax, [edx].VirtualAddress
                sub edi, eax                                    ;il ne reste que le décalage
                mov eax, [edx].PointerToRawData                 ;qu'on ajoute au début du RawData (data en dur)
                add eax, edi                                    ;et on obtient l'offset dans le fichier

                ret
            .ENDIF
        .ENDIF
        add edx, sizeof IMAGE_SECTION_HEADER
        dec ecx
    .ENDW
    assume esi:nothing
    assume edx:nothing
    mov eax, edi

	ret
	
RVAToOffset endp

;ReadCode proc hFile:DWORD
;		
;;	invoke SetFilePointer,hFile,count,NULL,FILE_BEGIN
;	
;;	invoke ReadFile,hFile,		: on doit ecrire dans une .data
;	
;	
;	
;	ret
;
;ReadCode endp
;
;
;GetExe proc
;
;	mov eax, offset StFile
;
;	invoke FindFirstFile, addr NomExe, StFile
;	mov hSearchFile, eax
;	
;	invoke SetDlgItemInt, hWnd, 1001, addr hSearchFile,TRUE
;	xor eax,eax
;	
;	
;	ret
;
;GetExe endp

end start



; le 25/10 
; problème avec le dumper: les valeurs des header sont en decimal, il faut une sortie en hexa
; mais SetDlgItemInt ne gère pas ça. Il faut convertir avant.
; Creation de la proc AjoutSection

;le 26/10
; j'ai fini la proc AjoutSection et après vérification, tout fonctionne sauf la modification de
; VirtualSize. 
; Problème: si le patcher ajoute du code avec un fichier texte, comment restaurer l'entrypoint
; puisque le code est déjà compilé?

; le 27/10
; Le patcher est presque terminé, le bug de VirtualSize est fixé, ne manquent que les procédures de Cryptage et de Fichier Texte
; Je pense que Fravia ne connaissait pas le shit, sinon il n'aurait jamais dit que l'alcool
; aide à coder.. La soirée "Hoggar m'a tuer" = pas de code. Il faut cesser!
; Et il faut convertir le décimal en héxa dans le dumper!

; le 28/10
; Sofiane m'a dit qu'il fallait utiliser un algo fait main pour le décimal->héxa
; Restent à faire:
; 			- Fonction cryptage
;			- Remplir la nvelle section avec un fichier texte
;			- Retrouver de la doc sur la recherche de "kernel32.dll" en mémoire, puis GetProcAdress
;			- Mettre la routine de décryptage

; Pour la proc de recherche des fichiers exe du système, trouver de la doc sur la transmission 
; de structure par référence (appel invoke). Un OFFSET StructName donne 0.
; Comment récupérer l'adresse d'une structure? Ou un pointeur?
; 