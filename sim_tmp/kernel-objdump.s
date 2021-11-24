
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
80000030:	4d440413          	addi	s0,s0,1236 # 80000500 <EXCEPTION_HANDLER>
80000034:	30541073          	csrw	mtvec,s0
80000038:	305022f3          	csrr	t0,mtvec
8000003c:	00828a63          	beq	t0,s0,80000050 <mtvec_done>
80000040:	00000417          	auipc	s0,0x0
80000044:	6c040413          	addi	s0,s0,1728 # 80000700 <VECTORED_EXCEPTION_HANDLER>
80000048:	00146413          	ori	s0,s0,1
8000004c:	30541073          	csrw	mtvec,s0

80000050 <mtvec_done>:
80000050:	08000293          	li	t0,128
80000054:	30429073          	csrw	mie,t0
80000058:	00800117          	auipc	sp,0x800
8000005c:	fa810113          	addi	sp,sp,-88 # 80800000 <KERNEL_STACK_INIT>
80000060:	807f02b7          	lui	t0,0x807f0
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
80000114:	00f00293          	li	t0,15
80000118:	3a029073          	csrw	pmpcfg0,t0
8000011c:	fff00293          	li	t0,-1
80000120:	3b029073          	csrw	pmpaddr0,t0
80000124:	0040006f          	j	80000128 <WELCOME>

80000128 <WELCOME>:
80000128:	00001517          	auipc	a0,0x1
8000012c:	04850513          	addi	a0,a0,72 # 80001170 <monitor_version>
80000130:	7c8000ef          	jal	ra,800008f8 <WRITE_SERIAL_STRING>
80000134:	0040006f          	j	80000138 <SHELL>

80000138 <SHELL>:
80000138:	7e0000ef          	jal	ra,80000918 <READ_SERIAL>
8000013c:	05200293          	li	t0,82
80000140:	06550863          	beq	a0,t0,800001b0 <.OP_R>
80000144:	04400293          	li	t0,68
80000148:	0a550263          	beq	a0,t0,800001ec <.OP_D>
8000014c:	04100293          	li	t0,65
80000150:	0c550e63          	beq	a0,t0,8000022c <.OP_A>
80000154:	04700293          	li	t0,71
80000158:	10550c63          	beq	a0,t0,80000270 <.OP_G>
8000015c:	05400293          	li	t0,84
80000160:	00550863          	beq	a0,t0,80000170 <.OP_T>
80000164:	00400513          	li	a0,4
80000168:	70c000ef          	jal	ra,80000874 <WRITE_SERIAL>
8000016c:	2cc0006f          	j	80000438 <.DONE>

80000170 <.OP_T>:
80000170:	ff410113          	addi	sp,sp,-12
80000174:	00912023          	sw	s1,0(sp)
80000178:	01212223          	sw	s2,4(sp)
8000017c:	fff00493          	li	s1,-1
80000180:	00912423          	sw	s1,8(sp)
80000184:	00810493          	addi	s1,sp,8
80000188:	00400913          	li	s2,4
8000018c:	00048503          	lb	a0,0(s1)
80000190:	fff90913          	addi	s2,s2,-1
80000194:	6e0000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000198:	00148493          	addi	s1,s1,1
8000019c:	fe0918e3          	bnez	s2,8000018c <.OP_T+0x1c>
800001a0:	00012483          	lw	s1,0(sp)
800001a4:	00412903          	lw	s2,4(sp)
800001a8:	00c10113          	addi	sp,sp,12
800001ac:	28c0006f          	j	80000438 <.DONE>

800001b0 <.OP_R>:
800001b0:	ff810113          	addi	sp,sp,-8
800001b4:	00912023          	sw	s1,0(sp)
800001b8:	01212223          	sw	s2,4(sp)
800001bc:	007f0497          	auipc	s1,0x7f0
800001c0:	e4448493          	addi	s1,s1,-444 # 807f0000 <_sbss>
800001c4:	07c00913          	li	s2,124
800001c8:	00048503          	lb	a0,0(s1)
800001cc:	fff90913          	addi	s2,s2,-1
800001d0:	6a4000ef          	jal	ra,80000874 <WRITE_SERIAL>
800001d4:	00148493          	addi	s1,s1,1
800001d8:	fe0918e3          	bnez	s2,800001c8 <.OP_R+0x18>
800001dc:	00012483          	lw	s1,0(sp)
800001e0:	00412903          	lw	s2,4(sp)
800001e4:	00810113          	addi	sp,sp,8
800001e8:	2500006f          	j	80000438 <.DONE>

