.include "src/globals.inc"

.import FT_TEMPO_ACC_L
.export prepare_blank_sprites, prepare_game_sprites, ppu_set_sprites

; This is the CPU's copy of the PPU's OAM memory.
; Write sprites to this location and copy them over to the PPU using OAMDMA.
; Note that the configuration file passed to CA65 (nrom128.cfg) reserves
; this space for us so we don't have to use .res or anything like that.
CPU_OAM = $0200

; This clears all of the sprites in CPU_OAM. Does not write to PPU.
; Clobbers A, X. Preserves Y.
.proc prepare_blank_sprites
    ldx #0
    jsr clear_remaining_cpu_oam
    rts
.endproc

; This writes sprite data to CPU_OAM. Does not write to PPU.
; Clobbers A, X, Y.
.proc prepare_game_sprites
    ; Use X as an index into CPU_OAM. The 'prepare_sprite' functions will
    ; use and increment X as they write to 'CPU_OAM'.
    ldx #0

    ; Now it's time to write to CPU_OAM.

    ; There's a depth-effect going on with player and gem sprites.
    ; The gem gets drawn on top of the player when it's below him,
    ; otherwise it gets drawn behind him.
    lda gem_y1
    cmp player_y2
    bcs gemInForeground
; Gem in background
    jsr prepare_player_sprites
    jsr prepare_gem_sprite
    jmp donePreparingGemAndPlayerSprites
gemInForeground:
    jsr prepare_gem_sprite
    jsr prepare_player_sprites
donePreparingGemAndPlayerSprites:

    jsr prepare_enemy_sprites
    jsr prepare_gem_shadow_sprite ; Draw the gem's shadow beneath enemies.

    ; Now clear the remaining portion of CPU_OAM so that unused/glitchy
    ; sprites aren't drawn.
    jsr clear_remaining_cpu_oam
    rts
.endproc

; Clears CPU_OAM (hides sprites) from X to $FF.
; Clobbers A, X. Preserves Y.
.proc clear_remaining_cpu_oam
    lda #$FF
clearOAMLoop:
    sta CPU_OAM,x
    .repeat 4
      inx
    .endrepeat
    bne clearOAMLoop    ; OAM is 256 bytes. Overflow signifies completion.
    rts
.endproc

; Copies CPU_OAM from main RAM to the PPU.
; Clobbers A. Preserves X, Y.
.proc ppu_set_sprites
    lda #0               ; Write a 0 as the offset into the OAM array.
    sta OAMADDR          ; (Meaning sprite 0 is at CPU_OAM+0)
    lda #.hibyte(CPU_OAM); Start the copy by writing the hibyte of CPU_OAM to
    sta OAMDMA           ; OAMDMA. (The lo-byte is implied to be $00.)
    rts
.endproc

; Clobbers A. Preserves Y. Increments X by 4 per sprite drawn.
.proc prepare_gem_sprite
    lda gem_visible     ; Only draw the gem when it is visible.
    bne doDraw
    rts
doDraw:
    lda gem_y1
    clc
    adc #GEM_SPRITE_Y_OFFSET
    sta CPU_OAM,x       ; Set sprite's y-position.
    ; Create animation by alternating frames using 'movement_ticks'.
    lda movement_ticks
    asl
    asl
    cmp #%10000000
    lda #GEM_SPRITE_PATTERN
    adc #0              ; Use the carry bit that was set with cmp.
    asl                 ; Have to shift left cause we're using 8x16.
    sta CPU_OAM+1,x     ; Set sprite's pattern.
    lda #GEM_SPRITE_PALETTE
    sta CPU_OAM+2,x     ; Set sprite's attributes.
    lda gem_x1
    clc
    adc #GEM_SPRITE_X_OFFSET
    sta CPU_OAM+3,x     ; Set sprite's x-position.
    .repeat 4
        inx
    .endrepeat
    rts
.endproc

; Clobbers A. Preserves Y. Increments X by 4 per sprite drawn.
.proc prepare_gem_shadow_sprite
    lda gem_visible     ; Only draw the gem's shadow when it is visible.
    bne doDraw
    rts
doDraw:
    lda gem_y1
    clc
    adc #GEM_SPRITE_Y_OFFSET
    sta CPU_OAM,x       ; Set sprite's y-position.
    lda #GEM_SHADOW_SPRITE_PATTERN << 1
    sta CPU_OAM+1,x     ; Set sprite's pattern.
    lda #GEM_SHADOW_SPRITE_PALETTE
    sta CPU_OAM+2,x     ; Set sprite's attributes.
    lda gem_x1
    clc
    adc #GEM_SPRITE_X_OFFSET
    sta CPU_OAM+3,x     ; Set sprite's x-position.
    .repeat 4
        inx
    .endrepeat
    rts
.endproc

; Clobbers A. Preserves Y. Increments X by 4 per sprite drawn.
.proc prepare_player_sprites
    ;lda animation_ticks
    ;clc
    ;adc #1
    ;cmp #40
    ;bcc setTicks
    ;lda #0
setTicks:
    ;sta animation_ticks

    .repeat 2, i        ; A 16x16 meta-sprite is made of two 8x16 sprites.
    .scope 
        lda player_y1
        clc
        adc #PLAYER_SPRITE_Y_OFFSET
        sta CPU_OAM,x   ; Set sprite's y-position.
        ; Determine player's pattern based on whether or not he's dead.
        lda game_event_flags
        and #EVENT_KILL_PLAYER
        beq notDeathSprite
    ; Death sprite:
        lda #(PLAYER_DEATH_SPRITE_PATTERN+i) << 1
        jmp setPattern
    notDeathSprite:
        lda animation_ticks
        and #%00000010
        beq frame2
        lda #(PLAYER_SPRITE_PATTERN1+i) << 1
        jmp setPattern
frame2:
        lda #(PLAYER_SPRITE_PATTERN2+i) << 1
    setPattern:
        sta CPU_OAM+1,x ; Set sprite's pattern.
        lda #PLAYER_SPRITE_PALETTE
        sta CPU_OAM+2,x ; Set sprite's attributes.
        lda player_x1
        clc
        adc #(8*i)+PLAYER_SPRITE_X_OFFSET
        sta CPU_OAM+3,x ; Set sprite's x-position.
        .repeat 4
            inx
        .endrepeat
    .endscope
    .endrepeat
    rts
.endproc

; Clobbers A, Y. Increments X by 4 per sprite drawn.
.proc prepare_enemy_sprites
    ldy num_enemies
    bne enemyLoop
    rts
enemyLoop:
    .repeat 2, i        ; A 16x16 meta-sprite is made of two 8x16 sprites.
        lda enemies_y1-1,y
        clc
        adc #ENEMY_SPRITE_Y_OFFSET
        sta CPU_OAM,x   ; Set sprite's y-position.
        lda #(ENEMY_SPRITE_PATTERN + i) << 1
        sta CPU_OAM+1,x ; Set sprite's pattern.
        lda #ENEMY_SPRITE_PALETTE
        sta CPU_OAM+2,x ; Set sprite's attributes.
        lda enemies_x1-1,y
        clc
        adc #8*i+ENEMY_SPRITE_X_OFFSET
        sta CPU_OAM+3,x ; Set sprite's x-position.
        .repeat 4
            inx
        .endrepeat
    .endrepeat
    dey
    bne enemyLoop
    rts
.endproc

