;===================================================================================================
;---------------------------------------------------------------------------------------------------
; Zero page
;---------------------------------------------------------------------------------------------------
;===================================================================================================
; PPU buffers
PPUCTRLQ        = $0000
PPUMASKQ        = $0001

; Joypad input for normal and famicom expansion port
; ABsSudlr
JOY1            = $0002
JOY1EX          = $0003

JOY2            = $0004
JOY2EX          = $0005

; PPUSCROLL buffers
SCROLLX         = $0006
SCROLLY         = $0007

; More joypad stuff
JOYREAL         = $0008 ; has all joypad input, except P2 start/select
JOYMOD          = $0009 ; seems to handle forced joypad changes

; FREE RAM: 0x01
UNUSED_0A       = $000A

UNKNOWN_000B    = $000B
UNKNOWN_000C    = $000C
UNKNOWN_000D    = $000D
UNKNOWN_000E    = $000E

SCRATCH0F       = $000F
SCRATCH10       = $0010
SCRATCH11       = $0011
SCRATCH12       = $0012

; Direction of pan
;   00 - up
;   01 - down
PANDIR          = $0013

; Buffer for Y scrolling to help with calculations
PANQ            = $0014

; Used for flagging which half of a block is being operated on
BLKHALF         = $0015

; Tilemap coordinates of the tiles on the top and left edges of the screen
SCRTY           = $0016
SCRTX           = $0017

; Indices into VMBUFFER
VUPY            = $0018
VUPX            = $0019

; Counter for arbitrary VRAM transfers during NMI
VXFRCT          = $001A

; Only used during VXfr02 as a mask
VXMASK          = $001B

; Scratch RAM; esp for pointers
SCRATCH1C       = $001C
SCRATCH1D       = $001D

SCRATCH1E       = $001E
SCRATCH1F       = $001F
SCRATCH20       = $0020
SCRATCH21       = $0021
SCRATCH22       = $0022
SCRATCH23       = $0023

; Used as some kinda scratch in movement code TODO
UNKNOWN_0024    = $0024

; Used together as temp variables in some code TODO
UNKNOWN_0025    = $0025
UNKNOWN_0026    = $0026
UNKNOWN_0027    = $0027

; Used as something with milon coordinates TODO
UNKNOWN_0028    = $0028

; Parameters, especially for tile map stuff
TMARGX          = $0029
TMARGY          = $002A
TMARGN          = $002B

; Holds the type of tile milon tepped on for creating transients/springs
STEPONA         = $002C

; A bit more general
STEPONB         = $002D

SCRATCH2E       = $002E
SCRATCH2F       = $002F

; Index into OAM buffer
OAMI            = $0030

; Flips between 00 and C0 for where OAMI starts
OAMF            = $0031

; Holds palette without flip for objects
OBJPAL          = $0032

; Used to index object flip tables
FLIPI           = $0033

; Direction (0: right | 1: left)
DRAWDIR         = $0034

; Object properties (same order as OAM)
OBJY            = $0035 ; yyyy yyyy
OBJT            = $0036 ; tttt tttn
OBJP            = $0037 ; vhp. ..cc
OBJX            = $0038 ; xxxx xxxx

; Flags NMI execution
DIDNMI          = $0039

; Skips NMI updates when set
NOUPDATE        = $003A

; Number of frames Milon has been performing a jump
AIRTIME         = $003B

; Milon mode?
; ccaa aaaa
;  c - some control thing?
;    00 - normal
;    01 - nothing...?
;    10 - damage jump
;    11 - change size
;  a - anim?
MILODE          = $003C

; Growth/recoil timer
OOFTM           = $003D

; Milon coords
SCREENX         = $003E
SCREENY         = $003F

; I'm Walkin Here! - Flags Milon doing his walk animation
IWH             = $0040

; Milon strut animation timer
STRUT           = $0041

; Caches dpad inputs
DPAD            = $0042

; Milon's direction, but not exactly?
;  00 - used during cutscenes
;  01 - right
;  02 - left
MDIR            = $0043

; Momentum timer
; In physics, momentum is often denoted with the variable p
PTM             = $0044

; Timer used
BLIMPTM         = $0045

; Milon's subpixel velocity on the X-axis
SUBVX           = $0046

; Milon's speed (00..0A)
SPEED           = $0047

