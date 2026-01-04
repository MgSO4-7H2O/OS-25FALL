
uapp:     file format elf64-littleriscv


Disassembly of section .text:

00000000000100e8 <_start>:
   100e8:	1b50006f          	j	10a9c <main>

00000000000100ec <atoi>:
   100ec:	fd010113          	addi	sp,sp,-48
   100f0:	02113423          	sd	ra,40(sp)
   100f4:	02813023          	sd	s0,32(sp)
   100f8:	03010413          	addi	s0,sp,48
   100fc:	fca43c23          	sd	a0,-40(s0)
   10100:	fe042623          	sw	zero,-20(s0)
   10104:	fd843503          	ld	a0,-40(s0)
   10108:	28d010ef          	jal	11b94 <strlen>
   1010c:	00050793          	mv	a5,a0
   10110:	fef42223          	sw	a5,-28(s0)
   10114:	fe042423          	sw	zero,-24(s0)
   10118:	0500006f          	j	10168 <atoi+0x7c>
   1011c:	fec42783          	lw	a5,-20(s0)
   10120:	00078713          	mv	a4,a5
   10124:	00070793          	mv	a5,a4
   10128:	0027979b          	slliw	a5,a5,0x2
   1012c:	00e787bb          	addw	a5,a5,a4
   10130:	0017979b          	slliw	a5,a5,0x1
   10134:	0007871b          	sext.w	a4,a5
   10138:	fe842783          	lw	a5,-24(s0)
   1013c:	fd843683          	ld	a3,-40(s0)
   10140:	00f687b3          	add	a5,a3,a5
   10144:	0007c783          	lbu	a5,0(a5)
   10148:	0007879b          	sext.w	a5,a5
   1014c:	00f707bb          	addw	a5,a4,a5
   10150:	0007879b          	sext.w	a5,a5
   10154:	fd07879b          	addiw	a5,a5,-48
   10158:	fef42623          	sw	a5,-20(s0)
   1015c:	fe842783          	lw	a5,-24(s0)
   10160:	0017879b          	addiw	a5,a5,1
   10164:	fef42423          	sw	a5,-24(s0)
   10168:	fe842783          	lw	a5,-24(s0)
   1016c:	00078713          	mv	a4,a5
   10170:	fe442783          	lw	a5,-28(s0)
   10174:	0007071b          	sext.w	a4,a4
   10178:	0007879b          	sext.w	a5,a5
   1017c:	faf740e3          	blt	a4,a5,1011c <atoi+0x30>
   10180:	fec42783          	lw	a5,-20(s0)
   10184:	00078513          	mv	a0,a5
   10188:	02813083          	ld	ra,40(sp)
   1018c:	02013403          	ld	s0,32(sp)
   10190:	03010113          	addi	sp,sp,48
   10194:	00008067          	ret

0000000000010198 <get_param>:
   10198:	fd010113          	addi	sp,sp,-48
   1019c:	02813423          	sd	s0,40(sp)
   101a0:	03010413          	addi	s0,sp,48
   101a4:	fca43c23          	sd	a0,-40(s0)
   101a8:	0100006f          	j	101b8 <get_param+0x20>
   101ac:	fd843783          	ld	a5,-40(s0)
   101b0:	00178793          	addi	a5,a5,1
   101b4:	fcf43c23          	sd	a5,-40(s0)
   101b8:	fd843783          	ld	a5,-40(s0)
   101bc:	0007c783          	lbu	a5,0(a5)
   101c0:	00078713          	mv	a4,a5
   101c4:	02000793          	li	a5,32
   101c8:	fef702e3          	beq	a4,a5,101ac <get_param+0x14>
   101cc:	fe042623          	sw	zero,-20(s0)
   101d0:	0300006f          	j	10200 <get_param+0x68>
   101d4:	fd843703          	ld	a4,-40(s0)
   101d8:	00170793          	addi	a5,a4,1
   101dc:	fcf43c23          	sd	a5,-40(s0)
   101e0:	fec42783          	lw	a5,-20(s0)
   101e4:	0017869b          	addiw	a3,a5,1
   101e8:	fed42623          	sw	a3,-20(s0)
   101ec:	00074703          	lbu	a4,0(a4)
   101f0:	00003697          	auipc	a3,0x3
   101f4:	e1068693          	addi	a3,a3,-496 # 13000 <string_buf>
   101f8:	00f687b3          	add	a5,a3,a5
   101fc:	00e78023          	sb	a4,0(a5)
   10200:	fd843783          	ld	a5,-40(s0)
   10204:	0007c783          	lbu	a5,0(a5)
   10208:	00078c63          	beqz	a5,10220 <get_param+0x88>
   1020c:	fd843783          	ld	a5,-40(s0)
   10210:	0007c783          	lbu	a5,0(a5)
   10214:	00078713          	mv	a4,a5
   10218:	02000793          	li	a5,32
   1021c:	faf71ce3          	bne	a4,a5,101d4 <get_param+0x3c>
   10220:	00003717          	auipc	a4,0x3
   10224:	de070713          	addi	a4,a4,-544 # 13000 <string_buf>
   10228:	fec42783          	lw	a5,-20(s0)
   1022c:	00f707b3          	add	a5,a4,a5
   10230:	00078023          	sb	zero,0(a5)
   10234:	00003797          	auipc	a5,0x3
   10238:	dcc78793          	addi	a5,a5,-564 # 13000 <string_buf>
   1023c:	00078513          	mv	a0,a5
   10240:	02813403          	ld	s0,40(sp)
   10244:	03010113          	addi	sp,sp,48
   10248:	00008067          	ret

000000000001024c <get_string>:
   1024c:	fd010113          	addi	sp,sp,-48
   10250:	02113423          	sd	ra,40(sp)
   10254:	02813023          	sd	s0,32(sp)
   10258:	03010413          	addi	s0,sp,48
   1025c:	fca43c23          	sd	a0,-40(s0)
   10260:	0100006f          	j	10270 <get_string+0x24>
   10264:	fd843783          	ld	a5,-40(s0)
   10268:	00178793          	addi	a5,a5,1
   1026c:	fcf43c23          	sd	a5,-40(s0)
   10270:	fd843783          	ld	a5,-40(s0)
   10274:	0007c783          	lbu	a5,0(a5)
   10278:	00078713          	mv	a4,a5
   1027c:	02000793          	li	a5,32
   10280:	fef702e3          	beq	a4,a5,10264 <get_string+0x18>
   10284:	fd843783          	ld	a5,-40(s0)
   10288:	0007c783          	lbu	a5,0(a5)
   1028c:	00078713          	mv	a4,a5
   10290:	02200793          	li	a5,34
   10294:	06f71c63          	bne	a4,a5,1030c <get_string+0xc0>
   10298:	fd843783          	ld	a5,-40(s0)
   1029c:	00178793          	addi	a5,a5,1
   102a0:	fcf43c23          	sd	a5,-40(s0)
   102a4:	fe042623          	sw	zero,-20(s0)
   102a8:	0300006f          	j	102d8 <get_string+0x8c>
   102ac:	fd843703          	ld	a4,-40(s0)
   102b0:	00170793          	addi	a5,a4,1
   102b4:	fcf43c23          	sd	a5,-40(s0)
   102b8:	fec42783          	lw	a5,-20(s0)
   102bc:	0017869b          	addiw	a3,a5,1
   102c0:	fed42623          	sw	a3,-20(s0)
   102c4:	00074703          	lbu	a4,0(a4)
   102c8:	00003697          	auipc	a3,0x3
   102cc:	d3868693          	addi	a3,a3,-712 # 13000 <string_buf>
   102d0:	00f687b3          	add	a5,a3,a5
   102d4:	00e78023          	sb	a4,0(a5)
   102d8:	fd843783          	ld	a5,-40(s0)
   102dc:	0007c783          	lbu	a5,0(a5)
   102e0:	00078713          	mv	a4,a5
   102e4:	02200793          	li	a5,34
   102e8:	fcf712e3          	bne	a4,a5,102ac <get_string+0x60>
   102ec:	00003717          	auipc	a4,0x3
   102f0:	d1470713          	addi	a4,a4,-748 # 13000 <string_buf>
   102f4:	fec42783          	lw	a5,-20(s0)
   102f8:	00f707b3          	add	a5,a4,a5
   102fc:	00078023          	sb	zero,0(a5)
   10300:	00003797          	auipc	a5,0x3
   10304:	d0078793          	addi	a5,a5,-768 # 13000 <string_buf>
   10308:	0100006f          	j	10318 <get_string+0xcc>
   1030c:	fd843503          	ld	a0,-40(s0)
   10310:	e89ff0ef          	jal	10198 <get_param>
   10314:	00050793          	mv	a5,a0
   10318:	00078513          	mv	a0,a5
   1031c:	02813083          	ld	ra,40(sp)
   10320:	02013403          	ld	s0,32(sp)
   10324:	03010113          	addi	sp,sp,48
   10328:	00008067          	ret

