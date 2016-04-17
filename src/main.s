.include "src/globals.inc"

.import read_gamepad
.import prepare_blank_sprites, prepare_game_sprites, ppu_set_sprites
.import ppu_set_title_bg, ppu_set_game_bg , ppu_set_ending_bg
.import ppu_set_results_bg, ppu_set_timer_display
.import move_player, reset_player_position
.import move_enemies
.import load_level
.import ppu_set_palette

.import FamiToneInit
.import FamiToneSfxInit
.import FamiToneMusicPlay
.import FamiToneUpdate
.import FamiToneSfxPlay
.importzp FT_SFX_CH0, FT_SFX_CH1
.importzp FT_SFX_CH2, FT_SFX_CH3
.import ralph4_music_music_data
.import sounds

.export main, nmi_handler, irq_handler

.segment "ZEROPAGE"
nmi_counter:    .res 1  ; Spin on this until vblank.

.segment "CODE"

; X should be set to 0.
; Carry should be set.
; Guarantees that carry will be set if not jumping to doneLabel.
.macro increment_digit var, modulo, doneLabel
    lda var
    adc #0
    sta var
    cmp #modulo
    bcc doneLabel
    stx var
.endmacro

.proc nmi_handler
    ; Push registers to the stack.
    php
    pha
    txa
    pha
    tya
    pha

    ; Rememeber: none of the functions called in the nmi handler
    ; can clobber zero page locals.

    lda do_draw
    cmp #1
    bcc dontDraw

    lda using_timer
    cmp #1
    bcc dontDisplayTimer
    jsr ppu_set_timer_display
dontDisplayTimer:

    jsr ppu_set_palette
    jsr ppu_set_sprites

    ; Update PPU registers.
    lda PPUSTATUS       ; Clear the vblank flag before writing PPUCTRL.
    lda #PPUCTRL_BG_PT_1000 | PPUCTRL_8X16_SPR | PPUCTRL_NMI_ON
    sta PPUCTRL
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL
    lda #PPUMASK_SPR_ON | PPUMASK_BG_ON | PPUMASK_NO_BG_CLIP
    sta PPUMASK
dontDraw:
    jsr FamiToneUpdate
    inc nmi_counter

    lda using_timer
    cmp #1
    bcc doneUpdatingGameTimer
    inc frame_counter
    lda #60
    cmp frame_counter
    bne doneUpdatingGameTimer
    ; Increment the timer by 1 second.
    ldx #0    ; X has to be 0 before using increment_digit.
    stx frame_counter
    sec       ; Carry has to be set before using increment_digit.
    increment_digit seconds_digits+1, 10, doneUpdatingGameTimer
    increment_digit seconds_digits+0,  6, doneUpdatingGameTimer
    increment_digit minutes_digits+1, 10, doneUpdatingGameTimer
    increment_digit minutes_digits+0,  6, doneUpdatingGameTimer
    last_i = ::NUM_HOURS_DIGITS-1
    .repeat ::NUM_HOURS_DIGITS, i
        increment_digit hours_digits+last_i-i, 10, doneUpdatingGameTimer
    .endrepeat
doneUpdatingGameTimer:
    ; Restore registers and return.
    pla
    tay
    pla
    tax
    pla
    plp
    rti
.endproc

.proc irq_handler
    rti
.endproc

.macro wait_for_nmi frames_to_wait
    .local nmiLoop
    lda nmi_counter
    .if frames_to_wait > 1
        clc
        adc #frames_to_wait-1
    nmiLoop:
        cmp nmi_counter
        bne nmiLoop
    .else
    nmiLoop:
        cmp nmi_counter
        beq nmiLoop
    .endif
.endmacro

.proc main
titleScreen:
    lda #0
    sta do_draw
    sta using_timer
    sta buttons_pressed
    sta buttons_held
    sta palette_dim

    ; Set the palette while we're still in the safe part of vblank.
    lda #INTRO_BG_COLOR
    sta palette_bg_color
    jsr ppu_set_palette
    
    ; Clear sprites.
    jsr prepare_blank_sprites
    jsr ppu_set_sprites

    ; Load the title screen and enable NMI.
    jsr ppu_set_title_bg
    lda PPUSTATUS       ; Clear the vblank flag before writing PPUCTRL.
    lda #PPUCTRL_SPR_PT_1000 | PPUCTRL_8X16_SPR | PPUCTRL_NMI_ON
    sta PPUCTRL

    ; Init FamiTone2 while waiting for the next frame.
    lda #1              ; A = 0 for PAL. A > 0 for NTSC.
    ldx #<ralph4_music_music_data
    ldy #>ralph4_music_music_data
    jsr FamiToneInit

    ldx #<sounds
    ldy #>sounds
    jsr FamiToneSfxInit

    lda #1
    sta do_draw
titleScreenLoop:
    jsr read_gamepad    ; Read the gamepad so that we can check for the
    lda buttons_pressed ; start button, signifying the start of the game.
    and #BUTTON_START
    bne startGame

    wait_for_nmi
    jmp titleScreenLoop
