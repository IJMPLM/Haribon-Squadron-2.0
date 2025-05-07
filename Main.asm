; -----------------------------------------------------------
;This is the main file for the game. It includes all the
;other files and calls the main functions.
; -----------------------------------------------------------

IDEAL
MODEL small
STACK 100h
P386

CODESEG

include "Library/FileUse.asm"
include "Library/Game.asm"
include "Library/Print.asm"
include "Library/Menus.asm"

start:
    mov ax, @data
    mov ds, ax


    ;Check if debug mode is enabled ( -dbg flag)
    call CheckDebug
    cmp ax, 0
    je setVideoMode

    mov [byte ptr DebugBool], 1 ;set debug as true

setVideoMode:
    ;Set video mode:
    mov ax, 13h
    int 10h

    call PrintOpening
    call PrintMainMenu

    ;Set text mode back:
    mov ax, 03h
    int 10h

exit:
    mov ax, 4c00h
    int 21h
END start