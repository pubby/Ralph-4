.include "globals.inc"

.export ppu_set_title_bg, ppu_set_game_bg, ppu_set_ending_bg
.export ppu_set_results_bg, ppu_set_timer_display

.segment "RODATA"

; We're only using the first nametable. This is its address.
ppu_nt_start_address = $2000

strCopyright1: .byt "@2016 PUBBY."
strCopyright2: .byt "MUSIC BY"
strCopyright3: .byt "MOVIEMOVIES1."

strPressStart1: .byt "PRESS START"
strPressStart2: .byt "TO BEGIN YOUR"
strPressStart3: .byt "ADVENTURE."

strEnding1: .byt "CONGRATULATIONS."
strEnding2: .byt "RALPH ENTERED THE BEAR"
strEnding3: .byt "LAIR AND OVERTHREW THE"
strEnding4: .byt "MALEVOLENT BEAR MONARCHY."
strEnding5: .byt "RALPH THANKS YOU"
strEnding6: .byt "FOR YOUR HELP."
strEnding7: .byt "YOU ARE A WINNER TODAY!"

strYourTime: .byt "TIME: "
strDeaths: .byt "DEATHS:  "
strPressStartResults1: .byt "PRESS START"
strPressStartResults2: .byt "TO PLAY AGAIN."

.segment "CODE"

; Writes a string (without newlines) on the screen as background tiles.
; Does not set attributes.
; Clobbers A, X. Preserves Y.
.macro write_str x_pos, y_pos, str
    .local ppu_nt_address, writeLoop, str_size
    ppu_nt_address = ppu_nt_start_address + (y_pos)*$20 + (x_pos)
    str_size = .sizeof(str)

    lda PPUSTATUS       ; Read PPU status to reset the hi/lo address latch.
    lda #.hibyte(ppu_nt_address)
    sta PPUADDR
    lda #.lobyte(ppu_nt_address)
    sta PPUADDR

    ldx #0
writeLoop:
    lda str,x
    ora #%10000000      ; Add $80 to ASCII value to get pattern table index.
    sta PPUDATA
    inx
    cpx #str_size
    bne writeLoop
.endmacro

; Clears the nametable by setting all tiles to BLANK_TILE_PATTERN,
; and all attributes in the attribute table to 0.
; Clobbers A, X. Preserves Y.
.proc ppu_clear_nt
    lda #.hibyte(ppu_nt_start_address)
    sta PPUADDR
    lda #.lobyte(ppu_nt_start_address)
    sta PPUADDR

    ; Clear the tiles using a 4-times unrolled loop.
    ; The loop has to be unrolled because NT_NUM_TILES > 256.
    lda #BLANK_TILE_PATTERN
    ldx #NT_NUM_TILES / 4       ; Unroll 4 times.
clearTilesLoop:
    .repeat 4
        sta PPUDATA     ; Write the blank tiles to the nametable.
    .endrepeat
    dex
    bne clearTilesLoop

    ; Now clear the attributes.
    ; Keep in mind that attribute data immediately follows tile data in VRAM,
    ; so it is not necessary to change PPUADDR.
    lda #0
    ldx #NT_NUM_ATTRIBUTES
clearAttributeLoop:
    sta PPUDATA         ; Write attributes of 0 to the nametable.
    dex
    bne clearAttributeLoop
    rts
.endproc

.proc ppu_set_timer_display
    x_pos = 2
    y_pos = 2
    ppu_nt_address = ppu_nt_start_address + y_pos*$20 + x_pos
    lda PPUSTATUS       ; Read PPU status to reset the hi/lo address latch.
    lda #.hibyte(ppu_nt_address)
    sta PPUADDR
    lda #.lobyte(ppu_nt_address)
    sta PPUADDR

    ldx #%11100000 + 10
    .repeat ::NUM_HOURS_DIGITS, i
        lda hours_digits+i
        ora #%11100000
        sta PPUDATA
    .endrepeat
    stx PPUDATA
    .repeat ::NUM_MINUTES_DIGITS, i
        lda minutes_digits+i
        ora #%11100000
        sta PPUDATA
    .endrepeat
    stx PPUDATA
    .repeat ::NUM_SECONDS_DIGITS, i
        lda seconds_digits+i
        ora #%11100000
        sta PPUDATA
    .endrepeat
    rts
.endproc

.proc ppu_set_title_bg
    ; Start with a blank (cleared) background.
    jsr ppu_clear_nt

    ; Write the logo.
    logo_x = 8
    logo_y = 11
    ppu_nt_address = ppu_nt_start_address + logo_y*$20 + logo_x
    lda PPUSTATUS       ; Read PPU status to reset the hi/lo address latch.
    lda #.hibyte(ppu_nt_address)
    sta PPUADDR
    lda #.lobyte(ppu_nt_address)
    sta PPUADDR

    logo_start_pattern = $60
    logo_end_pattern = logo_start_pattern+$40
    ldx #logo_start_pattern
    ldy #BLANK_TILE_PATTERN
logoWriteLoop:
    .repeat 16
        stx $2007       ; Write logo tiles to PPU.
        inx
    .endrepeat
    .repeat 16
        sty $2007       ; Write blank tiles to PPU as padding.
    .endrepeat
    cpx #logo_end_pattern
    bne logoWriteLoop

    ; Now write the text below the logo.
    write_str 10, 15, strCopyright1
    write_str 12, 16, strCopyright2
    write_str 10, 17, strCopyright3
    write_str 10, 19, strPressStart1
    write_str  9, 20, strPressStart2
    write_str 11, 21, strPressStart3
    rts
