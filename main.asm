norom

org $0000

incsrc "header.asm"
incsrc "registers.asm"

org $0010
BANK00: incsrc "bank00.asm"

org BANK00+$8000
CHRROM: incsrc "chrrom.asm"
