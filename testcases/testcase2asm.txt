; testcase 2
JMP main

; computes the max of r1 and r2, and stores the result in r3.
max:
    BGT r2, r1, 6
    ADD r3, r0, r1
    RET
r2_is_max:
    ADD r3, r0, r2
    RET

; computes the min of r1 and r2, and stores the result in r4.
min:
    BLT r2, r1, 6
    ADD r4, r0, r1
    RET
r2_is_min:
    ADD r4, r0, r2
    RET

; finds the sign of r5, and stores the result in r6.
; positive: 0, negative: 1
sign_of:
    BLTZ r5, 6
    ADDI r6, r0, 0
    RET
r5_is_negative:
    ADDI r6, r0, 1
    RET

main:
ADDI r1, r0, 5
ADDI r2, r0, 7
CALL max
CALL min
ADD r5, r0, r4
CALL sign_of
; attempt to write to r0
ADDI r0, r2, 7
