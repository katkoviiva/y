; ============================================
; SPRITE FORMATION DEMO
; by Elliot Raines, April 1985
;
; 8 sprites moving in formation
; left. right. down a little. back again.
; like the enemy ships in galaga but smoother
;
; i tried random patterns first but they felt
; WRONG. like the sprites were lying about
; what they were supposed to be doing.
; the formation just clicks. predictable.
; i always know where theyll be next.
;
; v0.2 - added sine bobbing, multiple patterns,
; animation frames, a little background tune.
; the flapping makes them look alive.
; ============================================

.segment "HEADER"
    .byte $01, $08

.segment "BASIC"
    .byte $0B, $08
    .byte $0A, $00
    .byte $9E
    .byte "2064"
    .byte $00
    .byte $00, $00

.segment "CODE"

; ---- hardware registers ----
SCREEN   = $0400
COLRAM   = $D800
BORDER   = $D020
BGCOL    = $D021
RASTER   = $D012
GETIN    = $FFE4

; VIC-II sprite registers
SPENA    = $D015         ; sprite enable
SP0X     = $D000         ; sprite 0 X pos
SP0Y     = $D001         ; sprite 0 Y pos
SPXMSB   = $D010         ; X MSB for sprites
SPCOL0   = $D027         ; sprite 0 color
SPMC     = $D01C         ; multicolor enable
SPMCOL0  = $D025         ; shared multicolor 0
SPMCOL1  = $D026         ; shared multicolor 1
SPXEX    = $D01D         ; X expand
SPYEX    = $D017         ; Y expand
SPBGPR   = $D01B         ; sprite-bg priority
SPSPCL   = $D01E         ; sprite-sprite collision

; sprite pointers (end of screen RAM)
SPRPTR   = $07F8

; sprite data destination
; frame 0 at block 128 ($2000), frame 1 at block 129 ($2040)
SPRDATA0 = $2000         ; block 128
SPRDATA1 = $2040         ; block 129
SPRBLK0  = (SPRDATA0/64) ; = 128
SPRBLK1  = (SPRDATA1/64) ; = 129

; SID registers
SIDV1FR  = $D400         ; voice 1 freq lo
SIDV1FH  = $D401         ; voice 1 freq hi
SIDV1PW  = $D402         ; pulse width lo
SIDV1PH  = $D403         ; pulse width hi
SIDV1CR  = $D404         ; control register
SIDV1AD  = $D405         ; attack/decay
SIDV1SR  = $D406         ; sustain/release
SIDV2FR  = $D407         ; voice 2 freq lo
SIDV2FH  = $D408         ; voice 2 freq hi
SIDV2PW  = $D409         ; pulse width lo
SIDV2PH  = $D40A         ; pulse width hi
SIDV2CR  = $D40B         ; control register
SIDV2AD  = $D40C         ; attack/decay
SIDV2SR  = $D40D         ; sustain/release
SIDVOL   = $D418

NUM_SPRITES = 8
ANIM_RATE   = 8          ; toggle sprite frame every 8 main frames
MUSIC_RATE  = 12         ; advance note every 12 frames
SINE_AMP    = 6          ; amplitude for Y bobbing

; ============================================
; INTRO / TITLE SCREEN
; ============================================
start:
    lda #$00
    sta BORDER
    sta BGCOL

    jsr clear_screen

    ; display title banner "FORMATION DEMO" centered on row 5
    ldx #0
@title_top:
    lda title_banner,x
    beq @title_done
    sta SCREEN + 5*40 + 13, x
    lda #1                  ; white
    sta COLRAM + 5*40 + 13, x
    inx
    bne @title_top
@title_done:

    ; display subtitle on row 7
    ldx #0
@subtitle:
    lda subtitle_text,x
    beq @sub_done
    sta SCREEN + 7*40 + 5, x
    lda #13                 ; light green
    sta COLRAM + 7*40 + 5, x
    inx
    bne @subtitle
@sub_done:

    ; display "PRESS ANY KEY" on row 12
    ldx #0
@presskey:
    lda presskey_text,x
    beq @pk_done
    sta SCREEN + 12*40 + 13, x
    lda #15                 ; light grey
    sta COLRAM + 12*40 + 13, x
    inx
    bne @presskey
