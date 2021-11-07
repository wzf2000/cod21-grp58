    .org 0x0
    .global _start
    .text
_start:
    li t0, 0
    li t2, 0
    li t3, 100
    ori t3, zero, 100
    li t4, 0x80000100
    li t5, 0x10000000
loop:
    addi t0, t0, 1
    add t2, t2, t0
    beq t0, t3, out
    beq zero, zero, loop
out:
    sw t2, 0(t4)
    sw t0, 4(t4)
    lw a1, 0(t4)
    lw a2, 4(t4)
    li a0, 100
    jal write
    li a0, 111
    jal write
    li a0, 110
    jal write
    li a0, 101
    jal write
    li a0, 33
    jal write
    jal end
write:
    lb t1, %lo(5)(t5)
    andi t1, t1, 0x20
    beq t1, zero, write
    sb a0, %lo(0)(t5)
    jr ra
end:
    beq zero, zero, end
