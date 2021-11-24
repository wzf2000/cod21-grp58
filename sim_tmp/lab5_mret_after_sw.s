    .org 0x0
    .global _start
    .text
_start:
    lui t0, 0x80001
	csrw satp, t0 #root at 0x80001000
	li a0, 0x20000800 #0x80002000 >> 2
	li t0, 0x80001800 #for 0x800XXXXX, VPN1=0b1000000000=2^9, offset=0x800=2^11, sum=0x80001000+0x800
	sw a0, 0(t0) #points to 0x80002000
	li a0, 0x20001000 #0x80004000 >> 2
	li t0, 0x80002000 #for 0x80003XXX, VPN0=3, offset=c; for 0x80000XXX, VPN0=0, offset=0;
	sw a0, 12(t0)
	li a0, 0x20000000 #0x80000000 >> 2
	sw a0, 0(t0)
	li s1, 0x80000058 #TODO change this address
	csrw mepc, s1
	li a0, 0
	csrw mstatus, a0
	li a0, 100
	li t0, 0x80004000
	sw a0, 0(t0)
	mret
	li a5, -1
	li a5, -1
	li t0, 0x80003000
	lw a1, 0(t0)
	li a2, 1
	li a3, 2
	li a4, 3
end:
    beq zero, zero, end
