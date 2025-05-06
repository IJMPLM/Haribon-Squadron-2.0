; -----------------------------------------------------------
; This file implements the combo streak feature for alien kills.
;
; The combo should:
;   - unlocks a skill after reaching a certain combo count
;   - if streak reaches max (9x) then streak is added to score. Streak will reset
;   - combo count is consumed upon use which is equivalent to the combo count 
;     requirement of a skill
;   - streak can reset (a) if the timer runs out or (b) if bullet missed
;     and hits the boundaries of screen
; -----------------------------------------------------------



DATASEG
    COMBO_COUNT db 0
    COMBO_COUNT_MAX db 9
    COMBO_ACTIVE db 0       ; tentative

CODESEG

;--------------------------------------------------------------------
; Display the combo value on screen (Jieco)
;--------------------------------------------------------------------

proc DisplayCombo ; called in Game.asm
	xor bh, bh
	mov dh, 23
	mov dl, 35
	mov ah, 2
	int 10h
	mov ah, 9
	mov dx, offset ComboString
	int 21h
	ret
endp DisplayCombo

;--------------------------------------------------------------------
; Updates the combo shown on screen (Jieco)
;--------------------------------------------------------------------
proc UpdateComboStat
	xor bh, bh
	mov dh, 23
	mov dl, 37
	mov ah, 2
	int 10h

	xor ah, ah
	mov al, [Combo]
	
	; [ ] cmp if ComboValue = ComboMax, if yes stops, otherwise continue converting
	; [/] should reset to 0 if player killed 
	; [ ] or hits boundaries
	; [ ] combo after 9x should be added to score +1 +1 ... sa score

@@ConvertComboValue:
	add al, '0'   ; convert to ASCII
	mov dl, al
	mov ah, 2
	int 21h               

@@EndUpdateCombo:
	ret

	; mov ah, 9
	; mov dx, offset ComboCounter
	; int 21h
endp UpdateComboStat