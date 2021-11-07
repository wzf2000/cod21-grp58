
lab5.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00000293          	li	t0,0
   4:	00000393          	li	t2,0
   8:	06400e13          	li	t3,100
   c:	06406e13          	ori	t3,zero,100
  10:	80000eb7          	lui	t4,0x80000
  14:	100e8e93          	addi	t4,t4,256 # 80000100 <__global_pointer$+0x7fffe880>
  18:	10000f37          	lui	t5,0x10000

0000001c <loop>:
  1c:	00128293          	addi	t0,t0,1
  20:	005383b3          	add	t2,t2,t0
  24:	01c28463          	beq	t0,t3,2c <out>
  28:	fe000ae3          	beqz	zero,1c <loop>

0000002c <out>:
  2c:	007ea023          	sw	t2,0(t4)
  30:	005ea223          	sw	t0,4(t4)
  34:	000ea583          	lw	a1,0(t4)
  38:	004ea603          	lw	a2,4(t4)
  3c:	06400513          	li	a0,100
  40:	028000ef          	jal	ra,68 <write>
  44:	06f00513          	li	a0,111
  48:	020000ef          	jal	ra,68 <write>
  4c:	06e00513          	li	a0,110
  50:	018000ef          	jal	ra,68 <write>
  54:	06500513          	li	a0,101
  58:	010000ef          	jal	ra,68 <write>
  5c:	02100513          	li	a0,33
  60:	008000ef          	jal	ra,68 <write>
  64:	018000ef          	jal	ra,7c <end>

00000068 <write>:
  68:	005f0303          	lb	t1,5(t5) # 10000005 <__global_pointer$+0xfffe785>
  6c:	02037313          	andi	t1,t1,32
  70:	fe030ce3          	beqz	t1,68 <write>
  74:	00af0023          	sb	a0,0(t5)
  78:	00008067          	ret

0000007c <end>:
  7c:	00000063          	beqz	zero,7c <end>
