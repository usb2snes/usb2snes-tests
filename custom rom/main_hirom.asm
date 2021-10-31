hirom
incsrc "header_hirom.asm"
org $8000
incsrc "snes.asm"
Main:
    xce
    rep #$10  
    rep #$10    ;met les registres xy en 16 bits 

    %SNES_INIT()
    
    ;INITIAL SETTINGS 
    
    ; c'est le registre $2100, il permet de faire un Forced Blank et de régler la luminosité 
    lda #$8F 
    sta !INIDISP 

    ;general init 
     
    ;Registre $212C, active l'utilisation des plans obj + bg 
    lda #$01 ; on active le BG1 
    sta !TM 
    
    ;Registre $2115, c'est pour dire que, à chaque fois qu'on écrit sur la VRAM avec le registre $2118/$2119, il incrémentera l'adresse quand on écrit à $2119 
    lda #$80 
    sta !VMAINC 
   
    
    ;La première couleur sera la couleur de fond de la SNES, 
    ;si un BG ou un sprite l'utilisent,la première couleur sera la transparence.
    ;adresse de CG-RAM = 0 
    lda #$00 
    sta !CGADD 

     
    ;Registre $2122 écrit sur la palette 
     
    ;orange 
    lda #$FF ; VVVR RRRR 
    sta !CGDATA 
    
    lda #$01 ; BBBB B0VV 
    sta !CGDATA 
     
    ;Là, il a incrémenté, donc on est à l'adresse de CG-RAM = 1 
     
    ;bleu 
    lda #$00 ; VVVR RRRR 
    sta !CGDATA 
    
    lda #$F7 ; BBBB B0VV 
    sta !CGDATA 
    
    ;ainsi de suite 
     
    
    ;On désactive le Forced Blank 
    lda #$0F 
    sta !INIDISP 


    ;;; WRAM Init
    ;; WRAM is set to 0 up to 50 then it's 40 bytes of 0, 40 bytes of 1, ect...

    lda #$00
    ldx.w #0000
dumbloop:
    stz 0,x
    INX
    CPX.w #50
    BNE dumbloop
    ldx.w #0049
    ldy #$0000
myincyloop:
    sta $7E0000,x
    CPY.w #40
    BNE continueloop
    ldy #$0000
    INC
    continueloop:
    INY
    INX
    CPX #$2000
    BNE myincyloop


    ;;; SRAM init
    ;; We copy a part ($1000 byte) of the first bank xor 42
    ;; Then $1000 bytes xor 69
    
    lda #$00
    ldx #$0000
    sramloop1:
    sta $700000, X
    INX
    CPX #$1000
    BNE sramloop1
    ldx #$0000
    sramloop2:
    lda $C10000, X
    EOR #42
    sta $206000, X
    INX
    CPX #$1000
    BNE sramloop2

    ldx #$0000
    sramloop3:
    lda $C10000, X
    EOR #69
    sta $207000, X
    INX
    CPX #$1000
    BNE sramloop3

    ;; Extended sram stuff
    lda $00FFD8
    rep #$80
    cmp #$03
    BMI endromcpy
    stz $03
    clc
    lda #13
    sbc $00FFD8
    sta $03
    rep #$20
    lda #$400
    ldy #$0000
    anotherloop:
    lsr
    INY
    CPY $03
    BNE anotherloop
    sep #$20
    dec
    dec
    dec
    sta $04

    clc
    adc #11 ; we stop when xor value = $05
    sta $05

    ; building the address in memory
    lda #$D8
    sta $12
    lda #$21
    sta $22
    lda #$00
    sta $11
    stz $10
    lda #$60
    sta $21
    stz $20
    stz $20

    lda #11
    sta $02
    ldx $0000
    romtosram:
        ldy #$0000
        mysramloop:
            lda [$10], Y
            EOR $02
            sta [$20], Y
            INY
            rep #$20
            sty $07
            tya
            ORA #$F000
            cmp #$F000 ; testing if we did a 0x1000 jump, to change the xor value and get out
            bne piko 
                sep #$20
                lda $02
                cmp $05
                beq endromcpy
                INC $02
            piko:
            ldy $07
            sep #$20
            CPY #$3000
            BNE mysramloop
        ;inc $12 Hirom is continuous
        inc $22
        INX
        jmp romtosram
    endromcpy:

    ;Registre $4200, on active le NMI(VBlank) et le joypad 

    Game: 
        wai ; interruption (qui permet d'attendre le NMI) 
         
                         
    jmp Game 

print pc

