; Routine d'infection de tous les .exe du repertoire

; Il faut faire un FindFirstFile puis un FindNextFile pour scanner le r�pertoire.
; Pour �a, il faut mettre en .data? une structure.

; Prototype des API:

;		HANDLE FindFirstFile(
;
;    LPCTSTR lpFileName,	// Nom du fichier � chercher (* et ? autoris�s)  
;    LPWIN32_FIND_DATA lpFindFileData 	// pointeur sur la structure
;   );

; Renvoie un search handle utile pour FindNextFile



; et
;
;		BOOL FindNextFile(
;
;    HANDLE hFindFile,	// handle h�rit� de FindFirstFile 
;    LPWIN32_FIND_DATA lpFindFileData 	// pointeur sur la structure  
;   );



; Ces fonctions ont donc besoin d'une structure  WIN32_FIND_DATA  pour renvoyer les informations
; sur le fichier renvoy�.
; Son prototype est:


;		 typedef struct _WIN32_FIND_DATA { // wfd  
;    DWORD dwFileAttributes; 				<----- 1/
;    FILETIME ftCreationTime; 				<----- 2/
;    FILETIME ftLastAccessTime; 
;    FILETIME ftLastWriteTime; 
;    DWORD    nFileSizeHigh; 
;    DWORD    nFileSizeLow; 
;    DWORD    dwReserved0; 
;    DWORD    dwReserved1; 
;    TCHAR    cFileName[ MAX_PATH ]; 
;    TCHAR    cAlternateFileName[ 14 ]; 
;} WIN32_FIND_DATA;



; 1/ Utile pour v�rifier si c'est un sous-r�pertoire ou un fichier gr�ce � l'attribut
;	FILE_ATTRIBUTE_DIRECTORY
; et s'il est en lecture seule gr�ce �
;	FILE_ATTRIBUTE_READONLY


; 2/ Pointe sur une structure  FILETIME  dont le prototype est:
;	 
;		typedef struct FILETIME { // ft  
;    DWORD dwLowDateTime; 
;    DWORD dwHighDateTime; 
;	} FILETIME; 

; Les deux arguments suivants sont aussi des structures  FILETIME



