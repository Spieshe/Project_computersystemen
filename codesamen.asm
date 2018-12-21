; -------------------------------------------------------------------
; 80386
; 32-bit x86 assembly language
; TASM
;
; author:	Dries Van de Steen, Cindy Wauters
; date:		24/12/2018
; program:	Paint
; -------------------------------------------------------------------

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "mouse.inc"

VMEMADR EQU 0A0000h	; video memory address
SCRWIDTH EQU 320	; screen witdth
SCRHEIGHT EQU 200	; screen height
col1to5y EQU 5
col6to10y EQU 25
col1and6x EQU 150
col2and7x EQU 180
col3and8x EQU 210
col4and9x EQU 240
col5and10x EQU 270
colbandex EQU 100
colb1andb3 EQU 25
colb2 EQU 55
dimsprites EQU 16
color1 EQU 20h
color2 EQU 23h
color3 EQU 24h
color4 EQU 28h
color5 EQU 2Ah
color6 EQU 2Ch
color7 EQU 2Fh
color8 EQU 06h
color9 EQU 00h
white EQU 0Fh

; -------------------------------------------------------------------

CODESEG

; Set the video mode
PROC setVideoMode
	ARG @@VM:byte
	USES eax
	
	movzx ax, [@@VM]
	int 10h
ret
ENDP setVideoMode

; ; Update the colour palette.
PROC updateColourPalette
		ARG @@ncolors:word
		USES eax, ecx, edx, esi
		
		mov esi, offset palette
		movzx ecx, [@@ncolors]
		
		mov eax, ecx
		sal eax, 1
		add ecx, eax
		
		mov dx, 03c8h
		xor al, al 
		out dx, al
		
		inc dx
		rep outsb
		
		ret
ENDP updateColourPalette

; ; Fill the background (for mode 13h)
PROC fillBackground
	ARG @@fillcolor:byte
	USES eax, ecx, edi

	mov edi, VMEMADR
	
	mov al, [@@fillcolor]
	mov ah, al
	mov cx, ax
	shl eax, 16
	mov ax, cx
	
	mov ecx, SCRWIDTH*SCRHEIGHT
	
	rep stosd
	
	ret
ENDP fillBackground

; ; Draw a rectangle (video mode 13h)
 proc drawRectangle2
	arg @@x: word, @@y: word, @@br:word, @@h: word, @@col: byte
	uses eax, ecx, edx, edi
	
	movzx eax, [@@col] 
	mov ax, [@@y]
	mov edx, SCRWIDTH
	MUL edx
	add ax, [@@x]
	
	mov edi, VMEMADR
	add edi, eax
	
	movzx edx, [@@br]
	mov ecx, edx 
	mov al, [@@col]
	rep stosb
	sub edi, edx 
	movzx ecx, [@@h]
	@@vertloop:
		mov [edi], al 
		mov [edi+edx-1], al 
		add edi, SCRWIDTH
		loop @@vertloop
	
	sub edi, SCRWIDTH
	
	mov ecx, edx
	rep stosb
	ret
endp drawRectangle2
; bovenstaande functies werden gehaald van de wpo's
; auteurs van code: Stijn Bettens, David Blinder

PROC DrawFullRectangle
	arg @@x: word, @@y: word, @@br:word, @@h: word, @@col: byte
	uses eax, ecx, edx, edi
	
	movzx eax, [@@col]
	mov ax, [@@y]
	mov edx, SCRWIDTH
	MUL edx
	add ax, [@@x]
	
	mov edi, VMEMADR
	add edi, eax
	
	movzx edx, [@@br]
	mov ecx, edx 
	mov al, [@@col]
	rep stosb
	sub edi, edx 
	movzx ecx, [@@h]
	@@vertloop:
		push ecx
		movzx edx, [@@br]
		mov ecx, edx 
		mov al, [@@col]
		rep stosb
		sub edi, edx 
		mov [edi+edx-1], al 
		add edi, SCRWIDTH
		pop ecx
		loop @@vertloop
		
	
	sub edi, SCRWIDTH
	
	
	
	mov ecx, edx
	rep stosb
	ret

