CODESEG

proc PlaySoundLaser
    mov al, 0b6h
    out 43h, al
    mov ax, 0400h ; High frequency for laser
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_laser:
        nop
        loop delay_laser
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundLaser

proc PlaySoundHeal
    mov al, 0b6h
    out 43h, al
    mov ax, 2000h ; Much higher, pleasant healing tone
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_heal:
        nop
        loop delay_heal
    in al, 61h
    and al, 0fch
    out 61h, al
    ret
endp PlaySoundHeal

proc PlaySoundShieldActivate
    mov al, 0b6h
    out 43h, al
    mov ax, 0500h ; Deeper, more protective sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_shield:
        nop
        loop delay_shield
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
    mov ax, 2500h ; Very high crystalline sound
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    mov cx, 1000h
    delay_freeze:
        nop
        loop delay_freeze
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
    mov al, 0b6h ; Set channel 2 (the PC speaker) to operate in square wave mode
    out 43h, al
    mov ax, 0c74h ; Set the frequency of the sound (in this case, roughly 3276 Hz)
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3 ; Turn on the speaker
    out 61h, al

    ; Delay for a while
    mov cx, 0ffffh
    mov bx, 0ah ; Repeat the delay 10 times
    outer_delay:
        push cx ; Save the original value of cx
        delaySoundDeath:
            nop
            loop delaySoundDeath
        pop cx ; Restore the original value of cx
        dec bx ; Decrease the counter
        jnz outer_delay ; Repeat the delay if bx is not zero

    ; Turn off the speaker
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
