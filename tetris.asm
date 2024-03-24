################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
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

	# Run the Tetris game.
main:

#initialize the game
#two register that store color
li $a0, 0x0000ff #for painting wall
li $a1, 0x1f1f1f#for painting grids
li $a2, 0xff0000#for drawing the tetramino
# for tracking if it reach the end of the row
lw $t1, ADDR_KBRD
# Starting address for the display
lw $t0, ADDR_DSPL

li $t2 48#line length






#initialize two horizontal wall offsets
li $t5, 960#offset added to $t0 to draw the horizontal line
add $t5 $t5 $t0#this represent the offset of the first unit in the last row
#loop index
li $t4, 0#loop index
draw_horizontal_walls:
    bge $t4, 48, initialize_draw_vertical # if loop index exceeds display width, start drawing vertical walls
    sw $a0 0($t5)
    addi $t4 $t4 4
    addi $t5 $t5 4
    j draw_horizontal_walls            # jump back to start of loop
    
initialize_draw_vertical:#reload the values into register for drawing vertical wall.
    li $t5, 0
    li $t4, 0#still the loop index
    add $t5 $t5 $t0 
    j draw_vertical_walls
    
    
# # Draw left and right walls
draw_vertical_walls:
    bge $t4, 20, initialize_drawgrid#after reaching the 21th row, draw the grids
    sw $a0 0($t5)
    sw $a0 44($t5)
    addi $t5 $t5 48
    addi $t4 $t4 1
    j draw_vertical_walls
    
initialize_drawgrid:#initialize for drawing grid on line of even idex, say line 0, line 2, etc.
    li $t4, 0#still the loop index, we draw 5 white units on each row, so t4 won't exceed 5
    li $t5, 4#this is for drawing on rows with even index, say row 0
    li $t6, 52#this is for drawing on rows with odd index, say row 19(last row we have beside the wall)
    add $t5 $t5 $t0#initialize offset
    add $t6 $t6 $t5#initialize offset
    la $t3,0#this is important, it keep track of whether all 20 lines are covered by white units. 
    j draw_grid

 reset_lopp_drawgrid:#reset the loop index to zero, increment $t3 to keep track of rows being drawn, add offset to t5 and t6.
    li $t4, 0
    addi $t5 $t5 56
    addi $t6 $t6 56
    addi $t3 $t3 1
    
 
 draw_grid:
    bge $t4, 5, reset_lopp_drawgrid
    bge $t3, 10, initialize_game#after finishing the grid, we successfully set up th bitmap and go to the game loop
    addi $t4 $t4 1
    sw $a1 0($t5)
    sw $a1 0($t6)
    addi $t5 $t5 8
    addi $t6 $t6 8
    j draw_grid
 #the field is drawn
 

#$t0 is for offset of the bitmap
#$t1 is for offset of keyboard input
#$t2 store 48(line length)
#$t3 store the left most/or bottom block of the tetramino
#$t4 keep track of orientation. if $t4 = 0, the tetramino is horizontal, $t3 being the leftmost block
#if $t4 = 0, the tetramino is vertical, $t3 being the bottom block.
#$t8 is used to check keyboard input
initialize_game:
     li $t4 0 #default orientation: horizontal
     li $t3 16#address of the first unit of the tetramino
     add $t3 $t3 $t0
     #draw the tetramino at the top of the bitmap
        sw $a2 0($t3)
        sw $a2 4($t3)
        sw $a2 8($t3)
        sw $a2 12($t3)
     j game_loop

game_loop:
    #draw grid at the top
    #here, we need to check if there is any complete line. if there is, need to do sth to update/redraw the field
    #code to check complete lines
    #... basic idea: loop thourgh the whole field from line 19 to line 0
    #if this line is not complete: go to the line above and check
    
    #else: go to a helper function that let all the red blocks above this line drop by one unit, then check the same line again in next iteration.
    
    #Helper function that "drop" blocks: basic idea: a nested loop that loop through all units within and above this line
    
    #for any particular line, we loop though all its units. For any unit, if the unit above this unit is red, make this unit red. 
    #if the unit above this unit is white, make this unit black. if the unit above is black, make this unit white. 
    
    #after finishing looping on this line, loop thourgh the line above and do the same thing.
    
    j check_keypress
    
    