ret
endp DrawFullRectangle
; sterk gebaseerd op de code van draw rectangle (auteurs:  Stijn Bettens, David Blinder)

PROC draweraser
	ARG @@file: dword, @@dim: dword, @@x: word, @@y: word
    USES eax, ebx, ecx, edx
    	
	mov esi, [@@file]
	
	mov ax, [@@y]
	mov edx, SCRWIDTH
	MUL edx
	add ax, [@@x]
	
	mov edi, VMEMADR
	add edi, eax
	mov ecx, [@@dim]
	push ecx
	rep movsb
	add edi, 320
	sub edi, [@@dim]
	pop ecx
	dec ecx
@@ecxloopke:
	push ecx
	mov ecx, [@@dim]
	rep movsb
	add edi, 320
	sub edi, [@@dim]
	pop ecx
	loop @@ecxloopke


ret
endp draweraser
PROC drawjerry
	Uses	eax, ebx, ecx, edx
	ARG @@file:dword
	
	cmp [mousey], 52
	jle @@draw
	jmp @@end
	
@@draw:
	mov eax, [mousey]
	mov edx, SCRWIDTH
	MUL edx
	add eax, [mousex]
	mov edi, VMEMADR
	add edi, eax
	mov eax, edi
	mov esi, [@@file]
	mov ecx, 3
	push ecx
	rep movsb
	add edi, 320
	sub edi, 3
	pop ecx
	dec ecx
@@ecxloopke:
	push ecx
	mov ecx, 3
	rep movsb
	add edi, 320
	sub edi, 3
	pop ecx
	loop @@ecxloopke
	
@@end:

ret
endp drawjerry

PROC checkcurrent
	USES eax, ebx
	
	mov eax, [previous]
	mov ebx, [current]
	cmp eax, ebx
	je @@end
	
	
	cmp [previous], 0
	je @@end
	cmp [previous], 1
	je @@undo1
	cmp [previous], 2
	je @@undo2
	cmp [previous], 3
	je @@undo3
	cmp [previous], 4
	je @@undo4
	cmp [previous], 5
	je @@undo5
	cmp [previous], 6
	je @@undo6
	cmp [previous], 7
	je @@undo7
	cmp [previous], 8
	je @@undo8
	cmp [previous], 9
	je @@undo9
	cmp [previous], 10
	je @@undo10
	cmp [previous], 11
	jge @@end
	jmp @@end
	
@@undo1:
	call DrawFullRectangle,col1and6x,col1to5y,dimsprites,dimsprites,color1
	jmp @@end
@@undo2:
	call DrawFullRectangle,col2and7x,col1to5y,dimsprites,dimsprites,color2
	jmp @@end
@@undo3:
	call DrawFullRectangle,col3and8x,col1to5y,dimsprites,dimsprites,color3
	jmp @@end
@@undo4:
	call DrawFullRectangle,col4and9x,col1to5y,dimsprites,dimsprites,color4
	jmp @@end
@@undo5:
	call DrawFullRectangle,col5and10x,col1to5y,dimsprites,dimsprites,color5
	jmp @@end
@@undo6:
	call DrawFullRectangle,col1and6x,col6to10y,dimsprites,dimsprites,color6
	jmp @@end
@@undo7:
	call DrawFullRectangle,col2and7x,col6to10y,dimsprites,dimsprites,color7
	jmp @@end
@@undo8:
	call DrawFullRectangle,col3and8x,col6to10y,dimsprites,dimsprites,color8
	jmp SHORT @@end
@@undo9:
	call DrawFullRectangle,col4and9x,col6to10y,dimsprites,dimsprites,color9
	jmp SHORT @@end
