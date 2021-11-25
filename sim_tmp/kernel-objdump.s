
kernel.elf:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <INITLOCATE>:
80000000:	00000d17          	auipc	s10,0x0
80000004:	00cd0d13          	addi	s10,s10,12 # 8000000c <START>
80000008:	000d0067          	jr	s10

8000000c <START>:
8000000c:	007f0d17          	auipc	s10,0x7f0
80000010:	ff4d0d13          	addi	s10,s10,-12 # 807f0000 <_sbss>
80000014:	007f0d97          	auipc	s11,0x7f0
80000018:	104d8d93          	addi	s11,s11,260 # 807f0118 <_ebss>

8000001c <bss_init>:
8000001c:	01bd0863          	beq	s10,s11,8000002c <bss_init_done>
80000020:	000d2023          	sw	zero,0(s10)
80000024:	004d0d13          	addi	s10,s10,4
80000028:	ff5ff06f          	j	8000001c <bss_init>

8000002c <bss_init_done>:
8000002c:	00000417          	auipc	s0,0x0
80000030:	5d440413          	addi	s0,s0,1492 # 80000600 <EXCEPTION_HANDLER>
80000034:	30541073          	csrw	mtvec,s0
80000038:	305022f3          	csrr	t0,mtvec
8000003c:	00828a63          	beq	t0,s0,80000050 <mtvec_done>
80000040:	00000417          	auipc	s0,0x0
80000044:	7c040413          	addi	s0,s0,1984 # 80000800 <VECTORED_EXCEPTION_HANDLER>
80000048:	00146413          	ori	s0,s0,1
8000004c:	30541073          	csrw	mtvec,s0

80000050 <mtvec_done>:
80000050:	08000293          	li	t0,128
80000054:	30429073          	csrw	mie,t0
80000058:	00800117          	auipc	sp,0x800
8000005c:	fa810113          	addi	sp,sp,-88 # 80800000 <KERNEL_STACK_INIT>
80000060:	800002b7          	lui	t0,0x80000
80000064:	007f0317          	auipc	t1,0x7f0
80000068:	fa030313          	addi	t1,t1,-96 # 807f0004 <uregs_sp>
8000006c:	00532023          	sw	t0,0(t1)
80000070:	007f0317          	auipc	t1,0x7f0
80000074:	fac30313          	addi	t1,t1,-84 # 807f001c <uregs_fp>
80000078:	00532023          	sw	t0,0(t1)
8000007c:	100002b7          	lui	t0,0x10000
80000080:	00700313          	li	t1,7
80000084:	00628123          	sb	t1,2(t0) # 10000002 <INITLOCATE-0x6ffffffe>
80000088:	08000313          	li	t1,128
8000008c:	006281a3          	sb	t1,3(t0)
80000090:	00c00313          	li	t1,12
80000094:	00628023          	sb	t1,0(t0)
80000098:	000280a3          	sb	zero,1(t0)
8000009c:	00300313          	li	t1,3
800000a0:	006281a3          	sb	t1,3(t0)
800000a4:	00028223          	sb	zero,4(t0)
800000a8:	00100313          	li	t1,1
800000ac:	006280a3          	sb	t1,1(t0)
800000b0:	08000293          	li	t0,128
800000b4:	ffc28293          	addi	t0,t0,-4
800000b8:	ffc10113          	addi	sp,sp,-4
800000bc:	00012023          	sw	zero,0(sp)
800000c0:	fe029ae3          	bnez	t0,800000b4 <mtvec_done+0x64>
800000c4:	007f0297          	auipc	t0,0x7f0
800000c8:	03c28293          	addi	t0,t0,60 # 807f0100 <TCBT>
800000cc:	0022a023          	sw	sp,0(t0)
800000d0:	00010f93          	mv	t6,sp
800000d4:	08000293          	li	t0,128
800000d8:	ffc28293          	addi	t0,t0,-4
800000dc:	ffc10113          	addi	sp,sp,-4
800000e0:	00012023          	sw	zero,0(sp)
800000e4:	fe029ae3          	bnez	t0,800000d8 <mtvec_done+0x88>
800000e8:	007f0297          	auipc	t0,0x7f0
800000ec:	01828293          	addi	t0,t0,24 # 807f0100 <TCBT>
800000f0:	0022a223          	sw	sp,4(t0)
800000f4:	002fa223          	sw	sp,4(t6)
800000f8:	007f0397          	auipc	t2,0x7f0
800000fc:	00c38393          	addi	t2,t2,12 # 807f0104 <TCBT+0x4>
80000100:	0003a383          	lw	t2,0(t2)
80000104:	34039073          	csrw	mscratch,t2
80000108:	007f0317          	auipc	t1,0x7f0
8000010c:	00830313          	addi	t1,t1,8 # 807f0110 <current>
80000110:	00732023          	sw	t2,0(t1)
80000114:	00002297          	auipc	t0,0x2
80000118:	eec28293          	addi	t0,t0,-276 # 80002000 <PAGE_TABLE>
8000011c:	00003317          	auipc	t1,0x3
80000120:	ee430313          	addi	t1,t1,-284 # 80003000 <PAGE_TABLE_USER_CODE>
80000124:	30000e13          	li	t3,768
80000128:	00000393          	li	t2,0
8000012c:	20040eb7          	lui	t4,0x20040
80000130:	0fbe8e93          	addi	t4,t4,251 # 200400fb <INITLOCATE-0x5ffbff05>
80000134:	00a39f13          	slli	t5,t2,0xa
80000138:	01ee8eb3          	add	t4,t4,t5
8000013c:	01d32023          	sw	t4,0(t1)
80000140:	00430313          	addi	t1,t1,4
80000144:	00138393          	addi	t2,t2,1
80000148:	ffc392e3          	bne	t2,t3,8000012c <mtvec_done+0xdc>
8000014c:	00003317          	auipc	t1,0x3
80000150:	eb430313          	addi	t1,t1,-332 # 80003000 <PAGE_TABLE_USER_CODE>
80000154:	00235313          	srli	t1,t1,0x2
80000158:	0f136313          	ori	t1,t1,241
8000015c:	0062a023          	sw	t1,0(t0)
80000160:	00002297          	auipc	t0,0x2
80000164:	ea028293          	addi	t0,t0,-352 # 80002000 <PAGE_TABLE>
80000168:	00004317          	auipc	t1,0x4
8000016c:	e9830313          	addi	t1,t1,-360 # 80004000 <PAGE_TABLE_KERNEL_CODE>
80000170:	00235313          	srli	t1,t1,0x2
80000174:	0f136313          	ori	t1,t1,241
80000178:	000013b7          	lui	t2,0x1
8000017c:	80038393          	addi	t2,t2,-2048 # 800 <INITLOCATE-0x7ffff800>
80000180:	007283b3          	add	t2,t0,t2
80000184:	0063a023          	sw	t1,0(t2)
80000188:	00005317          	auipc	t1,0x5
8000018c:	e7830313          	addi	t1,t1,-392 # 80005000 <PAGE_TABLE_USER_STACK>
80000190:	04030313          	addi	t1,t1,64
80000194:	40000e13          	li	t3,1024
80000198:	01000393          	li	t2,16
8000019c:	200fceb7          	lui	t4,0x200fc
800001a0:	0f7e8e93          	addi	t4,t4,247 # 200fc0f7 <INITLOCATE-0x5ff03f09>
800001a4:	00a39f13          	slli	t5,t2,0xa
800001a8:	01ee8eb3          	add	t4,t4,t5
800001ac:	01d32023          	sw	t4,0(t1)
800001b0:	00430313          	addi	t1,t1,4
800001b4:	00138393          	addi	t2,t2,1
800001b8:	ffc392e3          	bne	t2,t3,8000019c <mtvec_done+0x14c>
800001bc:	00005317          	auipc	t1,0x5
800001c0:	e4430313          	addi	t1,t1,-444 # 80005000 <PAGE_TABLE_USER_STACK>
800001c4:	00235313          	srli	t1,t1,0x2
800001c8:	0f136313          	ori	t1,t1,241
800001cc:	7fc00393          	li	t2,2044
800001d0:	007283b3          	add	t2,t0,t2
800001d4:	0063a023          	sw	t1,0(t2)
800001d8:	00002297          	auipc	t0,0x2
800001dc:	e2828293          	addi	t0,t0,-472 # 80002000 <PAGE_TABLE>
800001e0:	00c2d293          	srli	t0,t0,0xc
800001e4:	80000337          	lui	t1,0x80000
800001e8:	0062e2b3          	or	t0,t0,t1
800001ec:	18029073          	csrw	satp,t0
800001f0:	12000073          	sfence.vma
800001f4:	00f00293          	li	t0,15
800001f8:	3a029073          	csrw	pmpcfg0,t0
800001fc:	fff00293          	li	t0,-1
80000200:	3b029073          	csrw	pmpaddr0,t0
80000204:	0040006f          	j	80000208 <WELCOME>