@pk_done:

    ; display credits on row 20
    ldx #0
@credits:
    lda credit_text,x
    beq @cr_done
    sta SCREEN + 20*40 + 5, x
    lda #11                 ; dark grey
    sta COLRAM + 20*40 + 5, x
    inx
    bne @credits
@cr_done:

    ; flash border while waiting for key
@wait_key:
    lda #251
@wk_sync:
    cmp RASTER
    bne @wk_sync
    inc intro_timer
    lda intro_timer
    lsr
    lsr
    lsr
    lsr
    and #$0F
    tax
    lda color_cycle_tbl,x
    sta BORDER
    jsr GETIN
    cmp #0
    beq @wait_key

    lda #$00
    sta BORDER

    ; fall through to demo setup

; ============================================
; DEMO SETUP
; ============================================
    jsr clear_screen

    ; print status line at top
    ldx #0
@status:
    lda status_text,x
    beq @status_done
    sta SCREEN+1,x
    lda #1
    sta COLRAM+1,x
    inx
    bne @status
@status_done:

    ; copy both sprite frames to sprite blocks
    ldx #62
@cpframe0:
    lda invader_frame0,x
    sta SPRDATA0,x
    dex
    bpl @cpframe0

    ldx #62
@cpframe1:
    lda invader_frame1,x
    sta SPRDATA1,x
    dex
    bpl @cpframe1

    ; set all 8 sprite pointers to frame 0
    lda #SPRBLK0
    ldx #7
@setptr:
    sta SPRPTR,x
    dex
    bpl @setptr

    ; enable multicolor mode for all sprites
    lda #$FF
    sta SPMC

    ; shared multicolor colors
    lda #5                  ; green for body (%01)
    sta SPMCOL0
    lda #1                  ; white for highlights (%11)
    sta SPMCOL1

    ; individual sprite color = red for eye band (%10)
    ldx #7
@setcol:
    lda #2
    sta SPCOL0,x
    dex
    bpl @setcol

    ; init formation positions from pattern 0
    jsr load_pattern

    ; init state
    lda #1
    sta form_dir
    lda #0
    sta frame_count
    sta form_step
    sta sine_idx
    sta anim_timer
    sta music_idx1
    sta music_idx2
    sta music_timer
    sta cur_pattern

    ; enable all 8 sprites
    lda #$FF
    sta SPENA

    ; no expand, no priority
    lda #0
    sta SPXEX
    sta SPYEX
    sta SPBGPR

    ; setup SID
    lda #$0F
    sta SIDVOL
    ; voice 1: lead melody - triangle wave
    lda #$09
    sta SIDV1AD             ; attack=0, decay=9
    lda #$00
    sta SIDV1SR             ; sustain=0, release=0
    ; voice 2: bass line - pulse wave
    lda #$33
    sta SIDV2AD             ; attack=3, decay=3
    lda #$A0
    sta SIDV2SR             ; sustain=A, release=0
    lda #$00
    sta SIDV2PW
    lda #$08
    sta SIDV2PH             ; pulse width ~50%

; ============================================
; MAIN LOOP
; ============================================
mainloop:
    ; wait for raster line 251 (vsync)
    lda #251
@wait:
    cmp RASTER
    bne @wait

    inc frame_count

    ; --- sprite frame animation ---
    inc anim_timer
    lda anim_timer
    cmp #ANIM_RATE
    bcc @no_anim
    lda #0
    sta anim_timer
    ; toggle sprite frame for all sprites
    lda SPRPTR              ; read current block for sprite 0
    cmp #SPRBLK0
    beq @set_frame1
    lda #SPRBLK0
    jmp @write_frame
@set_frame1:
    lda #SPRBLK1
@write_frame:
    ldx #7
@wr_fr:
    sta SPRPTR,x
    dex
    bpl @wr_fr
@no_anim:

    ; --- Y-axis sine bobbing ---
    jsr apply_sine_bob

    ; --- update sprite hardware positions ---
    jsr update_sprite_hw

    ; --- move formation every 4 frames ---
    lda frame_count
    and #$03
    bne @skipform
    jsr move_formation
@skipform:

    ; --- color cycling ---
    lda frame_count
    lsr
    lsr
    lsr                     ; shift for slower cycling
    and #$0F
    tax
    lda color_cycle_tbl,x
    sta SPMCOL0

    ; --- background music ---
    jsr play_music

    ; --- pattern switching every 256 steps ---
    lda form_step
    bne @no_pattern_switch
    inc cur_pattern
    lda cur_pattern
    cmp #3
    bcc @pat_ok
    lda #0
    sta cur_pattern
@pat_ok:
    jsr load_pattern
@no_pattern_switch:

    ; check for keypress to exit
    jsr GETIN
    cmp #0
    beq mainloop

    ; cleanup
    lda #0
    sta SPENA
    sta SIDVOL
    ; gate off both voices
    lda #$00
    sta SIDV1CR
    sta SIDV2CR
    rts

; ============================================
; LOAD FORMATION PATTERN
; applies X/Y offsets from pattern table to
; base positions (2 rows of 4)
; ============================================
load_pattern:
    lda cur_pattern
    asl                     ; *2
    asl                     ; *4
    asl                     ; *8
    asl                     ; *16
    tax                     ; X = pattern_offset (0, 16, or 32)

    ldy #0                  ; sprite index
@lp_loop:
    ; base X: sprite_within_row * 48 + 40
    tya
    and #$03
    sta tmp
    asl                     ; *2
    asl                     ; *4
    asl                     ; *8
    asl                     ; *16
    sta tmp2
    lda tmp
    asl                     ; *2
    asl                     ; *4
    asl                     ; *8
    asl                     ; *16
    asl                     ; *32
    clc
    adc tmp2                ; *48
    clc
    adc #40                 ; base offset
    clc
    adc pattern_data,x      ; add pattern X offset
    sta sprite_x_lo,y
    lda #0
    sta sprite_x_hi,y

    ; base Y: row 0=70, row 1=110
    tya
    and #$04
    beq @row0_lp
    lda #110
    jmp @set_y_lp
@row0_lp:
    lda #70
@set_y_lp:
    clc
    adc pattern_data+1,x    ; add pattern Y offset
    sta sprite_y,y
    sta sprite_base_y,y     ; save base Y for sine bobbing

    inx
    inx                     ; advance by 2 (X offset, Y offset per sprite)
    iny
    cpy #NUM_SPRITES
    bne @lp_loop
    rts

; ============================================
; APPLY SINE BOBBING
; adds sine wave offset to each sprite's Y
; each sprite uses a different phase offset
; ============================================
apply_sine_bob:
    inc sine_idx
    ldx #(NUM_SPRITES-1)
@bob:
    ; compute sine index: global sine_idx + sprite*32
    txa
    asl
    asl
    asl
    asl
    asl                     ; sprite * 32
    clc
    adc sine_idx            ; phase-shifted per sprite
    tay
    lda sine_table,y        ; look up from 256-entry table

    ; sine value is 128-centered, convert to signed offset
    sec
    sbc #128                ; now -128 to +127
    ; scale down: divide by (128/SINE_AMP) ~= shift right
    ; we want amplitude ~6, so /21 is close.
    ; approximate: arithmetic shift right 4 times = /16 -> amp ~8
    ; close enough for a smooth bob
    cmp #$80
    ror                     ; arithmetic shift right (preserves sign)
    cmp #$80
    ror
    cmp #$80
    ror
    cmp #$80
    ror                     ; /16, signed

    clc
    adc sprite_base_y,x     ; base Y + sine offset
    sta sprite_y,x
    dex
    bpl @bob
    rts

; ============================================
; UPDATE HARDWARE SPRITE REGISTERS
; ============================================
update_sprite_hw:
    lda #0
    sta SPXMSB

    ldx #0                  ; sprite index
    ldy #0                  ; register offset
@setpos:
    lda sprite_x_lo,x
    sta SP0X,y              ; X lo
    lda sprite_y,x
    sta SP0Y,y              ; Y
    ; handle X MSB
    lda sprite_x_hi,x
    beq @nomsb
    lda SPXMSB
    ora bit_table,x
    sta SPXMSB
@nomsb:
    iny
    iny                     ; next sprite register pair
    inx
    cpx #NUM_SPRITES
    bne @setpos
    rts