@@undo10:
	call DrawFullRectangle,col5and10x,col6to10y,dimsprites,dimsprites,white
	jmp SHORT @@end
	

@@end:
ret
endp checkcurrent

PROC mouseHandler ;; GEKOPIEERD 
    USES    eax, ebx, ecx, edx
	call	draweraser,offset eraser,dimsprites, colbandex, 5
	call drawjerry, offset underneath
	movzx eax, dx		; get mouse height
	mov [mousey], eax
	mov edx, SCRWIDTH
	mul edx				; obtain vertical offset in eax
	sar cx, 1			; horizontal cursor position is doubled in input 
	mov [mousex], ecx
	add ax, cx			; add horizontal offset
	call drawjerry, offset jerry
	add eax, VMEMADR	; eax now contains pixel address mouse is pointing to
	and bl, 3			; check for one mouse buttons 
	jz SHORT @@skipit			; only execute if a mousebutton is pressed
    
	cmp [block], 1
	je @@skipit
	mov bl, [current_color]
	mov [eax], bl	; change color
	
	cmp [floodfill_on], 1
	je @@callfloodfill
	
	cmp [current_brush], 4
	jge @@brushsize4
	jmp @@skipit
	
@@brushsize4:
	mov [eax-1], bl
	mov [eax + SCRWIDTH], bl
	mov [eax + SCRWIDTH - 1], bl
	
	cmp [current_brush], 9
	jge @@brushsize9
	jmp @@skipit

@@brushsize9:
	mov [eax+1], bl
	mov [eax+SCRWIDTH+1], bl
	mov [EAX+SCRWIDTH+SCRWIDTH], bl
	mov [EAX+SCRWIDTH+SCRWIDTH+1], bl
	mov [EAX+SCRWIDTH+SCRWIDTH-1], bl
	jmp @@skipit
	
@@callfloodfill:
	call floodfill


@@skipit:
   ret
ENDP mouseHandler

PROC mouseposition
    USES    eax, ebx, ecx, edx

	
	movzx eax, dx ;get mouse height
	cmp eax, 40
	jle @@checkrow
	
	

@@checkdraw:
    cmp [mousey], 55 ; zodat er niet getekend kan worden op de bovenkant waar de kleuren worden getoont
	mov [block], 0
    jge @@callmousehandler
	 
	jmp @@skipit2
	
@@checkrow:
	mov [block], 1
	cmp [mousey], 20
	jle @@upperrow
	cmp [mousey], 40
	jle @@lowerrow
	jmp @@skipit2
	
@@upperrow:
	cmp [mousey], col1to5y
	jge @@checkcolorupperrow
	jmp @@checkdraw
	
@@lowerrow: 
	cmp [mousey], col6to10y
	jge @@checkcolorlowerrow
	jmp @@checkdraw
	
@@checkcolorupperrow: 

	cmp [mousex], 41
	jle @@brush1
	
	cmp [mousex], 71
	jle @@brush2	

	cmp [mousex], 116
	jle @@eraser
	
	cmp [mousex], 166
	jle @@color1
	
	cmp [mousex], 196
	jle @@color2
	
	cmp [mousex], 226
	jle @@color3
	
	cmp [mousex], 256
	jle @@color4
	
	cmp [mousex], 286
	jle @@color5
	
	jmp @@checkdraw
	
	
@@checkcolorlowerrow: 

	cmp [mousex], 41
	jle @@brush3

	cmp [mousex], 116
	jle @@bucket
	
	cmp [mousex], 166
	jle @@color6
	
	cmp [mousex], 196
	jle @@color7
	
	cmp [mousex], 226
	jle @@color8
	
	cmp [mousex], 256
	jle @@color9
	
	cmp [mousex], 286
	jle @@color10
	
	jmp @@checkdraw
	