000000000001032c <parse_cmd>:
   1032c:	c9010113          	addi	sp,sp,-880
   10330:	36113423          	sd	ra,872(sp)
   10334:	36813023          	sd	s0,864(sp)
   10338:	34913c23          	sd	s1,856(sp)
   1033c:	35213823          	sd	s2,848(sp)
   10340:	35313423          	sd	s3,840(sp)
   10344:	35413023          	sd	s4,832(sp)
   10348:	33513c23          	sd	s5,824(sp)
   1034c:	33613823          	sd	s6,816(sp)
   10350:	33713423          	sd	s7,808(sp)
   10354:	33813023          	sd	s8,800(sp)
   10358:	31913c23          	sd	s9,792(sp)
   1035c:	31a13823          	sd	s10,784(sp)
   10360:	31b13423          	sd	s11,776(sp)
   10364:	37010413          	addi	s0,sp,880
   10368:	d0a43423          	sd	a0,-760(s0)
   1036c:	00058793          	mv	a5,a1
   10370:	d0f42223          	sw	a5,-764(s0)
   10374:	d0843783          	ld	a5,-760(s0)
   10378:	0007c783          	lbu	a5,0(a5)
   1037c:	00078713          	mv	a4,a5
   10380:	06500793          	li	a5,101
   10384:	0af71863          	bne	a4,a5,10434 <parse_cmd+0x108>
   10388:	d0843783          	ld	a5,-760(s0)
   1038c:	00178793          	addi	a5,a5,1
   10390:	0007c783          	lbu	a5,0(a5)
   10394:	00078713          	mv	a4,a5
   10398:	06300793          	li	a5,99
   1039c:	08f71c63          	bne	a4,a5,10434 <parse_cmd+0x108>
   103a0:	d0843783          	ld	a5,-760(s0)
   103a4:	00278793          	addi	a5,a5,2
   103a8:	0007c783          	lbu	a5,0(a5)
   103ac:	00078713          	mv	a4,a5
   103b0:	06800793          	li	a5,104
   103b4:	08f71063          	bne	a4,a5,10434 <parse_cmd+0x108>
   103b8:	d0843783          	ld	a5,-760(s0)
   103bc:	00378793          	addi	a5,a5,3
   103c0:	0007c783          	lbu	a5,0(a5)
   103c4:	00078713          	mv	a4,a5
   103c8:	06f00793          	li	a5,111
   103cc:	06f71463          	bne	a4,a5,10434 <parse_cmd+0x108>
   103d0:	d0843783          	ld	a5,-760(s0)
   103d4:	00478793          	addi	a5,a5,4
   103d8:	d0f43423          	sd	a5,-760(s0)
   103dc:	d0843503          	ld	a0,-760(s0)
   103e0:	e6dff0ef          	jal	1024c <get_string>
   103e4:	f6a43823          	sd	a0,-144(s0)
   103e8:	f7043503          	ld	a0,-144(s0)
   103ec:	7a8010ef          	jal	11b94 <strlen>
   103f0:	00050793          	mv	a5,a0
   103f4:	d0f42223          	sw	a5,-764(s0)
   103f8:	d0442783          	lw	a5,-764(s0)
   103fc:	d0843703          	ld	a4,-760(s0)
   10400:	00f707b3          	add	a5,a4,a5
   10404:	d0f43423          	sd	a5,-760(s0)
   10408:	d0442783          	lw	a5,-764(s0)
   1040c:	00078613          	mv	a2,a5
   10410:	f7043583          	ld	a1,-144(s0)
   10414:	00100513          	li	a0,1
   10418:	7c8010ef          	jal	11be0 <write>
   1041c:	00100613          	li	a2,1
   10420:	00002597          	auipc	a1,0x2
   10424:	aa858593          	addi	a1,a1,-1368 # 11ec8 <lseek+0x70>
   10428:	00100513          	li	a0,1
   1042c:	7b4010ef          	jal	11be0 <write>
   10430:	62c0006f          	j	10a5c <parse_cmd+0x730>
   10434:	d0843783          	ld	a5,-760(s0)
   10438:	0007c783          	lbu	a5,0(a5)
   1043c:	00078713          	mv	a4,a5
   10440:	06300793          	li	a5,99
   10444:	16f71663          	bne	a4,a5,105b0 <parse_cmd+0x284>
   10448:	d0843783          	ld	a5,-760(s0)
   1044c:	00178793          	addi	a5,a5,1
   10450:	0007c783          	lbu	a5,0(a5)
   10454:	00078713          	mv	a4,a5
   10458:	06100793          	li	a5,97
   1045c:	14f71a63          	bne	a4,a5,105b0 <parse_cmd+0x284>
   10460:	d0843783          	ld	a5,-760(s0)
   10464:	00278793          	addi	a5,a5,2
   10468:	0007c783          	lbu	a5,0(a5)
   1046c:	00078713          	mv	a4,a5
   10470:	07400793          	li	a5,116
   10474:	12f71e63          	bne	a4,a5,105b0 <parse_cmd+0x284>
   10478:	d0843783          	ld	a5,-760(s0)
   1047c:	00378793          	addi	a5,a5,3
   10480:	00078513          	mv	a0,a5
   10484:	d15ff0ef          	jal	10198 <get_param>
   10488:	f6a43423          	sd	a0,-152(s0)
   1048c:	00100593          	li	a1,1
   10490:	f6843503          	ld	a0,-152(s0)
   10494:	135010ef          	jal	11dc8 <open>
   10498:	00050793          	mv	a5,a0
   1049c:	f6f42223          	sw	a5,-156(s0)
   104a0:	f6442783          	lw	a5,-156(s0)
   104a4:	0007871b          	sext.w	a4,a5
   104a8:	fff00793          	li	a5,-1
   104ac:	00f71c63          	bne	a4,a5,104c4 <parse_cmd+0x198>
   104b0:	f6843583          	ld	a1,-152(s0)
   104b4:	00002517          	auipc	a0,0x2
   104b8:	a1c50513          	addi	a0,a0,-1508 # 11ed0 <lseek+0x78>
   104bc:	5dc010ef          	jal	11a98 <printf>
   104c0:	59c0006f          	j	10a5c <parse_cmd+0x730>
   104c4:	d1840713          	addi	a4,s0,-744
   104c8:	f6442783          	lw	a5,-156(s0)
   104cc:	1fd00613          	li	a2,509
   104d0:	00070593          	mv	a1,a4
   104d4:	00078513          	mv	a0,a5
   104d8:	029010ef          	jal	11d00 <read>
   104dc:	00050793          	mv	a5,a0
   104e0:	f6f42023          	sw	a5,-160(s0)
   104e4:	f6042783          	lw	a5,-160(s0)
   104e8:	0007879b          	sext.w	a5,a5
   104ec:	02079263          	bnez	a5,10510 <parse_cmd+0x1e4>
   104f0:	f8f44783          	lbu	a5,-113(s0)
   104f4:	0ff7f713          	zext.b	a4,a5
   104f8:	00a00793          	li	a5,10
   104fc:	0af70063          	beq	a4,a5,1059c <parse_cmd+0x270>
   10500:	00002517          	auipc	a0,0x2
   10504:	9e850513          	addi	a0,a0,-1560 # 11ee8 <lseek+0x90>
   10508:	590010ef          	jal	11a98 <printf>
   1050c:	0900006f          	j	1059c <parse_cmd+0x270>
   10510:	f8042423          	sw	zero,-120(s0)
   10514:	06c0006f          	j	10580 <parse_cmd+0x254>
   10518:	f8842783          	lw	a5,-120(s0)
   1051c:	f9078793          	addi	a5,a5,-112
   10520:	008787b3          	add	a5,a5,s0
   10524:	d887c783          	lbu	a5,-632(a5)
   10528:	00079e63          	bnez	a5,10544 <parse_cmd+0x218>
   1052c:	00100613          	li	a2,1
   10530:	00002597          	auipc	a1,0x2
   10534:	9c058593          	addi	a1,a1,-1600 # 11ef0 <lseek+0x98>
   10538:	00100513          	li	a0,1
   1053c:	6a4010ef          	jal	11be0 <write>
   10540:	0200006f          	j	10560 <parse_cmd+0x234>
   10544:	d1840713          	addi	a4,s0,-744
   10548:	f8842783          	lw	a5,-120(s0)
   1054c:	00f707b3          	add	a5,a4,a5
   10550:	00100613          	li	a2,1
   10554:	00078593          	mv	a1,a5
   10558:	00100513          	li	a0,1
   1055c:	684010ef          	jal	11be0 <write>
   10560:	f8842783          	lw	a5,-120(s0)
   10564:	f9078793          	addi	a5,a5,-112
   10568:	008787b3          	add	a5,a5,s0
   1056c:	d887c783          	lbu	a5,-632(a5)
   10570:	f8f407a3          	sb	a5,-113(s0)
   10574:	f8842783          	lw	a5,-120(s0)
   10578:	0017879b          	addiw	a5,a5,1
   1057c:	f8f42423          	sw	a5,-120(s0)
   10580:	f8842783          	lw	a5,-120(s0)
   10584:	00078713          	mv	a4,a5
   10588:	f6042783          	lw	a5,-160(s0)
   1058c:	0007071b          	sext.w	a4,a4
   10590:	0007879b          	sext.w	a5,a5
   10594:	f8f742e3          	blt	a4,a5,10518 <parse_cmd+0x1ec>
   10598:	f2dff06f          	j	104c4 <parse_cmd+0x198>
   1059c:	00000013          	nop
   105a0:	f6442783          	lw	a5,-156(s0)
   105a4:	00078513          	mv	a0,a5
   105a8:	069010ef          	jal	11e10 <close>
   105ac:	4b00006f          	j	10a5c <parse_cmd+0x730>
   105b0:	d0843783          	ld	a5,-760(s0)
   105b4:	0007c783          	lbu	a5,0(a5)
   105b8:	00078713          	mv	a4,a5
   105bc:	06500793          	li	a5,101
   105c0:	48f71663          	bne	a4,a5,10a4c <parse_cmd+0x720>
   105c4:	d0843783          	ld	a5,-760(s0)
   105c8:	00178793          	addi	a5,a5,1
   105cc:	0007c783          	lbu	a5,0(a5)
   105d0:	00078713          	mv	a4,a5
   105d4:	06400793          	li	a5,100
   105d8:	46f71a63          	bne	a4,a5,10a4c <parse_cmd+0x720>
   105dc:	d0843783          	ld	a5,-760(s0)
   105e0:	00278793          	addi	a5,a5,2
   105e4:	0007c783          	lbu	a5,0(a5)
   105e8:	00078713          	mv	a4,a5
   105ec:	06900793          	li	a5,105
   105f0:	44f71e63          	bne	a4,a5,10a4c <parse_cmd+0x720>
   105f4:	d0843783          	ld	a5,-760(s0)
   105f8:	00378793          	addi	a5,a5,3
   105fc:	0007c783          	lbu	a5,0(a5)
   10600:	00078713          	mv	a4,a5
   10604:	07400793          	li	a5,116
   10608:	44f71263          	bne	a4,a5,10a4c <parse_cmd+0x720>
   1060c:	00010793          	mv	a5,sp
   10610:	00078493          	mv	s1,a5
   10614:	d0843783          	ld	a5,-760(s0)
   10618:	00478793          	addi	a5,a5,4
   1061c:	d0f43423          	sd	a5,-760(s0)
   10620:	0100006f          	j	10630 <parse_cmd+0x304>
   10624:	d0843783          	ld	a5,-760(s0)
   10628:	00178793          	addi	a5,a5,1
   1062c:	d0f43423          	sd	a5,-760(s0)
   10630:	d0843783          	ld	a5,-760(s0)
   10634:	0007c783          	lbu	a5,0(a5)
   10638:	00078713          	mv	a4,a5
   1063c:	02000793          	li	a5,32
   10640:	00f71863          	bne	a4,a5,10650 <parse_cmd+0x324>
   10644:	d0843783          	ld	a5,-760(s0)
   10648:	0007c783          	lbu	a5,0(a5)
   1064c:	fc079ce3          	bnez	a5,10624 <parse_cmd+0x2f8>
   10650:	d0843503          	ld	a0,-760(s0)
   10654:	b45ff0ef          	jal	10198 <get_param>
   10658:	f4a43c23          	sd	a0,-168(s0)
   1065c:	f5843503          	ld	a0,-168(s0)
   10660:	534010ef          	jal	11b94 <strlen>
   10664:	00050793          	mv	a5,a0
   10668:	f4f42a23          	sw	a5,-172(s0)
   1066c:	f5442783          	lw	a5,-172(s0)
   10670:	0017879b          	addiw	a5,a5,1
   10674:	0007879b          	sext.w	a5,a5
   10678:	00078713          	mv	a4,a5
   1067c:	fff70713          	addi	a4,a4,-1
   10680:	f4e43423          	sd	a4,-184(s0)
   10684:	00078713          	mv	a4,a5
   10688:	cee43823          	sd	a4,-784(s0)
   1068c:	ce043c23          	sd	zero,-776(s0)
   10690:	cf043703          	ld	a4,-784(s0)
   10694:	03d75713          	srli	a4,a4,0x3d
   10698:	cf843683          	ld	a3,-776(s0)
   1069c:	00369693          	slli	a3,a3,0x3
   106a0:	c8d43c23          	sd	a3,-872(s0)
   106a4:	c9843683          	ld	a3,-872(s0)
   106a8:	00d76733          	or	a4,a4,a3
   106ac:	c8e43c23          	sd	a4,-872(s0)
   106b0:	cf043703          	ld	a4,-784(s0)
   106b4:	00371713          	slli	a4,a4,0x3
   106b8:	c8e43823          	sd	a4,-880(s0)
   106bc:	00078713          	mv	a4,a5
   106c0:	cee43023          	sd	a4,-800(s0)
   106c4:	ce043423          	sd	zero,-792(s0)
   106c8:	ce043703          	ld	a4,-800(s0)
   106cc:	03d75713          	srli	a4,a4,0x3d
   106d0:	ce843683          	ld	a3,-792(s0)
   106d4:	00369d93          	slli	s11,a3,0x3
   106d8:	01b76db3          	or	s11,a4,s11
   106dc:	ce043703          	ld	a4,-800(s0)
   106e0:	00371d13          	slli	s10,a4,0x3
   106e4:	00f78793          	addi	a5,a5,15
   106e8:	0047d793          	srli	a5,a5,0x4
   106ec:	00479793          	slli	a5,a5,0x4
   106f0:	40f10133          	sub	sp,sp,a5
   106f4:	00010793          	mv	a5,sp
   106f8:	00078793          	mv	a5,a5
   106fc:	f4f43023          	sd	a5,-192(s0)
   10700:	f8042223          	sw	zero,-124(s0)
   10704:	0300006f          	j	10734 <parse_cmd+0x408>
   10708:	f8442783          	lw	a5,-124(s0)
   1070c:	f5843703          	ld	a4,-168(s0)
   10710:	00f707b3          	add	a5,a4,a5
   10714:	0007c703          	lbu	a4,0(a5)
   10718:	f4043683          	ld	a3,-192(s0)
   1071c:	f8442783          	lw	a5,-124(s0)
   10720:	00f687b3          	add	a5,a3,a5
   10724:	00e78023          	sb	a4,0(a5)
   10728:	f8442783          	lw	a5,-124(s0)
   1072c:	0017879b          	addiw	a5,a5,1
   10730:	f8f42223          	sw	a5,-124(s0)
   10734:	f8442783          	lw	a5,-124(s0)
   10738:	00078713          	mv	a4,a5
   1073c:	f5442783          	lw	a5,-172(s0)
   10740:	0007071b          	sext.w	a4,a4
   10744:	0007879b          	sext.w	a5,a5
   10748:	fcf740e3          	blt	a4,a5,10708 <parse_cmd+0x3dc>
   1074c:	f4043703          	ld	a4,-192(s0)
   10750:	f5442783          	lw	a5,-172(s0)
   10754:	00f707b3          	add	a5,a4,a5
   10758:	00078023          	sb	zero,0(a5)
   1075c:	f5442783          	lw	a5,-172(s0)
   10760:	d0843703          	ld	a4,-760(s0)
   10764:	00f707b3          	add	a5,a4,a5
   10768:	d0f43423          	sd	a5,-760(s0)
   1076c:	0100006f          	j	1077c <parse_cmd+0x450>
   10770:	d0843783          	ld	a5,-760(s0)
   10774:	00178793          	addi	a5,a5,1
   10778:	d0f43423          	sd	a5,-760(s0)
   1077c:	d0843783          	ld	a5,-760(s0)
   10780:	0007c783          	lbu	a5,0(a5)
   10784:	00078713          	mv	a4,a5
   10788:	02000793          	li	a5,32
   1078c:	00f71863          	bne	a4,a5,1079c <parse_cmd+0x470>
   10790:	d0843783          	ld	a5,-760(s0)
   10794:	0007c783          	lbu	a5,0(a5)
   10798:	fc079ce3          	bnez	a5,10770 <parse_cmd+0x444>
   1079c:	d0843503          	ld	a0,-760(s0)
   107a0:	9f9ff0ef          	jal	10198 <get_param>
   107a4:	f4a43c23          	sd	a0,-168(s0)
   107a8:	f5843503          	ld	a0,-168(s0)
   107ac:	3e8010ef          	jal	11b94 <strlen>
   107b0:	00050793          	mv	a5,a0
   107b4:	f4f42a23          	sw	a5,-172(s0)
   107b8:	f5442783          	lw	a5,-172(s0)
   107bc:	0017879b          	addiw	a5,a5,1
   107c0:	0007879b          	sext.w	a5,a5
   107c4:	00078713          	mv	a4,a5
   107c8:	fff70713          	addi	a4,a4,-1
   107cc:	f2e43c23          	sd	a4,-200(s0)
   107d0:	00078713          	mv	a4,a5
   107d4:	cce43823          	sd	a4,-816(s0)
   107d8:	cc043c23          	sd	zero,-808(s0)
   107dc:	cd043703          	ld	a4,-816(s0)
   107e0:	03d75713          	srli	a4,a4,0x3d
   107e4:	cd843683          	ld	a3,-808(s0)
   107e8:	00369c93          	slli	s9,a3,0x3
   107ec:	01976cb3          	or	s9,a4,s9
   107f0:	cd043703          	ld	a4,-816(s0)
   107f4:	00371c13          	slli	s8,a4,0x3
   107f8:	00078713          	mv	a4,a5
   107fc:	cce43023          	sd	a4,-832(s0)
   10800:	cc043423          	sd	zero,-824(s0)
   10804:	cc043703          	ld	a4,-832(s0)
   10808:	03d75713          	srli	a4,a4,0x3d
   1080c:	cc843683          	ld	a3,-824(s0)
   10810:	00369b93          	slli	s7,a3,0x3
   10814:	01776bb3          	or	s7,a4,s7
   10818:	cc043703          	ld	a4,-832(s0)
   1081c:	00371b13          	slli	s6,a4,0x3
   10820:	00f78793          	addi	a5,a5,15
   10824:	0047d793          	srli	a5,a5,0x4
   10828:	00479793          	slli	a5,a5,0x4
   1082c:	40f10133          	sub	sp,sp,a5
   10830:	00010793          	mv	a5,sp
   10834:	00078793          	mv	a5,a5
   10838:	f2f43823          	sd	a5,-208(s0)
   1083c:	f8042023          	sw	zero,-128(s0)
   10840:	0300006f          	j	10870 <parse_cmd+0x544>
   10844:	f8042783          	lw	a5,-128(s0)
   10848:	f5843703          	ld	a4,-168(s0)
   1084c:	00f707b3          	add	a5,a4,a5
   10850:	0007c703          	lbu	a4,0(a5)
   10854:	f3043683          	ld	a3,-208(s0)
   10858:	f8042783          	lw	a5,-128(s0)
   1085c:	00f687b3          	add	a5,a3,a5
   10860:	00e78023          	sb	a4,0(a5)
   10864:	f8042783          	lw	a5,-128(s0)
   10868:	0017879b          	addiw	a5,a5,1
   1086c:	f8f42023          	sw	a5,-128(s0)
   10870:	f8042783          	lw	a5,-128(s0)
   10874:	00078713          	mv	a4,a5
   10878:	f5442783          	lw	a5,-172(s0)
   1087c:	0007071b          	sext.w	a4,a4
   10880:	0007879b          	sext.w	a5,a5
   10884:	fcf740e3          	blt	a4,a5,10844 <parse_cmd+0x518>
   10888:	f3043703          	ld	a4,-208(s0)
   1088c:	f5442783          	lw	a5,-172(s0)
   10890:	00f707b3          	add	a5,a4,a5
   10894:	00078023          	sb	zero,0(a5)
   10898:	f5442783          	lw	a5,-172(s0)
   1089c:	d0843703          	ld	a4,-760(s0)
   108a0:	00f707b3          	add	a5,a4,a5
   108a4:	d0f43423          	sd	a5,-760(s0)
   108a8:	0100006f          	j	108b8 <parse_cmd+0x58c>
   108ac:	d0843783          	ld	a5,-760(s0)
   108b0:	00178793          	addi	a5,a5,1
   108b4:	d0f43423          	sd	a5,-760(s0)
   108b8:	d0843783          	ld	a5,-760(s0)
   108bc:	0007c783          	lbu	a5,0(a5)
   108c0:	00078713          	mv	a4,a5
   108c4:	02000793          	li	a5,32
   108c8:	00f71863          	bne	a4,a5,108d8 <parse_cmd+0x5ac>
   108cc:	d0843783          	ld	a5,-760(s0)
   108d0:	0007c783          	lbu	a5,0(a5)
   108d4:	fc079ce3          	bnez	a5,108ac <parse_cmd+0x580>
   108d8:	d0843503          	ld	a0,-760(s0)
   108dc:	971ff0ef          	jal	1024c <get_string>
   108e0:	f4a43c23          	sd	a0,-168(s0)
   108e4:	f5843503          	ld	a0,-168(s0)
   108e8:	2ac010ef          	jal	11b94 <strlen>
   108ec:	00050793          	mv	a5,a0
   108f0:	f4f42a23          	sw	a5,-172(s0)
   108f4:	f5442783          	lw	a5,-172(s0)
   108f8:	0017879b          	addiw	a5,a5,1
   108fc:	0007879b          	sext.w	a5,a5
   10900:	00078713          	mv	a4,a5
   10904:	fff70713          	addi	a4,a4,-1
   10908:	f2e43423          	sd	a4,-216(s0)
   1090c:	00078713          	mv	a4,a5
   10910:	cae43823          	sd	a4,-848(s0)
   10914:	ca043c23          	sd	zero,-840(s0)
   10918:	cb043703          	ld	a4,-848(s0)
   1091c:	03d75713          	srli	a4,a4,0x3d
   10920:	cb843683          	ld	a3,-840(s0)
   10924:	00369a93          	slli	s5,a3,0x3
   10928:	01576ab3          	or	s5,a4,s5
   1092c:	cb043703          	ld	a4,-848(s0)
   10930:	00371a13          	slli	s4,a4,0x3
   10934:	00078713          	mv	a4,a5
   10938:	cae43023          	sd	a4,-864(s0)
   1093c:	ca043423          	sd	zero,-856(s0)
   10940:	ca043703          	ld	a4,-864(s0)
   10944:	03d75713          	srli	a4,a4,0x3d
   10948:	ca843683          	ld	a3,-856(s0)
   1094c:	00369993          	slli	s3,a3,0x3
   10950:	013769b3          	or	s3,a4,s3
   10954:	ca043703          	ld	a4,-864(s0)
   10958:	00371913          	slli	s2,a4,0x3
   1095c:	00f78793          	addi	a5,a5,15
   10960:	0047d793          	srli	a5,a5,0x4
   10964:	00479793          	slli	a5,a5,0x4
   10968:	40f10133          	sub	sp,sp,a5
   1096c:	00010793          	mv	a5,sp
   10970:	00078793          	mv	a5,a5
   10974:	f2f43023          	sd	a5,-224(s0)
   10978:	f6042e23          	sw	zero,-132(s0)
   1097c:	0300006f          	j	109ac <parse_cmd+0x680>
   10980:	f7c42783          	lw	a5,-132(s0)
   10984:	f5843703          	ld	a4,-168(s0)
   10988:	00f707b3          	add	a5,a4,a5
   1098c:	0007c703          	lbu	a4,0(a5)
   10990:	f2043683          	ld	a3,-224(s0)
   10994:	f7c42783          	lw	a5,-132(s0)
   10998:	00f687b3          	add	a5,a3,a5
   1099c:	00e78023          	sb	a4,0(a5)
   109a0:	f7c42783          	lw	a5,-132(s0)
   109a4:	0017879b          	addiw	a5,a5,1
   109a8:	f6f42e23          	sw	a5,-132(s0)
   109ac:	f7c42783          	lw	a5,-132(s0)
   109b0:	00078713          	mv	a4,a5
   109b4:	f5442783          	lw	a5,-172(s0)
   109b8:	0007071b          	sext.w	a4,a4
   109bc:	0007879b          	sext.w	a5,a5
   109c0:	fcf740e3          	blt	a4,a5,10980 <parse_cmd+0x654>
   109c4:	f2043703          	ld	a4,-224(s0)
   109c8:	f5442783          	lw	a5,-172(s0)
   109cc:	00f707b3          	add	a5,a4,a5
   109d0:	00078023          	sb	zero,0(a5)
   109d4:	f5442783          	lw	a5,-172(s0)
   109d8:	d0843703          	ld	a4,-760(s0)
   109dc:	00f707b3          	add	a5,a4,a5
   109e0:	d0f43423          	sd	a5,-760(s0)
   109e4:	f3043503          	ld	a0,-208(s0)
   109e8:	f04ff0ef          	jal	100ec <atoi>
   109ec:	00050793          	mv	a5,a0
   109f0:	f0f42e23          	sw	a5,-228(s0)
   109f4:	00300593          	li	a1,3
   109f8:	f4043503          	ld	a0,-192(s0)
   109fc:	3cc010ef          	jal	11dc8 <open>
   10a00:	00050793          	mv	a5,a0
   10a04:	f0f42c23          	sw	a5,-232(s0)
   10a08:	f1c42703          	lw	a4,-228(s0)
   10a0c:	f1842783          	lw	a5,-232(s0)
   10a10:	00000613          	li	a2,0
   10a14:	00070593          	mv	a1,a4
   10a18:	00078513          	mv	a0,a5
   10a1c:	43c010ef          	jal	11e58 <lseek>
   10a20:	f5442703          	lw	a4,-172(s0)
   10a24:	f1842783          	lw	a5,-232(s0)
   10a28:	00070613          	mv	a2,a4
   10a2c:	f2043583          	ld	a1,-224(s0)
   10a30:	00078513          	mv	a0,a5
   10a34:	1ac010ef          	jal	11be0 <write>
   10a38:	f1842783          	lw	a5,-232(s0)
   10a3c:	00078513          	mv	a0,a5
   10a40:	3d0010ef          	jal	11e10 <close>
   10a44:	00048113          	mv	sp,s1
   10a48:	0140006f          	j	10a5c <parse_cmd+0x730>
   10a4c:	d0843583          	ld	a1,-760(s0)
   10a50:	00001517          	auipc	a0,0x1
   10a54:	4a850513          	addi	a0,a0,1192 # 11ef8 <lseek+0xa0>
   10a58:	040010ef          	jal	11a98 <printf>
   10a5c:	c9040113          	addi	sp,s0,-880
   10a60:	36813083          	ld	ra,872(sp)
   10a64:	36013403          	ld	s0,864(sp)
   10a68:	35813483          	ld	s1,856(sp)
   10a6c:	35013903          	ld	s2,848(sp)
   10a70:	34813983          	ld	s3,840(sp)
   10a74:	34013a03          	ld	s4,832(sp)
   10a78:	33813a83          	ld	s5,824(sp)
   10a7c:	33013b03          	ld	s6,816(sp)
   10a80:	32813b83          	ld	s7,808(sp)
   10a84:	32013c03          	ld	s8,800(sp)
   10a88:	31813c83          	ld	s9,792(sp)
   10a8c:	31013d03          	ld	s10,784(sp)
   10a90:	30813d83          	ld	s11,776(sp)
   10a94:	37010113          	addi	sp,sp,880
   10a98:	00008067          	ret

