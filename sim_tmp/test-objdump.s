
test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	800802b7          	lui	t0,0x80080
   4:	00128293          	addi	t0,t0,1 # 80080001 <__global_pointer$+0x8007e645>
   8:	18029073          	csrw	satp,t0
   c:	20001537          	lui	a0,0x20001
  10:	81150513          	addi	a0,a0,-2031 # 20000811 <__global_pointer$+0x1fffee55>
  14:	800022b7          	lui	t0,0x80002
  18:	80028293          	addi	t0,t0,-2048 # 80001800 <__global_pointer$+0x7ffffe44>
  1c:	00a2a023          	sw	a0,0(t0)
  20:	20001537          	lui	a0,0x20001
  24:	0d750513          	addi	a0,a0,215 # 200010d7 <__global_pointer$+0x1ffff71b>
  28:	800022b7          	lui	t0,0x80002
  2c:	00a2a623          	sw	a0,12(t0) # 8000200c <__global_pointer$+0x80000650>
  30:	20000537          	lui	a0,0x20000
  34:	01950513          	addi	a0,a0,25 # 20000019 <__global_pointer$+0x1fffe65d>
  38:	00a2a023          	sw	a0,0(t0)
  3c:	800004b7          	lui	s1,0x80000
  40:	08048493          	addi	s1,s1,128 # 80000080 <__global_pointer$+0x7fffe6c4>
  44:	34149073          	csrw	mepc,s1
  48:	00000513          	li	a0,0
  4c:	30051073          	csrw	mstatus,a0
  50:	06400513          	li	a0,100
  54:	800042b7          	lui	t0,0x80004
  58:	00a2a023          	sw	a0,0(t0) # 80004000 <__global_pointer$+0x80002644>
  5c:	fff00793          	li	a5,-1
  60:	ffe00793          	li	a5,-2
  64:	ffd00793          	li	a5,-3
  68:	80000537          	lui	a0,0x80000
  6c:	0b450513          	addi	a0,a0,180 # 800000b4 <__global_pointer$+0x7fffe6f8>
  70:	30551073          	csrw	mtvec,a0
  74:	80000537          	lui	a0,0x80000
  78:	34051073          	csrw	mscratch,a0
  7c:	30200073          	mret
  80:	ffc00793          	li	a5,-4
  84:	ffb00793          	li	a5,-5
  88:	ffa00793          	li	a5,-6
  8c:	810002b7          	lui	t0,0x81000
  90:	0800006f          	j	110 <UTEST_CRYPTONIGHT>
  94:	00100613          	li	a2,1
  98:	00200693          	li	a3,2
  9c:	00300713          	li	a4,3
  a0:	00c2a023          	sw	a2,0(t0) # 81000000 <__global_pointer$+0x80ffe644>
  a4:	00400793          	li	a5,4
  a8:	00500813          	li	a6,5
  ac:	00600893          	li	a7,6

000000b0 <end>:
  b0:	00000063          	beqz	zero,b0 <end>
  b4:	34011173          	csrrw	sp,mscratch,sp
  b8:	00112023          	sw	ra,0(sp)
  bc:	340110f3          	csrrw	ra,mscratch,sp
  c0:	34202573          	csrr	a0,mcause
  c4:	03550513          	addi	a0,a0,53 # 80000035 <__global_pointer$+0x7fffe679>
  c8:	0ff57513          	andi	a0,a0,255
  cc:	04100593          	li	a1,65
  d0:	00b54463          	blt	a0,a1,d8 <others>
  d4:	020000ef          	jal	ra,f4 <WRITE_SERIAL>

000000d8 <others>:
  d8:	800012b7          	lui	t0,0x80001
  dc:	a0028293          	addi	t0,t0,-1536 # 80000a00 <__global_pointer$+0x7ffff044>
  e0:	03100613          	li	a2,49
  e4:	00c2a023          	sw	a2,0(t0)
  e8:	0002a503          	lw	a0,0(t0)
  ec:	008000ef          	jal	ra,f4 <WRITE_SERIAL>

000000f0 <fin>:
  f0:	00000063          	beqz	zero,f0 <fin>

000000f4 <WRITE_SERIAL>:
  f4:	100002b7          	lui	t0,0x10000

000000f8 <.TESTW>:
  f8:	00528303          	lb	t1,5(t0) # 10000005 <__global_pointer$+0xfffe649>
  fc:	02037313          	andi	t1,t1,32
 100:	00031463          	bnez	t1,108 <.WSERIAL>
 104:	ff5ff06f          	j	f8 <.TESTW>

00000108 <.WSERIAL>:
 108:	00a28023          	sb	a0,0(t0)
 10c:	00008067          	ret

00000110 <UTEST_CRYPTONIGHT>:
 110:	80003537          	lui	a0,0x80003
 114:	000015b7          	lui	a1,0x1
 118:	7d000693          	li	a3,2000
 11c:	00001737          	lui	a4,0x1
 120:	ffc70713          	addi	a4,a4,-4 # ffc <.MAIN_LOOP+0xea0>
 124:	00a585b3          	add	a1,a1,a0
 128:	00100413          	li	s0,1
 12c:	00050613          	mv	a2,a0

00000130 <.INIT_LOOP>:
 130:	00862023          	sw	s0,0(a2)
 134:	00d41493          	slli	s1,s0,0xd
 138:	00944433          	xor	s0,s0,s1
 13c:	01145493          	srli	s1,s0,0x11
 140:	00944433          	xor	s0,s0,s1
 144:	00541493          	slli	s1,s0,0x5
 148:	00944433          	xor	s0,s0,s1
 14c:	00460613          	addi	a2,a2,4
 150:	feb610e3          	bne	a2,a1,130 <.INIT_LOOP>
 154:	00000613          	li	a2,0
 158:	00000293          	li	t0,0

0000015c <.MAIN_LOOP>:
 15c:	00e472b3          	and	t0,s0,a4
 160:	005502b3          	add	t0,a0,t0
 164:	0002a283          	lw	t0,0(t0)
 168:	0062c2b3          	xor	t0,t0,t1
 16c:	00544433          	xor	s0,s0,t0
 170:	00d41493          	slli	s1,s0,0xd
 174:	00944433          	xor	s0,s0,s1
 178:	01145493          	srli	s1,s0,0x11
 17c:	00944433          	xor	s0,s0,s1
 180:	00541493          	slli	s1,s0,0x5
 184:	00944433          	xor	s0,s0,s1
 188:	00e47333          	and	t1,s0,a4
 18c:	00650333          	add	t1,a0,t1
 190:	00532023          	sw	t0,0(t1)
 194:	00028313          	mv	t1,t0
 198:	00d41493          	slli	s1,s0,0xd
 19c:	00944433          	xor	s0,s0,s1
 1a0:	01145493          	srli	s1,s0,0x11
 1a4:	00944433          	xor	s0,s0,s1
 1a8:	00541493          	slli	s1,s0,0x5
 1ac:	00944433          	xor	s0,s0,s1
 1b0:	00160613          	addi	a2,a2,1
 1b4:	fad614e3          	bne	a2,a3,15c <.MAIN_LOOP>
 1b8:	00008067          	ret
