
uapp.elf:     file format elf64-littleriscv


Disassembly of section .text.init:

0000000000000000 <_start>:
   0:	1b50006f          	j	9b4 <main>

Disassembly of section .text.atoi:

0000000000000004 <atoi>:
   4:	fd010113          	addi	sp,sp,-48
   8:	02113423          	sd	ra,40(sp)
   c:	02813023          	sd	s0,32(sp)
  10:	03010413          	addi	s0,sp,48
  14:	fca43c23          	sd	a0,-40(s0)
  18:	fe042623          	sw	zero,-20(s0)
  1c:	fd843503          	ld	a0,-40(s0)
  20:	28d010ef          	jal	1aac <strlen>
  24:	00050793          	mv	a5,a0
  28:	fef42223          	sw	a5,-28(s0)
  2c:	fe042423          	sw	zero,-24(s0)
  30:	0500006f          	j	80 <atoi+0x7c>
  34:	fec42783          	lw	a5,-20(s0)
  38:	00078713          	mv	a4,a5
  3c:	00070793          	mv	a5,a4
  40:	0027979b          	slliw	a5,a5,0x2
  44:	00e787bb          	addw	a5,a5,a4
  48:	0017979b          	slliw	a5,a5,0x1
  4c:	0007871b          	sext.w	a4,a5
  50:	fe842783          	lw	a5,-24(s0)
  54:	fd843683          	ld	a3,-40(s0)
  58:	00f687b3          	add	a5,a3,a5
  5c:	0007c783          	lbu	a5,0(a5)
  60:	0007879b          	sext.w	a5,a5
  64:	00f707bb          	addw	a5,a4,a5
  68:	0007879b          	sext.w	a5,a5
  6c:	fd07879b          	addiw	a5,a5,-48
  70:	fef42623          	sw	a5,-20(s0)
  74:	fe842783          	lw	a5,-24(s0)
  78:	0017879b          	addiw	a5,a5,1
  7c:	fef42423          	sw	a5,-24(s0)
  80:	fe842783          	lw	a5,-24(s0)
  84:	00078713          	mv	a4,a5
  88:	fe442783          	lw	a5,-28(s0)
  8c:	0007071b          	sext.w	a4,a4
  90:	0007879b          	sext.w	a5,a5
  94:	faf740e3          	blt	a4,a5,34 <atoi+0x30>
  98:	fec42783          	lw	a5,-20(s0)
  9c:	00078513          	mv	a0,a5
  a0:	02813083          	ld	ra,40(sp)
  a4:	02013403          	ld	s0,32(sp)
  a8:	03010113          	addi	sp,sp,48
  ac:	00008067          	ret

Disassembly of section .text.get_param:

00000000000000b0 <get_param>:
  b0:	fd010113          	addi	sp,sp,-48
  b4:	02813423          	sd	s0,40(sp)
  b8:	03010413          	addi	s0,sp,48
  bc:	fca43c23          	sd	a0,-40(s0)
  c0:	0100006f          	j	d0 <get_param+0x20>
  c4:	fd843783          	ld	a5,-40(s0)
  c8:	00178793          	addi	a5,a5,1
  cc:	fcf43c23          	sd	a5,-40(s0)
  d0:	fd843783          	ld	a5,-40(s0)
  d4:	0007c783          	lbu	a5,0(a5)
  d8:	00078713          	mv	a4,a5
  dc:	02000793          	li	a5,32
  e0:	fef702e3          	beq	a4,a5,c4 <get_param+0x14>
  e4:	fe042623          	sw	zero,-20(s0)
  e8:	0300006f          	j	118 <get_param+0x68>
  ec:	fd843703          	ld	a4,-40(s0)
  f0:	00170793          	addi	a5,a4,1
  f4:	fcf43c23          	sd	a5,-40(s0)
  f8:	fec42783          	lw	a5,-20(s0)
  fc:	0017869b          	addiw	a3,a5,1
 100:	fed42623          	sw	a3,-20(s0)
 104:	00074703          	lbu	a4,0(a4)
 108:	00002697          	auipc	a3,0x2
 10c:	0d868693          	addi	a3,a3,216 # 21e0 <string_buf>
 110:	00f687b3          	add	a5,a3,a5
 114:	00e78023          	sb	a4,0(a5)
 118:	fd843783          	ld	a5,-40(s0)
 11c:	0007c783          	lbu	a5,0(a5)
 120:	00078c63          	beqz	a5,138 <get_param+0x88>
 124:	fd843783          	ld	a5,-40(s0)
 128:	0007c783          	lbu	a5,0(a5)
 12c:	00078713          	mv	a4,a5
 130:	02000793          	li	a5,32
 134:	faf71ce3          	bne	a4,a5,ec <get_param+0x3c>
 138:	00002717          	auipc	a4,0x2
 13c:	0a870713          	addi	a4,a4,168 # 21e0 <string_buf>
 140:	fec42783          	lw	a5,-20(s0)
 144:	00f707b3          	add	a5,a4,a5
 148:	00078023          	sb	zero,0(a5)
 14c:	00002797          	auipc	a5,0x2
 150:	09478793          	addi	a5,a5,148 # 21e0 <string_buf>
 154:	00078513          	mv	a0,a5
 158:	02813403          	ld	s0,40(sp)
 15c:	03010113          	addi	sp,sp,48
 160:	00008067          	ret

Disassembly of section .text.get_string:

0000000000000164 <get_string>:
 164:	fd010113          	addi	sp,sp,-48
 168:	02113423          	sd	ra,40(sp)
 16c:	02813023          	sd	s0,32(sp)
 170:	03010413          	addi	s0,sp,48
 174:	fca43c23          	sd	a0,-40(s0)
 178:	0100006f          	j	188 <get_string+0x24>
 17c:	fd843783          	ld	a5,-40(s0)
 180:	00178793          	addi	a5,a5,1
 184:	fcf43c23          	sd	a5,-40(s0)
 188:	fd843783          	ld	a5,-40(s0)
 18c:	0007c783          	lbu	a5,0(a5)
 190:	00078713          	mv	a4,a5
 194:	02000793          	li	a5,32
 198:	fef702e3          	beq	a4,a5,17c <get_string+0x18>
 19c:	fd843783          	ld	a5,-40(s0)
 1a0:	0007c783          	lbu	a5,0(a5)
 1a4:	00078713          	mv	a4,a5
 1a8:	02200793          	li	a5,34
 1ac:	06f71c63          	bne	a4,a5,224 <get_string+0xc0>
 1b0:	fd843783          	ld	a5,-40(s0)
 1b4:	00178793          	addi	a5,a5,1
 1b8:	fcf43c23          	sd	a5,-40(s0)
 1bc:	fe042623          	sw	zero,-20(s0)
 1c0:	0300006f          	j	1f0 <get_string+0x8c>
 1c4:	fd843703          	ld	a4,-40(s0)
 1c8:	00170793          	addi	a5,a4,1
 1cc:	fcf43c23          	sd	a5,-40(s0)
 1d0:	fec42783          	lw	a5,-20(s0)
 1d4:	0017869b          	addiw	a3,a5,1
 1d8:	fed42623          	sw	a3,-20(s0)
 1dc:	00074703          	lbu	a4,0(a4)
 1e0:	00002697          	auipc	a3,0x2
 1e4:	00068693          	mv	a3,a3
 1e8:	00f687b3          	add	a5,a3,a5
 1ec:	00e78023          	sb	a4,0(a5)
 1f0:	fd843783          	ld	a5,-40(s0)
 1f4:	0007c783          	lbu	a5,0(a5)
 1f8:	00078713          	mv	a4,a5
 1fc:	02200793          	li	a5,34
 200:	fcf712e3          	bne	a4,a5,1c4 <get_string+0x60>
 204:	00002717          	auipc	a4,0x2
 208:	fdc70713          	addi	a4,a4,-36 # 21e0 <string_buf>
 20c:	fec42783          	lw	a5,-20(s0)
 210:	00f707b3          	add	a5,a4,a5
 214:	00078023          	sb	zero,0(a5)
 218:	00002797          	auipc	a5,0x2
 21c:	fc878793          	addi	a5,a5,-56 # 21e0 <string_buf>
 220:	0100006f          	j	230 <get_string+0xcc>
 224:	fd843503          	ld	a0,-40(s0)
 228:	e89ff0ef          	jal	b0 <get_param>
 22c:	00050793          	mv	a5,a0
 230:	00078513          	mv	a0,a5
 234:	02813083          	ld	ra,40(sp)
 238:	02013403          	ld	s0,32(sp)
 23c:	03010113          	addi	sp,sp,48
 240:	00008067          	ret

Disassembly of section .text.parse_cmd:

