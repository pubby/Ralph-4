.export ralph4_music_music_data
;this file for FamiTone2 library generated by text2data tool

ralph4_music_music_data:
	.byte 3
	.word @instruments
	.word @samples-3
	.word @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4,307,256
	.word @song1ch0,@song1ch1,@song1ch2,@song1ch3,@song1ch4,307,256
	.word @song2ch0,@song2ch1,@song2ch2,@song2ch3,@song2ch4,307,256

@instruments:
	.byte $30 ;instrument $00
	.word @env1,@env12,@env0
	.byte $00
	.byte $30 ;instrument $01
	.word @env2,@env13,@env0
	.byte $00
	.byte $30 ;instrument $02
	.word @env3,@env14,@env0
	.byte $00
	.byte $30 ;instrument $03
	.word @env4,@env14,@env0
	.byte $00
	.byte $30 ;instrument $04
	.word @env5,@env0,@env0
	.byte $00
	.byte $70 ;instrument $05
	.word @env6,@env0,@env20
	.byte $00
	.byte $70 ;instrument $06
	.word @env7,@env0,@env0
	.byte $00
	.byte $b0 ;instrument $07
	.word @env8,@env0,@env0
	.byte $00
	.byte $b0 ;instrument $08
	.word @env9,@env18,@env21
	.byte $00
	.byte $30 ;instrument $09
	.word @env10,@env15,@env0
	.byte $00
	.byte $30 ;instrument $0a
	.word @env10,@env16,@env0
	.byte $00
	.byte $30 ;instrument $0b
	.word @env10,@env17,@env0
	.byte $00
	.byte $b0 ;instrument $0c
	.word @env7,@env18,@env0
	.byte $00
	.byte $b0 ;instrument $0d
	.word @env7,@env0,@env0
	.byte $00
	.byte $30 ;instrument $0f
	.word @env11,@env19,@env0
	.byte $00
	.byte $30 ;instrument $10
	.word @env11,@env16,@env0
	.byte $00
	.byte $30 ;instrument $11
	.word @env11,@env17,@env0
	.byte $00

@samples:
@env0:
	.byte $c0,$00,$00
@env1:
	.byte $c0,$cf,$cf,$c3,$c2,$c0,$00,$05
@env2:
	.byte $c0,$cf,$cb,$c9,$c6,$c5,$c5,$c4,$02,$c3,$02,$c2,$02,$c1,$c0,$00
	.byte $0e
@env3:
	.byte $c0,$c6,$c3,$c0,$00,$03
@env4:
	.byte $c0,$c8,$c4,$05,$c3,$05,$c2,$05,$c1,$05,$c0,$00,$0a
@env5:
	.byte $c0,$cf,$00,$01
@env6:
	.byte $c0,$c6,$c9,$c8,$00,$03
@env7:
	.byte $c0,$c2,$00,$01
@env8:
	.byte $c0,$ca,$c7,$c6,$03,$c3,$c1,$c0,$00,$07
@env9:
	.byte $c0,$c9,$cb,$cb,$ca,$c9,$c7,$c5,$c5,$c6,$c7,$c8,$00,$0b
@env10:
	.byte $c0,$ca,$c9,$c7,$c7,$c6,$04,$c4,$02,$c3,$02,$c2,$c1,$00,$0c
@env11:
	.byte $c0,$c6,$06,$c5,$0c,$c4,$0d,$c3,$0c,$c2,$00,$09
@env12:
	.byte $c0,$c3,$c0,$c0,$00,$03
@env13:
	.byte $c0,$c5,$c1,$c0,$c9,$00,$04
@env14:
	.byte $c0,$c0,$c1,$00,$02
@env15:
	.byte $c0,$c0,$c6,$c6,$c3,$c3,$00,$00
@env16:
	.byte $c0,$c0,$c7,$c7,$c4,$c4,$00,$00
@env17:
	.byte $c0,$c0,$c8,$c8,$c3,$c3,$00,$00
@env18:
	.byte $c0,$bd,$bf,$c0,$00,$03
@env19:
	.byte $c0,$c0,$c7,$c7,$c3,$c3,$00,$00
@env20:
	.byte $d4,$ca,$c0,$09,$bf,$be,$bf,$c0,$c1,$c2,$c1,$c0,$00,$04
@env21:
	.byte $c0,$0f,$c1,$c3,$c1,$c0,$bf,$bd,$bf,$c0,$00,$02


@song0ch0:
	.byte $fb,$0c
@song0ch0loop:
@ref0:
	.byte $9e,$3e,$8d,$a0,$3c,$8d
