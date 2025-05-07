
IDEAL
MODEL small
STACK 100h

include "Library/CC.asm"
; include "Library/Procs.asm"
; include "Library/FileUse.asm"
; include "Library/Game.asm"
; include "Library/Print.asm"
; include "Library/Menus.asm"

DATASEG
  PrintMe db 'Hello World$'
  STREAK db 0 ; 255 max

CODESEG
start:
  mov ax, @data
  mov ds, ax
  mov cx, 5
addScore:
  mov ah, 01h
  int 21h
  inc [STREAK]
  loop addScore

  mov al, [STREAK]
  xor ah, ah
  call PrintDecimal

exit:
  mov ax, 4c00h
  int 21h

END start