check_keypress:
	# 1a. Check if key has been pressed
	li $t8 0
	lw $t8, 0($t1)                  # Load first word from keyboard
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	j game_loop

keyboard_input:  # A key is pressed
    lw $t9, 4($t1)                  # Load second word from keyboard
    # 1b. Check which key has been pressed
    beq $t9, 100, respond_to_d     # Check if the key d was pressed
    beq $t9, 97, respond_to_a        # Check if the key a was pressed
    beq $t9, 119, respond_to_w       # Check if the key w was pressed
    beq $t9, 115, respond_to_s       # Check if the key s was pressed
    
    j exit


respond_to_d:#move right
    beq $t4, 0, respond_to_d_horizontal
    #if not, the tetramino is vertical in orientation, handle the case in another way
    
respond_to_d_horizontal:
    #if the tetramino can move right, it means that the unit at the right side of the tetramino is not wall or other tetramino
    lw $t5 16($t3)#retrive the color at the unit on the right side of the tetramino
    beq $t5, $a0, check_keypress#collide with the wall
    beq $t5, $a2, check_keypress#collide with existing tetramino
    sw $t5 0($t3)#maintain color of the grid cells
    addi $t3 $t3 4
    sw $a2 0($t3)#draw in new location
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    j check_keypress
    
    
respond_to_a:#move left
    
    beq $t4, 0, respond_to_a_horizontal
    #if not, handle the case when tetramino is vertical

respond_to_a_horizontal:
    #if the tetramino can move left, it means that the unit at the left side of the tetramino is not wall or other tetramino
    lw $t5 -4($t3)#retrive the color at the unit on the left side of the tetramino
    beq $t5, $a0, check_keypress#collide with the wall
    beq $t5, $a2, check_keypress#collide with existing tetramino
    sw $t5 12($t3)#maintain color of the grid cells
    addi $t3 $t3 -4
    sw $a2 0($t3)#draw in new location
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    j check_keypress

    
respond_to_w:#rotation
    


respond_to_s:#move down
    beq $t4, 0, respond_to_s_horizontal
    #if not, handle the vertical case
    
respond_to_s_horizontal:
    #if the tetramino can move down, it means that the units below the tetramino are not wall or other tetramino
    lw $t5 48($t3)#retrive the color at the unit below the tetramino
    beq $t5, $a0, initialize_game#collide with the wall
    beq $t5, $a2, initialize_game#collide with existing tetramino
    lw $t5 52($t3)#retrive the color at the unit below the tetramino
    beq $t5, $a0, initialize_game#collide with the wall
    beq $t5, $a2, initialize_game#collide with existing tetramino
    lw $t5 56($t3)#retrive the color at the unit below the tetramino
    beq $t5, $a0, initialize_game#collide with the wall
    beq $t5, $a2, initialize_game#collide with existing tetramino
    lw $t5 60($t3)#retrive the color at the unit below the tetramino
    beq $t5, $a0, initialize_game#collide with the wall
    beq $t5, $a2, initialize_game#collide with existing tetramino
    lw $t6 48($t3)#store the color below the leftmost unit ot the tetramino
    sw $t5 0($t3)#here, t5 is the color just below the right most unit of the tetramino
    sw $t5 0($t3)
    sw $t5 8($t3)
    sw $t6 4($t3)
    sw $t6 12($t3)
    
    addi $t3 $t3 48
    sw $a2 0($t3)#draw in new location
    sw $a2 4($t3)
    sw $a2 8($t3)
    sw $a2 12($t3)
    j check_keypress
    
    
    


   


exit: