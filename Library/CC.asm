COMBO_STREAK_COUNT   db 0
COMBO_ACTIVE         db 0

; Called on alien hit
proc IncrementComboStreak
    cmp [COMBO_ACTIVE], 0
    je @startStreak

    cmp [COMBO_STREAK_COUNT], 9
    jae @maxed
    inc [COMBO_STREAK_COUNT]

@maxed:
    jmp @done

@startStreak:
    mov [COMBO_ACTIVE], 1
    mov [COMBO_STREAK_COUNT], 1

@done:
    ret
endp IncrementComboStreak