800001ec <.OP_D>:
800001ec:	ff810113          	addi	sp,sp,-8
800001f0:	00912023          	sw	s1,0(sp)
800001f4:	01212223          	sw	s2,4(sp)
800001f8:	7bc000ef          	jal	ra,800009b4 <READ_SERIAL_XLEN>
800001fc:	000564b3          	or	s1,a0,zero
80000200:	7b4000ef          	jal	ra,800009b4 <READ_SERIAL_XLEN>
80000204:	00056933          	or	s2,a0,zero
80000208:	00048503          	lb	a0,0(s1)
8000020c:	fff90913          	addi	s2,s2,-1
80000210:	664000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000214:	00148493          	addi	s1,s1,1
80000218:	fe0918e3          	bnez	s2,80000208 <.OP_D+0x1c>
8000021c:	00012483          	lw	s1,0(sp)
80000220:	00412903          	lw	s2,4(sp)
80000224:	00810113          	addi	sp,sp,8
80000228:	2100006f          	j	80000438 <.DONE>

8000022c <.OP_A>:
8000022c:	ff810113          	addi	sp,sp,-8
80000230:	00912023          	sw	s1,0(sp)
80000234:	01212223          	sw	s2,4(sp)
80000238:	77c000ef          	jal	ra,800009b4 <READ_SERIAL_XLEN>
8000023c:	000564b3          	or	s1,a0,zero
80000240:	774000ef          	jal	ra,800009b4 <READ_SERIAL_XLEN>
80000244:	00056933          	or	s2,a0,zero
80000248:	00295913          	srli	s2,s2,0x2
8000024c:	6e8000ef          	jal	ra,80000934 <READ_SERIAL_WORD>
80000250:	00a4a023          	sw	a0,0(s1)
80000254:	fff90913          	addi	s2,s2,-1
80000258:	00448493          	addi	s1,s1,4
8000025c:	fe0918e3          	bnez	s2,8000024c <.OP_A+0x20>
80000260:	00012483          	lw	s1,0(sp)
80000264:	00412903          	lw	s2,4(sp)
80000268:	00810113          	addi	sp,sp,8
8000026c:	1cc0006f          	j	80000438 <.DONE>

80000270 <.OP_G>:
80000270:	744000ef          	jal	ra,800009b4 <READ_SERIAL_XLEN>
80000274:	00050d13          	mv	s10,a0
80000278:	00600513          	li	a0,6
8000027c:	5f8000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000280:	341d1073          	csrw	mepc,s10
80000284:	00002537          	lui	a0,0x2
80000288:	80050513          	addi	a0,a0,-2048 # 1800 <INITLOCATE-0x7fffe800>
8000028c:	30053073          	csrc	mstatus,a0
80000290:	0200c2b7          	lui	t0,0x200c
80000294:	ff828293          	addi	t0,t0,-8 # 200bff8 <INITLOCATE-0x7dff4008>
80000298:	0002a303          	lw	t1,0(t0)
8000029c:	0042a383          	lw	t2,4(t0)
800002a0:	00989e37          	lui	t3,0x989
800002a4:	680e0e13          	addi	t3,t3,1664 # 989680 <INITLOCATE-0x7f676980>
800002a8:	01c30e33          	add	t3,t1,t3
800002ac:	006e3333          	sltu	t1,t3,t1
800002b0:	006383b3          	add	t2,t2,t1
800002b4:	020042b7          	lui	t0,0x2004
800002b8:	0072a223          	sw	t2,4(t0) # 2004004 <INITLOCATE-0x7dffbffc>
800002bc:	01c2a023          	sw	t3,0(t0)
800002c0:	007f0097          	auipc	ra,0x7f0
800002c4:	d4008093          	addi	ra,ra,-704 # 807f0000 <_sbss>
800002c8:	0820a023          	sw	sp,128(ra)
800002cc:	0040a103          	lw	sp,4(ra)
800002d0:	0080a183          	lw	gp,8(ra)
800002d4:	00c0a203          	lw	tp,12(ra)
800002d8:	0100a283          	lw	t0,16(ra)
800002dc:	0140a303          	lw	t1,20(ra)
800002e0:	0180a383          	lw	t2,24(ra)
800002e4:	01c0a403          	lw	s0,28(ra)
800002e8:	0200a483          	lw	s1,32(ra)
800002ec:	0240a503          	lw	a0,36(ra)
800002f0:	0280a583          	lw	a1,40(ra)
800002f4:	02c0a603          	lw	a2,44(ra)
800002f8:	0300a683          	lw	a3,48(ra)
800002fc:	0340a703          	lw	a4,52(ra)
80000300:	0380a783          	lw	a5,56(ra)
80000304:	03c0a803          	lw	a6,60(ra)
80000308:	0400a883          	lw	a7,64(ra)
8000030c:	0440a903          	lw	s2,68(ra)
80000310:	0480a983          	lw	s3,72(ra)
80000314:	04c0aa03          	lw	s4,76(ra)
80000318:	0500aa83          	lw	s5,80(ra)
8000031c:	0540ab03          	lw	s6,84(ra)
80000320:	0580ab83          	lw	s7,88(ra)
80000324:	05c0ac03          	lw	s8,92(ra)
80000328:	0600ac83          	lw	s9,96(ra)
8000032c:	0680ad83          	lw	s11,104(ra)
80000330:	06c0ae03          	lw	t3,108(ra)
80000334:	0700ae83          	lw	t4,112(ra)
80000338:	0740af03          	lw	t5,116(ra)
8000033c:	0780af83          	lw	t6,120(ra)

80000340 <.ENTER_UESR>:
80000340:	00000097          	auipc	ra,0x0
80000344:	00c08093          	addi	ra,ra,12 # 8000034c <.USERRET_USER>
80000348:	30200073          	mret

8000034c <.USERRET_USER>:
8000034c:	00100073          	ebreak

80000350 <USERRET_TIMEOUT>:
80000350:	08100513          	li	a0,129
80000354:	520000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000358:	00c0006f          	j	80000364 <USERRET_MACHINE+0x8>

8000035c <USERRET_MACHINE>:
8000035c:	00700513          	li	a0,7
80000360:	514000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000364:	007f0497          	auipc	s1,0x7f0
80000368:	c9c48493          	addi	s1,s1,-868 # 807f0000 <_sbss>
8000036c:	08000913          	li	s2,128
80000370:	00012503          	lw	a0,0(sp)
80000374:	00a4a023          	sw	a0,0(s1)
80000378:	ffc90913          	addi	s2,s2,-4
8000037c:	00448493          	addi	s1,s1,4
80000380:	00410113          	addi	sp,sp,4
80000384:	fe0916e3          	bnez	s2,80000370 <USERRET_MACHINE+0x14>
80000388:	007f0497          	auipc	s1,0x7f0
8000038c:	c7848493          	addi	s1,s1,-904 # 807f0000 <_sbss>
80000390:	0804a103          	lw	sp,128(s1)
80000394:	0a40006f          	j	80000438 <.DONE>

80000398 <.USERRET2>:
80000398:	007f0097          	auipc	ra,0x7f0
8000039c:	c6808093          	addi	ra,ra,-920 # 807f0000 <_sbss>
800003a0:	0020a223          	sw	sp,4(ra)
800003a4:	0030a423          	sw	gp,8(ra)
800003a8:	0040a623          	sw	tp,12(ra)
800003ac:	0050a823          	sw	t0,16(ra)
800003b0:	0060aa23          	sw	t1,20(ra)
800003b4:	0070ac23          	sw	t2,24(ra)
800003b8:	0080ae23          	sw	s0,28(ra)
800003bc:	0290a023          	sw	s1,32(ra)
800003c0:	02a0a223          	sw	a0,36(ra)
800003c4:	02b0a423          	sw	a1,40(ra)
800003c8:	02c0a623          	sw	a2,44(ra)
800003cc:	02d0a823          	sw	a3,48(ra)
800003d0:	02e0aa23          	sw	a4,52(ra)
800003d4:	02f0ac23          	sw	a5,56(ra)
800003d8:	0300ae23          	sw	a6,60(ra)
800003dc:	0510a023          	sw	a7,64(ra)
800003e0:	0520a223          	sw	s2,68(ra)
800003e4:	0530a423          	sw	s3,72(ra)
800003e8:	0540a623          	sw	s4,76(ra)
800003ec:	0550a823          	sw	s5,80(ra)
800003f0:	0560aa23          	sw	s6,84(ra)
800003f4:	0570ac23          	sw	s7,88(ra)
800003f8:	0580ae23          	sw	s8,92(ra)
800003fc:	0790a023          	sw	s9,96(ra)
80000400:	07a0a223          	sw	s10,100(ra)
80000404:	07b0a423          	sw	s11,104(ra)
80000408:	07c0a623          	sw	t3,108(ra)
8000040c:	07d0a823          	sw	t4,112(ra)
80000410:	07e0aa23          	sw	t5,116(ra)
80000414:	07f0ac23          	sw	t6,120(ra)
80000418:	0800a103          	lw	sp,128(ra)
8000041c:	00008513          	mv	a0,ra
80000420:	00000097          	auipc	ra,0x0
80000424:	f7808093          	addi	ra,ra,-136 # 80000398 <.USERRET2>
80000428:	00152023          	sw	ra,0(a0)
8000042c:	00700513          	li	a0,7
80000430:	444000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000434:	0040006f          	j	80000438 <.DONE>

80000438 <.DONE>:
80000438:	d01ff06f          	j	80000138 <SHELL>
	...

80000500 <EXCEPTION_HANDLER>:
80000500:	34011173          	csrrw	sp,mscratch,sp
80000504:	00112023          	sw	ra,0(sp)
80000508:	340110f3          	csrrw	ra,mscratch,sp
8000050c:	00112223          	sw	ra,4(sp)
80000510:	00312423          	sw	gp,8(sp)
80000514:	00412623          	sw	tp,12(sp)
80000518:	00512823          	sw	t0,16(sp)
8000051c:	00612a23          	sw	t1,20(sp)
80000520:	00712c23          	sw	t2,24(sp)
80000524:	00812e23          	sw	s0,28(sp)
80000528:	02912023          	sw	s1,32(sp)
8000052c:	02a12223          	sw	a0,36(sp)
80000530:	02b12423          	sw	a1,40(sp)
80000534:	02c12623          	sw	a2,44(sp)
80000538:	02d12823          	sw	a3,48(sp)
8000053c:	02e12a23          	sw	a4,52(sp)
80000540:	02f12c23          	sw	a5,56(sp)
80000544:	03012e23          	sw	a6,60(sp)
80000548:	05112023          	sw	a7,64(sp)
8000054c:	05212223          	sw	s2,68(sp)
80000550:	05312423          	sw	s3,72(sp)
80000554:	05412623          	sw	s4,76(sp)
80000558:	05512823          	sw	s5,80(sp)
8000055c:	05612a23          	sw	s6,84(sp)
80000560:	05712c23          	sw	s7,88(sp)
80000564:	05812e23          	sw	s8,92(sp)
80000568:	07912023          	sw	s9,96(sp)
8000056c:	07a12223          	sw	s10,100(sp)
80000570:	07b12423          	sw	s11,104(sp)
80000574:	07c12623          	sw	t3,108(sp)
80000578:	07d12823          	sw	t4,112(sp)
8000057c:	07e12a23          	sw	t5,116(sp)
80000580:	07f12c23          	sw	t6,120(sp)
80000584:	341022f3          	csrr	t0,mepc
80000588:	06512e23          	sw	t0,124(sp)
8000058c:	342022f3          	csrr	t0,mcause
80000590:	80000337          	lui	t1,0x80000
80000594:	00730313          	addi	t1,t1,7 # 80000007 <KERNEL_STACK_INIT+0xff800007>
80000598:	04530a63          	beq	t1,t0,800005ec <.HANDLE_TIMER>
8000059c:	80000337          	lui	t1,0x80000
800005a0:	0062f333          	and	t1,t0,t1
800005a4:	04031263          	bnez	t1,800005e8 <.HANDLE_INT>
800005a8:	00800313          	li	t1,8
800005ac:	00530863          	beq	t1,t0,800005bc <.HANDLE_ECALL>
800005b0:	00300313          	li	t1,3
800005b4:	02530863          	beq	t1,t0,800005e4 <.HANDLE_BREAK>
800005b8:	2480006f          	j	80000800 <FATAL>

800005bc <.HANDLE_ECALL>:
800005bc:	07c12283          	lw	t0,124(sp)
800005c0:	00428293          	addi	t0,t0,4
800005c4:	06512e23          	sw	t0,124(sp)
800005c8:	01c12283          	lw	t0,28(sp)
800005cc:	01e00313          	li	t1,30
800005d0:	00628463          	beq	t0,t1,800005d8 <.HANDLE_ECALL_PUTC>
800005d4:	0300006f          	j	80000604 <CONTEXT_SWITCH>

800005d8 <.HANDLE_ECALL_PUTC>:
800005d8:	02412503          	lw	a0,36(sp)
800005dc:	298000ef          	jal	ra,80000874 <WRITE_SERIAL>
800005e0:	0240006f          	j	80000604 <CONTEXT_SWITCH>

800005e4 <.HANDLE_BREAK>:
800005e4:	d79ff06f          	j	8000035c <USERRET_MACHINE>

800005e8 <.HANDLE_INT>:
800005e8:	2180006f          	j	80000800 <FATAL>

800005ec <.HANDLE_TIMER>:
800005ec:	300022f3          	csrr	t0,mstatus
800005f0:	00002337          	lui	t1,0x2
800005f4:	80030313          	addi	t1,t1,-2048 # 1800 <INITLOCATE-0x7fffe800>
800005f8:	0062f2b3          	and	t0,t0,t1
800005fc:	00029463          	bnez	t0,80000604 <CONTEXT_SWITCH>
80000600:	d51ff06f          	j	80000350 <USERRET_TIMEOUT>

80000604 <CONTEXT_SWITCH>:
80000604:	07c12283          	lw	t0,124(sp)
80000608:	34129073          	csrw	mepc,t0
8000060c:	00012083          	lw	ra,0(sp)
80000610:	00812183          	lw	gp,8(sp)
80000614:	00c12203          	lw	tp,12(sp)
80000618:	01012283          	lw	t0,16(sp)
8000061c:	01412303          	lw	t1,20(sp)
80000620:	01812383          	lw	t2,24(sp)
80000624:	01c12403          	lw	s0,28(sp)
80000628:	02012483          	lw	s1,32(sp)
8000062c:	02412503          	lw	a0,36(sp)
80000630:	02812583          	lw	a1,40(sp)
80000634:	02c12603          	lw	a2,44(sp)
80000638:	03012683          	lw	a3,48(sp)
8000063c:	03412703          	lw	a4,52(sp)
80000640:	03812783          	lw	a5,56(sp)
80000644:	03c12803          	lw	a6,60(sp)
80000648:	04012883          	lw	a7,64(sp)
8000064c:	04412903          	lw	s2,68(sp)
80000650:	04812983          	lw	s3,72(sp)
80000654:	04c12a03          	lw	s4,76(sp)
80000658:	05012a83          	lw	s5,80(sp)
8000065c:	05412b03          	lw	s6,84(sp)
80000660:	05812b83          	lw	s7,88(sp)
80000664:	05c12c03          	lw	s8,92(sp)
80000668:	06012c83          	lw	s9,96(sp)
8000066c:	06412d03          	lw	s10,100(sp)
80000670:	06812d83          	lw	s11,104(sp)
80000674:	06c12e03          	lw	t3,108(sp)
80000678:	07012e83          	lw	t4,112(sp)
8000067c:	07412f03          	lw	t5,116(sp)
80000680:	07812f83          	lw	t6,120(sp)
80000684:	34011073          	csrw	mscratch,sp
80000688:	00412103          	lw	sp,4(sp)
8000068c:	30200073          	mret
80000690:	00000013          	nop
80000694:	00000013          	nop
80000698:	00000013          	nop
8000069c:	00000013          	nop
800006a0:	00000013          	nop
800006a4:	00000013          	nop
800006a8:	00000013          	nop
800006ac:	00000013          	nop
800006b0:	00000013          	nop
800006b4:	00000013          	nop
800006b8:	00000013          	nop
800006bc:	00000013          	nop
800006c0:	00000013          	nop
800006c4:	00000013          	nop
800006c8:	00000013          	nop
800006cc:	00000013          	nop
800006d0:	00000013          	nop
800006d4:	00000013          	nop
800006d8:	00000013          	nop
800006dc:	00000013          	nop
800006e0:	00000013          	nop
800006e4:	00000013          	nop
800006e8:	00000013          	nop
800006ec:	00000013          	nop
800006f0:	00000013          	nop
800006f4:	00000013          	nop
800006f8:	00000013          	nop
800006fc:	00000013          	nop

80000700 <VECTORED_EXCEPTION_HANDLER>:
80000700:	e01ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000704:	dfdff06f          	j	80000500 <EXCEPTION_HANDLER>
80000708:	df9ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000070c:	df5ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000710:	df1ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000714:	dedff06f          	j	80000500 <EXCEPTION_HANDLER>
80000718:	de9ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000071c:	de5ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000720:	de1ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000724:	dddff06f          	j	80000500 <EXCEPTION_HANDLER>
80000728:	dd9ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000072c:	dd5ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000730:	dd1ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000734:	dcdff06f          	j	80000500 <EXCEPTION_HANDLER>
80000738:	dc9ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000073c:	dc5ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000740:	dc1ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000744:	dbdff06f          	j	80000500 <EXCEPTION_HANDLER>
80000748:	db9ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000074c:	db5ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000750:	db1ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000754:	dadff06f          	j	80000500 <EXCEPTION_HANDLER>
80000758:	da9ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000075c:	da5ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000760:	da1ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000764:	d9dff06f          	j	80000500 <EXCEPTION_HANDLER>
80000768:	d99ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000076c:	d95ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000770:	d91ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000774:	d8dff06f          	j	80000500 <EXCEPTION_HANDLER>
80000778:	d89ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000077c:	d85ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000780:	d81ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000784:	d7dff06f          	j	80000500 <EXCEPTION_HANDLER>
80000788:	d79ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000078c:	d75ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000790:	d71ff06f          	j	80000500 <EXCEPTION_HANDLER>
80000794:	d6dff06f          	j	80000500 <EXCEPTION_HANDLER>
80000798:	d69ff06f          	j	80000500 <EXCEPTION_HANDLER>
8000079c:	d65ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007a0:	d61ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007a4:	d5dff06f          	j	80000500 <EXCEPTION_HANDLER>
800007a8:	d59ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007ac:	d55ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007b0:	d51ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007b4:	d4dff06f          	j	80000500 <EXCEPTION_HANDLER>
800007b8:	d49ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007bc:	d45ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007c0:	d41ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007c4:	d3dff06f          	j	80000500 <EXCEPTION_HANDLER>
800007c8:	d39ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007cc:	d35ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007d0:	d31ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007d4:	d2dff06f          	j	80000500 <EXCEPTION_HANDLER>
800007d8:	d29ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007dc:	d25ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007e0:	d21ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007e4:	d1dff06f          	j	80000500 <EXCEPTION_HANDLER>
800007e8:	d19ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007ec:	d15ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007f0:	d11ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007f4:	d0dff06f          	j	80000500 <EXCEPTION_HANDLER>
800007f8:	d09ff06f          	j	80000500 <EXCEPTION_HANDLER>
800007fc:	d05ff06f          	j	80000500 <EXCEPTION_HANDLER>

80000800 <FATAL>:
80000800:	08000513          	li	a0,128
80000804:	070000ef          	jal	ra,80000874 <WRITE_SERIAL>
80000808:	34102573          	csrr	a0,mepc
8000080c:	0d4000ef          	jal	ra,800008e0 <WRITE_SERIAL_XLEN>
80000810:	34202573          	csrr	a0,mcause
80000814:	0cc000ef          	jal	ra,800008e0 <WRITE_SERIAL_XLEN>
80000818:	34302573          	csrr	a0,mtval
8000081c:	0c4000ef          	jal	ra,800008e0 <WRITE_SERIAL_XLEN>
80000820:	fffff517          	auipc	a0,0xfffff
80000824:	7ec50513          	addi	a0,a0,2028 # 8000000c <START>
80000828:	00050067          	jr	a0
	...

80000874 <WRITE_SERIAL>:
80000874:	100002b7          	lui	t0,0x10000

80000878 <.TESTW>:
80000878:	00528303          	lb	t1,5(t0) # 10000005 <INITLOCATE-0x6ffffffb>
8000087c:	02037313          	andi	t1,t1,32
80000880:	00031463          	bnez	t1,80000888 <.WSERIAL>
80000884:	ff5ff06f          	j	80000878 <.TESTW>

80000888 <.WSERIAL>:
80000888:	00a28023          	sb	a0,0(t0)
8000088c:	00008067          	ret

80000890 <WRITE_SERIAL_WORD>:
80000890:	ff810113          	addi	sp,sp,-8
80000894:	00112023          	sw	ra,0(sp)
80000898:	00812223          	sw	s0,4(sp)
8000089c:	00050413          	mv	s0,a0
800008a0:	0ff57513          	andi	a0,a0,255
800008a4:	fd1ff0ef          	jal	ra,80000874 <WRITE_SERIAL>
800008a8:	00845513          	srli	a0,s0,0x8
800008ac:	0ff57513          	andi	a0,a0,255
800008b0:	fc5ff0ef          	jal	ra,80000874 <WRITE_SERIAL>
800008b4:	01045513          	srli	a0,s0,0x10
800008b8:	0ff57513          	andi	a0,a0,255
800008bc:	fb9ff0ef          	jal	ra,80000874 <WRITE_SERIAL>
800008c0:	01845513          	srli	a0,s0,0x18
800008c4:	0ff57513          	andi	a0,a0,255
800008c8:	fadff0ef          	jal	ra,80000874 <WRITE_SERIAL>
800008cc:	00040513          	mv	a0,s0
800008d0:	00012083          	lw	ra,0(sp)
800008d4:	00412403          	lw	s0,4(sp)
800008d8:	00810113          	addi	sp,sp,8
800008dc:	00008067          	ret

800008e0 <WRITE_SERIAL_XLEN>:
800008e0:	ffc10113          	addi	sp,sp,-4
800008e4:	00112023          	sw	ra,0(sp)
800008e8:	fa9ff0ef          	jal	ra,80000890 <WRITE_SERIAL_WORD>
800008ec:	00012083          	lw	ra,0(sp)
800008f0:	00410113          	addi	sp,sp,4
800008f4:	00008067          	ret

800008f8 <WRITE_SERIAL_STRING>:
800008f8:	00050593          	mv	a1,a0
800008fc:	00008613          	mv	a2,ra
80000900:	00058503          	lb	a0,0(a1)
80000904:	f71ff0ef          	jal	ra,80000874 <WRITE_SERIAL>
80000908:	00158593          	addi	a1,a1,1
8000090c:	00058503          	lb	a0,0(a1)
80000910:	fe051ae3          	bnez	a0,80000904 <WRITE_SERIAL_STRING+0xc>
80000914:	00060067          	jr	a2

80000918 <READ_SERIAL>:
80000918:	100002b7          	lui	t0,0x10000

8000091c <.TESTR>:
8000091c:	00528303          	lb	t1,5(t0) # 10000005 <INITLOCATE-0x6ffffffb>
80000920:	00137313          	andi	t1,t1,1
80000924:	00031463          	bnez	t1,8000092c <.RSERIAL>
80000928:	ff5ff06f          	j	8000091c <.TESTR>

8000092c <.RSERIAL>:
8000092c:	00028503          	lb	a0,0(t0)
80000930:	00008067          	ret

80000934 <READ_SERIAL_WORD>:
80000934:	fec10113          	addi	sp,sp,-20
80000938:	00112023          	sw	ra,0(sp)
8000093c:	00812223          	sw	s0,4(sp)
80000940:	00912423          	sw	s1,8(sp)
80000944:	01212623          	sw	s2,12(sp)
80000948:	01312823          	sw	s3,16(sp)
8000094c:	fcdff0ef          	jal	ra,80000918 <READ_SERIAL>
80000950:	00a06433          	or	s0,zero,a0
80000954:	fc5ff0ef          	jal	ra,80000918 <READ_SERIAL>
80000958:	00a064b3          	or	s1,zero,a0
8000095c:	fbdff0ef          	jal	ra,80000918 <READ_SERIAL>
80000960:	00a06933          	or	s2,zero,a0
80000964:	fb5ff0ef          	jal	ra,80000918 <READ_SERIAL>
80000968:	00a069b3          	or	s3,zero,a0
8000096c:	0ff47413          	andi	s0,s0,255
80000970:	0ff4f493          	andi	s1,s1,255
80000974:	0ff97913          	andi	s2,s2,255
80000978:	0ff9f993          	andi	s3,s3,255
8000097c:	01306533          	or	a0,zero,s3
80000980:	00851513          	slli	a0,a0,0x8
80000984:	01256533          	or	a0,a0,s2
80000988:	00851513          	slli	a0,a0,0x8
8000098c:	00956533          	or	a0,a0,s1
80000990:	00851513          	slli	a0,a0,0x8
80000994:	00856533          	or	a0,a0,s0
80000998:	00012083          	lw	ra,0(sp)
8000099c:	00412403          	lw	s0,4(sp)
800009a0:	00812483          	lw	s1,8(sp)
800009a4:	00c12903          	lw	s2,12(sp)
800009a8:	01012983          	lw	s3,16(sp)
800009ac:	01410113          	addi	sp,sp,20
800009b0:	00008067          	ret