; Milon's subpixel velocity on the Y-axis
SUBVY           = $0048

; Jump timer
JUMPTM          = $0049

; Milon is in air
INAIR           = $004A

; Milon's true coordinates
POSXL           = $004B
POSXH           = $004C
POSYL           = $004D
POSYH           = $004E

; Triggers death cutscene
DEAD            = $004F

; Flags Milon stepping on a spring
SPRUNG          = $0050

; Extra height from spring
SPRONG          = $0051

; Milon's size
;   00 - small
;   01 - big
;   other values are undefined behavior
BIGBOY          = $0052

; Milon's palette ID and props
MIPROPS         = $0053

; Tile under Milon
TUNDER          = $0054

; When set, Milon will be at terminal velocity when falling off a ledge/platform
FASTFALL        = $0055

; Difference between Milon's coordinates and moving platform's
PLATDIFFA       = $0056
PLATDIFFB       = $0057

; Scratch space for screen coordinates
MTEMPX          = $0058
MTEMPY          = $0059

; Used primarily as pointers for room theme tile and palette pointers, respectively
THRMRTL         = $005A
THRMRTH         = $005B
THRMRPL         = $005C
THRMRPH         = $005D

; Used for caching slot
SLOTX           = $005E

;---------------------------------------------------------------------------------------------------

; Bubble variables for zero page access

; Bubble direction
; .... ..vh
;   v - vertical direction
;   h - horizontal direction
;      00 - up right
;      01 - up left
;      10 - down right
;      11 - down left
BUBDIR          = $005F ; $0710,X

; Bubble timer
BUBTM           = $0060 ; $0711,X

; Screen coordinates - not sure if high bytes are used by bubbles
BUBX            = $0061 ; $0712,X
BUBXH           = $0062 ; $0713,X
BUBY            = $0063 ; $0714,X
BUBYH           = $0064 ; $0715,X

;---------------------------------------------------------------------------------------------------

; Sprite variables for zero page access
SPRATM          = $005F ; $0600,X - respawn timer
SPRGFX          = $0060 ; $0601,X
SPRXL           = $0061 ; $0602,X
SPRXH           = $0062 ; $0603,X
SPRYL           = $0063 ; $0604,X
SPRYH           = $0064 ; $0605,X

; Direction, at least for some sprites
; .... ..vh
SPRDIR          = $0065 ; $0606,X

SPRMISCA        = $0066 ; $0607,X
SPRMISCB        = $0067 ; $0608,X
SPRMISCC        = $0068 ; $0609,X

; Spawn coordinates (/16)
SPRX0           = $0069 ; $060A,X
SPRY0           = $006A ; $060B,X

;---------------------------------------------------------------------------------------------------

; Caches sprite slot
SPRSLOT         = $006B

; Entity ID for zero page access
SPRID           = $006C

; Caches platform screen coordinates
PLATFORMY       = $006D
PLATFORMX       = $006E

; Length of word
WLEN            = $006F

; Letter index of word?
LETTERN         = $0070

; Used as a pointer when reading words
WPTRL           = $0071
WPTRH           = $0072

; Word index in text data
WINDEX          = $0073

; FREE RAM: 0x01
UNUSED_74       = $0074

; Scratch space (often preserves X and Y)
SCRATCH75       = $0075
SCRATCH76       = $0076
SCRATCH77       = $0077

; Current bubble slots
;   00 - empty
;   01 - active
;   08 - about to explode
;   09 - exploding
; Also used in shops and bonus game.
BUBBLE1         = $0078 ; counts notes collected
BUBBLE2         = $0079
BUBBLE3         = $007A

; Caches bubble X and Y screen coordinates
BUBBLEX         = $007B
BUBBLEY         = $007E

; Shop prices
PRICE1          = $007B
PRICE2          = $007C
PRICE3          = $007D

; Barnaby text row/column
TEXTR           = $007E
TEXTC           = $007F

; Stops Milon from moving in shop
TEXTON          = $0080

; Used for tilemap X/Y calculations
TESTX           = $0081 ; Also used to flag item being purchased
TESTY           = $0082 ; Also used to index shop items

; Transient tile animations (blocks, trapdoor, ice, etc)
TRNSNT0         = $0083
TRNSNT1         = $0084
TRNSNT2         = $0085
TRNSNT3         = $0086