0000000000000244 <parse_cmd>:
 244:	c9010113          	addi	sp,sp,-880
 248:	36113423          	sd	ra,872(sp)
 24c:	36813023          	sd	s0,864(sp)
 250:	34913c23          	sd	s1,856(sp)
 254:	35213823          	sd	s2,848(sp)
 258:	35313423          	sd	s3,840(sp)
 25c:	35413023          	sd	s4,832(sp)
 260:	33513c23          	sd	s5,824(sp)
 264:	33613823          	sd	s6,816(sp)
 268:	33713423          	sd	s7,808(sp)
 26c:	33813023          	sd	s8,800(sp)
 270:	31913c23          	sd	s9,792(sp)
 274:	31a13823          	sd	s10,784(sp)
 278:	31b13423          	sd	s11,776(sp)
 27c:	37010413          	addi	s0,sp,880
 280:	d0a43423          	sd	a0,-760(s0)
 284:	00058793          	mv	a5,a1
 288:	d0f42223          	sw	a5,-764(s0)
 28c:	d0843783          	ld	a5,-760(s0)
 290:	0007c783          	lbu	a5,0(a5)
 294:	00078713          	mv	a4,a5
 298:	06500793          	li	a5,101
 29c:	0af71863          	bne	a4,a5,34c <parse_cmd+0x108>
 2a0:	d0843783          	ld	a5,-760(s0)
 2a4:	00178793          	addi	a5,a5,1
 2a8:	0007c783          	lbu	a5,0(a5)
 2ac:	00078713          	mv	a4,a5
 2b0:	06300793          	li	a5,99
 2b4:	08f71c63          	bne	a4,a5,34c <parse_cmd+0x108>
 2b8:	d0843783          	ld	a5,-760(s0)
 2bc:	00278793          	addi	a5,a5,2
 2c0:	0007c783          	lbu	a5,0(a5)
 2c4:	00078713          	mv	a4,a5
 2c8:	06800793          	li	a5,104
 2cc:	08f71063          	bne	a4,a5,34c <parse_cmd+0x108>
 2d0:	d0843783          	ld	a5,-760(s0)
 2d4:	00378793          	addi	a5,a5,3
 2d8:	0007c783          	lbu	a5,0(a5)
 2dc:	00078713          	mv	a4,a5
 2e0:	06f00793          	li	a5,111
 2e4:	06f71463          	bne	a4,a5,34c <parse_cmd+0x108>
 2e8:	d0843783          	ld	a5,-760(s0)
 2ec:	00478793          	addi	a5,a5,4
 2f0:	d0f43423          	sd	a5,-760(s0)
 2f4:	d0843503          	ld	a0,-760(s0)
 2f8:	e6dff0ef          	jal	164 <get_string>
 2fc:	f6a43823          	sd	a0,-144(s0)
 300:	f7043503          	ld	a0,-144(s0)
 304:	7a8010ef          	jal	1aac <strlen>
 308:	00050793          	mv	a5,a0
 30c:	d0f42223          	sw	a5,-764(s0)
 310:	d0442783          	lw	a5,-764(s0)
 314:	d0843703          	ld	a4,-760(s0)
 318:	00f707b3          	add	a5,a4,a5
 31c:	d0f43423          	sd	a5,-760(s0)
 320:	d0442783          	lw	a5,-764(s0)
 324:	00078613          	mv	a2,a5
 328:	f7043583          	ld	a1,-144(s0)
 32c:	00100513          	li	a0,1
 330:	7c8010ef          	jal	1af8 <write>
 334:	00100613          	li	a2,1
 338:	00002597          	auipc	a1,0x2
 33c:	aa858593          	addi	a1,a1,-1368 # 1de0 <lseek+0x70>
 340:	00100513          	li	a0,1
 344:	7b4010ef          	jal	1af8 <write>
 348:	62c0006f          	j	974 <parse_cmd+0x730>
 34c:	d0843783          	ld	a5,-760(s0)
 350:	0007c783          	lbu	a5,0(a5)
 354:	00078713          	mv	a4,a5
 358:	06300793          	li	a5,99
 35c:	16f71663          	bne	a4,a5,4c8 <parse_cmd+0x284>
 360:	d0843783          	ld	a5,-760(s0)
 364:	00178793          	addi	a5,a5,1
 368:	0007c783          	lbu	a5,0(a5)
 36c:	00078713          	mv	a4,a5
 370:	06100793          	li	a5,97
 374:	14f71a63          	bne	a4,a5,4c8 <parse_cmd+0x284>
 378:	d0843783          	ld	a5,-760(s0)
 37c:	00278793          	addi	a5,a5,2
 380:	0007c783          	lbu	a5,0(a5)
 384:	00078713          	mv	a4,a5
 388:	07400793          	li	a5,116
 38c:	12f71e63          	bne	a4,a5,4c8 <parse_cmd+0x284>
 390:	d0843783          	ld	a5,-760(s0)
 394:	00378793          	addi	a5,a5,3
 398:	00078513          	mv	a0,a5
 39c:	d15ff0ef          	jal	b0 <get_param>
 3a0:	f6a43423          	sd	a0,-152(s0)
 3a4:	00100593          	li	a1,1
 3a8:	f6843503          	ld	a0,-152(s0)
 3ac:	135010ef          	jal	1ce0 <open>
 3b0:	00050793          	mv	a5,a0
 3b4:	f6f42223          	sw	a5,-156(s0)
 3b8:	f6442783          	lw	a5,-156(s0)
 3bc:	0007871b          	sext.w	a4,a5
 3c0:	fff00793          	li	a5,-1
 3c4:	00f71c63          	bne	a4,a5,3dc <parse_cmd+0x198>
 3c8:	f6843583          	ld	a1,-152(s0)
 3cc:	00002517          	auipc	a0,0x2
 3d0:	a1c50513          	addi	a0,a0,-1508 # 1de8 <lseek+0x78>
 3d4:	5dc010ef          	jal	19b0 <printf>
 3d8:	59c0006f          	j	974 <parse_cmd+0x730>
 3dc:	d1840713          	addi	a4,s0,-744
 3e0:	f6442783          	lw	a5,-156(s0)
 3e4:	1fd00613          	li	a2,509
 3e8:	00070593          	mv	a1,a4
 3ec:	00078513          	mv	a0,a5
 3f0:	029010ef          	jal	1c18 <read>
 3f4:	00050793          	mv	a5,a0
 3f8:	f6f42023          	sw	a5,-160(s0)
 3fc:	f6042783          	lw	a5,-160(s0)
 400:	0007879b          	sext.w	a5,a5
 404:	02079263          	bnez	a5,428 <parse_cmd+0x1e4>
 408:	f8f44783          	lbu	a5,-113(s0)
 40c:	0ff7f713          	zext.b	a4,a5
 410:	00a00793          	li	a5,10
 414:	0af70063          	beq	a4,a5,4b4 <parse_cmd+0x270>
 418:	00002517          	auipc	a0,0x2
 41c:	9e850513          	addi	a0,a0,-1560 # 1e00 <lseek+0x90>
 420:	590010ef          	jal	19b0 <printf>
 424:	0900006f          	j	4b4 <parse_cmd+0x270>
 428:	f8042423          	sw	zero,-120(s0)
 42c:	06c0006f          	j	498 <parse_cmd+0x254>
 430:	f8842783          	lw	a5,-120(s0)
 434:	f9078793          	addi	a5,a5,-112
 438:	008787b3          	add	a5,a5,s0
 43c:	d887c783          	lbu	a5,-632(a5)
 440:	00079e63          	bnez	a5,45c <parse_cmd+0x218>
 444:	00100613          	li	a2,1
 448:	00002597          	auipc	a1,0x2
 44c:	9c058593          	addi	a1,a1,-1600 # 1e08 <lseek+0x98>
 450:	00100513          	li	a0,1
 454:	6a4010ef          	jal	1af8 <write>
 458:	0200006f          	j	478 <parse_cmd+0x234>
 45c:	d1840713          	addi	a4,s0,-744
 460:	f8842783          	lw	a5,-120(s0)
 464:	00f707b3          	add	a5,a4,a5
 468:	00100613          	li	a2,1
 46c:	00078593          	mv	a1,a5
 470:	00100513          	li	a0,1
 474:	684010ef          	jal	1af8 <write>
 478:	f8842783          	lw	a5,-120(s0)
 47c:	f9078793          	addi	a5,a5,-112
 480:	008787b3          	add	a5,a5,s0
 484:	d887c783          	lbu	a5,-632(a5)
 488:	f8f407a3          	sb	a5,-113(s0)
 48c:	f8842783          	lw	a5,-120(s0)
 490:	0017879b          	addiw	a5,a5,1
 494:	f8f42423          	sw	a5,-120(s0)
 498:	f8842783          	lw	a5,-120(s0)
 49c:	00078713          	mv	a4,a5
 4a0:	f6042783          	lw	a5,-160(s0)
 4a4:	0007071b          	sext.w	a4,a4
 4a8:	0007879b          	sext.w	a5,a5
 4ac:	f8f742e3          	blt	a4,a5,430 <parse_cmd+0x1ec>
 4b0:	f2dff06f          	j	3dc <parse_cmd+0x198>
 4b4:	00000013          	nop
 4b8:	f6442783          	lw	a5,-156(s0)
 4bc:	00078513          	mv	a0,a5
 4c0:	069010ef          	jal	1d28 <close>
 4c4:	4b00006f          	j	974 <parse_cmd+0x730>
 4c8:	d0843783          	ld	a5,-760(s0)
 4cc:	0007c783          	lbu	a5,0(a5)
 4d0:	00078713          	mv	a4,a5
 4d4:	06500793          	li	a5,101
 4d8:	48f71663          	bne	a4,a5,964 <parse_cmd+0x720>
 4dc:	d0843783          	ld	a5,-760(s0)
 4e0:	00178793          	addi	a5,a5,1
 4e4:	0007c783          	lbu	a5,0(a5)
 4e8:	00078713          	mv	a4,a5
 4ec:	06400793          	li	a5,100
 4f0:	46f71a63          	bne	a4,a5,964 <parse_cmd+0x720>
 4f4:	d0843783          	ld	a5,-760(s0)
 4f8:	00278793          	addi	a5,a5,2
 4fc:	0007c783          	lbu	a5,0(a5)
 500:	00078713          	mv	a4,a5
 504:	06900793          	li	a5,105
 508:	44f71e63          	bne	a4,a5,964 <parse_cmd+0x720>
 50c:	d0843783          	ld	a5,-760(s0)
 510:	00378793          	addi	a5,a5,3
 514:	0007c783          	lbu	a5,0(a5)
 518:	00078713          	mv	a4,a5
 51c:	07400793          	li	a5,116
 520:	44f71263          	bne	a4,a5,964 <parse_cmd+0x720>
 524:	00010793          	mv	a5,sp
 528:	00078493          	mv	s1,a5
 52c:	d0843783          	ld	a5,-760(s0)
 530:	00478793          	addi	a5,a5,4
 534:	d0f43423          	sd	a5,-760(s0)
 538:	0100006f          	j	548 <parse_cmd+0x304>
 53c:	d0843783          	ld	a5,-760(s0)
 540:	00178793          	addi	a5,a5,1
 544:	d0f43423          	sd	a5,-760(s0)
 548:	d0843783          	ld	a5,-760(s0)
 54c:	0007c783          	lbu	a5,0(a5)
 550:	00078713          	mv	a4,a5
 554:	02000793          	li	a5,32
 558:	00f71863          	bne	a4,a5,568 <parse_cmd+0x324>
 55c:	d0843783          	ld	a5,-760(s0)
 560:	0007c783          	lbu	a5,0(a5)
 564:	fc079ce3          	bnez	a5,53c <parse_cmd+0x2f8>
 568:	d0843503          	ld	a0,-760(s0)
 56c:	b45ff0ef          	jal	b0 <get_param>
 570:	f4a43c23          	sd	a0,-168(s0)
 574:	f5843503          	ld	a0,-168(s0)
 578:	534010ef          	jal	1aac <strlen>
 57c:	00050793          	mv	a5,a0
 580:	f4f42a23          	sw	a5,-172(s0)
 584:	f5442783          	lw	a5,-172(s0)
 588:	0017879b          	addiw	a5,a5,1
 58c:	0007879b          	sext.w	a5,a5
 590:	00078713          	mv	a4,a5
 594:	fff70713          	addi	a4,a4,-1
 598:	f4e43423          	sd	a4,-184(s0)
 59c:	00078713          	mv	a4,a5
 5a0:	cee43823          	sd	a4,-784(s0)
 5a4:	ce043c23          	sd	zero,-776(s0)
 5a8:	cf043703          	ld	a4,-784(s0)
 5ac:	03d75713          	srli	a4,a4,0x3d
 5b0:	cf843683          	ld	a3,-776(s0)
 5b4:	00369693          	slli	a3,a3,0x3
 5b8:	c8d43c23          	sd	a3,-872(s0)
 5bc:	c9843683          	ld	a3,-872(s0)
 5c0:	00d76733          	or	a4,a4,a3
 5c4:	c8e43c23          	sd	a4,-872(s0)
 5c8:	cf043703          	ld	a4,-784(s0)
 5cc:	00371713          	slli	a4,a4,0x3
 5d0:	c8e43823          	sd	a4,-880(s0)
 5d4:	00078713          	mv	a4,a5
 5d8:	cee43023          	sd	a4,-800(s0)
 5dc:	ce043423          	sd	zero,-792(s0)
 5e0:	ce043703          	ld	a4,-800(s0)
 5e4:	03d75713          	srli	a4,a4,0x3d
 5e8:	ce843683          	ld	a3,-792(s0)
 5ec:	00369d93          	slli	s11,a3,0x3
 5f0:	01b76db3          	or	s11,a4,s11
 5f4:	ce043703          	ld	a4,-800(s0)
 5f8:	00371d13          	slli	s10,a4,0x3
 5fc:	00f78793          	addi	a5,a5,15
 600:	0047d793          	srli	a5,a5,0x4
 604:	00479793          	slli	a5,a5,0x4
 608:	40f10133          	sub	sp,sp,a5
 60c:	00010793          	mv	a5,sp
 610:	00078793          	mv	a5,a5
 614:	f4f43023          	sd	a5,-192(s0)
 618:	f8042223          	sw	zero,-124(s0)
 61c:	0300006f          	j	64c <parse_cmd+0x408>
 620:	f8442783          	lw	a5,-124(s0)
 624:	f5843703          	ld	a4,-168(s0)
 628:	00f707b3          	add	a5,a4,a5
 62c:	0007c703          	lbu	a4,0(a5)
 630:	f4043683          	ld	a3,-192(s0)
 634:	f8442783          	lw	a5,-124(s0)
 638:	00f687b3          	add	a5,a3,a5
 63c:	00e78023          	sb	a4,0(a5)
 640:	f8442783          	lw	a5,-124(s0)
 644:	0017879b          	addiw	a5,a5,1
 648:	f8f42223          	sw	a5,-124(s0)
 64c:	f8442783          	lw	a5,-124(s0)
 650:	00078713          	mv	a4,a5
 654:	f5442783          	lw	a5,-172(s0)
 658:	0007071b          	sext.w	a4,a4
 65c:	0007879b          	sext.w	a5,a5
 660:	fcf740e3          	blt	a4,a5,620 <parse_cmd+0x3dc>
 664:	f4043703          	ld	a4,-192(s0)
 668:	f5442783          	lw	a5,-172(s0)
 66c:	00f707b3          	add	a5,a4,a5
 670:	00078023          	sb	zero,0(a5)
 674:	f5442783          	lw	a5,-172(s0)
 678:	d0843703          	ld	a4,-760(s0)
 67c:	00f707b3          	add	a5,a4,a5
 680:	d0f43423          	sd	a5,-760(s0)
 684:	0100006f          	j	694 <parse_cmd+0x450>
 688:	d0843783          	ld	a5,-760(s0)
 68c:	00178793          	addi	a5,a5,1
 690:	d0f43423          	sd	a5,-760(s0)
 694:	d0843783          	ld	a5,-760(s0)
 698:	0007c783          	lbu	a5,0(a5)
 69c:	00078713          	mv	a4,a5
 6a0:	02000793          	li	a5,32
 6a4:	00f71863          	bne	a4,a5,6b4 <parse_cmd+0x470>
 6a8:	d0843783          	ld	a5,-760(s0)
 6ac:	0007c783          	lbu	a5,0(a5)
 6b0:	fc079ce3          	bnez	a5,688 <parse_cmd+0x444>
 6b4:	d0843503          	ld	a0,-760(s0)
 6b8:	9f9ff0ef          	jal	b0 <get_param>
 6bc:	f4a43c23          	sd	a0,-168(s0)
 6c0:	f5843503          	ld	a0,-168(s0)
 6c4:	3e8010ef          	jal	1aac <strlen>
 6c8:	00050793          	mv	a5,a0
 6cc:	f4f42a23          	sw	a5,-172(s0)
 6d0:	f5442783          	lw	a5,-172(s0)
 6d4:	0017879b          	addiw	a5,a5,1
 6d8:	0007879b          	sext.w	a5,a5
 6dc:	00078713          	mv	a4,a5
 6e0:	fff70713          	addi	a4,a4,-1
 6e4:	f2e43c23          	sd	a4,-200(s0)
 6e8:	00078713          	mv	a4,a5
 6ec:	cce43823          	sd	a4,-816(s0)
 6f0:	cc043c23          	sd	zero,-808(s0)
 6f4:	cd043703          	ld	a4,-816(s0)
 6f8:	03d75713          	srli	a4,a4,0x3d
 6fc:	cd843683          	ld	a3,-808(s0)
 700:	00369c93          	slli	s9,a3,0x3
 704:	01976cb3          	or	s9,a4,s9
 708:	cd043703          	ld	a4,-816(s0)
 70c:	00371c13          	slli	s8,a4,0x3
 710:	00078713          	mv	a4,a5
 714:	cce43023          	sd	a4,-832(s0)
 718:	cc043423          	sd	zero,-824(s0)
 71c:	cc043703          	ld	a4,-832(s0)
 720:	03d75713          	srli	a4,a4,0x3d
 724:	cc843683          	ld	a3,-824(s0)
 728:	00369b93          	slli	s7,a3,0x3
 72c:	01776bb3          	or	s7,a4,s7
 730:	cc043703          	ld	a4,-832(s0)
 734:	00371b13          	slli	s6,a4,0x3
 738:	00f78793          	addi	a5,a5,15
 73c:	0047d793          	srli	a5,a5,0x4
 740:	00479793          	slli	a5,a5,0x4
 744:	40f10133          	sub	sp,sp,a5
 748:	00010793          	mv	a5,sp
 74c:	00078793          	mv	a5,a5
 750:	f2f43823          	sd	a5,-208(s0)
 754:	f8042023          	sw	zero,-128(s0)
 758:	0300006f          	j	788 <parse_cmd+0x544>
 75c:	f8042783          	lw	a5,-128(s0)
 760:	f5843703          	ld	a4,-168(s0)
 764:	00f707b3          	add	a5,a4,a5
 768:	0007c703          	lbu	a4,0(a5)
 76c:	f3043683          	ld	a3,-208(s0)
 770:	f8042783          	lw	a5,-128(s0)
 774:	00f687b3          	add	a5,a3,a5
 778:	00e78023          	sb	a4,0(a5)
 77c:	f8042783          	lw	a5,-128(s0)
 780:	0017879b          	addiw	a5,a5,1
 784:	f8f42023          	sw	a5,-128(s0)
 788:	f8042783          	lw	a5,-128(s0)
 78c:	00078713          	mv	a4,a5
 790:	f5442783          	lw	a5,-172(s0)
 794:	0007071b          	sext.w	a4,a4
 798:	0007879b          	sext.w	a5,a5
 79c:	fcf740e3          	blt	a4,a5,75c <parse_cmd+0x518>
 7a0:	f3043703          	ld	a4,-208(s0)
 7a4:	f5442783          	lw	a5,-172(s0)
 7a8:	00f707b3          	add	a5,a4,a5
 7ac:	00078023          	sb	zero,0(a5)
 7b0:	f5442783          	lw	a5,-172(s0)
 7b4:	d0843703          	ld	a4,-760(s0)
 7b8:	00f707b3          	add	a5,a4,a5
 7bc:	d0f43423          	sd	a5,-760(s0)
 7c0:	0100006f          	j	7d0 <parse_cmd+0x58c>
 7c4:	d0843783          	ld	a5,-760(s0)
 7c8:	00178793          	addi	a5,a5,1
 7cc:	d0f43423          	sd	a5,-760(s0)
 7d0:	d0843783          	ld	a5,-760(s0)
 7d4:	0007c783          	lbu	a5,0(a5)
 7d8:	00078713          	mv	a4,a5
 7dc:	02000793          	li	a5,32
 7e0:	00f71863          	bne	a4,a5,7f0 <parse_cmd+0x5ac>
 7e4:	d0843783          	ld	a5,-760(s0)
 7e8:	0007c783          	lbu	a5,0(a5)
 7ec:	fc079ce3          	bnez	a5,7c4 <parse_cmd+0x580>
 7f0:	d0843503          	ld	a0,-760(s0)
 7f4:	971ff0ef          	jal	164 <get_string>
 7f8:	f4a43c23          	sd	a0,-168(s0)
 7fc:	f5843503          	ld	a0,-168(s0)
 800:	2ac010ef          	jal	1aac <strlen>
 804:	00050793          	mv	a5,a0
 808:	f4f42a23          	sw	a5,-172(s0)
 80c:	f5442783          	lw	a5,-172(s0)
 810:	0017879b          	addiw	a5,a5,1
 814:	0007879b          	sext.w	a5,a5
 818:	00078713          	mv	a4,a5
 81c:	fff70713          	addi	a4,a4,-1
 820:	f2e43423          	sd	a4,-216(s0)
 824:	00078713          	mv	a4,a5
 828:	cae43823          	sd	a4,-848(s0)
 82c:	ca043c23          	sd	zero,-840(s0)
 830:	cb043703          	ld	a4,-848(s0)
 834:	03d75713          	srli	a4,a4,0x3d
 838:	cb843683          	ld	a3,-840(s0)
 83c:	00369a93          	slli	s5,a3,0x3
 840:	01576ab3          	or	s5,a4,s5
 844:	cb043703          	ld	a4,-848(s0)
 848:	00371a13          	slli	s4,a4,0x3
 84c:	00078713          	mv	a4,a5
 850:	cae43023          	sd	a4,-864(s0)
 854:	ca043423          	sd	zero,-856(s0)
 858:	ca043703          	ld	a4,-864(s0)
 85c:	03d75713          	srli	a4,a4,0x3d
 860:	ca843683          	ld	a3,-856(s0)
 864:	00369993          	slli	s3,a3,0x3
 868:	013769b3          	or	s3,a4,s3
 86c:	ca043703          	ld	a4,-864(s0)
 870:	00371913          	slli	s2,a4,0x3
 874:	00f78793          	addi	a5,a5,15
 878:	0047d793          	srli	a5,a5,0x4
 87c:	00479793          	slli	a5,a5,0x4
 880:	40f10133          	sub	sp,sp,a5
 884:	00010793          	mv	a5,sp
 888:	00078793          	mv	a5,a5
 88c:	f2f43023          	sd	a5,-224(s0)
 890:	f6042e23          	sw	zero,-132(s0)
 894:	0300006f          	j	8c4 <parse_cmd+0x680>
 898:	f7c42783          	lw	a5,-132(s0)
 89c:	f5843703          	ld	a4,-168(s0)
 8a0:	00f707b3          	add	a5,a4,a5
 8a4:	0007c703          	lbu	a4,0(a5)
 8a8:	f2043683          	ld	a3,-224(s0)
 8ac:	f7c42783          	lw	a5,-132(s0)
 8b0:	00f687b3          	add	a5,a3,a5
 8b4:	00e78023          	sb	a4,0(a5)
 8b8:	f7c42783          	lw	a5,-132(s0)
 8bc:	0017879b          	addiw	a5,a5,1
 8c0:	f6f42e23          	sw	a5,-132(s0)
 8c4:	f7c42783          	lw	a5,-132(s0)
 8c8:	00078713          	mv	a4,a5
 8cc:	f5442783          	lw	a5,-172(s0)
 8d0:	0007071b          	sext.w	a4,a4
 8d4:	0007879b          	sext.w	a5,a5
 8d8:	fcf740e3          	blt	a4,a5,898 <parse_cmd+0x654>
 8dc:	f2043703          	ld	a4,-224(s0)
 8e0:	f5442783          	lw	a5,-172(s0)
 8e4:	00f707b3          	add	a5,a4,a5
 8e8:	00078023          	sb	zero,0(a5)
 8ec:	f5442783          	lw	a5,-172(s0)
 8f0:	d0843703          	ld	a4,-760(s0)
 8f4:	00f707b3          	add	a5,a4,a5
 8f8:	d0f43423          	sd	a5,-760(s0)
 8fc:	f3043503          	ld	a0,-208(s0)
 900:	f04ff0ef          	jal	4 <atoi>
 904:	00050793          	mv	a5,a0
 908:	f0f42e23          	sw	a5,-228(s0)
 90c:	00300593          	li	a1,3
 910:	f4043503          	ld	a0,-192(s0)
 914:	3cc010ef          	jal	1ce0 <open>
 918:	00050793          	mv	a5,a0
 91c:	f0f42c23          	sw	a5,-232(s0)
 920:	f1c42703          	lw	a4,-228(s0)
 924:	f1842783          	lw	a5,-232(s0)
 928:	00000613          	li	a2,0
 92c:	00070593          	mv	a1,a4
 930:	00078513          	mv	a0,a5
 934:	43c010ef          	jal	1d70 <lseek>
 938:	f5442703          	lw	a4,-172(s0)
 93c:	f1842783          	lw	a5,-232(s0)
 940:	00070613          	mv	a2,a4
 944:	f2043583          	ld	a1,-224(s0)
 948:	00078513          	mv	a0,a5
 94c:	1ac010ef          	jal	1af8 <write>
 950:	f1842783          	lw	a5,-232(s0)
 954:	00078513          	mv	a0,a5
 958:	3d0010ef          	jal	1d28 <close>
 95c:	00048113          	mv	sp,s1
 960:	0140006f          	j	974 <parse_cmd+0x730>
 964:	d0843583          	ld	a1,-760(s0)
 968:	00001517          	auipc	a0,0x1
 96c:	4a850513          	addi	a0,a0,1192 # 1e10 <lseek+0xa0>
 970:	040010ef          	jal	19b0 <printf>
 974:	c9040113          	addi	sp,s0,-880
 978:	36813083          	ld	ra,872(sp)
 97c:	36013403          	ld	s0,864(sp)
 980:	35813483          	ld	s1,856(sp)
 984:	35013903          	ld	s2,848(sp)
 988:	34813983          	ld	s3,840(sp)
 98c:	34013a03          	ld	s4,832(sp)
 990:	33813a83          	ld	s5,824(sp)
 994:	33013b03          	ld	s6,816(sp)
 998:	32813b83          	ld	s7,808(sp)
 99c:	32013c03          	ld	s8,800(sp)
 9a0:	31813c83          	ld	s9,792(sp)
 9a4:	31013d03          	ld	s10,784(sp)
 9a8:	30813d83          	ld	s11,776(sp)
 9ac:	37010113          	addi	sp,sp,880
 9b0:	00008067          	ret

