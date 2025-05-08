; -----------------------------------------------------------
; This file contains the game assets, the gameplay logic, 
; and the game loop.
; -----------------------------------------------------------


DATASEG
include "Library/Strings.asm"

	DebugBool						db	0
	FreezeActive					db	0    ; Freeze state flag
	FreezeCounter					dw	0    ; Counter for freeze duration
	InvincibleActive				db	0    ; Invincibility state flag
	InvincibleCounter				dw	0    ; Counter for invincibility duration
	
; -----------------------------------------------------------
; Accessing bitmap files and text files for the game assets
; -----------------------------------------------------------

	RandomFileName					db	'Assets/Random.txt', 0
	RandomFileHandle				dw	?

	ScoresFileName					db	'Assets/Scores.txt', 0
	ScoresFileHandle				dw	?

	ScoreTableFileName				db	'Assets/ScoreTab.bmp', 0
	ScoreTableFileHandle			dw	?

	AskSaveFileName					db	'Assets/AskSave.bmp', 0
	AskSaveFileHandle				dw	?

	MainMenuFileName				db	'Assets/MainMenu.bmp',0
	MainMenuFileHandle				dw	?

	OpeningFileName					db	'Assets/Opening.bmp',0
	OpeningFileHandle				dw	?

	InstructionsFileName			db	'Assets/Instruct.bmp',0
	InstructionsFileHandle			dw	?

	AlienFileName					db	'Assets/Alien.bmp',0
	AlienFileHandle					dw	?
	AlienLength						equ	32
	AlienHeight						equ	32

	FAlienFileName					db	'Assets/FAlien.bmp',0
	FAlienFileHandle				dw	?
	FAlienLength					equ	32
	FAlienHeight					equ	32

	SplatterFileName				db	'Assets/Splatter.bmp',0
	SplatterFileHandle				dw	?
	SplatterLength					equ	8
	SplatterHeight					equ	8

	SpaceBgFileName					db	'Assets/SpaceBg.bmp',0
	SpaceBgFileHandle				dw	?

	ShooterFileName					db	'Assets/Shooter2.bmp', 0
	ShooterFileHandle				dw	?
	ShooterLength					equ	16
	ShooterHeight					equ	16

	ShooterReloadFileName			db	'Assets/Reload2.bmp', 0
	ShooterReloadFileHandle			dw	?
	ShooterReloadLength				equ	16
	ShooterReloadHeight				equ	16

	SShieldFileName					db	'Assets/SShield2.bmp', 0
	SShieldFileHandle				dw	?
	SShieldLength					equ	16
	SShieldHeight					equ	16

	RShieldFileName					db	'Assets/RShield2.bmp', 0
	RShieldFileHandle				dw	?
	RShieldLength					equ	16
	RShieldHeight					equ	16

	HeartFileName					db	'Assets/Heart.bmp', 0
	HeartFileHandle					dw	?
	HeartLength						equ	16
	HeartHeight						equ	16

; -----------------------------------------------------------
; Aliens and player locations, movements, shootings, etc...
; -----------------------------------------------------------
	AliensMoveRightBool				db	?
	AliensMovesToSideDone			db	?
	AliensPrintStartLine			dw	?
	AliensPrintStartRow				dw	?
	AliensLeftAmount				db	?
	AliensStatusArray				db	24 dup (?)

	AliensLoopMoveCounter			db	? ;Aliens move every 4 repeats of the game loop
	
	ShooterLineLocation				equ 149
	ShooterRowLocation				dw	?

	ShootingLength					equ	2
	ShootingHeight					equ	4

	PlayerShootingExists			db	?
	PlayerBulletLineLocation 		dw	?
	PlayerShootingRowLocation		dw	?

	AliensShootingMaxAmount		db	?
	AliensShootingCurrentAmount	db	?
	AliensShootingLineLocations	dw	10 dup (?)
	AliensShootingRowLocations	dw	10 dup (?)

	Score							db	?

	LivesRemaining					db	?
	Level							db	?

	DidNotDieInLevelBool			db	?


	HeartsPrintStartLine			equ	182
	HeartsPrintStartRow				equ	125

	StatsAreaBorderLine				equ	175

	FileReadBuffer					db	320 dup (?)

	;Color values:
	BlackColor						equ	0
	GreenColor						equ	30h
	RedColor						equ	40
	BlueColor						equ	54
	WhiteColor						equ	255

