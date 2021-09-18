;Initial settings for screen
macro SNES_INIDISP(arg)
	lda <arg>
	sta $2100
endmacro

!INIDISP = $2100

;OBJECT SIZE & OBJECT DATA AREA DESIGNATION
macro SNES_OBJSEL(arg)
	lda <arg>
	sta $2101
endmacro

!OBJSEL = $2101

;ADDRESS FOR ACCESSING OAM (OBJECT ATTRIBUTE MEMORY)
macro SNES_OAMADD(arg)
	ldy <arg>
	sty $2102
endmacro

!OAMADDL = $2102
!OAMADDH = $2103

;DATA FOR OAM WRITE
macro SNES_OAMDATA(arg)
	lda <arg>
	sta $2104
endmacro

!OAMDATA = $2104

;BG MODE & CHARACTER SIZE SETTINGS
macro SNES_BGMODE(arg)
	lda <arg>
	sta $2105
endmacro

!BGMODE = $2105

;SIZE & SCREEN DESIGNATION FOR MOSAIC DISPLAY
macro SNES_MOSAIC(arg)
	lda <arg>
	sta $2106
endmacro

!MOSAIC = $2106

;ADDRESS FOR STORING SC-DATA OF EACH BG & SC SIZE DESIGNATION
macro SNES_BG1SC(arg)
	lda <arg>
	sta $2107
endmacro

macro SNES_BG2SC(arg)
	lda <arg>
	sta $2108
endmacro

macro SNES_BG3SC(arg)
	lda <arg>
	sta $2109
endmacro

macro SNES_BG4SC(arg)
	lda <arg>
	sta $210A
endmacro

!BG1SC = $2107
!BG2SC = $2108
!BG3SC = $2109
!BG4SC = $210A

;BG CHARACTER DATA AREA DESTINATION
macro SNES_BGNBA(arg1,arg2)
	lda <arg1>
	sta $210B
	
	lda <arg2>
	sta $210C
endmacro

macro SNES_BG12NBA(arg)
	lda <arg>
	sta $210B
endmacro

macro SNES_BG34NBA(arg)
	lda <arg>
	sta $210C
endmacro

!BG12NBA = $210B
!BG34NBA = $210C

;H/V SCROLL VALUE DESIGNATION FOR BG-1,2,3,4
macro SNES_BG1H0FS(arg)
	lda <arg>
	sta $210D
endmacro

macro SNES_BG1V0FS(arg)
	lda <arg>
	sta $210E
endmacro

macro SNES_BG2H0FS(arg)
	lda <arg>
	sta $210F
endmacro

macro SNES_BG2V0FS(arg)
	lda <arg>
	sta $2110
endmacro

macro SNES_BG3H0FS(arg)
	lda <arg>
	sta $2111
endmacro

macro SNES_BG3V0FS(arg)
	lda <arg>
	sta $2112
endmacro

macro SNES_BG4H0FS(arg)
	lda <arg>
	sta $2113
endmacro

macro SNES_BG4V0FS(arg)
	lda <arg>
	sta $2114
endmacro

!BG1H0FS = $210D
!BG1V0FS = $210E

!BG2H0FS = $210F
!BG2V0FS = $2110

!BG3H0FS = $2111
!BG3V0FS = $2112

!BG4H0FS = $2113
!BG4V0FS = $2114

;VRAM ADRESS INCREMENT VALUE DESIGNATION
macro SNES_VMAINC(arg)
	lda <arg>
	sta $2115
endmacro

!VMAINC = $2115

;VRAM ADRESS INCREMENT VALUE DESIGNATION
macro SNES_VMADD(arg)
	ldy <arg>
	sty $2116
endmacro

!VMADDL = $2116
!VMADDH = $2117

;DATA FOR VRAM WRITE
macro SNES_VMDATA()
	ldy #\1
	sty $2118
endmacro

!VMDATAL = $2118
!VMDATAH = $2119

;INITIAL SETTING IN SCREEN MODE-7
macro SNES_M7SEL(arg)
	lda <arg>
	sta $211A
endmacro

!M7SEL = $211A

;ROTATION/ENLARGEMENT/REDUCTION/ IN MODE-7 , CENTER COORDINATE
;SETTINGS & MULTIPLICAND/MULTIPLIER SETTINGS OF COMPLEMENTARY
;MULTIPLICATION

macro SNES_M7()
	lda #\1
	sta $211B
	stz $211B
	
	lda #\2
	sta $211C
	stz $211C
	
	lda #\3
	sta $211D
	stz $211D
	
	lda #\4
	sta $211E
	stz $211E
	
	lda #\5
	sta $211F
	stz $211F
	
	lda #\6
	sta $2120
	stz $2120