; 
ROOMID          = $0087

; Controls which moving pit is being operated
PITN            = $0088

; 00 - Outside
; 01 - Inside
INSIDE          = $0089

; 00 - Inside
; 01 - Outside
OUTSIDE         = $008A

; Flags screen edge transitions, subrooms, etc
SCREDGE         = $008B

; Tilemap coordinates of return position from subrooms
RETX            = $008C
RETY            = $008D

; Frame counter
FRAME           = $008E

; Lightning timer
LTNGTM          = $008F
LTNGCT          = $0090

; Zeroed in one place, but never read
JUNK_0091       = $0091

; X and Y adjustments for screen coordinates
; only ever used by smoke puffs in practice
SCRADJX         = $0092
SCRADJY         = $0093

; Graphics bank
GFXBANK         = $0094

; Flags loading the overworld from a room with an animated exit
EXITING         = $0095

; Palette cycling counter
PALCYC          = $0096

; Flags palette updates
DOPAL           = $0097

; Overworld palette
OWPAL           = $0098

; Block push timer
PUSHTM          = $0099

; Counts up to 14 then starts balloon cutscene
BLNCSTM         = $009A

; ...e e.td
;   e - bubble damage
;       bit 3 from crystal 2 (bit 6 of $B7)
;       bit 4 from excalibur
;   t - triple shot
;   d - double shot
BUBBLE          = $009B

; Bee shield
SHIELD          = $009C

; Kill counter for umbrella
UMKILL          = $009D

; Some timer with ending cutscene
ENDCSTM         = $009E

; Flags which doors are revealed
DOOR1           = $009F ; Always the room exit
DOOR2           = $00A0

; Money and note counters (BCD)
CASHE2          = $00A1
CASHE1          = $00A2
CASHE0          = $00A3

NOTESE2         = $00A4
NOTESE1         = $00A5
NOTESE0         = $00A6

; Additive inverse of the amount the screen is scrolling per frame
SCRVIY          = $00A7
SCRVIX          = $00A8

; Nudge timer
NUDGETM         = $00A9

; Nudge direction
; d... ....
;   d - direction (0: right | 1: left)
NUDGEDIR        = $00AA

; Flags the platform as being off screen
; 00 - on screen
PLATVIS         = $00AB

; Reset to 00 on room load and incremented for ROOM 0B, but value never used
ICEDEBUG        = $00AC

; Used as a countdown to apply velocity one pixel at a time
VELX            = $00AD
VELY            = $00AE

; Flags for drawing
;   .... ..hs
;     h - flip for direction
;     s - check if on screen
DRAWHOW         = $00AF

; Flags how to deal with dealing damage
; .... ..dh
;  d - die only if Milon is shielded (never flagged in game)
;  h - can hurt Milon
HARMHOW         = $00B0

; Flags how to deal with taking damage
; ..dh b.vi
;   d - drop items
;   h - can be hurt when timer is running
;   b - require bubble damage upgrade to hit
;   v - invisible to bubbles
;   i - immune to bubbles
HURTHOW         = $00B1

; Milon HP
CURHP           = $00B2
MAXHP           = $00B3

; Boss ID
BOSSID          = $00B4

; Used as scratch space for sprite movement calculations
SPRVEL          = $00B5

; Crystal count and bitfield
CRYCT           = $00B6
CRYTALS         = $00B7

HARDMODE        = $00B8

; Horizontal position of life bar
HPX             = $00B9

; Flags which fake Maharitos have been defeated
FAKEMAH         = $00BA

; Damage taken with current shield level (breaks at 16)
SHIELDHP        = $00BB

; Tracks how many times you've visited the super shoes store
FOOTLOCKER      = $00BC

; .... ..wc
;   w - crown
;   c - cane
ROYAL           = $00BD

; pwwi iiii
;   p - song is playing
;   w - wave form modification via glitchy data
;   i - song ID
SONG            = $00BE

; Flags pausing
; m... ...p
;   m - music-specific paused
;   p - game paused
PAUSED          = $00BF

; Orchestral collection bits (in order you got them)
ORCH            = $00C0