Disassembly of section .text.main:

00000000000009b4 <main>:
 9b4:	f6010113          	addi	sp,sp,-160
 9b8:	08113c23          	sd	ra,152(sp)
 9bc:	08813823          	sd	s0,144(sp)
 9c0:	0a010413          	addi	s0,sp,160
 9c4:	00f00613          	li	a2,15
 9c8:	00001597          	auipc	a1,0x1
 9cc:	46058593          	addi	a1,a1,1120 # 1e28 <lseek+0xb8>
 9d0:	00100513          	li	a0,1
 9d4:	124010ef          	jal	1af8 <write>
 9d8:	00f00613          	li	a2,15
 9dc:	00001597          	auipc	a1,0x1
 9e0:	45c58593          	addi	a1,a1,1116 # 1e38 <lseek+0xc8>
 9e4:	00200513          	li	a0,2
 9e8:	110010ef          	jal	1af8 <write>
 9ec:	fe042623          	sw	zero,-20(s0)
 9f0:	00001517          	auipc	a0,0x1
 9f4:	45850513          	addi	a0,a0,1112 # 1e48 <lseek+0xd8>
 9f8:	7b9000ef          	jal	19b0 <printf>
 9fc:	fe840793          	addi	a5,s0,-24
 a00:	00100613          	li	a2,1
 a04:	00078593          	mv	a1,a5
 a08:	00000513          	li	a0,0
 a0c:	20c010ef          	jal	1c18 <read>
 a10:	fe844783          	lbu	a5,-24(s0)
 a14:	00078713          	mv	a4,a5
 a18:	00d00793          	li	a5,13
 a1c:	00f71e63          	bne	a4,a5,a38 <main+0x84>
 a20:	00100613          	li	a2,1
 a24:	00001597          	auipc	a1,0x1
 a28:	3bc58593          	addi	a1,a1,956 # 1de0 <lseek+0x70>
 a2c:	00100513          	li	a0,1
 a30:	0c8010ef          	jal	1af8 <write>
 a34:	0440006f          	j	a78 <main+0xc4>
 a38:	fe844783          	lbu	a5,-24(s0)
 a3c:	00078713          	mv	a4,a5
 a40:	07f00793          	li	a5,127
 a44:	02f71a63          	bne	a4,a5,a78 <main+0xc4>
 a48:	fec42783          	lw	a5,-20(s0)
 a4c:	0007879b          	sext.w	a5,a5
 a50:	0af05263          	blez	a5,af4 <main+0x140>
 a54:	00300613          	li	a2,3
 a58:	00001597          	auipc	a1,0x1
 a5c:	40858593          	addi	a1,a1,1032 # 1e60 <lseek+0xf0>
 a60:	00100513          	li	a0,1
 a64:	094010ef          	jal	1af8 <write>
 a68:	fec42783          	lw	a5,-20(s0)
 a6c:	fff7879b          	addiw	a5,a5,-1
 a70:	fef42623          	sw	a5,-20(s0)
 a74:	0800006f          	j	af4 <main+0x140>
 a78:	fe840793          	addi	a5,s0,-24
 a7c:	00100613          	li	a2,1
 a80:	00078593          	mv	a1,a5
 a84:	00100513          	li	a0,1
 a88:	070010ef          	jal	1af8 <write>
 a8c:	fe844783          	lbu	a5,-24(s0)
 a90:	00078713          	mv	a4,a5
 a94:	00d00793          	li	a5,13
 a98:	02f71e63          	bne	a4,a5,ad4 <main+0x120>
 a9c:	fec42783          	lw	a5,-20(s0)
 aa0:	ff078793          	addi	a5,a5,-16
 aa4:	008787b3          	add	a5,a5,s0
 aa8:	f6078c23          	sb	zero,-136(a5)
 aac:	fec42703          	lw	a4,-20(s0)
 ab0:	f6840793          	addi	a5,s0,-152
 ab4:	00070593          	mv	a1,a4
 ab8:	00078513          	mv	a0,a5
 abc:	f88ff0ef          	jal	244 <parse_cmd>
 ac0:	fe042623          	sw	zero,-20(s0)
 ac4:	00001517          	auipc	a0,0x1
 ac8:	38450513          	addi	a0,a0,900 # 1e48 <lseek+0xd8>
 acc:	6e5000ef          	jal	19b0 <printf>
 ad0:	f2dff06f          	j	9fc <main+0x48>
 ad4:	fec42783          	lw	a5,-20(s0)
 ad8:	0017871b          	addiw	a4,a5,1
 adc:	fee42623          	sw	a4,-20(s0)
 ae0:	fe844703          	lbu	a4,-24(s0)
 ae4:	ff078793          	addi	a5,a5,-16
 ae8:	008787b3          	add	a5,a5,s0
 aec:	f6e78c23          	sb	a4,-136(a5)
 af0:	f0dff06f          	j	9fc <main+0x48>
 af4:	00000013          	nop
 af8:	f05ff06f          	j	9fc <main+0x48>

Disassembly of section .text.putc:

0000000000000afc <putc>:
 afc:	fe010113          	addi	sp,sp,-32
 b00:	00813c23          	sd	s0,24(sp)
 b04:	02010413          	addi	s0,sp,32
 b08:	00050793          	mv	a5,a0
 b0c:	fef42623          	sw	a5,-20(s0)
 b10:	00002797          	auipc	a5,0x2
 b14:	6d078793          	addi	a5,a5,1744 # 31e0 <tail>
 b18:	0007a783          	lw	a5,0(a5)
 b1c:	0017871b          	addiw	a4,a5,1
 b20:	0007069b          	sext.w	a3,a4
 b24:	00002717          	auipc	a4,0x2
 b28:	6bc70713          	addi	a4,a4,1724 # 31e0 <tail>
 b2c:	00d72023          	sw	a3,0(a4)
 b30:	fec42703          	lw	a4,-20(s0)
 b34:	0ff77713          	zext.b	a4,a4
 b38:	00002697          	auipc	a3,0x2
 b3c:	6b068693          	addi	a3,a3,1712 # 31e8 <buffer>
 b40:	00f687b3          	add	a5,a3,a5
 b44:	00e78023          	sb	a4,0(a5)
 b48:	fec42783          	lw	a5,-20(s0)
 b4c:	0ff7f793          	zext.b	a5,a5
 b50:	0007879b          	sext.w	a5,a5
 b54:	00078513          	mv	a0,a5
 b58:	01813403          	ld	s0,24(sp)
 b5c:	02010113          	addi	sp,sp,32
 b60:	00008067          	ret

Disassembly of section .text.isspace:

0000000000000b64 <isspace>:
 b64:	fe010113          	addi	sp,sp,-32
 b68:	00813c23          	sd	s0,24(sp)
 b6c:	02010413          	addi	s0,sp,32
 b70:	00050793          	mv	a5,a0
 b74:	fef42623          	sw	a5,-20(s0)
 b78:	fec42783          	lw	a5,-20(s0)
 b7c:	0007871b          	sext.w	a4,a5
 b80:	02000793          	li	a5,32
 b84:	02f70263          	beq	a4,a5,ba8 <isspace+0x44>
 b88:	fec42783          	lw	a5,-20(s0)
 b8c:	0007871b          	sext.w	a4,a5
 b90:	00800793          	li	a5,8
 b94:	00e7de63          	bge	a5,a4,bb0 <isspace+0x4c>
 b98:	fec42783          	lw	a5,-20(s0)
 b9c:	0007871b          	sext.w	a4,a5
 ba0:	00d00793          	li	a5,13
 ba4:	00e7c663          	blt	a5,a4,bb0 <isspace+0x4c>
 ba8:	00100793          	li	a5,1
 bac:	0080006f          	j	bb4 <isspace+0x50>
 bb0:	00000793          	li	a5,0
 bb4:	00078513          	mv	a0,a5
 bb8:	01813403          	ld	s0,24(sp)
 bbc:	02010113          	addi	sp,sp,32
 bc0:	00008067          	ret

Disassembly of section .text.strtol:

0000000000000bc4 <strtol>:
 bc4:	fb010113          	addi	sp,sp,-80
 bc8:	04113423          	sd	ra,72(sp)
 bcc:	04813023          	sd	s0,64(sp)
 bd0:	05010413          	addi	s0,sp,80
 bd4:	fca43423          	sd	a0,-56(s0)
 bd8:	fcb43023          	sd	a1,-64(s0)
 bdc:	00060793          	mv	a5,a2
 be0:	faf42e23          	sw	a5,-68(s0)
 be4:	fe043423          	sd	zero,-24(s0)
 be8:	fe0403a3          	sb	zero,-25(s0)
 bec:	fc843783          	ld	a5,-56(s0)
 bf0:	fcf43c23          	sd	a5,-40(s0)
 bf4:	0100006f          	j	c04 <strtol+0x40>
 bf8:	fd843783          	ld	a5,-40(s0)
 bfc:	00178793          	addi	a5,a5,1
 c00:	fcf43c23          	sd	a5,-40(s0)
 c04:	fd843783          	ld	a5,-40(s0)
 c08:	0007c783          	lbu	a5,0(a5)
 c0c:	0007879b          	sext.w	a5,a5
 c10:	00078513          	mv	a0,a5
 c14:	f51ff0ef          	jal	b64 <isspace>
 c18:	00050793          	mv	a5,a0
 c1c:	fc079ee3          	bnez	a5,bf8 <strtol+0x34>
 c20:	fd843783          	ld	a5,-40(s0)
 c24:	0007c783          	lbu	a5,0(a5)
 c28:	00078713          	mv	a4,a5
 c2c:	02d00793          	li	a5,45
 c30:	00f71e63          	bne	a4,a5,c4c <strtol+0x88>
 c34:	00100793          	li	a5,1
 c38:	fef403a3          	sb	a5,-25(s0)
 c3c:	fd843783          	ld	a5,-40(s0)
 c40:	00178793          	addi	a5,a5,1
 c44:	fcf43c23          	sd	a5,-40(s0)
 c48:	0240006f          	j	c6c <strtol+0xa8>
 c4c:	fd843783          	ld	a5,-40(s0)
 c50:	0007c783          	lbu	a5,0(a5)
 c54:	00078713          	mv	a4,a5
 c58:	02b00793          	li	a5,43
 c5c:	00f71863          	bne	a4,a5,c6c <strtol+0xa8>
 c60:	fd843783          	ld	a5,-40(s0)
 c64:	00178793          	addi	a5,a5,1
 c68:	fcf43c23          	sd	a5,-40(s0)
 c6c:	fbc42783          	lw	a5,-68(s0)
 c70:	0007879b          	sext.w	a5,a5
 c74:	06079c63          	bnez	a5,cec <strtol+0x128>
 c78:	fd843783          	ld	a5,-40(s0)
 c7c:	0007c783          	lbu	a5,0(a5)
 c80:	00078713          	mv	a4,a5
 c84:	03000793          	li	a5,48
 c88:	04f71e63          	bne	a4,a5,ce4 <strtol+0x120>
 c8c:	fd843783          	ld	a5,-40(s0)
 c90:	00178793          	addi	a5,a5,1
 c94:	fcf43c23          	sd	a5,-40(s0)
 c98:	fd843783          	ld	a5,-40(s0)
 c9c:	0007c783          	lbu	a5,0(a5)
 ca0:	00078713          	mv	a4,a5
 ca4:	07800793          	li	a5,120
 ca8:	00f70c63          	beq	a4,a5,cc0 <strtol+0xfc>
 cac:	fd843783          	ld	a5,-40(s0)
 cb0:	0007c783          	lbu	a5,0(a5)
 cb4:	00078713          	mv	a4,a5
 cb8:	05800793          	li	a5,88
 cbc:	00f71e63          	bne	a4,a5,cd8 <strtol+0x114>
 cc0:	01000793          	li	a5,16
 cc4:	faf42e23          	sw	a5,-68(s0)
 cc8:	fd843783          	ld	a5,-40(s0)
 ccc:	00178793          	addi	a5,a5,1
 cd0:	fcf43c23          	sd	a5,-40(s0)
 cd4:	0180006f          	j	cec <strtol+0x128>
 cd8:	00800793          	li	a5,8
 cdc:	faf42e23          	sw	a5,-68(s0)
 ce0:	00c0006f          	j	cec <strtol+0x128>
 ce4:	00a00793          	li	a5,10
 ce8:	faf42e23          	sw	a5,-68(s0)
 cec:	fd843783          	ld	a5,-40(s0)
 cf0:	0007c783          	lbu	a5,0(a5)
 cf4:	00078713          	mv	a4,a5
 cf8:	02f00793          	li	a5,47
 cfc:	02e7f863          	bgeu	a5,a4,d2c <strtol+0x168>
 d00:	fd843783          	ld	a5,-40(s0)
 d04:	0007c783          	lbu	a5,0(a5)
 d08:	00078713          	mv	a4,a5
 d0c:	03900793          	li	a5,57
 d10:	00e7ee63          	bltu	a5,a4,d2c <strtol+0x168>
 d14:	fd843783          	ld	a5,-40(s0)
 d18:	0007c783          	lbu	a5,0(a5)
 d1c:	0007879b          	sext.w	a5,a5
 d20:	fd07879b          	addiw	a5,a5,-48
 d24:	fcf42a23          	sw	a5,-44(s0)
 d28:	0800006f          	j	da8 <strtol+0x1e4>
 d2c:	fd843783          	ld	a5,-40(s0)
 d30:	0007c783          	lbu	a5,0(a5)
 d34:	00078713          	mv	a4,a5
 d38:	06000793          	li	a5,96
 d3c:	02e7f863          	bgeu	a5,a4,d6c <strtol+0x1a8>
 d40:	fd843783          	ld	a5,-40(s0)
 d44:	0007c783          	lbu	a5,0(a5)
 d48:	00078713          	mv	a4,a5
 d4c:	07a00793          	li	a5,122
 d50:	00e7ee63          	bltu	a5,a4,d6c <strtol+0x1a8>
 d54:	fd843783          	ld	a5,-40(s0)
 d58:	0007c783          	lbu	a5,0(a5)
 d5c:	0007879b          	sext.w	a5,a5
 d60:	fa97879b          	addiw	a5,a5,-87
 d64:	fcf42a23          	sw	a5,-44(s0)
 d68:	0400006f          	j	da8 <strtol+0x1e4>
 d6c:	fd843783          	ld	a5,-40(s0)
 d70:	0007c783          	lbu	a5,0(a5)
 d74:	00078713          	mv	a4,a5
 d78:	04000793          	li	a5,64
 d7c:	06e7f863          	bgeu	a5,a4,dec <strtol+0x228>
 d80:	fd843783          	ld	a5,-40(s0)
 d84:	0007c783          	lbu	a5,0(a5)
 d88:	00078713          	mv	a4,a5
 d8c:	05a00793          	li	a5,90
 d90:	04e7ee63          	bltu	a5,a4,dec <strtol+0x228>
 d94:	fd843783          	ld	a5,-40(s0)
 d98:	0007c783          	lbu	a5,0(a5)
 d9c:	0007879b          	sext.w	a5,a5
 da0:	fc97879b          	addiw	a5,a5,-55
 da4:	fcf42a23          	sw	a5,-44(s0)
 da8:	fd442783          	lw	a5,-44(s0)
 dac:	00078713          	mv	a4,a5
 db0:	fbc42783          	lw	a5,-68(s0)
 db4:	0007071b          	sext.w	a4,a4
 db8:	0007879b          	sext.w	a5,a5
 dbc:	02f75663          	bge	a4,a5,de8 <strtol+0x224>
 dc0:	fbc42703          	lw	a4,-68(s0)
 dc4:	fe843783          	ld	a5,-24(s0)
 dc8:	02f70733          	mul	a4,a4,a5
 dcc:	fd442783          	lw	a5,-44(s0)
 dd0:	00f707b3          	add	a5,a4,a5
 dd4:	fef43423          	sd	a5,-24(s0)
 dd8:	fd843783          	ld	a5,-40(s0)
 ddc:	00178793          	addi	a5,a5,1
 de0:	fcf43c23          	sd	a5,-40(s0)
 de4:	f09ff06f          	j	cec <strtol+0x128>
 de8:	00000013          	nop
 dec:	fc043783          	ld	a5,-64(s0)
 df0:	00078863          	beqz	a5,e00 <strtol+0x23c>
 df4:	fc043783          	ld	a5,-64(s0)
 df8:	fd843703          	ld	a4,-40(s0)
 dfc:	00e7b023          	sd	a4,0(a5)
 e00:	fe744783          	lbu	a5,-25(s0)
 e04:	0ff7f793          	zext.b	a5,a5
 e08:	00078863          	beqz	a5,e18 <strtol+0x254>
 e0c:	fe843783          	ld	a5,-24(s0)
 e10:	40f007b3          	neg	a5,a5
 e14:	0080006f          	j	e1c <strtol+0x258>
 e18:	fe843783          	ld	a5,-24(s0)
 e1c:	00078513          	mv	a0,a5
 e20:	04813083          	ld	ra,72(sp)
 e24:	04013403          	ld	s0,64(sp)
 e28:	05010113          	addi	sp,sp,80
 e2c:	00008067          	ret

Disassembly of section .text.puts_wo_nl:

0000000000000e30 <puts_wo_nl>:
 e30:	fd010113          	addi	sp,sp,-48
 e34:	02113423          	sd	ra,40(sp)
 e38:	02813023          	sd	s0,32(sp)
 e3c:	03010413          	addi	s0,sp,48
 e40:	fca43c23          	sd	a0,-40(s0)
 e44:	fcb43823          	sd	a1,-48(s0)
 e48:	fd043783          	ld	a5,-48(s0)
 e4c:	00079863          	bnez	a5,e5c <puts_wo_nl+0x2c>
 e50:	00001797          	auipc	a5,0x1
 e54:	01878793          	addi	a5,a5,24 # 1e68 <lseek+0xf8>
 e58:	fcf43823          	sd	a5,-48(s0)
 e5c:	fd043783          	ld	a5,-48(s0)
 e60:	fef43423          	sd	a5,-24(s0)
 e64:	0240006f          	j	e88 <puts_wo_nl+0x58>
 e68:	fe843783          	ld	a5,-24(s0)
 e6c:	00178713          	addi	a4,a5,1
 e70:	fee43423          	sd	a4,-24(s0)
 e74:	0007c783          	lbu	a5,0(a5)
 e78:	0007871b          	sext.w	a4,a5
 e7c:	fd843783          	ld	a5,-40(s0)
 e80:	00070513          	mv	a0,a4
 e84:	000780e7          	jalr	a5
 e88:	fe843783          	ld	a5,-24(s0)
 e8c:	0007c783          	lbu	a5,0(a5)
 e90:	fc079ce3          	bnez	a5,e68 <puts_wo_nl+0x38>
 e94:	fe843703          	ld	a4,-24(s0)
 e98:	fd043783          	ld	a5,-48(s0)
 e9c:	40f707b3          	sub	a5,a4,a5
 ea0:	0007879b          	sext.w	a5,a5
 ea4:	00078513          	mv	a0,a5
 ea8:	02813083          	ld	ra,40(sp)
 eac:	02013403          	ld	s0,32(sp)
 eb0:	03010113          	addi	sp,sp,48
 eb4:	00008067          	ret

Disassembly of section .text.print_dec_int:

