
test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	800802b7          	lui	t0,0x80080
   4:	00128293          	addi	t0,t0,1 # 80080001 <__global_pointer$+0x8007e741>
   8:	18029073          	csrw	satp,t0
   c:	20001537          	lui	a0,0x20001
  10:	81150513          	addi	a0,a0,-2031 # 20000811 <__global_pointer$+0x1fffef51>
  14:	800022b7          	lui	t0,0x80002
  18:	80028293          	addi	t0,t0,-2048 # 80001800 <__global_pointer$+0x7fffff40>
  1c:	00a2a023          	sw	a0,0(t0)
  20:	20001537          	lui	a0,0x20001
  24:	01350513          	addi	a0,a0,19 # 20001013 <__global_pointer$+0x1ffff753>
  28:	800022b7          	lui	t0,0x80002
  2c:	00a2a623          	sw	a0,12(t0) # 8000200c <__global_pointer$+0x8000074c>
  30:	20000537          	lui	a0,0x20000
  34:	01f50513          	addi	a0,a0,31 # 2000001f <__global_pointer$+0x1fffe75f>
  38:	00a2a023          	sw	a0,0(t0)
  3c:	800004b7          	lui	s1,0x80000
  40:	08048493          	addi	s1,s1,128 # 80000080 <__global_pointer$+0x7fffe7c0>
  44:	34149073          	csrw	mepc,s1
  48:	00000513          	li	a0,0
  4c:	30051073          	csrw	mstatus,a0
  50:	06400513          	li	a0,100
  54:	800042b7          	lui	t0,0x80004
  58:	00a2a023          	sw	a0,0(t0) # 80004000 <__global_pointer$+0x80002740>
  5c:	fff00793          	li	a5,-1
  60:	ffe00793          	li	a5,-2
  64:	ffd00793          	li	a5,-3
  68:	80000537          	lui	a0,0x80000
  6c:	0b450513          	addi	a0,a0,180 # 800000b4 <__global_pointer$+0x7fffe7f4>
  70:	30551073          	csrw	mtvec,a0
  74:	80000537          	lui	a0,0x80000
  78:	34051073          	csrw	mscratch,a0
  7c:	30200073          	mret
  80:	ffc00793          	li	a5,-4
  84:	ffb00793          	li	a5,-5
  88:	ffa00793          	li	a5,-6
  8c:	800032b7          	lui	t0,0x80003
  90:	00028067          	jr	t0 # 80003000 <__global_pointer$+0x80001740>
  94:	00100613          	li	a2,1
  98:	00200693          	li	a3,2
  9c:	00300713          	li	a4,3
  a0:	00c2a023          	sw	a2,0(t0)
  a4:	00400793          	li	a5,4
  a8:	00500813          	li	a6,5
  ac:	00600893          	li	a7,6

000000b0 <end>:
  b0:	00000063          	beqz	zero,b0 <end>
  b4:	34011173          	csrrw	sp,mscratch,sp
  b8:	00112023          	sw	ra,0(sp)
  bc:	340110f3          	csrrw	ra,mscratch,sp