@@bucket:
	cmp [mousex], colbandex
	jge @@buck
	jmp @@checkdraw
	@@buck:
	mov [current], 11
	call checkcurrent
	call drawRectangle2, colbandex, col6to10y, dimsprites, dimsprites, white
	mov [previous], 0
	and bl, 3
	jz @@skipit2
	call drawRectangle2, colbandex, col6to10y, dimsprites, dimsprites, white
	mov [floodfill_on], 1
	jmp @@checkdraw
	
@@eraser:
	cmp [mousex], colbandex
	jge @@e
	jmp @@checkdraw
	@@e:
	mov [current], 0
	call checkcurrent
	call drawRectangle2,colbandex,col1to5y,dimsprites,dimsprites,white
	mov [previous], 0
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	call drawRectangle2,colbandex,col1to5y,dimsprites,dimsprites,white
	mov [current_color], white
	jmp @@checkdraw
	
@@color1:	
	cmp [mousex], col1and6x
	jge @@c1
	jmp @@checkdraw
	@@c1:
	call DrawFullRectangle,col1and6x,col1to5y,dimsprites, dimsprites, color1 ;color 1
	mov [current], 1
	call checkcurrent
	call drawRectangle2,col1and6x,col1to5y,dimsprites,dimsprites,white
	mov [previous], 1
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	call drawRectangle2,col1and6x,col1to5y,dimsprites,dimsprites,white
	mov [current_color], color1
	jmp @@checkdraw
		
@@color2:
	cmp [mousex], col2and7x
	jge @@c2
	jmp @@checkdraw
	@@c2:
	call	DrawFullRectangle,col2and7x,col1to5y,dimsprites, dimsprites, color2 ;color 2
	mov [current], 2
	call checkcurrent
	call drawRectangle2,col2and7x,col1to5y,dimsprites,dimsprites,white
	mov [previous], 2
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color2
	call drawRectangle2,col2and7x,col1to5y,dimsprites,dimsprites,white
	jmp @@checkdraw
	
@@color3:
	cmp [mousex], col3and8x
	jge @@c3
	jmp @@checkdraw
	@@c3:
	call	DrawFullRectangle,col3and8x,col1to5y,dimsprites, dimsprites, color3 ;color 3
	mov [current], 3
	call  checkcurrent
	call drawRectangle2,col3and8x,col1to5y,dimsprites,dimsprites,white
	mov [previous], 3
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	call drawRectangle2,col3and8x,col1to5y,dimsprites,dimsprites,white
	mov [current_color], color3
	jmp @@checkdraw
	
@@color4:
	cmp [mousex], col4and9x
	jge @@c4
	jmp @@checkdraw
	@@c4: 
	call	DrawFullRectangle,col4and9x,col1to5y,dimsprites, dimsprites, color4 ;color 4
	mov [current], 4
	call checkcurrent
	call drawRectangle2,col4and9x,col1to5y,dimsprites,dimsprites,white
	mov [previous], 4
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color4
	call drawRectangle2,col4and9x,col1to5y,dimsprites,dimsprites,white; select color 4
	jmp @@checkdraw
	
@@color5:
	cmp [mousex], col5and10x
	jge @@c5
	jmp @@checkdraw
	@@c5: 
	call	DrawFullRectangle,col5and10x,col1to5y,dimsprites, dimsprites, color5 ;color 5
	mov [current], 5
	call checkcurrent
	call drawRectangle2,col5and10x,col1to5y,dimsprites,dimsprites,white
	mov [previous], 5
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color5	
	call drawRectangle2,col5and10x,col1to5y,dimsprites,dimsprites,white
	jmp @@checkdraw

@@color6:	
	cmp [mousex], col1and6x
	jge @@c6
	jmp @@checkdraw
	@@c6:
	call	DrawFullRectangle,col1and6x,col6to10y,dimsprites, dimsprites, color6 ;color 6
	mov [current], 6
	call checkcurrent
	call drawRectangle2,col1and6x,col6to10y,dimsprites,dimsprites,white
	mov [previous], 6
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color6
	call drawRectangle2,col1and6x,col6to10y,dimsprites,dimsprites,white
	jmp @@checkdraw
		
