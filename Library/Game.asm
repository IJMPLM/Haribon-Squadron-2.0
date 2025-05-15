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
	UnliSkills						db  1

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

	Score							dw	?

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

	Skill1PrintStartLine		equ		180
	Skill1PrintStartRow			equ		140

	Skill2PrintStartLine		equ		180
	Skill2PrintStartRow			equ		160

	Skill3PrintStartLine		equ		180
	Skill3PrintStartRow			equ		180

	ScorePrintStartLine				equ		23
	ScorePrintStartRow				equ		28

	ScoreValPrintStartLine		equ 	23
	ScoreValPrintStartRow			equ		35

	StatsAreaBorderLine				equ	175

	FileReadBuffer					db	320 dup (?)

	LaserEnabled	 				db 	?
	LaserRow						dw  ?
	AOEEnabled						db	0
	AOEKillDirection				db  0 ; 0 - None, 1 - Right, 2 - Left (For splatter)

	;Color values:
	BlackColor						equ	0
	GreenColor						equ	30h
	RedColor						equ	40
	BlueColor						equ	54
	WhiteColor						equ	15
	OrangeColor						equ 6
	YellowColor					    equ 0Eh 

CODESEG
include "Library/Alien.asm"
include "Library/Procs.asm"
include "Library/Combo.asm"

; -----------------------------------------------------------
; Prints the background image of the game (space background)
; Changes background based on current level:
; Levels 1-3: SpaceBg.bmp
; Levels 4-6: SpaceBg2.bmp
; Levels 7-9: SpaceBg3.bmp
; -----------------------------------------------------------
proc PrintBackground
	call playSoundMenu

	; Select background based on level
	cmp [byte ptr Level], 4
	jb @@useBackground1  ; If level < 4, use first background
	cmp [byte ptr Level], 7
	jb @@useBackground2  ; If 4 <= level < 7, use second background
	jmp @@useBackground3 ; Otherwise use third background

@@useBackground1:
	push offset SpaceBgFileName
	push offset SpaceBgFileHandle
	jmp @@openFile

@@useBackground2:
	push offset SpaceBg2FileName
	push offset SpaceBg2FileHandle
	jmp @@openFile

@@useBackground3:
	push offset SpaceBg3FileName
	push offset SpaceBg3FileHandle

@@openFile:
	call OpenFile

	; Get the handle from the correct variable based on which background we're using
	cmp [byte ptr Level], 4
	jb @@useHandle1
	cmp [byte ptr Level], 7
	jb @@useHandle2
	push [SpaceBg3FileHandle]
	jmp @@printBMP
@@useHandle1:
	push [SpaceBgFileHandle]
	jmp @@printBMP
@@useHandle2:
	push [SpaceBg2FileHandle]

@@printBMP:
	push 320
	push 200
	push 0
	push 0
	push offset FileReadBuffer
	call PrintBMP

	; Close the correct file handle
	cmp [byte ptr Level], 4
	jb @@closeHandle1
	cmp [byte ptr Level], 7
	jb @@closeHandle2
	push [SpaceBg3FileHandle]
	jmp @@closeFile
@@closeHandle1:
	push [SpaceBgFileHandle]
	jmp @@closeFile
@@closeHandle2:
	push [SpaceBg2FileHandle]

@@closeFile:
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

; @@printHealth:
; 	push offset BHealthFileName
; 	push offset BHealthFileHandle	
; 	call OpenFile

; 	push [BHealthFileHandle]
; 	push BHealthLength
; 	push BHealthHeight
; 	push BHealthPrintStartLine
; 	push BHealthPrintStartRow
; 	push offset FileReadBuffer
; 	call PrintBMP

; 	push [BHealthFileHandle]
; 	call CloseFile

	;Score label:
	xor bh, bh
	mov dh, ScorePrintStartLine
	mov dl, ScorePrintStartRow
	mov ah, 2
	int 10h

	mov ah, 9
	mov dx, offset ScoreString
	int 21h

@ReprintDynamicLabels: ; #Jieco for hud 
	call UpdateLives	
	call UpdateScoreStat
	call UpdatePlayerStats
    call CheckSkillAvailability  
	call CheckSkillAvailability    
	call UpdateSkills	

	ret