endmacro

!M7A = $211B
!M7B = $211C
!M7C = $211D
!M7D = $211E
!M7X = $211F
!M7Y = $2120

;ADDRES FOR CG-RAM READ AND WRITE
macro SNES_CGADD(arg)
	lda <arg>
	sta $2121
endmacro

!CGADD = $2121

;DATA FOR CG-RAM WRITE
macro SNES_CGDATA(arg)
	lda <arg>
	sta $2122
endmacro

!CGDATA = $2122

;MAIN SCREEN DESIGNATION
macro SNES_TM(arg)
	lda <arg>
	sta $212C
endmacro

!TM = $212C

;SUB SCREEN DESIGNATION
macro SNES_TS(arg)
	lda <arg>
	sta $212D
endmacro

!TS = $212D

;INITIAL SETTINGS FOR FIXED COLOR ADDITION OR SCREEN ADDITION
macro SNES_CGSWSEL(arg)
	lda <arg>
	sta $2130
endmacro

!CGSWSEL = $2130

;ADDITION/SUBTRACTION & SUBTRACTION DESIGNATION FOR EACH BG SCREEN OBJ & BACKGROUND COLOR
macro SNES_CGADSUB(arg)
	lda <arg>
	sta $2131
endmacro

!CGADSUB = $2131

;FIXED COLOR DATA FOR FIXED COLOR ADDITION/SUBTRACTION
macro SNES_COLDATA(arg)
	lda <arg>
	sta $2132
endmacro

!COLDATA = $2132

;SCREEN INITIAL SETTINGS
macro SNES_SETINI(arg)
	lda <arg>
	sta $2133
endmacro

!SETINI = $2133

;ENABLE FLAG FOR V-BLANK, TIMER INTERRUPT & STANDARD CONTROLLER
macro SNES_NMITIMEN(arg)
	lda <arg>
	sta $4200
endmacro

!NMITIMEN = $4200

;MULTIPLIER & MULTIPLICAND BY MULTIPLICATION
macro SNES_WRMPYA(arg)
	lda <arg>
	sta $4202
endmacro

macro SNES_WRMPYB(arg)
	lda <arg>
	sta $4203
endmacro

!WRMPYA = $4202
!WRMPYB = $4203

;DIVISOR & DIVIDEND BY DIVIDE
macro SNES_WRDIVL(arg)
	lda <arg>
	sta $4204
endmacro

macro SNES_WRDIVH(arg)
	lda <arg>
	sta $4205
endmacro

macro SNES_WRDIVB(arg)
	lda <arg>
	sta $4206
endmacro

!WRDIVL = $4204
!WRDIVH = $4205
!WRDIVB = $4206

;DMA Enable Register
macro SNES_MDMAEN(arg)
	lda <arg>
	sta $420B
endmacro

!MDMAEN = $420B

;HDMA Enable Register
macro SNES_HDMAEN(arg)
	lda <arg>
	sta $420C
endmacro

!HDMAEN = $420C

;MAIN SCREEN DESIGNATION
macro SNES_MEMSEL(arg)
	lda <arg>
	sta $420D
endmacro

!MEMSEL = $420D

;QUOTIENT OF DIVIDE RESULT
macro SNES_RDDIVL(arg)
	lda <arg>
	sta $4214
endmacro

macro SNES_RDDIVH(arg)
	lda <arg>
	sta $4215
endmacro

!RDDIVL = $4214
!RDDIVH = $4215


;PRODUCT OF MULTIPLICATION RESULT OR REMAINDER OF DIVIDE RESULT
macro SNES_RDMPYL(arg)
	lda <arg>
	sta $4216
endmacro

macro SNES_RDMPYH(arg)
	lda <arg>
	sta $4217
endmacro

!RDMPYL = $4216
!RDMPYH = $4217

;DATA FOR STANDARD CONTROLLER I, II, III & IV

!STDCONTROL1L = $4218
!STDCONTROL1H = $4219

!STDCONTROL2L = $421A
!STDCONTROL2H = $421B

!STDCONTROL3L = $421C
!STDCONTROL3H = $421D

!STDCONTROL4L = $421E
!STDCONTROL4H = $421F

;PARAMETER FOR DMA TRANSFER
macro SNES_DMAX(arg)
	lda <arg>
	sta $4300
	sta $4310
	sta $4320
	sta $4330
	sta $4340
	sta $4350
	sta $4360
	sta $4370
endmacro

macro SNES_DMA0(arg)
	lda <arg>
	sta $4300
endmacro

