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
ori r1, r1, 2
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
blez r2, 1 // If bit not set, skip jump to method
movshpr

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