@@color7:
	cmp [mousex], col2and7x
	jge @@c7
	jmp @@checkdraw
	@@c7:
	call	DrawFullRectangle,col2and7x,col6to10y,dimsprites, dimsprites, color7 ;color 7
	mov [current], 7
	call checkcurrent
	call drawRectangle2,col2and7x,col6to10y,dimsprites,dimsprites,white
	mov [previous], 7
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color7
	call drawRectangle2,col2and7x,col6to10y,dimsprites,dimsprites,white
	jmp @@checkdraw
	
@@color8:
	cmp [mousex], col3and8x
	jge @@c8
	jmp @@checkdraw
	@@c8: 
	call	DrawFullRectangle,col3and8x,col6to10y,dimsprites, dimsprites, color8 ;color 8
	mov [current], 8
	call checkcurrent
	call drawRectangle2,col3and8x,col6to10y,dimsprites,dimsprites,white
	mov [previous], 8
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color8
	call drawRectangle2,col3and8x,col6to10y,dimsprites,dimsprites,white
	jmp @@checkdraw
	
@@color9:
	cmp [mousex], col4and9x
	jge @@c9
	jmp @@checkdraw
	@@c9: 
	call	DrawFullRectangle,col4and9x,col6to10y,dimsprites, dimsprites, color9 ;color 9
	mov [current], 9
	call checkcurrent
	call drawRectangle2,col4and9x,col6to10y,dimsprites,dimsprites,white
	mov [previous], 9
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], color9
	call drawRectangle2,col4and9x,col6to10y,dimsprites,dimsprites,white
	jmp @@checkdraw
	
@@color10:
	cmp [mousex], col5and10x
	jge @@c10
	jmp @@checkdraw
	@@c10: 
	call	DrawFullRectangle,col5and10x,col6to10y,dimsprites, dimsprites, white ;color 10
	mov [current], 10
	call checkcurrent
	call drawRectangle2,col5and10x,col6to10y,dimsprites,dimsprites,white
	mov [previous], 10
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_color], white
	call drawRectangle2,col5and10x,col6to10y,dimsprites,dimsprites,color9
	jmp @@checkdraw
	
@@brush1:
	cmp [mousex], colb1andb3
	jge @@b1
	jmp @@checkdraw
	@@b1:
	mov [current], 12
	call checkcurrent
	call drawRectangle2,colb1andb3,col1to5y,dimsprites,dimsprites,white
	mov [previous], 12
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_brush], 1
	call drawRectangle2,colb1andb3,col1to5y,dimsprites,dimsprites,white
	jmp @@checkdraw

@@brush2:
	cmp [mousex], colb2
	jge @@b2
	jmp @@checkdraw
	@@b2:
	mov [current], 13
	call checkcurrent
	call drawRectangle2,colb2,col1to5y,dimsprites,dimsprites,white
	mov [previous], 13
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_brush], 4
	call drawRectangle2,colb2,col1to5y,dimsprites,dimsprites,white
	jmp @@checkdraw
	
@@brush3:
	cmp [mousex], colb1andb3
	jge @@b3
	jmp @@checkdraw
	@@b3:
	mov [current], 14
	call checkcurrent
	call drawRectangle2,colb1andb3,col6to10y,dimsprites,dimsprites,white
	mov [previous], 14
	and bl, 3
	jz @@skipit2
	mov [floodfill_on], 0
	mov [current_brush], 9
	call drawRectangle2,colb1andb3,col6to10y,dimsprites,dimsprites,white
	jmp @@checkdraw


