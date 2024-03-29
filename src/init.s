.include "globals.inc"

.import FT_BASE_ADR, main

.export reset_handler

.segment "CODE"
; Init code.
; (See http://wiki.nesdev.com/w/index.php/Init_code )
.proc reset_handler
    ; Ignore IRQs.
    sei

    ; Disable NMI and rendering.
    lda #$00
    sta PPUCTRL
    sta PPUMASK

    ; Disable DMC IRQ.
    sta $4010

    ; Read the status registers to handle stray NMIs and DMC IRQs across
    ; resets.
    lda PPUSTATUS
    lda SNDCHN

    ; Disable APU frame counter IRQ.
    ; (See http://wiki.nesdev.com/w/index.php/APU_Frame_Counter )
    lda #%01000000
    sta $4017

    ; Disable DMC but initialize the other channels.
    lda #$0F
    sta SNDCHN
    
    ; Turn off decimal mode, just in case the game gets run on wonky hardware.
    cld

    ; Set the stack pointer.
    ldx #$FF
    txs

    ; Now wait two frames until the PPU stabilizes.
    ; Can't use NMI yet, so we'll spin on bit 7 of PPUSTATUS to determine
    ; when those frames pass.
waitFrame1:
    bit PPUSTATUS
    bpl waitFrame1

    ; FamiTone expects its memory to be cleared.
    lda #0
    ldx #0
clearRAM:
    sta FT_BASE_ADR,x
    inx
    bne clearRAM

waitFrame2:
    bit PPUSTATUS
    bpl waitFrame2

    ; NTSC/PAL detection code by tokumaru.
    ; (See http://forums.nesdev.com/viewtopic.php?f=2&t=12350 )

    ; Wait for the next NTSC vertical blank (PAL and Dendy would take longer)
    ldx #$70
:   ldy #$35
:   dey
    bne :-
    dex
    bne :--

    ;detect whether the frame rate is 60Hz or 50Hz
    lda PPUSTATUS
    and #%10000000
    sta framerate_60

    ; Ok! Everything is initialized and we'll jump to 'main' at the start
    ; of vblank.
    jmp main
.endproc