endp PrintStatsArea

; --------------------------------------------------------
; Prints and Update skills of the selected ship
; --------------------------------------------------------
proc UpdateSkills
	; GL = 0, GK = 1
	cmp [byte ptr ShipSelect], 0	; check which ship is selected 
	jne @@GKSkills

@@GLSkills:
	call GLBullet
	call GLLaser 
	call GLShield
	ret

@@GKSkills:
	call GKLED
	call GKFreeze
	call GKCharge
	ret

endp UpdateSkills

proc GLBullet
	cmp [byte ptr CAN_USE_SHIELD], 1 ; to be changed
	je @@Activate2Bullet

	@@Deactivate2Bullet:
		push offset GLBulletI_FileName
		push offset GLBulletI_FileHandle	
		call OpenFile

		push [GLBulletI_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill1PrintStartLine
		push Skill1PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GLBulletI_FileHandle]
		call CloseFile
		jmp @@endGLBullet

	@@Activate2Bullet:
		push offset GLBulletA_FileName
		push offset GLBulletA_FileHandle	
		call OpenFile

		push [GLBulletA_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill1PrintStartLine
		push Skill1PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GLBulletA_FileHandle]
		call CloseFile
		jmp @@endGLBullet

	@@endGLBullet:
		ret
endp GLBullet

proc GLLaser
	cmp [byte ptr CAN_USE_SHIELD], 1	; to be changed
	je @@ActivateLaser

	@@DeactivateLaser:
		push offset GLLaserI_FileName
		push offset GLLaserI_FileHandle	
		call OpenFile

		push [GLLaserI_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill2PrintStartLine
		push Skill2PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GLLaserI_FileHandle]
		call CloseFile
		jmp @@endGLLaser

	@@ActivateLaser:
		push offset GLLaserA_FileName
		push offset GLLaserA_FileHandle	
		call OpenFile

		push [GLLaserA_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill2PrintStartLine
		push Skill2PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GLLaserA_FileHandle]
		call CloseFile
		jmp @@endGLLaser

	@@endGLLaser:
		ret
endp GLLaser

proc GLShield
	cmp [byte ptr CAN_USE_SHIELD], 1	; to be changed
	je @@ActivateShield

	@@DeactivateShield: 
		push offset GKShieldI_FileName
		push offset GKShieldI_FileHandle	
		call OpenFile

		push [GKShieldI_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill3PrintStartLine
		push Skill3PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GKShieldI_FileHandle]
		call CloseFile
		jmp @@endGLShield

	@@ActivateShield:
		push offset GKShieldA_FileName
		push offset GKShieldA_FileHandle	
		call OpenFile

		push [GKShieldA_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill3PrintStartLine
		push Skill3PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GKShieldA_FileHandle]
		call CloseFile
		jmp @@endGLShield
	
	@@endGLShield:
		ret

endp GLShield

proc GKLED
	cmp [byte ptr CAN_USE_SHIELD], 1	; to be changed
	je @@ActivateLED

	@@DeactivateLED: 
		push offset GKLEDI_FileName
		push offset GKLEDI_FileHandle	
		call OpenFile

		push [GKLEDI_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill1PrintStartLine
		push Skill1PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GKLEDI_FileHandle]
		call CloseFile
		jmp @@endGKLED

	@@ActivateLED:
		push offset GKLEDA_FileName
		push offset GKLEDA_FileHandle	
		call OpenFile

		push [GKLEDA_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill1PrintStartLine
		push Skill1PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GKLEDA_FileHandle]
		call CloseFile
		jmp @@endGKLED

	@@endGKLED:
		ret
endp GKLED

proc GKFreeze
	cmp [byte ptr CAN_USE_SHIELD], 1	; to be changed
	je @@ActivateFreeze

	@@DeactivateFreeze: 
		push offset GKFreezeI_FileName
		push offset GKFreezeI_FileHandle	
		call OpenFile

		push [GKFreezeI_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill2PrintStartLine
		push Skill2PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GKFreezeI_FileHandle]
		call CloseFile
		jmp @@endGKFreeze

	@@ActivateFreeze:
		push offset GKFreezeA_FileName
		push offset GKFreezeA_FileHandle	
		call OpenFile

		push [GKFreezeA_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill2PrintStartLine
		push Skill2PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GKFreezeA_FileHandle]
		call CloseFile
		jmp @@endGKFreeze

	@@endGKFreeze:
		ret