@@callmousehandler:
	call	DrawFullRectangle,col1and6x,col1to5y,dimsprites, dimsprites, color1 ;color 1
	call	DrawFullRectangle,col2and7x,col1to5y,dimsprites, dimsprites, color2 ;color 2
	call	DrawFullRectangle,col3and8x,col1to5y,dimsprites, dimsprites, color3 ;color 3
	call	DrawFullRectangle,col4and9x,col1to5y,dimsprites, dimsprites, color4 ;color 4
	call	DrawFullRectangle,col5and10x,col1to5y,dimsprites, dimsprites, color5 ;color 5
	call	DrawFullRectangle,col1and6x,col6to10y,dimsprites, dimsprites, color6 ;color 6
	call	DrawFullRectangle,col2and7x,col6to10y,dimsprites, dimsprites, color7 ;color 7
	call	DrawFullRectangle,col3and8x,col6to10y,dimsprites, dimsprites, color8 ;color 8
	call	DrawFullRectangle,col4and9x,col6to10y,dimsprites, dimsprites, color9 ;color 9
	call	DrawFullRectangle,col5and10x,col6to10y,dimsprites, dimsprites, white ;color 10
	call mouseHandler
	
	
@@skipit2:
	mov [block], 1
	call mouseHandler
    ret
ENDP mouseposition
; Copyright (c) 2015, Tim Bruylants <tim.bruylants@gmail.com>
; All rights reserved.
; met redelijk wat aanpassingen

PROC floodfill	
	USES eax, ebx, ecx 
	
	xor ecx, ecx