.endproc

.proc ppu_set_ending_bg
    ; Start with a blank (cleared) background.
    jsr ppu_clear_nt

    ; Write the text.
    y_start = 11
    write_str  8, y_start +  0, strEnding1
    write_str  5, y_start +  2, strEnding2
    write_str  5, y_start +  3, strEnding3
    write_str  4, y_start +  4, strEnding4
    write_str  8, y_start +  6, strEnding5
    write_str 10, y_start +  7, strEnding6
    write_str  5, y_start +  8, strEnding7
    rts
.endproc

.proc ppu_set_results_bg
    ; Start with a blank (cleared) background.
    jsr ppu_clear_nt

    y_start = 11
    write_str  9, y_start+0, strDeaths
    .repeat ::NUM_DEATHS_DIGITS, i
        lda deaths_digits+i
        ora #%10110000  ; Fast way of adding (11*16).
        sta PPUDATA
    .endrepeat
    write_str  9, y_start+2, strYourTime

    ldx #%10110000 + 10
    .repeat ::NUM_HOURS_DIGITS, i
        lda hours_digits+i
        ora #%10110000
        sta PPUDATA
    .endrepeat
    stx PPUDATA
    .repeat ::NUM_MINUTES_DIGITS, i
        lda minutes_digits+i
        ora #%10110000
        sta PPUDATA
    .endrepeat
    stx PPUDATA
    .repeat ::NUM_SECONDS_DIGITS, i
        lda seconds_digits+i
        ora #%10110000
        sta PPUDATA
    .endrepeat

    write_str 10, y_start+7, strPressStartResults1
    write_str  9, y_start+8, strPressStartResults2

    rts
.endproc

; Writes a whole nametable of background tiles using data from 'tiles' array.
; Clobbers A, X. Preserves y.
.proc ppu_set_game_bg
cur_attribute = 0       ; Variable used to build the attribue array.
    ; Tell the PPU that we want to update the background.
    lda PPUSTATUS       ; Read PPU status to reset the hi/lo address latch.
    lda #.hibyte(ppu_nt_start_address)
    sta PPUADDR
    lda #.lobyte(ppu_nt_start_address)
    sta PPUADDR

    ; The game uses 16x16 metatiles, stored as 1-byte-per-tile in the 
    ; 'tiles' array. The value of each 1-byte item in the 'tiles' array
    ; corresponds to the upper-left 8x8 tile of the metatile.
    ; To turn 16x16 metatiles into 8x8 tiles, we iterate over 16-length
    ; rows twice, each time copying two 8x8 tiles at a time. This is the
    ; reason why 'loopUppers' and 'loopLowers' exist.
    ldx #0              ; Iterate from 0.
loopUppers:
    lda tiles,x         ; Load upper-left 8x8 tile of the 16x16 metatile.
    sta $2007           ; Write it to PPU.
    clc
    adc #1              ; Add 1 to get the upper-right tile.
    sta $2007           ; Write it to PPU.
    inx
    txa
    and #%00001111      ; Rows are 16 meta-tiles wide, so Y % 16 determines
    bne loopUppers      ; when an entire row is completed.
    txa
    sec
    sbc #LEVEL_W
    tax
loopLowers:
    lda tiles,x         ; Load the upper-left 8x8 tile, again.
    ora #%00010000      ; Add 16 to get the lower-left tile.
    sta $2007           ; Write the lower-left tile to PPU
    clc
    adc #1              ; Add 1 to get the lower-right tile.
    sta $2007           ; Write it to PPU.
    inx
    txa
    and #%00001111      ; Again, check if the row is completed.
    bne loopLowers
    cpx #LEVEL_W * LEVEL_H      ; And check if every tile is complete.
    bne loopUppers

    ; Now set the attribute data.

    lda PPUSTATUS       ; Read PPU status to reset the hi/lo address latch.
    lda #$23
    sta PPUADDR         ; Write the high byte of $23C0 address.
    lda #$C0
    sta PPUADDR         ; Write the low byte of $23C0 address.

    ; A 1-byte attribute represents a 32x32 area (four 16x16 metatiles).
    ; We build the attribute array by iterating over 'tiles' in increments
    ; of two, skipping every other row to account for the size difference.
    ldx #0              ; Iterate from 0.
loadAttrLoop:
    ; Build the 1-byte attribute checking 4 metatiles at once.
    lda #0
    sta cur_attribute
    .repeat 2, i
    .repeat 2, j
        lda tiles+i+j*16,x
        lsr
        and #%00000011  ; The lower 2 bits of a 'tiles' item determines the
                        ; palette it will use.
        .repeat i+j*2
            asl
            asl
        .endrepeat
        ora cur_attribute
        sta cur_attribute
    .endrepeat
    .endrepeat
    sta $2007           ; Attribute is complete. Write it to PPU.
    inx                 ; Increment twice since attributes are
    inx                 ; two-metatiles wide.
    txa
    and #%00001111      ; Check if we compeleted a row of tiles.
    bne loadAttrLoop
    txa                 ; If row was completed: skip the next row of tiles
    adc #LEVEL_W        ; as its attributes have already been set.
    tax                 ; Remember: attributes are 2-metatiles high.
    bcc loadAttrLoop    ; Overflow signifies all attributes have been set.
    rts
.endproc