@ref1:
	.byte $9c,$38,$9d
@ref2:
	.byte $a0,$38,$9d
@ref3:
	.byte $9e,$34,$9d
@ref4:
	.byte $9c,$38,$8d,$2e,$8d
@ref5:
	.byte $9e,$30,$9d
@ref6:
	.byte $a0,$2e,$8d,$9c,$2e,$8d
@ref7:
	.byte $9e,$30,$9d
	.byte $fd
	.word @song0ch0loop

@song0ch1:
@song0ch1loop:
@ref8:
	.byte $90,$56,$83,$64,$98,$56,$90,$64,$98,$64,$90,$61,$5e,$98,$5e,$90
	.byte $5b,$5e,$60,$5e
@ref9:
	.byte $81,$5a,$56,$98,$56,$90,$56,$5a,$5e,$57,$56,$54,$57,$98,$56,$54
	.byte $56
@ref10:
	.byte $90,$60,$56,$5a,$69,$56,$5a,$61,$56,$5a,$69,$64,$60,$64
@ref11:
	.byte $65,$98,$64,$90,$61,$98,$60,$90,$5e,$98,$5e,$90,$5f,$60,$5a,$85
	.byte $98,$5a
@ref12:
	.byte $8a,$46,$83,$3f,$8c,$3e,$8a,$47,$46,$83,$43,$3e,$3c,$3e
@ref13:
	.byte $46,$83,$38,$91,$8c,$38,$8a,$3c,$3e
@ref14:
	.byte $3e,$83,$3e,$8c,$3e,$8a,$3e,$42,$3e,$3c,$83,$3c,$8c,$3c,$8a,$3e
	.byte $3c,$34
@ref15:
	.byte $38,$83,$46,$91,$8c,$46,$90,$46,$4c
	.byte $fd
	.word @song0ch1loop

@song0ch2:
@song0ch2loop:
@ref16:
	.byte $88,$26,$26,$3e,$27,$26,$3e,$26,$1c,$1c,$34,$1d,$1c,$34,$1c
@ref17:
	.byte $20,$20,$38,$21,$20,$38,$20,$20,$20,$38,$21,$20,$38,$20
@ref18:
	.byte $2a,$2a,$42,$2b,$2a,$42,$2a,$2a,$2a,$42,$2b,$2a,$42,$2a
@ref19:
	.byte $34,$34,$4c,$35,$34,$4c,$34,$34,$34,$4c,$34,$34,$4c,$34,$4c
@ref20:
	.byte $39,$50,$39,$38,$50,$38,$35,$4c,$35,$34,$4c,$34
@ref21:
	.byte $31,$48,$31,$30,$48,$30,$31,$48,$31,$30,$48,$30
@ref22:
	.byte $27,$3e,$27,$26,$3e,$26,$2f,$46,$2f,$2e,$46,$2e
	.byte $ff,$0c
	.word @ref21
	.byte $fd
	.word @song0ch2loop

@song0ch3:
@song0ch3loop:
@ref24:
	.byte $80,$03,$82,$04,$80,$02,$84,$18,$86,$18,$82,$04,$80,$02,$03,$82
	.byte $04,$80,$02,$84,$18,$86,$18,$82,$04,$80,$02
@ref25:
	.byte $03,$82,$04,$80,$02,$84,$18,$86,$18,$82,$04,$80,$02,$03,$82,$04
	.byte $80,$02,$84,$18,$86,$18,$82,$04,$80,$02
	.byte $ff,$0e
	.word @ref25
	.byte $ff,$0e
	.word @ref25
	.byte $ff,$0e
	.word @ref25
	.byte $ff,$0e
	.word @ref25
	.byte $ff,$0e
	.word @ref25
	.byte $ff,$0e
	.word @ref25
	.byte $fd
	.word @song0ch3loop

@song0ch4:
@song0ch4loop:
@ref32:
	.byte $9f
@ref33:
	.byte $9f
@ref34:
	.byte $9f
@ref35:
	.byte $9f
@ref36:
	.byte $9f
@ref37:
	.byte $9f
@ref38:
	.byte $9f
@ref39:
	.byte $9f
	.byte $fd
	.word @song0ch4loop


@song1ch0:
	.byte $fb,$0a
@song1ch0loop:
@ref40:
	.byte $83,$92,$41,$94,$38,$39,$38,$83,$92,$41,$94,$38,$38,$83
@ref41:
	.byte $83,$92,$41,$94,$38,$39,$38,$83,$92,$41,$94,$38,$39,$96,$38
