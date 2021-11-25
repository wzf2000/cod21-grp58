    .org 0x0
    .global _start
    .text
_start:
	li t5, 0x10000000
	li a0, 101
	jal write
	li a1, 100
    csrrw a2, mepc, a1
	csrrw a0, mepc, a2
	jal write
	jal end
end:
    beq zero, zero, end
write:
    lb t1, %lo(5)(t5)
    andi t1, t1, 0x20
    beq t1, zero, write
    sb a0, %lo(0)(t5)
    jr ra