; ============================================
; MOVE FORMATION
; three modes: horizontal, sine-wave, diagonal
; selected by cur_pattern
; ============================================
move_formation:
    inc form_step

    lda cur_pattern
    cmp #1
    beq move_sine_wave
    cmp #2
    bne :+
    jmp move_diagonal
:
    ; fall through: pattern 0 = classic horizontal

; --- classic left-right movement ---
move_horizontal:
    lda form_dir
    beq @chkleft

    ; moving right
    ldx #3
    lda sprite_x_lo,x
    cmp #<280
    lda sprite_x_hi,x
    sbc #>280
    bcc @domove_h
    lda #0
    sta form_dir
    jsr drop_formation
    jsr play_bounce_sfx
    rts

@chkleft:
    ldx #0
    lda sprite_x_lo,x
    cmp #24
    bcs @domove_h
    lda #1
    sta form_dir
    jsr drop_formation
    jsr play_bounce_sfx
    rts

@domove_h:
    ldx #(NUM_SPRITES-1)
@mv_h:
    lda form_dir
    beq @mvleft_h
    lda sprite_x_lo,x
    clc
    adc #2
    sta sprite_x_lo,x
    lda sprite_x_hi,x
    adc #0
    sta sprite_x_hi,x
    jmp @mvnext_h
@mvleft_h:
    lda sprite_x_lo,x
    sec
    sbc #2
    sta sprite_x_lo,x
    lda sprite_x_hi,x
    sbc #0
    sta sprite_x_hi,x
@mvnext_h:
    dex
    bpl @mv_h
    rts

; --- sine wave movement: X moves linearly, Y follows sine ---
move_sine_wave:
    ldx #(NUM_SPRITES-1)
@mv_sw:
    ; X: always move right by 1, wrap at edges
    lda sprite_x_lo,x
    clc
    adc #1
    sta sprite_x_lo,x
    lda sprite_x_hi,x
    adc #0
    sta sprite_x_hi,x
    ; check for right edge and wrap
    lda sprite_x_hi,x
    cmp #>320
    bcc @sw_next
    lda #24
    sta sprite_x_lo,x
    lda #0
    sta sprite_x_hi,x
@sw_next:
    dex
    bpl @mv_sw
    rts

; --- diagonal movement: alternates NE/SW ---
move_diagonal:
    lda form_dir
    beq @diag_sw

    ; moving NE: X+2, Y-1
    ldx #(NUM_SPRITES-1)
@mv_ne:
    lda sprite_x_lo,x
    clc
    adc #2
    sta sprite_x_lo,x
    lda sprite_x_hi,x
    adc #0
    sta sprite_x_hi,x
    lda sprite_base_y,x
    sec
    sbc #1
    sta sprite_base_y,x
    dex
    bpl @mv_ne
    ; check bounds (sprite 3 = rightmost)
    ldx #3
    lda sprite_x_lo,x
    cmp #<280
    lda sprite_x_hi,x
    sbc #>280
    bcc @diag_done
    lda #0
    sta form_dir
    jsr play_bounce_sfx
    rts

@diag_sw:
    ; moving SW: X-2, Y+1
    ldx #(NUM_SPRITES-1)
@mv_sw2:
    lda sprite_x_lo,x
    sec
    sbc #2
    sta sprite_x_lo,x
    lda sprite_x_hi,x
    sbc #0
    sta sprite_x_hi,x
    lda sprite_base_y,x
    clc
    adc #1
    sta sprite_base_y,x
    dex
    bpl @mv_sw2
    ; check bounds (sprite 0 = leftmost)
    ldx #0
    lda sprite_x_lo,x
    cmp #24
    bcs @diag_done
    lda #1
    sta form_dir
    jsr play_bounce_sfx
@diag_done:
    rts

; ============================================
; DROP FORMATION DOWN
; ============================================
drop_formation:
    ldx #(NUM_SPRITES-1)
@drop:
    lda sprite_base_y,x
    clc
    adc #4
    cmp #230
    bcc @dropok
    lda #50
@dropok:
    sta sprite_base_y,x
    sta sprite_y,x
    dex
    bpl @drop
    rts

