
db "NES", $1A ; Magic word + EOL
db $02, $04   ; program size: 32KB
db $04        ; CHR ROM size: 32KB
db $31, $00   ; flags, mapper
db $00        ; flags, RAM size
db $00, $00   ; flags, tv

; unused
db $00, $00, $00, $00, $00