macro SNES_DMA1(arg)
	lda <arg>
	sta $4310
endmacro

macro SNES_DMA2(arg)
	lda <arg>
	sta $4320
endmacro

macro SNES_DMA3(arg)
	lda <arg>
	sta $4330
endmacro

macro SNES_DMA4(arg)
	lda <arg>
	sta $4340
endmacro

macro SNES_DMA5(arg)
	lda <arg>
	sta $4350
endmacro

macro SNES_DMA6(arg)
	lda <arg>
	sta $4360
endmacro

macro SNES_DMA7(arg)
	lda <arg>
	sta $4370
endmacro

!DMA = $4300

;B-BUS ADRESS FOR DMA
macro SNES_DMAX_BADD(arg)
	lda <arg>
	sta $4301
	sta $4311
	sta $4321
	sta $4331
	sta $4341
	sta $4351
	sta $4361
	sta $4371
endmacro

macro SNES_DMA0_BADD(arg)
	lda <arg>
	sta $4301
endmacro

macro SNES_DMA1_BADD(arg)
	lda <arg>
	sta $4311
endmacro

macro SNES_DMA2_BADD(arg)
	lda <arg>
	sta $4321
endmacro

macro SNES_DMA3_BADD(arg)
	lda <arg>
	sta $4331
endmacro

macro SNES_DMA4_BADD(arg)
	lda <arg>
	sta $4341
endmacro

macro SNES_DMA5_BADD(arg)
	lda <arg>
	sta $4351
endmacro

macro SNES_DMA6_BADD(arg)
	lda <arg>
	sta $4361
endmacro

macro SNES_DMA7_BADD(arg)
	lda <arg>
	sta $4371
endmacro

!DMA_BADD = $4301

;TABLE ADDRESS OF A-BUS FOR DMA

!DMA_ADDL = $4302
!DMA_ADDH = $4303
!DMA_BANK = $4304
!DMA_SIZEL = $4305
!DMA_SIZEH = $4306

!HDMA_DATABANK = $4306

macro SNES_DMA0_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4302
    sta $4304
    sty $4305    

endmacro

macro SNES_DMA1_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4312
    sta $4314
    sty $4315    

endmacro

macro SNES_DMA2_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4322
    sta $4324
    sty $4325    

endmacro

macro SNES_DMA3_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4332
    sta $4334
    sty $4335    

endmacro

macro SNES_DMA4_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4342
    sta $4344
    sty $4345    

endmacro

macro SNES_DMA5_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4352
    sta $4354
    sty $4355    

endmacro

macro SNES_DMA6_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4362
    sta $4364
    sty $4365    

endmacro

macro SNES_DMA7_ADD()

	lda #:\1  
    ldx #\1        
    ldy #\2   
    
    stx $4372
    sta $4374
    sty $4375    

endmacro

;DATA ADDRESS STORE BY H-DMA & NUMBER OF BYTE TO BE TRANSFERRED SETTINGS BY GENERAL PURPOSE DMA
macro SNES_HDMA0_ADD()

	ldx #\1        
    lda #\2 
    ldy #\3
    
    sty $4302
    stz $4304
    stx $4305
    sta $4307    

endmacro

macro SNES_HDMA1_ADD()

	ldx #\1        
    lda #\2 
    ldy #\3
    
    sty $4312
    stz $4314
    stx $4315
    sta $4317    

endmacro

;SNES INIT
macro SNES_INIT()
	stz $2100
	stz $2101
	stz $2102
	stz $2103
	stz $2104
	stz $2105
	stz $2106
	stz $2107
	stz $2108
	stz $2109
	stz $210A
	stz $210B
	stz $210C
	stz $210D
	stz $210E
	stz $210F
	
	stz $2110
	stz $2111
	stz $2112
	stz $2113
	stz $2114
	stz $2115 
	stz $2116
	stz $2117
	stz $2118 
	stz $2119 
	stz $211A
	stz $211B 
	stz $211C
	stz $211D
	stz $211E 
	stz $211F
	
	stz $2120
	stz $2121
	stz $2122 
	stz $2123
	stz $2124 
	stz $2125
	stz $2126
	stz $2127
	stz $2128
	stz $2129
	stz $212A
	stz $212B
	stz $212C
	stz $212D
	stz $212E
	stz $212F
	
	stz $2130
	stz $2131
	stz $2132 
	stz $2133
		
	stz $4200
	stz $4201
	stz $4202
	stz $4203
	stz $4204 
	stz $4205
	stz $4206
	stz $4207
	stz $4208
	stz $4209
	stz $420A
	stz $420B
	stz $420C
	stz $420D
	
	

endmacro