; ============================================
; PLAY BACKGROUND MUSIC (2 voices)
; called every frame, advances notes on timer
; ============================================
play_music:
    inc music_timer
    lda music_timer
    cmp #MUSIC_RATE
    bcc @mus_done
    lda #0
    sta music_timer

    ; --- voice 1: lead melody (triangle) ---
    ldx music_idx1
    lda melody_freq_lo,x
    sta SIDV1FR
    lda melody_freq_hi,x
    sta SIDV1FH
    ; gate on with triangle
    lda melody_freq_hi,x
    beq @v1_rest            ; freq hi = 0 means rest
    lda #$11                ; triangle, gate on
    sta SIDV1CR
    jmp @v1_advance
@v1_rest:
    lda #$10                ; triangle, gate off
    sta SIDV1CR
@v1_advance:
    inx
    cpx #MELODY_LEN
    bcc @v1_ok
    ldx #0
@v1_ok:
    stx music_idx1

    ; --- voice 2: bass line (pulse) ---
    ldx music_idx2
    lda bass_freq_lo,x
    sta SIDV2FR
    lda bass_freq_hi,x
    sta SIDV2FH
    lda bass_freq_hi,x
    beq @v2_rest
    lda #$41                ; pulse, gate on
    sta SIDV2CR
    jmp @v2_advance
@v2_rest:
    lda #$40                ; pulse, gate off
    sta SIDV2CR
@v2_advance:
    inx
    cpx #BASS_LEN
    bcc @v2_ok
    ldx #0
@v2_ok:
    stx music_idx2
@mus_done:
    rts

; ============================================
; SOUND EFFECT: bounce / direction change
; ============================================
play_bounce_sfx:
    lda #$30
    sta SIDV1FH
    lda #$00
    sta SIDV1FR
    lda #$21                ; sawtooth, gate on
    sta SIDV1CR
    lda #$20                ; gate off (trigger envelope)
    sta SIDV1CR
    rts

; ============================================
; CLEAR SCREEN
; ============================================
clear_screen:
    ldx #0
    lda #$20
@clr:
    sta SCREEN,x
    sta SCREEN+256,x
    sta SCREEN+512,x
    sta SCREEN+768,x
    lda #0
    sta COLRAM,x
    sta COLRAM+256,x
    sta COLRAM+512,x
    sta COLRAM+768,x
    lda #$20
    inx
    bne @clr
    rts

; ============================================
; DATA TABLES
; ============================================

; ---- text strings ----
; (PETSCII screen codes: A=1, B=2, ... Z=26, space=32)

title_banner:
    ; "FORMATION DEMO"
    .byte 6, 15, 18, 13, 1, 20, 9, 15, 14   ; FORMATION
    .byte 32                                   ; space
    .byte 4, 5, 13, 15                         ; DEMO
    .byte 0

subtitle_text:
    ; "8 SPRITES MARCHING IN LOCKSTEP - V0.2"
    .byte 56, 32                               ; "8 "
    .byte 19, 16, 18, 9, 20, 5, 19             ; SPRITES
    .byte 32                                   ; space
    .byte 13, 1, 18, 3, 8, 9, 14, 7            ; MARCHING
    .byte 32                                   ; space
    .byte 9, 14, 32                             ; "IN "
    .byte 12, 15, 3, 11, 19, 20, 5, 16         ; LOCKSTEP
    .byte 0

presskey_text:
    ; "PRESS ANY KEY"
    .byte 16, 18, 5, 19, 19, 32               ; "PRESS "
    .byte 1, 14, 25, 32                        ; "ANY "
    .byte 11, 5, 25                            ; "KEY"
    .byte 0

credit_text:
    ; "BY E.RAINES - APRIL 1985"
    .byte 2, 25, 32                            ; "BY "
    .byte 5, 46, 18, 1, 9, 14, 5, 19           ; "E.RAINES"
    .byte 32, 45, 32                            ; " - "
    .byte 1, 16, 18, 9, 12, 32                 ; "APRIL "
    .byte 49, 57, 56, 53                        ; "1985"
    .byte 0