0000000000000eb8 <print_dec_int>:
     eb8:	f9010113          	addi	sp,sp,-112
     ebc:	06113423          	sd	ra,104(sp)
     ec0:	06813023          	sd	s0,96(sp)
     ec4:	07010413          	addi	s0,sp,112
     ec8:	faa43423          	sd	a0,-88(s0)
     ecc:	fab43023          	sd	a1,-96(s0)
     ed0:	00060793          	mv	a5,a2
     ed4:	f8d43823          	sd	a3,-112(s0)
     ed8:	f8f40fa3          	sb	a5,-97(s0)
     edc:	f9f44783          	lbu	a5,-97(s0)
     ee0:	0ff7f793          	zext.b	a5,a5
     ee4:	02078663          	beqz	a5,f10 <print_dec_int+0x58>
     ee8:	fa043703          	ld	a4,-96(s0)
     eec:	fff00793          	li	a5,-1
     ef0:	03f79793          	slli	a5,a5,0x3f
     ef4:	00f71e63          	bne	a4,a5,f10 <print_dec_int+0x58>
     ef8:	00001597          	auipc	a1,0x1
     efc:	f7858593          	addi	a1,a1,-136 # 1e70 <lseek+0x100>
     f00:	fa843503          	ld	a0,-88(s0)
     f04:	f2dff0ef          	jal	e30 <puts_wo_nl>
     f08:	00050793          	mv	a5,a0
     f0c:	2a00006f          	j	11ac <print_dec_int+0x2f4>
     f10:	f9043783          	ld	a5,-112(s0)
     f14:	00c7a783          	lw	a5,12(a5)
     f18:	00079a63          	bnez	a5,f2c <print_dec_int+0x74>
     f1c:	fa043783          	ld	a5,-96(s0)
     f20:	00079663          	bnez	a5,f2c <print_dec_int+0x74>
     f24:	00000793          	li	a5,0
     f28:	2840006f          	j	11ac <print_dec_int+0x2f4>
     f2c:	fe0407a3          	sb	zero,-17(s0)
     f30:	f9f44783          	lbu	a5,-97(s0)
     f34:	0ff7f793          	zext.b	a5,a5
     f38:	02078063          	beqz	a5,f58 <print_dec_int+0xa0>
     f3c:	fa043783          	ld	a5,-96(s0)
     f40:	0007dc63          	bgez	a5,f58 <print_dec_int+0xa0>
     f44:	00100793          	li	a5,1
     f48:	fef407a3          	sb	a5,-17(s0)
     f4c:	fa043783          	ld	a5,-96(s0)
     f50:	40f007b3          	neg	a5,a5
     f54:	faf43023          	sd	a5,-96(s0)
     f58:	fe042423          	sw	zero,-24(s0)
     f5c:	f9f44783          	lbu	a5,-97(s0)
     f60:	0ff7f793          	zext.b	a5,a5
     f64:	02078863          	beqz	a5,f94 <print_dec_int+0xdc>
     f68:	fef44783          	lbu	a5,-17(s0)
     f6c:	0ff7f793          	zext.b	a5,a5
     f70:	00079e63          	bnez	a5,f8c <print_dec_int+0xd4>
     f74:	f9043783          	ld	a5,-112(s0)
     f78:	0057c783          	lbu	a5,5(a5)
     f7c:	00079863          	bnez	a5,f8c <print_dec_int+0xd4>
     f80:	f9043783          	ld	a5,-112(s0)
     f84:	0047c783          	lbu	a5,4(a5)
     f88:	00078663          	beqz	a5,f94 <print_dec_int+0xdc>
     f8c:	00100793          	li	a5,1
     f90:	0080006f          	j	f98 <print_dec_int+0xe0>
     f94:	00000793          	li	a5,0
     f98:	fcf40ba3          	sb	a5,-41(s0)
     f9c:	fd744783          	lbu	a5,-41(s0)
     fa0:	0017f793          	andi	a5,a5,1
     fa4:	fcf40ba3          	sb	a5,-41(s0)
     fa8:	fa043703          	ld	a4,-96(s0)
     fac:	00a00793          	li	a5,10
     fb0:	02f777b3          	remu	a5,a4,a5
     fb4:	0ff7f713          	zext.b	a4,a5
     fb8:	fe842783          	lw	a5,-24(s0)
     fbc:	0017869b          	addiw	a3,a5,1
     fc0:	fed42423          	sw	a3,-24(s0)
     fc4:	0307071b          	addiw	a4,a4,48
     fc8:	0ff77713          	zext.b	a4,a4
     fcc:	ff078793          	addi	a5,a5,-16
     fd0:	008787b3          	add	a5,a5,s0
     fd4:	fce78423          	sb	a4,-56(a5)
     fd8:	fa043703          	ld	a4,-96(s0)
     fdc:	00a00793          	li	a5,10
     fe0:	02f757b3          	divu	a5,a4,a5
     fe4:	faf43023          	sd	a5,-96(s0)
     fe8:	fa043783          	ld	a5,-96(s0)
     fec:	fa079ee3          	bnez	a5,fa8 <print_dec_int+0xf0>
     ff0:	f9043783          	ld	a5,-112(s0)
     ff4:	00c7a783          	lw	a5,12(a5)
     ff8:	00078713          	mv	a4,a5
     ffc:	fff00793          	li	a5,-1
    1000:	02f71063          	bne	a4,a5,1020 <print_dec_int+0x168>
    1004:	f9043783          	ld	a5,-112(s0)
    1008:	0037c783          	lbu	a5,3(a5)
    100c:	00078a63          	beqz	a5,1020 <print_dec_int+0x168>
    1010:	f9043783          	ld	a5,-112(s0)
    1014:	0087a703          	lw	a4,8(a5)
    1018:	f9043783          	ld	a5,-112(s0)
    101c:	00e7a623          	sw	a4,12(a5)
    1020:	fe042223          	sw	zero,-28(s0)
    1024:	f9043783          	ld	a5,-112(s0)
    1028:	0087a703          	lw	a4,8(a5)
    102c:	fe842783          	lw	a5,-24(s0)
    1030:	fcf42823          	sw	a5,-48(s0)
    1034:	f9043783          	ld	a5,-112(s0)
    1038:	00c7a783          	lw	a5,12(a5)
    103c:	fcf42623          	sw	a5,-52(s0)
    1040:	fd042783          	lw	a5,-48(s0)
    1044:	00078593          	mv	a1,a5
    1048:	fcc42783          	lw	a5,-52(s0)
    104c:	00078613          	mv	a2,a5
    1050:	0006069b          	sext.w	a3,a2
    1054:	0005879b          	sext.w	a5,a1
    1058:	00f6d463          	bge	a3,a5,1060 <print_dec_int+0x1a8>
    105c:	00058613          	mv	a2,a1
    1060:	0006079b          	sext.w	a5,a2
    1064:	40f707bb          	subw	a5,a4,a5
    1068:	0007871b          	sext.w	a4,a5
    106c:	fd744783          	lbu	a5,-41(s0)
    1070:	0007879b          	sext.w	a5,a5
    1074:	40f707bb          	subw	a5,a4,a5
    1078:	fef42023          	sw	a5,-32(s0)
    107c:	0280006f          	j	10a4 <print_dec_int+0x1ec>
    1080:	fa843783          	ld	a5,-88(s0)
    1084:	02000513          	li	a0,32
    1088:	000780e7          	jalr	a5
    108c:	fe442783          	lw	a5,-28(s0)
    1090:	0017879b          	addiw	a5,a5,1
    1094:	fef42223          	sw	a5,-28(s0)
    1098:	fe042783          	lw	a5,-32(s0)
    109c:	fff7879b          	addiw	a5,a5,-1
    10a0:	fef42023          	sw	a5,-32(s0)
    10a4:	fe042783          	lw	a5,-32(s0)
    10a8:	0007879b          	sext.w	a5,a5
    10ac:	fcf04ae3          	bgtz	a5,1080 <print_dec_int+0x1c8>
    10b0:	fd744783          	lbu	a5,-41(s0)
    10b4:	0ff7f793          	zext.b	a5,a5
    10b8:	04078463          	beqz	a5,1100 <print_dec_int+0x248>
    10bc:	fef44783          	lbu	a5,-17(s0)
    10c0:	0ff7f793          	zext.b	a5,a5
    10c4:	00078663          	beqz	a5,10d0 <print_dec_int+0x218>
    10c8:	02d00793          	li	a5,45
    10cc:	01c0006f          	j	10e8 <print_dec_int+0x230>
    10d0:	f9043783          	ld	a5,-112(s0)
    10d4:	0057c783          	lbu	a5,5(a5)
    10d8:	00078663          	beqz	a5,10e4 <print_dec_int+0x22c>
    10dc:	02b00793          	li	a5,43
    10e0:	0080006f          	j	10e8 <print_dec_int+0x230>
    10e4:	02000793          	li	a5,32
    10e8:	fa843703          	ld	a4,-88(s0)
    10ec:	00078513          	mv	a0,a5
    10f0:	000700e7          	jalr	a4
    10f4:	fe442783          	lw	a5,-28(s0)
    10f8:	0017879b          	addiw	a5,a5,1
    10fc:	fef42223          	sw	a5,-28(s0)
    1100:	fe842783          	lw	a5,-24(s0)
    1104:	fcf42e23          	sw	a5,-36(s0)
    1108:	0280006f          	j	1130 <print_dec_int+0x278>
    110c:	fa843783          	ld	a5,-88(s0)
    1110:	03000513          	li	a0,48
    1114:	000780e7          	jalr	a5
    1118:	fe442783          	lw	a5,-28(s0)
    111c:	0017879b          	addiw	a5,a5,1
    1120:	fef42223          	sw	a5,-28(s0)
    1124:	fdc42783          	lw	a5,-36(s0)
    1128:	0017879b          	addiw	a5,a5,1
    112c:	fcf42e23          	sw	a5,-36(s0)
    1130:	f9043783          	ld	a5,-112(s0)
    1134:	00c7a703          	lw	a4,12(a5)
    1138:	fd744783          	lbu	a5,-41(s0)
    113c:	0007879b          	sext.w	a5,a5
    1140:	40f707bb          	subw	a5,a4,a5
    1144:	0007871b          	sext.w	a4,a5
    1148:	fdc42783          	lw	a5,-36(s0)
    114c:	0007879b          	sext.w	a5,a5
    1150:	fae7cee3          	blt	a5,a4,110c <print_dec_int+0x254>
    1154:	fe842783          	lw	a5,-24(s0)
    1158:	fff7879b          	addiw	a5,a5,-1
    115c:	fcf42c23          	sw	a5,-40(s0)
    1160:	03c0006f          	j	119c <print_dec_int+0x2e4>
    1164:	fd842783          	lw	a5,-40(s0)
    1168:	ff078793          	addi	a5,a5,-16
    116c:	008787b3          	add	a5,a5,s0
    1170:	fc87c783          	lbu	a5,-56(a5)
    1174:	0007871b          	sext.w	a4,a5
    1178:	fa843783          	ld	a5,-88(s0)
    117c:	00070513          	mv	a0,a4
    1180:	000780e7          	jalr	a5
    1184:	fe442783          	lw	a5,-28(s0)
    1188:	0017879b          	addiw	a5,a5,1
    118c:	fef42223          	sw	a5,-28(s0)
    1190:	fd842783          	lw	a5,-40(s0)
    1194:	fff7879b          	addiw	a5,a5,-1
    1198:	fcf42c23          	sw	a5,-40(s0)
    119c:	fd842783          	lw	a5,-40(s0)
    11a0:	0007879b          	sext.w	a5,a5
    11a4:	fc07d0e3          	bgez	a5,1164 <print_dec_int+0x2ac>
    11a8:	fe442783          	lw	a5,-28(s0)
    11ac:	00078513          	mv	a0,a5
    11b0:	06813083          	ld	ra,104(sp)
    11b4:	06013403          	ld	s0,96(sp)
    11b8:	07010113          	addi	sp,sp,112
    11bc:	00008067          	ret

Disassembly of section .text.vprintfmt:

00000000000011c0 <vprintfmt>:
    11c0:	f4010113          	addi	sp,sp,-192
    11c4:	0a113c23          	sd	ra,184(sp)
    11c8:	0a813823          	sd	s0,176(sp)
    11cc:	0c010413          	addi	s0,sp,192
    11d0:	f4a43c23          	sd	a0,-168(s0)
    11d4:	f4b43823          	sd	a1,-176(s0)
    11d8:	f4c43423          	sd	a2,-184(s0)
    11dc:	f8043023          	sd	zero,-128(s0)
    11e0:	f8043423          	sd	zero,-120(s0)
    11e4:	fe042623          	sw	zero,-20(s0)
    11e8:	7a40006f          	j	198c <vprintfmt+0x7cc>
    11ec:	f8044783          	lbu	a5,-128(s0)
    11f0:	72078e63          	beqz	a5,192c <vprintfmt+0x76c>
    11f4:	f5043783          	ld	a5,-176(s0)
    11f8:	0007c783          	lbu	a5,0(a5)
    11fc:	00078713          	mv	a4,a5
    1200:	02300793          	li	a5,35
    1204:	00f71863          	bne	a4,a5,1214 <vprintfmt+0x54>
    1208:	00100793          	li	a5,1
    120c:	f8f40123          	sb	a5,-126(s0)
    1210:	7700006f          	j	1980 <vprintfmt+0x7c0>
    1214:	f5043783          	ld	a5,-176(s0)
    1218:	0007c783          	lbu	a5,0(a5)
    121c:	00078713          	mv	a4,a5
    1220:	03000793          	li	a5,48
    1224:	00f71863          	bne	a4,a5,1234 <vprintfmt+0x74>
    1228:	00100793          	li	a5,1
    122c:	f8f401a3          	sb	a5,-125(s0)
    1230:	7500006f          	j	1980 <vprintfmt+0x7c0>
    1234:	f5043783          	ld	a5,-176(s0)
    1238:	0007c783          	lbu	a5,0(a5)
    123c:	00078713          	mv	a4,a5
    1240:	06c00793          	li	a5,108
    1244:	04f70063          	beq	a4,a5,1284 <vprintfmt+0xc4>
    1248:	f5043783          	ld	a5,-176(s0)
    124c:	0007c783          	lbu	a5,0(a5)
    1250:	00078713          	mv	a4,a5
    1254:	07a00793          	li	a5,122
    1258:	02f70663          	beq	a4,a5,1284 <vprintfmt+0xc4>
    125c:	f5043783          	ld	a5,-176(s0)
    1260:	0007c783          	lbu	a5,0(a5)
    1264:	00078713          	mv	a4,a5
    1268:	07400793          	li	a5,116
    126c:	00f70c63          	beq	a4,a5,1284 <vprintfmt+0xc4>
    1270:	f5043783          	ld	a5,-176(s0)
    1274:	0007c783          	lbu	a5,0(a5)
    1278:	00078713          	mv	a4,a5
    127c:	06a00793          	li	a5,106
    1280:	00f71863          	bne	a4,a5,1290 <vprintfmt+0xd0>
    1284:	00100793          	li	a5,1
    1288:	f8f400a3          	sb	a5,-127(s0)
    128c:	6f40006f          	j	1980 <vprintfmt+0x7c0>
    1290:	f5043783          	ld	a5,-176(s0)
    1294:	0007c783          	lbu	a5,0(a5)
    1298:	00078713          	mv	a4,a5
    129c:	02b00793          	li	a5,43
    12a0:	00f71863          	bne	a4,a5,12b0 <vprintfmt+0xf0>
    12a4:	00100793          	li	a5,1
    12a8:	f8f402a3          	sb	a5,-123(s0)
    12ac:	6d40006f          	j	1980 <vprintfmt+0x7c0>
    12b0:	f5043783          	ld	a5,-176(s0)
    12b4:	0007c783          	lbu	a5,0(a5)
    12b8:	00078713          	mv	a4,a5
    12bc:	02000793          	li	a5,32
    12c0:	00f71863          	bne	a4,a5,12d0 <vprintfmt+0x110>
    12c4:	00100793          	li	a5,1
    12c8:	f8f40223          	sb	a5,-124(s0)
    12cc:	6b40006f          	j	1980 <vprintfmt+0x7c0>
    12d0:	f5043783          	ld	a5,-176(s0)
    12d4:	0007c783          	lbu	a5,0(a5)
    12d8:	00078713          	mv	a4,a5
    12dc:	02a00793          	li	a5,42
    12e0:	00f71e63          	bne	a4,a5,12fc <vprintfmt+0x13c>
    12e4:	f4843783          	ld	a5,-184(s0)
    12e8:	00878713          	addi	a4,a5,8
    12ec:	f4e43423          	sd	a4,-184(s0)
    12f0:	0007a783          	lw	a5,0(a5)
    12f4:	f8f42423          	sw	a5,-120(s0)
    12f8:	6880006f          	j	1980 <vprintfmt+0x7c0>
    12fc:	f5043783          	ld	a5,-176(s0)
    1300:	0007c783          	lbu	a5,0(a5)
    1304:	00078713          	mv	a4,a5
    1308:	03000793          	li	a5,48
    130c:	04e7f663          	bgeu	a5,a4,1358 <vprintfmt+0x198>
    1310:	f5043783          	ld	a5,-176(s0)
    1314:	0007c783          	lbu	a5,0(a5)
    1318:	00078713          	mv	a4,a5
    131c:	03900793          	li	a5,57
    1320:	02e7ec63          	bltu	a5,a4,1358 <vprintfmt+0x198>
    1324:	f5043783          	ld	a5,-176(s0)
    1328:	f5040713          	addi	a4,s0,-176
    132c:	00a00613          	li	a2,10
    1330:	00070593          	mv	a1,a4
    1334:	00078513          	mv	a0,a5
    1338:	88dff0ef          	jal	bc4 <strtol>
    133c:	00050793          	mv	a5,a0
    1340:	0007879b          	sext.w	a5,a5
    1344:	f8f42423          	sw	a5,-120(s0)
    1348:	f5043783          	ld	a5,-176(s0)
    134c:	fff78793          	addi	a5,a5,-1
    1350:	f4f43823          	sd	a5,-176(s0)
    1354:	62c0006f          	j	1980 <vprintfmt+0x7c0>
    1358:	f5043783          	ld	a5,-176(s0)
    135c:	0007c783          	lbu	a5,0(a5)
    1360:	00078713          	mv	a4,a5
    1364:	02e00793          	li	a5,46
    1368:	06f71863          	bne	a4,a5,13d8 <vprintfmt+0x218>
    136c:	f5043783          	ld	a5,-176(s0)
    1370:	00178793          	addi	a5,a5,1
    1374:	f4f43823          	sd	a5,-176(s0)
    1378:	f5043783          	ld	a5,-176(s0)
    137c:	0007c783          	lbu	a5,0(a5)
    1380:	00078713          	mv	a4,a5
    1384:	02a00793          	li	a5,42
    1388:	00f71e63          	bne	a4,a5,13a4 <vprintfmt+0x1e4>
    138c:	f4843783          	ld	a5,-184(s0)
    1390:	00878713          	addi	a4,a5,8
    1394:	f4e43423          	sd	a4,-184(s0)
    1398:	0007a783          	lw	a5,0(a5)
    139c:	f8f42623          	sw	a5,-116(s0)
    13a0:	5e00006f          	j	1980 <vprintfmt+0x7c0>
    13a4:	f5043783          	ld	a5,-176(s0)
    13a8:	f5040713          	addi	a4,s0,-176
    13ac:	00a00613          	li	a2,10
    13b0:	00070593          	mv	a1,a4
    13b4:	00078513          	mv	a0,a5
    13b8:	80dff0ef          	jal	bc4 <strtol>
    13bc:	00050793          	mv	a5,a0
    13c0:	0007879b          	sext.w	a5,a5
    13c4:	f8f42623          	sw	a5,-116(s0)
    13c8:	f5043783          	ld	a5,-176(s0)
    13cc:	fff78793          	addi	a5,a5,-1
    13d0:	f4f43823          	sd	a5,-176(s0)
    13d4:	5ac0006f          	j	1980 <vprintfmt+0x7c0>
    13d8:	f5043783          	ld	a5,-176(s0)
    13dc:	0007c783          	lbu	a5,0(a5)
    13e0:	00078713          	mv	a4,a5
    13e4:	07800793          	li	a5,120
    13e8:	02f70663          	beq	a4,a5,1414 <vprintfmt+0x254>
    13ec:	f5043783          	ld	a5,-176(s0)
    13f0:	0007c783          	lbu	a5,0(a5)
    13f4:	00078713          	mv	a4,a5
    13f8:	05800793          	li	a5,88
    13fc:	00f70c63          	beq	a4,a5,1414 <vprintfmt+0x254>
    1400:	f5043783          	ld	a5,-176(s0)
    1404:	0007c783          	lbu	a5,0(a5)
    1408:	00078713          	mv	a4,a5
    140c:	07000793          	li	a5,112
    1410:	30f71263          	bne	a4,a5,1714 <vprintfmt+0x554>
    1414:	f5043783          	ld	a5,-176(s0)
    1418:	0007c783          	lbu	a5,0(a5)
    141c:	00078713          	mv	a4,a5
    1420:	07000793          	li	a5,112
    1424:	00f70663          	beq	a4,a5,1430 <vprintfmt+0x270>
    1428:	f8144783          	lbu	a5,-127(s0)
    142c:	00078663          	beqz	a5,1438 <vprintfmt+0x278>
    1430:	00100793          	li	a5,1
    1434:	0080006f          	j	143c <vprintfmt+0x27c>
    1438:	00000793          	li	a5,0
    143c:	faf403a3          	sb	a5,-89(s0)
    1440:	fa744783          	lbu	a5,-89(s0)
    1444:	0017f793          	andi	a5,a5,1
    1448:	faf403a3          	sb	a5,-89(s0)
    144c:	fa744783          	lbu	a5,-89(s0)
    1450:	0ff7f793          	zext.b	a5,a5
    1454:	00078c63          	beqz	a5,146c <vprintfmt+0x2ac>
    1458:	f4843783          	ld	a5,-184(s0)
    145c:	00878713          	addi	a4,a5,8
    1460:	f4e43423          	sd	a4,-184(s0)
    1464:	0007b783          	ld	a5,0(a5)
    1468:	01c0006f          	j	1484 <vprintfmt+0x2c4>
    146c:	f4843783          	ld	a5,-184(s0)
    1470:	00878713          	addi	a4,a5,8
    1474:	f4e43423          	sd	a4,-184(s0)
    1478:	0007a783          	lw	a5,0(a5)
    147c:	02079793          	slli	a5,a5,0x20
    1480:	0207d793          	srli	a5,a5,0x20
    1484:	fef43023          	sd	a5,-32(s0)
    1488:	f8c42783          	lw	a5,-116(s0)
    148c:	02079463          	bnez	a5,14b4 <vprintfmt+0x2f4>
    1490:	fe043783          	ld	a5,-32(s0)
    1494:	02079063          	bnez	a5,14b4 <vprintfmt+0x2f4>
    1498:	f5043783          	ld	a5,-176(s0)
    149c:	0007c783          	lbu	a5,0(a5)
    14a0:	00078713          	mv	a4,a5
    14a4:	07000793          	li	a5,112
    14a8:	00f70663          	beq	a4,a5,14b4 <vprintfmt+0x2f4>
    14ac:	f8040023          	sb	zero,-128(s0)
    14b0:	4d00006f          	j	1980 <vprintfmt+0x7c0>
    14b4:	f5043783          	ld	a5,-176(s0)
    14b8:	0007c783          	lbu	a5,0(a5)
    14bc:	00078713          	mv	a4,a5
    14c0:	07000793          	li	a5,112
    14c4:	00f70a63          	beq	a4,a5,14d8 <vprintfmt+0x318>
    14c8:	f8244783          	lbu	a5,-126(s0)
    14cc:	00078a63          	beqz	a5,14e0 <vprintfmt+0x320>
    14d0:	fe043783          	ld	a5,-32(s0)
    14d4:	00078663          	beqz	a5,14e0 <vprintfmt+0x320>
    14d8:	00100793          	li	a5,1
    14dc:	0080006f          	j	14e4 <vprintfmt+0x324>
    14e0:	00000793          	li	a5,0
    14e4:	faf40323          	sb	a5,-90(s0)
    14e8:	fa644783          	lbu	a5,-90(s0)
    14ec:	0017f793          	andi	a5,a5,1
    14f0:	faf40323          	sb	a5,-90(s0)
    14f4:	fc042e23          	sw	zero,-36(s0)
    14f8:	f5043783          	ld	a5,-176(s0)
    14fc:	0007c783          	lbu	a5,0(a5)
    1500:	00078713          	mv	a4,a5
    1504:	05800793          	li	a5,88
    1508:	00f71863          	bne	a4,a5,1518 <vprintfmt+0x358>
    150c:	00001797          	auipc	a5,0x1
    1510:	ca478793          	addi	a5,a5,-860 # 21b0 <upperxdigits.1>
    1514:	00c0006f          	j	1520 <vprintfmt+0x360>
    1518:	00001797          	auipc	a5,0x1
    151c:	cb078793          	addi	a5,a5,-848 # 21c8 <lowerxdigits.0>
    1520:	f8f43c23          	sd	a5,-104(s0)
    1524:	fe043783          	ld	a5,-32(s0)
    1528:	00f7f793          	andi	a5,a5,15
    152c:	f9843703          	ld	a4,-104(s0)
    1530:	00f70733          	add	a4,a4,a5
    1534:	fdc42783          	lw	a5,-36(s0)
    1538:	0017869b          	addiw	a3,a5,1
    153c:	fcd42e23          	sw	a3,-36(s0)
    1540:	00074703          	lbu	a4,0(a4)
    1544:	ff078793          	addi	a5,a5,-16
    1548:	008787b3          	add	a5,a5,s0
    154c:	f8e78023          	sb	a4,-128(a5)
    1550:	fe043783          	ld	a5,-32(s0)
    1554:	0047d793          	srli	a5,a5,0x4
    1558:	fef43023          	sd	a5,-32(s0)
    155c:	fe043783          	ld	a5,-32(s0)
    1560:	fc0792e3          	bnez	a5,1524 <vprintfmt+0x364>
    1564:	f8c42783          	lw	a5,-116(s0)
    1568:	00078713          	mv	a4,a5
    156c:	fff00793          	li	a5,-1
    1570:	02f71663          	bne	a4,a5,159c <vprintfmt+0x3dc>
    1574:	f8344783          	lbu	a5,-125(s0)
    1578:	02078263          	beqz	a5,159c <vprintfmt+0x3dc>
    157c:	f8842703          	lw	a4,-120(s0)
    1580:	fa644783          	lbu	a5,-90(s0)
    1584:	0007879b          	sext.w	a5,a5
    1588:	0017979b          	slliw	a5,a5,0x1
    158c:	0007879b          	sext.w	a5,a5
    1590:	40f707bb          	subw	a5,a4,a5
    1594:	0007879b          	sext.w	a5,a5
    1598:	f8f42623          	sw	a5,-116(s0)
    159c:	f8842703          	lw	a4,-120(s0)
    15a0:	fa644783          	lbu	a5,-90(s0)
    15a4:	0007879b          	sext.w	a5,a5
    15a8:	0017979b          	slliw	a5,a5,0x1
    15ac:	0007879b          	sext.w	a5,a5
    15b0:	40f707bb          	subw	a5,a4,a5
    15b4:	0007871b          	sext.w	a4,a5
    15b8:	fdc42783          	lw	a5,-36(s0)
    15bc:	f8f42a23          	sw	a5,-108(s0)
    15c0:	f8c42783          	lw	a5,-116(s0)
    15c4:	f8f42823          	sw	a5,-112(s0)
    15c8:	f9442783          	lw	a5,-108(s0)
    15cc:	00078593          	mv	a1,a5
    15d0:	f9042783          	lw	a5,-112(s0)
    15d4:	00078613          	mv	a2,a5
    15d8:	0006069b          	sext.w	a3,a2
    15dc:	0005879b          	sext.w	a5,a1
    15e0:	00f6d463          	bge	a3,a5,15e8 <vprintfmt+0x428>
    15e4:	00058613          	mv	a2,a1
    15e8:	0006079b          	sext.w	a5,a2
    15ec:	40f707bb          	subw	a5,a4,a5
    15f0:	fcf42c23          	sw	a5,-40(s0)
    15f4:	0280006f          	j	161c <vprintfmt+0x45c>
    15f8:	f5843783          	ld	a5,-168(s0)
    15fc:	02000513          	li	a0,32
    1600:	000780e7          	jalr	a5
    1604:	fec42783          	lw	a5,-20(s0)
    1608:	0017879b          	addiw	a5,a5,1
    160c:	fef42623          	sw	a5,-20(s0)
    1610:	fd842783          	lw	a5,-40(s0)
    1614:	fff7879b          	addiw	a5,a5,-1
    1618:	fcf42c23          	sw	a5,-40(s0)
    161c:	fd842783          	lw	a5,-40(s0)
    1620:	0007879b          	sext.w	a5,a5
    1624:	fcf04ae3          	bgtz	a5,15f8 <vprintfmt+0x438>
    1628:	fa644783          	lbu	a5,-90(s0)
    162c:	0ff7f793          	zext.b	a5,a5
    1630:	04078463          	beqz	a5,1678 <vprintfmt+0x4b8>
    1634:	f5843783          	ld	a5,-168(s0)
    1638:	03000513          	li	a0,48
    163c:	000780e7          	jalr	a5
    1640:	f5043783          	ld	a5,-176(s0)
    1644:	0007c783          	lbu	a5,0(a5)
    1648:	00078713          	mv	a4,a5
    164c:	05800793          	li	a5,88
    1650:	00f71663          	bne	a4,a5,165c <vprintfmt+0x49c>
    1654:	05800793          	li	a5,88
    1658:	0080006f          	j	1660 <vprintfmt+0x4a0>
    165c:	07800793          	li	a5,120
    1660:	f5843703          	ld	a4,-168(s0)
    1664:	00078513          	mv	a0,a5
    1668:	000700e7          	jalr	a4
    166c:	fec42783          	lw	a5,-20(s0)
    1670:	0027879b          	addiw	a5,a5,2
    1674:	fef42623          	sw	a5,-20(s0)
    1678:	fdc42783          	lw	a5,-36(s0)
    167c:	fcf42a23          	sw	a5,-44(s0)
    1680:	0280006f          	j	16a8 <vprintfmt+0x4e8>
    1684:	f5843783          	ld	a5,-168(s0)
    1688:	03000513          	li	a0,48
    168c:	000780e7          	jalr	a5
    1690:	fec42783          	lw	a5,-20(s0)
    1694:	0017879b          	addiw	a5,a5,1
    1698:	fef42623          	sw	a5,-20(s0)
    169c:	fd442783          	lw	a5,-44(s0)
    16a0:	0017879b          	addiw	a5,a5,1
    16a4:	fcf42a23          	sw	a5,-44(s0)
    16a8:	f8c42703          	lw	a4,-116(s0)
    16ac:	fd442783          	lw	a5,-44(s0)
    16b0:	0007879b          	sext.w	a5,a5
    16b4:	fce7c8e3          	blt	a5,a4,1684 <vprintfmt+0x4c4>
    16b8:	fdc42783          	lw	a5,-36(s0)
    16bc:	fff7879b          	addiw	a5,a5,-1
    16c0:	fcf42823          	sw	a5,-48(s0)
    16c4:	03c0006f          	j	1700 <vprintfmt+0x540>
    16c8:	fd042783          	lw	a5,-48(s0)
    16cc:	ff078793          	addi	a5,a5,-16
    16d0:	008787b3          	add	a5,a5,s0
    16d4:	f807c783          	lbu	a5,-128(a5)
    16d8:	0007871b          	sext.w	a4,a5
    16dc:	f5843783          	ld	a5,-168(s0)
    16e0:	00070513          	mv	a0,a4
    16e4:	000780e7          	jalr	a5
    16e8:	fec42783          	lw	a5,-20(s0)
    16ec:	0017879b          	addiw	a5,a5,1
    16f0:	fef42623          	sw	a5,-20(s0)
    16f4:	fd042783          	lw	a5,-48(s0)
    16f8:	fff7879b          	addiw	a5,a5,-1
    16fc:	fcf42823          	sw	a5,-48(s0)
    1700:	fd042783          	lw	a5,-48(s0)
    1704:	0007879b          	sext.w	a5,a5
    1708:	fc07d0e3          	bgez	a5,16c8 <vprintfmt+0x508>
    170c:	f8040023          	sb	zero,-128(s0)
    1710:	2700006f          	j	1980 <vprintfmt+0x7c0>
    1714:	f5043783          	ld	a5,-176(s0)
    1718:	0007c783          	lbu	a5,0(a5)
    171c:	00078713          	mv	a4,a5
    1720:	06400793          	li	a5,100
    1724:	02f70663          	beq	a4,a5,1750 <vprintfmt+0x590>
    1728:	f5043783          	ld	a5,-176(s0)
    172c:	0007c783          	lbu	a5,0(a5)
    1730:	00078713          	mv	a4,a5
    1734:	06900793          	li	a5,105
    1738:	00f70c63          	beq	a4,a5,1750 <vprintfmt+0x590>
    173c:	f5043783          	ld	a5,-176(s0)
    1740:	0007c783          	lbu	a5,0(a5)
    1744:	00078713          	mv	a4,a5
    1748:	07500793          	li	a5,117
    174c:	08f71063          	bne	a4,a5,17cc <vprintfmt+0x60c>
    1750:	f8144783          	lbu	a5,-127(s0)
    1754:	00078c63          	beqz	a5,176c <vprintfmt+0x5ac>
    1758:	f4843783          	ld	a5,-184(s0)
    175c:	00878713          	addi	a4,a5,8
    1760:	f4e43423          	sd	a4,-184(s0)
    1764:	0007b783          	ld	a5,0(a5)
    1768:	0140006f          	j	177c <vprintfmt+0x5bc>
    176c:	f4843783          	ld	a5,-184(s0)
    1770:	00878713          	addi	a4,a5,8
    1774:	f4e43423          	sd	a4,-184(s0)
    1778:	0007a783          	lw	a5,0(a5)
    177c:	faf43423          	sd	a5,-88(s0)
    1780:	fa843583          	ld	a1,-88(s0)
    1784:	f5043783          	ld	a5,-176(s0)
    1788:	0007c783          	lbu	a5,0(a5)
    178c:	0007871b          	sext.w	a4,a5
    1790:	07500793          	li	a5,117
    1794:	40f707b3          	sub	a5,a4,a5
    1798:	00f037b3          	snez	a5,a5
    179c:	0ff7f793          	zext.b	a5,a5
    17a0:	f8040713          	addi	a4,s0,-128
    17a4:	00070693          	mv	a3,a4
    17a8:	00078613          	mv	a2,a5
    17ac:	f5843503          	ld	a0,-168(s0)
    17b0:	f08ff0ef          	jal	eb8 <print_dec_int>
    17b4:	00050793          	mv	a5,a0
    17b8:	fec42703          	lw	a4,-20(s0)
    17bc:	00f707bb          	addw	a5,a4,a5
    17c0:	fef42623          	sw	a5,-20(s0)
    17c4:	f8040023          	sb	zero,-128(s0)
    17c8:	1b80006f          	j	1980 <vprintfmt+0x7c0>
    17cc:	f5043783          	ld	a5,-176(s0)
    17d0:	0007c783          	lbu	a5,0(a5)
    17d4:	00078713          	mv	a4,a5
    17d8:	06e00793          	li	a5,110
    17dc:	04f71c63          	bne	a4,a5,1834 <vprintfmt+0x674>
    17e0:	f8144783          	lbu	a5,-127(s0)
    17e4:	02078463          	beqz	a5,180c <vprintfmt+0x64c>
    17e8:	f4843783          	ld	a5,-184(s0)
    17ec:	00878713          	addi	a4,a5,8
    17f0:	f4e43423          	sd	a4,-184(s0)
    17f4:	0007b783          	ld	a5,0(a5)
    17f8:	faf43823          	sd	a5,-80(s0)
    17fc:	fec42703          	lw	a4,-20(s0)
    1800:	fb043783          	ld	a5,-80(s0)
    1804:	00e7b023          	sd	a4,0(a5)
    1808:	0240006f          	j	182c <vprintfmt+0x66c>
    180c:	f4843783          	ld	a5,-184(s0)
    1810:	00878713          	addi	a4,a5,8
    1814:	f4e43423          	sd	a4,-184(s0)
    1818:	0007b783          	ld	a5,0(a5)
    181c:	faf43c23          	sd	a5,-72(s0)
    1820:	fb843783          	ld	a5,-72(s0)
    1824:	fec42703          	lw	a4,-20(s0)
    1828:	00e7a023          	sw	a4,0(a5)
    182c:	f8040023          	sb	zero,-128(s0)
    1830:	1500006f          	j	1980 <vprintfmt+0x7c0>
    1834:	f5043783          	ld	a5,-176(s0)
    1838:	0007c783          	lbu	a5,0(a5)
    183c:	00078713          	mv	a4,a5
    1840:	07300793          	li	a5,115
    1844:	02f71e63          	bne	a4,a5,1880 <vprintfmt+0x6c0>
    1848:	f4843783          	ld	a5,-184(s0)
    184c:	00878713          	addi	a4,a5,8
    1850:	f4e43423          	sd	a4,-184(s0)
    1854:	0007b783          	ld	a5,0(a5)
    1858:	fcf43023          	sd	a5,-64(s0)
    185c:	fc043583          	ld	a1,-64(s0)
    1860:	f5843503          	ld	a0,-168(s0)
    1864:	dccff0ef          	jal	e30 <puts_wo_nl>
    1868:	00050793          	mv	a5,a0
    186c:	fec42703          	lw	a4,-20(s0)
    1870:	00f707bb          	addw	a5,a4,a5
    1874:	fef42623          	sw	a5,-20(s0)
    1878:	f8040023          	sb	zero,-128(s0)
    187c:	1040006f          	j	1980 <vprintfmt+0x7c0>
    1880:	f5043783          	ld	a5,-176(s0)
    1884:	0007c783          	lbu	a5,0(a5)
    1888:	00078713          	mv	a4,a5
    188c:	06300793          	li	a5,99
    1890:	02f71e63          	bne	a4,a5,18cc <vprintfmt+0x70c>
    1894:	f4843783          	ld	a5,-184(s0)
    1898:	00878713          	addi	a4,a5,8
    189c:	f4e43423          	sd	a4,-184(s0)
    18a0:	0007a783          	lw	a5,0(a5)
    18a4:	fcf42623          	sw	a5,-52(s0)
    18a8:	fcc42703          	lw	a4,-52(s0)
    18ac:	f5843783          	ld	a5,-168(s0)
    18b0:	00070513          	mv	a0,a4
    18b4:	000780e7          	jalr	a5
    18b8:	fec42783          	lw	a5,-20(s0)
    18bc:	0017879b          	addiw	a5,a5,1
    18c0:	fef42623          	sw	a5,-20(s0)
    18c4:	f8040023          	sb	zero,-128(s0)
    18c8:	0b80006f          	j	1980 <vprintfmt+0x7c0>
    18cc:	f5043783          	ld	a5,-176(s0)
    18d0:	0007c783          	lbu	a5,0(a5)
    18d4:	00078713          	mv	a4,a5
    18d8:	02500793          	li	a5,37
    18dc:	02f71263          	bne	a4,a5,1900 <vprintfmt+0x740>
    18e0:	f5843783          	ld	a5,-168(s0)
    18e4:	02500513          	li	a0,37
    18e8:	000780e7          	jalr	a5
    18ec:	fec42783          	lw	a5,-20(s0)
    18f0:	0017879b          	addiw	a5,a5,1
    18f4:	fef42623          	sw	a5,-20(s0)
    18f8:	f8040023          	sb	zero,-128(s0)
    18fc:	0840006f          	j	1980 <vprintfmt+0x7c0>
    1900:	f5043783          	ld	a5,-176(s0)
    1904:	0007c783          	lbu	a5,0(a5)
    1908:	0007871b          	sext.w	a4,a5
    190c:	f5843783          	ld	a5,-168(s0)
    1910:	00070513          	mv	a0,a4
    1914:	000780e7          	jalr	a5
    1918:	fec42783          	lw	a5,-20(s0)
    191c:	0017879b          	addiw	a5,a5,1
    1920:	fef42623          	sw	a5,-20(s0)
    1924:	f8040023          	sb	zero,-128(s0)
    1928:	0580006f          	j	1980 <vprintfmt+0x7c0>
    192c:	f5043783          	ld	a5,-176(s0)
    1930:	0007c783          	lbu	a5,0(a5)
    1934:	00078713          	mv	a4,a5
    1938:	02500793          	li	a5,37
    193c:	02f71063          	bne	a4,a5,195c <vprintfmt+0x79c>
    1940:	f8043023          	sd	zero,-128(s0)
    1944:	f8043423          	sd	zero,-120(s0)
    1948:	00100793          	li	a5,1
    194c:	f8f40023          	sb	a5,-128(s0)
    1950:	fff00793          	li	a5,-1
    1954:	f8f42623          	sw	a5,-116(s0)
    1958:	0280006f          	j	1980 <vprintfmt+0x7c0>
    195c:	f5043783          	ld	a5,-176(s0)
    1960:	0007c783          	lbu	a5,0(a5)
    1964:	0007871b          	sext.w	a4,a5
    1968:	f5843783          	ld	a5,-168(s0)
    196c:	00070513          	mv	a0,a4
    1970:	000780e7          	jalr	a5
    1974:	fec42783          	lw	a5,-20(s0)
    1978:	0017879b          	addiw	a5,a5,1
    197c:	fef42623          	sw	a5,-20(s0)
    1980:	f5043783          	ld	a5,-176(s0)
    1984:	00178793          	addi	a5,a5,1
    1988:	f4f43823          	sd	a5,-176(s0)
    198c:	f5043783          	ld	a5,-176(s0)
    1990:	0007c783          	lbu	a5,0(a5)
    1994:	84079ce3          	bnez	a5,11ec <vprintfmt+0x2c>
    1998:	fec42783          	lw	a5,-20(s0)
    199c:	00078513          	mv	a0,a5
    19a0:	0b813083          	ld	ra,184(sp)
    19a4:	0b013403          	ld	s0,176(sp)
    19a8:	0c010113          	addi	sp,sp,192
    19ac:	00008067          	ret

