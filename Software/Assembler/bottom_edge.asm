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

// Main game loop
START:

// If inputReg[gameAction] == DOWN, LEFT, RIGHT
andi r2, r8, 1 // Down mask
blez r2, 1 // If bit not set, skip jump to method
jal MOVEDOWN

// dummy lines
ori r7, r7, 0
ori r7, r7, 0

andi r2, r8, 2 // Left mask
blez r2, 5 // If bit not set, skip jump to method
ori r7, r7, 0
ori r7, r7, 0
ori r7, r7, 0
ori r7, r7, 0
movshpl

// dummy lines
ori r7, r7, 0
ori r7, r7, 0

andi r2, r8, 4 // Right mask
blez r2, 1 // If bit not set, skip jump to method
movshpr

sndrow r4 // Send row to graphics module

// Update counter
bgtz r4, 2 // If not zero, skip lines to reset to 20
andi r4, r4, 0
addi r4, r4, 20
subi r4, r4, 1

j START
// End game loop

// Move down method
MOVEDOWN:
andi r2, r8, 8064 // YPOS mask
bgtz r2, 2

// If already at bottom, new shape
wshp r1
return

// If not at bottom, collision detection
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB

// Get row below
subi r2, r2, 1
getrow r2, r2

andi r0, r8, 24576 // Mask for shape type
sra r0, r0, 13 // Shift to get shape
subi r0, r0, 1 // r0 = shape - 1 for comp
bgtz r0, 9 // Branch if Square

// If shape is line
andi r6, r8, 120 // XPOS mask
sra r6, r6, 3 // Shift X to LSB
exp r6, r6 // Get mask for column to check
and r7, r2, r6 // Apply mask on row below
bgtz r7, 2 // Branch if pixel below has piece

// Can move down
movshpd
return

// Can't move down, write new shape
wshp r1
return


// Else if shape is Square
// Get row below
andi r2, r8, 8064 // YPOS mask
sra r2, r2, 7 // Shift Y to LSB
subi r2, r2, 1
getrow r2, r2

// Get xpos and xpos + 1
andi r6, r8, 120 // XPOS mask
sra r6, r6, 3 // Shift X to LSB (XPOS)
addi r3, r6, 1 // (XPOS+1)
exp r6, r6 // Get mask for column to check
exp r3, r3 // Get mask for column 1 to right

and r7, r2, r6 // Apply mask on row below
and r0, r2, r3 // Apply mask on row below 1 to right
or r7, r7, r0 // Either has pixel below
bgtz r7, 2 // Branch if either pixel below has piece

// Can move down
movshpd
return

// Can't move down, write new shape
wshp r1
return