endp GKFreeze

proc GKCharge
	cmp [byte ptr CAN_USE_SHIELD], 1	; to be changed
	je @@ActivateCharge

	@@DeactivateCharge: 
		push offset GLChargeI_FileName
		push offset GLChargeI_FileHandle	
		call OpenFile

		push [GLChargeI_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill3PrintStartLine
		push Skill3PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GLChargeI_FileHandle]
		call CloseFile
		jmp @@endGKCharge

	@@ActivateCharge:
		push offset GLChargeA_FileName
		push offset GLChargeA_FileHandle	
		call OpenFile

		push [GLChargeA_FileHandle]
		push SkillLength
		push SkillHeight
		push Skill3PrintStartLine
		push Skill3PrintStartRow
		push offset FileReadBuffer
		call PrintBMP

		push [GLChargeA_FileHandle]
		call CloseFile
		jmp @@endGKCharge

	@@endGKCharge:
		ret
endp GKCharge

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
	mov ax, [word ptr Score]
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
	jne @@checkLevelSix

	mov [byte ptr AliensShootingMaxAmount], 9
	jmp @@resetDidNotDieBool

@@checkLevelSix:
	cmp [byte ptr Level], 6
	jne @@checkLevelSeven

	mov [byte ptr AliensShootingMaxAmount], 10
	jmp @@resetDidNotDieBool

@@checkLevelSeven:
	cmp [byte ptr Level], 7
	jne @@checkLevelEight

	mov [byte ptr AliensShootingMaxAmount], 10
	jmp @@resetDidNotDieBool

@@checkLevelEight:
	cmp [byte ptr Level], 8
	jne @@checkLevelNine

	mov [byte ptr AliensShootingMaxAmount], 10
	jmp @@resetDidNotDieBool

@@checkLevelNine:
	cmp [byte ptr Level], 9
	jne @@setLevelTen

	mov [byte ptr AliensShootingMaxAmount], 10
	jmp @@resetDidNotDieBool

@@setLevelTen:
	mov [byte ptr AliensShootingMaxAmount], 10

@@resetDidNotDieBool:
	mov [byte ptr DidNotDieInLevelBool], 1 ;true

	call MoveToStart

	; #Jieco
	call ResetCombo ; resets combo every stage cleared

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
	mov [word ptr Score], 300 ; #Jieco
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
	cmp [AliensStatusArray + bx], 1
	je @@lineTwoNotEmpty

	inc bx
	loop @@checkLineTwo

	mov cx, 8
	mov bx, 8

@@checkLineOne:
	cmp [AliensStatusArray + bx], 1
	je @@lineOneNotEmpty
	
	inc bx
	loop @@checkLineOne

	mov cx, 8
	xor bx, bx

@@checkLineZero:
	cmp [AliensStatusArray + bx], 1
	je @@lineZeroNotEmpty
	
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
	; Open all alien sprites
	push offset AlienFileName
	push offset AlienFileHandle
	call OpenFile

	push offset Alien2FileName
	push offset Alien2FileHandle
	call OpenFile

	push offset Alien3FileName
	push offset Alien3FileHandle
	call OpenFile

	push offset FAlienFileName
	push offset FAlienFileHandle
	call OpenFile

	push offset FAlien2FileName
	push offset FAlien2FileHandle
	call OpenFile

	push offset FAlien3FileName
	push offset FAlien3FileHandle
	call OpenFile

	push offset SplatterFileName
	push offset SplatterFileHandle
	call OpenFile

	; GL = 0, GK = 1
	cmp [byte ptr ShipSelect], 0
	jne @@openGK
	
@@openGL:
	push offset GLS0FileName
	push offset ShooterReloadFileHandle
	call OpenFile
	push offset GLS1FileName
	push offset ShooterFileHandle
	call OpenFile
	jmp @@endShipSelect

@@openGK:
	push offset GKS0FileName
	push offset ShooterReloadFileHandle
	call OpenFile
	push offset GKS1FileName
	push offset ShooterFileHandle
	call OpenFile

