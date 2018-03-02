# Author: Jonas Fuhrmann
.section .data
clock_speed:
    .word 50000000  # 50MHz clock
    
.section .text
.globl _main
_main:
    #la a1, clock_speed  # address of clock_speed variable
    auipc a1, 0
    addi a1, a1, 0x40
    lw a1, 0(a1)        # load clock_speed to a1
    # ------------------------------------------------------------
    li a2, 0x00000001    # for shifting
    slli a2, a2, 31     # shift to MSB - LED config address => 0x80000000
    addi a3, a2, 0x00000001 # LED register address => 0x80000001
    # ------------------------------------------------------------
    sb zero, 0(a2)  # store zero to LED config address - GPIOs are output
    mv a4, zero     # led toggle variable
    mv a5, zero     # iteration variable

loop:
    addi a5, a5, 1      # a5++
    bgeu a5, a1, setLED # if(a5 >= a1) then setLED
    j loop
    
setLED:
    sb a4, 0(a3)    # set LEDs to a4
    xori a4, a4, 0x00000001 # toggle LED 0
    mv a5, zero     # reset iteration
    j loop
    