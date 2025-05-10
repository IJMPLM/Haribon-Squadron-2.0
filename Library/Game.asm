; -----------------------------------------------------------
; This file contains the game assets, the gameplay logic, 
; and the game loop.
; -----------------------------------------------------------


DATASEG
include "Library/Strings.asm"
include "Library/Database.asm"
include "Library/GAssets.asm"
include "Library/NAssets.asm"

	DebugBool						db	0

; -----------------------------------------------------------
; Accessing bitmap files and text files for the game assets
; -----------------------------------------------------------

	FreezeActive					db	0    ; Freeze state flag
	FreezeCounter					dw	0    ; Counter for freeze duration
	InvincibleActive				db	0    ; Invincibility state flag
	InvincibleCounter				dw	0    ; Counter for invincibility duration
	
; -----------------------------------------------------------
; Aliens and player locations, movements, shootings, etc...
; (Row = X, Line = Y)  
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

	SecondaryShootingExists			db	?
	SecondaryBulletLineLocation		dw	?
	SecondaryShootingRowLocation	dw	?

	AliensShootingMaxAmount		db	?
	AliensShootingCurrentAmount	db	?
	AliensShootingLineLocations	dw	10 dup (?)
	AliensShootingRowLocations	dw	10 dup (?)

	Score							db	?

	LivesRemaining					db	?
	Level							db	?

	DidNotDieInLevelBool			db	?

	LevelPrintStartLine				equ		23
	LevelPrintStartRow				equ		2

	LevelValPrintStartLine		equ 	23
	LevelValPrintStartRow			equ 	7

	BatteryPrintStartLine			equ 180
	BatteryPrintStartRow			equ 100

	BHealthPrintStartLine			equ 183
	BHealthPrintStartRow			equ	103

	HeartsPrintStartLine			equ	182		; to be replaced
	HeartsPrintStartRow				equ	75

	SkillsPrintStartLine		equ		180
	SkillsPrintStartRow			equ		140

	ScorePrintStartLine				equ		23
	ScorePrintStartRow				equ		28

	ScoreValPrintStartLine		equ 	23
	ScoreValPrintStartRow			equ		35

	StatsAreaBorderLine				equ	175

	FileReadBuffer					db	320 dup (?)

	LaserEnabled	 				db 	?
	AOEEnabled						db	0

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
	mov dh, LevelPrintStartLine
	mov dl, LevelPrintStartRow
	mov ah, 2
	int 10h

	mov ah, 9
	mov dx, offset LevelString
	int 21h

@@printSkills:		; #Skills
	push offset SkillsFileName
	push offset SkillsFileHandle	
	call OpenFile

	push [SkillsFileHandle]
	push SkillsLength
	push SkillsHeight
	push SkillsPrintStartLine
	push SkillsPrintStartRow
	push offset FileReadBuffer
	call PrintBMP

	push [SkillsFileHandle]
	call CloseFile

@@printBattery:
	push offset BatteryFileName
	push offset BatteryFileHandle	
	call OpenFile

	push [BatteryFileHandle]
	push BatteryLength
	push BatteryHeight
	push BatteryPrintStartLine
	push BatteryPrintStartRow
	push offset FileReadBuffer
	call PrintBMP

	push [BatteryFileHandle]
	call CloseFile

	;Score label:
	xor bh, bh
	mov dh, ScorePrintStartLine
	mov dl, ScorePrintStartRow
	mov ah, 2
	int 10h

	mov ah, 9
	mov dx, offset ScoreString
	int 21h

	;Combo label #Jieco:
	; call DisplayCombo ; yung ":" lang to

	ret
endp PrintStatsArea


;----------------------------------------------
; Updates the amount of lives shown on screen
;----------------------------------------------
proc UpdateLives
	;Clear previous hearts:
	; push 64											
	; push 14
	; push BHealthPrintStartLine
	; push BHealthPrintStartRow
	; push BlackColor
	; call PrintColor

	push offset BHealthFileName
	push offset BHealthFileHandle
	call OpenFile

	;Print amount of lifes remaining:
	xor ch, ch
	mov cl, [LivesRemaining]

	mov bx, BHealthPrintStartRow

@@printBHealth:
	push bx
	push cx

	push [BHealthFileHandle]
	push BHealthLength
	push BHealthHeight
	push BHealthPrintStartLine
	push bx
	push offset FileReadBuffer
	call PrintBMP

	pop cx							
	pop bx							
	add bx, 8
	loop @@printBHealth

	push [BHealthFileHandle]
	call CloseFile

	ret
