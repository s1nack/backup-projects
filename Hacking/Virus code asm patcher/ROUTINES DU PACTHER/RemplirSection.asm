On suppose qu'une section a déjà été ajoutée, que l'EntryPoint original a été modifié et pointe maintenant sur la nouvelle section.
Cette routine ouvre un fichier texte et copie son contenu dans la nouvelle section (en dur!).
A son exécution, le programme patché exécutera donc le contenu de la nouvelle section.
A l'avenir, il faudra modifier la procédure AjoutSection pour ne pas modifier l'EntryPoint, la modif de l'EntryPoint devant être faite par la routine RemplirSection (pour pouvoir sauvegarder l'ancien EntryPoint et rejumper dessus à la fin de notre nouvelle section).



invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
mov hFile, eax

invoke ReadFile,hFile,addr Buffer,nbBytesToRead,addr nbFileRead,NULL

invoke CreateFile,addr ExeName,GENERIC_WRITE,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
mov hExe, eax

invoke WriteFile,hExe,addr Buffer,addr nbFileRead,addr nbBytesWrite,NULL


Cette routine attend du fichier texte qu'il contienne des instructions ASCII (il faut donc à l'avance calculer la valeur de l'instruction héxa en ASCII et la mettre dans le .txt).
Pour utiliser des instructions directement en héxa dans le fichier texte, il faut faire la conversion ASCII->HEXA entre la lecture et l'ecriture (car il n'y a aucune option de lecture héxa directement).
Mais cette conversion ne peut se faire que byte par byte.
Il faut donc lire le buffer byte par byte (ReadFile a un argument NombreDeByteALire) MAIS du coup il faut bien ensuite
dire à ReadFile de lire le byte d'après, pour pas lire le même à chaque passage. Et pour ça il faut utiliser le dernier paramètre de ReadFile, qui est un pointeur sur une structure OVERLAPPED nécessaire à l'utilisation de SetFilePointer.
Voilà le prototype de la structure ReadFile:
	
	typedef struct _OVERLAPPED { // o  
   	  DWORD  Internal; 
   	  DWORD  InternalHigh; 
   	  DWORD  Offset; 
   	  DWORD  OffsetHigh; 
  	  HANDLE hEvent; 
	} OVERLAPPED;

Internal et InternalHigh doivent rester vides, Windows se charge de les remplir.
Offset est l'offset dans le fichier à partir duquel on veut lire.
OffsetHigh fait partie de ces paramètres magiques mal documentés, faudra yaller au petit bonheur la chance.
hEvent est, je crois, un handle sur une fonction à lancer une fois le ReadFile terminé. NULL doit aller.

Donc la fonction en gros serait une boucle qui:
 - lit le premier char (valeur ascii)
 - le stocke dans un buffer temporaire (valeur ascii toujours)
 - le convertit en héxa et le mette dans un tableau
 - modifie le param Offset de la struct en l'incrémentant d'un byte
 - recommence jusqu'au char NULL
Ensuite on a donc le tableau rempli avec nos valeurs en héxa.
On peut donc faire un WriteProcessMemory direct.


Petits détails vu qu'on sait pas encore comment faire exactement pour cette histoire de .txt

WriteProcessMemory fonctionne avec un BUFFER et non pas byte par byte.
Si on convertit il faut donc faire comme ci-dessus, lire 1 par 1 et écrire d'un coup.

Par contre je pense que WriteFile nous fera les même prob que ReadFile, à savoir qu'il convertit tout seul en ascii.
Il faudra donc une boucle comme au dessus avec en plus le WriteFile qui utilise une structure OVERLAPPED aussi.
Ca serait assez long en cycle processeur puisqu'il appellerait plusieurs fois les API ReadFile/WriteFile.

