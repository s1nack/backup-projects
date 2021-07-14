RVAToOffset proc uses edi esi edx ecx pFileMap:DWORD, RVA:DWORD ;pMapping2
	
	mov esi, pFileMap
    assume esi:ptr IMAGE_DOS_HEADER
        add esi, [esi].e_lfanew                                    
    assume esi:ptr IMAGE_NT_HEADERS                             
    mov edi, RVA
    mov edx, esi
    add edx, sizeof IMAGE_NT_HEADERS
    mov cx, [esi].FileHeader.NumberOfSections                   
    movzx ecx, cx
    assume edx:ptr IMAGE_SECTION_HEADER
    .WHILE ecx>0                                                
        .IF edi>=[edx].VirtualAddress                            
            mov eax, [edx].VirtualAddress
            add eax, [edx].SizeOfRawData                        
            .IF edi<eax
                mov eax, [edx].VirtualAddress
                sub edi, eax                                    
                mov eax, [edx].PointerToRawData                 
                add eax, edi                                    

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