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
    
ADDR_KEY:
    .word 0xffff0004

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################

.macro save()
    addi $sp,$sp,-56
    sw $ra,52($sp)    # Save $ra FIRST (highest address)
    sw $fp,48($sp)
    sw $s7,44($sp)
    sw $s6,40($sp)
    sw $s5,36($sp)
    sw $s4,32($sp)
    sw $s3,28($sp)
    sw $s2,24($sp)
    sw $s1,20($sp)
    sw $s0,16($sp)
    sw $a3,12($sp)
    sw $a2,8($sp)
    sw $a1,4($sp)
    sw $a0,0($sp)     # Save $a0 LAST (lowest address)
.end_macro

.macro return_val(%reg)
    move $v0, %reg
    lw $a0,0($sp)     # Restore $a0 FIRST (was saved last)
    lw $a1,4($sp)
    lw $a2,8($sp)
    lw $a3,12($sp)
    lw $s0,16($sp)
    lw $s1,20($sp)
    lw $s2,24($sp)
    lw $s3,28($sp)
    lw $s4,32($sp)
    lw $s5,36($sp)
    lw $s6,40($sp)
    lw $s7,44($sp)
    lw $fp,48($sp)
    lw $ra,52($sp)    # Restore $ra LAST (was saved first)
    addi $sp,$sp,56
    jr $ra
    nop
.end_macro

.macro return()
    lw $a0,0($sp)     # Restore $a0 FIRST
    lw $a1,4($sp)
    lw $a2,8($sp)
    lw $a3,12($sp)
    lw $s0,16($sp)
    lw $s1,20($sp)
    lw $s2,24($sp)
    lw $s3,28($sp)
    lw $s4,32($sp)
    lw $s5,36($sp)
    lw $s6,40($sp)
    lw $s7,44($sp)
    lw $fp,48($sp)
    lw $ra,52($sp)    # Restore $ra LAST
    addi $sp,$sp,56
    jr $ra
    nop
.end_macro


.macro push(%reg)
  addi $sp, $sp, -4
  sw %reg, 0($sp)
.end_macro
  
.macro pop(%reg)
  lw %reg,   0($sp)
  addi $sp, $sp, 4
.end_macro

.macro sleep(%ms)
    push($v0)
    push($a0)
    li $v0, 32
    li $a0, %ms
    syscall
    pop($a0)
    pop($v0)
.end_macro

.macro draw_pixel(%pixel)
    push($a0)
    li $a0, %pixel
    jal draw_pixel_func
    pop($a0)
.end_macro

.macro get_pixel(%source)
    push($a0)
    move $a0, %source
    jal get_pixel_func
    pop($a0)
.end_macro

.macro move_pixel_down_1(%pixel)
  push($a0)
  push($a1)
  move $a0, %pixel
  addi $a1, $a0, 16
  jal move_pixel_func
  pop($a1)
  pop($a0)
  
.end_macro

.macro random_pixel(%reg)
  push($a0)
  move $a0, %reg
  jal random_pixel_at
  pop($a0)
.end_macro

.macro random_pixel_i(%pos)
  push($a0)
  li $a0, %pos
  jal random_pixel_at
  pop($a0)
.end_macro

.macro random_num_1_6()
  push($a1)
  push($a0)
  li $a0, 0
  li $a1, 6
  li $v0, 42
  syscall
  addi $v0, $a0, 1
  pop($a0)
  pop($a1)
  
.end_macro

.macro is_not_empty(%pixel)     # (pixel) -> v0: 0 or  x >= 1
  push($t0)
  andi $t0, %pixel, 0xffffff00
  srl $v0, $t0, 8
  pop($t0)
.end_macro

.macro is_empty(%pixel)     # (pixel) -> v0: 0 or  x >= 1
  push($t0)
  srl $t0, %pixel, 8      # extract RRGGBB
  seq $v0, $t0, $zero     # v0 = 1 if RRGGBB == 0
  pop($t0)
.end_macro

.macro if(%cond, %func)
    blez %cond, skip
    nop
    jal %func
    nop
    j skip
    nop
    skip:
.end_macro

.macro if_equal(%reg, %const, %func)
    push($t0)   
    li $t0, %const
    bne %reg, $t0, skip
    nop
    jal %func
    nop
    j skip
    nop
    skip:
    pop($t0)
.end_macro

