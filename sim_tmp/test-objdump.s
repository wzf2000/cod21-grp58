
test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	800802b7          	lui	t0,0x80080
   4:	4ab28293          	addi	t0,t0,1195 # 800804ab <__global_pointer$+0x8007eb1f>
   8:	18029073          	csrw	satp,t0
   c:	20000537          	lui	a0,0x20000
  10:	01f50513          	addi	a0,a0,31 # 2000001f <__global_pointer$+0x1fffe693>
  14:	804ac2b7          	lui	t0,0x804ac
  18:	80028293          	addi	t0,t0,-2048 # 804ab800 <__global_pointer$+0x804a9e74>
  1c:	00a2a023          	sw	a0,0(t0)
  20:	2012b537          	lui	a0,0x2012b
  24:	c0150513          	addi	a0,a0,-1023 # 2012ac01 <__global_pointer$+0x20129275>
  28:	804ac2b7          	lui	t0,0x804ac
  2c:	fac28293          	addi	t0,t0,-84 # 804abfac <__global_pointer$+0x804aa620>
  30:	00a2a023          	sw	a0,0(t0)
  34:	2012b537          	lui	a0,0x2012b
  38:	c0750513          	addi	a0,a0,-1017 # 2012ac07 <__global_pointer$+0x2012927b>
  3c:	804ac2b7          	lui	t0,0x804ac
  40:	fb028293          	addi	t0,t0,-80 # 804abfb0 <__global_pointer$+0x804aa624>
  44:	00a2a023          	sw	a0,0(t0)
  48:	2012b537          	lui	a0,0x2012b
  4c:	01150513          	addi	a0,a0,17 # 2012b011 <__global_pointer$+0x20129685>
  50:	804ac2b7          	lui	t0,0x804ac
  54:	80428293          	addi	t0,t0,-2044 # 804ab804 <__global_pointer$+0x804a9e78>
  58:	00a2a023          	sw	a0,0(t0)
  5c:	800004b7          	lui	s1,0x80000
  60:	07848493          	addi	s1,s1,120 # 80000078 <__global_pointer$+0x7fffe6ec>
  64:	34149073          	csrw	mepc,s1
  68:	00001537          	lui	a0,0x1
  6c:	80050513          	addi	a0,a0,-2048 # 800 <.MAIN_LOOP+0x6d4>
  70:	30051073          	csrw	mstatus,a0
  74:	30200073          	mret
  78:	06400513          	li	a0,100
  7c:	fafed2b7          	lui	t0,0xfafed
  80:	80428293          	addi	t0,t0,-2044 # fafec804 <__global_pointer$+0xfafeae78>
  84:	0002a503          	lw	a0,0(t0)
  88:	03c000ef          	jal	ra,c4 <WRITE_SERIAL>
  8c:	00455513          	srli	a0,a0,0x4
  90:	034000ef          	jal	ra,c4 <WRITE_SERIAL>
  94:	00455513          	srli	a0,a0,0x4
  98:	02c000ef          	jal	ra,c4 <WRITE_SERIAL>
  9c:	00455513          	srli	a0,a0,0x4
  a0:	024000ef          	jal	ra,c4 <WRITE_SERIAL>

000000a4 <end>:
  a4:	00000063          	beqz	zero,a4 <end>

000000a8 <others>:
  a8:	800012b7          	lui	t0,0x80001
  ac:	a0028293          	addi	t0,t0,-1536 # 80000a00 <__global_pointer$+0x7ffff074>
  b0:	03100613          	li	a2,49
  b4:	00c2a023          	sw	a2,0(t0)
  b8:	0002a503          	lw	a0,0(t0)
  bc:	008000ef          	jal	ra,c4 <WRITE_SERIAL>

000000c0 <fin>:
  c0:	00000063          	beqz	zero,c0 <fin>

000000c4 <WRITE_SERIAL>:
  c4:	100002b7          	lui	t0,0x10000

000000c8 <.TESTW>:
  c8:	00528303          	lb	t1,5(t0) # 10000005 <__global_pointer$+0xfffe679>
  cc:	02037313          	andi	t1,t1,32
  d0:	00031463          	bnez	t1,d8 <.WSERIAL>
  d4:	ff5ff06f          	j	c8 <.TESTW>

000000d8 <.WSERIAL>:
  d8:	00a28023          	sb	a0,0(t0)
  dc:	00008067          	ret

000000e0 <UTEST_CRYPTONIGHT>:
  e0:	80003537          	lui	a0,0x80003
  e4:	000015b7          	lui	a1,0x1
  e8:	7d000693          	li	a3,2000
  ec:	00001737          	lui	a4,0x1
  f0:	ffc70713          	addi	a4,a4,-4 # ffc <.MAIN_LOOP+0xed0>
  f4:	00a585b3          	add	a1,a1,a0
  f8:	00100413          	li	s0,1
  fc:	00050613          	mv	a2,a0

00000100 <.INIT_LOOP>:
 100:	00862023          	sw	s0,0(a2)
 104:	00d41493          	slli	s1,s0,0xd
 108:	00944433          	xor	s0,s0,s1
 10c:	01145493          	srli	s1,s0,0x11
 110:	00944433          	xor	s0,s0,s1
 114:	00541493          	slli	s1,s0,0x5
 118:	00944433          	xor	s0,s0,s1
 11c:	00460613          	addi	a2,a2,4
 120:	feb610e3          	bne	a2,a1,100 <.INIT_LOOP>
 124:	00000613          	li	a2,0
 128:	00000293          	li	t0,0

0000012c <.MAIN_LOOP>:
 12c:	00e472b3          	and	t0,s0,a4
 130:	005502b3          	add	t0,a0,t0
 134:	0002a283          	lw	t0,0(t0)
 138:	0062c2b3          	xor	t0,t0,t1
 13c:	00544433          	xor	s0,s0,t0
 140:	00d41493          	slli	s1,s0,0xd
 144:	00944433          	xor	s0,s0,s1
 148:	01145493          	srli	s1,s0,0x11
 14c:	00944433          	xor	s0,s0,s1
 150:	00541493          	slli	s1,s0,0x5
 154:	00944433          	xor	s0,s0,s1
 158:	00e47333          	and	t1,s0,a4
 15c:	00650333          	add	t1,a0,t1
 160:	00532023          	sw	t0,0(t1)
 164:	00028313          	mv	t1,t0
 168:	00d41493          	slli	s1,s0,0xd
 16c:	00944433          	xor	s0,s0,s1
 170:	01145493          	srli	s1,s0,0x11
 174:	00944433          	xor	s0,s0,s1
 178:	00541493          	slli	s1,s0,0x5
 17c:	00944433          	xor	s0,s0,s1
 180:	00160613          	addi	a2,a2,1
 184:	fad614e3          	bne	a2,a3,12c <.MAIN_LOOP>
 188:	00008067          	ret