CODESEG
include "Library/Alien.asm"
include "Library/Procs.asm"
include "Library/Combo.asm" ; #Jieco

; -----------------------------------------------------------
; Prints the background image of the game (space background)
; -----------------------------------------------------------
proc PrintBackground
	call playSoundMenu

	push offset SpaceBgFileName
	push offset SpaceBgFileHandle
	call OpenFile

	push [SpaceBgFileHandle]
	push 320
	push 200
	push 0
	push 0
	push offset FileReadBuffer
	call PrintBMP

	push [SpaceBgFileHandle]
	call CloseFile

	ret
endp PrintBackground

; --------------------------------------------------------
; Prints the stats area of the game (level, score, lives)
; --------------------------------------------------------
proc PrintStatsArea
	; Print border:
	push 320 ;length
	push 2 ;height
	push StatsAreaBorderLine
	push 0
	push 100
	call PrintColor

	;Print labels:

	;Level label:
	xor bh, bh
	mov dh, 23
	mov dl, 1
	mov ah, 2
	int 10h

	mov ah, 9
	mov dx, offset LevelString
	int 21h


	;Score label:
	xor bh, bh
	mov dh, 23
	mov dl, 24 ; 29
	mov ah, 2
	int 10h

	mov ah, 9
	mov dx, offset ScoreString
	int 21h

	;Combo label #Jieco:
	call DisplayCombo

	ret
endp PrintStatsArea


;----------------------------------------------
; Updates the amount of lives shown on screen
;----------------------------------------------
proc UpdateLives
	;Clear previous hearts:
	push 64
	push 14
	push HeartsPrintStartLine
	push HeartsPrintStartRow
	push BlackColor
	call PrintColor

	push offset HeartFileName
	push offset HeartFileHandle
	call OpenFile

	;Print amount of lifes remaining:
	xor ch, ch
	mov cl, [LivesRemaining]

	mov bx, HeartsPrintStartRow

@@printHeart:
	push bx
	push cx

	push [HeartFileHandle]
	push HeartLength
	push HeartHeight
	push HeartsPrintStartLine
	push bx
	push offset FileReadBuffer
	call PrintBMP

	pop cx
	pop bx
	add bx, 20
	loop @@printHeart

	push [HeartFileHandle]
	call CloseFile

	ret
endp UpdateLives


;--------------------------------------------------------------------
; Updates the score shown on screen using hex to decimal conversion
;--------------------------------------------------------------------
proc UpdateScoreStat
	xor bh, bh
	mov dh, 23
	mov dl, 31
	mov ah, 2
	int 10h

	xor ah, ah
	mov al, [Score]
	push ax
	call HexToDecimal

	push ax
	mov ah, 2
	int 21h
	pop dx
	xchg dl, dh
	int 21h
	xchg dl, dh
	int 21h

	ret
endp UpdateScoreStat

; -------------------------------------------
; Updates the level and score shown on screen
; -------------------------------------------
proc UpdatePlayerStats
	;Update level:
	xor bh, bh
	mov dh, 23
	mov dl, 8
	mov ah, 2
	int 10h

	mov ah, 2
	mov dl, [byte ptr Level]
	add dl, 30h
	int 21h

	;Update score:
	call UpdateScoreStat

	ret
endp UpdatePlayerStats


; ------------------------------------------------------------
; Moving Aliens + player to initial location, removing shots
; Not getting back dead Aliens
; ------------------------------------------------------------
proc MoveToStart
	mov [byte ptr AliensMoveRightBool], 1
	mov [byte ptr AliensMovesToSideDone], 0

	mov [byte ptr AliensLoopMoveCounter], 0

	mov [byte ptr AliensPrintStartLine], 10
	mov [byte ptr AliensPrintStartRow], 8

	mov [word ptr ShooterRowLocation], 152
	mov [byte ptr PlayerShootingExists], 0

	mov [byte ptr AliensShootingCurrentAmount], 0

	cld
	push ds
	pop es

	;Zero Aliens shots locations:
	xor ax, ax

	mov di, offset AliensShootingLineLocations
	mov cx, 10
	rep stosw

	mov di, offset AliensShootingRowLocations
	mov cx, 10
	rep stosw

	ret
endp MoveToStart

