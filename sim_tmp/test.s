    .org 0x0
    .global _start
    .text
_start:
    li t0, 0x80080001 #root(0x80001000)PPN=0x80001, mode=1 => 0x80000000+0x00080001
	csrw satp, t0
	li a0, 0x20000811 #0x80002000 >> 2 + "UXWRV"
	li t0, 0x80001800 #for 0x800XXXXX, VPN1=0b1000000000=2^9, offset=0x800=2^11, sum=0x80001000+0x800
	sw a0, 0(t0) #points to 0x80002000
	li a0, 0x20001013 #0x80004000 >> 2 + "URV"
	li t0, 0x80002000 #for 0x80003XXX, VPN0=3, offset=c; for 0x80000XXX, VPN0=0, offset=0;
	sw a0, 12(t0)
	li a0, 0x2000001f #0x80000000 >> 2 + "UXWRV"
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
	li t0, 0x80003000
	jr t0
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
