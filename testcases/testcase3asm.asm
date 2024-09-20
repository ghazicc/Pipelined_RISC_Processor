; Testcase #3
; data hazards
ADDI r1, r0, 3
ADDI r2, r1, 4
AND r3, r2, r1
SUB r4, r2, r3

Sv r0, -4
LBs r5, r0, 0
ADD r6, r5, r4
ANDI r1, r5, 0
SW r6, r0, 2