.macro if_else(%cond, %then, %else)
    blez %cond, else
    nop
    jal %then
    nop
    j skip
    else:
    nop
    jal %else
    nop
    j skip
    nop
    skip:
.end_macro

.macro for(%n, %func)
    push($s5)
    push($s6)
    move $s5, $zero
    move $s6, %n
    loop_block:
    beq $s5, $s6, finish_loop
    addiu $s5, $s5, 1
    nop
    jal %func
    nop
    j loop_block
    finish_loop:
    pop($s6)
    pop($s5)
.end_macro

.macro for_n_with_index(%n, %func)  # func: (a0: current index) -> func(a0), n times
    push($s5)
    push($s6)
    push($a0)
    move $s5, $zero
    li $s6, %n
    loop_block:
    beq $s5, $s6, finish_loop
    addiu $s5, $s5, 1
    move $a0, $s5
    nop
    jal %func
    nop
    j loop_block
    finish_loop:
    pop($a0)
    pop($s6)
    pop($s5)
.end_macro

.macro for_n(%n, %func)
    push($s7)
    li $s7, %n
    for($s7, %func)
    pop($s7)
.end_macro

.macro feed_forward(%n, %initial_reg, %func)  # func: (a0: T) -> (v0: T), feeds forward previous output as next input
    push($ra)
    push($s5)
    push($s6)
    push($a0)
    move $s5, $zero
    li $s6, %n
    nop
    loop_block:
    bge $s5, $s6, finish_loop
    nop
    addiu $s5, $s5, 1
    move $a0, %initial_reg
    nop
    jal %func
    nop
    move %initial_reg, $v0
    j loop_block
    nop
    finish_loop:
    pop($a0)
    pop($s6)
    pop($s5)
    pop($ra)
.end_macro

.macro position_equal(%p1, %p2)     # -> v0: bool
    push($t0)
    push($t1)
    andi $t0, %p1, 0xff
    andi $t1, %p2, 0xff
    seq $v0, $t1, $t2
    pop($t1)
    pop($t0)
.end_macro

.macro move_pixel_left(%pixel)
    push($ra)
    push($a1)
    push($a0)
    subiu $a1, %pixel, 1
    move $a0, %pixel
    jal move_pixel_func
    
    pop($a0)
    pop($a1)
    pop($ra)
.end_macro

.macro move_pixel_right(%pixel)
    push($ra)
    push($a1)
    push($a0)
    addi $a1, %pixel, 1
    move $a0, %pixel
    jal move_pixel_func
    
    pop($a0)
    pop($a1)
    pop($ra)
.end_macro


	.text
	.globl main

    # Run the game.
main:

  jal setup

  la $sp, 0x7fffff0c
  
  lw $s6, ADDR_KBRD
  
  li $s3, 0
  
  li $s0, 0x35  # s0 = bottom active pixel
  
  sleep(500)

  jal game_loop
    
  jal exit

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed

    sleep(100)

    lw $s5, 0($s6)
    beq $s5, 1, check_key

    rest:
    
    # 2a. Check for collisions


	# 2b. Update locations (capsules)
	

	beq $s3, 5, drop
	addi $s3, $s3, 1
	
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
    
check_key:
    lw $s4, 4($s6)
    move $v0, $s0
    move $a0, $s0
    
    li   $t0, 0x61       # 'a'
    beq  $s4, $t0, a_pressed
    nop

    li   $t0, 0x64       # 'd'
    beq  $s4, $t0, d_pressed
    nop

    li   $t0, 0x77       # 'd'
    beq  $s4, $t0, w_pressed
    nop

    li   $t0, 0x73       # 'd'
    beq  $s4, $t0, drop
    nop
    
    move $s0, $v0
    j rest

scan_vertical_col: # a0: col
  save()

  addi $a0, $a0, 0x15

  feed_forward(13, $a0, scan_vertical)
  
  return()

scan_vertical:  # a0: pixel -> delete? -> v0 next pixel
  save()
  get_pixel($a0)

  move $s0, $v0
  addiu $s1, $s0, 16
  subiu $s2, $s0, 16
  get_pixel($s1)
  move $s1, $v0
  get_pixel($s2)
  move $s2, $v0
  andi $s3, $s0, 0xffffff00
  andi $s4, $s1, 0xffffff00
  andi $s5, $s2, 0xffffff00

  is_not_empty($a0)
  move $t4, $v0
  
  seq $t0, $s3, $s4
  seq $t1, $s3, $s5
  seq $t2, $s4, $s5
  addu $t0, $t0, $t1
  addu $t2, $t2, $t0

  move $a0, $s3
  move $a1, $s4
  move $a2, $s5
  
  bge $t2, 4, delete_pixels

  addiu $v0, $s0, 16

  return()

