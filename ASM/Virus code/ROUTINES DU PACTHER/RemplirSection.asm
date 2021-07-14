On suppose qu'une section a d�j� �t� ajout�e, que l'EntryPoint original a �t� modifi� et pointe maintenant sur la nouvelle section.
Cette routine ouvre un fichier texte et copie son contenu dans la nouvelle section (en dur!).
A son ex�cution, le programme patch� ex�cutera donc le contenu de la nouvelle section.
A l'avenir, il faudra modifier la proc�dure AjoutSection pour ne pas modifier l'EntryPoint, la modif de l'EntryPoint devant �tre faite par la routine RemplirSection (pour pouvoir sauvegarder l'ancien EntryPoint et rejumper dessus � la fin de notre nouvelle section).



invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
mov hFile, eax

invoke ReadFile,hFile,addr Buffer,nbBytesToRead,addr nbFileRead,NULL

invoke CreateFile,addr ExeName,GENERIC_WRITE,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
mov hExe, eax

invoke WriteFile,hExe,addr Buffer,addr nbFileRead,addr nbBytesWrite,NULL


Cette routine attend du fichier texte qu'il contienne des instructions ASCII (il faut donc � l'avance calculer la valeur de l'instruction h�xa en ASCII et la mettre dans le .txt).
Pour utiliser des instructions directement en h�xa dans le fichier texte, il faut faire la conversion ASCII->HEXA entre la lecture et l'ecriture (car il n'y a aucune option de lecture h�xa directement).
Mais cette conversion ne peut se faire que byte par byte.
Il faut donc lire le buffer byte par byte (ReadFile a un argument NombreDeByteALire) MAIS du coup il faut bien ensuite
dire � ReadFile de lire le byte d'apr�s, pour pas lire le m�me � chaque passage. Et pour �a il faut utiliser le dernier param�tre de ReadFile, qui est un pointeur sur une structure OVERLAPPED n�cessaire � l'utilisation de SetFilePointer.
Voil� le prototype de la structure ReadFile:
	
	typedef struct _OVERLAPPED { // o  
   	  DWORD  Internal; 
   	  DWORD  InternalHigh; 
   	  DWORD  Offset; 
   	  DWORD  OffsetHigh; 
  	  HANDLE hEvent; 
	} OVERLAPPED;

Internal et InternalHigh doivent rester vides, Windows se charge de les remplir.
Offset est l'offset dans le fichier � partir duquel on veut lire.
OffsetHigh fait partie de ces param�tres magiques mal document�s, faudra yaller au petit bonheur la chance.
hEvent est, je crois, un handle sur une fonction � lancer une fois le ReadFile termin�. NULL doit aller.

Donc la fonction en gros serait une boucle qui:
 - lit le premier char (valeur ascii)
 - le stocke dans un buffer temporaire (valeur ascii toujours)
 - le convertit en h�xa et le mette dans un tableau
 - modifie le param Offset de la struct en l'incr�mentant d'un byte
 - recommence jusqu'au char NULL
Ensuite on a donc le tableau rempli avec nos valeurs en h�xa.
On peut donc faire un WriteProcessMemory direct.


Petits d�tails vu qu'on sait pas encore comment faire exactement pour cette histoire de .txt

WriteProcessMemory fonctionne avec un BUFFER et non pas byte par byte.
Si on convertit il faut donc faire comme ci-dessus, lire 1 par 1 et �crire d'un coup.

Par contre je pense que WriteFile nous fera les m�me prob que ReadFile, � savoir qu'il convertit tout seul en ascii.
Il faudra donc une boucle comme au dessus avec en plus le WriteFile qui utilise une structure OVERLAPPED aussi.
Ca serait assez long en cycle processeur puisqu'il appellerait plusieurs fois les API ReadFile/WriteFile.

