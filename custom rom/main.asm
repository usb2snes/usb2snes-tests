.include "header_lorom.asm" 
.include "snes.asm" 


Main: 
    xce     
    rep #$10    ;met les registres xy en 16 bits 

    SNES_INIT 
    
    ;INITIAL SETTINGS 
    
    ; c'est le registre $2100, il permet de faire un Forced Blank et de régler la luminosité 
    lda #$8F 
    sta INIDISP 

    ;general init 
     
    ;Registre $212C, active l'utilisation des plans obj + bg 
    lda #$01 ; on active le BG1 
    sta TM 
    
    ;Registre $2115, c'est pour dire que, à chaque fois qu'on écrit sur la VRAM avec le registre $2118/$2119, il incrémentera l'adresse quand on écrit à $2119 
    lda #$80 
    sta VMAINC 
   
    
    ;La première couleur sera la couleur de fond de la SNES, 
    ;si un BG ou un sprite l'utilisent,la première couleur sera la transparence.
    ;adresse de CG-RAM = 0 
    lda #$00 
    sta CGADD 

     
    ;Registre $2122 écrit sur la palette 
     
    ;orange 
    lda #$FF ; VVVR RRRR 
    sta CGDATA 
    
    lda #$01 ; BBBB B0VV 
    sta CGDATA 
     
    ;Là, il a incrémenté, donc on est à l'adresse de CG-RAM = 1 
     
    ;bleu 
    lda #$00 ; VVVR RRRR 
    sta CGDATA 
    
    lda #$F7 ; BBBB B0VV 
    sta CGDATA 
    
    ;ainsi de suite 
     
    
    ;On désactive le Forced Blank 
    lda #$0F 
    sta INIDISP 
        



    ;;; WRAM Init
    ;; WRAM is set to 0 up to 50 then it's 40 bytes of 0, 40 bytes of 1, ect...

    lda #$00
    ldx #0000
dumbloop:
    stz 0,x
    INX
    CPX #50
    BNE dumbloop

    ldx #0049
    ldy #$0000
myincyloop:
    sta $7E0000,x
    CPY #40
    BNE continueloop
    ldy #$0000
    INA
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
    lda $018000, X
    EOR #42
    sta $700000, X
    INX
    CPX #$1000
    BNE sramloop2

    ldx #$0000
    sramloop3:
    lda $018000, X
    EOR #69
    sta $701000, X
    INX
    CPX #$1000
    BNE sramloop3

    sramtorom:
    stz $02
    ldx #$0000
    mysramloop:
    lda $718000, X
    EOR $02
    sta $710000, X
    INX
    CPX #$8000
    BNE mysramloop
    lda $02
    INA
    sta $02
    CMP #8
    BNE sramtorom


    ;Registre $4200, on active le NMI(VBlank) et le joypad 

    Game: 
        wai ; interruption (qui permet d'attendre le NMI) 
        lda $20
        INC
        sta $20
        CMP $FF : BNE gendloop
            lda #$00 
            sta CGADD 
            rep #$20
            lda $213B
            INC
            STA CGDATA
            sep #$20
        .gendloop
    jmp Game

    NMI_Routine:
        rti




