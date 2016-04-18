.include "src/globals.inc"

.import FamiToneSfxPlay
.importzp FT_SFX_CH0, FT_SFX_CH1


.export move_player, reset_player_position

.segment "CODE"
; Takes the player back to the level's start.
; Does not modify anything else, such as the gem.
; Clobbers A. Preserves X, Y.
.proc reset_player_position
    lda player_starting_x1
    sta player_x1
    clc
    adc #PLAYER_W
    sta player_x2
    lda player_starting_y1
    sta player_y1
    adc #PLAYER_H       ; Not clearing carry.
    sta player_y2
    rts
.endproc

; Changes the player's position based on 'buttons_held' input.
; Handles collisions by setting 'game_event_flags'.
; Clobbers A, X, Y. Clobbers zero-page locals.
.proc move_player
mask1 = 0
mask2 = 1
    ; Collisions with tiles are done by computing an index into the 'tiles'
    ; array, and then checking what tile is at that index.
    ; Finding 'tiles' array indexes requires combining x-position and
    ; y-position values into a single byte, using y-pos as the upper-nybble
    ; and x-pos as the lower-nybble. This is done using bitwise operations.
    ; Each movement direction requires checking two points to form an edge,
    ; thus 'mask1' and 'mask2' exist to store nybbles of the alternate
    ; components. When moving in x-directions, 'mask1' and 'mask2' will hold
    ; nybbles for y-positions, and vice-versa when moving in y-directions.

    ; So let's set mask1 and mask2 for player_y components,
    ; representing the upper-nybble of the 'tiles' array indexes.
    .repeat 2, i
        lda player_y1+i
        and #%11110000
        sta mask1+i
    .endrepeat

    ; TODO
    ;lda buttons_held
    ;and #BUTTON_A
    ;beq notA
        ;lda game_event_flags
        ;ora #EVENT_ADVANCE_LEVEL
        ;sta game_event_flags
    ;notA:

    lda buttons_held
    and #BUTTON_RIGHT
    beq notRight
    lda player_x2
    clc
    adc #1
    jsr checkXMove
    bcs notRight
    inc player_x1
    inc player_x2
notRight:

    lda buttons_held
    and #BUTTON_LEFT
    beq notLeft
    lda player_x1
    sec
    sbc #1
    dex
    jsr checkXMove
    bcs notLeft
    dec player_x1
    dec player_x2
notLeft:

    ; Now that we're done with moving in the x-direction, set mask1 and mask2
    ; for player_x components, representing the lower-nybble of the 'tiles'
    ; array indexes.
    .repeat 2, i
        lda player_x1+i
        .repeat 4
            lsr
        .endrepeat
        sta mask1+i
    .endrepeat

    lda buttons_held
    and #BUTTON_DOWN
    beq notDown
    lda player_y2
    clc
    adc #1
    jsr checkYMove
    bcs notDown
    inc player_y1
    inc player_y2
notDown:

    lda buttons_held
    and #BUTTON_UP
    beq notUp
    lda player_y1
    sec
    sbc #1
    jsr checkYMove
    bcs notUp
    dec player_y1
    dec player_y2
notUp:

    ; Finally, check collisions with other objects.
    jsr player_check_enemies
    jsr player_check_gem
    rts

; CheckXMove: Combines the x-position in A with mask1 and mask2 to do
;             collision-with-tile checks. Returns with carry cleared if
;             there are no collisions. Returns with carry set when colliding
;             with walls. Does not return otherwise; it handles other tile
;             collisions on its own and then returns from move_player.
; CheckYMove: Same as XheckXMove, except with x-pos and y-pos swapped.
; Clobbers A, X, Y.
checkYMove:
    and #%11110000      ; Get upper-nybble of a 'tiles' array index.
    tay                 ; Temporarily store it in Y.
    jmp checkMove
checkXMove:
    .repeat 4
        lsr             ; Get the lower-nybble of a 'tiles' array index.
    .endrepeat
    tay                 ; Temporarily store it in Y.
checkMove:
    ; Combine the nybbles together twice, forming two 'tiles' array indices.
    ora mask1
    tax
    tya
    ora mask2
    tay
    ; Ok: X register contains the first 'tiles' array index,
    ; and Y register contains the second.
    ; Now get the tiles at those indices and OR them together.
    ; This allows handling of both points at once.
    lda tiles,x
    ora tiles,y

    ; Use a series of >= checks to check for collisions.
    ; This works because TILE_WALL_START > TILE_BEAR_START > TILE_EXIT_START.
    ; We're using >= instead of AND because cmp doesn't modify A, while AND
    ; does.
    cmp #TILE_WALL_START
    bcc notWall
    rts
notWall:
    cmp #TILE_BEAR_START
    bcc notBear
    pla                 ; Pop the return address and throw it away.
    pla
    lda game_event_flags
    ora #EVENT_KILL_PLAYER
    sta game_event_flags
    rts
notBear:
    cmp #TILE_EXIT_START
    bcs isExit
    rts ; No collisions; return with carry clear.
isExit:
    lda gem_visible     ; Can only exit level when the gem has been collected.
    beq canExit
    clc ; No collisions after all; return with carry clear.
    rts
canExit:
    pla                 ; Pop the return address and throw it away.
    pla
    lda game_event_flags
    ora #EVENT_ADVANCE_LEVEL
    sta game_event_flags
    rts
.endproc

; Checks enemies for collisions and sets 'game_event_flags' when that happens.
; Clobbers A, X. Preserves Y.
.proc player_check_enemies
    ldx num_enemies
enemyLoop:
    dex
    cpx #$FF
    beq endLoop

    ; Four >= comparisons must be true for a collision to happen.
    ; If any are false then the collision is impossible.

    ; Enemies are always 16x16; there is no ENEMY_W or ENEMY_H.
    
    lda enemies_x1,x
    sec
    sbc #1              ; Have to subtract 1 to turn >= into >.
    cmp player_x2
    bcs enemyLoop
    adc #15 + 1         ; Carry is guaranteed to be clear.
    cmp player_x1
    bcc enemyLoop
    lda enemies_y1,x
    sbc #1              ; Carry is guaranteed to be set.
    cmp player_y2
    bcs enemyLoop
    adc #15 + 1         ; Carry is guaranteed to be clear.
    cmp player_y1
    bcc enemyLoop

    ; Collision detected! Handle it.
    lda game_event_flags
    ora #EVENT_KILL_PLAYER
    sta game_event_flags
endLoop:
    rts
.endproc

; Checks the gem for collisions and makes it invisible when that happens.
.proc player_check_gem
    lda gem_visible
    beq noCollision

    lda gem_x1
    clc
    adc #GEM_W/2
    cmp player_x1
    bcc noCollision
    sbc #GEM_W          ; Carry is guaranteed to be set.
    cmp player_x2
    bcs noCollision
    lda gem_y1
    adc #GEM_H/2        ; Carry is guaranteed to be clear.
    cmp player_y1
    bcc noCollision
    sbc #GEM_H          ; Carry is guaranteed to be set.
    cmp player_y2
    bcs noCollision

    ; Collision detected! Handle it by turning gem invisible.
    lda #0
    sta gem_visible

    lda #1
    ldx #FT_SFX_CH1
    jsr FamiToneSfxPlay
noCollision:
    rts
.endproc

