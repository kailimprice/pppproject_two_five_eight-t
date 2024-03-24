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
# for tracking if it reach the end of the row
li $t1, 48#length of a row
# Starting address for the display
lw $t0, ADDR_DSPL



#initialize two horizontal wall offsets
li $t5, 960#offset added to $t0 to draw the horizontal line
add $t5 $t5 $t0#this represent the offset of the first unit in the last row
#loop index
li $t4, 0#loop index
draw_horizontal_walls:
    bge $t4, $t1, initialize_draw_vertical # if loop index exceeds display width, start drawing vertical walls
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
    bge $t3, 10, exit
    addi $t4 $t4 1
    sw $a1 0($t5)
    sw $a1 0($t6)
    addi $t5 $t5 8
    addi $t6 $t6 8
    j draw_grid
 #initialize end

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop

exit: