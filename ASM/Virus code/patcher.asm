            ;proc�dure pour ajouter une section

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AjoutSection    proc uses esi edi                   ;ils vont servir de marque-page pour
                                                    ;certains "chapitres" des headers.

    ;on suppose que la data pMapping est le handle r�cup�r� apr�s le mapping de l'exe
    ;on suppose aussi la d�claration ant�rieure des data comme ImageBase, AdressOfEntryPoint,
    ;NumbersOfSections, etc. 


    mov edi, pMapping
    assume edi: ptr IMAGE_DOS_HEADER                ;assume permet d'associer un registre �
                                                    ;une structure, ce qui permet d'acc�der � ses
                                                    ;membres donn�es plus facilement
                                                    ;c'est l'�quivalent des classes en c++
    add edi, [edi].e_lfanew
    assume edi: ptr IMAGE_NT_HEADERS

    mov eax, [edi].OptionalHeader.ImageBase
    mov ImageBase, eax

    mov eax, [edi].OptionalHeader.AdressOfEntryPoint
    mov AdressOfEntryPoint, eax

    movzx eax, [edi].FileHeader.NumberOfSections    ;c'est la proc qui indique au loader
    mov NumberOfSections, eax                       ;que ta section existe
    inc NumberOfSections                            ;mais �a n'ajoute pas � proprement parler
    mov eax, NumberOfSections                       ;ta section,pour �a il faut son adresse
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
                                                    ;la premi�re table des sections

    mov eax, NumberOfSections
    sub eax, 2
    mov ebx, sizeof IMAGE_SECTION_HEADER
    mul ebx
    add edi, eax                                    ;on ajoute eax (la taille de toutes les 
                                                    ;sections - 2) � edi (d�but des sections)
                                                    ;pour atterrir sur la derni�re section (en
                                                    ;fait, sur l'avant-derni�re, mais la derni�re
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

    mov eax, VirtualAdress                	  ;ici on va chercher l'adresse � laquelle doit             
    mov ebx, VirtualSize               	 	  ;commencer la section qu'on ajoute
    add ebx, eax                       	    	  ;elle se trouve juste apr�s la derni�re section
    .WHILE eax<ebx                          
        add eax, SectionAlignment
    .ENDW
    mov [edi].VirtualAdress, eax
    mov VirtualAdress, eax                 	  ;voil� l'adresse de notre section (en m�moire!)

    mov eax, PointerToRawData
    mov ebx, SizeOfRawData
    add ebx, eax
    .WHILE eax<ebx
        add eax, FileAlignment
    .ENDW
    mov [edi].PointerToRawData, eax
    mov PointerToRawData, eax                     ;voil� l'adresse de notre section (en dur!)

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
    add eax, SizeOfRawData                      ;eax=la taille du fichier avec notre code ajout�
    
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
    mov [edi].OptionalHeader.AdressOfEntryPoint, eax        ;EntryPoint modifi�, pointe maintenant sur le d�but 
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
                                                                            ; et pFileMap pointe sur le d�but du prog load�

    mov esi, pFileMap
    assume esi:ptr IMAGE_DOS_HEADER                             ;toujours pareil, on se d�place dans les header avec assume
    add esi, [esi].e_lfanew                                    
    assume esi:ptr IMAGE_NT_HEADERS                             ;on avance de structure en structure..
    mov edi, RVA
    mov edx, esi
    add edx, sizeof IMAGE_NT_HEADERS
    mov cx, [esi].FileHeader.NumberOfSections                   
    movzx ecx, cx
    assume edx:ptr IMAGE_SECTION_HEADER
    .WHILE ecx>0                                                ;tant qu'il y a une section...
        .IF edi>=[edx].VirtualAdress                            ;si la RVA est plus loin que le d�but de la section..
            mov eax, [edx].VirtualAdress
            add eax, [edx].SizeOfRawData                        ;et si elle est moins loin que la fin de la section..
            .IF edi<eax
                mov eax, [edx].VirtualAdress
                sub edi, eax                                    ;il ne reste que le d�calage
                mov eax, [edx].PointerToRawData                 ;qu'on ajoute au d�but du RawData (data en dur)
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
                
    
;Si il reste des trucs que tu as pas compris mail moi (� part le coup du 1000h, il s'agit sans doute d'une constante dans
;le PE header..
;Il reste � modifier le remplissage de la section avec notre code (l� o� il remplit de 00h)
;pour �a, ouvrir le fichier, tout lire, r�cup�rer la taille de ce qui est lu, faire un writeprocessmemory avec comme 
;param�tre la taille, coller le code dans la nouvelle section, fermer les handle/instance.

;et l'interface graphique �videmment aha


;je pense qu'on devrait faire un crypteur avec
;en utilisant le truc md5 dont je t'ai parl� et que j'ai trouv� finalement
;�a servirait � prot�ger des exe, quels qu'ils soient
;guntz te ferait un bisou je pense

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;   Proc�dure d'ouverture de fichier  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
;;;;;;;;;;;;;   Proc�dure de cr�ation de fichier  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CREERFICHIER PROC
push eax
invoke CreateFile,ADDR nom_du_fichier,\
                  GENERIC_READ or GENERIC_WRITE ,\		 
                  FILE_SHARE_READ or FILE_SHARE_WRITE,\ 	 
                  NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_HIDDEN,\	 
		  NULL
mov hFichier, eax

;;;et pour �crire dedans:

invoke WriteFile, hFichier, addr data0?, X, addr data1?, NULL	 ;�crit data0? dans le fichier, X octets � la	
pop eax			  				 	 ;fois
ret									
CREERFICHIER ENDP

tip: pour attribuer l'op�rateur addr � un param�tre d'une fonction, il faut avoir d�clar� le prototype de la fonction au pr�alable. Utile pour les string[] .data?





































    
    










    