0000000000010a9c <main>:
   10a9c:	f6010113          	addi	sp,sp,-160
   10aa0:	08113c23          	sd	ra,152(sp)
   10aa4:	08813823          	sd	s0,144(sp)
   10aa8:	0a010413          	addi	s0,sp,160
   10aac:	00f00613          	li	a2,15
   10ab0:	00001597          	auipc	a1,0x1
   10ab4:	46058593          	addi	a1,a1,1120 # 11f10 <lseek+0xb8>
   10ab8:	00100513          	li	a0,1
   10abc:	124010ef          	jal	11be0 <write>
   10ac0:	00f00613          	li	a2,15
   10ac4:	00001597          	auipc	a1,0x1
   10ac8:	45c58593          	addi	a1,a1,1116 # 11f20 <lseek+0xc8>
   10acc:	00200513          	li	a0,2
   10ad0:	110010ef          	jal	11be0 <write>
   10ad4:	fe042623          	sw	zero,-20(s0)
   10ad8:	00001517          	auipc	a0,0x1
   10adc:	45850513          	addi	a0,a0,1112 # 11f30 <lseek+0xd8>
   10ae0:	7b9000ef          	jal	11a98 <printf>
   10ae4:	fe840793          	addi	a5,s0,-24
   10ae8:	00100613          	li	a2,1
   10aec:	00078593          	mv	a1,a5
   10af0:	00000513          	li	a0,0
   10af4:	20c010ef          	jal	11d00 <read>
   10af8:	fe844783          	lbu	a5,-24(s0)
   10afc:	00078713          	mv	a4,a5
   10b00:	00d00793          	li	a5,13
   10b04:	00f71e63          	bne	a4,a5,10b20 <main+0x84>
   10b08:	00100613          	li	a2,1
   10b0c:	00001597          	auipc	a1,0x1
   10b10:	3bc58593          	addi	a1,a1,956 # 11ec8 <lseek+0x70>
   10b14:	00100513          	li	a0,1
   10b18:	0c8010ef          	jal	11be0 <write>
   10b1c:	0440006f          	j	10b60 <main+0xc4>
   10b20:	fe844783          	lbu	a5,-24(s0)
   10b24:	00078713          	mv	a4,a5
   10b28:	07f00793          	li	a5,127
   10b2c:	02f71a63          	bne	a4,a5,10b60 <main+0xc4>
   10b30:	fec42783          	lw	a5,-20(s0)
   10b34:	0007879b          	sext.w	a5,a5
   10b38:	0af05263          	blez	a5,10bdc <main+0x140>
   10b3c:	00300613          	li	a2,3
   10b40:	00001597          	auipc	a1,0x1
   10b44:	40858593          	addi	a1,a1,1032 # 11f48 <lseek+0xf0>
   10b48:	00100513          	li	a0,1
   10b4c:	094010ef          	jal	11be0 <write>
   10b50:	fec42783          	lw	a5,-20(s0)
   10b54:	fff7879b          	addiw	a5,a5,-1
   10b58:	fef42623          	sw	a5,-20(s0)
   10b5c:	0800006f          	j	10bdc <main+0x140>
   10b60:	fe840793          	addi	a5,s0,-24
   10b64:	00100613          	li	a2,1
   10b68:	00078593          	mv	a1,a5
   10b6c:	00100513          	li	a0,1
   10b70:	070010ef          	jal	11be0 <write>
   10b74:	fe844783          	lbu	a5,-24(s0)
   10b78:	00078713          	mv	a4,a5
   10b7c:	00d00793          	li	a5,13
   10b80:	02f71e63          	bne	a4,a5,10bbc <main+0x120>
   10b84:	fec42783          	lw	a5,-20(s0)
   10b88:	ff078793          	addi	a5,a5,-16
   10b8c:	008787b3          	add	a5,a5,s0
   10b90:	f6078c23          	sb	zero,-136(a5)
   10b94:	fec42703          	lw	a4,-20(s0)
   10b98:	f6840793          	addi	a5,s0,-152
   10b9c:	00070593          	mv	a1,a4
   10ba0:	00078513          	mv	a0,a5
   10ba4:	f88ff0ef          	jal	1032c <parse_cmd>
   10ba8:	fe042623          	sw	zero,-20(s0)
   10bac:	00001517          	auipc	a0,0x1
   10bb0:	38450513          	addi	a0,a0,900 # 11f30 <lseek+0xd8>
   10bb4:	6e5000ef          	jal	11a98 <printf>
   10bb8:	f2dff06f          	j	10ae4 <main+0x48>
   10bbc:	fec42783          	lw	a5,-20(s0)
   10bc0:	0017871b          	addiw	a4,a5,1
   10bc4:	fee42623          	sw	a4,-20(s0)
   10bc8:	fe844703          	lbu	a4,-24(s0)
   10bcc:	ff078793          	addi	a5,a5,-16
   10bd0:	008787b3          	add	a5,a5,s0
   10bd4:	f6e78c23          	sb	a4,-136(a5)
   10bd8:	f0dff06f          	j	10ae4 <main+0x48>
   10bdc:	00000013          	nop
   10be0:	f05ff06f          	j	10ae4 <main+0x48>

0000000000010be4 <putc>:
   10be4:	fe010113          	addi	sp,sp,-32
   10be8:	00813c23          	sd	s0,24(sp)
   10bec:	02010413          	addi	s0,sp,32
   10bf0:	00050793          	mv	a5,a0
   10bf4:	fef42623          	sw	a5,-20(s0)
   10bf8:	00003797          	auipc	a5,0x3
   10bfc:	40878793          	addi	a5,a5,1032 # 14000 <tail>
   10c00:	0007a783          	lw	a5,0(a5)
   10c04:	0017871b          	addiw	a4,a5,1
   10c08:	0007069b          	sext.w	a3,a4
   10c0c:	00003717          	auipc	a4,0x3
   10c10:	3f470713          	addi	a4,a4,1012 # 14000 <tail>
   10c14:	00d72023          	sw	a3,0(a4)
   10c18:	fec42703          	lw	a4,-20(s0)
   10c1c:	0ff77713          	zext.b	a4,a4
   10c20:	00003697          	auipc	a3,0x3
   10c24:	3e868693          	addi	a3,a3,1000 # 14008 <buffer>
   10c28:	00f687b3          	add	a5,a3,a5
   10c2c:	00e78023          	sb	a4,0(a5)
   10c30:	fec42783          	lw	a5,-20(s0)
   10c34:	0ff7f793          	zext.b	a5,a5
   10c38:	0007879b          	sext.w	a5,a5
   10c3c:	00078513          	mv	a0,a5
   10c40:	01813403          	ld	s0,24(sp)
   10c44:	02010113          	addi	sp,sp,32
   10c48:	00008067          	ret