endp UpdateLives


;--------------------------------------------------------------------
; Updates the score shown on screen using hex to decimal conversion
;--------------------------------------------------------------------
proc UpdateScoreStat
	xor bh, bh
	mov dh, ScoreValPrintStartLine
	mov dl, ScoreValPrintStartRow
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
	mov dh, LevelValPrintStartLine
	mov dl, LevelValPrintStartRow
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
	jne @@checkLevelThree

	mov [byte ptr AliensShootingMaxAmount], 5
	jmp @@resetDidNotDieBool

@@checkLevelThree:
	cmp [byte ptr Level], 3
	jne @@checkLevelFour

	mov [byte ptr AliensShootingMaxAmount], 7
	jmp @@resetDidNotDieBool

@@checkLevelFour:
	cmp [byte ptr Level], 4
	jne @@checkLevelFive

	mov [byte ptr AliensShootingMaxAmount], 8
	jmp @@resetDidNotDieBool

@@checkLevelFive:
	cmp [byte ptr Level], 5
	jne @@setLevelSix

	mov [byte ptr AliensShootingMaxAmount], 9
	jmp @@resetDidNotDieBool

@@setLevelSix:
	mov [byte ptr AliensShootingMaxAmount], 10

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

	mov [byte ptr LaserEnabled], 0


	push offset ExplosionFileName
	push offset ExplosionFileHandle
	call OpenFile

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
    jne @@checkSpace
    call ResetCombo     ; Reset combo when ESC is pressed
    jmp @@procEnd

@@checkSpace:    
    cmp ah, 39h ; Space
    je @@shootPressed

    cmp ah, 4Bh ; Left
    je @@moveLeft

    cmp ah, 4Dh ; Right
    je @@moveRight

	cmp ah, 2Dh ; X (Laser Enable)
	je @@enableLaser

	cmp ah, 2Fh ; V (AOE Enable) 
	je @@enableAOE
	
    cmp ah, 2Ch ; Z (Freeze)
    je @@freezePressed

    cmp ah, 2Eh ; C (Invincibility)
    je @@invincibilityPressed

    cmp ah, 13h ; R (Regenerate Heart)
    je @@regenerateHeart

	cmp ah, 10h ; Q (Secondary Shot)
    je @@secondaryShootPressed

    jmp @@printShooterAgain

@@secondaryShootPressed:
    cmp [byte ptr SecondaryShootingExists], 0
    jne @@printShooterAgain
    call playSoundShoot

    mov ax, ShooterLineLocation
    sub ax, 6
    mov [word ptr SecondaryBulletLineLocation], ax
    mov ax, [ShooterRowLocation]
    add ax, 7
    mov [word ptr SecondaryShootingRowLocation], ax
    mov [byte ptr SecondaryShootingExists], 1
    jmp @@printShooterAgain

@@invincibilityPressed:
    call CheckSkillAvailability    ; Check if skills are available based on current combo
    cmp [byte ptr CAN_USE_INVINCIBLE], 0  ; Check if we have enough combo for invincibility
    je @@readKey                   ; If not enough combo, ignore key press
    cmp [byte ptr InvincibleActive], 1  ; Check if already invincible
    je @@readKey
    
    ; Activate invincibility and reduce combo
    mov [byte ptr InvincibleActive], 1   
    mov [word ptr InvincibleCounter], 36 ; 2 seconds
    sub [byte ptr COMBO_VAL], INVINCIBLE_COST ; Reduce combo by cost
    call UpdateComboStat          ; Update combo display
    jmp @@readKey

@@freezePressed:
    call CheckSkillAvailability   
    cmp [byte ptr CAN_USE_FREEZE], 0    ; Check if we have enough combo for freeze
    je @@readKey                  ; If not enough combo, ignore key press
    cmp [byte ptr FreezeActive], 1  
    je @@readKey
    
    ; Activate freeze and reduce combo
    mov [byte ptr FreezeActive], 1   
    mov [word ptr FreezeCounter], 54
    sub [byte ptr COMBO_VAL], FREEZE_COST ; Reduce combo by cost
    call UpdateComboStat         ; Update combo display

    ; Force redraw of aliens to show frozen state immediately
    call ClearAliens
    call PrintAliens
    
    jmp @@readKey

