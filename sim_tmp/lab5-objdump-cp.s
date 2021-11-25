
lab5.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	800012b7          	lui	t0,0x80001
   4:	18029073          	csrw	satp,t0
   8:	00001537          	lui	a0,0x1
   c:	80050513          	addi	a0,a0,-2048 # 800 <end+0x7a0>
  10:	00000293          	li	t0,0
  14:	00a2a023          	sw	a0,0(t0) # 80001000 <__global_pointer$+0x7ffff79c>
  18:	00001537          	lui	a0,0x1
  1c:	000022b7          	lui	t0,0x2
  20:	00a2a1a3          	sw	a0,3(t0) # 2003 <__global_pointer$+0x79f>
  24:	04c00493          	li	s1,76
  28:	34149073          	csrw	mepc,s1
  2c:	00000513          	li	a0,0
  30:	30051073          	csrw	mstatus,a0
  34:	06400513          	li	a0,100
  38:	000042b7          	lui	t0,0x4
  3c:	00a2a023          	sw	a0,0(t0) # 4000 <__global_pointer$+0x279c>
  40:	30200073          	mret
  44:	fff00793          	li	a5,-1
  48:	fff00793          	li	a5,-1
  4c:	000032b7          	lui	t0,0x3
  50:	0002a583          	lw	a1,0(t0) # 3000 <__global_pointer$+0x179c>
  54:	00100613          	li	a2,1
  58:	00200693          	li	a3,2
  5c:	00300713          	li	a4,3

00000060 <end>:
  60:	00000063          	beqz	zero,60 <end>
