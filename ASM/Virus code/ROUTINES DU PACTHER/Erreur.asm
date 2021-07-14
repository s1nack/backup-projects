Erreur proc CodeErreur:UINT
	
	xor eax,eax
	.if CodeErreur==1
		invoke MessageBox,hWnd,addr Erreur1,addr ErreurTitre,MB_OK
		ret
	.elseif CodeErreur==2
		invoke MessageBox,hWnd,addr Erreur2,addr ErreurTitre,MB_OK
		ret
	.endif	
	xor eax,eax		
	ret

Erreur endp