@@regenerateHeart:
    call CheckSkillAvailability
    cmp [byte ptr CAN_USE_REGEN], 0     ; Check if we have enough combo for heart regen
    je @@readKey                  ; If not enough combo, ignore key press
    cmp [LivesRemaining], 3 ; Max lives is 3
    jae @@readKey

    ; Regenerate heart and reduce combo
    inc [LivesRemaining]
    sub [byte ptr COMBO_VAL], REGEN_COST ; Reduce combo by cost
    call UpdateComboStat         ; Update combo display
    call UpdateLives
    jmp @@readKey

@@enableLaser:
	mov [byte ptr LaserEnabled], 1
    je @@shootPressed

@@enableAOE:
	mov [byte ptr AOEEnabled], 1
    je @@shootPressed

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
    ; Handle secondary shot movement and clearing
    cmp [byte ptr SecondaryShootingExists], 1
    jne @@checkMainShot
    
    ; Clear previous shot position
    push ShootingLength
    push ShootingHeight
    push [word ptr SecondaryBulletLineLocation]
    push [word ptr SecondaryShootingRowLocation]
    push BlackColor
    call PrintColor
    
    cmp [word ptr SecondaryBulletLineLocation], 10
    jb @@removeSecondaryShot
    
    sub [word ptr SecondaryBulletLineLocation], 10
    
    ; Print new shot position
    push ShootingLength
    push ShootingHeight
    push [word ptr SecondaryBulletLineLocation]
    push [word ptr SecondaryShootingRowLocation]
    push RedColor
    call PrintColor
    
    ; Check for alien hits
    call CheckAndHitAlienSecondary
    jmp @@checkMainShot
	
	; Update invincibility counter if active
	cmp [InvincibleCounter], 0
	je @@checkMainShot
	
	dec [InvincibleCounter]
	cmp [InvincibleCounter], 0
	jne @@checkMainShot
	
	mov [byte ptr InvincibleActive], 0   ; Disable invincibility when counter reaches 0
    
@@removeSecondaryShot:
    mov [byte ptr SecondaryShootingExists], 0
    mov [word ptr SecondaryBulletLineLocation], 0
    mov [word ptr SecondaryShootingRowLocation], 0

@@checkMainShot:
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

	cmp [byte ptr LaserEnabled], 1
	jne @@printShooting

	; Print laser
	mov ax, [PlayerBulletLineLocation]  ; starting Y position
	sub ax, 130                      ; Move up for height
	mov [PlayerBulletLineLocation], ax   

	push ShootingLength
	push 140        ; height
	push [word ptr PlayerBulletLineLocation]
	push [word ptr PlayerShootingRowLocation]
	push BlueColor
	call PrintColor
	jmp @@clearShot

@@printShooting:
	; Regular shot printing
	push ShootingLength
	push ShootingHeight
	push [word ptr PlayerBulletLineLocation]
	push [word ptr PlayerShootingRowLocation]
	push BlueColor
	call PrintColor
	jmp @@clearShot

@@moveShootingUp:
	cmp [word ptr PlayerBulletLineLocation], 10
	jb @@removeShot

	; Clear previous shot
	push ShootingLength
	mov ax, ShootingHeight
	cmp [byte ptr LaserEnabled], 1
	jne @@normalClearMove
	mov ax, 140    ; Laser height
@@normalClearMove:
	push ax
	push [word ptr PlayerBulletLineLocation]
	push [word ptr PlayerShootingRowLocation]
	push BlackColor
	call PrintColor

	; Move shot up
	sub [word ptr PlayerBulletLineLocation], 10

	; Print new shot position
	push ShootingLength
	mov ax, ShootingHeight
	cmp [byte ptr LaserEnabled], 1
	jne @@normalPrintMove
	mov ax, 140    ; Laser height
@@normalPrintMove:
	push ax
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

	; Clear shot with appropriate height
	push ShootingLength
	mov ax, ShootingHeight
	cmp [byte ptr LaserEnabled], 1
	jne @@normalClear
	mov ax, 140    ; Same height as laser
@@normalClear:
	push ax
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

	cmp [byte ptr Level], 6 ; maximum level
	je @@printWin


	inc [byte ptr Level]
	call InitializeLevel

	call ClearScreen
	jmp @@firstLevelPrint

@@printWin:
; Print win message to user (finished 6 levels):

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

	push [ExplosionFileHandle]
	call CloseFile

	ret
endp PlayGame