startGame:
    jsr fade_out

    lda #1
    jsr FamiToneMusicPlay

    lda #1
    sta using_timer

    lda #GAME_BG_COLOR
    sta palette_bg_color

    lda #0
    sta animation_ticks
    ; Set digit counters to 0
    .repeat ::NUM_DEATHS_DIGITS, i
        sta deaths_digits+i
    .endrepeat
    .repeat ::NUM_SECONDS_DIGITS, i
        sta seconds_digits+i
    .endrepeat
    .repeat ::NUM_MINUTES_DIGITS, i
        sta minutes_digits+i
    .endrepeat
    .repeat ::NUM_HOURS_DIGITS, i
        sta hours_digits+i
    .endrepeat

    ; Initialize 'current_level' and load the first level.
    ; A should be 0.
    sta current_level
    jsr load_level
    jsr ppu_set_game_bg

    jsr fade_in
gameLoop:
    ; Reset 'game_event_flags' at the start of every frame.
    lda #0
    sta game_event_flags

    inc movement_ticks

    jsr read_gamepad
    jsr move_player
    jsr move_enemies

    jsr prepare_game_sprites

    ; Check 'game_event_flags'.
    lda game_event_flags
    and #EVENT_KILL_PLAYER
    beq notKillingPlayer
    jsr do_kill_player
    jmp gameLoop
notKillingPlayer:
    lda game_event_flags
    and #EVENT_ADVANCE_LEVEL
    beq notAdvancingLevel
    ; Check if we've completed the last level.
    lda current_level
    cmp #num_levels - 1
    beq endingScreen            ; Go to the ending screen if we did.
    jsr do_advance_level        ; Otherwise go to the next level.
    jmp gameLoop
notAdvancingLevel:
    ; No events, so nothing fancy is going on with this frame.
    wait_for_nmi
    jmp gameLoop

endingScreen:
    wait_for_nmi
    jsr fade_out

    lda #0
    jsr FamiToneMusicPlay

    lda #0              ; Disable the timer so it doesn't increment.
    sta using_timer

    lda #ENDING_BG_COLOR
    sta palette_bg_color

    jsr prepare_blank_sprites
    jsr ppu_set_sprites
    jsr ppu_set_ending_bg

    jsr fade_in
endingScreenLoop:
    jsr read_gamepad
    lda buttons_pressed
    and #BUTTON_START
    bne resultsScreen

    wait_for_nmi
    jmp endingScreenLoop

resultsScreen:
    wait_for_nmi
    jsr fade_out
    jsr ppu_set_results_bg
    jsr fade_in
resultsScreenLoop:
    jsr read_gamepad
    lda buttons_pressed
    and #BUTTON_START
    bne restartGame

    wait_for_nmi
    jmp resultsScreenLoop

restartGame:
    wait_for_nmi
    jmp startGame
.endproc

; Call at the start of vblank. Returns in vblank.
; Clobbers A. Probably clobbers X, Y.
.proc fade_out
    .repeat 4, i
        lda #$10*(i+1)
        sta palette_dim
        wait_for_nmi 4
    .endrepeat
    lda #0              
    sta PPUMASK         ; Disable rendering; force vblank.
    sta do_draw
    rts
.endproc

; Call at the start of vblank. Returns in vblank.
; Clobbers A, X. Probably Y.
.proc fade_in
    lda #1
    sta do_draw
    .repeat 5, i
        lda #$10*(4-i)
        sta palette_dim
        wait_for_nmi 3
    .endrepeat
    rts
.endproc

.proc do_kill_player
    lda #1
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay

    wait_for_nmi
    lda #GAME_DEATH_BG_COLOR
    sta palette_bg_color

    ; Increment the deaths counter.
    ; If it gets to 10000 then it overflows to 0. Hurrah!
    ldx #0    ; X has to be 0 before using increment_digit.
    sec       ; Carry has to be set before using increment_digit.
    last_i = ::NUM_DEATHS_DIGITS-1
    .repeat ::NUM_DEATHS_DIGITS, i
        increment_digit deaths_digits+last_i-i, 10, doneIncrementDeaths
    .endrepeat
doneIncrementDeaths:

    ; Reset the player and gem positions now, but don't update their sprites.
    jsr reset_player_position
    lda gem_starting_visible
    sta gem_visible

    wait_for_nmi 20
    lda #GAME_BG_COLOR
    sta palette_bg_color
    rts
.endproc

.proc do_advance_level
    wait_for_nmi
    jsr fade_out

    lda #0              
    sta PPUMASK         ; Disable rendering; force vblank.
    sta do_draw

    inc current_level
    lda current_level
    jsr load_level

    lda #0
    sta movement_ticks

    jsr move_enemies

    jsr ppu_set_game_bg
    jsr prepare_game_sprites

    wait_for_nmi 8
    jsr fade_in

    rts
.endproc

.segment "CHR"
    .incbin "obj/nes/sprites16.chr"
    .incbin "obj/nes/bg.chr"
