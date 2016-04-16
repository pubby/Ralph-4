.include "src/globals.inc"

.export ppu_set_palette

.segment "RODATA"
palette:
    .byt $22,$01,$22,$30, $0F,$08,$19,$2A, $0F,$08,$17,$26, $0F,$0F,$19,$28
    .byt $22,$03,$11,$36, $0F,$08,$17,$36, $0F,$01,$2C,$30, $0F,$02,$12,$22

.segment "CODE"
; Set palette_dim and palette_bg_color before calling.
; Clobbers A, X. Preserves Y.
.proc ppu_set_palette
    ppu_palette_address = $3F00
    lda #.hibyte(ppu_palette_address)
    sta PPUADDR
    lda #.lobyte(ppu_palette_address)
    sta PPUADDR
    ldx #0
copyPaletteLoop:
    lda palette,x
    sec
    sbc palette_dim
    bcs doStore
    lda #$0F
doStore:
    sta PPUDATA
    inx
    cpx #32
    bne copyPaletteLoop

    ; Write the bg color.
    ; (This is a stupid hack to allow using only 1 palette in RODATA.)
    lda #.hibyte(ppu_palette_address)
    sta PPUADDR
    lda #.lobyte(ppu_palette_address)
    sta PPUADDR
    lda palette_bg_color
    sec
    sbc palette_dim
    bcs doStoreBG
    lda #$0F
doStoreBG:
    sta PPUDATA

    rts
.endproc

