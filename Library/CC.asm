; -----------------------------------------------------------
; This file implements the combo streak feature for alien kills.
;
; The combo should:
;   - unlocks a skill after reaching a certain combo count
;   - if streak reaches max (9x) then the ff consecutive hit is added to score.    
;   - combo count is consumed upon use which is equivalent to the combo count 
;     requirement of a skill
;   - streak can reset (a) if the timer runs out or (b) if bullet missed
;     and hits the boundaries of screen
;
; Checklist:
;   [/] cmp if COMBO_VAL = COMBO_MAX, if yes stops, otherwise continue incrementing
;   [/] should reset to 0 if player killed 
;   [ ] or hits boundaries, using COMBO_ACTIVE
;   [/] combo after 9x should be added to score +1 +1 ... sa score
; 
; -----------------------------------------------------------

DATASEG
	COMBO_STRING    db  '| ', '$' ; label

    COMBO_ACTIVE db 0       ; sets state of combo
    COMBO_VAL       db  ?   ; where combo count is stored
    COMBO_MAX       db  3   ; set combo cap to 9

CODESEG
;--------------------------------------------------------------------
; Display the combo label on screen
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
	mov dh, 23
	mov dl, 37
	mov ah, 2
	int 10h         ; layout on screen

	xor ah, ah
	mov al, [COMBO_VAL]

@@ConvertComboValue:
	add al, '0'   ; convert to ASCII
	mov dl, al
	mov ah, 2
	int 21h               

@@EndUpdateCombo:
	ret
endp UpdateComboStat

;--------------------------------------------------------------------
; Increments combo upon kill (not yet consecutive)
;--------------------------------------------------------------------
proc IncrementCombo ; called in Alien.asm, search word "#Jieco"
    xor ah, ah
    mov al, [COMBO_VAL]
	cmp [COMBO_MAX], al ; check if COMBO_VAL has reached COMBO_MAX
    je @@ComboMax       ; Jump if yes

@@IncrementPhase:
    inc [byte ptr COMBO_VAL]
    ret

@@ComboMax:
    inc [byte ptr Score]
    ret
endp IncrementCombo
