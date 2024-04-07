;@ base $8000

;===================================================================================================

RESET:
#_8000: SEI
#_8001: CLD

#_8002: LDX.b #$FF
#_8004: TXS

.wait_a
#_8005: LDA.w PPUSTATUS
#_8008: BPL .wait_a

.wait_b
#_800A: LDA.w PPUSTATUS
#_800D: BPL .wait_b

#_800F: JMP InitializeGame

;===================================================================================================

WriteToPPU:
#_8012: STA.w PPUDATA

#_8015: RTS

;===================================================================================================

SetPPUADDRSafely:
#_8016: STA.w PPUADDR
#_8019: STX.w PPUADDR

;===================================================================================================

FlushCamera:
#_801C: LDA.b $06
#_801E: STA.w PPUSCROLL

#_8021: LDA.b $07
#_8023: STA.w PPUSCROLL

#_8026: LDA.b $00
#_8028: STA.w PPUCTRL

#_802B: RTS

;===================================================================================================

ResetSmokeAndTransients:
#_802C: LDA.b #$00
#_802E: STA.b $78
#_8030: STA.b $79
#_8032: STA.b $7A
#_8034: STA.b $91

#_8036: TAX

.clear_a
#_8037: STA.w $01C0,X

#_803A: INX
#_803B: CPX.b #$10
#_803D: BNE .clear_a

#_803F: LDX.b #$03

.clear_b
#_8041: STA.b $83,X

#_8043: DEX
#_8044: BPL .clear_b

#_8046: RTS

;===================================================================================================

ClearSpritesAndBG:
#_8047: LDA.b $00
#_8049: ORA.b #$10
#_804B: JSR SetPPUCTRL

#_804E: LDA.b #$00
#_8050: STA.b $08
#_8052: STA.b $39
#_8054: STA.b $0B

#_8056: STA.w $0200

#_8059: STA.b $19
#_805B: STA.b $18

#_805D: JSR ClearOAM
#_8060: JSR ResetSmokeAndTransients

;===================================================================================================

ClearTilemapWith00:
#_8063: LDA.b #$00
#_8065: STA.b $1C
#_8067: BEQ ClearTilemap

;===================================================================================================

ClearTilemapWith2F:
#_8069: LDA.b #$2F
#_806B: STA.b $1C

;===================================================================================================

ClearTilemap:
#_806D: LDA.b #$20 ; VRAM $2000
#_806F: LDX.b #$00
#_8071: JSR SetPPUADDRSafely

#_8074: LDY.b #$08
#_8076: LDX.b #$00

#_8078: LDA.b $1C

.next_write
#_807A: JSR WriteToPPU

#_807D: DEX
#_807E: BNE .next_write

#_8080: DEY
#_8081: BNE .next_write

;---------------------------------------------------------------------------------------------------

#_8083: LDA.b #$23 ; VRAM $23C0
#_8085: JSR .clear_page

#_8088: LDA.b #$27 ; VRAM $27C0

;---------------------------------------------------------------------------------------------------

.clear_page
#_808A: LDX.b #$C0
#_808C: JSR SetPPUADDRSafely

#_808F: LDA.b #$00

.next_clear
#_8091: JSR WriteToPPU

#_8094: INX
#_8095: BNE .next_clear

#_8097: RTS

;===================================================================================================

NextFrameWithBGandOAM:
#_8098: JSR NextFrame

#_809B: LDA.b #$0A
#_809D: JSR SetPPUMask

;===================================================================================================

FlushOAM:
#_80A0: LDA.b #$00
#_80A2: STA.w OAMADDR

#_80A5: LDA.b #$03
#_80A7: STA.w OAMDMA

#_80AA: RTS

;===================================================================================================

NextFrameWithMaskReset:
#_80AB: JSR ResetUpdateQueues
#_80AE: JSR NextFrame

#_80B1: LDA.b #$00

;===================================================================================================

SetPPUMask:
#_80B3: STA.w PPUMASK

.set_mask_queue
#_80B6: STA.b $01

#_80B8: RTS

;===================================================================================================

#EnableSpriteDraw:
#_80B9: LDA.b $01
#_80BB: ORA.b #$14
#_80BD: BNE .set_mask_queue

;===================================================================================================
; FREE ROM: 0x03
;===================================================================================================
UNREACHABLE_80BF:
#_80BF: JMP ClearOAM

;===================================================================================================

NextFrame:

.wait_for_vblank
#_80C2: LDA.w PPUSTATUS
#_80C5: BMI .wait_for_vblank

.wait_for_end
#_80C7: LDA.w PPUSTATUS
#_80CA: BPL .wait_for_end

#_80CC: RTS

;===================================================================================================

NextFrameWithUpdates:
#_80CD: LDA.b #$00
#_80CF: STA.b $3A
#_80D1: JSR NextFrame

#_80D4: LDA.b $00
#_80D6: ORA.b #$80
#_80D8: BNE SetPPUCTRL

;===================================================================================================

WaitForNMI:
#_80DA: JSR ResetUpdateQueues

#_80DD: LDA.b #$00
#_80DF: STA.b $39

.spin
#_80E1: LDA.b $39
#_80E3: BEQ .spin

#_80E5: LDA.b $00
#_80E7: AND.b #$7F

;===================================================================================================

SetPPUCTRL:
#_80E9: STA.b $00
#_80EB: STA.w PPUCTRL

#_80EE: RTS

;===================================================================================================

ResetUpdateQueues:
#_80EF: LDA.b #$00
#_80F1: STA.b $18
#_80F3: STA.w $0200
#_80F6: STA.b $19

#_80F8: STA.b $97

#_80FA: RTS

;===================================================================================================

GetDefaultSpritePalettes:
#_80FB: LDA.w $05E0
#_80FE: STA.b $1E

#_8100: LDX.b $87
#_8102: BEQ .use_set_a

#_8104: LDX.b #$10

.use_set_a
#_8106: LDY.b #$00

.next
#_8108: TYA
#_8109: AND.b #$03
#_810B: BEQ .skip

#_810D: LDA.w DefaultSpritePalettes,X
#_8110: STA.w $05F0,Y

#_8113: JMP .continue

.skip
#_8116: LDA.b $1E
#_8118: STA.w $05F0,Y

.continue
#_811B: INX

#_811C: INY
#_811D: CPY.b #$10
#_811F: BNE .next

#_8121: JSR IsShrineOrBossRoom
#_8124: BCC EXIT_8146

;===================================================================================================

LoadScarySpritePalette_full:
#_8126: LDY.b #$04
#_8128: JSR LoadScarySpritePalette

#_812B: LDY.b #$0C
#_812D: JSR LoadScarySpritePalette

#_8130: LDY.b #$00

;===================================================================================================

LoadScarySpritePalette:
#_8132: LDA.b #$03
#_8134: STA.b $1C

#_8136: LDX.w ScarySpritePalettes,Y

#_8139: INY

.next
#_813A: LDA.w ScarySpritePalettes,Y
#_813D: STA.w $05F0,X

#_8140: INY
#_8141: INX

#_8142: DEC.b $1C
#_8144: BNE .next

;---------------------------------------------------------------------------------------------------

#EXIT_8146:
#_8146: RTS

;===================================================================================================

IsShrineOrBossRoom:
#_8147: LDA.b $87
#_8149: CMP.b #$0C ; ROOM 0C
#_814B: BEQ .succeed

#_814D: CMP.b #$0D ; ROOM 0D
#_814F: BEQ .succeed

#_8151: CMP.b #$15 ; ROOM 15
#_8153: BCC .fail

.succeed
#_8155: SEC
#_8156: RTS

.fail
#_8157: CLC
#_8158: RTS

;===================================================================================================
; PALETTE DATA
;===================================================================================================
ScarySpritePalettes:
;         index        colors
#_8159: db $0D : db $0F, $16, $37 ; Maharito / Shrine
#_815D: db $05 : db $2A, $00, $30 ; Maharito / Shrine
#_8161: db $0D : db $05, $0F, $0F ; Maharito flashing
#_8165: db $09 : db $16, $35, $30 ; Maharito / Shrine

;===================================================================================================

RefreshGFXBank:
#_8169: LDX.b $94

;===================================================================================================

SetGFXBank:
#_816B: LDA.w GFXBanks,X
#_816E: STA.w GFXBanks,X

#_8171: RTS

;===================================================================================================

ReloadDefaultSpritePalettes:
#_8172: JSR GetDefaultSpritePalettes

;===================================================================================================

ReloadPalettesWithWait:
#_8175: JSR NextFrame

;===================================================================================================

UploadPalettes:
#_8178: LDA.b #$3F ; VRAM $3F00
#_817A: LDX.b #$00
#_817C: JSR SetPPUADDRSafely

#_817F: LDY.b #$00

.next
#_8181: LDA.w $05E0,Y
#_8184: JSR WriteToPPU

#_8187: INY
#_8188: CPY.b #$20
#_818A: BNE .next

#_818C: LDA.b #$3F ; VRAM $3F00
#_818E: STA.w PPUADDR

#_8191: LDA.b #$00
#_8193: STA.w PPUADDR

#_8196: STA.w PPUADDR ; VRAM $0000
#_8199: STA.w PPUADDR

#_819C: JMP FlushCamera

;===================================================================================================

NMI:
#_819F: PHA

#_81A0: TXA
#_81A1: PHA

#_81A2: TYA
#_81A3: PHA

#_81A4: LDA.b $3A
#_81A6: BNE .no_updates

#_81A8: JSR FlushOAM
#_81AB: JSR FlushCamera
#_81AE: JSR RefreshGFXBank

#_81B1: LDA.b #$04
#_81B3: STA.b $1A

;---------------------------------------------------------------------------------------------------

#_81B5: LDY.b $18

#_81B7: LDA.w $0200,Y
#_81BA: BEQ .no_uploads

.next_vram_upload
#_81BC: LDY.b $18

#_81BE: LDA.w $0200,Y
#_81C1: BEQ .stop_uploading

#_81C3: JSR ArbitraryVRAMTransfer

#_81C6: DEC.b $1A
#_81C8: BEQ .stop_uploading

#_81CA: JMP .next_vram_upload

.no_uploads
#_81CD: LDA.b $97
#_81CF: BEQ .stop_uploading

#_81D1: JSR UploadPalettes

;---------------------------------------------------------------------------------------------------

.stop_uploading
#_81D4: LDA.b $01
#_81D6: STA.w PPUMASK

#_81D9: LDA.b #$01
#_81DB: STA.w JOY1

#_81DE: LDA.b #$00
#_81E0: STA.w JOY1

#_81E3: LDX.b #$08

.poll_controllers
#_81E5: LDA.w JOY1
#_81E8: LSR A
#_81E9: ROL.b $02
#_81EB: LSR A
#_81EC: ROL.b $03

#_81EE: LDA.w JOY2
#_81F1: LSR A
#_81F2: ROL.b $04
#_81F4: LSR A
#_81F5: ROL.b $05

#_81F7: DEX
#_81F8: BNE .poll_controllers

;---------------------------------------------------------------------------------------------------

#_81FA: LDA.b $04
#_81FC: AND.b #$CF ; Mask out JOY2 start/select
#_81FE: ORA.b $02
#_8200: ORA.b $03
#_8202: ORA.b $05
#_8204: STA.b $08

#_8206: LDA.b #$01
#_8208: STA.b $39

#_820A: JSR RunLightningTimer

.no_updates
#_820D: JSR HandleMusic
#_8210: JSR HandleSFX

#_8213: PLA
#_8214: TAY

#_8215: PLA
#_8216: TAX

#_8217: PLA

#_8218: RTI

;===================================================================================================

RunLightningTimer:
#_8219: INC.b $90

#_821B: LDA.b $90
#_821D: CMP.b #$78
#_821F: BCC .dont_reset

#_8221: LDA.b #$00
#_8223: STA.b $90

#_8225: DEC.b $8F
#_8227: BPL .dont_reset

#_8229: LDA.b #$09
#_822B: STA.b $8F

.dont_reset
#_822D: LDA.b $BF
#_822F: EOR.b #$01
#_8231: AND.b $8A
#_8233: BEQ EXIT_824E

#_8235: LDA.b $90
#_8237: ORA.b $8F
#_8239: BNE EXIT_824E

#_823B: LDA.b $98
#_823D: EOR.b #$02
#_823F: STA.b $98

#_8241: JMP HandleAndFlagOverworldPalette

;===================================================================================================

ArbitraryVRAMTransfer:
#_8244: ASL A
#_8245: TAX

#_8246: LDA.w .vectors-1,X
#_8249: PHA

#_824A: LDA.w .vectors-2,X
#_824D: PHA

;---------------------------------------------------------------------------------------------------

#EXIT_824E:
#_824E: RTS

;---------------------------------------------------------------------------------------------------

.vectors
#_824F: dw ArbVXfrOneRow-1                  ; 01
#_8251: dw ArbVXfrPanMapAttributes-1        ; 02
#_8253: dw ArbVXfrOneTile-1                 ; 03
#_8255: dw ArbVXfr2x2WithProps-1            ; 04
#_8257: dw ArbVXfrTwoTiles-1                ; 05
#_8259: dw ArbVXfrNullTerminated-1          ; 06
#_825B: dw ArbVXfrOneTileXY-1               ; 07

;===================================================================================================

ArbVXfrOneRow:
#_825D: INY
#_825E: LDA.w $0200,Y

#_8261: INY
#_8262: TAX

#_8263: LDA.w $0200,Y
#_8266: INY

#_8267: JSR SetPPUADDRSafely

#_826A: LDA.b #$02
#_826C: STA.b $02

.next
#_826E: LDA.w $0200,Y
#_8271: INY
#_8272: STA.w PPUDATA

#_8275: LDA.w $0200,Y
#_8278: INY
#_8279: STA.w PPUDATA

#_827C: LDA.w $0200,Y
#_827F: INY
#_8280: STA.w PPUDATA

#_8283: LDA.w $0200,Y
#_8286: INY
#_8287: STA.w PPUDATA

#_828A: LDA.w $0200,Y
#_828D: INY
#_828E: STA.w PPUDATA

#_8291: LDA.w $0200,Y
#_8294: INY
#_8295: STA.w PPUDATA

#_8298: LDA.w $0200,Y
#_829B: INY
#_829C: STA.w PPUDATA

#_829F: LDA.w $0200,Y
#_82A2: INY
#_82A3: STA.w PPUDATA

#_82A6: LDA.w $0200,Y
#_82A9: INY
#_82AA: STA.w PPUDATA

#_82AD: LDA.w $0200,Y
#_82B0: INY
#_82B1: STA.w PPUDATA

#_82B4: LDA.w $0200,Y
#_82B7: INY
#_82B8: STA.w PPUDATA

#_82BB: LDA.w $0200,Y
#_82BE: INY
#_82BF: STA.w PPUDATA

#_82C2: LDA.w $0200,Y
#_82C5: INY
#_82C6: STA.w PPUDATA

#_82C9: LDA.w $0200,Y
#_82CC: INY
#_82CD: STA.w PPUDATA

#_82D0: LDA.w $0200,Y
#_82D3: INY
#_82D4: STA.w PPUDATA

#_82D7: LDA.w $0200,Y
#_82DA: INY
#_82DB: STA.w PPUDATA

#_82DE: DEC.b $02
#_82E0: BNE .next

#_82E2: STY.b $18

#_82E4: RTS

;===================================================================================================

ArbVXfrPanMapAttributes:
#_82E5: INY

#_82E6: LDA.w $0200,Y
#_82E9: INY
#_82EA: TAX
#_82EB: STX.b $05

#_82ED: LDA.w $0200,Y
#_82F0: INY
#_82F1: STA.b $04
#_82F3: JSR SetPPUADDRSafely

#_82F6: LDA.w $0200,Y
#_82F9: INY
#_82FA: STA.b $1B

#_82FC: LDX.b #$00
#_82FE: LDA.w PPUDATA
#_8301: LDA.w PPUDATA
#_8304: AND.b $1B
#_8306: STA.w $06F0,X

#_8309: INX
#_830A: LDA.w PPUDATA
#_830D: AND.b $1B
#_830F: STA.w $06F0,X

#_8312: INX
#_8313: LDA.w PPUDATA
#_8316: AND.b $1B
#_8318: STA.w $06F0,X

#_831B: INX
#_831C: LDA.w PPUDATA
#_831F: AND.b $1B
#_8321: STA.w $06F0,X

#_8324: INX
#_8325: LDA.w PPUDATA
#_8328: AND.b $1B
#_832A: STA.w $06F0,X

#_832D: INX
#_832E: LDA.w PPUDATA
#_8331: AND.b $1B
#_8333: STA.w $06F0,X

#_8336: INX
#_8337: LDA.w PPUDATA
#_833A: AND.b $1B
#_833C: STA.w $06F0,X

#_833F: INX
#_8340: LDA.w PPUDATA
#_8343: AND.b $1B
#_8345: STA.w $06F0,X

;---------------------------------------------------------------------------------------------------

#_8348: INX
#_8349: LDA.b $04
#_834B: LDX.b $05
#_834D: JSR SetPPUADDRSafely

#_8350: LDX.b #$00
#_8352: LDA.w $06F0,X
#_8355: ORA.w $0200,Y
#_8358: INY
#_8359: STA.w PPUDATA

#_835C: INX
#_835D: LDA.w $06F0,X
#_8360: ORA.w $0200,Y
#_8363: INY
#_8364: STA.w PPUDATA

#_8367: INX
#_8368: LDA.w $06F0,X
#_836B: ORA.w $0200,Y
#_836E: INY
#_836F: STA.w PPUDATA

#_8372: INX
#_8373: LDA.w $06F0,X
#_8376: ORA.w $0200,Y
#_8379: INY
#_837A: STA.w PPUDATA

#_837D: INX
#_837E: LDA.w $06F0,X
#_8381: ORA.w $0200,Y
#_8384: INY
#_8385: STA.w PPUDATA

#_8388: INX
#_8389: LDA.w $06F0,X
#_838C: ORA.w $0200,Y
#_838F: INY
#_8390: STA.w PPUDATA

#_8393: INX
#_8394: LDA.w $06F0,X
#_8397: ORA.w $0200,Y
#_839A: INY
#_839B: STA.w PPUDATA

#_839E: INX
#_839F: LDA.w $06F0,X
#_83A2: ORA.w $0200,Y
#_83A5: INY
#_83A6: STA.w PPUDATA

#_83A9: INX
#_83AA: STY.b $18

#_83AC: RTS

;===================================================================================================

ArbVXfrOneTile:
#_83AD: INY

#_83AE: LDA.w $0200,Y
#_83B1: INY
#_83B2: TAX

#_83B3: LDA.w $0200,Y
#_83B6: INY
#_83B7: JSR SetPPUADDRSafely

#_83BA: LDA.w $0200,Y
#_83BD: INY
#_83BE: STA.w PPUDATA

#_83C1: STY.b $18

#_83C3: RTS

;===================================================================================================

ArbVXfr2x2WithProps:
#_83C4: INY

#_83C5: LDA.b #$02
#_83C7: STA.b $02

.next
#_83C9: LDA.w $0200,Y
#_83CC: INY
#_83CD: TAX

#_83CE: LDA.w $0200,Y
#_83D1: INY
#_83D2: JSR SetPPUADDRSafely

#_83D5: LDA.w $0200,Y
#_83D8: INY
#_83D9: STA.w PPUDATA

#_83DC: LDA.w $0200,Y
#_83DF: INY
#_83E0: STA.w PPUDATA

#_83E3: DEC.b $02
#_83E5: BNE .next

;---------------------------------------------------------------------------------------------------

#_83E7: LDA.w $0200,Y
#_83EA: INY
#_83EB: STA.b $05
#_83ED: TAX

#_83EE: LDA.w $0200,Y
#_83F1: INY
#_83F2: STA.b $04

#_83F4: JSR SetPPUADDRSafely

#_83F7: LDA.w PPUDATA
#_83FA: LDA.w PPUDATA
#_83FD: AND.w $0200,Y
#_8400: INY
#_8401: ORA.w $0200,Y
#_8404: INY
#_8405: PHA

#_8406: LDA.b $04
#_8408: LDX.b $05
#_840A: JSR SetPPUADDRSafely

#_840D: PLA
#_840E: STA.w PPUDATA

#_8411: STY.b $18

#_8413: RTS

;===================================================================================================

ArbVXfrTwoTiles:
#_8414: INY

#_8415: LDA.b #$02
#_8417: STA.b $02

.next
#_8419: LDA.w $0200,Y
#_841C: INY
#_841D: TAX

#_841E: LDA.w $0200,Y
#_8421: INY
#_8422: JSR SetPPUADDRSafely

#_8425: LDA.w $0200,Y
#_8428: INY
#_8429: STA.w PPUDATA

#_842C: LDA.w $0200,Y
#_842F: INY
#_8430: STA.w PPUDATA

#_8433: DEC.b $02
#_8435: BNE .next

#_8437: STY.b $18

#_8439: RTS

;===================================================================================================

ArbVXfrNullTerminated:
#_843A: INY
#_843B: LDA.w $0200,Y

#_843E: INY
#_843F: TAX
#_8440: LDA.w $0200,Y

#_8443: INY
#_8444: JSR SetPPUADDRSafely

.next
#_8447: LDA.w $0200,Y
#_844A: BEQ .done

#_844C: INY
#_844D: STA.w PPUDATA

#_8450: JMP .next

.done
#_8453: INY
#_8454: STY.b $18

#_8456: RTS

;===================================================================================================

ArbVXfrOneTileXY:
#_8457: INY

#_8458: LDX.b #$00
#_845A: STX.b $0B

#_845C: INX
#_845D: STX.b $12

#_845F: LDA.w $0200,Y
#_8462: INY
#_8463: STA.b $2E

#_8465: LDA.w $0200,Y
#_8468: INY
#_8469: STA.b $2F

#_846B: LDA.w $0200,Y

#_846E: INY
#_846F: STY.b $18

;===================================================================================================

DrawTileAtXY:
#_8471: JSR GetVRAMofTileFromXY

#_8474: LDA.b $0D
#_8476: LDX.b $0C
#_8478: JSR SetPPUADDRSafely

#_847B: LDA.b $0E
#_847D: STA.w PPUDATA

#_8480: RTS

;===================================================================================================

ResetForNewArea:
#_8481: LDA.b #$01
#_8483: STA.b $3C

#_8485: LDA.b #$0A
#_8487: STA.b $47

#_8489: LDA.b #$09
#_848B: STA.b $8F

#_848D: LDA.b #$05 ; some vestigial thing?
#_848F: STA.w $07C0

#_8492: LDA.b #$00
#_8494: STA.b $3D
#_8496: STA.b $40
#_8498: STA.b $49
#_849A: STA.b $4F

#_849C: STA.b $96
#_849E: STA.b $97

#_84A0: STA.b $13
#_84A2: STA.b $31

#_84A4: STA.b $8B
#_84A6: STA.b $90

#_84A8: STA.w $07BC
#_84AB: STA.w $07BE

#_84AE: STA.b $A9
#_84B0: STA.b $AA

#_84B2: STA.b $AC

#_84B4: STA.w $07C3
#_84B7: STA.b $B4
#_84B9: STA.w $07DB
#_84BC: STA.b $B9

#_84BE: RTS

;===================================================================================================

TitleScreen:
#_84BF: LDA.b #$00 ; GFXBANK 00
#_84C1: STA.b $94
#_84C3: STA.b $8A

#_84C5: JSR ResetBGandPalettes

#_84C8: LDA.b #$10
#_84CA: JSR SetPPUCTRL

#_84CD: JSR ResetBGScroll

#_84D0: LDA.b #$01
#_84D2: STA.b $3A
#_84D4: STA.b $98

#_84D6: JSR HandleOverworldPalette

#_84D9: LDX.b #$36
#_84DB: LDY.b #$08

#_84DD: LDA.b #$04
#_84DF: STA.b $1C

#_84E1: JSR SetOverworldPalette
#_84E4: JSR LoadOverworldTilemap

;---------------------------------------------------------------------------------------------------
; Clear the title screen with empty blue sky
;---------------------------------------------------------------------------------------------------
#_84E7: LDA.b #$00
#_84E9: STA.b $2A

.next_sky_row
#_84EB: LDA.b #$00
#_84ED: STA.b $29

.next_sky_tile
#_84EF: LDA.b #$32 ; OWOBJ 32
#_84F1: STA.b $2B

#_84F3: JSR DrawOverworldTileToXY

#_84F6: INC.b $29

#_84F8: LDA.b $29
#_84FA: CMP.b #$10
#_84FC: BNE .next_sky_tile

#_84FE: INC.b $2A

#_8500: LDA.b $2A
#_8502: CMP.b #$0F
#_8504: BNE .next_sky_row

;---------------------------------------------------------------------------------------------------
; Draw the castle
;---------------------------------------------------------------------------------------------------
#_8506: LDA.b #$01
#_8508: STA.b $2A

.next_castle_row
#_850A: LDA.b #$07
#_850C: STA.b $29

.next_castle_tile
#_850E: JSR GetObjectType_overworld

#_8511: LDA.b $29
#_8513: PHA

#_8514: SEC
#_8515: SBC.b #$07
#_8517: STA.b $29

#_8519: LDA.b $2A
#_851B: PHA

#_851C: CLC
#_851D: ADC.b #$08
#_851F: STA.b $2A

#_8521: JSR DrawOverworldTileToXY

#_8524: PLA
#_8525: STA.b $2A

#_8527: PLA
#_8528: STA.b $29

#_852A: INX

#_852B: INC.b $29
#_852D: LDA.b $29
#_852F: CMP.b #$17
#_8531: BNE .next_castle_tile

#_8533: INC.b $2A
#_8535: LDA.b $2A
#_8537: CMP.b #$07
#_8539: BNE .next_castle_row

;---------------------------------------------------------------------------------------------------
; Write "Milon's Secret Castle™"
;---------------------------------------------------------------------------------------------------
#_853B: LDA.b #$20 ; VRAM $20C3
#_853D: LDX.b #$C3
#_853F: JSR SetPPUADDRSafely

#_8542: LDX.b #$88 ; Firct

#_8544: LDA.b #$03
#_8546: STA.b $1C

.next_title_row
#_8548: LDA.b #$02
#_854A: STA.b $1D

.next_title_word
#_854C: JSR DrawTitleCardChunk
#_854F: JSR TitleCardSpaces_x2

#_8552: DEC.b $1D
#_8554: BNE .next_title_word

#_8556: JSR DrawTitleCardChunk
#_8559: JSR TitleCardSpaces_x7

#_855C: DEC.b $1C
#_855E: BNE .next_title_row

;---------------------------------------------------------------------------------------------------

#_8560: LDA.b #$08 ; MESSAGE 08
#_8562: JSR DrawBigMessage

#_8565: JSR ReloadDefaultSpritePalettes

#_8568: JSR NextFrameWithUpdates
#_856B: JSR ResetNMIFlags
#_856E: JSR NextFrameWithBGandOAM
#_8571: JSR EnableSpriteDraw

.wait
#_8574: JSR WaitForNMIthenClearOAM
#_8577: JSR ResetNMIFlags

#_857A: LDA.b $08
#_857C: AND.b #$10
#_857E: BEQ .wait

#_8580: RTS

;===================================================================================================

DisplayBigMessage:
#_8581: PHA

#_8582: LDA.b #$00 ; GFXBANK 00
#_8584: STA.b $94
#_8586: STA.b $8A

#_8588: JSR ResetBGandPalettes

#_858B: PLA
#_858C: PHA

#_858D: JSR DrawBigMessage

#_8590: PLA
#_8591: CMP.b #$03
#_8593: BNE .not_notes_message

#_8595: JSR CheckForAnyNotes
#_8598: BEQ .not_notes_message

#_859A: LDA.b #$01
#_859C: STA.b $22

#_859E: LDX.b #$07 ; MESSAGE 07
#_85A0: LDA.b $A4 ; check for 100+ notes
#_85A2: BNE .judgement_complete

#_85A4: LDA.b $A5
#_85A6: CMP.b #$05 ; check for 50+ notes
#_85A8: BCS .judgement_complete

#_85AA: DEC.b $22 ; decides whether you get $1 for every 2 notes or 4

#_85AC: DEX ; MESSAGE 06
#_85AD: CMP.b #$04 ; check for 40+ notes
#_85AF: BCS .judgement_complete

#_85B1: DEX ; MESSAGE 05
#_85B2: CMP.b #$03 ; check for 30+ notes
#_85B4: BCS .judgement_complete

#_85B6: DEX ; MESSAGE 04

.judgement_complete
#_85B7: TXA
#_85B8: JSR DrawBigMessage

;---------------------------------------------------------------------------------------------------

.not_notes_message
#_85BB: JSR FlushCamera
#_85BE: JSR NextFrameWithUpdates
#_85C1: JMP NextFrameWithBGandOAM

;===================================================================================================

CheckForAnyNotes:
#_85C4: LDX.b #$02

#_85C6: LDA.b $A4

.next
#_85C8: ORA.b $A4,X

#_85CA: DEX
#_85CB: BPL .next

#_85CD: TAX

#_85CE: RTS

;===================================================================================================

DrawBigMessage:
#_85CF: LDY.b #$00

#_85D1: CMP.b #$09 ; MESSAGE 09
#_85D3: BNE .not_second_ending

#_85D5: LDA.b #Ending2Text>>0
#_85D7: STA.b $1C
#_85D9: LDA.b #Ending2Text>>8
#_85DB: STA.b $1D

#_85DD: BNE .next_line

.not_second_ending
#_85DF: TAX
#_85E0: BEQ .message_zero

#_85E2: STY.b $1C

;---------------------------------------------------------------------------------------------------

.search
#_85E4: LDA.w InterfaceText,Y
#_85E7: CMP.b #$FF
#_85E9: BNE .not_end_of_message

#_85EB: INC.b $1C

.not_end_of_message
#_85ED: INY
#_85EE: CPX.b $1C
#_85F0: BNE .search

;---------------------------------------------------------------------------------------------------

.message_zero
#_85F2: LDA.b #InterfaceText>>0
#_85F4: STA.b $1C

#_85F6: LDA.b #InterfaceText>>8
#_85F8: STA.b $1D

;---------------------------------------------------------------------------------------------------

.next_line
#_85FA: JSR .get_next_byte
#_85FD: PHA

#_85FE: JSR .get_next_byte
#_8601: TAX

#_8602: PLA
#_8603: CMP.b #$FF
#_8605: BEQ .exit

#_8607: JSR SetPPUADDRSafely

#_860A: JSR .get_next_byte
#_860D: TAX

.next_character
#_860E: JSR .get_next_byte

#_8611: STA.w PPUDATA

#_8614: DEX
#_8615: BNE .next_character
#_8617: BEQ .next_line

;===================================================================================================

.get_next_byte
#_8619: LDA.b ($1C),Y

#_861B: INY
#_861C: BNE .exit

#_861E: INC.b $1D

.exit
#_8620: RTS

;===================================================================================================

ResetBGandPalettes:
#_8621: JSR NextFrameWithMaskReset
#_8624: JSR ClearTilemapWith00

#_8627: LDA.b #$00
#_8629: STA.b $07
#_862B: STA.b $06

#_862D: LDA.b #$10
#_862F: STA.b $00
#_8631: STA.w PPUCTRL

#_8634: LDA.b #$00
#_8636: TAX
#_8637: TAY

.next
#_8638: LDA.w DefaultPalette,X
#_863B: STA.w $05E0,Y

#_863E: INX
#_863F: TXA
#_8640: AND.b #$0F
#_8642: TAX

#_8643: INY
#_8644: CPY.b #$20
#_8646: BNE .next

#_8648: JSR ReloadPalettesWithWait
#_864B: JMP RefreshGFXBank

;===================================================================================================
; Returns with:
;   X - n/10
;   A - n%10
;===================================================================================================
DivideBy10:
#_864E: LDX.b #$00

.more
#_8650: SEC
#_8651: SBC.b #$0A
#_8653: BCC .overflow

#_8655: INX
#_8656: BNE .more

.overflow
#_8658: ADC.b #$0A

#_865A: RTS

;===================================================================================================
; PALETTE DATA
;===================================================================================================
DefaultPalette:
#_865B: db $0F, $0F, $15, $30
#_865F: db $0F, $21, $15, $36
#_8663: db $0F, $18, $27, $37
#_8667: db $0F, $0F, $15, $30

;===================================================================================================

InterfaceText:

.message_00
; "GAME START!"
#_866B: db $21, $AA, $0B ; VRAM $21AA, 11 bytes
#_866E: db $67, $5B, $6C, $5F, $00, $77, $78, $5B
#_8676: db $76, $78, $7E
#_8679: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_01
; "GAME OVER"
#_867A: db $21, $AB, $09 ; VRAM $21AB, 9 bytes
#_867D: db $67, $5B, $6C, $5F, $00, $6E, $7A, $5F
#_8685: db $76
#_8686: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_02
; "BONUS STAGE!"
#_8687: db $21, $CA, $0C ; VRAM $21CA, 12 bytes
#_868A: db $5C, $6E, $6D, $79, $77, $00, $77, $78
#_8692: db $5B, $67, $5F, $7E
#_8696: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_03
; "YOU CAUGHT"
#_8697: db $21, $4B, $0A ; VRAM $214B, 10 bytes
#_869A: db $7D, $6E, $79, $00, $5D, $5B, $79, $67
#_86A2: db $68, $78

; "NOTES"
#_86A4: db $21, $AF, $05 ; VRAM $21AF, 5 bytes
#_86A7: db $6D, $6E, $78, $5F, $77
#_86AC: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_04
; "GOOD!"
#_86AD: db $22, $6E, $05 ; VRAM $226E, 5 bytes
#_86B0: db $67, $6E, $6E, $5E, $7E
#_86B5: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_05
; "VERY GOOD!"
#_86B6: db $22, $6B, $0A ; VRAM $226B, 10 bytes
#_86B9: db $7A, $5F, $76, $7D, $00, $67, $6E, $6E
#_86C1: db $5E, $7E
#_86C3: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_06
; "EXCELLENT!"
#_86C4: db $22, $6B, $0A ; VRAM $226B, 10 bytes
#_86C7: db $5F, $7C, $5D, $5F, $6B, $6B, $5F, $6D
#_86CF: db $78, $7E
#_86D1: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_07
; "WONDERFUL!"
#_86D2: db $22, $6B, $0A ; VRAM $226B, 10 bytes
#_86D5: db $7B, $6E, $6D, $5E, $5F, $76, $66, $79
#_86DD: db $6B, $7E
#_86DF: db $FF ; end

;---------------------------------------------------------------------------------------------------

.message_08
; "TM AND © 1987 HUDSON SOFT"
#_86E0: db $21, $A3, $19 ; VRAM $21A3, 25 bytes
#_86E3: db $78, $6C, $01, $5B, $6D, $5E, $01, $56
#_86EB: db $01, $57, $58, $59, $FF, $01, $68, $79
#_86F3: db $5E, $77, $6E, $6D, $01, $77, $6E, $66
#_86FB: db $78

; "PUSH START"
#_86FC: db $21, $6B, $0A ; VRAM $216B, 10 bytes
#_86FF: db $6F, $79, $77, $68, $01, $77, $78, $5B
#_8707: db $76, $78

; "LICENCED BY"
#_8709: db $21, $EA, $0B ; VRAM $21EA, 11 bytes
#_870C: db $6B, $69, $5D, $5F, $6D, $5D, $5F, $5E
#_8714: db $01, $5C, $7D

; "NINTENDO OF AMERICA INC."
#_8717: db $22, $24, $18 ; VRAM $2224, 24 bytes
#_871A: db $6D, $69, $6D, $78, $5F, $6D, $5E, $6E
#_8722: db $01, $6E, $66, $01, $5B, $6C, $5F, $76
#_872A: db $69, $5D, $5B, $01, $69, $6D, $5D, $5A
#_8732: db $FF ; end

;---------------------------------------------------------------------------------------------------
; message_09
;---------------------------------------------------------------------------------------------------
Ending2Text:
; "THIS IS THE END OF"
#_8733: db $21, $47, $12 ; VRAM $2147, 18 bytes
#_8736: db $78, $68, $69, $77, $00, $69, $77, $00
#_873E: db $78, $68, $5F, $00, $5F, $6D, $5E, $00
#_8746: db $6E, $66

; "EPISODE 1"
#_8748: db $21, $AB, $09 ; VRAM $21AB, 9 bytes
#_874B: db $5F, $6F, $69, $77, $6E, $5E, $5F, $00
#_8753: db $57

; "SEE YOU AGAIN!"
#_8754: db $22, $29, $0E ; VRAM $2229, 14 bytes
#_8757: db $77, $5F, $5F, $00, $7D, $6E, $79, $00
#_875F: db $5B, $67, $5B, $69, $6D, $7E
#_8765: db $FF ; end

;===================================================================================================

TitleCardSpaces_x7:
#_8766: LDY.b #$07
#_8768: db $2C ; BIT trick

TitleCardSpaces_x2:
#_8769: LDY.b #$02
#_876B: LDA.b #$01

.next
#_876D: STA.w PPUDATA

#_8770: DEY
#_8771: BNE .next

#_8773: RTS

;===================================================================================================

DrawTitleCardChunk:
#_8774: LDY.b #$07

.next
#_8776: STX.w PPUDATA
#_8779: JSR .set_bit_3

#_877C: DEY
#_877D: BNE .next

#_877F: RTS

;---------------------------------------------------------------------------------------------------

; Why didn't you just TXA to begin with...?
.set_bit_3
#_8780: INX
#_8781: TXA
#_8782: ORA.b #$08
#_8784: TAX

#_8785: RTS

;===================================================================================================

EnterBossRoom:
#_8786: LDA.b #$01
#_8788: STA.b $52

#_878A: LDA.b $8C
#_878C: LDY.b #$00

.search
#_878E: CMP.w BossRooms,Y
#_8791: BEQ .match

#_8793: INY
#_8794: BNE .search

.match
#_8796: INY
#_8797: STY.b $B4

;---------------------------------------------------------------------------------------------------

#_8799: LDA.b #$00
#_879B: STA.b $8A
#_879D: STA.b $49

#_879F: STA.b $3A
#_87A1: STA.b $3C
#_87A3: STA.b $3D

#_87A5: JSR WaitForNMI

#_87A8: LDA.b $29
#_87AA: PHA

#_87AB: LDA.b $2A
#_87AD: PHA

#_87AE: JSR ClearTilemapWith00

#_87B1: LDA.b #$00 ; GFXBANK 00
#_87B3: STA.b $94

#_87B5: JSR ResetBGScroll

#_87B8: LDA.b $00
#_87BA: AND.b #$FC
#_87BC: ORA.b #$10
#_87BE: JSR SetPPUCTRL

;---------------------------------------------------------------------------------------------------

#_87C1: LDX.b #$20

.next_color
#_87C3: LDA.w BossRoomPalette,X
#_87C6: STA.w $05E0,X

#_87C9: DEX
#_87CA: BPL .next_color

#_87CC: JSR ReloadPalettesWithWait

;---------------------------------------------------------------------------------------------------

#_87CF: LDA.b #BossRoomTiles>>0
#_87D1: STA.b $1E
#_87D3: LDA.b #BossRoomTiles>>8
#_87D5: STA.b $1F

#_87D7: LDA.b #$04 ; number of tiles per strip
#_87D9: STA.b $20

#_87DB: JSR DrawSmallRoom

;---------------------------------------------------------------------------------------------------

#_87DE: LDA.b #$20
#_87E0: JSR ForceMilonToEntryPosition

#_87E3: LDA.b $87
#_87E5: PHA

#_87E6: JSR ResetSpritesAndPits

#_87E9: LDX.b $B4
#_87EB: DEX
#_87EC: BNE .not_first_boss

; Check for items to spawn first boss
#_87EE: LDA.w $079A ; shoes
#_87F1: ORA.w $079E ; shoes
#_87F4: AND.w $079D ; medicine
#_87F7: BEQ BossFight

.not_first_boss
#_87F9: LDA.b #$1A ; ROOM 1A
#_87FB: STA.b $87

#_87FD: JSR CheckForCrystal
#_8800: BNE BossFight

#_8802: JSR LoadAllSprites

#_8805: LDY.b $B4

#_8807: LDA.w BossGraphics-1,Y
#_880A: STA.w $060D

#_880D: LDA.b #$12 ; SONG 12
#_880F: STA.b $BE

;===================================================================================================

BossFight:
#_8811: JSR ResetSmokeAndTransients

#_8814: LDA.b #$00
#_8816: STA.b $3A

#_8818: JSR NextFrameWithUpdates
#_881B: JSR NextFrameWithBGandOAM
#_881E: JSR EnableSpriteDraw

;---------------------------------------------------------------------------------------------------

.next_frame
#_8821: JSR HandlePausing

#_8824: JSR WaitForNMIthenClearOAM

#_8827: JSR DrawEntireHUD

#_882A: JSR ShootBubbles
#_882D: JSR HandleBubbles

#_8830: JSR DrawBeeShield
#_8833: JSR DrawMilon
#_8836: JSR HandleSmokePuffs
#_8839: JSR SmallRoomMilon

#_883C: JSR HandleAllSprites

#_883F: JSR TestIfCrystalGrabbed
#_8842: JSR OpenBossDoor

#_8845: JSR ResetNMIFlags

#_8848: LDA.b $4F
#_884A: BEQ .not_dying

#_884C: JMP AnimateDeath

.not_dying
#_884F: LDA.b $3E
#_8851: CMP.b #$10
#_8853: BCC .check_y

#_8855: CMP.b #$E0
#_8857: BCC .next_frame

#_8859: LDA.b $3F
#_885B: CMP.b #$A8
#_885D: BNE .next_frame

#_885F: LDA.b $83
#_8861: CMP.b #$05
#_8863: BNE .next_frame

#_8865: LDA.b #$00
#_8867: STA.b $23
#_8869: BEQ .exit

.check_y
#_886B: LDA.b $3F
#_886D: CMP.b #$B8
#_886F: BNE .next_frame

;---------------------------------------------------------------------------------------------------

#_8871: LDA.b #$01
#_8873: STA.b $23

.exit
#_8875: PLA
#_8876: STA.b $87

#_8878: PLA
#_8879: STA.b $2A

#_887B: PLA
#_887C: STA.b $29

#_887E: RTS

;===================================================================================================

CheckForCrystal:
#_887F: LDX.b $B4
#_8881: DEX

#_8882: LDA.b $B7
#_8884: AND.w BitTable,X

#_8887: RTS

;===================================================================================================

TestIfCrystalGrabbed:
#_8888: LDA.b $83
#_888A: BNE .exit

#_888C: JSR CheckForCrystal
#_888F: BEQ .exit

#_8891: INC.b $83

.exit
#_8893: RTS

;===================================================================================================

BossRooms:
#_8894: db $15 ; ROOM 15 => BOSS 01
#_8895: db $02 ; ROOM 02 => BOSS 02
#_8896: db $1A ; ROOM 1A => BOSS 03
#_8897: db $01 ; ROOM 01 => BOSS 04
#_8898: db $1E ; ROOM 1E => BOSS 05
#_8899: db $1B ; ROOM 1B => BOSS 06
#_889A: db $0D ; ROOM 0D => BOSS 07

BossGraphics:
#_889B: db $00 ; BOSS 01 - HOMA
#_889C: db $06 ; BOSS 02 - DOMA
#_889D: db $04 ; BOSS 03 - BARUKAMA
#_889E: db $06 ; BOSS 04 - BLUE DOMA
#_889F: db $00 ; BOSS 05 - RED HOMA
#_88A0: db $04 ; BOSS 06 - RED BARUKAMA
#_88A1: db $02 ; BOSS 07 - KAMA

;===================================================================================================

OpenBossDoor:
#_88A2: LDA.b $83
#_88A4: BEQ .exit

#_88A6: CMP.b #$05
#_88A8: BEQ .exit

#_88AA: INC.b $84

#_88AC: LDA.b $84
#_88AE: AND.b #$03
#_88B0: BNE .exit

#_88B2: LDA.b #$04
#_88B4: SEC
#_88B5: SBC.b $83
#_88B7: LSR A
#_88B8: ROR A
#_88B9: ROR A
#_88BA: LSR A
#_88BB: CLC
#_88BC: ADC.b #$9C ; VRAM $229C
#_88BE: STA.b $1C

#_88C0: LDA.b #$22
#_88C2: ADC.b #$00
#_88C4: STA.b $1D

#_88C6: LDX.b $19

#_88C8: LDA.b #$06 ; VXFR 06
#_88CA: JSR AddToVRAMBuffer

#_88CD: LDA.b $1C
#_88CF: JSR AddToVRAMBuffer

#_88D2: LDA.b $1D
#_88D4: JSR AddToVRAMBuffer

#_88D7: LDA.b #$62
#_88D9: JSR AddToVRAMBuffer

#_88DC: LDA.b #$63
#_88DE: JSR AddToVRAMBuffer

#_88E1: LDA.b #$00
#_88E3: JSR AddToVRAMBuffer

#_88E6: JSR FinishedVRAMBuffer

#_88E9: INC.b $83

.exit
#_88EB: RTS

;===================================================================================================

DrawSmallRoom:
#_88EC: LDY.b #$00

.next_transfer
#_88EE: JSR .horizontal_transfers

#_88F1: LDA.b ($1E),Y
#_88F3: BEQ .horizontal_transfers

#_88F5: PHA

#_88F6: AND.b #$FB
#_88F8: PHA

#_88F9: INY

#_88FA: LDA.b ($1E),Y
#_88FC: TAX

#_88FD: INY
#_88FE: PLA

#_88FF: JSR SetPPUADDRSafely

#_8902: LDA.b ($1E),Y
#_8904: STA.b $1C

#_8906: INY

#_8907: LDA.b ($1E),Y
#_8909: STA.b $76

#_890B: INY

#_890C: PLA
#_890D: AND.b #$04
#_890F: ORA.b $00
#_8911: JSR SetPPUCTRL

;---------------------------------------------------------------------------------------------------

.next_strip
#_8914: LDX.b $76

#_8916: LDA.b $20
#_8918: STA.b $21

.next_tile
#_891A: LDA.w SmallRoomTiles,X
#_891D: STA.w PPUDATA

#_8920: INX

#_8921: DEC.b $21
#_8923: BNE .next_tile

#_8925: DEC.b $1C
#_8927: BNE .next_strip

#_8929: BEQ .next_transfer

;===================================================================================================

.horizontal_transfers
#_892B: LDA.b $00
#_892D: AND.b #$FB
#_892F: JMP SetPPUCTRL

;===================================================================================================

BossRoomTiles:
#_8932: db $22, $A1, $01, $3A ; VRAM $22A1,  1 horizontal, offset $3A
#_8936: db $22, $7B, $01, $3A ; VRAM $227B,  1 horizontal, offset $3A
#_893A: db $20, $00, $18, $0A ; VRAM $2000, 24 horizontal, offset $0A
#_893E: db $20, $60, $10, $0E ; VRAM $2060, 16 horizontal, offset $0E
#_8942: db $20, $80, $08, $12 ; VRAM $2080,  8 horizontal, offset $12
#_8946: db $20, $A0, $08, $16 ; VRAM $20A0,  8 horizontal, offset $16
#_894A: db $20, $C0, $08, $1A ; VRAM $20C0,  8 horizontal, offset $1A
#_894E: db $20, $E0, $08, $1E ; VRAM $20E0,  8 horizontal, offset $1E
#_8952: db $21, $00, $08, $22 ; VRAM $2100,  8 horizontal, offset $22
#_8956: db $21, $20, $01, $26 ; VRAM $2120,  1 horizontal, offset $26
#_895A: db $21, $24, $06, $2A ; VRAM $2124,  6 horizontal, offset $2A
#_895E: db $21, $3C, $01, $2E ; VRAM $213C,  1 horizontal, offset $2E
#_8962: db $23, $0B, $05, $4A ; VRAM $230B,  5 horizontal, offset $4A
#_8966: db $23, $2B, $05, $4E ; VRAM $232B,  5 horizontal, offset $4E
#_896A: db $23, $40, $08, $52 ; VRAM $2340,  8 horizontal, offset $52
#_896E: db $23, $60, $08, $12 ; VRAM $2360,  8 horizontal, offset $12
#_8972: db $23, $80, $10, $0A ; VRAM $2380, 16 horizontal, offset $0A
#_8976: db $26, $C4, $01, $46 ; VRAM $22C4,  1   vertical, offset $46
#_897A: db $25, $40, $04, $32 ; VRAM $2140,  4   vertical, offset $32
#_897E: db $25, $41, $04, $36 ; VRAM $2141,  4   vertical, offset $36
#_8982: db $25, $5E, $04, $32 ; VRAM $215E,  4   vertical, offset $32
#_8986: db $25, $5F, $04, $36 ; VRAM $215F,  4   vertical, offset $36
#_898A: db $26, $9C, $01, $3E ; VRAM $229C,  1   vertical, offset $3E
#_898E: db $26, $9D, $01, $42 ; VRAM $229D,  1   vertical, offset $42
#_8992: db $26, $9B, $01, $56 ; VRAM $229B,  1   vertical, offset $56
#_8996: db $00 ; end

;===================================================================================================
; PALETTE DATA
;===================================================================================================
BossRoomPalette:
#_8997: db $0F, $07, $17, $10
#_899B: db $0F, $07, $17, $10
#_899F: db $0F, $07, $17, $10
#_89A3: db $0F, $07, $17, $10
#_89A7: db $0F, $21, $15, $37
#_89AB: db $0F, $07, $27, $30
#_89AF: db $0F, $00, $30, $30
#_89B3: db $0F, $02, $15, $30

;===================================================================================================

ResetCashAndNotes:
#_89B7: LDA.b #$00

#_89B9: LDX.b #$05

.next
#_89BB: STA.b $A1,X

#_89BD: DEX
#_89BE: BPL .next

#_89C0: RTS

;===================================================================================================

InitializeGame:
; Clear $0200-$07FF
#_89C1: LDA.b #$0200>>0
#_89C3: STA.b $1C

#_89C5: LDA.b #$0200>>8
#_89C7: STA.b $1D

#_89C9: LDA.b #$00
#_89CB: TAY

#_89CC: LDX.b #$06

.clear_ram
#_89CE: STA.b ($1C),Y

#_89D0: INY
#_89D1: BNE .clear_ram

#_89D3: INC.b $1D

#_89D5: DEX
#_89D6: BNE .clear_ram

;---------------------------------------------------------------------------------------------------

#_89D8: LDX.b #$F4

.clear_zero_page
#_89DA: STA.b $00,X

#_89DC: DEX
#_89DD: CPX.b #$06
#_89DF: BNE .clear_zero_page

;---------------------------------------------------------------------------------------------------

#_89E1: JSR NextFrameWithMaskReset
#_89E4: JSR ClearSpritesAndBG
#_89E7: JSR MuteSongChannels
#_89EA: JSR MuteSFX

;===================================================================================================

StartGame:
#_89ED: LDA.b #$00
#_89EF: STA.b $E6 ; SFX OFF
#_89F1: STA.b $BE ; SONG OFF

#_89F3: JSR TitleScreen

#_89F6: LDA.b #$00
#_89F8: STA.w $07CF

#_89FB: JSR NextFrameWithMaskReset

#_89FE: LDA.b $B6 ; Reset data if no crystals
#_8A00: BEQ .reset_data

#_8A02: LDA.b $08
#_8A04: AND.b #$02
#_8A06: STA.w $07D0
#_8A09: BNE ContinueGame

;---------------------------------------------------------------------------------------------------

.reset_data
#_8A0B: LDA.b #$00

#_8A0D: LDX.b #$0E

.reset_items
#_8A0F: STA.w $079A,X

#_8A12: DEX
#_8A13: BPL .reset_items

;---------------------------------------------------------------------------------------------------

#_8A15: LDX.b #$77

.reset_collection
#_8A17: STA.w $0722,X

#_8A1A: DEX
#_8A1B: BPL .reset_collection

;---------------------------------------------------------------------------------------------------

; Decide the correct Maharito room
#_8A1D: LDA.b $8E
#_8A1F: AND.b #$03
#_8A21: CLC
#_8A22: ADC.b #$15 ; ROOM 15
#_8A24: STA.w $07D6

; Reset a bunch of things
#_8A27: LDA.b #$00

#_8A29: STA.w $07C8 ; Keys
#_8A2C: STA.w $07C9

#_8A2F: STA.b $BD ; Royal items
#_8A31: STA.b $BA ; Fake Maharito
#_8A33: STA.b $B7 ; Crystals
#_8A35: STA.b $B6 ; Crystals
#_8A37: STA.b $9B ; Bubbles

#_8A39: STA.w $07C5 ; Bees
#_8A3C: STA.w $07C6
#_8A3F: STA.w $07C7
#_8A42: STA.b $9C ; Shield

#_8A44: STA.w $07CA ; Music boxes
#_8A47: STA.w $07CB
#_8A4A: STA.b $C0

#_8A4C: STA.b $BB ; Shield HP
#_8A4E: STA.b $BC ; Super shoes visits

#_8A50: LDA.b #$38 ; 7 hearts max HP
#_8A52: STA.b $B3

#_8A54: JSR ResetCashAndNotes

;===================================================================================================

ContinueGame:
#_8A57: LDA.b #$20 ; 4 hearts
#_8A59: STA.b $B2

#_8A5B: LDA.w $07D0
#_8A5E: BEQ .respawn_outside

#_8A60: LDA.b $87
#_8A62: CMP.b #$01 ; ROOM 01
#_8A64: BNE .not_room_01

#_8A66: LDX.b $8C
#_8A68: CPX.b #$01
#_8A6A: BEQ .respawn_outside

.not_room_01
#_8A6C: CMP.b #$0F ; ROOM 0F
#_8A6E: BEQ LoadNewArea

#_8A70: CMP.b #$10 ; ROOM 10
#_8A72: BEQ LoadNewArea

#_8A74: CMP.b #$09 ; ROOM 09
#_8A76: BCS .respawn_outside

#_8A78: BCC LoadNewArea

;---------------------------------------------------------------------------------------------------

.respawn_outside
#_8A7A: LDX.b #$FF
#_8A7C: TXS

#_8A7D: LDX.b #$05

#_8A7F: LDA.b #$00
#_8A81: STA.b $95

#_8A83: STA.b $87 ; ROOM 00
#_8A85: STA.b $8C

#_8A87: LDA.b #$1B
#_8A89: STA.b $8D
#_8A8B: STA.b $4F

#_8A8D: JSR NextFrameWithMaskReset

#_8A90: JMP LoadTheOverworld

;===================================================================================================

LoadNewAreaFresh:
#_8A93: LDA.b #$00
#_8A95: STA.w $07BD ; Coin collection counter
#_8A98: STA.w $07BF ; Key collection flag

;===================================================================================================

LoadNewArea:
#_8A9B: LDX.b #$FF
#_8A9D: TXS

#_8A9E: LDA.b $87 ; ROOM 00
#_8AA0: BNE LoadTheInside

#_8AA2: JMP LoadTheOverworld

;===================================================================================================

LoadTheInside:
#_8AA5: LDX.w $07BF

#_8AA8: DEX
#_8AA9: BNE .key_collected

#_8AAB: STX.w $07BF

.key_collected
#_8AAE: LDA.b $4F
#_8AB0: BEQ .not_death

; Continue game
#_8AB2: LDA.b #$00 ; MESSAGE 00
#_8AB4: JSR DisplayBigMessage

#_8AB7: LDA.b #$03 ; SONG 03
#_8AB9: STA.b $BE

#_8ABB: JSR WaitOutBigMessage
#_8ABE: JSR NextFrameWithMaskReset

.not_death
#_8AC1: LDA.b #$01
#_8AC3: STA.b $3A

#_8AC5: JSR MoveMilonToXY
#_8AC8: JSR ClampMilonTilemapX

;---------------------------------------------------------------------------------------------------

#_8ACB: LDA.b $87
#_8ACD: LDY.b #$01 ; GFXBANK 01
#_8ACF: CMP.b #$08 ; ROOM 08
#_8AD1: BCC .puzzle_room

#_8AD3: INY ; GFXBANK 02

.puzzle_room
#_8AD4: STY.b $94

#_8AD6: JSR ClearSpritesAndBG
#_8AD9: JSR ResetForNewArea

#_8ADC: JSR LoadRoom
#_8ADF: JSR LoadAllSprites

#_8AE2: LDA.b $87
#_8AE4: CMP.b #$0E ; ROOM 0E
#_8AE6: BNE .not_dark_room

#_8AE8: LDA.w $079F ; lamp
#_8AEB: BNE .not_dark_room

#_8AED: LDA.b #$0F
#_8AEF: LDX.b #$03

.paint_it_black
#_8AF1: STA.w $05EC,X

#_8AF4: DEX
#_8AF5: BPL .paint_it_black

.not_dark_room
#_8AF7: JSR UploadRoomGraphics
#_8AFA: JSR LoadDoorLocations

;---------------------------------------------------------------------------------------------------

#_8AFD: LDA.b $B7
#_8AFF: AND.b #$02 ; crystal 7 - reuse the 2 for triple shot
#_8B01: BNE .set_magazine_size

#_8B03: LDA.b $B7
#_8B05: AND.b #$18 ; crystals 4 or 5
#_8B07: BEQ .set_magazine_size

#_8B09: LDA.b #$01 ; double shot

.set_magazine_size
#_8B0B: ORA.b $9B
#_8B0D: STA.b $9B

#_8B0F: LDA.b $B7
#_8B11: AND.b #$40 ; crystal 2
#_8B13: LSR A
#_8B14: LSR A
#_8B15: LSR A
#_8B16: STA.b $1C

#_8B18: LDA.w $07A7 ; excalibur
#_8B1B: LSR A
#_8B1C: ROR A
#_8B1D: LSR A
#_8B1E: LSR A
#_8B1F: LSR A
#_8B20: ORA.b $1C
#_8B22: ORA.b $9B
#_8B24: STA.b $9B

;---------------------------------------------------------------------------------------------------

#_8B26: LDA.b #$01
#_8B28: STA.b $89

#_8B2A: LDA.b #$00
#_8B2C: STA.b $8A

#_8B2E: LDA.w $07C2
#_8B31: BEQ .big_milon

#_8B33: LDA.b $87
#_8B35: CMP.b #$15 ; ROOM 15
#_8B37: BCS .some_boss_room

.big_milon
#_8B39: LDA.b #$01
#_8B3B: STA.b $52

.some_boss_room
#_8B3D: LDA.b #$00
#_8B3F: STA.b $3A
#_8B41: STA.w $07CE

#_8B44: JSR NextFrameWithBGandOAM
#_8B47: JSR EnableSpriteDraw

;---------------------------------------------------------------------------------------------------

#_8B4A: LDA.b $87
#_8B4C: CMP.b #$0B ; ROOM 0B
#_8B4E: BNE .not_ice_tower

#_8B50: INC.b $AC

.not_ice_tower
#_8B52: LDA.b $87
#_8B54: CMP.b #$0A ; ROOM 0A

#_8B56: LDA.b #$04 ; SONG 04
#_8B58: ADC.b #$00
#_8B5A: CMP.b #$05 ; SONG 05
#_8B5C: BNE .set_song

#_8B5E: LDA.b $BE
#_8B60: AND.b #$7F
#_8B62: CMP.b #$05 ; SONG 05
#_8B64: BEQ .next_frame

#_8B66: LDA.b #$05 ; SONG 05

.set_song
#_8B68: STA.b $BE

;---------------------------------------------------------------------------------------------------

.next_frame
#_8B6A: JSR HandlePausing
#_8B6D: JSR WaitForNMIthenClearOAM

#_8B70: JSR CycleRoomPalettes

#_8B73: JSR DrawMilon
#_8B76: JSR DrawBeeShield

#_8B79: JSR HandleMilonBasics

#_8B7C: LDA.b $8B
#_8B7E: BNE .hit_screen_edge

#_8B80: JSR HandleAllSprites

#_8B83: LDY.b $18

#_8B85: LDA.w $0200,Y
#_8B88: BNE .no_active_objects

#_8B8A: JSR HandleTransients
#_8B8D: JSR HandleMovingPits

.no_active_objects
#_8B90: JSR DrawEntireHUD
#_8B93: JSR HandleSmokePuffs

#_8B96: LDA.b $9E
#_8B98: BNE .ending_cutscene

#_8B9A: LDA.b $4F
#_8B9C: BNE AnimateDeath

#_8B9E: LDA.b $9A
#_8BA0: BEQ .no_balloon

#_8BA2: INC.b $9A

#_8BA4: LDA.b $9A
#_8BA6: CMP.b #$14
#_8BA8: BCC .no_balloon

#_8BAA: JMP BalloonEscape

.no_balloon
#_8BAD: JSR ResetNMIFlags

#_8BB0: JMP .next_frame

;---------------------------------------------------------------------------------------------------

.hit_screen_edge
#_8BB3: LDA.b #$00
#_8BB5: STA.b $3A

#_8BB7: JMP EdgeOrDoorTransition

.ending_cutscene
#_8BBA: JMP EndingCutscene

;===================================================================================================

AnimateDeath:
#_8BBD: JSR ResetNMIFlags
#_8BC0: STA.b $3C
#_8BC2: STA.b $49

#_8BC4: LDA.b #$10 ; fly up for 16 frames
#_8BC6: STA.b $48

#_8BC8: LDA.b #$0A ; SONG 0A
#_8BCA: STA.b $BE

#_8BCC: LDA.b #$00
#_8BCE: STA.b $9E
#_8BD0: STA.b $34
#_8BD2: STA.b $53

;---------------------------------------------------------------------------------------------------

.keep_dying
#_8BD4: JSR WaitForNMIthenClearOAM
#_8BD7: JSR GAMEOVER

#_8BDA: LDA.b $3C
#_8BDC: CMP.b #$02
#_8BDE: BCS .skip_milon

#_8BE0: LDX.b #$05
#_8BE2: JSR DrawSpecificMilon

.skip_milon
#_8BE5: JSR HandleAllSprites
#_8BE8: JSR DrawEntireHUD

#_8BEB: JSR ResetNMIFlags
#_8BEE: BEQ .keep_dying

;===================================================================================================

DrawEndingSprites:
#_8BF0: LDX.b #$00

.next
#_8BF2: STX.b $5E

#_8BF4: LDA.w $06C0,X
#_8BF7: STA.b $6C

#_8BF9: JSR LoadSpriteVars
#_8BFC: JSR HandleSpriteWonted

#_8BFF: LDX.b $5E

#_8C01: LDA.b $6C
#_8C03: STA.w $06C0,X

#_8C06: INX
#_8C07: CPX.b #$10
#_8C09: BNE .next

#_8C0B: RTS

;===================================================================================================

GAMEOVER:
#_8C0C: LDA.b $3C
#_8C0E: BEQ MilonFlyingIntoTheAirBecauseHeDied

#_8C10: CMP.b #$01
#_8C12: BEQ MilonFallingToHisDeath

#_8C14: CMP.b #$02
#_8C16: BEQ WaitForGameOverSong

#_8C18: INC.b $3C

#_8C1A: LDA.b $3C
#_8C1C: CMP.b #$17
#_8C1E: BCS DisplayGAMEOVER

#_8C20: RTS

;===================================================================================================

WaitForGameOverSong:
#_8C21: LDA.b $BE
#_8C23: AND.b #$7F
#_8C25: BNE .exit

#_8C27: INC.b $3C

.exit
#_8C29: RTS

;===================================================================================================

MilonFallingToHisDeath:
#_8C2A: JSR DyingMilonYVelocity

#_8C2D: LDA.b $3F
#_8C2F: CLC
#_8C30: ADC.b $AE
#_8C32: STA.b $3F
#_8C34: BCS .advance

#_8C36: CMP.b #$F0
#_8C38: BCS .advance

#_8C3A: INC.b $48

#_8C3C: RTS

.advance
#_8C3D: INC.b $3C

#_8C3F: RTS

;===================================================================================================

MilonFlyingIntoTheAirBecauseHeDied:
#_8C40: JSR DyingMilonYVelocity

#_8C43: DEC.b $48
#_8C45: BNE .still_flying

#_8C47: INC.b $3C

#_8C49: RTS

.still_flying
#_8C4A: LDA.b $3F
#_8C4C: SEC
#_8C4D: SBC.b $AE
#_8C4F: BCC .exit

#_8C51: STA.b $3F

.exit
#_8C53: RTS

;===================================================================================================

DyingMilonYVelocity:
#_8C54: LDA.b $48
#_8C56: CLC
#_8C57: ADC.b $49
#_8C59: TAX

#_8C5A: AND.b #$07
#_8C5C: STA.b $49

#_8C5E: TXA
#_8C5F: LSR A
#_8C60: LSR A
#_8C61: LSR A
#_8C62: STA.b $AE

#_8C64: RTS

;===================================================================================================

DisplayGAMEOVER:
#_8C65: LDA.b #$01 ; MESSAGE 01
#_8C67: JSR DisplayBigMessage

#_8C6A: JSR NextFrameWithUpdates
#_8C6D: JSR ResetNMIFlags

#_8C70: LDA.b #$07 ; SONG 07
#_8C72: STA.b $BE

#_8C74: JSR WaitOutBigMessage
#_8C77: JMP StartGame

;===================================================================================================

WaitOutBigMessage:
#_8C7A: JSR WaitForNMIthenClearOAM

#_8C7D: LDA.w $07CF
#_8C80: BNE .skip_hud

#_8C82: JSR DrawEntireHUD

.skip_hud
#_8C85: LDA.w $07CF
#_8C88: BEQ .skip_notes

#_8C8A: JSR DrawNotesCounter

.skip_notes
#_8C8D: JSR ResetNMIFlags

#_8C90: LDA.b $BE
#_8C92: AND.b #$7F
#_8C94: BNE WaitOutBigMessage

#_8C96: RTS

;===================================================================================================

EdgeOrDoorTransition:
#_8C97: LDA.b #$01
#_8C99: STA.b $3A
#_8C9B: JSR NextFrameWithMaskReset

#_8C9E: DEC.b $2A

#_8CA0: LDA.b $87
#_8CA2: STA.w $07C2
#_8CA5: CMP.b #$0A ; ROOM 0A
#_8CA7: BCC .puzzle_room

#_8CA9: CMP.b #$15 ; ROOM 15
#_8CAB: BCC .not_boss_room

#_8CAD: LDA.b #BossRoomTransitions>>0
#_8CAF: STA.b $1C
#_8CB1: LDA.b #BossRoomTransitions>>8
#_8CB3: STA.b $1D
#_8CB5: BNE .start

.not_boss_room
#_8CB7: LDA.b #GauntletRoomTransitions>>0
#_8CB9: STA.b $1C
#_8CBB: LDA.b #GauntletRoomTransitions>>8
#_8CBD: STA.b $1D
#_8CBF: BNE .start

.puzzle_room
#_8CC1: LDA.b #PuzzleRoomTransitions>>0
#_8CC3: STA.b $1C
#_8CC5: LDA.b #PuzzleRoomTransitions>>8
#_8CC7: STA.b $1D

;---------------------------------------------------------------------------------------------------

.start
#_8CC9: LDY.b #$00

.search
#_8CCB: JSR GetTransitionEntity

#_8CCE: LDA.b $1E
#_8CD0: STA.b $20

#_8CD2: LDA.w $07D1
#_8CD5: CMP.b $87
#_8CD7: BNE .not_it

#_8CD9: LDA.b $29
#_8CDB: CMP.w $07D2
#_8CDE: BNE .not_it

#_8CE0: LDA.w $07D3
#_8CE3: SEC
#_8CE4: SBC.b $2A
#_8CE6: CMP.b #$04
#_8CE8: BCC .found

.not_it
#_8CEA: INY
#_8CEB: INY
#_8CEC: INY
#_8CED: INY
#_8CEE: BNE .search

#_8CF0: LDA.b $29
#_8CF2: STA.b $8C

#_8CF4: LDA.b $2A
#_8CF6: STA.b $8D

#_8CF8: INC.b $3A

#_8CFA: JMP .going_shopping

;---------------------------------------------------------------------------------------------------

.found
#_8CFD: INY
#_8CFE: INY

#_8CFF: JSR GetTransitionEntity

#_8D02: LDA.b $1E
#_8D04: STA.b $21

#_8D06: LDA.w $07D1
#_8D09: STA.b $87
#_8D0B: STA.w $07C1

#_8D0E: LDA.w $07D2
#_8D11: STA.b $8C
#_8D13: STA.b $29

#_8D15: LDA.w $07D3
#_8D18: STA.b $8D
#_8D1A: STA.b $2A

#_8D1C: LDA.b $20
#_8D1E: BNE .going_shopping

#_8D20: LDA.b $21
#_8D22: BEQ .return_to_parent

#_8D24: JSR EnterBossRoom

#_8D27: JSR NextFrameWithMaskReset

#_8D2A: LDA.b $B4
#_8D2C: CMP.b #$02 ; BOSS 02
#_8D2E: BEQ .leaving_boss_fight

#_8D30: CMP.b #$06 ; BOSS 06
#_8D32: BNE .not_leaving_boss_fight

.leaving_boss_fight
#_8D34: LDA.b #$20 ; flags going to another subroom (a shop)
#_8D36: STA.b $1F

.not_leaving_boss_fight
#_8D38: JSR PrepBossExit

#_8D3B: LDA.b $1F
#_8D3D: BEQ .return_to_parent

.going_shopping
#_8D3F: JSR MilonShopping
#_8D42: JSR NextFrameWithMaskReset

.return_to_parent
#_8D45: LDA.b $87
#_8D47: BEQ EnterNewRoom

#_8D49: JMP LoadNewArea

;===================================================================================================

EnterNewRoom:
#_8D4C: LDA.b #$00
#_8D4E: STA.b $8A

#_8D50: DEC.b $8D

#_8D52: LDA.w $07C2
#_8D55: CMP.b #$0E ; ROOM 0E
#_8D57: BEQ .well_entry

#_8D59: LDA.b #$01
#_8D5B: STA.b $95

.well_entry
#_8D5D: JMP LoadNewAreaFresh

;===================================================================================================
; See: PuzzleRoomTransitions
;===================================================================================================
GetTransitionEntity:
#_8D60: LDA.b #$00
#_8D62: STA.w $07D1

#_8D65: LDA.b ($1C),Y
#_8D67: AND.b #$20
#_8D69: STA.b $1E

#_8D6B: LDA.b ($1C),Y
#_8D6D: AND.b #$1F
#_8D6F: STA.w $07D2

#_8D72: INY

#_8D73: LDA.b ($1C),Y
#_8D75: AND.b #$1F
#_8D77: STA.w $07D3

#_8D7A: LDA.b ($1C),Y

#_8D7C: LDX.b #$03
#_8D7E: JSR .rotate

#_8D81: DEY

#_8D82: LDA.b ($1C),Y

#_8D84: LDX.b #$02

;---------------------------------------------------------------------------------------------------

.rotate
#_8D86: ROL A
#_8D87: ROL.w $07D1

#_8D8A: DEX
#_8D8B: BNE .rotate

#_8D8D: RTS

;===================================================================================================
; Handles true coordinates and screen coordinates.
;===================================================================================================
MoveMilonToXY:
#_8D8E: LDA.b $8D
#_8D90: SEC
#_8D91: SBC.b #$07
#_8D93: BCS .keep_y

#_8D95: LDA.b #$00

.keep_y
#_8D97: CMP.b #$10
#_8D99: BCC .no_clamp_y

#_8D9B: LDA.b #$0F

.no_clamp_y
#_8D9D: STA.b $28
#_8D9F: STA.b $16

#_8DA1: LDA.b #$00
#_8DA3: STA.b $4E

#_8DA5: LDA.b $8D
#_8DA7: ASL A
#_8DA8: ROL.b $4E
#_8DAA: ASL A
#_8DAB: ROL.b $4E
#_8DAD: ASL A
#_8DAE: ROL.b $4E
#_8DB0: ASL A
#_8DB1: ROL.b $4E
#_8DB3: STA.b $4D

#_8DB5: CLC
#_8DB6: ADC.b #$08
#_8DB8: STA.b $4D
#_8DBA: BCC .no_overflow_y

#_8DBC: INC.b $4E

.no_overflow_y
#_8DBE: LDA.b $16
#_8DC0: ASL A
#_8DC1: ASL A
#_8DC2: ASL A
#_8DC3: ASL A
#_8DC4: STA.b $1C

#_8DC6: CMP.b #$F0
#_8DC8: BNE .no_reset_y

#_8DCA: LDA.b #$00

.no_reset_y
#_8DCC: STA.b $07
#_8DCE: STA.b $14

;---------------------------------------------------------------------------------------------------

#_8DD0: LDA.b $4D
#_8DD2: SEC
#_8DD3: SBC.b $1C
#_8DD5: STA.b $3F

#_8DD7: LDA.b $8C
#_8DD9: SEC
#_8DDA: SBC.b #$07
#_8DDC: BCS .keep_x

#_8DDE: LDA.b #$00

.keep_x
#_8DE0: CMP.b #$11
#_8DE2: BCC .no_clamp_x

#_8DE4: LDA.b #$10

.no_clamp_x
#_8DE6: STA.b $17
#_8DE8: STA.b $1C

#_8DEA: LDA.b #$00
#_8DEC: STA.b $4C

#_8DEE: LDA.b $8C
#_8DF0: ASL A
#_8DF1: ROL.b $4C
#_8DF3: ASL A
#_8DF4: ROL.b $4C
#_8DF6: ASL A
#_8DF7: ROL.b $4C
#_8DF9: ASL A
#_8DFA: ROL.b $4C
#_8DFC: STA.b $4B

#_8DFE: LDA.b $17
#_8E00: ASL A
#_8E01: ASL A
#_8E02: ASL A
#_8E03: ASL A
#_8E04: STA.b $06
#_8E06: STA.b $1D
#_8E08: BCC .left_side

.right_side
#_8E0A: LDA.b $00
#_8E0C: ORA.b #$01
#_8E0E: STA.b $00
#_8E10: BNE .set_x

.left_side
#_8E12: LDA.b $00 ; change nametable location
#_8E14: AND.b #$FE
#_8E16: STA.b $00

.set_x
#_8E18: LDA.b $4B
#_8E1A: SEC
#_8E1B: SBC.b $1D
#_8E1D: STA.b $3E

#_8E1F: RTS

;===================================================================================================

ClampMilonTilemapX:
#_8E20: LDA.b $8C
#_8E22: BEQ .positive

#_8E24: CMP.b #$1F
#_8E26: BEQ .negative

#_8E28: RTS

.positive
#_8E29: LDA.b #$10
#_8E2B: BNE .set

.negative
#_8E2D: LDA.b #$E0

.set
#_8E2F: STA.b $4B
#_8E31: STA.b $3E

#_8E33: RTS

;===================================================================================================

LoadTheOverworld:
#_8E34: LDA.b $29
#_8E36: PHA
#_8E37: LDA.b $2A
#_8E39: PHA

#_8E3A: LDA.b $4F
#_8E3C: BEQ .not_from_death

#_8E3E: LDA.b #$00 ; MESSAGE 00
#_8E40: JSR DisplayBigMessage

#_8E43: LDA.b #$01 ; SONG 01
#_8E45: STA.b $BE

#_8E47: JSR WaitOutBigMessage
#_8E4A: JSR NextFrameWithMaskReset

.not_from_death
#_8E4D: JSR ClearSpritesAndBG
#_8E50: JSR ResetForNewArea

#_8E53: LDA.b #$01
#_8E55: STA.b $3A
#_8E57: JSR MoveMilonToXY

#_8E5A: JSR AdjustOverworldPalette
#_8E5D: JSR LoadAllSprites
#_8E60: JSR DrawOverworldTilemap

#_8E63: PLA
#_8E64: STA.b $2A
#_8E66: PLA
#_8E67: STA.b $29

#_8E69: LDA.b #$00
#_8E6B: STA.b $3A
#_8E6D: STA.b $52
#_8E6F: STA.b $94 ; GFXBANK 00
#_8E71: STA.b $89
#_8E73: STA.w $07BF

#_8E76: LDA.b #$01
#_8E78: STA.b $8A
#_8E7A: JSR NextFrameWithBGandOAM
#_8E7D: JSR EnableSpriteDraw

#_8E80: LDA.b $95
#_8E82: BEQ HandleOverworld

#_8E84: JMP ExitingCastle

;===================================================================================================

HandleOverworld:
#_8E87: LDA.b #$02 ; SONG 02
#_8E89: STA.b $BE

;---------------------------------------------------------------------------------------------------

.next_frame
#_8E8B: JSR HandlePausing
#_8E8E: JSR WaitForNMIthenClearOAM

#_8E91: JSR AdjustOverworldPalette

#_8E94: JSR DrawMilon
#_8E97: JSR DrawBeeShield
#_8E9A: JSR DrawEntireHUD

#_8E9D: JSR HandleSmokePuffs

#_8EA0: JSR HandleMilonOverworld

#_8EA3: LDA.b $4F
#_8EA5: BEQ .not_dying

#_8EA7: JMP AnimateDeath

.not_dying
#_8EAA: PHP

#_8EAB: JSR HandleAllSprites

#_8EAE: PLP
#_8EAF: JSR ResetNMIFlags
#_8EB2: BCS .opened_door

#_8EB4: JSR TestWellEntry
#_8EB7: BCC .next_frame

;---------------------------------------------------------------------------------------------------

#_8EB9: LDA.b $3F
#_8EBB: CLC
#_8EBC: ADC.b #$03
#_8EBE: STA.b $3F

#_8EC0: LDX.b #$07
#_8EC2: STX.b $3C

.next_frame_b
#_8EC4: JSR WaitForNMIthenClearOAM

#_8EC7: LDX.b $3C

#_8EC9: JSR DrawMilon_preset_palette
#_8ECC: JSR DrawEntireHUD
#_8ECF: JSR HandleAllSprites

#_8ED2: LDA.b $8E
#_8ED4: AND.b #$03
#_8ED6: BNE .dont_animate

#_8ED8: INC.b $3C

#_8EDA: LDA.b $3C
#_8EDC: CMP.b #$0B
#_8EDE: BEQ .finished

.dont_animate
#_8EE0: JSR ResetNMIFlags
#_8EE3: BEQ .next_frame_b

;---------------------------------------------------------------------------------------------------

.finished
#_8EE5: JSR ResetNMIFlags

#_8EE8: LDA.b #$1D
#_8EEA: STA.b $29

#_8EEC: LDA.b #$1B
#_8EEE: STA.b $2A

#_8EF0: JMP FindCastleEntrance

;---------------------------------------------------------------------------------------------------

.opened_door
#_8EF3: STA.b $8E
#_8EF5: STA.b $53

#_8EF7: LDA.b #$08 ; SONG 08
#_8EF9: STA.b $BE

#_8EFB: LDA.b $2B
#_8EFD: STA.b $2D

;===================================================================================================

AnimateEnteringCastle:
#_8EFF: JSR WaitForNMIthenClearOAM

#_8F02: LDX.b #$06

#_8F04: LDA.b $8E
#_8F06: CMP.b #$28
#_8F08: BCS .dont_draw_milon

#_8F0A: JSR DrawMilon_preset_palette

.dont_draw_milon
#_8F0D: JSR DrawEntireHUD
#_8F10: JSR HandleAllSprites

#_8F13: LDA.b #(.return-1)>>8
#_8F15: PHA
#_8F16: LDA.b #(.return-1)>>0
#_8F18: PHA

#_8F19: LDA.b $8E
#_8F1B: CMP.b #$0A
#_8F1D: BEQ AnimateEntranceOpening

#_8F1F: CMP.b #$14
#_8F21: BEQ AnimateEntranceOpening

#_8F23: CMP.b #$28
#_8F25: BEQ FlipMilonPriority

#_8F27: CMP.b #$32
#_8F29: BEQ AnimateEntranceClosing

#_8F2B: CMP.b #$3C
#_8F2D: BEQ AnimateEntranceClosing

#_8F2F: RTS

;===================================================================================================

.return
#_8F30: JSR ResetNMIFlags
#_8F33: STA.w $07C2
#_8F36: STA.b $4F

#_8F38: LDA.b $8E
#_8F3A: CMP.b #$46
#_8F3C: BNE AnimateEnteringCastle

; Check for crown and cane at Kama
#_8F3E: LDA.b $29
#_8F40: STA.b $8C
#_8F42: CMP.b #$0D ; !HARDCODED Kama door coordinates
#_8F44: BNE .use_entrance

#_8F46: LDA.b $2A
#_8F48: STA.b $8D
#_8F4A: CMP.b #$08 ; !HARDCODED Kama door coordinates
#_8F4C: BNE .use_entrance

#_8F4E: LDA.b $BD
#_8F50: AND.b #$03
#_8F52: CMP.b #$03
#_8F54: BEQ .use_entrance

#_8F56: JSR NextFrameWithMaskReset
#_8F59: JMP EnterNewRoom

.use_entrance
#_8F5C: JMP FindCastleEntrance

;===================================================================================================

AnimateEntranceOpening:
#_8F5F: LDA.b $2B
#_8F61: AND.b #$40 ; OWOBJ 40
#_8F63: BEQ .on_base_tile

#_8F65: INC.b $2B
#_8F67: BNE .start_update

.on_base_tile
#_8F69: LDA.b $2D
#_8F6B: CMP.b #$1F ; OWOBJ 1F
#_8F6D: BNE .not_red_window

#_8F6F: LDA.b #$40 ; OWOBJ 40
#_8F71: BNE .set_tile

.not_red_window
#_8F73: LDA.b $2B
#_8F75: ASL A
#_8F76: ORA.b #$40

.set_tile
#_8F78: STA.b $2B
#_8F7A: BNE .start_update

;===================================================================================================

#FlipMilonPriority:
#_8F7C: LDA.b $53
#_8F7E: EOR.b #$20
#_8F80: STA.b $53

#_8F82: RTS

;===================================================================================================

#AnimateEntranceClosing:
#_8F83: LDA.b $2B
#_8F85: LSR A
#_8F86: BCS .step_back

#_8F88: AND.b #$03
#_8F8A: STA.b $2B

#_8F8C: LDA.b $2D
#_8F8E: CMP.b #$1F ; OWOBJ 1F
#_8F90: BNE .start_update

#_8F92: STA.b $2B
#_8F94: BEQ .start_update

.step_back
#_8F96: DEC.b $2B

;---------------------------------------------------------------------------------------------------

.start_update
#_8F98: JMP UpdateOverworldObjectGraphics

;===================================================================================================

ExitingCastle:
#_8F9B: JSR GetObjectType_overworld

#_8F9E: LDA.b $2B
#_8FA0: STA.b $2D

#_8FA2: LDA.b #$00
#_8FA4: STA.b $95
#_8FA6: STA.b $8E

#_8FA8: LDA.b #$20 ; low priority
#_8FAA: STA.b $53

#_8FAC: LDA.b #$09 ; SONG 09
#_8FAE: STA.b $BE

;===================================================================================================

AnimateExitingCastle:
#_8FB0: JSR WaitForNMIthenClearOAM

#_8FB3: LDX.b #$00

#_8FB5: LDA.b $8E
#_8FB7: CMP.b #$1E
#_8FB9: BCC .dont_draw_milon

#_8FBB: JSR DrawMilon_preset_palette

.dont_draw_milon
#_8FBE: JSR DrawEntireHUD

#_8FC1: LDA.b $2B
#_8FC3: PHA

#_8FC4: LDA.b $29
#_8FC6: PHA

#_8FC7: LDA.b $2A
#_8FC9: PHA

#_8FCA: JSR HandleAllSprites

#_8FCD: PLA
#_8FCE: STA.b $2A

#_8FD0: PLA
#_8FD1: STA.b $29

#_8FD3: PLA
#_8FD4: STA.b $2B

;---------------------------------------------------------------------------------------------------

#_8FD6: LDA.b #(.return-1)>>8
#_8FD8: PHA

#_8FD9: LDA.b #(.return-1)>>0
#_8FDB: PHA

#_8FDC: LDA.b $8E
#_8FDE: CMP.b #$0A
#_8FE0: BEQ .animate

#_8FE2: CMP.b #$14
#_8FE4: BEQ .animate

#_8FE6: CMP.b #$1E
#_8FE8: BEQ FlipMilonPriority

#_8FEA: CMP.b #$32
#_8FEC: BEQ AnimateEntranceClosing

#_8FEE: CMP.b #$3C
#_8FF0: BEQ AnimateEntranceClosing

#_8FF2: RTS

.animate
#_8FF3: JMP AnimateEntranceOpening

;===================================================================================================

.return
#_8FF6: JSR ResetNMIFlags
#_8FF9: STA.b $4F

#_8FFB: LDA.b $8E
#_8FFD: CMP.b #$46
#_8FFF: BNE AnimateExitingCastle

#_9001: JMP HandleOverworld

;===================================================================================================

TestWellEntry:
#_9004: LDA.b $54 ; test for being on well objects
#_9006: CMP.b #$12 ; OWOBJ 12
#_9008: BEQ .check_position

#_900A: CMP.b #$13 ; OWOBJ 13
#_900C: BEQ .check_position

.fail
#_900E: CLC

#_900F: RTS

.check_position
#_9010: LDA.b $3F
#_9012: CMP.b #$B8 ; !HARDCODED well coordinates
#_9014: BNE .fail

#_9016: LDA.b $3E
#_9018: CMP.b #$D1 ; !HARDCODED well coordinates
#_901A: BCC .fail

#_901C: CMP.b #$DF ; !HARDCODED well coordinates
#_901E: BCS .fail

#_9020: SEC

#_9021: RTS

;===================================================================================================

FindCastleEntrance:
#_9022: JSR NextFrameWithMaskReset

#_9025: LDA.b #EntranceData>>8
#_9027: STA.b $1D
#_9029: LDA.b #EntranceData>>0
#_902B: STA.b $1C

;---------------------------------------------------------------------------------------------------

#_902D: LDY.b #$00

.next
#_902F: LDA.b ($1C),Y
#_9031: CMP.b #$FF
#_9033: BEQ .end

#_9035: TAX

#_9036: AND.b #$20
#_9038: STA.b $1F

#_903A: TXA

#_903B: AND.b #$1F
#_903D: INY

#_903E: CMP.b $29
#_9040: BNE .no_match

#_9042: LDA.b ($1C),Y
#_9044: CMP.b $2A
#_9046: BEQ .match

.no_match
#_9048: INY
#_9049: INY
#_904A: INY
#_904B: BNE .next

;---------------------------------------------------------------------------------------------------

.end
#_904D: LDA.b $29
#_904F: STA.b $8C

#_9051: LDA.b $2A
#_9053: STA.b $8D

#_9055: INC.b $3A

#_9057: JSR NextFrameWithMaskReset

#_905A: JMP ExitInPlace

;---------------------------------------------------------------------------------------------------
; Were there supposed to be shortcuts for 100%???
; TODO needs more analysis and testing
;---------------------------------------------------------------------------------------------------
.match
#_905D: LDA.b $29
#_905F: LDX.b $2A

#_9061: CMP.b #$11
#_9063: BNE .not_seemingly_unused_shortcut

#_9065: CPX.b #$17
#_9067: BNE .not_seemingly_unused_shortcut

#_9069: JSR AllItemsCheck
#_906C: BEQ .not_seemingly_unused_shortcut

#_906E: LDY.b #SpecialExits-EntranceData+0
#_9070: BNE ExitIntoArea

;---------------------------------------------------------------------------------------------------

.not_seemingly_unused_shortcut
#_9072: LDA.b $29
#_9074: CMP.b #$05
#_9076: BNE .not_left_shrine

#_9078: CPX.b #$10
#_907A: BNE .not_left_shrine

#_907C: JSR AllItemsCheck
#_907F: BEQ .not_left_shrine

#_9081: LDY.b #SpecialExits-EntranceData+2
#_9083: BNE ExitIntoArea

;---------------------------------------------------------------------------------------------------

.not_left_shrine
#_9085: LDA.b $29
#_9087: CMP.b #$1B
#_9089: BNE .not_right_shrine

#_908B: CPX.b #$10
#_908D: BNE .not_right_shrine

#_908F: JSR AllItemsCheck
#_9092: BEQ .not_right_shrine

#_9094: LDA.b $BD ; check crown or cane
#_9096: BEQ .not_right_shrine

#_9098: LDY.b #SpecialExits-EntranceData+4
#_909A: BNE ExitIntoArea

;---------------------------------------------------------------------------------------------------

.not_right_shrine
#_909C: LDA.b $29
#_909E: CMP.b #$12
#_90A0: BNE .use_found_room

#_90A2: CPX.b #$04
#_90A4: BNE .use_found_room

#_90A6: LDA.b $B6 ; Check crystal count at Maharito
#_90A8: CMP.b #$06
#_90AA: BCC .use_found_room

#_90AC: LDY.b #SpecialExits-EntranceData+6
#_90AE: BNE ExitIntoArea

.use_found_room
#_90B0: INY

;===================================================================================================

ExitIntoArea:
#_90B1: JSR GetTransitionEntity

#_90B4: LDA.b $1F
#_90B6: BEQ .not_shopping

#_90B8: JSR MilonShopping
#_90BB: JSR NextFrameWithMaskReset

#_90BE: JMP .load_room

.not_shopping
#_90C1: LDA.b $1E
#_90C3: BEQ .load_room

#_90C5: JSR EnterBossRoom
#_90C8: JSR NextFrameWithMaskReset
#_90CB: JSR PrepBossExit

;---------------------------------------------------------------------------------------------------

.load_room
#_90CE: LDA.w $07D1
#_90D1: STA.b $87

#_90D3: LDY.b #$01 ; GFXBANK 01
#_90D5: CMP.b #$08 ; ROOM 08
#_90D7: BCC .puzzle_room

#_90D9: INY ; GFXBANK 02

.puzzle_room
#_90DA: STY.b $94

#_90DC: LDA.w $07D2
#_90DF: STA.b $29
#_90E1: STA.b $8C

#_90E3: LDA.w $07D3
#_90E6: STA.b $2A
#_90E8: STA.b $8D

#_90EA: LDA.b $87 ; ROOM 00
#_90EC: BNE .going_inside

;===================================================================================================

#ExitInPlace:
#_90EE: DEC.b $8D

#_90F0: LDA.b #$01
#_90F2: STA.b $95

#_90F4: JMP LoadNewArea

;---------------------------------------------------------------------------------------------------

.going_inside
#_90F7: LDA.b $9B ; Remove magazine upgrade
#_90F9: AND.b #$FC
#_90FB: STA.b $9B

#_90FD: JMP LoadNewAreaFresh

;===================================================================================================

PrepBossExit:
#_9100: LDA.b $23
#_9102: BEQ ClearBossID

#_9104: LDA.b $B4
#_9106: ASL A
#_9107: CLC
#_9108: ADC.b #BossExits-EntranceData-2
#_910A: TAY

#_910B: JSR ClearBossID

; Why didn't you just use the BossExits label for a pointer???
#_910E: LDA.b #EntranceData>>0
#_9110: STA.b $1C
#_9112: LDA.b #EntranceData>>8
#_9114: STA.b $1D

#_9116: LDA.b #$00
#_9118: STA.b $1F

#_911A: JMP ExitIntoArea

;===================================================================================================

ClearBossID:
#_911D: LDA.b #$00
#_911F: STA.b $B4

#_9121: RTS

;===================================================================================================

AllItemsCheck:
#_9122: LDA.b #$01
#_9124: LDX.b #$0D

.check_items
#_9126: AND.w $079A,X

#_9129: DEX
#_912A: BPL .check_items

#_912C: AND.w $07A8 ; canteen

#_912F: RTS

;===================================================================================================

BalloonEscape:
#_9130: LDA.b #$00
#_9132: STA.b $3A
#_9134: STA.b $9A

#_9136: JSR SpawnCutsceneBubbles

#_9139: LDX.b #$F8

#_913B: LDA.b #$0C ; SONG 0C
#_913D: STA.b $BE

;---------------------------------------------------------------------------------------------------

.next_frame
#_913F: TXA
#_9140: PHA

#_9141: JSR WaitForNMIthenClearOAM
#_9144: JSR DrawMilon
#_9147: JSR HandleCutsceneBubbles

#_914A: LDA.b #$00
#_914C: STA.b $3A

#_914E: PLA
#_914F: TAX

#_9150: DEX
#_9151: BNE .next_frame

;---------------------------------------------------------------------------------------------------

.next_frame_b
#_9153: JSR WaitForNMIthenClearOAM
#_9156: JSR DrawMilon
#_9159: JSR DrawGiganticBubble

#_915C: LDA.b #$00
#_915E: STA.b $3A

#_9160: DEC.b $3F
#_9162: BNE .next_frame_b

;---------------------------------------------------------------------------------------------------

#_9164: INC.b $3A

#_9166: JSR NextFrameWithMaskReset

#_9169: LDA.b #$00
#_916B: STA.b $87 ; ROOM 00
#_916D: STA.b $94 ; GFXBANK 00
#_916F: STA.b $95

#_9171: LDA.b #$1D
#_9173: STA.b $29
#_9175: STA.b $8C

#_9177: LDX.b #$1B
#_9179: STX.b $2A

#_917B: DEX
#_917C: STX.b $8D

#_917E: JMP LoadNewArea

;===================================================================================================

WaitForNMIthenClearOAM:
#_9181: LDA.b $39
#_9183: BEQ WaitForNMIthenClearOAM

#_9185: LDA.b #$00
#_9187: STA.b $39

#_9189: STA.b $A8
#_918B: STA.b $A7

#_918D: LDA.b $31
#_918F: EOR.b #$C0
#_9191: STA.b $31
#_9193: STA.b $30

#_9195: LDA.b #$01
#_9197: STA.b $3A

#_9199: INC.b $8E

;===================================================================================================

ClearOAM:
#_919B: LDA.b #$F8
#_919D: LDY.b #$00

.next
#_919F: STA.w $0300,Y

#_91A2: INY
#_91A3: INY
#_91A4: INY
#_91A5: INY
#_91A6: BNE .next

#_91A8: RTS

;===================================================================================================

HandlePausing:
#_91A9: LDA.b $08
#_91AB: AND.b #$10
#_91AD: BNE .pressed_start

#_91AF: RTS

.pressed_start
#_91B0: LDA.b #$01
#_91B2: STA.b $BF

.wait_for_release
#_91B4: JSR WaitForNMIThenDeflag

#_91B7: LDA.b $08
#_91B9: AND.b #$10
#_91BB: BNE .wait_for_release

.wait_for_press
#_91BD: JSR WaitForNMIThenDeflag

#_91C0: LDA.b $08
#_91C2: AND.b #$10
#_91C4: BEQ .wait_for_press

.wait_for_unpress
#_91C6: JSR WaitForNMIThenDeflag

#_91C9: LDA.b $08
#_91CB: AND.b #$10
#_91CD: BNE .wait_for_unpress

#_91CF: LDA.b #$00
#_91D1: STA.b $BF

#_91D3: RTS

;===================================================================================================
; D-Flag!
;===================================================================================================
WaitForNMIThenDeflag:
#_91D4: LDA.b $39
#_91D6: BEQ WaitForNMIThenDeflag

;===================================================================================================

ResetNMIFlags:
#_91D8: LDA.b #$00
#_91DA: STA.b $39
#_91DC: STA.b $3A

#_91DE: RTS

;===================================================================================================

CycleRoomPalettes:
#_91DF: LDA.b $87
#_91E1: CMP.b #$0F ; ROOM 0F
#_91E3: BNE .not_fire_room

#_91E5: INC.b $96

#_91E7: LDA.b $96
#_91E9: AND.b #$03
#_91EB: BNE .exit

#_91ED: LDA.b $96
#_91EF: AND.b #$0C
#_91F1: TAX

#_91F2: LDY.b #$08
#_91F4: JSR .copy_one_palette

#_91F7: LDA.b $96
#_91F9: CLC
#_91FA: ADC.b #$08
#_91FC: AND.b #$0C
#_91FE: TAX

#_91FF: LDY.b #$0C
#_9201: JSR .copy_one_palette

#_9204: LDA.b #$01
#_9206: STA.b $97

#_9208: RTS

;---------------------------------------------------------------------------------------------------

.copy_one_palette
#_9209: LDA.b #$04
#_920B: STA.b $1C

.next_hell
#_920D: LDA.w WellHellPalette,X
#_9210: STA.w $05E0,Y

#_9213: INX
#_9214: INY

#_9215: DEC.b $1C
#_9217: BNE .next_hell

.exit
#_9219: RTS

;---------------------------------------------------------------------------------------------------

.not_fire_room
#_921A: CMP.b #$12 ; ROOM 12
#_921C: BNE .exit

#_921E: LDA.b $8E
#_9220: AND.b #$01
#_9222: ASL A
#_9223: ASL A
#_9224: CLC
#_9225: ADC.b #$08
#_9227: TAY

#_9228: INC.b $96
#_922A: LDX.b $96

#_922C: LDA.w RESET,X
#_922F: AND.b #$07
#_9231: ASL A
#_9232: ASL A
#_9233: TAX

#_9234: LDA.b #$04
#_9236: STA.b $1C

.next_lightning
#_9238: LDA.w LightningPalette,X
#_923B: STA.w $05E0,Y

#_923E: INX

#_923F: INY
#_9240: DEC.b $1C
#_9242: BNE .next_lightning

#_9244: LDA.b #$01
#_9246: STA.b $97

#_9248: RTS

;===================================================================================================
; PALETTE DATA
;===================================================================================================
LightningPalette:
#_9249: db $0F, $31, $31, $0F
#_924D: db $0F, $35, $35, $0F
#_9251: db $0F, $37, $37, $0F
#_9255: db $0F, $0F, $0F, $0F
#_9259: db $0F, $0F, $31, $31
#_925D: db $0F, $0F, $35, $35
#_9261: db $0F, $0F, $37, $37
#_9265: db $0F, $0F, $0F, $0F

;===================================================================================================
; PALETTE DATA
;===================================================================================================
WellHellPalette:
#_9269: db $06, $04, $14, $25
#_926D: db $06, $04, $25, $36
#_9271: db $06, $14, $25, $37
#_9275: db $06, $05, $14, $25

;===================================================================================================

HandleLightningFlash:
#_9279: LDA.b $98
#_927B: AND.b #$04
#_927D: BNE .unflash

#_927F: LDA.b $98
#_9281: AND.b #$02
#_9283: BEQ .exit

#_9285: LDY.b $8E
#_9287: LDA.w RESET,Y
#_928A: AND.b #$0F
#_928C: CMP.b #$01
#_928E: BEQ .flash

.exit
#_9290: RTS

;---------------------------------------------------------------------------------------------------

.flash
#_9291: LDA.b $98
#_9293: AND.b #$01
#_9295: ORA.b #$04
#_9297: STA.b $98
#_9299: BNE HandleAndFlagOverworldPalette

.unflash
#_929B: LDA.b $98
#_929D: AND.b #$01
#_929F: ORA.b #$02
#_92A1: STA.b $98
#_92A3: BNE HandleAndFlagOverworldPalette

;===================================================================================================

AdjustOverworldPalette:
#_92A5: JSR HandleLightningFlash
#_92A8: JSR CheckCastleHalf

#_92AB: CPX.b $96 ; test if the same already
#_92AD: BEQ .exit

#_92AF: STX.b $96

#_92B1: DEX
#_92B2: STX.b $1C

#_92B4: LDA.b $98
#_92B6: AND.b #$FE
#_92B8: ORA.b $1C
#_92BA: STA.b $98

;===================================================================================================

#HandleAndFlagOverworldPalette:
#_92BC: JSR HandleOverworldPalette

#_92BF: LDA.b #$01
#_92C1: STA.b $97

.exit
#_92C3: RTS

;===================================================================================================

CheckCastleHalf:
#_92C4: LDA.b $16

#_92C6: LDX.b #$01

#_92C8: CMP.b #$08
#_92CA: BCS EXIT_92CD

#_92CC: INX

;---------------------------------------------------------------------------------------------------

#EXIT_92CD:
#_92CD: RTS

;===================================================================================================

LoadDoorLocations:
#_92CE: LDA.b #$00
#_92D0: STA.b $9F
#_92D2: STA.b $A0

#_92D4: LDA.b $87
#_92D6: CMP.b #$09 ; ROOM 09
#_92D8: BCS .gauntlet_room

#_92DA: ASL A
#_92DB: TAX

#_92DC: LDA.w DoorALocations-2,X
#_92DF: STA.w $07D7
#_92E2: LDA.w DoorALocations-1,X
#_92E5: STA.w $07D9

#_92E8: LDA.w DoorBLocations-2,X
#_92EB: STA.w $07D8
#_92EE: LDA.w DoorBLocations-1,X
#_92F1: STA.w $07DA

#_92F4: JSR CheckIfKeyIsHere
#_92F7: BEQ EXIT_92CD

#_92F9: INC.b $9F

#_92FB: LDA.b #$02
#_92FD: STA.w $07BF

;---------------------------------------------------------------------------------------------------

#_9300: LDA.w $07D7
#_9303: STA.b $29

#_9305: LDA.w $07D9
#_9308: STA.b $2A

#_930A: LDA.b #$08 ; OBJECT 08
#_930C: STA.b $2B

#_930E: JSR DrawObjectIfOnScreen
#_9311: JSR ChangeObjectType

#_9314: INC.b $2A
#_9316: INC.b $2B ; OBJECT 09

#_9318: JSR DrawObjectIfOnScreen
#_931B: JMP ChangeObjectType

;---------------------------------------------------------------------------------------------------

.gauntlet_room
#_931E: LDX.b #$03
#_9320: LDA.b #$63

.clear_next
#_9322: STA.w $07D7,X

#_9325: DEX
#_9326: BPL .clear_next

;---------------------------------------------------------------------------------------------------

#EXIT_9328:
#_9328: RTS

;===================================================================================================

DrawObjectIfOnScreen:
#_9329: LDA.b $2A
#_932B: CMP.b $16
#_932D: BCC EXIT_9328

#_932F: LDA.b $16
#_9331: CLC
#_9332: ADC.b #$0E
#_9334: CMP.b $2A
#_9336: BCC EXIT_9328

#_9338: JMP RedrawObject

;===================================================================================================

PlayBonusGame:
#_933B: LDA.b $29
#_933D: PHA

#_933E: LDA.b $2A
#_9340: PHA

#_9341: LDA.w $079B ; save super shoes
#_9344: PHA

#_9345: LDA.b #$02 ; MESSAGE 02
#_9347: JSR DisplayBigMessage

#_934A: LDA.b #$0B ; SONG 0B
#_934C: STA.b $BE

#_934E: JSR WaitOutBigMessage

#_9351: JSR NextFrameWithMaskReset
#_9354: JSR ClearTilemapWith2F

#_9357: LDX.b #$00
#_9359: STX.w $07FF
#_935C: STX.b $94 ; GFXBANK 00

#_935E: JSR ResetBGScroll

#_9361: INX
#_9362: STX.w $07CF

#_9365: JSR NextFrame

;---------------------------------------------------------------------------------------------------

#_9368: LDA.b #$00
#_936A: JSR SetPPUCTRL

#_936D: LDX.b #$1F

.next_bonus_color
#_936F: LDA.w BonusGamePalette,X
#_9372: STA.w $05E0,X

#_9375: DEX
#_9376: BPL .next_bonus_color

#_9378: JSR ReloadPalettesWithWait

;---------------------------------------------------------------------------------------------------

#_937B: LDA.b #$23 ; VRAM $23C0
#_937D: LDX.b #$C0
#_937F: JSR SetPPUADDRSafely

#_9382: LDX.b #$40
#_9384: LDA.b #$FF

.next_tile_fill
#_9386: STA.w PPUDATA

#_9389: DEX
#_938A: BNE .next_tile_fill

;---------------------------------------------------------------------------------------------------

#_938C: LDX.b #$00

.next_performer
#_938E: LDA.w PerformerPosition,X
#_9391: BEQ .band_drawn

#_9393: STA.b $29

#_9395: INX

#_9396: LDA.w PerformerPosition,X
#_9399: STA.b $2A

#_939B: INX
#_939C: STX.b $76

.reroll
#_939E: JSR Random
#_93A1: AND.b #$03
#_93A3: CMP.b #$03
#_93A5: BEQ .reroll

; draw pedestal
#_93A7: STA.b $2B
#_93A9: JSR DrawOrchestralObject

#_93AC: INC.b $29
#_93AE: JSR DrawOrchestralObject

; draw performer
#_93B1: DEC.b $2A
#_93B3: DEC.b $2A

#_93B5: LDA.b #$04
#_93B7: STA.b $2B
#_93B9: JSR DrawOrchestralObject

#_93BC: DEC.b $29
#_93BE: DEC.b $2B
#_93C0: JSR DrawOrchestralObject

#_93C3: INC.b $2A

#_93C5: LDA.b #$05
#_93C7: STA.b $2B
#_93C9: JSR DrawOrchestralObject

#_93CC: INC.b $29
#_93CE: INC.b $2B
#_93D0: JSR DrawOrchestralObject

#_93D3: LDX.b $76
#_93D5: BNE .next_performer

;---------------------------------------------------------------------------------------------------

.band_drawn
#_93D7: LDA.b #$0D
#_93D9: STA.b $2A

; draw staff lines
#_93DB: LDA.b #$07
#_93DD: STA.b $2B

#_93DF: JSR DrawLineOfOrchestralObjects

#_93E2: INC.b $2B
#_93E4: INC.b $2A

#_93E6: JSR DrawLineOfOrchestralObjects

; draw clef
#_93E9: LDA.b #$01
#_93EB: STA.b $29

#_93ED: LDA.b #$0C
#_93EF: STA.b $2A

#_93F1: LDA.b #$09
#_93F3: STA.b $2B

#_93F5: JSR DrawOrchestralObject

#_93F8: INC.b $2A
#_93FA: INC.b $2B

#_93FC: JSR DrawOrchestralObject

#_93FF: INC.b $2A
#_9401: INC.b $2B

#_9403: JSR DrawOrchestralObject

;---------------------------------------------------------------------------------------------------

#_9406: JSR ResetSpritesAndPits

#_9409: LDA.b $C0
#_940B: STA.b $1C

#_940D: LDA.b #$00
#_940F: STA.b $1E
#_9411: STA.b $20
#_9413: TAX

;---------------------------------------------------------------------------------------------------

.add_next_instrument
#_9414: ROL.b $1C
#_9416: BCC .no_more_instruments

#_9418: LDY.b $1E

#_941A: LDA.b #$22 ; SPRITE 22
#_941C: STA.w $06C0+1,Y

#_941F: INC.b $1E

#_9421: LDY.b $20
#_9423: LDA.w OrchestralProps,Y
#_9426: STA.w $0602+$0C,X

#_9429: INY
#_942A: LDA.w OrchestralProps,Y
#_942D: STA.w $0604+$0C,X

#_9430: INY
#_9431: LDA.w OrchestralProps,Y
#_9434: STA.w $0608+$0C,X

#_9437: INY
#_9438: STY.b $20

#_943A: TXA
#_943B: CLC
#_943C: ADC.b #$0C
#_943E: TAX

#_943F: BNE .add_next_instrument

;---------------------------------------------------------------------------------------------------

.no_more_instruments
#_9441: LDA.b #$78
#_9443: STA.b $3E
#_9445: STA.b $4B

#_9447: LDA.b #$B8
#_9449: STA.b $3F
#_944B: STA.b $4D

#_944D: LDA.b #$00
#_944F: STA.b $4C
#_9451: STA.b $4E

#_9453: STA.b $3C
#_9455: STA.b $3D
#_9457: STA.b $3A

#_9459: STA.b $78
#_945B: STA.w $079B ; temporarily disable super shoes

;---------------------------------------------------------------------------------------------------

#_945E: LDX.b #$0D ; SONG 0D

#_9460: LDA.b $C0
#_9462: ROL A
#_9463: ROL A
#_9464: ROL A
#_9465: BCC .set_song

#_9467: INX ; SONG 0E

#_9468: ROL A
#_9469: ROL A
#_946A: BCC .set_song

#_946C: INX ; SONG 0F
#_946D: ROL A
#_946E: ROL A
#_946F: BCC .set_song

#_9471: INX ; SONG 10

.set_song
#_9472: STX.b $BE

#_9474: JSR NextFrameWithBGandOAM
#_9477: JSR EnableSpriteDraw
#_947A: JSR NextFrameWithUpdates

;---------------------------------------------------------------------------------------------------

.next_frame
#_947D: JSR HandlePausing
#_9480: JSR WaitForNMIthenClearOAM
#_9483: JSR HandleAllSprites
#_9486: JSR HandleNoteSpawn

#_9489: JSR DrawMilon
#_948C: JSR SmallRoomMilon
#_948F: JSR AnimateOrchestra

#_9492: LDX.b #$14
#_9494: JSR PositionHUDSprite

#_9497: LDA.b #$03
#_9499: STA.b $37

#_949B: LDA.b #$19
#_949D: JSR AddObjectToBufferSafely
#_94A0: JSR AdvanceObjectX

#_94A3: LDX.b #$03
#_94A5: JSR DrawCurrencySprites
#_94A8: JSR ResetNMIFlags

#_94AB: LDA.b $BE
#_94AD: AND.b #$7F
#_94AF: BNE .next_frame

;---------------------------------------------------------------------------------------------------

#_94B1: LDA.b #$03 ; MESSAGE 03
#_94B3: JSR DisplayBigMessage

#_94B6: JSR DrawNotesCounter
#_94B9: JSR EnableSpriteDraw

#_94BC: LDA.b #$0B ; SONG 0B
#_94BE: STA.b $BE

#_94C0: JSR WaitOutBigMessage

#_94C3: LDA.b #$00
#_94C5: STA.b $78

;===================================================================================================

CashForNotes:
#_94C7: JSR WaitForNMIthenClearOAM
#_94CA: JSR DrawNotesCounter
#_94CD: JSR ResetNMIFlags

#_94D0: JSR CheckForAnyNotes
#_94D3: BEQ .out_of_notes

#_94D5: JSR TakeANote

#_94D8: LDY.b #$00
#_94DA: STY.w $07CF

#_94DD: LDA.b $22 ; get increment (0 / 1) => (1 / 2)
#_94DF: SEC
#_94E0: ADC.b $78
#_94E2: CMP.b #$04
#_94E4: BCC .dont_reset_count

#_94E6: LDA.b #$00

.dont_reset_count
#_94E8: STA.b $78
#_94EA: BCC .dont_give_cash

#_94EC: LDA.b #$01
#_94EE: JSR AddCurrency

.dont_give_cash
#_94F1: INC.w $07CF

#_94F4: JSR CheckForAnyNotes
#_94F7: BNE CashForNotes

#_94F9: LDA.b #$00
#_94FB: STA.b $8E
#_94FD: BEQ CashForNotes

;---------------------------------------------------------------------------------------------------

.out_of_notes
#_94FF: LDA.b $8E
#_9501: CMP.b #$B4
#_9503: BNE CashForNotes

#_9505: LDA.b #$00
#_9507: STA.w $07CF

#_950A: PLA
#_950B: STA.w $079B ; recover super shoes

#_950E: PLA
#_950F: STA.b $2A

#_9511: PLA
#_9512: STA.b $29

#_9514: JMP NextFrameWithMaskReset

;===================================================================================================

TakeANote:
#_9517: LDA.b #$16 ; SFX 16
#_9519: STA.b $E6

#_951B: LDX.b #$02

.next_digit
#_951D: DEC.b $A4,X
#_951F: BPL EXIT_9528

#_9521: LDA.b #$09
#_9523: STA.b $A4,X

#_9525: DEX
#_9526: BPL .next_digit

;---------------------------------------------------------------------------------------------------

#EXIT_9528:
#_9528: RTS

;===================================================================================================

DrawNotesCounter:
#_9529: LDX.b #$12
#_952B: JSR PositionHUDSprite

#_952E: LDA.b #$00
#_9530: STA.b $37

#_9532: LDX.b #$03
#_9534: JSR DrawCurrencySprites

#_9537: JMP DrawCashMoney

;===================================================================================================
; TODO why do euphonium and cymbals not/rarely animate?
AnimateOrchestra:
#_953A: LDA.b $8E
#_953C: AND.b #$03
#_953E: BNE EXIT_9528

.reroll
#_9540: JSR Random
#_9543: AND.b #$07
#_9545: BEQ .reroll

#_9547: ASL A
#_9548: TAX

#_9549: LDA.w PerformerPosition-2,X
#_954C: STA.b $29

#_954E: LDA.w PerformerPosition-1,X
#_9551: STA.b $2A

#_9553: DEC.b $2A

#_9555: JSR Random
#_9558: LSR A
#_9559: BCS .tap_foot

#_955B: AND.b #$01
#_955D: TAX

#_955E: LDA.w .slap,X
#_9561: BNE .draw_tile

.tap_foot
#_9563: AND.b #$01
#_9565: TAX

#_9566: INC.b $29

#_9568: LDA.w .tap,X

.draw_tile
#_956B: STA.b $2B

#_956D: JMP RedrawPerformerParts

;---------------------------------------------------------------------------------------------------

.slap
#_9570: db $05, $0C

.tap
#_9572: db $06, $0D

;===================================================================================================

HandleNoteSpawn:
#_9574: LDA.b $8E ; Notes spawn every 32 frames
#_9576: AND.b #$1F
#_9578: BNE .exit

#_957A: JSR Random
#_957D: TAY

#_957E: LDA.b #$00
#_9580: STA.b $62
#_9582: STA.b $64

#_9584: LDA.b #$E0
#_9586: STA.b $63

#_9588: TYA
#_9589: CMP.b #$D0
#_958B: BCC .note_in_bounds

#_958D: LSR A

.note_in_bounds
#_958E: CLC
#_958F: ADC.b #$10
#_9591: STA.b $61

#_9593: LDA.b #$25 ; SPRITE 25
#_9595: JSR SpawnSprite
#_9598: BCS .exit

#_959A: TYA
#_959B: AND.b #$01
#_959D: CLC
#_959E: ADC.b #$FA
#_95A0: STA.w $0608,X

;---------------------------------------------------------------------------------------------------

#_95A3: LDA.b $78
#_95A5: CMP.b #$05
#_95A7: BCS .collected_5_notes

#_95A9: TYA
#_95AA: LSR A
#_95AB: AND.b #$07
#_95AD: BNE .tied_quavers
#_95AF: BEQ .check_closeness

.collected_5_notes
#_95B1: LDA.b #$00
#_95B3: STA.b $78

#_95B5: LDA.w $07C0 ; !WEIRD vestigial variable? Only ever set to 00 or 05
#_95B8: CMP.b #$14
#_95BA: BCS .tied_quavers

#_95BC: LDA.b #$11 ; Sharp
#_95BE: BNE .set_note_value

.check_closeness
#_95C0: LDA.b $3E
#_95C2: SEC
#_95C3: SBC.b $61
#_95C5: BCC .milon_left

#_95C7: CMP.b #$10
#_95C9: BCC .tied_quavers
#_95CB: BCS .try_to_spawn_flat

.milon_left
#_95CD: CMP.b #$F0
#_95CF: BCS .tied_quavers

.try_to_spawn_flat
#_95D1: LDA.w $07C0
#_95D4: CMP.b #$01
#_95D6: BEQ .tied_quavers

#_95D8: LDA.b #$58 ; Flat
#_95DA: BNE .set_note_value

.tied_quavers
#_95DC: LDA.b #$0D

.set_note_value
#_95DE: STA.w $0601,X

.exit
#_95E1: RTS

;===================================================================================================

DrawLineOfOrchestralObjects:
#_95E2: LDA.b #$00
#_95E4: STA.b $29

.next
#_95E6: JSR DrawOrchestralObject

#_95E9: INC.b $29

#_95EB: LDA.b $29
#_95ED: CMP.b #$10
#_95EF: BNE .next

#_95F1: RTS

;===================================================================================================

DrawOrchestralObject:
#_95F2: LDA.b $29
#_95F4: ASL A
#_95F5: STA.b $2E

#_95F7: LDA.b $2A
#_95F9: ASL A
#_95FA: STA.b $2F

#_95FC: LDY.b $2B
#_95FE: LDA.w OrchestraPalettes,Y
#_9601: STA.b $12

#_9603: JSR GetVRAMofTileFromXY
#_9606: LDA.b $2B
#_9608: ASL A
#_9609: ASL A
#_960A: TAY

#_960B: LDA.b #OrchestraTiles>>0
#_960D: STA.b $1C
#_960F: LDA.b #OrchestraTiles>>8
#_9611: STA.b $1D

#_9613: JMP DrawAndFlush4x4Icon

;===================================================================================================

RedrawPerformerParts:
#_9616: LDY.b $2B

#_9618: LDA.w OrchestraPalettes,Y
#_961B: JSR QueueObjectPaletteChange

#_961E: LDA.b #OrchestraTiles>>0
#_9620: STA.b $1C
#_9622: LDA.b #OrchestraTiles>>8
#_9624: STA.b $1D

#_9626: LDA.b $2B
#_9628: ASL A
#_9629: ASL A
#_962A: TAY

#_962B: JMP RedrawObject_prepped

;===================================================================================================

ResetBGScroll:
#_962E: LDX.b #$00
#_9630: STX.b $06
#_9632: STX.b $07
#_9634: STX.b $0B
#_9636: STX.b $16

#_9638: RTS

;---------------------------------------------------------------------------------------------------

OrchestralProps:
;           x    y    t
#_9639: db $79, $45, $00 ; 00 - Drum
#_963C: db $D0, $60, $01 ; 01 - Cymbals
#_963F: db $CC, $2C, $02 ; 02 - Euphonium
#_9642: db $9E, $50, $03 ; 03 - Ocarina
#_9645: db $20, $60, $04 ; 04 - Harp
#_9648: db $62, $52, $05 ; 05 - Trumpet
#_964B: db $22, $2A, $06 ; 06 - Violin

;===================================================================================================

PerformerPosition:
#_964E: db $01, $04
#_9650: db $02, $07
#_9652: db $05, $06
#_9654: db $07, $05
#_9656: db $09, $06
#_9658: db $0C, $07
#_965A: db $0D, $04
#_965C: db $00

OrchestraTiles:
#_965D: db $8C, $8D, $9C, $9D ; 00 - Pedestal (pink)
#_9661: db $8C, $8D, $9C, $9D ; 01 - Pedestal (orange)
#_9665: db $8C, $8D, $9C, $9D ; 02 - Pedestal (blue)
#_9669: db $2F, $2F, $2F, $A8 ; 03 - Performer (head left)
#_966D: db $2F, $2F, $A9, $2F ; 04 - Performer (head right)
#_9671: db $2F, $B8, $2F, $C8 ; 05 - Performer (body left)
#_9675: db $B9, $2F, $C9, $2F ; 06 - Performer (body right)
#_9679: db $20, $20, $30, $30 ; 07 - Staff lines
#_967D: db $8E, $8E, $2F, $2F ; 08 - Staff lines
#_9681: db $2F, $2F, $2F, $8F ; 09 - Treble clef
#_9685: db $9E, $9F, $AE, $AF ; 0A - Treble clef
#_9689: db $BE, $BF, $CE, $CF ; 0B - Treble clef
#_968D: db $2F, $84, $2F, $94 ; 0C - Performer (chest slap)
#_9691: db $85, $2F, $95, $2F ; 0D - Performer (foot tap)

OrchestraPalettes:
#_9695: db $01 ; 00 - Pedestal
#_9696: db $02 ; 01 - Pedestal
#_9697: db $03 ; 02 - Pedestal
#_9698: db $00 ; 03 - Performer
#_9699: db $00 ; 04 - Performer
#_969A: db $00 ; 05 - Performer
#_969B: db $00 ; 06 - Performer
#_969C: db $03 ; 07 - Staff lines
#_969D: db $03 ; 08 - Staff lines
#_969E: db $03 ; 09 - Treble clef
#_969F: db $03 ; 0A - Treble clef
#_96A0: db $03 ; 0B - Treble clef
#_96A1: db $00 ; 0C - Performer
#_96A2: db $00 ; 0D - Performer

;===================================================================================================
; PALETTE DATA
;===================================================================================================
BonusGamePalette:
#_96A3: db $0F, $19, $15, $37
#_96A7: db $0F, $04, $25, $35
#_96AB: db $0F, $00, $26, $37
#_96AF: db $0F, $00, $21, $30
#_96B3: db $0F, $21, $15, $37
#_96B7: db $0F, $19, $27, $31
#_96BB: db $0F, $07, $16, $37
#_96BF: db $0F, $1A, $25, $30

;===================================================================================================

EndingCutscene:
#_96C3: JSR ResetNMIFlags
#_96C6: JSR WaitForNMIthenClearOAM

#_96C9: JSR DrawMilon
#_96CC: JSR DrawBeeShield
#_96CF: JSR DrawEndingSprites
#_96D2: JSR DrawEntireHUD

#_96D5: INC.b $9E
#_96D7: BEQ .flashing_over

#_96D9: LDA.b $9E
#_96DB: AND.b #$07
#_96DD: CMP.b #$04
#_96DF: BCC .white

#_96E1: LDA.b #$0F ; black
#_96E3: BNE .start

.white
#_96E5: LDA.b #$30 ; white

.start
#_96E7: LDX.b #$1C

.fill_palette
#_96E9: STA.w $05E0,X

#_96EC: DEX
#_96ED: DEX
#_96EE: DEX
#_96EF: DEX
#_96F0: BPL .fill_palette

#_96F2: INC.b $97
#_96F4: JMP EndingCutscene

;---------------------------------------------------------------------------------------------------

.flashing_over
#_96F7: INC.b $3A
#_96F9: JSR NextFrameWithMaskReset

#_96FC: JSR ClearTilemapWith2F
#_96FF: JSR ResetBGScroll

#_9702: LDA.b $00
#_9704: AND.b #$FE
#_9706: JSR SetPPUCTRL

;---------------------------------------------------------------------------------------------------
; Make the throne room by copying from the current tilemap
;---------------------------------------------------------------------------------------------------
#_9709: LDA.b #$00
#_970B: STA.b $59

#_970D: LDA.b #$02
#_970F: STA.b $75

.next_throne_row
#_9711: LDA.b #$08
#_9713: STA.b $58

#_9715: LDA.b #$00
#_9717: STA.b $76

.next_throne_object
#_9719: LDA.b $58
#_971B: STA.b $29

#_971D: LDA.b $59
#_971F: STA.b $2A

#_9721: JSR GetObjectType_indoors

#_9724: LDA.b $2B ; OBJECT 00
#_9726: BNE .no_override ; This never happens

#_9728: LDA.b #$0E ; OBJECT 0E
#_972A: STA.b $2B

.no_override
#_972C: LDA.b $76
#_972E: STA.b $29

#_9730: LDA.b $75
#_9732: STA.b $2A

#_9734: JSR DrawAndFlushReplacementObject

#_9737: INC.b $76

#_9739: INC.b $58
#_973B: LDA.b $58
#_973D: CMP.b #$18
#_973F: BCC .next_throne_object

#_9741: INC.b $75

#_9743: INC.b $59
#_9745: LDA.b $59
#_9747: CMP.b #$09
#_9749: BCC .next_throne_row

;---------------------------------------------------------------------------------------------------

#_974B: LDY.b #$00
#_974D: STY.b $3A

#_974F: JSR DrawThankedMilon
#_9752: JSR SpawnCutsceneBubbles
#_9755: JSR LoadScarySpritePalette_full

#_9758: INC.b $97

#_975A: JSR NextFrameWithBGandOAM
#_975D: JSR EnableSpriteDraw

#_9760: LDA.b #$0C ; SONG 0C
#_9762: STA.b $BE

#_9764: LDA.b #$F8
#_9766: STA.b $77

;---------------------------------------------------------------------------------------------------

.next_frame
#_9768: JSR ResetNMIFlags
#_976B: JSR WaitForNMIthenClearOAM

#_976E: JSR DrawCutsceneMilon
#_9771: JSR HandleCutsceneBubbles

#_9774: DEC.b $77
#_9776: BNE .next_frame

;---------------------------------------------------------------------------------------------------

#_9778: LDA.b #$19 ; ROOM 19
#_977A: STA.b $87

#_977C: JSR ResetSpritesAndPits

#_977F: LDY.b #$00

.load_next_sprite
#_9781: LDA.w ThroneRoomSpriteData,Y
#_9784: STA.b $1E

#_9786: AND.b #$3F
#_9788: BEQ .done_sprites

#_978A: INY
#_978B: JSR LoadOneSprite

#_978E: JMP .load_next_sprite

;---------------------------------------------------------------------------------------------------

.done_sprites
#_9791: LDA.b #$6A
#_9793: STA.w $0610

#_9796: LDA.b #$07
#_9798: STA.w $0614

#_979B: LDA.b #$98
#_979D: STA.w $061A

#_97A0: LDA.b #$08
#_97A2: STA.w $0620

#_97A5: LDA.b #$00
#_97A7: STA.b $3A
#_97A9: STA.b $9E
#_97AB: STA.b $8E

;---------------------------------------------------------------------------------------------------

.wait_for_fanfare
#_97AD: JSR WaitForNMIthenClearOAM
#_97B0: JSR DrawCutsceneMilon

#_97B3: LDA.b $9E
#_97B5: BEQ .skip_sprites

#_97B7: JSR HandleAllSprites

.skip_sprites
#_97BA: JSR DrawFlashingMilon

#_97BD: LDA.b #$00
#_97BF: STA.b $3A

#_97C1: LDA.b $BE
#_97C3: AND.b #$7F
#_97C5: BNE .wait_for_fanfare

;---------------------------------------------------------------------------------------------------

#_97C7: LDA.b $B8
#_97C9: CMP.b #$01
#_97CB: BNE .not_second_ending

#_97CD: LDA.b #$09 ; MESSAGE 09
#_97CF: JSR DisplayBigMessage

#_97D2: LDA.b #$10 ; SONG 10
#_97D4: STA.b $BE

#_97D6: JSR WaitOutBigMessage

#_97D9: LDA.b #$FF ; reset difficulty
#_97DB: STA.b $B8

.not_second_ending
#_97DD: INC.b $B8

#_97DF: LDA.b #$00
#_97E1: STA.b $9E
#_97E3: STA.b $3A

#_97E5: STA.w $07D0
#_97E8: STA.b $B6

#_97EA: JMP StartGame

;===================================================================================================

DrawCutsceneMilon:
#_97ED: LDX.b #$00
#_97EF: STX.b $43

#_97F1: INX
#_97F2: STX.b $52

#_97F4: LDA.b #$60
#_97F6: STA.b $3E

#_97F8: LDA.b #$78
#_97FA: STA.b $3F

#_97FC: LDX.b #$00
#_97FE: JMP DrawMilon_with_palette_0

;===================================================================================================

DrawFlashingMilon:
#_9801: LDA.b $9E
#_9803: BNE DrawThankedMilon

#_9805: LDA.b $8E
#_9807: CMP.b #$78
#_9809: BCS .draw_ending_text

#_980B: AND.b #$07
#_980D: CMP.b #$04
#_980F: BCS .exit

;===================================================================================================

#DrawThankedMilon:
#_9811: LDA.b #$90
#_9813: STA.b $3E

#_9815: LDA.b #$78
#_9817: STA.b $3F

#_9819: LDA.b #$02
#_981B: STA.b $53

#_981D: LDX.b #$07
#_981F: JMP DrawMilon_with_palette

;---------------------------------------------------------------------------------------------------

.draw_ending_text
#_9822: INC.b $9E

#_9824: LDA.b #$06 ; SONG 06
#_9826: STA.b $BE

#_9828: LDY.b #$00

.next_letter
#_982A: LDA.w BravelySaved,Y
#_982D: INY

#_982E: JSR AppendSingleToVRAMBuffer
#_9831: CMP.b #$FF
#_9833: BNE .next_letter

#_9835: DEC.b $19

#_9837: LDA.b #$00
#_9839: JSR AppendSingleToVRAMBuffer

#_983C: DEC.b $19

.exit
#_983E: RTS

;===================================================================================================

BravelySaved:
; "YOU BRAVELY SAVED"
#_983F: db $06 : dw $22E8 ; transfer type, VRAM address
#_9842: db $79, $5D, $6A, $2F, $49, $5F, $48, $6B
#_984A: db $4C, $5A, $79, $2F, $68, $48, $6B, $4C
#_9852: db $4B
#_9853: db $00 ; end of string

; "CASTLE GARLAND."
#_9854: db $06 : dw $2329 ; transfer type, VRAM address
#_9857: db $4A, $48, $68, $69, $5A, $4C, $2F, $4E
#_985F: db $48, $5F, $5A, $48, $5C, $4B, $7B
#_9866: db $00 ; end of string

; "THANK YOU MILON!"
#_9867: db $06 : dw $2368 ; transfer type, VRAM address
#_986A: db $69, $4F, $48, $5C, $59, $2F, $79, $5D
#_9872: db $6A, $2F, $5B, $58, $5A, $5D, $5C, $7A
#_987A: db $00 ; end of string

#_987B: db $FF ; end of data

;===================================================================================================

ThroneRoomSpriteData:
#_987C: db $E2, $29, $00 ; SPRITE 22 | xy: {090,070} | dir: 00 | misc: 00
#_987F: db $22, $4A, $00 ; SPRITE 22 | xy: {0A0,080} | dir: 00 | misc: 00
#_9882: db $00 ; end

;===================================================================================================

TrapThreshold:
#_9883: db $C0 ; overworld
#_9884: db $A0 ; inside

;===================================================================================================

TileSolidityThreshold:
#_9885: db $C0 ; overworld
#_9886: db $80 ; inside

;===================================================================================================

; Counter value where Milon stops rising during a jump
JumpDurations:
#_9887: db $05 ; Normal jump
#_9888: db $07 ; Spring launch
#_9889: db $04 ; Overworld jump
#_988A: db $09 ; Super shoes jump
#_988B: db $0E ; Super shoes spring launch

; Counter value where Milon stops accelerating downwards during a jump
TerminalVelocity:
#_988C: db $0A ; Normal jump
#_988D: db $0E ; Spring launch
#_988E: db $08 ; Overworld jump
#_988F: db $12 ; Super shoes jump
#_9890: db $1B ; Super shoes spring launch

; Number of frames A input can be used to extend jump height
JumpExtendDurations:
#_9891: db $0F ; Normal jump
#_9892: db $15 ; Spring launch
#_9893: db $0C ; Overworld jump
#_9894: db $1B ; Super shoes jump
#_9895: db $2A ; Super shoes spring launch

;===================================================================================================

JumpVelocityIndexer:
#_9896: db $00 ; JumpVelocityNormal
#_9897: db $0A ; JumpVelocitySuperShoes

SpringVelocityIndexer:
#_9898: db $00 ; JumpVelocitySpringLaunch
#_9899: db $0E ; JumpVelocitySuperShoesSpringLaunch

;---------------------------------------------------------------------------------------------------
; Indices in comments are value of $49
;---------------------------------------------------------------------------------------------------
JumpVelocityNormal:
#_989A: db $20, $14, $0E, $07           ; 01 - rising
#_989E: db $02, $02, $07, $0E, $14, $20 ; 05 - falling

;---------------------------------------------------------------------------------------------------

JumpVelocitySuperShoes:
#_98A4: db $20, $20, $20, $10, $0B, $08, $07, $03 ; 01 - rising
#_98AC: db $02, $03, $06, $07, $08, $0B, $10, $20 ; 09 - falling
#_98B4: db $20, $20

;---------------------------------------------------------------------------------------------------

JumpVelocitySpringLaunch:
#_98B6: db $20, $20, $1C, $12, $0A, $06           ; 01 - rising
#_98BC: db $02, $02, $06, $0A, $12, $1C, $20, $20 ; 07 - falling

;---------------------------------------------------------------------------------------------------

JumpVelocitySuperShoesSpringLaunch:
#_98C4: db $20, $20, $20, $20, $20, $20, $10, $0B ; 01 - rising
#_98CC: db $08, $07, $04, $03, $02
#_98D1: db $02, $04, $07, $08, $0B, $10, $10, $20 ; 0E - falling
#_98D9: db $20, $20, $20, $20, $20

;---------------------------------------------------------------------------------------------------

JumpVelocityOverworld:
#_98DE: db $20, $20, $10, $06      ; 00 - rising
#_98E2: db $02, $02, $06, $10, $20 ; 04 - falling

;===================================================================================================

HandleMilonOverworld:
#_98E7: JSR NormalMilonMovement

#_98EA: JSR ShootBubbles
#_98ED: JSR HandleBubbles

#_98F0: LDA.b $49
#_98F2: BNE .fail

; check for up press
#_98F4: LDA.b $08
#_98F6: AND.b #$08
#_98F8: BEQ .fail

#_98FA: LDA.b $8A
#_98FC: BEQ .fail

#_98FE: LDA.b $4B
#_9900: CLC
#_9901: ADC.b #$03
#_9903: AND.b #$0F
#_9905: CMP.b #$07
#_9907: BCS .fail

#_9909: JSR MilonCoordinatesToXY
#_990C: JSR GetObjectType_overworld

#_990F: LDA.b $2B
#_9911: CMP.b #$1F ; OWOBJ 1F
#_9913: BNE .not_sawable

#_9915: LDA.w $079C ; saw
#_9918: BEQ .fail
#_991A: BNE .have_saw

.not_sawable
#_991C: CMP.b #$04
#_991E: BCS .fail

#_9920: CMP.b #$02
#_9922: BCS .check_for_hammer
#_9924: BCC .succeed

.check_for_hammer
#_9926: LDA.w $07A0 ; hammer
#_9929: BEQ .fail

.have_saw
#_992B: LDA.b #$07 ; SFX 07
#_992D: STA.b $E6

.succeed
#_992F: SEC
#_9930: RTS

.fail
#_9931: CLC
#_9932: RTS

;===================================================================================================

NormalMilonMovement:
#_9933: LDA.b $08
#_9935: AND.b #$03
#_9937: STA.b $42

#_9939: JSR CheckObjectBelowMilon

#_993C: JSR MilonJump
#_993F: JSR MilonMoveY

#_9942: JSR MilonWalk
#_9945: JSR MilonMoveX

#_9948: JSR PanCamera
#_994B: JSR PanTilemap

#_994E: JSR PanCamera
#_9951: JSR PanTilemap

#_9954: JSR PanCamera
#_9957: JSR PanTilemap

#_995A: JSR PanCamera
#_995D: JSR PanTilemap

#_9960: JMP HandleNudging

;===================================================================================================

HandleMilonBasics:
#_9963: JSR NormalMilonMovement

#_9966: JSR ShootBubbles
#_9969: JSR HandleBubbles

#_996C: JSR AttemptKeySpawn

#_996F: JSR MilonCoordinatesToXY
#_9972: JSR GetObjectType_indoors
#_9975: JSR CheckForHotObjects
#_9978: JSR CheckForShockingObjects

#_997B: JSR HandleMoneyHoneyCollection
#_997E: JSR DoorCheck

;---------------------------------------------------------------------------------------------------

#_9981: LDA.b $3E
#_9983: CMP.b #$F1
#_9985: BCS .edge_transition

#_9987: LDA.b $3F
#_9989: CMP.b #$F0
#_998B: BCC .exit

#_998D: LDA.b $4E
#_998F: CMP.b #$FF
#_9991: BEQ .bottom_of_screen

#_9993: CMP.b #$01
#_9995: BNE .exit

#_9997: LDA.b $4D
#_9999: CMP.b #$E0
#_999B: BCC .exit

#_999D: LDA.b #$1E
#_999F: STA.b $2A

.edge_transition
#_99A1: LDA.b #$01
#_99A3: STA.b $8B

.exit
#_99A5: RTS

.bottom_of_screen
#_99A6: LDA.b $3F
#_99A8: CMP.b #$FC
#_99AA: BCS .exit

#_99AC: LDA.b #$00
#_99AE: STA.b $2A
#_99B0: BEQ .edge_transition

;===================================================================================================

DoorCheck:
#_99B2: LDA.b $4B
#_99B4: CLC
#_99B5: ADC.b #$03
#_99B7: AND.b #$0F
#_99B9: CMP.b #$07
#_99BB: BCS .exit

#_99BD: LDA.b $4D
#_99BF: AND.b #$0F
#_99C1: CMP.b #$08
#_99C3: BNE .exit

#_99C5: LDA.b $2B
#_99C7: CMP.b #$08 ; OBJECT 08
#_99C9: BEQ .valid

#_99CB: DEC.b $2A
#_99CD: CMP.b #$09 ; OBJECT 09
#_99CF: BEQ .valid

#_99D1: RTS

;---------------------------------------------------------------------------------------------------

.valid
#_99D2: LDA.b $87
#_99D4: CMP.b #$09 ; ROOM 09
#_99D6: BCS .exit

#_99D8: JSR CheckDoorLocations
#_99DB: BCS .enter_shop

#_99DD: CPX.b #$00
#_99DF: BNE .enter_shop

#_99E1: LDA.w $07BF
#_99E4: CMP.b #$02
#_99E6: BCS .enter_shop

.exit
#_99E8: RTS

;---------------------------------------------------------------------------------------------------

.enter_shop
#_99E9: INC.b $8B

#_99EB: LDA.b #$00 ; SONG OFF
#_99ED: STA.b $BE

#_99EF: RTS

;===================================================================================================

CheckIfKeyIsHere:
#_99F0: JSR GetBitIndexForRoom

#_99F3: LDA.w $07C8,X
#_99F6: AND.w BitTable,Y

#_99F9: RTS

;===================================================================================================

HandleMoneyHoneyCollection:
#_99FA: LDA.b $2B
#_99FC: CMP.b #$1E ; OBJECT 1E
#_99FE: BCC .exit
#_9A00: BNE .honeycomb

; Coin
#_9A02: LDA.b $29
#_9A04: STA.b $61

#_9A06: LDA.b $2A
#_9A08: STA.b $63

#_9A0A: JSR TilemapXYtoFullCoordinates

#_9A0D: JSR IsAbsoluteOnScreen
#_9A10: BCS .no_smoke

#_9A12: LDA.b #$02
#_9A14: JSR SpawnSmokePuff

.no_smoke
#_9A17: LDA.b #$10 ; SFX 10
#_9A19: STA.b $E6

#_9A1B: LDA.b #$01
#_9A1D: JSR AddCurrency

; !BUG 99% sure this is not an intentional bonus
; You're not expected to grab 256 coins in a single room
; So this BNE is actually meant to be a BRA
#_9A20: INC.w $07BD
#_9A23: BNE .no_moneycomb

.honeycomb
#_9A25: JSR PerformCollectionJingle

#_9A28: LDA.b $B3
#_9A2A: CLC
#_9A2B: ADC.b #$08
#_9A2D: STA.b $B3
#_9A2F: STA.b $B2

;---------------------------------------------------------------------------------------------------

.no_moneycomb
#_9A31: JSR FlagObjectAsCollected

#_9A34: LDA.b $2B
#_9A36: PHA

#_9A37: LDA.b #$00 ; OBJECT 00
#_9A39: STA.b $2B

#_9A3B: JSR ChangeObjectType
#_9A3E: JSR RedrawObject

#_9A41: PLA
#_9A42: STA.b $2B

.exit
#_9A44: RTS

;===================================================================================================

PerformCollectionJingle:
#_9A45: LDA.b #$11 ; SONG 11
#_9A47: STA.b $BE

#_9A49: INC.b $3A

.wait_for_jingle
#_9A4B: LDA.b $BE
#_9A4D: AND.b #$7F
#_9A4F: CMP.b #$11 ; SONG 11
#_9A51: BEQ .wait_for_jingle

#_9A53: LDA.b #$00
#_9A55: STA.b $3A

#_9A57: RTS

;===================================================================================================

MilonCoordinatesToXY:
#_9A58: LDA.b $4B
#_9A5A: CLC
#_9A5B: ADC.b #$08
#_9A5D: STA.b $1C

#_9A5F: LDA.b $4C
#_9A61: ADC.b #$00
#_9A63: STA.b $1D

#_9A65: LDA.b $1C
#_9A67: LSR.b $1D
#_9A69: ROR A
#_9A6A: LSR A
#_9A6B: LSR A
#_9A6C: LSR A
#_9A6D: STA.b $29

#_9A6F: LDA.b $4D
#_9A71: CLC
#_9A72: ADC.b #$0A
#_9A74: STA.b $1C

#_9A76: LDA.b $4E
#_9A78: ADC.b #$00
#_9A7A: STA.b $1D
#_9A7C: LDA.b $1C
#_9A7E: LSR.b $1D
#_9A80: ROR A
#_9A81: LSR A
#_9A82: LSR A
#_9A83: LSR A
#_9A84: STA.b $2A

#_9A86: RTS

;===================================================================================================

MilonJump:
#_9A87: LDA.b $49
#_9A89: BNE .performing_jump

#_9A8B: JSR CheckIfRecoiling
#_9A8E: BCS .performing_jump

#_9A90: LDA.b #$00
#_9A92: STA.b $3B

#_9A94: LDA.b $50
#_9A96: STA.b $51
#_9A98: BNE .execute_jump

#_9A9A: LDA.b $08
#_9A9C: TAX
#_9A9D: AND.b #$80
#_9A9F: BNE .pressed_a

#_9AA1: LDA.b $09
#_9AA3: AND.b #$80
#_9AA5: BEQ .pressed_a

#_9AA7: LDA.b $09
#_9AA9: AND.b #$7F
#_9AAB: STA.b $09

.pressed_a
#_9AAD: TXA
#_9AAE: AND.b #$80
#_9AB0: BEQ .exit

#_9AB2: LDA.b $09
#_9AB4: TAX
#_9AB5: AND.b #$80
#_9AB7: BNE .exit

#_9AB9: TXA
#_9ABA: ORA.b #$80
#_9ABC: STA.b $09

#_9ABE: LDA.b #$02 ; SFX 02
#_9AC0: STA.b $E6
#_9AC2: BNE .execute_jump

;---------------------------------------------------------------------------------------------------

.performing_jump
#_9AC4: INC.b $3B

#_9AC6: JSR GetJumpHeightIndex

#_9AC9: LDA.b $49
#_9ACB: CMP.w JumpDurations,X
#_9ACE: BCS .falling

#_9AD0: LDA.b $08 ; Check for A press
#_9AD2: AND.b #$80
#_9AD4: BNE .not_holding_a

#_9AD6: LDA.b $3B
#_9AD8: CMP.w JumpExtendDurations,X
#_9ADB: BCC .tick_fast

#_9ADD: JSR MakeMilonFall

#_9AE0: DEC.b $49

.not_holding_a
#_9AE2: LDA.b #$07
#_9AE4: BNE .set_decay

.falling
#_9AE6: LDA.w $07A6 ; blimp
#_9AE9: BEQ .tick_fast

#_9AEB: LDA.b $08
#_9AED: AND.b #$80
#_9AEF: BEQ .tick_fast

#_9AF1: LDA.b #$10
#_9AF3: BNE .set_decay

.tick_fast
#_9AF5: LDA.b #$03

.set_decay
#_9AF7: STA.b $1C

#_9AF9: INC.b $45

#_9AFB: LDA.b $45
#_9AFD: CMP.b $1C
#_9AFF: BCC .exit

;---------------------------------------------------------------------------------------------------

.execute_jump
#_9B01: LDA.b #$00
#_9B03: STA.b $50
#_9B05: STA.b $45
#_9B07: STA.b $57

#_9B09: INC.b $49

#_9B0B: JSR GetJumpHeightIndex

#_9B0E: LDA.w TerminalVelocity,X
#_9B11: CMP.b $49
#_9B13: BCS .exit

#_9B15: LDA.b $4A
#_9B17: BNE .airborne

#_9B19: LDA.b #$00
#_9B1B: STA.b $49

.exit
#_9B1D: RTS

.airborne
#_9B1E: DEC.b $49

#_9B20: RTS

;===================================================================================================
; Overworld            => 2
; Spring               => 1
; Super shoes          => 3
; Super shoes spring   => 4
; else                 => 0
;===================================================================================================
GetJumpHeightIndex:
#_9B21: LDA.b $8A
#_9B23: ASL A
#_9B24: BNE .overworld

#_9B26: LDA.w $079B ; super shoes
#_9B29: BEQ .no_super_shoes

#_9B2B: LDA.b #$03

.no_super_shoes
#_9B2D: CLC
#_9B2E: ADC.b $51

.overworld
#_9B30: TAX

#_9B31: RTS

;===================================================================================================

MilonWalk:
#_9B32: LDA.b $42
#_9B34: AND.b #$03
#_9B36: BEQ .reset_strut

#_9B38: CMP.b $43
#_9B3A: BEQ .dont_reset_speed

#_9B3C: STA.b $43

#_9B3E: LDA.b #$0A
#_9B40: STA.b $47

.dont_reset_speed
#_9B42: LDA.b #$01
#_9B44: STA.b $40
#_9B46: BNE .test_shrink

.reset_strut
#_9B48: LDA.b #$00
#_9B4A: STA.b $40

#_9B4C: JSR .test_next

;---------------------------------------------------------------------------------------------------

.test_next
#_9B4F: JSR BuildMomentum
#_9B52: BNE .exit_a

#_9B54: LDA.b $47
#_9B56: CMP.b #$0A
#_9B58: BCS .exit_a

#_9B5A: INC.b $47

.exit_a
#_9B5C: RTS

;---------------------------------------------------------------------------------------------------

.test_shrink
#_9B5D: JSR CheckIfRecoiling
#_9B60: BCS .test_next

;---------------------------------------------------------------------------------------------------

#_9B62: LDA.b $49
#_9B64: BNE .exit_b

#_9B66: JSR BuildMomentum
#_9B69: BNE .exit_b

#_9B6B: DEC.b $47
#_9B6D: BNE .exit_b

#_9B6F: INC.b $47

.exit_b
#_9B71: RTS

;===================================================================================================

BuildMomentum:
#_9B72: LDA.b #$06
#_9B74: STA.b $1C

#_9B76: LDA.b $40
#_9B78: BNE .im_walkin_here

#_9B7A: LDA.b #$03
#_9B7C: STA.b $1C

.im_walkin_here
#_9B7E: INC.b $44

#_9B80: LDA.b $44
#_9B82: CMP.b $1C
#_9B84: BCC .exit

#_9B86: LDA.b #$00
#_9B88: STA.b $44

.exit
#_9B8A: RTS

;===================================================================================================

GetSpeedInPixels:
#_9B8B: LDX.b $47

#_9B8D: LDA.b $46
#_9B8F: CLC
#_9B90: ADC.w .velocity-1,X
#_9B93: TAX

#_9B94: AND.b #$07
#_9B96: STA.b $46

#_9B98: TXA
#_9B99: LSR A
#_9B9A: LSR A
#_9B9B: LSR A
#_9B9C: STA.b $AD

#_9B9E: RTS

;---------------------------------------------------------------------------------------------------

.velocity
#_9B9F: db $10, $0B, $0B, $0B
#_9BA3: db $08, $08, $07, $06
#_9BA7: db $05, $04

;===================================================================================================

GetJumpVelocity:
#_9BA9: LDA.b $8A
#_9BAB: BNE .overworld

#_9BAD: LDA.b $51
#_9BAF: BNE .springy

#_9BB1: LDX.w $079B ; super shoes

#_9BB4: LDA.w JumpVelocityIndexer,X
#_9BB7: CLC
#_9BB8: ADC.b $49
#_9BBA: TAX

#_9BBB: LDA.b $48
#_9BBD: CLC
#_9BBE: ADC.w JumpVelocityNormal-1,X

.finished
#_9BC1: TAX
#_9BC2: AND.b #$07
#_9BC4: STA.b $48
#_9BC6: TXA

#_9BC7: LSR A
#_9BC8: LSR A
#_9BC9: LSR A
#_9BCA: STA.b $AE

#_9BCC: RTS

;---------------------------------------------------------------------------------------------------

.springy
#_9BCD: LDX.w $079B ; super shoes

#_9BD0: LDA.w SpringVelocityIndexer,X
#_9BD3: CLC
#_9BD4: ADC.b $49
#_9BD6: TAX

#_9BD7: LDA.b $48
#_9BD9: CLC
#_9BDA: ADC.w JumpVelocitySpringLaunch-1,X

#_9BDD: JMP .finished

;---------------------------------------------------------------------------------------------------

.overworld
#_9BE0: LDX.b $49

#_9BE2: LDA.b $48
#_9BE4: CLC
#_9BE5: ADC.w JumpVelocityOverworld,X

#_9BE8: JMP .finished

;===================================================================================================

MilonMoveX:
#_9BEB: LDA.b $A9
#_9BED: BNE .exit

#_9BEF: LDA.b $40
#_9BF1: BNE .im_walkin_here

#_9BF3: LDA.b $47
#_9BF5: CMP.b #$0A
#_9BF7: BEQ .exit

#_9BF9: LDA.b $43
#_9BFB: STA.b $42

.im_walkin_here
#_9BFD: JSR GetSpeedInPixels
#_9C00: BEQ .exit

#_9C02: JSR AnimateMilonStrut

#_9C05: LDA.b $42
#_9C07: TAX

#_9C08: AND.b #$01
#_9C0A: BNE MoveMilonRight

#_9C0C: TXA
#_9C0D: AND.b #$02
#_9C0F: BNE MoveMilonLeft

.exit
#_9C11: RTS

;===================================================================================================

#HandleNudging:
#_9C12: LDA.b $A9
#_9C14: BEQ .exit

#_9C16: LDA.b #$01
#_9C18: STA.b $AD

#_9C1A: DEC.b $A9

#_9C1C: LDA.b $AA
#_9C1E: BMI MoveMilonLeft

;===================================================================================================

MoveMilonRight:
#_9C20: LDA.b $42
#_9C22: AND.b #$0C
#_9C24: ORA.b #$01
#_9C26: STA.b $42

.move_one
#_9C28: JSR MoveMilonRightOne

#_9C2B: DEC.b $AD
#_9C2D: BNE .move_one

#_9C2F: RTS

;===================================================================================================

MoveMilonLeft:
#_9C30: LDA.b $42
#_9C32: AND.b #$0C
#_9C34: ORA.b #$02
#_9C36: STA.b $42

.move_one
#_9C38: JSR MoveMilonLeftOne

#_9C3B: DEC.b $AD
#_9C3D: BNE .move_one

#_9C3F: RTS

;===================================================================================================

MilonMoveY:
#_9C40: LDA.b $57
#_9C42: BEQ .not_on_platform

#_9C44: LDA.b $56
#_9C46: BEQ .not_on_platform

#_9C48: LDA.b #$01
#_9C4A: STA.b $AE

#_9C4C: JMP MoveMilonUpOne

;---------------------------------------------------------------------------------------------------

.not_on_platform
#_9C4F: JSR GetJumpVelocity
#_9C52: BEQ .exit

#_9C54: LDA.b $49
#_9C56: BEQ .exit

#_9C58: JSR GetJumpHeightIndex

#_9C5B: LDA.b $49
#_9C5D: CMP.w JumpDurations,X
#_9C60: BCC .jumping

;---------------------------------------------------------------------------------------------------

.falling
#_9C62: LDA.b $42
#_9C64: AND.b #$03
#_9C66: ORA.b #$04
#_9C68: STA.b $42

.fall_more
#_9C6A: JSR MoveMilonDownOne

#_9C6D: DEC.b $AE
#_9C6F: BNE .fall_more

#_9C71: RTS

;---------------------------------------------------------------------------------------------------

.jumping
#_9C72: LDA.b $42
#_9C74: AND.b #$03
#_9C76: ORA.b #$08
#_9C78: STA.b $42

.rise_more
#_9C7A: JSR MoveMilonUpOne

#_9C7D: DEC.b $AE
#_9C7F: BNE .rise_more

.exit
#_9C81: RTS

;===================================================================================================

CheckIfRecoiling:
#_9C82: LDA.b $3D
#_9C84: BEQ .not_hurt

#_9C86: LDA.b $3C
#_9C88: AND.b #$40
#_9C8A: BNE .not_hurt

.ouch
#_9C8C: SEC

#_9C8D: RTS

.not_hurt
#_9C8E: CLC

#_9C8F: RTS

;===================================================================================================

CheckObjectBelowMilon:
#_9C90: LDA.b #$00
#_9C92: STA.b $4A

#_9C94: JSR GetJumpHeightIndex

#_9C97: LDA.w JumpDurations,X
#_9C9A: SEC
#_9C9B: SBC.b #$01
#_9C9D: STA.b $1C

#_9C9F: LDA.b $49
#_9CA1: SEC
#_9CA2: SBC.b #$01
#_9CA4: CMP.b $1C
#_9CA6: BCC .stay_airborne

#_9CA8: LDA.b $3F ; no tile check if Milon is too low on screen
#_9CAA: CMP.b #$C9
#_9CAC: BCS .skip_traps

#_9CAE: JSR CheckForTraps
#_9CB1: BCS .triggered_trap

.skip_traps
#_9CB3: LDA.b #$01
#_9CB5: STA.b $4A

#_9CB7: LDA.b $49
#_9CB9: BNE .stay_airborne

#_9CBB: JSR GetJumpHeightIndex

#_9CBE: LDA.w JumpDurations,X

#_9CC1: LDY.b $55
#_9CC3: BEQ .normal_fall

#_9CC5: LDA.b #$00
#_9CC7: STA.b $55

#_9CC9: LDA.w TerminalVelocity,X
#_9CCC: BNE .set_gravity

.normal_fall
#_9CCE: CLC
#_9CCF: ADC.b #$02

.set_gravity
#_9CD1: STA.b $49

#_9CD3: LDA.b $2B
#_9CD5: CMP.b #$17 ; OBJECT 17
#_9CD7: BEQ .stepped_on_trapdoor

.stay_airborne
#_9CD9: JMP .check_for_tile

;---------------------------------------------------------------------------------------------------

.triggered_trap
#_9CDC: LDA.b $4D
#_9CDE: AND.b #$07
#_9CE0: BNE .exit

#_9CE2: LDA.b $2B
#_9CE4: STA.b $54

#_9CE6: LDA.b $8A
#_9CE8: BNE .exit

#_9CEA: LDA.b $2D
#_9CEC: CMP.b #$10 ; OBJECT 10
#_9CEE: BEQ CreateMeltingIce

#_9CF0: CMP.b #$11 ; OBJECT 11
#_9CF2: BEQ .stepped_on_spring

#_9CF4: DEC.b $29

#_9CF6: LDA.b $2C
#_9CF8: CMP.b #$10 ; OBJECT 10
#_9CFA: BEQ CreateMeltingIce

#_9CFC: CMP.b #$11 ; OBJECT 11
#_9CFE: BEQ .stepped_on_spring

;---------------------------------------------------------------------------------------------------

.check_for_tile
#_9D00: LDA.b $4D
#_9D02: AND.b #$07
#_9D04: BNE .exit

#_9D06: LDA.b $8A
#_9D08: BNE .exit

#_9D0A: LDA.b $4A
#_9D0C: BEQ .exit

#_9D0E: LDA.b $2B
#_9D10: CMP.b #$17 ; OBJECT 17
#_9D12: BEQ .stepped_on_trapdoor

.exit
#_9D14: RTS

;---------------------------------------------------------------------------------------------------

.stepped_on_trapdoor
#_9D15: LDA.b #$0E ; SFX 0E
#_9D17: STA.b $E6

#_9D19: LDY.b #$02
#_9D1B: BNE FindTransientSlot

;---------------------------------------------------------------------------------------------------

.stepped_on_spring
#_9D1D: LDA.w $079A ; shoes
#_9D20: BEQ .exit

#_9D22: LDA.b #$01
#_9D24: STA.b $50

#_9D26: LDA.b #$01 ; SFX 01
#_9D28: STA.b $E6

#_9D2A: LDA.b $29
#_9D2C: STA.b $69

#_9D2E: LDA.b $2A
#_9D30: STA.b $6A
#_9D32: DEC.b $6A

#_9D34: JSR ReturnToDefaultPosition

#_9D37: LDA.b #$01 ; SPRITE 01
#_9D39: STA.w $06C0

#_9D3C: LDA.b #$03
#_9D3E: STA.b $60

#_9D40: LDX.b #$00
#_9D42: STX.b $6B
#_9D44: STX.b $5F
#_9D46: STX.b $65

#_9D48: JMP SaveSpriteVars

;===================================================================================================

CreatePushedBlock:
#_9D4B: LDA.b #$06 ; SFX 06
#_9D4D: STA.b $E6
#_9D4F: BNE FindTransientSlot

;===================================================================================================

CreateMeltingIce:
#_9D51: INC.b $55

#_9D53: LDA.b #$0F ; SFX 0F
#_9D55: STA.b $E6

#_9D57: LDY.b #$01

;===================================================================================================

FindTransientSlot:
#_9D59: LDX.b #$03

.search
#_9D5B: LDA.b $83,X
#_9D5D: BEQ .empty_slot

#_9D5F: DEX
#_9D60: BPL .search

#_9D62: INX

;---------------------------------------------------------------------------------------------------

.empty_slot
#_9D63: STY.b $83,X

#_9D65: TXA
#_9D66: ASL A
#_9D67: ASL A
#_9D68: TAX

#_9D69: LDA.b $29
#_9D6B: STA.w $07A9,X

#_9D6E: LDA.b $2A
#_9D70: STA.w $07AA,X

#_9D73: LDA.b #$1F ; OBJECT 1F - actually OBJECT 20 minus 1
#_9D75: STA.w $07AB,X

#_9D78: LDA.b #$00
#_9D7A: STA.w $07AC,X

#_9D7D: CPY.b #$02
#_9D7F: BEQ .is_trapdoor

#_9D81: LDA.b #$0F ; OBJECT 0F
#_9D83: STA.b $2B

#_9D85: JMP ChangeObjectType

.is_trapdoor
#_9D88: LDA.b #$00 ; OBJECT 00
#_9D8A: STA.b $2B

#_9D8C: JSR RedrawObject

#_9D8F: JMP ChangeObjectType

;===================================================================================================

CheckForShockingObjects:
#_9D92: LDA.b $87
#_9D94: CMP.b #$12 ; ROOM 12
#_9D96: BNE EXIT_9DEB

#_9D98: LDA.b $2B
#_9D9A: CMP.b #$02 ; OBJECT 02
#_9D9C: BCC EXIT_9DEB

#_9D9E: CMP.b #$0E ; OBJECT 0E
#_9DA0: BCS EXIT_9DEB

#_9DA2: LDX.b #$18
#_9DA4: JMP DamageMilon

;===================================================================================================

CheckForHotObjects:
#_9DA7: LDA.b $87
#_9DA9: CMP.b #$0F ; ROOM 0F
#_9DAB: BNE EXIT_9DEB

#_9DAD: LDA.b $2B
#_9DAF: CMP.b #$1A ; OBJECT 1A
#_9DB1: BEQ .fire_indeed_hot

#_9DB3: CMP.b #$02 ; OBJECT 02
#_9DB5: BCC EXIT_9DEB

#_9DB7: CMP.b #$0C ; OBJECT 0C
#_9DB9: BCS EXIT_9DEB

.fire_indeed_hot
#_9DBB: LDA.w $07A3 ; vest
#_9DBE: BEQ .no_vest

#_9DC0: JSR Random
#_9DC3: AND.b #$1F ; 1/32 chance to deal 1 damage with the vest
#_9DC5: BNE EXIT_9DEB

#_9DC7: LDX.b #$01
#_9DC9: BNE .deal_damage

.no_vest
#_9DCB: LDX.b #$08

.deal_damage
#_9DCD: JMP DamageMilon

;===================================================================================================

PushSolidRight:
#_9DD0: LDA.b $2B
#_9DD2: CMP.b #$16 ; OBJECT 16
#_9DD4: BNE ResetPushTimer

#_9DD6: LDA.b #$01
#_9DD8: STA.w $07C3

#_9DDB: INC.b $29

#_9DDD: JSR GetObjectType_indoors

#_9DE0: LDA.b $2B ; OBJECT 00
#_9DE2: BNE ResetPushTimer

#_9DE4: DEC.b $29

#_9DE6: LDY.b #$04
#_9DE8: JMP PushPushableBlock

;---------------------------------------------------------------------------------------------------

#EXIT_9DEB:
#_9DEB: RTS

;===================================================================================================

MoveMilonRightOne:
#_9DEC: JSR CheckObjectRightOfMilon
#_9DEF: BCS PushSolidRight

#_9DF1: INC.b $4B
#_9DF3: BNE .no_overflow

#_9DF5: INC.b $4C

.no_overflow
#_9DF7: JSR IsScrollNeededRight
#_9DFA: BCC .scroll_right

#_9DFC: INC.b $3E

#_9DFE: RTS

;---------------------------------------------------------------------------------------------------

.scroll_right
#_9DFF: DEC.b $A8

#_9E01: INC.b $06
#_9E03: BNE .no_overflow_scroll

#_9E05: LDA.b $00
#_9E07: AND.b #$01
#_9E09: EOR.b #$01
#_9E0B: STA.b $1C

#_9E0D: LDA.b $00
#_9E0F: AND.b #$FE
#_9E11: ORA.b $1C
#_9E13: STA.b $00

.no_overflow_scroll
#_9E15: LDA.b $06
#_9E17: AND.b #$0F
#_9E19: BNE .not_aligned

#_9E1B: INC.b $17

.not_aligned
#_9E1D: RTS

;===================================================================================================

PushSolidLeft:
#_9E1E: LDA.b $2B
#_9E20: CMP.b #$16 ; OBJECT 16
#_9E22: BNE ResetPushTimer

#_9E24: LDA.b #$01
#_9E26: STA.w $07C3

#_9E29: DEC.b $29

#_9E2B: JSR GetObjectType_indoors

#_9E2E: LDA.b $2B ; OBJECT 00
#_9E30: BNE ResetPushTimer

#_9E32: LDY.b #$03

;---------------------------------------------------------------------------------------------------

PushPushableBlock:
#_9E34: INC.b $99

#_9E36: LDA.b $99
#_9E38: AND.b #$3F
#_9E3A: BNE .dont_push_block

#_9E3C: JSR CreatePushedBlock

;---------------------------------------------------------------------------------------------------

#ResetPushTimer:
#_9E3F: LDA.b #$00
#_9E41: STA.b $99

.dont_push_block
#_9E43: LDA.b #$0A
#_9E45: STA.b $47

#_9E47: RTS

;===================================================================================================

MoveMilonLeftOne:
#_9E48: JSR CheckObjectLeftOfMilon
#_9E4B: BCS PushSolidLeft

#_9E4D: LDA.b $4B
#_9E4F: BNE .no_overflow

#_9E51: DEC.b $4C

.no_overflow
#_9E53: DEC.b $4B

#_9E55: JSR IsScrollNeededLeft
#_9E58: BCC .no_scroll

#_9E5A: DEC.b $3E

#_9E5C: RTS

;---------------------------------------------------------------------------------------------------

.no_scroll
#_9E5D: INC.b $A8

#_9E5F: LDA.b $06
#_9E61: BNE .no_overflow_scroll

#_9E63: LDA.b $00
#_9E65: AND.b #$01
#_9E67: EOR.b #$01
#_9E69: STA.b $1C

#_9E6B: LDA.b $00
#_9E6D: AND.b #$FE
#_9E6F: ORA.b $1C
#_9E71: STA.b $00

.no_overflow_scroll
#_9E73: DEC.b $06

#_9E75: LDA.b $06
#_9E77: AND.b #$0F
#_9E79: CMP.b #$0F
#_9E7B: BNE .not_aligned

#_9E7D: DEC.b $17

.not_aligned
#_9E7F: RTS

;===================================================================================================

MoveMilonDownOne:
#_9E80: JSR CheckObjectBelowMilon

#_9E83: LDA.b $4A
#_9E85: BEQ .grounded

#_9E87: INC.b $4D
#_9E89: BNE .no_overflow

#_9E8B: INC.b $4E

.no_overflow
#_9E8D: INC.b $3F

#_9E8F: RTS

.grounded
#_9E90: LDA.b #$00
#_9E92: STA.b $49

#_9E94: RTS

;===================================================================================================

MoveMilonUpOne:
#_9E95: JSR CheckObjectAboveMilon
#_9E98: BCS .hit_ceiling

#_9E9A: LDA.b $3C
#_9E9C: AND.b #$40
#_9E9E: BEQ .no_music_box_check

#_9EA0: LDA.b $3D
#_9EA2: CMP.b #$77
#_9EA4: BCS .hit_ceiling

.no_music_box_check
#_9EA6: LDA.b $4D
#_9EA8: BNE .no_overflow

#_9EAA: DEC.b $4E

.no_overflow
#_9EAC: DEC.b $4D
#_9EAE: DEC.b $3F

#_9EB0: RTS

;---------------------------------------------------------------------------------------------------

.hit_ceiling
#_9EB1: JSR MakeMilonFall

#_9EB4: LDA.w $07CE
#_9EB7: BNE .exit

#_9EB9: LDA.b $29
#_9EBB: CMP.w $07CC
#_9EBE: BNE .exit

#_9EC0: LDA.b $2A
#_9EC2: CMP.w $07CD
#_9EC5: BNE .exit

#_9EC7: JSR CheckIfMusicBoxIsHere
#_9ECA: BNE .exit

#_9ECC: DEC.b $2A

#_9ECE: LDA.b $29
#_9ED0: STA.b $61

#_9ED2: LDA.b $2A
#_9ED4: STA.b $63
#_9ED6: JSR TilemapXYtoFullCoordinates

#_9ED9: LDA.b #$22 ; SPRITE 22
#_9EDB: JSR SpawnSprite
#_9EDE: BCS .exit

#_9EE0: LDA.b #$06
#_9EE2: STA.w $0608,X

#_9EE5: INC.w $07CE

#_9EE8: RTS

;===================================================================================================

#FlagMusicBox:
#_9EE9: JSR GetBitIndexForRoom

#_9EEC: LDA.w $07CA,X
#_9EEF: ORA.w BitTable,Y
#_9EF2: STA.w $07CA,X

.exit
#_9EF5: RTS

;===================================================================================================

CheckIfMusicBoxIsHere:
#_9EF6: JSR GetBitIndexForRoom

#_9EF9: LDA.w $07CA,X
#_9EFC: AND.w BitTable,Y

#_9EFF: RTS

;===================================================================================================

MakeMilonFall:
#_9F00: JSR GetJumpHeightIndex

#_9F03: LDA.w JumpDurations,X
#_9F06: STA.b $49

#_9F08: RTS

;===================================================================================================

PanCamera:
#_9F09: LDA.b $52
#_9F0B: EOR.b #$01
#_9F0D: ASL A
#_9F0E: ASL A
#_9F0F: ASL A
#_9F10: CLC
#_9F11: ADC.b $3F
#_9F13: CMP.b #$40
#_9F15: BCC .pan_up

#_9F17: CMP.b #$98
#_9F19: BCS .pan_down

.exit_a
#_9F1B: RTS

;---------------------------------------------------------------------------------------------------

.pan_up
#_9F1C: LDA.b $16
#_9F1E: ORA.b $14
#_9F20: BEQ .exit_a

#_9F22: INC.b $A7

#_9F24: LDA.b #$00
#_9F26: STA.b $13

#_9F28: INC.b $3F

#_9F2A: DEC.b $14

#_9F2C: LDA.b $14
#_9F2E: CMP.b #$FF
#_9F30: BNE .not_too_negative

#_9F32: LDA.b #$EF
#_9F34: STA.b $14

.not_too_negative
#_9F36: AND.b #$0F
#_9F38: CMP.b #$0F
#_9F3A: BNE .exit_b

#_9F3C: DEC.b $16

.exit_b
#_9F3E: RTS

;---------------------------------------------------------------------------------------------------

.pan_down
#_9F3F: LDA.b $14
#_9F41: BNE .nonzero_scroll

#_9F43: LDA.b $16
#_9F45: CMP.b #$0F
#_9F47: BEQ .exit_a

.nonzero_scroll
#_9F49: LDA.b #$01
#_9F4B: STA.b $13

#_9F4D: DEC.b $A7
#_9F4F: DEC.b $3F

#_9F51: INC.b $14

#_9F53: LDA.b $14
#_9F55: CMP.b #$F0
#_9F57: BCC .not_too_positive

#_9F59: LDA.b #$00
#_9F5B: STA.b $14

.not_too_positive
#_9F5D: AND.b #$0F
#_9F5F: BNE .exit_c

#_9F61: INC.b $16

.exit_c
#_9F63: RTS

;===================================================================================================

IsScrollNeededRight:
#_9F64: LDA.b $3E
#_9F66: CMP.b #$B0
#_9F68: BCC .no

#_9F6A: LDA.b $00
#_9F6C: AND.b #$01
#_9F6E: EOR.b #$01
#_9F70: ORA.b $06
#_9F72: BEQ .no

.yes
#_9F74: CLC

#_9F75: RTS

;===================================================================================================

#IsScrollNeededLeft:
#_9F76: LDA.b $3E
#_9F78: CMP.b #$40
#_9F7A: BCS .no

#_9F7C: LDA.b $00
#_9F7E: AND.b #$01
#_9F80: ORA.b $06
#_9F82: BNE .yes

.no
#_9F84: SEC

#_9F85: RTS

;===================================================================================================

AnimateMilonStrut:
#_9F86: LDY.b $AD

.next
#_9F88: JSR .cycle

#_9F8B: DEY
#_9F8C: BNE .next

#_9F8E: RTS

;---------------------------------------------------------------------------------------------------

.cycle
#_9F8F: INC.b $41

#_9F91: LDX.b #$04
#_9F93: CPX.b $41
#_9F95: BCS .dont_reset

#_9F97: LDA.b #$00
#_9F99: STA.b $41

.dont_reset
#_9F9B: LDA.b $41
#_9F9D: BNE .exit

#_9F9F: INC.b $3C

#_9FA1: LDA.b $3C
#_9FA3: AND.b #$F3
#_9FA5: STA.b $3C

.exit
#_9FA7: RTS

;===================================================================================================

TestIfOnPlatform:
#_9FA8: LDA.w $07A4 ; feather
#_9FAB: BEQ .fail

#_9FAD: LDA.b $6D
#_9FAF: CMP.b #$FF
#_9FB1: BEQ .fail

#_9FB3: LDA.b $58
#_9FB5: SEC
#_9FB6: SBC.b $6E
#_9FB8: BCC .fail

#_9FBA: CMP.b #$20
#_9FBC: BCS .fail

#_9FBE: LDA.b $59
#_9FC0: SEC
#_9FC1: SBC.b $6D
#_9FC3: BCC .fail

#_9FC5: CMP.b #$03
#_9FC7: BCS .fail

#_9FC9: STA.b $56
#_9FCB: STA.b $57

#_9FCD: SEC
#_9FCE: RTS

.fail
#_9FCF: CLC
#_9FD0: RTS

;===================================================================================================

CheckForTraps:
#_9FD1: LDA.b #$FF
#_9FD3: STA.b $2B

#_9FD5: LDA.b $3F
#_9FD7: CLC
#_9FD8: ADC.b #$18
#_9FDA: STA.b $59

#_9FDC: JSR GetTrapLeft
#_9FDF: JSR GetTrapRight

#_9FE2: LDA.b $23
#_9FE4: ORA.b $24
#_9FE6: TAX

#_9FE7: AND.b #$04
#_9FE9: BNE .on_platform

#_9FEB: LDA.b $23
#_9FED: AND.b $24
#_9FEF: AND.b #$03
#_9FF1: CMP.b #$03
#_9FF3: BEQ .fail

#_9FF5: TXA
#_9FF6: AND.b #$03
#_9FF8: CMP.b #$03
#_9FFA: BNE .test_normal_trap

#_9FFC: LDA.b $23
#_9FFE: AND.b #$03
#_A000: CMP.b #$03
#_A002: BEQ .trapdoor_left

#_A004: LDA.b $23
#_A006: TAX

#_A007: JMP .test_normal_trap

.trapdoor_left
#_A00A: LDA.b $24
#_A00C: TAX

.test_normal_trap
#_A00D: TXA
#_A00E: AND.b #$02
#_A010: BEQ .fail

#_A012: SEC

#_A013: RTS

.fail
#_A014: CLC

#_A015: RTS

;---------------------------------------------------------------------------------------------------

.on_platform
#_A016: STA.b $55

#_A018: SEC

#_A019: RTS

;===================================================================================================

GetTrapLeft:
#_A01A: LDX.b #$00
#_A01C: STX.b $23

#_A01E: DEX
#_A01F: STX.b $2C

#_A021: LDA.b $3E
#_A023: CLC
#_A024: ADC.b #$02
#_A026: STA.b $58

#_A028: JSR TestIfOnPlatform
#_A02B: ROL.b $23

#_A02D: LDA.b $4D
#_A02F: AND.b #$07
#_A031: BNE .skip_this

#_A033: JSR GetObjectTile

#_A036: LDX.b $89
#_A038: CMP.w TrapThreshold,X
#_A03B: ROL.b $23

#_A03D: LDA.b $2B
#_A03F: STA.b $2C

#_A041: EOR.b $89
#_A043: CMP.b #$16 ; OBJECT 16, OBJECT 17
#_A045: BEQ .trapdoor

#_A047: CLC

.trapdoor
#_A048: ROL.b $23

#_A04A: RTS

.skip_this
#_A04B: ASL.b $23
#_A04D: ASL.b $23

#_A04F: RTS

;===================================================================================================

GetTrapRight:
#_A050: LDX.b #$00
#_A052: STX.b $24

#_A054: DEX
#_A055: STX.b $2D

#_A057: LDA.b $3E
#_A059: CLC
#_A05A: ADC.b #$0D
#_A05C: STA.b $58

#_A05E: JSR TestIfOnPlatform
#_A061: ROL.b $24

#_A063: LDA.b $4D
#_A065: AND.b #$07
#_A067: BNE .skip_this

#_A069: JSR GetObjectTile

#_A06C: LDX.b $89
#_A06E: CMP.w TrapThreshold,X
#_A071: ROL.b $24

#_A073: LDA.b $2B
#_A075: STA.b $2D

#_A077: EOR.b $89
#_A079: CMP.b #$16 ; OBJECT 16, OBJECT 17
#_A07B: BEQ .trapdoor

#_A07D: CLC

.trapdoor
#_A07E: ROL.b $24

#_A080: RTS

.skip_this
#_A081: ASL.b $24
#_A083: ASL.b $24

#_A085: RTS

;===================================================================================================

CheckObjectAboveMilon:
#_A086: LDX.b #$00
#_A088: STX.b $75

#_A08A: LDA.b $4D
#_A08C: AND.b #$07
#_A08E: CMP.b #$04
#_A090: BEQ .halfway

#_A092: INX

.halfway
#_A093: STX.b $76

#_A095: LDA.b $3F
#_A097: CLC
#_A098: LDX.b $52
#_A09A: ADC.w MilonHeightDifference,X
#_A09D: STA.b $59

;---------------------------------------------------------------------------------------------------

#_A09F: LDA.b $3E
#_A0A1: CLC
#_A0A2: ADC.b #$02
#_A0A4: STA.b $58

#_A0A6: JSR TestIfOnPlatform
#_A0A9: BCS .on_platform_left

#_A0AB: LDA.b $76
#_A0AD: BNE .not_solid_left

#_A0AF: JSR GetObjectTile
#_A0B2: JSR GetTileSolidity
#_A0B5: BCC .not_solid_left

.on_platform_left
#_A0B7: INC.b $75

;---------------------------------------------------------------------------------------------------

.not_solid_left
#_A0B9: LDA.b $58
#_A0BB: CLC
#_A0BC: ADC.b #$0B
#_A0BE: STA.b $58

#_A0C0: JSR TestIfOnPlatform
#_A0C3: BCS .on_platform_right

#_A0C5: LDA.b $76
#_A0C7: BNE .not_solid_right

#_A0C9: JSR GetObjectTile
#_A0CC: JSR GetTileSolidity
#_A0CF: BCC .not_solid_right

.on_platform_right
#_A0D1: LDA.b $75
#_A0D3: ORA.b #$02
#_A0D5: STA.b $75

;---------------------------------------------------------------------------------------------------

.not_solid_right
#_A0D7: LDA.b $75
#_A0D9: BEQ .no_solid_at_all

#_A0DB: CMP.b #$03
#_A0DD: BEQ TouchedSolid

#_A0DF: CMP.b #$01
#_A0E1: BEQ .only_left_solid

.only_right_solid
#_A0E3: LDA.b $4B
#_A0E5: AND.b #$0F
#_A0E7: CMP.b #$07
#_A0E9: BCS TouchedSolid

#_A0EB: SEC
#_A0EC: SBC.b #$02
#_A0EE: BCC .no_nudge_right

#_A0F0: STA.b $A9

#_A0F2: LDA.b #$FF
#_A0F4: STA.b $AA

.no_nudge_right
#_A0F6: CLC

#_A0F7: RTS

;---------------------------------------------------------------------------------------------------

.only_left_solid
#_A0F8: LDA.b $4B
#_A0FA: AND.b #$0F
#_A0FC: CMP.b #$0A
#_A0FE: BCC TouchedSolid

#_A100: STA.b $1C

#_A102: LDA.b #$0E
#_A104: SEC
#_A105: SBC.b $1C
#_A107: BCC .exit

#_A109: STA.b $A9

#_A10B: LDA.b #$01
#_A10D: STA.b $AA

#_A10F: CLC

.exit
#_A110: RTS

;===================================================================================================

#GetTileSolidity:
#_A111: LDX.b $89
#_A113: CMP.w TileSolidityThreshold,X

#_A116: RTS

;===================================================================================================

.no_solid_at_all
#_A117: CLC

#_A118: RTS

;===================================================================================================

TouchedSolid:
#_A119: SEC

#_A11A: RTS

;===================================================================================================

CheckObjectRightOfMilon:
#_A11B: LDA.b $8A
#_A11D: BEQ .overworld

#_A11F: LDA.b $3E
#_A121: CMP.b #$F0
#_A123: BEQ TouchedSolid

.overworld
#_A125: LDA.b $4B
#_A127: AND.b #$0F
#_A129: CMP.b #$02
#_A12B: BEQ .perform_test

#_A12D: CLC
#_A12E: RTS

.perform_test
#_A12F: LDA.b $3E
#_A131: CLC
#_A132: ADC.b #$0E
#_A134: BNE CheckTileHorizontal

;===================================================================================================

CheckObjectLeftOfMilon:
#_A136: LDA.b $8A
#_A138: BEQ .overworld

#_A13A: LDA.b $3E
#_A13C: BEQ .touched_solid

.overworld
#_A13E: LDA.b $4B
#_A140: AND.b #$07
#_A142: CMP.b #$06
#_A144: BEQ .perform_test

#_A146: CLC

#_A147: RTS

.perform_test
#_A148: LDA.b $3E
#_A14A: CLC
#_A14B: ADC.b #$01

;===================================================================================================

#CheckTileHorizontal:
#_A14D: STA.b $58

#_A14F: LDA.b $52
#_A151: BEQ .small_milon

#_A153: LDA.b $3F
#_A155: CLC
#_A156: ADC.b #$03
#_A158: STA.b $59

#_A15A: JSR TestIfOnPlatform
#_A15D: BCS .touched_solid

#_A15F: JSR GetObjectTile
#_A162: JSR GetTileSolidity
#_A165: BCS .touched_solid

.small_milon
#_A167: LDA.b $3F
#_A169: CLC
#_A16A: LDX.b $52
#_A16C: ADC.w .offset_top,X
#_A16F: STA.b $59

#_A171: JSR TestIfOnPlatform
#_A174: BCS .touched_solid

#_A176: JSR GetObjectTile
#_A179: JSR GetTileSolidity
#_A17C: BCS .touched_solid

#_A17E: LDA.b $3F
#_A180: CLC
#_A181: LDX.b $52
#_A183: ADC.w .offset_bottom,X
#_A186: STA.b $59

#_A188: JSR TestIfOnPlatform
#_A18B: BCS .touched_solid

#_A18D: JSR GetObjectTile
#_A190: JSR GetTileSolidity
#_A193: BCS .touched_solid

#_A195: LDA.b $3F
#_A197: CLC
#_A198: LDX.b $52
#_A19A: ADC.w .offset_under,X
#_A19D: STA.b $59

#_A19F: JSR TestIfOnPlatform
#_A1A2: BCS .touched_solid

#_A1A4: JSR GetObjectTile
#_A1A7: JMP GetTileSolidity

;---------------------------------------------------------------------------------------------------

.touched_solid
#_A1AA: SEC

#_A1AB: RTS

;---------------------------------------------------------------------------------------------------

.offset_top
#_A1AC: db $09, $07

.offset_bottom
#_A1AE: db $10, $0F

.offset_under
#_A1B0: db $17, $17

;===================================================================================================

GetObjectTile:
#_A1B2: LDA.b $8A
#_A1B4: BNE GetObjectTile_overworld

;===================================================================================================

GetObjectTile_inside:
#_A1B6: JSR GetObjectCoordinates_inside
#_A1B9: JSR GetObjectType_indoors

#_A1BC: LDA.b #$00
#_A1BE: STA.b $1D

#_A1C0: LDY.b $2B

#_A1C2: LDA.b ($5A),Y
#_A1C4: ASL A
#_A1C5: ROL.b $1D
#_A1C7: ASL A
#_A1C8: ROL.b $1D
#_A1CA: ADC.b #ObjectTileNames>>0
#_A1CC: STA.b $1C

#_A1CE: LDA.b #ObjectTileNames>>8
#_A1D0: ADC.b $1D
#_A1D2: STA.b $1D

#_A1D4: LDY.b #$00

#_A1D6: LDA.b $14
#_A1D8: CLC
#_A1D9: ADC.b $59
#_A1DB: AND.b #$08
#_A1DD: BEQ .left_half

#_A1DF: INY
#_A1E0: INY

.left_half
#_A1E1: LDA.b $06
#_A1E3: CLC
#_A1E4: ADC.b $58
#_A1E6: AND.b #$08
#_A1E8: BEQ .left_tile

#_A1EA: INY

.left_tile
#_A1EB: LDA.b ($1C),Y

#_A1ED: RTS

;===================================================================================================

GetObjectTile_overworld:
#_A1EE: JSR GetObjectCoordinatesAndType_overworld

#_A1F1: LDA.b #$00
#_A1F3: STA.b $1D

#_A1F5: LDA.b $2B
#_A1F7: ASL A
#_A1F8: ROL.b $1D
#_A1FA: ASL A
#_A1FB: ROL.b $1D
#_A1FD: CLC
#_A1FE: ADC.b #OverworldObjectTiles>>0
#_A200: STA.b $1C

#_A202: LDA.b $1D
#_A204: ADC.b #OverworldObjectTiles>>8
#_A206: STA.b $1D

#_A208: LDY.b #$00

#_A20A: LDA.b $14
#_A20C: CLC
#_A20D: ADC.b $59
#_A20F: AND.b #$08
#_A211: BEQ .left_half

#_A213: INY
#_A214: INY

.left_half
#_A215: LDA.b $06
#_A217: CLC
#_A218: ADC.b $58
#_A21A: AND.b #$08
#_A21C: BEQ .left_tile

#_A21E: INY

.left_tile
#_A21F: LDA.b ($1C),Y

#_A221: RTS

;===================================================================================================

GetObjectCoordinates_inside:
#_A222: LDA.b $14
#_A224: AND.b #$0F
#_A226: CLC
#_A227: ADC.b $59
#_A229: LSR A
#_A22A: LSR A
#_A22B: LSR A
#_A22C: LSR A
#_A22D: CLC
#_A22E: ADC.b $16
#_A230: STA.b $2A

#_A232: LDA.b $06
#_A234: CLC
#_A235: ADC.b $58
#_A237: STA.b $1E

#_A239: LDA.b $00
#_A23B: AND.b #$01
#_A23D: ADC.b #$00
#_A23F: LSR A
#_A240: ROR.b $1E
#_A242: LSR.b $1E
#_A244: LSR.b $1E
#_A246: LSR.b $1E

#_A248: LDA.b $1E
#_A24A: STA.b $29

#_A24C: RTS

;===================================================================================================

GetObjectCoordinatesAndType_overworld:
#_A24D: LDA.b $14
#_A24F: AND.b #$0F
#_A251: CLC
#_A252: ADC.b $59
#_A254: LSR A
#_A255: LSR A
#_A256: LSR A
#_A257: LSR A
#_A258: CLC
#_A259: ADC.b $16
#_A25B: STA.b $2A

#_A25D: LDA.b $06
#_A25F: CLC
#_A260: ADC.b $58
#_A262: STA.b $1E

#_A264: LDA.b $00
#_A266: AND.b #$01
#_A268: ADC.b #$00
#_A26A: LSR A
#_A26B: ROR.b $1E
#_A26D: LSR.b $1E
#_A26F: LSR.b $1E
#_A271: LSR.b $1E

#_A273: LDA.b $1E
#_A275: STA.b $29

#_A277: JMP GetObjectType_overworld

;===================================================================================================

DrawMilon:
#_A27A: LDX.b #$04

#_A27C: LDA.b $49
#_A27E: BNE DrawSpecificMilon

#_A280: LDA.b $40
#_A282: TAX
#_A283: BNE .dont_check_for_up

#_A285: LDA.b $08 ; check for up press
#_A287: AND.b #$08
#_A289: BEQ DrawSpecificMilon

#_A28B: LDA.b $89
#_A28D: EOR.b #$01
#_A28F: ORA.b $52
#_A291: BEQ DrawSpecificMilon

#_A293: LDX.b #$06
#_A295: BNE DrawSpecificMilon

.dont_check_for_up
#_A297: STA.b $1C

#_A299: LDA.b $3C
#_A29B: AND.b #$03
#_A29D: CLC
#_A29E: ADC.b $1C
#_A2A0: TAX

#_A2A1: CPX.b #$04
#_A2A3: BNE DrawSpecificMilon

#_A2A5: LDX.b #$02

;===================================================================================================

DrawSpecificMilon:
#_A2A7: LDA.b $3C
#_A2A9: BPL DrawMilon_with_palette_0

#_A2AB: DEC.b $3D
#_A2AD: BEQ .change_size_over

#_A2AF: LDA.b $3C
#_A2B1: AND.b #$40
#_A2B3: BEQ .continue

#_A2B5: LDA.b $3D
#_A2B7: CMP.b #$40
#_A2B9: BCS .continue

#_A2BB: AND.b #$07
#_A2BD: BNE .continue

#_A2BF: LDA.b $52
#_A2C1: EOR.b #$01
#_A2C3: STA.b $52

#_A2C5: JMP .continue

.change_size_over
#_A2C8: LDA.b $3C
#_A2CA: AND.b #$03
#_A2CC: STA.b $3C

.continue
#_A2CE: LDA.b $3D
#_A2D0: LSR A
#_A2D1: LSR A
#_A2D2: AND.b #$01
#_A2D4: JMP DrawMilon_with_palette

;===================================================================================================

DrawMilon_with_palette_0:
#_A2D7: LDA.b #$00

;===================================================================================================

DrawMilon_with_palette:
#_A2D9: STA.b $53

;===================================================================================================

DrawMilon_preset_palette:
#_A2DB: LDA.b $43
#_A2DD: AND.b #$02
#_A2DF: LSR A
#_A2E0: STA.b $34

#_A2E2: LDA.b $3F
#_A2E4: STA.b $35

#_A2E6: LDA.b $3E
#_A2E8: STA.b $38

#_A2EA: JMP .start

;---------------------------------------------------------------------------------------------------

#MilonHeightDifference:
#_A2ED: db $09, $03

;---------------------------------------------------------------------------------------------------

.next
#_A2EF: LDA.b $35
#_A2F1: CLC
#_A2F2: ADC.b #$08
#_A2F4: STA.b $35

#_A2F6: TXA
#_A2F7: CLC
#_A2F8: ADC.b #$4B
#_A2FA: JMP DrawPreordainedSprite

.start
#_A2FD: LDA.b $53
#_A2FF: STA.b $32

#_A301: LDA.b $52
#_A303: BEQ .next

#_A305: TXA

;===================================================================================================

Draw2x3SpriteEnemy:
#_A306: LDX.b #$00
#_A308: STX.b $33
#_A30A: STA.b $36

;===================================================================================================

Draw2x3Sprite:
#_A30C: STX.b $76
#_A30E: STY.b $75

#_A310: LDA.b $34
#_A312: LSR A
#_A313: ROR A
#_A314: ROR A
#_A315: ORA.b $32
#_A317: STA.b $37

#_A319: LDA.b $34
#_A31B: BEQ .facing_right

#_A31D: LDA.b #$06

.facing_right
#_A31F: STA.b $1C

#_A321: LDA.b $36
#_A323: ASL A
#_A324: STA.b $1E

#_A326: ASL A
#_A327: ADC.b $1E
#_A329: STA.b $1E ; x6

#_A32B: LDX.b $36

#_A32D: LDA.w .flipping_offset,X
#_A330: STA.b $1F

#_A332: LDA.b #$00
#_A334: STA.b $1D

;---------------------------------------------------------------------------------------------------

.next_object
#_A336: LDX.b $1C

#_A338: LDA.w .tile_index,X
#_A33B: STA.b $22

#_A33D: CLC
#_A33E: ADC.b $1E
#_A340: TAX

#_A341: LDA.w .character,X
#_A344: STA.b $36

#_A346: LDX.b $1D

#_A348: LDA.b $38
#_A34A: CLC
#_A34B: ADC.w .offset_x,X
#_A34E: STA.b $38

#_A350: LDA.b $35
#_A352: CLC
#_A353: ADC.w .offset_y,X
#_A356: STA.b $35

#_A358: LDA.b $22
#_A35A: CLC
#_A35B: ADC.b $1F
#_A35D: TAX

#_A35E: LDA.b $37
#_A360: STA.b $22

#_A362: EOR.w .flip,X
#_A365: STA.b $37

#_A367: JSR AddObjectToBuffer

#_A36A: LDA.b $22
#_A36C: STA.b $37

#_A36E: INC.b $1C
#_A370: INC.b $1D

#_A372: LDA.b $1D
#_A374: CMP.b #$06
#_A376: BNE .next_object

;---------------------------------------------------------------------------------------------------

#_A378: LDX.b $76
#_A37A: LDY.b $75

#_A37C: RTS

;---------------------------------------------------------------------------------------------------

.offset_x
#_A37D: db $00, $00, $F0, $00, $F0, $00

.offset_y
#_A383: db $00, $00, $08, $00, $08, $00

.tile_index
#_A389: db $00, $01, $02, $03, $04, $05
#_A38F: db $01, $00, $03, $02, $05, $04

;---------------------------------------------------------------------------------------------------

.flip
#_A395: db $00, $00, $00, $00, $00, $00 ; 00
#_A39B: db $00, $40, $00, $40, $00, $40 ; 06
#_A3A1: db $00, $40, $00, $00, $00, $00 ; 0C
#_A3A7: db $40, $40, $C0, $C0, $80, $C0 ; 12
#_A3AD: db $00, $80, $00, $00, $C0, $C0 ; 18
#_A3B3: db $00, $40, $00, $80, $00, $00 ; 1E
#_A3B9: db $C0, $00, $40, $80, $80, $80 ; 24
#_A3BF: db $00, $00, $00, $80, $80, $C0 ; 2A
#_A3C5: db $40, $40, $00, $00, $80, $80 ; 30
#_A3CB: db $40, $00, $40, $00, $80, $80 ; 36
#_A3D1: db $00, $00, $00, $00, $80, $C0 ; 3C

.character
#_A3D7: db $D0, $D1, $E8, $E9, $F8, $F9 ; 00 - Milon standing
#_A3DD: db $D0, $D1, $E0, $E1, $F0, $F1 ; 01 - Milon walking
#_A3E3: db $D2, $D3, $E2, $E3, $F2, $F3 ; 02 - Milon walking
#_A3E9: db $D0, $D1, $E4, $E5, $F4, $F5 ; 03 - Milon walking
#_A3EF: db $D0, $D1, $E6, $E7, $F6, $F7 ; 04 - Milon walking
#_A3F5: db $C0, $C0, $C1, $C1, $C2, $C2 ; 05 - Milon dying
#_A3FB: db $D0, $D1, $E8, $E9, $F8, $F9 ; 06 - Milon standing
#_A401: db $86, $87, $96, $97, $8C, $8D ; 07 - Princess
#_A407: db $6E, $6E, $7E, $7E, $8E, $8E ; 08 - Crow closed
#_A40D: db $9E, $9E, $AE, $AE, $BE, $BE ; 09 - Crow open
#_A413: db $84, $85, $94, $95, $8A, $8B ; 0A - Fire
#_A419: db $2F, $C6, $A4, $A5, $B4, $B5 ; 0B - Homa parts
#_A41F: db $2F, $D9, $2F, $86, $2F, $96 ; 0C - Homa parts
#_A425: db $C7, $2F, $D7, $D8, $97, $A7 ; 0D - Homa parts
#_A42B: db $2F, $D6, $C4, $C5, $D4, $D5 ; 0E - Homa parts
#_A431: db $2F, $D9, $2F, $86, $2F, $B6 ; 0F - Homa parts
#_A437: db $C7, $2F, $D7, $D8, $B7, $87 ; 10 - Homa parts
#_A43D: db $BC, $BD, $CC, $CD, $DC, $DD ; 11 - Homa parts
#_A443: db $A0, $A1, $B0, $B1, $15, $16 ; 12 - Kama parts
#_A449: db $DA, $DB, $2F, $EA, $FA, $FB ; 13 - Kama parts
#_A44F: db $35, $2F, $EB, $EC, $FC, $2F ; 14 - Kama parts
#_A455: db $A2, $A3, $B2, $B3, $18, $C3 ; 15 - Kama parts
#_A45B: db $DE, $DF, $EE, $EF, $FE, $FF ; 16 - Kama parts
#_A461: db $35, $2F, $AB, $AC, $BB, $2F ; 17 - Kama parts
#_A467: db $2F, $22, $21, $32, $31, $B5 ; 18 - Barukama parts
#_A46D: db $2F, $AD, $2F, $86, $2F, $0A ; 19 - Barukama parts
#_A473: db $C7, $2F, $D7, $D8, $0B, $AA ; 1A - Barukama parts
#_A479: db $2F, $24, $23, $34, $33, $B5 ; 1B - Barukama parts
#_A47F: db $2F, $AD, $2F, $A6, $2F, $1E ; 1C - Barukama parts
#_A485: db $C7, $2F, $D7, $D8, $1F, $BA ; 1D - Barukama parts
#_A48B: db $98, $8A, $26, $27, $36, $37 ; 1E - Doma parts
#_A491: db $8B, $98, $47, $28, $48, $38 ; 1F - Doma parts
#_A497: db $38, $49, $28, $49, $98, $9B ; 20 - Doma parts
#_A49D: db $49, $28, $49, $28, $9A, $99 ; 21 - Doma parts
#_A4A3: db $99, $9A, $29, $27, $39, $3A ; 22 - Doma parts
#_A4A9: db $9B, $98, $47, $28, $47, $28 ; 23 - Doma parts
#_A4AF: db $28, $49, $28, $49, $99, $9A ; 24 - Doma parts
#_A4B5: db $48, $38, $27, $28, $9B, $98 ; 25 - Doma parts
#_A4BB: db $98, $9B, $29, $27, $36, $37 ; 26 - Doma parts
#_A4C1: db $9A, $99, $47, $38, $48, $28 ; 27 - Doma parts
#_A4C7: db $28, $27, $38, $27, $98, $8A ; 28 - Doma parts
#_A4CD: db $27, $28, $47, $38, $8B, $98 ; 29 - Doma parts

;---------------------------------------------------------------------------------------------------

.flipping_offset
#_A4D3: db $00 ; 00
#_A4D4: db $00 ; 01
#_A4D5: db $00 ; 02
#_A4D6: db $00 ; 03
#_A4D7: db $00 ; 04
#_A4D8: db $06 ; 05
#_A4D9: db $00 ; 06
#_A4DA: db $00 ; 07
#_A4DB: db $06 ; 08
#_A4DC: db $06 ; 09
#_A4DD: db $00 ; 0A
#_A4DE: db $00 ; 0B
#_A4DF: db $00 ; 0C
#_A4E0: db $00 ; 0D
#_A4E1: db $00 ; 0E
#_A4E2: db $00 ; 0F
#_A4E3: db $00 ; 10
#_A4E4: db $00 ; 11
#_A4E5: db $00 ; 12
#_A4E6: db $00 ; 13
#_A4E7: db $00 ; 14
#_A4E8: db $00 ; 15
#_A4E9: db $00 ; 16
#_A4EA: db $00 ; 17
#_A4EB: db $00 ; 18
#_A4EC: db $00 ; 19
#_A4ED: db $00 ; 1A
#_A4EE: db $00 ; 1B
#_A4EF: db $00 ; 1C
#_A4F0: db $00 ; 1D
#_A4F1: db $00 ; 1E
#_A4F2: db $0C ; 1F
#_A4F3: db $12 ; 20
#_A4F4: db $18 ; 21
#_A4F5: db $00 ; 22
#_A4F6: db $1E ; 23
#_A4F7: db $24 ; 24
#_A4F8: db $2A ; 25
#_A4F9: db $0C ; 26
#_A4FA: db $30 ; 27
#_A4FB: db $36 ; 28
#_A4FC: db $3C ; 29

;===================================================================================================

ShootBubbles:
#_A4FD: LDA.b $3D
#_A4FF: BNE .exit

#_A501: LDA.b $08
#_A503: TAX

#_A504: AND.b #$40
#_A506: BNE .pressed_b

#_A508: LDA.b $09
#_A50A: AND.b #$BF
#_A50C: STA.b $09

.pressed_b
#_A50E: TXA
#_A50F: AND.b #$40
#_A511: BEQ .exit

#_A513: LDA.b $09
#_A515: TAX
#_A516: AND.b #$40
#_A518: BNE .exit

#_A51A: TXA
#_A51B: ORA.b #$40
#_A51D: STA.b $09

#_A51F: LDA.b $9B
#_A521: AND.b #$03
#_A523: TAX

;---------------------------------------------------------------------------------------------------

.next_bubble
#_A524: LDA.b $78,X
#_A526: BEQ .free_slot

#_A528: DEX
#_A529: BPL .next_bubble

.exit
#_A52B: RTS

;---------------------------------------------------------------------------------------------------

.free_slot
#_A52C: LDA.b #$11 ; SFX 11
#_A52E: STA.b $E6

#_A530: LDA.b #$01
#_A532: STA.b $78,X

#_A534: TXA
#_A535: ASL A
#_A536: STA.b $1C

#_A538: ASL A
#_A539: ADC.b $1C
#_A53B: TAX

#_A53C: LDA.b $08
#_A53E: AND.b #$04
#_A540: LSR A
#_A541: STA.w $0710,X

#_A544: LDA.b $43
#_A546: AND.b #$02
#_A548: LSR A
#_A549: PHP

#_A54A: ORA.w $0710,X
#_A54D: STA.w $0710,X

#_A550: PLP
#_A551: BEQ .add

#_A553: LDA.b $3E
#_A555: SEC
#_A556: SBC.b #$08
#_A558: STA.w $0712,X
#_A55B: BCS .continue

.add
#_A55D: LDA.b $3E
#_A55F: CLC
#_A560: ADC.b #$08
#_A562: STA.w $0712,X

.continue
#_A565: LDA.b $3F
#_A567: CLC
#_A568: ADC.b #$04
#_A56A: STA.w $0714,X

#_A56D: LDA.b #$00
#_A56F: STA.w $0711,X

#_A572: RTS

;===================================================================================================

HandleBubbles:
#_A573: LDX.b #$02

.next
#_A575: LDA.b $78,X
#_A577: BEQ .skip

#_A579: STX.b $76
#_A57B: STA.b $77

#_A57D: JSR LoadBubbleVars

#_A580: JSR DrawBubble
#_A583: JSR OperateBubble

#_A586: JSR SaveBubbleVars

#_A589: JSR CheckBubbleObjectHit

#_A58C: LDX.b $76

.skip
#_A58E: DEX
#_A58F: BPL .next

#_A591: RTS

;===================================================================================================

CheckBubbleObjectHit:
#_A592: LDA.b $B4 ; no object interactions in boss rooms
#_A594: ORA.b $8A ; or on overworld
#_A596: BNE .hit_nothing

#_A598: LDA.b $77
#_A59A: BEQ .hit_nothing

#_A59C: LDX.b #$02

#_A59E: LDA.b #$01
#_A5A0: BIT.b $5F
#_A5A2: BNE .thin_hitbox

#_A5A4: LDX.b #$0E

.thin_hitbox
#_A5A6: TXA
#_A5A7: CLC
#_A5A8: ADC.b $61
#_A5AA: JSR ApplyBigXCoordinateChange

#_A5AD: LDX.b #$04

#_A5AF: LDA.b #$02
#_A5B1: BIT.b $5F
#_A5B3: BEQ .short_hitbox

#_A5B5: LDX.b #$0C

.short_hitbox
#_A5B7: TXA
#_A5B8: CLC
#_A5B9: ADC.b $63
#_A5BB: JSR ApplyBigYCoordinateChange

;---------------------------------------------------------------------------------------------------

#_A5BE: JSR FullCoordinatesToTilemapXY

#_A5C1: JSR SummonTheHudsonBee
#_A5C4: JSR RevealSecretDoor

#_A5C7: JSR GetObjectType_indoors

#_A5CA: LDA.b $2B ; OBJECT 00
#_A5CC: BEQ .hit_nothing

#_A5CE: CMP.b #$1E ; OBJECT 1E
#_A5D0: BCS .hit_nothing

#_A5D2: CMP.b #$18 ; OBJECT 18
#_A5D4: BCS .hit_something

.hit_nothing
#_A5D6: RTS

.hit_something
#_A5D7: INC.w $07BC ; increment hit counter

#_A5DA: JSR HitBlockWithBubble

#_A5DD: LDA.b #$05 ; SFX 05
#_A5DF: STA.b $E6

#_A5E1: JSR ChangeObjectType
#_A5E4: JSR RedrawObject
#_A5E7: JSR MakeBubbleExplode

;===================================================================================================

PopBubble:
#_A5EA: LDX.b $76

#_A5EC: LDA.b #$08
#_A5EE: STA.b $78,X

#_A5F0: RTS

;===================================================================================================

#MakeBubbleExplode:
#_A5F1: LDA.b $29
#_A5F3: STA.b $61

#_A5F5: LDA.b $2A
#_A5F7: STA.b $63

#_A5F9: JSR TilemapXYtoFullCoordinates

#_A5FC: JSR IsAbsoluteOnScreen
#_A5FF: BCS PopBubble

#_A601: LDA.b #$01
#_A603: JMP SpawnSmokePuff

;===================================================================================================

RevealSecretDoor:
#_A606: JSR CheckDoorLocations
#_A609: BCC .continue

#_A60B: RTS

.continue
#_A60C: INC.b $2A
#_A60E: STX.b $75

#_A610: JSR GetObjectType_indoors

#_A613: LDA.b $2B ; skip over tangible objects
#_A615: CMP.b #$08 ; OBJECT 08
#_A617: BCS .exit

#_A619: LDX.b $75

#_A61B: INC.b $9F,X

#_A61D: LDA.b #$09 ; OBJECT 09
#_A61F: STA.b $2B

#_A621: JSR RedrawObject
#_A624: JSR ChangeObjectType
#_A627: JSR MakeBubbleExplode

#_A62A: DEC.b $2A
#_A62C: DEC.b $2B ; OBJECT 08

#_A62E: JSR RedrawObject
#_A631: JSR ChangeObjectType
#_A634: JSR MakeBubbleExplode

#_A637: LDX.b $76

#_A639: LDA.b #$08
#_A63B: STA.b $78,X

.exit
#_A63D: RTS

;===================================================================================================

HitBlockWithBubble:
#_A63E: CMP.b #$1C ; OBJECT 1C
#_A640: BCS .special_reveal

#_A642: CMP.b #$18 ; OBJECT 18
#_A644: BNE .no_paint

#_A646: LDX.w $07A5 ; paint
#_A649: BEQ .no_paint

#_A64B: LDX.b $87
#_A64D: CPX.b #$0C ; ROOM 0C
#_A64F: BEQ .painted_tile

#_A651: CPX.b #$0D ; ROOM 0D
#_A653: BEQ .painted_tile

;---------------------------------------------------------------------------------------------------

.no_paint
#_A655: SEC
#_A656: SBC.b #$18 ; OBJECT 18
#_A658: STA.b $1C

#_A65A: LDA.b $87
#_A65C: ASL A
#_A65D: ASL A
#_A65E: ADC.b $1C
#_A660: TAX

#_A661: LDA.w HiddenObjectReveals-4,X
#_A664: STA.b $2B

#_A666: RTS

;---------------------------------------------------------------------------------------------------

.special_reveal
#_A667: CLC
#_A668: ADC.b #$02
#_A66A: STA.b $2B

#_A66C: JSR CheckIfObjectIsCollected
#_A66F: BEQ .exit

#_A671: LDA.b #$00 ; OBJECT 00
#_A673: STA.b $2B

.exit
#_A675: RTS

;---------------------------------------------------------------------------------------------------

.painted_tile
#_A676: LDA.b #$13 ; OBJECT 13
#_A678: STA.b $2B

#_A67A: RTS

;===================================================================================================

CheckDoorLocations:
#_A67B: LDX.b #$01

.check_next
#_A67D: LDA.b $29
#_A67F: CMP.w $07D7,X
#_A682: BNE .no_match

#_A684: LDA.b $2A
#_A686: CMP.w $07D9,X
#_A689: BNE .no_match

#_A68B: CLC

#_A68C: RTS

.no_match
#_A68D: DEX
#_A68E: BPL .check_next

#_A690: SEC

#_A691: RTS

;===================================================================================================

SummonTheHudsonBee:
#_A692: LDA.w $07BB
#_A695: BNE .exit

#_A697: LDA.b $29
#_A699: CMP.w $07B9
#_A69C: BNE .exit

#_A69E: LDA.b $2A
#_A6A0: CMP.w $07BA
#_A6A3: BNE .exit

#_A6A5: JSR IsBeeOnScreenX
#_A6A8: BCS .exit

#_A6AA: JSR CheckIfBeeIsHere
#_A6AD: BNE .exit

#_A6AF: LDA.b #$0B ; SFX 0B
#_A6B1: STA.b $E6

#_A6B3: LDA.b #$1A ; SPRITE 1A
#_A6B5: JSR SpawnSprite
#_A6B8: BCS .exit

#_A6BA: LDA.b $43
#_A6BC: AND.b #$02
#_A6BE: LSR A
#_A6BF: STA.w $0606,X

#_A6C2: LDA.b #$01
#_A6C4: STA.w $07BB
#_A6C7: JSR GetBitIndexForRoom

#_A6CA: LDA.w $07C5,X
#_A6CD: ORA.w BitTable,Y
#_A6D0: STA.w $07C5,X

.exit
#_A6D3: RTS

;===================================================================================================

CheckIfBeeIsHere:
#_A6D4: JSR GetBitIndexForRoom

#_A6D7: LDA.w $07C5,X
#_A6DA: AND.w BitTable,Y

#_A6DD: RTS

;===================================================================================================

GetBitIndexForRoom:
#_A6DE: LDA.b $87
#_A6E0: PHA

#_A6E1: LSR A
#_A6E2: LSR A
#_A6E3: LSR A
#_A6E4: TAX
#_A6E5: PLA

#_A6E6: AND.b #$07
#_A6E8: TAY

#_A6E9: RTS

;===================================================================================================
; Mostly. Is actually checking bubble.
;===================================================================================================
IsBeeOnScreenX:
#_A6EA: LDX.b $76

#_A6EC: LDA.b $7B,X
#_A6EE: SEC
#_A6EF: SBC.b $3E
#_A6F1: BCC .check_right_edge

#_A6F3: CMP.b #$18
#_A6F5: BCS .on_screen

#_A6F7: SEC
#_A6F8: RTS

.check_right_edge
#_A6F9: CMP.b #$E8
#_A6FB: RTS

.on_screen
#_A6FC: CLC
#_A6FD: RTS

;===================================================================================================

AdjustCoordinatesWithScroll:
#_A6FE: LDA.b $61
#_A700: CLC
#_A701: ADC.b $A8
#_A703: STA.b $61

#_A705: LDA.b $63
#_A707: CLC
#_A708: ADC.b $A7
#_A70A: STA.b $63

#_A70C: RTS

;===================================================================================================

OperateBubble:
#_A70D: JSR AdjustCoordinatesWithScroll

#_A710: LDA.b $77
#_A712: CMP.b #$08
#_A714: BCS .exploding

#_A716: LDA.b #$02
#_A718: BIT.b $5F
#_A71A: BNE .moving_down

#_A71C: DEC.b $63
#_A71E: DEC.b $63

.moving_down
#_A720: INC.b $63

#_A722: LDA.b $63
#_A724: CMP.b #$E0
#_A726: BCS .pop_bubble

;---------------------------------------------------------------------------------------------------

#_A728: LDA.b #$01
#_A72A: BIT.b $5F
#_A72C: BNE .moving_left

#_A72E: LDA.b #$03
#_A730: CLC
#_A731: ADC.b $61
#_A733: STA.b $61

#_A735: JMP .check_on_screen_x

.moving_left
#_A738: LDA.b $61
#_A73A: SEC
#_A73B: SBC.b #$03
#_A73D: STA.b $61

.check_on_screen_x
#_A73F: CMP.b #$F0
#_A741: BCS .undraw

#_A743: INC.b $60

#_A745: LDA.b $B7 ; check crystal 3
#_A747: AND.b #$20 ; 8 extra frames for crystal 3
#_A749: LSR A
#_A74A: LSR A
#_A74B: ADC.b #$12 ; 18 or 26 frames
#_A74D: CMP.b $60
#_A74F: BEQ .pop_bubble

#_A751: RTS

;---------------------------------------------------------------------------------------------------

.pop_bubble
#_A752: LDA.b #$08

.cache_and_leave
#_A754: LDY.b $76

#_A756: STA.w $0078,Y
#_A759: STA.b $77

#_A75B: RTS

;---------------------------------------------------------------------------------------------------

.exploding
#_A75C: CLC
#_A75D: ADC.b #$01
#_A75F: CMP.b #$0A
#_A761: BCC .cache_and_leave

.undraw
#_A763: LDA.b #$00
#_A765: BEQ .cache_and_leave

;===================================================================================================

DrawBubble:
#_A767: LDA.b #$00
#_A769: STA.b $34

#_A76B: LDA.b $61
#_A76D: STA.b $38

#_A76F: LDX.b $76
#_A771: STA.b $7B,X

#_A773: LDA.b $63
#_A775: STA.b $35
#_A777: STA.b $7E,X

#_A779: LDA.b $77
#_A77B: CMP.b #$08
#_A77D: BCS .grab_character

#_A77F: LDA.w $07A7 ; excalibur
#_A782: BNE .have_excalibur

#_A784: LDX.b #$02

#_A786: LDA.b $B7
#_A788: AND.b #$40 ; check crystal 2
#_A78A: BNE .have_crystal_2

#_A78C: LDX.b #$00

.have_crystal_2
#_A78E: STX.b $1C

#_A790: LDA.b $60
#_A792: AND.b #$01
#_A794: CLC
#_A795: ADC.b $1C
#_A797: BCC .grab_character

.have_excalibur
#_A799: LDA.w $07D5
#_A79C: CLC
#_A79D: ADC.b #$04

.grab_character
#_A79F: TAY

#_A7A0: LDA.w BubbleCharacters,Y
#_A7A3: JMP DrawPredefinedSprite

;---------------------------------------------------------------------------------------------------

BubbleCharacters:
#_A7A6: db $14 ; 00 - small bubble contracted
#_A7A7: db $15 ; 01 - small bubble normal
#_A7A8: db $56 ; 02 - big bubble contracted
#_A7A9: db $57 ; 03 - big bubble normal
#_A7AA: db $3D ; 04 - excalibur frame 1
#_A7AB: db $3E ; 05 - excalibur frame 2
#_A7AC: db $3F ; 06 - excalibur frame 3
#_A7AD: db $00 ; 07 - popped bubble contracted
#_A7AE: db $00 ; 08 - popped bubble contracted
#_A7AF: db $01 ; 09 - popped bubble normal

;===================================================================================================

LoadBubbleVars:
#_A7B0: TXA ; get X * 6
#_A7B1: ASL A
#_A7B2: ASL A
#_A7B3: ADC.b $76
#_A7B5: ADC.b $76
#_A7B7: STA.b $6B

#_A7B9: TAX

#_A7BA: LDY.b #$00

.next
#_A7BC: LDA.w $0710,X
#_A7BF: STA.w $005F,Y

#_A7C2: INX

#_A7C3: INY
#_A7C4: CPY.b #$06
#_A7C6: BNE .next

#_A7C8: RTS

;===================================================================================================

SaveBubbleVars:
#_A7C9: LDX.b $6B
#_A7CB: LDY.b #$00

.next
#_A7CD: LDA.w $005F,Y
#_A7D0: STA.w $0710,X

#_A7D3: INX

#_A7D4: INY
#_A7D5: CPY.b #$06
#_A7D7: BNE .next

#_A7D9: RTS

;===================================================================================================

FlagObjectAsCollected:
#_A7DA: LDA.b $2A
#_A7DC: ASL A
#_A7DD: ASL A
#_A7DE: STA.b $1C

#_A7E0: LDA.b $29
#_A7E2: LSR A
#_A7E3: LSR A
#_A7E4: LSR A
#_A7E5: CLC
#_A7E6: ADC.b $1C
#_A7E8: TAX

#_A7E9: LDA.b $29
#_A7EB: AND.b #$07
#_A7ED: TAY

#_A7EE: LDA.w $0722,X
#_A7F1: ORA.w BitTable,Y
#_A7F4: STA.w $0722,X

#_A7F7: RTS

;===================================================================================================

CheckIfObjectIsCollected:
#_A7F8: LDA.b $2A
#_A7FA: ASL A
#_A7FB: ASL A
#_A7FC: STA.b $1C

#_A7FE: LDA.b $29
#_A800: LSR A
#_A801: LSR A
#_A802: LSR A
#_A803: CLC
#_A804: ADC.b $1C
#_A806: TAX

#_A807: LDA.b $29
#_A809: AND.b #$07
#_A80B: TAY

#_A80C: LDA.w $0722,X
#_A80F: AND.w BitTable,Y

#_A812: RTS

;===================================================================================================

AttemptKeySpawn:
#_A813: LDA.b $87
#_A815: CMP.b #$09 ; ROOM 09
#_A817: BCS .no_key_for_you

#_A819: LDA.w $07BF
#_A81C: BNE .no_key_for_you

#_A81E: LDA.w $07BD
#_A821: CMP.b #$04
#_A823: BCC .no_key_for_you

#_A825: LDA.w $07BC
#_A828: LDX.b #$00
#_A82A: CMP.b #$0F
#_A82C: BCS .spawn_key

#_A82E: LDA.w $07BE
#_A831: LDX.b #$02
#_A833: CMP.b #$05
#_A835: BCS .spawn_key

.no_key_for_you
#_A837: RTS

;---------------------------------------------------------------------------------------------------

.spawn_key
#_A838: LDA.b $87
#_A83A: ASL A
#_A83B: ASL A
#_A83C: STA.b $1C

#_A83E: TXA
#_A83F: CLC
#_A840: ADC.b $1C
#_A842: TAX

#_A843: LDA.b #$00
#_A845: STA.b $62
#_A847: STA.b $64

#_A849: LDA.w KeyLocations-4,X
#_A84C: ASL A
#_A84D: ASL A
#_A84E: ASL A
#_A84F: ASL A
#_A850: STA.b $61

#_A852: ROL.b $62

#_A854: LDA.w KeyLocations-3,X
#_A857: ASL A
#_A858: ASL A
#_A859: ASL A
#_A85A: ASL A
#_A85B: STA.b $63

#_A85D: ROL.b $64

#_A85F: LDA.b #$1B ; SPRITE 1B
#_A861: JSR SpawnSprite
#_A864: BCS .exit

#_A866: LDA.b #$01
#_A868: STA.w $07BF

#_A86B: LDA.b #$09 ; SFX 09
#_A86D: STA.b $E6

.exit
#_A86F: RTS

;===================================================================================================
; A lot of these are recursive, meaning they update each frame
; (because they keep resetting the bubble)
;===================================================================================================
HiddenObjectReveals:

; ROOM 01
#_A870: db $00 ; OBJECT 18 => OBJECT 00
#_A871: db $19 ; OBJECT 19 => OBJECT 19
#_A872: db $1B ; OBJECT 1A => OBJECT 1B
#_A873: db $1D ; OBJECT 1B => OBJECT 1D

; ROOM 02
#_A874: db $00 ; OBJECT 18 => OBJECT 00
#_A875: db $00 ; OBJECT 19 => OBJECT 00
#_A876: db $1B ; OBJECT 1A => OBJECT 1B
#_A877: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 03
#_A878: db $00 ; OBJECT 18 => OBJECT 00
#_A879: db $00 ; OBJECT 19 => OBJECT 00
#_A87A: db $1B ; OBJECT 1A => OBJECT 1B
#_A87B: db $17 ; OBJECT 1B => OBJECT 17

; ROOM 04
#_A87C: db $00 ; OBJECT 18 => OBJECT 00
#_A87D: db $00 ; OBJECT 19 => OBJECT 00
#_A87E: db $1B ; OBJECT 1A => OBJECT 1B
#_A87F: db $17 ; OBJECT 1B => OBJECT 17

; ROOM 05
#_A880: db $00 ; OBJECT 18 => OBJECT 00
#_A881: db $1A ; OBJECT 19 => OBJECT 1A
#_A882: db $1B ; OBJECT 1A => OBJECT 1B
#_A883: db $1D ; OBJECT 1B => OBJECT 1D

; ROOM 06
#_A884: db $00 ; OBJECT 18 => OBJECT 00
#_A885: db $17 ; OBJECT 19 => OBJECT 17
#_A886: db $1B ; OBJECT 1A => OBJECT 1B
#_A887: db $1D ; OBJECT 1B => OBJECT 1D

; ROOM 07
#_A888: db $00 ; OBJECT 18 => OBJECT 00
#_A889: db $00 ; OBJECT 19 => OBJECT 00
#_A88A: db $00 ; OBJECT 1A => OBJECT 00
#_A88B: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 08
#_A88C: db $00 ; OBJECT 18 => OBJECT 00
#_A88D: db $18 ; OBJECT 19 => OBJECT 18
#_A88E: db $00 ; OBJECT 1A => OBJECT 00
#_A88F: db $1E ; OBJECT 1B => OBJECT 1E - This is why the money respawns

; ROOM 09
#_A890: db $00 ; OBJECT 18 => OBJECT 00
#_A891: db $00 ; OBJECT 19 => OBJECT 00
#_A892: db $00 ; OBJECT 1A => OBJECT 00
#_A893: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 0A
#_A894: db $19 ; OBJECT 18 => OBJECT 19
#_A895: db $1A ; OBJECT 19 => OBJECT 1A
#_A896: db $00 ; OBJECT 1A => OBJECT 00
#_A897: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 0B
#_A898: db $00 ; OBJECT 18 => OBJECT 00
#_A899: db $00 ; OBJECT 19 => OBJECT 00
#_A89A: db $00 ; OBJECT 1A => OBJECT 00
#_A89B: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 0C
#_A89C: db $0A ; OBJECT 18 => OBJECT 0A
#_A89D: db $00 ; OBJECT 19 => OBJECT 00
#_A89E: db $1B ; OBJECT 1A => OBJECT 1B
#_A89F: db $19 ; OBJECT 1B => OBJECT 19

; ROOM 0D
#_A8A0: db $0A ; OBJECT 18 => OBJECT 0A
#_A8A1: db $00 ; OBJECT 19 => OBJECT 00
#_A8A2: db $1B ; OBJECT 1A => OBJECT 1B
#_A8A3: db $19 ; OBJECT 1B => OBJECT 19

; ROOM 0E
#_A8A4: db $00 ; OBJECT 18 => OBJECT 00
#_A8A5: db $00 ; OBJECT 19 => OBJECT 00
#_A8A6: db $19 ; OBJECT 1A => OBJECT 19
#_A8A7: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 0F
#_A8A8: db $00 ; OBJECT 18 => OBJECT 00
#_A8A9: db $00 ; OBJECT 19 => OBJECT 00
#_A8AA: db $00 ; OBJECT 1A => OBJECT 00
#_A8AB: db $1B ; OBJECT 1B => OBJECT 1B

; ROOM 10
#_A8AC: db $00 ; OBJECT 18 => OBJECT 00
#_A8AD: db $00 ; OBJECT 19 => OBJECT 00
#_A8AE: db $00 ; OBJECT 1A => OBJECT 00
#_A8AF: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 11
#_A8B0: db $00 ; OBJECT 18 => OBJECT 00
#_A8B1: db $00 ; OBJECT 19 => OBJECT 00
#_A8B2: db $00 ; OBJECT 1A => OBJECT 00
#_A8B3: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 12
#_A8B4: db $00 ; OBJECT 18 => OBJECT 00
#_A8B5: db $00 ; OBJECT 19 => OBJECT 00
#_A8B6: db $00 ; OBJECT 1A => OBJECT 00
#_A8B7: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 13
#_A8B8: db $00 ; OBJECT 18 => OBJECT 00
#_A8B9: db $00 ; OBJECT 19 => OBJECT 00
#_A8BA: db $00 ; OBJECT 1A => OBJECT 00
#_A8BB: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 14
#_A8BC: db $00 ; OBJECT 18 => OBJECT 00
#_A8BD: db $00 ; OBJECT 19 => OBJECT 00
#_A8BE: db $00 ; OBJECT 1A => OBJECT 00
#_A8BF: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 15
#_A8C0: db $00 ; OBJECT 18 => OBJECT 00
#_A8C1: db $00 ; OBJECT 19 => OBJECT 00
#_A8C2: db $00 ; OBJECT 1A => OBJECT 00
#_A8C3: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 16
#_A8C4: db $00 ; OBJECT 18 => OBJECT 00
#_A8C5: db $00 ; OBJECT 19 => OBJECT 00
#_A8C6: db $00 ; OBJECT 1A => OBJECT 00
#_A8C7: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 17
#_A8C8: db $00 ; OBJECT 18 => OBJECT 00
#_A8C9: db $00 ; OBJECT 19 => OBJECT 00
#_A8CA: db $00 ; OBJECT 1A => OBJECT 00
#_A8CB: db $00 ; OBJECT 1B => OBJECT 00

; ROOM 18
#_A8CC: db $00 ; OBJECT 18 => OBJECT 00
#_A8CD: db $00 ; OBJECT 19 => OBJECT 00
#_A8CE: db $00 ; OBJECT 1A => OBJECT 00
#_A8CF: db $00 ; OBJECT 1B => OBJECT 00

;===================================================================================================

KeyLocations:
;       A:  x    y    B:  x    y
#_A8D0: db $1E, $1C : db $13, $0A ; ROOM 01
#_A8D4: db $15, $14 : db $01, $0E ; ROOM 02
#_A8D8: db $1E, $13 : db $08, $11 ; ROOM 03
#_A8DC: db $01, $1C : db $1A, $1C ; ROOM 04
#_A8E0: db $1E, $1C : db $1E, $1C ; ROOM 05
#_A8E4: db $01, $0D : db $1D, $11 ; ROOM 06
#_A8E8: db $17, $13 : db $03, $02 ; ROOM 07
#_A8EC: db $01, $08 : db $16, $05 ; ROOM 08

;===================================================================================================

ApplyBigXCoordinateChange:
#_A8F0: CLC
#_A8F1: ADC.b $06
#_A8F3: STA.b $61

#_A8F5: LDA.b $00
#_A8F7: AND.b #$01
#_A8F9: ADC.b #$00
#_A8FB: STA.b $62

#_A8FD: RTS

;===================================================================================================

ApplyBigYCoordinateChange:
#_A8FE: LDX.b $14
#_A900: BNE .no_offset

#_A902: LDX.b $16
#_A904: BEQ .no_offset

#_A906: CLC
#_A907: ADC.b #$F0
#_A909: STA.b $63

#_A90B: LDA.b #$00
#_A90D: BEQ .do_high_byte

.no_offset
#_A90F: CLC
#_A910: ADC.b $14
#_A912: STA.b $63
#_A914: LDA.b #$00

.do_high_byte
#_A916: ADC.b #$00
#_A918: STA.b $64

#_A91A: RTS

;===================================================================================================

MilonShopping:
#_A91B: LDA.b #$01
#_A91D: STA.b $B9
#_A91F: STA.b $52

#_A921: LDA.b #$00
#_A923: STA.b $8A
#_A925: STA.b $B4
#_A927: STA.b $BE

#_A929: JSR FindShopID

#_A92C: LDX.w $07D4
#_A92F: DEX
#_A930: BNE .not_super_shoes_store

#_A932: INC.b $BC

.not_super_shoes_store
#_A934: LDA.b #$00
#_A936: STA.b $3A
#_A938: STA.b $49
#_A93A: STA.b $3C
#_A93C: STA.b $3D

#_A93E: JSR WaitForNMI

#_A941: LDA.b $29
#_A943: PHA

#_A944: LDA.b $2A
#_A946: PHA

#_A947: JSR ClearTilemapWith2F

#_A94A: LDA.b #$01 ; GFXBANK 01
#_A94C: STA.b $94

#_A94E: LDA.b #$00
#_A950: STA.w $07CF

#_A953: STA.b $06
#_A955: STA.b $07
#_A957: STA.b $0B

;---------------------------------------------------------------------------------------------------

#_A959: LDA.b $00
#_A95B: AND.b #$80
#_A95D: ORA.b #$10
#_A95F: JSR SetPPUCTRL

#_A962: LDA.b #$B0 ; seems to be some unused pointer
#_A964: STA.b $5B  ; probably the old location of ShopBGPalettes

#_A966: LDA.b #$C9
#_A968: STA.b $5A

#_A96A: LDX.b #$0F

.next_color
#_A96C: LDA.w ShopBGPalettes,X
#_A96F: STA.w $05E0,X

#_A972: DEX
#_A973: BPL .next_color

#_A975: LDY.b #$04
#_A977: JSR LoadScarySpritePalette

;---------------------------------------------------------------------------------------------------

#_A97A: LDA.b #ShopRoomTiles>>0
#_A97C: STA.b $1E
#_A97E: LDA.b #ShopRoomTiles>>8
#_A980: STA.b $1F

#_A982: LDA.b #$02 ; number of tiles per strip
#_A984: STA.b $20

#_A986: JSR DrawSmallRoom

#_A989: JSR DrawMilonsItems
#_A98C: JSR ReloadDefaultSpritePalettes

;---------------------------------------------------------------------------------------------------

#_A98F: LDA.b #$23 ; VRAM $23C0
#_A991: LDX.b #$C0
#_A993: JSR SetPPUADDRSafely

#_A996: LDX.b #$00

.next_tile
#_A998: LDA.w ShopTileAttributes,X
#_A99B: STA.w PPUDATA

#_A99E: INX
#_A99F: CPX.b #$40
#_A9A1: BNE .next_tile

;---------------------------------------------------------------------------------------------------

#_A9A3: LDA.b #$00
#_A9A5: STA.b $78
#_A9A7: STA.b $79
#_A9A9: STA.b $7A

#_A9AB: JSR DrawShopStock
#_A9AE: JSR DrawCrystalTracker
#_A9B1: JSR DrawShopDollarSigns

#_A9B4: JSR ForceMilonToEntryPosition_X78
#_A9B7: STA.b $80

#_A9B9: JSR NextFrameWithUpdates
#_A9BC: JSR NextFrameWithBGandOAM
#_A9BF: JSR EnableSpriteDraw

#_A9C2: LDX.w $07D4
#_A9C5: LDY.w ShopWelcomeMessage,X
#_A9C8: JSR HandleShopText

;---------------------------------------------------------------------------------------------------

.next_frame
#_A9CB: JSR WaitForNMIthenClearOAM

#_A9CE: JSR DrawBeeShield
#_A9D1: JSR DrawMilon
#_A9D4: JSR DrawHealthBar

#_A9D7: JSR SmallRoomMilon

#_A9DA: JSR HandleBarnabyText
#_A9DD: JSR AnimateBarnaby
#_A9E0: JSR DrawMoneyInShop

#_A9E3: JSR DrawShopButtons
#_A9E6: JSR HandleShopPurchase

#_A9E9: JSR ResetNMIFlags

#_A9EC: LDA.b $3E
#_A9EE: CMP.b #$F0
#_A9F0: BCC .next_frame

;---------------------------------------------------------------------------------------------------

#_A9F2: LDA.b #$00
#_A9F4: STA.b $B9

#_A9F6: PLA
#_A9F7: STA.b $2A

#_A9F9: PLA
#_A9FA: STA.b $29

#_A9FC: RTS

;===================================================================================================
; This is so dumb
;===================================================================================================
FindShopID:
#_A9FD: LDX.w $07C2 ; ROOM 00
#_AA00: BEQ .use_set_b

#_AA02: CPX.b #$01 ; ROOM 01
#_AA04: BEQ .use_set_c

#_AA06: CPX.b #$04 ; ROOM 04
#_AA08: BEQ .use_set_c

#_AA0A: CPX.b #$05 ; ROOM 05
#_AA0C: BEQ .use_set_b

#_AA0E: TXA

.user_set_a
#_AA0F: LDY.b #$00
#_AA11: BEQ .find_index

.use_set_b
#_AA13: LDY.b #$0C
#_AA15: BNE .search_by_x_position

.use_set_c
#_AA17: LDY.b #$18

;---------------------------------------------------------------------------------------------------

.search_by_x_position
#_AA19: LDA.b $8C ; get tilemap X position of return point

.find_index
#_AA1B: CMP.w ShopIDAssociation+0,Y
#_AA1E: BEQ .found

#_AA20: INY
#_AA21: BNE .find_index

.found
#_AA23: LDX.w ShopIDAssociation+6,Y
#_AA26: STX.w $07D4

#_AA29: RTS

;---------------------------------------------------------------------------------------------------

ShopIDAssociation:
; set A
#_AA2A: db $0F, $02, $06, $08, $07, $12 ; ROOM ID
#_AA30: db $06, $07, $0A, $0C, $0D, $0E ; Shop ID

; set B
#_AA36: db $0D, $10, $11, $0E, $1F, $63 ; Tilemap X
#_AA3C: db $02, $03, $0B, $04, $05, $63 ; Shop ID

; set C
#_AA42: db $16, $05, $02, $1E, $63, $63 ; Tilemap X
#_AA48: db $00, $01, $08, $09           ; Shop ID

;===================================================================================================

ForceMilonToEntryPosition_X78:
#_AA4C: LDA.b #$78

;===================================================================================================

ForceMilonToEntryPosition:
#_AA4E: STA.b $3E
#_AA50: STA.b $4B

#_AA52: LDA.b #$B8
#_AA54: STA.b $3F
#_AA56: STA.b $4D

#_AA58: LDA.b #$00
#_AA5A: STA.b $4C
#_AA5C: STA.b $4E

#_AA5E: RTS

;===================================================================================================

HandleShopPurchase:
#_AA5F: LDY.b $82

#_AA61: LDA.w $0078,Y
#_AA64: CMP.b #$08
#_AA66: BNE .exit

#_AA68: LDA.b $80
#_AA6A: CMP.b #$01
#_AA6C: BEQ .continue

.exit
#_AA6E: RTS

;---------------------------------------------------------------------------------------------------

.continue
#_AA6F: DEC.b $81
#_AA71: BMI .done_taking_money

#_AA73: LDA.b #$16 ; SFX 16
#_AA75: STA.b $E6

#_AA77: LDA.b #$01
#_AA79: JSR RemoveCurrency

#_AA7C: LDA.b $81
#_AA7E: BNE .exit

.done_taking_money
#_AA80: LDA.b #$00
#_AA82: STA.b $80

#_AA84: LDA.b $82
#_AA86: BNE .not_item_1

#_AA88: LDX.w $07D4
#_AA8B: LDY.w ShopItem1,X
#_AA8E: BNE .handle_text

;---------------------------------------------------------------------------------------------------

.not_item_1
#_AA90: CMP.b #$01
#_AA92: BNE .not_item_2

#_AA94: LDX.w $07D4

#_AA97: LDA.w ShopItem2,X
#_AA9A: PHA

#_AA9B: AND.b #$3F
#_AA9D: TAY

#_AA9E: PLA
#_AA9F: AND.b #$C0
#_AAA1: BEQ .handle_text

#_AAA3: CMP.b #$40
#_AAA5: BNE .full_heal

#_AAA7: JSR Restore8Health ; !DUMB why not LDA.b #$10 : JSR RestoreHealth?
#_AAAA: JSR Restore8Health

#_AAAD: JMP .handle_text

.full_heal
#_AAB0: LDA.b $B3
#_AAB2: STA.b $B2
#_AAB4: BNE .handle_text

;---------------------------------------------------------------------------------------------------

.not_item_2
#_AAB6: JSR DeleteShopItem3Icon

#_AAB9: LDA.w $07D4
#_AABC: CMP.b #$08
#_AABE: BEQ .is_free_cash

#_AAC0: LDA.b $84
#_AAC2: STA.b $2E

#_AAC4: LDA.b $85
#_AAC6: STA.b $2F

#_AAC8: LDA.b $86
#_AACA: STA.b $2B

#_AACC: JSR AddShopIconToTilemap

.is_free_cash
#_AACF: LDX.w $07D4

#_AAD2: LDA.b #$01
#_AAD4: STA.w $079A,X

#_AAD7: LDA.w ShopItem3Icon,X
#_AADA: BEQ .is_shoes

#_AADC: CMP.b #$04
#_AADE: BEQ .purchased_lamp

#_AAE0: CMP.b #$15
#_AAE2: BNE .ring_sales_bell

#_AAE4: LDA.b #$0A ; !HARDCODED 10 dollars (coulda been in the prices table though...)
#_AAE6: JSR AddCurrency

#_AAE9: JMP .ring_sales_bell

;---------------------------------------------------------------------------------------------------

.purchased_lamp
#_AAEC: LDA.b #$01
#_AAEE: STA.w $079F ; lamp
#_AAF1: STA.w $07A1 ; lamp
#_AAF4: BNE .ring_sales_bell

.is_shoes
#_AAF6: LDA.b #$01
#_AAF8: STA.w $079A ; shoes
#_AAFB: STA.w $079E ; shoes

.ring_sales_bell
#_AAFE: LDA.b #$16 ; SFX 16
#_AB00: STA.b $E6

#_AB02: LDX.w $07D4
#_AB05: LDY.w ShopPurchaseText,X

.handle_text
#_AB08: JMP HandleShopText

;===================================================================================================

DeleteShopItem3Icon:
#_AB0B: LDA.b #$03
#_AB0D: JSR GetRowColumnForTile

#_AB10: LDA.b $7E
#_AB12: STA.b $2E

#_AB14: LDA.b $7F
#_AB16: STA.b $2F

#_AB18: LDA.b #$13
#_AB1A: STA.b $2B

#_AB1C: JMP AddShopIconToTilemap

;===================================================================================================

ClearBarnabyText:
#_AB1F: LDA.b #$F0 ; VRAM $20F0
#_AB21: STA.b $76
#_AB23: LDA.b #$20
#_AB25: STA.b $75

.next_line
#_AB27: LDA.b #$06
#_AB29: JSR AppendSingleToVRAMBuffer

#_AB2C: LDA.b $76
#_AB2E: JSR AppendSingleToVRAMBuffer

#_AB31: LDA.b $75
#_AB33: JSR AppendSingleToVRAMBuffer

#_AB36: LDY.b #$0E

.next_space
#_AB38: LDA.b #$2F
#_AB3A: JSR AppendSingleToVRAMBuffer

#_AB3D: DEY
#_AB3E: BNE .next_space

#_AB40: LDA.b #$00
#_AB42: JSR AppendSingleToVRAMBuffer

#_AB45: LDA.b $76
#_AB47: CLC
#_AB48: ADC.b #$40
#_AB4A: STA.b $76
#_AB4C: BCC .no_overflow

#_AB4E: INC.b $75

.no_overflow
#_AB50: CMP.b #$F0
#_AB52: BNE .next_line

#_AB54: LDA.b #$00
#_AB56: STA.b $6F

#_AB58: JSR AppendSingleToVRAMBuffer

#_AB5B: DEC.b $19

#_AB5D: RTS

;===================================================================================================

DrawMilonsItems:
#_AB5E: LDA.b #$02
#_AB60: STA.b $2E

#_AB62: LDA.b #$05
#_AB64: STA.b $2F

#_AB66: LDX.b #$00
#_AB68: STX.b $76

.next_item_box
#_AB6A: LDX.b $76

#_AB6C: LDA.w ShopItem3Icon,X
#_AB6F: STA.b $2B

#_AB71: LDX.b $76
#_AB73: LDA.w $079A,X
#_AB76: JSR DrawNextItemBox

.check_next_item
#_AB79: INC.b $76

#_AB7B: LDA.b $76
#_AB7D: CMP.b #$08 ; skip over cash item
#_AB7F: BEQ .check_next_item

#_AB81: CMP.b #$04 ; shoes
#_AB83: BEQ .test_this_item

#_AB85: CMP.b #$07 ; lamp
#_AB87: BNE .skip

.test_this_item
#_AB89: JSR CheckForHavingItem
#_AB8C: CMP.b #$02
#_AB8E: BCS .check_next_item

.skip
#_AB90: CMP.b #$0F
#_AB92: BNE .next_item_box

;---------------------------------------------------------------------------------------------------

#_AB94: LDA.b $2F
#_AB96: PHA

#_AB97: LDA.b $2E
#_AB99: PHA

.draw_empty_boxes
#_AB9A: LDA.b $2F
#_AB9C: CMP.b #$0B
#_AB9E: BEQ .finished

#_ABA0: LDA.b #$14
#_ABA2: STA.b $2B

#_ABA4: JSR DrawNextItemBox
#_ABA7: BNE .draw_empty_boxes

.finished
#_ABA9: PLA
#_ABAA: STA.b $84

#_ABAC: PLA
#_ABAD: STA.b $85

#_ABAF: RTS

;===================================================================================================

DrawNextItemBox:
#_ABB0: BEQ .no_draw
#_ABB2: JSR DrawShopIcon

#_ABB5: LDA.b $2E
#_ABB7: CLC
#_ABB8: ADC.b #$02
#_ABBA: STA.b $2E

#_ABBC: CMP.b #$0E
#_ABBE: BNE .no_draw

#_ABC0: LDA.b #$02
#_ABC2: STA.b $2E

#_ABC4: LDA.b $2F
#_ABC6: CLC
#_ABC7: ADC.b #$03
#_ABC9: STA.b $2F

.no_draw
#_ABCB: INC.b $2B

#_ABCD: RTS

;===================================================================================================

HandleBarnabyPurchase:
#_ABCE: CPX.b #$B0 ; !HARDCODED - button head bump position
#_ABD0: BNE .exit

#_ABD2: LDA.w $0078,Y
#_ABD5: BNE .exit

#_ABD7: LDA.w $007B,Y
#_ABDA: JSR CheckIfMilonIsPoor
#_ABDD: BCS .exit

#_ABDF: LDA.b #$01
#_ABE1: STA.w $0078,Y

#_ABE4: STY.b $82

#_ABE6: LDA.w $007B,Y
#_ABE9: STA.b $81

#_ABEB: JSR ClearBarnabyText

#_ABEE: LDA.b #$01
#_ABF0: STA.b $80

.exit
#_ABF2: RTS

;===================================================================================================

CheckIfMilonIsPoor:
#_ABF3: LDX.b $A1
#_ABF5: BNE .succeed

#_ABF7: JSR DivideBy10

#_ABFA: CPX.b $A2
#_ABFC: BEQ .check_ones

#_ABFE: RTS

.check_ones
#_ABFF: CMP.b $A3
#_AC01: BEQ .succeed

#_AC03: RTS

.succeed
#_AC04: CLC
#_AC05: RTS

;===================================================================================================

HandleShopText:
#_AC06: DEY

#_AC07: LDX.b #$00
#_AC09: STX.b $1C
#_AC0B: STX.b $70

#_AC0D: TYA
#_AC0E: BEQ .is_first_sentence

.find_sentence
#_AC10: LDA.w TextData,X
#_AC13: BPL .same_sentence

#_AC15: INC.b $1C

.same_sentence
#_AC17: INX
#_AC18: CPY.b $1C
#_AC1A: BNE .find_sentence

#_AC1C: LDA.b $1C

.is_first_sentence
#_AC1E: STX.b $73

#_AC20: JSR FindWordInSentence

#_AC23: LDA.b #$04
#_AC25: JMP GetRowColumnForTile

;===================================================================================================

HandleBarnabyText:
#_AC28: LDA.b #$00
#_AC2A: STA.b $83

#_AC2C: LDA.b $8E
#_AC2E: AND.b #$01
#_AC30: BNE .exit

#_AC32: LDA.b $6F
#_AC34: BNE .still_characters_left

#_AC36: LDX.b $73

#_AC38: LDA.w TextData,X
#_AC3B: AND.b #$80
#_AC3D: BNE .end_of_sentence

#_AC3F: INC.b $73

#_AC41: JSR FindWordInSentence

#_AC44: LDA.b #$1E
#_AC46: SEC
#_AC47: SBC.b $7E
#_AC49: CMP.b $6F
#_AC4B: BCS .end_of_word

#_AC4D: JSR BarnabyNewLine

.end_of_word
#_AC50: LDA.b #$00
#_AC52: STA.b $70

.exit
#_AC54: RTS

.end_of_sentence
#_AC55: LDA.b #$00
#_AC57: STA.b $73
#_AC59: BEQ .end_of_word

.still_characters_left
#_AC5B: JMP WriteNextBarnabyCharacter

;===================================================================================================

FindWordInSentence:
#_AC5E: LDX.b $73

#_AC60: LDA.w TextData,X
#_AC63: AND.b #$7F
#_AC65: TAY

#_AC66: JMP FindWord

;===================================================================================================

WriteNextBarnabyCharacter:
#_AC69: LDY.b $70

#_AC6B: LDA.b ($71),Y
#_AC6D: AND.b #$7F
#_AC6F: CMP.b #$2F
#_AC71: BEQ .space

#_AC73: ORA.b #$80

.space
#_AC75: JSR AppendBarnabyCharacter

#_AC78: INC.b $70

#_AC7A: DEC.b $6F
#_AC7C: BNE AdvanceBarnabyCursor

#_AC7E: LDA.b $7E
#_AC80: CMP.b #$1D
#_AC82: BEQ AdvanceBarnabyCursor

#_AC84: JSR AdvanceBarnabyCursor

#_AC87: LDA.b #$2F
#_AC89: JSR AppendBarnabyCharacter

;===================================================================================================

AdvanceBarnabyCursor:
#_AC8C: INC.b $7E

#_AC8E: LDA.b $7E
#_AC90: CMP.b #$1E
#_AC92: BNE .exit

;===================================================================================================

#BarnabyNewLine:
#_AC94: LDA.b #$10
#_AC96: STA.b $7E

#_AC98: INC.b $7F
#_AC9A: INC.b $7F

.exit
#_AC9C: RTS

;===================================================================================================

AppendBarnabyCharacter:
#_AC9D: LDX.b $83
#_AC9F: BNE PositionBarnabyCursor

#_ACA1: PHA

#_ACA2: LDA.b #$07
#_ACA4: JSR AppendSingleToVRAMBuffer

#_ACA7: LDA.b $7E
#_ACA9: JSR AppendSingleToVRAMBuffer

#_ACAC: LDA.b $7F
#_ACAE: JSR AppendSingleToVRAMBuffer

#_ACB1: PLA
#_ACB2: JSR AppendSingleToVRAMBuffer

#_ACB5: LDA.b #$00
#_ACB7: JSR AppendSingleToVRAMBuffer

#_ACBA: DEC.b $19

#_ACBC: RTS

;===================================================================================================

PositionBarnabyCursor:
#_ACBD: PHA

#_ACBE: LDA.b $7E
#_ACC0: STA.b $2E

#_ACC2: LDA.b $7F
#_ACC4: STA.b $2F

#_ACC6: PLA

#_ACC7: JMP DrawTileAtXY

;===================================================================================================

DrawShopStock:
; Draw orange $ icon
#_ACCA: LDA.b #$03
#_ACCC: STA.b $2E

#_ACCE: LDA.b #$0B
#_ACD0: STA.b $2F

#_ACD2: LDA.b #$0E
#_ACD4: STA.b $2B

#_ACD6: JSR DrawShopIcon

; Draw x
#_ACD9: LDA.b #$04
#_ACDB: STA.b $2E

#_ACDD: INC.b $2B

#_ACDF: JSR DrawShopIcon

; Draw cane
#_ACE2: LDA.b #$0A
#_ACE4: STA.b $2E

#_ACE6: LDA.b #$0F
#_ACE8: INC.b $2B

#_ACEA: LDA.b $BD
#_ACEC: AND.b #$01
#_ACEE: BEQ .no_cane

#_ACF0: JSR DrawShopIcon

; Draw crown
.no_cane
#_ACF3: INC.b $2E
#_ACF5: INC.b $2E

#_ACF7: INC.b $2B

#_ACF9: LDA.b $BD
#_ACFB: AND.b #$02
#_ACFD: BEQ .no_crown

#_ACFF: JSR DrawShopIcon

; Draw "ITEMS"
.no_crown
#_AD02: LDA.b #$00
#_AD04: JSR GetRowColumnForTile

#_AD07: LDY.b #$01
#_AD09: JSR DrawWordInShop

;---------------------------------------------------------------------------------------------------
; Shop item 1
;---------------------------------------------------------------------------------------------------
#_AD0C: LDA.b #$01
#_AD0E: JSR GetRowColumnForTile

#_AD11: LDX.w $07D4

#_AD14: LDA.w ShopItem1,X
#_AD17: BNE .has_item_1

#_AD19: LDA.b #$08
#_AD1B: STA.b $78

#_AD1D: LDY.b #$02 ; "SOLD"
#_AD1F: BNE .draw_shop_name_1

.has_item_1
#_AD21: LDY.b #$03 ; "HINTS"

.draw_shop_name_1
#_AD23: JSR DrawWordInShop

;---------------------------------------------------------------------------------------------------
; Shop item 2
;---------------------------------------------------------------------------------------------------
#_AD26: LDX.w $07D4

#_AD29: LDA.b #$02
#_AD2B: JSR GetRowColumnForTile

#_AD2E: LDA.w ShopItem2,X
#_AD31: BNE .has_item_2

#_AD33: LDA.b #$08
#_AD35: STA.b $79

#_AD37: LDY.b #$02 ; "SOLD"
#_AD39: BNE .draw_shop_name_2

.has_item_2
#_AD3B: AND.b #$C0
#_AD3D: BEQ .not_power

#_AD3F: LDY.b #$0F ; "POWER"
#_AD41: BNE .draw_shop_name_2

.not_power
#_AD43: LDY.b #$03 ; "HINTS"

.draw_shop_name_2
#_AD45: JSR DrawWordInShop

;---------------------------------------------------------------------------------------------------
; Shop item 3
;---------------------------------------------------------------------------------------------------
#_AD48: LDA.b #$03
#_AD4A: JSR GetRowColumnForTile

#_AD4D: LDA.w $07D4
#_AD50: JSR CheckForHavingItem
#_AD53: BEQ .not_purchased

#_AD55: LDA.b #$08
#_AD57: STA.b $7A

#_AD59: LDY.b #$02 ; "SOLD"
#_AD5B: JMP DrawWordInShop

.not_purchased
#_AD5E: LDA.b $7E
#_AD60: STA.b $2E

#_AD62: LDA.b $7F
#_AD64: STA.b $2F

#_AD66: LDX.w $07D4

#_AD69: LDA.w ShopItem3Icon,X
#_AD6C: STA.b $86
#_AD6E: STA.b $2B

#_AD70: JMP DrawShopIcon

;===================================================================================================
; TODO annoying... shop ID determines which item you're given
CheckForHavingItem:
#_AD73: CMP.b #$00
#_AD75: BEQ .check_for_shoes

#_AD77: CMP.b #$04
#_AD79: BEQ .check_for_shoes

#_AD7B: CMP.b #$05
#_AD7D: BEQ .check_for_lamp

#_AD7F: CMP.b #$07
#_AD81: BEQ .check_for_lamp

#_AD83: TAX

#_AD84: LDA.w $079A,X

#_AD87: RTS

.check_for_shoes
#_AD88: LDA.w $079A ; shoes
#_AD8B: CLC
#_AD8C: ADC.w $079E ; shoes

#_AD8F: RTS

.check_for_lamp
#_AD90: LDA.w $079F ; lamp
#_AD93: CLC
#_AD94: ADC.w $07A1 ; lamp

#_AD97: RTS

;===================================================================================================

ShopItem3Icon:
#_AD98: db $00 ; 00 - Shoes
#_AD99: db $01 ; 01 - Super shoes
#_AD9A: db $02 ; 02 - Saw
#_AD9B: db $03 ; 03 - Medicine
#_AD9C: db $00 ; 04 - Shoes
#_AD9D: db $04 ; 05 - Lamp
#_AD9E: db $06 ; 06 - Hammer
#_AD9F: db $04 ; 07 - Lamp
#_ADA0: db $15 ; 08 - Cash
#_ADA1: db $09 ; 09 - Vest
#_ADA2: db $05 ; 0A - Feather
#_ADA3: db $08 ; 0B - Paint
#_ADA4: db $0A ; 0C - Blimp
#_ADA5: db $07 ; 0D - Excalibur
#_ADA6: db $0B ; 0E - Canteen

;===================================================================================================

DrawCrystalTracker:
#_ADA7: LDA.b $B6
#_ADA9: PHA

#_ADAA: LDA.b #$05
#_ADAC: STA.b $22

.next
#_ADAE: JSR GetRowColumnForTile

#_ADB1: LDX.b #$4F

#_ADB3: DEC.b $B6
#_ADB5: BPL .no_overflow

#_ADB7: DEX

.no_overflow
#_ADB8: TXA
#_ADB9: JSR PositionBarnabyCursor

#_ADBC: INC.b $22

#_ADBE: LDA.b $22
#_ADC0: CMP.b #$0C
#_ADC2: BNE .next

#_ADC4: PLA
#_ADC5: STA.b $B6

#_ADC7: RTS

;===================================================================================================

DrawShopDollarSigns:
#_ADC8: LDX.w $07D4

#_ADCB: LDA.w ShopItem1,X
#_ADCE: BMI .this_never_happens ; TODO ???

#_ADD0: LDA.b #$00

.this_never_happens
#_ADD2: STA.b $7B

#_ADD4: LDA.w ShopItem2,X
#_ADD7: AND.b #$C0
#_ADD9: ASL A
#_ADDA: ROL A
#_ADDB: ROL A
#_ADDC: TAY

#_ADDD: LDA.w PowerPrices,Y
#_ADE0: STA.b $7C

#_ADE2: LDY.w ShopItem3Price,X

#_ADE5: LDA.b $7A
#_ADE7: BEQ .no_override

#_ADE9: LDY.b #$FF

.no_override
#_ADEB: STY.b $7D

#_ADED: LDA.b #$12
#_ADEF: STA.b $2F

#_ADF1: LDX.b #$00
#_ADF3: STX.b $76

;---------------------------------------------------------------------------------------------------

.next_item
#_ADF5: LDX.b $76

#_ADF7: LDA.b $7B,X
#_ADF9: BEQ .dont_draw
#_ADFB: BMI .dont_draw

#_ADFD: LDA.w ShopDollarSignXPosition,X
#_AE00: STA.b $2E

#_AE02: LDA.b #$B0 ; dollar sign
#_AE04: JSR DrawTileAtXY

.dont_draw
#_AE07: INC.b $76

#_AE09: LDA.b $76
#_AE0B: CMP.b #$03
#_AE0D: BNE .next_item

#_AE0F: RTS

;===================================================================================================

PowerPrices:
#_AE10: db $00, $05, $0F

ShopDollarSignXPosition:
#_AE13: db $05, $0F, $1A

;===================================================================================================

DrawMoneyInShop:
#_AE16: LDA.b #$01
#_AE18: STA.b $37

#_AE1A: LDX.b #$00
#_AE1C: JSR PositionHUDSprite

#_AE1F: LDX.b #$00
#_AE21: JSR DrawCurrencySprites

#_AE24: LDX.b #$06
#_AE26: JSR PositionHUDSprite

#_AE29: LDA.b $7C
#_AE2B: BEQ .skip_digit

#_AE2D: JSR DrawHexToDecSprite

.skip_digit
#_AE30: LDX.b #$08
#_AE32: JSR PositionHUDSprite

#_AE35: LDA.b $7D
#_AE37: BEQ EXIT_AE56
#_AE39: BMI EXIT_AE56

#_AE3B: JMP DrawHexToDecSprite

;===================================================================================================

DrawHexToDecSprite:
#_AE3E: JSR DivideBy10
#_AE41: PHA

#_AE42: TXA
#_AE43: BEQ .skip_digit

#_AE45: JSR AddObjectToBufferSafely

.skip_digit
#_AE48: PLA
#_AE49: JMP AddObjectToBufferSafely

;===================================================================================================

PositionHUDSprite:
#_AE4C: LDA.w .position+0,X
#_AE4F: STA.b $38

#_AE51: LDA.w .position+1,X
#_AE54: STA.b $35

;---------------------------------------------------------------------------------------------------

#EXIT_AE56:
#_AE56: RTS

;---------------------------------------------------------------------------------------------------

.position
#_AE57: db $28, $58
#_AE59: db $38, $60
#_AE5B: db $30, $90
#_AE5D: db $80, $90
#_AE5F: db $D8, $90
#_AE61: db $78, $10
#_AE63: db $78, $90
#_AE65: db $18, $18
#_AE67: db $E0, $18
#_AE69: db $60, $68
#_AE6B: db $50, $18

;===================================================================================================

FindWord:
#_AE6D: LDA.b #WordData>>0
#_AE6F: STA.b $71

#_AE71: LDA.b #WordData>>8
#_AE73: STA.b $72

#_AE75: LDX.b #$00
#_AE77: STX.b $1C

.word_search
#_AE79: LDA.b ($71,X)
#_AE7B: BPL .same_word

#_AE7D: INC.b $1C

.same_word
#_AE7F: INC.b $71
#_AE81: BNE .no_overflow

#_AE83: INC.b $72

.no_overflow
#_AE85: CPY.b $1C
#_AE87: BNE .word_search

;---------------------------------------------------------------------------------------------------

#_AE89: LDA.b $71
#_AE8B: STA.b $1E

#_AE8D: LDA.b $72
#_AE8F: STA.b $1F

#_AE91: LDY.b #$00

.count_letters
#_AE93: LDA.b ($1E),Y
#_AE95: BMI .end_of_word

#_AE97: INY
#_AE98: BNE .count_letters

.end_of_word
#_AE9A: INY
#_AE9B: STY.b $6F

#_AE9D: RTS

;===================================================================================================

DrawWordInShop:
#_AE9E: JSR FindWord

#_AEA1: LDX.b #$00
#_AEA3: STX.b $70

#_AEA5: INX
#_AEA6: STX.b $83

.next
#_AEA8: JSR WriteNextBarnabyCharacter

#_AEAB: LDA.b $6F
#_AEAD: BNE .next

#_AEAF: RTS

;===================================================================================================

GetRowColumnForTile:
#_AEB0: ASL A
#_AEB1: TAY

#_AEB2: LDA.w .position+0,Y
#_AEB5: STA.b $7E

#_AEB7: LDA.w .position+1,Y
#_AEBA: STA.b $7F

#_AEBC: RTS

;---------------------------------------------------------------------------------------------------

.position
#_AEBD: db $04, $03 ; 00
#_AEBF: db $02, $11 ; 01
#_AEC1: db $0C, $11 ; 02
#_AEC3: db $16, $11 ; 03
#_AEC5: db $10, $07 ; 04
#_AEC7: db $14, $04 ; 05
#_AEC9: db $16, $03 ; 06
#_AECB: db $16, $05 ; 07
#_AECD: db $18, $04 ; 08
#_AECF: db $1A, $03 ; 09
#_AED1: db $1A, $05 ; 0A
#_AED3: db $1C, $04 ; 0B

;===================================================================================================

AddShopIconToTilemap:
#_AED5: JSR GetVRAMofTileFromXY

#_AED8: LDX.b $19
#_AEDA: LDA.b #$05 ; VXFR 05
#_AEDC: JSR AddToVRAMBuffer

#_AEDF: LDA.b $0C
#_AEE1: JSR AddToVRAMBuffer

#_AEE4: LDA.b $0D
#_AEE6: JSR AddToVRAMBuffer

#_AEE9: LDA.b #ShopItemIconTiles>>0
#_AEEB: STA.b $1C
#_AEED: LDA.b #ShopItemIconTiles>>8
#_AEEF: STA.b $1D

#_AEF1: LDA.b $2B
#_AEF3: ASL A
#_AEF4: ASL A
#_AEF5: TAY

#_AEF6: JSR GetObjectTilesFromTable
#_AEF9: JMP FinishedVRAMBuffer

;===================================================================================================
; Enters with:
;  $2B - Icon ID
;  $2E - X position
;  $2F - Y position
;===================================================================================================
DrawShopIcon:
#_AEFC: JSR GetVRAMofTileFromXY

#_AEFF: LDA.b $2B
#_AF01: ASL A
#_AF02: ASL A
#_AF03: TAY

#_AF04: LDA.b #ShopItemIconTiles>>0
#_AF06: STA.b $1C

#_AF08: LDA.b #ShopItemIconTiles>>8
#_AF0A: STA.b $1D

#_AF0C: JMP Draw4x4Icon

;===================================================================================================

SmallRoomMilon:
#_AF0F: LDA.b $80
#_AF11: EOR.b #$01
#_AF13: ORA.b $B4
#_AF15: ORA.w $07CF
#_AF18: BEQ .cant_move

#_AF1A: LDA.b $08
#_AF1C: AND.b #$03

.cant_move
#_AF1E: STA.b $42

#_AF20: JSR SmallRoomJump
#_AF23: JSR MilonWalk

#_AF26: JSR SmallRoomWalking
#_AF29: JSR MilonJump

#_AF2C: JMP SmallRoomGravity

;===================================================================================================

DrawShopButtons:
#_AF2F: LDA.b #$21
#_AF31: STA.b $37

#_AF33: LDA.b #$20
#_AF35: STA.b $38

#_AF37: LDX.b #$00
#_AF39: JSR .draw_one

#_AF3C: LDA.b #$70
#_AF3E: STA.b $38

#_AF40: LDX.b #$01
#_AF42: JSR .draw_one

#_AF45: LDA.b #$C0
#_AF47: STA.b $38

#_AF49: LDX.b #$02

;---------------------------------------------------------------------------------------------------

.draw_one
#_AF4B: LDA.b #$A8 ; !HARDCODED - shop ceiling
#_AF4D: SEC
#_AF4E: SBC.b $78,X
#_AF50: STA.b $35

#_AF52: LDA.b #$48
#_AF54: JSR AddObjectToBufferSafely

#_AF57: LDA.b #$49
#_AF59: JSR AddObjectToBufferSafely

#_AF5C: LDA.b $8E
#_AF5E: AND.b #$01
#_AF60: BNE .exit

#_AF62: LDA.b $78,X
#_AF64: BEQ .exit

#_AF66: CMP.b #$08
#_AF68: BEQ .exit

#_AF6A: INC.b $78,X

.exit
#_AF6C: RTS

;===================================================================================================

AnimateBarnaby:
#_AF6D: LDA.b $8E
#_AF6F: AND.b #$3F
#_AF71: BNE .dont_toggle_animation

#_AF73: LDA.b $60
#_AF75: EOR.b #$01
#_AF77: STA.b $60

.dont_toggle_animation
#_AF79: LDA.b #$12
#_AF7B: STA.b $2E
#_AF7D: LDA.b #$04
#_AF7F: STA.b $2F

#_AF81: LDA.b $60
#_AF83: AND.b #$01
#_AF85: CLC
#_AF86: ADC.b #$0C
#_AF88: STA.b $2B

#_AF8A: JMP AddShopIconToTilemap

;===================================================================================================

SmallRoomWalking:
#_AF8D: LDA.b $40
#_AF8F: BNE .im_walkin_here

#_AF91: LDA.b $47
#_AF93: CMP.b #$0A
#_AF95: BEQ EXIT_AFAF

#_AF97: LDA.b $43
#_AF99: STA.b $42

.im_walkin_here
#_AF9B: JSR GetSpeedInPixels
#_AF9E: BEQ EXIT_AFAF

#_AFA0: JSR AnimateMilonStrut

#_AFA3: LDA.b $42
#_AFA5: TAX

#_AFA6: AND.b #$01
#_AFA8: BNE GetSmallRoomRightWall

#_AFAA: TXA
#_AFAB: AND.b #$02
#_AFAD: BNE GetSmallRoomLeftWall

;---------------------------------------------------------------------------------------------------

#EXIT_AFAF:
#_AFAF: RTS

;===================================================================================================

GetSmallRoomRightWall:
#_AFB0: LDA.b $42
#_AFB2: AND.b #$0C
#_AFB4: ORA.b #$01
#_AFB6: STA.b $42

.next_pixel
#_AFB8: LDA.b #$E0
#_AFBA: STA.b $1C

#_AFBC: LDA.b $B4
#_AFBE: BNE .boss_room

#_AFC0: LDA.w $07CF
#_AFC3: BEQ .not_bonus_game

#_AFC5: LDA.b #$F2
#_AFC7: STA.b $1C

.boss_room
#_AFC9: LDA.b $3E
#_AFCB: CMP.b #$4A
#_AFCD: BEQ .boss_platform

.check_wall
#_AFCF: CMP.b $1C
#_AFD1: BCS SmallRoomHitWall

.not_bonus_game
#_AFD3: INC.b $3E

#_AFD5: DEC.b $AD
#_AFD7: BNE .next_pixel

#_AFD9: RTS

.boss_platform
#_AFDA: LDX.b $B4
#_AFDC: BEQ .check_wall

#_AFDE: LDX.b $3F
#_AFE0: CPX.b #$A9
#_AFE2: BCC .check_wall

;===================================================================================================

SmallRoomHitWall:
#_AFE4: LDA.b #$0A
#_AFE6: STA.b $47

#_AFE8: RTS

;---------------------------------------------------------------------------------------------------

GetSmallRoomLeftWall:
#_AFE9: LDA.b $42
#_AFEB: AND.b #$0C
#_AFED: ORA.b #$02
#_AFEF: STA.b $42

.next_pixel
#_AFF1: LDA.b #$0F
#_AFF3: STA.b $1C

#_AFF5: LDA.b $B4
#_AFF7: BNE .boss_room

#_AFF9: LDA.w $07CF
#_AFFC: BEQ .not_bonus_game

#_AFFE: LDA.b #$01
#_B000: STA.b $1C

.boss_room
#_B002: LDA.b $3E
#_B004: CMP.b $1C
#_B006: BCC SmallRoomHitWall

.not_bonus_game
#_B008: DEC.b $3E

#_B00A: DEC.b $AD
#_B00C: BNE .next_pixel

#_B00E: RTS

;===================================================================================================
; BOOF
;===================================================================================================
SmallRoomGravity:
#_B00F: JSR GetJumpVelocity
#_B012: BEQ EXIT_AFAF

#_B014: JSR GetJumpHeightIndex

#_B017: LDA.b $49
#_B019: BEQ EXIT_AFAF

#_B01B: CMP.w JumpDurations,X
#_B01E: BCC .jumping

;---------------------------------------------------------------------------------------------------

#_B020: LDA.b $42
#_B022: AND.b #$03
#_B024: ORA.b #$04
#_B026: STA.b $42

.falling
#_B028: JSR GetSmallRoomFloor
#_B02B: BCS .landed

#_B02D: INC.b $3F

#_B02F: DEC.b $AE
#_B031: BNE .falling

#_B033: RTS

.landed
#_B034: LDA.b #$00
#_B036: STA.b $49

#_B038: RTS

;---------------------------------------------------------------------------------------------------

.jumping
#_B039: LDA.b $42
#_B03B: AND.b #$03
#_B03D: ORA.b #$08
#_B03F: STA.b $42

#_B041: LDA.w $07CF
#_B044: ORA.b $B4
#_B046: BNE .perform_jump

#_B048: JSR TestSmallRoomHeadBonk
#_B04B: BCS .bonked

.perform_jump
#_B04D: DEC.b $3F
#_B04F: DEC.b $AE
#_B051: BNE .perform_jump

#_B053: RTS

;---------------------------------------------------------------------------------------------------

.bonked
#_B054: JSR GetJumpHeightIndex

#_B057: LDA.w JumpDurations,X
#_B05A: SEC
#_B05B: SBC.b $49
#_B05D: BMI .exit

#_B05F: CLC
#_B060: ADC.w JumpDurations,X
#_B063: SBC.b #$02
#_B065: STA.b $49

.exit
#_B067: RTS

;===================================================================================================
; Wow... There's no collision... Just a hardcoded check.
;===================================================================================================
GetSmallRoomFloor:
#_B068: LDA.b #$B8
#_B06A: STA.b $1C

#_B06C: LDA.b $B4
#_B06E: BEQ .test_floor

#_B070: LDA.b $3E
#_B072: CMP.b #$4B
#_B074: BCC .test_floor

#_B076: LDA.b #$A8 ; !HARDCODED - shop ceiling
#_B078: STA.b $1C

.test_floor
#_B07A: LDA.b $3F
#_B07C: CMP.b $1C

#_B07E: RTS

;===================================================================================================

GetSmallRoomCeiling:
#_B07F: LDY.b #$00

.next
#_B081: LDA.w .button_x,Y
#_B084: CMP.b $58
#_B086: BCS .skip

#_B088: ADC.b #$0F
#_B08A: CMP.b $58
#_B08C: BCC .skip

#_B08E: LDA.w $0078,Y
#_B091: BNE .skip

#_B093: LDX.b #$B0 ; !HARDCODED - button head bump position
#_B095: SEC

#_B096: RTS

.skip
#_B097: INY
#_B098: CPY.b #$03
#_B09A: BNE .next

;---------------------------------------------------------------------------------------------------

#_B09C: CLC

#_B09D: LDX.b #$A8 ; !HARDCODED - shop ceiling

#_B09F: RTS

;---------------------------------------------------------------------------------------------------

.button_x
#_B0A0: db $20, $70, $C0

;===================================================================================================

TestSmallRoomHeadBonk:
#_B0A3: LDA.b $3E
#_B0A5: CLC
#_B0A6: ADC.b #$02
#_B0A8: STA.b $58

#_B0AA: JSR .test_one
#_B0AD: BCS .succeed

#_B0AF: LDA.b $3E
#_B0B1: CLC
#_B0B2: ADC.b #$0E
#_B0B4: STA.b $58

;---------------------------------------------------------------------------------------------------

.test_one
#_B0B6: LDA.b $3F
#_B0B8: STA.b $59

#_B0BA: JSR GetSmallRoomCeiling

#_B0BD: CPX.b $3F
#_B0BF: BCC .fail

#_B0C1: JSR HandleBarnabyPurchase

.succeed
#_B0C4: SEC
#_B0C5: RTS

.fail
#_B0C6: CLC
#_B0C7: RTS

;===================================================================================================

SmallRoomJump:
#_B0C8: LDA.b #$00
#_B0CA: STA.b $4A

#_B0CC: JSR GetJumpHeightIndex

#_B0CF: LDA.w JumpDurations,X
#_B0D2: SEC
#_B0D3: SBC.b #$01
#_B0D5: STA.b $1C

#_B0D7: LDA.b $49
#_B0D9: SEC
#_B0DA: SBC.b #$01
#_B0DC: CMP.b $1C
#_B0DE: BCC .exit

#_B0E0: JSR GetSmallRoomFloor
#_B0E3: BCS .exit

#_B0E5: LDA.b #$01
#_B0E7: STA.b $4A

#_B0E9: LDA.b $49
#_B0EB: BNE .exit

#_B0ED: JSR GetJumpHeightIndex

#_B0F0: LDA.w JumpDurations,X
#_B0F3: CLC
#_B0F4: ADC.b #$02
#_B0F6: STA.b $49

.exit
#_B0F8: RTS

;===================================================================================================

ShopBGPalettes:
#_B0F9: db $0F, $16, $26, $37
#_B0FD: db $0F, $19, $16, $36
#_B101: db $0F, $00, $10, $30
#_B105: db $0F, $29, $00, $30

;===================================================================================================

ShopItemIconTiles:
#_B109: db $24, $25, $34, $35 ; 00 - Shoes
#_B10D: db $40, $41, $50, $51 ; 01 - Super shoes
#_B111: db $68, $69, $78, $79 ; 02 - Saw
#_B115: db $20, $21, $30, $31 ; 03 - Medicine
#_B119: db $22, $23, $32, $33 ; 04 - Lamp
#_B11D: db $26, $27, $36, $37 ; 05 - Feather
#_B121: db $42, $43, $52, $53 ; 06 - Hammer
#_B125: db $28, $29, $38, $39 ; 07 - Excalibur
#_B129: db $2A, $2B, $3A, $3B ; 08 - Paint
#_B12D: db $2C, $2D, $3C, $3D ; 09 - Vest
#_B131: db $46, $47, $56, $57 ; 0A - Blimp
#_B135: db $44, $45, $54, $55 ; 0B - Canteen
#_B139: db $48, $49, $58, $59 ; 0C - Barnaby A
#_B13D: db $4A, $4B, $5A, $5B ; 0D - Barnaby B
#_B141: db $6D, $2F, $2F, $2F ; 0E - Small orange dollar sign
#_B145: db $BE, $2F, $2F, $2F ; 0F - Small x
#_B149: db $6A, $6B, $7A, $7B ; 10 - Crown
#_B14D: db $2F, $7C, $2F, $7D ; 11 - Cane
#_B151: db $2F, $2F, $B0, $2F ; 12 - Font dollar sign
#_B155: db $2F, $2F, $2F, $2F ; 13 - Nothing
#_B159: db $4C, $4D, $5C, $5D ; 14 - Empty box
#_B15D: db $08, $09, $18, $19 ; 15 - Cash

;===================================================================================================

ShopRoomTiles:
#_B161: db $20, $00, $10, $00 ; VRAM $2000, 16 horizontal, offset $00
#_B165: db $20, $20, $10, $00 ; VRAM $2020, 16 horizontal, offset $00
#_B169: db $23, $40, $10, $02 ; VRAM $2340, 16 horizontal, offset $02
#_B16D: db $23, $60, $10, $02 ; VRAM $2360, 16 horizontal, offset $02
#_B171: db $23, $80, $10, $02 ; VRAM $2380, 16 horizontal, offset $02
#_B175: db $23, $A0, $10, $02 ; VRAM $23A0, 16 horizontal, offset $02
#_B179: db $24, $40, $09, $04 ; VRAM $2040,  9   vertical, offset $04
#_B17D: db $24, $4F, $06, $06 ; VRAM $204F,  6   vertical, offset $06
#_B181: db $24, $5E, $09, $08 ; VRAM $205E,  9   vertical, offset $08
#_B185: db $24, $1F, $0A, $04 ; VRAM $201F, 10   vertical, offset $04
#_B189: db $25, $E9, $03, $08 ; VRAM $21E9,  3   vertical, offset $08
#_B18D: db $25, $EA, $03, $04 ; VRAM $21EA,  3   vertical, offset $04
#_B191: db $25, $F3, $03, $08 ; VRAM $21F3,  3   vertical, offset $08
#_B195: db $25, $F4, $03, $04 ; VRAM $21F4,  3   vertical, offset $04
#_B199: db $21, $C0, $10, $00 ; VRAM $21C0, 16 horizontal, offset $00
#_B19D: db $22, $80, $10, $00 ; VRAM $2280, 16 horizontal, offset $00
#_B1A1: db $00 ; end

;===================================================================================================

SmallRoomTiles:
; Shop tiles (sets of 2)
#_B1A2: db $C2, $C3             ; 00 - shop horizontal wood
#_B1A4: db $BF, $BF             ; 02 - shop floor
#_B1A6: db $D1, $D1             ; 04 - shop vertical wood column
#_B1A8: db $C2, $C2             ; 06 - shop vertical wood blocks
#_B1AA: db $C0, $C0             ; 08 - shop left vertical wood column

; Boss room tiles (sets of 4)
#_B1AC: db $07, $07, $07, $07   ; 0A - boss bricks
#_B1B0: db $EA, $EA, $EA, $EA   ; 0E - boss glitchy row (bottom right of S) - accidental NOP?
#_B1B4: db $1E, $1E, $1E, $1E   ; 12 - boss floor and ceiling trim
#_B1B8: db $0E, $0F, $07, $07   ; 16 - boss arches top
#_B1BC: db $64, $65, $0C, $0B   ; 1A - boss arches middle
#_B1C0: db $00, $00, $29, $2A   ; 1E - boss arches bottom
#_B1C4: db $00, $00, $C4, $C5   ; 22 - boss arches base
#_B1C8: db $07, $38, $39, $75   ; 26 - boss ceiling top left
#_B1CC: db $74, $75, $74, $75   ; 2A - boss ceiling
#_B1D0: db $74, $3A, $3B, $07   ; 2E - boss ceiling top right
#_B1D4: db $C6, $C6, $C6, $C6   ; 32 - boss marble column left
#_B1D8: db $C7, $C7, $C7, $C7   ; 36 - boss marble column right
#_B1DC: db $38, $39, $3A, $3B   ; 3A - boss door top
#_B1E0: db $26, $36, $36, $36   ; 3E - boss door gate
#_B1E4: db $27, $37, $37, $37   ; 42 - boss door gate right edge
#_B1E8: db $2C, $2C, $2C, $2C   ; 46 - boss door right edge
#_B1EC: db $C0, $C1, $C0, $C1   ; 4A - boss stone platform top
#_B1F0: db $C2, $C3, $C2, $C3   ; 4E - boss stone platform bottom
#_B1F4: db $C4, $C5, $C4, $C5   ; 52 - boss floor
#_B1F8: db $2D, $2D, $2D, $2D   ; 56 - boss door left edge

;===================================================================================================

ShopTileAttributes:
#_B1FC: db $80, $A0, $A0, $20, $A0, $50, $50, $20
#_B204: db $88, $AA, $AA, $22, $A5, $A5, $A5, $21
#_B20C: db $08, $AA, $EA, $32, $AA, $AA, $AA, $22
#_B214: db $08, $0A, $0E, $03, $0A, $0A, $0A, $02
#_B21C: db $88, $AA, $00, $AA, $22, $88, $AA, $22
#_B224: db $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0
#_B22C: db $5A, $5A, $5A, $5A, $5A, $5A, $5A, $5A
#_B234: db $55, $55, $55, $55, $55, $55, $55, $55

;===================================================================================================

ShopItem1:
#_B23C: db $05 ; 00 - Hint
#_B23D: db $00 ; 01 - SOLD
#_B23E: db $00 ; 02 - SOLD
#_B23F: db $08 ; 03 - Hint
#_B240: db $00 ; 04 - SOLD
#_B241: db $0A ; 05 - Hint
#_B242: db $00 ; 06 - SOLD
#_B243: db $0B ; 07 - Hint
#_B244: db $0D ; 08 - Hint
#_B245: db $0E ; 09 - Hint
#_B246: db $0F ; 0A - Hint
#_B247: db $14 ; 0B - Hint
#_B248: db $11 ; 0C - Hint
#_B249: db $13 ; 0D - Hint
#_B24A: db $00 ; 0E - SOLD

; ppmm mmmm
;   p - power price (0, 5, 15, 5)
;   m - message TODO (for power - ???)
; $00 - nothing
ShopItem2:
#_B24B: db $06 ; 00 - Hint
#_B24C: db $A5 ; 01 - Power $15
#_B24D: db $65 ; 02 - Power $5
#_B24E: db $09 ; 03 - Hint
#_B24F: db $65 ; 04 - Power $5
#_B250: db $65 ; 05 - Power $5
#_B251: db $00 ; 06 - SOLD
#_B252: db $0C ; 07 - Hint
#_B253: db $A6 ; 08 - Power $15
#_B254: db $65 ; 09 - Power $5
#_B255: db $10 ; 0A - Hint
#_B256: db $65 ; 0B - Power $5
#_B257: db $12 ; 0C - Hint
#_B258: db $65 ; 0D - Power $5
#_B259: db $00 ; 0E - Hint

ShopPurchaseText:
#_B25A: db $17 ; 00
#_B25B: db $22 ; 01
#_B25C: db $18 ; 02
#_B25D: db $19 ; 03
#_B25E: db $17 ; 04
#_B25F: db $1A ; 05
#_B260: db $1C ; 06
#_B261: db $1A ; 07
#_B262: db $26 ; 08
#_B263: db $1F ; 09
#_B264: db $1B ; 0A
#_B265: db $1E ; 0B
#_B266: db $21 ; 0C
#_B267: db $1D ; 0D
#_B268: db $20 ; 0E

ShopWelcomeMessage:
#_B269: db $04 ; 00 - MAY I HELP YOU ?
#_B26A: db $04 ; 01 - MAY I HELP YOU ?
#_B26B: db $16 ; 02 - TAKE THIS!
#_B26C: db $04 ; 03 - MAY I HELP YOU ?
#_B26D: db $04 ; 04 - MAY I HELP YOU ?
#_B26E: db $04 ; 05 - MAY I HELP YOU ?
#_B26F: db $16 ; 06 - TAKE THIS!
#_B270: db $04 ; 07 - MAY I HELP YOU ?
#_B271: db $15 ; 08 - TAKE ONE YOU LIKE
#_B272: db $04 ; 09 - MAY I HELP YOU ?
#_B273: db $04 ; 0A - MAY I HELP YOU ?
#_B274: db $04 ; 0B - MAY I HELP YOU ?
#_B275: db $04 ; 0C - MAY I HELP YOU ?
#_B276: db $04 ; 0D - MAY I HELP YOU ?
#_B277: db $16 ; 0E - TAKE THIS!

ShopItem3Price:
#_B278: db $10 ; 00 - 16 - Shoes
#_B279: db $3C ; 01 - 60 - Super shoes
#_B27A: db $00 ; 02 -  0 - Saw
#_B27B: db $05 ; 03 -  5 - Medicine
#_B27C: db $0A ; 04 - 10 - Shoes
#_B27D: db $32 ; 05 - 50 - Lamp
#_B27E: db $00 ; 06 -  0 - Hammer
#_B27F: db $0F ; 07 - 15 - Lamp
#_B280: db $00 ; 08 -  0 - Cash
#_B281: db $19 ; 09 - 25 - Vest
#_B282: db $23 ; 0A - 35 - Feather
#_B283: db $28 ; 0B - 40 - Paint
#_B284: db $28 ; 0C - 40 - Blimp
#_B285: db $32 ; 0D - 50 - Excalibur
#_B286: db $00 ; 0E -  0 - Canteen

;===================================================================================================

TextData:

.sentence_00
; "ITEMS"
#_B287: db $81

.sentence_01
; "SOLD OUT"
#_B288: db $02, $C4

.sentence_02
; "HINTS"
#_B28A: db $83

.sentence_03
; "MAY I HELP YOU ?"
#_B28B: db $04, $45, $46, $05, $86

.sentence_04
; "BUMP HEAD TO FIND BOX"
#_B290: db $07, $47, $48, $49, $CB

.sentence_05
; "SECRET ENTRANCE IN THE FRONT WALL"
#_B295: db $08, $09, $0A, $16, $0B, $CC

.sentence_06
; "FIND A CROWN & A CANE"
#_B29B: db $49, $1B, $0D, $4E, $1B, $CF

.sentence_07
; "CRYSTAL HAS MYSTERIOUS POWER"
#_B2A1: db $0E, $51, $52, $8F

.sentence_08
; "FIND A SAW"
#_B2A5: db $49, $1B, $90

.sentence_09
; "SECRETS IN THE WELL"
#_B2A8: db $11, $0A, $16, $92

.sentence_0A
; "THE WELL IS CLIMBABLE"
#_B2AC: db $16, $12, $13, $94

.sentence_0B
; "BALLOON MAKES THE BUBBLE BIGGER"
#_B2B0: db $15, $56, $16, $35, $97

.sentence_0C
; "PUSH FOR 4 SECONDS ON THE FIREPLACE"
#_B2B5: db $18, $4D, $53, $54, $55, $16, $99

.sentence_0D
; "THE VEST ISN'T 100% AGAINST HEAT"
#_B2BC: db $16, $1A, $57, $58, $59, $DA

.sentence_0E
; "A ROOM BELOW THE FIREPLACE"
#_B2C2: db $1B, $1C, $1D, $16, $99

.sentence_0F
; "A TRAP IN LEFT TOWER"
#_B2C7: db $1B, $1E, $0A, $1F, $DB

.sentence_10
; "A CROWN & A CANE IS NEEDED AT THE 4TH FLOOR"
#_B2CC: db $1B, $0D, $4E, $1B, $4F, $13, $20, $5C
#_B2D4: db $16, $21, $DD

.sentence_11
; "THERE IS ONLY ONE MAHARITO"
#_B2D7: db $22, $13, $23, $24, $A5

.sentence_12
; "WATCH OUT FOR A PHONEY PRINCESS"
#_B2DC: db $26, $44, $4D, $1B, $5E, $DF

.sentence_13
; "A WATERPOT IN ICY ROOM"
#_B2E2: db $1B, $27, $0A, $60, $9C

.sentence_14
; "TAKE ONE YOU LIKE"
#_B2E7: db $28, $24, $05, $A9

.sentence_15
; "TAKE THIS!"
#_B2EB: db $28, $AA

.sentence_16
; "JUMP HIGHER WHERE SPRINGS ARE SET"
#_B2ED: db $3C, $2B, $62, $63, $64, $E5

.sentence_17
; "CAN ENTER THRU WINDOWS"
#_B2F3: db $2C, $33, $2D, $C1

.sentence_18
; "SHRINK WHEN YOU TOUCH THE GLOVE"
#_B2F7: db $42, $4A, $05, $43, $16, $AE

.sentence_19
; "NEED A LIGHT IN THE DARK"
#_B2FD: db $2F, $1B, $66, $0A, $16, $B0

.sentence_1A
; "LOOSE WEIGHT AND RIDE THE ELEVATORS"
#_B303: db $31, $67, $50, $68, $16, $B2

.sentence_1B
; "ENTER THRU THE FRONT WALL"
#_B309: db $33, $2D, $16, $0B, $CC

.sentence_1C
; "POWER UP THE BUBBLE"
#_B30E: db $0F, $34, $16, $B5

.sentence_1D
; "MAKE INVISIBLE THINGS VISIBLE"
#_B312: db $36, $69, $6A, $EB

.sentence_1E
; "HELPS YOU IN THE FIRE ROOM"
#_B316: db $37, $05, $0A, $16, $38, $9C

.sentence_1F
; "EXTINGUISH THE FIRE"
#_B31C: db $39, $16, $B8

.sentence_20
; "GLIDE DOWN SLOWLY"
#_B31F: db $3B, $40, $BA

.sentence_21
; "JUMP HIGH ANYWHERE"
#_B322: db $3C, $3E, $BD

.sentence_22
; "POWER"
#_B325: db $8F

.sentence_23
; "HIGH POWER"
#_B326: db $3E, $8F

.sentence_24
; "THANK YOU"
#_B328: db $3F, $85

.sentence_25
; "GO AHEAD"
#_B32A: db $61, $8C

;===================================================================================================

WordData:
#_B32C: db $80                                                       ; 00 - A
#_B32D: db $08, $13, $04, $0C, $92                                   ; 01 - ITEMS
#_B332: db $12, $0E, $0B, $83                                        ; 02 - SOLD
#_B336: db $07, $08, $0D, $13, $92                                   ; 03 - HINTS
#_B33B: db $0C, $00, $98                                             ; 04 - MAY
#_B33E: db $18, $0E, $94                                             ; 05 - YOU
#_B341: db $BA                                                       ; 06 - ?
#_B342: db $01, $14, $0C, $8F                                        ; 07 - BUMP
#_B346: db $12, $04, $02, $11, $04, $93                              ; 08 - SECRET
#_B34C: db $04, $0D, $13, $11, $00, $0D, $02, $84                    ; 09 - ENTRANCE
#_B354: db $08, $8D                                                  ; 0A - IN
#_B356: db $05, $11, $0E, $0D, $93                                   ; 0B - FRONT
#_B35B: db $00, $07, $04, $00, $83                                   ; 0C - AHEAD
#_B360: db $02, $11, $0E, $16, $8D                                   ; 0D - CROWN
#_B365: db $02, $11, $18, $12, $13, $00, $8B                         ; 0E - CRYSTAL
#_B36C: db $0F, $0E, $16, $04, $91                                   ; 0F - POWER
#_B371: db $12, $00, $96                                             ; 10 - SAW
#_B374: db $12, $04, $02, $11, $04, $13, $92                         ; 11 - SECRETS
#_B37B: db $16, $04, $0B, $8B                                        ; 12 - WELL
#_B37F: db $08, $92                                                  ; 13 - IS
#_B381: db $02, $0B, $08, $0C, $01, $00, $01, $0B, $84               ; 14 - CLIMBABLE
#_B38A: db $01, $00, $0B, $0B, $0E, $0E, $8D                         ; 15 - BALLOON
#_B391: db $13, $07, $84                                             ; 16 - THE
#_B394: db $01, $08, $06, $06, $04, $91                              ; 17 - BIGGER
#_B39A: db $0F, $14, $12, $87                                        ; 18 - PUSH
#_B39E: db $05, $08, $11, $04, $0F, $0B, $00, $02, $84               ; 19 - FIREPLACE
#_B3A7: db $15, $04, $12, $93                                        ; 1A - VEST
#_B3AB: db $80                                                       ; 1B - A
#_B3AC: db $11, $0E, $0E, $8C                                        ; 1C - ROOM
#_B3B0: db $01, $04, $0B, $0E, $96                                   ; 1D - BELOW
#_B3B5: db $13, $11, $00, $8F                                        ; 1E - TRAP
#_B3B9: db $0B, $04, $05, $93                                        ; 1F - LEFT
#_B3BD: db $0D, $04, $04, $03, $04, $83                              ; 20 - NEEDED
#_B3C3: db $24, $13, $87                                             ; 21 - 4TH
#_B3C6: db $13, $07, $04, $11, $84                                   ; 22 - THERE
#_B3CB: db $0E, $0D, $0B, $98                                        ; 23 - ONLY
#_B3CF: db $0E, $0D, $84                                             ; 24 - ONE
#_B3D2: db $0C, $00, $07, $00, $11, $08, $13, $8E                    ; 25 - MAHARITO
#_B3DA: db $16, $00, $13, $02, $87                                   ; 26 - WATCH
#_B3DF: db $16, $00, $13, $04, $11, $0F, $0E, $93                    ; 27 - WATERPOT
#_B3E7: db $13, $00, $0A, $84                                        ; 28 - TAKE
#_B3EB: db $0B, $08, $0A, $84                                        ; 29 - LIKE
#_B3EF: db $13, $07, $08, $12, $9A                                   ; 2A - THIS!
#_B3F4: db $07, $08, $06, $07, $04, $91                              ; 2B - HIGHER
#_B3FA: db $02, $00, $8D                                             ; 2C - CAN
#_B3FD: db $13, $07, $11, $94                                        ; 2D - THRU
#_B401: db $06, $0B, $0E, $15, $84                                   ; 2E - GLOVE
#_B406: db $0D, $04, $04, $83                                        ; 2F - NEED
#_B40A: db $03, $00, $11, $8A                                        ; 30 - DARK
#_B40E: db $0B, $0E, $0E, $12, $84                                   ; 31 - LOOSE
#_B413: db $04, $0B, $04, $15, $00, $13, $0E, $11, $92               ; 32 - ELEVATORS
#_B41C: db $04, $0D, $13, $04, $91                                   ; 33 - ENTER
#_B421: db $14, $8F                                                  ; 34 - UP
#_B423: db $01, $14, $01, $01, $0B, $84                              ; 35 - BUBBLE
#_B429: db $0C, $00, $0A, $84                                        ; 36 - MAKE
#_B42D: db $07, $04, $0B, $0F, $92                                   ; 37 - HELPS
#_B432: db $05, $08, $11, $84                                        ; 38 - FIRE
#_B436: db $04, $17, $13, $08, $0D, $06, $14, $08, $12, $87          ; 39 - EXTINGUISH
#_B440: db $12, $0B, $0E, $16, $0B, $98                              ; 3A - SLOWLY
#_B446: db $06, $0B, $08, $03, $84                                   ; 3B - GLIDE
#_B44B: db $09, $14, $0C, $8F                                        ; 3C - JUMP
#_B44F: db $00, $0D, $18, $16, $07, $04, $11, $84                    ; 3D - ANYWHERE
#_B457: db $07, $08, $06, $87                                        ; 3E - HIGH
#_B45B: db $13, $07, $00, $0D, $8A                                   ; 3F - THANK
#_B460: db $03, $0E, $16, $8D                                        ; 40 - DOWN
#_B464: db $16, $08, $0D, $03, $0E, $16, $92                         ; 41 - WINDOWS
#_B46B: db $12, $07, $11, $08, $0D, $8A                              ; 42 - SHRINK
#_B471: db $13, $0E, $14, $02, $87                                   ; 43 - TOUCH
#_B476: db $0E, $14, $93                                             ; 44 - OUT
#_B479: db $88                                                       ; 45 - I
#_B47A: db $07, $04, $0B, $8F                                        ; 46 - HELP
#_B47E: db $07, $04, $00, $83                                        ; 47 - HEAD
#_B482: db $13, $8E                                                  ; 48 - TO
#_B484: db $05, $08, $0D, $83                                        ; 49 - FIND
#_B488: db $16, $07, $04, $8D                                        ; 4A - WHEN
#_B48C: db $01, $0E, $97                                             ; 4B - BOX
#_B48F: db $16, $00, $0B, $8B                                        ; 4C - WALL
#_B493: db $05, $0E, $91                                             ; 4D - FOR
#_B496: db $9C                                                       ; 4E - &
#_B497: db $02, $00, $0D, $84                                        ; 4F - CANE
#_B49B: db $00, $0D, $83                                             ; 50 - AND
#_B49E: db $07, $00, $92                                             ; 51 - HAS
#_B4A1: db $0C, $18, $12, $13, $04, $11, $08, $0E, $14, $92          ; 52 - MYSTERIOUS
#_B4AB: db $A4                                                       ; 53 - 4
#_B4AC: db $12, $04, $02, $0E, $0D, $03, $92                         ; 54 - SECONDS
#_B4B3: db $0E, $8D                                                  ; 55 - ON
#_B4B5: db $0C, $00, $0A, $04, $92                                   ; 56 - MAKES
#_B4BA: db $08, $12, $0D, $1D, $93                                   ; 57 - ISN'T
#_B4BF: db $21, $20, $20, $9B                                        ; 58 - 100%
#_B4C3: db $00, $06, $00, $08, $0D, $12, $93                         ; 59 - AGAINST
#_B4CA: db $07, $04, $00, $93                                        ; 5A - HEAT
#_B4CE: db $13, $0E, $16, $04, $91                                   ; 5B - TOWER
#_B4D3: db $00, $93                                                  ; 5C - AT
#_B4D5: db $05, $0B, $0E, $0E, $91                                   ; 5D - FLOOR
#_B4DA: db $0F, $07, $0E, $0D, $04, $98                              ; 5E - PHONEY
#_B4E0: db $0F, $11, $08, $0D, $02, $04, $12, $92                    ; 5F - PRINCESS
#_B4E8: db $08, $02, $98                                             ; 60 - ICY
#_B4EB: db $06, $8E                                                  ; 61 - GO
#_B4ED: db $16, $07, $04, $11, $84                                   ; 62 - WHERE
#_B4F2: db $12, $0F, $11, $08, $0D, $06, $92                         ; 63 - SPRINGS
#_B4F9: db $00, $11, $84                                             ; 64 - ARE
#_B4FC: db $12, $04, $93                                             ; 65 - SET
#_B4FF: db $0B, $08, $06, $07, $93                                   ; 66 - LIGHT
#_B504: db $16, $04, $08, $06, $07, $93                              ; 67 - WEIGHT
#_B50A: db $11, $08, $03, $84                                        ; 68 - RIDE
#_B50E: db $08, $0D, $15, $08, $12, $08, $01, $0B, $84               ; 69 - INVISIBLE
#_B517: db $13, $07, $08, $0D, $06, $92                              ; 6A - THINGS
#_B51D: db $15, $08, $12, $08, $01, $0B, $84                         ; 6B - VISIBLE

;===================================================================================================

UploadRoomGraphics:

; Replace collected objects
#_B524: LDA.b #$02
#_B526: STA.b $2A

.next_group
#_B528: LDA.b #$03
#_B52A: STA.b $29

.next_tile
#_B52C: JSR GetObjectType_indoors

#_B52F: LDA.b $2B
#_B531: CMP.b #$1E ; OBJECT 1E
#_B533: BNE .skip

#_B535: LDA.b $BC
#_B537: CMP.b #$03 ; !HARDCODED - number of times super shoes store can be visited
#_B539: BCC .skip  ;              after which, pre-revealed coins no longer spawn

#_B53B: LDA.b #$00 ; OBJECT 00
#_B53D: STA.b $2B

#_B53F: JSR ChangeObjectType

.skip
#_B542: INC.b $29

#_B544: LDA.b $29
#_B546: CMP.b #$08
#_B548: BNE .next_tile

#_B54A: INC.b $2A

#_B54C: LDA.b $2A
#_B54E: CMP.b #$05
#_B550: BNE .next_group

;---------------------------------------------------------------------------------------------------

#_B552: JSR ReloadDefaultSpritePalettes

#_B555: LDA.b #$00
#_B557: STA.b $0B
#_B559: STA.b $27

#_B55B: JSR RoomLoadOneNametable

#_B55E: LDA.b #$04
#_B560: STA.b $0B

#_B562: LDA.b #$10
#_B564: STA.b $27

#_B566: JSR RoomLoadOneNametable

#_B569: LDA.b #$00
#_B56B: STA.b $27
#_B56D: STA.b $0B

#_B56F: RTS

;===================================================================================================

RoomLoadOneNametable:
#_B570: LDA.b #$0F
#_B572: STA.b $25

.next_group
#_B574: LDA.b #$00
#_B576: STA.b $26

.next
#_B578: JSR RoomLoadOneObject

#_B57B: INC.b $26

#_B57D: LDA.b $26
#_B57F: CMP.b #$0F
#_B581: BNE .next

#_B583: DEC.b $25
#_B585: BPL .next_group

#_B587: RTS

;===================================================================================================

RoomLoadOneObject:
#_B588: LDA.b $26
#_B58A: CLC
#_B58B: ADC.b $28
#_B58D: STA.b $2A

#_B58F: LDA.b $25
#_B591: CLC
#_B592: ADC.b $27
#_B594: STA.b $29

#_B596: JSR GetObjectType_indoors

#_B599: LDA.b $2A
#_B59B: CMP.b #$0F
#_B59D: BCC .no_wrap

#_B59F: SEC
#_B5A0: SBC.b #$0F

.no_wrap
#_B5A2: STA.b $2A

#_B5A4: LDA.b $25
#_B5A6: STA.b $29

#_B5A8: JMP DrawAndFlushReplacementObject

;===================================================================================================

GetVRAMofTileFromXY:
#_B5AB: STA.b $0E

#_B5AD: LDA.b $2E
#_B5AF: STA.b $1C

#_B5B1: LDA.b $2F
#_B5B3: STA.b $1D

#_B5B5: JSR PrepObjectAttributeBits

#_B5B8: LDA.b #$01
#_B5BA: STA.b $0D

#_B5BC: LDA.b $1D
#_B5BE: ASL A
#_B5BF: ROL.b $0D
#_B5C1: ASL A
#_B5C2: ROL.b $0D
#_B5C4: ASL A
#_B5C5: ROL.b $0D
#_B5C7: ASL A
#_B5C8: ROL.b $0D
#_B5CA: ASL A
#_B5CB: ROL.b $0D
#_B5CD: CLC
#_B5CE: ADC.b $1C
#_B5D0: STA.b $0C

#_B5D2: BCC .no_overflow

#_B5D4: INC.b $0D

.no_overflow
#_B5D6: LDA.b $0D
#_B5D8: ORA.b $0B
#_B5DA: STA.b $0D

#_B5DC: RTS

;===================================================================================================

PrepObjectAttributeBits:
#_B5DD: LDA.b $1D
#_B5DF: AND.b #$FC
#_B5E1: ASL A
#_B5E2: STA.b $0F

#_B5E4: LDA.b $1C
#_B5E6: LSR A
#_B5E7: LSR A
#_B5E8: CLC
#_B5E9: ADC.b $0F
#_B5EB: ORA.b #$23C0>>0 ; VRAM $23C0
#_B5ED: STA.b $0F

#_B5EF: LDA.b #$23C0>>8
#_B5F1: ORA.b $0B
#_B5F3: STA.b $10

#_B5F5: LDA.b #$FC
#_B5F7: STA.b $11

#_B5F9: LDA.b $1D
#_B5FB: AND.b #$02
#_B5FD: ASL A
#_B5FE: TAX

#_B5FF: LDA.b $1C
#_B601: AND.b #$02
#_B603: BEQ .shift_less

#_B605: INX
#_B606: INX

.shift_less
#_B607: INX

#_B608: DEX
#_B609: BEQ .exit

.roll
#_B60B: ASL.b $12
#_B60D: SEC
#_B60E: ROL.b $11

#_B610: DEX
#_B611: BNE .roll

.exit
#_B613: RTS

;===================================================================================================

DrawOverworldTileToVRAM:
#_B614: LDA.b $0D
#_B616: LDX.b $0C
#_B618: JSR SetPPUADDRSafely

#_B61B: LDA.b ($5A),Y
#_B61D: STA.w PPUDATA

#_B620: INY
#_B621: LDA.b ($5A),Y
#_B623: STA.w PPUDATA

#_B626: INY

#_B627: LDA.b $0C
#_B629: CLC
#_B62A: ADC.b #$20
#_B62C: TAX

#_B62D: LDA.b $0D
#_B62F: JSR SetPPUADDRSafely

#_B632: LDA.b ($5A),Y
#_B634: STA.w PPUDATA

#_B637: INY
#_B638: LDA.b ($5A),Y
#_B63A: STA.w PPUDATA

#_B63D: LDA.b $10
#_B63F: LDX.b $0F
#_B641: PHA

#_B642: JSR SetPPUADDRSafely

#_B645: LDA.w PPUDATA
#_B648: LDA.w PPUDATA
#_B64B: AND.b $11
#_B64D: ORA.b $12
#_B64F: TAY

#_B650: PLA
#_B651: JSR SetPPUADDRSafely

#_B654: TYA
#_B655: STA.w PPUDATA

#_B658: JMP FlushCamera

;===================================================================================================

RoomTilemapDataOffset:
#_B65B: db $00 ; $0000 | 01 => ROOM 01
#_B65C: db $01 ; $01E0 | 02 => ROOM 02
#_B65D: db $02 ; $03C0 | 03 => ROOM 04
#_B65E: db $03 ; $05A0 | 04 => ROOM 05
#_B65F: db $04 ; $0780 | 05 => ROOM 06
#_B660: db $05 ; $0960 | 06 => ROOM 08
#_B661: db $06 ; $0B40 | 07 => ROOM 07
#_B662: db $07 ; $0D20 | 08 => ROOM 09, ROOM 15, ROOM 16, ROOM 17, ROOM 18
#_B663: db $FF ; ----- | 09 => ROOM 0A, ROOM 13, ROOM 14
#_B664: db $08 ; $0F00 | 0A => ROOM 0B, ROOM 12
#_B665: db $09 ; $10E0 | 0B => ROOM 0C
#_B666: db $09 ; $10E0 | 0C => ROOM 0D
#_B667: db $0A ; $12C0 | 0D => ROOM 0E
#_B668: db $0B ; $14A0 | 0E => ROOM 0F

; Technically, this value is in the table, but also it's not
;       db $87 ; $FD20 | 10 => ROOM 11

;===================================================================================================

LoadRoom:
#_B669: LDY.b $87

#_B66B: LDA.w RoomDataPointerIndex,Y
#_B66E: PHA

#_B66F: ASL A
#_B670: TAX

#_B671: LDA.w RoomTheme_patterns-2,X
#_B674: STA.b $5A
#_B676: LDA.w RoomTheme_patterns-1,X
#_B679: STA.b $5B

#_B67B: LDA.w RoomTheme_palettes-2,X
#_B67E: STA.b $5C
#_B680: LDA.w RoomTheme_palettes-1,X
#_B683: STA.b $5D

#_B685: PLA ; Get index * 12 in Y
#_B686: ASL A
#_B687: STA.b $1C

#_B689: ASL A
#_B68A: ADC.b $1C
#_B68C: ASL A
#_B68D: TAY

;---------------------------------------------------------------------------------------------------

#_B68E: LDX.b #$00

.next_background_palette
#_B690: TXA
#_B691: AND.b #$03
#_B693: BNE .not_transparent

#_B695: LDA.b #$0F
#_B697: BNE .add_black

.not_transparent
#_B699: LDA.w RoomPalettes-12,Y
#_B69C: INY

.add_black
#_B69D: STA.w $05E0,X

#_B6A0: INX
#_B6A1: CPX.b #$10
#_B6A3: BNE .next_background_palette

;---------------------------------------------------------------------------------------------------

#_B6A5: LDA.b $87
#_B6A7: CMP.b #$15 ; ROOM 15
#_B6A9: BCC .no_theme_change

#_B6AB: SEC
#_B6AC: SBC.b #$15
#_B6AE: TAX

#_B6AF: LDA.w Floor4Theme,X
#_B6B2: STA.b $1C

#_B6B4: LDY.b #$03

.next_theme_color
#_B6B6: LDA.w $05E4,Y
#_B6B9: AND.b #$F0
#_B6BB: ORA.b $1C
#_B6BD: STA.w $05E4,Y

#_B6C0: DEY
#_B6C1: BNE .next_theme_color

;---------------------------------------------------------------------------------------------------

.no_theme_change
#_B6C3: LDA.b $94
#_B6C5: PHA

#_B6C6: LDX.b #$03 ; GFXBANK 03
#_B6C8: STX.b $94

#_B6CA: JSR RefreshGFXBank

#_B6CD: LDA.b #$00
#_B6CF: STA.b $1C
#_B6D1: STA.b $1D

#_B6D3: LDY.b $87

#_B6D5: LDX.w RoomDataPointerIndex,Y
#_B6D8: CPX.b #$09
#_B6DA: BEQ .left_tower_spiral

#_B6DC: LDA.w RoomTilemapDataOffset-1,X
#_B6DF: TAX
#_B6E0: BEQ .no_adjustment

#_B6E2: CPX.b #$FF

.infinite_loop
#_B6E4: BEQ .infinite_loop
#_B6E6: BNE .adjust_address

.left_tower_spiral
#_B6E8: JSR LoadTowerSpiral

#_B6EB: JMP .continue

;---------------------------------------------------------------------------------------------------

.adjust_address
#_B6EE: LDA.b $1C
#_B6F0: CLC
#_B6F1: ADC.b #$E0
#_B6F3: STA.b $1C

#_B6F5: LDA.b $1D
#_B6F7: ADC.b #$01
#_B6F9: STA.b $1D

#_B6FB: DEX
#_B6FC: BNE .adjust_address

;---------------------------------------------------------------------------------------------------

.no_adjustment
#_B6FE: LDA.b #$0400>>0
#_B700: STA.b $20

#_B702: LDA.b #$0400>>8
#_B704: STA.b $21

#_B706: LDA.b $1D
#_B708: LDX.b $1C
#_B70A: JSR SetPPUADDRSafely

#_B70D: LDA.w PPUDATA

; Right shrine and left shrine use the same data
; but right shrine reads it in differently
#_B710: LDA.b $87
#_B712: CMP.b #$0D ; ROOM 0D
#_B714: BEQ .right_shrine

;---------------------------------------------------------------------------------------------------

#_B716: LDX.b #$1E

.next_row
#_B718: LDY.b #$00

.read_tile
#_B71A: LDA.w PPUDATA
#_B71D: STA.b ($20),Y

#_B71F: INY
#_B720: CPY.b #$10
#_B722: BNE .read_tile

#_B724: DEX
#_B725: BEQ .continue

#_B727: LDA.b #$10
#_B729: JSR .advance_pointer

#_B72C: JMP .next_row

;---------------------------------------------------------------------------------------------------

.right_shrine
#_B72F: LDX.b #$00

.read_shrine_a
#_B731: LDA.w PPUDATA
#_B734: STA.w $0400,X

#_B737: INX
#_B738: CPX.b #$60
#_B73A: BNE .read_shrine_a

#_B73C: LDX.b #$00

.read_shrine_b
#_B73E: LDA.w PPUDATA
#_B741: STA.w $0500,X

#_B744: INX
#_B745: CPX.b #$A0
#_B747: BNE .read_shrine_b

#_B749: LDX.b #$00

.read_shrine_c
#_B74B: LDA.w PPUDATA
#_B74E: STA.w $0460,X

#_B751: INX
#_B752: CPX.b #$A0
#_B754: BNE .read_shrine_c

#_B756: LDX.b #$00

.read_shrine_d
#_B758: LDA.w PPUDATA
#_B75B: STA.w $05A0,X

#_B75E: INX
#_B75F: CPX.b #$40
#_B761: BNE .read_shrine_d

;---------------------------------------------------------------------------------------------------

.continue
#_B763: JSR ReadIndoorTilemapHighBits

#_B766: PLA
#_B767: STA.b $94

#_B769: LDX.b #$FF

#_B76B: LDA.b $87
#_B76D: CMP.b #$18 ; ROOM 18
#_B76F: BCS .boss_or_ending

#_B771: ASL A
#_B772: TAX

#_B773: LDA.w HudsonBeeLocations-2,X
#_B776: STA.w $07B9

#_B779: LDA.w HudsonBeeLocations-1,X
#_B77C: STA.w $07BA

#_B77F: LDX.b #$00

.boss_or_ending
#_B781: STX.w $07BB

#_B784: LDA.b $87
#_B786: CMP.b #$09 ; ROOM 09
#_B788: BCS .no_music_box

#_B78A: ASL A
#_B78B: TAX

#_B78C: LDA.w MusicBoxLocations-2,X
#_B78F: STA.w $07CC

#_B792: LDA.w MusicBoxLocations-1,X

.set_y
#_B795: STA.w $07CD

#_B798: RTS

.no_music_box
#_B799: LDA.b #$FF
#_B79B: BNE .set_y

;---------------------------------------------------------------------------------------------------

#Floor4Theme:
#_B79D: db $01, $05, $09, $07

;---------------------------------------------------------------------------------------------------

.advance_pointer
#_B7A1: CLC
#_B7A2: ADC.b $20
#_B7A4: STA.b $20

#_B7A6: BCC .exit

#_B7A8: INC.b $21

.exit
#_B7AA: RTS

;===================================================================================================

QueueOverworldObjectUpdate:
#_B7AB: LDA.b ($5A),Y
#_B7AD: INY
#_B7AE: JSR AddToVRAMBuffer

#_B7B1: LDA.b ($5A),Y
#_B7B3: INY
#_B7B4: JSR AddToVRAMBuffer

#_B7B7: LDA.b $0C
#_B7B9: CLC
#_B7BA: ADC.b #$20
#_B7BC: STA.b $0C
#_B7BE: BNE .no_overflow

#_B7C0: INC.b $0D

.no_overflow
#_B7C2: LDA.b $0C
#_B7C4: JSR AddToVRAMBuffer

#_B7C7: LDA.b $0D
#_B7C9: JSR AddToVRAMBuffer

#_B7CC: LDA.b ($5A),Y
#_B7CE: JSR AddToVRAMBuffer

#_B7D1: INY
#_B7D2: LDA.b ($5A),Y
#_B7D4: JSR AddToVRAMBuffer

#_B7D7: LDA.b $0F
#_B7D9: JSR AddToVRAMBuffer

#_B7DC: LDA.b $10
#_B7DE: JSR AddToVRAMBuffer

#_B7E1: LDA.b $11
#_B7E3: JSR AddToVRAMBuffer

#_B7E6: LDA.b $12
#_B7E8: JSR AddToVRAMBuffer

#_B7EB: JMP FinishedVRAMBuffer

;===================================================================================================

QueueObjectPaletteChange:
#_B7EE: STA.b $12

#_B7F0: LDA.b $29
#_B7F2: ASL A
#_B7F3: AND.b #$1F
#_B7F5: STA.b $2E

#_B7F7: LDA.b $29
#_B7F9: AND.b #$10
#_B7FB: LSR A
#_B7FC: LSR A
#_B7FD: STA.b $0B

#_B7FF: LDA.b $2A
#_B801: SEC

.clamp_value
#_B802: SBC.b #$0F
#_B804: BCS .clamp_value

#_B806: ADC.b #$0F
#_B808: ASL A
#_B809: STA.b $2F

#_B80B: JSR GetVRAMofTileFromXY

#_B80E: LDX.b $19
#_B810: LDA.b #$04 ; VXFR 04
#_B812: JSR AddToVRAMBuffer

#_B815: LDA.b $0C
#_B817: JSR AddToVRAMBuffer

#_B81A: LDA.b $0D
#_B81C: JMP AddToVRAMBuffer

;===================================================================================================

DrawAndFlushReplacementObject:
#_B81F: LDA.b $29
#_B821: ASL A
#_B822: STA.b $2E

#_B824: LDA.b $2A
#_B826: ASL A
#_B827: STA.b $2F

#_B829: LDA.b $2B
#_B82B: JSR GetObjectPaletteFromTable
#_B82E: STA.b $12

#_B830: JSR GetVRAMofTileFromXY

#_B833: LDA.b #$00
#_B835: STA.b $1D

#_B837: LDY.b $2B

#_B839: LDA.b ($5A),Y
#_B83B: ASL A
#_B83C: ROL.b $1D
#_B83E: ASL A
#_B83F: ROL.b $1D
#_B841: ADC.b #ObjectTileNames>>0
#_B843: STA.b $1C

#_B845: LDA.b #ObjectTileNames>>8
#_B847: ADC.b $1D
#_B849: STA.b $1D

#_B84B: LDY.b #$00

;===================================================================================================

DrawAndFlush4x4Icon:
#_B84D: JSR Draw4x4Icon

#_B850: LDA.b $10
#_B852: LDX.b $0F

#_B854: PHA

#_B855: JSR SetPPUADDRSafely

#_B858: LDA.w PPUDATA
#_B85B: LDA.w PPUDATA
#_B85E: AND.b $11
#_B860: ORA.b $12
#_B862: TAY

#_B863: PLA
#_B864: JSR SetPPUADDRSafely

#_B867: TYA
#_B868: STA.w PPUDATA

#_B86B: JMP FlushCamera

;===================================================================================================

Draw4x4Icon:
#_B86E: LDA.b $0D
#_B870: LDX.b $0C
#_B872: JSR SetPPUADDRSafely

#_B875: LDA.b ($1C),Y
#_B877: STA.w PPUDATA

#_B87A: INY
#_B87B: LDA.b ($1C),Y
#_B87D: STA.w PPUDATA

#_B880: INY

#_B881: LDA.b $0C
#_B883: CLC
#_B884: ADC.b #$20
#_B886: TAX

#_B887: LDA.b $0D
#_B889: JSR SetPPUADDRSafely

#_B88C: LDA.b ($1C),Y
#_B88E: STA.w PPUDATA

#_B891: INY
#_B892: LDA.b ($1C),Y
#_B894: STA.w PPUDATA

#_B897: RTS

;===================================================================================================

RedrawObject:
#_B898: LDA.b $2B
#_B89A: JSR GetObjectPaletteFromTable
#_B89D: JSR QueueObjectPaletteChange

#_B8A0: LDA.b #$00
#_B8A2: STA.b $1D

#_B8A4: LDY.b $2B

#_B8A6: LDA.b ($5A),Y
#_B8A8: ASL A
#_B8A9: ROL.b $1D
#_B8AB: ASL A
#_B8AC: ROL.b $1D
#_B8AE: ADC.b #ObjectTileNames>>0
#_B8B0: STA.b $1C

#_B8B2: LDA.b #ObjectTileNames>>8
#_B8B4: ADC.b $1D
#_B8B6: STA.b $1D

#_B8B8: LDY.b #$00

;===================================================================================================

RedrawObject_prepped:
#_B8BA: JSR GetObjectTilesFromTable

#_B8BD: LDA.b $0F
#_B8BF: JSR AddToVRAMBuffer

#_B8C2: LDA.b $10
#_B8C4: JSR AddToVRAMBuffer

#_B8C7: LDA.b $11
#_B8C9: JSR AddToVRAMBuffer

#_B8CC: LDA.b $12
#_B8CE: JSR AddToVRAMBuffer

#_B8D1: JMP FinishedVRAMBuffer

;===================================================================================================

GetObjectTilesFromTable:
#_B8D4: LDA.b ($1C),Y
#_B8D6: INY
#_B8D7: JSR AddToVRAMBuffer

#_B8DA: LDA.b ($1C),Y
#_B8DC: INY
#_B8DD: JSR AddToVRAMBuffer

#_B8E0: LDA.b $0C
#_B8E2: CLC
#_B8E3: ADC.b #$20
#_B8E5: STA.b $0C
#_B8E7: BNE .no_overflow

#_B8E9: INC.b $0D

.no_overflow
#_B8EB: LDA.b $0C
#_B8ED: JSR AddToVRAMBuffer

#_B8F0: LDA.b $0D
#_B8F2: JSR AddToVRAMBuffer

#_B8F5: LDA.b ($1C),Y
#_B8F7: JSR AddToVRAMBuffer

#_B8FA: INY
#_B8FB: LDA.b ($1C),Y
#_B8FD: JMP AddToVRAMBuffer

;===================================================================================================

GetObjectPaletteFromTable:
#_B900: STA.b $1C

#_B902: LSR A
#_B903: LSR A
#_B904: TAY

#_B905: LDA.b ($5C),Y
#_B907: TAX

#_B908: LDA.b $1C
#_B90A: AND.b #$03
#_B90C: TAY
#_B90D: TXA

.next
#_B90E: DEY
#_B90F: BMI .finished

#_B911: LSR A
#_B912: LSR A
#_B913: JMP .next

.finished
#_B916: AND.b #$03

#_B918: RTS

;===================================================================================================

PanTilemap:
#_B919: LDA.b $8A
#_B91B: BEQ PanTilemap_indoors

#_B91D: JMP PanTilemap_overworld

;===================================================================================================

PanTilemap_indoors:
#_B920: LDA.b $14
#_B922: CMP.b $07
#_B924: BEQ .exit

#_B926: STA.b $07

#_B928: JSR PanObjectAttributes_indoors

#_B92B: LDA.b $07
#_B92D: AND.b #$07
#_B92F: ASL A
#_B930: ORA.b $13
#_B932: CMP.b #$06
#_B934: BEQ PanObjectCharacters_indoors

#_B936: CMP.b #$0B
#_B938: BEQ PanObjectCharacters_indoors

.exit
#_B93A: RTS

;===================================================================================================

PanObjectCharacters_indoors:
#_B93B: JSR GetObjectsInNewRow_indoors
#_B93E: JSR GetNewRowTilemapAddress

#_B941: LDX.b #$00

#_B943: LDA.b $14
#_B945: AND.b #$0F
#_B947: CMP.b #$08
#_B949: BCC .top_half

#_B94B: LDX.b #$02

.top_half
#_B94D: STX.b $15

;---------------------------------------------------------------------------------------------------

#_B94F: LDX.b $19
#_B951: LDA.b #$01 ; VXFR 01
#_B953: JSR AddToVRAMBuffer

#_B956: LDA.b $1F
#_B958: JSR AddToVRAMBuffer

#_B95B: LDA.b $1E
#_B95D: JSR AddToVRAMBuffer

#_B960: LDY.b #$00

.next_left
#_B962: JSR AddObjectTileToRow_indoors

#_B965: INY
#_B966: CPY.b #$10
#_B968: BNE .next_left

;---------------------------------------------------------------------------------------------------

#_B96A: LDA.b #$01 ; VXFR 01
#_B96C: JSR AddToVRAMBuffer

#_B96F: LDA.b $1F
#_B971: JSR AddToVRAMBuffer

#_B974: LDA.b $1E
#_B976: ORA.b #$04
#_B978: JSR AddToVRAMBuffer

.next_right
#_B97B: JSR AddObjectTileToRow_indoors

#_B97E: INY
#_B97F: CPY.b #$20
#_B981: BNE .next_right

#_B983: JMP FinishedVRAMBuffer

;===================================================================================================

AddObjectTileToRow_indoors:
#_B986: STY.b $75

#_B988: LDA.b #$00
#_B98A: STA.b $1D

#_B98C: LDA.w $06D0,Y
#_B98F: TAY

#_B990: LDA.b ($5A),Y
#_B992: ASL A
#_B993: ROL.b $1D
#_B995: ASL A
#_B996: ROL.b $1D
#_B998: ADC.b #ObjectTileNames>>0
#_B99A: STA.b $1C

#_B99C: LDA.b #ObjectTileNames>>8
#_B99E: ADC.b $1D
#_B9A0: STA.b $1D

#_B9A2: LDY.b $15

#_B9A4: LDA.b ($1C),Y
#_B9A6: JSR AddToVRAMBuffer

#_B9A9: INY
#_B9AA: LDA.b ($1C),Y
#_B9AC: JSR AddToVRAMBuffer

#_B9AF: LDY.b $75

#_B9B1: RTS

;===================================================================================================

AppendSingleToVRAMBuffer:
#_B9B2: LDX.b $19

#_B9B4: JSR AddToVRAMBuffer

#_B9B7: STX.b $19

#_B9B9: RTS

;===================================================================================================

AddToVRAMBuffer:
#_B9BA: STA.w $0200,X

#_B9BD: INX

#_B9BE: RTS

;===================================================================================================

GetNewRowTilemapAddress:
#_B9BF: LDA.b #$00
#_B9C1: STA.b $1F

#_B9C3: LDA.b $14
#_B9C5: LSR A
#_B9C6: LSR A
#_B9C7: LSR A
#_B9C8: LSR A
#_B9C9: ROR.b $1F
#_B9CB: LSR A
#_B9CC: ROR.b $1F
#_B9CE: LSR A
#_B9CF: ROR.b $1F
#_B9D1: ADC.b #$20
#_B9D3: STA.b $1E

#_B9D5: RTS

;===================================================================================================

PanObjectAttributes_indoors:
#_B9D6: LDA.b $14
#_B9D8: AND.b #$0F
#_B9DA: ASL A
#_B9DB: ORA.b $13
#_B9DD: CMP.b #$13
#_B9DF: BEQ .continue

#_B9E1: CMP.b #$0E
#_B9E3: BEQ .continue

#_B9E5: RTS

;---------------------------------------------------------------------------------------------------

.continue
#_B9E6: JSR GetObjectsInNewRow_indoors
#_B9E9: JSR GetNewRowAttributeAddress

#_B9EC: LDA.b $14
#_B9EE: AND.b #$10
#_B9F0: STA.b $15
#_B9F2: BEQ .bottom_mask

#_B9F4: LDY.b #$0F
#_B9F6: BNE .set_mask

.bottom_mask
#_B9F8: LDY.b #$F0

.set_mask
#_B9FA: STY.b $75

#_B9FC: LDX.b $19
#_B9FE: LDA.b #$02 ; VXFR 02
#_BA00: JSR AddToVRAMBuffer

#_BA03: LDA.b $1E
#_BA05: JSR AddToVRAMBuffer

#_BA08: LDA.b #$23C0>>8 ; VRAM $23C0
#_BA0A: JSR AddToVRAMBuffer

#_BA0D: LDA.b $75
#_BA0F: JSR AddToVRAMBuffer

;---------------------------------------------------------------------------------------------------

#_BA12: LDY.b #$00

.next_left
#_BA14: JSR GetRowObjectPalette_indoors

#_BA17: LDA.b $1F
#_BA19: JSR AddToVRAMBuffer

#_BA1C: CPY.b #$10
#_BA1E: BNE .next_left

;---------------------------------------------------------------------------------------------------

#_BA20: LDA.b #$02 ; VXFR 02
#_BA22: JSR AddToVRAMBuffer

#_BA25: LDA.b $1E
#_BA27: JSR AddToVRAMBuffer

#_BA2A: LDA.b #$27C0>>8 ; VRAM $27C0
#_BA2C: JSR AddToVRAMBuffer

#_BA2F: LDA.b $75
#_BA31: JSR AddToVRAMBuffer

;---------------------------------------------------------------------------------------------------

.next_right
#_BA34: JSR GetRowObjectPalette_indoors

#_BA37: LDA.b $1F
#_BA39: JSR AddToVRAMBuffer

#_BA3C: CPY.b #$20
#_BA3E: BNE .next_right

#_BA40: JMP FinishedVRAMBuffer

;===================================================================================================

GetObjectsInNewRow_indoors:
#_BA43: LDA.b $13
#_BA45: BEQ .panning_up

#_BA47: LDA.b $16
#_BA49: CLC
#_BA4A: ADC.b #$0F
#_BA4C: BNE .panning_down

.panning_up
#_BA4E: LDA.b $16

.panning_down
#_BA50: STA.b $2A

#_BA52: LDA.b #$00
#_BA54: STA.b $29

#_BA56: JSR GetObjectType_indoors
#_BA59: STY.b $75

;---------------------------------------------------------------------------------------------------

#_BA5B: LDY.b #$00
#_BA5D: LDX.b #$00

.next_object_base
#_BA5F: LDA.b ($1C),Y
#_BA61: LSR A
#_BA62: LSR A
#_BA63: LSR A
#_BA64: LSR A
#_BA65: STA.w $06D0,X

#_BA68: INX

#_BA69: LDA.b ($1C),Y
#_BA6B: AND.b #$0F
#_BA6D: STA.w $06D0,X

#_BA70: INX

#_BA71: INY
#_BA72: CPY.b #$10
#_BA74: BNE .next_object_base

;---------------------------------------------------------------------------------------------------

#_BA76: LDY.b $75
#_BA78: LDX.b #$00

.next_object_high
#_BA7A: LDA.w $0120,Y
#_BA7D: AND.w BitTable,X
#_BA80: BEQ .no_high_bit

#_BA82: LDA.w $06D0,X
#_BA85: ORA.b #$10
#_BA87: STA.w $06D0,X

.no_high_bit
#_BA8A: INX
#_BA8B: CPX.b #$20
#_BA8D: BEQ .exit

#_BA8F: TXA
#_BA90: AND.b #$07
#_BA92: BNE .next_object_high

#_BA94: INY
#_BA95: BNE .next_object_high

.exit
#_BA97: RTS

;===================================================================================================

GetRowObjectPalette_indoors:
#_BA98: STX.b $76

#_BA9A: TYA
#_BA9B: TAX

#_BA9C: LDA.b #$00
#_BA9E: STA.b $1F

#_BAA0: LDA.w $06D0,X
#_BAA3: INX
#_BAA4: STX.b $1D

#_BAA6: JSR GetObjectPaletteFromTable

#_BAA9: LDX.b $1D
#_BAAB: LSR A
#_BAAC: ROR.b $1F
#_BAAE: LSR A
#_BAAF: ROR.b $1F

#_BAB1: LDA.w $06D0,X

#_BAB4: INX
#_BAB5: STX.b $1D

#_BAB7: JSR GetObjectPaletteFromTable

#_BABA: LDX.b $1D
#_BABC: LSR A
#_BABD: ROR.b $1F
#_BABF: LSR A
#_BAC0: ROR.b $1F

#_BAC2: LDA.b $15
#_BAC4: BNE .low_nibble

#_BAC6: LSR.b $1F
#_BAC8: LSR.b $1F
#_BACA: LSR.b $1F
#_BACC: LSR.b $1F

.low_nibble
#_BACE: TXA
#_BACF: TAY
#_BAD0: LDX.b $76

#_BAD2: RTS

;===================================================================================================

GetNewRowAttributeAddress:
#_BAD3: LDA.b $14
#_BAD5: AND.b #$E0
#_BAD7: LSR A
#_BAD8: LSR A
#_BAD9: ADC.b #$23C0>>0 ; VRAM $23C0
#_BADB: STA.b $1E

#_BADD: RTS

;===================================================================================================
; BADE: Zarby and I both like this number.
;===================================================================================================
GetObjectType_indoors:
#_BADE: LDA.b $29
#_BAE0: LSR A
#_BAE1: PHP

#_BAE2: JSR GetTilemapAddress

#_BAE5: LDA.b ($1C),Y

#_BAE7: PLP
#_BAE8: BCS .low_nibble

#_BAEA: LSR A
#_BAEB: LSR A
#_BAEC: LSR A
#_BAED: LSR A
#_BAEE: db $BE ; LDX.w $0F29,Y - !DUMB skipping the AND doesn't matter

.low_nibble
#_BAEF: AND.b #$0F
#_BAF1: STA.b $2B
#_BAF3: TYA

#_BAF4: LSR A
#_BAF5: LSR A
#_BAF6: CLC
#_BAF7: ADC.b $1F
#_BAF9: TAY

#_BAFA: LDA.b $29
#_BAFC: AND.b #$07
#_BAFE: TAX

#_BAFF: LDA.w $0120,Y
#_BB02: AND.w BitTable,X
#_BB05: BEQ .exit

#_BB07: LDA.b $2B
#_BB09: ORA.b #$10
#_BB0B: STA.b $2B

.exit
#_BB0D: RTS

;===================================================================================================

GetTilemapAddress:
#_BB0E: TAY

#_BB0F: LDA.b #$02
#_BB11: STA.b $1D

#_BB13: LDA.b $2A
#_BB15: ASL A
#_BB16: ASL A
#_BB17: STA.b $1F
#_BB19: ASL A
#_BB1A: ASL A
#_BB1B: ROL.b $1D
#_BB1D: STA.b $1C

#_BB1F: RTS

;===================================================================================================

ChangeObjectType:
#_BB20: LDA.b $29
#_BB22: LSR A
#_BB23: PHP

#_BB24: JSR GetTilemapAddress

#_BB27: PLP
#_BB28: BCS .low_nibble

.high_nibble
#_BB2A: LDA.b $2B
#_BB2C: ASL A
#_BB2D: ASL A
#_BB2E: ASL A
#_BB2F: ASL A
#_BB30: STA.b $20

#_BB32: LDA.b ($1C),Y
#_BB34: AND.b #$0F
#_BB36: ORA.b $20
#_BB38: STA.b ($1C),Y

#_BB3A: JMP .continue

.low_nibble
#_BB3D: LDA.b $2B
#_BB3F: AND.b #$0F
#_BB41: STA.b $20

#_BB43: LDA.b ($1C),Y
#_BB45: AND.b #$F0
#_BB47: ORA.b $20
#_BB49: STA.b ($1C),Y

;---------------------------------------------------------------------------------------------------

.continue
#_BB4B: TYA
#_BB4C: LSR A
#_BB4D: LSR A
#_BB4E: CLC
#_BB4F: ADC.b $1F
#_BB51: TAY

#_BB52: LDA.b $29
#_BB54: AND.b #$07
#_BB56: TAX

#_BB57: LDA.b $2B
#_BB59: AND.b #$10
#_BB5B: BNE .low_tile_id

#_BB5D: LDA.w $0120,Y
#_BB60: AND.w BitTableInverted,X
#_BB63: STA.w $0120,Y

#_BB66: RTS

.low_tile_id
#_BB67: LDA.w $0120,Y
#_BB6A: ORA.w BitTable,X
#_BB6D: STA.w $0120,Y

#_BB70: RTS

;===================================================================================================

BitTable:
#_BB71: db $80, $40, $20, $10, $08, $04, $02, $01
#_BB79: db $80, $40, $20, $10, $08, $04, $02, $01
#_BB81: db $80, $40, $20, $10, $08, $04, $02, $01
#_BB89: db $80, $40, $20, $10, $08, $04, $02, $01

BitTableInverted:
#_BB91: db $7F, $BF, $DF, $EF, $F7, $FB, $FD, $FE

;===================================================================================================
; PALETTE DATA
;===================================================================================================
DefaultSpritePalettes:
; set A - Shops at least
#_BB99: db $0F, $21, $15, $36
#_BB9D: db $0F, $18, $27, $38
#_BBA1: db $0F, $0F, $27, $30
#_BBA5: db $0F, $18, $0C, $35

; set B - normal stuff
#_BBA9: db $0F, $21, $15, $36
#_BBAD: db $0F, $19, $26, $30
#_BBB1: db $0F, $16, $26, $36
#_BBB5: db $0F, $0F, $27, $30

;===================================================================================================

HandleOverworldPalette:
#_BBB9: LDA.b $98
#_BBBB: AND.b #$FE
#_BBBD: STA.b $1E

#_BBBF: ASL A
#_BBC0: ADC.b $1E
#_BBC2: TAX

#_BBC3: LDY.b #$00

#_BBC5: LDA.b #$08
#_BBC7: STA.b $1C

#_BBC9: JSR SetOverworldPalette

#_BBCC: LDA.b $98
#_BBCE: ASL A
#_BBCF: STA.b $1E
#_BBD1: ASL A
#_BBD2: ADC.b $1E
#_BBD4: ADC.b #$12
#_BBD6: TAX

#_BBD7: LDY.b #$08
#_BBD9: STY.b $1C

;===================================================================================================

SetOverworldPalette:

.next
#_BBDB: TYA
#_BBDC: AND.b #$03
#_BBDE: BNE .get_color

#_BBE0: LDA.b #$0F
#_BBE2: BNE .skip

.get_color
#_BBE4: LDA.w OverworldPalettes,X

#_BBE7: INX

.skip
#_BBE8: STA.w $05E0,Y

#_BBEB: INY

#_BBEC: DEC.b $1C
#_BBEE: BNE .next

#_BBF0: RTS

;===================================================================================================
; PALETTE DATA
;===================================================================================================
; TODO examine code better to name these
OverworldPalettes:
#_BBF1: db $06, $16, $26 ; 00 - Daytime high
#_BBF4: db $0B, $00, $10

#_BBF7: db $0F, $06, $16 ; 01 - Daytime low
#_BBFA: db $0F, $00, $10

#_BBFD: db $0F, $06, $36 ; 02 - Dark high
#_BC00: db $0F, $00, $30

#_BC03: db $29, $16, $26 ; 03 - Dark low
#_BC06: db $11, $16, $26

#_BC09: db $11, $18, $27 ; 04 - Lightning flash high
#_BC0C: db $11, $27, $37

#_BC0F: db $19, $06, $16 ; 05 - Lightning flash low
#_BC12: db $0C, $06, $16

#_BC15: db $0C, $0F, $07 ; 06 - 
#_BC18: db $0C, $07, $17

#_BC1B: db $39, $06, $36 ; 07 - 
#_BC1E: db $2C, $06, $36

#_BC21: db $3C, $0F, $37 ; 08 - TODO
#_BC24: db $3C, $37, $37

#_BC27: db $11, $10, $30 ; 09 - Title screen words

;===================================================================================================

HandleAllSprites:
#_BC2A: LDA.b #$FF
#_BC2C: STA.b $6D

#_BC2E: LDA.b $2B
#_BC30: PHA

#_BC31: LDA.b $29
#_BC33: PHA

#_BC34: LDA.b $2A
#_BC36: PHA

#_BC37: LDX.b #$00

.next_sprite
#_BC39: STX.b $5E

#_BC3B: LDA.w $06C0,X
#_BC3E: STA.b $6C

#_BC40: JSR HandleSprite
#_BC43: JSR HandleSpriteWonted

#_BC46: LDX.b $5E

#_BC48: LDA.b $6C
#_BC4A: STA.w $06C0,X

#_BC4D: INX
#_BC4E: CPX.b #$10
#_BC50: BNE .next_sprite

#_BC52: PLA
#_BC53: STA.b $2A

#_BC55: PLA
#_BC56: STA.b $29

#_BC58: PLA
#_BC59: STA.b $2B

;---------------------------------------------------------------------------------------------------

#EXIT_BC5B:
#_BC5B: RTS

;===================================================================================================

HandleSprite:
#_BC5C: LDA.b $6C
#_BC5E: BEQ EXIT_BC5B

#_BC60: JSR LoadSpriteVars

#_BC63: LDA.b $6C
#_BC65: JSR .run_vector

#_BC68: JMP SaveSpriteVars

;===================================================================================================

.run_vector
#_BC6B: ASL A
#_BC6C: TAY

#_BC6D: LDA.w SpriteVectors-1,Y
#_BC70: PHA

#_BC71: LDA.w SpriteVectors-2,Y
#_BC74: PHA

#_BC75: RTS

;===================================================================================================

SpriteVectors:
#_BC76: dw Sprite_01_Spring-1            ; 01 - SPRING
#_BC78: dw Sprite_02_Platform-1          ; 02 - PLATFORM
#_BC7A: dw Sprite_03_Crystal-1           ; 03 - CRYSTAL
#_BC7C: dw Sprite_04_BossFireball-1      ; 04 - BOSSFIRE BALL
#_BC7E: dw Sprite_05_HardTaru-1          ; 05 - HARD TARU
#_BC80: dw Sprite_06_BoxingGlove-1       ; 06 - BOXING GLOVE
#_BC82: dw Sprite_07_Paumeru-1           ; 07 - PAUMERU
#_BC84: dw Sprite_08_Mauri-1             ; 08 - MAURI / GIANT HEAD
#_BC86: dw Sprite_09_Katchinsha-1        ; 09 - KATCHINSHA
#_BC88: dw Sprite_0A_Boss-1              ; 0A - BOSS
#_BC8A: dw Sprite_0B_Heart-1             ; 0B - HEART
#_BC8C: dw Sprite_0C_Safuma-1            ; 0C - SAFUMA
#_BC8E: dw Sprite_0D_Voodoo-1            ; 0D - VOODOO / AGU-AGU
#_BC90: dw Sprite_0E_SlimeEye-1          ; 0E - SLIME EYE
#_BC92: dw Sprite_0F_HELP-1              ; 0F - HELP
#_BC94: dw Sprite_10_PhoneyPrincess-1    ; 10 - PHONEY PRINCESS
#_BC96: dw Sprite_11_Tambo-1             ; 11 - TAMBO / BONE WING
#_BC98: dw Sprite_12_Medamaruge-1        ; 12 - MEDAMARUGE
#_BC9A: dw Sprite_13_Projectile-1        ; 13 - PROJECTILE
#_BC9C: dw Sprite_14_Gyoro-1             ; 14 - GYORO
#_BC9E: dw Sprite_15_Beat-1              ; 15 - BEAT
#_BCA0: dw Sprite_16_EyeEye-1            ; 16 - EYE-EYE
#_BCA2: dw Sprite_17_Rubide-1            ; 17 - RUBIDE
#_BCA4: dw Sprite_18_Umbrella-1          ; 18 - UMBRELLA
#_BCA6: dw Sprite_19_Balloon-1           ; 19 - BALLOON
#_BCA8: dw Sprite_1A_TheHudsonBee-1      ; 1A - HUDSON BEE
#_BCAA: dw Sprite_1B_Key-1               ; 1B - KEY
#_BCAC: dw Sprite_1C_Fire-1              ; 1C - FIRE
#_BCAE: dw Sprite_1D_Unbao-1             ; 1D - UNBAO
#_BCB0: dw Sprite_1E_BrainToto-1         ; 1E - BRAIN TOTO
#_BCB2: dw Sprite_1F_Spark-1             ; 1F - SPARK
#_BCB4: dw Sprite_20_Flag-1              ; 20 - FLAG
#_BCB6: dw Sprite_21_Crow-1              ; 21 - CROW
#_BCB8: dw Sprite_22_StoryItem-1         ; 22 - STORY ITEM
#_BCBA: dw Sprite_23_Maharito-1          ; 23 - MAHARITO
#_BCBC: dw Sprite_24_Madora-1            ; 24 - MADORA
#_BCBE: dw Sprite_25_Note-1              ; 25 - NOTE
#_BCC0: dw Sprite_26_Gerubo-1            ; 26 - GERUBO
#_BCC2: dw Sprite_27_FlyingEye-1         ; 27 - FLYING EYE
#_BCC4: dw Sprite_28_Camry-1             ; 28 - CAMRY
#_BCC6: dw Sprite_29_Shim-1              ; 29 - SHIM

;===================================================================================================

Sprite_04_BossFireball:
#_BCC8: LDA.b $69
#_BCCA: CLC
#_BCCB: ADC.b $6A
#_BCCD: TAX

#_BCCE: AND.b #$07
#_BCD0: STA.b $6A
#_BCD2: TXA

#_BCD3: LSR A
#_BCD4: LSR A
#_BCD5: LSR A
#_BCD6: JSR GetAdditiveInverse

#_BCD9: CLC
#_BCDA: ADC.b $61
#_BCDC: STA.b $61

#_BCDE: JMP Sprite_25_Note

;===================================================================================================

Sprite_03_Crystal:
#_BCE1: LDA.b $63
#_BCE3: CMP.b #$B2
#_BCE5: BCS .dont_drop

#_BCE7: INC.b $63

.dont_drop
#_BCE9: LDA.b #$04
#_BCEB: STA.b $60

#_BCED: RTS

;===================================================================================================
; Toyota Camry
;===================================================================================================
Sprite_28_Camry:
#_BCEE: JSR HandleRespawn

#_BCF1: LDA.b $8E
#_BCF3: LSR A
#_BCF4: LSR A
#_BCF5: AND.b #$01
#_BCF7: CLC
#_BCF8: ADC.b #$25
#_BCFA: STA.b $60

;===================================================================================================

ToyotaMovement:
#_BCFC: JSR HorizontalToyotaMovement

#_BCFF: JSR GetFrameMod2
#_BD02: BEQ .exit

#_BD04: LDA.b $63
#_BD06: ORA.b $64
#_BD08: TAX

#_BD09: LDA.b $65
#_BD0B: AND.b #$02
#_BD0D: BEQ .moving_down

#_BD0F: CPX.b #$10
#_BD11: BEQ .change_vertical_direction

#_BD13: LDA.b #$02
#_BD15: JMP MoveSpriteUp

.moving_down
#_BD18: CPX.b #$C1
#_BD1A: BEQ .change_vertical_direction

#_BD1C: LDA.b #$02
#_BD1E: JMP MoveSpriteDown

.change_vertical_direction
#_BD21: LDA.b $65
#_BD23: EOR.b #$02
#_BD25: STA.b $65

.exit
#_BD27: RTS

;===================================================================================================

HorizontalToyotaMovement:
#_BD28: LDA.b $61
#_BD2A: ORA.b $62
#_BD2C: TAX

#_BD2D: LDA.b $65
#_BD2F: AND.b #$01
#_BD31: BEQ .moving_right

#_BD33: CPX.b #$10
#_BD35: BEQ .turn_around

#_BD37: LDA.b #$02
#_BD39: JMP MoveSpriteLeft

.moving_right
#_BD3C: CPX.b #$E1
#_BD3E: BEQ .turn_around

#_BD40: LDA.b #$02
#_BD42: JMP MoveSpriteRight

.turn_around
#_BD45: JMP SpriteTurnAroundX

;===================================================================================================

Sprite_27_FlyingEye:
#_BD48: JSR HandleRespawn

#_BD4B: JSR GetFrameBit4inY

#_BD4E: LDA.w .graphics,Y
#_BD51: STA.b $60

#_BD53: JMP SafumaMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_BD56: db $5F, $60

;===================================================================================================

Sprite_17_Rubide:
#_BD58: JSR HandleRespawn
#_BD5B: JSR GetFrameBit4inY

#_BD5E: LDA.w .graphics,Y
#_BD61: STA.b $60

#_BD63: JMP MauriMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_BD66: db $3A, $3B

;===================================================================================================

GetFrameMod2:
#_BD68: LDA.b $8E
#_BD6A: AND.b #$01

#_BD6C: RTS

;===================================================================================================

GetFrameMod4:
#_BD6D: LDA.b $8E
#_BD6F: AND.b #$03

#_BD71: RTS

;===================================================================================================

GetFrameBit4inY:
#_BD72: JSR .roll_thrice
#_BD75: AND.b #$01
#_BD77: TAY

#_BD78: RTS

;---------------------------------------------------------------------------------------------------

.roll_thrice
#_BD79: LDA.b $8E
#_BD7B: ROR A
#_BD7C: ROR A
#_BD7D: ROR A

#_BD7E: RTS

;===================================================================================================

Sprite_29_Shim:
#_BD7F: JSR HandleRespawn
#_BD82: JSR GetFrameBit4inY

#_BD85: LDA.w .graphics,Y
#_BD88: STA.b $60

#_BD8A: JMP ShimmySlimeMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_BD8D: db $66, $67

;===================================================================================================

Sprite_0E_SlimeEye:
Sprite_1D_Unbao:
#_BD8F: JSR HandleRespawn

#_BD92: JSR GetFrameBit4inY
#_BD95: STA.b $1C

#_BD97: LDA.b $94 ; check GFX bank for character
#_BD99: AND.b #$02
#_BD9B: CLC
#_BD9C: ADC.b $1C
#_BD9E: TAY

#_BD9F: LDA.w .graphics,Y
#_BDA2: STA.b $60

#_BDA4: JMP ShimmySlimeMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_BDA7: db $1E, $1F
#_BDA9: db $64, $65

;===================================================================================================

Sprite_0D_Voodoo:
#_BDAB: JSR HandleRespawn

#_BDAE: JSR GetFrameBit4inY
#_BDB1: TAY ; IT'S ALREADY THERE!!!

#_BDB2: LDA.w .graphics,Y
#_BDB5: STA.b $60

#_BDB7: LDA.b $68
#_BDB9: BNE .jumping

#_BDBB: DEC.b $67
#_BDBD: BPL .handle_movement

;---------------------------------------------------------------------------------------------------

.jumping
#_BDBF: INC.b $68

#_BDC1: LDA.b $68
#_BDC3: CMP.b #$78
#_BDC5: BEQ .set_jump_timer

#_BDC7: CMP.b #$5A
#_BDC9: BCS .exit

#_BDCB: CMP.b #$3C
#_BDCD: BCS .move_down

#_BDCF: CMP.b #$1E
#_BDD1: BCS .move_up

#_BDD3: RTS

;---------------------------------------------------------------------------------------------------

.move_up
#_BDD4: LDA.b #$02
#_BDD6: JMP MoveSpriteUp

.move_down
#_BDD9: LDA.b #$02
#_BDDB: JMP MoveSpriteDown

;---------------------------------------------------------------------------------------------------

.set_jump_timer
#_BDDE: LDA.b #$00
#_BDE0: STA.b $68

#_BDE2: JSR Random
#_BDE5: AND.b #$0F
#_BDE7: CLC
#_BDE8: ADC.b #$78
#_BDEA: STA.b $67

.exit
#_BDEC: RTS

;---------------------------------------------------------------------------------------------------

.handle_movement
#_BDED: LDA.w GetFrameMod2
#_BDF0: BEQ .exit

#_BDF2: JMP VoodooMoveX

;---------------------------------------------------------------------------------------------------

.graphics
#_BDF5: db $08, $09

;===================================================================================================

SafumaGraphics:
#_BDF7: db $5B, $5C

;===================================================================================================

Sprite_0C_Safuma:
#_BDF9: LDA.b #$02
#_BDFB: STA.b $B5

#_BDFD: JSR HandleRespawn

#_BE00: JSR GetFrameBit4inY

#_BE03: LDA.w SafumaGraphics,Y
#_BE06: STA.b $60

;===================================================================================================

#SafumaMovement:
#_BE08: JSR GetFrameMod4
#_BE0B: BNE .exit_a

#_BE0D: JSR FlyAggressively

#_BE10: JSR FlyJankilyY

#_BE13: INC.b $66

.exit_a
#_BE15: RTS

;===================================================================================================

GyoroMovement:
#_BE16: LDA.b $61
#_BE18: AND.b #$0F
#_BE1A: BNE MoveSpriteWithFalling

#_BE1C: LDA.b $63
#_BE1E: AND.b #$0F
#_BE20: BNE .fall_down

#_BE22: JSR FullCoordinatesToTilemapXY

#_BE25: INC.b $2A

#_BE27: JSR GetObjectType_indoors

#_BE2A: LDA.b $2B
#_BE2C: CMP.b #$0D ; OBJECT 0D
#_BE2E: BCC .fall_down

#_BE30: LDA.b $65
#_BE32: AND.b #$01
#_BE34: STA.b $65

#_BE36: DEC.b $2A

#_BE38: JSR CheckCollisionInFrontOfSprite
#_BE3B: BCS .turn_around

;===================================================================================================

#MoveSpriteWithFalling:
#_BE3D: LDA.b $65
#_BE3F: AND.b #$01
#_BE41: BEQ .move_right

#_BE43: LDA.b $B5
#_BE45: JMP MoveSpriteLeft

.move_right
#_BE48: LDA.b $B5
#_BE4A: JMP MoveSpriteRight

;---------------------------------------------------------------------------------------------------

.turn_around
#_BE4D: INC.b $67

#_BE4F: LDA.b $67
#_BE51: CMP.b #$02
#_BE53: BCS .die

#_BE55: JMP SpriteTurnAroundX

.fall_down
#_BE58: LDA.b #$00
#_BE5A: STA.b $67

#_BE5C: LDA.b $65
#_BE5E: ORA.b #$02
#_BE60: STA.b $65

#_BE62: LDA.b #$02
#_BE64: JMP MoveSpriteDown

.cant_exit ; unreachable
#_BE67: RTS

.die
#_BE68: INC.b $5F

#_BE6A: RTS

;===================================================================================================

Sprite_0B_Heart:
#_BE6B: JSR SpriteMoveWithScroll
#_BE6E: BCS RevertHeartToDropper

#_BE70: JSR GetFrameMod4
#_BE73: BNE .exit

#_BE75: INC.b $66

#_BE77: LDA.b $66
#_BE79: CMP.b #$B0
#_BE7B: BCC .exit

;===================================================================================================

#RevertHeartToDropper:
#_BE7D: LDA.b $67 ; Get dropper sprite ID
#_BE7F: STA.b $6C

#_BE81: LDA.b #$01
#_BE83: STA.b $5F

#_BE85: JSR AmIAWeirdFlyingGuy
#_BE88: BNE .exit

#_BE8A: LDA.b $69
#_BE8C: STA.b $61

#_BE8E: LDA.b $6A
#_BE90: STA.b $63

.exit
#_BE92: RTS

;===================================================================================================

DeleteSpriteself:
#_BE93: LDA.b #$00
#_BE95: STA.b $6C

#_BE97: RTS

;===================================================================================================

Sprite_0A_Boss:
#_BE98: LDA.b $5F
#_BE9A: BEQ .alive

#_BE9C: INC.b $5F

#_BE9E: LDA.b $5F
#_BEA0: BMI .turn_into_crystal

#_BEA2: AND.b #$07
#_BEA4: CMP.b #$01
#_BEA6: BNE .exit

#_BEA8: JSR Random
#_BEAB: AND.b #$03
#_BEAD: ASL A
#_BEAE: TAX

#_BEAF: LDA.b $61
#_BEB1: CLC
#_BEB2: ADC.w BossExplosionOffsets+0,X
#_BEB5: STA.b $38

#_BEB7: LDA.b $63
#_BEB9: CLC
#_BEBA: ADC.w BossExplosionOffsets+1,X
#_BEBD: STA.b $35

#_BEBF: LDA.b #$01
#_BEC1: JSR SpawnSmokePuff

#_BEC4: LDA.b #$07 ; SFX 07
#_BEC6: STA.b $E6

.exit
#_BEC8: RTS

;---------------------------------------------------------------------------------------------------

.turn_into_crystal
#_BEC9: LDA.b $61
#_BECB: CLC
#_BECC: ADC.b #$08
#_BECE: STA.b $61

#_BED0: LDA.b #$03 ; SPRITE 03
#_BED2: STA.b $6C

#_BED4: RTS

;---------------------------------------------------------------------------------------------------

.alive
#_BED5: LDA.b $63
#_BED7: CMP.b #$90 ; !HARDCODED - boss platform ground
#_BED9: BEQ .grounded

.retry_main
#_BEDB: JSR HandleBossShooting
#_BEDE: JSR AnimateBoss
#_BEE1: JSR MoveBossX

#_BEE4: LDA.b $67
#_BEE6: BPL .moving_down

#_BEE8: JSR GetAdditiveInverse
#_BEEB: JSR MoveSpriteUp

#_BEEE: JMP .handle_y_accel

.moving_down
#_BEF1: JSR MoveSpriteDown

;---------------------------------------------------------------------------------------------------

.handle_y_accel
#_BEF4: LDA.b $66
#_BEF6: CLC
#_BEF7: ADC.b #$1D
#_BEF9: STA.b $66
#_BEFB: BCC .keep_y_speed

#_BEFD: INC.b $67

.keep_y_speed
#_BEFF: LDA.b $63
#_BF01: CMP.b #$90 ; !HARDCODED - boss platform ground
#_BF03: BCS .reset_jump

#_BF05: RTS

.reset_jump
#_BF06: LDA.b #$FD
#_BF08: STA.b $67

#_BF0A: LDA.b #$00
#_BF0C: STA.b $66

#_BF0E: RTS

;---------------------------------------------------------------------------------------------------

.grounded
#_BF0F: LDA.b $67
#_BF11: CMP.b #$FD
#_BF13: BEQ .already_jumping

#_BF15: JSR .reset_jump

.already_jumping
#_BF18: JMP .retry_main

;===================================================================================================

BossExplosionOffsets:
#_BF1B: db $04, $08
#_BF1D: db $14, $0C
#_BF1F: db $0C, $18
#_BF21: db $10, $28

;===================================================================================================

MoveBossX:
#_BF23: LDA.b $8E
#_BF25: AND.b #$3F
#_BF27: BNE .no_cheese_check

; Is Milon behind the boss?
#_BF29: LDA.b $61
#_BF2B: CMP.b $3E
#_BF2D: BCS .no_cheese_check

#_BF2F: LDA.b $65
#_BF31: AND.b #$FE
#_BF33: STA.b $65

.no_cheese_check
#_BF35: LDA.b $8E
#_BF37: AND.b #$01
#_BF39: BNE .exit

#_BF3B: LDA.b $65
#_BF3D: AND.b #$01
#_BF3F: EOR.b #$01
#_BF41: ASL A
#_BF42: ADC.b #$FF
#_BF44: CLC
#_BF45: ADC.b $61
#_BF47: STA.b $61

#_BF49: LDX.b $B4
#_BF4B: CMP.w BossLeftEdge-1,X
#_BF4E: BCC .turn_around

#_BF50: CMP.b #$D1
#_BF52: BCC .exit

.turn_around
#_BF54: LDA.b $65
#_BF56: EOR.b #$01
#_BF58: STA.b $65

.exit
#_BF5A: RTS

;===================================================================================================

AnimateBoss:
#_BF5B: LDA.b $8E
#_BF5D: AND.b #$07
#_BF5F: BNE .exit

#_BF61: LDA.b $60
#_BF63: CMP.b #$06
#_BF65: BCC .flip_anim

#_BF67: CLC
#_BF68: ADC.b #$01
#_BF6A: CMP.b #$09
#_BF6C: BCC .set_anim

#_BF6E: DEC.b $60

.flip_anim
#_BF70: LDA.b $60
#_BF72: EOR.b #$01

.set_anim
#_BF74: STA.b $60

.exit
#_BF76: RTS

;===================================================================================================

HandleBossShooting:
#_BF77: DEC.b $69
#_BF79: BPL .exit

#_BF7B: JSR Random
#_BF7E: AND.b #$0F
#_BF80: LDX.b $B4
#_BF82: ADC.w BossShotDelay-1,X
#_BF85: STA.b $69

#_BF87: LDA.b $B8
#_BF89: ASL A
#_BF8A: JSR GetAdditiveInverse
#_BF8D: CLC
#_BF8E: ADC.b $69
#_BF90: STA.b $69

#_BF92: LDA.b $63
#_BF94: STA.b $22

#_BF96: CLC
#_BF97: ADC.b #$10
#_BF99: STA.b $63

#_BF9B: LDA.b #$04 ; SPRITE 04
#_BF9D: JSR SpawnSprite

#_BFA0: JSR Random
#_BFA3: AND.b #$01

#_BFA5: LDY.b $B4
#_BFA7: CPY.b #$03
#_BFA9: ADC.b #$FE
#_BFAB: STA.w $0608,X

#_BFAE: LDA.b #$00
#_BFB0: STA.w $0607,X

#_BFB3: JSR Random
#_BFB6: AND.b #$03
#_BFB8: TAY

#_BFB9: LDA.w BossShotSpeed,Y
#_BFBC: STA.w $060A,X

#_BFBF: LDA.b $22
#_BFC1: STA.b $63

#_BFC3: LDA.b #$04 ; SFX 04
#_BFC5: STA.b $E6

.exit
#_BFC7: RTS

;===================================================================================================

BossShotSpeed:
#_BFC8: db $04, $08, $0C, $12

BossShotDelay:
#_BFCC: db $2A, $26, $22, $1E, $1A, $16, $12

BossLeftEdge:
#_BFD3: db $90, $88, $80, $78, $70, $68, $60

;===================================================================================================

GetAdditiveInverse:
#_BFDA: EOR.b #$FF
#_BFDC: CLC
#_BFDD: ADC.b #$01

#_BFDF: RTS

;===================================================================================================

Sprite_25_Note:
#_BFE0: LDA.b $67
#_BFE2: BPL .falling

#_BFE4: EOR.b #$FF
#_BFE6: CLC
#_BFE7: ADC.b #$01

#_BFE9: JSR MoveSpriteUp

#_BFEC: JMP .continue

.falling
#_BFEF: JSR MoveSpriteDown

.continue
#_BFF2: LDA.b $66
#_BFF4: CLC
#_BFF5: ADC.b #$1D
#_BFF7: STA.b $66

#_BFF9: BCC .delay

#_BFFB: INC.b $67

.delay
#_BFFD: LDA.b $64
#_BFFF: BNE .die

#_C001: RTS

.die
#_C002: JMP DeleteSpriteself

;===================================================================================================

Sprite_23_Maharito:
#_C005: LDA.b $66 ; TODO what is this timer?
#_C007: BPL .skip_timer

#_C009: LDX.b $4B

#_C00B: LDA.b $4C
#_C00D: BNE .no_resistance

#_C00F: CPX.b #$98
#_C011: BCC .new_movement_roll
#_C013: BCS .resist_timer

.no_resistance
#_C015: CPX.b #$60
#_C017: BCS .new_movement_roll

.resist_timer
#_C019: INC.b $66
#_C01B: BEQ .new_movement_roll
#_C01D: BNE .start_movement

.skip_timer
#_C01F: JSR GetFrameMod4
#_C022: BNE .start_movement

#_C024: LDA.b $66
#_C026: BEQ .new_movement_roll

#_C028: DEC.b $66
#_C02A: BNE .start_movement

#_C02C: LDA.b #$80
#_C02E: STA.b $66
#_C030: BNE .start_movement

.new_movement_roll
#_C032: JSR Random
#_C035: AND.b #$7F
#_C037: ORA.b #$20
#_C039: STA.b $66

;---------------------------------------------------------------------------------------------------

.start_movement
#_C03B: LDA.b #(MaharitoYMovement-1)>>8
#_C03D: PHA

#_C03E: LDA.b #(MaharitoYMovement-1)>>0
#_C040: PHA

#_C041: JSR GetFrameMod4
#_C044: BEQ .try_x_first

#_C046: RTS

.try_x_first
#_C047: LDA.b $61
#_C049: AND.b #$0F
#_C04B: BNE .dont_check_x

#_C04D: JSR FullCoordinatesToTilemapXY

#_C050: JSR CheckCollisionInFrontOfSprite
#_C053: BCS MaharitoTurnAround

#_C055: INC.b $2A
#_C057: JSR GetObjectType_indoors
#_C05A: DEC.b $2A

#_C05C: LDA.b $2B
#_C05E: CMP.b #$0D ; OBJECT 0D
#_C060: BCS MaharitoTurnAround

.dont_check_x
#_C062: LDA.b #$02
#_C064: STA.b $B5

#_C066: JMP MoveSpriteWithFalling

;---------------------------------------------------------------------------------------------------

#MaharitoYMovement:
#_C069: JSR MaharitoGetAltitudeChange
#_C06C: STX.b $B5

.next_y_movement
#_C06E: LDA.b $B5
#_C070: BEQ .exit

#_C072: JSR MaharitoAltitude

#_C075: DEC.b $B5
#_C077: BNE .next_y_movement

.exit
#_C079: RTS

;===================================================================================================

MaharitoAltitude:
#_C07A: LDA.b $63
#_C07C: AND.b #$0F
#_C07E: BNE .dont_check_y

#_C080: JSR FullCoordinatesToTilemapXY

#_C083: JSR MaharitoGetTileInYDirection
#_C086: BCS .change_direction

.dont_check_y
#_C088: LDA.b $65
#_C08A: AND.b #$02
#_C08C: BNE .moving_down

#_C08E: JMP MoveSpriteUpBy1

.moving_down
#_C091: JMP MoveSpriteDownBy1

;---------------------------------------------------------------------------------------------------

.change_direction
#_C094: LDA.b $65
#_C096: EOR.b #$02
#_C098: STA.b $65

#_C09A: AND.b #$02
#_C09C: BEQ .boing

#_C09E: LDA.b #$02
#_C0A0: STA.b $67

#_C0A2: RTS

.boing
#_C0A3: LDA.b #$08 ; SFX 08
#_C0A5: STA.b $E6

#_C0A7: LDA.b #$10
#_C0A9: STA.b $67

#_C0AB: RTS

;===================================================================================================

MaharitoTurnAround:
#_C0AC: JMP SpriteTurnAroundX

;===================================================================================================

MaharitoGetTileInYDirection:
#_C0AF: DEC.b $2A

#_C0B1: LDA.b $65
#_C0B3: AND.b #$02
#_C0B5: BEQ .moving_up

#_C0B7: LDA.b $2A
#_C0B9: CLC
#_C0BA: ADC.b #$03
#_C0BC: STA.b $2A

.moving_up
#_C0BE: JSR GetObjectType_indoors

#_C0C1: LDA.b $2B
#_C0C3: CMP.b #$0D ; OBJECT 0D

#_C0C5: RTS

;===================================================================================================

MaharitoGetAltitudeChange:
#_C0C6: LDA.b $67
#_C0C8: CLC
#_C0C9: ADC.b $6A
#_C0CB: TAX
#_C0CC: AND.b #$07
#_C0CE: STA.b $6A

#_C0D0: TXA
#_C0D1: LSR A
#_C0D2: LSR A
#_C0D3: LSR A
#_C0D4: AND.b #$03
#_C0D6: TAX

#_C0D7: JSR GetFrameMod4
#_C0DA: BNE .exit

#_C0DC: LDA.b $65
#_C0DE: AND.b #$02
#_C0E0: BEQ .decrement

#_C0E2: LDA.b $67
#_C0E4: CMP.b #$10
#_C0E6: BCS .exit

#_C0E8: INC.b $67

#_C0EA: RTS

.decrement
#_C0EB: LDA.b $67
#_C0ED: CMP.b #$02
#_C0EF: BCC .exit

#_C0F1: DEC.b $67

.exit
#_C0F3: RTS

;===================================================================================================

Sprite_22_StoryItem:
#_C0F4: LDX.b $67

#_C0F6: LDA.w .graphics,X
#_C0F9: STA.b $60

#_C0FB: LDA.b #$00
#_C0FD: STA.b $65

#_C0FF: RTS

;---------------------------------------------------------------------------------------------------

.graphics
#_C100: db $47 ; 00 - Drum
#_C101: db $0F ; 01 - Cymbals
#_C102: db $10 ; 02 - Euphonium
#_C103: db $48 ; 03 - Ocarina
#_C104: db $34 ; 04 - Harp
#_C105: db $35 ; 05 - Trumpet
#_C106: db $33 ; 06 - Violin / Music box
#_C107: db $49 ; 07 - Crown
#_C108: db $4A ; 08 - Cane

;===================================================================================================

Sprite_21_Crow:
#_C109: JSR GetFrameMod2
#_C10C: BNE .exit

#_C10E: JSR GetFrameBit4inY
#_C111: CLC
#_C112: ADC.b #$08
#_C114: STA.b $60

#_C116: JMP BigGuyMovement

.exit
#_C119: RTS

;===================================================================================================

Sprite_20_Flag:
#_C11A: LDX.b $5F
#_C11C: DEX
#_C11D: BEQ RespawnInRandomPosition

#_C11F: DEX
#_C120: BEQ InitialChargeTowardsMilon

#_C122: JSR AdjustCoordinatesWithScroll

#_C125: JSR GetFrameBit4inY

#_C128: LDA.w .graphics,Y
#_C12B: STA.b $60

#_C12D: LDA.b #$01
#_C12F: STA.b $1C

#_C131: JSR MoveRadiallyWithScreenCheckX
#_C134: BCS DieLikeSpark

#_C136: JSR MoveRadiallyWithScreenCheckY
#_C139: BCS DieLikeSpark

#_C13B: JSR GetFrameMod2
#_C13E: BNE .exit

;---------------------------------------------------------------------------------------------------

#_C140: LDA.b $65
#_C142: AND.b #$07
#_C144: CLC
#_C145: ADC.b #$02
#_C147: CMP.b #$05
#_C149: BCC .jank_horizontal

#_C14B: JSR FlyJankilyY

#_C14E: INC.b $66

#_C150: RTS

.jank_horizontal
#_C151: JSR FlyJankilyX

#_C154: INC.b $66

.exit
#_C156: RTS

;---------------------------------------------------------------------------------------------------

.graphics
#_C157: db $1A, $23

;===================================================================================================

Sprite_1F_Spark:
#_C159: LDX.b $5F
#_C15B: DEX
#_C15C: BEQ RespawnInRandomPosition

#_C15E: DEX
#_C15F: BEQ InitialChargeTowardsMilon

#_C161: JSR AdjustCoordinatesWithScroll

#_C164: LDA.b #$27
#_C166: STA.b $60

#_C168: LDA.b #$01
#_C16A: STA.b $1C

#_C16C: JSR MoveRadiallyWithScreenCheckX
#_C16F: BCS DieLikeSpark

#_C171: JSR MoveRadiallyWithScreenCheckY
#_C174: BCS DieLikeSpark

#_C176: RTS

;===================================================================================================

DieLikeSpark:
#_C177: INC.b $5F

#_C179: RTS

;---------------------------------------------------------------------------------------------------

InitialChargeTowardsMilon:
#_C17A: JSR GetFrameMod2
#_C17D: BNE .exit

#_C17F: DEC.b $66 ; respawn timer
#_C181: BPL .exit

#_C183: LDA.b #$00
#_C185: STA.b $5F

#_C187: LDA.b $61
#_C189: STA.b $81

#_C18B: LDA.b $63
#_C18D: STA.b $82

#_C18F: JSR GetDirectionTowardsMilon
#_C192: STA.b $65

.exit
#_C194: RTS

;===================================================================================================

RespawnInRandomPosition:
#_C195: JSR Random
#_C198: AND.b #$7F
#_C19A: TAX
#_C19B: STA.b $66

#_C19D: TXA
#_C19E: AND.b #$07
#_C1A0: ASL A
#_C1A1: TAX

#_C1A2: LDA.w RandomScreenRespawns+0,X
#_C1A5: STA.b $61

#_C1A7: LDA.w RandomScreenRespawns+1,X
#_C1AA: STA.b $63

#_C1AC: INC.b $5F

;---------------------------------------------------------------------------------------------------

#EXIT_C1AE:
#_C1AE: RTS

;===================================================================================================

Sprite_13_Projectile:
#_C1AF: JSR SpriteMoveWithScroll

#_C1B2: LDX.b $67

#_C1B4: LDA.w .speed,X
#_C1B7: STA.b $1C

#_C1B9: JSR MoveRadiallyWithScreenCheckX
#_C1BC: BCS .die

#_C1BE: JSR MoveRadiallyWithScreenCheckY
#_C1C1: BCC EXIT_C1AE

.die
#_C1C3: JMP DeleteProjectileSelf

;---------------------------------------------------------------------------------------------------

.speed
#_C1C6: db $01, $02, $02, $02, $02

;===================================================================================================

Sprite_1C_Fire:
#_C1CB: LDA.b #$0A
#_C1CD: STA.b $60

#_C1CF: JSR GetFrameMod2
#_C1D2: AND.w $07C3 ; check for push block touch
#_C1D5: BEQ EXIT_C228

;===================================================================================================

BigGuyMovement:
#_C1D7: LDA.b $5F
#_C1D9: BEQ FlyAroundRandomly

#_C1DB: INC.b $5F
#_C1DD: BPL .exit

#_C1DF: JSR DeleteSpriteself

#_C1E2: LDA.b $87
#_C1E4: CMP.b #$0C ; ROOM 0C
#_C1E6: BEQ .become_crown

#_C1E8: CMP.b #$0D ; ROOM 0D
#_C1EA: BNE .exit

#_C1EC: LDA.b #$22 ; SPRITE 22
#_C1EE: STA.b $6C

#_C1F0: LDA.b #$00
#_C1F2: STA.b $62
#_C1F4: STA.b $64

#_C1F6: LDA.b #$20
#_C1F8: STA.b $61

#_C1FA: LDA.b #$90
#_C1FC: STA.b $63

#_C1FE: LDA.b #$08
#_C200: STA.b $67

#_C202: RTS

;---------------------------------------------------------------------------------------------------

.become_crown
#_C203: LDA.b #$22 ; SPRITE 22
#_C205: LDA.b #$22 ; SPRITE 22 - REDUNDANT!!!!!!!!
#_C207: STA.b $6C

#_C209: LDA.b #$01
#_C20B: STA.b $62
#_C20D: STA.b $64

#_C20F: LDA.b #$30
#_C211: STA.b $61

#_C213: LDA.b #$90
#_C215: STA.b $63

#_C217: LDA.b #$07
#_C219: STA.b $67

.exit
#_C21B: RTS

;===================================================================================================

FlyAroundRandomly:
#_C21C: LDA.b $66
#_C21E: BEQ .rerandomize

#_C220: DEC.b $66

#_C222: JSR MoveSpriteWithCollisionCheckX
#_C225: JSR MoveSpriteWithCollisionCheckY

;---------------------------------------------------------------------------------------------------

#EXIT_C228:
#_C228: RTS

;---------------------------------------------------------------------------------------------------

.rerandomize
#_C229: JSR Random
#_C22C: AND.b #$01
#_C22E: STA.b $1C

#_C230: INC.b $1C

#_C232: JSR Random
#_C235: BPL .keep_sign

#_C237: LDA.b $1C
#_C239: EOR.b #$FF
#_C23B: STA.b $1C

#_C23D: INC.b $1C

.keep_sign
#_C23F: LDA.b $65
#_C241: CLC
#_C242: ADC.b $1C
#_C244: AND.b #$0F
#_C246: STA.b $65

#_C248: JSR Random
#_C24B: AND.b #$7F
#_C24D: STA.b $66

#_C24F: RTS

;===================================================================================================

MoveSpriteWithCollisionCheckX:
#_C250: JSR CheckObjectCollisionX
#_C253: BCS .ricochet

#_C255: JMP MoveSpriteRadiallyPlusExtraX

.ricochet
#_C258: LDA.b #$10
#_C25A: SEC
#_C25B: SBC.b $65
#_C25D: STA.b $65

#_C25F: RTS

;===================================================================================================

MoveSpriteWithCollisionCheckY:
#_C260: JSR CheckObjectCollisionY
#_C263: BCS .ricochet

#_C265: JMP MoveSpriteRadiallyPlusExtraY

.ricochet
#_C268: LDA.b #$08
#_C26A: SEC
#_C26B: SBC.b $65
#_C26D: AND.b #$0F
#_C26F: STA.b $65

#_C271: RTS

;===================================================================================================

Sprite_1B_Key:
#_C272: LDA.b #$46
#_C274: STA.b $60

#_C276: RTS

;===================================================================================================
; Hachisuke
;===================================================================================================
Sprite_1A_TheHudsonBee:
#_C277: JSR GetFrameBit4inY

#_C27A: LDA.w .graphics,Y
#_C27D: STA.b $60

#_C27F: JSR GetFrameMod2
#_C282: BEQ .exit

#_C284: JSR MoveSpriteUpBy1

#_C287: LDA.b $63
#_C289: ORA.b $64
#_C28B: BEQ .die

#_C28D: LDA.b $65
#_C28F: BEQ .move_right

#_C291: JSR MoveSpriteLeftBy1

#_C294: LDA.b $61
#_C296: ORA.b $62
#_C298: BEQ .die

#_C29A: RTS

.move_right
#_C29B: JSR MoveSpriteRightBy1

#_C29E: LDA.b $62
#_C2A0: CMP.b #$02
#_C2A2: BCS .die

.exit
#_C2A4: RTS

.die
#_C2A5: JMP DeleteSpriteself

;---------------------------------------------------------------------------------------------------

.graphics
#_C2A8: db $42, $43

;===================================================================================================

Sprite_19_Balloon:
#_C2AA: LDA.b #$41
#_C2AC: STA.b $60

#_C2AE: JSR GetFrameMod2
#_C2B1: BEQ .exit

#_C2B3: JSR MoveSpriteUpBy1

#_C2B6: LDA.b $63
#_C2B8: ORA.b $64
#_C2BA: BEQ AscendingDeath

#_C2BC: JSR FlyJankilyX

#_C2BF: INC.b $66

.exit
#_C2C1: RTS

;===================================================================================================

Sprite_18_Umbrella:
#_C2C2: LDA.b #$40
#_C2C4: STA.b $60

#_C2C6: LDA.b $B8
#_C2C8: BNE .hard_mode

#_C2CA: JSR GetFrameMod2
#_C2CD: BNE .exit

.hard_mode
#_C2CF: JSR MoveSpriteUpBy1

#_C2D2: LDA.b $63
#_C2D4: ORA.b $64
#_C2D6: BEQ AscendingDeath

#_C2D8: RTS

;---------------------------------------------------------------------------------------------------

#AscendingDeath:
#_C2D9: JSR DeleteSpriteself
#_C2DC: STA.w $07C0

;---------------------------------------------------------------------------------------------------

.exit
#_C2DF: RTS

;===================================================================================================

Sprite_11_Tambo:
#_C2E0: JSR HandleRespawn

#_C2E3: JSR GetFrameBit4inY
#_C2E6: STA.b $1C

#_C2E8: LDA.b $94 ; check GFX bank for character
#_C2EA: AND.b #$02
#_C2EC: CLC
#_C2ED: ADC.b $1C
#_C2EF: TAX

#_C2F0: LDA.w TamboGraphics,X
#_C2F3: STA.b $60

#_C2F5: JSR TamboMoveX

#_C2F8: JSR GetFrameMod2
#_C2FB: BNE .exit

#_C2FD: LDA.b $67
#_C2FF: BMI .am_falling

#_C301: TAX

#_C302: LDA.w TamboJumpSpeeds,X
#_C305: BMI .start_falling

#_C307: JSR MoveSpriteUp

#_C30A: JSR FullCoordinatesToTilemapXY

#_C30D: DEC.b $2A

#_C30F: JSR GetObjectType_indoors

#_C312: LDA.b $2B
#_C314: CMP.b #$0D ; OBJECT 0D
#_C316: BCS .start_falling

#_C318: INC.b $67

.exit
#_C31A: RTS

.start_falling
#_C31B: LDA.b #$80
#_C31D: STA.b $67

#_C31F: RTS

;---------------------------------------------------------------------------------------------------

.am_falling
#_C320: AND.b #$7F
#_C322: TAX

#_C323: LDA.w TamboFallSpeeds,X
#_C326: BMI .land

#_C328: JSR MoveSpriteDown

#_C32B: INC.b $67

#_C32D: RTS

.land
#_C32E: JSR FullCoordinatesToTilemapXY

#_C331: INC.b $2A

#_C333: JSR GetObjectType_indoors

#_C336: LDA.b $2B
#_C338: CMP.b #$0D ; OBJECT 0D
#_C33A: BCC .keep_falling

.stop_falling
#_C33C: LDA.b #$00
#_C33E: STA.b $67

#_C340: RTS

.keep_falling
#_C341: DEC.b $67

#_C343: RTS

;===================================================================================================

#TamboMoveX:
#_C344: JSR GetFrameMod4
#_C347: BNE .exit

#_C349: JSR FullCoordinatesToTilemapXY

#_C34C: INC.b $2A

#_C34E: JSR GetObjectType_indoors

#_C351: LDA.b $2B
#_C353: CMP.b #$0D ; OBJECT 0D
#_C355: BCS .stop_falling

#_C357: DEC.b $2A

#_C359: LDA.b $61
#_C35B: AND.b #$0F
#_C35D: BNE .just_move

#_C35F: JSR CheckCollisionInFrontOfSprite
#_C362: BCS SpriteTurnAroundX

.just_move
#_C364: LDA.b #$02
#_C366: STA.b $B5

#_C368: JMP MoveSpriteWithFalling

;===================================================================================================

SpriteTurnAroundX:
#_C36B: LDA.b $65
#_C36D: EOR.b #$01
#_C36F: STA.b $65

#_C371: RTS

;===================================================================================================

TamboJumpSpeeds:
#_C372: db $05, $05, $05, $05, $05, $04, $04, $04
#_C37A: db $04, $04, $03, $03, $03, $03, $02, $02
#_C382: db $02, $02, $01, $01, $01, $01, $FF

;===================================================================================================

TamboFallSpeeds:
#_C389: db $01, $01, $01, $01, $02, $02, $02, $02
#_C391: db $03, $03, $03, $03, $04, $04, $04, $04
#_C399: db $04, $05, $05, $05, $05, $05, $FF

;===================================================================================================

TamboGraphics:
#_C3A0: db $12, $13
#_C3A2: db $06, $32

;===================================================================================================

Sprite_14_Gyoro:
#_C3A4: JSR HandleRespawn

#_C3A7: JSR GetFrameBit4inY

#_C3AA: LDA.w .graphics,Y
#_C3AD: STA.b $60

#_C3AF: LDA.b #$02
#_C3B1: STA.b $B5

#_C3B3: JMP GyoroMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_C3B6: db $5D, $5E

;===================================================================================================

Sprite_1E_BrainToto:
#_C3B8: JSR HandleRespawn

#_C3BB: JSR GetFrameBit4inY

#_C3BE: LDA.w .graphics,Y
#_C3C1: STA.b $60

#_C3C3: JMP FlyAroundRandomly

;---------------------------------------------------------------------------------------------------

.graphics
#_C3C6: db $1B, $1C

;===================================================================================================

Sprite_15_Beat:
#_C3C8: JSR HandleRespawn

#_C3CB: JSR GetFrameBit4inY

#_C3CE: LDA.w .graphics,Y
#_C3D1: STA.b $60

#_C3D3: JMP FlyAroundRandomly

;---------------------------------------------------------------------------------------------------

.graphics
#_C3D6: db $23, $24

;===================================================================================================

MedamarugeDie:
#_C3D8: LDA.b #$01
#_C3DA: STA.b $5F

#_C3DC: LDA.b #$0C ; SFX 0C
#_C3DE: STA.b $E6

#_C3E0: LDA.b #$19 ; SPRITE 19
#_C3E2: JMP SpawnSprite

;===================================================================================================

MedamarugeRespawning:
#_C3E5: JMP RunRespawnTimer

;===================================================================================================

Sprite_12_Medamaruge:
#_C3E8: LDA.b $5F
#_C3EA: BEQ .alive
#_C3EC: BPL MedamarugeRespawning

#_C3EE: JSR GetFrameMod2
#_C3F1: BNE .exit

#_C3F3: INC.b $5F
#_C3F5: BEQ .jitter_around

#_C3F7: LDA.b $5F
#_C3F9: CMP.b #$90
#_C3FB: BCC .exit

#_C3FD: CMP.b #$F0
#_C3FF: BCS .exit
#_C401: BCC .alive

;---------------------------------------------------------------------------------------------------

.jitter_around
#_C403: JSR Random
#_C406: STA.b $68

#_C408: JSR RandomBool

#_C40B: LDA.b #$10
#_C40D: BCS .jitter_left_a

#_C40F: JSR MoveSpriteRight
#_C412: JMP .next_jitter

.jitter_left_a
#_C415: JSR MoveSpriteLeft

.next_jitter
#_C418: JSR RandomBool

#_C41B: LDA.b #$10
#_C41D: BCS .jitter_left_b

#_C41F: JMP MoveSpriteRight

.jitter_left_b
#_C422: JMP MoveSpriteLeft

;---------------------------------------------------------------------------------------------------

.alive
#_C425: JSR GetFrameBit4inY

#_C428: LDA.w MedamarugeGraphics,Y
#_C42B: STA.b $60

#_C42D: TYA
#_C42E: BNE .do_your_jank_movement

#_C430: LDA.b $5F
#_C432: BNE .do_your_jank_movement

#_C434: LDA.b $68
#_C436: BEQ .fake_despawn

#_C438: DEC.b $68
#_C43A: BNE .do_your_jank_movement

.fake_despawn
#_C43C: LDA.b #$80
#_C43E: STA.b $5F

.exit
#_C440: RTS

;---------------------------------------------------------------------------------------------------

.do_your_jank_movement
#_C441: JSR GetHardmodeAdjustment
#_C444: ADC.b #$0A
#_C446: STA.b $1C

#_C448: LDA.b $67
#_C44A: CMP.b $1C
#_C44C: BCS MedamarugeDie

#_C44E: JSR GetFrameMod2
#_C451: BNE EXIT_C4A0

#_C453: JSR FlyJankilyX
#_C456: STA.b $65

;===================================================================================================

FlyJankilyY:
#_C458: LDA.b $66
#_C45A: CLC
#_C45B: ADC.b #$08
#_C45D: AND.b #$0F
#_C45F: TAY

#_C460: LDA.b $66
#_C462: INC.b $66
#_C464: AND.b #$3F
#_C466: LSR A
#_C467: LSR A
#_C468: LSR A
#_C469: TAX

#_C46A: DEX
#_C46B: DEX
#_C46C: CPX.b #$04
#_C46E: BCC .jank_down

#_C470: LDA.w JankyFlightSpeeds,Y
#_C473: JMP MoveSpriteUp

.jank_down
#_C476: LDA.w JankyFlightSpeeds,Y
#_C479: JMP MoveSpriteDown

;===================================================================================================

FlyJankilyX:
#_C47C: LDA.b $66
#_C47E: AND.b #$0F
#_C480: TAY

#_C481: LDA.b $66
#_C483: AND.b #$18
#_C485: LSR A
#_C486: LSR A
#_C487: LSR A
#_C488: TAX

#_C489: DEX
#_C48A: CPX.b #$02
#_C48C: BCC .jank_left

#_C48E: LDA.w JankyFlightSpeeds,Y
#_C491: JSR MoveSpriteRight

#_C494: LDA.b #$00
#_C496: RTS

.jank_left
#_C497: LDA.w JankyFlightSpeeds,Y
#_C49A: JSR MoveSpriteLeft

#_C49D: LDA.b #$01
#_C49F: RTS

;---------------------------------------------------------------------------------------------------

#EXIT_C4A0:
#_C4A0: RTS

;===================================================================================================

RandomBool:
#_C4A1: JSR Random
#_C4A4: AND.b #$01
#_C4A6: ROR A

#_C4A7: RTS

;===================================================================================================

JankyFlightSpeeds:
#_C4A8: db $04, $04, $03, $02, $02, $01, $01, $01
#_C4B0: db $01, $01, $01, $02, $02, $03, $04, $04

;===================================================================================================

MedamarugeGraphics:
#_C4B8: db $36, $37

;===================================================================================================
; Lisa's pet peeve is phonies? I thought she loved them!
;===================================================================================================
Sprite_10_PhoneyPrincess:
#_C4BA: LDA.b $66
#_C4BC: BNE .become_crow

#_C4BE: JSR GetFrameBit4inY
#_C4C1: STA.b $65

#_C4C3: LDA.b #$07
#_C4C5: STA.b $60

#_C4C7: RTS

;---------------------------------------------------------------------------------------------------

.become_crow
#_C4C8: LDA.b $8E
#_C4CA: LSR A
#_C4CB: LSR A
#_C4CC: AND.b #$02
#_C4CE: CLC
#_C4CF: ADC.b #$07
#_C4D1: STA.b $60

#_C4D3: DEC.b $66
#_C4D5: BNE .exit

#_C4D7: LDA.b #$21 ; SPRITE 21
#_C4D9: STA.b $6C

#_C4DB: LDX.b $5E

#_C4DD: LDA.b #$00
#_C4DF: STA.w $06C1,X

.exit
#_C4E2: RTS

;===================================================================================================

Sprite_0F_HELP:
#_C4E3: JSR GetFrameBit4inY

#_C4E6: LDA.w .graphics,Y
#_C4E9: STA.b $60

#_C4EB: RTS

;---------------------------------------------------------------------------------------------------

.graphics
#_C4EC: db $28, $29

;===================================================================================================

Sprite_01_Spring:
#_C4EE: JSR GetFrameMod4
#_C4F1: BNE .exit

#_C4F3: INC.b $67
#_C4F5: LDX.b $67

#_C4F7: LDA.w .graphics,X
#_C4FA: STA.b $60

#_C4FC: CPX.b #$03
#_C4FE: BEQ .die

.exit
#_C500: RTS

.die
#_C501: JMP DeleteSpriteself

;---------------------------------------------------------------------------------------------------

.graphics
#_C504: db $03, $02, $03

;===================================================================================================

Sprite_02_Platform:
#_C507: JSR GetFrameMod2
#_C50A: BNE .exit_b

#_C50C: LDA.b $67
#_C50E: CMP.b $68
#_C510: BEQ .delay_movement

#_C512: LDA.b $65
#_C514: BEQ .moving_up

#_C516: JSR MoveSpriteDownBy1
#_C519: BNE .continue

.moving_up
#_C51B: JSR MoveSpriteUpBy1

.continue
#_C51E: LDA.b $63
#_C520: AND.b #$0F
#_C522: BNE .exit_a

#_C524: INC.b $67

.exit_a
#_C526: RTS

;---------------------------------------------------------------------------------------------------

.delay_movement
#_C527: LDA.b $65
#_C529: EOR.b #$01
#_C52B: STA.b $65

#_C52D: LDA.b #$00
#_C52F: STA.b $67

.exit_b
#_C531: RTS

;===================================================================================================

Sprite_05_HardTaru:
#_C532: JSR HandleRespawn

#_C535: JSR GetFrameBit4inY

#_C538: LDA.w .graphics,Y
#_C53B: STA.b $60

#_C53D: JSR HardTaruCollisionCheck
#_C540: BCS .get_four

#_C542: JMP MoveInACardinal

.get_four
#_C545: JMP GetUniqueNewDirection

;---------------------------------------------------------------------------------------------------

.graphics
#_C548: db $59, $5A

;===================================================================================================
; Eye-eye captain
;===================================================================================================
Sprite_16_EyeEye:
#_C54A: JSR HandleRespawn

#_C54D: JSR GetFrameBit4inY

#_C550: LDA.w .graphics,Y
#_C553: STA.b $60

#_C555: BNE KrummMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_C557: db $22, $3C

;===================================================================================================

Sprite_09_Katchinsha:
#_C559: JSR HandleRespawn

#_C55C: JSR GetFrameBit4inY

#_C55F: LDA.w .graphics,Y
#_C562: STA.b $60

;---------------------------------------------------------------------------------------------------

#KrummMovement:
#_C564: LDX.b #$01

#_C566: LDA.b $4D
#_C568: CLC
#_C569: ADC.b #$08
#_C56B: CMP.b $63
#_C56D: BNE .slower

#_C56F: INX

.slower
#_C570: TXA
#_C571: JMP SpriteWalkOnPlatform

;---------------------------------------------------------------------------------------------------

.graphics
#_C574: db $38, $39

;===================================================================================================
; Book of Madora
;===================================================================================================
Sprite_24_Madora:
#_C576: JSR HandleRespawn

#_C579: JSR GetFrameBit4inY

#_C57C: LDA.w .graphics,Y
#_C57F: STA.b $60

#_C581: JSR GetFrameMod2
#_C584: BNE EXIT_C5D0

#_C586: LDA.b $61
#_C588: AND.b #$0F
#_C58A: BNE .skip_tile_check

#_C58C: JSR CheckWallAndFloorInFrontOfSprite

.skip_tile_check
#_C58F: JMP MoveSpriteSinusoidally

;---------------------------------------------------------------------------------------------------

.graphics
#_C592: db $68, $69

;===================================================================================================

ShimmySlimeMovement:
#_C594: JSR GetFrameMod4
#_C597: BNE EXIT_C5E1

;===================================================================================================

VoodooMoveX:
#_C599: LDA.b #$01

;===================================================================================================

SpriteWalkOnPlatform:
#_C59B: STA.b $B5

.check_tile_position
#_C59D: LDA.b $61
#_C59F: AND.b #$0F
#_C5A1: BNE .at_edge

#_C5A3: JSR CheckWallAndFloorInFrontOfSprite

.at_edge
#_C5A6: LDA.b $65
#_C5A8: BNE .move_left
#_C5AA: JSR MoveSpriteRightBy1

.check_more_pixels
#_C5AD: DEC.b $B5
#_C5AF: BNE .check_tile_position

#_C5B1: RTS

.move_left
#_C5B2: LDA.b $B5
#_C5B4: JSR MoveSpriteLeftBy1

#_C5B7: JMP .check_more_pixels

;---------------------------------------------------------------------------------------------------

.turn_around
#_C5BA: JMP SpriteTurnAroundX

;===================================================================================================

#CheckWallAndFloorInFrontOfSprite:
#_C5BD: JSR FullCoordinatesToTilemapXY

#_C5C0: JSR CheckCollisionInFrontOfSprite
#_C5C3: BCS .turn_around

#_C5C5: INC.b $2A
#_C5C7: JSR GetObjectType_indoors

#_C5CA: LDA.b $2B
#_C5CC: CMP.b #$0D ; OBJECT 0D
#_C5CE: BCC .turn_around

;---------------------------------------------------------------------------------------------------

#EXIT_C5D0:
#_C5D0: RTS

;===================================================================================================
; Gerubo Valley
;===================================================================================================
Sprite_26_Gerubo:
#_C5D1: JSR HandleRespawn

#_C5D4: JSR GetFrameBit4inY

#_C5D7: LDA.w .graphics,Y
#_C5DA: STA.b $60

#_C5DC: JMP ToyotaMovement

;---------------------------------------------------------------------------------------------------

.graphics
#_C5DF: db $20, $21

;===================================================================================================

#EXIT_C5E1:
#_C5E1: RTS

;===================================================================================================
; Mauri Povich
;===================================================================================================
Sprite_08_Mauri:
#_C5E2: JSR HandleRespawn

#_C5E5: JSR GetFrameBit4inY
#_C5E8: STA.b $1C

#_C5EA: LDA.b $94 ; check GFX bank for character
#_C5EC: AND.b #$02
#_C5EE: CLC
#_C5EF: ADC.b $1C
#_C5F1: TAY

#_C5F2: LDA.w MauriGraphics,Y
#_C5F5: STA.b $60

;===================================================================================================

MauriMovement:
#_C5F7: JSR GetFrameMod2
#_C5FA: BEQ EXIT_C5E1

#_C5FC: LDA.b $67
#_C5FE: BNE .jumping

#_C600: LDA.b $61
#_C602: AND.b #$0F
#_C604: BEQ .on_tile_grid

#_C606: JMP MoveSpriteSinusoidally

;---------------------------------------------------------------------------------------------------

.on_tile_grid
#_C609: LDA.b $3E
#_C60B: AND.b #$07
#_C60D: CMP.b #$07
#_C60F: BEQ .hop

#_C611: JSR FullCoordinatesToTilemapXY

#_C614: LDA.b $68
#_C616: BEQ .check_below

#_C618: LDA.b #$00
#_C61A: STA.b $68
#_C61C: BEQ .walking

.check_below
#_C61E: INC.b $2A
#_C620: JSR GetObjectType_indoors

#_C623: LDA.b $2B
#_C625: CMP.b #$0D ; OBJECT 0D
#_C627: BCC .fall

#_C629: DEC.b $2A

.walking
#_C62B: JSR CheckCollisionInFrontOfSprite
#_C62E: BCC MoveSpriteSinusoidally

.hop
#_C630: LDA.b #$01
#_C632: STA.b $67

#_C634: RTS

;---------------------------------------------------------------------------------------------------

.jumping
#_C635: LDA.b $67
#_C637: BPL .moving_up

#_C639: JSR CheckObjectBelowSprite
#_C63C: BCC .can_move

#_C63E: RTS

.can_move
#_C63F: LDA.b #$02
#_C641: JMP MoveSpriteDown

.fall
#_C644: LDA.b #$FF
#_C646: STA.b $67

#_C648: RTS

.moving_up
#_C649: JSR CheckObjectAboveSprite
#_C64C: BCS .you_are_not_the_father

#_C64E: LDA.b #$02
#_C650: JSR MoveSpriteUp

.you_are_not_the_father
#_C653: RTS

;===================================================================================================

MoveSpriteSinusoidally:
#_C654: INC.b $66

#_C656: LDA.b $66
#_C658: AND.b #$07
#_C65A: TAY

#_C65B: LDA.w SinusoidalVelocity,Y
#_C65E: BEQ .move_in_direction
#_C660: BMI .move_up

#_C662: JSR MoveSpriteDown
#_C665: JMP .move_in_direction

.move_up
#_C668: EOR.b #$FF
#_C66A: CLC
#_C66B: ADC.b #$01
#_C66D: JSR MoveSpriteUp

.move_in_direction
#_C670: LDA.b #$02
#_C672: STA.b $B5

#_C674: JMP MoveSpriteWithFalling

;===================================================================================================

CheckObjectBelowSprite:
#_C677: LDA.b $63
#_C679: AND.b #$0F
#_C67B: BNE .fail

#_C67D: JSR FullCoordinatesToTilemapXY

#_C680: INC.b $2A
#_C682: BNE .check

;===================================================================================================

#CheckObjectAboveSprite:
#_C684: JSR FullCoordinatesToTilemapXY

#_C687: DEC.b $2A

.check
#_C689: JSR GetObjectType_indoors

#_C68C: LDA.b $2B
#_C68E: CMP.b #$0D ; OBJECT 0D
#_C690: BCC .fail

#_C692: LDA.b #$01
#_C694: STA.b $68

#_C696: LDA.b #$00
#_C698: STA.b $67
#_C69A: STA.b $66

#_C69C: LDA.b $3E
#_C69E: EOR.b $8E
#_C6A0: AND.b #$01
#_C6A2: STA.b $65

#_C6A4: SEC
#_C6A5: RTS

.fail
#_C6A6: CLC
#_C6A7: RTS

;===================================================================================================

SinusoidalVelocity:
#_C6A8: db $04, $FC, $FE, $FF, $FF, $01, $01, $02

;===================================================================================================

MauriGraphics:
#_C6B0: db $16, $17
#_C6B2: db $61, $62

;===================================================================================================

Sprite_06_BoxingGlove:
#_C6B4: LDA.b $67
#_C6B6: BEQ .float_like_a_butterfly

.sting_like_a_hudson_bee
#_C6B8: CMP.b #$11
#_C6BA: BCS .south_paw

#_C6BC: LDA.b #$02
#_C6BE: JSR MoveSpriteDown

#_C6C1: INC.b $67

.exit
#_C6C3: RTS

;---------------------------------------------------------------------------------------------------

.south_paw
#_C6C4: LDA.b #$02
#_C6C6: JSR MoveSpriteUp

#_C6C9: INC.b $67

#_C6CB: LDA.b $67
#_C6CD: CMP.b #$21
#_C6CF: BNE .exit

#_C6D1: LDA.b #$00
#_C6D3: STA.b $67

#_C6D5: RTS

;---------------------------------------------------------------------------------------------------

.float_like_a_butterfly
#_C6D6: LDA.b $61
#_C6D8: STA.b $1C

#_C6DA: LDA.b $62
#_C6DC: STA.b $1D

#_C6DE: LDA.b $06
#_C6E0: STA.b $1E

#_C6E2: LDA.b $00
#_C6E4: AND.b #$01
#_C6E6: STA.b $1F

#_C6E8: JSR Subtraction16Bit
#_C6EB: BCC .not_close

#_C6ED: LDA.b $1C
#_C6EF: CMP.b $3E
#_C6F1: BNE .not_close

#_C6F3: LDA.b #$01
#_C6F5: STA.b $67

.not_close
#_C6F7: LDA.b #$0E
#_C6F9: STA.b $60

;---------------------------------------------------------------------------------------------------

#EXIT_C6FB:
#_C6FB: RTS

;===================================================================================================

Sprite_07_Paumeru:
#_C6FC: JSR HandleRespawn

#_C6FF: JSR GetFrameBit4inY

#_C702: LDA.w .graphics,Y
#_C705: STA.b $60

#_C707: JSR GetFrameMod2
#_C70A: BEQ EXIT_C6FB

#_C70C: JMP FlyAroundRandomly

;---------------------------------------------------------------------------------------------------

.graphics
#_C70F: db $05, $1D

;===================================================================================================

FlyAggressively:
#_C711: LDA.b $67
#_C713: BEQ .try_horizontal_movement

#_C715: INC.b $67

#_C717: LDA.b $67
#_C719: CMP.b #$11
#_C71B: BCC .move_vertically

#_C71D: LDA.b #$00
#_C71F: STA.b $67
#_C721: BEQ .try_horizontal_movement

.move_vertically
#_C723: LDA.b $68
#_C725: BNE .move_up

#_C727: LDA.b #$02
#_C729: JMP MoveSpriteDown

.move_up
#_C72C: LDA.b #$02
#_C72E: JMP MoveSpriteUp

;---------------------------------------------------------------------------------------------------

.try_horizontal_movement
#_C731: LDA.b $65
#_C733: BEQ .dont_move_left

#_C735: LDA.b $61
#_C737: SEC
#_C738: SBC.b #$10
#_C73A: ORA.b $62
#_C73C: BEQ .test_proximity

#_C73E: LDA.b #$04
#_C740: JMP MoveSpriteLeft

.dont_move_left
#_C743: LDA.b $61
#_C745: CMP.b #$E0
#_C747: BNE .move_right

#_C749: LDA.b $62
#_C74B: BEQ .move_right

.test_proximity
#_C74D: LDA.b $64
#_C74F: CMP.b $4E
#_C751: BEQ .not_too_far_from_milon

#_C753: LDA.b #$00
#_C755: ROL A
#_C756: JMP .turn_around ; coulda used BCC smh

.not_too_far_from_milon
#_C759: LDA.b $63
#_C75B: CMP.b $4D
#_C75D: LDA.b #$00
#_C75F: ROL A

.turn_around
#_C760: STA.b $68

#_C762: LDX.b #$01
#_C764: STX.b $67

#_C766: JMP SpriteTurnAroundX

.move_right
#_C769: LDA.b #$04
#_C76B: JMP MoveSpriteRight

;===================================================================================================

SpawnSprite:
#_C76E: STA.b $20

#_C770: LDA.b #$00
#_C772: STA.b $21

#_C774: LDX.b #$01

.next_slot
#_C776: LDA.w $06C0,X
#_C779: BEQ .free_slot

#_C77B: INX
#_C77C: CPX.b #$10
#_C77E: BNE .next_slot

#_C780: SEC
#_C781: RTS

;---------------------------------------------------------------------------------------------------

.free_slot
#_C782: LDA.b $20
#_C784: STA.w $06C0,X

#_C787: STX.b $1C

#_C789: TXA
#_C78A: ASL A
#_C78B: ASL A
#_C78C: ADC.b $1C
#_C78E: ADC.b $1C
#_C790: ASL A
#_C791: TAX

#_C792: LDA.b #$00
#_C794: STA.w $0600,X

#_C797: LDA.b $61
#_C799: STA.w $0602,X
#_C79C: STA.b $1E

#_C79E: LDA.b $62
#_C7A0: STA.w $0603,X
#_C7A3: STA.b $1F

#_C7A5: LDA.b $63
#_C7A7: SEC
#_C7A8: SBC.b $21
#_C7AA: STA.w $0604,X

#_C7AD: LDA.b $64
#_C7AF: SBC.b #$00
#_C7B1: STA.w $0605,X

#_C7B4: LDA.b #$00
#_C7B6: STA.w $0606,X
#_C7B9: STA.w $0607,X

#_C7BC: CLC
#_C7BD: RTS

;===================================================================================================

HandleRespawn:
#_C7BE: LDA.b $5F
#_C7C0: BEQ .alive

#_C7C2: PLA
#_C7C3: PLA

;---------------------------------------------------------------------------------------------------

#RunRespawnTimer:
#_C7C4: LDA.b $5F
#_C7C6: CMP.b #$40
#_C7C8: BCS .tick_timer

#_C7CA: JSR GetFrameMod4
#_C7CD: BEQ .tick_timer

.alive
#_C7CF: RTS

.tick_timer
#_C7D0: INC.b $5F

#_C7D2: LDX.b $B8

#_C7D4: LDA.b $5F
#_C7D6: CMP.w .respawn_timer,X
#_C7D9: BEQ ReturnToDefaultPosition
#_C7DB: BCC .exit_b

#_C7DD: AND.b #$7F
#_C7DF: STA.b $5F
#_C7E1: AND.b #$01
#_C7E3: TAX

#_C7E4: LDA.w .bubble_graphics,X
#_C7E7: STA.b $60

.exit_b
#_C7E9: RTS

;---------------------------------------------------------------------------------------------------

.respawn_timer
#_C7EA: db $40, $38

; This indicates plans for up to 8 difficulties!
#_C7EC: db $30, $28, $20, $18, $10, $08

.bubble_graphics
#_C7F2: db $18, $19

;===================================================================================================

ReturnToDefaultPosition:
#_C7F4: LDA.b #$00
#_C7F6: STA.b $67
#_C7F8: STA.b $68
#_C7FA: STA.b $66

#_C7FC: JSR AmIAWeirdFlyingGuy
#_C7FF: BEQ EXIT_C825

#_C801: STA.b $61
#_C803: STA.b $63

#_C805: LDA.b $69
#_C807: LSR A
#_C808: ROR.b $61
#_C80A: LSR A
#_C80B: ROR.b $61
#_C80D: LSR A
#_C80E: ROR.b $61
#_C810: LSR A
#_C811: ROR.b $61
#_C813: STA.b $62

#_C815: LDA.b $6A
#_C817: LSR A
#_C818: ROR.b $63
#_C81A: LSR A
#_C81B: ROR.b $63
#_C81D: LSR A
#_C81E: ROR.b $63
#_C820: LSR A
#_C821: ROR.b $63
#_C823: STA.b $64

;---------------------------------------------------------------------------------------------------

#EXIT_C825:
#_C825: RTS

;===================================================================================================

AmIAWeirdFlyingGuy:
#_C826: LDX.b $6C
#_C828: CPX.b #$07 ; SPRITE 07
#_C82A: BEQ EXIT_C825

#_C82C: CPX.b #$15 ; SPRITE 15
#_C82E: BEQ EXIT_C825

#_C830: CPX.b #$1E ; SPRITE 1E

#_C832: RTS

;===================================================================================================

CheckObjectCollisionX:
#_C833: LDA.b $61
#_C835: AND.b #$0F
#_C837: BNE .fail

#_C839: JSR FullCoordinatesToTilemapXY

#_C83C: LDA.b $65
#_C83E: CMP.b #$08
#_C840: BCC .check_right

#_C842: DEC.b $29

.check_tile
#_C844: JSR GetObjectType_indoors

#_C847: LDA.b $2B
#_C849: CMP.b #$0D ; OBJECT 0D

#_C84B: RTS

.fail
#_C84C: CLC

#_C84D: RTS

.check_right
#_C84E: INC.b $29
#_C850: BNE .check_tile

;===================================================================================================

CheckObjectCollisionY:
#_C852: LDA.b $63
#_C854: AND.b #$07
#_C856: BNE .fail

#_C858: LDA.b $65
#_C85A: CLC
#_C85B: ADC.b #$04
#_C85D: AND.b #$0F
#_C85F: CMP.b #$08
#_C861: BCS .check_bottom

#_C863: JSR FullCoordinatesToTilemapXY
#_C866: DEC.b $2A

.check_tile
#_C868: JSR GetObjectType_indoors

#_C86B: LDA.b $2B
#_C86D: CMP.b #$0D ; OBJECT 0D

#_C86F: RTS

.fail
#_C870: CLC

#_C871: RTS

.check_bottom
#_C872: LDA.b #$08
#_C874: JSR MoveSpriteDown

#_C877: JSR FullCoordinatesToTilemapXY

#_C87A: LDA.b #$08
#_C87C: JSR MoveSpriteUp

#_C87F: INC.b $2A
#_C881: BNE .check_tile

;===================================================================================================

MoveRadiallyWithScreenCheckX:
#_C883: JSR MoveSpriteRadiallyX
#_C886: BCS SpriteIsOffScreen

#_C888: LDA.b $65
#_C88A: CMP.b #$08

#_C88C: LDA.b $61
#_C88E: BCC .move_right

#_C890: SEC
#_C891: SBC.b $1C
#_C893: STA.b $61

#_C895: BCC SpriteIsOnScreen

;---------------------------------------------------------------------------------------------------

#SpriteIsOffScreen:
#_C897: CLC

#_C898: RTS

;---------------------------------------------------------------------------------------------------

.move_right
#_C899: CLC
#_C89A: ADC.b $1C
#_C89C: STA.b $61

#_C89E: BCC SpriteIsOffScreen

;---------------------------------------------------------------------------------------------------

#SpriteIsOnScreen:
#_C8A0: SEC

#_C8A1: RTS

;===================================================================================================

MoveRadiallyWithScreenCheckY:
#_C8A2: JSR MoveSpriteRadiallyY
#_C8A5: BCS SpriteIsOffScreen

#_C8A7: LDA.b $65
#_C8A9: CLC
#_C8AA: ADC.b #$04
#_C8AC: AND.b #$0F
#_C8AE: CMP.b #$08

#_C8B0: LDA.b $63
#_C8B2: BCS .move_down

#_C8B4: SEC
#_C8B5: SBC.b $1C
#_C8B7: STA.b $63

#_C8B9: BCC SpriteIsOnScreen

#_C8BB: CLC

#_C8BC: RTS

.move_down
#_C8BD: CLC
#_C8BE: ADC.b $1C
#_C8C0: STA.b $63

#_C8C2: BCC SpriteIsOffScreen

#_C8C4: SEC

#_C8C5: RTS

;===================================================================================================

MoveSpriteRadiallyPlusExtraX:
#_C8C6: LDA.b #$01
#_C8C8: STA.b $1C

#_C8CA: JSR MoveSpriteRadiallyX
#_C8CD: BCS EXIT_C8F5

#_C8CF: LDA.b $65
#_C8D1: CMP.b #$08
#_C8D3: BCC .move_right

#_C8D5: LDA.b $1C
#_C8D7: JMP MoveSpriteLeft

.move_right
#_C8DA: LDA.b $1C
#_C8DC: JMP MoveSpriteRight

;===================================================================================================

MoveSpriteRadiallyX:
#_C8DF: LDA.b $65
#_C8E1: AND.b #$07
#_C8E3: TAX

#_C8E4: LDA.w RadialVelocityX,X
#_C8E7: CLC
#_C8E8: ADC.b $69
#_C8EA: TAY

#_C8EB: AND.b #$07
#_C8ED: STA.b $69

#_C8EF: TYA
#_C8F0: AND.b #$F8
#_C8F2: BEQ .fail

#_C8F4: CLC

;---------------------------------------------------------------------------------------------------

#EXIT_C8F5:
#_C8F5: RTS

;---------------------------------------------------------------------------------------------------

.fail
#_C8F6: SEC

;===================================================================================================

#EXIT_C8F7:
#_C8F7: RTS

;===================================================================================================

MoveSpriteRadiallyPlusExtraY:
#_C8F8: LDA.b #$01
#_C8FA: STA.b $1C

#_C8FC: JSR MoveSpriteRadiallyY
#_C8FF: BCS EXIT_C8F7

#_C901: LDA.b $65
#_C903: CLC
#_C904: ADC.b #$04
#_C906: AND.b #$0F
#_C908: CMP.b #$08

#_C90A: LDA.b $1C
#_C90C: BCS .move_down

#_C90E: JMP MoveSpriteUp

.move_down
#_C911: JMP MoveSpriteDown

;===================================================================================================

MoveSpriteRadiallyY:
#_C914: LDA.b $65
#_C916: AND.b #$07
#_C918: TAX

#_C919: LDA.w RadialVelocityY,X
#_C91C: CLC
#_C91D: ADC.b $6A
#_C91F: TAY

#_C920: AND.b #$07
#_C922: STA.b $6A
#_C924: TYA

#_C925: AND.b #$F8
#_C927: BEQ .fail

#_C929: CLC
#_C92A: RTS

.fail
#_C92B: SEC
#_C92C: RTS

;===================================================================================================

RadialVelocityX:
#_C92D: db $00, $03, $06, $07

RadialVelocityY:
#_C931: db $08, $07, $06, $03
#_C935: db $00, $03, $06, $07

;===================================================================================================

Random:
#_C939: LDY.w $07C4
#_C93C: INC.w $07C4

#_C93F: LDA.w RESET,Y
#_C942: EOR.b $8E

#_C944: RTS

;===================================================================================================

SpriteMoveWithScroll:
#_C945: LDA.b $A8
#_C947: BMI .negative_x

#_C949: LDA.b $61
#_C94B: CLC
#_C94C: ADC.b $A8
#_C94E: BCC .set_x

.off_screen
#_C950: SEC

#_C951: RTS

.negative_x
#_C952: JSR GetAdditiveInverse
#_C955: STA.b $1C

#_C957: LDA.b $61
#_C959: SEC
#_C95A: SBC.b $1C
#_C95C: BCC .off_screen

.set_x
#_C95E: STA.b $61

;---------------------------------------------------------------------------------------------------

#_C960: LDA.b $A7
#_C962: BMI .negative_y

#_C964: LDA.b $63
#_C966: CLC
#_C967: ADC.b $A7
#_C969: BCC .set_y

#_C96B: SEC

#_C96C: RTS

.negative_y
#_C96D: JSR GetAdditiveInverse
#_C970: STA.b $1C

#_C972: LDA.b $63
#_C974: SEC
#_C975: SBC.b $1C
#_C977: BCC .off_screen

.set_y
#_C979: STA.b $63

#_C97B: CLC

#_C97C: RTS

;===================================================================================================

HardTaruCollisionCheck:
#_C97D: LDA.b $65
#_C97F: AND.b #$06
#_C981: BNE .check_y

#_C983: LDA.b $61
#_C985: AND.b #$0F
#_C987: BNE .no_collision

#_C989: JSR FullCoordinatesToTilemapXY

#_C98C: JMP CheckCollisionInFrontOfSprite

.check_y
#_C98F: LDA.b $63
#_C991: AND.b #$0F
#_C993: BNE .no_collision

#_C995: JSR FullCoordinatesToTilemapXY

#_C998: DEC.b $2A

#_C99A: LDA.b $65
#_C99C: AND.b #$04
#_C99E: LSR A
#_C99F: CLC
#_C9A0: ADC.b $2A
#_C9A2: STA.b $2A

#_C9A4: JSR GetObjectType_indoors

#_C9A7: LDA.b $2B
#_C9A9: CMP.b #$0D ; OBJECT 0D

#_C9AB: RTS

.no_collision
#_C9AC: CLC

#_C9AD: RTS

;===================================================================================================

CheckCollisionInFrontOfSprite:
#_C9AE: DEC.b $29

#_C9B0: LDA.b $65
#_C9B2: AND.b #$01
#_C9B4: EOR.b #$01
#_C9B6: ASL A
#_C9B7: CLC
#_C9B8: ADC.b $29
#_C9BA: STA.b $29

#_C9BC: JSR GetObjectType_indoors

#_C9BF: LDA.b $2B
#_C9C1: CMP.b #$0D ; OBJECT 0D

#_C9C3: RTS

;===================================================================================================
; 0 - Right
; 1 - Left
; 2 - Up
; 4 - Down
;===================================================================================================
MoveInACardinal:
#_C9C4: LDX.b $65
#_C9C6: BNE .not_right

#_C9C8: JMP MoveSpriteRightBy1

.not_right
#_C9CB: DEX
#_C9CC: BNE .not_left

#_C9CE: JMP MoveSpriteLeftBy1

.not_left
#_C9D1: DEX
#_C9D2: BNE .not_up

#_C9D4: JMP MoveSpriteUpBy1

.not_up
#_C9D7: JMP MoveSpriteDownBy1

;===================================================================================================

GetUniqueNewDirection:
#_C9DA: JSR Random
#_C9DD: AND.b #$03
#_C9DF: TAX

#_C9E0: LDA.w .direction,X
#_C9E3: CMP.b $65
#_C9E5: BEQ GetUniqueNewDirection

#_C9E7: STA.b $65

#_C9E9: RTS

;---------------------------------------------------------------------------------------------------

.direction
#_C9EA: db $00, $01, $02, $04

;===================================================================================================

HandleSpriteWonted:
#_C9EE: LDA.b $6C
#_C9F0: BEQ .exit

#_C9F2: JSR .run_vector

#_C9F5: JMP SaveSpriteVars

;---------------------------------------------------------------------------------------------------

.run_vector
#_C9F8: ASL A
#_C9F9: TAY

#_C9FA: LDA.w SpriteWontVectors-1,Y
#_C9FD: PHA

#_C9FE: LDA.w SpriteWontVectors-2,Y
#_CA01: PHA

.exit
#_CA02: RTS

;===================================================================================================

SpriteWontVectors:
#_CA03: dw WontedSproing-1            ; 01 - SPRING
#_CA05: dw WontedPlatform-1           ; 02 - PLATFORM
#_CA07: dw WontedItem-1               ; 03 - CRYSTAL
#_CA09: dw WontedBossFireball-1       ; 04 - BOSS FIREBALL
#_CA0B: dw WontedEnemyA-1             ; 05 - HARD TARU
#_CA0D: dw WontedSproing-1            ; 06 - BOXING GLOVE
#_CA0F: dw WontedPaumeru-1            ; 07 - PAUMERU
#_CA11: dw WontedEnemyA-1             ; 08 - MAURI / GIANT HEAD
#_CA13: dw WontedEnemyA-1             ; 09 - KATCHINSHA
#_CA15: dw WontedBoss-1               ; 0A - BOSS
#_CA17: dw WontedHeart-1              ; 0B - HEART
#_CA19: dw WontedSafuma-1             ; 0C - SAFUMA
#_CA1B: dw WontedEnemyA-1             ; 0D - VOODOO / AGU-AGU
#_CA1D: dw WontedEnemyA-1             ; 0E - SLIME EYE
#_CA1F: dw BasicSpriteDraw-1          ; 0F - HELP
#_CA21: dw WontedPhoneyPrincess-1     ; 10 - PHONEY PRINCESS
#_CA23: dw WontedEnemyA-1             ; 11 - TAMBO / BONE WING
#_CA25: dw WontedMedamaruge-1         ; 12 - MEDAMARUGE
#_CA27: dw WontedProjectile-1         ; 13 - PROJECTILE
#_CA29: dw WontedEnemyA-1             ; 14 - GYORO
#_CA2B: dw WontedEnemyA-1             ; 15 - BEAT
#_CA2D: dw WontedEnemyA-1             ; 16 - EYE-EYE
#_CA2F: dw WontedRubide-1             ; 17 - RUBIDE
#_CA31: dw WontedItem-1               ; 18 - UMBRELLA
#_CA33: dw WontedItem-1               ; 19 - BALLOON
#_CA35: dw WontedItem-1               ; 1A - HUDSON BEE
#_CA37: dw WontedItem-1               ; 1B - KEY
#_CA39: dw WontedEnemyB-1             ; 1C - FIRE
#_CA3B: dw WontedEnemyC-1             ; 1D - UNBAO
#_CA3D: dw WontedEnemyC-1             ; 1E - BRAIN TOTO
#_CA3F: dw WontedEnemyD-1             ; 1F - SPARK
#_CA41: dw WontedEnemyD-1             ; 20 - FLAG
#_CA43: dw WontedEnemyB-1             ; 21 - CROW
#_CA45: dw WontedItem-1               ; 22 - STORY ITEM
#_CA47: dw WontedMaharito-1           ; 23 - MAHARITO
#_CA49: dw WontedEnemyC-1             ; 24 - MADORA
#_CA4B: dw WontedItem-1               ; 25 - NOTE
#_CA4D: dw WontedEnemyA-1             ; 26 - GERUBO
#_CA4F: dw WontedEnemyC-1             ; 27 - FLYING EYE
#_CA51: dw WontedEnemyA-1             ; 28 - CAMRY
#_CA53: dw WontedEnemyA-1             ; 29 - SHIM

;===================================================================================================

WontedBossFireball:
#_CA55: LDA.b #$00
#_CA57: STA.b $34

#_CA59: LDA.b $61
#_CA5B: STA.b $81
#_CA5D: STA.b $38

#_CA5F: LDA.b $63
#_CA61: STA.b $82
#_CA63: STA.b $35

#_CA65: LDA.b $8E
#_CA67: LSR A
#_CA68: LSR A
#_CA69: AND.b #$01
#_CA6B: CLC
#_CA6C: ADC.b #$44
#_CA6E: JSR DrawPredefinedSprite

#_CA71: JSR CheckHitbox_00
#_CA74: BCC EXIT_CAEB

#_CA76: JSR DeleteSpriteself

#_CA79: LDA.b $61
#_CA7B: STA.b $38

#_CA7D: LDA.b #$02
#_CA7F: JSR SpawnSmokePuff

#_CA82: LDA.b $B8
#_CA84: ASL A
#_CA85: ASL A
#_CA86: ASL A
#_CA87: STA.b $1C

#_CA89: LDA.b $B4
#_CA8B: ASL A
#_CA8C: ADC.b $1C
#_CA8E: ADC.b #$08
#_CA90: TAX

#_CA91: JMP DamageMilon

;===================================================================================================

WontedHeart:
#_CA94: LDA.b $66
#_CA96: BPL .draw

; flicker
#_CA98: AND.b #$03 ; AND.b #$02 : BEQ next time
#_CA9A: CMP.b #$02
#_CA9C: BCC EXIT_CAEB

.draw
#_CA9E: LDA.b $8E
#_CAA0: LSR A
#_CAA1: AND.b #$01
#_CAA3: STA.b $37

#_CAA5: LDA.b #$6A
#_CAA7: STA.b $60

#_CAA9: JSR DrawSimpleSprite

#_CAAC: LDA.b $81
#_CAAE: SEC
#_CAAF: SBC.b #$04
#_CAB1: STA.b $81

#_CAB3: LDA.b $82
#_CAB5: SEC
#_CAB6: SBC.b #$04
#_CAB8: STA.b $82

#_CABA: JSR CheckHitbox_00
#_CABD: BCC EXIT_CAEB

#_CABF: LDA.b #$16 ; SFX 16
#_CAC1: STA.b $E6

#_CAC3: JSR RevertHeartToDropper

;===================================================================================================

Restore8Health:
#_CAC6: LDA.b #$08

;===================================================================================================

RestoreHealth:
#_CAC8: CLC
#_CAC9: ADC.b $B2
#_CACB: STA.b $B2

#_CACD: CMP.b $B3
#_CACF: BCC .clamp_health
#_CAD1: BEQ .clamp_health

#_CAD3: LDA.b $B3
#_CAD5: STA.b $B2

#_CAD7: LDA.b #$00
#_CAD9: STA.b $BB

#_CADB: LDA.b $9C
#_CADD: BEQ .clamp_health

#_CADF: CMP.b #$02
#_CAE1: BCS .clamp_health

#_CAE3: INC.b $9C

.clamp_health
#_CAE5: LDA.b $B2
#_CAE7: AND.b #$F8
#_CAE9: STA.b $B2

;===================================================================================================

#EXIT_CAEB:
#_CAEB: RTS

;===================================================================================================

WontedBoss:
#_CAEC: LDA.b #$00
#_CAEE: STA.b $34

#_CAF0: LDX.b $B4
#_CAF2: LDA.w BossPalette-1,X
#_CAF5: STA.b $32

#_CAF7: LDA.b $61
#_CAF9: STA.b $81
#_CAFB: STA.b $38

#_CAFD: LDA.b $63
#_CAFF: STA.b $35
#_CB01: STA.b $82

#_CB03: JSR DrawBossBody

; Draw the wings
#_CB06: LDA.b $60
#_CB08: CMP.b #$06
#_CB0A: BCS .collision_test

#_CB0C: LDA.b $8E
#_CB0E: LSR A
#_CB0F: LSR A
#_CB10: AND.b #$03
#_CB12: TAX

#_CB13: LDA.w .wings_offset,X
#_CB16: STA.b $23

#_CB18: LDA.b $61
#_CB1A: CLC
#_CB1B: ADC.b #$10
#_CB1D: SEC
#_CB1E: SBC.b $23
#_CB20: STA.b $38

#_CB22: PHA

#_CB23: LDA.b $63
#_CB25: CLC
#_CB26: ADC.b $23
#_CB28: STA.b $35

#_CB2A: PHA

#_CB2B: LDA.b #$11
#_CB2D: STA.b $36
#_CB2F: JSR Draw2x3Sprite

#_CB32: PLA
#_CB33: CLC
#_CB34: ADC.b #$18
#_CB36: STA.b $35

#_CB38: PLA
#_CB39: CLC
#_CB3A: ADC.b #$08
#_CB3C: STA.b $38

#_CB3E: LDA.b #$ED
#_CB40: STA.b $36

#_CB42: JSR AddObjectToBufferSafely

#_CB45: LDA.b $38
#_CB47: SEC
#_CB48: SBC.b #$08
#_CB4A: STA.b $38

#_CB4C: LDA.b $35
#_CB4E: CLC
#_CB4F: ADC.b #$08
#_CB51: STA.b $35

#_CB53: LDA.b #$FD
#_CB55: STA.b $36
#_CB57: JSR AddObjectToBufferSafely

;---------------------------------------------------------------------------------------------------

.collision_test
#_CB5A: LDA.b $5F
#_CB5C: BNE EXIT_CB9E

#_CB5E: LDX.b #$08
#_CB60: JSR CheckHitbox
#_CB63: BCC .no_touching

#_CB65: LDY.b $B4
#_CB67: LDA.w BossHugDamage-1,Y
#_CB6A: TAX
#_CB6B: JSR DamageMilon

.no_touching
#_CB6E: LDA.b $82
#_CB70: CLC
#_CB71: ADC.b #$08
#_CB73: STA.b $82

#_CB75: JSR CheckForBubbleHit
#_CB78: BCC EXIT_CB9E

#_CB7A: LDA.b #$13 ; SFX 13
#_CB7C: STA.b $E6

#_CB7E: JSR GetBubbleStrength
#_CB81: LSR A
#_CB82: CLC
#_CB83: ADC.b #$01
#_CB85: ADC.b $68
#_CB87: STA.b $68

#_CB89: JSR GetHardmodeAdjustment

; More HP in hardmode
#_CB8C: LDX.b $B4
#_CB8E: LDA.w BossHP-1,X
#_CB91: CLC
#_CB92: ADC.b $1C
#_CB94: STA.b $1C

#_CB96: LDA.b $68
#_CB98: CMP.b $1C
#_CB9A: BCC EXIT_CB9E

#_CB9C: INC.b $5F

;---------------------------------------------------------------------------------------------------

#EXIT_CB9E:
#_CB9E: RTS

;---------------------------------------------------------------------------------------------------

.wings_offset
#_CB9F: db $00, $01, $02, $01

;===================================================================================================

BossHP:
#_CBA3: db $0E ; BOSS 01 - HOMA          | 14 HP
#_CBA4: db $11 ; BOSS 02 - DOMA          | 17 HP
#_CBA5: db $14 ; BOSS 03 - BARUKAMA      | 20 HP
#_CBA6: db $28 ; BOSS 04 - BLUE DOMA     | 40 HP
#_CBA7: db $30 ; BOSS 05 - RED HOMA      | 48 HP
#_CBA8: db $38 ; BOSS 06 - RED BARUKAMA  | 56 HP
#_CBA9: db $40 ; BOSS 07 - KAMA          | 64 HP

BossPalette:
#_CBAA: db $01 ; BOSS 01
#_CBAB: db $01 ; BOSS 02
#_CBAC: db $01 ; BOSS 03
#_CBAD: db $03 ; BOSS 04
#_CBAE: db $03 ; BOSS 05
#_CBAF: db $03 ; BOSS 06
#_CBB0: db $02 ; BOSS 07

BossHugDamage:
#_CBB1: db $0C ; BOSS 01
#_CBB2: db $10 ; BOSS 02
#_CBB3: db $14 ; BOSS 03
#_CBB4: db $18 ; BOSS 04
#_CBB5: db $1C ; BOSS 05
#_CBB6: db $20 ; BOSS 06
#_CBB7: db $24 ; BOSS 07

;===================================================================================================

DrawBossBody:
#_CBB8: LDX.b #$02

#_CBBA: LDA.b $60
#_CBBC: CMP.b #$06
#_CBBE: BCC .not_doma

#_CBC0: INX

.not_doma
#_CBC1: STX.b $23

#_CBC3: LDA.b $60
#_CBC5: ASL A
#_CBC6: ASL A
#_CBC7: TAX

#_CBC8: LDY.b #$00

;---------------------------------------------------------------------------------------------------

.next_body_part
#_CBCA: LDA.w .body_parts,X
#_CBCD: STA.b $36

#_CBCF: JSR Draw2x3Sprite

#_CBD2: INX

#_CBD3: CPY.b $23
#_CBD5: BEQ .finished

#_CBD7: LDA.w .offset_x,Y
#_CBDA: CLC
#_CBDB: ADC.b $38
#_CBDD: STA.b $38

#_CBDF: LDA.w .offset_y,Y
#_CBE2: CLC
#_CBE3: ADC.b $35
#_CBE5: STA.b $35

#_CBE7: INY
#_CBE8: BNE .next_body_part

;---------------------------------------------------------------------------------------------------

.finished
#_CBEA: CPY.b #$02 ; only add if the boss had 3 parts (so not Doma)
#_CBEC: BNE EXIT_CB9E

#_CBEE: LDA.b $38
#_CBF0: CLC
#_CBF1: ADC.b #$F0
#_CBF3: STA.b $38

#_CBF5: LDA.b $35
#_CBF7: CLC
#_CBF8: ADC.b #$E8
#_CBFA: STA.b $35

#_CBFC: LDX.b $60

#_CBFE: LDA.w .shoulder,X
#_CC01: JMP AddObjectToBufferSafely

;---------------------------------------------------------------------------------------------------

.shoulder
#_CC04: db $D8 ; HOMA
#_CC05: db $D8 ; HOMA
#_CC06: db $25 ; KAMA
#_CC07: db $25 ; KAMA
#_CC08: db $D8 ; BARUKAMA
#_CC09: db $D8 ; BARUKAMA

.body_parts
#_CC0A: db $0B, $0C, $0D, $FF ; HOMA
#_CC0E: db $0E, $0F, $10, $FF ; HOMA
#_CC12: db $12, $13, $14, $FF ; KAMA
#_CC16: db $15, $16, $17, $FF ; KAMA
#_CC1A: db $18, $19, $1A, $FF ; BARUKAMA
#_CC1E: db $1B, $1C, $1D, $FF ; BARUKAMA
#_CC22: db $1E, $20, $21, $1F ; DOMA
#_CC26: db $22, $24, $25, $23 ; DOMA
#_CC2A: db $26, $28, $29, $27 ; DOMA

.offset_x
#_CC2E: db $F0, $00, $F0

.offset_y
#_CC31: db $08, $F0, $D8

;===================================================================================================

WontedMaharito:
#_CC34: LDA.w $05FD ; check for flashing palette
#_CC37: CMP.b #$05
#_CC39: BNE .not_flashing

#_CC3B: LDY.b #$00
#_CC3D: JSR LoadScarySpritePalette

#_CC40: INC.b $97

.not_flashing
#_CC42: LDA.b #$01
#_CC44: STA.b $AF

#_CC46: LDA.b #$00
#_CC48: STA.b $34

#_CC4A: LDA.b #$07
#_CC4C: STA.b $60

#_CC4E: JSR GenericSpriteDraw

#_CC51: PHP
#_CC52: BCS .dont_hurt_milon

;---------------------------------------------------------------------------------------------------

#_CC54: JSR CheckForBubbleHit
#_CC57: BCC .no_bubble_damage

#_CC59: LDA.b $66
#_CC5B: BPL .no_bubble_damage

#_CC5D: JSR GetBubbleStrength
#_CC60: ADC.b $68
#_CC62: STA.b $68

#_CC64: TAX

#_CC65: LDA.b $87
#_CC67: CMP.w $07D6
#_CC6A: BNE .phoney_maharito

#_CC6C: JSR GetHardmodeAdjustment
#_CC6F: ADC.b #$20 ; 32 HP (40 hardmode)
#_CC71: STA.b $1C

#_CC73: CPX.b $1C
#_CC75: BCC .palette_change

#_CC77: INC.b $9E

#_CC79: PLP
#_CC7A: RTS

;---------------------------------------------------------------------------------------------------

.phoney_maharito
#_CC7B: JSR GetHardmodeAdjustment
#_CC7E: ADC.b #$10 ; 16 HP (24 hardmode)
#_CC80: STA.b $1C

#_CC82: CPX.b $1C
#_CC84: BCC .palette_change

#_CC86: LDA.b $87
#_CC88: SEC
#_CC89: SBC.b #$15 ; ROOM 15
#_CC8B: TAY

#_CC8C: LDA.b $BA
#_CC8E: ORA.w BitTable,Y
#_CC91: STA.b $BA

#_CC93: LDA.b #$20
#_CC95: JSR RestoreHealth

#_CC98: LDA.b #$21 ; SPRITE 21
#_CC9A: STA.b $6C

#_CC9C: LDA.b #$00
#_CC9E: STA.b $67

#_CCA0: PLP
#_CCA1: RTS

.palette_change
#_CCA2: LDY.b #$08
#_CCA4: JSR LoadScarySpritePalette

#_CCA7: INC.b $97

;---------------------------------------------------------------------------------------------------

.no_bubble_damage
#_CCA9: LDX.b #$06
#_CCAB: JSR CheckHitbox
#_CCAE: BCC .dont_hurt_milon

#_CCB0: LDA.b $B8
#_CCB2: CLC
#_CCB3: ADC.b #$01
#_CCB5: ASL A
#_CCB6: ASL A
#_CCB7: ASL A
#_CCB8: TAX

#_CCB9: JSR DamageMilon

;---------------------------------------------------------------------------------------------------

.dont_hurt_milon
#_CCBC: LDA.b $8E
#_CCBE: LSR A
#_CCBF: LSR A
#_CCC0: LSR A
#_CCC1: AND.b #$01
#_CCC3: ASL A
#_CCC4: TAX

#_CCC5: LDA.b $66
#_CCC7: BPL .set_a

#_CCC9: INX
#_CCCA: INX
#_CCCB: INX
#_CCCC: INX

.set_a
#_CCCD: STX.b $76

#_CCCF: LDA.b #$08
#_CCD1: JSR MoveSpriteLeft

#_CCD4: LDA.b #$10
#_CCD6: JSR MoveSpriteDown

#_CCD9: LDA.w MaharitoGraphics,X
#_CCDC: INC.b $76
#_CCDE: STA.b $60

#_CCE0: JSR GenericSpriteDraw

#_CCE3: INC.b $34

#_CCE5: LDA.b #$10
#_CCE7: JSR MoveSpriteRight

#_CCEA: LDX.b $76
#_CCEC: LDA.w MaharitoGraphics,X
#_CCEF: STA.b $60

#_CCF1: JSR GenericSpriteDraw

#_CCF4: LDA.b #$08
#_CCF6: JSR MoveSpriteLeft

#_CCF9: LDA.b #$10
#_CCFB: JSR MoveSpriteUp

#_CCFE: PLP
#_CCFF: BCS .exit

#_CD01: LDA.b $66
#_CD03: CMP.b #$90
#_CD05: BEQ .shoot_shots

#_CD07: CMP.b #$D0
#_CD09: BNE .exit

;---------------------------------------------------------------------------------------------------

.shoot_shots
#_CD0B: LDA.b #$12 ; SFX 12
#_CD0D: STA.b $E6

#_CD0F: LDA.b $38
#_CD11: SBC.b #$0C
#_CD13: STA.b $38

#_CD15: LDA.b $35
#_CD17: SBC.b #$0C
#_CD19: STA.b $35

#_CD1B: JSR AttemptMaharitoShot
#_CD1E: JSR AttemptMaharitoShot
#_CD21: BCS .failed_a_shot

#_CD23: INC.w $0606,X
#_CD26: JSR .clamp

.failed_a_shot
#_CD29: JSR AttemptMaharitoShot
#_CD2C: BCS .exit

#_CD2E: DEC.w $0606,X

;---------------------------------------------------------------------------------------------------

.clamp
#_CD31: LDA.w $0606,X
#_CD34: AND.b #$0F
#_CD36: STA.w $0606,X

.exit
#_CD39: RTS

;---------------------------------------------------------------------------------------------------

MaharitoGraphics:
#_CD3A: db $0B, $0C, $0C, $0B
#_CD3E: db $0A, $0A, $0A, $0A

;===================================================================================================

WontedSproing:
#_CD42: LDA.b #$01
#_CD44: STA.b $B0

#_CD46: JSR BasicSpriteDraw
#_CD49: BCS EXIT_CD62

#_CD4B: JMP CheckDamageToAndFrom

;===================================================================================================

WontedEnemyA:
#_CD4E: LDA.b #$01
#_CD50: STA.b $B0

#_CD52: LDA.b #$03
#_CD54: STA.b $B1

#_CD56: JSR BasicSpriteDraw
#_CD59: BCS EXIT_CD62

#_CD5B: JSR CheckDamageToAndFrom
#_CD5E: JSR AdvancedBubbleDamageCheck

#_CD61: CLC

;---------------------------------------------------------------------------------------------------

#EXIT_CD62:
#_CD62: RTS

;===================================================================================================

WontedEnemyC:
#_CD63: JSR WontedEnemyA
#_CD66: BCS EXIT_CDCD

#_CD68: LDA.b $5F
#_CD6A: BNE EXIT_CDCD

#_CD6C: LDA.b $6C
#_CD6E: CMP.b #$1E ; SPRITE 1E
#_CD70: BNE .not_brain

#_CD72: LDA.b #$40
#_CD74: JSR TestProximityToMilonXY
#_CD77: BCS EXIT_CDCD

#_CD79: LDA.b $8E
#_CD7B: AND.b #$3F
#_CD7D: BNE EXIT_CDCD

#_CD7F: LDA.b #$02
#_CD81: JMP AttemptCustomProjectileShot

;---------------------------------------------------------------------------------------------------

.not_brain
#_CD84: CMP.b #$27 ; SPRITE 27
#_CD86: BNE .not_flying_eye

.am_unbao
#_CD88: JSR TestIfFacingMilonX
#_CD8B: BNE EXIT_CDCD

#_CD8D: LDA.b #$20
#_CD8F: JSR TestProximityToMilonY
#_CD92: BCS EXIT_CDCD

#_CD94: LDA.b $8E
#_CD96: AND.b #$1F
#_CD98: BNE EXIT_CDCD

#_CD9A: LDA.b #$01
#_CD9C: JMP AttemptCustomProjectileShot

;---------------------------------------------------------------------------------------------------

.not_flying_eye
#_CD9F: CMP.b #$1D ; SPRITE 1D
#_CDA1: BEQ .am_unbao

#_CDA3: CMP.b #$24 ; SPRITE 24
#_CDA5: BNE EXIT_CDCD

; Madora
#_CDA7: JSR TestIfFacingMilonX
#_CDAA: BNE EXIT_CDCD

#_CDAC: LDA.b #$50
#_CDAE: JSR TestProximityToMilonY
#_CDB1: BCS EXIT_CDCD

#_CDB3: LDA.b $8E
#_CDB5: AND.b #$3F
#_CDB7: BNE EXIT_CDCD

#_CDB9: LDA.b #$02
#_CDBB: JMP AttemptCustomProjectileShot

;===================================================================================================

TestIfFacingMilonX:
#_CDBE: LDA.b $81
#_CDC0: CMP.b $3E

#_CDC2: LDA.b #$00
#_CDC4: ROL A
#_CDC5: STA.b $1C

#_CDC7: LDA.b $65
#_CDC9: AND.b #$01
#_CDCB: CMP.b $1C

;---------------------------------------------------------------------------------------------------
; Most popular exit?
;---------------------------------------------------------------------------------------------------
#EXIT_CDCD:
#_CDCD: RTS

;===================================================================================================

WontedPaumeru:
#_CDCE: JSR WontedEnemyA
#_CDD1: BCS EXIT_CD62

#_CDD3: LDA.b $5F
#_CDD5: BNE EXIT_CD62

#_CDD7: LDA.b #$50
#_CDD9: JSR TestProximityToMilonXY
#_CDDC: BCS EXIT_CD62

#_CDDE: JSR Random
#_CDE1: AND.b #$3F
#_CDE3: CMP.b #$06
#_CDE5: BNE EXIT_CDCD

#_CDE7: LDA.b #$01
#_CDE9: JMP AttemptCustomProjectileShot

;===================================================================================================

TestProximityToMilonXY:
#_CDEC: STA.b $1C

#_CDEE: LDA.b $3E
#_CDF0: SBC.b $81
#_CDF2: JSR GetAbsoluteValue
#_CDF5: CMP.b $1C
#_CDF7: BCS EXIT_CE02

.check_milon_screen_y
#_CDF9: LDA.b $3F
#_CDFB: SBC.b $82
#_CDFD: JSR GetAbsoluteValue
#_CE00: CMP.b $1C

;---------------------------------------------------------------------------------------------------

#EXIT_CE02:
#_CE02: RTS

;===================================================================================================

#TestProximityToMilonY:
#_CE03: STA.b $1C
#_CE05: BNE .check_milon_screen_y ; BRA

;===================================================================================================

GetAbsoluteValue:
#_CE07: BCS EXIT_CE02

#_CE09: JMP GetAdditiveInverse

;===================================================================================================

WontedSafuma:
#_CE0C: JSR WontedEnemyA
#_CE0F: BCS EXIT_CDCD

#_CE11: LDA.b $5F
#_CE13: BNE EXIT_CDCD

#_CE15: LDA.b #$78
#_CE17: JSR TestProximityToMilonXY
#_CE1A: BCS EXIT_CDCD

#_CE1C: JSR Random
#_CE1F: AND.b #$3F
#_CE21: CMP.b #$0D
#_CE23: BNE EXIT_CDCD

#_CE25: LDA.b #$01
#_CE27: JMP AttemptCustomProjectileShot

;===================================================================================================

WontedRubide:
#_CE2A: JSR WontedEnemyA
#_CE2D: BCS EXIT_CDCD

#_CE2F: LDA.b $5F
#_CE31: BNE EXIT_CDCD

#_CE33: LDA.b #$64
#_CE35: JSR TestProximityToMilonXY
#_CE38: BCS EXIT_CDCD

#_CE3A: JSR Random
#_CE3D: AND.b #$7F
#_CE3F: CMP.b #$05
#_CE41: BNE EXIT_CDCD

#_CE43: LDA.b #$02
#_CE45: JMP AttemptCustomProjectileShot

;===================================================================================================

MedamarugeWontedIfVisible:
#_CE48: JSR IsAbsoluteOnScreen
#_CE4B: BCS .fail

#_CE4D: JSR RandomlyTimedProjectile

#_CE50: LDA.b #$02
#_CE52: STA.b $AF

#_CE54: JSR GenericSpriteDraw

#_CE57: LDA.b #$01
#_CE59: STA.b $B0

#_CE5B: LDA.b #$12
#_CE5D: STA.b $B1

#_CE5F: JSR CheckDamageToAndFrom

#_CE62: JSR AdvancedBubbleDamageCheck
#_CE65: BCC .fail

#_CE67: JSR GetBubbleStrength
#_CE6A: ADC.b #$01
#_CE6C: ADC.b $67
#_CE6E: STA.b $67

#_CE70: RTS

.fail
#_CE71: SEC

#_CE72: RTS

;===================================================================================================

GetBubbleStrength:
#_CE73: LDA.b $9B
#_CE75: AND.b #$18
#_CE77: LSR A
#_CE78: LSR A
#_CE79: LSR A

#_CE7A: CLC

#_CE7B: RTS

;===================================================================================================

BasicSpriteDraw:
#_CE7C: LDA.b $5F
#_CE7E: BEQ .alive

#_CE80: CMP.b #$40
#_CE82: BCC .fail

.alive
#_CE84: LDA.b #$03
#_CE86: STA.b $AF

;===================================================================================================

#GenericSpriteDraw:
#_CE88: LDA.b $AF
#_CE8A: AND.b #$01
#_CE8C: BEQ .ignore_screen_check

#_CE8E: JSR IsAbsoluteOnScreen
#_CE91: BCS .fail

.ignore_screen_check
#_CE93: LDA.b $AF
#_CE95: AND.b #$02
#_CE97: BEQ .ignore_direction

#_CE99: LDA.b $65
#_CE9B: AND.b #$01
#_CE9D: STA.b $34

.ignore_direction
#_CE9F: LDA.b $60
#_CEA1: JSR DrawPredefinedSprite

;---------------------------------------------------------------------------------------------------

#CLC_CEA4:
#_CEA4: CLC

#_CEA5: RTS

;===================================================================================================

#CheckDamageToAndFrom:
#_CEA6: JSR CheckHitbox_00
#_CEA9: BCC .exit

; Interesting unused code for dying if hitting Milon when he's shielded
; Unused because nothing sets this flag
#_CEAB: LDA.b $B0
#_CEAD: AND.b #$02
#_CEAF: BEQ .attempt_damage

#_CEB1: LDA.b $9C
#_CEB3: BEQ .attempt_damage

#_CEB5: JSR ProcessEnemyDrop

.fail
#_CEB8: SEC

#_CEB9: RTS

.attempt_damage
#_CEBA: LDA.b $B0
#_CEBC: AND.b #$01
#_CEBE: BEQ .no_damage

#_CEC0: JSR DamageMilon1Heart

.no_damage
#_CEC3: SEC

.exit
#_CEC4: RTS

;===================================================================================================

AdvancedBubbleDamageCheck:
#_CEC5: LDA.b $B1
#_CEC7: AND.b #$08
#_CEC9: BEQ .not_tough_guy

#_CECB: LDA.b $9B
#_CECD: AND.b #$18
#_CECF: BEQ .exit

.not_tough_guy
#_CED1: LDA.b $B1
#_CED3: AND.b #$02
#_CED5: BEQ .exit

#_CED7: LDA.b $B1
#_CED9: AND.b #$10
#_CEDB: BEQ .not_permissive

#_CEDD: LDA.b $5F
#_CEDF: BMI .check_bubbles

.not_permissive
#_CEE1: LDA.b $5F
#_CEE3: BNE CLC_CEA4

.check_bubbles
#_CEE5: JSR CheckForBubbleHit
#_CEE8: BCC .exit

#_CEEA: LDA.b $B1
#_CEEC: AND.b #$01
#_CEEE: BEQ .exit

#_CEF0: JSR ProcessEnemyDrop

#_CEF3: SEC

.exit
#_CEF4: RTS

;===================================================================================================

WontedEnemyD:
#_CEF5: LDA.b $8A
#_CEF7: BEQ .inside

#_CEF9: LDA.b $98
#_CEFB: AND.b #$02
#_CEFD: BEQ EXIT_CF43

.inside
#_CEFF: LDA.b $5F
#_CF01: BNE EXIT_CF43

#_CF03: LDA.b $61
#_CF05: STA.b $38
#_CF07: STA.b $81
#_CF09: STA.b $92

#_CF0B: LDA.b $63
#_CF0D: STA.b $35
#_CF0F: STA.b $82
#_CF11: STA.b $93

#_CF13: LDA.b $8E
#_CF15: LSR A
#_CF16: LSR A
#_CF17: AND.b #$01
#_CF19: STA.b $34

#_CF1B: LDA.b #$00
#_CF1D: STA.b $AF

#_CF1F: JSR GenericSpriteDraw

#_CF22: LDA.b #$01
#_CF24: STA.b $B0

#_CF26: LDA.b #$0B
#_CF28: STA.b $B1

#_CF2A: JSR CheckDamageToAndFrom

#_CF2D: JMP AdvancedBubbleDamageCheck

;===================================================================================================

WontedMedamaruge:
#_CF30: LDA.b $5F
#_CF32: BPL EXIT_CF43

#_CF34: CMP.b #$F0
#_CF36: BCS .alternate

#_CF38: CMP.b #$90
#_CF3A: BCC .alternate

.actually_yes
#_CF3C: JMP MedamarugeWontedIfVisible

.alternate
#_CF3F: AND.b #$01
#_CF41: BEQ .actually_yes

;---------------------------------------------------------------------------------------------------

#EXIT_CF43:
#_CF43: RTS

;===================================================================================================

WontedProjectile:
#_CF44: LDX.b $67
#_CF46: LDA.w ProjectilePalette,X
#_CF49: STA.b $37

#_CF4B: JSR GetFrameMod4
#_CF4E: TAX
#_CF4F: CMP.b #$02
#_CF51: BCC .no_flip

#_CF53: LDA.b $37
#_CF55: ORA.b #$C0
#_CF57: STA.b $37

.no_flip
#_CF59: LDA.b $67
#_CF5B: ASL A
#_CF5C: STA.b $1C

#_CF5E: TXA
#_CF5F: AND.b #$01
#_CF61: CLC
#_CF62: ADC.b $1C
#_CF64: TAX

#_CF65: LDA.w ProjectileGraphics,X
#_CF68: STA.b $60

#_CF6A: JSR DrawSimpleSprite

;---------------------------------------------------------------------------------------------------

#_CF6D: JSR CheckHitbox_04
#_CF70: BCC .exit

#_CF72: LDA.b #$23
#_CF74: STA.b $B1

#_CF76: JSR DamageMilon1Heart
#_CF79: JSR ProcessEnemyDrop

;===================================================================================================

#DeleteProjectileSelf:
#_CF7C: JSR DecrementProjectileQuota

#_CF7F: LDA.b #$00
#_CF81: STA.b $6C

.exit
#_CF83: RTS

;===================================================================================================

DecrementProjectileQuota:
#_CF84: DEC.w $07DB
#_CF87: BPL .exit

#_CF89: INC.w $07DB

.exit
#_CF8C: RTS

;===================================================================================================

ProjectilePalette:
#_CF8D: db $02
#_CF8E: db $02
#_CF8F: db $03
#_CF90: db $02
#_CF91: db $03

ProjectileGraphics:
#_CF92: db $6C, $6D ; 00 - shuriken
#_CF94: db $6C, $6D ; 01 - small fireball
#_CF96: db $7C, $7D ; 02 - 6-pointed shuriken / Snapdragon booger
#_CF98: db $7C, $7D ; 03 - Crow fireball
#_CF9A: db $3A, $3A ; 04 - Maharito fireball

;===================================================================================================

DrawSimpleSprite:
#_CF9C: LDA.b $61
#_CF9E: STA.b $38
#_CFA0: STA.b $81
#_CFA2: STA.b $92

#_CFA4: LDA.b $63
#_CFA6: STA.b $35
#_CFA8: STA.b $82
#_CFAA: STA.b $93

#_CFAC: LDA.b $60
#_CFAE: JMP AddObjectToBufferSafely

;===================================================================================================
; B is for BIG!
;===================================================================================================
WontedEnemyB:
#_CFB1: LDA.b $87
#_CFB3: CMP.b #$08 ; ROOM 08
#_CFB5: BNE .force_check

#_CFB7: LDA.w $07C3
#_CFBA: BEQ .exit

.force_check
#_CFBC: LDA.b $6C
#_CFBE: CMP.b #$21 ; SPRITE 21

#_CFC0: LDA.b #$02
#_CFC2: ADC.b #$00
#_CFC4: STA.b $32

#_CFC6: JSR GetFrameBit4inY
#_CFC9: STA.b $34

#_CFCB: LDA.b $5F
#_CFCD: BEQ .no_flipping

#_CFCF: LSR A
#_CFD0: AND.b #$01
#_CFD2: BEQ .exit

.no_flipping
#_CFD4: JSR DrawBigGuy
#_CFD7: BCS .exit

#_CFD9: LDA.b $5F
#_CFDB: BNE .exit

#_CFDD: LDA.b $38
#_CFDF: SBC.b #$0C
#_CFE1: STA.b $38

#_CFE3: LDA.b $35
#_CFE5: SBC.b #$08
#_CFE7: STA.b $35

;---------------------------------------------------------------------------------------------------

#_CFE9: JSR AttemptBigGuyFireShot

#_CFEC: JSR CheckForBubbleHit
#_CFEF: BCC .no_damage

#_CFF1: LDA.w $07A8 ; canteen
#_CFF4: BEQ .no_damage

#_CFF6: LDA.b #$13 ; SFX 13
#_CFF8: STA.b $E6

#_CFFA: INC.b $67

#_CFFC: JSR GetHardmodeAdjustment
#_CFFF: ADC.b #$10 ; 16 HP (24 in hardmode)
#_D001: STA.b $1C

#_D003: LDA.b $67
#_D005: CMP.b $1C
#_D007: BCC .no_damage

#_D009: INC.b $5F

#_D00B: LDA.b #$00
#_D00D: STA.b $66

#_D00F: RTS

.no_damage
#_D010: JSR CheckHitbox_02
#_D013: BCC .exit

#_D015: JSR DamageMilon1Heart
#_D018: CLC

.exit
#_D019: RTS

;===================================================================================================

WontedPhoneyPrincess:
#_D01A: LDA.b $60
#_D01C: LDX.b #$03

#_D01E: CMP.b #$07
#_D020: BNE .keep_3

#_D022: DEX

.keep_3
#_D023: STX.b $32

#_D025: LDA.b $65
#_D027: STA.b $34

#_D029: JSR DrawBigGuy
#_D02C: BCS .exit

#_D02E: LDA.b $66
#_D030: BNE .exit

#_D032: JSR CheckHitbox_02
#_D035: BCC .exit

#_D037: LDA.b #$7F
#_D039: STA.b $66

.exit
#_D03B: RTS

;===================================================================================================

DrawBigGuy:
#_D03C: JSR IsAbsoluteOnScreen
#_D03F: BCS .exit

#_D041: LDA.b $60
#_D043: JSR Draw2x3SpriteEnemy

#_D046: CLC

.exit
#_D047: RTS

;===================================================================================================

DieAndExplode:
#_D048: JSR BurstIntoSmoke

#_D04B: INC.b $5F

#_D04D: RTS

;===================================================================================================

ProcessEnemyDrop:
#_D04E: LDA.b $8A
#_D050: BNE DieAndExplode

#_D052: LDA.b $B1
#_D054: AND.b #$20
#_D056: BNE DieAndExplode

; Get umbrella drop kill count
#_D058: LDA.b $9B
#_D05A: AND.b #$03
#_D05C: ASL A
#_D05D: ASL A
#_D05E: ADC.b #$0A
#_D060: STA.b $1C

#_D062: INC.b $9D
#_D064: LDA.b $9D
#_D066: CMP.b $1C
#_D068: BCC .no_umbrella_drop

#_D06A: LDA.b #$00
#_D06C: STA.b $9D

#_D06E: LDA.b $6C
#_D070: CMP.b #$20 ; SPRITE 20
#_D072: BEQ .am_annoying_bat

#_D074: CMP.b #$1F ; SPRITE 1F
#_D076: BNE .am_not_annoying

.am_annoying_bat
#_D078: LDA.b $61
#_D07A: JSR ApplyBigXCoordinateChange

#_D07D: LDA.b $63
#_D07F: JSR ApplyBigYCoordinateChange

.am_not_annoying
#_D082: LDA.b #$18 ; SPRITE 18
#_D084: JSR SpawnSprite

#_D087: JSR DieAndExplode

#_D08A: LDA.b #$0C ; SFX 0C
#_D08C: STA.b $E6

#_D08E: RTS

;---------------------------------------------------------------------------------------------------

.no_umbrella_drop
#_D08F: JSR Random
#_D092: AND.b #$03
#_D094: BNE DieAndExplode

#_D096: JSR AmIAWeirdFlyingGuy
#_D099: BNE .dont_cache_coordinates

#_D09B: LDA.b $61
#_D09D: STA.b $69

#_D09F: LDA.b $63
#_D0A1: STA.b $6A

.dont_cache_coordinates
#_D0A3: LDA.b $6C
#_D0A5: STA.b $67

#_D0A7: LDA.b #$0B ; SPRITE 0B
#_D0A9: STA.b $6C

#_D0AB: LDA.b $81
#_D0AD: CLC
#_D0AE: ADC.b #$04
#_D0B0: STA.b $61

#_D0B2: LDA.b $82
#_D0B4: CLC
#_D0B5: ADC.b #$04
#_D0B7: STA.b $63

;===================================================================================================

BurstIntoSmoke:
#_D0B9: LDA.b $81
#_D0BB: STA.b $38

#_D0BD: LDA.b $82
#_D0BF: STA.b $35

#_D0C1: LDA.b #$02
#_D0C3: JSR SpawnSmokePuff

#_D0C6: LDX.b #$14 ; SFX 14
#_D0C8: STX.b $E6

#_D0CA: INC.w $07BE

;---------------------------------------------------------------------------------------------------

#EXIT_D0CD:
#_D0CD: RTS

;===================================================================================================

WontedItem:
#_D0CE: JSR BasicSpriteDraw
#_D0D1: BCS EXIT_D0CD

#_D0D3: JSR CheckHitbox_00
#_D0D6: BCC EXIT_D0CD

#_D0D8: LDA.b $6C

#_D0DA: LDX.b #$00 ; Clear sprite ID
#_D0DC: STX.b $6C

#_D0DE: CMP.b #$03 ; SPRITE 03
#_D0E0: BNE .not_crystal

#_D0E2: JSR PerformCollectionJingle

#_D0E5: LDA.b #$06 ; SFX 06
#_D0E7: STA.b $E6

#_D0E9: INC.b $B6 ; Increment crystals

#_D0EB: LDX.b $B4
#_D0ED: DEX

#_D0EE: LDA.b $B7
#_D0F0: ORA.w BitTable,X
#_D0F3: STA.b $B7

#_D0F5: RTS

;---------------------------------------------------------------------------------------------------

.not_crystal
#_D0F6: CMP.b #$19 ; SPRITE 19
#_D0F8: BNE .not_balloon

#_D0FA: LDA.b #$01
#_D0FC: STA.b $9A

#_D0FE: RTS

;---------------------------------------------------------------------------------------------------

.not_balloon
#_D0FF: CMP.b #$1B ; SPRITE 1B
#_D101: BNE .not_key

#_D103: INC.w $07BF

#_D106: LDA.b #$0A ; SFX 0A
#_D108: STA.b $E6

#_D10A: LDA.w $07BF
#_D10D: CMP.b #$02
#_D10F: BCC .exit

#_D111: JSR GetBitIndexForRoom

#_D114: LDA.w $07C8,X
#_D117: ORA.w BitTable,Y
#_D11A: STA.w $07C8,X

#_D11D: RTS

;---------------------------------------------------------------------------------------------------

.not_key
#_D11E: CMP.b #$1A ; SPRITE 1A
#_D120: BNE .not_hudson_bee

#_D122: LDA.b $9C
#_D124: CMP.b #$02
#_D126: BCS .max_shield

#_D128: INC.b $9C

#_D12A: LDA.b #$0D ; SFX 0D
#_D12C: STA.b $E6

.exit
#_D12E: RTS

.max_shield
#_D12F: JSR Restore8Health

#_D132: LDA.b #$00
#_D134: STA.b $BB

#_D136: RTS

;---------------------------------------------------------------------------------------------------

.not_hudson_bee
#_D137: CMP.b #$18 ; SPRITE 18
#_D139: BNE .not_umbrella

#_D13B: LDA.b $9B
#_D13D: TAX

#_D13E: AND.b #$03
#_D140: CMP.b #$02
#_D142: BCS .max_shot

#_D144: CLC
#_D145: ADC.b #$01
#_D147: STA.b $1C

#_D149: TXA
#_D14A: AND.b #$FC
#_D14C: ORA.b $1C
#_D14E: STA.b $9B

#_D150: BNE .play_umbrella_sound ; BRA

.max_shot
#_D152: JSR Restore8Health

.play_umbrella_sound
#_D155: LDA.b #$0D ; SFX 0D
#_D157: STA.b $E6

#_D159: RTS

;---------------------------------------------------------------------------------------------------

.not_umbrella
#_D15A: CMP.b #$22 ; SPRITE 22
#_D15C: BNE .not_crowncanebox

#_D15E: LDA.b $67
#_D160: CMP.b #$07 ; crown
#_D162: BEQ .crown_or_cane

#_D164: CMP.b #$08 ; cane
#_D166: BEQ .crown_or_cane

#_D168: SEC
#_D169: ROR.b $C0

#_D16B: JSR FlagMusicBox
#_D16E: JSR PerformCollectionJingle

#_D171: LDA.b #$00 ; SONG OFF
#_D173: STA.b $BE

#_D175: JSR PlayBonusGame

#_D178: JMP LoadNewArea

;---------------------------------------------------------------------------------------------------

.not_crowncanebox
; SPRITE 25
#_D17B: LDA.b #$16 ; SFX 16
#_D17D: STA.b $E6

#_D17F: INC.b $78

#_D181: LDA.b $60 ; Check note graphics
#_D183: CMP.b #$11
#_D185: BEQ .sharp

#_D187: CMP.b #$58
#_D189: BNE .beamed_notes

#_D18B: LDA.b #$01
#_D18D: JMP RemoveCurrency

.sharp
#_D190: LDA.b #$02
#_D192: db $2C ; BIT trick

.beamed_notes
#_D193: LDA.b #$01
#_D195: JMP AddCurrency

;---------------------------------------------------------------------------------------------------

.crown_or_cane
#_D198: SEC
#_D199: SBC.b #$06
#_D19B: ORA.b $BD
#_D19D: STA.b $BD

#_D19F: JMP PerformCollectionJingle

;===================================================================================================

CheckForBubbleHit:
#_D1A2: LDX.b #$00

#_D1A4: JSR .test_bubble_hit
#_D1A7: BCS .exit

#_D1A9: INX

#_D1AA: JSR .test_bubble_hit
#_D1AD: BCS .exit

#_D1AF: INX

;---------------------------------------------------------------------------------------------------

.test_bubble_hit
#_D1B0: LDA.b $78,X
#_D1B2: BEQ .no_hit

#_D1B4: CMP.b #$08
#_D1B6: BCS .no_hit

#_D1B8: LDA.b $7E,X
#_D1BA: CLC
#_D1BB: ADC.b #$0D
#_D1BD: SEC
#_D1BE: SBC.b $82
#_D1C0: BCC .exit

#_D1C2: CMP.b #$1A
#_D1C4: BCS .no_hit

#_D1C6: LDA.b $7B,X
#_D1C8: CLC
#_D1C9: ADC.b #$0D
#_D1CB: SEC
#_D1CC: SBC.b $81
#_D1CE: BCC .exit

#_D1D0: CMP.b #$1A
#_D1D2: BCC .hit_by_bubble

.no_hit
#_D1D4: CLC

.exit
#_D1D5: RTS

.hit_by_bubble
#_D1D6: LDA.b #$08
#_D1D8: STA.b $78,X

#_D1DA: SEC

#_D1DB: RTS

;===================================================================================================

CheckHitbox_04:
#_D1DC: LDX.b #$04
#_D1DE: db $2C ; BIT trick

CheckHitbox_02:
#_D1DF: LDX.b #$02
#_D1E1: db $2C ; BIT trick

CheckHitbox_00:
#_D1E2: LDX.b #$00

;===================================================================================================

CheckHitbox:
#_D1E4: LDA.b $4F
#_D1E6: BNE .no_overlap

; Check if spring
#_D1E8: LDA.b $6C
#_D1EA: CMP.b #$01 ; SPRITE 01
#_D1EC: BEQ .no_overlap

#_D1EE: LDA.b $5F
#_D1F0: BMI .force_check
#_D1F2: BNE .no_overlap

.force_check
#_D1F4: LDA.b $52 ; +8 when small, 0 for big
#_D1F6: EOR.b #$01
#_D1F8: ASL A
#_D1F9: ASL A
#_D1FA: ASL A
#_D1FB: CLC
#_D1FC: ADC.b $3F
#_D1FE: STA.b $1C

#_D200: TXA
#_D201: ORA.b $52
#_D203: TAX

;---------------------------------------------------------------------------------------------------

#_D204: LDA.b $82
#_D206: SEC
#_D207: SBC.b $1C
#_D209: BCC .above_milon

#_D20B: CMP.w SpriteHitboxes_y_below,X
#_D20E: BCC .check_x

#_D210: CLC

#_D211: RTS

.above_milon
#_D212: CMP.w SpriteHitboxes_y_above,X
#_D215: BCC .no_overlap

;---------------------------------------------------------------------------------------------------

.check_x
#_D217: LDA.b $81
#_D219: SEC
#_D21A: SBC.b $3E
#_D21C: BCC .left_of_milon

#_D21E: CMP.w SpriteHitboxes_x_right,X
#_D221: BCC .overlapped

#_D223: CLC

#_D224: RTS

.left_of_milon
#_D225: CMP.w SpriteHitboxes_x_left,X
#_D228: BCC .no_overlap

;---------------------------------------------------------------------------------------------------

.overlapped
#_D22A: LDA.b $6C
#_D22C: CMP.b #$06 ; SPRITE 06
#_D22E: BEQ HitByBoxingGlove

;---------------------------------------------------------------------------------------------------

#SEC_D230:
#_D230: SEC
#_D231: RTS

;---------------------------------------------------------------------------------------------------

.no_overlap
#_D232: CLC
#_D233: RTS

;===================================================================================================

DamageMilon1Heart:
#_D234: LDX.b #$08

;===================================================================================================

DamageMilon:
#_D236: LDA.b $3C
#_D238: BMI .exit

#_D23A: CMP.b #$07
#_D23C: BCS .exit

#_D23E: LDA.b #$15 ; SFX 15
#_D240: STA.b $E6

#_D242: LDA.b $9C
#_D244: BEQ .no_shield

#_D246: TXA
#_D247: CLC
#_D248: ADC.b $BB
#_D24A: STA.b $BB

#_D24C: CMP.b #$10
#_D24E: BCC .set_recoil

#_D250: LDA.b #$00
#_D252: STA.b $BB

#_D254: DEC.b $9C
#_D256: BPL .set_recoil

.no_shield
#_D258: LDA.b $B2
#_D25A: BEQ .milon_is_dead

#_D25C: TXA
#_D25D: JSR RemoveMilonHP
#_D260: BCC .milon_is_dead

.set_recoil
#_D262: LDA.b $3C
#_D264: ORA.b #$80
#_D266: STA.b $3C

#_D268: LDA.b #$14
#_D26A: STA.b $3D

.exit
#_D26C: RTS

.milon_is_dead
#_D26D: INC.b $4F

#_D26F: RTS

;===================================================================================================

RemoveMilonHP:
#_D270: STA.b $1C

#_D272: LDA.b $B2
#_D274: SEC
#_D275: SBC.b $1C
#_D277: BCS .didnt_die

#_D279: LDA.b #$00

.didnt_die
#_D27B: STA.b $B2

#_D27D: RTS

;===================================================================================================

HitByBoxingGlove:
#_D27E: LDA.w $079D ; medicine
#_D281: BEQ SEC_D230

#_D283: LDA.b $3C
#_D285: BMI .dont_change_size

#_D287: ORA.b #$C0
#_D289: STA.b $3C

#_D28B: LDA.b #$78
#_D28D: STA.b $3D

.dont_change_size
#_D28F: CLC

#_D290: RTS

;===================================================================================================
; db <small>, <big>
;===================================================================================================
SpriteHitboxes:

.y_below
#_D291: db $0B, $13 ; 00
#_D293: db $0B, $13 ; 02
#_D295: db $0B, $13 ; 04
#_D297: db $0B, $13 ; 06
#_D299: db $0B, $13 ; 08

.y_above
#_D29B: db $F5, $F5 ; 00
#_D29D: db $ED, $ED ; 02
#_D29F: db $FD, $FD ; 04
#_D2A1: db $E5, $E5 ; 06
#_D2A3: db $D5, $D5 ; 08

.x_right
#_D2A5: db $0B, $0B ; 00
#_D2A7: db $0B, $0B ; 02
#_D2A9: db $0B, $0B ; 04
#_D2AB: db $0B, $0B ; 06
#_D2AD: db $0B, $0B ; 08

.x_left
#_D2AF: db $F5, $F5 ; 00
#_D2B1: db $F5, $F5 ; 02
#_D2B3: db $FD, $FD ; 04
#_D2B5: db $F5, $F5 ; 06
#_D2B7: db $E5, $E5 ; 08

;===================================================================================================

WontedPlatform:
#_D2B9: JSR GetPlatformScreenPosition
#_D2BC: BCS EXIT_D334

#_D2BE: LDA.b $AB
#_D2C0: BNE .skip_cache

#_D2C2: LDA.b $65
#_D2C4: ASL A
#_D2C5: SEC
#_D2C6: SBC.b #$01
#_D2C8: CLC
#_D2C9: ADC.b $35
#_D2CB: STA.b $6D

#_D2CD: LDA.b $38
#_D2CF: STA.b $6E

;---------------------------------------------------------------------------------------------------

.skip_cache
#_D2D1: LDA.b #$03
#_D2D3: STA.b $37

#_D2D5: LDA.b $8A
#_D2D7: ASL A
#_D2D8: ASL A
#_D2D9: TAX

#_D2DA: LDA.b $AB
#_D2DC: PHA

#_D2DD: JSR DrawPlatform

#_D2E0: PLA
#_D2E1: STA.b $AB

#_D2E3: LDA.b $89
#_D2E5: BEQ EXIT_D334

;---------------------------------------------------------------------------------------------------

; Draw the shadow
#_D2E7: LDA.b $35
#_D2E9: CLC
#_D2EA: ADC.b #$0C
#_D2EC: STA.b $35
#_D2EE: BCS EXIT_D334

#_D2F0: LDA.b $20
#_D2F2: SEC
#_D2F3: SBC.b #$06
#_D2F5: STA.b $38
#_D2F7: BCS .start_shadow

#_D2F9: LDA.b $AB
#_D2FB: BNE .start_shadow

#_D2FD: DEC.b $AB

.start_shadow
#_D2FF: LDX.b #$04

;===================================================================================================

DrawPlatform:
#_D301: JSR .draw_segment
#_D304: BCS EXIT_D334

#_D306: JSR .draw_segment
#_D309: BCS EXIT_D334

#_D30B: JSR .draw_segment
#_D30E: BCS EXIT_D334

;---------------------------------------------------------------------------------------------------

.draw_segment
#_D310: LDA.b $AB
#_D312: BNE .skip_draw

#_D314: LDA.w .character,X
#_D317: STA.b $36

#_D319: STX.b $76

#_D31B: JSR AddObjectToBuffer

#_D31E: LDX.b $76
#_D320: JMP .continue

.skip_draw
#_D323: LDA.b $38
#_D325: CLC
#_D326: ADC.b #$08
#_D328: STA.b $38

.continue
#_D32A: INX
#_D32B: BCC EXIT_D334

#_D32D: LDA.b $AB
#_D32F: BEQ EXIT_D334

#_D331: INC.b $AB
#_D333: CLC

;---------------------------------------------------------------------------------------------------

#EXIT_D334:
#_D334: RTS

;---------------------------------------------------------------------------------------------------

.character
#_D335: db $25, $25, $25, $25 ; platform
#_D339: db $24, $24, $24, $24 ; shadow

;===================================================================================================

GetPlatformScreenPosition:
#_D33D: LDA.b #$00
#_D33F: STA.b $AB

#_D341: LDA.b $00
#_D343: AND.b #$01
#_D345: STA.b $1F

#_D347: LDA.b $61
#_D349: SEC
#_D34A: SBC.b $06
#_D34C: STA.b $38
#_D34E: STA.b $20

#_D350: LDA.b $62
#_D352: SBC.b $1F
#_D354: BCC .infinite_loop
#_D356: BNE .fail

#_D358: BEQ .equal

; !WTF
.infinite_loop
#_D35A: CMP.b #$FF
#_D35C: BNE .infinite_loop

#_D35E: STA.b $AB

;---------------------------------------------------------------------------------------------------

.equal
#_D360: LDA.b $07
#_D362: BNE .use_value

#_D364: LDA.b $16
#_D366: BEQ .use_value

#_D368: LDA.b #$F0

.use_value
#_D36A: STA.b $1E

#_D36C: LDA.b $63
#_D36E: SEC
#_D36F: SBC.b $1E
#_D371: STA.b $35

#_D373: LDA.b $64
#_D375: SBC.b #$00
#_D377: BCC .fail
#_D379: BNE .fail

#_D37B: CLC
#_D37C: RTS

.fail
#_D37D: SEC
#_D37E: RTS

;===================================================================================================

Subtraction16Bit:
#_D37F: LDA.b $1C
#_D381: SEC
#_D382: SBC.b $1E
#_D384: STA.b $1C

#_D386: LDA.b $1D
#_D388: SBC.b $1F
#_D38A: STA.b $1D

#_D38C: RTS

;===================================================================================================

SaveSpriteVars:
#_D38D: JSR GetSpriteOffset

.next
#_D390: LDA.w $005F,Y
#_D393: STA.w $0600,X

#_D396: INX

#_D397: INY
#_D398: CPY.b #$0C
#_D39A: BNE .next

#_D39C: LDX.b $6B

#_D39E: RTS

;===================================================================================================

LoadSpriteVars:
#_D39F: STX.b $6B

#_D3A1: JSR GetSpriteOffset

.next
#_D3A4: LDA.w $0600,X
#_D3A7: STA.w $005F,Y

#_D3AA: INX

#_D3AB: INY
#_D3AC: CPY.b #$0C
#_D3AE: BNE .next

#_D3B0: RTS

;===================================================================================================
; x12
;===================================================================================================
GetSpriteOffset:
#_D3B1: LDA.b $6B
#_D3B3: ASL A
#_D3B4: ASL A
#_D3B5: CLC
#_D3B6: ADC.b $6B
#_D3B8: ADC.b $6B
#_D3BA: ASL A
#_D3BB: TAX

#_D3BC: LDY.b #$00

#_D3BE: RTS

;===================================================================================================

AttemptMaharitoShot:
#_D3BF: LDA.b #$04
#_D3C1: STA.b $22

#_D3C3: BNE AttemptBigGuyProjectile

;===================================================================================================

AttemptBigGuyFireShot:
#_D3C5: LDA.b $8E
#_D3C7: AND.b #$06
#_D3C9: BNE .no_shot

#_D3CB: JSR Random
#_D3CE: AND.b #$1F
#_D3D0: CMP.b #$01
#_D3D2: BNE .no_shot

#_D3D4: LDA.b #$04 ; SFX 04
#_D3D6: STA.b $E6

#_D3D8: LDA.b #$03
#_D3DA: STA.b $22

;---------------------------------------------------------------------------------------------------

#AttemptBigGuyProjectile:
#_D3DC: LDA.b #$03
#_D3DE: JSR CheckProjectileQuota
#_D3E1: BCC .no_shot

#_D3E3: LDA.b #$13 ; SPRITE 13
#_D3E5: JSR SpawnSprite
#_D3E8: BCS .no_shot

#_D3EA: INC.w $07DB

#_D3ED: LDA.b $22
#_D3EF: STA.w $0608,X

#_D3F2: JSR GetDirectionTowardsMilon
#_D3F5: STA.w $0606,X

#_D3F8: LDA.b $38
#_D3FA: STA.w $0602,X

#_D3FD: LDA.b $35
#_D3FF: STA.w $0604,X

#_D402: CLC
#_D403: RTS

.no_shot
#_D404: SEC
#_D405: RTS

;===================================================================================================

AttemptCustomProjectileShot:
#_D406: STA.b $22

#_D408: LDA.b #$03
#_D40A: JSR CheckProjectileQuota
#_D40D: BCC .exit

#_D40F: JSR AttemptProjectileShot
#_D412: BCS .exit

#_D414: LDA.b $22
#_D416: STA.w $0608,X

.exit
#_D419: RTS

;===================================================================================================

RandomlyTimedProjectile:
#_D41A: LDA.b #$03
#_D41C: JSR CheckProjectileQuota
#_D41F: BCC .exit

#_D421: JSR Random
#_D424: ADC.b $3E
#_D426: ADC.b $68
#_D428: STA.b $68

#_D42A: AND.b #$3F
#_D42C: BNE EXIT_D454

#_D42E: JSR AttemptProjectileShot
#_D431: BCS .exit

#_D433: LDA.b #$00
#_D435: STA.w $0608,X

.exit
#_D438: RTS

;===================================================================================================

AttemptProjectileShot:
#_D439: LDA.b #$13 ; SPRITE 13
#_D43B: JSR SpawnSprite
#_D43E: BCS EXIT_D454

#_D440: INC.w $07DB

#_D443: JSR GetDirectionTowardsMilon
#_D446: STA.w $0606,X

#_D449: LDA.b $81
#_D44B: STA.w $0602,X

#_D44E: LDA.b $82
#_D450: STA.w $0604,X

#_D453: CLC

;---------------------------------------------------------------------------------------------------

#EXIT_D454:
#_D454: RTS

;===================================================================================================

CheckProjectileQuota:
#_D455: CMP.w $07DB

#_D458: RTS

;===================================================================================================

GetHardmodeAdjustment:
#_D459: LDA.b $B8
#_D45B: ASL A
#_D45C: ASL A
#_D45D: ASL A
#_D45E: STA.b $1C

#_D460: RTS

;===================================================================================================

LoadAllSprites:
#_D461: INC.b $3A

#_D463: JSR ResetSpritesAndPits

#_D466: LDX.b #$03
#_D468: JSR SetGFXBank

#_D46B: LDA.b $87
#_D46D: ASL A
#_D46E: CLC
#_D46F: ADC.b #SpritePointers>>0
#_D471: TAX

#_D472: LDA.b #$00
#_D474: ADC.b #SpritePointers>>8
#_D476: JSR SetPPUADDRSafely

#_D479: LDA.w PPUDATA
#_D47C: LDA.w PPUDATA
#_D47F: TAX

#_D480: LDA.w PPUDATA

#_D483: JSR SetPPUADDRSafely

#_D486: LDA.w PPUDATA

.next
#_D489: LDA.w PPUDATA
#_D48C: STA.b $1E

#_D48E: AND.b #$3F
#_D490: BEQ .exit

#_D492: JSR LoadOneSprite

#_D495: JMP .next

.exit
#_D498: RTS

;===================================================================================================
; byte 1 : yyii iiii
; byte 2 : YYYx xxxx
; byte 3 : ddhh hhhh
;---------------------------------------------------------------------------------------------------
;  i - sprite ID
;  x - x position /16
;  y - y position /16 (YYYyy)
;  d - direction ($65)
;  h - misc ($68)
;===================================================================================================
LoadOneSprite:
#_D499: CMP.b #$23 ; SPRITE 23
#_D49B: BNE .not_maharito

#_D49D: TAX

#_D49E: LDA.b $87
#_D4A0: SEC
#_D4A1: SBC.b #$15 ; ROOM 15
#_D4A3: TAY

#_D4A4: LDA.b $BA
#_D4A6: AND.w BitTable,Y
#_D4A9: BNE .dont_spawn

#_D4AB: TXA

.not_maharito
#_D4AC: CMP.b #$0F ; SPRITE 0F
#_D4AE: BEQ .am_thing_b

#_D4B0: CMP.b #$10 ; SPRITE 10
#_D4B2: BNE .not_thing_c

.am_thing_b
#_D4B4: TAX

#_D4B5: LDA.b $87
#_D4B7: SEC
#_D4B8: SBC.b #$0B
#_D4BA: AND.b $BD
#_D4BC: BEQ .continue

.dont_spawn
#_D4BE: JSR GetSpriteByte
#_D4C1: JMP GetSpriteByte

;---------------------------------------------------------------------------------------------------

.continue
#_D4C4: TXA

.not_thing_c
#_D4C5: CMP.b #$3F
#_D4C7: BNE .set_id

#_D4C9: JMP SpawnMovingPit

.set_id
#_D4CC: STA.b $6C

#_D4CE: LDX.b #$01

.check_slots
#_D4D0: LDA.w $06C0,X
#_D4D3: BEQ .empty_slot

#_D4D5: INX
#_D4D6: BNE .check_slots

.empty_slot
#_D4D8: LDA.b $6C
#_D4DA: STA.w $06C0,X

#_D4DD: CMP.b #$1F ; SPRITE 1F
#_D4DF: BEQ .bat_or_lightning

#_D4E1: CMP.b #$20 ; SPRITE 20
#_D4E3: BEQ .bat_or_lightning

;---------------------------------------------------------------------------------------------------

#_D4E5: LDA.b #$00
#_D4E7: STA.b $67
#_D4E9: STA.b $62
#_D4EB: STA.b $64
#_D4ED: STA.b $5F
#_D4EF: STA.b $66
#_D4F1: STA.b $60

#_D4F3: JSR GetSpritePropData

#_D4F6: LDA.b $20
#_D4F8: STA.b $61
#_D4FA: STA.b $69

#_D4FC: LDA.b $21
#_D4FE: STA.b $63
#_D500: STA.b $6A

#_D502: LDA.b $1F
#_D504: STA.b $65

#_D506: LDA.b $1E
#_D508: STA.b $68

#_D50A: JSR TilemapXYtoFullCoordinates

#_D50D: LDA.b $6C
#_D50F: CMP.b #$10 ; SPRITE 10
#_D511: BNE .not_a_phoney

#_D513: LDA.b #$08
#_D515: JSR MoveSpriteDown

.not_a_phoney
#_D518: LDA.b $6C
#_D51A: CMP.b #$1C ; SPRITE 1C
#_D51C: BNE .finished

#_D51E: JSR MoveSpriteLeftBy1

#_D521: LDA.b #$0C
#_D523: STA.b $65

#_D525: LDA.b #$20
#_D527: STA.b $66

.finished
#_D529: STX.b $6B
#_D52B: STY.b $75

#_D52D: JSR SaveSpriteVars

#_D530: LDY.b $75

#_D532: RTS

;---------------------------------------------------------------------------------------------------

.bat_or_lightning
#_D533: LDA.b #$01
#_D535: STA.b $5F
#_D537: BNE .finished

;===================================================================================================

SpawnMovingPit:
#_D539: LDX.b #$00

.find_slot
#_D53B: LDA.w $0198,X
#_D53E: CMP.b #$FF
#_D540: BEQ .found_slot

#_D542: TXA
#_D543: CLC
#_D544: ADC.b #$05
#_D546: TAX

#_D547: BNE .find_slot

;---------------------------------------------------------------------------------------------------

.found_slot
#_D549: JSR GetSpritePropData

#_D54C: LDA.b $20
#_D54E: ASL A
#_D54F: STA.w $0198,X

#_D552: LDA.b $21
#_D554: STA.w $0199,X

#_D557: LDA.b $1F
#_D559: STA.w $019A,X

#_D55C: LDA.b $1E
#_D55E: ASL A
#_D55F: STA.w $019C,X

#_D562: LDA.b #$00
#_D564: STA.w $019B,X

#_D567: RTS

;===================================================================================================

GetSpritePropData:
#_D568: JSR GetSpriteByte
#_D56B: STA.b $1F

#_D56D: AND.b #$1F
#_D56F: STA.b $20

#_D571: ASL.b $1F
#_D573: ROL A
#_D574: ASL.b $1F
#_D576: ROL A
#_D577: ASL.b $1F
#_D579: ROL A

#_D57A: ASL.b $1E
#_D57C: ROL A
#_D57D: ASL.b $1E
#_D57F: ROL A
#_D580: AND.b #$1F
#_D582: STA.b $21

#_D584: JSR GetSpriteByte
#_D587: STA.b $1E

#_D589: ROL A
#_D58A: ROL A
#_D58B: ROL A
#_D58C: AND.b #$03
#_D58E: STA.b $1F

#_D590: LDA.b $1E
#_D592: AND.b #$3F
#_D594: STA.b $1E

#_D596: RTS

;===================================================================================================

GetSpriteByte:
#_D597: LDA.b $87
#_D599: CMP.b #$19 ; ROOM 19
#_D59B: BEQ .check_rom

#_D59D: LDA.w PPUDATA

#_D5A0: RTS

.check_rom
#_D5A1: LDA.w ThroneRoomSpriteData,Y

#_D5A4: INY

#_D5A5: RTS

;===================================================================================================

TilemapXYtoFullCoordinates:
#_D5A6: LDA.b #$00
#_D5A8: STA.b $62
#_D5AA: STA.b $64

#_D5AC: LDA.b $61
#_D5AE: ASL A
#_D5AF: ASL A
#_D5B0: ASL A
#_D5B1: ASL A
#_D5B2: ROL.b $62
#_D5B4: STA.b $61

#_D5B6: LDA.b $63
#_D5B8: ASL A
#_D5B9: ASL A
#_D5BA: ASL A
#_D5BB: ASL A
#_D5BC: ROL.b $64
#_D5BE: STA.b $63

#_D5C0: RTS

;===================================================================================================

ResetSpritesAndPits:
#_D5C1: LDA.b #$00
#_D5C3: TAX

.clear_next
#_D5C4: STA.w $0600,X

#_D5C7: INX
#_D5C8: CPX.b #$D0
#_D5CA: BNE .clear_next

;---------------------------------------------------------------------------------------------------

#_D5CC: LDX.b #$00

.clear_more
#_D5CE: LDA.b #$FF
#_D5D0: STA.w $0198,X

#_D5D3: TXA
#_D5D4: CLC
#_D5D5: ADC.b #$05
#_D5D7: TAX

#_D5D8: CPX.b #$28
#_D5DA: BNE .clear_more

#_D5DC: RTS

;===================================================================================================

MoveSpriteDownBy1:
#_D5DD: INC.b $63
#_D5DF: BNE .no_overflow

#_D5E1: INC.b $64

.no_overflow
#_D5E3: RTS

;===================================================================================================

MoveSpriteUpBy1:
#_D5E4: LDA.b $63
#_D5E6: BNE .no_overflow

#_D5E8: DEC.b $64

.no_overflow
#_D5EA: DEC.b $63

#_D5EC: RTS

;===================================================================================================

MoveSpriteRightBy1:
#_D5ED: INC.b $61
#_D5EF: BNE .no_overflow

#_D5F1: INC.b $62

.no_overflow
#_D5F3: RTS

;===================================================================================================

MoveSpriteLeftBy1:
#_D5F4: LDA.b $61
#_D5F6: BNE .no_overflow

#_D5F8: DEC.b $62

.no_overflow
#_D5FA: DEC.b $61

#_D5FC: RTS

;===================================================================================================

MoveSpriteRight:
#_D5FD: CLC
#_D5FE: ADC.b $61
#_D600: STA.b $61

#_D602: BCC .no_overflow

#_D604: INC.b $62

.no_overflow
#_D606: RTS

;===================================================================================================

MoveSpriteLeft:
#_D607: STA.b $1C

#_D609: LDA.b $61
#_D60B: SEC
#_D60C: SBC.b $1C
#_D60E: STA.b $61

#_D610: BCS .no_overflow

#_D612: DEC.b $62

.no_overflow
#_D614: RTS

;===================================================================================================

MoveSpriteDown:
#_D615: CLC
#_D616: ADC.b $63
#_D618: STA.b $63

#_D61A: BCC .no_overflow

#_D61C: INC.b $64

.no_overflow
#_D61E: RTS

;===================================================================================================

MoveSpriteUp:
#_D61F: STA.b $1C

#_D621: LDA.b $63
#_D623: SEC
#_D624: SBC.b $1C
#_D626: STA.b $63

#_D628: LDA.b $64
#_D62A: SBC.b #$00
#_D62C: STA.b $64

#_D62E: RTS

;===================================================================================================

FullCoordinatesToTilemapXY:
#_D62F: LDA.b $62
#_D631: CMP.b #$01

#_D633: LDA.b $61
#_D635: ROR A
#_D636: LSR A
#_D637: LSR A
#_D638: LSR A
#_D639: STA.b $29

#_D63B: LDA.b $64
#_D63D: CMP.b #$01

#_D63F: LDA.b $63
#_D641: ROR A
#_D642: LSR A
#_D643: LSR A
#_D644: LSR A
#_D645: STA.b $2A

#_D647: RTS

;===================================================================================================

IsAbsoluteOnScreen:
#_D648: LDA.b $00
#_D64A: AND.b #$01
#_D64C: STA.b $1F

#_D64E: LDA.b $61
#_D650: SEC
#_D651: SBC.b $06
#_D653: STA.b $38
#_D655: STA.b $81
#_D657: STA.b $20
#_D659: STA.b $92

#_D65B: LDA.b $62
#_D65D: SBC.b $1F
#_D65F: BCC .fail
#_D661: BNE .fail

#_D663: LDA.b $07
#_D665: BNE .set_difference

#_D667: LDA.b $16
#_D669: BEQ .set_difference

#_D66B: LDA.b #$F0

.set_difference
#_D66D: STA.b $1E

#_D66F: LDA.b $63
#_D671: SEC
#_D672: SBC.b $1E
#_D674: STA.b $35
#_D676: STA.b $82
#_D678: STA.b $93

#_D67A: LDA.b $64
#_D67C: SBC.b #$00
#_D67E: BCC .fail
#_D680: BNE .fail

#_D682: CLC
#_D683: RTS

.fail
#_D684: SEC
#_D685: RTS

;===================================================================================================

GetDirectionTowardsMilon:
#_D686: LDA.b #$00
#_D688: STA.b $21
#_D68A: STA.b $20

#_D68C: LDA.b $81
#_D68E: STA.b $1C

#_D690: LDA.b $3E
#_D692: JSR GetAbsoluteDifference
#_D695: STA.b $1E
#_D697: TAY

#_D698: BCC .milon_left

#_D69A: INC.b $20

.milon_left
#_D69C: LDA.b $82
#_D69E: STA.b $1C

#_D6A0: LDA.b $3F
#_D6A2: JSR GetAbsoluteDifference
#_D6A5: STA.b $1F

#_D6A7: BCC .milon_up

#_D6A9: INC.b $20
#_D6AB: INC.b $20

.milon_up
#_D6AD: CMP.b $1E
#_D6AF: BCS .y_difference_bigger

#_D6B1: STA.b $1E
#_D6B3: STY.b $1F

#_D6B5: LDA.b #$04
#_D6B7: STA.b $21

;---------------------------------------------------------------------------------------------------

.y_difference_bigger
#_D6B9: JSR Divide16by8
#_D6BC: TAY
#_D6BD: BEQ .set_fractional_part

#_D6BF: DEY
#_D6C0: BEQ .set_fractional_part

#_D6C2: CPY.b #$01
#_D6C4: BEQ .set_fractional_part

#_D6C6: DEY
#_D6C7: CPY.b #$03
#_D6C9: BCC .set_fractional_part

#_D6CB: LDY.b #$02

.set_fractional_part
#_D6CD: STY.b $1C

#_D6CF: LDA.b $21
#_D6D1: ORA.b $20
#_D6D3: TAY

#_D6D4: LDA.w .parity,Y
#_D6D7: BEQ .positive

#_D6D9: LDA.b $1C
#_D6DB: EOR.b #$FF
#_D6DD: CLC
#_D6DE: ADC.b #$01
#_D6E0: STA.b $1C

.positive
#_D6E2: LDY.b $20

#_D6E4: LDA.w .increase,Y
#_D6E7: CLC
#_D6E8: ADC.b $1C

#_D6EA: RTS

;---------------------------------------------------------------------------------------------------

.increase
#_D6EB: db $0E, $02, $0A, $06

.parity
#_D6EF: db $00, $FF, $FF, $00
#_D6F3: db $FF, $00, $00, $FF

;===================================================================================================

GetAbsoluteDifference:
#_D6F7: SEC
#_D6F8: SBC.b $1C
#_D6FA: BCS .exit

#_D6FC: EOR.b #$FF
#_D6FE: ADC.b #$01
#_D700: CLC

.exit
#_D701: RTS

;===================================================================================================

Divide16by8:
#_D702: LDY.b #$08
#_D704: LDA.b #$00

.divide
#_D706: ASL.b $1F
#_D708: ROL A
#_D709: SEC
#_D70A: SBC.b $1E
#_D70C: BCS .no_borrow

#_D70E: ADC.b $1E
#_D710: CLC

.no_borrow
#_D711: ROL.b $1C

#_D713: DEY
#_D714: BNE .divide

#_D716: LDA.b $1C

#_D718: RTS

;===================================================================================================

HudsonBeeLocations:
#_D719: db $17, $0D ; ROOM 01
#_D71B: db $0D, $11 ; ROOM 02
#_D71D: db $12, $15 ; ROOM 03
#_D71F: db $11, $0D ; ROOM 04
#_D721: db $18, $0E ; ROOM 05
#_D723: db $18, $10 ; ROOM 06
#_D725: db $18, $0C ; ROOM 07
#_D727: db $18, $0D ; ROOM 08
#_D729: db $63, $63 ; ROOM 09
#_D72B: db $63, $14 ; ROOM 0A
#_D72D: db $63, $14 ; ROOM 0B
#_D72F: db $0E, $07 ; ROOM 0C
#_D731: db $13, $0B ; ROOM 0D
#_D733: db $05, $19 ; ROOM 0E
#_D735: db $13, $0A ; ROOM 0F
#_D737: db $1A, $0A ; ROOM 10
#_D739: db $63, $14 ; ROOM 11
#_D73B: db $17, $0E ; ROOM 12
#_D73D: db $06, $10 ; ROOM 13
#_D73F: db $63, $11 ; ROOM 14
#_D741: db $0A, $17 ; ROOM 15
#_D743: db $11, $11 ; ROOM 16
#_D745: db $0F, $04 ; ROOM 17
#_D747: db $17, $0D ; ROOM 18

;===================================================================================================

MusicBoxLocations:
#_D749: db $11, $1A ; ROOM 01
#_D74B: db $05, $03 ; ROOM 02
#_D74D: db $05, $1A ; ROOM 03
#_D74F: db $03, $13 ; ROOM 04
#_D751: db $15, $09 ; ROOM 05
#_D753: db $09, $0A ; ROOM 06
#_D755: db $0A, $19 ; ROOM 07
#_D757: db $04, $18 ; ROOM 08

;===================================================================================================

SpawnSmokePuff:
#_D759: TAY

#_D75A: LDX.b #$03

.check_next
#_D75C: LDA.w $01C0,X
#_D75F: BEQ .found_slot

#_D761: DEX
#_D762: BPL .check_next

#_D764: INX

.found_slot
#_D765: LDA.b #$00
#_D767: STA.w $01C4,X

#_D76A: TYA
#_D76B: STA.w $01C0,X

#_D76E: LDA.b $38
#_D770: STA.w $01C8,X

#_D773: LDA.b $35
#_D775: STA.w $01CC,X

#_D778: RTS

;===================================================================================================

HandleSmokePuffs:
#_D779: LDX.b #$03
#_D77B: STX.b $20

.next_puff
#_D77D: LDX.b $20

#_D77F: LDY.w $01C0,X
#_D782: BNE .theres_a_puff

.to_next_puff
#_D784: DEC.b $20
#_D786: BPL .next_puff

#_D788: RTS

;---------------------------------------------------------------------------------------------------

.theres_a_puff
#_D789: LDA.w $01C8,X
#_D78C: CLC
#_D78D: ADC.b $A8
#_D78F: STA.w $01C8,X
#_D792: STA.b $92

#_D794: LDA.w $01CC,X
#_D797: CLC
#_D798: ADC.b $A7
#_D79A: STA.w $01CC,X
#_D79D: STA.b $93

#_D79F: LDA.w $01C4,X
#_D7A2: STA.b $21

#_D7A4: JSR IsShrineOrBossRoom

#_D7A7: LDY.b #$03 ; palette 3
#_D7A9: BCC .not_shrine_or_boss

#_D7AB: DEY ; palette 2

.not_shrine_or_boss
#_D7AC: STY.b $37
#_D7AE: JSR DrawSmokePuff

#_D7B1: LDX.b $20

#_D7B3: INC.w $01C4,X

#_D7B6: LDA.w $01C0,X
#_D7B9: AND.b #$7F
#_D7BB: TAY

#_D7BC: LDA.w $01C4,X
#_D7BF: CMP.w .smoke_duration-1,Y
#_D7C2: BNE .to_next_puff

#_D7C4: LDA.b #$00
#_D7C6: STA.w $01C0,X
#_D7C9: BEQ .to_next_puff

;---------------------------------------------------------------------------------------------------

.smoke_duration
#_D7CB: db $10, $0C

;===================================================================================================

SmokePuffCoordinateIndicesA:
#_D7CD: db $00, $20

SmokePuffCoordinateIndicesB:
#_D7CF: db $10, $2C

SmokePuffCharacterOffsets:
#_D7D1: db $00, $08

;===================================================================================================

DrawSmokePuff:
#_D7D3: LDA.w $01C0,X
#_D7D6: AND.b #$7F
#_D7D8: TAX

#_D7D9: LDA.w SmokePuffCoordinateIndicesA-1,X
#_D7DC: STA.b $1C

#_D7DE: LDA.w SmokePuffCoordinateIndicesB-1,X
#_D7E1: STA.b $1D

#_D7E3: LDA.w SmokePuffCharacterOffsets-1,X
#_D7E6: STA.b $1E

#_D7E8: LDY.b #$00

;---------------------------------------------------------------------------------------------------

.next_object
#_D7EA: LDX.b $1C

#_D7EC: TYA
#_D7ED: LSR A
#_D7EE: BCS .left_x

#_D7F0: LDX.b $1D

.left_x
#_D7F2: TXA
#_D7F3: CLC
#_D7F4: ADC.b $21
#_D7F6: TAX

#_D7F7: LDA.w .offsets,X
#_D7FA: CLC
#_D7FB: ADC.b $92
#_D7FD: STA.b $38

#_D7FF: LDX.b $1C

#_D801: TYA
#_D802: LSR A
#_D803: LSR A
#_D804: BCS .left_y

#_D806: LDX.b $1D

.left_y
#_D808: TXA
#_D809: CLC
#_D80A: ADC.b $21
#_D80C: TAX

#_D80D: LDA.w .offsets,X
#_D810: CLC
#_D811: ADC.b $93
#_D813: STA.b $35

#_D815: LDA.b $21
#_D817: LSR A
#_D818: CLC
#_D819: ADC.b $1E
#_D81B: TAX

#_D81C: LDA.w .characters,X
#_D81F: JSR AddObjectToBufferSafely

#_D822: INY
#_D823: CPY.b #$04
#_D825: BNE .next_object

#_D827: RTS

;---------------------------------------------------------------------------------------------------

.offsets
#_D828: db $08, $09, $08, $09 ; 00
#_D82C: db $08, $09, $0A, $0B
#_D830: db $0C, $0D, $0E, $0F
#_D834: db $10, $11, $12, $13

#_D838: db $00, $FF, $00, $FF ; 10
#_D83C: db $00, $FF, $FE, $FD
#_D840: db $FC, $FB, $FA, $F9
#_D844: db $F8, $F7, $F6, $F5

#_D848: db $08, $07, $06, $05 ; 20
#_D84C: db $04, $03, $04, $05
#_D850: db $06, $07, $08, $09

#_D854: db $00, $01, $02, $03 ; 2C
#_D858: db $04, $05, $04, $03
#_D85C: db $02, $01, $00, $FF

;---------------------------------------------------------------------------------------------------

.characters
#_D860: db $62, $63 ; 00
#_D862: db $62, $63
#_D864: db $72, $72
#_D866: db $73, $73

#_D868: db $62, $62 ; 08
#_D86A: db $62, $63
#_D86C: db $72, $73

;===================================================================================================

DrawEntireHUD:
#_D86E: LDA.b $B4
#_D870: ORA.w $07CF
#_D873: BNE DrawHealthBar

#_D875: LDA.w $07BF
#_D878: CMP.b #$02
#_D87A: BNE .no_key

#_D87C: LDA.b $8E
#_D87E: AND.b #$0F
#_D880: CMP.b #$08
#_D882: BCC .no_key

#_D884: LDA.b #$02
#_D886: STA.b $37

#_D888: LDX.b #$10
#_D88A: JSR PositionHUDSprite

#_D88D: LDA.b #$19 ; Draw key
#_D88F: JSR AddObjectToBufferSafely

.no_key
#_D892: JSR DrawCashMoney

;===================================================================================================

DrawHealthBar:
#_D895: LDA.b #$66
#_D897: STA.b $35

#_D899: LDA.b #$00
#_D89B: STA.b $37

#_D89D: LDA.b $B2
#_D89F: LSR A
#_D8A0: LSR A
#_D8A1: LSR A
#_D8A2: STA.b $1E

#_D8A4: LDA.b $B3
#_D8A6: LSR A
#_D8A7: LSR A
#_D8A8: LSR A
#_D8A9: STA.b $1F

#_D8AB: LDA.b #$08
#_D8AD: STA.b $1C

;---------------------------------------------------------------------------------------------------

.next
#_D8AF: LDX.b #$10

#_D8B1: LDA.b $B9
#_D8B3: BEQ .indented

#_D8B5: LDX.b #$08

.indented
#_D8B7: STX.b $38

#_D8B9: JSR GetHealthChar
#_D8BC: BEQ .exit

#_D8BE: JSR AddObjectToBufferSafely

#_D8C1: LDA.b $35
#_D8C3: SEC
#_D8C4: SBC.b #$0A
#_D8C6: STA.b $35

#_D8C8: DEC.b $1E
#_D8CA: DEC.b $1F

#_D8CC: DEC.b $1E
#_D8CE: DEC.b $1F

#_D8D0: DEC.b $1C
#_D8D2: BNE .next

.exit
#_D8D4: RTS

;===================================================================================================

GetHealthChar:
#_D8D5: LDX.b $1E
#_D8D7: BMI .missing_hp
#_D8D9: BEQ .missing_hp

#_D8DB: DEX
#_D8DC: BEQ .not_double_filled

.filled_filled
#_D8DE: LDA.b #$11
#_D8E0: RTS

.not_double_filled
#_D8E1: INX
#_D8E2: CPX.b $1F
#_D8E4: BEQ .null_filled

.empty_filled
#_D8E6: LDA.b #$14
#_D8E8: RTS

.null_filled
#_D8E9: LDA.b #$13
#_D8EB: RTS

;---------------------------------------------------------------------------------------------------

.missing_hp
#_D8EC: LDX.b $1F
#_D8EE: DEX
#_D8EF: BEQ .null_empty
#_D8F1: BPL .empty_empty

.null_null
#_D8F3: LDA.b #$00
#_D8F5: RTS

.null_empty
#_D8F6: LDA.b #$12
#_D8F8: RTS

.empty_empty
#_D8F9: LDA.b #$10
#_D8FB: RTS

;===================================================================================================

DrawCashMoney:
#_D8FC: LDA.b #$03
#_D8FE: STA.b $37

#_D900: LDX.b #$0E
#_D902: JSR PositionHUDSprite

#_D905: LDA.b #$17 ; $ character
#_D907: JSR AddObjectToBufferSafely

#_D90A: LDX.b #$00

;===================================================================================================

DrawCurrencySprites:
#_D90C: LDA.b #$00
#_D90E: STA.b $1C

#_D910: LDA.b $A1,X
#_D912: BNE .draw_digit

#_D914: INC.b $1C
#_D916: INX

#_D917: LDA.b $A1,X
#_D919: BNE .draw_digit

#_D91B: INC.b $1C
#_D91D: INX

.draw_digit
#_D91E: LDA.b $A1,X
#_D920: JSR AddObjectToBufferSafely

#_D923: INX
#_D924: INC.b $1C

#_D926: LDA.b $1C
#_D928: CMP.b #$03
#_D92A: BNE .draw_digit

#_D92C: RTS

;===================================================================================================

AddObjectToBufferSafely:
#_D92D: STX.b $76
#_D92F: STY.b $75

#_D931: STA.b $36
#_D933: JSR AddObjectToBuffer

#_D936: LDY.b $75
#_D938: LDX.b $76

#_D93A: RTS

;===================================================================================================

AddCurrency:
#_D93B: LDX.b #$02
#_D93D: STX.b $1C

#_D93F: LDX.w $07CF
#_D942: BNE .notes

#_D944: LDX.b #$02
#_D946: BNE .next_digit

.notes
#_D948: LDX.b #$05

.next_digit
#_D94A: LDY.b #$00
#_D94C: CLC
#_D94D: ADC.b $A1,X

.next_carry
#_D94F: STA.b $A1,X
#_D951: CMP.b #$0A
#_D953: BCC .no_overflow

#_D955: SEC
#_D956: SBC.b #$0A

#_D958: INY
#_D959: BNE .next_carry

.no_overflow
#_D95B: TYA

#_D95C: DEX
#_D95D: DEC.b $1C
#_D95F: BPL .next_digit

#_D961: TAY
#_D962: BEQ .exit

#_D964: LDA.b #$09
#_D966: BNE ClampCurrency

.exit
#_D968: RTS

;===================================================================================================

RemoveCurrency:
#_D969: LDX.b #$02
#_D96B: STX.b $1C

#_D96D: LDX.w $07CF
#_D970: BNE .notes

#_D972: LDX.b #$02
#_D974: BNE .next_digit

.notes
#_D976: LDX.b #$05

.next_digit
#_D978: LDY.b #$00

#_D97A: JSR GetAdditiveInverse
#_D97D: CLC
#_D97E: ADC.b $A1,X

.next_carry
#_D980: STA.b $A1,X

#_D982: CMP.b #$00
#_D984: BPL .no_overflow

#_D986: CLC
#_D987: ADC.b #$0A

#_D989: INY
#_D98A: BNE .next_carry

.no_overflow
#_D98C: TYA

#_D98D: DEX
#_D98E: DEC.b $1C
#_D990: BPL .next_digit

#_D992: TAY
#_D993: BEQ .exit

#_D995: LDA.b #$00

;---------------------------------------------------------------------------------------------------

#ClampCurrency:
#_D997: STA.b $A2,X
#_D999: STA.b $A3,X
#_D99B: STA.b $A4,X

.exit
#_D99D: RTS

;===================================================================================================

HandleTransients:
#_D99E: LDX.b #$03

.next
#_D9A0: LDA.b $83,X
#_D9A2: STA.b $6C

#_D9A4: ASL A
#_D9A5: TAY

#_D9A6: LDA.w .vectors+1,Y
#_D9A9: PHA

#_D9AA: LDA.w .vectors+0,Y
#_D9AD: PHA

#_D9AE: RTS

;---------------------------------------------------------------------------------------------------

#NextTransient:
#_D9AF: DEX
#_D9B0: BPL .next

#_D9B2: RTS

;---------------------------------------------------------------------------------------------------

.vectors
#_D9B3: dw NextTransient-1            ; 00
#_D9B5: dw TransientCollapsingShelf-1 ; 01
#_D9B7: dw TransientTrapdoor-1        ; 02
#_D9B9: dw TransientPushBlock-1       ; 03
#_D9BB: dw TransientPushBlock-1       ; 04 - !UNUSED ?

;===================================================================================================

TransientPushBlock:
#_D9BD: STX.b $76

#_D9BF: TXA
#_D9C0: ASL A
#_D9C1: ASL A
#_D9C2: TAX

#_D9C3: INC.w $07AC,X

#_D9C6: LDA.w $07AC,X
#_D9C9: CMP.b #$01
#_D9CB: BEQ .draw_half_pushed_block

#_D9CD: CMP.b #$08
#_D9CF: BNE .do_nothing

#_D9D1: LDA.w $07A9,X
#_D9D4: STA.b $29

#_D9D6: LDA.w $07AA,X
#_D9D9: STA.b $2A

#_D9DB: LDA.b $6C
#_D9DD: CMP.b #$04 ; ID 04 goes back to where it was instead of moving
#_D9DF: BEQ .unpush_self

#_D9E1: LDA.b #$0F ; OBJECT 0F
#_D9E3: STA.b $2B

#_D9E5: JSR RedrawObject
#_D9E8: JSR ChangeObjectType

#_D9EB: INC.b $29

#_D9ED: LDA.b #$00 ; OBJECT 00

.finish_up
#_D9EF: STA.b $2B

#_D9F1: JMP TransientFinished

;---------------------------------------------------------------------------------------------------

.unpush_self
#_D9F4: LDA.b #$00 ; OBJECT 00
#_D9F6: STA.b $2B

#_D9F8: JSR RedrawObject
#_D9FB: JSR ChangeObjectType

#_D9FE: INC.b $29

#_DA00: LDA.b #$0F
#_DA02: BNE .finish_up

;---------------------------------------------------------------------------------------------------

.draw_half_pushed_block
#_DA04: LDA.w $07A9,X
#_DA07: STA.b $29

#_DA09: LDA.w $07AA,X
#_DA0C: STA.b $2A

#_DA0E: LDA.b #$23 ; OBJECT 23
#_DA10: STA.b $2B

#_DA12: JSR RedrawObject

#_DA15: INC.b $29
#_DA17: INC.b $2B ; OBJECT 24

#_DA19: JSR RedrawObject

.do_nothing
#_DA1C: LDX.b $76
#_DA1E: JMP NextTransient

;===================================================================================================

TransientTrapdoor:
#_DA21: JSR TickTransientTimer
#_DA24: CMP.b #$09
#_DA26: BCC .do_nothing

#_DA28: JSR GetTransientXY

#_DA2B: LDA.b #$17 ; OBJECT 17
#_DA2D: STA.b $2B

#_DA2F: BNE TransientFinished

;===================================================================================================

#TransientCollapsingShelf:
#_DA31: JSR TickTransientTimer
#_DA34: AND.b #$03
#_DA36: BNE .do_nothing

#_DA38: JSR GetTransientXY

#_DA3B: INC.w $07AB,X

#_DA3E: LDA.w $07AB,X
#_DA41: CMP.b #$23 ; OBJECT 23
#_DA43: BEQ .finished

#_DA45: STA.b $2B
#_DA47: JSR RedrawObject

.do_nothing
#_DA4A: LDX.b $76
#_DA4C: JMP NextTransient

.finished
#_DA4F: LDA.b #$00 ; OBJECT 00
#_DA51: STA.b $2B

;===================================================================================================

TransientFinished:
#_DA53: JSR ChangeObjectType
#_DA56: JSR RedrawObject

#_DA59: LDX.b $76

#_DA5B: LDA.b #$00
#_DA5D: STA.b $83,X

#_DA5F: JMP NextTransient

;===================================================================================================

TickTransientTimer:
#_DA62: STX.b $76

#_DA64: TXA
#_DA65: ASL A
#_DA66: ASL A
#_DA67: TAX

#_DA68: INC.w $07AC,X

#_DA6B: LDA.w $07AC,X

#_DA6E: RTS

;===================================================================================================

GetTransientXY:
#_DA6F: LDA.w $07A9,X
#_DA72: STA.b $29

#_DA74: LDA.w $07AA,X
#_DA77: STA.b $2A

#_DA79: RTS

;===================================================================================================

HandleMovingPits:
#_DA7A: INC.b $88

#_DA7C: LDA.b $88
#_DA7E: AND.b #$07
#_DA80: STA.b $1C

#_DA82: ASL A
#_DA83: ASL A
#_DA84: CLC
#_DA85: ADC.b $1C
#_DA87: TAX

#_DA88: LDA.w $0198,X
#_DA8B: BMI .exit

#_DA8D: LDA.w $0199,X
#_DA90: SEC
#_DA91: SBC.b #$01
#_DA93: CMP.b $16
#_DA95: BCC .exit

#_DA97: LDA.b $16
#_DA99: CLC
#_DA9A: ADC.b #$0E
#_DA9C: CMP.w $0199,X
#_DA9F: BCC .exit

#_DAA1: JSR DrawMovingPit

#_DAA4: JMP MovingPitMovement

.exit
#_DAA7: RTS

;===================================================================================================

DrawMovingPit:
#_DAA8: LDA.w $019A,X
#_DAAB: BEQ .moving_left

#_DAAD: LDA.w $0199,X
#_DAB0: STA.b $2A

#_DAB2: LDA.w $0198,X
#_DAB5: LSR A
#_DAB6: STA.b $29
#_DAB8: BCS .half_x

#_DABA: LDA.w $019B,X
#_DABD: BEQ .newly_moving

#_DABF: DEC.b $29

#_DAC1: LDA.b #$12 ; OBJECT 12
#_DAC3: JSR DrawMovingPitSegment

#_DAC6: INC.b $29

.newly_moving
#_DAC8: LDA.b #$14 ; OBJECT 14
#_DACA: JSR DrawMovingPitSegment

#_DACD: INC.b $29
#_DACF: JMP DrawMovingPitSegment_reuse_last

;---------------------------------------------------------------------------------------------------

.half_x
#_DAD2: LDA.b #$13 ; OBJECT 13
#_DAD4: JSR DrawMovingPitSegment

#_DAD7: INC.b $29
#_DAD9: LDA.b #$14 ; OBJECT 14
#_DADB: JSR DrawMovingPitSegment

#_DADE: INC.b $29
#_DAE0: LDA.b #$15 ; OBJECT 15
#_DAE2: JMP DrawMovingPitSegment

;---------------------------------------------------------------------------------------------------

.moving_left
#_DAE5: LDA.w $0199,X
#_DAE8: STA.b $2A

#_DAEA: LDA.w $0198,X
#_DAED: LSR A
#_DAEE: STA.b $29
#_DAF0: BCS .half_x

#_DAF2: LDA.b #$14 ; OBJECT 14
#_DAF4: JSR DrawMovingPitSegment

#_DAF7: INC.b $29
#_DAF9: JSR DrawMovingPitSegment_reuse_last

#_DAFC: INC.b $29

#_DAFE: LDA.w $019B,X
#_DB01: BEQ EXIT_DB1D

#_DB03: LDA.b #$12 ; OBJECT 12
#_DB05: JMP DrawMovingPitSegment

;===================================================================================================

MovingPitMovement:
#_DB08: LDA.w $019B,X
#_DB0B: CMP.w $019C,X
#_DB0E: BCC .not_at_target

#_DB10: LDA.w $019A,X
#_DB13: EOR.b #$01
#_DB15: STA.w $019A,X

#_DB18: LDA.b #$00
#_DB1A: STA.w $019B,X

;---------------------------------------------------------------------------------------------------

#EXIT_DB1D:
#_DB1D: RTS

;---------------------------------------------------------------------------------------------------

.not_at_target
#_DB1E: LDA.w $019A,X
#_DB21: BEQ .going_left

.going_right
#_DB23: INC.w $0198,X
#_DB26: BNE .finished

.going_left
#_DB28: DEC.w $0198,X

.finished
#_DB2B: INC.w $019B,X

#_DB2E: RTS

;===================================================================================================

DrawMovingPitSegment:
#_DB2F: STA.b $2B

;===================================================================================================

DrawMovingPitSegment_reuse_last:
#_DB31: STX.b $76

#_DB33: JSR ChangeTileForPit
#_DB36: JSR ChangeObjectType

#_DB39: LDX.b $76

#_DB3B: RTS

;===================================================================================================

ChangeTileForPit:
#_DB3C: LDA.b $29
#_DB3E: ASL A
#_DB3F: AND.b #$1F
#_DB41: STA.b $1C

#_DB43: LDA.b $29
#_DB45: AND.b #$10
#_DB47: LSR A
#_DB48: LSR A
#_DB49: STA.b $0B

#_DB4B: LDA.b $2A
#_DB4D: SEC

.clamp
#_DB4E: SBC.b #$0F
#_DB50: BCS .clamp

#_DB52: ADC.b #$0F
#_DB54: ASL A
#_DB55: STA.b $1D

#_DB57: LDA.b #$01
#_DB59: STA.b $0D

#_DB5B: LDA.b $1D
#_DB5D: ASL A
#_DB5E: ROL.b $0D
#_DB60: ASL A
#_DB61: ROL.b $0D
#_DB63: ASL A
#_DB64: ROL.b $0D
#_DB66: ASL A
#_DB67: ROL.b $0D
#_DB69: ASL A
#_DB6A: ROL.b $0D
#_DB6C: CLC
#_DB6D: ADC.b $1C
#_DB6F: STA.b $0C

#_DB71: BCC .no_overflow_a

#_DB73: INC.b $0D

.no_overflow_a
#_DB75: LDA.b $0D
#_DB77: ORA.b $0B
#_DB79: STA.b $0D

#_DB7B: LDX.b $19
#_DB7D: LDA.b #$05 ; VXFR 05
#_DB7F: JSR AddToVRAMBuffer

#_DB82: LDA.b $0C
#_DB84: JSR AddToVRAMBuffer

#_DB87: LDA.b $0D
#_DB89: JSR AddToVRAMBuffer

;---------------------------------------------------------------------------------------------------

#_DB8C: LDA.b #$00
#_DB8E: STA.b $1D

#_DB90: LDY.b $2B

#_DB92: LDA.b ($5A),Y
#_DB94: ASL A
#_DB95: ROL.b $1D
#_DB97: ASL A
#_DB98: ROL.b $1D
#_DB9A: ADC.b #ObjectTileNames>>0
#_DB9C: STA.b $1C

#_DB9E: LDA.b #ObjectTileNames>>8
#_DBA0: ADC.b $1D
#_DBA2: STA.b $1D

#_DBA4: LDY.b #$00
#_DBA6: LDA.b ($1C),Y
#_DBA8: JSR AddToVRAMBuffer

#_DBAB: INY
#_DBAC: LDA.b ($1C),Y
#_DBAE: JSR AddToVRAMBuffer

#_DBB1: INY
#_DBB2: LDA.b $0C
#_DBB4: CLC
#_DBB5: ADC.b #$20
#_DBB7: STA.b $0C
#_DBB9: BNE .no_overflow_b

#_DBBB: INC.b $0D

.no_overflow_b
#_DBBD: LDA.b $0C
#_DBBF: JSR AddToVRAMBuffer

#_DBC2: LDA.b $0D
#_DBC4: JSR AddToVRAMBuffer

#_DBC7: LDA.b ($1C),Y
#_DBC9: JSR AddToVRAMBuffer

#_DBCC: INY
#_DBCD: LDA.b ($1C),Y
#_DBCF: JSR AddToVRAMBuffer

#_DBD2: JMP FinishedVRAMBuffer

;===================================================================================================

DrawOverworldTilemap:
#_DBD5: JSR LoadOverworldTilemap

#_DBD8: LDA.b #$00
#_DBDA: STA.b $0B
#_DBDC: STA.b $27

#_DBDE: JSR .draw_half

#_DBE1: LDA.b #$04
#_DBE3: STA.b $0B
#_DBE5: LDA.b #$10
#_DBE7: STA.b $27

#_DBE9: JSR .draw_half

#_DBEC: LDA.b #$00
#_DBEE: STA.b $27
#_DBF0: STA.b $0B

#_DBF2: JSR ReloadDefaultSpritePalettes

#_DBF5: LDA.b #$01
#_DBF7: STA.w $07BB

#_DBFA: RTS

;===================================================================================================

.draw_half
#_DBFB: LDA.b #$0F
#_DBFD: STA.b $25

.next_row
#_DBFF: LDA.b #$00
#_DC01: STA.b $26

.next_object
#_DC03: JSR .draw_object

#_DC06: INC.b $26

#_DC08: LDA.b $26
#_DC0A: CMP.b #$0F
#_DC0C: BNE .next_object

#_DC0E: DEC.b $25
#_DC10: BPL .next_row

#_DC12: RTS

;===================================================================================================

.draw_object
#_DC13: LDA.b $26
#_DC15: CLC
#_DC16: ADC.b $28
#_DC18: STA.b $2A

#_DC1A: LDA.b $25
#_DC1C: CLC
#_DC1D: ADC.b $27
#_DC1F: STA.b $29

#_DC21: JSR GetObjectType_overworld

#_DC24: LDA.b $2A
#_DC26: CMP.b #$0F
#_DC28: BCC .no_wrap

#_DC2A: SEC
#_DC2B: SBC.b #$0F

.no_wrap
#_DC2D: STA.b $2A

#_DC2F: LDA.b $25
#_DC31: STA.b $29

;===================================================================================================

DrawOverworldTileToXY:
#_DC33: LDA.b $29
#_DC35: ASL A
#_DC36: STA.b $2E

#_DC38: LDA.b $2A
#_DC3A: ASL A
#_DC3B: STA.b $2F

#_DC3D: JSR GetOverworldObjectPalette
#_DC40: STA.b $12

#_DC42: JSR GetVRAMofTileFromXY
#_DC45: JSR GetOverworldObjectTilesPointer

#_DC48: LDY.b #$00
#_DC4A: JMP DrawOverworldTileToVRAM

;===================================================================================================

GetObjectType_overworld:
#_DC4D: LDA.b #$00
#_DC4F: STA.b $1D

#_DC51: LDA.b $2A
#_DC53: ASL A
#_DC54: ASL A
#_DC55: ASL A
#_DC56: ASL A
#_DC57: ROL.b $1D
#_DC59: STA.b $1C

#_DC5B: CLC
#_DC5C: ADC.b #$0400>>0
#_DC5E: STA.b $1C

#_DC60: LDA.b $1D
#_DC62: ADC.b #$0400>>8
#_DC64: STA.b $1D

#_DC66: LDA.b $29
#_DC68: LSR A
#_DC69: TAY

#_DC6A: LDA.b ($1C),Y
#_DC6C: BCS .low_nibble

#_DC6E: LSR A
#_DC6F: LSR A
#_DC70: LSR A
#_DC71: LSR A

.low_nibble
#_DC72: AND.b #$0F
#_DC74: STA.b $2B

#_DC76: LDA.b #$0120>>0
#_DC78: STA.b $1C

#_DC7A: LDA.b #$0120>>8
#_DC7C: STA.b $1D

#_DC7E: JSR ReadOverworldTileHighBit

#_DC81: LSR A
#_DC82: LSR A
#_DC83: LSR A
#_DC84: ORA.b $2B
#_DC86: STA.b $2B

#_DC88: LDA.b #$0648>>0
#_DC8A: STA.b $1C
#_DC8C: LDA.b #$0648>>8
#_DC8E: STA.b $1D

#_DC90: JSR ReadOverworldTileHighBit
#_DC93: LSR A
#_DC94: LSR A
#_DC95: ORA.b $2B
#_DC97: STA.b $2B

#_DC99: RTS

;===================================================================================================

ReadOverworldTileHighBit:
#_DC9A: LDA.b $29
#_DC9C: AND.b #$07
#_DC9E: TAX
#_DC9F: INX

#_DCA0: LDA.b $2A
#_DCA2: ASL A
#_DCA3: ASL A
#_DCA4: CLC
#_DCA5: ADC.b $1C
#_DCA7: STA.b $1E

#_DCA9: LDA.b #$00
#_DCAB: ADC.b $1D
#_DCAD: STA.b $1F

#_DCAF: LDA.b $29
#_DCB1: LSR A
#_DCB2: LSR A
#_DCB3: LSR A
#_DCB4: TAY

#_DCB5: LDA.b ($1E),Y
#_DCB7: LSR A

.roll
#_DCB8: ROL A

#_DCB9: DEX
#_DCBA: BNE .roll

#_DCBC: AND.b #$80

#_DCBE: RTS

;===================================================================================================

UpdateOverworldObjectGraphics:
#_DCBF: JSR GetOverworldObjectPalette
#_DCC2: JSR QueueObjectPaletteChange
#_DCC5: JSR GetOverworldObjectTilesPointer

#_DCC8: LDY.b #$00
#_DCCA: JMP QueueOverworldObjectUpdate

;===================================================================================================

GetOverworldObjectPalette:
#_DCCD: LDA.b $2B
#_DCCF: AND.b #$03
#_DCD1: TAX

#_DCD2: LDA.b $2B
#_DCD4: LSR A
#_DCD5: LSR A
#_DCD6: TAY

#_DCD7: LDA.w OverworldCastleObjectPalettes,Y

.roll
#_DCDA: DEX
#_DCDB: BMI .done_rolling

#_DCDD: LSR A
#_DCDE: LSR A
#_DCDF: JMP .roll

.done_rolling
#_DCE2: AND.b #$03

#_DCE4: RTS

;===================================================================================================

GetOverworldObjectTilesPointer:
#_DCE5: LDA.b #$00
#_DCE7: STA.b $5B

#_DCE9: LDA.b $2B
#_DCEB: ASL A
#_DCEC: ASL A
#_DCED: ROL.b $5B
#_DCEF: ADC.b #OverworldObjectTiles>>0
#_DCF1: STA.b $5A

#_DCF3: LDA.b $5B
#_DCF5: ADC.b #OverworldObjectTiles>>8
#_DCF7: STA.b $5B

#_DCF9: RTS

;===================================================================================================

LoadOverworldTilemap:
#_DCFA: LDA.b $94
#_DCFC: PHA

#_DCFD: LDA.b #$02 ; GFXBANK 03
#_DCFF: STA.b $94

#_DD01: JSR RefreshGFXBank

#_DD04: LDA.b #OverworldTilemap>>8 ; VRAM $1800
#_DD06: LDX.b #OverworldTilemap>>0
#_DD08: JSR SetPPUADDRSafely

#_DD0B: LDA.w PPUDATA
#_DD0E: LDX.b #$00

.read_out_tilemap_a
#_DD10: LDA.w PPUDATA
#_DD13: STA.w $0400,X

#_DD16: INX
#_DD17: BNE .read_out_tilemap_a

.read_out_tilemap_b
#_DD19: LDA.w PPUDATA
#_DD1C: STA.w $0500,X

#_DD1F: INX
#_DD20: CPX.b #$E0
#_DD22: BNE .read_out_tilemap_b

#_DD24: LDX.b #$00

.get_tilemap_high_bits
#_DD26: LDA.w PPUDATA
#_DD29: STA.w $0120,X

#_DD2C: INX
#_DD2D: CPX.b #$78
#_DD2F: BNE .get_tilemap_high_bits

; seems that the overworld has more tiles, and puts more high bits here
#_DD31: LDX.b #$00

.get_highest_bits
#_DD33: LDA.w PPUDATA
#_DD36: STA.w $0648,X

#_DD39: INX
#_DD3A: CPX.b #$78
#_DD3C: BNE .get_highest_bits

#_DD3E: PLA
#_DD3F: STA.b $94

#_DD41: RTS

;===================================================================================================

PanTilemap_overworld:
#_DD42: LDA.b $14
#_DD44: CMP.b $07
#_DD46: BEQ .exit

#_DD48: STA.b $07

#_DD4A: JSR PanObjectAttributes_overworld

#_DD4D: LDA.b $07
#_DD4F: AND.b #$07
#_DD51: ASL A
#_DD52: ORA.b $13
#_DD54: CMP.b #$06
#_DD56: BEQ PanObjectCharacters_overworld

#_DD58: CMP.b #$0B
#_DD5A: BEQ PanObjectCharacters_overworld

.exit
#_DD5C: RTS

;===================================================================================================

PanObjectCharacters_overworld:
#_DD5D: JSR GetObjectsInNewRow_overworld
#_DD60: JSR GetNewRowTilemapAddress

#_DD63: LDX.b #$00

#_DD65: LDA.b $14
#_DD67: AND.b #$0F
#_DD69: CMP.b #$08
#_DD6B: BCC .top_half

#_DD6D: LDX.b #$02

.top_half
#_DD6F: STX.b $15

;---------------------------------------------------------------------------------------------------

#_DD71: LDX.b $19
#_DD73: LDA.b #$01 ; VXFR 01
#_DD75: JSR AddToVRAMBuffer

#_DD78: LDA.b $1F
#_DD7A: JSR AddToVRAMBuffer

#_DD7D: LDA.b $1E
#_DD7F: JSR AddToVRAMBuffer

#_DD82: LDY.b #$00

.next_left
#_DD84: JSR AddObjectTileToRow_overworld

#_DD87: INY
#_DD88: CPY.b #$10
#_DD8A: BNE .next_left

;---------------------------------------------------------------------------------------------------

#_DD8C: LDA.b #$01 ; VXFR 01
#_DD8E: JSR AddToVRAMBuffer

#_DD91: LDA.b $1F
#_DD93: JSR AddToVRAMBuffer

#_DD96: LDA.b $1E
#_DD98: ORA.b #$04
#_DD9A: JSR AddToVRAMBuffer

.next_right
#_DD9D: JSR AddObjectTileToRow_overworld

#_DDA0: INY
#_DDA1: CPY.b #$20
#_DDA3: BNE .next_right

;===================================================================================================

FinishedVRAMBuffer:
#_DDA5: LDA.b #$00
#_DDA7: STA.w $0200,X

#_DDAA: STX.b $19

#_DDAC: RTS

;===================================================================================================

AddObjectTileToRow_overworld:
#_DDAD: STY.b $75

#_DDAF: LDA.b #$00
#_DDB1: STA.b $1D

#_DDB3: LDA.w $06D0,Y
#_DDB6: ASL A
#_DDB7: ROL.b $1D
#_DDB9: ASL A
#_DDBA: ROL.b $1D
#_DDBC: CLC
#_DDBD: ADC.b #OverworldObjectTiles>>0
#_DDBF: STA.b $1C

#_DDC1: LDA.b $1D
#_DDC3: ADC.b #OverworldObjectTiles>>8
#_DDC5: STA.b $1D

#_DDC7: LDY.b $15
#_DDC9: LDA.b ($1C),Y
#_DDCB: JSR AddToVRAMBuffer

#_DDCE: INY
#_DDCF: LDA.b ($1C),Y
#_DDD1: JSR AddToVRAMBuffer

#_DDD4: LDY.b $75

#_DDD6: RTS

;===================================================================================================

PanObjectAttributes_overworld:
#_DDD7: LDA.b $14
#_DDD9: AND.b #$0F
#_DDDB: ASL A
#_DDDC: ORA.b $13
#_DDDE: CMP.b #$13
#_DDE0: BEQ .continue

#_DDE2: CMP.b #$0E
#_DDE4: BEQ .continue

#_DDE6: RTS

;---------------------------------------------------------------------------------------------------

.continue
#_DDE7: JSR GetObjectsInNewRow_overworld
#_DDEA: JSR GetNewRowAttributeAddress

#_DDED: LDA.b $14
#_DDEF: AND.b #$10
#_DDF1: STA.b $15
#_DDF3: BEQ .bottom_mask

#_DDF5: LDY.b #$0F
#_DDF7: BNE .set_mask

.bottom_mask
#_DDF9: LDY.b #$F0

.set_mask
#_DDFB: STY.b $75

#_DDFD: LDX.b $19

#_DDFF: LDA.b #$02 ; VXFR 02
#_DE01: JSR AddToVRAMBuffer

#_DE04: LDA.b $1E
#_DE06: JSR AddToVRAMBuffer

#_DE09: LDA.b #$23C0>>8 ; VRAM $23C0
#_DE0B: JSR AddToVRAMBuffer

#_DE0E: LDA.b $75
#_DE10: JSR AddToVRAMBuffer

;---------------------------------------------------------------------------------------------------

#_DE13: LDY.b #$00

.next_left
#_DE15: JSR GetRowObjectPalette_overworld

#_DE18: LDA.b $1F
#_DE1A: JSR AddToVRAMBuffer

#_DE1D: CPY.b #$10
#_DE1F: BNE .next_left

;---------------------------------------------------------------------------------------------------

#_DE21: LDA.b #$02 ; VXFR 02
#_DE23: JSR AddToVRAMBuffer

#_DE26: LDA.b $1E
#_DE28: JSR AddToVRAMBuffer

#_DE2B: LDA.b #$27C0>>8 ; VRAM $27C0
#_DE2D: JSR AddToVRAMBuffer

#_DE30: LDA.b $75
#_DE32: JSR AddToVRAMBuffer

;---------------------------------------------------------------------------------------------------

.next_right
#_DE35: JSR GetRowObjectPalette_overworld

#_DE38: LDA.b $1F
#_DE3A: JSR AddToVRAMBuffer

#_DE3D: CPY.b #$20
#_DE3F: BNE .next_right

#_DE41: JMP FinishedVRAMBuffer

;===================================================================================================

GetObjectsInNewRow_overworld:
#_DE44: LDA.b $13
#_DE46: BEQ .panning_up

#_DE48: LDA.b $16
#_DE4A: CLC
#_DE4B: ADC.b #$0F
#_DE4D: BNE .panning_down

.panning_up
#_DE4F: LDA.b $16

.panning_down
#_DE51: STA.b $2A

;---------------------------------------------------------------------------------------------------

#_DE53: LDA.b #$00
#_DE55: STA.b $29

.next
#_DE57: JSR GetObjectType_overworld

#_DE5A: LDY.b $29

#_DE5C: STA.w $06D0,Y

#_DE5F: INY
#_DE60: STY.b $29
#_DE62: CPY.b #$20
#_DE64: BNE .next

#_DE66: RTS

;===================================================================================================

GetRowObjectPalette_overworld:
#_DE67: STX.b $76

#_DE69: TYA
#_DE6A: TAX

#_DE6B: LDA.b #$00
#_DE6D: STA.b $1F

#_DE6F: LDY.w $06D0,X
#_DE72: INX
#_DE73: STX.b $20
#_DE75: STY.b $2B

#_DE77: JSR GetOverworldObjectPalette

#_DE7A: LDX.b $20
#_DE7C: LSR A
#_DE7D: ROR.b $1F
#_DE7F: LSR A
#_DE80: ROR.b $1F

#_DE82: LDY.w $06D0,X

#_DE85: INX
#_DE86: STX.b $20
#_DE88: STY.b $2B
#_DE8A: JSR GetOverworldObjectPalette

#_DE8D: LDX.b $20
#_DE8F: LSR A
#_DE90: ROR.b $1F
#_DE92: LSR A
#_DE93: ROR.b $1F
#_DE95: LDA.b $15
#_DE97: BNE .low_nibble

#_DE99: LSR.b $1F
#_DE9B: LSR.b $1F
#_DE9D: LSR.b $1F
#_DE9F: LSR.b $1F

.low_nibble
#_DEA1: TXA
#_DEA2: TAY

#_DEA3: LDX.b $76

#_DEA5: RTS

;===================================================================================================

RoomDataPointerIndex:
#_DEA6: db $00 ; ROOM 00
#_DEA7: db $01 ; ROOM 01
#_DEA8: db $02 ; ROOM 02
#_DEA9: db $FF ; ROOM 03
#_DEAA: db $03 ; ROOM 04
#_DEAB: db $04 ; ROOM 05
#_DEAC: db $05 ; ROOM 06
#_DEAD: db $07 ; ROOM 07
#_DEAE: db $06 ; ROOM 08
#_DEAF: db $08 ; ROOM 09
#_DEB0: db $09 ; ROOM 0A
#_DEB1: db $0A ; ROOM 0B
#_DEB2: db $0B ; ROOM 0C
#_DEB3: db $0C ; ROOM 0D
#_DEB4: db $0D ; ROOM 0E
#_DEB5: db $0E ; ROOM 0F
#_DEB6: db $0D ; ROOM 10
#_DEB7: db $10 ; ROOM 11
#_DEB8: db $0A ; ROOM 12
#_DEB9: db $09 ; ROOM 13
#_DEBA: db $09 ; ROOM 14
#_DEBB: db $08 ; ROOM 15
#_DEBC: db $08 ; ROOM 16
#_DEBD: db $08 ; ROOM 17
#_DEBE: db $08 ; ROOM 18

;===================================================================================================

DoorALocations:
#_DEBF: db $1D, $04 ; ROOM 01
#_DEC1: db $01, $01 ; ROOM 02
#_DEC3: db $63, $63 ; ROOM 03
#_DEC5: db $16, $0F ; ROOM 04
#_DEC7: db $1D, $10 ; ROOM 05
#_DEC9: db $04, $02 ; ROOM 06
#_DECB: db $03, $01 ; ROOM 07
#_DECD: db $0C, $02 ; ROOM 08
#_DECF: db $63, $63 ; ROOM 09

DoorBLocations:
#_DED1: db $16, $1B ; ROOM 01
#_DED3: db $0E, $06 ; ROOM 02
#_DED5: db $63, $63 ; ROOM 03
#_DED7: db $01, $03 ; ROOM 04
#_DED9: db $0E, $06 ; ROOM 05
#_DEDB: db $63, $63 ; ROOM 06
#_DEDD: db $10, $02 ; ROOM 07
#_DEDF: db $19, $07 ; ROOM 08
#_DEE1: db $13, $11 ; ROOM 09

;===================================================================================================
;---------------------------------------------------------------------------------------------------
;===================================================================================================
; Room data formatted as:
;
;  byte 1      byte 2
; rrfx xxxx   mmmy yyyy
;  rm - room id (...rrmmm)
;  f  - transition type flag
;  x  - x tilemap coordinate
;  y  - y tilemap coordinate
;===================================================================================================
;---------------------------------------------------------------------------------------------------
;===================================================================================================
; db <X>, <Y>, <A1>, <A2>
;    X - ..sx xxxx
;          s - is shop
;          x - x tilemap coordinate
;    Y - y tilemap coordinate
;    A - room entry data
;    b - boss flag in A1.f (bit 5)
;===================================================================================================
; TODO verify data understanding
EntranceData:
;                               sb | OW xy   => Entrance    x,y
#_DEE3: db $05, $08, $87, $40 ; .. | {05,08} => ROOM 0A : {07,00}
#_DEE7: db $05, $10, $11, $17 ; .. | {05,10} => ROOM 00 : {11,17}
#_DEEB: db $05, $1C, $40, $1B ; .. | {05,1C} => ROOM 01 : {00,1B}
#_DEEF: db $09, $0D, $80, $2C ; .. | {09,0D} => ROOM 06 : {00,0C}
#_DEF3: db $09, $08, $41, $03 ; .. | {09,08} => ROOM 01 : {01,03}
#_DEF7: db $0B, $14, $80, $0D ; .. | {0B,14} => ROOM 02 : {00,0D}
#_DEFB: db $12, $04, $12, $04 ; .. | {12,04} => ROOM 00 : {12,04}
#_DEFF: db $12, $08, $C0, $2F ; .. | {12,08} => ROOM 07 : {00,0F}
#_DF03: db $15, $0B, $11, $17 ; .. | {15,0B} => ROOM 00 : {11,17}
#_DF07: db $15, $14, $00, $2D ; .. | {15,14} => ROOM 04 : {00,0D}
#_DF0B: db $0D, $08, $30, $04 ; .b | {0D,08} => ROOM 00 : {10,04}
#_DF0F: db $1A, $17, $2A, $0B ; .b | {1A,17} => ROOM 00 : {0A,0B}
#_DF13: db $15, $1B, $30, $14 ; .b | {15,1B} => ROOM 00 : {10,14}
#_DF17: db $16, $0D, $00, $4C ; .. | {16,0D} => ROOM 08 : {00,0C}
#_DF1B: db $18, $1C, $40, $3B ; .. | {18,1C} => ROOM 05 : {00,1B}
#_DF1F: db $1B, $08, $C7, $40 ; .. | {1B,08} => ROOM 0B : {07,00}
#_DF23: db $1B, $10, $1A, $17 ; .. | {1B,10} => ROOM 00 : {1A,17}
#_DF27: db $1D, $1B, $87, $60 ; .. | {1D,1B} => ROOM 0E : {07,00}
#_DF2B: db $2D, $1A, $0D, $1A ; s. | {0D,1A} => ROOM 00 : {0D,1A}
#_DF2F: db $31, $0D, $11, $0D ; s. | {11,0D} => ROOM 00 : {11,0D}
#_DF33: db $30, $1C, $10, $1C ; s. | {10,1C} => ROOM 00 : {10,1C}
#_DF37: db $FF ; end

;===================================================================================================

SpecialExits:
#_DF38: db $10, $04 ; . | ROOM 00 : {10,04} - Floor 4 west
#_DF3A: db $01, $60 ; . | ROOM 0C : {01,00} - Shrine left
#_DF3C: db $5E, $60 ; . | ROOM 0D : {1E,00} - Shrine right
#_DF3E: db $01, $DB ; . | ROOM 18 : {01,1B} - Maharito

;===================================================================================================

BossExits:
#_DF40: db $15, $1B ; . | ROOM 00 : {15,1B}
#_DF42: db $C2, $7B ; . | ROOM 0F : {02,1B}
#_DF44: db $1A, $17 ; . | ROOM 00 : {1A,17}
#_DF46: db $05, $14 ; . | ROOM 00 : {05,14}
#_DF48: db $09, $1B ; . | ROOM 00 : {09,1B}
#_DF4A: db $1B, $10 ; . | ROOM 00 : {1B,10}
#_DF4C: db $0D, $08 ; b | ROOM 00 : {0D,08}

;===================================================================================================
; FREE ROM: 0x01
;---------------------------------------------------------------------------------------------------
; This was probably meant as a sentinel, but this table's code isn't written that way.
;===================================================================================================
NULL_DF4E:
#_DF4E: db $FF

;===================================================================================================
; Two sets of bytes per transition:
; db <A1>, <A2>, <Z1>, <Z2>
;    A - entrance room
;    Z - exit room
;
; flags:
;  sb
;   s - A1.f - shop (priority)
;   b - Z1.f - boss fight
;      00 - exit to overworld
;      01 - boss fight
;      10 - shop
;      11 - shop
;===================================================================================================
PuzzleRoomTransitions:
;                               sb | Entrance    x,y   | Exit        x,y
#_DF4F: db $5D, $04, $05, $1C ; .. | ROOM 01 : {1D,04} | ROOM 00 : {05,1C}
#_DF53: db $76, $1B, $56, $1A ; s. | ROOM 01 : {16,1B} | ROOM 01 : {16,1A}
#_DF57: db $69, $04, $05, $1C ; s. | ROOM 01 : {09,04} | ROOM 00 : {05,1C}
#_DF5B: db $81, $01, $0B, $14 ; .. | ROOM 02 : {01,01} | ROOM 00 : {0B,14}
#_DF5F: db $AE, $06, $8E, $05 ; s. | ROOM 02 : {0E,06} | ROOM 02 : {0E,05}
#_DF63: db $DB, $06, $10, $1C ; .. | ROOM 03 : {1B,06} | ROOM 00 : {10,1C}
#_DF67: db $16, $2F, $15, $14 ; .. | ROOM 04 : {16,0F} | ROOM 00 : {15,14}
#_DF6B: db $3F, $3B, $1E, $38 ; s. | ROOM 04 : {1F,1B} | ROOM 04 : {1E,18}
#_DF6F: db $21, $23, $02, $23 ; s. | ROOM 04 : {01,03} | ROOM 04 : {02,03}
#_DF73: db $6E, $26, $4E, $25 ; s. | ROOM 05 : {0E,06} | ROOM 05 : {0E,05}
#_DF77: db $5D, $30, $18, $1C ; .. | ROOM 05 : {1D,10} | ROOM 00 : {18,1C}
#_DF7B: db $84, $22, $09, $0D ; .. | ROOM 06 : {04,02} | ROOM 00 : {09,0D}
#_DF7F: db $BD, $20, $9D, $22 ; s. | ROOM 06 : {1D,00} | ROOM 06 : {1D,02}
#_DF83: db $0C, $42, $16, $0D ; .. | ROOM 08 : {0C,02} | ROOM 00 : {16,0D}
#_DF87: db $1D, $5D, $7E, $60 ; .b | ROOM 08 : {1D,1D} | ROOM 0D : {1E,00}
#_DF8B: db $39, $47, $19, $4A ; s. | ROOM 08 : {19,07} | ROOM 08 : {19,0A}
#_DF8F: db $C3, $21, $12, $08 ; .. | ROOM 07 : {03,01} | ROOM 00 : {12,08}
#_DF93: db $F0, $22, $D0, $22 ; s. | ROOM 07 : {10,02} | ROOM 07 : {10,02}

;---------------------------------------------------------------------------------------------------

GauntletRoomTransitions:
;                               sb | Entrance    x,y   | Exit        x,y
#_DF97: db $9F, $49, $C0, $88 ; .. | ROOM 0A : {1F,09} | ROOM 13 : {00,08}
#_DF9B: db $C0, $88, $9F, $48 ; .. | ROOM 13 : {00,08} | ROOM 0A : {1F,08}
#_DF9F: db $DF, $92, $00, $B1 ; .. | ROOM 13 : {1F,12} | ROOM 14 : {00,11}
#_DFA3: db $00, $B1, $DF, $92 ; .. | ROOM 14 : {00,11} | ROOM 13 : {1F,12}
#_DFA7: db $1F, $BB, $80, $43 ; .. | ROOM 14 : {1F,1B} | ROOM 0A : {00,03}
#_DFAB: db $80, $43, $1F, $BB ; .. | ROOM 0A : {00,03} | ROOM 14 : {1F,1B}
#_DFAF: db $9F, $4D, $C0, $8D ; .. | ROOM 0A : {1F,0D} | ROOM 13 : {00,0D}
#_DFB3: db $C0, $8D, $9F, $4D ; .. | ROOM 13 : {00,0D} | ROOM 0A : {1F,0D}
#_DFB7: db $DF, $97, $00, $B6 ; .. | ROOM 13 : {1F,17} | ROOM 14 : {00,16}
#_DFBB: db $00, $B6, $DF, $97 ; .. | ROOM 14 : {00,16} | ROOM 13 : {1F,17}
#_DFBF: db $15, $BD, $15, $A0 ; .. | ROOM 14 : {15,1D} | ROOM 14 : {15,00}
#_DFC3: db $1F, $A4, $80, $43 ; .. | ROOM 14 : {1F,04} | ROOM 0A : {00,03}
#_DFC7: db $1F, $A1, $80, $5B ; .. | ROOM 14 : {1F,01} | ROOM 0A : {00,1B}
#_DFCB: db $80, $5B, $1F, $BB ; .. | ROOM 0A : {00,1B} | ROOM 14 : {1F,1B}
#_DFCF: db $85, $5D, $21, $60 ; .b | ROOM 0A : {05,1D} | ROOM 0C : {01,00}
#_DFD3: db $C7, $5D, $98, $80 ; .. | ROOM 0B : {07,1D} | ROOM 12 : {18,00}
#_DFD7: db $9F, $9B, $3B, $10 ; .b | ROOM 12 : {1F,1B} | ROOM 00 : {1B,10}
#_DFDB: db $00, $7B, $05, $14 ; .. | ROOM 0C : {00,1B} | ROOM 00 : {05,14}
#_DFDF: db $1F, $7B, $40, $7B ; .. | ROOM 0C : {1F,1B} | ROOM 0D : {00,1B}
#_DFE3: db $5F, $7B, $1A, $14 ; .. | ROOM 0D : {1F,1B} | ROOM 00 : {1A,14}
#_DFE7: db $40, $7B, $1F, $7B ; .. | ROOM 0D : {00,1B} | ROOM 0C : {1F,1B}
#_DFEB: db $80, $71, $1F, $81 ; .. | ROOM 0E : {00,11} | ROOM 10 : {1F,01}
#_DFEF: db $8A, $60, $1D, $1B ; .. | ROOM 0E : {0A,00} | ROOM 00 : {1D,1B}
#_DFF3: db $89, $60, $1D, $1B ; .. | ROOM 0E : {09,00} | ROOM 00 : {1D,1B}
#_DFF7: db $88, $60, $1D, $1B ; .. | ROOM 0E : {08,00} | ROOM 00 : {1D,1B}
#_DFFB: db $87, $60, $1D, $1B ; .. | ROOM 0E : {07,00} | ROOM 00 : {1D,1B}
#_DFFF: db $86, $60, $1D, $1B ; .. | ROOM 0E : {06,00} | ROOM 00 : {1D,1B}
#_E003: db $1F, $81, $80, $71 ; .. | ROOM 10 : {1F,01} | ROOM 0E : {00,11}
#_E007: db $1F, $9B, $C0, $61 ; .. | ROOM 10 : {1F,1B} | ROOM 0F : {00,01}
#_E00B: db $C0, $61, $1F, $9B ; .. | ROOM 0F : {00,01} | ROOM 10 : {1F,1B}
#_E00F: db $DD, $7D, $E2, $7B ; .b | ROOM 0F : {1D,1D} | ROOM 0F : {02,1B}

;---------------------------------------------------------------------------------------------------

BossRoomTransitions:
;                               sb | Entrance    x,y   | Exit        x,y
#_E013: db $40, $BB, $1F, $DB ; .. | ROOM 15 : {00,1B} | ROOM 18 : {1F,1B}
#_E017: db $4A, $BD, $10, $04 ; .. | ROOM 15 : {0A,1D} | ROOM 00 : {10,04}
#_E01B: db $55, $BD, $10, $04 ; .. | ROOM 15 : {15,1D} | ROOM 00 : {10,04}
#_E01F: db $5F, $BB, $80, $BB ; .. | ROOM 15 : {1F,1B} | ROOM 16 : {00,1B}
#_E023: db $40, $AE, $10, $04 ; .. | ROOM 15 : {00,0E} | ROOM 00 : {10,04}
#_E027: db $5F, $AE, $10, $04 ; .. | ROOM 15 : {1F,0E} | ROOM 00 : {10,04}
#_E02B: db $40, $A3, $1F, $C3 ; .. | ROOM 15 : {00,03} | ROOM 18 : {1F,03}
#_E02F: db $5F, $A3, $80, $A3 ; .. | ROOM 15 : {1F,03} | ROOM 16 : {00,03}
#_E033: db $80, $BB, $5F, $BB ; .. | ROOM 16 : {00,1B} | ROOM 15 : {1F,1B}
#_E037: db $8A, $BD, $10, $04 ; .. | ROOM 16 : {0A,1D} | ROOM 00 : {10,04}
#_E03B: db $95, $BD, $10, $04 ; .. | ROOM 16 : {15,1D} | ROOM 00 : {10,04}
#_E03F: db $9F, $BB, $C0, $BB ; .. | ROOM 16 : {1F,1B} | ROOM 17 : {00,1B}
#_E043: db $80, $AE, $10, $04 ; .. | ROOM 16 : {00,0E} | ROOM 00 : {10,04}
#_E047: db $9F, $AE, $10, $04 ; .. | ROOM 16 : {1F,0E} | ROOM 00 : {10,04}
#_E04B: db $80, $A3, $5F, $A3 ; .. | ROOM 16 : {00,03} | ROOM 15 : {1F,03}
#_E04F: db $9F, $A3, $C0, $A3 ; .. | ROOM 16 : {1F,03} | ROOM 17 : {00,03}
#_E053: db $C0, $BB, $9F, $BB ; .. | ROOM 17 : {00,1B} | ROOM 16 : {1F,1B}
#_E057: db $CA, $BD, $12, $04 ; .. | ROOM 17 : {0A,1D} | ROOM 00 : {12,04}
#_E05B: db $D5, $BD, $12, $04 ; .. | ROOM 17 : {15,1D} | ROOM 00 : {12,04}
#_E05F: db $DF, $BB, $00, $DB ; .. | ROOM 17 : {1F,1B} | ROOM 18 : {00,1B}
#_E063: db $C0, $AE, $12, $04 ; .. | ROOM 17 : {00,0E} | ROOM 00 : {12,04}
#_E067: db $DF, $AE, $12, $04 ; .. | ROOM 17 : {1F,0E} | ROOM 00 : {12,04}
#_E06B: db $C0, $A3, $9F, $A3 ; .. | ROOM 17 : {00,03} | ROOM 16 : {1F,03}
#_E06F: db $DF, $A3, $00, $C3 ; .. | ROOM 17 : {1F,03} | ROOM 18 : {00,03}
#_E073: db $00, $DB, $DF, $BB ; .. | ROOM 18 : {00,1B} | ROOM 17 : {1F,1B}
#_E077: db $0A, $DD, $12, $04 ; .. | ROOM 18 : {0A,1D} | ROOM 00 : {12,04}
#_E07B: db $15, $DD, $12, $04 ; .. | ROOM 18 : {15,1D} | ROOM 00 : {12,04}
#_E07F: db $1F, $DB, $40, $BB ; .. | ROOM 18 : {1F,1B} | ROOM 15 : {00,1B}
#_E083: db $00, $CE, $12, $04 ; .. | ROOM 18 : {00,0E} | ROOM 00 : {12,04}
#_E087: db $1F, $CE, $12, $04 ; .. | ROOM 18 : {1F,0E} | ROOM 00 : {12,04}
#_E08B: db $00, $C3, $DF, $A3 ; .. | ROOM 18 : {00,03} | ROOM 17 : {1F,03}
#_E08F: db $1F, $C3, $40, $A3 ; .. | ROOM 18 : {1F,03} | ROOM 15 : {00,03}


;===================================================================================================

DrawPreordainedSprite:
#_E093: TAY
#_E094: JMP .start

;===================================================================================================

#DrawPredefinedSprite:
#_E097: TAY

#_E098: LDA.w .props,Y
#_E09B: AND.b #$03
#_E09D: STA.b $32

;---------------------------------------------------------------------------------------------------

.start
#_E09F: LDA.b $34
#_E0A1: BEQ .facing_right

#_E0A3: LDA.b #$40

.facing_right
#_E0A5: ORA.b $32
#_E0A7: STA.b $32

#_E0A9: LDA.w .props,Y
#_E0AC: AND.b #$3C
#_E0AE: STA.b $33

#_E0B0: LDA.b #$00
#_E0B2: STA.b $1D

#_E0B4: TYA
#_E0B5: ASL A
#_E0B6: ROL.b $1D
#_E0B8: ASL A
#_E0B9: ROL.b $1D
#_E0BB: ADC.b #.characters>>0
#_E0BD: STA.b $1C

#_E0BF: LDA.b $1D
#_E0C1: ADC.b #.characters>>8
#_E0C3: STA.b $1D

#_E0C5: LDY.b #$00

#_E0C7: LDA.b $38
#_E0C9: STA.b $1E

#_E0CB: JSR .add_two

#_E0CE: LDA.b $35
#_E0D0: CMP.b #$F8
#_E0D2: BCS .off_screen

#_E0D4: CLC
#_E0D5: ADC.b #$08
#_E0D7: STA.b $35

#_E0D9: LDA.b $1E
#_E0DB: STA.b $38

;===================================================================================================

.add_two
#_E0DD: JSR .add_one
#_E0E0: BCS .dont_add

;===================================================================================================

.add_one
#_E0E2: LDA.b $35
#_E0E4: TYA
#_E0E5: EOR.b $34
#_E0E7: TAY
#_E0E8: STA.b $1F

#_E0EA: LDA.b ($1C),Y
#_E0EC: STA.b $36

#_E0EE: LDA.b $33
#_E0F0: EOR.b $34
#_E0F2: TAY

#_E0F3: LDA.w .flips,Y
#_E0F6: EOR.b $32
#_E0F8: STA.b $37

#_E0FA: LDA.b $1F
#_E0FC: EOR.b $34
#_E0FE: TAY
#_E0FF: INY

#_E100: INC.b $33
#_E102: STY.b $75

#_E104: JSR AddObjectToBuffer

#_E107: LDY.b $75

.off_screen
#_E109: RTS

.dont_add
#_E10A: INY

#_E10B: RTS

;===================================================================================================

#AddObjectToBuffer:
#_E10C: DEC.b $35

#_E10E: LDX.b #$00
#_E110: LDY.b $30

.next_byte
#_E112: LDA.b $35,X
#_E114: STA.w $0300,Y

#_E117: INX
#_E118: INY

#_E119: CPX.b #$04
#_E11B: BNE .next_byte

#_E11D: STY.b $30

#_E11F: INC.b $35

;===================================================================================================

#AdvanceObjectX:
#_E121: LDA.b $38
#_E123: CLC
#_E124: ADC.b #$08
#_E126: STA.b $38

#_E128: RTS

;===================================================================================================

.characters
#_E129: db $88, $88, $88, $88 ; 00 - Popped bubble
#_E12D: db $89, $89, $89, $89 ; 01 - Popped bubble
#_E131: db $20, $21, $30, $31 ; 02 - Spring
#_E135: db $2F, $2F, $32, $33 ; 03 - Spring
#_E139: db $3D, $3D, $1A, $1B ; 04 - Crystal
#_E13D: db $0A, $0B, $1A, $1B ; 05 - Paumeru
#_E141: db $C8, $C9, $D8, $D9 ; 06 - Bone Wing
#_E145: db $0A, $0B, $1A, $1B ; 07 - Maharito head
#_E149: db $A0, $A1, $B0, $B1 ; 08 - Voodoo
#_E14D: db $A2, $A3, $B2, $B3 ; 09 - Voodoo
#_E151: db $2A, $2B, $2F, $6F ; 0A - Maharito T pose
#_E155: db $2F, $7F, $2F, $8F ; 0B - Maharito shuffle
#_E159: db $2F, $9F, $2F, $AF ; 0C - Maharito shuffle
#_E15D: db $6E, $6F, $7E, $7F ; 0D - Beamed quavers
#_E161: db $AC, $AD, $BC, $BD ; 0E - Glove
#_E165: db $6B, $6B, $7B, $7B ; 0F - Cymbals
#_E169: db $6C, $6D, $7C, $7D ; 10 - Euphonium
#_E16D: db $1D, $2F, $2D, $2F ; 11 - Sharp
#_E171: db $26, $27, $36, $37 ; 12 - Tambo
#_E175: db $28, $29, $38, $39 ; 13 - Tambo
#_E179: db $80, $90, $90, $80 ; 14 - Small bubble
#_E17D: db $81, $91, $91, $81 ; 15 - Small bubble
#_E181: db $64, $65, $74, $75 ; 16 - Mauri
#_E185: db $66, $67, $76, $77 ; 17 - Mauri
#_E189: db $4C, $4D, $5C, $5D ; 18 - Respawn bubble
#_E18D: db $4E, $4F, $5E, $5F ; 19 - Respawn bubble
#_E191: db $A4, $A5, $B4, $B5 ; 1A - Flag
#_E195: db $8A, $8B, $9A, $9B ; 1B - Brain Toto
#_E199: db $AE, $AF, $BE, $BF ; 1C - Brain Toto
#_E19D: db $2D, $3D, $1B, $1A ; 1D - Paumeru
#_E1A1: db $6E, $6F, $7E, $7F ; 1E - Slime Eye
#_E1A5: db $8E, $8F, $9E, $9F ; 1F - Slime Eye
#_E1A9: db $A8, $A9, $B8, $B9 ; 20 - Gerubo
#_E1AD: db $AA, $AB, $BA, $BB ; 21 - Gerubo
#_E1B1: db $34, $35, $64, $65 ; 22 - Eye-eye
#_E1B5: db $CC, $CD, $DC, $DD ; 23 - Beat / Flag
#_E1B9: db $CE, $CF, $DE, $DD ; 24 - Beat
#_E1BD: db $A4, $A5, $B4, $B5 ; 25 - Camry
#_E1C1: db $A6, $A5, $B6, $B7 ; 26 - Camry
#_E1C5: db $CA, $CB, $CB, $CA ; 27 - Spark
#_E1C9: db $2F, $2F, $98, $99 ; 28 - HELP
#_E1CD: db $2F, $2F, $2F, $2F ; 29 - HELP
#_E1D1: db $9B, $9C, $9A, $2F ; 2A - Gigantic bubble
#_E1D5: db $9C, $9B, $2F, $9A ; 2B - Gigantic bubble
#_E1D9: db $9A, $2F, $9B, $9C ; 2C - Gigantic bubble
#_E1DD: db $2F, $9A, $9C, $9B ; 2D - Gigantic bubble
#_E1E1: db $48, $49, $47, $2F ; 2E - Gigantic bubble
#_E1E5: db $49, $48, $2F, $47 ; 2F - Gigantic bubble
#_E1E9: db $47, $2F, $48, $49 ; 30 - Gigantic bubble
#_E1ED: db $2F, $47, $49, $48 ; 31 - Gigantic bubble
#_E1F1: db $CE, $CF, $DE, $DF ; 32 - Bone Wing
#_E1F5: db $60, $61, $70, $71 ; 33 - Violin / Music box
#_E1F9: db $65, $6A, $77, $7A ; 34 - Harp
#_E1FD: db $64, $2F, $74, $75 ; 35 - Trumpet
#_E201: db $28, $29, $38, $39 ; 36 - Medamaruge
#_E205: db $28, $29, $22, $23 ; 37 - Medamaruge
#_E209: db $22, $23, $34, $35 ; 38 - Katchinsha
#_E20D: db $2A, $2B, $3A, $3B ; 39 - Katchinsha
#_E211: db $84, $85, $94, $95 ; 3A - Rubide
#_E215: db $86, $87, $96, $97 ; 3B - Rubide
#_E219: db $34, $35, $74, $75 ; 3C - Eye-eye
#_E21D: db $2E, $2E, $2E, $2E ; 3D - Excalibur bubble
#_E221: db $3E, $3E, $3E, $3E ; 3E - Excalibur bubble
#_E225: db $3F, $3F, $3F, $3F ; 3F - Excalibur bubble
#_E229: db $0C, $0C, $1C, $1D ; 40 - Umbrella
#_E22D: db $0E, $0F, $1E, $1F ; 41 - Balloon
#_E231: db $C6, $C7, $D6, $D7 ; 42 - Hudson Bee
#_E235: db $EE, $C7, $FE, $FF ; 43 - Hudson Bee
#_E239: db $3B, $3C, $3C, $3B ; 44 - Boss fireball
#_E23D: db $3C, $3B, $3B, $3C ; 45 - Boss fireball
#_E241: db $2C, $6B, $3C, $7B ; 46 - Key
#_E245: db $66, $67, $76, $76 ; 47 - Drums
#_E249: db $68, $2F, $78, $79 ; 48 - Ocarina
#_E24D: db $2F, $2F, $36, $37 ; 49 - Crown
#_E251: db $A7, $A7, $EF, $EF ; 4A - Cane
#_E255: db $40, $41, $56, $57 ; 4B - Milon standing
#_E259: db $40, $41, $50, $51 ; 4C - Milon walking
#_E25D: db $42, $43, $52, $53 ; 4D - Milon walking
#_E261: db $40, $41, $54, $55 ; 4E - Milon walking
#_E265: db $40, $41, $58, $59 ; 4F - Milon walking
#_E269: db $4A, $4B, $5A, $5B ; 50 - Milon dying
#_E26D: db $4C, $4D, $5C, $5D ; 51 - Milon's butt
#_E271: db $4E, $4F, $5E, $5F ; 52 - 50% of Milon
#_E275: db $2F, $2F, $40, $41 ; 53 - 25% of Milon
#_E279: db $2F, $2F, $2A, $2B ; 54 - 12% of Milon
#_E27D: db $2F, $2F, $2F, $2F ; 55 - Milon is gone
#_E281: db $82, $92, $92, $82 ; 56 - Big bubble
#_E285: db $83, $93, $93, $83 ; 57 - Big bubble
#_E289: db $1C, $2F, $2C, $2F ; 58 - Flat
#_E28D: db $C8, $C9, $D8, $D9 ; 59 - Hard Taru
#_E291: db $CA, $CB, $DA, $DB ; 5A - Hard Taru
#_E295: db $EA, $EB, $FA, $FB ; 5B - Safuma
#_E299: db $EC, $ED, $FC, $FD ; 5C - Safuma
#_E29D: db $68, $69, $78, $79 ; 5D - Gyoro
#_E2A1: db $69, $68, $79, $78 ; 5E - Gyoro
#_E2A5: db $15, $18, $15, $47 ; 5F - Flying Eye
#_E2A9: db $16, $DF, $16, $EF ; 60 - Flying Eye
#_E2AD: db $26, $27, $18, $3B ; 61 - Giant Head
#_E2B1: db $26, $27, $2D, $3D ; 62 - Giant Head
#_E2B5: db $FF, $FF, $FF, $FF ; 63 - !UNUSED
#_E2B9: db $A6, $9D, $B6, $B7 ; 64 - Unbao
#_E2BD: db $15, $16, $DA, $DB ; 65 - Unbao
#_E2C1: db $66, $67, $76, $77 ; 66 - Shim
#_E2C5: db $68, $69, $78, $79 ; 67 - Shim
#_E2C9: db $EA, $EB, $FA, $FB ; 68 - Madora
#_E2CD: db $C3, $C4, $C5, $BF ; 69 - Madora

;---------------------------------------------------------------------------------------------------

.flips
#_E2D1: db $00, $00, $00, $00 ; 00
#_E2D5: db $00, $40, $80, $C0 ; 04
#_E2D9: db $40, $40, $40, $40 ; 08
#_E2DD: db $80, $80, $80, $80 ; 0C
#_E2E1: db $C0, $C0, $C0, $C0 ; 10
#_E2E5: db $00, $00, $C0, $C0 ; 14
#_E2E9: db $40, $40, $80, $80 ; 18
#_E2ED: db $00, $C0, $00, $C0 ; 1C
#_E2F1: db $00, $40, $00, $40 ; 20
#_E2F5: db $00, $40, $00, $00 ; 24
#_E2F9: db $00, $00, $80, $00 ; 28
#_E2FD: db $40, $00, $40, $00 ; 2C
#_E301: db $00, $00, $00, $40 ; 30
#_E305: db $00, $00, $40, $40 ; 34

;---------------------------------------------------------------------------------------------------

; ..ff ffpp
;   f - flip offset
;   p - palette
.props
#_E309: db $04 ; 00 - flip: 04 | pal: 0
#_E30A: db $04 ; 01 - flip: 04 | pal: 0
#_E30B: db $01 ; 02 - flip: 00 | pal: 1
#_E30C: db $01 ; 03 - flip: 00 | pal: 1
#_E30D: db $24 ; 04 - flip: 24 | pal: 0
#_E30E: db $02 ; 05 - flip: 00 | pal: 2
#_E30F: db $03 ; 06 - flip: 00 | pal: 3
#_E310: db $03 ; 07 - flip: 00 | pal: 3
#_E311: db $03 ; 08 - flip: 00 | pal: 3
#_E312: db $03 ; 09 - flip: 00 | pal: 3
#_E313: db $03 ; 0A - flip: 00 | pal: 3
#_E314: db $03 ; 0B - flip: 00 | pal: 3
#_E315: db $03 ; 0C - flip: 00 | pal: 3
#_E316: db $03 ; 0D - flip: 00 | pal: 3
#_E317: db $01 ; 0E - flip: 00 | pal: 1
#_E318: db $2F ; 0F - flip: 2C | pal: 3
#_E319: db $02 ; 10 - flip: 00 | pal: 2
#_E31A: db $03 ; 11 - flip: 00 | pal: 3
#_E31B: db $02 ; 12 - flip: 00 | pal: 2
#_E31C: db $02 ; 13 - flip: 00 | pal: 2
#_E31D: db $1C ; 14 - flip: 1C | pal: 0
#_E31E: db $1C ; 15 - flip: 1C | pal: 0
#_E31F: db $01 ; 16 - flip: 00 | pal: 1
#_E320: db $01 ; 17 - flip: 00 | pal: 1
#_E321: db $00 ; 18 - flip: 00 | pal: 0
#_E322: db $00 ; 19 - flip: 00 | pal: 0
#_E323: db $02 ; 1A - flip: 00 | pal: 2
#_E324: db $03 ; 1B - flip: 00 | pal: 3
#_E325: db $03 ; 1C - flip: 00 | pal: 3
#_E326: db $36 ; 1D - flip: 34 | pal: 2
#_E327: db $01 ; 1E - flip: 00 | pal: 1
#_E328: db $01 ; 1F - flip: 00 | pal: 1
#_E329: db $00 ; 20 - flip: 00 | pal: 0
#_E32A: db $00 ; 21 - flip: 00 | pal: 0
#_E32B: db $02 ; 22 - flip: 00 | pal: 2
#_E32C: db $02 ; 23 - flip: 00 | pal: 2
#_E32D: db $02 ; 24 - flip: 00 | pal: 2
#_E32E: db $02 ; 25 - flip: 00 | pal: 2
#_E32F: db $02 ; 26 - flip: 00 | pal: 2
#_E330: db $1F ; 27 - flip: 1C | pal: 3
#_E331: db $03 ; 28 - flip: 00 | pal: 3
#_E332: db $00 ; 29 - flip: 00 | pal: 0
#_E333: db $00 ; 2A - flip: 00 | pal: 0
#_E334: db $08 ; 2B - flip: 08 | pal: 0
#_E335: db $0C ; 2C - flip: 0C | pal: 0
#_E336: db $10 ; 2D - flip: 10 | pal: 0
#_E337: db $00 ; 2E - flip: 00 | pal: 0
#_E338: db $08 ; 2F - flip: 08 | pal: 0
#_E339: db $0C ; 30 - flip: 0C | pal: 0
#_E33A: db $10 ; 31 - flip: 10 | pal: 0
#_E33B: db $03 ; 32 - flip: 00 | pal: 3
#_E33C: db $02 ; 33 - flip: 00 | pal: 2
#_E33D: db $00 ; 34 - flip: 00 | pal: 0
#_E33E: db $02 ; 35 - flip: 00 | pal: 2
#_E33F: db $02 ; 36 - flip: 00 | pal: 2
#_E340: db $02 ; 37 - flip: 00 | pal: 2
#_E341: db $00 ; 38 - flip: 00 | pal: 0
#_E342: db $00 ; 39 - flip: 00 | pal: 0
#_E343: db $01 ; 3A - flip: 00 | pal: 1
#_E344: db $01 ; 3B - flip: 00 | pal: 1
#_E345: db $02 ; 3C - flip: 00 | pal: 2
#_E346: db $04 ; 3D - flip: 04 | pal: 0
#_E347: db $04 ; 3E - flip: 04 | pal: 0
#_E348: db $04 ; 3F - flip: 04 | pal: 0
#_E349: db $24 ; 40 - flip: 24 | pal: 0
#_E34A: db $00 ; 41 - flip: 00 | pal: 0
#_E34B: db $03 ; 42 - flip: 00 | pal: 3
#_E34C: db $03 ; 43 - flip: 00 | pal: 3
#_E34D: db $17 ; 44 - flip: 14 | pal: 3
#_E34E: db $1B ; 45 - flip: 18 | pal: 3
#_E34F: db $02 ; 46 - flip: 00 | pal: 2
#_E350: db $32 ; 47 - flip: 30 | pal: 2
#_E351: db $02 ; 48 - flip: 00 | pal: 2
#_E352: db $01 ; 49 - flip: 00 | pal: 1
#_E353: db $21 ; 4A - flip: 20 | pal: 1
#_E354: db $00 ; 4B - flip: 00 | pal: 0
#_E355: db $00 ; 4C - flip: 00 | pal: 0
#_E356: db $00 ; 4D - flip: 00 | pal: 0
#_E357: db $00 ; 4E - flip: 00 | pal: 0
#_E358: db $00 ; 4F - flip: 00 | pal: 0
#_E359: db $00 ; 50 - flip: 00 | pal: 0
#_E35A: db $00 ; 51 - flip: 00 | pal: 0
#_E35B: db $00 ; 52 - flip: 00 | pal: 0
#_E35C: db $00 ; 53 - flip: 00 | pal: 0
#_E35D: db $00 ; 54 - flip: 00 | pal: 0
#_E35E: db $00 ; 55 - flip: 00 | pal: 0
#_E35F: db $1C ; 56 - flip: 1C | pal: 0
#_E360: db $1C ; 57 - flip: 1C | pal: 0
#_E361: db $03 ; 58 - flip: 00 | pal: 3
#_E362: db $01 ; 59 - flip: 00 | pal: 1
#_E363: db $01 ; 5A - flip: 00 | pal: 1
#_E364: db $02 ; 5B - flip: 00 | pal: 2
#_E365: db $02 ; 5C - flip: 00 | pal: 2
#_E366: db $01 ; 5D - flip: 00 | pal: 1
#_E367: db $09 ; 5E - flip: 08 | pal: 1
#_E368: db $2B ; 5F - flip: 28 | pal: 3
#_E369: db $2B ; 60 - flip: 28 | pal: 3
#_E36A: db $01 ; 61 - flip: 00 | pal: 1
#_E36B: db $01 ; 62 - flip: 00 | pal: 1
#_E36C: db $02 ; 63 - flip: 00 | pal: 2
#_E36D: db $02 ; 64 - flip: 00 | pal: 2
#_E36E: db $02 ; 65 - flip: 00 | pal: 2
#_E36F: db $01 ; 66 - flip: 00 | pal: 1
#_E370: db $01 ; 67 - flip: 00 | pal: 1
#_E371: db $03 ; 68 - flip: 00 | pal: 3
#_E372: db $03 ; 69 - flip: 00 | pal: 3

;===================================================================================================

DrawBeeShield:
#_E373: LDA.b $9C
#_E375: BEQ .no_shield

#_E377: LDX.w $07D5

#_E37A: LDA.w ShieldGraphic,X
#_E37D: STA.b $36

#_E37F: LDA.b #$00
#_E381: STA.b $37

#_E383: LDA.b $52
#_E385: ASL A
#_E386: ASL A
#_E387: STA.b $1C

#_E389: LDA.b $3F
#_E38B: ADC.b #$08
#_E38D: SEC
#_E38E: SBC.b $1C
#_E390: STA.b $35

#_E392: LDA.b $9C
#_E394: ASL A
#_E395: ASL A
#_E396: STA.b $1C

#_E398: LDA.b $3E
#_E39A: SEC
#_E39B: SBC.b $1C
#_E39D: STA.b $38
#_E39F: BCC .off_screen

#_E3A1: JSR DrawShieldHalf

.off_screen
#_E3A4: LDA.b $9C
#_E3A6: ASL A
#_E3A7: ASL A
#_E3A8: CLC
#_E3A9: ADC.b #$08
#_E3AB: ADC.b $3E
#_E3AD: STA.b $38
#_E3AF: BCS .no_shield

#_E3B1: LDA.b #$40
#_E3B3: STA.b $37

;===================================================================================================

#DrawShieldHalf:
#_E3B5: LDA.b $38
#_E3B7: PHA

#_E3B8: JSR AddObjectToBuffer

#_E3BB: PLA
#_E3BC: STA.b $38

#_E3BE: LDA.b $35
#_E3C0: PHA
#_E3C1: CLC
#_E3C2: ADC.b #$08
#_E3C4: STA.b $35

#_E3C6: LDA.b $37
#_E3C8: ORA.b #$80
#_E3CA: STA.b $37

#_E3CC: JSR AddObjectToBuffer

#_E3CF: PLA
#_E3D0: STA.b $35

;---------------------------------------------------------------------------------------------------

.no_shield
#_E3D2: LDA.b $8E
#_E3D4: AND.b #$03
#_E3D6: BNE .exit

#_E3D8: INC.w $07D5

#_E3DB: LDA.w $07D5
#_E3DE: CMP.b #$03
#_E3E0: BCC .exit

#_E3E2: LDA.b #$00
#_E3E4: STA.w $07D5

.exit
#_E3E7: RTS

;---------------------------------------------------------------------------------------------------

ShieldGraphic:
#_E3E8: db $44, $45, $46

;===================================================================================================

DrawGiganticBubble:
#_E3EB: LDA.b $8E
#_E3ED: AND.b #$02
#_E3EF: ASL A
#_E3F0: STA.b $76

#_E3F2: LDA.b #$00
#_E3F4: STA.b $34
#_E3F6: STA.b $6B

;---------------------------------------------------------------------------------------------------

.next_object
#_E3F8: LDX.b $6B

#_E3FA: LDA.b $3E
#_E3FC: CLC
#_E3FD: ADC.w .offset,X
#_E400: INX
#_E401: STA.b $38

#_E403: LDA.b $3F
#_E405: CLC
#_E406: ADC.w .offset,X
#_E409: INX
#_E40A: STX.b $6B
#_E40C: STA.b $35

#_E40E: LDA.b $76
#_E410: CLC
#_E411: ADC.b #$2A
#_E413: JSR DrawPredefinedSprite

#_E416: INC.b $76

#_E418: LDA.b #$08
#_E41A: CMP.b $6B
#_E41C: BNE .next_object

#_E41E: RTS

;---------------------------------------------------------------------------------------------------

.offset
#_E41F: db $F8, $FC, $08, $FC
#_E423: db $F8, $0C, $08, $0C

;===================================================================================================

HandleCutsceneBubbles:
#_E427: LDX.b #$00

.next
#_E429: STX.b $5E

#_E42B: JSR LoadSpriteVars
#_E42E: JSR MoveCutsceneBubble
#_E431: JSR DrawCutsceneBubble
#_E434: JSR SaveSpriteVars

#_E437: LDX.b $5E
#_E439: INX
#_E43A: CPX.b #$0A
#_E43C: BNE .next

#_E43E: RTS

;===================================================================================================

DrawCutsceneBubble:
#_E43F: LDA.b $63
#_E441: STA.b $38

#_E443: LDA.b $64
#_E445: STA.b $35

#_E447: LDA.b #$00
#_E449: STA.b $34

#_E44B: LDA.b $66
#_E44D: AND.b #$04
#_E44F: LSR A
#_E450: LSR A
#_E451: CLC
#_E452: ADC.b #$56
#_E454: JMP DrawPredefinedSprite

;===================================================================================================

MoveCutsceneBubble:
#_E457: INC.b $66

#_E459: LDA.b $5F
#_E45B: CLC
#_E45C: ADC.b $61
#_E45E: STA.b $61
#_E460: BCC .move_y

#_E462: LDA.b $65
#_E464: AND.b #$01
#_E466: BNE .move_left

#_E468: INC.b $63

#_E46A: JMP .move_y ; BCS smh

.move_left
#_E46D: DEC.b $63

;---------------------------------------------------------------------------------------------------

.move_y
#_E46F: LDA.b $60
#_E471: CLC
#_E472: ADC.b $62
#_E474: STA.b $62
#_E476: BCC .exit

#_E478: LDA.b $65
#_E47A: AND.b #$02
#_E47C: BNE .move_up

#_E47E: INC.b $64

#_E480: RTS

.move_up
#_E481: DEC.b $64

.exit
#_E483: RTS

;===================================================================================================

SpawnCutsceneBubbles:
#_E484: LDX.b #$00

.next
#_E486: STX.b $5E

#_E488: JSR LoadSpriteVars
#_E48B: JSR SpawnOneCutsceneBubble
#_E48E: JSR SaveSpriteVars

#_E491: LDX.b $5E
#_E493: INX
#_E494: CPX.b #$0A
#_E496: BNE .next

#_E498: RTS

;===================================================================================================

SpawnOneCutsceneBubble:
#_E499: INC.b $1C

#_E49B: LDA.b $1C
#_E49D: AND.b #$07
#_E49F: STA.b $66

#_E4A1: LDA.b #$00
#_E4A3: STA.b $61
#_E4A5: STA.b $62
#_E4A7: STA.b $65

#_E4A9: LDA.b $5E
#_E4AB: ASL A
#_E4AC: TAY

#_E4AD: LDA.w RandomScreenRespawns+0,Y
#_E4B0: STA.b $63
#_E4B2: TAX

#_E4B3: LDA.w RandomScreenRespawns+1,Y
#_E4B6: STA.b $64
#_E4B8: TXA

#_E4B9: SEC
#_E4BA: SBC.b $3E
#_E4BC: BCC .left_of_milon

#_E4BE: INC.b $65

#_E4C0: STA.b $5F
#_E4C2: BNE .set_y_direction

.left_of_milon
#_E4C4: EOR.b #$FF
#_E4C6: CLC
#_E4C7: ADC.b #$01
#_E4C9: STA.b $5F

.set_y_direction
#_E4CB: LDA.b $64
#_E4CD: SEC
#_E4CE: SBC.b $3F
#_E4D0: BCC .above_milon

#_E4D2: STA.b $60

#_E4D4: LDA.b $65
#_E4D6: ORA.b #$02
#_E4D8: STA.b $65

#_E4DA: RTS

.above_milon
#_E4DB: EOR.b #$FF
#_E4DD: CLC
#_E4DE: ADC.b #$01
#_E4E0: STA.b $60

#_E4E2: RTS

;===================================================================================================

RandomScreenRespawns:
#_E4E3: db $20, $24
#_E4E5: db $60, $00
#_E4E7: db $A0, $00
#_E4E9: db $D8, $24
#_E4EB: db $F7, $70
#_E4ED: db $D8, $CC
#_E4EF: db $A0, $F0
#_E4F1: db $60, $F0
#_E4F3: db $20, $CC
#_E4F5: db $08, $70

;===================================================================================================

GFXBanks:
#_E4F7: db $30 ; GFXBANK 00
#_E4F8: db $31 ; GFXBANK 01
#_E4F9: db $32 ; GFXBANK 02
#_E4FA: db $33 ; GFXBANK 03

;===================================================================================================

ReadIndoorTilemapHighBits:
#_E4FB: LDY.b $87

#_E4FD: LDA.w RoomDataPointerIndex,Y
#_E500: ASL A
#_E501: TAX

#_E502: LDA.w TilemapHighBitPointers-2,X
#_E505: STA.b $1C

#_E507: LDA.w TilemapHighBitPointers-1,X
#_E50A: LDX.b $1C
#_E50C: JSR SetPPUADDRSafely

#_E50F: LDA.w PPUDATA
#_E512: LDX.b #$00

;---------------------------------------------------------------------------------------------------

.next
#_E514: CPX.b #$78
#_E516: BEQ .exit

.find_first_unset
#_E518: BCS .find_first_unset

#_E51A: LDA.w PPUDATA
#_E51D: STA.b $1F

#_E51F: LSR A
#_E520: LSR A
#_E521: LSR A
#_E522: LSR A
#_E523: BEQ .do_copy

#_E525: STA.b $1E

#_E527: LDA.b #$00

.clear
#_E529: STA.w $0120,X

#_E52C: INX

#_E52D: DEC.b $1E
#_E52F: BNE .clear

.do_copy
#_E531: LDA.b $1F
#_E533: AND.b #$0F
#_E535: BEQ .next

#_E537: STA.b $1E

.copy_next
#_E539: LDA.w PPUDATA
#_E53C: STA.w $0120,X

#_E53F: INX

#_E540: DEC.b $1E
#_E542: BNE .copy_next

#_E544: BEQ .next

.exit
#_E546: RTS

;===================================================================================================

TilemapHighBitPointers:
#_E547: dw CastleTilemapHighBits_high_bits_00
#_E549: dw CastleTilemapHighBits_high_bits_01
#_E54B: dw CastleTilemapHighBits_high_bits_02
#_E54D: dw CastleTilemapHighBits_high_bits_03
#_E54F: dw CastleTilemapHighBits_high_bits_04
#_E551: dw CastleTilemapHighBits_high_bits_05
#_E553: dw CastleTilemapHighBits_high_bits_06
#_E555: dw CastleTilemapHighBits_high_bits_07
#_E557: dw CastleTilemapHighBits_high_bits_08
#_E559: dw CastleTilemapHighBits_high_bits_09
#_E55B: dw CastleTilemapHighBits_high_bits_0A
#_E55D: dw CastleTilemapHighBits_high_bits_0B
#_E55F: dw CastleTilemapHighBits_high_bits_0C
#_E561: dw CastleTilemapHighBits_high_bits_0D
#_E563: dw CastleTilemapHighBits_high_bits_0E
#_E565: dw CastleTilemapHighBits_high_bits_0F

;===================================================================================================

LoadTowerSpiral:
#_E567: LDA.b #$00
#_E569: STA.b $1E
#_E56B: TAX

.clear_tiles_a
#_E56C: STA.w $0400,X

#_E56F: INX
#_E570: BNE .clear_tiles_a

.clear_tiles_b
#_E572: STA.w $0500,X

#_E575: INX
#_E576: CPX.b #$E0
#_E578: BNE .clear_tiles_b

;---------------------------------------------------------------------------------------------------

#_E57A: LDA.b #$0400>>0
#_E57C: STA.b $20

#_E57E: LDA.b #$0400>>8
#_E580: STA.b $21

#_E582: LDY.b #$00
#_E584: STY.b $75

.read_next
#_E586: LDY.b $75

#_E588: LDA.w .pattern,Y
#_E58B: BMI .single_block

;---------------------------------------------------------------------------------------------------

#_E58D: ASL A
#_E58E: TAX

#_E58F: LDA.w .segment_pointers+0,X
#_E592: STA.b $1C
#_E594: LDA.w .segment_pointers+1,X
#_E597: STA.b $1D

#_E599: LDY.b #$00

.next_in_segment
#_E59B: LDA.b ($1C),Y
#_E59D: BEQ .end_of_segment

#_E59F: JSR .set_block

#_E5A2: INY
#_E5A3: BNE .next_in_segment

.end_of_segment
#_E5A5: INC.b $75
#_E5A7: BNE .read_next

;---------------------------------------------------------------------------------------------------

.single_block
#_E5A9: CMP.b #$FF
#_E5AB: BEQ .set_block

#_E5AD: AND.b #$0F
#_E5AF: TAX

#_E5B0: LDA.w .single_blocks,X
#_E5B3: JSR .set_block

#_E5B6: INC.b $75
#_E5B8: BNE .read_next

;---------------------------------------------------------------------------------------------------

.set_block
#_E5BA: LDX.b #$00
#_E5BC: STA.b ($20,X)

#_E5BE: INC.b $20
#_E5C0: BNE .exit

#_E5C2: INC.b $21

.exit
#_E5C4: RTS

;---------------------------------------------------------------------------------------------------

.segment_pointers
#_E5C5: dw .segment_00
#_E5C7: dw .segment_01
#_E5C9: dw .segment_02
#_E5CB: dw .segment_03
#_E5CD: dw .segment_04
#_E5CF: dw .segment_05
#_E5D1: dw .segment_06
#_E5D3: dw .segment_07
#_E5D5: dw .segment_08
#_E5D7: dw .segment_09
#_E5D9: dw .segment_0A
#_E5DB: dw .segment_0B
#_E5DD: dw .segment_0C
#_E5DF: dw .segment_0D

;---------------------------------------------------------------------------------------------------

.segment_00
#_E5E1: db $21, $21, $23, $43
#_E5E5: db $00

.segment_01
#_E5E6: db $21, $21
#_E5E8: db $00

.segment_02
#_E5E9: db $23, $43, $4E, $EE, $F1
#_E5EE: db $00

.segment_03
#_E5EF: db $EE, $EF
#_E5F1: db $00

.segment_04
#_E5F2: db $12, $12, $12, $34, $34, $EE, $EF
#_E5F9: db $00

.segment_05
#_E5FA: db $12, $12
#_E5FC: db $00

.segment_06
#_E5FD: db $12, $12, $12
#_E600: db $00

.segment_07
#_E601: db $34, $34
#_E603: db $00

.segment_08
#_E604: db $4E, $EE, $F1
#_E607: db $00

.segment_09
#_E608: db $34, $34, $34, $34, $34
#_E60D: db $00

.segment_0A
#_E60E: db $4E, $EE
#_E610: db $00

.segment_0B
#_E611: db $EE, $F1
#_E613: db $00

.segment_0C
#_E614: db $EE, $EE, $EE, $EE, $EE
#_E619: db $00

.segment_0D
#_E61A: db $EE, $EE
#_E61C: db $00

;---------------------------------------------------------------------------------------------------

.single_blocks
#_E61D: db $EE, $E7, $7E, $88, $43, $48, $12, $34
#_E625: db $EF, $21, $23, $C1, $31, $4E

;---------------------------------------------------------------------------------------------------

.pattern
#_E62B: db $0D, $80, $81, $82, $0C, $81, $82, $0D
#_E633: db $0D, $03, $09, $03, $09, $80, $83, $84
#_E63B: db $08, $01, $02, $00, $85, $86, $07, $03
#_E643: db $04, $06, $87, $01, $02, $01, $02, $01
#_E64B: db $88, $04, $04, $86, $08, $01, $02, $00
#_E653: db $0A, $07, $03, $04, $06, $07, $89, $02
#_E65B: db $01, $02, $01, $8A, $04, $04, $05, $0B
#_E663: db $01, $02, $01, $02, $87, $03, $04, $06
#_E66B: db $07, $80, $02, $00, $0A, $8B, $00, $05
#_E673: db $07, $03, $04, $06, $8C, $01, $02, $01
#_E67B: db $02, $89, $03, $04, $04, $84, $08, $01
#_E683: db $02, $00, $8D, $86, $07, $03, $04, $06
#_E68B: db $87, $01, $02, $01, $02, $01, $88, $04
#_E693: db $04, $86, $08, $01, $02, $00, $0A, $07
#_E69B: db $03, $04, $06, $07, $89, $02, $01, $02
#_E6A3: db $89, $89, $89, $04, $04, $05, $0B, $01
#_E6AB: db $02, $01, $02, $87, $03, $04, $06, $07
#_E6B3: db $80, $02, $01, $02, $00, $05, $07, $03
#_E6BB: db $06, $07, $03, $06, $89, $01, $02, $01
#_E6C3: db $02, $89, $0D, $81, $0C, $0D, $81, $0C
#_E6CB: db $FF ; end

;===================================================================================================
; Tile name definitions for drawing an object:
;   AB
;   CD
;---------------------------------------------------------------------------------------------------
; [pg]
;   p - used in puzzle room graphics
;   g - used in gauntlet room graphics
;   . - not used in these graphics
;===================================================================================================
ObjectTileNames:
;           A    B    C    D
#_E6CC: db $00, $01, $10, $11 ; 00 [pg] - Empty square
#_E6D0: db $02, $03, $12, $13 ; 01 [p.] - Door top
#_E6D4: db $04, $05, $14, $15 ; 02 [p.] - Door bottom
#_E6D8: db $06, $07, $16, $17 ; 03 [p.] - Window
#_E6DC: db $08, $09, $18, $19 ; 04 [pg] - Coin
#_E6E0: db $2E, $2E, $2E, $2E ; 05 [p.] - Brick wall
#_E6E4: db $2F, $2F, $2E, $2E ; 06 [p.] - Brick wall
#_E6E8: db $2F, $3E, $2E, $2E ; 07 [p.] - Brick wall
#_E6EC: db $2E, $2F, $2E, $2F ; 08 [p.] - Brick wall
#_E6F0: db $2E, $3F, $2E, $2F ; 09 [p.] - Brick wall
#_E6F4: db $2E, $2F, $2E, $2E ; 0A [p.] - Brick wall
#_E6F8: db $2F, $2F, $2E, $2F ; 0B [p.] - Brick wall
#_E6FC: db $0C, $0D, $1C, $1D ; 0C [pg] - Wall decor
#_E700: db $2F, $2F, $1C, $1D ; 0D [p.] - Wall decor
#_E704: db $2F, $66, $1C, $1D ; 0E [p.] - Wall decor
#_E708: db $0C, $2F, $1C, $2F ; 0F [p.] - Wall decor
#_E70C: db $0C, $76, $1C, $2F ; 10 [p.] - Wall decor
#_E710: db $0C, $2F, $1C, $1D ; 11 [p.] - Wall decor
#_E714: db $2F, $2F, $1C, $2F ; 12 [p.] - Wall decor
#_E718: db $1A, $1B, $1B, $1A ; 13 [p.] - Steel plates
#_E71C: db $2F, $2F, $1B, $1A ; 14 [p.] - Steel plates
#_E720: db $2F, $0A, $1B, $1A ; 15 [p.] - Steel plates
#_E724: db $1A, $2F, $1B, $2F ; 16 [p.] - Steel plates
#_E728: db $1A, $0B, $1B, $2F ; 17 [p.] - Steel plates
#_E72C: db $1A, $2F, $1B, $1A ; 18 [p.] - Steel plates
#_E730: db $2F, $2F, $1B, $2F ; 19 [p.] - Steel plates
#_E734: db $72, $73, $72, $73 ; 1A [p.] - Brick wall
#_E738: db $2F, $2F, $72, $73 ; 1B [p.] - Brick wall
#_E73C: db $2F, $62, $72, $73 ; 1C [p.] - Brick wall
#_E740: db $72, $2F, $72, $2F ; 1D [p.] - Brick wall
#_E744: db $72, $63, $72, $2F ; 1E [p.] - Brick wall
#_E748: db $72, $2F, $72, $73 ; 1F [p.] - Brick wall
#_E74C: db $2F, $2F, $72, $2F ; 20 [p.] - Brick wall
#_E750: db $74, $75, $74, $75 ; 21 [p.] - Brick wall
#_E754: db $2F, $2F, $74, $75 ; 22 [p.] - Brick wall
#_E758: db $2F, $64, $74, $75 ; 23 [p.] - Brick wall
#_E75C: db $74, $2F, $74, $2F ; 24 [p.] - Brick wall
#_E760: db $74, $65, $74, $2F ; 25 [p.] - Brick wall
#_E764: db $74, $2F, $74, $75 ; 26 [p.] - Brick wall
#_E768: db $2F, $2F, $74, $2F ; 27 [p.] - Brick wall
#_E76C: db $70, $71, $71, $70 ; 28 [.g] - Ruins decor
#_E770: db $2F, $2F, $71, $70 ; 29 [.g] - Ruins decor
#_E774: db $2F, $60, $71, $70 ; 2A [.g] - Ruins decor
#_E778: db $70, $2F, $71, $2F ; 2B [.g] - Ruins decor
#_E77C: db $70, $61, $71, $2F ; 2C [.g] - Ruins decor
#_E780: db $70, $2F, $71, $70 ; 2D [.g] - Ruins decor
#_E784: db $2F, $2F, $71, $2F ; 2E [.g] - Ruins decor
#_E788: db $2F, $63, $2F, $63 ; 2F [.g] - Ruins column
#_E78C: db $20, $21, $30, $31 ; 30 [.g] - Shrine walls
#_E790: db $22, $23, $32, $33 ; 31 [.g] - Shrine walls
#_E794: db $24, $25, $34, $35 ; 32 [.g] - Shrine walls
#_E798: db $26, $27, $36, $33 ; 33 [.g] - Shrine walls
#_E79C: db $20, $25, $30, $31 ; 34 [.g] - Shrine walls
#_E7A0: db $22, $27, $36, $37 ; 35 [.g] - Shrine walls
#_E7A4: db $2A, $2B, $3A, $3B ; 36 [.g] - Delapidated brick wall
#_E7A8: db $28, $29, $3A, $3B ; 37 [.g] - Delapidated brick wall
#_E7AC: db $28, $0A, $3A, $3B ; 38 [.g] - Delapidated brick wall
#_E7B0: db $2A, $29, $3A, $39 ; 39 [.g] - Delapidated brick wall
#_E7B4: db $2A, $0B, $3A, $39 ; 3A [.g] - Delapidated brick wall
#_E7B8: db $2A, $29, $3A, $3B ; 3B [.g] - Delapidated brick wall
#_E7BC: db $28, $29, $3A, $39 ; 3C [.g] - Delapidated brick wall
#_E7C0: db $28, $29, $38, $39 ; 3D [.g] - Delapidated brick wall
#_E7C4: db $2F, $2F, $2F, $2F ; 3E [pg] - Empty
#_E7C8: db $0E, $0F, $1E, $1F ; 3F [pg] - Honeycomb
#_E7CC: db $2E, $2E, $67, $67 ; 40 [p.] - Decor
#_E7D0: db $62, $2E, $72, $2E ; 41 [p.] - Decor
#_E7D4: db $2F, $2F, $2F, $2F ; 42 [..] - Empty - !UNUSED
#_E7D8: db $46, $45, $56, $55 ; 43 [.g] - Long fire left
#_E7DC: db $44, $45, $54, $55 ; 44 [.g] - Long fire middle
#_E7E0: db $44, $47, $54, $57 ; 45 [.g] - Long fire right
#_E7E4: db $2C, $2D, $3C, $3D ; 46 [.g] - Fire column top
#_E7E8: db $40, $41, $50, $51 ; 47 [.g] - Fire column
#_E7EC: db $42, $43, $52, $53 ; 48 [.g] - Fire column base
#_E7F0: db $46, $47, $56, $57 ; 49 [.g] - Small fire
#_E7F4: db $74, $74, $75, $75 ; 4A [.g] - Lightning (vertical)
#_E7F8: db $75, $75, $75, $75 ; 4B [.g] - Lightning (vertical)
#_E7FC: db $75, $75, $76, $76 ; 4C [.g] - Lightning (vertical)
#_E800: db $64, $65, $2F, $2F ; 4D [.g] - Lightning (horizontal)
#_E804: db $65, $65, $2F, $2F ; 4E [.g] - Lightning (horizontal)
#_E808: db $65, $66, $2F, $2F ; 4F [.g] - Lightning (horizontal)
#_E80C: db $D5, $D5, $2F, $2F ; 50 [p.] - Steel beam
#_E810: db $D5, $2F, $2F, $2F ; 51 [p.] - Steel beam
#_E814: db $2F, $D5, $2F, $2F ; 52 [p.] - Steel beam
#_E818: db $DF, $DE, $2F, $2F ; 53 [p.] - Steel beam
#_E81C: db $DF, $2F, $2F, $2F ; 54 [p.] - Steel beam
#_E820: db $2F, $DE, $2F, $2F ; 55 [p.] - Steel beam
#_E824: db $C2, $C3, $2F, $2F ; 56 [pg] - Wood platform
#_E828: db $C2, $2F, $2F, $2F ; 57 [pg] - Wood platform
#_E82C: db $2F, $C3, $2F, $2F ; 58 [pg] - Wood platform
#_E830: db $BF, $BF, $2F, $2F ; 59 [p.] - Steel block
#_E834: db $BF, $2F, $2F, $2F ; 5A [p.] - Steel block
#_E838: db $2F, $BF, $2F, $2F ; 5B [p.] - Steel block
#_E83C: db $C6, $C7, $2F, $2F ; 5C [pg] - Steel beam
#_E840: db $70, $61, $61, $C4 ; 5D [.g] - Steel beam
#_E844: db $C5, $71, $D5, $C5 ; 5E [.g] - Steel beam
#_E848: db $D2, $D3, $2F, $2F ; 5F [p.] - Steel block
#_E84C: db $D3, $D2, $D2, $D3 ; 60 [p.] - Steel block
#_E850: db $D3, $D4, $D2, $D3 ; 61 [p.] - Steel block
#_E854: db $CA, $CB, $DA, $DB ; 62 [pg] - Clay block / Ruins platform
#_E858: db $C6, $C7, $D6, $D7 ; 63 [pg] - Picnic table
#_E85C: db $DF, $DE, $DE, $DF ; 64 [p.] - Granite bricks
#_E860: db $DF, $CE, $DE, $DF ; 65 [p.] - Granite bricks
#_E864: db $EE, $EF, $EE, $EF ; 66 [pg] - Marble column
#_E868: db $C0, $D1, $D0, $D1 ; 67 [pg] - Wood column
#_E86C: db $C2, $C3, $C2, $C3 ; 68 [p.] - Wood column
#_E870: db $C3, $D1, $D0, $D1 ; 69 [pg] - Wood column
#_E874: db $C2, $C3, $C0, $C1 ; 6A [p.] - Wood column
#_E878: db $C0, $C3, $D0, $C1 ; 6B [.g] - Wood column
#_E87C: db $C8, $C9, $D8, $D9 ; 6C [pg] - Brick column
#_E880: db $FE, $FF, $FE, $FF ; 6D [p.] - Stone column
#_E884: db $DF, $FF, $FE, $FF ; 6E [p.] - Stone column
#_E888: db $CC, $CD, $DC, $DD ; 6F [pg] - Bread twist / Dark well block
#_E88C: db $C5, $CD, $DC, $DD ; 70 [p.] - Steel platform on bread twist
#_E890: db $DE, $DF, $EE, $EF ; 71 [.g] - Marble column top
#_E894: db $EE, $EF, $FE, $FF ; 72 [.g] - Marble column bottom
#_E898: db $2F, $2F, $2F, $2F ; 73 [..] - Empty - !UNUSED
#_E89C: db $C6, $C7, $C7, $BD ; 74 [.g] - Bricks
#_E8A0: db $BE, $BF, $CE, $CF ; 75 [.g] - Painted brick
#_E8A4: db $D5, $D5, $D5, $D5 ; 76 [pg] - Double steel platform
#_E8A8: db $DE, $DF, $2F, $2F ; 77 [p.] - steel platform top
#_E8AC: db $E0, $E1, $F0, $F1 ; 78 [pg] - Collapsing floor / Melting ice
#_E8B0: db $E2, $E3, $F2, $F3 ; 79 [pg] - Trap door / Melting ice step 1
#_E8B4: db $E4, $E5, $F4, $F5 ; 7A [pg] - Trap door / Melting ice step 2
#_E8B8: db $E6, $E7, $F6, $F7 ; 7B [pg] - Trap door / Melting ice step 3
#_E8BC: db $2F, $2F, $2F, $2F ; 7C [..] - Empty - !UNUSED
#_E8C0: db $E8, $E9, $F8, $F9 ; 7D [pg] - Collapsing floor step 1
#_E8C4: db $EA, $EB, $FA, $FB ; 7E [pg] - Collapsing floor step 2
#_E8C8: db $EC, $ED, $FC, $FD ; 7F [pg] - Collapsing floor step 3
#_E8CC: db $00, $CA, $10, $DA ; 80 [p.] - Half-pushed clay block left
#_E8D0: db $CB, $01, $DB, $11 ; 81 [p.] - Half-pushed clay block right
#_E8D4: db $00, $C8, $10, $D8 ; 82 [p.] - Half-pushed lime block left
#_E8D8: db $C9, $01, $D9, $11 ; 83 [p.] - Half-pushed lime block right
#_E8DC: db $00, $EE, $10, $EE ; 84 [p.] - Half-pushed marble block left
#_E8E0: db $EF, $01, $EF, $11 ; 85 [p.] - Half-pushed marble block right
#_E8E4: db $2F, $2F, $2F, $2F ; 86 [..] - Empty - !UNUSED
#_E8E8: db $2F, $2F, $2F, $2F ; 87 [..] - Empty - !UNUSED

;===================================================================================================
; PALETTE DATA
;===================================================================================================
RoomPalettes:
#_E8EC: db $05, $17, $27 ; PALETTE 00
#_E8EF: db $07, $08, $18
#_E8F2: db $05, $18, $37
#_E8F5: db $1B, $27, $30

#_E8F8: db $08, $1B, $38 ; PALETTE 01
#_E8FB: db $07, $06, $16
#_E8FE: db $06, $17, $26
#_E901: db $17, $28, $37

#_E904: db $17, $27, $38 ; PALETTE 02
#_E907: db $09, $08, $18
#_E90A: db $0F, $17, $27
#_E90D: db $16, $25, $34

#_E910: db $17, $27, $37 ; PALETTE 03
#_E913: db $07, $06, $16
#_E916: db $16, $26, $36
#_E919: db $11, $21, $31

#_E91C: db $04, $13, $23 ; PALETTE 04
#_E91F: db $0A, $08, $1B
#_E922: db $3C, $1C, $2C
#_E925: db $15, $25, $35

#_E928: db $07, $17, $26 ; PALETTE 05
#_E92B: db $08, $06, $17
#_E92E: db $17, $28, $37
#_E931: db $08, $00, $37

#_E934: db $00, $10, $28 ; PALETTE 06
#_E937: db $05, $06, $37
#_E93A: db $17, $28, $37
#_E93D: db $18, $29, $38

#_E940: db $00, $10, $20 ; PALETTE 07
#_E943: db $01, $11, $31
#_E946: db $06, $16, $26
#_E949: db $31, $21, $31

#_E94C: db $08, $1B, $26 ; PALETTE 08
#_E94F: db $08, $0B, $00
#_E952: db $08, $1B, $16
#_E955: db $11, $21, $31

#_E958: db $00, $10, $20 ; PALETTE 09
#_E95B: db $11, $21, $31
#_E95E: db $0F, $25, $25
#_E961: db $27, $27, $0F

#_E964: db $08, $16, $27 ; PALETTE 0A
#_E967: db $0B, $07, $17
#_E96A: db $05, $15, $25
#_E96D: db $01, $01, $01

#_E970: db $08, $16, $27 ; PALETTE 0B
#_E973: db $0B, $07, $17
#_E976: db $05, $15, $25
#_E979: db $01, $01, $01

#_E97C: db $01, $0B, $11 ; PALETTE 0C
#_E97F: db $0F, $0B, $01
#_E982: db $05, $15, $25
#_E985: db $0F, $0B, $01

#_E988: db $16, $26, $37 ; PALETTE 0D
#_E98B: db $18, $28, $38
#_E98E: db $04, $25, $36
#_E991: db $05, $14, $25

;===================================================================================================

RoomTheme:

#RoomTheme_patterns:
#_E994: dw .objects_01 ; 01 - ROOM 01
#_E996: dw .objects_02 ; 02 - ROOM 02
#_E998: dw .objects_03 ; 03 - ROOM 04
#_E99A: dw .objects_04 ; 04 - ROOM 05
#_E99C: dw .objects_05 ; 05 - ROOM 06
#_E99E: dw .objects_06 ; 06 - ROOM 08
#_E9A0: dw .objects_07 ; 07 - ROOM 07
#_E9A2: dw .objects_08 ; 08 - ROOM 09, ROOM 15, ROOM 16, ROOM 17, ROOM 18
#_E9A4: dw .objects_09 ; 09 - ROOM 0A, ROOM 13, ROOM 14
#_E9A6: dw .objects_0A ; 0A - ROOM 0B, ROOM 12
#_E9A8: dw .objects_0B ; 0B - ROOM 0C
#_E9AA: dw .objects_0B ; 0C - ROOM 0D
#_E9AC: dw .objects_0D ; 0D - ROOM 0E, ROOM 10
#_E9AE: dw .objects_0E ; 0E - ROOM 0F

#RoomTheme_palettes:
#_E9B0: dw .palettes_01 ; 01 - ROOM 01
#_E9B2: dw .palettes_02 ; 02 - ROOM 02
#_E9B4: dw .palettes_03 ; 03 - ROOM 04
#_E9B6: dw .palettes_04 ; 04 - ROOM 05
#_E9B8: dw .palettes_05 ; 05 - ROOM 06
#_E9BA: dw .palettes_06 ; 06 - ROOM 08
#_E9BC: dw .palettes_07 ; 07 - ROOM 07
#_E9BE: dw .palettes_08 ; 08 - ROOM 09, ROOM 15, ROOM 16, ROOM 17, ROOM 18
#_E9C0: dw .palettes_09 ; 09 - ROOM 0A, ROOM 13, ROOM 14
#_E9C2: dw .palettes_0A ; 0A - ROOM 0B, ROOM 12
#_E9C4: dw .palettes_0B ; 0B - ROOM 0C
#_E9C6: dw .palettes_0B ; 0C - ROOM 0D
#_E9C8: dw .palettes_0D ; 0D - ROOM 0E, ROOM 10
#_E9CA: dw .palettes_0E ; 0E - ROOM 0F

;---------------------------------------------------------------------------------------------------

.objects_01
#_E9CC: db $00, $05, $06, $07 ; 00, 01, 02, 03
#_E9D0: db $08, $09, $0A, $0B ; 04, 05, 06, 07
#_E9D4: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_E9D8: db $03, $40, $60, $62 ; 0C, 0D, 0E, 0F
#_E9DC: db $78, $63, $50, $51 ; 10, 11, 12, 13
#_E9E0: db $3E, $52, $62, $59 ; 14, 15, 16, 17
#_E9E4: db $62, $60, $62, $00 ; 18, 19, 1A, 1B
#_E9E8: db $62, $62, $04, $3F ; 1C, 1D, 1E, 1F
#_E9EC: db $79, $7A, $7B, $80 ; 20, 21, 22, 23
#_E9F0: db $81                ; 24

.palettes_01
#_E9F1: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_E9F2: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_E9F3: db $00 ; 08:0 | 09:0 | 0A:0 | 0B:0
#_E9F4: db $85 ; 0C:1 | 0D:1 | 0E:0 | 0F:2
#_E9F5: db $00 ; 10:0 | 11:0 | 12:0 | 13:0
#_E9F6: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_E9F7: db $62 ; 18:2 | 19:0 | 1A:2 | 1B:1
#_E9F8: db $FA ; 1C:2 | 1D:2 | 1E:3 | 1F:3
#_E9F9: db $40 ; 20:0 | 21:0 | 22:0 | 23:1
#_E9FA: db $01 ; 24:1 | 25:0 | 26:0 | 27:0

;---------------------------------------------------------------------------------------------------

.objects_02
#_E9FB: db $00, $0C, $0D, $0E ; 00, 01, 02, 03
#_E9FF: db $0F, $10, $11, $12 ; 04, 05, 06, 07
#_EA03: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_EA07: db $03, $3E, $64, $66 ; 0C, 0D, 0E, 0F
#_EA0B: db $78, $78, $53, $54 ; 10, 11, 12, 13
#_EA0F: db $3E, $55, $66, $78 ; 14, 15, 16, 17
#_EA13: db $66, $64, $66, $66 ; 18, 19, 1A, 1B
#_EA17: db $64, $66, $04, $3F ; 1C, 1D, 1E, 1F
#_EA1B: db $79, $7A, $7B      ; 20, 21, 22

.palettes_02
#_EA1E: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EA1F: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EA20: db $0A ; 08:2 | 09:2 | 0A:0 | 0B:0
#_EA21: db $01 ; 0C:1 | 0D:0 | 0E:0 | 0F:0
#_EA22: db $0A ; 10:2 | 11:2 | 12:0 | 13:0
#_EA23: db $80 ; 14:0 | 15:0 | 16:0 | 17:2
#_EA24: db $00 ; 18:0 | 19:0 | 1A:0 | 1B:0
#_EA25: db $E0 ; 1C:0 | 1D:0 | 1E:2 | 1F:3
#_EA26: db $2A ; 20:2 | 21:2 | 22:2 | 23:0

;---------------------------------------------------------------------------------------------------

.objects_03
#_EA27: db $00, $13, $14, $15 ; 00, 01, 02, 03
#_EA2B: db $16, $17, $18, $19 ; 04, 05, 06, 07
#_EA2F: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_EA33: db $03, $68, $69, $67 ; 0C, 0D, 0E, 0F
#_EA37: db $78, $68, $56, $57 ; 10, 11, 12, 13
#_EA3B: db $3E, $58, $3E, $78 ; 14, 15, 16, 17
#_EA3F: db $67, $68, $6A, $6A ; 18, 19, 1A, 1B
#_EA43: db $67, $67, $04, $3F ; 1C, 1D, 1E, 1F
#_EA47: db $79, $7A, $7B      ; 20, 21, 22

.palettes_03
#_EA4A: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EA4B: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EA4C: db $00 ; 08:0 | 09:0 | 0A:0 | 0B:0
#_EA4D: db $01 ; 0C:1 | 0D:0 | 0E:0 | 0F:0
#_EA4E: db $02 ; 10:2 | 11:0 | 12:0 | 13:0
#_EA4F: db $80 ; 14:0 | 15:0 | 16:0 | 17:2
#_EA50: db $00 ; 18:0 | 19:0 | 1A:0 | 1B:0
#_EA51: db $C0 ; 1C:0 | 1D:0 | 1E:0 | 1F:3
#_EA52: db $2A ; 20:2 | 21:2 | 22:2 | 23:0

;---------------------------------------------------------------------------------------------------

.objects_04
#_EA53: db $00, $05, $06, $07 ; 00, 01, 02, 03
#_EA57: db $08, $09, $0A, $0B ; 04, 05, 06, 07
#_EA5B: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_EA5F: db $03, $65, $64, $6C ; 0C, 0D, 0E, 0F
#_EA63: db $5F, $63, $59, $5A ; 10, 11, 12, 13
#_EA67: db $3E, $5B, $6C, $60 ; 14, 15, 16, 17
#_EA6B: db $6C, $6C, $00, $00 ; 18, 19, 1A, 1B
#_EA6F: db $6C, $6C, $04, $3F ; 1C, 1D, 1E, 1F
#_EA73: db $79, $7A, $7B, $82 ; 20, 21, 22, 23
#_EA77: db $83                ; 24

.palettes_04
#_EA78: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EA79: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EA7A: db $00 ; 08:0 | 09:0 | 0A:0 | 0B:0
#_EA7B: db $01 ; 0C:1 | 0D:0 | 0E:0 | 0F:0
#_EA7C: db $08 ; 10:0 | 11:2 | 12:0 | 13:0
#_EA7D: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EA7E: db $50 ; 18:0 | 19:0 | 1A:1 | 1B:1
#_EA7F: db $F0 ; 1C:0 | 1D:0 | 1E:3 | 1F:3
#_EA80: db $40 ; 20:0 | 21:0 | 22:0 | 23:1
#_EA81: db $01 ; 24:1 | 25:0 | 26:0 | 27:0

;---------------------------------------------------------------------------------------------------

.objects_05
#_EA82: db $00, $1A, $1B, $1C ; 00, 01, 02, 03
#_EA86: db $1D, $1E, $1F, $20 ; 04, 05, 06, 07
#_EA8A: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_EA8E: db $03, $64, $6E, $6D ; 0C, 0D, 0E, 0F
#_EA92: db $77, $64, $53, $54 ; 10, 11, 12, 13
#_EA96: db $3E, $55, $6D, $64 ; 14, 15, 16, 17
#_EA9A: db $64, $64, $64, $3E ; 18, 19, 1A, 1B
#_EA9E: db $64, $64, $04, $3F ; 1C, 1D, 1E, 1F
#_EAA2: db $7D, $7E, $7F      ; 20, 21, 22

.palettes_05
#_EAA5: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EAA6: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EAA7: db $00 ; 08:0 | 09:0 | 0A:0 | 0B:0
#_EAA8: db $01 ; 0C:1 | 0D:0 | 0E:0 | 0F:0
#_EAA9: db $00 ; 10:0 | 11:0 | 12:0 | 13:0
#_EAAA: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EAAB: db $00 ; 18:0 | 19:0 | 1A:0 | 1B:0
#_EAAC: db $F0 ; 1C:0 | 1D:0 | 1E:3 | 1F:3
#_EAAD: db $00 ; 20:0 | 21:0 | 22:0 | 23:0

;---------------------------------------------------------------------------------------------------

.objects_06
#_EAAE: db $00, $05, $06, $07 ; 00, 01, 02, 03
#_EAB2: db $08, $09, $0A, $0B ; 04, 05, 06, 07
#_EAB6: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_EABA: db $03, $41, $61, $66 ; 0C, 0D, 0E, 0F
#_EABE: db $3E, $7D, $60, $5C ; 10, 11, 12, 13
#_EAC2: db $7D, $3E, $66, $60 ; 14, 15, 16, 17
#_EAC6: db $66, $00, $7D, $7D ; 18, 19, 1A, 1B
#_EACA: db $66, $3E, $04, $3F ; 1C, 1D, 1E, 1F
#_EACE: db $3E, $3E, $3E, $84 ; 20, 21, 22, 23
#_EAD2: db $85                ; 24

.palettes_06
#_EAD3: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EAD4: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EAD5: db $0A ; 08:2 | 09:2 | 0A:0 | 0B:0
#_EAD6: db $85 ; 0C:1 | 0D:1 | 0E:0 | 0F:2
#_EAD7: db $CC ; 10:0 | 11:3 | 12:0 | 13:3
#_EAD8: db $23 ; 14:3 | 15:0 | 16:2 | 17:0
#_EAD9: db $F6 ; 18:2 | 19:1 | 1A:3 | 1B:3
#_EADA: db $22 ; 1C:2 | 1D:0 | 1E:2 | 1F:0
#_EADB: db $40 ; 20:0 | 21:0 | 22:0 | 23:1
#_EADC: db $01 ; 24:1 | 25:0 | 26:0 | 27:0

;---------------------------------------------------------------------------------------------------

.objects_07
#_EADD: db $00, $21, $22, $23 ; 00, 01, 02, 03
#_EAE1: db $24, $25, $26, $27 ; 04, 05, 06, 07
#_EAE5: db $01, $02, $3E, $3E ; 08, 09, 0A, 0B
#_EAE9: db $03, $50, $70, $6F ; 0C, 0D, 0E, 0F
#_EAED: db $50, $6F, $50, $51 ; 10, 11, 12, 13
#_EAF1: db $3E, $52, $76, $50 ; 14, 15, 16, 17
#_EAF5: db $6F, $50, $3E, $3E ; 18, 19, 1A, 1B
#_EAF9: db $6F, $6F, $04, $3F ; 1C, 1D, 1E, 1F

.palettes_07
#_EAFD: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EAFE: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EAFF: db $0F ; 08:3 | 09:3 | 0A:0 | 0B:0
#_EB00: db $01 ; 0C:1 | 0D:0 | 0E:0 | 0F:0
#_EB01: db $00 ; 10:0 | 11:0 | 12:0 | 13:0
#_EB02: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EB03: db $00 ; 18:0 | 19:0 | 1A:0 | 1B:0
#_EB04: db $E0 ; 1C:0 | 1D:0 | 1E:2 | 1F:3

;---------------------------------------------------------------------------------------------------

.objects_08
#_EB05: db $00, $28, $29, $2A ; 00, 01, 02, 03
#_EB09: db $2B, $2C, $2D, $2E ; 04, 05, 06, 07
#_EB0D: db $5D, $5E, $2F, $0C ; 08, 09, 0A, 0B
#_EB11: db $7F, $71, $66, $72 ; 0C, 0D, 0E, 0F
#_EB15: db $3E, $7E, $76, $5E ; 10, 11, 12, 13
#_EB19: db $3E, $7E, $72, $7E ; 14, 15, 16, 17
#_EB1D: db $72, $66, $71, $7E ; 18, 19, 1A, 1B

.palettes_08
#_EB21: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EB22: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EB23: db $15 ; 08:1 | 09:1 | 0A:1 | 0B:0
#_EB24: db $00 ; 0C:0 | 0D:0 | 0E:0 | 0F:0
#_EB25: db $50 ; 10:0 | 11:0 | 12:1 | 13:1
#_EB26: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EB27: db $00 ; 18:0 | 19:0 | 1A:0 | 1B:0

;---------------------------------------------------------------------------------------------------

.objects_09
#_EB28: db $00, $30, $31, $32 ; 00, 01, 02, 03
#_EB2C: db $33, $3E, $3E, $3E ; 04, 05, 06, 07
#_EB30: db $3E, $3E, $3E, $3E ; 08, 09, 0A, 0B
#_EB34: db $3E, $3E, $63, $74 ; 0C, 0D, 0E, 0F
#_EB38: db $3E, $3E, $3E, $3E ; 10, 11, 12, 13
#_EB3C: db $3E, $3E, $3E, $63 ; 14, 15, 16, 17
#_EB40: db $63, $63, $6C, $3E ; 18, 19, 1A, 1B
#_EB44: db $63, $3E, $04      ; 1C, 1D, 1E

.palettes_09
#_EB47: db $56 ; 00:2 | 01:1 | 02:1 | 03:1
#_EB48: db $01 ; 04:1 | 05:0 | 06:0 | 07:0
#_EB49: db $00 ; 08:0 | 09:0 | 0A:0 | 0B:0
#_EB4A: db $00 ; 0C:0 | 0D:0 | 0E:0 | 0F:0
#_EB4B: db $00 ; 10:0 | 11:0 | 12:0 | 13:0
#_EB4C: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EB4D: db $18 ; 18:0 | 19:2 | 1A:1 | 1B:0
#_EB4E: db $30 ; 1C:0 | 1D:0 | 1E:3 | 1F:0

;---------------------------------------------------------------------------------------------------

.objects_0A
#_EB4F: db $3E, $3E, $4A, $4B ; 00, 01, 02, 03
#_EB53: db $4C, $4A, $4B, $4C ; 04, 05, 06, 07
#_EB57: db $4D, $4E, $4F, $4D ; 08, 09, 0A, 0B
#_EB5B: db $4E, $4F, $5C, $6C ; 0C, 0D, 0E, 0F
#_EB5F: db $78, $6C, $3E, $3E ; 10, 11, 12, 13
#_EB63: db $3E, $3E, $6C, $5C ; 14, 15, 16, 17
#_EB67: db $6C, $6C, $6C, $3E ; 18, 19, 1A, 1B
#_EB6B: db $6C, $6C, $04, $3F ; 1C, 1D, 1E, 1F
#_EB6F: db $79, $7A, $7B      ; 20, 21, 22

.palettes_0A
#_EB72: db $F0 ; 00:0 | 01:0 | 02:3 | 03:3
#_EB73: db $AB ; 04:3 | 05:2 | 06:2 | 07:2
#_EB74: db $BF ; 08:3 | 09:3 | 0A:3 | 0B:2
#_EB75: db $0A ; 0C:2 | 0D:2 | 0E:0 | 0F:0
#_EB76: db $01 ; 10:1 | 11:0 | 12:0 | 13:0
#_EB77: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EB78: db $00 ; 18:0 | 19:0 | 1A:0 | 1B:0
#_EB79: db $50 ; 1C:0 | 1D:0 | 1E:1 | 1F:1
#_EB7A: db $15 ; 20:1 | 21:1 | 22:1 | 23:0

;---------------------------------------------------------------------------------------------------

.objects_0B
#_EB7B: db $00, $30, $31, $32 ; 00, 01, 02, 03
#_EB7F: db $33, $34, $35, $3E ; 04, 05, 06, 07
#_EB83: db $3E, $3E, $75, $3E ; 08, 09, 0A, 0B
#_EB87: db $3E, $71, $66, $72 ; 0C, 0D, 0E, 0F
#_EB8B: db $3E, $3E, $62, $75 ; 10, 11, 12, 13
#_EB8F: db $3E, $3E, $72, $62 ; 14, 15, 16, 17
#_EB93: db $30, $66, $66, $66 ; 18, 19, 1A, 1B
#_EB97: db $66, $3E, $04      ; 1C, 1D, 1E

.palettes_0B
#_EB9A: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EB9B: db $15 ; 04:1 | 05:1 | 06:1 | 07:0
#_EB9C: db $10 ; 08:0 | 09:0 | 0A:1 | 0B:0
#_EB9D: db $00 ; 0C:0 | 0D:0 | 0E:0 | 0F:0
#_EB9E: db $00 ; 10:0 | 11:0 | 12:0 | 13:0
#_EB9F: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EBA0: db $01 ; 18:1 | 19:0 | 1A:0 | 1B:0
#_EBA1: db $20 ; 1C:0 | 1D:0 | 1E:2 | 1F:0

;---------------------------------------------------------------------------------------------------

.objects_0D
#_EBA2: db $00, $36, $37, $38 ; 00, 01, 02, 03
#_EBA6: db $39, $3A, $3B, $3C ; 04, 05, 06, 07
#_EBAA: db $36, $3D, $3D, $3E ; 08, 09, 0A, 0B
#_EBAE: db $3E, $6F, $7D, $6F ; 0C, 0D, 0E, 0F
#_EBB2: db $3E, $6F, $3E, $3E ; 10, 11, 12, 13
#_EBB6: db $3E, $3E, $3E, $7D ; 14, 15, 16, 17
#_EBBA: db $7D, $6F, $3D, $3E ; 18, 19, 1A, 1B
#_EBBE: db $7D, $7D, $04, $3F ; 1C, 1D, 1E, 1F

.palettes_0D
#_EBC2: db $55 ; 00:1 | 01:1 | 02:1 | 03:1
#_EBC3: db $55 ; 04:1 | 05:1 | 06:1 | 07:1
#_EBC4: db $30 ; 08:0 | 09:0 | 0A:3 | 0B:0
#_EBC5: db $0C ; 0C:0 | 0D:3 | 0E:0 | 0F:0
#_EBC6: db $0C ; 10:0 | 11:3 | 12:0 | 13:0
#_EBC7: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EBC8: db $34 ; 18:0 | 19:1 | 1A:3 | 1B:0
#_EBC9: db $A0 ; 1C:0 | 1D:0 | 1E:2 | 1F:2

;---------------------------------------------------------------------------------------------------

.objects_0E
#_EBCA: db $3E, $43, $44, $45 ; 00, 01, 02, 03
#_EBCE: db $46, $47, $48, $43 ; 04, 05, 06, 07
#_EBD2: db $44, $45, $46, $48 ; 08, 09, 0A, 0B
#_EBD6: db $47, $6B, $69, $67 ; 0C, 0D, 0E, 0F
#_EBDA: db $3E, $67, $56, $57 ; 10, 11, 12, 13
#_EBDE: db $3E, $58, $3E, $56 ; 14, 15, 16, 17
#_EBE2: db $67, $67, $3E, $56 ; 18, 19, 1A, 1B
#_EBE6: db $67, $49, $04, $3F ; 1C, 1D, 1E, 1F

.palettes_0E
#_EBEA: db $A8 ; 00:0 | 01:2 | 02:2 | 03:2
#_EBEB: db $EA ; 04:2 | 05:2 | 06:2 | 07:3
#_EBEC: db $FF ; 08:3 | 09:3 | 0A:3 | 0B:3
#_EBED: db $03 ; 0C:3 | 0D:0 | 0E:0 | 0F:0
#_EBEE: db $00 ; 10:0 | 11:0 | 12:0 | 13:0
#_EBEF: db $00 ; 14:0 | 15:0 | 16:0 | 17:0
#_EBF0: db $CC ; 18:0 | 19:3 | 1A:0 | 1B:3
#_EBF1: db $58 ; 1C:0 | 1D:2 | 1E:1 | 1F:1

;===================================================================================================
; OWOBJ
;===================================================================================================
OverworldObjectTiles:
#_EBF2: db $20, $21, $30, $31 ; 00 - window
#_EBF6: db $22, $23, $32, $33 ; 01 - door
#_EBFA: db $07, $07, $07, $07 ; 02 - hammerable brick wall
#_EBFE: db $07, $4A, $07, $4A ; 03 - hammerable tower wall inner right
#_EC02: db $04, $05, $04, $05 ; 04 - tower wall outer left
#_EC06: db $06, $07, $06, $07 ; 05 - tower wall inner left
#_EC0A: db $4B, $4E, $4B, $4E ; 06 - tower wall outer right shaded
#_EC0E: db $C4, $C5, $1E, $1F ; 07 - tower solid platform inner right
#_EC12: db $C0, $C1, $C2, $C3 ; 08 - solid block
#_EC16: db $C4, $C5, $1E, $1E ; 09 - solid ledge
#_EC1A: db $C4, $C5, $1E, $1F ; 0A - solid platform
#_EC1E: db $C4, $C5, $47, $1E ; 0B - solid ledge left edge
#_EC22: db $06, $0D, $06, $1D ; 0C - tower wall with platform shadow
#_EC26: db $07, $4A, $07, $4A ; 0D - tower wall inner right
#_EC2A: db $4B, $4C, $4B, $4C ; 0E - tower wall outer right lit
#_EC2E: db $C4, $C5, $82, $1F ; 0F - tower solid platform inner left
#_EC32: db $07, $07, $07, $06 ; 10 - brick wall with 1/4 dark bricks ▗
#_EC36: db $07, $06, $06, $06 ; 11 - brick wall with 3/4 dark bricks ▟
#_EC3A: db $E0, $E1, $F0, $F1 ; 12 - well left
#_EC3E: db $E2, $E3, $F2, $F3 ; 13 - well right
#_EC42: db $07, $48, $07, $07 ; 14 - brick wall with top-right tree shadow
#_EC46: db $D4, $D4, $D2, $D3 ; 15 - tree top
#_EC4A: db $E4, $E5, $F4, $F5 ; 16 - tree middle
#_EC4E: db $E6, $E7, $F6, $F7 ; 17 - tree trunk
#_EC52: db $07, $0D, $4D, $4E ; 18 - big gap
#_EC56: db $17, $0D, $46, $4E ; 19 - big gap left side
#_EC5A: db $07, $15, $4D, $47 ; 1A - big gap right side
#_EC5E: db $0C, $0B, $1C, $1B ; 1B - brick wall with door edges on both sides
#_EC62: db $07, $4D, $C4, $C5 ; 1C - solid platform niche
#_EC66: db $C5, $C4, $07, $07 ; 1D - solid brick ceiling
#_EC6A: db $17, $4D, $C4, $C5 ; 1E - solid platform niche with left corner
#_EC6E: db $26, $27, $36, $37 ; 1F - grated window
#_EC72: db $16, $07, $17, $07 ; 20 - brick wall left edge
#_EC76: db $07, $18, $07, $19 ; 21 - brick wall right edge
#_EC7A: db $07, $28, $07, $38 ; 22 - door sopraporte left
#_EC7E: db $29, $2A, $39, $3A ; 23 - door sopraporte middle
#_EC82: db $2B, $07, $3B, $07 ; 24 - door sopraporte right
#_EC86: db $07, $0B, $07, $1B ; 25 - window left edge
#_EC8A: db $0C, $07, $1C, $07 ; 26 - window right edge
#_EC8E: db $26, $27, $36, $37 ; 27 - tower grated window
#_EC92: db $07, $0D, $07, $1D ; 28 - brick wall with right shadow
#_EC96: db $2E, $2F, $3E, $3F ; 29 - passable brick
#_EC9A: db $07, $2C, $07, $3C ; 2A - door left edge
#_EC9E: db $07, $07, $07, $07 ; 2B - brick wall
#_ECA2: db $2D, $07, $3D, $07 ; 2C - door right edge
#_ECA6: db $4F, $07, $01, $4F ; 2D - brick wall corner ◥
#_ECAA: db $07, $49, $49, $01 ; 2E - brick wall corner ◤
#_ECAE: db $D0, $D1, $08, $09 ; 2F - grassy ground
#_ECB2: db $07, $07, $0E, $0F ; 30 - window top
#_ECB6: db $07, $0D, $0E, $1A ; 31 - window top with platform shadow
#_ECBA: db $01, $01, $01, $01 ; 32 - empty sky
#_ECBE: db $01, $10, $01, $10 ; 33 - black right edge
#_ECC2: db $01, $0A, $01, $80 ; 34 - spire tip left
#_ECC6: db $11, $01, $81, $01 ; 35 - spire tip right
#_ECCA: db $94, $95, $A0, $A1 ; 36 - spire middle left
#_ECCE: db $01, $90, $01, $92 ; 37 - spire top left
#_ECD2: db $91, $01, $93, $01 ; 38 - spire top right
#_ECD6: db $96, $97, $A2, $A3 ; 39 - spire middle right
#_ECDA: db $01, $94, $12, $B0 ; 3A - spire base outer left
#_ECDE: db $A4, $A5, $B1, $B3 ; 3B - spire base inner left
#_ECE2: db $A6, $A7, $B5, $B6 ; 3C - west spire base inner right (castle shadow)
#_ECE6: db $97, $10, $B7, $13 ; 3D - west spire base outer right (castle shadow)
#_ECEA: db $A6, $A7, $B5, $B2 ; 3E - east spire base inner right (lit)
#_ECEE: db $97, $01, $B4, $12 ; 3F - east spire base outer right (lit)

;---------------------------------------------------------------------------------------------------
; Only used in animations
;---------------------------------------------------------------------------------------------------
#_ECF2: db $40, $41, $50, $51 ; 40 - window opening
#_ECF6: db $60, $61, $70, $71 ; 41 - window completely open
#_ECFA: db $42, $43, $52, $53 ; 42 - door opening
#_ECFE: db $62, $63, $72, $73 ; 43 - door completely open
#_ED02: db $24, $25, $34, $35 ; 44 - wall opening
#_ED06: db $44, $45, $54, $55 ; 45 - wall completely open
#_ED0A: db $24, $25, $34, $35 ; 46 - tower wall opening
#_ED0E: db $44, $45, $54, $55 ; 47 - tower wall completely open

;===================================================================================================
; ID: palette
;   0 - red
;   1 - green
;   2 - red with green
;   3 - red with blue
;===================================================================================================
OverworldCastleObjectPalettes:
#_ED12: db $40 ; 00: 0 | 01: 0 | 02: 0 | 03: 1
#_ED13: db $55 ; 04: 1 | 05: 1 | 06: 1 | 07: 1
#_ED14: db $00 ; 08: 0 | 09: 0 | 0A: 0 | 0B: 0
#_ED15: db $55 ; 0C: 1 | 0D: 1 | 0E: 1 | 0F: 1
#_ED16: db $00 ; 10: 0 | 11: 0 | 12: 0 | 13: 0
#_ED17: db $28 ; 14: 0 | 15: 2 | 16: 2 | 17: 0
#_ED18: db $00 ; 18: 0 | 19: 0 | 1A: 0 | 1B: 0
#_ED19: db $00 ; 1C: 0 | 1D: 0 | 1E: 0 | 1F: 0
#_ED1A: db $00 ; 20: 0 | 21: 0 | 22: 0 | 23: 0
#_ED1B: db $40 ; 24: 0 | 25: 0 | 26: 0 | 27: 1
#_ED1C: db $00 ; 28: 0 | 29: 0 | 2A: 0 | 2B: 0
#_ED1D: db $BC ; 2C: 0 | 2D: 3 | 2E: 3 | 2F: 2
#_ED1E: db $F0 ; 30: 0 | 31: 0 | 32: 3 | 33: 3
#_ED1F: db $AF ; 34: 3 | 35: 3 | 36: 2 | 37: 2
#_ED20: db $AF ; 38: 3 | 39: 3 | 3A: 2 | 3B: 2
#_ED21: db $FF ; 3C: 3 | 3D: 3 | 3E: 3 | 3F: 3
#_ED22: db $00 ; 40: 0 | 41: 0 | 42: 0 | 43: 0
#_ED23: db $50 ; 44: 0 | 45: 0 | 46: 1 | 47: 1

;===================================================================================================

HandleSFX:
#_ED24: LDA.b $E6
#_ED26: BMI .playing_sfx
#_ED28: BEQ .no_new_sfx

#_ED2A: CMP.b #$11 ; SFX 11
#_ED2C: BEQ .low_priority_sfx

#_ED2E: CMP.b #$01 ; SFX 01
#_ED30: BEQ .low_priority_sfx

#_ED32: CMP.b #$02 ; SFX 02
#_ED34: BNE .allow_sfx

.low_priority_sfx
#_ED36: LDA.b $E7
#_ED38: AND.b #$7F
#_ED3A: BEQ .allow_sfx

#_ED3C: CMP.b $E6
#_ED3E: BEQ .allow_sfx

#_ED40: LDA.b $E7
#_ED42: ORA.b #$80
#_ED44: STA.b $E6

#_ED46: JMP .playing_sfx

;---------------------------------------------------------------------------------------------------

.allow_sfx
#_ED49: LDA.b $E6

.no_new_sfx
#_ED4B: PHA

#_ED4C: JSR SetSFXVolumes

#_ED4F: PLA
#_ED50: BEQ .no_sfx_to_play

#_ED52: TAX

#_ED53: LDA.b #SoundEffectData>>0
#_ED55: STA.b $EC
#_ED57: LDA.b #SoundEffectData>>8
#_ED59: STA.b $ED

#_ED5B: DEX
#_ED5C: BEQ .is_sfx01

#_ED5E: LDY.b #$00
#_ED60: STY.b $EE

.search
#_ED62: LDA.b ($EC),Y
#_ED64: CMP.b #$0F
#_ED66: BNE .not_end_of_sfx

#_ED68: INC.b $EE

.not_end_of_sfx
#_ED6A: INC.b $EC
#_ED6C: BNE .no_overflow

#_ED6E: INC.b $ED

.no_overflow
#_ED70: CPX.b $EE
#_ED72: BNE .search

;---------------------------------------------------------------------------------------------------

.is_sfx01
#_ED74: LDY.b #$02
#_ED76: STY.b $F1

#_ED78: LDY.b #$00
#_ED7A: STY.b $EE

#_ED7C: LDA.b ($EC),Y
#_ED7E: TAX

#_ED7F: AND.b #$1F
#_ED81: STA.b $EF
#_ED83: TXA

#_ED84: AND.b #$C0
#_ED86: STA.b $F0

#_ED88: INC.b $EE

#_ED8A: JSR NextSFXByte

#_ED8D: LDA.b $EF
#_ED8F: AND.b #$10
#_ED91: LSR A
#_ED92: LSR A
#_ED93: LSR A
#_ED94: TAX

#_ED95: LDA.b #$01
#_ED97: STA.b $E9,X

;---------------------------------------------------------------------------------------------------

.no_sfx_to_play
#_ED99: LDA.b $E6
#_ED9B: STA.b $E7

#_ED9D: ORA.b #$80
#_ED9F: STA.b $E6

#_EDA1: RTS

;---------------------------------------------------------------------------------------------------

.playing_sfx
#_EDA2: LDA.b $E6
#_EDA4: CMP.b #$80
#_EDA6: BEQ EXIT_EDE6

#_EDA8: JMP NextSFXByte

;===================================================================================================

NextSFXByte:
#_EDAB: LDX.b $F1
#_EDAD: INX

#_EDAE: CPX.b #$03
#_EDB0: BCC .dont_rollover

#_EDB2: LDX.b #$00

.dont_rollover
#_EDB4: STX.b $F1
#_EDB6: BNE EXIT_EDE6

#_EDB8: LDY.b $EE

#_EDBA: LDA.b ($EC),Y
#_EDBC: CMP.b #$0F
#_EDBE: BEQ TerminateSFX

#_EDC0: INC.b $EE

#_EDC2: TAX

#_EDC3: LDA.b $EF
#_EDC5: AND.b #$10
#_EDC7: BNE .play_noise

.play_square
#_EDC9: TXA
#_EDCA: AND.b #$0F
#_EDCC: ORA.b #$30
#_EDCE: ORA.b $F0
#_EDD0: STA.w SQ2VOL

#_EDD3: TXA
#_EDD4: AND.b #$F0
#_EDD6: ORA.b #$0F
#_EDD8: STA.w SQ2LO

#_EDDB: LDA.b $E6
#_EDDD: BMI EXIT_EDE6

#_EDDF: LDA.b $EF
#_EDE1: AND.b #$07
#_EDE3: STA.w SQ2HI

;---------------------------------------------------------------------------------------------------

#EXIT_EDE6:
#_EDE6: RTS

;---------------------------------------------------------------------------------------------------

.play_noise
#_EDE7: TXA
#_EDE8: AND.b #$0F
#_EDEA: ORA.b #$30
#_EDEC: STA.w NOISEVOL

#_EDEF: TXA
#_EDF0: AND.b #$F0
#_EDF2: LSR A
#_EDF3: LSR A
#_EDF4: LSR A
#_EDF5: LSR A
#_EDF6: STA.w NOISEPD

#_EDF9: LDA.b #$08
#_EDFB: STA.w NOISELN

#_EDFE: RTS

;===================================================================================================

TerminateSFX:
#_EDFF: LDA.b #$00
#_EE01: STA.b $E6
#_EE03: STA.b $E7

#_EE05: STA.b $E9
#_EE07: STA.b $EB

#_EE09: STA.w SQ2LO
#_EE0C: STA.w SQ2HI

#_EE0F: BEQ SetSFXVolumes

;===================================================================================================

MuteSFX:
#_EE11: LDA.b #$00
#_EE13: LDX.b #$03

.next
#_EE15: STA.b $E8,X

#_EE17: DEX
#_EE18: BPL .next

#_EE1A: STA.w TRILINEAR

#_EE1D: LDA.b #$10
#_EE1F: STA.w SQ1VOL

#_EE22: LDA.b #$0F
#_EE24: STA.w SNDCHN

;===================================================================================================

SetSFXVolumes:
#_EE27: LDA.b #$10
#_EE29: STA.w SQ2VOL
#_EE2C: STA.w NOISEVOL

#_EE2F: RTS

;===================================================================================================
;===================================================================================================
;===================================================================================================

SoundEffectData:

;---------------------------------------------------------------------------------------------------
; SFX 01
;---------------------------------------------------------------------------------------------------
.sfx_01
#_EE30: db $80 ; square 2, base volume: $80, freq hi: $00
#_EE31: db $FE ; v:BE f:00FF
#_EE32: db $CE ; v:BE f:00CF
#_EE33: db $AE ; v:BE f:00AF
#_EE34: db $9E ; v:BE f:009F
#_EE35: db $8E ; v:BE f:008F
#_EE36: db $7E ; v:BE f:007F
#_EE37: db $6E ; v:BE f:006F
#_EE38: db $5E ; v:BE f:005F
#_EE39: db $49 ; v:B9 f:004F
#_EE3A: db $39 ; v:B9 f:003F
#_EE3B: db $29 ; v:B9 f:002F
#_EE3C: db $45 ; v:B5 f:004F
#_EE3D: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 02
;---------------------------------------------------------------------------------------------------
.sfx_02
#_EE3E: db $40 ; square 2, base volume: $40, freq hi: $00
#_EE3F: db $FE ; v:7E f:00FF
#_EE40: db $DD ; v:7D f:00DF
#_EE41: db $CC ; v:7C f:00CF
#_EE42: db $BA ; v:7A f:00BF
#_EE43: db $A9 ; v:79 f:00AF
#_EE44: db $98 ; v:78 f:009F
#_EE45: db $87 ; v:77 f:008F
#_EE46: db $66 ; v:76 f:006F
#_EE47: db $55 ; v:75 f:005F
#_EE48: db $44 ; v:74 f:004F
#_EE49: db $32 ; v:72 f:003F
#_EE4A: db $21 ; v:71 f:002F
#_EE4B: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 03
;---------------------------------------------------------------------------------------------------
.sfx_03
#_EE4C: db $80 ; square 2, base volume: $80, freq hi: $00
#_EE4D: db $FF ; v:BF f:00FF
#_EE4E: db $CD ; v:BD f:00CF
#_EE4F: db $9B ; v:BB f:009F
#_EE50: db $69 ; v:B9 f:006F
#_EE51: db $38 ; v:B8 f:003F
#_EE52: db $00 ; v:B0 f:000F
#_EE53: db $36 ; v:B6 f:003F
#_EE54: db $00 ; v:B0 f:000F
#_EE55: db $34 ; v:B4 f:003F
#_EE56: db $00 ; v:B0 f:000F
#_EE57: db $33 ; v:B3 f:003F
#_EE58: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 04
;---------------------------------------------------------------------------------------------------
.sfx_04
#_EE59: db $10 ; noise
#_EE5A: db $1F ; v:3F f:0801
#_EE5B: db $3D ; v:3D f:0803
#_EE5C: db $5B ; v:3B f:0805
#_EE5D: db $76 ; v:36 f:0807
#_EE5E: db $A5 ; v:35 f:080A
#_EE5F: db $B4 ; v:34 f:080B
#_EE60: db $C3 ; v:33 f:080C
#_EE61: db $D2 ; v:32 f:080D
#_EE62: db $E1 ; v:31 f:080E
#_EE63: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 05
;---------------------------------------------------------------------------------------------------
.sfx_05
#_EE64: db $81 ; square 2, base volume: $80, freq hi: $01
#_EE65: db $8F ; v:BF f:018F
#_EE66: db $00 ; v:B0 f:010F
#_EE67: db $0E ; v:BE f:010F
#_EE68: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 06
;---------------------------------------------------------------------------------------------------
.sfx_06
#_EE69: db $10 ; noise
#_EE6A: db $83 ; v:33 f:0808
#_EE6B: db $86 ; v:36 f:0808
#_EE6C: db $89 ; v:39 f:0808
#_EE6D: db $8C ; v:3C f:0808
#_EE6E: db $8C ; v:3C f:0808
#_EE6F: db $8A ; v:3A f:0808
#_EE70: db $87 ; v:37 f:0808
#_EE71: db $85 ; v:35 f:0808
#_EE72: db $82 ; v:32 f:0808
#_EE73: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 07
;---------------------------------------------------------------------------------------------------
.sfx_07
#_EE74: db $10 ; noise
#_EE75: db $9F ; v:3F f:0809
#_EE76: db $AA ; v:3A f:080A
#_EE77: db $A4 ; v:34 f:080A
#_EE78: db $BC ; v:3C f:080B
#_EE79: db $C8 ; v:38 f:080C
#_EE7A: db $C2 ; v:32 f:080C
#_EE7B: db $DA ; v:3A f:080D
#_EE7C: db $E5 ; v:35 f:080E
#_EE7D: db $E1 ; v:31 f:080E
#_EE7E: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 08
;---------------------------------------------------------------------------------------------------
.sfx_08
#_EE7F: db $83 ; square 2, base volume: $80, freq hi: $03
#_EE80: db $FD ; v:BD f:03FF
#_EE81: db $00 ; v:B0 f:030F
#_EE82: db $4F ; v:BF f:034F
#_EE83: db $CC ; v:BC f:03CF
#_EE84: db $D9 ; v:B9 f:03DF
#_EE85: db $E6 ; v:B6 f:03EF
#_EE86: db $F5 ; v:B5 f:03FF
#_EE87: db $E4 ; v:B4 f:03EF
#_EE88: db $F4 ; v:B4 f:03FF
#_EE89: db $E3 ; v:B3 f:03EF
#_EE8A: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 09
;---------------------------------------------------------------------------------------------------
.sfx_09
#_EE8B: db $40 ; square 2, base volume: $40, freq hi: $00
#_EE8C: db $8F ; v:7F f:008F
#_EE8D: db $6F ; v:7F f:006F
#_EE8E: db $4F ; v:7F f:004F
#_EE8F: db $8A ; v:7A f:008F
#_EE90: db $6A ; v:7A f:006F
#_EE91: db $4A ; v:7A f:004F
#_EE92: db $86 ; v:76 f:008F
#_EE93: db $66 ; v:76 f:006F
#_EE94: db $46 ; v:76 f:004F
#_EE95: db $83 ; v:73 f:008F
#_EE96: db $63 ; v:73 f:006F
#_EE97: db $43 ; v:73 f:004F
#_EE98: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 0A
;---------------------------------------------------------------------------------------------------
.sfx_0A
#_EE99: db $40 ; square 2, base volume: $40, freq hi: $00
#_EE9A: db $2F ; v:7F f:002F
#_EE9B: db $4E ; v:7E f:004F
#_EE9C: db $6D ; v:7D f:006F
#_EE9D: db $8C ; v:7C f:008F
#_EE9E: db $AB ; v:7B f:00AF
#_EE9F: db $29 ; v:79 f:002F
#_EEA0: db $48 ; v:78 f:004F
#_EEA1: db $67 ; v:77 f:006F
#_EEA2: db $86 ; v:76 f:008F
#_EEA3: db $A5 ; v:75 f:00AF
#_EEA4: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 0B
;---------------------------------------------------------------------------------------------------
.sfx_0B
#_EEA5: db $00 ; square 2, base volume: $00, freq hi: $00
#_EEA6: db $0E ; v:3E f:000F
#_EEA7: db $2E ; v:3E f:002F
#_EEA8: db $4E ; v:3E f:004F
#_EEA9: db $2B ; v:3B f:002F
#_EEAA: db $4B ; v:3B f:004F
#_EEAB: db $6B ; v:3B f:006F
#_EEAC: db $48 ; v:38 f:004F
#_EEAD: db $78 ; v:38 f:007F
#_EEAE: db $A8 ; v:38 f:00AF
#_EEAF: db $75 ; v:35 f:007F
#_EEB0: db $A5 ; v:35 f:00AF
#_EEB1: db $C5 ; v:35 f:00CF
#_EEB2: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 0C
;---------------------------------------------------------------------------------------------------
.sfx_0C
#_EEB3: db $81 ; square 2, base volume: $80, freq hi: $01
#_EEB4: db $5A ; v:BA f:015F
#_EEB5: db $4C ; v:BC f:014F
#_EEB6: db $3E ; v:BE f:013F
#_EEB7: db $2F ; v:BF f:012F
#_EEB8: db $1C ; v:BC f:011F
#_EEB9: db $0A ; v:BA f:010F
#_EEBA: db $18 ; v:B8 f:011F
#_EEBB: db $27 ; v:B7 f:012F
#_EEBC: db $16 ; v:B6 f:011F
#_EEBD: db $05 ; v:B5 f:010F
#_EEBE: db $14 ; v:B4 f:011F
#_EEBF: db $23 ; v:B3 f:012F
#_EEC0: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 0D
;---------------------------------------------------------------------------------------------------
.sfx_0D
#_EEC1: db $80 ; square 2, base volume: $80, freq hi: $00
#_EEC2: db $4E ; v:BE f:004F
#_EEC3: db $3D ; v:BD f:003F
#_EEC4: db $2C ; v:BC f:002F
#_EEC5: db $3B ; v:BB f:003F
#_EEC6: db $4A ; v:BA f:004F
#_EEC7: db $39 ; v:B9 f:003F
#_EEC8: db $28 ; v:B8 f:002F
#_EEC9: db $37 ; v:B7 f:003F
#_EECA: db $46 ; v:B6 f:004F
#_EECB: db $35 ; v:B5 f:003F
#_EECC: db $24 ; v:B4 f:002F
#_EECD: db $33 ; v:B3 f:003F
#_EECE: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 0E
;---------------------------------------------------------------------------------------------------
.sfx_0E
#_EECF: db $41 ; square 2, base volume: $40, freq hi: $01
#_EED0: db $3E ; v:7E f:013F
#_EED1: db $00 ; v:70 f:010F
#_EED2: db $5C ; v:7C f:015F
#_EED3: db $00 ; v:70 f:010F
#_EED4: db $8A ; v:7A f:018F
#_EED5: db $00 ; v:70 f:010F
#_EED6: db $B9 ; v:79 f:01BF
#_EED7: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 0F
;---------------------------------------------------------------------------------------------------
.sfx_0F
#_EED8: db $80 ; square 2, base volume: $80, freq hi: $00
#_EED9: db $1F ; v:BF f:001F
#_EEDA: db $00 ; v:B0 f:000F
#_EEDB: db $3D ; v:BD f:003F
#_EEDC: db $00 ; v:B0 f:000F
#_EEDD: db $5C ; v:BC f:005F
#_EEDE: db $00 ; v:B0 f:000F
#_EEDF: db $7B ; v:BB f:007F
#_EEE0: db $00 ; v:B0 f:000F
#_EEE1: db $99 ; v:B9 f:009F
#_EEE2: db $00 ; v:B0 f:000F
#_EEE3: db $B6 ; v:B6 f:00BF
#_EEE4: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 10
;---------------------------------------------------------------------------------------------------
.sfx_10
#_EEE5: db $80 ; square 2, base volume: $80, freq hi: $00
#_EEE6: db $FF ; v:BF f:00FF
#_EEE7: db $FF ; v:BF f:00FF
#_EEE8: db $3E ; v:BE f:003F
#_EEE9: db $3E ; v:BE f:003F
#_EEEA: db $F7 ; v:B7 f:00FF
#_EEEB: db $F7 ; v:B7 f:00FF
#_EEEC: db $35 ; v:B5 f:003F
#_EEED: db $35 ; v:B5 f:003F
#_EEEE: db $F3 ; v:B3 f:00FF
#_EEEF: db $F3 ; v:B3 f:00FF
#_EEF0: db $32 ; v:B2 f:003F
#_EEF1: db $32 ; v:B2 f:003F
#_EEF2: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 11
;---------------------------------------------------------------------------------------------------
.sfx_11
#_EEF3: db $00 ; square 2, base volume: $00, freq hi: $00
#_EEF4: db $A8 ; v:38 f:00AF
#_EEF5: db $97 ; v:37 f:009F
#_EEF6: db $A6 ; v:36 f:00AF
#_EEF7: db $95 ; v:35 f:009F
#_EEF8: db $A4 ; v:34 f:00AF
#_EEF9: db $93 ; v:33 f:009F
#_EEFA: db $A2 ; v:32 f:00AF
#_EEFB: db $91 ; v:31 f:009F
#_EEFC: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 12
;---------------------------------------------------------------------------------------------------
.sfx_12
#_EEFD: db $10 ; noise
#_EEFE: db $A3 ; v:33 f:080A
#_EEFF: db $66 ; v:36 f:0806
#_EF00: db $29 ; v:39 f:0802
#_EF01: db $AC ; v:3C f:080A
#_EF02: db $6C ; v:3C f:0806
#_EF03: db $2C ; v:3C f:0802
#_EF04: db $AC ; v:3C f:080A
#_EF05: db $6C ; v:3C f:0806
#_EF06: db $2B ; v:3B f:0802
#_EF07: db $AA ; v:3A f:080A
#_EF08: db $68 ; v:38 f:0806
#_EF09: db $26 ; v:36 f:0802
#_EF0A: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 13
;---------------------------------------------------------------------------------------------------
.sfx_13
#_EF0B: db $82 ; square 2, base volume: $80, freq hi: $02
#_EF0C: db $8F ; v:BF f:028F
#_EF0D: db $6F ; v:BF f:026F
#_EF0E: db $4F ; v:BF f:024F
#_EF0F: db $9E ; v:BE f:029F
#_EF10: db $AD ; v:BD f:02AF
#_EF11: db $BC ; v:BC f:02BF
#_EF12: db $CB ; v:BB f:02CF
#_EF13: db $DA ; v:BA f:02DF
#_EF14: db $E9 ; v:B9 f:02EF
#_EF15: db $F8 ; v:B8 f:02FF
#_EF16: db $D8 ; v:B8 f:02DF
#_EF17: db $C8 ; v:B8 f:02CF
#_EF18: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 14
;---------------------------------------------------------------------------------------------------
.sfx_14
#_EF19: db $81 ; square 2, base volume: $80, freq hi: $01
#_EF1A: db $8F ; v:BF f:018F
#_EF1B: db $6F ; v:BF f:016F
#_EF1C: db $4F ; v:BF f:014F
#_EF1D: db $9E ; v:BE f:019F
#_EF1E: db $AD ; v:BD f:01AF
#_EF1F: db $BC ; v:BC f:01BF
#_EF20: db $CB ; v:BB f:01CF
#_EF21: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 15
;---------------------------------------------------------------------------------------------------
.sfx_15
#_EF22: db $41 ; square 2, base volume: $40, freq hi: $01
#_EF23: db $0E ; v:7E f:010F
#_EF24: db $2F ; v:7F f:012F
#_EF25: db $4F ; v:7F f:014F
#_EF26: db $2B ; v:7B f:012F
#_EF27: db $4B ; v:7B f:014F
#_EF28: db $6B ; v:7B f:016F
#_EF29: db $48 ; v:78 f:014F
#_EF2A: db $78 ; v:78 f:017F
#_EF2B: db $A8 ; v:78 f:01AF
#_EF2C: db $75 ; v:75 f:017F
#_EF2D: db $A5 ; v:75 f:01AF
#_EF2E: db $C5 ; v:75 f:01CF
#_EF2F: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 16
;---------------------------------------------------------------------------------------------------
.sfx_16
#_EF30: db $80 ; square 2, base volume: $80, freq hi: $00
#_EF31: db $7E ; v:BE f:007F
#_EF32: db $3D ; v:BD f:003F
#_EF33: db $76 ; v:B6 f:007F
#_EF34: db $34 ; v:B4 f:003F
#_EF35: db $0F ; end

;---------------------------------------------------------------------------------------------------
; SFX 17
;---------------------------------------------------------------------------------------------------
.sfx_17
#_EF36: db $80 ; square 2, base volume: $80, freq hi: $00
#_EF37: db $4E ; v:BE f:004F
#_EF38: db $FE ; v:BE f:00FF
#_EF39: db $8E ; v:BE f:008F
#_EF3A: db $BE ; v:BE f:00BF
#_EF3B: db $49 ; v:B9 f:004F
#_EF3C: db $F9 ; v:B9 f:00FF
#_EF3D: db $89 ; v:B9 f:008F
#_EF3E: db $B9 ; v:B9 f:00BF
#_EF3F: db $46 ; v:B6 f:004F
#_EF40: db $F6 ; v:B6 f:00FF
#_EF41: db $86 ; v:B6 f:008F
#_EF42: db $B6 ; v:B6 f:00BF
#_EF43: db $43 ; v:B3 f:004F
#_EF44: db $F3 ; v:B3 f:00FF
#_EF45: db $83 ; v:B3 f:008F
#_EF46: db $B3 ; v:B3 f:00BF
#_EF47: db $41 ; v:B1 f:004F
#_EF48: db $F1 ; v:B1 f:00FF
#_EF49: db $81 ; v:B1 f:008F
#_EF4A: db $B1 ; v:B1 f:00BF
#_EF4B: db $0F ; end

;===================================================================================================
; db $VA, $WB
;   V - square 1 base volume
;   A - square 1 envelope
;   W - square 2 base volume
;   B - square 2 envelope
;===================================================================================================
SongVolumeControl:
#_EF4C: db $B0, $B0 ; SONG 01
#_EF4E: db $B0, $B0 ; SONG 02
#_EF50: db $B0, $B0 ; SONG 03
#_EF52: db $70, $30 ; SONG 04
#_EF54: db $72, $73 ; SONG 05
#_EF56: db $B0, $30 ; SONG 06
#_EF58: db $73, $73 ; SONG 07
#_EF5A: db $73, $73 ; SONG 08
#_EF5C: db $73, $73 ; SONG 09
#_EF5E: db $B3, $B3 ; SONG 0A
#_EF60: db $72, $33 ; SONG 0B
#_EF62: db $70, $70 ; SONG 0C
#_EF64: db $72, $33 ; SONG 0D
#_EF66: db $72, $33 ; SONG 0E
#_EF68: db $33, $72 ; SONG 0F
#_EF6A: db $72, $33 ; SONG 10
#_EF6C: db $B0, $B0 ; SONG 11
#_EF6E: db $73, $73 ; SONG 12

;===================================================================================================
;===================================================================================================
;===================================================================================================

MuteSongChannels:
#_EF70: LDA.b #$00
#_EF72: STA.w SQ1SWEEP
#_EF75: STA.w SQ2SWEEP

#_EF78: STA.w $07F6
#_EF7B: STA.w $07F7
#_EF7E: STA.w $07FC
#_EF81: STA.w $07FD

#_EF84: STA.b $BE ; SONG OFF

#_EF86: LDA.b #$0F
#_EF88: STA.w SNDCHN

#_EF8B: RTS

;---------------------------------------------------------------------------------------------------

MusicPaused:
#_EF8C: BMI .exit

#_EF8E: ORA.b #$80
#_EF90: STA.b $BF

#_EF92: JSR MuteSFX

#_EF95: LDA.b #$17 ; SFX 17
#_EF97: STA.b $E6

.exit
#_EF99: RTS

;===================================================================================================

MuteSong:
#_EF9A: JSR MuteSongChannels

#_EF9D: LDA.b #$80 ; SONG OFF
#_EF9F: STA.b $BE

;---------------------------------------------------------------------------------------------------

#NoSongActually:
#_EFA1: JMP SongIsTrulyOver

;===================================================================================================

HandleMusic:
#_EFA4: LDA.b $BF
#_EFA6: BNE MusicPaused

#_EFA8: LDA.b $BE
#_EFAA: BMI PlaySong

#_EFAC: LDA.b $BE
#_EFAE: STA.b $E5
#_EFB0: CMP.b #$11 ; SONG 11
#_EFB2: BCS .dont_cache

#_EFB4: STA.w $07FF

.dont_cache
#_EFB7: ORA.b #$80
#_EFB9: STA.b $BE

#_EFBB: DEC.b $E5
#_EFBD: BMI MuteSong

;---------------------------------------------------------------------------------------------------

#_EFBF: LDA.b $E5
#_EFC1: STA.b $DF

#_EFC3: JSR InitTrackPointers

#_EFC6: LDA.b #$00
#_EFC8: STA.b $E3

#_EFCA: LDA.b $DF
#_EFCC: ASL A
#_EFCD: TAX

#_EFCE: STX.b $DF

#_EFD0: LDA.w SongVolumeControl+0,X
#_EFD3: TAY
#_EFD4: AND.b #$F0
#_EFD6: STA.b $E0

#_EFD8: TYA
#_EFD9: AND.b #$0F
#_EFDB: JSR SetVolumeEnvelope

#_EFDE: LDX.b $DF

#_EFE0: LDA.w SongVolumeControl+1,X
#_EFE3: TAY
#_EFE4: AND.b #$F0
#_EFE6: STA.b $E1

#_EFE8: TYA
#_EFE9: AND.b #$0F

#_EFEB: INC.b $E3

#_EFED: JSR SetVolumeEnvelope

;---------------------------------------------------------------------------------------------------

; Reset channel durations
#_EFF0: LDA.b #$01
#_EFF2: LDX.b #$06

.next
#_EFF4: STA.b $C9,X

#_EFF6: DEX
#_EFF7: BPL .next

;===================================================================================================

PlaySong:
#_EFF9: AND.b #$7F
#_EFFB: BEQ NoSongActually

#_EFFD: LDA.b #$00
#_EFFF: STA.b $E4
#_F001: STA.b $E3

.tick_channel
#_F003: LDX.b $E3

#_F005: DEC.b $C9,X
#_F007: BNE .still_waiting

#_F009: JSR ProcessTrackByte

.still_waiting
#_F00C: LDA.b $E4
#_F00E: BNE .song_ended

#_F010: INC.b $E3
#_F012: LDA.b $E3
#_F014: CMP.b #$04
#_F016: BNE .tick_channel

;===================================================================================================

#SongIsTrulyOver:
#_F018: JSR HandleVolumeEnvelope
#_F01B: JMP SetSquareWavesVolumes

;---------------------------------------------------------------------------------------------------

.song_ended
#_F01E: LDA.b $BE
#_F020: CMP.b #$91 ; SONG 11
#_F022: BCC .dont_restore

#_F024: LDA.w $07FF
#_F027: BPL .real_song

.dont_restore
#_F029: LDA.b #$80 ; SONG OFF

.real_song
#_F02B: STA.b $BE
#_F02D: BEQ SongIsTrulyOver

;===================================================================================================

HandleVolumeEnvelope:
#_F02F: LDX.b #$01
#_F031: STX.b $E3

.next
#_F033: LDX.b $E3

#_F035: LDY.w $07F6,X

#_F038: LDA.w EnvelopeVolumes,Y
#_F03B: BMI .skip

#_F03D: STA.w $07FC,X

#_F040: INC.w $07F6,X

.skip
#_F043: DEC.b $E3
#_F045: BPL .next

#_F047: RTS

;===================================================================================================

SetSquareWavesVolumes:
#_F048: LDX.b #$00
#_F04A: JSR .set_one

#_F04D: LDX.b #$01

;---------------------------------------------------------------------------------------------------

.set_one
#_F04F: LDA.b $E8,X
#_F051: BNE .exit

#_F053: LDA.b $E0,X
#_F055: ORA.w $07FC,X
#_F058: TAY

#_F059: TXA
#_F05A: ASL A
#_F05B: ASL A
#_F05C: TAX

#_F05D: TYA
#_F05E: STA.w SQ1VOL,X

.exit
#_F061: RTS

;===================================================================================================

SetVolumeEnvelope:
#_F062: TAX

#_F063: LDA.w .class,X

#_F066: LDX.b $E3
#_F068: STA.w $07F9,X

#_F06B: RTS

;---------------------------------------------------------------------------------------------------

.class
#_F06C: db $01 ; envelope 0
#_F06D: db $0A ; envelope 1
#_F06E: db $11 ; envelope 2
#_F06F: db $1E ; envelope 3

;===================================================================================================

EnvelopeVolumes:
#_F070: db $FF ; !UNUSED technically...

#_F071: db $0F, $0D, $0B, $0A, $09, $08, $07, $06  ; envelope 0
#_F079: db $FF

#_F07A: db $01, $02, $04, $05, $06, $07, $FF       ; envelope 1

#_F081: db $01, $03, $05, $08, $0B, $0D, $0E, $0D  ; envelope 2
#_F089: db $0B, $09, $08, $07, $FF

#_F08E: db $0F, $0D, $0B, $09, $07, $06, $05, $04  ; envelope 3
#_F096: db $03, $02, $01, $00, $FF

;===================================================================================================

ProcessTrackByte:
#_F09B: JSR GetNextSongByte
#_F09E: STA.b $E5

#_F0A0: LDA.b $E3
#_F0A2: CMP.b #$03
#_F0A4: BEQ IsNoiseChannel

#_F0A6: LDA.b $E5
#_F0A8: BMI CommandOrDuration

#_F0AA: JMP NextNote

;===================================================================================================

CommandOrDuration:
#_F0AD: CMP.b #$F9
#_F0AF: BCC .not_a_command

#_F0B1: SEC

#_F0B2: LDA.b #$FF
#_F0B4: SBC.b $E5
#_F0B6: ASL A
#_F0B7: TAY

#_F0B8: LDA.w TrackCommands+1,Y
#_F0BB: PHA

#_F0BC: LDA.w TrackCommands+0,Y
#_F0BF: PHA

#_F0C0: RTS

;---------------------------------------------------------------------------------------------------

.not_a_command
#_F0C1: LDX.b $E3

#_F0C3: LDA.b $E5
#_F0C5: AND.b #$7F
#_F0C7: STA.b $E5
#_F0C9: STA.b $CD,X

#_F0CB: CPX.b #$02
#_F0CD: BEQ .i_wanna_be_a_triangle

#_F0CF: JMP ProcessTrackByte

;---------------------------------------------------------------------------------------------------

; triangle channel also sets volume to twice the duration
; probably for NES reasons
.i_wanna_be_a_triangle
#_F0D2: LDA.b $E5
#_F0D4: ASL A
#_F0D5: BMI .clamp
#_F0D7: BPL .set

.clamp
#_F0D9: LDA.b #$7F

.set
#_F0DB: STA.b $E2
#_F0DD: JMP ProcessTrackByte

;===================================================================================================

IsNoiseChannel:
#_F0E0: LDA.b $E5
#_F0E2: BMI CommandOrDuration

#_F0E4: AND.b #$0F
#_F0E6: TAX

#_F0E7: LDA.w NoiseChannelDurations,X
#_F0EA: STA.b $CC

#_F0EC: LDA.b $EB
#_F0EE: BNE .exit

#_F0F0: LDA.b $E5
#_F0F2: LSR A
#_F0F3: LSR A
#_F0F4: LSR A
#_F0F5: LSR A
#_F0F6: BEQ .exit

#_F0F8: CMP.b #$01
#_F0FA: BEQ .snare_hit

.snare_scratch
#_F0FC: LDX.b #$00
#_F0FE: BEQ .set_sound

.snare_hit
#_F100: LDX.b #$03

.set_sound
#_F102: LDA.w NoiseAurality+0,X
#_F105: STA.w NOISEVOL

#_F108: LDA.w NoiseAurality+1,X
#_F10B: STA.w NOISEPD

#_F10E: LDA.w NoiseAurality+2,X
#_F111: STA.w NOISELN

.exit
#_F114: RTS

;===================================================================================================

NoiseAurality:
#_F115: db $05, $02, $90
#_F118: db $00, $05, $00

;===================================================================================================

NoiseChannelDurations:
#_F11B: db $04, $06, $08, $0C
#_F11F: db $10, $18, $24, $30
#_F123: db $48, $58, $60, $78

;===================================================================================================

TrackCommands:
#_F127: dw TrackCmdFF_EndSong-1        ; FF
#_F129: dw TrackCmdFE_ResetSong-1      ; FE
#_F12B: dw TrackCmdFC_StartLoop-1      ; FD
#_F12D: dw TrackCmdFC_EndLoop-1        ; FC
#_F12F: dw TrackCmdFB_EndChannel-1     ; FB
#_F131: dw TrackCmdFA_SetVolume-1      ; FA

;===================================================================================================

NextNote:
#_F133: LDX.b $E3

#_F135: LDY.b $CD,X
#_F137: STY.b $C9,X

#_F139: LDY.b $E8,X
#_F13B: BNE .exit

#_F13D: TXA
#_F13E: ASL A
#_F13F: ASL A
#_F140: TAY

#_F141: LDA.b $E0,X
#_F143: STA.w SQ1VOL,Y

#_F146: LDA.b #$00
#_F148: STA.w SQ1SWEEP,Y

#_F14B: JSR HandleNotePitch

#_F14E: LDA.b $E3
#_F150: CMP.b #$02
#_F152: BNE .square_waves

;---------------------------------------------------------------------------------------------------

; Euphonium/ocarina split
#_F154: LDA.b $BE
#_F156: CMP.b #$8E ; SONG 0E
#_F158: BNE .test_track_byte

#_F15A: LDA.b $C0
#_F15C: AND.b #$10 ; test for ocarina
#_F15E: BNE .test_track_byte

#_F160: LDA.b $E5
#_F162: CMP.b #$44 ; G#5 and above are ocarina
#_F164: BCS .exit

.test_track_byte
#_F166: LDA.b $E5
#_F168: BEQ .exit

;---------------------------------------------------------------------------------------------------

.square_waves
#_F16A: LDA.b $DD
#_F16C: STA.w SQ1LO,Y

#_F16F: LDA.b $DE
#_F171: ORA.b #$08
#_F173: STA.w SQ1HI,Y

#_F176: LDX.b $E3
#_F178: LDA.w $07F9,X
#_F17B: STA.w $07F6,X

.exit
#_F17E: RTS

;===================================================================================================

PlayRest:
#_F17F: LDA.b #$00
#_F181: STA.b $DD
#_F183: STA.b $DE

#_F185: RTS

;===================================================================================================

HandleNotePitch:
#_F186: LDA.b $E5
#_F188: BEQ PlayRest

#_F18A: LDA.b $E3
#_F18C: BNE .get_note

#_F18E: LDA.b $BE
#_F190: CMP.b #$8F ; SONG 0F
#_F192: BNE .get_note

#_F194: LDA.b $C0
#_F196: AND.b #$04 ; test for trumpet
#_F198: BNE .get_note

#_F19A: LDA.b $E0
#_F19C: CMP.b #$30
#_F19E: BNE PlayRest

;---------------------------------------------------------------------------------------------------

.get_note
#_F1A0: LDA.b $E5
#_F1A2: CLC
#_F1A3: ADC.b #$E8

#_F1A5: STY.b $DF

#_F1A7: LDY.b #$01
#_F1A9: SEC

.get_octave
#_F1AA: SBC.b #$0C

#_F1AC: INY
#_F1AD: BCS .get_octave

#_F1AF: DEY

#_F1B0: ADC.b #$0D
#_F1B2: ASL A
#_F1B3: TAX

#_F1B4: LDA.w NotePitch+0,X
#_F1B7: STA.b $DD

#_F1B9: LDA.w NotePitch+1,X
#_F1BC: STA.b $DE

;---------------------------------------------------------------------------------------------------

.shift_octave
#_F1BE: DEY
#_F1BF: BEQ .correct_octave

#_F1C1: LSR.b $DE
#_F1C3: ROR.b $DD

#_F1C5: JMP .shift_octave

.correct_octave
#_F1C8: LDY.b $DF

#_F1CA: RTS

;===================================================================================================

TrackCmdFF_EndSong:
#_F1CB: INC.b $E4

#_F1CD: RTS

;===================================================================================================

TrackCmdFE_ResetSong:
#_F1CE: LDA.b $BE
#_F1D0: AND.b #$7F
#_F1D2: SEC
#_F1D3: SBC.b #$01
#_F1D5: JSR InitTrackPointers

#_F1D8: JMP ProcessTrackByte

;===================================================================================================

InitTrackPointers:
#_F1DB: ASL A
#_F1DC: ASL A
#_F1DD: ASL A
#_F1DE: TAY

#_F1DF: LDX.b #$00

.next
#_F1E1: LDA.w SongPointers,Y
#_F1E4: STA.b $C1,X

#_F1E6: INY

#_F1E7: INX
#_F1E8: CPX.b #$08
#_F1EA: BNE .next

#_F1EC: LDA.b #$00
#_F1EE: STA.b $F2
#_F1F0: STA.b $F3

#_F1F2: RTS

;===================================================================================================

TrackCmdFC_StartLoop:
#_F1F3: JSR GetNextSongByte

#_F1F6: LDX.b $E3

#_F1F8: STA.b $D9,X

#_F1FA: TXA
#_F1FB: ASL A
#_F1FC: TAX

; Save return location
#_F1FD: LDA.b $C1,X
#_F1FF: STA.b $D1,X

#_F201: LDA.b $C2,X
#_F203: STA.b $D2,X

#_F205: JMP ProcessTrackByte

;===================================================================================================

TrackCmdFC_EndLoop:
#_F208: LDX.b $E3

#_F20A: DEC.b $D9,X
#_F20C: BEQ .dont_return

#_F20E: TXA
#_F20F: ASL A
#_F210: TAX

; Recover return location
#_F211: LDA.b $D1,X
#_F213: STA.b $C1,X

#_F215: LDA.b $D2,X
#_F217: STA.b $C2,X

.dont_return
#_F219: JMP ProcessTrackByte

;===================================================================================================

TrackCmdFB_EndChannel:
#_F21C: LDA.b $E3
#_F21E: ASL A
#_F21F: TAX

; Just keeps going back one byte forever to stay on this command byte
#_F220: LDA.b $C1,X
#_F222: BNE .no_overflow

#_F224: DEC.b $C2,X

.no_overflow
#_F226: DEC.b $C1,X

#_F228: RTS

;===================================================================================================

TrackCmdFA_SetVolume:
#_F229: JSR GetNextSongByte
#_F22C: PHA

#_F22D: AND.b #$F0

#_F22F: LDX.b $E3

#_F231: STA.b $E0,X

#_F233: PLA
#_F234: AND.b #$0F
#_F236: JSR SetVolumeEnvelope

#_F239: JMP ProcessTrackByte

;===================================================================================================

GetNextSongByte:
#_F23C: LDA.b $E3
#_F23E: ASL A
#_F23F: TAX

#_F240: LDA.b ($C1,X)

#_F242: INC.b $C1,X
#_F244: BNE .exit

#_F246: INC.b $C2,X

.exit
#_F248: RTS

;===================================================================================================

NotePitch:
#_F249: dw $0000 ; R
#_F24B: dw $06AE ; C
#_F24D: dw $064E ; C#
#_F24F: dw $05F3 ; D
#_F251: dw $059F ; D#
#_F253: dw $054D ; E
#_F255: dw $0501 ; F
#_F257: dw $04B9 ; F#
#_F259: dw $0475 ; G
#_F25B: dw $0435 ; G#
#_F25D: dw $03F8 ; A
#_F25F: dw $03BF ; A#
#_F261: dw $0389 ; B

;===================================================================================================
;===================================================================================================
;===================================================================================================

SongPointers:

.song_01
#_F263: dw Song01Square1
#_F265: dw Song01Square2
#_F267: dw Song01Triangle
#_F269: dw Song01Noise

.song_02
#_F26B: dw Song02Square1
#_F26D: dw Song02Square2
#_F26F: dw Song02Triangle
#_F271: dw Song02Noise

.song_03
#_F273: dw Song03Square1
#_F275: dw Song03Square2
#_F277: dw Song03Triangle
#_F279: dw SilentTrack

.song_04
#_F27B: dw Song04Square1
#_F27D: dw Song04Square2
#_F27F: dw Song04Triangle
#_F281: dw Song04Noise

.song_05
#_F283: dw Song05Square1
#_F285: dw Song05Square2
#_F287: dw Song05Triangle
#_F289: dw SilentTrack

.song_06
#_F28B: dw Song06Square1
#_F28D: dw Song06Square2
#_F28F: dw Song06Triangle
#_F291: dw SilentTrack

.song_07
#_F293: dw Song07Square1
#_F295: dw Song07Square2
#_F297: dw Song07Triangle
#_F299: dw SilentTrack

.song_08
#_F29B: dw Song08Square1
#_F29D: dw Song08Square2
#_F29F: dw SilentTrack
#_F2A1: dw SilentTrack

.song_09
#_F2A3: dw Song09Square1
#_F2A5: dw Song09Square2
#_F2A7: dw SilentTrack
#_F2A9: dw SilentTrack

.song_0A
#_F2AB: dw Song0ASquare1
#_F2AD: dw Song0ASquare2
#_F2AF: dw Song0ATriangle
#_F2B1: dw SilentTrack

.song_0B
#_F2B3: dw Song0BSquare1
#_F2B5: dw Song0BSquare2
#_F2B7: dw Song0BTriangle
#_F2B9: dw Song0BNoise

.song_0C
#_F2BB: dw Song0CSquare1
#_F2BD: dw Song0CSquare2
#_F2BF: dw Song0CTriangle
#_F2C1: dw SilentTrack

.song_0D
#_F2C3: dw SilentTrack
#_F2C5: dw SilentTrack
#_F2C7: dw SilentTrack
#_F2C9: dw BonusGameDrums

.song_0E
#_F2CB: dw SilentTrack
#_F2CD: dw SilentTrack
#_F2CF: dw BonusGameEuphoniumOcarina
#_F2D1: dw BonusGameDrums

.song_0F
#_F2D3: dw BonusGameHarpTrumpet
#_F2D5: dw SilentTrack
#_F2D7: dw BonusGameEuphoniumOcarina
#_F2D9: dw BonusGameDrums

.song_10
#_F2DB: dw BonusGameViolin
#_F2DD: dw BonusGameHarpTrumpet
#_F2DF: dw BonusGameEuphoniumOcarina
#_F2E1: dw BonusGameDrums

.song_11
#_F2E3: dw Song11Square1
#_F2E5: dw Song11Square2
#_F2E7: dw Song11Triangle
#_F2E9: dw SilentTrack

.song_12
#_F2EB: dw Song12Square1
#_F2ED: dw Song12Square2
#_F2EF: dw Song12Triangle
#_F2F1: dw SilentTrack

;===================================================================================================

SilentTrack:
#_F2F3: db $FB ; hang track

;===================================================================================================
;===================================================================================================
; SONG 02
;===================================================================================================
;===================================================================================================
Song02Square2:
#_F2F4: db $88 ; duration: $08
#_F2F5: db $32 ; D4
#_F2F6: db $A0 ; duration: $20
#_F2F7: db $00 ; rest
#_F2F8: db $F8 ; duration: $78
#_F2F9: db $31 ; C#4
#_F2FA: db $88 ; duration: $08
#_F2FB: db $00 ; rest
#_F2FC: db $90 ; duration: $10
#_F2FD: db $2F ; B3
#_F2FE: db $88 ; duration: $08
#_F2FF: db $31 ; C#4
#_F300: db $32 ; D4
#_F301: db $A0 ; duration: $20
#_F302: db $00 ; rest
#_F303: db $F8 ; duration: $78
#_F304: db $31 ; C#4
#_F305: db $A0 ; duration: $20
#_F306: db $00 ; rest
#_F307: db $88 ; duration: $08
#_F308: db $32 ; D4
#_F309: db $A0 ; duration: $20
#_F30A: db $00 ; rest
#_F30B: db $D8 ; duration: $58
#_F30C: db $31 ; C#4
#_F30D: db $88 ; duration: $08
#_F30E: db $00 ; rest
#_F30F: db $98 ; duration: $18
#_F310: db $30 ; C4
#_F311: db $88 ; duration: $08
#_F312: db $31 ; C#4
#_F313: db $90 ; duration: $10
#_F314: db $2B ; G3
#_F315: db $88 ; duration: $08
#_F316: db $2D ; A3
#_F317: db $32 ; D4
#_F318: db $A0 ; duration: $20
#_F319: db $00 ; rest
#_F31A: db $F8 ; duration: $78
#_F31B: db $31 ; C#4
#_F31C: db $A0 ; duration: $20
#_F31D: db $00 ; rest
#_F31E: db $88 ; duration: $08
#_F31F: db $37 ; G4
#_F320: db $A0 ; duration: $20
#_F321: db $00 ; rest
#_F322: db $F8 ; duration: $78
#_F323: db $36 ; F#4
#_F324: db $88 ; duration: $08
#_F325: db $00 ; rest
#_F326: db $90 ; duration: $10
#_F327: db $34 ; E4
#_F328: db $88 ; duration: $08
#_F329: db $36 ; F#4
#_F32A: db $37 ; G4
#_F32B: db $A0 ; duration: $20
#_F32C: db $00 ; rest
#_F32D: db $F8 ; duration: $78
#_F32E: db $36 ; F#4
#_F32F: db $A0 ; duration: $20
#_F330: db $00 ; rest
#_F331: db $88 ; duration: $08
#_F332: db $37 ; G4
#_F333: db $A0 ; duration: $20
#_F334: db $00 ; rest
#_F335: db $E8 ; duration: $68
#_F336: db $36 ; F#4
#_F337: db $88 ; duration: $08
#_F338: db $35 ; F4
#_F339: db $35 ; F4
#_F33A: db $36 ; F#4
#_F33B: db $90 ; duration: $10
#_F33C: db $34 ; E4
#_F33D: db $88 ; duration: $08
#_F33E: db $36 ; F#4
#_F33F: db $37 ; G4
#_F340: db $A0 ; duration: $20
#_F341: db $00 ; rest
#_F342: db $F8 ; duration: $78
#_F343: db $36 ; F#4
#_F344: db $A0 ; duration: $20
#_F345: db $00 ; rest
#_F346: db $88 ; duration: $08
#_F347: db $32 ; D4
#_F348: db $A0 ; duration: $20
#_F349: db $00 ; rest
#_F34A: db $F8 ; duration: $78
#_F34B: db $31 ; C#4
#_F34C: db $88 ; duration: $08
#_F34D: db $00 ; rest
#_F34E: db $90 ; duration: $10
#_F34F: db $2F ; B3
#_F350: db $88 ; duration: $08
#_F351: db $31 ; C#4
#_F352: db $32 ; D4
#_F353: db $A0 ; duration: $20
#_F354: db $00 ; rest
#_F355: db $F8 ; duration: $78
#_F356: db $31 ; C#4
#_F357: db $A0 ; duration: $20
#_F358: db $00 ; rest
#_F359: db $88 ; duration: $08
#_F35A: db $32 ; D4
#_F35B: db $A0 ; duration: $20
#_F35C: db $00 ; rest
#_F35D: db $D8 ; duration: $58
#_F35E: db $31 ; C#4
#_F35F: db $88 ; duration: $08
#_F360: db $00 ; rest
#_F361: db $98 ; duration: $18
#_F362: db $30 ; C4
#_F363: db $88 ; duration: $08
#_F364: db $31 ; C#4
#_F365: db $90 ; duration: $10
#_F366: db $2B ; G3
#_F367: db $88 ; duration: $08
#_F368: db $2D ; A3
#_F369: db $32 ; D4
#_F36A: db $A0 ; duration: $20
#_F36B: db $00 ; rest
#_F36C: db $F8 ; duration: $78
#_F36D: db $31 ; C#4
#_F36E: db $A0 ; duration: $20
#_F36F: db $00 ; rest

#_F370: db $FD, $06 ; loop point
#_F372: db $90 ; duration: $10
#_F373: db $34 ; E4
#_F374: db $FC ; loop part

#_F375: db $88 ; duration: $08
#_F376: db $32 ; D4
#_F377: db $A0 ; duration: $20
#_F378: db $00 ; rest
#_F379: db $98 ; duration: $18
#_F37A: db $2F ; B3
#_F37B: db $88 ; duration: $08
#_F37C: db $30 ; C4
#_F37D: db $90 ; duration: $10
#_F37E: db $2D ; A3
#_F37F: db $88 ; duration: $08
#_F380: db $2F ; B3
#_F381: db $32 ; D4
#_F382: db $A0 ; duration: $20
#_F383: db $00 ; rest
#_F384: db $B8 ; duration: $38
#_F385: db $31 ; C#4
#_F386: db $90 ; duration: $10
#_F387: db $00 ; rest
#_F388: db $88 ; duration: $08
#_F389: db $37 ; G4
#_F38A: db $90 ; duration: $10
#_F38B: db $00 ; rest
#_F38C: db $B8 ; duration: $38
#_F38D: db $37 ; G4

;---------------------------------------------------------------------------------------------------

Song02Square1:
#_F38E: db $88 ; duration: $08
#_F38F: db $37 ; G4
#_F390: db $A0 ; duration: $20
#_F391: db $00 ; rest
#_F392: db $F8 ; duration: $78
#_F393: db $37 ; G4
#_F394: db $88 ; duration: $08
#_F395: db $00 ; rest
#_F396: db $90 ; duration: $10
#_F397: db $34 ; E4
#_F398: db $88 ; duration: $08
#_F399: db $36 ; F#4
#_F39A: db $37 ; G4
#_F39B: db $A0 ; duration: $20
#_F39C: db $00 ; rest
#_F39D: db $F8 ; duration: $78
#_F39E: db $37 ; G4
#_F39F: db $A0 ; duration: $20
#_F3A0: db $00 ; rest
#_F3A1: db $88 ; duration: $08
#_F3A2: db $37 ; G4
#_F3A3: db $A0 ; duration: $20
#_F3A4: db $00 ; rest
#_F3A5: db $D8 ; duration: $58
#_F3A6: db $37 ; G4
#_F3A7: db $88 ; duration: $08
#_F3A8: db $00 ; rest
#_F3A9: db $98 ; duration: $18
#_F3AA: db $36 ; F#4
#_F3AB: db $88 ; duration: $08
#_F3AC: db $37 ; G4
#_F3AD: db $90 ; duration: $10
#_F3AE: db $34 ; E4
#_F3AF: db $88 ; duration: $08
#_F3B0: db $36 ; F#4
#_F3B1: db $37 ; G4
#_F3B2: db $A0 ; duration: $20
#_F3B3: db $00 ; rest
#_F3B4: db $F8 ; duration: $78
#_F3B5: db $37 ; G4
#_F3B6: db $A0 ; duration: $20
#_F3B7: db $00 ; rest
#_F3B8: db $88 ; duration: $08
#_F3B9: db $3C ; C5
#_F3BA: db $A0 ; duration: $20
#_F3BB: db $00 ; rest
#_F3BC: db $F8 ; duration: $78
#_F3BD: db $3C ; C5
#_F3BE: db $88 ; duration: $08
#_F3BF: db $00 ; rest
#_F3C0: db $90 ; duration: $10
#_F3C1: db $39 ; A4
#_F3C2: db $88 ; duration: $08
#_F3C3: db $3B ; B4
#_F3C4: db $3C ; C5
#_F3C5: db $A0 ; duration: $20
#_F3C6: db $00 ; rest
#_F3C7: db $F8 ; duration: $78
#_F3C8: db $3C ; C5
#_F3C9: db $A0 ; duration: $20
#_F3CA: db $00 ; rest
#_F3CB: db $88 ; duration: $08
#_F3CC: db $3C ; C5
#_F3CD: db $A0 ; duration: $20
#_F3CE: db $00 ; rest
#_F3CF: db $E8 ; duration: $68
#_F3D0: db $3C ; C5
#_F3D1: db $88 ; duration: $08
#_F3D2: db $3B ; B4
#_F3D3: db $3B ; B4
#_F3D4: db $3C ; C5
#_F3D5: db $90 ; duration: $10
#_F3D6: db $39 ; A4
#_F3D7: db $88 ; duration: $08
#_F3D8: db $3B ; B4
#_F3D9: db $3C ; C5
#_F3DA: db $A0 ; duration: $20
#_F3DB: db $00 ; rest
#_F3DC: db $F8 ; duration: $78
#_F3DD: db $3C ; C5
#_F3DE: db $A0 ; duration: $20
#_F3DF: db $00 ; rest
#_F3E0: db $88 ; duration: $08
#_F3E1: db $37 ; G4
#_F3E2: db $A0 ; duration: $20
#_F3E3: db $00 ; rest
#_F3E4: db $F8 ; duration: $78
#_F3E5: db $37 ; G4
#_F3E6: db $88 ; duration: $08
#_F3E7: db $00 ; rest
#_F3E8: db $90 ; duration: $10
#_F3E9: db $34 ; E4
#_F3EA: db $88 ; duration: $08
#_F3EB: db $36 ; F#4
#_F3EC: db $37 ; G4
#_F3ED: db $A0 ; duration: $20
#_F3EE: db $00 ; rest
#_F3EF: db $F8 ; duration: $78
#_F3F0: db $37 ; G4
#_F3F1: db $A0 ; duration: $20
#_F3F2: db $00 ; rest
#_F3F3: db $88 ; duration: $08
#_F3F4: db $37 ; G4
#_F3F5: db $A0 ; duration: $20
#_F3F6: db $00 ; rest
#_F3F7: db $D8 ; duration: $58
#_F3F8: db $37 ; G4
#_F3F9: db $88 ; duration: $08
#_F3FA: db $00 ; rest
#_F3FB: db $98 ; duration: $18
#_F3FC: db $36 ; F#4
#_F3FD: db $88 ; duration: $08
#_F3FE: db $37 ; G4
#_F3FF: db $90 ; duration: $10
#_F400: db $34 ; E4
#_F401: db $88 ; duration: $08
#_F402: db $36 ; F#4
#_F403: db $37 ; G4
#_F404: db $A0 ; duration: $20
#_F405: db $00 ; rest
#_F406: db $F8 ; duration: $78
#_F407: db $37 ; G4
#_F408: db $A0 ; duration: $20
#_F409: db $00 ; rest
#_F40A: db $90 ; duration: $10
#_F40B: db $32 ; D4
#_F40C: db $32 ; D4
#_F40D: db $31 ; C#4
#_F40E: db $2F ; B3
#_F40F: db $2D ; A3
#_F410: db $2C ; G#3
#_F411: db $88 ; duration: $08
#_F412: db $2A ; F#3
#_F413: db $A0 ; duration: $20
#_F414: db $00 ; rest
#_F415: db $26 ; D3
#_F416: db $90 ; duration: $10
#_F417: db $2A ; F#3
#_F418: db $88 ; duration: $08
#_F419: db $2B ; G3
#_F41A: db $37 ; G4
#_F41B: db $A0 ; duration: $20
#_F41C: db $00 ; rest
#_F41D: db $B8 ; duration: $38
#_F41E: db $37 ; G4
#_F41F: db $90 ; duration: $10
#_F420: db $00 ; rest
#_F421: db $88 ; duration: $08
#_F422: db $2C ; G#3
#_F423: db $90 ; duration: $10
#_F424: db $00 ; rest
#_F425: db $B8 ; duration: $38
#_F426: db $2C ; G#3

#_F427: db $FE ; loop song

;---------------------------------------------------------------------------------------------------

Song02Triangle:
#_F428: db $FD, $04 ; loop point
#_F42A: db $90 ; duration: $10
#_F42B: db $2D ; A3
#_F42C: db $88 ; duration: $08
#_F42D: db $2D ; A3
#_F42E: db $90 ; duration: $10
#_F42F: db $31 ; C#4
#_F430: db $88 ; duration: $08
#_F431: db $31 ; C#4
#_F432: db $90 ; duration: $10
#_F433: db $34 ; E4
#_F434: db $88 ; duration: $08
#_F435: db $34 ; E4
#_F436: db $90 ; duration: $10
#_F437: db $37 ; G4
#_F438: db $88 ; duration: $08
#_F439: db $39 ; A4
#_F43A: db $90 ; duration: $10
#_F43B: db $39 ; A4
#_F43C: db $88 ; duration: $08
#_F43D: db $34 ; E4
#_F43E: db $90 ; duration: $10
#_F43F: db $37 ; G4
#_F440: db $88 ; duration: $08
#_F441: db $39 ; A4
#_F442: db $90 ; duration: $10
#_F443: db $37 ; G4
#_F444: db $88 ; duration: $08
#_F445: db $34 ; E4
#_F446: db $32 ; D4
#_F447: db $33 ; D#4
#_F448: db $34 ; E4
#_F449: db $FC ; loop part

#_F44A: db $FD, $04 ; loop point
#_F44C: db $90 ; duration: $10
#_F44D: db $32 ; D4
#_F44E: db $88 ; duration: $08
#_F44F: db $32 ; D4
#_F450: db $90 ; duration: $10
#_F451: db $36 ; F#4
#_F452: db $88 ; duration: $08
#_F453: db $36 ; F#4
#_F454: db $90 ; duration: $10
#_F455: db $39 ; A4
#_F456: db $88 ; duration: $08
#_F457: db $39 ; A4
#_F458: db $90 ; duration: $10
#_F459: db $3C ; C5
#_F45A: db $88 ; duration: $08
#_F45B: db $3E ; D5
#_F45C: db $90 ; duration: $10
#_F45D: db $3E ; D5
#_F45E: db $88 ; duration: $08
#_F45F: db $39 ; A4
#_F460: db $90 ; duration: $10
#_F461: db $3C ; C5
#_F462: db $88 ; duration: $08
#_F463: db $3E ; D5
#_F464: db $90 ; duration: $10
#_F465: db $3C ; C5
#_F466: db $88 ; duration: $08
#_F467: db $39 ; A4
#_F468: db $37 ; G4
#_F469: db $38 ; G#4
#_F46A: db $39 ; A4
#_F46B: db $FC ; loop part

#_F46C: db $FD, $04 ; loop point
#_F46E: db $90 ; duration: $10
#_F46F: db $2D ; A3
#_F470: db $88 ; duration: $08
#_F471: db $2D ; A3
#_F472: db $90 ; duration: $10
#_F473: db $31 ; C#4
#_F474: db $88 ; duration: $08
#_F475: db $31 ; C#4
#_F476: db $90 ; duration: $10
#_F477: db $34 ; E4
#_F478: db $88 ; duration: $08
#_F479: db $34 ; E4
#_F47A: db $90 ; duration: $10
#_F47B: db $37 ; G4
#_F47C: db $88 ; duration: $08
#_F47D: db $39 ; A4
#_F47E: db $90 ; duration: $10
#_F47F: db $39 ; A4
#_F480: db $88 ; duration: $08
#_F481: db $34 ; E4
#_F482: db $90 ; duration: $10
#_F483: db $37 ; G4
#_F484: db $88 ; duration: $08
#_F485: db $39 ; A4
#_F486: db $90 ; duration: $10
#_F487: db $37 ; G4
#_F488: db $88 ; duration: $08
#_F489: db $34 ; E4
#_F48A: db $32 ; D4
#_F48B: db $33 ; D#4
#_F48C: db $34 ; E4
#_F48D: db $FC ; loop part

#_F48E: db $FD, $06 ; loop point
#_F490: db $90 ; duration: $10
#_F491: db $34 ; E4
#_F492: db $FC ; loop part

#_F493: db $88 ; duration: $08
#_F494: db $32 ; D4
#_F495: db $B8 ; duration: $38
#_F496: db $00 ; rest
#_F497: db $88 ; duration: $08
#_F498: db $32 ; D4
#_F499: db $90 ; duration: $10
#_F49A: db $3E ; D5
#_F49B: db $88 ; duration: $08
#_F49C: db $38 ; G#4
#_F49D: db $90 ; duration: $10
#_F49E: db $2D ; A3
#_F49F: db $88 ; duration: $08
#_F4A0: db $34 ; E4
#_F4A1: db $90 ; duration: $10
#_F4A2: db $00 ; rest
#_F4A3: db $B0 ; duration: $30
#_F4A4: db $39 ; A4
#_F4A5: db $88 ; duration: $08
#_F4A6: db $2D ; A3
#_F4A7: db $90 ; duration: $10
#_F4A8: db $34 ; E4
#_F4A9: db $88 ; duration: $08
#_F4AA: db $34 ; E4
#_F4AB: db $90 ; duration: $10
#_F4AC: db $00 ; rest
#_F4AD: db $98 ; duration: $18
#_F4AE: db $34 ; E4
#_F4AF: db $88 ; duration: $08
#_F4B0: db $34 ; E4
#_F4B1: db $90 ; duration: $10
#_F4B2: db $37 ; G4
#_F4B3: db $88 ; duration: $08
#_F4B4: db $38 ; G#4

;---------------------------------------------------------------------------------------------------

Song02Noise:
#_F4B5: db $FD, $06 ; loop point
#_F4B7: db $12 ; snare hit | duration: $08
#_F4B8: db $04 ; rest      | duration: $10
#_F4B9: db $22 ; scratch   | duration: $08
#_F4BA: db $02 ; rest      | duration: $08
#_F4BB: db $22 ; scratch   | duration: $08
#_F4BC: db $12 ; snare hit | duration: $08
#_F4BD: db $04 ; rest      | duration: $10
#_F4BE: db $22 ; scratch   | duration: $08
#_F4BF: db $02 ; rest      | duration: $08
#_F4C0: db $22 ; scratch   | duration: $08
#_F4C1: db $12 ; snare hit | duration: $08
#_F4C2: db $04 ; rest      | duration: $10
#_F4C3: db $22 ; scratch   | duration: $08
#_F4C4: db $02 ; rest      | duration: $08
#_F4C5: db $22 ; scratch   | duration: $08
#_F4C6: db $12 ; snare hit | duration: $08
#_F4C7: db $04 ; rest      | duration: $10
#_F4C8: db $22 ; scratch   | duration: $08
#_F4C9: db $02 ; rest      | duration: $08
#_F4CA: db $22 ; scratch   | duration: $08
#_F4CB: db $12 ; snare hit | duration: $08
#_F4CC: db $02 ; rest      | duration: $08
#_F4CD: db $12 ; snare hit | duration: $08
#_F4CE: db $22 ; scratch   | duration: $08
#_F4CF: db $04 ; rest      | duration: $10
#_F4D0: db $12 ; snare hit | duration: $08
#_F4D1: db $02 ; rest      | duration: $08
#_F4D2: db $12 ; snare hit | duration: $08
#_F4D3: db $22 ; scratch   | duration: $08
#_F4D4: db $04 ; rest      | duration: $10
#_F4D5: db $12 ; snare hit | duration: $08
#_F4D6: db $02 ; rest      | duration: $08
#_F4D7: db $12 ; snare hit | duration: $08
#_F4D8: db $22 ; scratch   | duration: $08
#_F4D9: db $04 ; rest      | duration: $10
#_F4DA: db $12 ; snare hit | duration: $08
#_F4DB: db $22 ; scratch   | duration: $08
#_F4DC: db $12 ; snare hit | duration: $08
#_F4DD: db $22 ; scratch   | duration: $08
#_F4DE: db $02 ; rest      | duration: $08
#_F4DF: db $22 ; scratch   | duration: $08
#_F4E0: db $FC ; loop part

#_F4E1: db $24 ; scratch   | duration: $10
#_F4E2: db $24 ; scratch   | duration: $10
#_F4E3: db $24 ; scratch   | duration: $10
#_F4E4: db $24 ; scratch   | duration: $10
#_F4E5: db $24 ; scratch   | duration: $10
#_F4E6: db $24 ; scratch   | duration: $10
#_F4E7: db $22 ; scratch   | duration: $08
#_F4E8: db $09 ; rest      | duration: $58
#_F4E9: db $12 ; snare hit | duration: $08
#_F4EA: db $04 ; rest      | duration: $10
#_F4EB: db $22 ; scratch   | duration: $08
#_F4EC: db $02 ; rest      | duration: $08
#_F4ED: db $22 ; scratch   | duration: $08
#_F4EE: db $12 ; snare hit | duration: $08
#_F4EF: db $04 ; rest      | duration: $10
#_F4F0: db $22 ; scratch   | duration: $08
#_F4F1: db $02 ; rest      | duration: $08
#_F4F2: db $22 ; scratch   | duration: $08
#_F4F3: db $04 ; rest      | duration: $10
#_F4F4: db $22 ; scratch   | duration: $08
#_F4F5: db $04 ; rest      | duration: $10
#_F4F6: db $22 ; scratch   | duration: $08
#_F4F7: db $05 ; rest      | duration: $18
#_F4F8: db $22 ; scratch   | duration: $08
#_F4F9: db $04 ; rest      | duration: $10

;===================================================================================================
;===================================================================================================
; SONG 04
;===================================================================================================
;===================================================================================================
Song04Square1:
#_F4FA: db $FD, $02 ; loop point
#_F4FC: db $A0 ; duration: $20
#_F4FD: db $37 ; G4
#_F4FE: db $90 ; duration: $10
#_F4FF: db $39 ; A4
#_F500: db $A0 ; duration: $20
#_F501: db $3B ; B4
#_F502: db $90 ; duration: $10
#_F503: db $3C ; C5
#_F504: db $A0 ; duration: $20
#_F505: db $3B ; B4
#_F506: db $90 ; duration: $10
#_F507: db $39 ; A4
#_F508: db $B0 ; duration: $30
#_F509: db $37 ; G4
#_F50A: db $90 ; duration: $10
#_F50B: db $34 ; E4
#_F50C: db $35 ; F4
#_F50D: db $37 ; G4
#_F50E: db $39 ; A4
#_F50F: db $3B ; B4
#_F510: db $3C ; C5
#_F511: db $B0 ; duration: $30
#_F512: db $3D ; C#5
#_F513: db $3E ; D5
#_F514: db $A0 ; duration: $20
#_F515: db $37 ; G4
#_F516: db $90 ; duration: $10
#_F517: db $39 ; A4
#_F518: db $A0 ; duration: $20
#_F519: db $3B ; B4
#_F51A: db $90 ; duration: $10
#_F51B: db $3C ; C5
#_F51C: db $A0 ; duration: $20
#_F51D: db $3B ; B4
#_F51E: db $90 ; duration: $10
#_F51F: db $39 ; A4
#_F520: db $B0 ; duration: $30
#_F521: db $37 ; G4
#_F522: db $90 ; duration: $10
#_F523: db $37 ; G4
#_F524: db $39 ; A4
#_F525: db $3B ; B4
#_F526: db $3C ; C5
#_F527: db $3E ; D5
#_F528: db $3F ; D#5
#_F529: db $E0 ; duration: $60
#_F52A: db $40 ; E5
#_F52B: db $A0 ; duration: $20
#_F52C: db $37 ; G4
#_F52D: db $90 ; duration: $10
#_F52E: db $39 ; A4
#_F52F: db $A0 ; duration: $20
#_F530: db $3B ; B4
#_F531: db $90 ; duration: $10
#_F532: db $3C ; C5
#_F533: db $A0 ; duration: $20
#_F534: db $3B ; B4
#_F535: db $90 ; duration: $10
#_F536: db $39 ; A4
#_F537: db $B0 ; duration: $30
#_F538: db $37 ; G4
#_F539: db $90 ; duration: $10
#_F53A: db $39 ; A4
#_F53B: db $3B ; B4
#_F53C: db $3D ; C#5
#_F53D: db $A0 ; duration: $20
#_F53E: db $3E ; D5
#_F53F: db $90 ; duration: $10
#_F540: db $40 ; E5
#_F541: db $E0 ; duration: $60
#_F542: db $41 ; F5
#_F543: db $A0 ; duration: $20
#_F544: db $39 ; A4
#_F545: db $90 ; duration: $10
#_F546: db $3B ; B4
#_F547: db $A0 ; duration: $20
#_F548: db $3C ; C5
#_F549: db $90 ; duration: $10
#_F54A: db $3E ; D5
#_F54B: db $40 ; E5
#_F54C: db $3C ; C5
#_F54D: db $47 ; B5
#_F54E: db $B0 ; duration: $30
#_F54F: db $45 ; A5
#_F550: db $A0 ; duration: $20
#_F551: db $40 ; E5
#_F552: db $90 ; duration: $10
#_F553: db $3E ; D5
#_F554: db $41 ; F5
#_F555: db $3E ; D5
#_F556: db $3B ; B4
#_F557: db $B0 ; duration: $30
#_F558: db $3C ; C5
#_F559: db $2F ; B3
#_F55A: db $FC ; loop part

#_F55B: db $E0 ; duration: $60
#_F55C: db $34 ; E4
#_F55D: db $34 ; E4
#_F55E: db $35 ; F4
#_F55F: db $38 ; G#4
#_F560: db $34 ; E4
#_F561: db $34 ; E4
#_F562: db $35 ; F4
#_F563: db $B0 ; duration: $30
#_F564: db $38 ; G#4
#_F565: db $88 ; duration: $08
#_F566: db $3C ; C5
#_F567: db $00 ; rest
#_F568: db $3A ; A#4
#_F569: db $00 ; rest
#_F56A: db $38 ; G#4
#_F56B: db $00 ; rest

#_F56C: db $FD, $02 ; loop point
#_F56E: db $90 ; duration: $10
#_F56F: db $3C ; C5
#_F570: db $88 ; duration: $08
#_F571: db $34 ; E4
#_F572: db $35 ; F4
#_F573: db $C0 ; duration: $40
#_F574: db $37 ; G4
#_F575: db $90 ; duration: $10
#_F576: db $3E ; D5
#_F577: db $88 ; duration: $08
#_F578: db $37 ; G4
#_F579: db $39 ; A4
#_F57A: db $C0 ; duration: $40
#_F57B: db $3A ; A#4
#_F57C: db $90 ; duration: $10
#_F57D: db $40 ; E5
#_F57E: db $88 ; duration: $08
#_F57F: db $39 ; A4
#_F580: db $3A ; A#4
#_F581: db $C0 ; duration: $40
#_F582: db $3C ; C5
#_F583: db $90 ; duration: $10
#_F584: db $3E ; D5
#_F585: db $88 ; duration: $08
#_F586: db $38 ; G#4
#_F587: db $3A ; A#4
#_F588: db $C0 ; duration: $40
#_F589: db $3C ; C5
#_F58A: db $FC ; loop part

#_F58B: db $98 ; duration: $18
#_F58C: db $37 ; G4
#_F58D: db $88 ; duration: $08
#_F58E: db $32 ; D4
#_F58F: db $34 ; E4
#_F590: db $37 ; G4
#_F591: db $98 ; duration: $18
#_F592: db $3B ; B4
#_F593: db $88 ; duration: $08
#_F594: db $34 ; E4
#_F595: db $3E ; D5
#_F596: db $3B ; B4
#_F597: db $98 ; duration: $18
#_F598: db $39 ; A4
#_F599: db $88 ; duration: $08
#_F59A: db $35 ; F4
#_F59B: db $39 ; A4
#_F59C: db $3C ; C5
#_F59D: db $90 ; duration: $10
#_F59E: db $3B ; B4
#_F59F: db $88 ; duration: $08
#_F5A0: db $39 ; A4
#_F5A1: db $00 ; rest
#_F5A2: db $38 ; G#4
#_F5A3: db $00 ; rest
#_F5A4: db $98 ; duration: $18
#_F5A5: db $37 ; G4
#_F5A6: db $88 ; duration: $08
#_F5A7: db $32 ; D4
#_F5A8: db $34 ; E4
#_F5A9: db $37 ; G4
#_F5AA: db $98 ; duration: $18
#_F5AB: db $3B ; B4
#_F5AC: db $88 ; duration: $08
#_F5AD: db $34 ; E4
#_F5AE: db $3E ; D5
#_F5AF: db $3B ; B4
#_F5B0: db $98 ; duration: $18
#_F5B1: db $39 ; A4
#_F5B2: db $88 ; duration: $08
#_F5B3: db $35 ; F4
#_F5B4: db $39 ; A4
#_F5B5: db $3C ; C5
#_F5B6: db $B0 ; duration: $30
#_F5B7: db $3B ; B4
#_F5B8: db $90 ; duration: $10
#_F5B9: db $3B ; B4
#_F5BA: db $88 ; duration: $08
#_F5BB: db $39 ; A4
#_F5BC: db $00 ; rest
#_F5BD: db $38 ; G#4
#_F5BE: db $00 ; rest
#_F5BF: db $E0 ; duration: $60
#_F5C0: db $37 ; G4

#_F5C1: db $FE ; loop song

;---------------------------------------------------------------------------------------------------

Song04Square2:
#_F5C2: db $FD, $02 ; loop point
#_F5C4: db $B0 ; duration: $30
#_F5C5: db $40 ; E5
#_F5C6: db $40 ; E5
#_F5C7: db $40 ; E5
#_F5C8: db $40 ; E5
#_F5C9: db $43 ; G5
#_F5CA: db $40 ; E5
#_F5CB: db $41 ; F5
#_F5CC: db $41 ; F5
#_F5CD: db $41 ; F5
#_F5CE: db $41 ; F5
#_F5CF: db $41 ; F5
#_F5D0: db $41 ; F5
#_F5D1: db $41 ; F5
#_F5D2: db $43 ; G5
#_F5D3: db $E0 ; duration: $60
#_F5D4: db $43 ; G5
#_F5D5: db $B0 ; duration: $30
#_F5D6: db $40 ; E5
#_F5D7: db $40 ; E5
#_F5D8: db $40 ; E5
#_F5D9: db $40 ; E5
#_F5DA: db $43 ; G5
#_F5DB: db $A0 ; duration: $20
#_F5DC: db $43 ; G5
#_F5DD: db $90 ; duration: $10
#_F5DE: db $39 ; A4
#_F5DF: db $E0 ; duration: $60
#_F5E0: db $3E ; D5
#_F5E1: db $B0 ; duration: $30
#_F5E2: db $41 ; F5
#_F5E3: db $45 ; A5
#_F5E4: db $43 ; G5
#_F5E5: db $3D ; C#5
#_F5E6: db $45 ; A5
#_F5E7: db $44 ; G#5
#_F5E8: db $43 ; G5
#_F5E9: db $88 ; duration: $08
#_F5EA: db $33 ; D#4
#_F5EB: db $2B ; G3
#_F5EC: db $2F ; B3
#_F5ED: db $39 ; A4
#_F5EE: db $90 ; duration: $10
#_F5EF: db $37 ; G4
#_F5F0: db $FC ; loop part

#_F5F1: db $E0 ; duration: $60
#_F5F2: db $3C ; C5
#_F5F3: db $3A ; A#4
#_F5F4: db $3C ; C5
#_F5F5: db $3E ; D5
#_F5F6: db $3C ; C5
#_F5F7: db $3A ; A#4
#_F5F8: db $3C ; C5
#_F5F9: db $B0 ; duration: $30
#_F5FA: db $3E ; D5
#_F5FB: db $41 ; F5

#_F5FC: db $FD, $02 ; loop point
#_F5FE: db $90 ; duration: $10
#_F5FF: db $34 ; E4
#_F600: db $88 ; duration: $08
#_F601: db $30 ; C4
#_F602: db $32 ; D4
#_F603: db $A0 ; duration: $20
#_F604: db $34 ; E4
#_F605: db $88 ; duration: $08
#_F606: db $30 ; C4
#_F607: db $32 ; D4
#_F608: db $A0 ; duration: $20
#_F609: db $34 ; E4
#_F60A: db $88 ; duration: $08
#_F60B: db $34 ; E4
#_F60C: db $35 ; F4
#_F60D: db $A0 ; duration: $20
#_F60E: db $37 ; G4
#_F60F: db $88 ; duration: $08
#_F610: db $34 ; E4
#_F611: db $35 ; F4
#_F612: db $90 ; duration: $10
#_F613: db $37 ; G4
#_F614: db $3C ; C5
#_F615: db $88 ; duration: $08
#_F616: db $35 ; F4
#_F617: db $37 ; G4
#_F618: db $A0 ; duration: $20
#_F619: db $39 ; A4
#_F61A: db $88 ; duration: $08
#_F61B: db $35 ; F4
#_F61C: db $37 ; G4
#_F61D: db $90 ; duration: $10
#_F61E: db $39 ; A4
#_F61F: db $38 ; G#4
#_F620: db $88 ; duration: $08
#_F621: db $35 ; F4
#_F622: db $37 ; G4
#_F623: db $98 ; duration: $18
#_F624: db $38 ; G#4
#_F625: db $88 ; duration: $08
#_F626: db $35 ; F4
#_F627: db $41 ; F5
#_F628: db $3C ; C5
#_F629: db $38 ; G#4
#_F62A: db $35 ; F4
#_F62B: db $FC ; loop part

#_F62C: db $88 ; duration: $08
#_F62D: db $30 ; C4
#_F62E: db $2F ; B3
#_F62F: db $34 ; E4
#_F630: db $90 ; duration: $10
#_F631: db $2F ; B3
#_F632: db $88 ; duration: $08
#_F633: db $34 ; E4
#_F634: db $37 ; G4
#_F635: db $36 ; F#4
#_F636: db $34 ; E4
#_F637: db $90 ; duration: $10
#_F638: db $2F ; B3
#_F639: db $88 ; duration: $08
#_F63A: db $34 ; E4
#_F63B: db $35 ; F4
#_F63C: db $2D ; A3
#_F63D: db $90 ; duration: $10
#_F63E: db $30 ; C4
#_F63F: db $35 ; F4
#_F640: db $88 ; duration: $08
#_F641: db $37 ; G4
#_F642: db $00 ; rest
#_F643: db $35 ; F4
#_F644: db $00 ; rest
#_F645: db $35 ; F4
#_F646: db $00 ; rest
#_F647: db $30 ; C4
#_F648: db $2F ; B3
#_F649: db $34 ; E4
#_F64A: db $90 ; duration: $10
#_F64B: db $2F ; B3
#_F64C: db $88 ; duration: $08
#_F64D: db $34 ; E4
#_F64E: db $37 ; G4
#_F64F: db $36 ; F#4
#_F650: db $34 ; E4
#_F651: db $90 ; duration: $10
#_F652: db $2F ; B3
#_F653: db $88 ; duration: $08
#_F654: db $34 ; E4
#_F655: db $35 ; F4
#_F656: db $2D ; A3
#_F657: db $90 ; duration: $10
#_F658: db $30 ; C4
#_F659: db $35 ; F4
#_F65A: db $B0 ; duration: $30
#_F65B: db $37 ; G4
#_F65C: db $90 ; duration: $10
#_F65D: db $37 ; G4
#_F65E: db $88 ; duration: $08
#_F65F: db $35 ; F4
#_F660: db $00 ; rest
#_F661: db $35 ; F4
#_F662: db $00 ; rest
#_F663: db $E0 ; duration: $60
#_F664: db $32 ; D4

;---------------------------------------------------------------------------------------------------

Song04Triangle:
#_F665: db $FD, $02 ; loop point
#_F667: db $90 ; duration: $10
#_F668: db $30 ; C4
#_F669: db $88 ; duration: $08
#_F66A: db $43 ; G5
#_F66B: db $00 ; rest
#_F66C: db $43 ; G5
#_F66D: db $00 ; rest
#_F66E: db $90 ; duration: $10
#_F66F: db $2B ; G3
#_F670: db $88 ; duration: $08
#_F671: db $43 ; G5
#_F672: db $00 ; rest
#_F673: db $43 ; G5
#_F674: db $00 ; rest
#_F675: db $90 ; duration: $10
#_F676: db $30 ; C4
#_F677: db $88 ; duration: $08
#_F678: db $43 ; G5
#_F679: db $00 ; rest
#_F67A: db $43 ; G5
#_F67B: db $00 ; rest
#_F67C: db $90 ; duration: $10
#_F67D: db $2B ; G3
#_F67E: db $88 ; duration: $08
#_F67F: db $43 ; G5
#_F680: db $00 ; rest
#_F681: db $43 ; G5
#_F682: db $00 ; rest
#_F683: db $90 ; duration: $10
#_F684: db $30 ; C4
#_F685: db $88 ; duration: $08
#_F686: db $43 ; G5
#_F687: db $00 ; rest
#_F688: db $43 ; G5
#_F689: db $00 ; rest
#_F68A: db $90 ; duration: $10
#_F68B: db $2B ; G3
#_F68C: db $88 ; duration: $08
#_F68D: db $43 ; G5
#_F68E: db $00 ; rest
#_F68F: db $43 ; G5
#_F690: db $00 ; rest
#_F691: db $90 ; duration: $10
#_F692: db $2B ; G3
#_F693: db $88 ; duration: $08
#_F694: db $43 ; G5
#_F695: db $00 ; rest
#_F696: db $43 ; G5
#_F697: db $00 ; rest
#_F698: db $90 ; duration: $10
#_F699: db $32 ; D4
#_F69A: db $88 ; duration: $08
#_F69B: db $43 ; G5
#_F69C: db $00 ; rest
#_F69D: db $43 ; G5
#_F69E: db $00 ; rest
#_F69F: db $90 ; duration: $10
#_F6A0: db $2B ; G3
#_F6A1: db $88 ; duration: $08
#_F6A2: db $41 ; F5
#_F6A3: db $00 ; rest
#_F6A4: db $41 ; F5
#_F6A5: db $00 ; rest
#_F6A6: db $90 ; duration: $10
#_F6A7: db $32 ; D4
#_F6A8: db $88 ; duration: $08
#_F6A9: db $41 ; F5
#_F6AA: db $00 ; rest
#_F6AB: db $41 ; F5
#_F6AC: db $00 ; rest
#_F6AD: db $90 ; duration: $10
#_F6AE: db $2B ; G3
#_F6AF: db $88 ; duration: $08
#_F6B0: db $41 ; F5
#_F6B1: db $00 ; rest
#_F6B2: db $41 ; F5
#_F6B3: db $00 ; rest
#_F6B4: db $90 ; duration: $10
#_F6B5: db $32 ; D4
#_F6B6: db $88 ; duration: $08
#_F6B7: db $41 ; F5
#_F6B8: db $00 ; rest
#_F6B9: db $41 ; F5
#_F6BA: db $00 ; rest
#_F6BB: db $90 ; duration: $10
#_F6BC: db $2B ; G3
#_F6BD: db $88 ; duration: $08
#_F6BE: db $41 ; F5
#_F6BF: db $00 ; rest
#_F6C0: db $41 ; F5
#_F6C1: db $00 ; rest
#_F6C2: db $90 ; duration: $10
#_F6C3: db $32 ; D4
#_F6C4: db $88 ; duration: $08
#_F6C5: db $41 ; F5
#_F6C6: db $00 ; rest
#_F6C7: db $47 ; B5
#_F6C8: db $00 ; rest
#_F6C9: db $90 ; duration: $10
#_F6CA: db $30 ; C4
#_F6CB: db $88 ; duration: $08
#_F6CC: db $43 ; G5
#_F6CD: db $00 ; rest
#_F6CE: db $43 ; G5
#_F6CF: db $00 ; rest
#_F6D0: db $90 ; duration: $10
#_F6D1: db $2B ; G3
#_F6D2: db $88 ; duration: $08
#_F6D3: db $45 ; A5
#_F6D4: db $00 ; rest
#_F6D5: db $43 ; G5
#_F6D6: db $00 ; rest
#_F6D7: db $90 ; duration: $10
#_F6D8: db $30 ; C4
#_F6D9: db $88 ; duration: $08
#_F6DA: db $43 ; G5
#_F6DB: db $00 ; rest
#_F6DC: db $43 ; G5
#_F6DD: db $00 ; rest
#_F6DE: db $90 ; duration: $10
#_F6DF: db $2B ; G3
#_F6E0: db $88 ; duration: $08
#_F6E1: db $43 ; G5
#_F6E2: db $00 ; rest
#_F6E3: db $43 ; G5
#_F6E4: db $00 ; rest
#_F6E5: db $90 ; duration: $10
#_F6E6: db $30 ; C4
#_F6E7: db $88 ; duration: $08
#_F6E8: db $43 ; G5
#_F6E9: db $00 ; rest
#_F6EA: db $43 ; G5
#_F6EB: db $00 ; rest
#_F6EC: db $90 ; duration: $10
#_F6ED: db $2B ; G3
#_F6EE: db $88 ; duration: $08
#_F6EF: db $43 ; G5
#_F6F0: db $00 ; rest
#_F6F1: db $43 ; G5
#_F6F2: db $00 ; rest
#_F6F3: db $90 ; duration: $10
#_F6F4: db $31 ; C#4
#_F6F5: db $88 ; duration: $08
#_F6F6: db $43 ; G5
#_F6F7: db $00 ; rest
#_F6F8: db $43 ; G5
#_F6F9: db $00 ; rest
#_F6FA: db $90 ; duration: $10
#_F6FB: db $34 ; E4
#_F6FC: db $88 ; duration: $08
#_F6FD: db $43 ; G5
#_F6FE: db $00 ; rest
#_F6FF: db $90 ; duration: $10
#_F700: db $2D ; A3
#_F701: db $32 ; D4
#_F702: db $88 ; duration: $08
#_F703: db $45 ; A5
#_F704: db $00 ; rest
#_F705: db $45 ; A5
#_F706: db $00 ; rest
#_F707: db $90 ; duration: $10
#_F708: db $2D ; A3
#_F709: db $88 ; duration: $08
#_F70A: db $45 ; A5
#_F70B: db $00 ; rest
#_F70C: db $45 ; A5
#_F70D: db $00 ; rest
#_F70E: db $90 ; duration: $10
#_F70F: db $29 ; F3
#_F710: db $88 ; duration: $08
#_F711: db $3C ; C5
#_F712: db $3C ; C5
#_F713: db $41 ; F5
#_F714: db $00 ; rest
#_F715: db $90 ; duration: $10
#_F716: db $2A ; F#3
#_F717: db $88 ; duration: $08
#_F718: db $3F ; D#5
#_F719: db $3F ; D#5
#_F71A: db $44 ; G#5
#_F71B: db $00 ; rest
#_F71C: db $90 ; duration: $10
#_F71D: db $30 ; C4
#_F71E: db $88 ; duration: $08
#_F71F: db $43 ; G5
#_F720: db $00 ; rest
#_F721: db $90 ; duration: $10
#_F722: db $2F ; B3
#_F723: db $2D ; A3
#_F724: db $88 ; duration: $08
#_F725: db $43 ; G5
#_F726: db $00 ; rest
#_F727: db $40 ; E5
#_F728: db $00 ; rest
#_F729: db $90 ; duration: $10
#_F72A: db $32 ; D4
#_F72B: db $88 ; duration: $08
#_F72C: db $41 ; F5
#_F72D: db $00 ; rest
#_F72E: db $41 ; F5
#_F72F: db $00 ; rest
#_F730: db $90 ; duration: $10
#_F731: db $2B ; G3
#_F732: db $88 ; duration: $08
#_F733: db $41 ; F5
#_F734: db $00 ; rest
#_F735: db $3E ; D5
#_F736: db $00 ; rest
#_F737: db $90 ; duration: $10
#_F738: db $30 ; C4
#_F739: db $88 ; duration: $08
#_F73A: db $43 ; G5
#_F73B: db $00 ; rest
#_F73C: db $43 ; G5
#_F73D: db $00 ; rest
#_F73E: db $90 ; duration: $10
#_F73F: db $2B ; G3
#_F740: db $88 ; duration: $08
#_F741: db $43 ; G5
#_F742: db $00 ; rest
#_F743: db $43 ; G5
#_F744: db $00 ; rest
#_F745: db $FC ; loop part

#_F746: db $FD, $02 ; loop point
#_F748: db $90 ; duration: $10
#_F749: db $30 ; C4
#_F74A: db $88 ; duration: $08
#_F74B: db $34 ; E4
#_F74C: db $35 ; F4
#_F74D: db $90 ; duration: $10
#_F74E: db $37 ; G4
#_F74F: db $3C ; C5
#_F750: db $88 ; duration: $08
#_F751: db $34 ; E4
#_F752: db $35 ; F4
#_F753: db $90 ; duration: $10
#_F754: db $37 ; G4
#_F755: db $30 ; C4
#_F756: db $88 ; duration: $08
#_F757: db $34 ; E4
#_F758: db $35 ; F4
#_F759: db $90 ; duration: $10
#_F75A: db $37 ; G4
#_F75B: db $3C ; C5
#_F75C: db $88 ; duration: $08
#_F75D: db $34 ; E4
#_F75E: db $35 ; F4
#_F75F: db $90 ; duration: $10
#_F760: db $37 ; G4
#_F761: db $35 ; F4
#_F762: db $88 ; duration: $08
#_F763: db $39 ; A4
#_F764: db $3A ; A#4
#_F765: db $90 ; duration: $10
#_F766: db $3C ; C5
#_F767: db $41 ; F5
#_F768: db $88 ; duration: $08
#_F769: db $39 ; A4
#_F76A: db $3A ; A#4
#_F76B: db $90 ; duration: $10
#_F76C: db $3C ; C5
#_F76D: db $98 ; duration: $18
#_F76E: db $35 ; F4
#_F76F: db $88 ; duration: $08
#_F770: db $38 ; G#4
#_F771: db $3C ; C5
#_F772: db $41 ; F5
#_F773: db $44 ; G#5
#_F774: db $00 ; rest
#_F775: db $43 ; G5
#_F776: db $00 ; rest
#_F777: db $41 ; F5
#_F778: db $00 ; rest
#_F779: db $FC ; loop part

#_F77A: db $FD, $02 ; loop point
#_F77C: db $90 ; duration: $10
#_F77D: db $30 ; C4
#_F77E: db $88 ; duration: $08
#_F77F: db $43 ; G5
#_F780: db $43 ; G5
#_F781: db $90 ; duration: $10
#_F782: db $48 ; C6
#_F783: db $2B ; G3
#_F784: db $88 ; duration: $08
#_F785: db $43 ; G5
#_F786: db $00 ; rest
#_F787: db $90 ; duration: $10
#_F788: db $43 ; G5
#_F789: db $30 ; C4
#_F78A: db $88 ; duration: $08
#_F78B: db $46 ; A#5
#_F78C: db $46 ; A#5
#_F78D: db $90 ; duration: $10
#_F78E: db $46 ; A#5
#_F78F: db $2B ; G3
#_F790: db $88 ; duration: $08
#_F791: db $43 ; G5
#_F792: db $00 ; rest
#_F793: db $90 ; duration: $10
#_F794: db $46 ; A#5
#_F795: db $29 ; F3
#_F796: db $88 ; duration: $08
#_F797: db $41 ; F5
#_F798: db $41 ; F5
#_F799: db $90 ; duration: $10
#_F79A: db $41 ; F5
#_F79B: db $30 ; C4
#_F79C: db $88 ; duration: $08
#_F79D: db $41 ; F5
#_F79E: db $00 ; rest
#_F79F: db $90 ; duration: $10
#_F7A0: db $41 ; F5
#_F7A1: db $29 ; F3
#_F7A2: db $88 ; duration: $08
#_F7A3: db $41 ; F5
#_F7A4: db $41 ; F5
#_F7A5: db $90 ; duration: $10
#_F7A6: db $41 ; F5
#_F7A7: db $30 ; C4
#_F7A8: db $88 ; duration: $08
#_F7A9: db $3C ; C5
#_F7AA: db $38 ; G#4
#_F7AB: db $35 ; F4
#_F7AC: db $32 ; D4
#_F7AD: db $FC ; loop part

#_F7AE: db $A8 ; duration: $28
#_F7AF: db $30 ; C4
#_F7B0: db $88 ; duration: $08
#_F7B1: db $2B ; G3
#_F7B2: db $A8 ; duration: $28
#_F7B3: db $34 ; E4
#_F7B4: db $88 ; duration: $08
#_F7B5: db $2F ; B3
#_F7B6: db $A8 ; duration: $28
#_F7B7: db $35 ; F4
#_F7B8: db $88 ; duration: $08
#_F7B9: db $30 ; C4
#_F7BA: db $37 ; G4
#_F7BB: db $00 ; rest
#_F7BC: db $37 ; G4
#_F7BD: db $00 ; rest
#_F7BE: db $37 ; G4
#_F7BF: db $00 ; rest
#_F7C0: db $A8 ; duration: $28
#_F7C1: db $30 ; C4
#_F7C2: db $88 ; duration: $08
#_F7C3: db $2B ; G3
#_F7C4: db $A8 ; duration: $28
#_F7C5: db $34 ; E4
#_F7C6: db $88 ; duration: $08
#_F7C7: db $2F ; B3
#_F7C8: db $A8 ; duration: $28
#_F7C9: db $35 ; F4
#_F7CA: db $88 ; duration: $08
#_F7CB: db $30 ; C4
#_F7CC: db $98 ; duration: $18
#_F7CD: db $37 ; G4
#_F7CE: db $88 ; duration: $08
#_F7CF: db $32 ; D4
#_F7D0: db $3E ; D5
#_F7D1: db $3B ; B4
#_F7D2: db $B0 ; duration: $30
#_F7D3: db $37 ; G4
#_F7D4: db $37 ; G4
#_F7D5: db $88 ; duration: $08
#_F7D6: db $2B ; G3
#_F7D7: db $00 ; rest
#_F7D8: db $2D ; A3
#_F7D9: db $00 ; rest
#_F7DA: db $2F ; B3
#_F7DB: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song04Noise:
#_F7DC: db $FD, $20 ; loop point
#_F7DE: db $0A ; rest      | duration: $60
#_F7DF: db $FC ; loop part

#_F7E0: db $FD, $03 ; loop point
#_F7E2: db $12 ; snare hit | duration: $08
#_F7E3: db $08 ; rest      | duration: $48
#_F7E4: db $12 ; snare hit | duration: $08
#_F7E5: db $12 ; snare hit | duration: $08
#_F7E6: db $FC ; loop part

#_F7E7: db $12 ; snare hit | duration: $08
#_F7E8: db $05 ; rest      | duration: $18
#_F7E9: db $12 ; snare hit | duration: $08
#_F7EA: db $12 ; snare hit | duration: $08
#_F7EB: db $12 ; snare hit | duration: $08
#_F7EC: db $05 ; rest      | duration: $18
#_F7ED: db $12 ; snare hit | duration: $08
#_F7EE: db $12 ; snare hit | duration: $08

#_F7EF: db $FD, $03 ; loop point
#_F7F1: db $12 ; snare hit | duration: $08
#_F7F2: db $08 ; rest      | duration: $48
#_F7F3: db $12 ; snare hit | duration: $08
#_F7F4: db $12 ; snare hit | duration: $08
#_F7F5: db $FC ; loop part

#_F7F6: db $12 ; snare hit | duration: $08
#_F7F7: db $05 ; rest      | duration: $18
#_F7F8: db $12 ; snare hit | duration: $08
#_F7F9: db $12 ; snare hit | duration: $08
#_F7FA: db $12 ; snare hit | duration: $08
#_F7FB: db $05 ; rest      | duration: $18
#_F7FC: db $12 ; snare hit | duration: $08
#_F7FD: db $12 ; snare hit | duration: $08
#_F7FE: db $12 ; snare hit | duration: $08
#_F7FF: db $09 ; rest      | duration: $58

#_F800: db $FD, $0B ; loop point
#_F802: db $0A ; rest      | duration: $60
#_F803: db $FC ; loop part

#_F804: db $07 ; rest      | duration: $30
#_F805: db $0A ; rest      | duration: $60

;===================================================================================================
;===================================================================================================
; SONG 05
;===================================================================================================
;===================================================================================================
Song05Square1:
#_F806: db $FD, $02 ; loop point
#_F808: db $86 ; duration: $06
#_F809: db $39 ; A4
#_F80A: db $00 ; rest
#_F80B: db $3C ; C5
#_F80C: db $00 ; rest
#_F80D: db $40 ; E5
#_F80E: db $00 ; rest
#_F80F: db $98 ; duration: $18
#_F810: db $3F ; D#5
#_F811: db $86 ; duration: $06
#_F812: db $39 ; A4
#_F813: db $00 ; rest
#_F814: db $3C ; C5
#_F815: db $00 ; rest
#_F816: db $40 ; E5
#_F817: db $00 ; rest
#_F818: db $A4 ; duration: $24
#_F819: db $3F ; D#5
#_F81A: db $8C ; duration: $0C
#_F81B: db $40 ; E5
#_F81C: db $42 ; F#5
#_F81D: db $86 ; duration: $06
#_F81E: db $43 ; G5
#_F81F: db $00 ; rest
#_F820: db $8C ; duration: $0C
#_F821: db $42 ; F#5
#_F822: db $86 ; duration: $06
#_F823: db $43 ; G5
#_F824: db $00 ; rest
#_F825: db $39 ; A4
#_F826: db $00 ; rest
#_F827: db $3C ; C5
#_F828: db $00 ; rest
#_F829: db $40 ; E5
#_F82A: db $00 ; rest
#_F82B: db $98 ; duration: $18
#_F82C: db $3F ; D#5
#_F82D: db $86 ; duration: $06
#_F82E: db $39 ; A4
#_F82F: db $00 ; rest
#_F830: db $3C ; C5
#_F831: db $00 ; rest
#_F832: db $40 ; E5
#_F833: db $00 ; rest
#_F834: db $A4 ; duration: $24
#_F835: db $3F ; D#5
#_F836: db $8C ; duration: $0C
#_F837: db $40 ; E5
#_F838: db $86 ; duration: $06
#_F839: db $42 ; F#5
#_F83A: db $43 ; G5
#_F83B: db $00 ; rest
#_F83C: db $43 ; G5
#_F83D: db $8C ; duration: $0C
#_F83E: db $42 ; F#5
#_F83F: db $86 ; duration: $06
#_F840: db $43 ; G5
#_F841: db $00 ; rest
#_F842: db $FC ; loop part

#_F843: db $FD, $02 ; loop point
#_F845: db $86 ; duration: $06
#_F846: db $3C ; C5
#_F847: db $00 ; rest
#_F848: db $3F ; D#5
#_F849: db $00 ; rest
#_F84A: db $43 ; G5
#_F84B: db $00 ; rest
#_F84C: db $98 ; duration: $18
#_F84D: db $42 ; F#5
#_F84E: db $86 ; duration: $06
#_F84F: db $3C ; C5
#_F850: db $00 ; rest
#_F851: db $3F ; D#5
#_F852: db $00 ; rest
#_F853: db $43 ; G5
#_F854: db $00 ; rest
#_F855: db $A4 ; duration: $24
#_F856: db $42 ; F#5
#_F857: db $8C ; duration: $0C
#_F858: db $43 ; G5
#_F859: db $45 ; A5
#_F85A: db $86 ; duration: $06
#_F85B: db $46 ; A#5
#_F85C: db $00 ; rest
#_F85D: db $8C ; duration: $0C
#_F85E: db $45 ; A5
#_F85F: db $86 ; duration: $06
#_F860: db $46 ; A#5
#_F861: db $00 ; rest
#_F862: db $3C ; C5
#_F863: db $00 ; rest
#_F864: db $3F ; D#5
#_F865: db $00 ; rest
#_F866: db $43 ; G5
#_F867: db $00 ; rest
#_F868: db $98 ; duration: $18
#_F869: db $42 ; F#5
#_F86A: db $86 ; duration: $06
#_F86B: db $3C ; C5
#_F86C: db $00 ; rest
#_F86D: db $3F ; D#5
#_F86E: db $00 ; rest
#_F86F: db $43 ; G5
#_F870: db $00 ; rest
#_F871: db $A4 ; duration: $24
#_F872: db $42 ; F#5
#_F873: db $8C ; duration: $0C
#_F874: db $43 ; G5
#_F875: db $86 ; duration: $06
#_F876: db $45 ; A5
#_F877: db $46 ; A#5
#_F878: db $00 ; rest
#_F879: db $46 ; A#5
#_F87A: db $8C ; duration: $0C
#_F87B: db $45 ; A5
#_F87C: db $86 ; duration: $06
#_F87D: db $46 ; A#5
#_F87E: db $00 ; rest
#_F87F: db $FC ; loop part

#_F880: db $98 ; duration: $18
#_F881: db $00 ; rest
#_F882: db $8C ; duration: $0C
#_F883: db $46 ; A#5
#_F884: db $00 ; rest
#_F885: db $44 ; G#5
#_F886: db $42 ; F#5
#_F887: db $00 ; rest
#_F888: db $C8 ; duration: $48
#_F889: db $41 ; F5
#_F88A: db $8C ; duration: $0C
#_F88B: db $3E ; D5
#_F88C: db $3F ; D#5
#_F88D: db $A4 ; duration: $24
#_F88E: db $41 ; F5
#_F88F: db $8C ; duration: $0C
#_F890: db $41 ; F5
#_F891: db $98 ; duration: $18
#_F892: db $3F ; D#5
#_F893: db $3D ; C#5
#_F894: db $B0 ; duration: $30
#_F895: db $3E ; D5
#_F896: db $98 ; duration: $18
#_F897: db $3A ; A#4
#_F898: db $8C ; duration: $0C
#_F899: db $3E ; D5
#_F89A: db $41 ; F5
#_F89B: db $46 ; A#5
#_F89C: db $98 ; duration: $18
#_F89D: db $00 ; rest
#_F89E: db $8C ; duration: $0C
#_F89F: db $45 ; A5
#_F8A0: db $45 ; A5
#_F8A1: db $44 ; G#5
#_F8A2: db $42 ; F#5
#_F8A3: db $00 ; rest
#_F8A4: db $C8 ; duration: $48
#_F8A5: db $40 ; E5
#_F8A6: db $8C ; duration: $0C
#_F8A7: db $3D ; C#5
#_F8A8: db $3E ; D5
#_F8A9: db $C8 ; duration: $48
#_F8AA: db $40 ; E5

#_F8AB: db $FD, $02 ; loop point
#_F8AD: db $8C ; duration: $0C
#_F8AE: db $3C ; C5
#_F8AF: db $3E ; D5
#_F8B0: db $C8 ; duration: $48
#_F8B1: db $40 ; E5
#_F8B2: db $FC ; loop part

#_F8B3: db $A4 ; duration: $24
#_F8B4: db $00 ; rest
#_F8B5: db $8C ; duration: $0C
#_F8B6: db $40 ; E5
#_F8B7: db $3C ; C5
#_F8B8: db $3E ; D5
#_F8B9: db $40 ; E5
#_F8BA: db $00 ; rest
#_F8BB: db $A4 ; duration: $24
#_F8BC: db $3E ; D5

#_F8BD: db $FE ; loop song

;---------------------------------------------------------------------------------------------------

Song05Square2:
#_F8BE: db $FD, $1C ; loop point
#_F8C0: db $8C ; duration: $0C
#_F8C1: db $00 ; rest
#_F8C2: db $86 ; duration: $06
#_F8C3: db $30 ; C4
#_F8C4: db $00 ; rest
#_F8C5: db $FC ; loop part

#_F8C6: db $8C ; duration: $0C
#_F8C7: db $00 ; rest
#_F8C8: db $34 ; E4
#_F8C9: db $39 ; A4
#_F8CA: db $3C ; C5
#_F8CB: db $86 ; duration: $06
#_F8CC: db $3B ; B4
#_F8CD: db $3C ; C5
#_F8CE: db $00 ; rest
#_F8CF: db $3C ; C5
#_F8D0: db $8C ; duration: $0C
#_F8D1: db $3F ; D#5
#_F8D2: db $86 ; duration: $06
#_F8D3: db $40 ; E5
#_F8D4: db $00 ; rest

#_F8D5: db $FD, $1C ; loop point
#_F8D7: db $8C ; duration: $0C
#_F8D8: db $00 ; rest
#_F8D9: db $86 ; duration: $06
#_F8DA: db $33 ; D#4
#_F8DB: db $00 ; rest
#_F8DC: db $FC ; loop part

#_F8DD: db $8C ; duration: $0C
#_F8DE: db $00 ; rest
#_F8DF: db $37 ; G4
#_F8E0: db $3C ; C5
#_F8E1: db $3F ; D#5
#_F8E2: db $86 ; duration: $06
#_F8E3: db $3E ; D5
#_F8E4: db $3F ; D#5
#_F8E5: db $00 ; rest
#_F8E6: db $3F ; D#5
#_F8E7: db $8C ; duration: $0C
#_F8E8: db $42 ; F#5
#_F8E9: db $86 ; duration: $06
#_F8EA: db $43 ; G5
#_F8EB: db $00 ; rest
#_F8EC: db $8C ; duration: $0C
#_F8ED: db $36 ; F#4
#_F8EE: db $3A ; A#4
#_F8EF: db $42 ; F#5
#_F8F0: db $3F ; D#5
#_F8F1: db $41 ; F5
#_F8F2: db $3D ; C#5
#_F8F3: db $36 ; F#4
#_F8F4: db $39 ; A4
#_F8F5: db $3E ; D5
#_F8F6: db $35 ; F4
#_F8F7: db $3A ; A#4
#_F8F8: db $98 ; duration: $18
#_F8F9: db $39 ; A4
#_F8FA: db $8C ; duration: $0C
#_F8FB: db $3A ; A#4
#_F8FC: db $3C ; C5
#_F8FD: db $3D ; C#5
#_F8FE: db $3A ; A#4
#_F8FF: db $36 ; F#4
#_F900: db $3D ; C#5
#_F901: db $3A ; A#4
#_F902: db $36 ; F#4
#_F903: db $3A ; A#4
#_F904: db $33 ; D#4
#_F905: db $36 ; F#4
#_F906: db $35 ; F4
#_F907: db $39 ; A4
#_F908: db $32 ; D4
#_F909: db $98 ; duration: $18
#_F90A: db $35 ; F4
#_F90B: db $8C ; duration: $0C
#_F90C: db $35 ; F4
#_F90D: db $3A ; A#4
#_F90E: db $3E ; D5
#_F90F: db $86 ; duration: $06
#_F910: db $39 ; A4
#_F911: db $36 ; F#4
#_F912: db $39 ; A4
#_F913: db $3D ; C#5
#_F914: db $8C ; duration: $0C
#_F915: db $42 ; F#5
#_F916: db $3E ; D5
#_F917: db $40 ; E5
#_F918: db $A4 ; duration: $24
#_F919: db $39 ; A4
#_F91A: db $86 ; duration: $06
#_F91B: db $38 ; G#4
#_F91C: db $39 ; A4
#_F91D: db $3D ; C#5
#_F91E: db $34 ; E4
#_F91F: db $8C ; duration: $0C
#_F920: db $38 ; G#4
#_F921: db $98 ; duration: $18
#_F922: db $39 ; A4
#_F923: db $8C ; duration: $0C
#_F924: db $34 ; E4
#_F925: db $3B ; B4
#_F926: db $37 ; G4
#_F927: db $00 ; rest

#_F928: db $FD, $02 ; loop point
#_F92A: db $86 ; duration: $06
#_F92B: db $3B ; B4
#_F92C: db $92 ; duration: $12
#_F92D: db $00 ; rest
#_F92E: db $86 ; duration: $06
#_F92F: db $37 ; G4
#_F930: db $92 ; duration: $12
#_F931: db $00 ; rest
#_F932: db $8C ; duration: $0C
#_F933: db $34 ; E4
#_F934: db $35 ; F4
#_F935: db $98 ; duration: $18
#_F936: db $37 ; G4
#_F937: db $FC ; loop part

#_F938: db $86 ; duration: $06
#_F939: db $3B ; B4
#_F93A: db $92 ; duration: $12
#_F93B: db $00 ; rest
#_F93C: db $86 ; duration: $06
#_F93D: db $39 ; A4
#_F93E: db $92 ; duration: $12
#_F93F: db $00 ; rest
#_F940: db $86 ; duration: $06
#_F941: db $37 ; G4
#_F942: db $92 ; duration: $12
#_F943: db $00 ; rest
#_F944: db $86 ; duration: $06
#_F945: db $35 ; F4
#_F946: db $00 ; rest

#_F947: db $FD, $04 ; loop point
#_F949: db $86 ; duration: $06
#_F94A: db $38 ; G#4
#_F94B: db $39 ; A4
#_F94C: db $FC ; loop part

#_F94D: db $8C ; duration: $0C
#_F94E: db $38 ; G#4
#_F94F: db $2F ; B3
#_F950: db $2D ; A3
#_F951: db $2C ; G#3

;---------------------------------------------------------------------------------------------------

Song05Triangle:
#_F952: db $FD, $0F ; loop point
#_F954: db $8C ; duration: $0C
#_F955: db $2D ; A3
#_F956: db $86 ; duration: $06
#_F957: db $40 ; E5
#_F958: db $00 ; rest
#_F959: db $8C ; duration: $0C
#_F95A: db $34 ; E4
#_F95B: db $86 ; duration: $06
#_F95C: db $40 ; E5
#_F95D: db $00 ; rest
#_F95E: db $FC ; loop part

#_F95F: db $8C ; duration: $0C
#_F960: db $2D ; A3
#_F961: db $86 ; duration: $06
#_F962: db $40 ; E5
#_F963: db $00 ; rest
#_F964: db $8C ; duration: $0C
#_F965: db $2F ; B3
#_F966: db $86 ; duration: $06
#_F967: db $42 ; F#5
#_F968: db $00 ; rest

#_F969: db $FD, $0F ; loop point
#_F96B: db $8C ; duration: $0C
#_F96C: db $30 ; C4
#_F96D: db $86 ; duration: $06
#_F96E: db $43 ; G5
#_F96F: db $00 ; rest
#_F970: db $8C ; duration: $0C
#_F971: db $2B ; G3
#_F972: db $86 ; duration: $06
#_F973: db $43 ; G5
#_F974: db $00 ; rest
#_F975: db $FC ; loop part

#_F976: db $8C ; duration: $0C
#_F977: db $30 ; C4
#_F978: db $86 ; duration: $06
#_F979: db $43 ; G5
#_F97A: db $00 ; rest
#_F97B: db $8C ; duration: $0C
#_F97C: db $32 ; D4
#_F97D: db $86 ; duration: $06
#_F97E: db $45 ; A5
#_F97F: db $00 ; rest
#_F980: db $A4 ; duration: $24
#_F981: db $33 ; D#4
#_F982: db $98 ; duration: $18
#_F983: db $36 ; F#4
#_F984: db $8C ; duration: $0C
#_F985: db $3F ; D#5
#_F986: db $98 ; duration: $18
#_F987: db $3A ; A#4
#_F988: db $A4 ; duration: $24
#_F989: db $2E ; A#3
#_F98A: db $98 ; duration: $18
#_F98B: db $32 ; D4
#_F98C: db $8C ; duration: $0C
#_F98D: db $35 ; F4
#_F98E: db $98 ; duration: $18
#_F98F: db $3A ; A#4
#_F990: db $A4 ; duration: $24
#_F991: db $33 ; D#4
#_F992: db $36 ; F#4
#_F993: db $98 ; duration: $18
#_F994: db $3A ; A#4
#_F995: db $8C ; duration: $0C
#_F996: db $2E ; A#3
#_F997: db $98 ; duration: $18
#_F998: db $3A ; A#4
#_F999: db $32 ; D4
#_F99A: db $8C ; duration: $0C
#_F99B: db $35 ; F4
#_F99C: db $3A ; A#4
#_F99D: db $30 ; C4
#_F99E: db $32 ; D4
#_F99F: db $98 ; duration: $18
#_F9A0: db $36 ; F#4
#_F9A1: db $39 ; A4
#_F9A2: db $3E ; D5
#_F9A3: db $3D ; C#5
#_F9A4: db $8C ; duration: $0C
#_F9A5: db $39 ; A4
#_F9A6: db $34 ; E4
#_F9A7: db $98 ; duration: $18
#_F9A8: db $31 ; C#4
#_F9A9: db $2D ; A3
#_F9AA: db $8C ; duration: $0C
#_F9AB: db $2F ; B3
#_F9AC: db $30 ; C4
#_F9AD: db $86 ; duration: $06
#_F9AE: db $43 ; G5
#_F9AF: db $00 ; rest
#_F9B0: db $8C ; duration: $0C
#_F9B1: db $30 ; C4
#_F9B2: db $86 ; duration: $06
#_F9B3: db $40 ; E5
#_F9B4: db $00 ; rest
#_F9B5: db $8C ; duration: $0C
#_F9B6: db $30 ; C4
#_F9B7: db $86 ; duration: $06
#_F9B8: db $3C ; C5
#_F9B9: db $00 ; rest
#_F9BA: db $8C ; duration: $0C
#_F9BB: db $30 ; C4
#_F9BC: db $86 ; duration: $06
#_F9BD: db $3C ; C5
#_F9BE: db $00 ; rest
#_F9BF: db $8C ; duration: $0C
#_F9C0: db $29 ; F3
#_F9C1: db $86 ; duration: $06
#_F9C2: db $43 ; G5
#_F9C3: db $00 ; rest
#_F9C4: db $8C ; duration: $0C
#_F9C5: db $29 ; F3
#_F9C6: db $86 ; duration: $06
#_F9C7: db $40 ; E5
#_F9C8: db $00 ; rest

#_F9C9: db $FD, $02 ; loop point
#_F9CB: db $8C ; duration: $0C
#_F9CC: db $29 ; F3
#_F9CD: db $86 ; duration: $06
#_F9CE: db $3C ; C5
#_F9CF: db $00 ; rest
#_F9D0: db $FC ; loop part

#_F9D1: db $8C ; duration: $0C
#_F9D2: db $30 ; C4
#_F9D3: db $86 ; duration: $06
#_F9D4: db $43 ; G5
#_F9D5: db $00 ; rest
#_F9D6: db $8C ; duration: $0C
#_F9D7: db $30 ; C4
#_F9D8: db $86 ; duration: $06
#_F9D9: db $41 ; F5
#_F9DA: db $00 ; rest
#_F9DB: db $8C ; duration: $0C
#_F9DC: db $30 ; C4
#_F9DD: db $86 ; duration: $06
#_F9DE: db $40 ; E5
#_F9DF: db $00 ; rest
#_F9E0: db $8C ; duration: $0C
#_F9E1: db $30 ; C4
#_F9E2: db $86 ; duration: $06
#_F9E3: db $3E ; D5
#_F9E4: db $00 ; rest

#_F9E5: db $FD, $02 ; loop point
#_F9E7: db $8C ; duration: $0C
#_F9E8: db $34 ; E4
#_F9E9: db $86 ; duration: $06
#_F9EA: db $40 ; E5
#_F9EB: db $00 ; rest
#_F9EC: db $FC ; loop part

#_F9ED: db $86 ; duration: $06
#_F9EE: db $34 ; E4
#_F9EF: db $40 ; E5
#_F9F0: db $32 ; D4
#_F9F1: db $3E ; D5
#_F9F2: db $30 ; C4
#_F9F3: db $3C ; C5
#_F9F4: db $2F ; B3
#_F9F5: db $3B ; B4

;===================================================================================================
;===================================================================================================
; SONG 01
;===================================================================================================
;===================================================================================================
Song01Square1:
#_F9F6: db $88 ; duration: $08
#_F9F7: db $31 ; C#4
#_F9F8: db $34 ; E4
#_F9F9: db $36 ; F#4
#_F9FA: db $39 ; A4
#_F9FB: db $00 ; rest
#_F9FC: db $37 ; G4
#_F9FD: db $00 ; rest
#_F9FE: db $3A ; A#4
#_F9FF: db $3D ; C#5
#_FA00: db $40 ; E5
#_FA01: db $00 ; rest
#_FA02: db $43 ; G5
#_FA03: db $90 ; duration: $10
#_FA04: db $3E ; D5
#_FA05: db $88 ; duration: $08
#_FA06: db $3B ; B4
#_FA07: db $36 ; F#4
#_FA08: db $00 ; rest
#_FA09: db $A0 ; duration: $20
#_FA0A: db $3E ; D5
#_FA0B: db $98 ; duration: $18
#_FA0C: db $00 ; rest

#_FA0D: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song01Square2:
#_FA0E: db $88 ; duration: $08
#_FA0F: db $2D ; A3
#_FA10: db $31 ; C#4
#_FA11: db $32 ; D4
#_FA12: db $34 ; E4
#_FA13: db $00 ; rest
#_FA14: db $31 ; C#4
#_FA15: db $00 ; rest
#_FA16: db $34 ; E4
#_FA17: db $37 ; G4
#_FA18: db $3A ; A#4
#_FA19: db $00 ; rest
#_FA1A: db $3D ; C#5
#_FA1B: db $90 ; duration: $10
#_FA1C: db $3B ; B4
#_FA1D: db $88 ; duration: $08
#_FA1E: db $36 ; F#4
#_FA1F: db $2F ; B3
#_FA20: db $00 ; rest
#_FA21: db $A0 ; duration: $20
#_FA22: db $38 ; G#4
#_FA23: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song01Triangle:
#_FA24: db $88 ; duration: $08
#_FA25: db $2D ; A3
#_FA26: db $2D ; A3
#_FA27: db $2D ; A3
#_FA28: db $2D ; A3
#_FA29: db $00 ; rest
#_FA2A: db $2E ; A#3
#_FA2B: db $00 ; rest
#_FA2C: db $2E ; A#3
#_FA2D: db $2E ; A#3
#_FA2E: db $31 ; C#4
#_FA2F: db $00 ; rest
#_FA30: db $2E ; A#3
#_FA31: db $90 ; duration: $10
#_FA32: db $2F ; B3
#_FA33: db $88 ; duration: $08
#_FA34: db $2F ; B3
#_FA35: db $90 ; duration: $10
#_FA36: db $2F ; B3
#_FA37: db $34 ; E4
#_FA38: db $88 ; duration: $08
#_FA39: db $00 ; rest
#_FA3A: db $47 ; B5
#_FA3B: db $98 ; duration: $18
#_FA3C: db $28 ; E3
#_FA3D: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song01Noise:
#_FA3E: db $12 ; snare hit | duration: $08
#_FA3F: db $12 ; snare hit | duration: $08
#_FA40: db $12 ; snare hit | duration: $08
#_FA41: db $12 ; snare hit | duration: $08
#_FA42: db $02 ; rest      | duration: $08
#_FA43: db $12 ; snare hit | duration: $08
#_FA44: db $02 ; rest      | duration: $08
#_FA45: db $12 ; snare hit | duration: $08
#_FA46: db $02 ; rest      | duration: $08
#_FA47: db $22 ; scratch   | duration: $08
#_FA48: db $02 ; rest      | duration: $08
#_FA49: db $12 ; snare hit | duration: $08
#_FA4A: db $12 ; snare hit | duration: $08
#_FA4B: db $02 ; rest      | duration: $08
#_FA4C: db $12 ; snare hit | duration: $08
#_FA4D: db $12 ; snare hit | duration: $08
#_FA4E: db $02 ; rest      | duration: $08
#_FA4F: db $22 ; scratch   | duration: $08
#_FA50: db $07 ; rest      | duration: $30

;===================================================================================================
;===================================================================================================
; SONG 03
;===================================================================================================
;===================================================================================================
Song03Square1:
#_FA51: db $88 ; duration: $08
#_FA52: db $43 ; G5
#_FA53: db $90 ; duration: $10
#_FA54: db $00 ; rest
#_FA55: db $88 ; duration: $08
#_FA56: db $43 ; G5
#_FA57: db $43 ; G5
#_FA58: db $00 ; rest
#_FA59: db $44 ; G#5
#_FA5A: db $90 ; duration: $10
#_FA5B: db $00 ; rest
#_FA5C: db $88 ; duration: $08
#_FA5D: db $44 ; G#5
#_FA5E: db $44 ; G#5
#_FA5F: db $00 ; rest
#_FA60: db $45 ; A5
#_FA61: db $90 ; duration: $10
#_FA62: db $00 ; rest
#_FA63: db $88 ; duration: $08
#_FA64: db $45 ; A5
#_FA65: db $45 ; A5
#_FA66: db $00 ; rest
#_FA67: db $47 ; B5
#_FA68: db $00 ; rest
#_FA69: db $47 ; B5
#_FA6A: db $98 ; duration: $18
#_FA6B: db $00 ; rest

#_FA6C: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song03Square2:
#_FA6D: db $88 ; duration: $08
#_FA6E: db $3E ; D5
#_FA6F: db $90 ; duration: $10
#_FA70: db $00 ; rest
#_FA71: db $88 ; duration: $08
#_FA72: db $3E ; D5
#_FA73: db $3E ; D5
#_FA74: db $00 ; rest
#_FA75: db $3E ; D5
#_FA76: db $90 ; duration: $10
#_FA77: db $00 ; rest
#_FA78: db $88 ; duration: $08
#_FA79: db $3E ; D5
#_FA7A: db $3E ; D5
#_FA7B: db $00 ; rest
#_FA7C: db $3E ; D5
#_FA7D: db $90 ; duration: $10
#_FA7E: db $00 ; rest
#_FA7F: db $88 ; duration: $08
#_FA80: db $3E ; D5
#_FA81: db $41 ; F5
#_FA82: db $00 ; rest
#_FA83: db $43 ; G5
#_FA84: db $00 ; rest
#_FA85: db $43 ; G5
#_FA86: db $98 ; duration: $18
#_FA87: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song03Triangle:
#_FA88: db $FD, $02 ; loop point
#_FA8A: db $88 ; duration: $08
#_FA8B: db $2B ; G3
#_FA8C: db $00 ; rest
#_FA8D: db $37 ; G4
#_FA8E: db $47 ; B5
#_FA8F: db $37 ; G4
#_FA90: db $00 ; rest
#_FA91: db $FC ; loop part

#_FA92: db $88 ; duration: $08
#_FA93: db $2B ; G3
#_FA94: db $00 ; rest
#_FA95: db $32 ; D4
#_FA96: db $34 ; E4
#_FA97: db $35 ; F4
#_FA98: db $00 ; rest
#_FA99: db $37 ; G4
#_FA9A: db $00 ; rest
#_FA9B: db $2B ; G3
#_FA9C: db $98 ; duration: $18
#_FA9D: db $00 ; rest

;===================================================================================================
;===================================================================================================
; SONG 07
;===================================================================================================
;===================================================================================================
Song07Square1:
#_FA9E: db $90 ; duration: $10
#_FA9F: db $40 ; E5
#_FAA0: db $88 ; duration: $08
#_FAA1: db $3B ; B4
#_FAA2: db $A8 ; duration: $28
#_FAA3: db $3C ; C5
#_FAA4: db $88 ; duration: $08
#_FAA5: db $33 ; D#4
#_FAA6: db $B0 ; duration: $30
#_FAA7: db $34 ; E4
#_FAA8: db $C8 ; duration: $48
#_FAA9: db $00 ; rest

#_FAAA: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song07Square2:
#_FAAB: db $A8 ; duration: $28
#_FAAC: db $37 ; G4
#_FAAD: db $88 ; duration: $08
#_FAAE: db $36 ; F#4
#_FAAF: db $A8 ; duration: $28
#_FAB0: db $37 ; G4
#_FAB1: db $88 ; duration: $08
#_FAB2: db $2F ; B3
#_FAB3: db $98 ; duration: $18
#_FAB4: db $30 ; C4
#_FAB5: db $C8 ; duration: $48
#_FAB6: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song07Triangle:
#_FAB7: db $E0 ; duration: $60
#_FAB8: db $30 ; C4
#_FAB9: db $98 ; duration: $18
#_FABA: db $00 ; rest
#_FABB: db $8C ; duration: $0C
#_FABC: db $3C ; C5
#_FABD: db $00 ; rest
#_FABE: db $30 ; C4
#_FABF: db $A4 ; duration: $24
#_FAC0: db $00 ; rest

;===================================================================================================
;===================================================================================================
; SONG 06
;===================================================================================================
;===================================================================================================
Song06Square1:
#_FAC1: db $FD, $02 ; loop point
#_FAC3: db $98 ; duration: $18
#_FAC4: db $3C ; C5
#_FAC5: db $8C ; duration: $0C
#_FAC6: db $3E ; D5
#_FAC7: db $98 ; duration: $18
#_FAC8: db $40 ; E5
#_FAC9: db $8C ; duration: $0C
#_FACA: db $3E ; D5
#_FACB: db $3C ; C5
#_FACC: db $37 ; G4
#_FACD: db $E0 ; duration: $60
#_FACE: db $39 ; A4
#_FACF: db $98 ; duration: $18
#_FAD0: db $3E ; D5
#_FAD1: db $8C ; duration: $0C
#_FAD2: db $40 ; E5
#_FAD3: db $98 ; duration: $18
#_FAD4: db $41 ; F5
#_FAD5: db $8C ; duration: $0C
#_FAD6: db $40 ; E5
#_FAD7: db $3E ; D5
#_FAD8: db $39 ; A4
#_FAD9: db $A4 ; duration: $24
#_FADA: db $3B ; B4
#_FADB: db $8C ; duration: $0C
#_FADC: db $39 ; A4
#_FADD: db $B0 ; duration: $30
#_FADE: db $37 ; G4
#_FADF: db $98 ; duration: $18
#_FAE0: db $40 ; E5
#_FAE1: db $8C ; duration: $0C
#_FAE2: db $41 ; F5
#_FAE3: db $98 ; duration: $18
#_FAE4: db $43 ; G5
#_FAE5: db $8C ; duration: $0C
#_FAE6: db $41 ; F5
#_FAE7: db $98 ; duration: $18
#_FAE8: db $40 ; E5
#_FAE9: db $41 ; F5
#_FAEA: db $8C ; duration: $0C
#_FAEB: db $43 ; G5
#_FAEC: db $98 ; duration: $18
#_FAED: db $44 ; G#5
#_FAEE: db $8C ; duration: $0C
#_FAEF: db $43 ; G5
#_FAF0: db $98 ; duration: $18
#_FAF1: db $41 ; F5
#_FAF2: db $A4 ; duration: $24
#_FAF3: db $40 ; E5
#_FAF4: db $86 ; duration: $06
#_FAF5: db $39 ; A4
#_FAF6: db $3C ; C5
#_FAF7: db $B0 ; duration: $30
#_FAF8: db $40 ; E5
#_FAF9: db $A4 ; duration: $24
#_FAFA: db $3E ; D5
#_FAFB: db $86 ; duration: $06
#_FAFC: db $3C ; C5
#_FAFD: db $3E ; D5
#_FAFE: db $B0 ; duration: $30
#_FAFF: db $43 ; G5
#_FB00: db $FC ; loop part

#_FB01: db $CE ; duration: $4E
#_FB02: db $3C ; C5
#_FB03: db $86 ; duration: $06
#_FB04: db $3C ; C5
#_FB05: db $40 ; E5
#_FB06: db $43 ; G5
#_FB07: db $8C ; duration: $0C
#_FB08: db $48 ; C6
#_FB09: db $00 ; rest
#_FB0A: db $30 ; C4
#_FB0B: db $BC ; duration: $3C
#_FB0C: db $00 ; rest

#_FB0D: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song06Square2:
#_FB0E: db $FD, $02 ; loop point
#_FB10: db $86 ; duration: $06
#_FB11: db $34 ; E4
#_FB12: db $00 ; rest
#_FB13: db $34 ; E4
#_FB14: db $35 ; F4
#_FB15: db $8C ; duration: $0C
#_FB16: db $37 ; G4
#_FB17: db $86 ; duration: $06
#_FB18: db $43 ; G5
#_FB19: db $48 ; C6
#_FB1A: db $40 ; E5
#_FB1B: db $43 ; G5
#_FB1C: db $3C ; C5
#_FB1D: db $40 ; E5
#_FB1E: db $37 ; G4
#_FB1F: db $3C ; C5
#_FB20: db $34 ; E4
#_FB21: db $37 ; G4
#_FB22: db $35 ; F4
#_FB23: db $34 ; E4
#_FB24: db $35 ; F4
#_FB25: db $34 ; E4
#_FB26: db $8C ; duration: $0C
#_FB27: db $35 ; F4
#_FB28: db $86 ; duration: $06
#_FB29: db $41 ; F5
#_FB2A: db $45 ; A5
#_FB2B: db $3C ; C5
#_FB2C: db $41 ; F5
#_FB2D: db $39 ; A4
#_FB2E: db $3C ; C5
#_FB2F: db $35 ; F4
#_FB30: db $39 ; A4
#_FB31: db $30 ; C4
#_FB32: db $35 ; F4
#_FB33: db $35 ; F4
#_FB34: db $00 ; rest
#_FB35: db $35 ; F4
#_FB36: db $37 ; G4
#_FB37: db $8C ; duration: $0C
#_FB38: db $39 ; A4
#_FB39: db $86 ; duration: $06
#_FB3A: db $45 ; A5
#_FB3B: db $48 ; C6
#_FB3C: db $41 ; F5
#_FB3D: db $45 ; A5
#_FB3E: db $3E ; D5
#_FB3F: db $41 ; F5
#_FB40: db $39 ; A4
#_FB41: db $3C ; C5
#_FB42: db $35 ; F4
#_FB43: db $39 ; A4
#_FB44: db $37 ; G4
#_FB45: db $36 ; F#4
#_FB46: db $37 ; G4
#_FB47: db $36 ; F#4
#_FB48: db $8C ; duration: $0C
#_FB49: db $37 ; G4
#_FB4A: db $86 ; duration: $06
#_FB4B: db $3E ; D5
#_FB4C: db $41 ; F5
#_FB4D: db $3B ; B4
#_FB4E: db $3E ; D5
#_FB4F: db $36 ; F#4
#_FB50: db $37 ; G4
#_FB51: db $38 ; G#4
#_FB52: db $39 ; A4
#_FB53: db $3A ; A#4
#_FB54: db $3B ; B4
#_FB55: db $8C ; duration: $0C
#_FB56: db $37 ; G4
#_FB57: db $98 ; duration: $18
#_FB58: db $34 ; E4
#_FB59: db $40 ; E5
#_FB5A: db $8C ; duration: $0C
#_FB5B: db $3C ; C5
#_FB5C: db $37 ; G4
#_FB5D: db $3A ; A#4
#_FB5E: db $3C ; C5
#_FB5F: db $98 ; duration: $18
#_FB60: db $30 ; C4
#_FB61: db $41 ; F5
#_FB62: db $8C ; duration: $0C
#_FB63: db $3C ; C5
#_FB64: db $38 ; G#4
#_FB65: db $35 ; F4
#_FB66: db $86 ; duration: $06
#_FB67: db $39 ; A4
#_FB68: db $00 ; rest
#_FB69: db $36 ; F#4
#_FB6A: db $39 ; A4
#_FB6B: db $A4 ; duration: $24
#_FB6C: db $3C ; C5
#_FB6D: db $86 ; duration: $06
#_FB6E: db $3C ; C5
#_FB6F: db $40 ; E5
#_FB70: db $98 ; duration: $18
#_FB71: db $45 ; A5
#_FB72: db $86 ; duration: $06
#_FB73: db $3C ; C5
#_FB74: db $00 ; rest
#_FB75: db $37 ; G4
#_FB76: db $3C ; C5
#_FB77: db $A4 ; duration: $24
#_FB78: db $3E ; D5
#_FB79: db $86 ; duration: $06
#_FB7A: db $3E ; D5
#_FB7B: db $43 ; G5
#_FB7C: db $98 ; duration: $18
#_FB7D: db $47 ; B5
#_FB7E: db $FC ; loop part

#_FB7F: db $86 ; duration: $06
#_FB80: db $37 ; G4
#_FB81: db $28 ; E3
#_FB82: db $2B ; G3
#_FB83: db $30 ; C4
#_FB84: db $34 ; E4
#_FB85: db $2B ; G3
#_FB86: db $30 ; C4
#_FB87: db $34 ; E4
#_FB88: db $37 ; G4
#_FB89: db $30 ; C4
#_FB8A: db $34 ; E4
#_FB8B: db $37 ; G4
#_FB8C: db $3C ; C5
#_FB8D: db $34 ; E4
#_FB8E: db $37 ; G4
#_FB8F: db $3C ; C5
#_FB90: db $8C ; duration: $0C
#_FB91: db $40 ; E5
#_FB92: db $00 ; rest
#_FB93: db $2B ; G3
#_FB94: db $BC ; duration: $3C
#_FB95: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song06Triangle:
#_FB96: db $FD, $02 ; loop point
#_FB98: db $8C ; duration: $0C
#_FB99: db $30 ; C4
#_FB9A: db $98 ; duration: $18
#_FB9B: db $37 ; G4
#_FB9C: db $3C ; C5
#_FB9D: db $43 ; G5
#_FB9E: db $8C ; duration: $0C
#_FB9F: db $40 ; E5
#_FBA0: db $29 ; F3
#_FBA1: db $98 ; duration: $18
#_FBA2: db $30 ; C4
#_FBA3: db $35 ; F4
#_FBA4: db $41 ; F5
#_FBA5: db $8C ; duration: $0C
#_FBA6: db $3C ; C5
#_FBA7: db $32 ; D4
#_FBA8: db $98 ; duration: $18
#_FBA9: db $39 ; A4
#_FBAA: db $3E ; D5
#_FBAB: db $45 ; A5
#_FBAC: db $8C ; duration: $0C
#_FBAD: db $41 ; F5
#_FBAE: db $2B ; G3
#_FBAF: db $98 ; duration: $18
#_FBB0: db $32 ; D4
#_FBB1: db $37 ; G4
#_FBB2: db $3B ; B4
#_FBB3: db $8C ; duration: $0C
#_FBB4: db $3E ; D5
#_FBB5: db $30 ; C4
#_FBB6: db $A4 ; duration: $24
#_FBB7: db $3C ; C5
#_FBB8: db $8C ; duration: $0C
#_FBB9: db $2E ; A#3
#_FBBA: db $A4 ; duration: $24
#_FBBB: db $3A ; A#4
#_FBBC: db $8C ; duration: $0C
#_FBBD: db $2D ; A3
#_FBBE: db $A4 ; duration: $24
#_FBBF: db $39 ; A4
#_FBC0: db $98 ; duration: $18
#_FBC1: db $2C ; G#3
#_FBC2: db $38 ; G#4
#_FBC3: db $8C ; duration: $0C
#_FBC4: db $2A ; F#3
#_FBC5: db $2A ; F#3
#_FBC6: db $2A ; F#3
#_FBC7: db $2A ; F#3
#_FBC8: db $2A ; F#3
#_FBC9: db $2A ; F#3
#_FBCA: db $2A ; F#3
#_FBCB: db $2A ; F#3
#_FBCC: db $2B ; G3
#_FBCD: db $2B ; G3
#_FBCE: db $2B ; G3
#_FBCF: db $2B ; G3
#_FBD0: db $2B ; G3
#_FBD1: db $2B ; G3
#_FBD2: db $2B ; G3
#_FBD3: db $2B ; G3
#_FBD4: db $FC ; loop part

#_FBD5: db $E0 ; duration: $60
#_FBD6: db $30 ; C4
#_FBD7: db $8C ; duration: $0C
#_FBD8: db $43 ; G5
#_FBD9: db $00 ; rest
#_FBDA: db $30 ; C4
#_FBDB: db $BC ; duration: $3C
#_FBDC: db $00 ; rest

#_FBDD: db $FF ; end of song

;===================================================================================================
;===================================================================================================
; SONG 0A
;===================================================================================================
;===================================================================================================
Song0ASquare1:
#_FBDE: db $FD, $03 ; loop point
#_FBE0: db $86 ; duration: $06
#_FBE1: db $31 ; C#4
#_FBE2: db $32 ; D4
#_FBE3: db $37 ; G4
#_FBE4: db $FC ; loop part

#_FBE5: db $86 ; duration: $06
#_FBE6: db $35 ; F4
#_FBE7: db $00 ; rest
#_FBE8: db $35 ; F4
#_FBE9: db $00 ; rest
#_FBEA: db $35 ; F4

#_FBEB: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song0ASquare2:
#_FBEC: db $FD, $03 ; loop point
#_FBEE: db $86 ; duration: $06
#_FBEF: db $2E ; A#3
#_FBF0: db $2F ; B3
#_FBF1: db $34 ; E4
#_FBF2: db $FC ; loop part

#_FBF3: db $86 ; duration: $06
#_FBF4: db $33 ; D#4
#_FBF5: db $32 ; D4
#_FBF6: db $33 ; D#4
#_FBF7: db $32 ; D4
#_FBF8: db $33 ; D#4

;---------------------------------------------------------------------------------------------------

Song0ATriangle:
#_FBF9: db $86 ; duration: $06
#_FBFA: db $00 ; rest
#_FBFB: db $43 ; G5
#_FBFC: db $00 ; rest
#_FBFD: db $3E ; D5
#_FBFE: db $00 ; rest
#_FBFF: db $3D ; C#5
#_FC00: db $00 ; rest
#_FC01: db $37 ; G4
#_FC02: db $00 ; rest
#_FC03: db $45 ; A5
#_FC04: db $44 ; G#5
#_FC05: db $39 ; A4
#_FC06: db $38 ; G#4
#_FC07: db $2D ; A3

;===================================================================================================
;===================================================================================================
; BONUS GAME
;---------------------------------------------------------------------------------------------------
; SONG 0D
; SONG 0E
; SONG 0F
; SONG 10
;===================================================================================================
;===================================================================================================
BonusGameViolin:
#_FC08: db $FD, $02 ; loop point
#_FC0A: db $90 ; duration: $10
#_FC0B: db $39 ; A4
#_FC0C: db $88 ; duration: $08
#_FC0D: db $00 ; rest
#_FC0E: db $38 ; G#4
#_FC0F: db $39 ; A4
#_FC10: db $00 ; rest
#_FC11: db $90 ; duration: $10
#_FC12: db $30 ; C4
#_FC13: db $35 ; F4
#_FC14: db $39 ; A4
#_FC15: db $A0 ; duration: $20
#_FC16: db $3C ; C5
#_FC17: db $90 ; duration: $10
#_FC18: db $3B ; B4
#_FC19: db $B0 ; duration: $30
#_FC1A: db $3A ; A#4
#_FC1B: db $90 ; duration: $10
#_FC1C: db $37 ; G4
#_FC1D: db $88 ; duration: $08
#_FC1E: db $00 ; rest
#_FC1F: db $36 ; F#4
#_FC20: db $37 ; G4
#_FC21: db $00 ; rest
#_FC22: db $90 ; duration: $10
#_FC23: db $2E ; A#3
#_FC24: db $34 ; E4
#_FC25: db $37 ; G4
#_FC26: db $36 ; F#4
#_FC27: db $37 ; G4
#_FC28: db $38 ; G#4
#_FC29: db $B0 ; duration: $30
#_FC2A: db $39 ; A4
#_FC2B: db $90 ; duration: $10
#_FC2C: db $00 ; rest
#_FC2D: db $88 ; duration: $08
#_FC2E: db $39 ; A4
#_FC2F: db $38 ; G#4
#_FC30: db $90 ; duration: $10
#_FC31: db $39 ; A4
#_FC32: db $30 ; C4
#_FC33: db $35 ; F4
#_FC34: db $39 ; A4
#_FC35: db $39 ; A4
#_FC36: db $3A ; A#4
#_FC37: db $3C ; C5
#_FC38: db $B0 ; duration: $30
#_FC39: db $3E ; D5
#_FC3A: db $90 ; duration: $10
#_FC3B: db $41 ; F5
#_FC3C: db $40 ; E5
#_FC3D: db $3E ; D5
#_FC3E: db $3C ; C5
#_FC3F: db $3A ; A#4
#_FC40: db $39 ; A4
#_FC41: db $34 ; E4
#_FC42: db $35 ; F4
#_FC43: db $37 ; G4
#_FC44: db $B0 ; duration: $30
#_FC45: db $35 ; F4
#_FC46: db $FC ; loop part

#_FC47: db $98 ; duration: $18
#_FC48: db $3E ; D5
#_FC49: db $88 ; duration: $08
#_FC4A: db $3D ; C#5
#_FC4B: db $90 ; duration: $10
#_FC4C: db $3E ; D5
#_FC4D: db $41 ; F5
#_FC4E: db $40 ; E5
#_FC4F: db $3E ; D5
#_FC50: db $3C ; C5
#_FC51: db $88 ; duration: $08
#_FC52: db $34 ; E4
#_FC53: db $35 ; F4
#_FC54: db $37 ; G4
#_FC55: db $38 ; G#4
#_FC56: db $B0 ; duration: $30
#_FC57: db $39 ; A4
#_FC58: db $90 ; duration: $10
#_FC59: db $00 ; rest
#_FC5A: db $88 ; duration: $08
#_FC5B: db $3E ; D5
#_FC5C: db $3D ; C#5
#_FC5D: db $90 ; duration: $10
#_FC5E: db $3E ; D5
#_FC5F: db $41 ; F5
#_FC60: db $40 ; E5
#_FC61: db $3E ; D5
#_FC62: db $88 ; duration: $08
#_FC63: db $3C ; C5
#_FC64: db $30 ; C4
#_FC65: db $32 ; D4
#_FC66: db $34 ; E4
#_FC67: db $35 ; F4
#_FC68: db $37 ; G4
#_FC69: db $B0 ; duration: $30
#_FC6A: db $39 ; A4
#_FC6B: db $90 ; duration: $10
#_FC6C: db $3E ; D5
#_FC6D: db $88 ; duration: $08
#_FC6E: db $00 ; rest
#_FC6F: db $3D ; C#5
#_FC70: db $3E ; D5
#_FC71: db $00 ; rest
#_FC72: db $90 ; duration: $10
#_FC73: db $41 ; F5
#_FC74: db $40 ; E5
#_FC75: db $3E ; D5
#_FC76: db $3C ; C5
#_FC77: db $3E ; D5
#_FC78: db $40 ; E5
#_FC79: db $F8 ; duration: $78
#_FC7A: db $45 ; A5
#_FC7B: db $88 ; duration: $08
#_FC7C: db $00 ; rest
#_FC7D: db $C0 ; duration: $40
#_FC7E: db $00 ; rest
#_FC7F: db $90 ; duration: $10
#_FC80: db $46 ; A#5
#_FC81: db $45 ; A5
#_FC82: db $43 ; G5
#_FC83: db $3C ; C5
#_FC84: db $3E ; D5
#_FC85: db $40 ; E5
#_FC86: db $88 ; duration: $08
#_FC87: db $43 ; G5
#_FC88: db $43 ; G5
#_FC89: db $43 ; G5
#_FC8A: db $00 ; rest
#_FC8B: db $40 ; E5
#_FC8C: db $00 ; rest
#_FC8D: db $41 ; F5
#_FC8E: db $41 ; F5
#_FC8F: db $41 ; F5
#_FC90: db $00 ; rest

#_FC91: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

BonusGameHarpTrumpet:
#_FC92: db $FD, $04 ; loop point
#_FC94: db $88 ; duration: $08
#_FC95: db $3C ; C5
#_FC96: db $39 ; A4
#_FC97: db $35 ; F4
#_FC98: db $30 ; C4
#_FC99: db $39 ; A4
#_FC9A: db $35 ; F4
#_FC9B: db $3C ; C5
#_FC9C: db $39 ; A4
#_FC9D: db $34 ; E4
#_FC9E: db $30 ; C4
#_FC9F: db $39 ; A4
#_FCA0: db $35 ; F4
#_FCA1: db $3C ; C5
#_FCA2: db $39 ; A4
#_FCA3: db $33 ; D#4
#_FCA4: db $30 ; C4
#_FCA5: db $39 ; A4
#_FCA6: db $35 ; F4
#_FCA7: db $3A ; A#4
#_FCA8: db $35 ; F4
#_FCA9: db $32 ; D4
#_FCAA: db $2E ; A#3
#_FCAB: db $3A ; A#4
#_FCAC: db $39 ; A4
#_FCAD: db $3C ; C5
#_FCAE: db $37 ; G4
#_FCAF: db $34 ; E4
#_FCB0: db $30 ; C4
#_FCB1: db $37 ; G4
#_FCB2: db $34 ; E4
#_FCB3: db $3C ; C5
#_FCB4: db $37 ; G4
#_FCB5: db $34 ; E4
#_FCB6: db $32 ; D4
#_FCB7: db $37 ; G4
#_FCB8: db $34 ; E4
#_FCB9: db $3C ; C5
#_FCBA: db $37 ; G4
#_FCBB: db $34 ; E4
#_FCBC: db $33 ; D#4
#_FCBD: db $37 ; G4
#_FCBE: db $34 ; E4
#_FCBF: db $3C ; C5
#_FCC0: db $39 ; A4
#_FCC1: db $35 ; F4
#_FCC2: db $34 ; E4
#_FCC3: db $39 ; A4
#_FCC4: db $35 ; F4
#_FCC5: db $FC ; loop part

#_FCC6: db $FA, $70 ; set volume: $70, envelope: 0

#_FCC8: db $FD, $02 ; loop point
#_FCCA: db $88 ; duration: $08
#_FCCB: db $3E ; D5
#_FCCC: db $3E ; D5
#_FCCD: db $3A ; A#4
#_FCCE: db $3A ; A#4
#_FCCF: db $35 ; F4
#_FCD0: db $35 ; F4
#_FCD1: db $3E ; D5
#_FCD2: db $3E ; D5
#_FCD3: db $3B ; B4
#_FCD4: db $3B ; B4
#_FCD5: db $35 ; F4
#_FCD6: db $35 ; F4
#_FCD7: db $41 ; F5
#_FCD8: db $41 ; F5
#_FCD9: db $3C ; C5
#_FCDA: db $3C ; C5
#_FCDB: db $39 ; A4
#_FCDC: db $39 ; A4
#_FCDD: db $41 ; F5
#_FCDE: db $41 ; F5
#_FCDF: db $3C ; C5
#_FCE0: db $3C ; C5
#_FCE1: db $39 ; A4
#_FCE2: db $39 ; A4
#_FCE3: db $FC ; loop part

#_FCE4: db $88 ; duration: $08
#_FCE5: db $3E ; D5
#_FCE6: db $3E ; D5
#_FCE7: db $3A ; A#4
#_FCE8: db $3A ; A#4
#_FCE9: db $35 ; F4
#_FCEA: db $35 ; F4
#_FCEB: db $3E ; D5
#_FCEC: db $3E ; D5
#_FCED: db $3B ; B4
#_FCEE: db $3B ; B4
#_FCEF: db $35 ; F4
#_FCF0: db $35 ; F4
#_FCF1: db $41 ; F5
#_FCF2: db $41 ; F5
#_FCF3: db $3C ; C5
#_FCF4: db $3C ; C5
#_FCF5: db $39 ; A4
#_FCF6: db $39 ; A4
#_FCF7: db $41 ; F5
#_FCF8: db $2F ; B3
#_FCF9: db $32 ; D4
#_FCFA: db $35 ; F4
#_FCFB: db $38 ; G#4
#_FCFC: db $3B ; B4
#_FCFD: db $3E ; D5
#_FCFE: db $41 ; F5
#_FCFF: db $44 ; G#5
#_FD00: db $47 ; B5
#_FD01: db $4A ; D6
#_FD02: db $B0 ; duration: $30
#_FD03: db $4A ; D6
#_FD04: db $B8 ; duration: $38
#_FD05: db $00 ; rest
#_FD06: db $88 ; duration: $08
#_FD07: db $41 ; F5
#_FD08: db $41 ; F5
#_FD09: db $3E ; D5
#_FD0A: db $3E ; D5
#_FD0B: db $3A ; A#4
#_FD0C: db $3A ; A#4
#_FD0D: db $43 ; G5
#_FD0E: db $43 ; G5
#_FD0F: db $40 ; E5
#_FD10: db $40 ; E5
#_FD11: db $3C ; C5
#_FD12: db $3C ; C5
#_FD13: db $3C ; C5
#_FD14: db $3C ; C5
#_FD15: db $40 ; E5
#_FD16: db $00 ; rest
#_FD17: db $43 ; G5
#_FD18: db $00 ; rest
#_FD19: db $39 ; A4
#_FD1A: db $3C ; C5
#_FD1B: db $41 ; F5
#_FD1C: db $00 ; rest

#_FD1D: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

BonusGameEuphoniumOcarina:
#_FD1E: db $FD, $02 ; loop point
#_FD20: db $90 ; duration: $10
#_FD21: db $35 ; F4
#_FD22: db $88 ; duration: $08
#_FD23: db $54 ; C7
#_FD24: db $51 ; A6
#_FD25: db $54 ; C7
#_FD26: db $51 ; A6
#_FD27: db $90 ; duration: $10
#_FD28: db $34 ; E4
#_FD29: db $88 ; duration: $08
#_FD2A: db $54 ; C7
#_FD2B: db $51 ; A6
#_FD2C: db $54 ; C7
#_FD2D: db $51 ; A6
#_FD2E: db $90 ; duration: $10
#_FD2F: db $33 ; D#4
#_FD30: db $88 ; duration: $08
#_FD31: db $54 ; C7
#_FD32: db $51 ; A6
#_FD33: db $54 ; C7
#_FD34: db $51 ; A6
#_FD35: db $90 ; duration: $10
#_FD36: db $32 ; D4
#_FD37: db $88 ; duration: $08
#_FD38: db $56 ; D7
#_FD39: db $57 ; D#7
#_FD3A: db $58 ; E7
#_FD3B: db $59 ; F7
#_FD3C: db $90 ; duration: $10
#_FD3D: db $30 ; C4
#_FD3E: db $88 ; duration: $08
#_FD3F: db $4F ; G6
#_FD40: db $4C ; E6
#_FD41: db $4F ; G6
#_FD42: db $4C ; E6
#_FD43: db $90 ; duration: $10
#_FD44: db $32 ; D4
#_FD45: db $88 ; duration: $08
#_FD46: db $4F ; G6
#_FD47: db $4C ; E6
#_FD48: db $4F ; G6
#_FD49: db $4C ; E6
#_FD4A: db $90 ; duration: $10
#_FD4B: db $34 ; E4
#_FD4C: db $88 ; duration: $08
#_FD4D: db $4F ; G6
#_FD4E: db $4C ; E6
#_FD4F: db $4F ; G6
#_FD50: db $4C ; E6
#_FD51: db $90 ; duration: $10
#_FD52: db $35 ; F4
#_FD53: db $88 ; duration: $08
#_FD54: db $5D ; A7
#_FD55: db $5C ; G#7
#_FD56: db $5B ; G7
#_FD57: db $59 ; F7
#_FD58: db $90 ; duration: $10
#_FD59: db $35 ; F4
#_FD5A: db $88 ; duration: $08
#_FD5B: db $54 ; C7
#_FD5C: db $51 ; A6
#_FD5D: db $54 ; C7
#_FD5E: db $51 ; A6
#_FD5F: db $90 ; duration: $10
#_FD60: db $34 ; E4
#_FD61: db $88 ; duration: $08
#_FD62: db $54 ; C7
#_FD63: db $51 ; A6
#_FD64: db $54 ; C7
#_FD65: db $51 ; A6
#_FD66: db $90 ; duration: $10
#_FD67: db $33 ; D#4
#_FD68: db $88 ; duration: $08
#_FD69: db $54 ; C7
#_FD6A: db $51 ; A6
#_FD6B: db $54 ; C7
#_FD6C: db $51 ; A6
#_FD6D: db $90 ; duration: $10
#_FD6E: db $32 ; D4
#_FD6F: db $88 ; duration: $08
#_FD70: db $56 ; D7
#_FD71: db $57 ; D#7
#_FD72: db $58 ; E7
#_FD73: db $59 ; F7
#_FD74: db $90 ; duration: $10
#_FD75: db $30 ; C4
#_FD76: db $88 ; duration: $08
#_FD77: db $4F ; G6
#_FD78: db $4C ; E6
#_FD79: db $4F ; G6
#_FD7A: db $4C ; E6
#_FD7B: db $90 ; duration: $10
#_FD7C: db $32 ; D4
#_FD7D: db $88 ; duration: $08
#_FD7E: db $4F ; G6
#_FD7F: db $4C ; E6
#_FD80: db $4F ; G6
#_FD81: db $4C ; E6
#_FD82: db $90 ; duration: $10
#_FD83: db $34 ; E4
#_FD84: db $88 ; duration: $08
#_FD85: db $4F ; G6
#_FD86: db $4C ; E6
#_FD87: db $4F ; G6
#_FD88: db $4C ; E6
#_FD89: db $90 ; duration: $10
#_FD8A: db $35 ; F4
#_FD8B: db $88 ; duration: $08
#_FD8C: db $5D ; A7
#_FD8D: db $5C ; G#7
#_FD8E: db $5B ; G7
#_FD8F: db $59 ; F7
#_FD90: db $FC ; loop part

#_FD91: db $90 ; duration: $10
#_FD92: db $2E ; A#3
#_FD93: db $88 ; duration: $08
#_FD94: db $4A ; D6
#_FD95: db $4D ; F6
#_FD96: db $4A ; D6
#_FD97: db $4D ; F6
#_FD98: db $90 ; duration: $10
#_FD99: db $2F ; B3
#_FD9A: db $88 ; duration: $08
#_FD9B: db $4A ; D6
#_FD9C: db $4D ; F6
#_FD9D: db $4A ; D6
#_FD9E: db $4D ; F6
#_FD9F: db $90 ; duration: $10
#_FDA0: db $30 ; C4
#_FDA1: db $88 ; duration: $08
#_FDA2: db $4D ; F6
#_FDA3: db $51 ; A6
#_FDA4: db $4D ; F6
#_FDA5: db $51 ; A6
#_FDA6: db $90 ; duration: $10
#_FDA7: db $35 ; F4
#_FDA8: db $88 ; duration: $08
#_FDA9: db $4D ; F6
#_FDAA: db $51 ; A6
#_FDAB: db $4D ; F6
#_FDAC: db $51 ; A6
#_FDAD: db $90 ; duration: $10
#_FDAE: db $2E ; A#3
#_FDAF: db $88 ; duration: $08
#_FDB0: db $4A ; D6
#_FDB1: db $4D ; F6
#_FDB2: db $4A ; D6
#_FDB3: db $4D ; F6
#_FDB4: db $90 ; duration: $10
#_FDB5: db $2F ; B3
#_FDB6: db $88 ; duration: $08
#_FDB7: db $4A ; D6
#_FDB8: db $4D ; F6
#_FDB9: db $4A ; D6
#_FDBA: db $4D ; F6
#_FDBB: db $90 ; duration: $10
#_FDBC: db $30 ; C4
#_FDBD: db $88 ; duration: $08
#_FDBE: db $4D ; F6
#_FDBF: db $51 ; A6
#_FDC0: db $4D ; F6
#_FDC1: db $51 ; A6
#_FDC2: db $90 ; duration: $10
#_FDC3: db $35 ; F4
#_FDC4: db $88 ; duration: $08
#_FDC5: db $4D ; F6
#_FDC6: db $51 ; A6
#_FDC7: db $4D ; F6
#_FDC8: db $51 ; A6
#_FDC9: db $90 ; duration: $10
#_FDCA: db $2E ; A#3
#_FDCB: db $88 ; duration: $08
#_FDCC: db $4A ; D6
#_FDCD: db $4D ; F6
#_FDCE: db $4A ; D6
#_FDCF: db $4D ; F6
#_FDD0: db $90 ; duration: $10
#_FDD1: db $2F ; B3
#_FDD2: db $88 ; duration: $08
#_FDD3: db $4A ; D6
#_FDD4: db $4D ; F6
#_FDD5: db $4A ; D6
#_FDD6: db $4D ; F6
#_FDD7: db $90 ; duration: $10
#_FDD8: db $30 ; C4
#_FDD9: db $88 ; duration: $08
#_FDDA: db $4D ; F6
#_FDDB: db $51 ; A6
#_FDDC: db $4D ; F6
#_FDDD: db $51 ; A6
#_FDDE: db $90 ; duration: $10
#_FDDF: db $32 ; D4
#_FDE0: db $88 ; duration: $08
#_FDE1: db $47 ; B5
#_FDE2: db $4A ; D6
#_FDE3: db $4D ; F6
#_FDE4: db $50 ; G#6
#_FDE5: db $53 ; B6
#_FDE6: db $56 ; D7
#_FDE7: db $59 ; F7
#_FDE8: db $5C ; G#7
#_FDE9: db $5F ; B7
#_FDEA: db $62 ; D8
#_FDEB: db $4A ; D6
#_FDEC: db $47 ; B5
#_FDED: db $4D ; F6
#_FDEE: db $4A ; D6
#_FDEF: db $50 ; G#6
#_FDF0: db $4D ; F6
#_FDF1: db $53 ; B6
#_FDF2: db $50 ; G#6
#_FDF3: db $56 ; D7
#_FDF4: db $53 ; B6
#_FDF5: db $59 ; F7
#_FDF6: db $56 ; D7
#_FDF7: db $90 ; duration: $10
#_FDF8: db $2E ; A#3
#_FDF9: db $88 ; duration: $08
#_FDFA: db $4A ; D6
#_FDFB: db $4D ; F6
#_FDFC: db $4A ; D6
#_FDFD: db $4D ; F6
#_FDFE: db $90 ; duration: $10
#_FDFF: db $30 ; C4
#_FE00: db $88 ; duration: $08
#_FE01: db $4C ; E6
#_FE02: db $54 ; C7
#_FE03: db $4C ; E6
#_FE04: db $54 ; C7
#_FE05: db $30 ; C4
#_FE06: db $30 ; C4
#_FE07: db $30 ; C4
#_FE08: db $00 ; rest
#_FE09: db $30 ; C4
#_FE0A: db $00 ; rest
#_FE0B: db $35 ; F4
#_FE0C: db $35 ; F4
#_FE0D: db $35 ; F4
#_FE0E: db $00 ; rest

#_FE0F: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

BonusGameDrums:
#_FE10: db $FD, $15 ; loop point
#_FE12: db $10 ; snare hit | duration: $04
#_FE13: db $10 ; snare hit | duration: $04
#_FE14: db $10 ; snare hit | duration: $04
#_FE15: db $10 ; snare hit | duration: $04
#_FE16: db $12 ; snare hit | duration: $08
#_FE17: db $12 ; snare hit | duration: $08
#_FE18: db $22 ; scratch   | duration: $08
#_FE19: db $02 ; rest      | duration: $08
#_FE1A: db $24 ; scratch   | duration: $10
#_FE1B: db $12 ; snare hit | duration: $08
#_FE1C: db $12 ; snare hit | duration: $08
#_FE1D: db $12 ; snare hit | duration: $08
#_FE1E: db $02 ; rest      | duration: $08
#_FE1F: db $FC ; loop part

#_FE20: db $10 ; snare hit | duration: $04
#_FE21: db $10 ; snare hit | duration: $04
#_FE22: db $10 ; snare hit | duration: $04
#_FE23: db $10 ; snare hit | duration: $04
#_FE24: db $12 ; snare hit | duration: $08
#_FE25: db $12 ; snare hit | duration: $08
#_FE26: db $22 ; scratch   | duration: $08
#_FE27: db $02 ; rest      | duration: $08

#_FE28: db $FD, $06 ; loop point
#_FE2A: db $04 ; rest      | duration: $10
#_FE2B: db $14 ; snare hit | duration: $10
#_FE2C: db $14 ; snare hit | duration: $10
#_FE2D: db $FC ; loop part

#_FE2E: db $12 ; snare hit | duration: $08
#_FE2F: db $12 ; snare hit | duration: $08
#_FE30: db $12 ; snare hit | duration: $08
#_FE31: db $02 ; rest      | duration: $08
#_FE32: db $22 ; scratch   | duration: $08
#_FE33: db $02 ; rest      | duration: $08
#_FE34: db $12 ; snare hit | duration: $08
#_FE35: db $12 ; snare hit | duration: $08
#_FE36: db $12 ; snare hit | duration: $08
#_FE37: db $02 ; rest      | duration: $08

#_FE38: db $FF ; end of song

;===================================================================================================
;===================================================================================================
; SONG 08
;===================================================================================================
;===================================================================================================
Song08Square1:
#_FE39: db $84 ; duration: $04
#_FE3A: db $21 ; A2
#_FE3B: db $28 ; E3
#_FE3C: db $2F ; B3
#_FE3D: db $28 ; E3
#_FE3E: db $2F ; B3
#_FE3F: db $36 ; F#4
#_FE40: db $2D ; A3
#_FE41: db $34 ; E4
#_FE42: db $3B ; B4
#_FE43: db $32 ; D4
#_FE44: db $39 ; A4
#_FE45: db $40 ; E5
#_FE46: db $37 ; G4
#_FE47: db $3E ; D5
#_FE48: db $45 ; A5
#_FE49: db $3C ; C5
#_FE4A: db $43 ; G5
#_FE4B: db $4A ; D6

#_FE4C: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song08Square2:
#_FE4D: db $8C ; duration: $0C
#_FE4E: db $00 ; rest
#_FE4F: db $84 ; duration: $04
#_FE50: db $21 ; A2
#_FE51: db $28 ; E3
#_FE52: db $2F ; B3
#_FE53: db $28 ; E3
#_FE54: db $2F ; B3
#_FE55: db $36 ; F#4
#_FE56: db $2D ; A3
#_FE57: db $34 ; E4
#_FE58: db $3B ; B4
#_FE59: db $32 ; D4
#_FE5A: db $39 ; A4
#_FE5B: db $40 ; E5
#_FE5C: db $37 ; G4
#_FE5D: db $3E ; D5
#_FE5E: db $45 ; A5
#_FE5F: db $3C ; C5
#_FE60: db $43 ; G5
#_FE61: db $4A ; D6

;===================================================================================================
;===================================================================================================
; SONG 09
;===================================================================================================
;===================================================================================================
Song09Square1:
#_FE62: db $84 ; duration: $04
#_FE63: db $4A ; D6
#_FE64: db $43 ; G5
#_FE65: db $3C ; C5
#_FE66: db $45 ; A5
#_FE67: db $3E ; D5
#_FE68: db $37 ; G4
#_FE69: db $40 ; E5
#_FE6A: db $39 ; A4
#_FE6B: db $32 ; D4
#_FE6C: db $3B ; B4
#_FE6D: db $34 ; E4
#_FE6E: db $2D ; A3
#_FE6F: db $36 ; F#4
#_FE70: db $2F ; B3
#_FE71: db $28 ; E3
#_FE72: db $2F ; B3
#_FE73: db $28 ; E3
#_FE74: db $21 ; A2

#_FE75: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song09Square2:
#_FE76: db $8C ; duration: $0C
#_FE77: db $00 ; rest
#_FE78: db $84 ; duration: $04
#_FE79: db $4A ; D6
#_FE7A: db $43 ; G5
#_FE7B: db $3C ; C5
#_FE7C: db $45 ; A5
#_FE7D: db $3E ; D5
#_FE7E: db $37 ; G4
#_FE7F: db $40 ; E5
#_FE80: db $39 ; A4
#_FE81: db $32 ; D4
#_FE82: db $3B ; B4
#_FE83: db $34 ; E4
#_FE84: db $2D ; A3
#_FE85: db $36 ; F#4
#_FE86: db $2F ; B3
#_FE87: db $28 ; E3
#_FE88: db $2F ; B3
#_FE89: db $28 ; E3
#_FE8A: db $21 ; A2

;===================================================================================================
;===================================================================================================
; SONG 0C
;===================================================================================================
;===================================================================================================
Song0CSquare1:
#_FE8B: db $86 ; duration: $06
#_FE8C: db $4C ; E6
#_FE8D: db $48 ; C6
#_FE8E: db $45 ; A5
#_FE8F: db $41 ; F5
#_FE90: db $4A ; D6
#_FE91: db $47 ; B5
#_FE92: db $44 ; G#5
#_FE93: db $41 ; F5
#_FE94: db $4A ; D6
#_FE95: db $47 ; B5
#_FE96: db $43 ; G5
#_FE97: db $40 ; E5
#_FE98: db $49 ; C#6
#_FE99: db $46 ; A#5
#_FE9A: db $43 ; G5
#_FE9B: db $40 ; E5
#_FE9C: db $48 ; C6
#_FE9D: db $45 ; A5
#_FE9E: db $41 ; F5
#_FE9F: db $3E ; D5
#_FEA0: db $47 ; B5
#_FEA1: db $44 ; G#5
#_FEA2: db $41 ; F5
#_FEA3: db $3E ; D5
#_FEA4: db $47 ; B5
#_FEA5: db $43 ; G5
#_FEA6: db $40 ; E5
#_FEA7: db $3E ; D5
#_FEA8: db $46 ; A#5
#_FEA9: db $43 ; G5
#_FEAA: db $40 ; E5
#_FEAB: db $3D ; C#5
#_FEAC: db $40 ; E5
#_FEAD: db $35 ; F4
#_FEAE: db $39 ; A4
#_FEAF: db $3C ; C5
#_FEB0: db $3E ; D5
#_FEB1: db $8C ; duration: $0C
#_FEB2: db $40 ; E5
#_FEB3: db $86 ; duration: $06
#_FEB4: db $39 ; A4
#_FEB5: db $3C ; C5
#_FEB6: db $3E ; D5
#_FEB7: db $8C ; duration: $0C
#_FEB8: db $41 ; F5
#_FEB9: db $86 ; duration: $06
#_FEBA: db $3C ; C5
#_FEBB: db $3E ; D5
#_FEBC: db $41 ; F5
#_FEBD: db $8C ; duration: $0C
#_FEBE: db $45 ; A5
#_FEBF: db $86 ; duration: $06
#_FEC0: db $3E ; D5
#_FEC1: db $41 ; F5
#_FEC2: db $45 ; A5
#_FEC3: db $8C ; duration: $0C
#_FEC4: db $48 ; C6
#_FEC5: db $86 ; duration: $06
#_FEC6: db $41 ; F5
#_FEC7: db $45 ; A5
#_FEC8: db $48 ; C6
#_FEC9: db $8C ; duration: $0C
#_FECA: db $4C ; E6
#_FECB: db $86 ; duration: $06
#_FECC: db $45 ; A5
#_FECD: db $48 ; C6
#_FECE: db $4A ; D6
#_FECF: db $8C ; duration: $0C
#_FED0: db $4D ; F6
#_FED1: db $86 ; duration: $06
#_FED2: db $48 ; C6
#_FED3: db $4A ; D6
#_FED4: db $4D ; F6
#_FED5: db $98 ; duration: $18
#_FED6: db $51 ; A6
#_FED7: db $B6 ; duration: $36
#_FED8: db $00 ; rest

#_FED9: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song0CSquare2:
#_FEDA: db $86 ; duration: $06
#_FEDB: db $48 ; C6
#_FEDC: db $45 ; A5
#_FEDD: db $41 ; F5
#_FEDE: db $3E ; D5
#_FEDF: db $47 ; B5
#_FEE0: db $44 ; G#5
#_FEE1: db $41 ; F5
#_FEE2: db $3E ; D5
#_FEE3: db $47 ; B5
#_FEE4: db $43 ; G5
#_FEE5: db $40 ; E5
#_FEE6: db $3B ; B4
#_FEE7: db $46 ; A#5
#_FEE8: db $43 ; G5
#_FEE9: db $40 ; E5
#_FEEA: db $3D ; C#5
#_FEEB: db $45 ; A5
#_FEEC: db $41 ; F5
#_FEED: db $3E ; D5
#_FEEE: db $39 ; A4
#_FEEF: db $44 ; G#5
#_FEF0: db $41 ; F5
#_FEF1: db $3E ; D5
#_FEF2: db $3B ; B4
#_FEF3: db $43 ; G5
#_FEF4: db $40 ; E5
#_FEF5: db $3E ; D5
#_FEF6: db $3B ; B4
#_FEF7: db $43 ; G5
#_FEF8: db $40 ; E5
#_FEF9: db $3D ; C#5
#_FEFA: db $3A ; A#4
#_FEFB: db $92 ; duration: $12
#_FEFC: db $00 ; rest
#_FEFD: db $86 ; duration: $06
#_FEFE: db $40 ; E5
#_FEFF: db $35 ; F4
#_FF00: db $39 ; A4
#_FF01: db $3C ; C5
#_FF02: db $3E ; D5
#_FF03: db $8C ; duration: $0C
#_FF04: db $40 ; E5
#_FF05: db $86 ; duration: $06
#_FF06: db $39 ; A4
#_FF07: db $3C ; C5
#_FF08: db $3E ; D5
#_FF09: db $8C ; duration: $0C
#_FF0A: db $41 ; F5
#_FF0B: db $86 ; duration: $06
#_FF0C: db $3C ; C5
#_FF0D: db $3E ; D5
#_FF0E: db $41 ; F5
#_FF0F: db $8C ; duration: $0C
#_FF10: db $45 ; A5
#_FF11: db $86 ; duration: $06
#_FF12: db $3E ; D5
#_FF13: db $41 ; F5
#_FF14: db $45 ; A5
#_FF15: db $8C ; duration: $0C
#_FF16: db $48 ; C6
#_FF17: db $86 ; duration: $06
#_FF18: db $41 ; F5
#_FF19: db $45 ; A5
#_FF1A: db $48 ; C6
#_FF1B: db $8C ; duration: $0C
#_FF1C: db $4C ; E6
#_FF1D: db $86 ; duration: $06
#_FF1E: db $45 ; A5
#_FF1F: db $48 ; C6
#_FF20: db $4A ; D6
#_FF21: db $8C ; duration: $0C
#_FF22: db $4D ; F6
#_FF23: db $86 ; duration: $06
#_FF24: db $48 ; C6
#_FF25: db $4A ; D6
#_FF26: db $4D ; F6
#_FF27: db $98 ; duration: $18
#_FF28: db $51 ; A6
#_FF29: db $A4 ; duration: $24
#_FF2A: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song0CTriangle:
#_FF2B: db $FD, $02 ; loop point
#_FF2D: db $98 ; duration: $18
#_FF2E: db $3E ; D5
#_FF2F: db $43 ; G5
#_FF30: db $40 ; E5
#_FF31: db $45 ; A5
#_FF32: db $FC ; loop part

#_FF33: db $E0 ; duration: $60
#_FF34: db $3E ; D5
#_FF35: db $F8 ; duration: $78
#_FF36: db $00 ; rest
#_FF37: db $B0 ; duration: $30
#_FF38: db $00 ; rest

;===================================================================================================
;===================================================================================================
; SONG 0B
;===================================================================================================
;===================================================================================================
Song0BSquare1:
#_FF39: db $98 ; duration: $18
#_FF3A: db $2F ; B3
#_FF3B: db $88 ; duration: $08
#_FF3C: db $32 ; D4
#_FF3D: db $36 ; F#4
#_FF3E: db $00 ; rest
#_FF3F: db $39 ; A4
#_FF40: db $00 ; rest
#_FF41: db $39 ; A4
#_FF42: db $98 ; duration: $18
#_FF43: db $00 ; rest

#_FF44: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song0BSquare2:
#_FF45: db $98 ; duration: $18
#_FF46: db $2C ; G#3
#_FF47: db $88 ; duration: $08
#_FF48: db $2C ; G#3
#_FF49: db $2C ; G#3
#_FF4A: db $00 ; rest
#_FF4B: db $31 ; C#4
#_FF4C: db $00 ; rest
#_FF4D: db $31 ; C#4
#_FF4E: db $98 ; duration: $18
#_FF4F: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song0BTriangle:
#_FF50: db $98 ; duration: $18
#_FF51: db $34 ; E4
#_FF52: db $88 ; duration: $08
#_FF53: db $34 ; E4
#_FF54: db $34 ; E4
#_FF55: db $00 ; rest
#_FF56: db $39 ; A4
#_FF57: db $00 ; rest
#_FF58: db $39 ; A4
#_FF59: db $98 ; duration: $18
#_FF5A: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song0BNoise:
#_FF5B: db $10 ; snare hit | duration: $04
#_FF5C: db $10 ; snare hit | duration: $04
#_FF5D: db $10 ; snare hit | duration: $04
#_FF5E: db $10 ; snare hit | duration: $04
#_FF5F: db $12 ; snare hit | duration: $08
#_FF60: db $12 ; snare hit | duration: $08
#_FF61: db $14 ; snare hit | duration: $10
#_FF62: db $14 ; snare hit | duration: $10
#_FF63: db $14 ; snare hit | duration: $10
#_FF64: db $04 ; rest      | duration: $10

;===================================================================================================
;===================================================================================================
; SONG 11
;===================================================================================================
;===================================================================================================
Song11Square1:
#_FF65: db $8C ; duration: $0C
#_FF66: db $37 ; G4
#_FF67: db $84 ; duration: $04
#_FF68: db $00 ; rest
#_FF69: db $37 ; G4
#_FF6A: db $37 ; G4
#_FF6B: db $88 ; duration: $08
#_FF6C: db $39 ; A4
#_FF6D: db $35 ; F4
#_FF6E: db $39 ; A4
#_FF6F: db $9C ; duration: $1C
#_FF70: db $3B ; B4
#_FF71: db $8C ; duration: $0C
#_FF72: db $00 ; rest

#_FF73: db $FF ; end of song

;---------------------------------------------------------------------------------------------------

Song11Square2:
#_FF74: db $8C ; duration: $0C
#_FF75: db $2F ; B3
#_FF76: db $84 ; duration: $04
#_FF77: db $00 ; rest
#_FF78: db $2F ; B3
#_FF79: db $2F ; B3
#_FF7A: db $88 ; duration: $08
#_FF7B: db $30 ; C4
#_FF7C: db $30 ; C4
#_FF7D: db $30 ; C4
#_FF7E: db $9C ; duration: $1C
#_FF7F: db $38 ; G#4
#_FF80: db $00 ; rest

;---------------------------------------------------------------------------------------------------

Song11Triangle:
#_FF81: db $8C ; duration: $0C
#_FF82: db $37 ; G4
#_FF83: db $84 ; duration: $04
#_FF84: db $00 ; rest
#_FF85: db $37 ; G4
#_FF86: db $37 ; G4
#_FF87: db $88 ; duration: $08
#_FF88: db $35 ; F4
#_FF89: db $35 ; F4
#_FF8A: db $35 ; F4
#_FF8B: db $B0 ; duration: $30
#_FF8C: db $34 ; E4

;===================================================================================================
;===================================================================================================
; SONG 12
;===================================================================================================
;===================================================================================================
Song12Square1:
#_FF8D: db $FD, $04 ; loop point
#_FF8F: db $86 ; duration: $06
#_FF90: db $3E ; D5
#_FF91: db $37 ; G4
#_FF92: db $3E ; D5
#_FF93: db $3D ; C#5
#_FF94: db $37 ; G4
#_FF95: db $3D ; C#5
#_FF96: db $FC ; loop part

#_FF97: db $FD, $04 ; loop point
#_FF99: db $86 ; duration: $06
#_FF9A: db $40 ; E5
#_FF9B: db $39 ; A4
#_FF9C: db $40 ; E5
#_FF9D: db $3F ; D#5
#_FF9E: db $39 ; A4
#_FF9F: db $3F ; D#5
#_FFA0: db $FC ; loop part

#_FFA1: db $FD, $04 ; loop point
#_FFA3: db $86 ; duration: $06
#_FFA4: db $3E ; D5
#_FFA5: db $37 ; G4
#_FFA6: db $3E ; D5
#_FFA7: db $3D ; C#5
#_FFA8: db $37 ; G4
#_FFA9: db $3D ; C#5
#_FFAA: db $FC ; loop part

#_FFAB: db $FD, $04 ; loop point
#_FFAD: db $86 ; duration: $06
#_FFAE: db $40 ; E5
#_FFAF: db $39 ; A4
#_FFB0: db $40 ; E5
#_FFB1: db $3F ; D#5
#_FFB2: db $39 ; A4
#_FFB3: db $3F ; D#5
#_FFB4: db $FC ; loop part

#_FFB5: db $FE ; loop song

;---------------------------------------------------------------------------------------------------

Song12Square2:
#_FFB6: db $FD, $08 ; loop point
#_FFB8: db $86 ; duration: $06
#_FFB9: db $3B ; B4
#_FFBA: db $00 ; rest
#_FFBB: db $3B ; B4
#_FFBC: db $FC ; loop part

#_FFBD: db $FD, $08 ; loop point
#_FFBF: db $86 ; duration: $06
#_FFC0: db $3D ; C#5
#_FFC1: db $00 ; rest
#_FFC2: db $3D ; C#5
#_FFC3: db $FC ; loop part

#_FFC4: db $FD, $08 ; loop point
#_FFC6: db $86 ; duration: $06
#_FFC7: db $3B ; B4
#_FFC8: db $00 ; rest
#_FFC9: db $3B ; B4
#_FFCA: db $FC ; loop part

#_FFCB: db $FD, $08 ; loop point
#_FFCD: db $86 ; duration: $06
#_FFCE: db $3D ; C#5
#_FFCF: db $00 ; rest
#_FFD0: db $3D ; C#5
#_FFD1: db $FC ; loop part

;---------------------------------------------------------------------------------------------------

Song12Triangle:
#_FFD2: db $FD, $08 ; loop point
#_FFD4: db $86 ; duration: $06
#_FFD5: db $35 ; F4
#_FFD6: db $00 ; rest
#_FFD7: db $35 ; F4
#_FFD8: db $FC ; loop part

#_FFD9: db $FD, $08 ; loop point
#_FFDB: db $86 ; duration: $06
#_FFDC: db $37 ; G4
#_FFDD: db $00 ; rest
#_FFDE: db $37 ; G4
#_FFDF: db $FC ; loop part

#_FFE0: db $FD, $04 ; loop point
#_FFE2: db $8C ; duration: $0C
#_FFE3: db $35 ; F4
#_FFE4: db $86 ; duration: $06
#_FFE5: db $41 ; F5
#_FFE6: db $43 ; G5
#_FFE7: db $8C ; duration: $0C
#_FFE8: db $3F ; D#5
#_FFE9: db $FC ; loop part

#_FFEA: db $FD, $04 ; loop point
#_FFEC: db $8C ; duration: $0C
#_FFED: db $37 ; G4
#_FFEE: db $86 ; duration: $06
#_FFEF: db $43 ; G5
#_FFF0: db $45 ; A5
#_FFF1: db $8C ; duration: $0C
#_FFF2: db $41 ; F5
#_FFF3: db $FC ; loop part

;===================================================================================================
;===================================================================================================
;===================================================================================================

;===================================================================================================
; FREE ROM: 0x05
;===================================================================================================
NULL_FFF4:
#_FFF4: db $FF, $FF, $FF, $FF, $FF

;===================================================================================================

IRQ:
#_FFF9: RTI

;===================================================================================================

Interrupts:
#_FFFA: dw NMI
#_FFFC: dw RESET
#_FFFE: dw IRQ

;===================================================================================================