delete_pixels:  # a0, a1, a2: pixel -> delete
  save()
  andi $a0, $a0, 0x000000ff
  jal draw_pixel_func
  andi $a0, $a1, 0x000000ff
  jal draw_pixel_func
  andi $a0, $a2, 0x000000ff
  jal draw_pixel_func
  return()

drop:
    move $a0, $s0
	jal next_active_pixel
	move $s0, $v0
	
	for_n_with_index(6, drop_one_row)
	
	addi $s0, $s0, 16
	get_pixel($s0)
	move $s0, $v0
    
	li $s3, 0
	j rest

next_active_pixel:   # (a0: current bottom active pixel) -> v0: next bottom active pixel
    save()
    

    
    move $s0, $a0
    addi $a0, $a0, 16
    get_pixel($a0)
    move $s2, $v0
    is_not_empty($s2)
    move $s1, $v0
    move $v0, $s0
    if($s1, new_triple)
    
    return_val($v0)

    

drop_one_row:   #(a0: column [1..6]) -> drops an entire col by one row
    save()
    addiu $t0, $a0, 0xd4
    
    get_pixel($t0)
    
    move $s1, $v0
    
    feed_forward(13, $s1, shift_pixel)
    
    return()
    
    shift_pixel:    # (a0: pixel) -> v0: next pixel up { shift a0 down 1 }
        save()

        nop
        addiu $s1, $a0, 16  # s1 = the pixel below
        
        get_pixel($s1)
        
        is_empty($v0)
        if($v0, move_pixel_down_1_func)
        subiu $v0, $a0, 16
        return()

        
        

# Pixel format: RRGGBBYX
draw_pixel_func:     # ($a0: Pixel) -> stores to bitmap
    save()
    lw $t4, ADDR_DSPL
    andi $t0, $a0, 0x000000ff #just position
    sll $t5, $t0, 2   # position times 4
    andi $t3, $a0, 0xffffff00 #t3 stores colour
    srl $t7, $t3, 8
    addu $t6, $t4, $t5
    sw $t7,0($t6)   #write pixel
    return()

get_pixel_func:  # ($a0: yx) -> $v0: pixel at that location
    save()
    andi $a0, $a0, 0x000000ff
    lw $t4, ADDR_DSPL   # bitmap address
    sll $t0, $a0, 2   # yx * 4
    addu $t1, $t0, $t4   # &colour = bitmap addr + yx * 4
    lw $t7 0($t1)   # t7 = *colour
    sll $t3, $t7, 8   # t3 = *colour << 8
    #andi $t5, $a0, 0x000000ff   # t5 = yx
    or $v0, $t3, $a0   # t7 colour + t5 pos
    return()

move_pixel_func: # ($a0: yx, $a1: y'x') -> Move pixel at a0 to a1

    save()
    
    andi $a0, $a0, 0x000000ff

    jal get_pixel_func

    move $s0, $v0
    
    jal draw_pixel_func
    
    andi $s1, $s0, 0xffffff00   # colour
    andi $s2, $a1, 0x000000ff   # new pos
    or $a0, $s2, $s1 # combine into new pixel
    
    jal draw_pixel_func

    return()

move_pixel_down_1_func:     # (a0: pixel) -> move down 1
  save()
  addi $a1, $a0, 16
  jal move_pixel_func
  return()

random_pixel_at: # (a0: pos) -> pixel with random color

  save()

  move $t0, $a0 # pos
  random_num_1_6()
  andi $t2, $t0, 0x000000ff # just pos

  andi $t3, $v0, 0x00000001  # xyZ
  andi $t4, $v0, 0x00000002  # xYz
  andi $t5, $v0, 0x00000004  # Xyz

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

new_triple:     # -> v0: bottom pixel of the triple

  save()

  random_num_1_6()

  addi $s0, $v0 20
  addi $s1, $s0, 16
  addi $s2, $s1, 16

  random_pixel($s0)
  random_pixel($s1)
  random_pixel($s2)
  
  get_pixel($s2)
  return()


  
exit:
    li $v0, 10              # terminate the program gracefully
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
  
  li $t0, 0x15
  random_pixel($t0)
  li $t0, 0x25
  random_pixel($t0)
  li $t0, 0x35
  random_pixel($t0)

  return()