status_text:
    .byte 6, 15, 18, 13, 1, 20, 9, 15, 14     ; FORMATION
    .byte 32                                   ; space
    .byte 20, 5, 19, 20, 32                    ; "TEST "
    .byte 22, 48, 46, 50                        ; "V0.2"
    .byte 32, 45, 32                            ; " - "
    .byte 5, 46, 18, 46, 32                    ; "E.R. "
    .byte 56, 53                                ; "85"
    .byte 0

; ---- bit mask table for sprite MSB ----
bit_table:
    .byte $01, $02, $04, $08, $10, $20, $40, $80

; ---- color cycle table (16 entries) ----
; greens/cyans fading in and out for a pulsing glow
color_cycle_tbl:
    .byte 5, 5, 13, 13, 3, 3, 13, 13
    .byte 5, 5, 11, 11, 5, 5, 13, 13

; ============================================
; FORMATION PATTERN DATA
; 3 patterns x 8 sprites x 2 bytes (X offset, Y offset)
; = 48 bytes total
; ============================================
pattern_data:
    ; pattern 0: standard grid (no offsets)
    .byte   0,  0           ; sprite 0
    .byte   0,  0           ; sprite 1
    .byte   0,  0           ; sprite 2
    .byte   0,  0           ; sprite 3
    .byte   0,  0           ; sprite 4
    .byte   0,  0           ; sprite 5
    .byte   0,  0           ; sprite 6
    .byte   0,  0           ; sprite 7

    ; pattern 1: V-formation (like flying geese)
    .byte   0, 24           ; sprite 0 - left wingtip, lower
    .byte  16, 12           ; sprite 1 - inner left
    .byte  32,  0           ; sprite 2 - near center
    .byte  48, 12           ; sprite 3 - inner right (mirrored)
    .byte   0, 36           ; sprite 4 - left outer, lowest
    .byte  16, 24           ; sprite 5
    .byte  32, 12           ; sprite 6
    .byte  48, 24           ; sprite 7

    ; pattern 2: diamond cluster
    .byte  24,  0           ; sprite 0 - top
    .byte   0, 16           ; sprite 1 - left
    .byte  48, 16           ; sprite 2 - right
    .byte  24, 32           ; sprite 3 - bottom
    .byte  12,  8           ; sprite 4 - inner top-left
    .byte  36,  8           ; sprite 5 - inner top-right
    .byte  12, 24           ; sprite 6 - inner bottom-left
    .byte  36, 24           ; sprite 7 - inner bottom-right

; ============================================
; INVADER SPRITE DATA - FRAME 0 (antennae up, legs out)
; multicolor mode: 12 effective pixels wide x 21 rows
; %00 = transparent
; %01 = multicolor 0 (green body)
; %10 = sprite color (red eye band)
; %11 = multicolor 1 (white highlight)
;
; designed to match the dank armada invader:
; - two antennae prongs at top
; - body widens then narrows
; - prominent red horizontal band (the eye strip)
; - spread legs with feet at bottom
;
; i drew this on graph paper first
; the shape came to me the same way the
; station shape did. like remembering.
; ============================================

invader_frame0:
    ;         pixels 0-3     pixels 4-7     pixels 8-11
    .byte %00000100, %00000000, %00010000  ; row 0:  . . G .  . . . .  . G . .
    .byte %00000100, %00000000, %00010000  ; row 1:  . . G .  . . . .  . G . .
    .byte %00000001, %00000001, %00000000  ; row 2:  . . . G  . . . G  . . . .
    .byte %00000101, %01010101, %01000000  ; row 3:  . . G G  G G G G  G . . .
    .byte %00000101, %01110101, %01000000  ; row 4:  . . G G  G W G G  G . . .
    .byte %00010101, %01010101, %01010000  ; row 5:  . G G G  G G G G  G G . .
    .byte %01010001, %01010101, %00010100  ; row 6:  G G . G  G G G G  . G G .
    .byte %01010000, %01010100, %00010100  ; row 7:  G G . .  G G G .  . G G .
    .byte %10101010, %10101010, %10101010  ; row 8:  R R R R  R R R R  R R R R
    .byte %10101010, %10111010, %10101010  ; row 9:  R R R R  R W R R  R R R R
    .byte %10101010, %10101010, %10101010  ; row 10: R R R R  R R R R  R R R R
    .byte %01010001, %01010101, %00010100  ; row 11: G G . G  G G G G  . G G .
    .byte %01000001, %01010101, %00000100  ; row 12: G . . G  G G G G  . . G .
    .byte %00000000, %01010100, %00000000  ; row 13: . . . .  G G G .  . . . .
    .byte %00000000, %01010100, %00000000  ; row 14: . . . .  G G G .  . . . .
    .byte %01000001, %00000001, %00000100  ; row 15: G . . G  . . . G  . . G .
    .byte %01000000, %01000100, %00000100  ; row 16: G . . .  G . G .  . . G .
    .byte %00000000, %00000000, %00000000  ; row 17: . . . .  . . . .  . . . .
    .byte %00000001, %00000000, %01000000  ; row 18: . . . G  . . . .  G . . .
    .byte %00000001, %00000000, %01000000  ; row 19: . . . G  . . . .  G . . .
    .byte %00000000, %00000000, %00000000  ; row 20: . . . .  . . . .  . . . .