80000208 <WELCOME>:
80000208:	00001517          	auipc	a0,0x1
8000020c:	f7c50513          	addi	a0,a0,-132 # 80001184 <monitor_version>
80000210:	7e8000ef          	jal	ra,800009f8 <WRITE_SERIAL_STRING>
80000214:	0040006f          	j	80000218 <SHELL>

80000218 <SHELL>:
80000218:	001000ef          	jal	ra,80000a18 <READ_SERIAL>
8000021c:	05200293          	li	t0,82
80000220:	06550a63          	beq	a0,t0,80000294 <.OP_R>
80000224:	04400293          	li	t0,68
80000228:	0a550463          	beq	a0,t0,800002d0 <.OP_D>
8000022c:	04100293          	li	t0,65
80000230:	0e550063          	beq	a0,t0,80000310 <.OP_A>
80000234:	04700293          	li	t0,71
80000238:	10550e63          	beq	a0,t0,80000354 <.OP_G>
8000023c:	05400293          	li	t0,84
80000240:	00550863          	beq	a0,t0,80000250 <.OP_T>
80000244:	00400513          	li	a0,4
80000248:	72c000ef          	jal	ra,80000974 <WRITE_SERIAL>
8000024c:	2d00006f          	j	8000051c <.DONE>

80000250 <.OP_T>:
80000250:	ff410113          	addi	sp,sp,-12
80000254:	00912023          	sw	s1,0(sp)
80000258:	01212223          	sw	s2,4(sp)
8000025c:	180024f3          	csrr	s1,satp
80000260:	00c49493          	slli	s1,s1,0xc
80000264:	00912423          	sw	s1,8(sp)
80000268:	00810493          	addi	s1,sp,8
8000026c:	00400913          	li	s2,4
80000270:	00048503          	lb	a0,0(s1)
80000274:	fff90913          	addi	s2,s2,-1
80000278:	6fc000ef          	jal	ra,80000974 <WRITE_SERIAL>
8000027c:	00148493          	addi	s1,s1,1
80000280:	fe0918e3          	bnez	s2,80000270 <.OP_T+0x20>
80000284:	00012483          	lw	s1,0(sp)
80000288:	00412903          	lw	s2,4(sp)
8000028c:	00c10113          	addi	sp,sp,12
80000290:	28c0006f          	j	8000051c <.DONE>