800009b4 <READ_SERIAL_XLEN>:
800009b4:	ff810113          	addi	sp,sp,-8
800009b8:	00112023          	sw	ra,0(sp)
800009bc:	00812223          	sw	s0,4(sp)
800009c0:	f75ff0ef          	jal	ra,80000934 <READ_SERIAL_WORD>
800009c4:	00050413          	mv	s0,a0
800009c8:	00040513          	mv	a0,s0
800009cc:	00012083          	lw	ra,0(sp)
800009d0:	00412403          	lw	s0,4(sp)
800009d4:	00810113          	addi	sp,sp,8
800009d8:	00008067          	ret
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

800010c4 <UTEST_CRYPTONIGHT>:
800010c4:	80400537          	lui	a0,0x80400
800010c8:	002005b7          	lui	a1,0x200
800010cc:	000806b7          	lui	a3,0x80
800010d0:	00200737          	lui	a4,0x200
800010d4:	ffc70713          	addi	a4,a4,-4 # 1ffffc <INITLOCATE-0x7fe00004>
800010d8:	00a585b3          	add	a1,a1,a0
800010dc:	00100413          	li	s0,1
800010e0:	00050613          	mv	a2,a0

800010e4 <.INIT_LOOP>:
800010e4:	00862023          	sw	s0,0(a2)
800010e8:	00d41493          	slli	s1,s0,0xd
800010ec:	00944433          	xor	s0,s0,s1
800010f0:	01145493          	srli	s1,s0,0x11
800010f4:	00944433          	xor	s0,s0,s1
800010f8:	00541493          	slli	s1,s0,0x5
800010fc:	00944433          	xor	s0,s0,s1
80001100:	00460613          	addi	a2,a2,4
80001104:	feb610e3          	bne	a2,a1,800010e4 <.INIT_LOOP>
80001108:	00000613          	li	a2,0
8000110c:	00000293          	li	t0,0

80001110 <.MAIN_LOOP>:
80001110:	00e472b3          	and	t0,s0,a4
80001114:	005502b3          	add	t0,a0,t0
80001118:	0002a283          	lw	t0,0(t0) # 2000000 <INITLOCATE-0x7e000000>
8000111c:	0062c2b3          	xor	t0,t0,t1
80001120:	00544433          	xor	s0,s0,t0
80001124:	00d41493          	slli	s1,s0,0xd
80001128:	00944433          	xor	s0,s0,s1
8000112c:	01145493          	srli	s1,s0,0x11
80001130:	00944433          	xor	s0,s0,s1
80001134:	00541493          	slli	s1,s0,0x5
80001138:	00944433          	xor	s0,s0,s1
8000113c:	00e47333          	and	t1,s0,a4
80001140:	00650333          	add	t1,a0,t1
80001144:	00532023          	sw	t0,0(t1)
80001148:	00028313          	mv	t1,t0
8000114c:	00d41493          	slli	s1,s0,0xd
80001150:	00944433          	xor	s0,s0,s1
80001154:	01145493          	srli	s1,s0,0x11
80001158:	00944433          	xor	s0,s0,s1
8000115c:	00541493          	slli	s1,s0,0x5
80001160:	00944433          	xor	s0,s0,s1
80001164:	00160613          	addi	a2,a2,1
80001168:	fad614e3          	bne	a2,a3,80001110 <.MAIN_LOOP>
8000116c:	00008067          	ret
