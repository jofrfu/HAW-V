# Author: Jonas Fuhrmann, Matthis Keppner
.section .data
iterations:
    .word 1000000  # iteration count
    
.section .text
.globl _main
_main:
    #la a1, iterations  # address of clock_speed variable
    auipc a1, 0
    addi a1, a1, 0x50   # change
    lw a1, 0(a1)        # load clock_speed to a1
    # ------------------------------------------------------------
    li a2, 0x00000001   # for shifting
    slli a2, a2, 31     # shift to MSB - LED config address => 0x80000000
    addi a3, a2, 0x00000001 # LED register address => 0x80000001
    # ------------------------------------------------------------
    sb zero, 0(a2)  # store zero to LED config address - GPIOs are output
    mv a4, zero     # led toggle variable
    mv a5, zero     # iteration variable
    
    li a6, 0x80     # for check
loop:
    addi a5, a5, 1      # a5++
    bgeu a5, a1, setLED # if(a5 >= a1) then setLED
    j loop
    
setLED:
    sb a4, 0(a3)    # set LEDs to a4
    slli a4, a4, 1  # shift LED
    mv a5, zero     # reset iteration
    bgt a4, a6, resetLED    # if(a4 > a6) then resetLED
    j loop

resetLED:
    mv a4, zero
    j loop
    
