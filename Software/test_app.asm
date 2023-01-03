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
andi r0, r0, 0
andi r0, r0, 0
andi r0, r0, 0
movshpd

// Main game loop
START:

sndrow r4 // Send row to graphics module

// Update counter
bgtz r4, 2 // If not zero, skip lines to reset to 20
andi r4, r4, 0
addi r4, r4, 20
subi r4, r4, 1

j START
// End game loop