draw_line_x:   # (a0: init, a1: dest)

  save()

  andi $a0, $a0, 0x000000ff
  andi $t1, $a1, 0x000000ff
  la $t2, loop_line_x
  la $t8, end_loop_line_x

  loop_line_x:
    bgt $a0, $t1, end_loop_line_x
    ori $a0, $a0, 0xffffff00
    jal draw_pixel_func
    andi $a0, $a0, 0x000000ff
    addiu $a0, $a0, 1
    j loop_line_x
  end_loop_line_x:
    return()

draw_line_y:   # (a0: init, a1: dest)

  save()

  andi $a0, $a0, 0x000000ff
  andi $t1, $a1, 0x000000ff
  la $t2, loop_line_y
  la $t8, end_loop_line_y

  loop_line_y:
    bgt $a0, $t1, end_loop_line_x
    ori $a0, $a0, 0xffffff00
    jal draw_pixel_func
    andi $a0, $a0, 0x000000ff
    addiu $a0, $a0, 16
    j loop_line_y
  end_loop_line_y:
    return()


key_pressed_func:   # -> v0: ASCII key or 0
    save()
    lw $s7, ADDR_KBRD
    lw $t0, 0($s7)
    if_else($t0, which_key, zero_func)
    return_val($v0)

which_key:  # -> v0
    save()
    lw $s7, ADDR_KEY
    lw $v0, 0($s7)
    return()

a_pressed:  # a0: active pixel -> $v0: new active pixel
    save()
    move $s0, $a0  # Use saved register instead of temporary
    jal no_collision_left
    move $a0, $s0
    move $s1, $v0
    move $v0, $s0
    if($s1, move_a)
    return_val($v0)

move_a:
    save()
    move $s0, $a0
    move_pixel_left($s0)
    subi $t0, $s0, 16
    move_pixel_left($t0)
    subi $t1, $s0, 32
    move_pixel_left($t1)
    subi $v0, $s0, 1  # Return new position
    get_pixel($v0)
    return()

d_pressed:  # a0: active pixel -> $v0: new active pixel
    save()
    move $s0, $a0  # Use saved register instead of temporary
    jal no_collision_right
    move $a0, $s0
    move $s1, $v0
    move $v0, $s0
    if($s1, move_d)
    return_val($v0)

move_d:   # a0: active pixel -> $v0: new active pixel
    save()
    move $s0, $a0
    move_pixel_right($s0)
    subi $t0, $s0, 16
    move_pixel_right($t0)
    subi $t1, $s0, 32
    move_pixel_right($t1)
    addi $v0, $s0, 1  # Return new position
    get_pixel($v0)
    return()

w_pressed:    # a0: active pixel -> shuffle and v0 new active pixel
    save()
    move $s0, $a0

    subiu $s1, $s0, 16
    subiu $s2, $s0, 32
    get_pixel($s1)
    move $s1, $v0
    get_pixel($s2)
    move $s2, $v0

    andi $a0, $s0, 0xffffff00

    jal draw_pixel_func

    move_pixel_down_1($s1)
    move_pixel_down_1($s2)

    li $a0, 0
    move $a1, $s2
    
    jal move_pixel_func

    get_pixel($s0)

    return()

zero_func:
    save()
    return_val($zero)

no_collision_left:   # a0: active pixel -> v0: bool
    save()
    move $s0, $a0
    
    subiu $s1, $s0, 1
    subiu $s2, $s0, 17
    subiu $s3, $s0, 33
    
    li $s4, 1
    
    get_pixel($s1)
    is_empty($v0)
    mul $s4, $s4, $v0

    get_pixel($s2)
    is_empty($v0)
    mul $s4, $s4, $v0
    
    get_pixel($s3)
    is_empty($v0)
    mul $s4, $s4, $v0
    
    return_val($s4)

    
no_collision_right:     # a0: active pixel -> v0: bool
    save()
    move $s0, $a0
    
    addi $s1, $s0, 1
    subiu $s2, $s0, 15
    subiu $s3, $s0, 31
    
    li $s4, 1
    
    get_pixel($s1)
    is_empty($v0)
    mul $s4, $s4, $v0

    get_pixel($s2)
    is_empty($v0)
    mul $s4, $s4, $v0
    
    get_pixel($s3)
    is_empty($v0)
    mul $s4, $s4, $v0
    
    return_val($s4)









        