0000000000010c4c <isspace>:
   10c4c:	fe010113          	addi	sp,sp,-32
   10c50:	00813c23          	sd	s0,24(sp)
   10c54:	02010413          	addi	s0,sp,32
   10c58:	00050793          	mv	a5,a0
   10c5c:	fef42623          	sw	a5,-20(s0)
   10c60:	fec42783          	lw	a5,-20(s0)
   10c64:	0007871b          	sext.w	a4,a5
   10c68:	02000793          	li	a5,32
   10c6c:	02f70263          	beq	a4,a5,10c90 <isspace+0x44>
   10c70:	fec42783          	lw	a5,-20(s0)
   10c74:	0007871b          	sext.w	a4,a5
   10c78:	00800793          	li	a5,8
   10c7c:	00e7de63          	bge	a5,a4,10c98 <isspace+0x4c>
   10c80:	fec42783          	lw	a5,-20(s0)
   10c84:	0007871b          	sext.w	a4,a5
   10c88:	00d00793          	li	a5,13
   10c8c:	00e7c663          	blt	a5,a4,10c98 <isspace+0x4c>
   10c90:	00100793          	li	a5,1
   10c94:	0080006f          	j	10c9c <isspace+0x50>
   10c98:	00000793          	li	a5,0
   10c9c:	00078513          	mv	a0,a5
   10ca0:	01813403          	ld	s0,24(sp)
   10ca4:	02010113          	addi	sp,sp,32
   10ca8:	00008067          	ret

0000000000010cac <strtol>:
   10cac:	fb010113          	addi	sp,sp,-80
   10cb0:	04113423          	sd	ra,72(sp)
   10cb4:	04813023          	sd	s0,64(sp)
   10cb8:	05010413          	addi	s0,sp,80
   10cbc:	fca43423          	sd	a0,-56(s0)
   10cc0:	fcb43023          	sd	a1,-64(s0)
   10cc4:	00060793          	mv	a5,a2
   10cc8:	faf42e23          	sw	a5,-68(s0)
   10ccc:	fe043423          	sd	zero,-24(s0)
   10cd0:	fe0403a3          	sb	zero,-25(s0)
   10cd4:	fc843783          	ld	a5,-56(s0)
   10cd8:	fcf43c23          	sd	a5,-40(s0)
   10cdc:	0100006f          	j	10cec <strtol+0x40>
   10ce0:	fd843783          	ld	a5,-40(s0)
   10ce4:	00178793          	addi	a5,a5,1
   10ce8:	fcf43c23          	sd	a5,-40(s0)
   10cec:	fd843783          	ld	a5,-40(s0)
   10cf0:	0007c783          	lbu	a5,0(a5)
   10cf4:	0007879b          	sext.w	a5,a5
   10cf8:	00078513          	mv	a0,a5
   10cfc:	f51ff0ef          	jal	10c4c <isspace>
   10d00:	00050793          	mv	a5,a0
   10d04:	fc079ee3          	bnez	a5,10ce0 <strtol+0x34>
   10d08:	fd843783          	ld	a5,-40(s0)
   10d0c:	0007c783          	lbu	a5,0(a5)
   10d10:	00078713          	mv	a4,a5
   10d14:	02d00793          	li	a5,45
   10d18:	00f71e63          	bne	a4,a5,10d34 <strtol+0x88>
   10d1c:	00100793          	li	a5,1
   10d20:	fef403a3          	sb	a5,-25(s0)
   10d24:	fd843783          	ld	a5,-40(s0)
   10d28:	00178793          	addi	a5,a5,1
   10d2c:	fcf43c23          	sd	a5,-40(s0)
   10d30:	0240006f          	j	10d54 <strtol+0xa8>
   10d34:	fd843783          	ld	a5,-40(s0)
   10d38:	0007c783          	lbu	a5,0(a5)
   10d3c:	00078713          	mv	a4,a5
   10d40:	02b00793          	li	a5,43
   10d44:	00f71863          	bne	a4,a5,10d54 <strtol+0xa8>
   10d48:	fd843783          	ld	a5,-40(s0)
   10d4c:	00178793          	addi	a5,a5,1
   10d50:	fcf43c23          	sd	a5,-40(s0)
   10d54:	fbc42783          	lw	a5,-68(s0)
   10d58:	0007879b          	sext.w	a5,a5
   10d5c:	06079c63          	bnez	a5,10dd4 <strtol+0x128>
   10d60:	fd843783          	ld	a5,-40(s0)
   10d64:	0007c783          	lbu	a5,0(a5)
   10d68:	00078713          	mv	a4,a5
   10d6c:	03000793          	li	a5,48
   10d70:	04f71e63          	bne	a4,a5,10dcc <strtol+0x120>
   10d74:	fd843783          	ld	a5,-40(s0)
   10d78:	00178793          	addi	a5,a5,1
   10d7c:	fcf43c23          	sd	a5,-40(s0)
   10d80:	fd843783          	ld	a5,-40(s0)
   10d84:	0007c783          	lbu	a5,0(a5)
   10d88:	00078713          	mv	a4,a5
   10d8c:	07800793          	li	a5,120
   10d90:	00f70c63          	beq	a4,a5,10da8 <strtol+0xfc>
   10d94:	fd843783          	ld	a5,-40(s0)
   10d98:	0007c783          	lbu	a5,0(a5)
   10d9c:	00078713          	mv	a4,a5
   10da0:	05800793          	li	a5,88
   10da4:	00f71e63          	bne	a4,a5,10dc0 <strtol+0x114>
   10da8:	01000793          	li	a5,16
   10dac:	faf42e23          	sw	a5,-68(s0)
   10db0:	fd843783          	ld	a5,-40(s0)
   10db4:	00178793          	addi	a5,a5,1
   10db8:	fcf43c23          	sd	a5,-40(s0)
   10dbc:	0180006f          	j	10dd4 <strtol+0x128>
   10dc0:	00800793          	li	a5,8
   10dc4:	faf42e23          	sw	a5,-68(s0)
   10dc8:	00c0006f          	j	10dd4 <strtol+0x128>
   10dcc:	00a00793          	li	a5,10
   10dd0:	faf42e23          	sw	a5,-68(s0)
   10dd4:	fd843783          	ld	a5,-40(s0)
   10dd8:	0007c783          	lbu	a5,0(a5)
   10ddc:	00078713          	mv	a4,a5
   10de0:	02f00793          	li	a5,47
   10de4:	02e7f863          	bgeu	a5,a4,10e14 <strtol+0x168>
   10de8:	fd843783          	ld	a5,-40(s0)
   10dec:	0007c783          	lbu	a5,0(a5)
   10df0:	00078713          	mv	a4,a5
   10df4:	03900793          	li	a5,57
   10df8:	00e7ee63          	bltu	a5,a4,10e14 <strtol+0x168>
   10dfc:	fd843783          	ld	a5,-40(s0)
   10e00:	0007c783          	lbu	a5,0(a5)
   10e04:	0007879b          	sext.w	a5,a5
   10e08:	fd07879b          	addiw	a5,a5,-48
   10e0c:	fcf42a23          	sw	a5,-44(s0)
   10e10:	0800006f          	j	10e90 <strtol+0x1e4>
   10e14:	fd843783          	ld	a5,-40(s0)
   10e18:	0007c783          	lbu	a5,0(a5)
   10e1c:	00078713          	mv	a4,a5
   10e20:	06000793          	li	a5,96
   10e24:	02e7f863          	bgeu	a5,a4,10e54 <strtol+0x1a8>
   10e28:	fd843783          	ld	a5,-40(s0)
   10e2c:	0007c783          	lbu	a5,0(a5)
   10e30:	00078713          	mv	a4,a5
   10e34:	07a00793          	li	a5,122
   10e38:	00e7ee63          	bltu	a5,a4,10e54 <strtol+0x1a8>
   10e3c:	fd843783          	ld	a5,-40(s0)
   10e40:	0007c783          	lbu	a5,0(a5)
   10e44:	0007879b          	sext.w	a5,a5
   10e48:	fa97879b          	addiw	a5,a5,-87
   10e4c:	fcf42a23          	sw	a5,-44(s0)
   10e50:	0400006f          	j	10e90 <strtol+0x1e4>
   10e54:	fd843783          	ld	a5,-40(s0)
   10e58:	0007c783          	lbu	a5,0(a5)
   10e5c:	00078713          	mv	a4,a5
   10e60:	04000793          	li	a5,64
   10e64:	06e7f863          	bgeu	a5,a4,10ed4 <strtol+0x228>
   10e68:	fd843783          	ld	a5,-40(s0)
   10e6c:	0007c783          	lbu	a5,0(a5)
   10e70:	00078713          	mv	a4,a5
   10e74:	05a00793          	li	a5,90
   10e78:	04e7ee63          	bltu	a5,a4,10ed4 <strtol+0x228>
   10e7c:	fd843783          	ld	a5,-40(s0)
   10e80:	0007c783          	lbu	a5,0(a5)
   10e84:	0007879b          	sext.w	a5,a5
   10e88:	fc97879b          	addiw	a5,a5,-55
   10e8c:	fcf42a23          	sw	a5,-44(s0)
   10e90:	fd442783          	lw	a5,-44(s0)
   10e94:	00078713          	mv	a4,a5
   10e98:	fbc42783          	lw	a5,-68(s0)
   10e9c:	0007071b          	sext.w	a4,a4
   10ea0:	0007879b          	sext.w	a5,a5
   10ea4:	02f75663          	bge	a4,a5,10ed0 <strtol+0x224>
   10ea8:	fbc42703          	lw	a4,-68(s0)
   10eac:	fe843783          	ld	a5,-24(s0)
   10eb0:	02f70733          	mul	a4,a4,a5
   10eb4:	fd442783          	lw	a5,-44(s0)
   10eb8:	00f707b3          	add	a5,a4,a5
   10ebc:	fef43423          	sd	a5,-24(s0)
   10ec0:	fd843783          	ld	a5,-40(s0)
   10ec4:	00178793          	addi	a5,a5,1
   10ec8:	fcf43c23          	sd	a5,-40(s0)
   10ecc:	f09ff06f          	j	10dd4 <strtol+0x128>
   10ed0:	00000013          	nop
   10ed4:	fc043783          	ld	a5,-64(s0)
   10ed8:	00078863          	beqz	a5,10ee8 <strtol+0x23c>
   10edc:	fc043783          	ld	a5,-64(s0)
   10ee0:	fd843703          	ld	a4,-40(s0)
   10ee4:	00e7b023          	sd	a4,0(a5)
   10ee8:	fe744783          	lbu	a5,-25(s0)
   10eec:	0ff7f793          	zext.b	a5,a5
   10ef0:	00078863          	beqz	a5,10f00 <strtol+0x254>
   10ef4:	fe843783          	ld	a5,-24(s0)
   10ef8:	40f007b3          	neg	a5,a5
   10efc:	0080006f          	j	10f04 <strtol+0x258>
   10f00:	fe843783          	ld	a5,-24(s0)
   10f04:	00078513          	mv	a0,a5
   10f08:	04813083          	ld	ra,72(sp)
   10f0c:	04013403          	ld	s0,64(sp)
   10f10:	05010113          	addi	sp,sp,80
   10f14:	00008067          	ret

0000000000010f18 <puts_wo_nl>:
   10f18:	fd010113          	addi	sp,sp,-48
   10f1c:	02113423          	sd	ra,40(sp)
   10f20:	02813023          	sd	s0,32(sp)
   10f24:	03010413          	addi	s0,sp,48
   10f28:	fca43c23          	sd	a0,-40(s0)
   10f2c:	fcb43823          	sd	a1,-48(s0)
   10f30:	fd043783          	ld	a5,-48(s0)
   10f34:	00079863          	bnez	a5,10f44 <puts_wo_nl+0x2c>
   10f38:	00001797          	auipc	a5,0x1
   10f3c:	01878793          	addi	a5,a5,24 # 11f50 <lseek+0xf8>
   10f40:	fcf43823          	sd	a5,-48(s0)
   10f44:	fd043783          	ld	a5,-48(s0)
   10f48:	fef43423          	sd	a5,-24(s0)
   10f4c:	0240006f          	j	10f70 <puts_wo_nl+0x58>
   10f50:	fe843783          	ld	a5,-24(s0)
   10f54:	00178713          	addi	a4,a5,1
   10f58:	fee43423          	sd	a4,-24(s0)
   10f5c:	0007c783          	lbu	a5,0(a5)
   10f60:	0007871b          	sext.w	a4,a5
   10f64:	fd843783          	ld	a5,-40(s0)
   10f68:	00070513          	mv	a0,a4
   10f6c:	000780e7          	jalr	a5
   10f70:	fe843783          	ld	a5,-24(s0)
   10f74:	0007c783          	lbu	a5,0(a5)
   10f78:	fc079ce3          	bnez	a5,10f50 <puts_wo_nl+0x38>
   10f7c:	fe843703          	ld	a4,-24(s0)
   10f80:	fd043783          	ld	a5,-48(s0)
   10f84:	40f707b3          	sub	a5,a4,a5
   10f88:	0007879b          	sext.w	a5,a5
   10f8c:	00078513          	mv	a0,a5
   10f90:	02813083          	ld	ra,40(sp)
   10f94:	02013403          	ld	s0,32(sp)
   10f98:	03010113          	addi	sp,sp,48
   10f9c:	00008067          	ret

0000000000010fa0 <print_dec_int>:
   10fa0:	f9010113          	addi	sp,sp,-112
   10fa4:	06113423          	sd	ra,104(sp)
   10fa8:	06813023          	sd	s0,96(sp)
   10fac:	07010413          	addi	s0,sp,112
   10fb0:	faa43423          	sd	a0,-88(s0)
   10fb4:	fab43023          	sd	a1,-96(s0)
   10fb8:	00060793          	mv	a5,a2
   10fbc:	f8d43823          	sd	a3,-112(s0)
   10fc0:	f8f40fa3          	sb	a5,-97(s0)
   10fc4:	f9f44783          	lbu	a5,-97(s0)
   10fc8:	0ff7f793          	zext.b	a5,a5
   10fcc:	02078663          	beqz	a5,10ff8 <print_dec_int+0x58>
   10fd0:	fa043703          	ld	a4,-96(s0)
   10fd4:	fff00793          	li	a5,-1
   10fd8:	03f79793          	slli	a5,a5,0x3f
   10fdc:	00f71e63          	bne	a4,a5,10ff8 <print_dec_int+0x58>
   10fe0:	00001597          	auipc	a1,0x1
   10fe4:	f7858593          	addi	a1,a1,-136 # 11f58 <lseek+0x100>
   10fe8:	fa843503          	ld	a0,-88(s0)
   10fec:	f2dff0ef          	jal	10f18 <puts_wo_nl>
   10ff0:	00050793          	mv	a5,a0
   10ff4:	2a00006f          	j	11294 <print_dec_int+0x2f4>
   10ff8:	f9043783          	ld	a5,-112(s0)
   10ffc:	00c7a783          	lw	a5,12(a5)
   11000:	00079a63          	bnez	a5,11014 <print_dec_int+0x74>
   11004:	fa043783          	ld	a5,-96(s0)
   11008:	00079663          	bnez	a5,11014 <print_dec_int+0x74>
   1100c:	00000793          	li	a5,0
   11010:	2840006f          	j	11294 <print_dec_int+0x2f4>
   11014:	fe0407a3          	sb	zero,-17(s0)
   11018:	f9f44783          	lbu	a5,-97(s0)
   1101c:	0ff7f793          	zext.b	a5,a5
   11020:	02078063          	beqz	a5,11040 <print_dec_int+0xa0>
   11024:	fa043783          	ld	a5,-96(s0)
   11028:	0007dc63          	bgez	a5,11040 <print_dec_int+0xa0>
   1102c:	00100793          	li	a5,1
   11030:	fef407a3          	sb	a5,-17(s0)
   11034:	fa043783          	ld	a5,-96(s0)
   11038:	40f007b3          	neg	a5,a5
   1103c:	faf43023          	sd	a5,-96(s0)
   11040:	fe042423          	sw	zero,-24(s0)
   11044:	f9f44783          	lbu	a5,-97(s0)
   11048:	0ff7f793          	zext.b	a5,a5
   1104c:	02078863          	beqz	a5,1107c <print_dec_int+0xdc>
   11050:	fef44783          	lbu	a5,-17(s0)
   11054:	0ff7f793          	zext.b	a5,a5
   11058:	00079e63          	bnez	a5,11074 <print_dec_int+0xd4>
   1105c:	f9043783          	ld	a5,-112(s0)
   11060:	0057c783          	lbu	a5,5(a5)
   11064:	00079863          	bnez	a5,11074 <print_dec_int+0xd4>
   11068:	f9043783          	ld	a5,-112(s0)
   1106c:	0047c783          	lbu	a5,4(a5)
   11070:	00078663          	beqz	a5,1107c <print_dec_int+0xdc>
   11074:	00100793          	li	a5,1
   11078:	0080006f          	j	11080 <print_dec_int+0xe0>
   1107c:	00000793          	li	a5,0
   11080:	fcf40ba3          	sb	a5,-41(s0)
   11084:	fd744783          	lbu	a5,-41(s0)
   11088:	0017f793          	andi	a5,a5,1
   1108c:	fcf40ba3          	sb	a5,-41(s0)
   11090:	fa043703          	ld	a4,-96(s0)
   11094:	00a00793          	li	a5,10
   11098:	02f777b3          	remu	a5,a4,a5
   1109c:	0ff7f713          	zext.b	a4,a5
   110a0:	fe842783          	lw	a5,-24(s0)
   110a4:	0017869b          	addiw	a3,a5,1
   110a8:	fed42423          	sw	a3,-24(s0)
   110ac:	0307071b          	addiw	a4,a4,48
   110b0:	0ff77713          	zext.b	a4,a4
   110b4:	ff078793          	addi	a5,a5,-16
   110b8:	008787b3          	add	a5,a5,s0
   110bc:	fce78423          	sb	a4,-56(a5)
   110c0:	fa043703          	ld	a4,-96(s0)
   110c4:	00a00793          	li	a5,10
   110c8:	02f757b3          	divu	a5,a4,a5
   110cc:	faf43023          	sd	a5,-96(s0)
   110d0:	fa043783          	ld	a5,-96(s0)
   110d4:	fa079ee3          	bnez	a5,11090 <print_dec_int+0xf0>
   110d8:	f9043783          	ld	a5,-112(s0)
   110dc:	00c7a783          	lw	a5,12(a5)
   110e0:	00078713          	mv	a4,a5
   110e4:	fff00793          	li	a5,-1
   110e8:	02f71063          	bne	a4,a5,11108 <print_dec_int+0x168>
   110ec:	f9043783          	ld	a5,-112(s0)
   110f0:	0037c783          	lbu	a5,3(a5)
   110f4:	00078a63          	beqz	a5,11108 <print_dec_int+0x168>
   110f8:	f9043783          	ld	a5,-112(s0)
   110fc:	0087a703          	lw	a4,8(a5)
   11100:	f9043783          	ld	a5,-112(s0)
   11104:	00e7a623          	sw	a4,12(a5)
   11108:	fe042223          	sw	zero,-28(s0)
   1110c:	f9043783          	ld	a5,-112(s0)
   11110:	0087a703          	lw	a4,8(a5)
   11114:	fe842783          	lw	a5,-24(s0)
   11118:	fcf42823          	sw	a5,-48(s0)
   1111c:	f9043783          	ld	a5,-112(s0)
   11120:	00c7a783          	lw	a5,12(a5)
   11124:	fcf42623          	sw	a5,-52(s0)
   11128:	fd042783          	lw	a5,-48(s0)
   1112c:	00078593          	mv	a1,a5
   11130:	fcc42783          	lw	a5,-52(s0)
   11134:	00078613          	mv	a2,a5
   11138:	0006069b          	sext.w	a3,a2
   1113c:	0005879b          	sext.w	a5,a1
   11140:	00f6d463          	bge	a3,a5,11148 <print_dec_int+0x1a8>
   11144:	00058613          	mv	a2,a1
   11148:	0006079b          	sext.w	a5,a2
   1114c:	40f707bb          	subw	a5,a4,a5
   11150:	0007871b          	sext.w	a4,a5
   11154:	fd744783          	lbu	a5,-41(s0)
   11158:	0007879b          	sext.w	a5,a5
   1115c:	40f707bb          	subw	a5,a4,a5
   11160:	fef42023          	sw	a5,-32(s0)
   11164:	0280006f          	j	1118c <print_dec_int+0x1ec>
   11168:	fa843783          	ld	a5,-88(s0)
   1116c:	02000513          	li	a0,32
   11170:	000780e7          	jalr	a5
   11174:	fe442783          	lw	a5,-28(s0)
   11178:	0017879b          	addiw	a5,a5,1
   1117c:	fef42223          	sw	a5,-28(s0)
   11180:	fe042783          	lw	a5,-32(s0)
   11184:	fff7879b          	addiw	a5,a5,-1
   11188:	fef42023          	sw	a5,-32(s0)
   1118c:	fe042783          	lw	a5,-32(s0)
   11190:	0007879b          	sext.w	a5,a5
   11194:	fcf04ae3          	bgtz	a5,11168 <print_dec_int+0x1c8>
   11198:	fd744783          	lbu	a5,-41(s0)
   1119c:	0ff7f793          	zext.b	a5,a5
   111a0:	04078463          	beqz	a5,111e8 <print_dec_int+0x248>
   111a4:	fef44783          	lbu	a5,-17(s0)
   111a8:	0ff7f793          	zext.b	a5,a5
   111ac:	00078663          	beqz	a5,111b8 <print_dec_int+0x218>
   111b0:	02d00793          	li	a5,45
   111b4:	01c0006f          	j	111d0 <print_dec_int+0x230>
   111b8:	f9043783          	ld	a5,-112(s0)
   111bc:	0057c783          	lbu	a5,5(a5)
   111c0:	00078663          	beqz	a5,111cc <print_dec_int+0x22c>
   111c4:	02b00793          	li	a5,43
   111c8:	0080006f          	j	111d0 <print_dec_int+0x230>
   111cc:	02000793          	li	a5,32
   111d0:	fa843703          	ld	a4,-88(s0)
   111d4:	00078513          	mv	a0,a5
   111d8:	000700e7          	jalr	a4
   111dc:	fe442783          	lw	a5,-28(s0)
   111e0:	0017879b          	addiw	a5,a5,1
   111e4:	fef42223          	sw	a5,-28(s0)
   111e8:	fe842783          	lw	a5,-24(s0)
   111ec:	fcf42e23          	sw	a5,-36(s0)
   111f0:	0280006f          	j	11218 <print_dec_int+0x278>
   111f4:	fa843783          	ld	a5,-88(s0)
   111f8:	03000513          	li	a0,48
   111fc:	000780e7          	jalr	a5
   11200:	fe442783          	lw	a5,-28(s0)
   11204:	0017879b          	addiw	a5,a5,1
   11208:	fef42223          	sw	a5,-28(s0)
   1120c:	fdc42783          	lw	a5,-36(s0)
   11210:	0017879b          	addiw	a5,a5,1
   11214:	fcf42e23          	sw	a5,-36(s0)
   11218:	f9043783          	ld	a5,-112(s0)
   1121c:	00c7a703          	lw	a4,12(a5)
   11220:	fd744783          	lbu	a5,-41(s0)
   11224:	0007879b          	sext.w	a5,a5
   11228:	40f707bb          	subw	a5,a4,a5
   1122c:	0007871b          	sext.w	a4,a5
   11230:	fdc42783          	lw	a5,-36(s0)
   11234:	0007879b          	sext.w	a5,a5
   11238:	fae7cee3          	blt	a5,a4,111f4 <print_dec_int+0x254>
   1123c:	fe842783          	lw	a5,-24(s0)
   11240:	fff7879b          	addiw	a5,a5,-1
   11244:	fcf42c23          	sw	a5,-40(s0)
   11248:	03c0006f          	j	11284 <print_dec_int+0x2e4>
   1124c:	fd842783          	lw	a5,-40(s0)
   11250:	ff078793          	addi	a5,a5,-16
   11254:	008787b3          	add	a5,a5,s0
   11258:	fc87c783          	lbu	a5,-56(a5)
   1125c:	0007871b          	sext.w	a4,a5
   11260:	fa843783          	ld	a5,-88(s0)
   11264:	00070513          	mv	a0,a4
   11268:	000780e7          	jalr	a5
   1126c:	fe442783          	lw	a5,-28(s0)
   11270:	0017879b          	addiw	a5,a5,1
   11274:	fef42223          	sw	a5,-28(s0)
   11278:	fd842783          	lw	a5,-40(s0)
   1127c:	fff7879b          	addiw	a5,a5,-1
   11280:	fcf42c23          	sw	a5,-40(s0)
   11284:	fd842783          	lw	a5,-40(s0)
   11288:	0007879b          	sext.w	a5,a5
   1128c:	fc07d0e3          	bgez	a5,1124c <print_dec_int+0x2ac>
   11290:	fe442783          	lw	a5,-28(s0)
   11294:	00078513          	mv	a0,a5
   11298:	06813083          	ld	ra,104(sp)
   1129c:	06013403          	ld	s0,96(sp)
   112a0:	07010113          	addi	sp,sp,112
   112a4:	00008067          	ret

00000000000112a8 <vprintfmt>:
   112a8:	f4010113          	addi	sp,sp,-192
   112ac:	0a113c23          	sd	ra,184(sp)
   112b0:	0a813823          	sd	s0,176(sp)
   112b4:	0c010413          	addi	s0,sp,192
   112b8:	f4a43c23          	sd	a0,-168(s0)
   112bc:	f4b43823          	sd	a1,-176(s0)
   112c0:	f4c43423          	sd	a2,-184(s0)
   112c4:	f8043023          	sd	zero,-128(s0)
   112c8:	f8043423          	sd	zero,-120(s0)
   112cc:	fe042623          	sw	zero,-20(s0)
   112d0:	7a40006f          	j	11a74 <vprintfmt+0x7cc>
   112d4:	f8044783          	lbu	a5,-128(s0)
   112d8:	72078e63          	beqz	a5,11a14 <vprintfmt+0x76c>
   112dc:	f5043783          	ld	a5,-176(s0)
   112e0:	0007c783          	lbu	a5,0(a5)
   112e4:	00078713          	mv	a4,a5
   112e8:	02300793          	li	a5,35
   112ec:	00f71863          	bne	a4,a5,112fc <vprintfmt+0x54>
   112f0:	00100793          	li	a5,1
   112f4:	f8f40123          	sb	a5,-126(s0)
   112f8:	7700006f          	j	11a68 <vprintfmt+0x7c0>
   112fc:	f5043783          	ld	a5,-176(s0)
   11300:	0007c783          	lbu	a5,0(a5)
   11304:	00078713          	mv	a4,a5
   11308:	03000793          	li	a5,48
   1130c:	00f71863          	bne	a4,a5,1131c <vprintfmt+0x74>
   11310:	00100793          	li	a5,1
   11314:	f8f401a3          	sb	a5,-125(s0)
   11318:	7500006f          	j	11a68 <vprintfmt+0x7c0>
   1131c:	f5043783          	ld	a5,-176(s0)
   11320:	0007c783          	lbu	a5,0(a5)
   11324:	00078713          	mv	a4,a5
   11328:	06c00793          	li	a5,108
   1132c:	04f70063          	beq	a4,a5,1136c <vprintfmt+0xc4>
   11330:	f5043783          	ld	a5,-176(s0)
   11334:	0007c783          	lbu	a5,0(a5)
   11338:	00078713          	mv	a4,a5
   1133c:	07a00793          	li	a5,122
   11340:	02f70663          	beq	a4,a5,1136c <vprintfmt+0xc4>
   11344:	f5043783          	ld	a5,-176(s0)
   11348:	0007c783          	lbu	a5,0(a5)
   1134c:	00078713          	mv	a4,a5
   11350:	07400793          	li	a5,116
   11354:	00f70c63          	beq	a4,a5,1136c <vprintfmt+0xc4>
   11358:	f5043783          	ld	a5,-176(s0)
   1135c:	0007c783          	lbu	a5,0(a5)
   11360:	00078713          	mv	a4,a5
   11364:	06a00793          	li	a5,106
   11368:	00f71863          	bne	a4,a5,11378 <vprintfmt+0xd0>
   1136c:	00100793          	li	a5,1
   11370:	f8f400a3          	sb	a5,-127(s0)
   11374:	6f40006f          	j	11a68 <vprintfmt+0x7c0>
   11378:	f5043783          	ld	a5,-176(s0)
   1137c:	0007c783          	lbu	a5,0(a5)
   11380:	00078713          	mv	a4,a5
   11384:	02b00793          	li	a5,43
   11388:	00f71863          	bne	a4,a5,11398 <vprintfmt+0xf0>
   1138c:	00100793          	li	a5,1
   11390:	f8f402a3          	sb	a5,-123(s0)
   11394:	6d40006f          	j	11a68 <vprintfmt+0x7c0>
   11398:	f5043783          	ld	a5,-176(s0)
   1139c:	0007c783          	lbu	a5,0(a5)
   113a0:	00078713          	mv	a4,a5
   113a4:	02000793          	li	a5,32
   113a8:	00f71863          	bne	a4,a5,113b8 <vprintfmt+0x110>
   113ac:	00100793          	li	a5,1
   113b0:	f8f40223          	sb	a5,-124(s0)
   113b4:	6b40006f          	j	11a68 <vprintfmt+0x7c0>
   113b8:	f5043783          	ld	a5,-176(s0)
   113bc:	0007c783          	lbu	a5,0(a5)
   113c0:	00078713          	mv	a4,a5
   113c4:	02a00793          	li	a5,42
   113c8:	00f71e63          	bne	a4,a5,113e4 <vprintfmt+0x13c>
   113cc:	f4843783          	ld	a5,-184(s0)
   113d0:	00878713          	addi	a4,a5,8
   113d4:	f4e43423          	sd	a4,-184(s0)
   113d8:	0007a783          	lw	a5,0(a5)
   113dc:	f8f42423          	sw	a5,-120(s0)
   113e0:	6880006f          	j	11a68 <vprintfmt+0x7c0>
   113e4:	f5043783          	ld	a5,-176(s0)
   113e8:	0007c783          	lbu	a5,0(a5)
   113ec:	00078713          	mv	a4,a5
   113f0:	03000793          	li	a5,48
   113f4:	04e7f663          	bgeu	a5,a4,11440 <vprintfmt+0x198>
   113f8:	f5043783          	ld	a5,-176(s0)
   113fc:	0007c783          	lbu	a5,0(a5)
   11400:	00078713          	mv	a4,a5
   11404:	03900793          	li	a5,57
   11408:	02e7ec63          	bltu	a5,a4,11440 <vprintfmt+0x198>
   1140c:	f5043783          	ld	a5,-176(s0)
   11410:	f5040713          	addi	a4,s0,-176
   11414:	00a00613          	li	a2,10
   11418:	00070593          	mv	a1,a4
   1141c:	00078513          	mv	a0,a5
   11420:	88dff0ef          	jal	10cac <strtol>
   11424:	00050793          	mv	a5,a0
   11428:	0007879b          	sext.w	a5,a5
   1142c:	f8f42423          	sw	a5,-120(s0)
   11430:	f5043783          	ld	a5,-176(s0)
   11434:	fff78793          	addi	a5,a5,-1
   11438:	f4f43823          	sd	a5,-176(s0)
   1143c:	62c0006f          	j	11a68 <vprintfmt+0x7c0>
   11440:	f5043783          	ld	a5,-176(s0)
   11444:	0007c783          	lbu	a5,0(a5)
   11448:	00078713          	mv	a4,a5
   1144c:	02e00793          	li	a5,46
   11450:	06f71863          	bne	a4,a5,114c0 <vprintfmt+0x218>
   11454:	f5043783          	ld	a5,-176(s0)
   11458:	00178793          	addi	a5,a5,1
   1145c:	f4f43823          	sd	a5,-176(s0)
   11460:	f5043783          	ld	a5,-176(s0)
   11464:	0007c783          	lbu	a5,0(a5)
   11468:	00078713          	mv	a4,a5
   1146c:	02a00793          	li	a5,42
   11470:	00f71e63          	bne	a4,a5,1148c <vprintfmt+0x1e4>
   11474:	f4843783          	ld	a5,-184(s0)
   11478:	00878713          	addi	a4,a5,8
   1147c:	f4e43423          	sd	a4,-184(s0)
   11480:	0007a783          	lw	a5,0(a5)
   11484:	f8f42623          	sw	a5,-116(s0)
   11488:	5e00006f          	j	11a68 <vprintfmt+0x7c0>
   1148c:	f5043783          	ld	a5,-176(s0)
   11490:	f5040713          	addi	a4,s0,-176
   11494:	00a00613          	li	a2,10
   11498:	00070593          	mv	a1,a4
   1149c:	00078513          	mv	a0,a5
   114a0:	80dff0ef          	jal	10cac <strtol>
   114a4:	00050793          	mv	a5,a0
   114a8:	0007879b          	sext.w	a5,a5
   114ac:	f8f42623          	sw	a5,-116(s0)
   114b0:	f5043783          	ld	a5,-176(s0)
   114b4:	fff78793          	addi	a5,a5,-1
   114b8:	f4f43823          	sd	a5,-176(s0)
   114bc:	5ac0006f          	j	11a68 <vprintfmt+0x7c0>
   114c0:	f5043783          	ld	a5,-176(s0)
   114c4:	0007c783          	lbu	a5,0(a5)
   114c8:	00078713          	mv	a4,a5
   114cc:	07800793          	li	a5,120
   114d0:	02f70663          	beq	a4,a5,114fc <vprintfmt+0x254>
   114d4:	f5043783          	ld	a5,-176(s0)
   114d8:	0007c783          	lbu	a5,0(a5)
   114dc:	00078713          	mv	a4,a5
   114e0:	05800793          	li	a5,88
   114e4:	00f70c63          	beq	a4,a5,114fc <vprintfmt+0x254>
   114e8:	f5043783          	ld	a5,-176(s0)
   114ec:	0007c783          	lbu	a5,0(a5)
   114f0:	00078713          	mv	a4,a5
   114f4:	07000793          	li	a5,112
   114f8:	30f71263          	bne	a4,a5,117fc <vprintfmt+0x554>
   114fc:	f5043783          	ld	a5,-176(s0)
   11500:	0007c783          	lbu	a5,0(a5)
   11504:	00078713          	mv	a4,a5
   11508:	07000793          	li	a5,112
   1150c:	00f70663          	beq	a4,a5,11518 <vprintfmt+0x270>
   11510:	f8144783          	lbu	a5,-127(s0)
   11514:	00078663          	beqz	a5,11520 <vprintfmt+0x278>
   11518:	00100793          	li	a5,1
   1151c:	0080006f          	j	11524 <vprintfmt+0x27c>
   11520:	00000793          	li	a5,0
   11524:	faf403a3          	sb	a5,-89(s0)
   11528:	fa744783          	lbu	a5,-89(s0)
   1152c:	0017f793          	andi	a5,a5,1
   11530:	faf403a3          	sb	a5,-89(s0)
   11534:	fa744783          	lbu	a5,-89(s0)
   11538:	0ff7f793          	zext.b	a5,a5
   1153c:	00078c63          	beqz	a5,11554 <vprintfmt+0x2ac>
   11540:	f4843783          	ld	a5,-184(s0)
   11544:	00878713          	addi	a4,a5,8
   11548:	f4e43423          	sd	a4,-184(s0)
   1154c:	0007b783          	ld	a5,0(a5)
   11550:	01c0006f          	j	1156c <vprintfmt+0x2c4>
   11554:	f4843783          	ld	a5,-184(s0)
   11558:	00878713          	addi	a4,a5,8
   1155c:	f4e43423          	sd	a4,-184(s0)
   11560:	0007a783          	lw	a5,0(a5)
   11564:	02079793          	slli	a5,a5,0x20
   11568:	0207d793          	srli	a5,a5,0x20
   1156c:	fef43023          	sd	a5,-32(s0)
   11570:	f8c42783          	lw	a5,-116(s0)
   11574:	02079463          	bnez	a5,1159c <vprintfmt+0x2f4>
   11578:	fe043783          	ld	a5,-32(s0)
   1157c:	02079063          	bnez	a5,1159c <vprintfmt+0x2f4>
   11580:	f5043783          	ld	a5,-176(s0)
   11584:	0007c783          	lbu	a5,0(a5)
   11588:	00078713          	mv	a4,a5
   1158c:	07000793          	li	a5,112
   11590:	00f70663          	beq	a4,a5,1159c <vprintfmt+0x2f4>
   11594:	f8040023          	sb	zero,-128(s0)
   11598:	4d00006f          	j	11a68 <vprintfmt+0x7c0>
   1159c:	f5043783          	ld	a5,-176(s0)
   115a0:	0007c783          	lbu	a5,0(a5)
   115a4:	00078713          	mv	a4,a5
   115a8:	07000793          	li	a5,112
   115ac:	00f70a63          	beq	a4,a5,115c0 <vprintfmt+0x318>
   115b0:	f8244783          	lbu	a5,-126(s0)
   115b4:	00078a63          	beqz	a5,115c8 <vprintfmt+0x320>
   115b8:	fe043783          	ld	a5,-32(s0)
   115bc:	00078663          	beqz	a5,115c8 <vprintfmt+0x320>
   115c0:	00100793          	li	a5,1
   115c4:	0080006f          	j	115cc <vprintfmt+0x324>
   115c8:	00000793          	li	a5,0
   115cc:	faf40323          	sb	a5,-90(s0)
   115d0:	fa644783          	lbu	a5,-90(s0)
   115d4:	0017f793          	andi	a5,a5,1
   115d8:	faf40323          	sb	a5,-90(s0)
   115dc:	fc042e23          	sw	zero,-36(s0)
   115e0:	f5043783          	ld	a5,-176(s0)
   115e4:	0007c783          	lbu	a5,0(a5)
   115e8:	00078713          	mv	a4,a5
   115ec:	05800793          	li	a5,88
   115f0:	00f71863          	bne	a4,a5,11600 <vprintfmt+0x358>
   115f4:	00001797          	auipc	a5,0x1
   115f8:	97c78793          	addi	a5,a5,-1668 # 11f70 <upperxdigits.1>
   115fc:	00c0006f          	j	11608 <vprintfmt+0x360>
   11600:	00001797          	auipc	a5,0x1
   11604:	98878793          	addi	a5,a5,-1656 # 11f88 <lowerxdigits.0>
   11608:	f8f43c23          	sd	a5,-104(s0)
   1160c:	fe043783          	ld	a5,-32(s0)
   11610:	00f7f793          	andi	a5,a5,15
   11614:	f9843703          	ld	a4,-104(s0)
   11618:	00f70733          	add	a4,a4,a5
   1161c:	fdc42783          	lw	a5,-36(s0)
   11620:	0017869b          	addiw	a3,a5,1
   11624:	fcd42e23          	sw	a3,-36(s0)
   11628:	00074703          	lbu	a4,0(a4)
   1162c:	ff078793          	addi	a5,a5,-16
   11630:	008787b3          	add	a5,a5,s0
   11634:	f8e78023          	sb	a4,-128(a5)
   11638:	fe043783          	ld	a5,-32(s0)
   1163c:	0047d793          	srli	a5,a5,0x4
   11640:	fef43023          	sd	a5,-32(s0)
   11644:	fe043783          	ld	a5,-32(s0)
   11648:	fc0792e3          	bnez	a5,1160c <vprintfmt+0x364>
   1164c:	f8c42783          	lw	a5,-116(s0)
   11650:	00078713          	mv	a4,a5
   11654:	fff00793          	li	a5,-1
   11658:	02f71663          	bne	a4,a5,11684 <vprintfmt+0x3dc>
   1165c:	f8344783          	lbu	a5,-125(s0)
   11660:	02078263          	beqz	a5,11684 <vprintfmt+0x3dc>
   11664:	f8842703          	lw	a4,-120(s0)
   11668:	fa644783          	lbu	a5,-90(s0)
   1166c:	0007879b          	sext.w	a5,a5
   11670:	0017979b          	slliw	a5,a5,0x1
   11674:	0007879b          	sext.w	a5,a5
   11678:	40f707bb          	subw	a5,a4,a5
   1167c:	0007879b          	sext.w	a5,a5
   11680:	f8f42623          	sw	a5,-116(s0)
   11684:	f8842703          	lw	a4,-120(s0)
   11688:	fa644783          	lbu	a5,-90(s0)
   1168c:	0007879b          	sext.w	a5,a5
   11690:	0017979b          	slliw	a5,a5,0x1
   11694:	0007879b          	sext.w	a5,a5
   11698:	40f707bb          	subw	a5,a4,a5
   1169c:	0007871b          	sext.w	a4,a5
   116a0:	fdc42783          	lw	a5,-36(s0)
   116a4:	f8f42a23          	sw	a5,-108(s0)
   116a8:	f8c42783          	lw	a5,-116(s0)
   116ac:	f8f42823          	sw	a5,-112(s0)
   116b0:	f9442783          	lw	a5,-108(s0)
   116b4:	00078593          	mv	a1,a5
   116b8:	f9042783          	lw	a5,-112(s0)
   116bc:	00078613          	mv	a2,a5
   116c0:	0006069b          	sext.w	a3,a2
   116c4:	0005879b          	sext.w	a5,a1
   116c8:	00f6d463          	bge	a3,a5,116d0 <vprintfmt+0x428>
   116cc:	00058613          	mv	a2,a1
   116d0:	0006079b          	sext.w	a5,a2
   116d4:	40f707bb          	subw	a5,a4,a5
   116d8:	fcf42c23          	sw	a5,-40(s0)
   116dc:	0280006f          	j	11704 <vprintfmt+0x45c>
   116e0:	f5843783          	ld	a5,-168(s0)
   116e4:	02000513          	li	a0,32
   116e8:	000780e7          	jalr	a5
   116ec:	fec42783          	lw	a5,-20(s0)
   116f0:	0017879b          	addiw	a5,a5,1
   116f4:	fef42623          	sw	a5,-20(s0)
   116f8:	fd842783          	lw	a5,-40(s0)
   116fc:	fff7879b          	addiw	a5,a5,-1
   11700:	fcf42c23          	sw	a5,-40(s0)
   11704:	fd842783          	lw	a5,-40(s0)
   11708:	0007879b          	sext.w	a5,a5
   1170c:	fcf04ae3          	bgtz	a5,116e0 <vprintfmt+0x438>
   11710:	fa644783          	lbu	a5,-90(s0)
   11714:	0ff7f793          	zext.b	a5,a5
   11718:	04078463          	beqz	a5,11760 <vprintfmt+0x4b8>
   1171c:	f5843783          	ld	a5,-168(s0)
   11720:	03000513          	li	a0,48
   11724:	000780e7          	jalr	a5
   11728:	f5043783          	ld	a5,-176(s0)
   1172c:	0007c783          	lbu	a5,0(a5)
   11730:	00078713          	mv	a4,a5
   11734:	05800793          	li	a5,88
   11738:	00f71663          	bne	a4,a5,11744 <vprintfmt+0x49c>
   1173c:	05800793          	li	a5,88
   11740:	0080006f          	j	11748 <vprintfmt+0x4a0>
   11744:	07800793          	li	a5,120
   11748:	f5843703          	ld	a4,-168(s0)
   1174c:	00078513          	mv	a0,a5
   11750:	000700e7          	jalr	a4
   11754:	fec42783          	lw	a5,-20(s0)
   11758:	0027879b          	addiw	a5,a5,2
   1175c:	fef42623          	sw	a5,-20(s0)
   11760:	fdc42783          	lw	a5,-36(s0)
   11764:	fcf42a23          	sw	a5,-44(s0)
   11768:	0280006f          	j	11790 <vprintfmt+0x4e8>
   1176c:	f5843783          	ld	a5,-168(s0)
   11770:	03000513          	li	a0,48
   11774:	000780e7          	jalr	a5
   11778:	fec42783          	lw	a5,-20(s0)
   1177c:	0017879b          	addiw	a5,a5,1
   11780:	fef42623          	sw	a5,-20(s0)
   11784:	fd442783          	lw	a5,-44(s0)
   11788:	0017879b          	addiw	a5,a5,1
   1178c:	fcf42a23          	sw	a5,-44(s0)
   11790:	f8c42703          	lw	a4,-116(s0)
   11794:	fd442783          	lw	a5,-44(s0)
   11798:	0007879b          	sext.w	a5,a5
   1179c:	fce7c8e3          	blt	a5,a4,1176c <vprintfmt+0x4c4>
   117a0:	fdc42783          	lw	a5,-36(s0)
   117a4:	fff7879b          	addiw	a5,a5,-1
   117a8:	fcf42823          	sw	a5,-48(s0)
   117ac:	03c0006f          	j	117e8 <vprintfmt+0x540>
   117b0:	fd042783          	lw	a5,-48(s0)
   117b4:	ff078793          	addi	a5,a5,-16
   117b8:	008787b3          	add	a5,a5,s0
   117bc:	f807c783          	lbu	a5,-128(a5)
   117c0:	0007871b          	sext.w	a4,a5
   117c4:	f5843783          	ld	a5,-168(s0)
   117c8:	00070513          	mv	a0,a4
   117cc:	000780e7          	jalr	a5
   117d0:	fec42783          	lw	a5,-20(s0)
   117d4:	0017879b          	addiw	a5,a5,1
   117d8:	fef42623          	sw	a5,-20(s0)
   117dc:	fd042783          	lw	a5,-48(s0)
   117e0:	fff7879b          	addiw	a5,a5,-1
   117e4:	fcf42823          	sw	a5,-48(s0)
   117e8:	fd042783          	lw	a5,-48(s0)
   117ec:	0007879b          	sext.w	a5,a5
   117f0:	fc07d0e3          	bgez	a5,117b0 <vprintfmt+0x508>
   117f4:	f8040023          	sb	zero,-128(s0)
   117f8:	2700006f          	j	11a68 <vprintfmt+0x7c0>
   117fc:	f5043783          	ld	a5,-176(s0)
   11800:	0007c783          	lbu	a5,0(a5)
   11804:	00078713          	mv	a4,a5
   11808:	06400793          	li	a5,100
   1180c:	02f70663          	beq	a4,a5,11838 <vprintfmt+0x590>
   11810:	f5043783          	ld	a5,-176(s0)
   11814:	0007c783          	lbu	a5,0(a5)
   11818:	00078713          	mv	a4,a5
   1181c:	06900793          	li	a5,105
   11820:	00f70c63          	beq	a4,a5,11838 <vprintfmt+0x590>
   11824:	f5043783          	ld	a5,-176(s0)
   11828:	0007c783          	lbu	a5,0(a5)
   1182c:	00078713          	mv	a4,a5
   11830:	07500793          	li	a5,117
   11834:	08f71063          	bne	a4,a5,118b4 <vprintfmt+0x60c>
   11838:	f8144783          	lbu	a5,-127(s0)
   1183c:	00078c63          	beqz	a5,11854 <vprintfmt+0x5ac>
   11840:	f4843783          	ld	a5,-184(s0)
   11844:	00878713          	addi	a4,a5,8
   11848:	f4e43423          	sd	a4,-184(s0)
   1184c:	0007b783          	ld	a5,0(a5)
   11850:	0140006f          	j	11864 <vprintfmt+0x5bc>
   11854:	f4843783          	ld	a5,-184(s0)
   11858:	00878713          	addi	a4,a5,8
   1185c:	f4e43423          	sd	a4,-184(s0)
   11860:	0007a783          	lw	a5,0(a5)
   11864:	faf43423          	sd	a5,-88(s0)
   11868:	fa843583          	ld	a1,-88(s0)
   1186c:	f5043783          	ld	a5,-176(s0)
   11870:	0007c783          	lbu	a5,0(a5)
   11874:	0007871b          	sext.w	a4,a5
   11878:	07500793          	li	a5,117
   1187c:	40f707b3          	sub	a5,a4,a5
   11880:	00f037b3          	snez	a5,a5
   11884:	0ff7f793          	zext.b	a5,a5
   11888:	f8040713          	addi	a4,s0,-128
   1188c:	00070693          	mv	a3,a4
   11890:	00078613          	mv	a2,a5
   11894:	f5843503          	ld	a0,-168(s0)
   11898:	f08ff0ef          	jal	10fa0 <print_dec_int>
   1189c:	00050793          	mv	a5,a0
   118a0:	fec42703          	lw	a4,-20(s0)
   118a4:	00f707bb          	addw	a5,a4,a5
   118a8:	fef42623          	sw	a5,-20(s0)
   118ac:	f8040023          	sb	zero,-128(s0)
   118b0:	1b80006f          	j	11a68 <vprintfmt+0x7c0>
   118b4:	f5043783          	ld	a5,-176(s0)
   118b8:	0007c783          	lbu	a5,0(a5)
   118bc:	00078713          	mv	a4,a5
   118c0:	06e00793          	li	a5,110
   118c4:	04f71c63          	bne	a4,a5,1191c <vprintfmt+0x674>
   118c8:	f8144783          	lbu	a5,-127(s0)
   118cc:	02078463          	beqz	a5,118f4 <vprintfmt+0x64c>
   118d0:	f4843783          	ld	a5,-184(s0)
   118d4:	00878713          	addi	a4,a5,8
   118d8:	f4e43423          	sd	a4,-184(s0)
   118dc:	0007b783          	ld	a5,0(a5)
   118e0:	faf43823          	sd	a5,-80(s0)
   118e4:	fec42703          	lw	a4,-20(s0)
   118e8:	fb043783          	ld	a5,-80(s0)
   118ec:	00e7b023          	sd	a4,0(a5)
   118f0:	0240006f          	j	11914 <vprintfmt+0x66c>
   118f4:	f4843783          	ld	a5,-184(s0)
   118f8:	00878713          	addi	a4,a5,8
   118fc:	f4e43423          	sd	a4,-184(s0)
   11900:	0007b783          	ld	a5,0(a5)
   11904:	faf43c23          	sd	a5,-72(s0)
   11908:	fb843783          	ld	a5,-72(s0)
   1190c:	fec42703          	lw	a4,-20(s0)
   11910:	00e7a023          	sw	a4,0(a5)
   11914:	f8040023          	sb	zero,-128(s0)
   11918:	1500006f          	j	11a68 <vprintfmt+0x7c0>
   1191c:	f5043783          	ld	a5,-176(s0)
   11920:	0007c783          	lbu	a5,0(a5)
   11924:	00078713          	mv	a4,a5
   11928:	07300793          	li	a5,115
   1192c:	02f71e63          	bne	a4,a5,11968 <vprintfmt+0x6c0>
   11930:	f4843783          	ld	a5,-184(s0)
   11934:	00878713          	addi	a4,a5,8
   11938:	f4e43423          	sd	a4,-184(s0)
   1193c:	0007b783          	ld	a5,0(a5)
   11940:	fcf43023          	sd	a5,-64(s0)
   11944:	fc043583          	ld	a1,-64(s0)
   11948:	f5843503          	ld	a0,-168(s0)
   1194c:	dccff0ef          	jal	10f18 <puts_wo_nl>
   11950:	00050793          	mv	a5,a0
   11954:	fec42703          	lw	a4,-20(s0)
   11958:	00f707bb          	addw	a5,a4,a5
   1195c:	fef42623          	sw	a5,-20(s0)
   11960:	f8040023          	sb	zero,-128(s0)
   11964:	1040006f          	j	11a68 <vprintfmt+0x7c0>
   11968:	f5043783          	ld	a5,-176(s0)
   1196c:	0007c783          	lbu	a5,0(a5)
   11970:	00078713          	mv	a4,a5
   11974:	06300793          	li	a5,99
   11978:	02f71e63          	bne	a4,a5,119b4 <vprintfmt+0x70c>
   1197c:	f4843783          	ld	a5,-184(s0)
   11980:	00878713          	addi	a4,a5,8
   11984:	f4e43423          	sd	a4,-184(s0)
   11988:	0007a783          	lw	a5,0(a5)
   1198c:	fcf42623          	sw	a5,-52(s0)
   11990:	fcc42703          	lw	a4,-52(s0)
   11994:	f5843783          	ld	a5,-168(s0)
   11998:	00070513          	mv	a0,a4
   1199c:	000780e7          	jalr	a5
   119a0:	fec42783          	lw	a5,-20(s0)
   119a4:	0017879b          	addiw	a5,a5,1
   119a8:	fef42623          	sw	a5,-20(s0)
   119ac:	f8040023          	sb	zero,-128(s0)
   119b0:	0b80006f          	j	11a68 <vprintfmt+0x7c0>
   119b4:	f5043783          	ld	a5,-176(s0)
   119b8:	0007c783          	lbu	a5,0(a5)
   119bc:	00078713          	mv	a4,a5
   119c0:	02500793          	li	a5,37
   119c4:	02f71263          	bne	a4,a5,119e8 <vprintfmt+0x740>
   119c8:	f5843783          	ld	a5,-168(s0)
   119cc:	02500513          	li	a0,37
   119d0:	000780e7          	jalr	a5
   119d4:	fec42783          	lw	a5,-20(s0)
   119d8:	0017879b          	addiw	a5,a5,1
   119dc:	fef42623          	sw	a5,-20(s0)
   119e0:	f8040023          	sb	zero,-128(s0)
   119e4:	0840006f          	j	11a68 <vprintfmt+0x7c0>
   119e8:	f5043783          	ld	a5,-176(s0)
   119ec:	0007c783          	lbu	a5,0(a5)
   119f0:	0007871b          	sext.w	a4,a5
   119f4:	f5843783          	ld	a5,-168(s0)
   119f8:	00070513          	mv	a0,a4
   119fc:	000780e7          	jalr	a5
   11a00:	fec42783          	lw	a5,-20(s0)
   11a04:	0017879b          	addiw	a5,a5,1
   11a08:	fef42623          	sw	a5,-20(s0)
   11a0c:	f8040023          	sb	zero,-128(s0)
   11a10:	0580006f          	j	11a68 <vprintfmt+0x7c0>
   11a14:	f5043783          	ld	a5,-176(s0)
   11a18:	0007c783          	lbu	a5,0(a5)
   11a1c:	00078713          	mv	a4,a5
   11a20:	02500793          	li	a5,37
   11a24:	02f71063          	bne	a4,a5,11a44 <vprintfmt+0x79c>
   11a28:	f8043023          	sd	zero,-128(s0)
   11a2c:	f8043423          	sd	zero,-120(s0)
   11a30:	00100793          	li	a5,1
   11a34:	f8f40023          	sb	a5,-128(s0)
   11a38:	fff00793          	li	a5,-1
   11a3c:	f8f42623          	sw	a5,-116(s0)
   11a40:	0280006f          	j	11a68 <vprintfmt+0x7c0>
   11a44:	f5043783          	ld	a5,-176(s0)
   11a48:	0007c783          	lbu	a5,0(a5)
   11a4c:	0007871b          	sext.w	a4,a5
   11a50:	f5843783          	ld	a5,-168(s0)
   11a54:	00070513          	mv	a0,a4
   11a58:	000780e7          	jalr	a5
   11a5c:	fec42783          	lw	a5,-20(s0)
   11a60:	0017879b          	addiw	a5,a5,1
   11a64:	fef42623          	sw	a5,-20(s0)
   11a68:	f5043783          	ld	a5,-176(s0)
   11a6c:	00178793          	addi	a5,a5,1
   11a70:	f4f43823          	sd	a5,-176(s0)
   11a74:	f5043783          	ld	a5,-176(s0)
   11a78:	0007c783          	lbu	a5,0(a5)
   11a7c:	84079ce3          	bnez	a5,112d4 <vprintfmt+0x2c>
   11a80:	fec42783          	lw	a5,-20(s0)
   11a84:	00078513          	mv	a0,a5
   11a88:	0b813083          	ld	ra,184(sp)
   11a8c:	0b013403          	ld	s0,176(sp)
   11a90:	0c010113          	addi	sp,sp,192
   11a94:	00008067          	ret

0000000000011a98 <printf>:
   11a98:	f8010113          	addi	sp,sp,-128
   11a9c:	02113c23          	sd	ra,56(sp)
   11aa0:	02813823          	sd	s0,48(sp)
   11aa4:	04010413          	addi	s0,sp,64
   11aa8:	fca43423          	sd	a0,-56(s0)
   11aac:	00b43423          	sd	a1,8(s0)
   11ab0:	00c43823          	sd	a2,16(s0)
   11ab4:	00d43c23          	sd	a3,24(s0)
   11ab8:	02e43023          	sd	a4,32(s0)
   11abc:	02f43423          	sd	a5,40(s0)
   11ac0:	03043823          	sd	a6,48(s0)
   11ac4:	03143c23          	sd	a7,56(s0)
   11ac8:	fe042623          	sw	zero,-20(s0)
   11acc:	04040793          	addi	a5,s0,64
   11ad0:	fcf43023          	sd	a5,-64(s0)
   11ad4:	fc043783          	ld	a5,-64(s0)
   11ad8:	fc878793          	addi	a5,a5,-56
   11adc:	fcf43823          	sd	a5,-48(s0)
   11ae0:	fd043783          	ld	a5,-48(s0)
   11ae4:	00078613          	mv	a2,a5
   11ae8:	fc843583          	ld	a1,-56(s0)
   11aec:	fffff517          	auipc	a0,0xfffff
   11af0:	0f850513          	addi	a0,a0,248 # 10be4 <putc>
   11af4:	fb4ff0ef          	jal	112a8 <vprintfmt>
   11af8:	00050793          	mv	a5,a0
   11afc:	fef42623          	sw	a5,-20(s0)
   11b00:	00100793          	li	a5,1
   11b04:	fef43023          	sd	a5,-32(s0)
   11b08:	00002797          	auipc	a5,0x2
   11b0c:	4f878793          	addi	a5,a5,1272 # 14000 <tail>
   11b10:	0007a783          	lw	a5,0(a5)
   11b14:	0017871b          	addiw	a4,a5,1
   11b18:	0007069b          	sext.w	a3,a4
   11b1c:	00002717          	auipc	a4,0x2
   11b20:	4e470713          	addi	a4,a4,1252 # 14000 <tail>
   11b24:	00d72023          	sw	a3,0(a4)
   11b28:	00002717          	auipc	a4,0x2
   11b2c:	4e070713          	addi	a4,a4,1248 # 14008 <buffer>
   11b30:	00f707b3          	add	a5,a4,a5
   11b34:	00078023          	sb	zero,0(a5)
   11b38:	00002797          	auipc	a5,0x2
   11b3c:	4c878793          	addi	a5,a5,1224 # 14000 <tail>
   11b40:	0007a603          	lw	a2,0(a5)
   11b44:	fe043703          	ld	a4,-32(s0)
   11b48:	00002697          	auipc	a3,0x2
   11b4c:	4c068693          	addi	a3,a3,1216 # 14008 <buffer>
   11b50:	fd843783          	ld	a5,-40(s0)
   11b54:	04000893          	li	a7,64
   11b58:	00070513          	mv	a0,a4
   11b5c:	00068593          	mv	a1,a3
   11b60:	00060613          	mv	a2,a2
   11b64:	00000073          	ecall
   11b68:	00050793          	mv	a5,a0
   11b6c:	fcf43c23          	sd	a5,-40(s0)
   11b70:	00002797          	auipc	a5,0x2
   11b74:	49078793          	addi	a5,a5,1168 # 14000 <tail>
   11b78:	0007a023          	sw	zero,0(a5)
   11b7c:	fec42783          	lw	a5,-20(s0)
   11b80:	00078513          	mv	a0,a5
   11b84:	03813083          	ld	ra,56(sp)
   11b88:	03013403          	ld	s0,48(sp)
   11b8c:	08010113          	addi	sp,sp,128
   11b90:	00008067          	ret

