GetPEInfos proc uses edi
	invoke GetDlgItemText, hWnd, 1003, addr pFile, 256d
	

	invoke CreateFile,addr pFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,NULL
	mov hMapping, eax
	.IF (!eax)
		invoke Erreur,1
		ret
	.ENDIF
	
 	invoke CreateFileMapping,hMapping,NULL,PAGE_READONLY,0,0,addr NomObjetMappe
 	mov pMapping, eax
 		.IF (!eax)
		invoke Erreur,2
		ret
	.ENDIF
 		       
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