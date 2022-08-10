.include "globals.inc"

.export move_enemies

; Explanation of enemies_attr:
; aabbccdd (bits)
; aa: Movement type. 00=bouncey, 01=circular, 10=unused, 11=unused
; If bouncy: 
;   bb: Turn increment. When enemy hits a wall: cc += bb.
;   cc: Current direction. 00=right, 01=down, 10=left, 11=up.
;   dd: Speed.
; If circular: 
;   bb: Start at top/bottom
;   cc: Inverse radius.
;   dd: Speed.

.segment "CODE"
; Moves all enemies and updates their attributes when they collide with walls.
; Does not check for collisions with the player. See player.s for that.
; Clobbers A, X, Y. Clobbers zero page locals.
.proc move_enemies
    ldx num_enemies
    beq doneMoveAll
enemyLoop:
    dex
    lda enemies_attr,x
    and #%11000000
    bne notBounceMovement
    jsr enemy_bouncey_movement
    jmp doneMove1
notBounceMovement:
    jsr enemy_circular_movement
doneMove1:
    cpx #0
    bne enemyLoop
doneMoveAll:
    rts
.endproc

; Clobbers A, Y. Preserves X. Clobbers zero-page locals.
.proc enemy_bouncey_movement
x_nybble  = 0
y_nybble  = 1
new_dir = 2
speed = 3
new_x_value = 4
new_y_value = 4
    ; Store the speed.
    ; The number of pixels the enemy will move is 'speed' + 1.
    lda enemies_attr,x
    and #%00000011
    sta speed

    ; Enemy collision detection with walls is very similiar to how it works 
    ; in player.s, albeit simpler. With the player, two points are checked
    ; per direction, but enemies only check a single point, as they will
    ; always be aligned to one axis of the 16x16 grid.
    ; In player.s, mask1 and mask2 held nybbles of a 'tiles' array index,
    ; but in enemies.s, x_nybble and y_nybble do that job instead.

repeatMove:
    ; Set x_nybble and y_nybble.
    lda enemies_x1,x
    .repeat 4
        lsr
    .endrepeat
    sta x_nybble
    lda enemies_y1,x
    and #%11110000
    sta y_nybble

    lda enemies_attr,x
    and #%00001100
    cmp #%00000000
    bne notRight
; Move right:
    lda enemies_x1,x
    sec                 ; Set carry so that value is 'speed' + 1
    adc speed
    sta new_x_value
    adc #15             ; Adjust for right-side of sprite.
    jsr checkXMove
    lda new_x_value
    sta enemies_x1,x
    rts
notRight:
    cmp #%00000100
    bne notDown
; Move down:
    lda enemies_y1,x
    sec                 ; Set carry so that value is 'speed' + 1.
    adc speed
    sta new_y_value
    adc #15
    jsr checkYMove
    lda new_y_value
    sta enemies_y1,x
    rts
notDown:
    cmp #%00001000
    bne notLeft
; Move left:
    lda enemies_x1,x
    clc                 ; Clear carry so that value is 'speed' - 1.
    sbc speed
    sta new_x_value
    jsr checkXMove
    lda new_x_value
    sta enemies_x1,x
    rts
notLeft:
; Move up:
    lda enemies_y1,x
    clc                 ; Clear carry so that value is 'speed' - 1.
    sbc speed
    sta new_y_value
    jsr checkYMove
    lda new_y_value
    sta enemies_y1,x
    ; And that's it.
    rts

; CheckXMove: Combines the x-position in A with y_nybble to do
;             collision-with-wall checks. Handles collisions if they occur,
;             returns otherwise.
; CheckYMove: Same as XheckXMove, except with x-pos and y-pos swapped.
; Clobbers A, Y. Preserves X.
checkXMove:
    .repeat 4
        lsr
    .endrepeat
    ora y_nybble
    jmp checkTile
checkYMove:
    and #%11110000
    ora x_nybble
checkTile:
    tay
    lda tiles,y
    cmp #TILE_WALL_START
    bcs doCollision
    rts
doCollision:
    pla                 ; Pop the return address and throw it away.
    pla
    ; Change direction.
    lda enemies_attr,x
    and #%00110000
    lsr
    lsr
    clc
    adc enemies_attr,x
    and #%00001100
    sta new_dir
    lda enemies_attr,x
    and #%11110011
    ora new_dir
    sta enemies_attr,x
    ; Attempt to move again after the direction was changed.
    ; Enemies can't pause for a frame cause that would throw off their timing,
    ; so they have to attempt to move after determining collision.
    ; Note that this can lead to an infinite loop when the enemy is between
    ; two walls, but with proper level design that should never happen.
    jmp repeatMove
.endproc

; Circular movement is done using trig functions and the global timer called
; 'movement_ticks'.
; Clobbers A, Y. Preserves X. Clobbers zero page locals.
.proc enemy_circular_movement
inverse_radius = 0
ticks_offset = 1
sin_table_index = 2

    ; Start off by extracting the attributes.
    lda enemies_attr,x
    and #%00001100
    .repeat 2
        lsr
    .endrepeat
    sta inverse_radius

    lda enemies_attr,x
    and #%00110000
    asl
    asl
    sta ticks_offset

    ; Use the speed attribute to shift movement_ticks to the left 1 place
    ; for each speed value.
    lda enemies_attr,x
    and #%00000011
    tay                 ; Use y to iterate through the speed values.
    lda movement_ticks
    cpy #0
    beq doneIncreaseSpeed
increaseSpeedLoop:
    asl
    dey
    bne increaseSpeedLoop
doneIncreaseSpeed:
    ; A now holds the updated movement_ticks.
    ; Update it even further by adding ticks_offset, modifying the starting
    ; angle of the enemy's circular path.
    clc
    adc ticks_offset
    sta sin_table_index
    tay                 ; Y now holds sin_table_index.

    lda sin_table,y
    ldy inverse_radius  ; And now Y holds the inverse_radius.
    beq doneReduceSinLoop
reduceSinLoop:
    cmp #$80            ; Allows dividing by 2 using ror, preserving the sign.
    ror
    dey
    bne reduceSinLoop
doneReduceSinLoop:
    ; Update the y-position.
    clc
    adc enemies_starting_y1,x
    sta enemies_y1,x

    ; Turn sin_table_index into an index that uses the table for cosine.
    ; sin(x) = -cos(x+pi/2), and this is doing the same thing.
    lda sin_table_index
    clc
    adc #256 / 4
    tay

    lda sin_table,y
    ldy inverse_radius
    beq doneReduceCosLoop
reduceCosLoop:
    cmp #$80            ; Allows dividing by 2 using ror, preserving the sign.
    ror
    dey
    bne reduceCosLoop
doneReduceCosLoop:
    ; Update the x-position.
    clc
    adc enemies_starting_x1,x
    sta enemies_x1,x

    rts
.endproc

