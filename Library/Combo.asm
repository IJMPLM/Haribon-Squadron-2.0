; -----------------------------------------------------------
; This file implements the combo streak feature for alien kills.
;
;	Bug:
;		- Combo does not reset when stage is immediately cleared
; -----------------------------------------------------------

DATASEG

	COMBO_STRING    db  '| ', '$' ; label
	COMBO_Y				equ	37
	COMBO_X				equ 19

	COMBO_ACTIVE 			db 	0   ; sets state of combo
	COMBO_KILL_COUNT	db 	?		; kill count for combo trigger
	COMBO_TRIGGER			db 	1		; sets the no. of kill count should the combo trigger 
	COMBO_VAL       	db  ?   ; where combo value is stored
	COMBO_MAX       	db  9   ; set combo cap to 9

	; Skill costs
	REGEN_COST      	equ 9    ; Cost for heart regeneration
	INVINCIBLE_COST 	equ 7    ; Cost for invincibility
	FREEZE_COST     	equ 5    ; Cost for freeze

	; Skill availability flags  
	CAN_USE_REGEN    	db  0    ; Flag if regen is available
	CAN_USE_INVINCIBLE db  0    ; Flag if invincibility is available
	CAN_USE_FREEZE   	db  0    ; Flag if freeze is available

	; Combo BMPs
	Combo0FileName				db	'Assets/0.bmp', 0
	Combo0FileHandle			dw	?
	Combo0Length					equ	16
	Combo0Height					equ	16

	; Combo1FileName				db	'Assets/1.bmp', 0
	Combo1FileHandle			dw	?
	Combo1Length					equ	16
	Combo1Height					equ	16

	; Combo2FileName				db	'Assets/2.bmp', 0
	Combo2FileHandle			dw	?
	Combo2Length					equ	16
	Combo2Height					equ	16

	Combo3FileName				db	'Assets/3.bmp', 0
	Combo3FileHandle			dw	?
	Combo3Length					equ	16
	Combo3Height					equ	16

	; Combo4FileName				db	'Assets/4.bmp', 0
	Combo4FileHandle			dw	?
	Combo4Length					equ	16
	Combo4Height					equ	16

	Combo5FileName				db	'Assets/5.bmp', 0
	Combo5FileHandle			dw	?
	Combo5Length					equ	16
	Combo5Height					equ	16

	; Combo6FileName				db	'Assets/6.bmp', 0
	Combo6FileHandle			dw	?
	Combo6Length					equ	16
	Combo6Height					equ	16

	; Combo7FileName				db	'Assets/7.bmp', 0
	Combo7FileHandle			dw	?
	Combo7Length					equ	16
	Combo7Height					equ	16

	; Combo8FileName				db	'Assets/8.bmp', 0
	Combo8FileHandle			dw	?
	Combo8Length					equ	16
	Combo8Height					equ	16

	Combo9FileName				db	'Assets/9.bmp', 0
	Combo9FileHandle			dw	?
	Combo9Length					equ	16
	Combo9Height					equ	16
	
	ComboPrintStartLine		equ	149
	ComboPrintStartRow		equ	285

CODESEG

;--------------------------------------------------------------------
; Display the combo label on screen
;--------------------------------------------------------------------

proc DisplayCombo ; called in Game.asm, search word "#Jieco"
	xor ah, ah
	mov al, [COMBO_VAL]
	cmp al, 0
	je @@NoDisplay
	cmp al, 1
	je @@printCombo1
	cmp al, 2
	je @@printCombo2
	cmp al, 3
	je @@printCombo3
	cmp al, 4
	je @@printCombo4
	cmp al, 5
	je @@printCombo5
	cmp al, 6
	je @@printCombo6
	cmp al, 7
	je @@printCombo7
	cmp al, 8
	je @@printCombo8
	cmp al, 9
	je @@printCombo9

@@NoDisplay:	; should have 0 bmp
	push offset Combo0FileName
	push offset Combo0FileHandle	
	call OpenFile

	push [Combo0FileHandle]
	push Combo0Length
	push Combo0Height
	push ComboPrintStartLine
	push ComboPrintStartRow
	push offset FileReadBuffer
	call PrintBMP

	push [Combo0FileHandle]
	call CloseFile
	ret

