.386
.model flat,stdcall
option casemap:none

include KeyGen1.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	mov		CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDC_GO
			invoke GetTxt,hWin
		.endif
;	.elseif eax==WM_SIZE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

Convert proc fck:DWORD
	push edx
	mov ecx, 0
cvert:
	cmp byte ptr[eax], 0
	je exit
	cmp ecx, 4
	jge exit
	xor byte ptr[eax], 0FFh
	mov dl, byte ptr[eax]
	xor dl, byte ptr[ebx]
	mov byte ptr[ebx], dl
	inc ecx
	inc eax
	inc ebx
	jmp cvert
exit:
	pop edx
	ret

Convert endp

GetTxt proc hWin:HWND
	invoke GetDlgItemText,hWin,IDC_NAME,addr inVal,50
	cmp eax, 0
	jle exit
	mov sLength, al		;sLength = input string length to know when we are finished
	lea edx, CodeKey
	mov edx, [edx]
	mov ecx, 0
	lea ebx, rslt
keepGoing:
	mov byte ptr[ebx + ecx],dl	;load buff with init vals
	shr edx, 8
	inc ecx
	cmp ecx, 4
	jne keepGoing 
	lea eax, inVal
	mov ecx, 0
cont:
	cmp byte ptr[eax], 0
	je quit
	mov ebx, offset rslt
	invoke Convert,0
	mov ecx, 1
	jmp cont
quit:
	cmp ecx, 0
	je exit
	invoke CreateXorSum,offset rslt
	invoke byteToText,addr buff,addr strOut
	mov ecx, 1
	lea edx, [strOut + ecx * 2]
	lea eax, [rslt + ecx * 2]
keepgng:
	push eax
	push edx
	invoke byteToText,eax,edx
	pop edx
	pop eax
	inc eax
	inc edx
	cmp ecx, 4
	jne keepgng
	mov byte ptr[edx], 0
	invoke SetDlgItemText,hWin,IDC_KEY,addr strOut
exit:
	ret
	
GetTxt endp

byteToText proc lprslt:DWORD, strOutIndex:DWORD
	mov ecx, 2
	mov edx, [strOutIndex]
roll:
	mov eax, lprslt
	mov al, byte ptr[eax]
	cmp ecx, 1
	je noroll
	shr eax, 4
noroll:
	and eax, 0fh
	cmp eax, 9
	jg abvNine
	or eax, 030h
	mov byte ptr[edx], al
	inc edx
	dec ecx
	je exit
	jmp roll
abvNine:
	add eax, 037h
	mov byte ptr[edx], al
	inc edx
	dec ecx
	jne roll	
exit:
	ret
byteToText endp

CreateXorSum proc a:DWORD
	mov eax, a
	mov dl, byte ptr[eax]
	mov ecx, 1
	
cont:
	xor dl, byte ptr[eax + ecx]
	inc ecx
	cmp ecx, 4
	jne cont
	mov buff, dl
	ret

CreateXorSum endp
end start