@@endShipSelect:
	push offset SShieldFileName
	push offset SShieldFileHandle
	call OpenFile

	push offset RShieldFileName
	push offset RShieldFileHandle
	call OpenFile

	call InitializeGame

	call ClearScreen


@@stageOnePrint:
	call PrintBackground
	call PrintStatsArea
	call UpdateSkills
	call UpdatePlayerStats
	call DisplayCombo

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

	; Skill Selection per Ship
	cmp [byte ptr ShipSelect], 0
	jne @@checkGKSkills
    cmp ah, 2Eh ; C (Invincibility) CP: 7
    je @@invincibilityPressed
	cmp ah, 2Dh ; X (Laser Enable) CP: 5
	je @@enableLaser
	cmp ah, 2Ch ; Z (Secondary Shot) CP:3
    je @@secondaryShootPressed
	jmp @@endSkillCheck

@@checkGKSkills:
    cmp ah, 2Eh ; C (Regenerate Heart) CP: 9
    je @@regenerateHeart
    cmp ah, 2Dh ; X (Freeze) CP: 5
    je @@freezePressed
	cmp ah, 2Ch ; Z (AOE Enable) CP: 3
	je @@enableAOE

@@endSkillCheck:
    jmp @@printShooterAgain


; ================================
; Skills Checker Format:
; 	Skill Conditions
; 	Unli Skill Conditions
;	Combo Conditions
; 	Skill Function
; ================================


@@secondaryShootPressed:
    cmp [byte ptr SecondaryShootingExists], 0
    jne @@printShooterAgain

    cmp [byte ptr UnliSkills], 1
    jmp @@skillFunctionBullet2
	
    cmp [byte ptr CAN_USE_BULLET2], 0  
    je @@readKey                  
    sub [byte ptr COMBO_VAL], BULLET2_COST
	call DisplayCombo				

	@@skillFunctionBullet2:
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
	cmp [byte ptr InvincibleActive], 1 
    je @@readKey

    cmp [byte ptr UnliSkills], 1
    jmp @@skillFunctionInvincibility
	
    cmp [byte ptr CAN_USE_SHIELD], 0  
    je @@readKey                  
    sub [byte ptr COMBO_VAL], SHIELD_COST
	call DisplayCombo
    
	@@skillFunctionInvincibility:
    mov [byte ptr InvincibleActive], 1   
    mov [word ptr InvincibleCounter], 36
    mov [word ptr InvincibleCounter], 36 ; 2 seconds
    sub [byte ptr COMBO_VAL], SHIELD_COST ; Reduce combo by cost
    ; #Jieco
		; call UpdateComboStat  ; for debugging
		call DisplayCombo				; Update combo display
    jmp @@readKey

@@freezePressed:
	cmp [byte ptr FreezeActive], 1 
    je @@readKey

    cmp [byte ptr UnliSkills], 1
    jmp @@skillFunctionFreeze
	
    cmp [byte ptr CAN_USE_FREEZE], 0  
    je @@readKey                  
    sub [byte ptr COMBO_VAL], FREEZE_COST
	call DisplayCombo

    @@skillFunctionFreeze:
    mov [byte ptr FreezeActive], 1   
    mov [word ptr FreezeCounter], 54
    sub [byte ptr COMBO_VAL], FREEZE_COST ; Reduce combo by cost
    ; #Jieco
		; call UpdateComboStat  ; for debugging
		call DisplayCombo				; Update combo display

    ; Force redraw of aliens to show frozen state immediately
    call ClearAliens
    call PrintAliens
    jmp @@readKey

@@regenerateHeart:
    cmp [byte ptr UnliSkills], 1
    jmp @@skillFunctionRegenerate
	
    cmp [byte ptr CAN_USE_REGEN], 0  
    je @@readKey                  
    sub [byte ptr COMBO_VAL], REGEN_COST
	call DisplayCombo

	@@skillFunctionRegenerate:
    inc [LivesRemaining]
    sub [byte ptr COMBO_VAL], REGEN_COST ; Reduce combo by cost
    ; #Jieco
		; call UpdateComboStat  ; for debugging
		call DisplayCombo				; Update combo display
    call UpdateLives
    jmp @@readKey

