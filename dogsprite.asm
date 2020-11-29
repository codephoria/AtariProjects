  processor 6502
  include "vcs.h"
  include "macro.h"

  seg.u Variables
  org $80

YPos .byte
YPosP1 .byte
BGColor .byte

;;;; CONSTANTS ;;;;;;;;;;;;;;
SPRITE_HEIGHT = 16
SPRITE1_HEIGHT = 9

  seg Code
  org $F000

Start:
  CLEAN_START


  ;;;;;;;;;;;; initialize variables ;;;;;;;;;;;;;;;;;;;;;;;;
  lda #20
  sta YPos     ; Y-Pos of Player 0

  lda #40
  sta YPosP1

  lda #00
  sta BGColor

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;; FRAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;

NextFrame:
  lda #2
  sta VBLANK
  sta VSYNC

  sta WSYNC
  sta WSYNC
  sta WSYNC

  lda #0
  sta VSYNC


;;;;;;;;;;;; vertical blank ;;;;;;;;;;;;;;;;;
  ldx #34
LVBlank:
  sta WSYNC
  dex
  bne LVBlank

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Calculations and tasks inside VBLANK time
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  lda #60
  ldx #0
  jsr SetHorizPos
  sta WSYNC
  sta HMOVE

  ldy BGColor
  sty COLUBK

  sta WSYNC



;;;;;;;;;; end of VBLANK ;;;;;;;;;;;;;;;;;;;
  lda #0
  sta VBLANK


  ;;;;;;; visible scanlines;;;;;;;;;;;;;;
  lda #$02
  sta COLUPF

  ldx #49

;;;;;; SpriteLoop ;;;;;;;;;;;;;;;;;;
LVScan:

  txa
  sec
  sbc YPos
  bne .InspriteCheck
  lda #$ff
  sta PF0
  sta PF1
  sta PF2
.InspriteCheck
  cmp #SPRITE_HEIGHT
  bcc InSprite
  lda #0

InSprite:
  tay
  lda P0Bitmap,y
  sta WSYNC
  sta GRP0
  lda P0Color,y
  sta COLUP0
  lda #%00000111
  sta NUSIZ0

  sta WSYNC
  sta WSYNC


  txa
  sec
  sbc YPosP1
  cmp #SPRITE1_HEIGHT
  bcc InSprite1
  lda #0

InSprite1:
  tay
  lda P1Bitmap,y
  sta WSYNC
  sta GRP1
  lda P1Color,y
  sta COLUP1
  lda #%00000111
  sta NUSIZ1




  sta WSYNC

  dex
  bne LVScan



Overscan:
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC
  REPEND


  ;;;;;;; preparation for next frame;;;;;;;;;;
  ; inc BGColor
  lda #0
  sta PF0
  sta PF1
  sta PF2
  jmp NextFrame



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Subroutine for horizontal positioning
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; A = target x-coordinate position in pixels of the object
  ;; Y = the object type (0: player0, 1: player1, 2: missile0, 3: missile1, 4: ball)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetHorizPos subroutine
  sta WSYNC                       ; start fresh scanline
  sec                             ; set carry flag before subtraction
.Div15Loop:
  sbc #15                         ; subtract 15 from accumulator
  bcs .Div15Loop                  ; loop until carry flag is clear
  eor #7                          ; handle offset range from -8 to 7
  asl
  asl
  asl
  asl                             ; four shifts left to get only the top 4 bits
  sta HMP0,Y                      ; store the fine offset in the correct HMxx
  sta RESP0,Y                     ; fix object position in 15-step increment
  rts

;;;;;;;;;;;;;;;; Lookup table for the player graphics bitmap ;;;;;;;;;;;;;;;;;;;
P0Bitmap:
  .byte #%00000000
  .byte #%00100010 ;$F8
  .byte #%00111110 ;$F8
  .byte #%00111110 ;$F8
  .byte #%00111110 ;$0E
  .byte #%00111111 ;$F8
  .byte #%00011101 ;$F8
  .byte #%00001000
  .byte #%00011100 ;$F8
  .byte #%00100010 ;$F8
  .byte #%00111110 ;$F8
  .byte #%00110110 ;$0E
  .byte #%00101010 ;$F8
  .byte #%01111111 ;$F8
  .byte #%01100011 ;$F8
  .byte #%01000001 ;$0E

  ;;;;;;;;;;;;;;;; Lookup table for player colors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
  .byte #$00
  .byte #$F8;
  .byte #$F8;
  .byte #$F8;
  .byte #$0E;
  .byte #$F8;
  .byte #$F8;
  .byte #$F8
  .byte #$F8
  .byte #$F8
  .byte #$F8
  .byte #$0E
  .byte #$F8
  .byte #$F8
  .byte #$F8
  .byte #$0E

P1Bitmap:
  .byte #%00000000
  .byte #%00111100
  .byte #%00110110
  .byte #%01100010
  .byte #%01100000
  .byte #%01100000
  .byte #%01110010
  .byte #%00111110
  .byte #%00011100

P1Color:
  .byte #$00
  .byte #$0A;
  .byte #$0A;
  .byte #$0A;
  .byte #$0C;
  .byte #$0C;
  .byte #$0E;
  .byte #$0E;
  .byte #$0E;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;; end cartridge ;;;;;;;;;;;
  org $FFFC
  .word Start
  .word Start