80000294 <.OP_R>:
80000294:	ff810113          	addi	sp,sp,-8
80000298:	00912023          	sw	s1,0(sp)
8000029c:	01212223          	sw	s2,4(sp)
800002a0:	007f0497          	auipc	s1,0x7f0
800002a4:	d6048493          	addi	s1,s1,-672 # 807f0000 <_sbss>
800002a8:	07c00913          	li	s2,124
800002ac:	00048503          	lb	a0,0(s1)
800002b0:	fff90913          	addi	s2,s2,-1
800002b4:	6c0000ef          	jal	ra,80000974 <WRITE_SERIAL>
800002b8:	00148493          	addi	s1,s1,1
800002bc:	fe0918e3          	bnez	s2,800002ac <.OP_R+0x18>
800002c0:	00012483          	lw	s1,0(sp)
800002c4:	00412903          	lw	s2,4(sp)
800002c8:	00810113          	addi	sp,sp,8
800002cc:	2500006f          	j	8000051c <.DONE>

800002d0 <.OP_D>:
800002d0:	ff810113          	addi	sp,sp,-8
800002d4:	00912023          	sw	s1,0(sp)
800002d8:	01212223          	sw	s2,4(sp)
800002dc:	7d8000ef          	jal	ra,80000ab4 <READ_SERIAL_XLEN>
800002e0:	000564b3          	or	s1,a0,zero
800002e4:	7d0000ef          	jal	ra,80000ab4 <READ_SERIAL_XLEN>
800002e8:	00056933          	or	s2,a0,zero
800002ec:	00048503          	lb	a0,0(s1)
800002f0:	fff90913          	addi	s2,s2,-1
800002f4:	680000ef          	jal	ra,80000974 <WRITE_SERIAL>
800002f8:	00148493          	addi	s1,s1,1
800002fc:	fe0918e3          	bnez	s2,800002ec <.OP_D+0x1c>
80000300:	00012483          	lw	s1,0(sp)
80000304:	00412903          	lw	s2,4(sp)
80000308:	00810113          	addi	sp,sp,8
8000030c:	2100006f          	j	8000051c <.DONE>

80000310 <.OP_A>:
80000310:	ff810113          	addi	sp,sp,-8
80000314:	00912023          	sw	s1,0(sp)
80000318:	01212223          	sw	s2,4(sp)
8000031c:	798000ef          	jal	ra,80000ab4 <READ_SERIAL_XLEN>
80000320:	000564b3          	or	s1,a0,zero
80000324:	790000ef          	jal	ra,80000ab4 <READ_SERIAL_XLEN>
80000328:	00056933          	or	s2,a0,zero
8000032c:	00295913          	srli	s2,s2,0x2
80000330:	704000ef          	jal	ra,80000a34 <READ_SERIAL_WORD>
80000334:	00a4a023          	sw	a0,0(s1)
80000338:	fff90913          	addi	s2,s2,-1
8000033c:	00448493          	addi	s1,s1,4
80000340:	fe0918e3          	bnez	s2,80000330 <.OP_A+0x20>
80000344:	00012483          	lw	s1,0(sp)
80000348:	00412903          	lw	s2,4(sp)
8000034c:	00810113          	addi	sp,sp,8
80000350:	1cc0006f          	j	8000051c <.DONE>

80000354 <.OP_G>:
80000354:	760000ef          	jal	ra,80000ab4 <READ_SERIAL_XLEN>
80000358:	00050d13          	mv	s10,a0
8000035c:	00600513          	li	a0,6
80000360:	614000ef          	jal	ra,80000974 <WRITE_SERIAL>
80000364:	341d1073          	csrw	mepc,s10
80000368:	00002537          	lui	a0,0x2
8000036c:	80050513          	addi	a0,a0,-2048 # 1800 <INITLOCATE-0x7fffe800>
80000370:	30053073          	csrc	mstatus,a0
80000374:	0200c2b7          	lui	t0,0x200c
80000378:	ff828293          	addi	t0,t0,-8 # 200bff8 <INITLOCATE-0x7dff4008>
8000037c:	0002a303          	lw	t1,0(t0)
80000380:	0042a383          	lw	t2,4(t0)
80000384:	00989e37          	lui	t3,0x989
80000388:	680e0e13          	addi	t3,t3,1664 # 989680 <INITLOCATE-0x7f676980>
8000038c:	01c30e33          	add	t3,t1,t3
80000390:	006e3333          	sltu	t1,t3,t1
80000394:	006383b3          	add	t2,t2,t1
80000398:	020042b7          	lui	t0,0x2004
8000039c:	0072a223          	sw	t2,4(t0) # 2004004 <INITLOCATE-0x7dffbffc>
800003a0:	01c2a023          	sw	t3,0(t0)
800003a4:	007f0097          	auipc	ra,0x7f0
800003a8:	c5c08093          	addi	ra,ra,-932 # 807f0000 <_sbss>
800003ac:	0820a023          	sw	sp,128(ra)
800003b0:	0040a103          	lw	sp,4(ra)
800003b4:	0080a183          	lw	gp,8(ra)
800003b8:	00c0a203          	lw	tp,12(ra)
800003bc:	0100a283          	lw	t0,16(ra)
800003c0:	0140a303          	lw	t1,20(ra)
800003c4:	0180a383          	lw	t2,24(ra)
800003c8:	01c0a403          	lw	s0,28(ra)
800003cc:	0200a483          	lw	s1,32(ra)
800003d0:	0240a503          	lw	a0,36(ra)
800003d4:	0280a583          	lw	a1,40(ra)
800003d8:	02c0a603          	lw	a2,44(ra)
800003dc:	0300a683          	lw	a3,48(ra)
800003e0:	0340a703          	lw	a4,52(ra)
800003e4:	0380a783          	lw	a5,56(ra)
800003e8:	03c0a803          	lw	a6,60(ra)
800003ec:	0400a883          	lw	a7,64(ra)
800003f0:	0440a903          	lw	s2,68(ra)
800003f4:	0480a983          	lw	s3,72(ra)
800003f8:	04c0aa03          	lw	s4,76(ra)
800003fc:	0500aa83          	lw	s5,80(ra)
80000400:	0540ab03          	lw	s6,84(ra)
80000404:	0580ab83          	lw	s7,88(ra)
80000408:	05c0ac03          	lw	s8,92(ra)
8000040c:	0600ac83          	lw	s9,96(ra)
80000410:	0680ad83          	lw	s11,104(ra)
80000414:	06c0ae03          	lw	t3,108(ra)
80000418:	0700ae83          	lw	t4,112(ra)
8000041c:	0740af03          	lw	t5,116(ra)
80000420:	0780af83          	lw	t6,120(ra)

80000424 <.ENTER_UESR>:
80000424:	00000097          	auipc	ra,0x0
80000428:	00c08093          	addi	ra,ra,12 # 80000430 <.USERRET_USER>
8000042c:	30200073          	mret

80000430 <.USERRET_USER>:
80000430:	00100073          	ebreak

80000434 <USERRET_TIMEOUT>:
80000434:	08100513          	li	a0,129
80000438:	53c000ef          	jal	ra,80000974 <WRITE_SERIAL>
8000043c:	00c0006f          	j	80000448 <USERRET_MACHINE+0x8>

80000440 <USERRET_MACHINE>:
80000440:	00700513          	li	a0,7
80000444:	530000ef          	jal	ra,80000974 <WRITE_SERIAL>
80000448:	007f0497          	auipc	s1,0x7f0
8000044c:	bb848493          	addi	s1,s1,-1096 # 807f0000 <_sbss>
80000450:	08000913          	li	s2,128
80000454:	00012503          	lw	a0,0(sp)
80000458:	00a4a023          	sw	a0,0(s1)
8000045c:	ffc90913          	addi	s2,s2,-4
80000460:	00448493          	addi	s1,s1,4
80000464:	00410113          	addi	sp,sp,4
80000468:	fe0916e3          	bnez	s2,80000454 <USERRET_MACHINE+0x14>
8000046c:	007f0497          	auipc	s1,0x7f0
80000470:	b9448493          	addi	s1,s1,-1132 # 807f0000 <_sbss>
80000474:	0804a103          	lw	sp,128(s1)
80000478:	0a40006f          	j	8000051c <.DONE>

8000047c <.USERRET2>:
8000047c:	007f0097          	auipc	ra,0x7f0
80000480:	b8408093          	addi	ra,ra,-1148 # 807f0000 <_sbss>
80000484:	0020a223          	sw	sp,4(ra)
80000488:	0030a423          	sw	gp,8(ra)
8000048c:	0040a623          	sw	tp,12(ra)
80000490:	0050a823          	sw	t0,16(ra)
80000494:	0060aa23          	sw	t1,20(ra)
80000498:	0070ac23          	sw	t2,24(ra)
8000049c:	0080ae23          	sw	s0,28(ra)
800004a0:	0290a023          	sw	s1,32(ra)
800004a4:	02a0a223          	sw	a0,36(ra)
800004a8:	02b0a423          	sw	a1,40(ra)
800004ac:	02c0a623          	sw	a2,44(ra)
800004b0:	02d0a823          	sw	a3,48(ra)
800004b4:	02e0aa23          	sw	a4,52(ra)
800004b8:	02f0ac23          	sw	a5,56(ra)
800004bc:	0300ae23          	sw	a6,60(ra)
800004c0:	0510a023          	sw	a7,64(ra)
800004c4:	0520a223          	sw	s2,68(ra)
800004c8:	0530a423          	sw	s3,72(ra)
800004cc:	0540a623          	sw	s4,76(ra)
800004d0:	0550a823          	sw	s5,80(ra)
800004d4:	0560aa23          	sw	s6,84(ra)
800004d8:	0570ac23          	sw	s7,88(ra)
800004dc:	0580ae23          	sw	s8,92(ra)
800004e0:	0790a023          	sw	s9,96(ra)
800004e4:	07a0a223          	sw	s10,100(ra)
800004e8:	07b0a423          	sw	s11,104(ra)
800004ec:	07c0a623          	sw	t3,108(ra)
800004f0:	07d0a823          	sw	t4,112(ra)
800004f4:	07e0aa23          	sw	t5,116(ra)
800004f8:	07f0ac23          	sw	t6,120(ra)
800004fc:	0800a103          	lw	sp,128(ra)
80000500:	00008513          	mv	a0,ra
80000504:	00000097          	auipc	ra,0x0
80000508:	f7808093          	addi	ra,ra,-136 # 8000047c <.USERRET2>
8000050c:	00152023          	sw	ra,0(a0)
80000510:	00700513          	li	a0,7
80000514:	460000ef          	jal	ra,80000974 <WRITE_SERIAL>
80000518:	0040006f          	j	8000051c <.DONE>

8000051c <.DONE>:
8000051c:	cfdff06f          	j	80000218 <SHELL>
	...

