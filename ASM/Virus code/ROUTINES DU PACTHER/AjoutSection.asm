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
    
    movzx eax, [edi].FileHeader.NumberOfSections    
    mov NumberOfSections, eax                       
    inc NumberOfSections                            
    mov eax, NumberOfSections                      
    mov [edi].FileHeader.NumberOfSections, ax    
    
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

    mov eax, VirtualAddress         	              
    mov ebx, VirtualSize       	 	  
    add ebx, eax 
    .WHILE eax<ebx                          
        add eax, SectionAlignment
    .ENDW
    mov [edi].VirtualAddress, eax
    mov VirtualAddress, eax                 	  

    mov eax, PointerToRawData
    mov ebx, SizeOfRawData
    add ebx, eax
    .WHILE eax<ebx
        add eax, FileAlignment
    .ENDW
    mov [edi].PointerToRawData, eax
    mov PointerToRawData, eax                     

    mov edx, 1000h                                

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

    mov dword ptr [edi], "cram"             	
                                          	

    invoke UnmapViewOfFile, pMapping2
    invoke CloseHandle, pMapping
    
    mov eax, PointerToRawData
    add eax, SizeOfRawData                      
    
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
        mov byte ptr [eax+edx-1], 16h           ;padding de la section
        dec edx
    .ENDW
    
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
    mov [edi].OptionalHeader.AddressOfEntryPoint, eax         
                                                            
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