; ============================================
; INVADER SPRITE DATA - FRAME 1 (antennae out, legs in)
; "flapping" frame: antennae spread wider,
; legs pulled together, slight body shift.
; alternates with frame 0 for animation.
;
; the motion looked jerky with just one frame.
; added this second pose and suddenly they
; felt like they were breathing. alive.
; ============================================

invader_frame1:
    ;         pixels 0-3     pixels 4-7     pixels 8-11
    .byte %00010000, %00000000, %00000100  ; row 0:  . G . .  . . . .  . . G .  (antennae wider)
    .byte %00010000, %00000000, %00000100  ; row 1:  . G . .  . . . .  . . G .
    .byte %00000100, %00000000, %01000000  ; row 2:  . . G .  . . . .  G . . .  (angled inward)
    .byte %00000101, %01010101, %01000000  ; row 3:  . . G G  G G G G  G . . .
    .byte %00000101, %01110101, %01000000  ; row 4:  . . G G  G W G G  G . . .
    .byte %00010101, %01010101, %01010000  ; row 5:  . G G G  G G G G  G G . .
    .byte %01010001, %01010101, %00010100  ; row 6:  G G . G  G G G G  . G G .
    .byte %01010000, %01010100, %00010100  ; row 7:  G G . .  G G G .  . G G .
    .byte %10101010, %10101010, %10101010  ; row 8:  R R R R  R R R R  R R R R
    .byte %10101010, %10111010, %10101010  ; row 9:  R R R R  R W R R  R R R R
    .byte %10101010, %10101010, %10101010  ; row 10: R R R R  R R R R  R R R R
    .byte %01010001, %01010101, %00010100  ; row 11: G G . G  G G G G  . G G .
    .byte %01000001, %01010101, %00000100  ; row 12: G . . G  G G G G  . . G .
    .byte %00000000, %01010100, %00000000  ; row 13: . . . .  G G G .  . . . .
    .byte %00000001, %01010101, %00000000  ; row 14: . . . G  G G G G  . . . .  (legs start closer)
    .byte %00000001, %01000101, %00000000  ; row 15: . . . G  G . G G  . . . .  (legs tucked in)
    .byte %00000000, %01000100, %00000000  ; row 16: . . . .  G . G .  . . . .  (feet together)
    .byte %00000000, %00000000, %00000000  ; row 17: . . . .  . . . .  . . . .
    .byte %00000000, %01000100, %00000000  ; row 18: . . . .  G . G .  . . . .  (inner feet)
    .byte %00000000, %01000100, %00000000  ; row 19: . . . .  G . G .  . . . .
    .byte %00000000, %00000000, %00000000  ; row 20: . . . .  . . . .  . . . .

; ============================================
; MUSIC DATA - LEAD MELODY (voice 1, triangle)
; frequency table for C64 SID notes
; lo/hi byte pairs index into standard PAL freqs
; 0/0 = rest (silence)
;
; melody: a simple descending minor phrase
; that loops. sounds like a march.
; ============================================
MELODY_LEN = 24

