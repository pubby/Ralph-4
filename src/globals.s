.include "src/globals.inc"

.segment "ZEROPAGE"
; Control variables
do_draw:                .res 1
using_timer:            .res 1
current_level:          .res 1
game_event_flags:       .res 1
game_timer:             .res 3 ; 24 bits to hold a few hours worth
movement_ticks:         .res 1
animation_ticks:        .res 1
frame_counter:          .res 1
deaths_digits:          .res NUM_DEATHS_DIGITS
seconds_digits:         .res NUM_SECONDS_DIGITS
minutes_digits:         .res NUM_MINUTES_DIGITS
hours_digits:           .res NUM_HOURS_DIGITS

; Palette
palette_dim:            .res 1
palette_bg_color:       .res 1

; Gamepad
buttons_held:           .res 1
buttons_pressed:        .res 1

; Player variables
player_x1:              .res 2
player_x2:=player_x1+1
player_y1:              .res 2
player_y2:=player_y1+1
player_starting_x1:     .res 1
player_starting_y1:     .res 1

; Enemy variables
num_enemies:            .res 1
enemies_attr:           .res ENEMIES_MAX
enemies_x1:             .res ENEMIES_MAX
enemies_y1:             .res ENEMIES_MAX
enemies_starting_x1:    .res ENEMIES_MAX
enemies_starting_y1:    .res ENEMIES_MAX

; Gem
gem_visible:            .res 1
gem_starting_visible:   .res 1
gem_x1:                 .res 1
gem_y1:                 .res 1

; For local variables in FamiTone2.
ft_zp_storage:          .res 4

.segment "BSS" ; RAM
.align 256
ft_storage:             .res 256 ; A page for FamiTone2.
.align 256
tiles:                  .res 256 ; Tile array of the current level