@@enableLaser:
    cmp [byte ptr PlayerShootingExists], 0
    jne @@readKey

    cmp [byte ptr UnliSkills], 1
    jmp @@skillFunctionLaser
	
    cmp [byte ptr CAN_USE_LASER], 0  
    je @@readKey                  
    sub [byte ptr COMBO_VAL], LASER_COST
	call DisplayCombo

	@@skillFunctionLaser:
    mov [byte ptr LaserEnabled], 1
    sub [byte ptr COMBO_VAL], 5    ; Deduct combo cost
    ; #Jieco
		; call UpdateComboStat  ; for debugging
		call DisplayCombo				; Update combo display
    jmp @@shootPressed

@@enableAOE:
    cmp [byte ptr UnliSkills], 1
    jmp @@skillFunctionAOE
	
    cmp [byte ptr CAN_USE_LED], 0  
    je @@readKey                  
    sub [byte ptr COMBO_VAL], LED_COST
	call DisplayCombo

	@@skillFunctionAOE:
	mov [byte ptr AOEEnabled], 1
    jmp @@printShooterAgain

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
    push YellowColor
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
	push RedColor
	call PrintColor
	jmp @@clearShot

@@printShooting:
	; Regular shot printing
	push ShootingLength
	push ShootingHeight
	push [word ptr PlayerBulletLineLocation]
	push [word ptr PlayerShootingRowLocation]
	
	call BulletColor

	cmp [byte ptr AOEEnabled], 1
	jne @@normalColor
	mov al, OrangeColor
@@normalColor:
	push ax
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

	call BulletColor

	cmp [byte ptr AOEEnabled], 1
	jne @@normalColorMove
	mov al, OrangeColor
@@normalColorMove:
	push ax
	call PrintColor
	jmp @@clearShot

@@removeShot:
	; #Jieco
	call ResetCombo				; Resets combo
	; call UpdateComboStat	; #Jieco for debugging 	
	; call DisplayCombo			; reflect changes on screen


	mov [byte ptr PlayerShootingExists], 0
	mov [word ptr PlayerBulletLineLocation], 0
	mov [word ptr PlayerShootingRowLocation], 0
	mov [byte ptr AOEKillDirection], 0
    mov [byte ptr AOEEnabled], 0

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

	; for re-displaying hud
	call DisplayCombo
	; call @@printShooterAgain		; prints shooter but flickers upon being called
	
	call CheckAndMoveAliens
	call PrintStatsArea
	
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
	call ResetCombo	; resets combo upon death

	;sub 5 score if possible, if he doesn't have 5 yet, just reset to 0:
	cmp [word ptr Score], 5
	jb @@resetScoreAfterDeath

	sub [word ptr Score], 5
	jmp @@resetBeforeContinueAfterDeath


@@resetScoreAfterDeath:
	mov [word ptr Score], 0

@@resetBeforeContinueAfterDeath:
	call MoveToStart

	mov [byte ptr DidNotDieInLevelBool], 0 ;false


	push 24
	call Delay

	call ClearScreen

	
	jmp @@stageOnePrint


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
	mov ax, [Score]
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

	add [word ptr Score], 5 ;special bonus for perfect level (no death in level)

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

	cmp [byte ptr Level], 9 ; maximum level is now 9
	je @@printWin


	inc [byte ptr Level]
	call InitializeLevel

	call ClearScreen
	jmp @@stageOnePrint

@@printWin:
; Print win message to user (finished 6 levels):
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
	mov ax, [Score]
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

	; Close all alien sprites
	push [FAlienFileHandle]
	call CloseFile

	push [FAlien2FileHandle]
	call CloseFile

	push [FAlien3FileHandle]
	call CloseFile

	push [AlienFileHandle]
	call CloseFile

	push [Alien2FileHandle]
	call CloseFile

	push [Alien3FileHandle]
	call CloseFile

	push [ExplosionFileHandle]
	call CloseFile

	ret
endp PlayGame

proc BulletColor
	; Ship Select Bullet Color
	cmp [byte ptr ShipSelect], 0
	jne @@bulletGK	
	mov al, BlueColor
	jmp @@endBulletSelect
@@bulletGK:
	mov al, WhiteColor
@@endBulletSelect:
	ret
endp BulletColor