################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Noa Higuchi, 1011345518
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       1
# - Unit height in pixels:      1
# - Display width in pixels:    16
# - Display height in pixels:   16
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
BLACKV: .word 0x000000
WHITEV: .word 0xffffff
REDV: .word 0xff0000
ORANGEV: .word 0xff9900
YELLOWV: .word 0xffff00
GREENV: .word 0x00ff00
BLUEV: .word 0x0000ff
PURPLEV: .word 0xff00ff
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    li $a0, 0xff00ff00
    jal draw_pixel
    li $a0, 0xffffffff
    jal draw_pixel
    li $a0, 0xff
    li $a1, 0xf0
    jal move_pixel
    jal exit

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    #j game_loop

# Pixel format: RRGGBBYX
    draw_pixel:     # ($a0: Pixel) -> stores to bitmap
        lw $t4, ADDR_DSPL
        andi $t0, $a0, 0x000000ff #just position
        sll $t5, $t0, 2   # position times 4
        andi $t3, $a0, 0xffffff00 #t3 stores colour
        srl $t7, $t3, 8
        addu $t6, $t4, $t5
        sw $t7,0($t6)   #write pixel
        jr $ra
    
    get_pixel:  # ($a0: yx) -> pixel at that location into $s0
        lw $t4, ADDR_DSPL
        sll $t0, $a0, 2
        addu $t1, $t0, $t4
        lw $t7 0($t1)
        sll $t3, $t7, 8
        andi $t5, $a0, 0x000000ff
        addu $s0, $t7, $t5
        jr $ra
    
    move_pixel: # ($a0: yx, $a1: y'x') -> Move pixel at a0 to a1
        move $t9, $a0
        jal get_pixel
        move $t8, $s0
        andi $a0, $t9, 0x000000ff
        jal draw_pixel
        andi $t2, $t8, 0xffffff00
        andi $t3, $a1, 0x000000ff
        or $a0, $t2, $t3
        jal draw_pixel
        jr $ra
        
        

    exit:
        li $v0, 10              # terminate the program gracefully
        syscall