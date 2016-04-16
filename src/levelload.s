.include "src/globals.inc"

.export load_level

.segment "RODATA"
; When compressed, tiles are integers in the range 0-15.
; Uncompressing requires converting these 4-bit integers into an
; 8-bit pattern table index, and is done by using this lookup table.
tile_lookup:
.repeat 4, i
    .byt TILE_EMPTY_START + i*2
.endrepeat
.repeat 4, i
    .byt TILE_EXIT_START + i*2
.endrepeat
.repeat 4, i
    .byt TILE_BEAR_START + i*2
.endrepeat
.repeat 4, i
    .byt TILE_WALL_START + i*2
.endrepeat

.segment "CODE"
; Loads level A into memory.
; Clobbers A, X, Y.
.proc load_level
level_ptr        = 0     ; 2 bytes
level_tiles_ptr  = 2     ; 2 bytes
objs_size        = 4
compressed_i     = 5
uncompressed_i   = 6
run_length       = 7
    ; Lookup the level (indexed by A) in 'level_index' and store the 16-bit
    ; pointer in level_ptr.
    asl                 ; The array has 16-bits items, so we have to multiply
    tay                 ; the index by 2.
    lda level_index,y
    sta level_ptr+1
    lda level_index+1,y
    sta level_ptr

    ;lda #<level_data0
    ;sta level_ptr
    ;lda #>level_data0
    ;sta level_ptr+1

    ; Now we're going to read the objects from level_ptr, and we'll use
    ; the Y register as an index to the pointed-to array.
    ldy #0              ; Start at index 0, obviously.

    ; Set the player's position.
    lda (level_ptr),y
    .repeat 4
        asl
    .endrepeat
    clc
    adc #PLAYER_XOFF
    sta player_x1
    sta player_starting_x1
    adc #PLAYER_W       ; Don't have to clear carry.
    sta player_x2
    lda (level_ptr),y
    and #%11110000
    clc
    adc #PLAYER_YOFF
    sta player_y1
    sta player_starting_y1
    adc #PLAYER_H       ; Don't have to clear carry.
    sta player_y2
    iny

    ; Set the gem's position
    lda (level_ptr),y
    sta gem_visible     ; 0 position signifies a level with no gem.
    sta gem_starting_visible
    .repeat 4
        asl
    .endrepeat
    clc
    adc #8              ; Add 8 to put the gem in the middle of 16x16 square.
    sta gem_x1
    lda (level_ptr),y
    and #%11110000
    adc #8              ; Add 8 to put the gem in the middle of 16x16 square.
    sta gem_y1
    iny

    ; Set enemies.
    lda (level_ptr),y
    iny
    sta num_enemies
    cmp #0
    beq doneSettingEnemies
    tax
enemyAttrLoop:
    lda (level_ptr),y
    sta enemies_attr-1,x
    iny
    dex
    bne enemyAttrLoop
doneEnemyAttrLoop:
    ldx num_enemies
enemyPositionLoop:
    lda (level_ptr),y
    .repeat 4
        asl
    .endrepeat
    sta enemies_x1-1,x
    sta enemies_starting_x1-1,x
    lda (level_ptr),y
    and #%11110000
    sta enemies_y1-1,x
    sta enemies_starting_y1-1,x
    iny
    dex
    bne enemyPositionLoop
doneSettingEnemies:

    ; Ok! Done with objects.
    ; Write how many bytes they took up to 'objs_size'.
    sty objs_size

    ; Add objs_size to level_ptr to get level_tiles_ptr.
    ; (note: we could reuse level_ptr here, but it's less confusing
    ; to intorduce a new variable.)
    lda level_ptr
    clc
    adc objs_size
    sta level_tiles_ptr
    lda level_ptr+1
    adc #0
    sta level_tiles_ptr+1

    ; Now for the tiles. We need to uncompress their RLE format and
    ; copy them into RAM.
    ; The RLE format is bytes of aaaabbbb, where bbbb is the tile index
    ; and aaaa is the number of repetitions ('run_length') after the first.
    ; The decoder needs to iterate two arrays and one run-length per
    ; 'tileCopyLoop', but there's not enough registers to do that.
    ; To compensate, compressed_i and uncompressed_i are used to swap Y
    ; between variables.
    ldy #0
    sty compressed_i
tileCopyLoop:
    sty uncompressed_i
    ldy compressed_i

    lda (level_tiles_ptr),y
    and #%11110000
    .repeat 4
        lsr
    .endrepeat
    sta run_length

    lda (level_tiles_ptr),y
    and #%00001111
    tax
    lda tile_lookup,x   ; The tile's pattern table index is now in A.
                        ; This will get copied into the 'tiles' array.
    ldx run_length
    iny
    sty compressed_i
    ldy uncompressed_i
runLengthLoop:
    sta tiles,y
    iny
    dex
    cpx #$FF            ; An "underflow" signifies the end of the run.
    bne runLengthLoop
    cpy #LEVEL_W*LEVEL_H
    bne tileCopyLoop

    rts
.endproc