; ------------------------------------------------------------
; Resetting Aliens locations, shootings, etc for a new level
; ------------------------------------------------------------
proc InitializeLevel
	mov [AliensLeftAmount], 24

	cmp [byte ptr Level], 1
	jne @@checkLevelTwo

	mov [byte ptr AliensShootingMaxAmount], 3
	jmp @@resetDidNotDieBool

@@checkLevelTwo:
	cmp [byte ptr Level], 2
	jne @@setLevelThree

	mov [byte ptr AliensShootingMaxAmount], 5
	jmp @@resetDidNotDieBool

@@setLevelThree:
	mov [byte ptr AliensShootingMaxAmount], 7

@@resetDidNotDieBool:
	mov [byte ptr DidNotDieInLevelBool], 1 ;true

	call MoveToStart


	cld
	push ds
	pop es

	;Set all Aliens as 'active':
	mov di, offset AliensStatusArray
	mov cx, 24
	mov al, 1
	rep stosb

	ret
endp InitializeLevel


; -----------------------------------------------
; Initiating the game, setting the initial values
; -----------------------------------------------
proc InitializeGame
	mov [byte ptr Score], 0
	mov [byte ptr LivesRemaining], 3
	mov [byte ptr Level], 1


	call InitializeLevel

	ret
endp InitializeGame

; ------------------------------------------------
; Checks if the player was hit by an Alien shot
; If true, ax = 1. If not, ax = 0.
; ------------------------------------------------
proc CheckIfPlayerDied
	; Check invincibility first
	cmp [byte ptr InvincibleActive], 1
	je @@returnZero    ; If invincible, player can't be hit

	; Update invincibility counter if active
	cmp [InvincibleCounter], 0
	je @@normalCheck
	
	dec [InvincibleCounter]
	cmp [InvincibleCounter], 0
	jne @@returnZero
	
	mov [byte ptr InvincibleActive], 0   ; Disable invincibility when counter reaches 0

@@normalCheck:
	xor ch, ch
	mov cl, [AliensShootingCurrentAmount]
	cmp cx, 0
	je @@returnZero

	xor si, si

@@checkShot:
	;check from above:
	mov ax, ShooterLineLocation
	sub ax, 3
	cmp ax, [AliensShootingLineLocations + si]
	ja @@checkNextShot

	;check from below:
	add ax, 3
	add ax, 16 ;height
	cmp ax, [AliensShootingLineLocations + si]
	jb @@checkNextShot

	;check from left
	mov ax, [ShooterRowLocation]
	dec ax
	cmp ax, [AliensShootingRowLocations + si]
	ja @@checkNextShot

	;check from right:
	add ax, 16 ;length
	cmp ax, [AliensShootingRowLocations + si]
	jb @@checkNextShot

	;Player hit:
	mov ax, 1
	ret 

@@checkNextShot:
	inc si
	loop @@checkShot

@@returnZero:
	;Player not hit:
	xor ax, ax 
	ret
endp CheckIfPlayerDied


; ---------------------------------------------------------------
; Checks if the currently lowest line of Aliens reached too low
; If true, ax = 1. If not, ax = 0.
; ---------------------------------------------------------------
proc CheckIfAliensReachedBottom
	mov cx, 8
	mov bx, 16

@@checkLineTwo:
	cmp [AliensStatusArray + bx], 0
	jne @@lineTwoNotEmpty

	inc bx
	loop @@checkLineTwo

	mov cx, 8
	mov bx, 8

@@checkLineOne:
	cmp [AliensStatusArray + bx], 0
	jne @@lineOneNotEmpty
	
	inc bx
	loop @@checkLineOne

	mov cx, 8
	xor bx, bx

@@checkLineZero:
	cmp [AliensStatusArray + bx], 0
	jne @@lineZeroNotEmpty
	
	inc bx
	loop @@checkLineZero

	jmp @@AliensDidNotReachBottom

@@lineTwoNotEmpty:
	cmp [word ptr AliensPrintStartLine], ShooterLineLocation - 59
	ja @@AliensReachedBottom

	jmp @@AliensDidNotReachBottom

@@lineOneNotEmpty:
	cmp [word ptr AliensPrintStartLine], ShooterLineLocation - 39
	ja @@AliensReachedBottom

	jmp @@AliensDidNotReachBottom