melody_freq_lo:
    ; C5   D5   Eb5  G4   C5   Bb4  G4   rest
    ; C5   D5   F5   Eb5  C5   Bb4  G4   G4
    ; Eb5  D5   C5   Bb4  G4   rest rest rest
    .byte $17, $6B, $A1, $5C, $17, $71, $5C, $00
    .byte $17, $6B, $43, $A1, $17, $71, $5C, $5C
    .byte $A1, $6B, $17, $71, $5C, $00, $00, $00

melody_freq_hi:
    .byte $11, $13, $14, $0B, $11, $0F, $0B, $00
    .byte $11, $13, $17, $14, $11, $0F, $0B, $0B
    .byte $14, $13, $11, $0F, $0B, $00, $00, $00

; ============================================
; MUSIC DATA - BASS LINE (voice 2, pulse)
; pumping eighth-note bass pattern
; ============================================
BASS_LEN = 16

bass_freq_lo:
    ; C3   C3   Eb3  Eb3  G3   G3   Bb3  Bb3
    ; C3   C3   F3   F3   G3   G3   C3   rest
    .byte $45, $45, $E8, $E8, $5C, $5C, $71, $71
    .byte $45, $45, $50, $50, $5C, $5C, $45, $00

bass_freq_hi:
    .byte $04, $04, $05, $05, $05, $05, $07, $07
    .byte $04, $04, $05, $05, $05, $05, $04, $00

; ============================================
; 256-BYTE SINE TABLE
; values range 0-255, centered at 128
; used for smooth Y-axis bobbing
;
; generated from: 128 + 127 * sin(i * 2*pi / 256)
; typed in by hand from a printout.
; took all afternoon but the movement is SMOOTH.
; ============================================
.segment "RODATA"
sine_table:
    .byte 128,131,134,137,140,143,146,149
    .byte 152,155,158,162,165,167,170,173
    .byte 176,179,182,184,187,190,192,195
    .byte 197,200,202,204,207,209,211,213
    .byte 215,217,219,221,223,224,226,228
    .byte 229,231,232,233,235,236,237,238
    .byte 239,240,241,242,243,243,244,245
    .byte 245,246,246,247,247,247,247,247
    .byte 248,247,247,247,247,247,246,246
    .byte 245,245,244,243,243,242,241,240
    .byte 239,238,237,236,235,233,232,231
    .byte 229,228,226,224,223,221,219,217
    .byte 215,213,211,209,207,204,202,200
    .byte 197,195,192,190,187,184,182,179
    .byte 176,173,170,167,165,162,158,155
    .byte 152,149,146,143,140,137,134,131
    .byte 128,124,121,118,115,112,109,106
    .byte 103,100, 97, 93, 90, 88, 85, 82
    .byte  79, 76, 73, 71, 68, 65, 63, 60
    .byte  58, 55, 53, 51, 48, 46, 44, 42
    .byte  40, 38, 36, 34, 32, 31, 29, 27
    .byte  26, 24, 23, 22, 20, 19, 18, 17
    .byte  16, 15, 14, 13, 12, 12, 11, 10
    .byte  10,  9,  9,  8,  8,  8,  8,  8
    .byte   7,  8,  8,  8,  8,  8,  9,  9
    .byte  10, 10, 11, 12, 12, 13, 14, 15
    .byte  16, 17, 18, 19, 20, 22, 23, 24
    .byte  26, 27, 29, 31, 32, 34, 36, 38
    .byte  40, 42, 44, 46, 48, 51, 53, 55
    .byte  58, 60, 63, 65, 68, 71, 73, 76
    .byte  79, 82, 85, 88, 90, 93, 97,100
    .byte 103,106,109,112,115,118,121,124

; ---- zero page ----
.segment "ZEROPAGE"
tmp:           .res 1
tmp2:          .res 1

; ---- BSS ----
.segment "BSS"
sprite_x_lo:   .res NUM_SPRITES
sprite_x_hi:   .res NUM_SPRITES
sprite_y:      .res NUM_SPRITES
sprite_base_y: .res NUM_SPRITES  ; base Y before sine applied
form_dir:      .res 1
form_step:     .res 1
frame_count:   .res 1
sine_idx:      .res 1
anim_timer:    .res 1
music_timer:   .res 1
music_idx1:    .res 1
music_idx2:    .res 1
cur_pattern:   .res 1
intro_timer:   .res 1
