# Author: Jonas Fuhrmann
.section .data
GPIO_base:
    .word 0x80000000 # base address

#############################
# LED config:    0x80000000 #
# switch config: 0x80000001 #
# button config: 0x80000002 #
#############################
# LED reg:       0x80000003 #
# switch reg:    0x80000004 #
# button reg:    0x80000005 #
#############################

.section .text
.globl _main
_main:
    li x1, 0x3C    # GPIO_base address
    
    lw x1, 0(x1)   # load base address
    li x2, 0xFF    # for config

    sb zero, 0(x1) # configure LEDs as output
    sb x2, 1(x1)   # configure switches as input
    sb x2, 2(x1)   # configure buttons as input

switches:
    lb x3, 4(x1)   # get switches
    sb x3, 3(x1)   # map switches to LEDs
    
    lb x4, 5(x1)   # get buttons
    bne x4, zero, mode # if(button_pressed) mode()

    j switches

mode:
    sb x2, 3(x1)   # turn all LEDs on
buttons:
    lb x4, 5(x1)   # get buttons
    beq x4, zero, switches # if(no_button_pressen) switches()

    j buttons