@@lineZeroNotEmpty:
	cmp [word ptr AliensPrintStartLine], ShooterLineLocation - 19
	ja @@AliensReachedBottom


@@AliensDidNotReachBottom:
	xor ax, ax
	ret

@@AliensReachedBottom:
	mov ax, 1
	ret
endp CheckIfAliensReachedBottom


; -----------------------------------------------------------
; Initiating the game, combining the game parts together
; Handles shooter + Aliens hits and deaths, movements, etc.
; -----------------------------------------------------------
proc PlayGame
	push offset AlienFileName
	push offset AlienFileHandle
	call OpenFile

	push offset FAlienFileName
	push offset FAlienFileHandle
	call OpenFile

	push offset SplatterFileName
	push offset SplatterFileHandle
	call OpenFile

	push offset ShooterFileName
	push offset ShooterFileHandle
	call OpenFile

	push offset ShooterReloadFileName
	push offset ShooterReloadFileHandle
	call OpenFile

	push offset SShieldFileName
	push offset SShieldFileHandle
	call OpenFile

	push offset RShieldFileName
	push offset RShieldFileHandle
	call OpenFile

	call InitializeGame

	call ClearScreen


@@firstLevelPrint:
	call PrintBackground
	call PrintStatsArea
	call UpdatePlayerStats
	call UpdateLives
	call UpdateComboStat ; #Jieco

	call CheckAndMoveAliens

	push [ShooterFileHandle]
	push ShooterLength
	push ShooterHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push offset FileReadBuffer
	call PrintBMP


	call PrintAliens


	;Print countdown to start:
	mov cx, 3
	mov dx, 33h
@@printCountdownNum:
	push cx
	push dx

	mov ah, 2
	xor bh, bh
	mov dh, 12
	mov dl, 19
	int 10h

	pop dx
	push dx
	mov ah, 2
	int 21h

	push 18
	call Delay

	pop dx
	dec dx
	pop cx
	loop @@printCountdownNum

	;clear number:
	mov ah, 2
	xor bh, bh
	mov dh, 12
	mov dl, 19
	int 10h

	xor dl, dl
	mov ah, 2
	int 21h


@@readKey:
	mov ah, 1
	int 16h

	jz @@checkShotStatus

    ; Clean buffer:
    push ax
    xor al, al
    mov ah, 0ch
    int 21h
    pop ax

    ; Check which key was pressed:
    cmp ah, 1 ; Esc
    je @@procEnd

    cmp ah, 39h ; Space
    je @@shootPressed

    cmp ah, 4Bh ; Left
    je @@moveLeft

    cmp ah, 4Dh ; Right
    je @@moveRight

    cmp ah, 2Dh ; X key for freeze
    je @@freezePressed

    cmp ah, 2Eh ; C key for invincibility
    je @@invincibilityPressed

    cmp ah, 2Ch ; Z (Regenerate Heart)
    je @@regenerateHeart

    jmp @@readKey

@@invincibilityPressed:
    cmp [byte ptr InvincibleActive], 1  ; Check if already invincible
    je @@readKey
    
    mov [byte ptr InvincibleActive], 1   ; Activate invincibility
    mov [word ptr InvincibleCounter], 36 ; Set duration (2 seconds)
    jmp @@readKey

@@freezePressed:
    cmp [byte ptr FreezeActive], 1  ; Check if already frozen
    je @@readKey
    
    mov [byte ptr FreezeActive], 1   ; Activate freeze
    mov [word ptr FreezeCounter], 54 ; Set duration (3 seconds; 18 ticks/second)

	; Force redraw of aliens to show frozen state immediately
    call ClearAliens
    call PrintAliens
    
    jmp @@readKey

@@regenerateHeart:
    cmp [LivesRemaining], 3 ; Max lives is 3
    jae @@readKey

    inc [LivesRemaining]
    call UpdateLives
    jmp @@readKey

@@moveLeft:
    cmp [word ptr ShooterRowLocation], 21
    jb @@clearShot

    ; Clear current shooter print:
    push ShooterLength
    push ShooterHeight
    push ShooterLineLocation
    push [word ptr ShooterRowLocation]
    push BlackColor
    call PrintColor

    sub [word ptr ShooterRowLocation], 10
    jmp @@printShooterAgain

