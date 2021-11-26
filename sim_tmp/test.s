    .org 0x0
    .global _start
    .text
_start:
    li t0, 0x80080001 #root(0x80001000)PPN=0x80001, mode=1 => 0x80000000+0x00080001
	csrw satp, t0
	li a0, 0x20000811 #0x80002000 >> 2 + "UXWRV"
	li t0, 0x80001800 #for 0x800XXXXX, VPN1=0b1000000000=2^9, offset=0x800=2^11, sum=0x80001000+0x800
	sw a0, 0(t0) #points to 0x80002000
	li a0, 0x200010d7 #0x80004000 >> 2 + "URWV"
	li t0, 0x80002000 #for 0x80003XXX, VPN0=3, offset=c; for 0x80000XXX, VPN0=0, offset=0;
	sw a0, 12(t0)
	li a0, 0x20000019 #0x80000000 >> 2 + "UXV"
	sw a0, 0(t0)
	li s1, 0x80000080 #TODO change this address
	csrw mepc, s1
	li a0, 0
	csrw mstatus, a0
	li a0, 100
	li t0, 0x80004000
	sw a0, 0(t0)
	li a5, -1
	li a5, -2
	li a5, -3
	li a0, 0x800000b4
	csrw mtvec, a0
	li a0, 0x80000000
	csrw mscratch, a0
	mret
	li a5, -4
	li a5, -5
	li a5, -6
	li t0, 0x81000000
	j UTEST_CRYPTONIGHT
	li a2, 1
	li a3, 2
	li a4, 3
	sw a2, 0(t0)
	li a5, 4
	li a6, 5
	li a7, 6
end:
    beq zero, zero, end

	csrrw sp, mscratch, sp
	sw	ra, 0(sp)
	csrrw ra, mscratch, sp
	csrr a0, mcause
	addi a0, a0, 53
	andi a0, a0, 255
	li a1, 65
	blt a0, a1, others
	jal WRITE_SERIAL
others:
	li t0, 0x80000a00
	li a2, 49
	sw a2, 0(t0)
	lw a0, 0(t0)
	jal WRITE_SERIAL
fin:
	beq zero, zero, fin

WRITE_SERIAL:
    li t0, 0x10000000
.TESTW:
    lb t1, %lo(5)(t0)
    andi t1, t1, 0x20
    bne t1, zero, .WSERIAL
    j .TESTW
.WSERIAL:
    sb a0, %lo(0)(t0)
    jr ra

UTEST_CRYPTONIGHT:
    li a0, 0x80003000
    li a1, 0x1000
    li a3, 2000
    li a4, 0xFFC
    add a1, a1, a0
    li s0, 1

    mv a2, a0
.INIT_LOOP:
    sw s0, 0(a2)
    slli s1, s0, 13
    xor s0, s0, s1
    srli s1, s0, 17
    xor s0, s0, s1
    slli s1, s0, 5
    xor s0, s0, s1

    addi a2, a2, 4
    bne a2, a1, .INIT_LOOP

    li a2, 0
    li t0, 0
.MAIN_LOOP:
    and t0, s0, a4
    add t0, a0, t0
    lw t0, 0(t0)
    xor t0, t0, t1
    xor s0, s0, t0

    slli s1, s0, 13
    xor s0, s0, s1
    srli s1, s0, 17
    xor s0, s0, s1
    slli s1, s0, 5
    xor s0, s0, s1

    and t1, s0, a4
    add t1, a0, t1
    sw t0, 0(t1)
    mv t1, t0

    slli s1, s0, 13
    xor s0, s0, s1
    srli s1, s0, 17
    xor s0, s0, s1
    slli s1, s0, 5
    xor s0, s0, s1

    add a2, a2, 1
    bne a2, a3, .MAIN_LOOP

    jr ra
