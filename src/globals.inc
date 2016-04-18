.ifndef GLOBAL_INC
.define GLOBAL_INC

.include "src/nes.inc"

NUM_DEATHS_DIGITS  = 5
NUM_SECONDS_DIGITS = 2  ; Don't change this.
NUM_MINUTES_DIGITS = 2  ; Don't change this.
NUM_HOURS_DIGITS   = 2

; Game event flags.
EVENT_KILL_PLAYER   = %00000001
EVENT_ADVANCE_LEVEL = %00000010

; Tiles are stored as indexes to pattern tables, and these values double as
; bit-flags for collision purposes. The bit-flags part is important for it
; allows multiple collision checks to be handled at once by OR-ing the
; results and using cmp's >= operation. (See collision code in player.s for
; how that works.)
; These values shouldn't be changed unless you know what you're doing.
; Changing these requires:
;  1) Updating the background png files.
;  2) Updating levelc.cpp.
;  3) Updating collision logic.
TILE_EMPTY_START = %00000000
TILE_EXIT_START  = %00001000
TILE_BEAR_START  = %00100000
TILE_WALL_START  = %01000000

; These determine the bounding box of the player.
PLAYER_W = 9
PLAYER_H = 9
PLAYER_XOFF = (16 - PLAYER_W) / 2
PLAYER_YOFF = (16 - PLAYER_H) / 2

GEM_W = 12
GEM_H = 8

; Enemies are always 16x16; there is no ENEMY_W or ENEMY_H.

LEVEL_W = 16 ; Width has to be 16. It's hardcoded by use of $0F bit masks.
LEVEL_H = 15 ; You *might* be able to change the height, but I wouldn't.

; This determines how much memory gets allocated for enemy data.
ENEMIES_MAX = 16

; Background stuff:
INTRO_BG_COLOR      = $0F
ENDING_BG_COLOR     = $0F
GAME_BG_COLOR       = $22
GAME_DEATH_BG_COLOR = $26

BLANK_TILE_PATTERN = 2

; Sprite stuff:
GEM_SPRITE_PATTERN = 6
GEM_SPRITE_PALETTE = 2
GEM_SPRITE_X_OFFSET = -4
GEM_SPRITE_Y_OFFSET = -6
GEM_SHADOW_SPRITE_PATTERN = 8
GEM_SHADOW_SPRITE_PALETTE = 2

PLAYER_SPRITE_PATTERN1 = 2
PLAYER_SPRITE_PATTERN2 = 18
PLAYER_SPRITE_PALETTE = 0
PLAYER_SPRITE_X_OFFSET = -3
PLAYER_SPRITE_Y_OFFSET = -4
PLAYER_DEATH_SPRITE_PATTERN = 34

ENEMY_SPRITE_PATTERN = 4
ENEMY_SPRITE_PALETTE = 1
ENEMY_SPRITE_X_OFFSET = 0
ENEMY_SPRITE_Y_OFFSET = -1

.globalzp do_draw
.globalzp current_level, game_event_flags, game_timer, movement_ticks
.globalzp frame_counter, using_timer, animation_ticks
.globalzp deaths_digits, seconds_digits, minutes_digits, hours_digits
.globalzp framerate_60
.globalzp palette_dim, palette_bg_color
.globalzp buttons_held, buttons_pressed
.globalzp player_x1, player_x2, player_y1, player_y2
.globalzp player_starting_x1, player_starting_y1
.globalzp num_enemies, enemies_attr, enemies_x1, enemies_y1
.globalzp enemies_starting_x1, enemies_starting_y1
.globalzp gem_visible, gem_starting_visible, gem_x1, gem_y1
.globalzp ft_zp_storage
.globalzp num_levels
.global ft_storage, tiles
.global ralph4_music_music_data
.global level_index
.global sin_table

.endif
