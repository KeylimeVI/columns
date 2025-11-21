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

  #addi $sp, $sp, -4
  #sw $ra, 0($sp)
  
  li $a0, 0x00000004
  li $a1, 0x0000000b
  jal draw_line_x

  li $a0, 0x00000004
  li $a1, 0x000000f4
  jal draw_line_y

  li $a0, 0x000000f4
  li $a1, 0x000000fb
  jal draw_line_x

  li $a0, 0x0000000b
  li $a1, 0x000000fb
  jal draw_line_y

  li $a0, 0xff0000e5
  jal draw_pixel
  li $a0, 0xff00ffd5
  jal draw_pixel
  li $a0, 0x0000ffc5
  jal draw_pixel
  
  #lw $ra, 0($sp)
  #addi $sp, $sp, 4
    
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
    lw $t4, ADDR_DSPL   # bitmap address
    sll $t0, $a0, 2   # yx * 4
    addu $t1, $t0, $t4   # &colour = bitmap addr + yx * 4
    lw $t7 0($t1)   # t7 = *colour
    sll $t3, $t7, 8   # t3 = *colour << 8
    andi $t5, $a0, 0x000000ff   # t5 = yx
    addu $s0, $t3, $t5   # t7 colour + t5 pos
    jr $ra

move_pixel: # ($a0: yx, $a1: y'x') -> Move pixel at a0 to a1

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal get_pixel
    andi $a0, $a0, 0x000000ff
    
    jal draw_pixel
    
    andi $t8, $s0, 0xffffff00   # colour
    andi $t9, $a1, 0x000000ff   # new pos
    or $a0, $t8, $t9   # combine into new pixel
    
    jal draw_pixel

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra


draw_line_x:   # (a0: init, a1: dest)

  addi $sp, $sp, -4
  sw $ra, 0($sp)

  andi $a0, $a0, 0x000000ff
  andi $t1, $a1, 0x000000ff
  la $t2, loop
  la $t8, end_loop

  loop:
    bgt $a0, $t1, end_loop
    ori $a0, $a0, 0xffffff00
    jal draw_pixel
    andi $a0, $a0, 0x000000ff
    addiu $a0, $a0, 1
    j loop
  end_loop:

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

draw_line_y:   # (a0: init, a1: dest)

  addi $sp, $sp, -4
  sw $ra, 0($sp)

  andi $a0, $a0, 0x000000ff
  andi $t1, $a1, 0x000000ff
  la $t2, loop_line_y
  la $t8, end_loop_line_y

  loop_line_y:
    bgt $a0, $t1, end_loop
    ori $a0, $a0, 0xffffff00
    jal draw_pixel
    andi $a0, $a0, 0x000000ff
    addiu $a0, $a0, 16
    j loop_line_y
  end_loop_line_y:

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

random_pixel_at: # (a0: pos) -> s0: pixel with random color

  addi $sp, $sp, -4
  sw $ra, 0($sp)

  move $t0, $a0 # pos
  li $a0, 0
  li $a1, 5
  li $v0, 42
  syscall
  move $t1, $a0 # random number
  andi $t2, $t0, 0x000000ff # just pos
  li $t3, 0
  beq $t3, $t1, red
  li $t3, 1
  beq $t3, $t1, orange
  li $t3, 2
  beq $t3, $t1, yellow
  li $t3, 3
  beq $t3, $t1, green
  li $t3, 4
  beq $t3, $t1, blue
  li $t3, 5
  beq $t3, $t1, purple


  red:
    ori $a0, $t2, 0xff000000
    jal draw_pixel
    jr $ra
  orange:
    ori $a0, $t2, 0xffff0000
    jal draw_pixel
    jr $ra
  yellow:
    ori $a0, $t2, 0x00ff0000
    jal draw_pixel
    jr $ra
  green:
    ori $a0, $t2, 0x00ff0000
    jal draw_pixel
    jr $ra
  blue:
    ori $a0, $t2, 0x0000ff00
    jal draw_pixel
    jr $ra
  purple:
    ori $a0, $t2, 0xff00ff00
    jal draw_pixel
    jr $ra

  lw $ra, 0($sp)
  addi $sp, $sp, 4
    
  done:
    jr $ra
  

  
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

tick:
    li $v0, 32
    li $a0, 5000
    syscall






















        