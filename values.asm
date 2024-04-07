;===================================================================================================
; SPRITES
;===================================================================================================
; 00 - NOTHING
; 01 - SPRING
; 02 - PLATFORM
; 03 - CRYSTAL
; 04 - BOSS FIREBALL
; 05 - HARD TARU             beetle guy
; 06 - BOXING GLOVE
; 07 - PAUMERU               fire-shooting walrus
; 08 - MAURI / GIANT HEAD    frog guy / bird frog
; 09 - KATCHINSHA            porygon guy
; 0A - BOSS
; 0B - HEART
; 0C - SAFUMA                fire comet guy
; 0D - VOODOO / AGU-AGU      skull snifit guy / ugly penguin man
; 0E - SLIME EYE
; 0F - HELP
; 10 - PHONEY PRINCESS
; 11 - TAMBO / BONE WING     spring guy / bouncing winged skull
; 12 - MEDAMARUGE            eyeball guy
; 13 - PROJECTILE            shuriken / fireball
; 14 - GYORO                 depressed blob
; 15 - BEAT                  derpy-lipped winged man
; 16 - EYE-EYE               Krumm from Aaahh!!! Real Monsters
; 17 - RUBIDE                spear guy
; 18 - UMBRELLA
; 19 - BALLOON
; 1A - HUDSON BEE            Hachisuke, the one and only
; 1B - KEY
; 1C - FIRE                  big one
; 1D - UNBAO                 kodongo guy
; 1E - BRAIN TOTO
; 1F - SPARK                 lightning
; 20 - FLAG                  annoying bat
; 21 - CROW
; 22 - STORY ITEM            music box / crown / cane
; 23 - MAHARITO              final boss
; 24 - MADORA                snapdragon toucan
; 25 - NOTE                  actually 2 beamed notes / accidentals
; 26 - GERUBO                pterodactyl guy
; 27 - FLYING EYE
; 28 - CAMRY                 flying fish
; 29 - SHIM                  scorpion guy

;===================================================================================================
; BOSSES
;===================================================================================================
; 01 - HOMA                  yellow kangaroo
; 02 - DOMA                  umaru~n
; 03 - BARUKAMA              yellow ridley
; 04 - BLUE DOMA             blumaru
; 05 - RED HOMA              red kangaroo
; 06 - RED BARUKAMA          red ridley (redley)
; 07 - KAMA                  skeletal demon, indiscriminate killer of runs

;===================================================================================================
; ROOMS
;---------------------------------------------------------------------------------------------------
; 00     - Overworld
; 01..08 - Puzzle rooms
; 09     - Cutscene room
; 0A..14 - Gauntlet rooms
; 15..1A - Boss rooms
;===================================================================================================
; 00 - Overworld
; 01 - First room
; 02 - Circular trap room
; 03 - NULL
; 04 - hudson room
; 05 - Big stairs room
; 06 - Purple room
; 07 - Breadsticks
; 08 - Fire place room
; 09 - Ending cutscene
; 0A - Left tower 1
; 0B - Right tower ice
; 0C - Shrine left
; 0D - Shrine right
; 0E - Well 1
; 0F - Well Hell
; 10 - Well 2
; 11 - GARBAGE
; 12 - Right tower lightning
; 13 - Left tower 2
; 14 - Left tower 3
; 15 - Maharito blue
; 16 - Maharito purple
; 17 - Maharito green
; 18 - Maharito brown
; 19 - Ending throne room
; 1A - Boss room

;===================================================================================================
; INDOOR OBJECTS
;---------------------------------------------------------------------------------------------------
; b - manipulable by bubbles
; s - passable by sprites
; f - damaging in well hell
; e - damaging in arc room
;===================================================================================================
; 00 |  s   | Empty
; 01 |  s   | 
; 02 |  sfe | 
; 03 |  sfe | 
; 04 |  sfe | 
; 05 |  sfe | 
; 06 |  sfe | 
; 07 |  sfe | 
; 08 |  sfe | Door top
; 09 |  sfe | Door bottom
; 0A |  sfe | 
; 0B |  sfe | 
; 0C |  sf  | 
; 0D |   f  | 
; 0E |      | 
; 0F |      | 
; 10 |      | Ice
; 11 |      | Spring
; 12 |      | Moving floor full
; 13 |      | Moving floor left half / Painted
; 14 |      | Moving floor empty
; 15 |      | Moving floor right half
; 16 |      | Pushable block
; 17 |      | Trapdoor
; 18 | b    | Breakable / Paintable
; 19 | b    | Breakable
; 1A | bf   | Breakable
; 1B | b    | Breakable
; 1C | b    | Block with coin
; 1D | b    | Block with honeycomb
; 1E |      | Coin
; 1F |      | Honeycomb
;---------------------------------------------------------------------------------------------------
; These objects are only ever called as arguments to drawing code:
;---------------------------------------------------------------------------------------------------
; 20 - Collapsing floor step 1
; 21 - Collapsing floor step 2
; 22 - Collapsing floor step 3
; 23 - Half-pushed block left
; 24 - Half-pushed block right

;===================================================================================================
; OVERWORLD OBJECTS
;---------------------------------------------------------------------------------------------------
; See OverworldObjectTiles
;===================================================================================================

;===================================================================================================
; MUSIC
;===================================================================================================
; 00 - Nothing
; 01 - Intro
; 02 - Overworld
; 03 - Continue
; 04 - Castle
; 05 - Well
; 06 - You win!
; 07 - Game over
; 08 - Entering door
; 09 - Exiting door
; 0A - Dying
; 0B - Bonus stage!
; 0C - Bubble cutscene
; 0D - Bonus stage - Drums
; 0E - Bonus stage - Euphonium/Ocarina
; 0F - Bonus stage - Harp/Trumpet
; 10 - Bonus stage - Violin
; 11 - Fanfare
; 12 - Boss stage

;===================================================================================================
; SOUND EFFECTS
;===================================================================================================
; 00 - Nothing
; 01 - Spring
; 02 - Milon jump
; 03 - Some collection thing (verify which)
; 04 - Fire blast
; 05 - Break block
; 06 - Push block / Open boss door
; 07 - Boss exploding
; 08 - Deep boing
; 09 - Key spawn
; 0A - Collect key
; 0B - Bee spawn
; 0C - Umbrella spawn
; 0D - Collect bee/umbrella
; 0E - Platform collapse
; 0F - Ice melt
; 10 - Collect money
; 11 - Shoot bubble
; 12 - Maharito shot
; 13 - Damage boss
; 14 - Enemy dying
; 15 - Milon damage
; 16 - Collect heart/note / Counter drain
; 17 - Pause/unpause
; 18 - Some explosion thing