@@moveRight:
    cmp [word ptr ShooterRowLocation], 290
    ja @@clearShot

    ; Clear current shooter print:
    push ShooterLength
    push ShooterHeight
    push ShooterLineLocation
    push [word ptr ShooterRowLocation]
    push BlackColor
    call PrintColor

    add [word ptr ShooterRowLocation], 10
    jmp @@printShooterAgain

@@printShooterAgain:
	cmp [byte ptr PlayerShootingExists], 1
	je @@printReload
	cmp [byte ptr InvincibleActive], 1
	je @@printShield

	; Regular Shooter Print if all above are false
	push [ShooterFileHandle]
	push ShooterLength
	push ShooterHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push offset FileReadBuffer
	call PrintBMP
	jmp @@checkShotStatus

@@printShield:
	push [SShieldFileHandle]
	push SShieldLength
	push RShieldHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push offset FileReadBuffer
	call PrintBMP
	jmp @@checkShotStatus

@@printReloadShield:
	push [RShieldFileHandle]
	push RShieldLength
	push RShieldHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push offset FileReadBuffer
	call PrintBMP
	jmp @@checkShotStatus

@@printReload:
	cmp [byte ptr InvincibleActive], 1
	je @@printReloadShield
	push [ShooterReloadFileHandle]
	push ShooterReloadLength
	push ShooterReloadHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push offset FileReadBuffer
	call PrintBMP

@@checkShotStatus:
	; Update invincibility counter if active
	cmp [InvincibleCounter], 0
	je @@checkPlayerShot
	
	dec [InvincibleCounter]
	cmp [InvincibleCounter], 0
	jne @@checkPlayerShot
	
	mov [byte ptr InvincibleActive], 0   ; Disable invincibility when counter reaches 0

@@checkPlayerShot:
	;Check if shooting already exists in screen:
	cmp [byte ptr PlayerShootingExists], 0
	jne @@moveShootingUp

	jmp @@clearShot

@@shootPressed:	

	;Check if shooting already exists in screen:
	cmp [byte ptr PlayerShootingExists], 0
	jne @@moveShootingUp
	call playSoundShoot


@@initiateShot:
	;Set initial shot location:
	mov ax, ShooterLineLocation
	sub ax, 6
	mov [word ptr PlayerBulletLineLocation], ax
	mov ax, [ShooterRowLocation]
	add ax, 7
	mov [word ptr PlayerShootingRowLocation], ax

	mov [byte ptr PlayerShootingExists], 1
	jmp @@printShooting

@@moveShootingUp:
	cmp [word ptr PlayerBulletLineLocation], 10
	jb @@removeShot

	sub [word ptr PlayerBulletLineLocation], 10

@@printShooting:
	push ShootingLength
	push ShootingHeight
	push [word ptr PlayerBulletLineLocation]
	push [word ptr PlayerShootingRowLocation]
	push BlueColor
	call PrintColor

	jmp @@clearShot

@@removeShot:
	call ResetCombo				; Resets combo #Jieco
	call UpdateComboStat	; Reflect changes on screen 

	mov [byte ptr PlayerShootingExists], 0
	mov [word ptr PlayerBulletLineLocation], 0
	mov [word ptr PlayerShootingRowLocation], 0

@@clearShot:
	push 2
	call Delay

	;Clear shot:
	push ShootingLength
	push ShootingHeight
	push [word ptr PlayerBulletLineLocation]
	push [word ptr PlayerShootingRowLocation]
	push BlackColor
	call PrintColor

	cmp [byte ptr AliensLeftAmount], 0
	je @@setNewLevel

	;Check if Alien hit:
	call CheckAndHitAlien


@@moveAliens:
	call ClearAliensShots

	call CheckAndMoveAliens
	
	call CheckIfAliensReachedBottom
	cmp ax, 1
	je @@playerDied

	call UpdateAliensShots
	call AliensRandomShot
	call printAliensShots


	;Check if player was hit:
	call CheckIfPlayerDied
	cmp ax, 0
	je @@readKey

@@playerDied:
	;Player died:

	call playSoundDeath

	push 18
	call Delay

	;decrease amount of lives left, check if 0 left:
	dec [byte ptr LivesRemaining]
	cmp [byte ptr LivesRemaining], 0
	je @@printDied

	;Clear screan without stats area:
	push 320
	push StatsAreaBorderLine
	push 0 ;line
	push 0 ;row
	push BlackColor
	call PrintColor

	mov ah, 2
	xor bh, bh
	mov dh, 12
	mov dl, 8
	int 10h

	;tell user he was hit, -5 score...
	mov ah, 9
	mov dx, offset HitString
	int 21h