;---------------------------------------------------------------------------------------------------
; Music variables
;---------------------------------------------------------------------------------------------------
; Track pointers
CH1TPL          = $00C1
CH1TPH          = $00C2
CH2TPL          = $00C3
CH2TPH          = $00C4
CH3TPL          = $00C5
CH3TPH          = $00C6
CH4TPL          = $00C7
CH4TPH          = $00C8

; Channel durations
CH1DUR          = $00C9
CH2DUR          = $00CA
CH3DUR          = $00CB
CH4DUR          = $00CC

; Channel current durations
CH1NV0          = $00CD
CH2NV0          = $00CE
CH3NV0          = $00CF
CH4NV0          = $00D0

; Return point for calling a loop
CH1RTL          = $00D1
CH1RTH          = $00D2
CH2RTL          = $00D3
CH2RTH          = $00D4
CH3RTL          = $00D5
CH3RTH          = $00D6
CH4RTL          = $00D7
CH4RTH          = $00D8

; Loop counter for parts
CH1LOOP         = $00D9
CH2LOOP         = $00DA
CH3LOOP         = $00DB
CH4LOOP         = $00DC

; Note frequency scratch space
FREQL           = $00DD
FREQH           = $00DE

; Scratch used for music
SCRATCH_DF      = $00DF

; Channel base volume
CH1VOL          = $00E0
CH2VOL          = $00E1
CH3VOL          = $00E2

; Channel index
CHX             = $00E3

; Flags song being ended via command
SONGOVER        = $00E4

; General scratch for music, but also holds the track byte
CHTB            = $00E5

; SFX and previous SFX
SFX             = $00E6
SFXL            = $00E7

; Flags whether a SFX is using the channel
SFXUSES1        = $00E8 ; square 1
SFXUSES2        = $00E9 ; square 2
SFXUSETR        = $00EA ; triangle
SFXUSENS        = $00EB ; noise

; SFX data pointer
SFXPTRL         = $00EC
SFXPTRH         = $00ED

; Offset into SFX data
SFXOFF          = $00EE

; Lower 5 bits of SFX data
SFXPRM          = $00EF

; Base volume for square wave sound effects
SFXVOL          = $00F0

; Sound effect wait timer
SFXWT           = $00F1

; Zeroed on song load, but never read
JUNK_00F2       = $00F2
JUNK_00F3       = $00F3

; FREE RAM: 0x0C
UNUSED_F4       = $00F4
UNUSED_F5       = $00F5
UNUSED_F6       = $00F6
UNUSED_F7       = $00F7
UNUSED_F8       = $00F8
UNUSED_F9       = $00F9
UNUSED_FA       = $00FA
UNUSED_FB       = $00FB
UNUSED_FC       = $00FC
UNUSED_FD       = $00FD
UNUSED_FE       = $00FE
UNUSED_FF       = $00FF

;===================================================================================================

; FREE RAM: 0x20
UNUSED_0100     = $0100

; Tilemap high bits
TMAPHI          = $0120

; Moving pit array
MPITX           = $0198 ; X position ($80+ disabled and end of list)
MPITY           = $0199 ; Y position
MPITD           = $019A ; Direction (0: left | 1: right)
MPITT           = $019B ; Timer
MPITM           = $019C ; Timer target

MPIT00          = $0198
MPIT01          = $019D
MPIT02          = $01A2
MPIT03          = $01A7
MPIT04          = $01AC
MPIT05          = $01B1
MPIT06          = $01B6
MPIT07          = $01BB

; Smoke puffs
PUFF0           = $01C0
PUFF1           = $01C1
PUFF2           = $01C2
PUFF3           = $01C3

PUFFTM          = $01C4
PUFFX           = $01C8
PUFFY           = $01CC

; Stack $01D0..$01FF
STACKTOP        = $01FF

;===================================================================================================
; Some sort of update buffer
;===================================================================================================
VMBUFFER        = $0200

; OAM buffer
OAMBFR          = $0300

; Tile map
TILEMAP         = $0400

; Palette buffer
PALBUFR         = $05E0

;===================================================================================================

SPRVARS0        = $0600
SPRVARS1        = $060C
SPRVARS2        = $0618
SPRVARS3        = $0624
SPRVARS4        = $0630
SPRVARS5        = $063C
SPRVARS6        = $0648
SPRVARS7        = $0654
SPRVARS8        = $0660
SPRVARS9        = $066C
SPRVARSA        = $0678
SPRVARSB        = $0684
SPRVARSC        = $0690
SPRVARSD        = $069C
SPRVARSE        = $06A8
SPRVARSF        = $06B4