;	mov [background_curr_pix
	mov bl, [current_color]
	mov [eax], bl
	
	add ecx, 1
	jmp @@colorleft


@@start:
	sub ecx, 1
	cmp ecx, -1
	jle SHORT @@stop
	pop eax

	mov bl, [current_color]
	mov [eax], bl
	
@@colorleft:
	sub eax, 1
;	cmp [eax], [background_curr_pix]
;	jne @@pushonstackleft

;	xor ebx, ebx
;
;	mov bl, [background_curr_pix]
	
	cmp [eax], bl
	jne @@pushonstackleft
	
	
	jmp @@colorright

@@pushonstackleft:
	push eax
	add ecx, 1

@@colorright:
	add eax, 2
	cmp [eax],  bl
	jne @@pushonstackright
	jmp @@colorup

@@pushonstackright:
	
	push eax
	add ecx, 1

@@colorup:
	sub eax, 1
	add eax, SCRWIDTH
	cmp [eax], bl
	jne @@pushonstackup

	
	jmp @@colordown

@@pushonstackup: 
	
	push eax
	add ecx, 1

@@colordown:
	sub eax, SCRWIDTH
	sub eax, SCRWIDTH
	cmp [eax], bl
	jne @@pushonstackdown
	
	
	jmp @@start

@@pushonstackdown:

	push eax
	add ecx, 1
	jmp @@start

@@stop:
	ret 
	;call mouseHandler

ENDP floodfill
	

; ; Wait for a specific keystroke.
PROC waitForSpecificKeystroke
	ARG @@key:byte
	USES eax
	
	@@waitKeystroke:
		mov ah, 00h
		int 16h 
		cmp al, [@@key]
	jne @@waitKeystroke
	
	ret		
ENDP waitForSpecificKeystroke

PROC waitforkeybrush
;	ARG @@key:byte
	USES eax
	@@waitkey:
		mov ah, 00h
		int 16h
		cmp al, 99
		je @@99
		cmp al, 98
		je @@98
	jne @@waitkey
	
@@99:
;	mov eax, 00h
	mov [current_brush], 4
	mov [floodfill_on], 0
	jmp @@waitkey

@@98:
	mov [floodfill_on], 1
	jmp @@waitkey

ret
ENDP waitforkeybrush
; bovenstaande functie werden gehaald van de wpo's met enkele aanpassingen voor de specifieke kleuren 
; auteurs van code: Stijn Bettens, David Blinder

	
		

; Terminate the program.
PROC terminateProcess
	USES eax
	call setVideoMode, 03h
	mov	ax,04C00h
	int 21h
	ret
ENDP terminateProcess

PROC main
	sti
	cld
	
	push ds
	pop	es

	call setVideoMode,13h
	
	
		mov eax, 00h
	
    call 	mouse_install, offset mouseposition,28h
	call	fillBackground, white
	

	call	DrawFullRectangle,0,0,SCRWIDTH,55, 1dh ; bovenste rechthoek waar kleuren op getoont worden
	
	;; later zal er nog een functie geschreven worden zodat dit niet allemaal handmatig moet gebeuren
	;  al deze vierkantjes geven een kleur weer 
	call	DrawFullRectangle,col1and6x,col1to5y,dimsprites, dimsprites, color1 ;kleur 1 BLAUW
	call	DrawFullRectangle,col2and7x,col1to5y,dimsprites, dimsprites, color2 ;kleur 2
	call	DrawFullRectangle,col3and8x,col1to5y,dimsprites, dimsprites, color3 ;kleur 3
	call	DrawFullRectangle,col4and9x,col1to5y,dimsprites, dimsprites, color4 ;kleur 4
	call	DrawFullRectangle,col5and10x,col1to5y,dimsprites, dimsprites, color5 ;kleur 5
	call	DrawFullRectangle,col1and6x,col6to10y,dimsprites, dimsprites, color6 ;kleur 6 GEEL
	call	DrawFullRectangle,col2and7x,col6to10y,dimsprites, dimsprites, color7 ;kleur 7
	call	DrawFullRectangle,col3and8x,col6to10y,dimsprites, dimsprites, color8 ;kleur 8
	call	DrawFullRectangle,col4and9x,col6to10y,dimsprites, dimsprites, color9 ;kleur 9
	call	DrawFullRectangle,col5and10x,col6to10y,dimsprites, dimsprites, white ;kleur 10
	
	
	call waitforkeybrush

	;; dit zijn functies om te testen of er effectief van kleuren kan veranderd worden
	;; voor nu kun je dus ook van kleur veranderen met de c en b toets, maar dit zal nog weggehaald worden
	call waitForSpecificKeystroke, 99
	mov [current_brush], 4

	 


	
	call waitForSpecificKeystroke, 001Bh ; keycode for ESC
	call mouse_uninstall
	call terminateProcess, 001Bh
ENDP main

; -------------------------------------------------------------------
DATASEG
	palette		db 768 dup (?)
	
	eraser db 17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,17H,17H,17H,00H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,17H,17H,00H,40H,00H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,17H,00H,40H,40H,40H,00H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,00H,40H,40H,40H,40H,40H,00H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,00H,40H,40H,40H,40H,40H,00H,00H,17H,17H,17H
		   db 17H,17H,17H,17H,00H,40H,40H,40H,40H,40H,00H,40H,00H,17H,17H,17H
		   db 17H,17H,17H,00H,40H,40H,40H,40H,40H,00H,40H,40H,00H,17H,17H,17H
		   db 17H,17H,00H,40H,00H,40H,40H,40H,00H,40H,40H,00H,17H,17H,17H,17H
		   db 17H,17H,00H,40H,40H,00H,40H,00H,40H,40H,00H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,00H,40H,40H,00H,40H,40H,00H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,00H,40H,00H,40H,00H,17H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,00H,00H,00H,17H,17H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H
		   db 17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H,17H
		   
	jerry  db 00H,00H,00H
		   db 00H,1FH,00H
		   db 00H,00H,00H
	
	current_color db 06h
	
	current_brush db 1
	
	floodfill_on db 0
	
	background_curr_pix db 0Fh
	
	current dd 4
	
	previous dd 4
	
	underneath db 1Dh, 1Dh, 1Dh
			   db 1Dh, 1Dh, 1Dh
			   db 1Dh, 1Dh, 1Dh
	block db 0
	


;-------------------------------------------------------------------
UDATASEG
	mousex dd ?
	mousey dd ?
	pixelcol db ?
	
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 1000h

END main