0000000000011b94 <strlen>:
   11b94:	fd010113          	addi	sp,sp,-48
   11b98:	02813423          	sd	s0,40(sp)
   11b9c:	03010413          	addi	s0,sp,48
   11ba0:	fca43c23          	sd	a0,-40(s0)
   11ba4:	fe042623          	sw	zero,-20(s0)
   11ba8:	0100006f          	j	11bb8 <strlen+0x24>
   11bac:	fec42783          	lw	a5,-20(s0)
   11bb0:	0017879b          	addiw	a5,a5,1
   11bb4:	fef42623          	sw	a5,-20(s0)
   11bb8:	fd843783          	ld	a5,-40(s0)
   11bbc:	00178713          	addi	a4,a5,1
   11bc0:	fce43c23          	sd	a4,-40(s0)
   11bc4:	0007c783          	lbu	a5,0(a5)
   11bc8:	fe0792e3          	bnez	a5,11bac <strlen+0x18>
   11bcc:	fec42783          	lw	a5,-20(s0)
   11bd0:	00078513          	mv	a0,a5
   11bd4:	02813403          	ld	s0,40(sp)
   11bd8:	03010113          	addi	sp,sp,48
   11bdc:	00008067          	ret

0000000000011be0 <write>:
   11be0:	fb010113          	addi	sp,sp,-80
   11be4:	04813423          	sd	s0,72(sp)
   11be8:	05010413          	addi	s0,sp,80
   11bec:	00050693          	mv	a3,a0
   11bf0:	fcb43023          	sd	a1,-64(s0)
   11bf4:	fac43c23          	sd	a2,-72(s0)
   11bf8:	fcd42623          	sw	a3,-52(s0)
   11bfc:	00010693          	mv	a3,sp
   11c00:	00068593          	mv	a1,a3
   11c04:	fb843683          	ld	a3,-72(s0)
   11c08:	00168693          	addi	a3,a3,1
   11c0c:	00068613          	mv	a2,a3
   11c10:	fff60613          	addi	a2,a2,-1
   11c14:	fec43023          	sd	a2,-32(s0)
   11c18:	00068e13          	mv	t3,a3
   11c1c:	00000e93          	li	t4,0
   11c20:	03de5613          	srli	a2,t3,0x3d
   11c24:	003e9893          	slli	a7,t4,0x3
   11c28:	011668b3          	or	a7,a2,a7
   11c2c:	003e1813          	slli	a6,t3,0x3
   11c30:	00068313          	mv	t1,a3
   11c34:	00000393          	li	t2,0
   11c38:	03d35613          	srli	a2,t1,0x3d
   11c3c:	00339793          	slli	a5,t2,0x3
   11c40:	00f667b3          	or	a5,a2,a5
   11c44:	00331713          	slli	a4,t1,0x3
   11c48:	00f68793          	addi	a5,a3,15
   11c4c:	0047d793          	srli	a5,a5,0x4
   11c50:	00479793          	slli	a5,a5,0x4
   11c54:	40f10133          	sub	sp,sp,a5
   11c58:	00010793          	mv	a5,sp
   11c5c:	00078793          	mv	a5,a5
   11c60:	fcf43c23          	sd	a5,-40(s0)
   11c64:	fe042623          	sw	zero,-20(s0)
   11c68:	0300006f          	j	11c98 <write+0xb8>
   11c6c:	fec42783          	lw	a5,-20(s0)
   11c70:	fc043703          	ld	a4,-64(s0)
   11c74:	00f707b3          	add	a5,a4,a5
   11c78:	0007c703          	lbu	a4,0(a5)
   11c7c:	fd843683          	ld	a3,-40(s0)
   11c80:	fec42783          	lw	a5,-20(s0)
   11c84:	00f687b3          	add	a5,a3,a5
   11c88:	00e78023          	sb	a4,0(a5)
   11c8c:	fec42783          	lw	a5,-20(s0)
   11c90:	0017879b          	addiw	a5,a5,1
   11c94:	fef42623          	sw	a5,-20(s0)
   11c98:	fec42783          	lw	a5,-20(s0)
   11c9c:	fb843703          	ld	a4,-72(s0)
   11ca0:	fce7e6e3          	bltu	a5,a4,11c6c <write+0x8c>
   11ca4:	fd843703          	ld	a4,-40(s0)
   11ca8:	fb843783          	ld	a5,-72(s0)
   11cac:	00f707b3          	add	a5,a4,a5
   11cb0:	00078023          	sb	zero,0(a5)
   11cb4:	fcc42703          	lw	a4,-52(s0)
   11cb8:	fd843683          	ld	a3,-40(s0)
   11cbc:	fb843603          	ld	a2,-72(s0)
   11cc0:	fd043783          	ld	a5,-48(s0)
   11cc4:	04000893          	li	a7,64
   11cc8:	00070513          	mv	a0,a4
   11ccc:	00068593          	mv	a1,a3
   11cd0:	00060613          	mv	a2,a2
   11cd4:	00000073          	ecall
   11cd8:	00050793          	mv	a5,a0
   11cdc:	fcf43823          	sd	a5,-48(s0)
   11ce0:	fd043783          	ld	a5,-48(s0)
   11ce4:	0007879b          	sext.w	a5,a5
   11ce8:	00058113          	mv	sp,a1
   11cec:	00078513          	mv	a0,a5
   11cf0:	fb040113          	addi	sp,s0,-80
   11cf4:	04813403          	ld	s0,72(sp)
   11cf8:	05010113          	addi	sp,sp,80
   11cfc:	00008067          	ret

0000000000011d00 <read>:
   11d00:	fc010113          	addi	sp,sp,-64
   11d04:	02813c23          	sd	s0,56(sp)
   11d08:	04010413          	addi	s0,sp,64
   11d0c:	00050793          	mv	a5,a0
   11d10:	fcb43823          	sd	a1,-48(s0)
   11d14:	fcc43423          	sd	a2,-56(s0)
   11d18:	fcf42e23          	sw	a5,-36(s0)
   11d1c:	fdc42703          	lw	a4,-36(s0)
   11d20:	fd043683          	ld	a3,-48(s0)
   11d24:	fc843603          	ld	a2,-56(s0)
   11d28:	fe843783          	ld	a5,-24(s0)
   11d2c:	03f00893          	li	a7,63
   11d30:	00070513          	mv	a0,a4
   11d34:	00068593          	mv	a1,a3
   11d38:	00060613          	mv	a2,a2
   11d3c:	00000073          	ecall
   11d40:	00050793          	mv	a5,a0
   11d44:	fef43423          	sd	a5,-24(s0)
   11d48:	fe843783          	ld	a5,-24(s0)
   11d4c:	0007879b          	sext.w	a5,a5
   11d50:	00078513          	mv	a0,a5
   11d54:	03813403          	ld	s0,56(sp)
   11d58:	04010113          	addi	sp,sp,64
   11d5c:	00008067          	ret

0000000000011d60 <sys_openat>:
   11d60:	fd010113          	addi	sp,sp,-48
   11d64:	02813423          	sd	s0,40(sp)
   11d68:	03010413          	addi	s0,sp,48
   11d6c:	00050793          	mv	a5,a0
   11d70:	fcb43823          	sd	a1,-48(s0)
   11d74:	00060713          	mv	a4,a2
   11d78:	fcf42e23          	sw	a5,-36(s0)
   11d7c:	00070793          	mv	a5,a4
   11d80:	fcf42c23          	sw	a5,-40(s0)
   11d84:	fdc42703          	lw	a4,-36(s0)
   11d88:	fd842603          	lw	a2,-40(s0)
   11d8c:	fd043683          	ld	a3,-48(s0)
   11d90:	fe843783          	ld	a5,-24(s0)
   11d94:	03800893          	li	a7,56
   11d98:	00070513          	mv	a0,a4
   11d9c:	00068593          	mv	a1,a3
   11da0:	00060613          	mv	a2,a2
   11da4:	00000073          	ecall
   11da8:	00050793          	mv	a5,a0
   11dac:	fef43423          	sd	a5,-24(s0)
   11db0:	fe843783          	ld	a5,-24(s0)
   11db4:	0007879b          	sext.w	a5,a5
   11db8:	00078513          	mv	a0,a5
   11dbc:	02813403          	ld	s0,40(sp)
   11dc0:	03010113          	addi	sp,sp,48
   11dc4:	00008067          	ret

0000000000011dc8 <open>:
   11dc8:	fe010113          	addi	sp,sp,-32
   11dcc:	00113c23          	sd	ra,24(sp)
   11dd0:	00813823          	sd	s0,16(sp)
   11dd4:	02010413          	addi	s0,sp,32
   11dd8:	fea43423          	sd	a0,-24(s0)
   11ddc:	00058793          	mv	a5,a1
   11de0:	fef42223          	sw	a5,-28(s0)
   11de4:	fe442783          	lw	a5,-28(s0)
   11de8:	00078613          	mv	a2,a5
   11dec:	fe843583          	ld	a1,-24(s0)
   11df0:	f9c00513          	li	a0,-100
   11df4:	f6dff0ef          	jal	11d60 <sys_openat>
   11df8:	00050793          	mv	a5,a0
   11dfc:	00078513          	mv	a0,a5
   11e00:	01813083          	ld	ra,24(sp)
   11e04:	01013403          	ld	s0,16(sp)
   11e08:	02010113          	addi	sp,sp,32
   11e0c:	00008067          	ret

0000000000011e10 <close>:
   11e10:	fd010113          	addi	sp,sp,-48
   11e14:	02813423          	sd	s0,40(sp)
   11e18:	03010413          	addi	s0,sp,48
   11e1c:	00050793          	mv	a5,a0
   11e20:	fcf42e23          	sw	a5,-36(s0)
   11e24:	fdc42703          	lw	a4,-36(s0)
   11e28:	fe843783          	ld	a5,-24(s0)
   11e2c:	03900893          	li	a7,57
   11e30:	00070513          	mv	a0,a4
   11e34:	00000073          	ecall
   11e38:	00050793          	mv	a5,a0
   11e3c:	fef43423          	sd	a5,-24(s0)
   11e40:	fe843783          	ld	a5,-24(s0)
   11e44:	0007879b          	sext.w	a5,a5
   11e48:	00078513          	mv	a0,a5
   11e4c:	02813403          	ld	s0,40(sp)
   11e50:	03010113          	addi	sp,sp,48
   11e54:	00008067          	ret

0000000000011e58 <lseek>:
   11e58:	fd010113          	addi	sp,sp,-48
   11e5c:	02813423          	sd	s0,40(sp)
   11e60:	03010413          	addi	s0,sp,48
   11e64:	00050793          	mv	a5,a0
   11e68:	00058693          	mv	a3,a1
   11e6c:	00060713          	mv	a4,a2
   11e70:	fcf42e23          	sw	a5,-36(s0)
   11e74:	00068793          	mv	a5,a3
   11e78:	fcf42c23          	sw	a5,-40(s0)
   11e7c:	00070793          	mv	a5,a4
   11e80:	fcf42a23          	sw	a5,-44(s0)
   11e84:	fdc42703          	lw	a4,-36(s0)
   11e88:	fd842683          	lw	a3,-40(s0)
   11e8c:	fd442603          	lw	a2,-44(s0)
   11e90:	fe843783          	ld	a5,-24(s0)
   11e94:	03e00893          	li	a7,62
   11e98:	00070513          	mv	a0,a4
   11e9c:	00068593          	mv	a1,a3
   11ea0:	00060613          	mv	a2,a2
   11ea4:	00000073          	ecall
   11ea8:	00050793          	mv	a5,a0
   11eac:	fef43423          	sd	a5,-24(s0)
   11eb0:	fe843783          	ld	a5,-24(s0)
   11eb4:	0007879b          	sext.w	a5,a5
   11eb8:	00078513          	mv	a0,a5
   11ebc:	02813403          	ld	s0,40(sp)
   11ec0:	03010113          	addi	sp,sp,48
   11ec4:	00008067          	ret
