;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEBUT DU BOMBYX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ETUDE DU HEADER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;pour ton problème d'include de ressource c'est simple, va dans tes tuts d'iczelion et tu trouveras dans certains dossiers
;un makeit.bat, ya qq lignes de code qui te montreront comment include un fichier type rsrc.rc
;le rsrc.rc est le fichier que tu vois avec ResHacker quand tu veux ajouter un menu, tu sais le truc avec les POPUP MENU
;quand tu compiles, n'oublie pas de mettre dans ton repertoire le "resource.h"

;Ce programme va afficher certaines informations du header d'un exe dans des edit box
;Il permettra d'ouvrir le fichier exe par le biais d'un menu listview
;J'utilise une DlgBox en tant que fenêtre principale, le callback WndProc sera donc remplacé par un DlgProc, c'est la même
;en version spécialisé DlgBox (c'est windows qui gère tout donc pas de prise de tête)
;le WinMain disparait aussi, la fenêtre principale étant une DlgBox et pas une fenêtre classique

;Je te conseille avant de faire tout ça de consulter la msdn sur l'api SendDlgItemMessage qui prend en parametre un
;argument  uMsg:DWORD  qui est la clé de cette api, avec par exemple un GetText, et aussi un truc pour printer du text


.386
.model flat,stdcall
option casemap:none

DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib

.data
DlgName db "MyDialog",0 
AppName db "Our Second Dialog Box",0 
TestString db "string envoyee avec SendDlgItemText",0                      ;ensuite faudra mettre ça en .data? puisqu'on
                                                                            ;ne connaitra pas encore le contenu
                                                                            ;des pe headers

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
buffer db 512 dup(?)                                              ;ce buffer sert à récupérer le texte avec GetDlgItemText

.const 
IDC_EDIT        equ 3000                                                    ; ce sont donc tes menus qui seront 
IDC_BUTTON      equ 3001                                                    ; détaillés dans un fichier .rc
IDC_EXIT        equ 3002                                                    ; que tu associeras à ton .asm avec le makeit
IDM_GETTEXT     equ 32000                                                   ; dont je te parle au-dessus
IDM_CLEAR       equ 32001 
IDM_EXIT        equ 32002 


.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke DialogBoxParam, hInstance, ADDR DlgName, NULL, ADDR DlgProc, NULL    ;remplace WinMain, le paramètre DlgProc
    invoke ExitProcess, eax                                                     ;remplace WndProc

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM                 ;pas besoin de s'occuper de wParam/lParam
    .IF uMsg==WM_INITDIALOG                                                     ;le bouton cliqué ira direct dans wParam
        invoke GetDlgItem, hWnd,IDC_EDIT 
        invoke SetFocus,eax
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 
            .IF ax==IDM_GETTEXT 
                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512 
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL 
            .ELSEIF ax==IDM_EXIT 
                invoke EndDialog, hWnd,NULL 
            .ENDIF 
        .ELSE 
            mov edx,wParam 
            shr edx,16 
            .if dx==BN_CLICKED 
                .IF ax==IDC_BUTTON 
                    invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString 
                .ELSEIF ax==IDC_EXIT 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0 
                .ENDIF 
            .ENDIF 
        .ENDIF 
    .ELSE 
        mov eax,FALSE 
        ret 
    .ENDIF 
    mov eax,TRUE 
    ret 
DlgProc endp 
end start















