// GP registers = r0-r7
// Input register = r8
// Input register format [right, left, down]
// Row status register = r9

// Using r1 to indicate shape
// Using r4 to indicate counter
// Using r5 to indicate score

// 1 is line 2 is square
// ypos mask = 8064
// xpos mask = 120

// Clear GP registers
andi r0, r0, 0
andi r1, r1, 0
andi r2, r2, 0
andi r3, r3, 0
andi r4, r4, 0
andi r5, r5, 0
andi r6, r6, 0
andi r7, r7, 0

// Init game
ori r1, r1, 1
ori r4, r4, 19

wshp r1
andi r1, r1, 0
ori r1, r1, 2

// Main game loop
START:

// If inputReg[gameAction] == DOWN, LEFT, RIGHT
andi r2, r8, 1 // Down mask
blez r2, 1 // If bit not set, skip jump to method
movshpd

// dummy lines
andi r6, r6, 0
andi r7, r7, 0

andi r2, r8, 2 // Left mask
blez r2, 1 // If bit not set, skip jump to method
movshpl

// dummy lines
andi r6, r6, 0
andi r7, r7, 0

andi r2, r8, 4 // Right mask
blez r2, 4 // If bit not set, skip jump to method
ori r2, r2, 0
ori r2, r2, 0
ori r2, r2, 0
jal MOVERIGHT

// Clear line logic
exp r2, r4 // Get mask to index rowStatusReg
and r2, r2, r9 // Mask bit based on counter r4
blez r2, 2 // If bit not set, skip calling clrl
clrl r4 // If bit is set, clear line
addi r5, r5, 1 // Increment score

sndrow r4 // Send row to graphics module

// Update counter
bgtz r4, 2 // If not zero, skip lines to reset to 20
andi r4, r4, 0
addi r4, r4, 20
subi r4, r4, 1


j START
// End game loop


MOVERIGHT:

// Get current shape
andi r0, r8, 24576 // Mask for shape type
sra r0, r0, 13 // Shift to get shape
subi r0, r0, 1 // r0 = shape - 1 for comp
bgtz r0, 37 // Branch if Square

// If shape is line
// Check if all the way right and return
andi r6, r8, 120 // XPOS mask
sra r6, r6, 3 // Shift X to LSB (XPOS)
andi r3, r3, 0 
addi r3, r3, 19 // Load imm for comp
bne r6, r3, 1 // Branch if xpos != 19
return

andi r3, r3, 0

// Get row at Y
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
getrow r2, r2
// Get XPOS + 1
andi r6, r8, 120 // XPOS mask
sra r6, r6, 3 // Shift X to LSB (XPOS)
addi r6, r6, 1 // (XPOS+1)
exp r6, r6 // Get mask for column 1 to the left
// Check to the right on the get row
and r7, r2, r6
or r3, r3, r7

// Get row at Y+1
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
addi r2, r2, 1
getrow r2, r2
// r6 is already XPOS + 1
// Check to the right on the get row
and r7, r2, r6
or r3, r3, r7

// Get row at Y+2
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
addi r2, r2, 2
getrow r2, r2
// r6 is already XPOS + 1
// Check to the right on the get row
and r7, r2, r6
or r3, r3, r7

// Get row at Y+3
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
addi r2, r2, 3
getrow r2, r2
// r6 is already XPOS + 1
// Check to the right on the get row
and r7, r2, r6
or r3, r3, r7

bgtz r3, 1 // Branch if can't move right
movshpr
return

// Else if shape is Square
// Check if all the way right and return
andi r6, r8, 120 // XPOS mask
sra r6, r6, 3 // Shift X to LSB (XPOS)
andi r3, r3, 0 
addi r3, r3, 18 // Load imm for comp
bne r6, r3, 1 // Branch if xpos != 18
return

andi r3, r3, 0

// Get row at Y
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
getrow r2, r2
// Get XPOS + 2
andi r6, r8, 120 // XPOS mask
sra r6, r6, 3 // Shift X to LSB (XPOS)
addi r6, r6, 2 // (XPOS+2)
exp r6, r6 // Get mask for column 1 to the right
// Check to the right on the get row
and r7, r2, r6
or r3, r3, r7

// Get row at Y+1
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
addi r2, r2, 1
getrow r2, r2
// r6 is already XPOS + 2
// Check to the left on the get row
and r7, r2, r6
or r3, r3, r7

bgtz r3, 1 // Branch if can't move right
movshpr
return