80000600 <EXCEPTION_HANDLER>:
80000600:	34011173          	csrrw	sp,mscratch,sp
80000604:	00112023          	sw	ra,0(sp)
80000608:	340110f3          	csrrw	ra,mscratch,sp
8000060c:	00112223          	sw	ra,4(sp)
80000610:	00312423          	sw	gp,8(sp)
80000614:	00412623          	sw	tp,12(sp)
80000618:	00512823          	sw	t0,16(sp)
8000061c:	00612a23          	sw	t1,20(sp)
80000620:	00712c23          	sw	t2,24(sp)
80000624:	00812e23          	sw	s0,28(sp)
80000628:	02912023          	sw	s1,32(sp)
8000062c:	02a12223          	sw	a0,36(sp)
80000630:	02b12423          	sw	a1,40(sp)
80000634:	02c12623          	sw	a2,44(sp)
80000638:	02d12823          	sw	a3,48(sp)
8000063c:	02e12a23          	sw	a4,52(sp)
80000640:	02f12c23          	sw	a5,56(sp)
80000644:	03012e23          	sw	a6,60(sp)
80000648:	05112023          	sw	a7,64(sp)
8000064c:	05212223          	sw	s2,68(sp)
80000650:	05312423          	sw	s3,72(sp)
80000654:	05412623          	sw	s4,76(sp)
80000658:	05512823          	sw	s5,80(sp)
8000065c:	05612a23          	sw	s6,84(sp)
80000660:	05712c23          	sw	s7,88(sp)
80000664:	05812e23          	sw	s8,92(sp)
80000668:	07912023          	sw	s9,96(sp)
8000066c:	07a12223          	sw	s10,100(sp)
80000670:	07b12423          	sw	s11,104(sp)
80000674:	07c12623          	sw	t3,108(sp)
80000678:	07d12823          	sw	t4,112(sp)
8000067c:	07e12a23          	sw	t5,116(sp)
80000680:	07f12c23          	sw	t6,120(sp)
80000684:	341022f3          	csrr	t0,mepc
80000688:	06512e23          	sw	t0,124(sp)
8000068c:	342022f3          	csrr	t0,mcause
80000690:	80000337          	lui	t1,0x80000
80000694:	00730313          	addi	t1,t1,7 # 80000007 <KERNEL_STACK_INIT+0xff800007>
80000698:	04530a63          	beq	t1,t0,800006ec <.HANDLE_TIMER>
8000069c:	80000337          	lui	t1,0x80000
800006a0:	0062f333          	and	t1,t0,t1
800006a4:	04031263          	bnez	t1,800006e8 <.HANDLE_INT>
800006a8:	00800313          	li	t1,8
800006ac:	00530863          	beq	t1,t0,800006bc <.HANDLE_ECALL>
800006b0:	00300313          	li	t1,3
800006b4:	02530863          	beq	t1,t0,800006e4 <.HANDLE_BREAK>
800006b8:	2480006f          	j	80000900 <FATAL>

800006bc <.HANDLE_ECALL>:
800006bc:	07c12283          	lw	t0,124(sp)
800006c0:	00428293          	addi	t0,t0,4
800006c4:	06512e23          	sw	t0,124(sp)
800006c8:	01c12283          	lw	t0,28(sp)
800006cc:	01e00313          	li	t1,30
800006d0:	00628463          	beq	t0,t1,800006d8 <.HANDLE_ECALL_PUTC>
800006d4:	0300006f          	j	80000704 <CONTEXT_SWITCH>

800006d8 <.HANDLE_ECALL_PUTC>:
800006d8:	02412503          	lw	a0,36(sp)
800006dc:	298000ef          	jal	ra,80000974 <WRITE_SERIAL>
800006e0:	0240006f          	j	80000704 <CONTEXT_SWITCH>

800006e4 <.HANDLE_BREAK>:
800006e4:	d5dff06f          	j	80000440 <USERRET_MACHINE>

800006e8 <.HANDLE_INT>:
800006e8:	2180006f          	j	80000900 <FATAL>

800006ec <.HANDLE_TIMER>:
800006ec:	300022f3          	csrr	t0,mstatus
800006f0:	00002337          	lui	t1,0x2
800006f4:	80030313          	addi	t1,t1,-2048 # 1800 <INITLOCATE-0x7fffe800>
800006f8:	0062f2b3          	and	t0,t0,t1
800006fc:	00029463          	bnez	t0,80000704 <CONTEXT_SWITCH>
80000700:	d35ff06f          	j	80000434 <USERRET_TIMEOUT>

80000704 <CONTEXT_SWITCH>:
80000704:	07c12283          	lw	t0,124(sp)
80000708:	34129073          	csrw	mepc,t0
8000070c:	00012083          	lw	ra,0(sp)
80000710:	00812183          	lw	gp,8(sp)
80000714:	00c12203          	lw	tp,12(sp)
80000718:	01012283          	lw	t0,16(sp)
8000071c:	01412303          	lw	t1,20(sp)
80000720:	01812383          	lw	t2,24(sp)
80000724:	01c12403          	lw	s0,28(sp)
80000728:	02012483          	lw	s1,32(sp)
8000072c:	02412503          	lw	a0,36(sp)
80000730:	02812583          	lw	a1,40(sp)
80000734:	02c12603          	lw	a2,44(sp)
80000738:	03012683          	lw	a3,48(sp)
8000073c:	03412703          	lw	a4,52(sp)
80000740:	03812783          	lw	a5,56(sp)
80000744:	03c12803          	lw	a6,60(sp)
80000748:	04012883          	lw	a7,64(sp)
8000074c:	04412903          	lw	s2,68(sp)
80000750:	04812983          	lw	s3,72(sp)
80000754:	04c12a03          	lw	s4,76(sp)
80000758:	05012a83          	lw	s5,80(sp)
8000075c:	05412b03          	lw	s6,84(sp)
80000760:	05812b83          	lw	s7,88(sp)
80000764:	05c12c03          	lw	s8,92(sp)
80000768:	06012c83          	lw	s9,96(sp)
8000076c:	06412d03          	lw	s10,100(sp)
80000770:	06812d83          	lw	s11,104(sp)
80000774:	06c12e03          	lw	t3,108(sp)
80000778:	07012e83          	lw	t4,112(sp)
8000077c:	07412f03          	lw	t5,116(sp)
80000780:	07812f83          	lw	t6,120(sp)
80000784:	34011073          	csrw	mscratch,sp
80000788:	00412103          	lw	sp,4(sp)
8000078c:	30200073          	mret
80000790:	00000013          	nop
80000794:	00000013          	nop
80000798:	00000013          	nop
8000079c:	00000013          	nop
800007a0:	00000013          	nop
800007a4:	00000013          	nop
800007a8:	00000013          	nop
800007ac:	00000013          	nop
800007b0:	00000013          	nop
800007b4:	00000013          	nop
800007b8:	00000013          	nop
800007bc:	00000013          	nop
800007c0:	00000013          	nop
800007c4:	00000013          	nop
800007c8:	00000013          	nop
800007cc:	00000013          	nop
800007d0:	00000013          	nop
800007d4:	00000013          	nop
800007d8:	00000013          	nop
800007dc:	00000013          	nop
800007e0:	00000013          	nop
800007e4:	00000013          	nop
800007e8:	00000013          	nop
800007ec:	00000013          	nop
800007f0:	00000013          	nop
800007f4:	00000013          	nop
800007f8:	00000013          	nop
800007fc:	00000013          	nop

