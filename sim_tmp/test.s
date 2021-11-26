    .org 0x0
    .global _start
    .text
_start:
    li t0, 0x800804ab #root(0x80001000)PPN=0x80001, mode=1 => 0x80000000+0x00080001
	csrw satp, t0
    li a0, 0x2000001f
    li t0, 0x804ab800
    sw a0, 0(t0)
	li a0, 0x2012ac01 #0x80002000 >> 2 + "UXWRV"
	li t0, 0x804abfac #for 0x800XXXXX, VPN1=0b1000000000=2^9, offset=0x800=2^11, sum=0x80001000+0x800
	sw a0, 0(t0) #points to 0x80002000
	li a0, 0x2012ac07 #0x80004000 >> 2 + "URWV"
	li t0, 0x804abfb0 #for 0x80003XXX, VPN0=3, offset=c; for 0x80000XXX, VPN0=0, offset=0;
	sw a0, 0(t0)
	li a0, 0x2012b011 #0x80000000 >> 2 + "UXV"
    li t0, 0x804ab804
	sw a0, 0(t0)
	li s1, 0x80000078 #TODO change this address
	csrw mepc, s1
	li a0, 0x800
	csrw mstatus, a0
    mret
	li a0, 100
	li t0, 0xfafec804
	lw a0, 0(t0)
    jal WRITE_SERIAL
    srli a0, a0, 4
    jal WRITE_SERIAL
    srli a0, a0, 4
    jal WRITE_SERIAL
    srli a0, a0, 4
    jal WRITE_SERIAL
end:
    beq zero, zero, end

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
