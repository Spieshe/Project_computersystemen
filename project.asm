; -------------------------------------------------------------------
; 80386
; 32-bit x86 assembly language
; TASM
;
; author:	David Blinder, Stijn Bettens
; date:		23/10/2018
; program:	Video mode 13h
; -------------------------------------------------------------------

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "mouse.inc"

; compile-time constants (with macros)
VMEMADR EQU 0A0000h	; video memory address
SCRWIDTH EQU 320	; screen witdth
SCRHEIGHT EQU 200	; screen height

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

; create a gradient palette
PROC gradientPalette
	USES edi, eax
	
	mov edi, offset palette
	xor al, al
	
@@colorloop:
	stosb
	stosb
	stosb
	inc al
	cmp al, 64
	jne @@colorloop
ret	
ENDP gradientPalette

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

PROC mouseHandler ;; GEKOPIEERD 
	ARG @@col:byte
    USES    eax, ebx, ecx, edx
	
;	mov bh, [@@col]
	and bl, 3			; check for one mouse buttons 
	jz @@skipit			; only execute if a mousebutton is pressed

    movzx eax, dx		; get mouse height
	mov edx, SCRWIDTH
	mul edx				; obtain vertical offset in eax
	sar cx, 1			; horizontal cursor position is doubled in input 
	add ax, cx			; add horizontal offset
	add eax, VMEMADR	; eax now contains pixel address mouse is pointing to
	mov bl, [@@col]
	mov [eax], bl	; change color


	@@skipit:
    ret
ENDP mouseHandler

PROC mouseposition
    USES    eax, ebx, ecx, edx
    
	and bl, 3			; check for two mouse buttons (2 low end bits)
	jz @@skipit			; only execute if a mousebutton is pressed

    movzx eax, dx		; get mouse height
    cmp eax, 55
    jge callmousehandler
    
	mov edx, SCRWIDTH
	mul edx				; obtain vertical offset in eax
	sar cx, 1			; horizontal cursor position is doubled in input 
	add ax, cx			; add horizontal offset
	add eax, VMEMADR	; eax now contains pixel address mouse is pointing to
	jmp @@skipit
	
@@callmousehandler:
	call mouseHandler
	
@@skipit:
    ret
ENDP mouseposition


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

        call mouse_install, offset mouseposition, 28h
	call	fillBackground, 1Fh

	
	
	call	DrawFullRectangle,0,0,SCRWIDTH,55, 1Dh   ; bovenbalk
	call	DrawFullRectangle,150,5,15, 15, 15h ;kleur 1
	call	DrawFullRectangle,180,5,15, 15, 23h ;kleur 2
	call	DrawFullRectangle,210,5,15, 15, 24h ;kleur 3
	call	DrawFullRectangle,240,5,15, 15, 28h ;kleur 4
	call	DrawFullRectangle,270,5,15, 15, 2Ah ;kleur 5
	call	DrawFullRectangle,150,25,15, 15, 2Ch ;kleur 6
	call	DrawFullRectangle,180,25,15, 15, 2Fh ;kleur 7
	call	DrawFullRectangle,210,25,15, 15, 06h ;kleur 8
	call	DrawFullRectangle,240,25,15, 15, 00h ;kleur 9
	call	DrawFullRectangle,270,25,15, 15, 0Fh ;kleur 10
	
	
	call waitForSpecificKeystroke, 001Bh ; keycode for ESC
	call mouse_uninstall
	call terminateProcess, 001Bh
ENDP main

; -------------------------------------------------------------------
DATASEG
	palette		db 768 dup (?)
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main