80000800 <VECTORED_EXCEPTION_HANDLER>:
80000800:	e01ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000804:	dfdff06f          	j	80000600 <EXCEPTION_HANDLER>
80000808:	df9ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000080c:	df5ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000810:	df1ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000814:	dedff06f          	j	80000600 <EXCEPTION_HANDLER>
80000818:	de9ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000081c:	de5ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000820:	de1ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000824:	dddff06f          	j	80000600 <EXCEPTION_HANDLER>
80000828:	dd9ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000082c:	dd5ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000830:	dd1ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000834:	dcdff06f          	j	80000600 <EXCEPTION_HANDLER>
80000838:	dc9ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000083c:	dc5ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000840:	dc1ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000844:	dbdff06f          	j	80000600 <EXCEPTION_HANDLER>
80000848:	db9ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000084c:	db5ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000850:	db1ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000854:	dadff06f          	j	80000600 <EXCEPTION_HANDLER>
80000858:	da9ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000085c:	da5ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000860:	da1ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000864:	d9dff06f          	j	80000600 <EXCEPTION_HANDLER>
80000868:	d99ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000086c:	d95ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000870:	d91ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000874:	d8dff06f          	j	80000600 <EXCEPTION_HANDLER>
80000878:	d89ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000087c:	d85ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000880:	d81ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000884:	d7dff06f          	j	80000600 <EXCEPTION_HANDLER>
80000888:	d79ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000088c:	d75ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000890:	d71ff06f          	j	80000600 <EXCEPTION_HANDLER>
80000894:	d6dff06f          	j	80000600 <EXCEPTION_HANDLER>
80000898:	d69ff06f          	j	80000600 <EXCEPTION_HANDLER>
8000089c:	d65ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008a0:	d61ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008a4:	d5dff06f          	j	80000600 <EXCEPTION_HANDLER>
800008a8:	d59ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008ac:	d55ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008b0:	d51ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008b4:	d4dff06f          	j	80000600 <EXCEPTION_HANDLER>
800008b8:	d49ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008bc:	d45ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008c0:	d41ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008c4:	d3dff06f          	j	80000600 <EXCEPTION_HANDLER>
800008c8:	d39ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008cc:	d35ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008d0:	d31ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008d4:	d2dff06f          	j	80000600 <EXCEPTION_HANDLER>
800008d8:	d29ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008dc:	d25ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008e0:	d21ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008e4:	d1dff06f          	j	80000600 <EXCEPTION_HANDLER>
800008e8:	d19ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008ec:	d15ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008f0:	d11ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008f4:	d0dff06f          	j	80000600 <EXCEPTION_HANDLER>
800008f8:	d09ff06f          	j	80000600 <EXCEPTION_HANDLER>
800008fc:	d05ff06f          	j	80000600 <EXCEPTION_HANDLER>

80000900 <FATAL>:
80000900:	08000513          	li	a0,128
80000904:	070000ef          	jal	ra,80000974 <WRITE_SERIAL>
80000908:	34102573          	csrr	a0,mepc
8000090c:	0d4000ef          	jal	ra,800009e0 <WRITE_SERIAL_XLEN>
80000910:	34202573          	csrr	a0,mcause
80000914:	0cc000ef          	jal	ra,800009e0 <WRITE_SERIAL_XLEN>
80000918:	34302573          	csrr	a0,mtval
8000091c:	0c4000ef          	jal	ra,800009e0 <WRITE_SERIAL_XLEN>
80000920:	fffff517          	auipc	a0,0xfffff
80000924:	6ec50513          	addi	a0,a0,1772 # 8000000c <START>
80000928:	00050067          	jr	a0
	...

80000974 <WRITE_SERIAL>:
80000974:	100002b7          	lui	t0,0x10000

80000978 <.TESTW>:
80000978:	00528303          	lb	t1,5(t0) # 10000005 <INITLOCATE-0x6ffffffb>
8000097c:	02037313          	andi	t1,t1,32
80000980:	00031463          	bnez	t1,80000988 <.WSERIAL>
80000984:	ff5ff06f          	j	80000978 <.TESTW>

80000988 <.WSERIAL>:
80000988:	00a28023          	sb	a0,0(t0)
8000098c:	00008067          	ret