; Nice blink animation for death:
	mov cx, 3
@@blinkShooter:
	push cx

	push ShooterLength
	push ShooterHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push BlackColor
	call PrintColor

	push 6
	call Delay

	push [word ptr ShooterFileHandle]
	push ShooterLength
	push ShooterHeight
	push ShooterLineLocation
	push [word ptr ShooterRowLocation]
	push offset FileReadBuffer
	call PrintBMP

	push 6
	call Delay

	pop cx
	loop @@blinkShooter

	; reset combo #Jieco 
	call ResetCombo

	;sub 5 score if possible, if he doesn't have 5 yet, just reset to 0:
	cmp [byte ptr Score], 5
	jb @@resetScoreAfterDeath

	sub [byte ptr Score], 5
	jmp @@resetBeforeContinueAfterDeath


@@resetScoreAfterDeath:
	mov [byte ptr Score], 0

@@resetBeforeContinueAfterDeath:
	call MoveToStart

	mov [byte ptr DidNotDieInLevelBool], 0 ;false


	push 24
	call Delay

	call ClearScreen

	
	jmp @@firstLevelPrint


	jmp @@readKey

@@printDied:
	call ClearScreen
; Print a message when game is over:
	call PrintBackground

	mov ah, 2
	xor bh, bh
	mov dh, 12
	mov dl, 15
	int 10h

	mov ah, 9
	mov dx, offset GameOverString
	int 21h

	;print actual score #:
	mov ah, 2
	xor bh, bh
	mov dh, 13
	mov dl, 10
	int 10h

	mov ah, 9
	mov dx, offset YouEarnedXString
	int 21h
	
	xor ah, ah
	mov al, [Score]
	push ax
	call HexToDecimal

	push ax
	mov ah, 2
	int 21h
	pop dx
	xchg dl, dh
	int 21h
	xchg dl, dh
	int 21h

	mov ah, 9
	mov dx, offset ScoreWordString
	int 21h
	
	push 54
	call Delay

	jmp @@procEnd


@@setNewLevel:
	cmp [byte ptr DidNotDieInLevelBool], 1
	jne @@SkipPerfectLevelBonus

	add [byte ptr Score], 5 ;special bonus for perfect level (no death in level)

	;print bonus message:
	mov ah, 2
	xor bh, bh
	mov dh, 12
	mov dl, 8
	int 10h

	mov ah, 9
	mov dx, offset PerfectLevelString
	int 21h

	push 24
	call Delay

	call ClearScreen


@@SkipPerfectLevelBonus:

	cmp [byte ptr Level], 3 ; maximum level
	je @@printWin


	inc [byte ptr Level]
	call InitializeLevel

	call ClearScreen
	jmp @@firstLevelPrint

@@printWin:
; Print win message to user (finished 3 levels):

	call PrintBackground

	mov ah, 2
	xor bh, bh
	mov dh, 12
	mov dl, 15
	int 10h

	mov ah, 9
	mov dx, offset WinString
	int 21h

	;print actual score #:
	mov ah, 2
	xor bh, bh
	mov dh, 13
	mov dl, 10
	int 10h

	mov ah, 9
	mov dx, offset YouEarnedXString
	int 21h

	xor ah, ah
	mov al, [Score]
	push ax
	call HexToDecimal

	push ax
	mov ah, 2
	int 21h
	pop dx
	xchg dl, dh
	int 21h
	xchg dl, dh
	int 21h

	mov ah, 9
	mov dx, offset ScoreWordString
	int 21h

	push 54
	call Delay

@@procEnd:
	push [RShieldFileHandle]
	call CloseFile

	push [SShieldFileHandle]
	call CloseFile

	push [ShooterReloadFileHandle]
	call CloseFile

	push [ShooterFileHandle]
	call CloseFile

	call playSoundMenu

	push [SplatterFileHandle]
	call CloseFile

	push [FAlienFileHandle]
	call CloseFile

	push [AlienFileHandle]
	call CloseFile

	ret
endp PlayGame