; Used for highest highest bits on overworld
MOSTHBITS       = $0648

; Sprite ID for each slot
SPRID           = $06C0

; Tilemap buffers for panning new row of tiles
ROWTILEQ        = $06D0
ROWPALSQ        = $06F0

;---------------------------------------------------------------------------------------------------

; FREE RAM: 0x18
UNUSED_06F0     = $06F8

; Bubble variables
BUBVARS0        = $0710
BUBVARS1        = $0716
BUBVARS2        = $071C

; Tile flagging (0x78 bytes)
TILEFLAG        = $0722

; Items
; Doubles as a shop-ID indexed flag set...
SHOES           = $079A
SPRSHOES        = $079B
WALLSAW         = $079C
MEDICINE        = $079D
SHOES2          = $079E ; from the other shop
LAMP            = $079F
HAMMER          = $07A0
LAMP2           = $07A1 ; from the other shop
CASHGOT         = $07A2 ; only tracks whether you've grabbed the free money
VEST            = $07A3
FEATHER         = $07A4
PAINT           = $07A5
BLIMP           = $07A6
EXCALIBUR       = $07A7
CANTEEN         = $07A8

;---------------------------------------------------------------------------------------------------

; Transient tile properties
TRNTV0          = $07A9
TRNTV2          = $07AD
TRNTV3          = $07B1
TRNTV4          = $07B5

TRNTX           = $07A9 ; X position
TRNTY           = $07AA ; Y position
TRNTC           = $07AB ; Tile for trapdoors
TRNTTM          = $07AC ; Timer

;---------------------------------------------------------------------------------------------------

; Location of Hudson bee
BEEX            = $07B9
BEEY            = $07BA

; Flags bee being collected for this room
BEEGOT          = $07BB

; Break things counter per room
BRKCT           = $07BC

; Money counter per room
CASHCT          = $07BD

; Enemy counter per room
KILLCT          = $07BE

; 00 - no key
; 01 - key has spawned
; 02 - key has been collected
KEYFLAG         = $07BF

; Changes the logic for note value spawns in the bonus game,
; but it can never hold a value that's checked for
; TODO is this vestigial from the JP version mash counter perhaps?
NOTEMOD         = $07C0

; Written to with room ID once; never read
JUNK07C1        = $07C1

; Room ID of where a subroom was entered from
TOPROOM         = $07C2

; Flags touching a push block, used by fire to hide in the fire place
PUSHED          = $07C3

; RNG seed, incremented
RNG             = $07C4

; Tables for tracking room stuff

; Item grabbed flags
BEEGRAB         = $07C5 ; 3 bytes
KEYGRAB         = $07C8 ; 2 bytes
MUSGRAB         = $07CA ; 2 bytes, music boxes

; Music box coordinates
MBOXX           = $07CC
MBOXY           = $07CD

; Flags music box being collected for this room
MBOXDONE        = $07CE

; Note-cash exchange rate; also flags being in bonus game
NOTEPER         = $07CF

; Flags continuing
CONTINUED       = $07D0

; Used for calculating tranitions
TRNROOM         = $07D1
TRNTMX          = $07D2
TRNTMY          = $07D3

; Hold shop ID
SHOPID          = $07D4

; Animates bubble and bee shield
; Counts 0, 1, 2 and resets
EQUANIM         = $07D5

; Room ID of the real Maharito
TRUEMAHA        = $07D6

; Door locations
DOORAX          = $07D7
DOORBX          = $07D8
DOORAY          = $07D9
DOORBY          = $07DA

; Number of projectiles on screen
PROJCT          = $07DB

; FREE RAM 0x1A
UNUSED_07DC     = $07DC

; Channel envelope volume index
CH1ENV          = $07F6
CH2ENV          = $07F7
CH3ENV          = $07F8 ; Technically not used

; Channel base envelope volume index
CH1ENV0         = $07F9
CH2ENV0         = $07FA
CH3ENV0         = $07FB ; Technically not used

CH1VOL          = $07FC
CH2VOL          = $07FD
CH3VOL          = $07FE ; Technically not used

PREVSONG        = $07FF