80000990 <WRITE_SERIAL_WORD>:
80000990:	ff810113          	addi	sp,sp,-8
80000994:	00112023          	sw	ra,0(sp)
80000998:	00812223          	sw	s0,4(sp)
8000099c:	00050413          	mv	s0,a0
800009a0:	0ff57513          	andi	a0,a0,255
800009a4:	fd1ff0ef          	jal	ra,80000974 <WRITE_SERIAL>
800009a8:	00845513          	srli	a0,s0,0x8
800009ac:	0ff57513          	andi	a0,a0,255
800009b0:	fc5ff0ef          	jal	ra,80000974 <WRITE_SERIAL>
800009b4:	01045513          	srli	a0,s0,0x10
800009b8:	0ff57513          	andi	a0,a0,255
800009bc:	fb9ff0ef          	jal	ra,80000974 <WRITE_SERIAL>
800009c0:	01845513          	srli	a0,s0,0x18
800009c4:	0ff57513          	andi	a0,a0,255
800009c8:	fadff0ef          	jal	ra,80000974 <WRITE_SERIAL>
800009cc:	00040513          	mv	a0,s0
800009d0:	00012083          	lw	ra,0(sp)
800009d4:	00412403          	lw	s0,4(sp)
800009d8:	00810113          	addi	sp,sp,8
800009dc:	00008067          	ret

800009e0 <WRITE_SERIAL_XLEN>:
800009e0:	ffc10113          	addi	sp,sp,-4
800009e4:	00112023          	sw	ra,0(sp)
800009e8:	fa9ff0ef          	jal	ra,80000990 <WRITE_SERIAL_WORD>
800009ec:	00012083          	lw	ra,0(sp)
800009f0:	00410113          	addi	sp,sp,4
800009f4:	00008067          	ret

800009f8 <WRITE_SERIAL_STRING>:
800009f8:	00050593          	mv	a1,a0
800009fc:	00008613          	mv	a2,ra
80000a00:	00058503          	lb	a0,0(a1)
80000a04:	f71ff0ef          	jal	ra,80000974 <WRITE_SERIAL>
80000a08:	00158593          	addi	a1,a1,1
80000a0c:	00058503          	lb	a0,0(a1)
80000a10:	fe051ae3          	bnez	a0,80000a04 <WRITE_SERIAL_STRING+0xc>
80000a14:	00060067          	jr	a2

80000a18 <READ_SERIAL>:
80000a18:	100002b7          	lui	t0,0x10000

80000a1c <.TESTR>:
80000a1c:	00528303          	lb	t1,5(t0) # 10000005 <INITLOCATE-0x6ffffffb>
80000a20:	00137313          	andi	t1,t1,1
80000a24:	00031463          	bnez	t1,80000a2c <.RSERIAL>
80000a28:	ff5ff06f          	j	80000a1c <.TESTR>

80000a2c <.RSERIAL>:
80000a2c:	00028503          	lb	a0,0(t0)
80000a30:	00008067          	ret

80000a34 <READ_SERIAL_WORD>:
80000a34:	fec10113          	addi	sp,sp,-20
80000a38:	00112023          	sw	ra,0(sp)
80000a3c:	00812223          	sw	s0,4(sp)
80000a40:	00912423          	sw	s1,8(sp)
80000a44:	01212623          	sw	s2,12(sp)
80000a48:	01312823          	sw	s3,16(sp)
80000a4c:	fcdff0ef          	jal	ra,80000a18 <READ_SERIAL>
80000a50:	00a06433          	or	s0,zero,a0
80000a54:	fc5ff0ef          	jal	ra,80000a18 <READ_SERIAL>
80000a58:	00a064b3          	or	s1,zero,a0
80000a5c:	fbdff0ef          	jal	ra,80000a18 <READ_SERIAL>
80000a60:	00a06933          	or	s2,zero,a0
80000a64:	fb5ff0ef          	jal	ra,80000a18 <READ_SERIAL>
80000a68:	00a069b3          	or	s3,zero,a0
80000a6c:	0ff47413          	andi	s0,s0,255
80000a70:	0ff4f493          	andi	s1,s1,255
80000a74:	0ff97913          	andi	s2,s2,255
80000a78:	0ff9f993          	andi	s3,s3,255
80000a7c:	01306533          	or	a0,zero,s3
80000a80:	00851513          	slli	a0,a0,0x8
80000a84:	01256533          	or	a0,a0,s2
80000a88:	00851513          	slli	a0,a0,0x8
80000a8c:	00956533          	or	a0,a0,s1
80000a90:	00851513          	slli	a0,a0,0x8
80000a94:	00856533          	or	a0,a0,s0
80000a98:	00012083          	lw	ra,0(sp)
80000a9c:	00412403          	lw	s0,4(sp)
80000aa0:	00812483          	lw	s1,8(sp)
80000aa4:	00c12903          	lw	s2,12(sp)
80000aa8:	01012983          	lw	s3,16(sp)
80000aac:	01410113          	addi	sp,sp,20
80000ab0:	00008067          	ret

80000ab4 <READ_SERIAL_XLEN>:
80000ab4:	ff810113          	addi	sp,sp,-8
80000ab8:	00112023          	sw	ra,0(sp)
80000abc:	00812223          	sw	s0,4(sp)
80000ac0:	f75ff0ef          	jal	ra,80000a34 <READ_SERIAL_WORD>
80000ac4:	00050413          	mv	s0,a0
80000ac8:	00040513          	mv	a0,s0
80000acc:	00012083          	lw	ra,0(sp)
80000ad0:	00412403          	lw	s0,4(sp)
80000ad4:	00810113          	addi	sp,sp,8
80000ad8:	00008067          	ret
	...

80001000 <UTEST_SIMPLE>:
80001000:	001f0f13          	addi	t5,t5,1
80001004:	00008067          	ret

80001008 <UTEST_1PTB>:
80001008:	040002b7          	lui	t0,0x4000
8000100c:	fff28293          	addi	t0,t0,-1 # 3ffffff <INITLOCATE-0x7c000001>
80001010:	00000313          	li	t1,0
80001014:	00100393          	li	t2,1
80001018:	00200e13          	li	t3,2
8000101c:	fe0298e3          	bnez	t0,8000100c <UTEST_1PTB+0x4>
80001020:	00008067          	ret

