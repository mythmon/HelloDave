;***********************************************************
;*
;*    Enter Name of file here
;*
;*    Enter the description of the program here
;*
;*    This is the skeleton file Lab 3 of ECE 375
;*
;***********************************************************
;*
;*     Author: Enter your name
;*       Date: Enter Date
;*
;***********************************************************

.include "m128def.inc"            ; Include definition file

;***********************************************************
;*    Internal Register Definitions and Constants
;***********************************************************
.def    mpr     = r16               ; Multipurpose register required for LCD Driver
.def    olcnt   = r23               ; Used as the outer loop counter
.def    ilcnt   = r24               ; Used as the inner loop counter
.def    waitcnt = r25               ; Used in the wait loop counter

.equ    BTN_RIGHT = 15            ; Buttons on the right side of the board
.equ    BTN_LEFT  = 240           ; Buttons on the left side

;***********************************************************
;*    Start of Code Segment
;***********************************************************
.cseg                            ; Beginning of code segment

;-----------------------------------------------------------
; Interrupt Vectors
;-----------------------------------------------------------
.org    $0000                    ; Beginning of IVs
        rjmp INIT                ; Reset interrupt

.org    $0046                    ; End of Interrupt Vectors

;-----------------------------------------------------------
; Program Initialization
;-----------------------------------------------------------
INIT:                            ; The initialization routine
        ; Initialize Stack Pointer
        ldi        mpr, HIGH(RAMEND)
        out        SPH, mpr
        ldi        mpr, LOW(RAMEND)
        out        SPL, mpr

        ; Initialize LCD Display
        rcall   LCDInit

        ; Initialize Port D for inputs
        ldi     mpr, $FF        ; Initialize Port D for inputs
        out     PORTD, mpr      ; with Tri-State
        ldi     mpr, $00        ; Set Port D Directional Register
        out     DDRD, mpr       ; for inputs

;-----------------------------------------------------------
; Main Program
;-----------------------------------------------------------
MAIN:
        ; Move to the first data block
        ldi     ZL, low(START<<1)
        ldi     ZH, high(START<<1)
        ldi     YL, low(LCDLn1Addr)
        ldi     YH, high(LCDLn1Addr)

GAME:
        ; Draw the text to the screen
        rcall   SubDrawScreen

        ldi     olcnt, 32

        adiw    ZH:ZL, 32       ; Move past the game text.

        ldi     waitcnt, 25
        rcall   SubWait
        rjmp INPUT              ; Wait for user input

INPUT:      ; Get user input and move the story appropriately
            ; TODO: This should be done with interrupts.
busywait:   ; Wait for a button press
        in      mpr, PIND       ; Note: active low
        com     mpr             ; Flip the input
        andi    mpr, BTN_RIGHT  ; Check for the right buttons
        brne    RIGHT_PRESS     ; Branch if any button pressed

        in      mpr, PIND       ; Note: active low
        com     mpr             ; Flip the input
        andi    mpr, BTN_LEFT   ; Check for the left buttons
        brne    LEFT_PRESS      ; Branch if any button pressed

        rjmp    busywait        ; Wait for input

RIGHT_PRESS:
        lpm     XL, Z+
        lpm     XH, Z+
        rjmp    MOVE_ON

LEFT_PRESS:
        rjmp    MOVE_ON

MOVE_ON:
        ; Load the next-block pointer from the end of the current block and
        ; make Z point to the next block.
        lpm     XL, Z+
        lpm     XH, Z+

        movw    ZH:ZL, XH:XL

        rjmp    GAME            ; Game Loop

;***********************************************************
;*    Functions and Subroutines
;***********************************************************

;----------------------------------------------------------------
; Sub:  SubDrawScreen
; Desc: Writes the page in program memory pointed to by the Z
;       register to the LCD.
;----------------------------------------------------------------
SubDrawScreen:
        ; Save registers on the stack
        push    mpr
        push    ZH
        push    ZL
        push    YH
        push    YL
        push    olcnt

        ; Point the Y register to the LCD memory.
        ldi     YL, low(LCDLn1Addr)
        ldi     YH, high(LCDLn1Addr)

        ldi     olcnt, 32       ; The number of chars on the screen
LOAD_TEXT:
        lpm     mpr, Z+         ; Get the character
        st      Y+, mpr         ; Put it in the LCD memory
        dec     olcnt           ; One less character
        brne    LOAD_TEXT       ; Are we done yet?

        rcall LCDWrite          ; Put it on the screen.

        ; Restore registers from the stack
        pop     olcnt
        pop     YL
        pop     YH
        pop     ZL
        pop     ZH
        pop     mpr

        ret

;----------------------------------------------------------------
; Sub:  SubWait
; Desc: A wait loop that is 16 + 159975*waitcnt cycles or roughly 
;       waitcnt*10ms.  Just initialize wait for the specific amount 
;       of time in 10ms intervals. Here is the general eqaution
;       for the number of clock cycles in the wait loop:
;           ((3 * ilcnt + 3) * olcnt + 3) * waitcnt + 13 + call
;----------------------------------------------------------------
SubWait:
        push    waitcnt         ; Save wait register
        push    ilcnt           ; Save ilcnt register
        push    olcnt           ; Save olcnt register

Loop:   ldi     olcnt, 224      ; load olcnt register
OLoop:  ldi     ilcnt, 237      ; load ilcnt register
ILoop:  dec     ilcnt           ; decrement ilcnt
        brne    ILoop           ; Continue Inner Loop
        dec     olcnt           ; decrement olcnt
        brne    OLoop           ; Continue Outer Loop
        dec     waitcnt         ; Decrement wait
        brne    Loop            ; Continue Wait loop

        pop     olcnt           ; Restore olcnt register
        pop     ilcnt           ; Restore ilcnt register
        pop     waitcnt         ; Restore wait register
        ret                     ; Return from subroutine

;***********************************************************
;*    Stored Program Data
;***********************************************************

START:
.include "storydata.asm"

;***********************************************************
;*    Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"        ; Include the LCD Driver
