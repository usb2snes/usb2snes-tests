
; Internal ROM header
org $00FFB0 ; ROM registration
db "SP"
db "UTDM"
db $00, $00, $00, $00, $00, $00
db $00 ; flash size
db $00 ; expansion RAM size
db $00 ; special version
db $00 ; special chip

org $00FFC0 ; ROM specifications
db "USB2SNES Test HiROM  "

db $21 ; rom map
db $02 ; rom type, rom, ram, sram
db $0b ; rom size
db $03 ; sram size
db $01 ; ntsc
db $C3 ; use $FFB0 for header
db $33 ; version
dw #$FFFF ; checksum
dw #$0000 ; inverse checksum

; native mode
dw $FFFF, $FFFF ; unused
dw $0000 ; Vector_COP0
dw $0000 ; Vector_BRK
dw $0000 ; Vector_Abort
dw $0000 ; Vector_NMI
dw Main ; Vector_Reset
dw $0000 ; IRQ

; emulation mode
dw $FFFF, $FFFF ; unused
dw $0000 ; Vector_COP
dw $0000 ; Vector_Unused
dw $0000 ; Vector_Abort
dw $0000 ; Vector_NMI
dw Main ; Vector_Reset
dw $0000 ; IRQ/BRK