@ref42:
	.byte $83,$39,$38,$39,$3c,$83,$3d,$3c,$3c,$83
@ref43:
	.byte $83,$92,$41,$94,$38,$39,$38,$83,$92,$41,$94,$38,$39,$38
	.byte $ff,$0a
	.word @ref40
	.byte $ff,$0a
	.word @ref41
	.byte $ff,$0a
	.word @ref42
	.byte $ff,$0a
	.word @ref43
@ref48:
	.byte $01,$98,$56,$85,$5e,$83,$5a,$87,$56,$5a
@ref49:
	.byte $56,$5a,$61,$60,$64,$68,$61,$65,$5b,$55,$56
@ref50:
	.byte $5a,$5e,$57,$57,$5a,$5f,$5b,$5b,$5a,$5e,$60
@ref51:
	.byte $64,$60,$69,$68,$65,$69,$6d,$6c,$68,$64,$5a,$81
@ref52:
	.byte $96,$40,$83,$40,$83,$41,$3c,$3d,$3d,$3c,$83
@ref53:
	.byte $40,$83,$40,$83,$40,$83,$3c,$83,$3c,$85
@ref54:
	.byte $40,$83,$40,$83,$41,$3c,$3d,$3d,$3c,$83
@ref55:
	.byte $38,$83,$38,$83,$38,$83,$3c,$83,$3c,$85
	.byte $ff,$0a
	.word @ref54
	.byte $ff,$0a
	.word @ref53
	.byte $ff,$0a
	.word @ref55
@ref59:
	.byte $40,$83,$40,$83,$40,$83,$40,$41,$40,$40,$83
	.byte $fd
	.word @song1ch0loop

@song1ch1:
@song1ch1loop:
@ref60:
	.byte $83,$8a,$4c,$8c,$4c,$8a,$4a,$4c,$8c,$4a,$8a,$47,$46,$42,$40,$87
@ref61:
	.byte $8c,$41,$8a,$4c,$8c,$4c,$8a,$4a,$4c,$8c,$4a,$8a,$59,$58,$54,$51
	.byte $58,$54,$50
@ref62:
	.byte $50,$83,$48,$83,$51,$54,$83,$4d,$46,$4c,$50
@ref63:
	.byte $50,$50,$4c,$50,$8c,$4c,$8a,$51,$8c,$50,$8a,$50,$8e,$5e,$58,$50
	.byte $58,$50,$46,$40
@ref64:
	.byte $9a,$40,$8a,$40,$4c,$8c,$4c,$8a,$4a,$4c,$8c,$4a,$8a,$47,$46,$42
	.byte $40,$87
@ref65:
	.byte $8c,$40,$8a,$4c,$58,$8c,$4c,$8a,$54,$58,$8c,$54,$8a,$5b,$58,$54
	.byte $59,$58,$54,$58
@ref66:
	.byte $50,$83,$56,$83,$61,$5a,$83,$57,$54,$50,$54
@ref67:
	.byte $58,$58,$8c,$58,$8a,$58,$8c,$58,$8a,$50,$54,$59,$8e,$58,$5e,$58
	.byte $68,$5e,$58,$50
@ref68:
	.byte $90,$56,$85,$5e,$83,$5a,$87,$56,$5a,$56,$5a
@ref69:
	.byte $61,$60,$64,$68,$61,$65,$5b,$55,$56,$5a,$5e
@ref70:
	.byte $57,$57,$5a,$5f,$5b,$5b,$5a,$5e,$60,$64,$60
@ref71:
	.byte $69,$68,$65,$69,$6d,$6c,$68,$64,$5b,$64,$81
@ref72:
	.byte $68,$68,$98,$68,$90,$5e,$68,$70,$98,$70,$90,$6c,$98,$6c,$90,$64
	.byte $98,$64,$90,$5a,$65,$5a,$81
@ref73:
	.byte $59,$98,$58,$90,$5e,$98,$5e,$90,$58,$98,$5e,$90,$5a,$8b,$98,$5a
	.byte $81
@ref74:
	.byte $90,$58,$50,$58,$5e,$98,$5e,$90,$68,$98,$5e,$90,$65,$62,$98,$64
	.byte $90,$5e,$98,$62,$90,$5b,$98,$5a
@ref75:
	.byte $90,$56,$98,$56,$90,$56,$56,$98,$56,$90,$56,$98,$56,$90,$5a,$98
	.byte $5a,$90,$64,$98,$5a,$90,$6c,$98,$64,$90,$73,$98,$72
