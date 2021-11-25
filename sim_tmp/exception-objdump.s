
exception.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	10000f37          	lui	t5,0x10000
   4:	06500513          	li	a0,101
   8:	01c000ef          	jal	ra,24 <write>
   c:	06400593          	li	a1,100
  10:	34159673          	csrrw	a2,mepc,a1
  14:	34161573          	csrrw	a0,mepc,a2
  18:	00c000ef          	jal	ra,24 <write>
  1c:	004000ef          	jal	ra,20 <end>

00000020 <end>:
  20:	00000063          	beqz	zero,20 <end>

00000024 <write>:
  24:	005f0303          	lb	t1,5(t5) # 10000005 <__global_pointer$+0xfffe7cd>
  28:	02037313          	andi	t1,t1,32
  2c:	fe030ce3          	beqz	t1,24 <write>
  30:	00af0023          	sb	a0,0(t5)
  34:	00008067          	ret