80001024 <UTEST_2DCT>:
80001024:	010002b7          	lui	t0,0x1000
80001028:	00100313          	li	t1,1
8000102c:	00200393          	li	t2,2
80001030:	00300e13          	li	t3,3
80001034:	0063c3b3          	xor	t2,t2,t1
80001038:	00734333          	xor	t1,t1,t2
8000103c:	0063c3b3          	xor	t2,t2,t1
80001040:	007e4e33          	xor	t3,t3,t2
80001044:	01c3c3b3          	xor	t2,t2,t3
80001048:	007e4e33          	xor	t3,t3,t2
8000104c:	01c34333          	xor	t1,t1,t3
80001050:	006e4e33          	xor	t3,t3,t1
80001054:	01c34333          	xor	t1,t1,t3
80001058:	fff28293          	addi	t0,t0,-1 # ffffff <INITLOCATE-0x7f000001>
8000105c:	fc029ce3          	bnez	t0,80001034 <UTEST_2DCT+0x10>
80001060:	00008067          	ret

80001064 <UTEST_3CCT>:
80001064:	040002b7          	lui	t0,0x4000
80001068:	00029463          	bnez	t0,80001070 <UTEST_3CCT+0xc>
8000106c:	00008067          	ret
80001070:	0040006f          	j	80001074 <UTEST_3CCT+0x10>
80001074:	fff28293          	addi	t0,t0,-1 # 3ffffff <INITLOCATE-0x7c000001>
80001078:	ff1ff06f          	j	80001068 <UTEST_3CCT+0x4>
8000107c:	fff28293          	addi	t0,t0,-1

80001080 <UTEST_4MDCT>:
80001080:	020002b7          	lui	t0,0x2000
80001084:	ffc10113          	addi	sp,sp,-4
80001088:	00512023          	sw	t0,0(sp)
8000108c:	00012303          	lw	t1,0(sp)
80001090:	fff30313          	addi	t1,t1,-1
80001094:	00612023          	sw	t1,0(sp)
80001098:	00012283          	lw	t0,0(sp)
8000109c:	fe0296e3          	bnez	t0,80001088 <UTEST_4MDCT+0x8>
800010a0:	00410113          	addi	sp,sp,4
800010a4:	00008067          	ret

800010a8 <UTEST_PUTC>:
800010a8:	01e00413          	li	s0,30
800010ac:	04f00513          	li	a0,79
800010b0:	00000073          	ecall
800010b4:	04b00513          	li	a0,75
800010b8:	00000073          	ecall
800010bc:	00008067          	ret

800010c0 <UTEST_SPIN>:
800010c0:	0000006f          	j	800010c0 <UTEST_SPIN>

800010c4 <UTEST_MYTEST1>:
800010c4:	00000293          	li	t0,0
800010c8:	80100337          	lui	t1,0x80100
800010cc:	00532023          	sw	t0,0(t1) # 80100000 <KERNEL_STACK_INIT+0xff900000>

800010d0 <UTEST_MYTEST2>:
800010d0:	804002b7          	lui	t0,0x80400
800010d4:	00028067          	jr	t0 # 80400000 <KERNEL_STACK_INIT+0xffc00000>

800010d8 <UTEST_CRYPTONIGHT>:
800010d8:	80400537          	lui	a0,0x80400
800010dc:	002005b7          	lui	a1,0x200
800010e0:	000806b7          	lui	a3,0x80
800010e4:	00200737          	lui	a4,0x200
800010e8:	ffc70713          	addi	a4,a4,-4 # 1ffffc <INITLOCATE-0x7fe00004>
800010ec:	00a585b3          	add	a1,a1,a0
800010f0:	00100413          	li	s0,1
800010f4:	00050613          	mv	a2,a0

800010f8 <.INIT_LOOP>:
800010f8:	00862023          	sw	s0,0(a2)
800010fc:	00d41493          	slli	s1,s0,0xd
80001100:	00944433          	xor	s0,s0,s1
80001104:	01145493          	srli	s1,s0,0x11
80001108:	00944433          	xor	s0,s0,s1
8000110c:	00541493          	slli	s1,s0,0x5
80001110:	00944433          	xor	s0,s0,s1
80001114:	00460613          	addi	a2,a2,4
80001118:	feb610e3          	bne	a2,a1,800010f8 <.INIT_LOOP>
8000111c:	00000613          	li	a2,0
80001120:	00000293          	li	t0,0

80001124 <.MAIN_LOOP>:
80001124:	00e472b3          	and	t0,s0,a4
80001128:	005502b3          	add	t0,a0,t0
8000112c:	0002a283          	lw	t0,0(t0)
80001130:	0062c2b3          	xor	t0,t0,t1
80001134:	00544433          	xor	s0,s0,t0
80001138:	00d41493          	slli	s1,s0,0xd
8000113c:	00944433          	xor	s0,s0,s1
80001140:	01145493          	srli	s1,s0,0x11
80001144:	00944433          	xor	s0,s0,s1
80001148:	00541493          	slli	s1,s0,0x5
8000114c:	00944433          	xor	s0,s0,s1
80001150:	00e47333          	and	t1,s0,a4
80001154:	00650333          	add	t1,a0,t1
80001158:	00532023          	sw	t0,0(t1)
8000115c:	00028313          	mv	t1,t0
80001160:	00d41493          	slli	s1,s0,0xd
80001164:	00944433          	xor	s0,s0,s1
80001168:	01145493          	srli	s1,s0,0x11
8000116c:	00944433          	xor	s0,s0,s1
80001170:	00541493          	slli	s1,s0,0x5
80001174:	00944433          	xor	s0,s0,s1
80001178:	00160613          	addi	a2,a2,1
8000117c:	fad614e3          	bne	a2,a3,80001124 <.MAIN_LOOP>
80001180:	00008067          	ret