Disassembly of section .text.printf:

00000000000019b0 <printf>:
    19b0:	f8010113          	addi	sp,sp,-128
    19b4:	02113c23          	sd	ra,56(sp)
    19b8:	02813823          	sd	s0,48(sp)
    19bc:	04010413          	addi	s0,sp,64
    19c0:	fca43423          	sd	a0,-56(s0)
    19c4:	00b43423          	sd	a1,8(s0)
    19c8:	00c43823          	sd	a2,16(s0)
    19cc:	00d43c23          	sd	a3,24(s0)
    19d0:	02e43023          	sd	a4,32(s0)
    19d4:	02f43423          	sd	a5,40(s0)
    19d8:	03043823          	sd	a6,48(s0)
    19dc:	03143c23          	sd	a7,56(s0)
    19e0:	fe042623          	sw	zero,-20(s0)
    19e4:	04040793          	addi	a5,s0,64
    19e8:	fcf43023          	sd	a5,-64(s0)
    19ec:	fc043783          	ld	a5,-64(s0)
    19f0:	fc878793          	addi	a5,a5,-56
    19f4:	fcf43823          	sd	a5,-48(s0)
    19f8:	fd043783          	ld	a5,-48(s0)
    19fc:	00078613          	mv	a2,a5
    1a00:	fc843583          	ld	a1,-56(s0)
    1a04:	fffff517          	auipc	a0,0xfffff
    1a08:	0f850513          	addi	a0,a0,248 # afc <putc>
    1a0c:	fb4ff0ef          	jal	11c0 <vprintfmt>
    1a10:	00050793          	mv	a5,a0
    1a14:	fef42623          	sw	a5,-20(s0)
    1a18:	00100793          	li	a5,1
    1a1c:	fef43023          	sd	a5,-32(s0)
    1a20:	00001797          	auipc	a5,0x1
    1a24:	7c078793          	addi	a5,a5,1984 # 31e0 <tail>
    1a28:	0007a783          	lw	a5,0(a5)
    1a2c:	0017871b          	addiw	a4,a5,1
    1a30:	0007069b          	sext.w	a3,a4
    1a34:	00001717          	auipc	a4,0x1
    1a38:	7ac70713          	addi	a4,a4,1964 # 31e0 <tail>
    1a3c:	00d72023          	sw	a3,0(a4)
    1a40:	00001717          	auipc	a4,0x1
    1a44:	7a870713          	addi	a4,a4,1960 # 31e8 <buffer>
    1a48:	00f707b3          	add	a5,a4,a5
    1a4c:	00078023          	sb	zero,0(a5)
    1a50:	00001797          	auipc	a5,0x1
    1a54:	79078793          	addi	a5,a5,1936 # 31e0 <tail>
    1a58:	0007a603          	lw	a2,0(a5)
    1a5c:	fe043703          	ld	a4,-32(s0)
    1a60:	00001697          	auipc	a3,0x1
    1a64:	78868693          	addi	a3,a3,1928 # 31e8 <buffer>
    1a68:	fd843783          	ld	a5,-40(s0)
    1a6c:	04000893          	li	a7,64
    1a70:	00070513          	mv	a0,a4
    1a74:	00068593          	mv	a1,a3
    1a78:	00060613          	mv	a2,a2
    1a7c:	00000073          	ecall
    1a80:	00050793          	mv	a5,a0
    1a84:	fcf43c23          	sd	a5,-40(s0)
    1a88:	00001797          	auipc	a5,0x1
    1a8c:	75878793          	addi	a5,a5,1880 # 31e0 <tail>
    1a90:	0007a023          	sw	zero,0(a5)
    1a94:	fec42783          	lw	a5,-20(s0)
    1a98:	00078513          	mv	a0,a5
    1a9c:	03813083          	ld	ra,56(sp)
    1aa0:	03013403          	ld	s0,48(sp)
    1aa4:	08010113          	addi	sp,sp,128
    1aa8:	00008067          	ret

