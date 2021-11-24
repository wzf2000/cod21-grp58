
lab5.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	800802b7          	lui	t0,0x80080
   4:	00128293          	addi	t0,t0,1 # 80080001 <__global_pointer$+0x8007e761>
   8:	18029073          	csrw	satp,t0
   c:	20001537          	lui	a0,0x20001
  10:	81f50513          	addi	a0,a0,-2017 # 2000081f <__global_pointer$+0x1fffef7f>
  14:	800022b7          	lui	t0,0x80002
  18:	80028293          	addi	t0,t0,-2048 # 80001800 <__global_pointer$+0x7fffff60>
  1c:	00a2a023          	sw	a0,0(t0)
  20:	20001537          	lui	a0,0x20001
  24:	01b50513          	addi	a0,a0,27 # 2000101b <__global_pointer$+0x1ffff77b>
  28:	800022b7          	lui	t0,0x80002
  2c:	00a2a623          	sw	a0,12(t0) # 8000200c <__global_pointer$+0x8000076c>
  30:	20000537          	lui	a0,0x20000
  34:	01f50513          	addi	a0,a0,31 # 2000001f <__global_pointer$+0x1fffe77f>
  38:	00a2a023          	sw	a0,0(t0)
  3c:	800004b7          	lui	s1,0x80000
  40:	07048493          	addi	s1,s1,112 # 80000070 <__global_pointer$+0x7fffe7d0>
  44:	34149073          	csrw	mepc,s1
  48:	00000513          	li	a0,0
  4c:	30051073          	csrw	mstatus,a0
  50:	06400513          	li	a0,100
  54:	800042b7          	lui	t0,0x80004
  58:	00a2a023          	sw	a0,0(t0) # 80004000 <__global_pointer$+0x80002760>
  5c:	fff00793          	li	a5,-1
  60:	ffe00793          	li	a5,-2
  64:	ffd00793          	li	a5,-3
  68:	30200073          	mret
  6c:	ffc00793          	li	a5,-4
  70:	ffb00793          	li	a5,-5
  74:	ffa00793          	li	a5,-6
  78:	800032b7          	lui	t0,0x80003
  7c:	0002a583          	lw	a1,0(t0) # 80003000 <__global_pointer$+0x80001760>
  80:	00100613          	li	a2,1
  84:	00200693          	li	a3,2
  88:	00300713          	li	a4,3
  8c:	00c2a023          	sw	a2,0(t0)
  90:	00400793          	li	a5,4
  94:	00500813          	li	a6,5
  98:	00600893          	li	a7,6

0000009c <end>:
  9c:	00000063          	beqz	zero,9c <end>
