JMP main

sum:
    ADD r5, r5, r3
    ADDI r3, r3, -1
    BNE r3, r0, -4
    RET

main:
Sv r0, 5
LW r2, r0, 0
SW r2, r0, 2
LBu r3, r0, 2
ANDI r5, r0, 0
CALL sum
SW r5, r0, 4
ADDI r6, r5, -15
ADDI r6, r6, -15
SW r6, r0, 6
LBs r1, r0, 6