@@printCombo1:
	ret

@@printCombo2:
	ret

@@printCombo3:
	push offset Combo3FileName
	push offset Combo3FileHandle	
	call OpenFile

	push [Combo3FileHandle]
	push Combo3Length
	push Combo3Height
	push ComboPrintStartLine
	push ComboPrintStartRow
	push offset FileReadBuffer
	call PrintBMP

	push [Combo3FileHandle]
	call CloseFile
	ret

@@printCombo4:
	ret

@@printCombo5:
	push offset Combo5FileName
	push offset Combo5FileHandle	
	call OpenFile

	push [Combo5FileHandle]
	push Combo5Length
	push Combo5Height
	push ComboPrintStartLine
	push ComboPrintStartRow
	push offset FileReadBuffer
	call PrintBMP

	push [Combo5FileHandle]
	call CloseFile
	ret

@@printCombo6:
	ret

@@printCombo7:
	ret

@@printCombo8:
	ret

@@printCombo9:
	ret

endp DisplayCombo

;--------------------------------------------------------------------
; Updates the combo shown on screen (to be hidden)
;--------------------------------------------------------------------

proc UpdateComboStat ; called in Game.asm, search word "#Jieco"
	xor bh, bh
	mov dh, 19
	mov dl, 33
	mov ah, 2
	int 10h

	xor ah, ah
	mov al, [COMBO_VAL]

@@ConvertComboValue: ; convert to ASCII
	add al, '0'   
	mov dl, al
	mov ah, 2
	int 21h

@@EndUpdateCombo:
	ret
endp UpdateComboStat

;--------------------------------------------------------------------
; Validate combo state
;--------------------------------------------------------------------

proc ValidateCombo
	xor ah, ah
	mov al, [COMBO_KILL_COUNT]
	cmp [COMBO_TRIGGER], al
	je @@ActivateCombo	; if COMBO_KILL_COUNT = COMBO_TRIGGER, activate combo

@@IncrementKillCount:
	inc [byte ptr COMBO_KILL_COUNT]
	ret

@@ActivateCombo:
	inc [byte ptr COMBO_ACTIVE]
	call IncrementCombo
	ret

endp ValidateCombo

;--------------------------------------------------------------------
; Increments combo upon kill
;--------------------------------------------------------------------

proc IncrementCombo ; called in Alien.asm, search word "#Jieco"
	xor ah, ah
	mov al, [COMBO_VAL]
	cmp [COMBO_MAX], al 
	je @@ComboMax       ; if COMBO_VAL has reached COMBO_MAX, adds consecutive hits to score

@@IncrementPhase:
	inc [byte ptr COMBO_VAL]
	ret

@@ComboMax:
	inc [byte ptr Score]
	ret

endp IncrementCombo

;--------------------------------------------------------------------
; Resets combo
;--------------------------------------------------------------------

proc ResetCombo	; called in Game.asm, search word "#Jieco"
	mov [byte ptr COMBO_VAL], 0
	mov [byte ptr COMBO_KILL_COUNT], 0
	mov [byte ptr COMBO_ACTIVE], 0
	ret
endp ResetCombo

;--------------------------------------------------------------------
; Check which skills are available based on current combo value
;--------------------------------------------------------------------

proc CheckSkillAvailability
	; Check Regen Heart availability
	mov al, [COMBO_VAL]
	cmp al, REGEN_COST
	jae @@canRegen
	mov [byte ptr CAN_USE_REGEN], 0
	jmp @@checkInvincible
@@canRegen:
	mov [byte ptr CAN_USE_REGEN], 1

@@checkInvincible:
	mov al, [COMBO_VAL]
	cmp al, INVINCIBLE_COST
	jae @@canInvincible
	mov [byte ptr CAN_USE_INVINCIBLE], 0
	jmp @@checkFreeze
@@canInvincible:
	mov [byte ptr CAN_USE_INVINCIBLE], 1

@@checkFreeze:
	mov al, [COMBO_VAL]
	cmp al, FREEZE_COST
	jae @@canFreeze
	mov [byte ptr CAN_USE_FREEZE], 0
	jmp @@endCheck
@@canFreeze:
	mov [byte ptr CAN_USE_FREEZE], 1

@@endCheck:
	ret
endp CheckSkillAvailability