@ref76:
	.byte $90,$70,$70,$98,$70,$90,$68,$70,$76,$98,$76,$90,$72,$98,$76,$90
	.byte $70,$98,$72,$90,$70,$6d,$68,$81
@ref77:
	.byte $69,$98,$68,$90,$5e,$68,$70,$68,$6c,$8b,$98,$6c,$81
@ref78:
	.byte $90,$69,$60,$69,$6f,$6d,$6f,$73,$76,$83
@ref79:
	.byte $70,$72,$70,$69,$6d,$68,$8d,$98,$68
	.byte $fd
	.word @song1ch1loop

@song1ch2:
@song1ch2loop:
@ref80:
	.byte $88,$38,$38,$00,$2a,$2e,$34,$00,$38,$00,$38,$00,$38,$2a,$2e,$34
	.byte $2e
@ref81:
	.byte $38,$38,$00,$2a,$2e,$34,$00,$38,$00,$38,$00,$38,$2a,$2e,$34,$2e
@ref82:
	.byte $30,$30,$00,$30,$3e,$30,$00,$35,$34,$2a,$34,$00,$2a,$2e,$34
	.byte $ff,$10
	.word @ref81
	.byte $ff,$10
	.word @ref81
	.byte $ff,$10
	.word @ref81
	.byte $ff,$0f
	.word @ref82
	.byte $ff,$10
	.word @ref81
	.byte $ff,$0f
	.word @ref82
	.byte $ff,$0f
	.word @ref82
	.byte $ff,$0f
	.word @ref82
	.byte $ff,$0f
	.word @ref82
	.byte $ff,$10
	.word @ref81
	.byte $ff,$10
	.word @ref81
	.byte $ff,$10
	.word @ref81
@ref95:
	.byte $30,$30,$00,$26,$30,$30,$00,$34,$00,$34,$00,$26,$2a,$2e,$34,$2e
	.byte $ff,$10
	.word @ref81
	.byte $ff,$10
	.word @ref81
	.byte $ff,$10
	.word @ref95
	.byte $ff,$10
	.word @ref81
	.byte $fd
	.word @song1ch2loop

@song1ch3:
@song1ch3loop:
@ref100:
	.byte $80,$02,$84,$18,$82,$04,$80,$02,$02,$84,$18,$82,$04,$86,$18,$80
	.byte $02,$84,$18,$82,$04,$80,$02,$02,$84,$18,$82,$04,$86,$18
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
@ref103:
	.byte $80,$02,$84,$18,$82,$04,$80,$02,$02,$84,$18,$82,$04,$86,$18,$80
	.byte $02,$84,$18,$82,$04,$04,$80,$02,$82,$04,$86,$18,$82,$04
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref103
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref103
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref103
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
	.byte $ff,$10
	.word @ref100
@ref119:
	.byte $80,$02,$84,$18,$82,$04,$80,$02,$02,$84,$18,$82,$04,$04,$80,$02
	.byte $82,$04,$04,$04,$80,$02,$82,$04,$04,$04
	.byte $fd
	.word @song1ch3loop

@song1ch4:
@song1ch4loop:
@ref120:
	.byte $9f
@ref121:
	.byte $9f
@ref122:
	.byte $9f
@ref123:
	.byte $9f
@ref124:
	.byte $9f
@ref125:
	.byte $9f
@ref126:
	.byte $9f
@ref127:
	.byte $9f
@ref128:
	.byte $9f
@ref129:
	.byte $9f
@ref130:
	.byte $9f
@ref131:
	.byte $9f
@ref132:
	.byte $9f
@ref133:
	.byte $9f
@ref134:
	.byte $9f
@ref135:
	.byte $9f
@ref136:
	.byte $9f
@ref137:
	.byte $9f
@ref138:
	.byte $9f
@ref139:
	.byte $9f
	.byte $fd
	.word @song1ch4loop


@song2ch0:
	.byte $fb,$06
@song2ch0loop:
@ref140:
	.byte $f9,$85
	.byte $fd
	.word @song2ch0loop

@song2ch1:
@song2ch1loop:
@ref141:
	.byte $8e,$6a,$f9,$83
	.byte $fd
	.word @song2ch1loop

@song2ch2:
@song2ch2loop:
@ref142:
	.byte $f9,$85
	.byte $fd
	.word @song2ch2loop

@song2ch3:
@song2ch3loop:
@ref143:
	.byte $f9,$85
	.byte $fd
	.word @song2ch3loop

@song2ch4:
@song2ch4loop:
@ref144:
	.byte $f9,$85
	.byte $fd
	.word @song2ch4loop
