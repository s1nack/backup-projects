code pour afficher les trucs comme STUD_PE

bon on suppose que l'interface graphique est faite avec une editbox en dans laquelle on tape le nom du fichier 
à étudier, et à coté de cette editbox il y a un bouton qu'on appellera B1.
Le code commence dans le DlgProc ou WndProc peu importe comment on construit le prog, Dlg only ou WinMain/WndProc
donc on en est là:

DECLARATION IMPORTANTES:

il faut déclarer pFile, hMapping, pMapping dans les .data?
et tous les membres du type NumberOfSections, AdressOfEntryPoint, etc.

il faut déclarer une procédure ErrorProc qui affiche une MsgBox avec la nature de l'erreur rencontrée
pour ça, déclarer au préalable des codes du style

1 db "OpenFileMapping a echoue"
2 db "MapViewOfFile a echoue"
3 db "L'exe n'a pas un format PE valide"

ErrorProc proc CodeErreur:WORD
    invoke MsgBox, CodeErreur(comme param de texte dans la MsgBox)
    ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; le vrai code commence donc ici ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[start]
Routine de vérification de la validité de l'exe:

mov ebx, 5045h
cmp eax, ebx
je good_boy
invoke ErrorProc?
good_boy:
...
[/start]


[start]
Routine de récupération des headers

.IF uMsg==B1_CLICKED
    invoke GetPEInfos

GetPEInfos proc uses edi

    invoke GetDlgItemText, hDlg, nIDDlgItem, pFile, 30d
    invoke OpenFileMapping, FILE_MAP_READ, FALSE, pFile
    .IF (!eax)
        invoke ErrorProc, 1
    .ENDIF
    mov hMapping, eax
    invoke MapViewOfFile, hMapping, FILE_MAP_WRITE, 0, 0, 0
    .IF (!eax)
        invoke ErrorProc, 2
    .ENDIF
    mov pMapping, eax
    
    mov edi, pMapping
    assume edi: ptr IMAGE_DOS_HEADER

    add edi, [edi].e_lfanew
    assume edi: ptr IMAGE_NT_HEADERS

    mov eax, [edi].Signature
    mov ebx, SignaturePEValide
    cmp eax, ebx
|-- je [2 adresses en dessous]
|   invoke ErrorProc, 1
|  
|-- mov eax, [edi].FileHeader.NumberOfSections
    mov NumberOfSections, eax

    mov eax, [edi].OptionalHeader.AdressOfEntryPoint
    mov AdressOfEntryPoint, eax

    mov eax, [edi].OptionalHeader.ImageBase
    mov ImageBase, eax

    mov eax, [edi].OptionalHeader.SectionAlignment
    mov SectionAlignment, eax

    mov eax, [edi].OptionalHeader.FileAlignment
    mov FileAlignment, eax

    mov eax, [edi].OptionalHeader.SizeOfImage
    mov SizeOfImage, eax

    mov eax, [edi].OptionalHeader.SizeOfHeaders
    mov SizeOfHeaders, eax
[/start]

bon je vais pas tout faire c'est inutile, le schéma est le même pour récupérer toutes les données importantes.
Sauf pour les structures IMAGE_DATA_DIRECTORY dans lesquelles on trouve notamment:
 - IMAGE_DIRECTORY_ENTRY_EXPORT
 - IMAGE_DIRECTORY_ENTRY_IMPORT
 - IMAGE_DIRECTORY_ENTRY_RESOURCE
 - IMAGE_DIRECTORY_ENTRY_IAT
Une méthode fiable serait de déplacer edi sur le tableau de structures qui est à la fin du OptionalHeaders, puis de le 
déplacer ensuite sur chaque structure en lui ajoutant 2 DWORD (la taille d'une structure) et en relevant les données avec 
    mov eax, [edi].VirtualAdress
    mov VirtualAdress1, eax
    mov eax, [edi].Size
    mov Size1, eax
    add edi, [2 DWORDS]
    mov eax, [edi].VirtualAdress
    mov VirtualAdress2, eax
On est obligés d'utiliser un chiffre après VirtualAdress car, pour rappel, les structures IMAGE_DATA_DIRECTORY sont composées
comme ceci:

struct _IMAGE_DATA_DIRECTORY {
    DWORD VirtualAdress
    DWORD Size
    };

Et cette structure est la même pour toutes les infos utiles: IMPORT, EXPORT, RESOURCE et IAT...
A voir aussi, il existe peut-être un moyen direct pour accéder à ces structures, du type (avec edi qui reste sur NT_HEADERS)
[edi].OptionalHeader.DataDirectory.IMAGE_DIRECTORY_ENTRY_EXPORT
Mais bon osef pour le moment, ma routine au-dessus est un peu lourde mais fonctionnera très bien une fois raccordée à 
une interface graphique.


Il faut qu'on apprenne à se servir d'un rsrc.rc parceque là c'est vraiment galère d'afficher bcp de EditBox et de Box
normales sur une même form.
A mon avis le plus simple pour notre STUD_PE serait d'utiliser une DlgBox qui se substituerait au combo WinMain/WndProc,
pour un petit projet comme ça c'est jouable, par contre pour le patcher on perdrait trop de temps à compenser l'absence
de "squelette" pour le code, vu qu'il y aura un bon nombre de modules (le RVAToOffset requis pour l'ajout de sections,
la routine d'ouverture de fichier etc.)

Bon, ce soir j'ai pu de shit donc je vais CALL HOGGAR, Sofiane && Marc || Arezki, 21h-00h, ALCOOL_ALLOWED
LE PATCHER BOMBYX SERA BIENTOT PRET!!!
gl&hf

    
    
    