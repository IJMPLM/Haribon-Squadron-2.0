CODESEG

proc PlaySoundLaser
    ; First tone
    mov al, 0b6h
    out 43h, al
    mov ax, 1500  ; First frequency
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 0FFFFh
    delay_heal1:
        nop
        loop delay_heal1
        
    ; Turn off speaker between tones
    in al, 61h
    and al, 0fch
    out 61h, al
    
    ; Short pause between tones
    mov cx, 1000h
    delay_between:
        nop
        loop delay_between
    
    ; Second tone
    mov al, 0b6h
    out 43h, al
    mov ax, 1800  ; Second frequency
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 0FFFFh
    delay_heal2:
        nop
        loop delay_heal2
        
    ; Turn off speaker between second and third tones
    in al, 61h
    and al, 0fch
    out 61h, al
    
    ; Short pause before third tone
    mov cx, 1000h
    delay_between2:
        nop
        loop delay_between2
    
    ; Third tone (higher pitch to complete pheww sound)
    mov al, 0b6h
    out 43h, al
    mov ax, 2500  ; Third frequency (higher)
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 08000h  ; Slightly shorter duration for final tone
    delay_heal3:
        nop
        loop delay_heal3
        
    ; Turn off speaker
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundLaser

proc PlaySoundHeal
    ; First tone (lower pitch)
    mov al, 0b6h
    out 43h, al
    mov ax, 2000  ; Start with lower pitch
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    
    push 1        ; Quick first tone
    call Delay
    
    ; Turn off speaker between tones
    in al, 61h
    and al, 0fch
    out 61h, al
    
    ; Very short gap
    push 1
    call Delay
    
    ; Second tone (higher pitch)
    mov al, 0b6h
    out 43h, al
    mov ax, 1500  ; Higher pitch
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    
    push 1        ; Quick second tone
    call Delay
    
    ; Turn off speaker
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundHeal

proc PlaySoundShieldActivate
    mov al, 0b6h
    out 43h, al
    mov ax, 5000  ; Medium-low frequency for closer, more impactful shield sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    
    push 2        ; Moderate duration
    call Delay
    
    ; Turn off speaker
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundShieldActivate

proc PlaySoundBombActivate   ; renamed from PlaySoundAOEActivate
    mov al, 0b6h
    out 43h, al
    mov ax, 0150h ; Lower frequency for bomb deployment
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_bomb_activate:     ; renamed label
        nop
        loop delay_bomb_activate
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundBombActivate

proc PlaySoundBombHit       ; renamed from PlaySoundAOEHit
    mov al, 0b6h
    out 43h, al
    mov ax, 0080h ; Even lower frequency for bigger explosion
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_bomb_hit:         ; renamed label
        nop
        loop delay_bomb_hit
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundBombHit

proc PlaySoundFreezeActivate
    mov al, 0b6h
    out 43h, al
    mov ax, 8000   ; Lower pitch for ice effect
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    
    push 1        ; Moderate duration
    call Delay
    
    ; Turn off speaker
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundFreezeActivate


proc PlaySoundSecondBullet
    mov al, 0b6h
    out 43h, al
    mov ax, 1200h ; Distinct secondary weapon sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_second_bullet:
        nop
        loop delay_second_bullet
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundSecondBullet

proc PlaySoundBulletHit
    mov al, 0b6h
    out 43h, al
    mov ax, 0350h ; Punchier impact sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_bullet_hit:
        nop
        loop delay_bullet_hit
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundBulletHit

proc PlaySoundBulletCollision
    mov al, 0b6h
    out 43h, al
    mov ax, 0350h ; Punchier impact sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_bullet_collision:
        nop
        loop delay_bullet_collision
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundBulletCollision


; ----------------------------------------------------------------------
; Sound Procs
; ----------------------------------------------------------------------

proc playSoundShoot 
    mov al, 0b6h ; Set channel 2 (the PC speaker) to operate in square wave mode
    out 43h, al
	mov ax, 0c74h ; 0c74h is 3276 in decimal, which is the frequency of the sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3 ; Turn on the speaker
    out 61h, al

    ; Delay for a while
    ;delay for 800ms
	mov cx, 0ffffh
    delaybeep:
        nop
        loop delaybeep

    ; Turn off the speaker
    in al, 61h
    and al, 0fch
    out 61h, al

    ret
endp playSoundShoot

; ----------------------------------------------------------------------
; Plays a beep sound when player is hit by Alien's shot
; ----------------------------------------------------------------------

proc playSoundDeath
    mov al, 0b6h
    out 43h, al
    mov ax, 0c74h ; Keep original frequency
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al

    ; Simpler delay structure
    mov bx, 14h ; Number of iterations
@@outer_delay:
    mov cx, 0FFFFh
@@delay_loop:
    nop
    nop
    loop @@delay_loop
    dec bx
    jnz @@outer_delay

    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp playSoundDeath

; -----------------------------------------------------------
; Plays a beep sound when Alien is hit by player's shot
; -----------------------------------------------------------

proc playSoundAlien ; Old PlaySoundBulletHit
    mov al, 0b6h ; Set channel 2 (the PC speaker) to operate in square wave mode
    out 43h, al
    ; Set the frequency of the sound to replicate an alien being destroyed
	mov ax, 0b6d0h ; 0b6d0h is the frequency of the sound

    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3 ; Turn on the speaker
    out 61h, al

    ; Delay for a while
    mov cx, 0ffffh
    mov bx, 3 ; Repeat the delay 10 times
    outer_delay_Aliensound:
        push cx ; Save the original value of cx
        delaySoundAlien:
            nop
            loop delaySoundAlien
        pop cx ; Restore the original value of cx
        dec bx ; Decrease the counter
        jnz outer_delay_Aliensound ; Repeat the delay if bx is not zero

    ; Turn off the speaker
    in al, 61h
    and al, 0fch
    out 61h, al

    ret
endp playSoundAlien

; -----------------------------------------------------------
; Plays a sound when navigating the menu
; -----------------------------------------------------------

proc playSoundMenu
    mov al, 0b6h ; Set channel 2 (the PC speaker) to operate in square wave mode
    out 43h, al
	mov ax, 0c74h ; 0c74h is 3276 in decimal, which is the frequency of the sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3 ; Turn on the speaker
    out 61h, al

    ; Delay for a while
    ;delay for 800ms
	mov cx, 0ffffh
    delaybeepmenu:
        nop
        loop delaybeepmenu

    ; Turn off the speaker
    in al, 61h
    and al, 0fch
    out 61h, al

    ret
endp playSoundMenu
