; -----------------------------------------------------------
; This file implements the combo streak feature for alien kills.
; 
;	Bugs:
;		- Combo resets when bullets 'passed through' aliens
;		- When bullets collide, combo increments
; -----------------------------------------------------------

DATASEG
	COMBO_STRING    db  '| ', '$' ; label

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

CODESEG

;--------------------------------------------------------------------
; Display the combo label on screen (unused)
;--------------------------------------------------------------------

proc DisplayCombo ; called in Game.asm, search word "#Jieco"
	xor bh, bh
	mov dh, 23
	mov dl, 35
	mov ah, 2
	int 10h
	mov ah, 9
	mov dx, offset COMBO_STRING
	int 21h
	ret
endp DisplayCombo

;--------------------------------------------------------------------
; Updates the combo shown on screen
;--------------------------------------------------------------------

proc UpdateComboStat ; called in Game.asm, search word "#Jieco"
	xor bh, bh
	mov dh, 19
	mov dl, 37
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
