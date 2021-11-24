
lab5.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00000293          	li	t0,0
   4:	00000393          	li	t2,0
   8:	06400e13          	li	t3,100
   c:	06406e13          	ori	t3,zero,100
  10:	80000eb7          	lui	t4,0x80000
  14:	100e8e93          	addi	t4,t4,256 # 80000100 <__global_pointer$+0x7fffe878>
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
  3c:	00bea423          	sw	a1,8(t4)
  40:	00cea623          	sw	a2,12(t4)
  44:	06400513          	li	a0,100
  48:	028000ef          	jal	ra,70 <write>
  4c:	06f00513          	li	a0,111
  50:	020000ef          	jal	ra,70 <write>
  54:	06e00513          	li	a0,110
  58:	018000ef          	jal	ra,70 <write>
  5c:	06500513          	li	a0,101
  60:	010000ef          	jal	ra,70 <write>
  64:	02100513          	li	a0,33
  68:	008000ef          	jal	ra,70 <write>
  6c:	018000ef          	jal	ra,84 <end>

00000070 <write>:
  70:	005f0303          	lb	t1,5(t5) # 10000005 <__global_pointer$+0xfffe77d>
  74:	02037313          	andi	t1,t1,32
  78:	fe030ce3          	beqz	t1,70 <write>
  7c:	00af0023          	sb	a0,0(t5)
  80:	00008067          	ret

00000084 <end>:
  84:	00000063          	beqz	zero,84 <end>