Disassembly of section .text.strlen:

0000000000001aac <strlen>:
    1aac:	fd010113          	addi	sp,sp,-48
    1ab0:	02813423          	sd	s0,40(sp)
    1ab4:	03010413          	addi	s0,sp,48
    1ab8:	fca43c23          	sd	a0,-40(s0)
    1abc:	fe042623          	sw	zero,-20(s0)
    1ac0:	0100006f          	j	1ad0 <strlen+0x24>
    1ac4:	fec42783          	lw	a5,-20(s0)
    1ac8:	0017879b          	addiw	a5,a5,1
    1acc:	fef42623          	sw	a5,-20(s0)
    1ad0:	fd843783          	ld	a5,-40(s0)
    1ad4:	00178713          	addi	a4,a5,1
    1ad8:	fce43c23          	sd	a4,-40(s0)
    1adc:	0007c783          	lbu	a5,0(a5)
    1ae0:	fe0792e3          	bnez	a5,1ac4 <strlen+0x18>
    1ae4:	fec42783          	lw	a5,-20(s0)
    1ae8:	00078513          	mv	a0,a5
    1aec:	02813403          	ld	s0,40(sp)
    1af0:	03010113          	addi	sp,sp,48
    1af4:	00008067          	ret

Disassembly of section .text.write:

0000000000001af8 <write>:
    1af8:	fb010113          	addi	sp,sp,-80
    1afc:	04813423          	sd	s0,72(sp)
    1b00:	05010413          	addi	s0,sp,80
    1b04:	00050693          	mv	a3,a0
    1b08:	fcb43023          	sd	a1,-64(s0)
    1b0c:	fac43c23          	sd	a2,-72(s0)
    1b10:	fcd42623          	sw	a3,-52(s0)
    1b14:	00010693          	mv	a3,sp
    1b18:	00068593          	mv	a1,a3
    1b1c:	fb843683          	ld	a3,-72(s0)
    1b20:	00168693          	addi	a3,a3,1
    1b24:	00068613          	mv	a2,a3
    1b28:	fff60613          	addi	a2,a2,-1
    1b2c:	fec43023          	sd	a2,-32(s0)
    1b30:	00068e13          	mv	t3,a3
    1b34:	00000e93          	li	t4,0
    1b38:	03de5613          	srli	a2,t3,0x3d
    1b3c:	003e9893          	slli	a7,t4,0x3
    1b40:	011668b3          	or	a7,a2,a7
    1b44:	003e1813          	slli	a6,t3,0x3
    1b48:	00068313          	mv	t1,a3
    1b4c:	00000393          	li	t2,0
    1b50:	03d35613          	srli	a2,t1,0x3d
    1b54:	00339793          	slli	a5,t2,0x3
    1b58:	00f667b3          	or	a5,a2,a5
    1b5c:	00331713          	slli	a4,t1,0x3
    1b60:	00f68793          	addi	a5,a3,15
    1b64:	0047d793          	srli	a5,a5,0x4
    1b68:	00479793          	slli	a5,a5,0x4
    1b6c:	40f10133          	sub	sp,sp,a5
    1b70:	00010793          	mv	a5,sp
    1b74:	00078793          	mv	a5,a5
    1b78:	fcf43c23          	sd	a5,-40(s0)
    1b7c:	fe042623          	sw	zero,-20(s0)
    1b80:	0300006f          	j	1bb0 <write+0xb8>
    1b84:	fec42783          	lw	a5,-20(s0)
    1b88:	fc043703          	ld	a4,-64(s0)
    1b8c:	00f707b3          	add	a5,a4,a5
    1b90:	0007c703          	lbu	a4,0(a5)
    1b94:	fd843683          	ld	a3,-40(s0)
    1b98:	fec42783          	lw	a5,-20(s0)
    1b9c:	00f687b3          	add	a5,a3,a5
    1ba0:	00e78023          	sb	a4,0(a5)
    1ba4:	fec42783          	lw	a5,-20(s0)
    1ba8:	0017879b          	addiw	a5,a5,1
    1bac:	fef42623          	sw	a5,-20(s0)
    1bb0:	fec42783          	lw	a5,-20(s0)
    1bb4:	fb843703          	ld	a4,-72(s0)
    1bb8:	fce7e6e3          	bltu	a5,a4,1b84 <write+0x8c>
    1bbc:	fd843703          	ld	a4,-40(s0)
    1bc0:	fb843783          	ld	a5,-72(s0)
    1bc4:	00f707b3          	add	a5,a4,a5
    1bc8:	00078023          	sb	zero,0(a5)
    1bcc:	fcc42703          	lw	a4,-52(s0)
    1bd0:	fd843683          	ld	a3,-40(s0)
    1bd4:	fb843603          	ld	a2,-72(s0)
    1bd8:	fd043783          	ld	a5,-48(s0)
    1bdc:	04000893          	li	a7,64
    1be0:	00070513          	mv	a0,a4
    1be4:	00068593          	mv	a1,a3
    1be8:	00060613          	mv	a2,a2
    1bec:	00000073          	ecall
    1bf0:	00050793          	mv	a5,a0
    1bf4:	fcf43823          	sd	a5,-48(s0)
    1bf8:	fd043783          	ld	a5,-48(s0)
    1bfc:	0007879b          	sext.w	a5,a5
    1c00:	00058113          	mv	sp,a1
    1c04:	00078513          	mv	a0,a5
    1c08:	fb040113          	addi	sp,s0,-80
    1c0c:	04813403          	ld	s0,72(sp)
    1c10:	05010113          	addi	sp,sp,80
    1c14:	00008067          	ret

Disassembly of section .text.read:

0000000000001c18 <read>:
    1c18:	fc010113          	addi	sp,sp,-64
    1c1c:	02813c23          	sd	s0,56(sp)
    1c20:	04010413          	addi	s0,sp,64
    1c24:	00050793          	mv	a5,a0
    1c28:	fcb43823          	sd	a1,-48(s0)
    1c2c:	fcc43423          	sd	a2,-56(s0)
    1c30:	fcf42e23          	sw	a5,-36(s0)
    1c34:	fdc42703          	lw	a4,-36(s0)
    1c38:	fd043683          	ld	a3,-48(s0)
    1c3c:	fc843603          	ld	a2,-56(s0)
    1c40:	fe843783          	ld	a5,-24(s0)
    1c44:	03f00893          	li	a7,63
    1c48:	00070513          	mv	a0,a4
    1c4c:	00068593          	mv	a1,a3
    1c50:	00060613          	mv	a2,a2
    1c54:	00000073          	ecall
    1c58:	00050793          	mv	a5,a0
    1c5c:	fef43423          	sd	a5,-24(s0)
    1c60:	fe843783          	ld	a5,-24(s0)
    1c64:	0007879b          	sext.w	a5,a5
    1c68:	00078513          	mv	a0,a5
    1c6c:	03813403          	ld	s0,56(sp)
    1c70:	04010113          	addi	sp,sp,64
    1c74:	00008067          	ret

Disassembly of section .text.sys_openat:

0000000000001c78 <sys_openat>:
    1c78:	fd010113          	addi	sp,sp,-48
    1c7c:	02813423          	sd	s0,40(sp)
    1c80:	03010413          	addi	s0,sp,48
    1c84:	00050793          	mv	a5,a0
    1c88:	fcb43823          	sd	a1,-48(s0)
    1c8c:	00060713          	mv	a4,a2
    1c90:	fcf42e23          	sw	a5,-36(s0)
    1c94:	00070793          	mv	a5,a4
    1c98:	fcf42c23          	sw	a5,-40(s0)
    1c9c:	fdc42703          	lw	a4,-36(s0)
    1ca0:	fd842603          	lw	a2,-40(s0)
    1ca4:	fd043683          	ld	a3,-48(s0)
    1ca8:	fe843783          	ld	a5,-24(s0)
    1cac:	03800893          	li	a7,56
    1cb0:	00070513          	mv	a0,a4
    1cb4:	00068593          	mv	a1,a3
    1cb8:	00060613          	mv	a2,a2
    1cbc:	00000073          	ecall
    1cc0:	00050793          	mv	a5,a0
    1cc4:	fef43423          	sd	a5,-24(s0)
    1cc8:	fe843783          	ld	a5,-24(s0)
    1ccc:	0007879b          	sext.w	a5,a5
    1cd0:	00078513          	mv	a0,a5
    1cd4:	02813403          	ld	s0,40(sp)
    1cd8:	03010113          	addi	sp,sp,48
    1cdc:	00008067          	ret

Disassembly of section .text.open:

0000000000001ce0 <open>:
    1ce0:	fe010113          	addi	sp,sp,-32
    1ce4:	00113c23          	sd	ra,24(sp)
    1ce8:	00813823          	sd	s0,16(sp)
    1cec:	02010413          	addi	s0,sp,32
    1cf0:	fea43423          	sd	a0,-24(s0)
    1cf4:	00058793          	mv	a5,a1
    1cf8:	fef42223          	sw	a5,-28(s0)
    1cfc:	fe442783          	lw	a5,-28(s0)
    1d00:	00078613          	mv	a2,a5
    1d04:	fe843583          	ld	a1,-24(s0)
    1d08:	f9c00513          	li	a0,-100
    1d0c:	f6dff0ef          	jal	1c78 <sys_openat>
    1d10:	00050793          	mv	a5,a0
    1d14:	00078513          	mv	a0,a5
    1d18:	01813083          	ld	ra,24(sp)
    1d1c:	01013403          	ld	s0,16(sp)
    1d20:	02010113          	addi	sp,sp,32
    1d24:	00008067          	ret

Disassembly of section .text.close:

0000000000001d28 <close>:
    1d28:	fd010113          	addi	sp,sp,-48
    1d2c:	02813423          	sd	s0,40(sp)
    1d30:	03010413          	addi	s0,sp,48
    1d34:	00050793          	mv	a5,a0
    1d38:	fcf42e23          	sw	a5,-36(s0)
    1d3c:	fdc42703          	lw	a4,-36(s0)
    1d40:	fe843783          	ld	a5,-24(s0)
    1d44:	03900893          	li	a7,57
    1d48:	00070513          	mv	a0,a4
    1d4c:	00000073          	ecall
    1d50:	00050793          	mv	a5,a0
    1d54:	fef43423          	sd	a5,-24(s0)
    1d58:	fe843783          	ld	a5,-24(s0)
    1d5c:	0007879b          	sext.w	a5,a5
    1d60:	00078513          	mv	a0,a5
    1d64:	02813403          	ld	s0,40(sp)
    1d68:	03010113          	addi	sp,sp,48
    1d6c:	00008067          	ret

Disassembly of section .text.lseek:

0000000000001d70 <lseek>:
    1d70:	fd010113          	addi	sp,sp,-48
    1d74:	02813423          	sd	s0,40(sp)
    1d78:	03010413          	addi	s0,sp,48
    1d7c:	00050793          	mv	a5,a0
    1d80:	00058693          	mv	a3,a1
    1d84:	00060713          	mv	a4,a2
    1d88:	fcf42e23          	sw	a5,-36(s0)
    1d8c:	00068793          	mv	a5,a3
    1d90:	fcf42c23          	sw	a5,-40(s0)
    1d94:	00070793          	mv	a5,a4
    1d98:	fcf42a23          	sw	a5,-44(s0)
    1d9c:	fdc42703          	lw	a4,-36(s0)
    1da0:	fd842683          	lw	a3,-40(s0)
    1da4:	fd442603          	lw	a2,-44(s0)
    1da8:	fe843783          	ld	a5,-24(s0)
    1dac:	03e00893          	li	a7,62
    1db0:	00070513          	mv	a0,a4
    1db4:	00068593          	mv	a1,a3
    1db8:	00060613          	mv	a2,a2
    1dbc:	00000073          	ecall
    1dc0:	00050793          	mv	a5,a0
    1dc4:	fef43423          	sd	a5,-24(s0)
    1dc8:	fe843783          	ld	a5,-24(s0)
    1dcc:	0007879b          	sext.w	a5,a5
    1dd0:	00078513          	mv	a0,a5
    1dd4:	02813403          	ld	s0,40(sp)
    1dd8:	03010113          	addi	sp,sp,48
    1ddc:	00008067          	ret
