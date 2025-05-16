DATASEG
; -----------------------------------------------------------
; Accessing bitmap files and text files for the game assets
; -----------------------------------------------------------	
	AlienFileName					db	'Assets/Alien.bmp',0
	AlienFileHandle					dw	?
	AlienLength						equ	32
	AlienHeight						equ	32


	Alien2FileName					db	'Assets/Alien2.bmp',0
	Alien2FileHandle				dw	?

	Alien3FileName					db	'Assets/Alien3.bmp',0
	Alien3FileHandle				dw	?

	FAlienFileName					db	'Assets/FAlien.bmp',0
	FAlienFileHandle				dw	?
	FAlienLength					equ	32
	FAlienHeight					equ	32

	FAlien2FileName					db	'Assets/FAlien2.bmp',0
	FAlien2FileHandle				dw	?

	FAlien3FileName					db	'Assets/FAlien3.bmp',0
	FAlien3FileHandle				dw	?

	SplatterFileName				db	'Assets/Splatter.bmp',0
	SplatterFileHandle				dw	?
	SplatterLength					equ	8
	SplatterHeight					equ	8
	SpaceBgFileName					db	'Assets/SpaceBg.bmp',0
	SpaceBgFileHandle				dw	?

	SpaceBg2FileName					db	'Assets/SpaceBg2.bmp',0
	SpaceBg2FileHandle				dw	?

	SpaceBg3FileName					db	'Assets/SpaceBg3.bmp',0
	SpaceBg3FileHandle				dw	?

	ShooterFileName					db	'Assets/Shooter2.bmp', 0
	ShooterFileHandle				dw	?
	ShooterLength					equ	16
	ShooterHeight					equ	16

	ShooterReloadFileName			db	'Assets/Reload2.bmp', 0
	ShooterReloadFileHandle			dw	?
	ShooterReloadLength				equ	16
	ShooterReloadHeight				equ	16

	GLS0FileName					db	'Assets/GLS0.bmp', 0
	GLS1FileName					db	'Assets/GLS1.bmp', 0
	GLSS0FileName					db	'Assets/GLSS0.bmp', 0
	GLSS1FileName					db	'Assets/GLSS1.bmp', 0
	GKS0FileName					db	'Assets/GKS0.bmp', 0
	GKS1FileName					db	'Assets/GKS1.bmp', 0


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

	ExplosionFileName				db	'Assets/Explode.bmp',0
	ExplosionFileHandle				dw	?
	ExplosionLength					equ	32
	ExplosionHeight					equ	32

	; GL Skill 1:  Second Bullet
	GLBulletI_FileName				db 'Assets/Bullet2I.bmp', 0
	GLBulletI_FileHandle			dw	?
	GLBulletA_FileName				db 'Assets/Bullet2A.bmp', 0
	GLBulletA_FileHandle			dw	?

	; GL Skill 2: Laser
	GLLaserI_FileName				db 'Assets/LaserI.bmp', 0
	GLLaserI_FileHandle			dw	?
	GLLaserA_FileName				db 'Assets/LaserA.bmp', 0
	GLLaserA_FileHandle			dw	?

	; GL Skill 3: Charge
	GLChargeI_FileName				db 'Assets/ChargeI.bmp', 0
	GLChargeI_FileHandle			dw	?
	GLChargeA_FileName				db 'Assets/ChargeA.bmp', 0
	GLChargeA_FileHandle			dw	?

	; GK Skill 1: LED
	GKLEDI_FileName				db 'Assets/LEDI.bmp', 0
	GKLEDI_FileHandle			dw	?
	GKLEDA_FileName				db 'Assets/LEDA.bmp', 0
	GKLEDA_FileHandle			dw	?

	; GK Skill 2: Freeze
	GKFreezeI_FileName				db 'Assets/FreezeI.bmp', 0
	GKFreezeI_FileHandle			dw	?
	GKFreezeA_FileName				db 'Assets/FreezeA.bmp', 0
	GKFreezeA_FileHandle			dw	?
	GKFreezeAc_FileName				db 'Assets/FreezeAc.bmp', 0
	GKFreezeAc_FileHandle			dw	?

	; GK Skill 3: Shield
	GKShieldI_FileName				db 'Assets/ShieldI.bmp', 0
	GKShieldI_FileHandle			dw	?
	GKShieldA_FileName				db 'Assets/ShieldA.bmp', 0
	GKShieldA_FileHandle			dw	?
	GKShieldAc_FileName				db 'Assets/ShieldAc.bmp', 0
	GKShieldAc_FileHandle			dw	?

	SkillLength						equ 16
	SkillHeight						equ 16

	BatteryFileName				db	'Assets/Battery.bmp', 0
	BatteryFileHandle			dw	?
	BatteryLength					equ	32	; 32 is max
	BatteryHeight					equ 16

	BHealthFileName				db	'Assets/BHealth.bmp', 0	
	BHealthFileHandle			dw	?
	BHealthLength					equ	7
	BHealthHeight					equ	10