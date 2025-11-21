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

.macro save()
    addi $sp, $sp, -128

    sw $zero,   0($sp)
    sw $at,     4($sp)
    sw $a0,    16($sp)
    sw $a1,    20($sp)
    sw $a2,    24($sp)
    sw $a3,    28($sp)
    sw $t0,    32($sp)
    sw $t1,    36($sp)
    sw $t2,    40($sp)
    sw $t3,    44($sp)
    sw $t4,    48($sp)
    sw $t5,    52($sp)
    sw $t6,    56($sp)
    sw $t7,    60($sp)
    sw $s0,    64($sp)
    sw $s1,    68($sp)
    sw $s2,    72($sp)
    sw $s3,    76($sp)
    sw $s4,    80($sp)
    sw $s5,    84($sp)
    sw $s6,    88($sp)
    sw $s7,    92($sp)
    sw $t8,    96($sp)
    sw $t9,   100($sp)
    sw $k0,   104($sp)
    sw $k1,   108($sp)
    sw $gp,   112($sp)
    sw $sp,   116($sp)
    sw $fp,   120($sp)
    sw $ra,   124($sp)

    # hi/lo
    mfhi $t0
    mflo $t1
    sw $t0,   128($sp)
    sw $t1,   132($sp)
.end_macro

.macro return()
    lw $t0,   128($sp)
    lw $t1,   132($sp)
    mthi $t0
    mtlo $t1

    lw $zero,   0($sp)
    lw $at,     4($sp)
    lw $a0,    16($sp)
    lw $a1,    20($sp)
    lw $a2,    24($sp)
    lw $a3,    28($sp)
    lw $t0,    32($sp)
    lw $t1,    36($sp)
    lw $t2,    40($sp)
    lw $t3,    44($sp)
    lw $t4,    48($sp)
    lw $t5,    52($sp)
    lw $t6,    56($sp)
    lw $t7,    60($sp)
    lw $s0,    64($sp)
    lw $s1,    68($sp)
    lw $s2,    72($sp)
    lw $s3,    76($sp)
    lw $s4,    80($sp)
    lw $s5,    84($sp)
    lw $s6,    88($sp)
    lw $s7,    92($sp)
    lw $t8,    96($sp)
    lw $t9,   100($sp)
    lw $k0,   104($sp)
    lw $k1,   108($sp)
    lw $gp,   112($sp)
    lw $sp,   116($sp)
    lw $fp,   120($sp)
    lw $ra,   124($sp)

    addi $sp, $sp, 128
    jr $ra
.end_macro

.macro push(%reg)
  addi $sp, $sp, -4
  sw %reg, 0($sp)
.end_macro
  
.macro pop(%reg)
  lw %reg,   0($sp)
  addi $sp, $sp, 4
.end_macro

.macro draw_pixel(%pixel)
  li $a0, %pixel
  jal draw_pixel_func
.end_macro

.macro random_pixel(%reg)
  move $a0, %reg
  jal random_pixel_at
.end_macro

.macro random_pixel_i(%pos)
  li $a0, %pos
  jal random_pixel_at
.end_macro

.macro random_num_1_6(%reg)
  push($a0)
  push($a1)
  push($v0)
  li $a0, 0
  li $a1, 6
  li $v0, 42
  syscall
  addi %reg, $a0, 1
  pop($a0)
  pop($a1)
  pop($v0)
  
.end_macro



	.text
	.globl main

    # Run the game.
main:

  jal setup

  random_pixel($a0)

  jal new_triple
    
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

get_matching_neighbours:   #(a0: pixel) -> matches: a0, a1, a2, a3
  

# Pixel format: RRGGBBYX
draw_pixel_func:     # ($a0: Pixel) -> stores to bitmap
    lw $t4, ADDR_DSPL
    andi $t0, $a0, 0x000000ff #just position
    sll $t5, $t0, 2   # position times 4
    andi $t3, $a0, 0xffffff00 #t3 stores colour
    srl $t7, $t3, 8
    addu $t6, $t4, $t5
    sw $t7,0($t6)   #write pixel
    jr $ra

get_pixel_func:  # ($a0: yx) -> pixel at that location into $v0
    lw $t4, ADDR_DSPL   # bitmap address
    sll $t0, $a0, 2   # yx * 4
    addu $t1, $t0, $t4   # &colour = bitmap addr + yx * 4
    lw $t7 0($t1)   # t7 = *colour
    sll $t3, $t7, 8   # t3 = *colour << 8
    andi $t5, $a0, 0x000000ff   # t5 = yx
    addu $v0, $t3, $t5   # t7 colour + t5 pos
    jr $ra

move_pixel_func: # ($a0: yx, $a1: y'x') -> Move pixel at a0 to a1

    save()

    jal get_pixel_func
    andi $a0, $a0, 0x000000ff
    
    jal draw_pixel_func
    
    andi $t8, $v0, 0xffffff00   # colour
    andi $t9, $a1, 0x000000ff   # new pos
    or $a0, $t8, $t9   # combine into new pixel
    
    jal draw_pixel_func

    return()


random_pixel_at: # (a0: pos) -> v0: pixel with random color

  save()

  move $t0, $a0 # pos
  random_num_1_6($t1)
  andi $t2, $t0, 0x000000ff # just pos

  andi $t3, $t1, 0x00000001  # xyZ
  andi $t4, $t1, 0x00000002  # xYz
  andi $t5, $t1, 0x00000004  # Xyz

  srl $t4, $t4, 1
  srl $t5, $t5, 2

  mul $t3, $t3, 0x000000ff
  mul $t4, $t4, 0x000000ff
  mul $t5, $t5, 0x000000ff

  sll $t3, $t3, 8
  sll $t4, $t4, 16
  sll $t5, $t5, 24

  or $t2, $t2, $t3
  or $t2, $t2, $t4
  or $t2, $t2, $t5

  move $a0, $t2
  jal draw_pixel_func

  return()

new_triple:

  save()

  random_num_1_6($t0)

  addi $t0, $t0, 20
  addi $t1, $t0, 16
  addi $t2, $t1, 16

  random_pixel($t0)
  random_pixel($t1)
  random_pixel($t2)

  return()


  
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

tick:
    li $v0, 32
    li $a0, 5000
    syscall


setup:
  save()
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
  li $a1, 0x000000fc
  jal draw_line_y

  return()

draw_line_x:   # (a0: init, a1: dest)

  save()

  andi $a0, $a0, 0x000000ff
  andi $t1, $a1, 0x000000ff
  la $t2, loop
  la $t8, end_loop

  loop:
    bgt $a0, $t1, end_loop
    ori $a0, $a0, 0xffffff00
    jal draw_pixel_func
    andi $a0, $a0, 0x000000ff
    addiu $a0, $a0, 1
    j loop
  end_loop:
    return()

draw_line_y:   # (a0: init, a1: dest)

  save()

  andi $a0, $a0, 0x000000ff
  andi $t1, $a1, 0x000000ff
  la $t2, loop_line_y
  la $t8, end_loop_line_y

  loop_line_y:
    bgt $a0, $t1, end_loop
    ori $a0, $a0, 0xffffff00
    jal draw_pixel_func
    andi $a0, $a0, 0x000000ff
    addiu $a0, $a0, 16
    j loop_line_y
  end_loop_line_y:
    return()

.macro colour_only(%pixel)
  andi %pixel, %pixel, 0xffffff00
.end_macro















        