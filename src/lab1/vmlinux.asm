
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    # ------------------
    # - your code here -
    # ------------------

    # load the stack top address into the stack pointer
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>

    # 开启trap处理新增指令，使用一个临时寄存器t0来存储_traps的地址
    la t0, _traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec, t0
    80200010:	10529073          	csrw	stvec,t0
    # 开启时钟中断，sie[STIE] 置 1
    li t0, (1 << 5)
    80200014:	02000293          	li	t0,32
    csrs sie, t0
    80200018:	1042a073          	csrs	sie,t0

    # 设置第一次时钟中断
    rdtime t0
    8020001c:	c01022f3          	rdtime	t0
    li t1, 10000000 # TIMECLOCK为10000000
    80200020:	00989337          	lui	t1,0x989
    80200024:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    add t0, t0, t1
    80200028:	006282b3          	add	t0,t0,t1
    # 参数传递
    mv a0, t0
    8020002c:	00028513          	mv	a0,t0



    call sbi_set_timer
    80200030:	28c000ef          	jal	802002bc <sbi_set_timer>



    #开启全局中断，sstatus[SIE] 置 1
    li t0, (1 << 1)
    80200034:	00200293          	li	t0,2
    csrs sstatus, t0
    80200038:	1002a073          	csrs	sstatus,t0

    # call the function
    call start_kernel
    8020003c:	51c000ef          	jal	80200558 <start_kernel>

0000000080200040 <_traps>:
_traps:
    # 1. save 32 registers and sepc to stack
    # 2. call trap_handler
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    # 4. return from trap
    addi sp, sp, -272
    80200040:	ef010113          	addi	sp,sp,-272
    # 保存寄存器
    sd zero, 0(sp)
    80200044:	00013023          	sd	zero,0(sp)
    sd ra, 8(sp)
    80200048:	00113423          	sd	ra,8(sp)
    sd gp, 16(sp)
    8020004c:	00313823          	sd	gp,16(sp)
    sd tp, 24(sp)
    80200050:	00413c23          	sd	tp,24(sp)
    sd t0, 32(sp)
    80200054:	02513023          	sd	t0,32(sp)
    sd t1, 40(sp)
    80200058:	02613423          	sd	t1,40(sp)
    sd t2, 48(sp)
    8020005c:	02713823          	sd	t2,48(sp)
    sd s0, 56(sp)
    80200060:	02813c23          	sd	s0,56(sp)
    sd s1, 64(sp)
    80200064:	04913023          	sd	s1,64(sp)
    sd a0, 72(sp)
    80200068:	04a13423          	sd	a0,72(sp)
    sd a1, 80(sp)
    8020006c:	04b13823          	sd	a1,80(sp)
    sd a2, 88(sp)
    80200070:	04c13c23          	sd	a2,88(sp)
    sd a3, 96(sp)
    80200074:	06d13023          	sd	a3,96(sp)
    sd a4, 104(sp)
    80200078:	06e13423          	sd	a4,104(sp)
    sd a5, 112(sp)
    8020007c:	06f13823          	sd	a5,112(sp)
    sd a6, 120(sp)
    80200080:	07013c23          	sd	a6,120(sp)
    sd a7, 128(sp)
    80200084:	09113023          	sd	a7,128(sp)
    sd s2, 136(sp)
    80200088:	09213423          	sd	s2,136(sp)
    sd s3, 144(sp)
    8020008c:	09313823          	sd	s3,144(sp)
    sd s4, 152(sp)
    80200090:	09413c23          	sd	s4,152(sp)
    sd s5, 160(sp)
    80200094:	0b513023          	sd	s5,160(sp)
    sd s6, 168(sp)
    80200098:	0b613423          	sd	s6,168(sp)
    sd s7, 176(sp)
    8020009c:	0b713823          	sd	s7,176(sp)
    sd s8, 184(sp)
    802000a0:	0b813c23          	sd	s8,184(sp)
    sd s9, 192(sp)
    802000a4:	0d913023          	sd	s9,192(sp)
    sd s10, 200(sp)
    802000a8:	0da13423          	sd	s10,200(sp)
    sd s11, 208(sp)
    802000ac:	0db13823          	sd	s11,208(sp)
    sd t3, 216(sp)
    802000b0:	0dc13c23          	sd	t3,216(sp)
    sd t4, 224(sp)
    802000b4:	0fd13023          	sd	t4,224(sp)
    sd t5, 232(sp)
    802000b8:	0fe13423          	sd	t5,232(sp)
    sd t6, 240(sp)
    802000bc:	0ff13823          	sd	t6,240(sp)
    
    # 保存 scause 和 sepc
    csrr t0, scause
    802000c0:	142022f3          	csrr	t0,scause
    sd t0, 248(sp)
    802000c4:	0e513c23          	sd	t0,248(sp)
    csrr t0, sepc
    802000c8:	141022f3          	csrr	t0,sepc
    sd t0, 256(sp)
    802000cc:	10513023          	sd	t0,256(sp)

    # 传递参数
    ld a0, 248(sp)
    802000d0:	0f813503          	ld	a0,248(sp)
    ld a1, 256(sp)
    802000d4:	10013583          	ld	a1,256(sp)

    call trap_handler
    802000d8:	39c000ef          	jal	80200474 <trap_handler>

    # 恢复寄存器
    ld t0, 256(sp)
    802000dc:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
    802000e0:	14129073          	csrw	sepc,t0
    # ld t0, 248(sp)
    # csrw scause, t0

    ld t6, 240(sp)
    802000e4:	0f013f83          	ld	t6,240(sp)
    ld t5, 232(sp)
    802000e8:	0e813f03          	ld	t5,232(sp)
    ld t4, 224(sp)
    802000ec:	0e013e83          	ld	t4,224(sp)
    ld t3, 216(sp)
    802000f0:	0d813e03          	ld	t3,216(sp)
    ld s11, 208(sp)
    802000f4:	0d013d83          	ld	s11,208(sp)
    ld s10, 200(sp)
    802000f8:	0c813d03          	ld	s10,200(sp)
    ld s9, 192(sp)
    802000fc:	0c013c83          	ld	s9,192(sp)
    ld s8, 184(sp)
    80200100:	0b813c03          	ld	s8,184(sp)
    ld s7, 176(sp)
    80200104:	0b013b83          	ld	s7,176(sp)
    ld s6, 168(sp)
    80200108:	0a813b03          	ld	s6,168(sp)
    ld s5, 160(sp)
    8020010c:	0a013a83          	ld	s5,160(sp)
    ld s4, 152(sp)
    80200110:	09813a03          	ld	s4,152(sp)
    ld s3, 144(sp)
    80200114:	09013983          	ld	s3,144(sp)
    ld s2, 136(sp)
    80200118:	08813903          	ld	s2,136(sp)
    ld a7, 128(sp)
    8020011c:	08013883          	ld	a7,128(sp)
    ld a6, 120(sp)
    80200120:	07813803          	ld	a6,120(sp)
    ld a5, 112(sp)
    80200124:	07013783          	ld	a5,112(sp)
    ld a4, 104(sp)
    80200128:	06813703          	ld	a4,104(sp)
    ld a3, 96(sp)
    8020012c:	06013683          	ld	a3,96(sp)
    ld a2, 88(sp)
    80200130:	05813603          	ld	a2,88(sp)
    ld a1, 80(sp)
    80200134:	05013583          	ld	a1,80(sp)
    ld a0, 72(sp)
    80200138:	04813503          	ld	a0,72(sp)
    ld s1, 64(sp)
    8020013c:	04013483          	ld	s1,64(sp)
    ld s0, 56(sp)
    80200140:	03813403          	ld	s0,56(sp)
    ld t2, 48(sp)
    80200144:	03013383          	ld	t2,48(sp)
    ld t1, 40(sp)
    80200148:	02813303          	ld	t1,40(sp)
    ld t0, 32(sp)
    8020014c:	02013283          	ld	t0,32(sp)
    ld tp, 24(sp)
    80200150:	01813203          	ld	tp,24(sp)
    ld gp, 16(sp)
    80200154:	01013183          	ld	gp,16(sp)
    ld ra, 8(sp)
    80200158:	00813083          	ld	ra,8(sp)
    ld zero, 0(sp)
    8020015c:	00013003          	ld	zero,0(sp)

    # 恢复栈顶
    addi sp, sp, 272
    80200160:	11010113          	addi	sp,sp,272

    # 返回
    80200164:	10200073          	sret

0000000080200168 <get_cycles>:
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    80200168:	fe010113          	addi	sp,sp,-32
    8020016c:	00813c23          	sd	s0,24(sp)
    80200170:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t time;
    asm volatile(
    80200174:	c01027f3          	rdtime	a5
    80200178:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r"(time)
    );
    return time;
    8020017c:	fe843783          	ld	a5,-24(s0)
}
    80200180:	00078513          	mv	a0,a5
    80200184:	01813403          	ld	s0,24(sp)
    80200188:	02010113          	addi	sp,sp,32
    8020018c:	00008067          	ret

0000000080200190 <clock_set_next_event>:

void clock_set_next_event() {
    80200190:	fe010113          	addi	sp,sp,-32
    80200194:	00113c23          	sd	ra,24(sp)
    80200198:	00813823          	sd	s0,16(sp)
    8020019c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    802001a0:	fc9ff0ef          	jal	80200168 <get_cycles>
    802001a4:	00050713          	mv	a4,a0
    802001a8:	00003797          	auipc	a5,0x3
    802001ac:	e5878793          	addi	a5,a5,-424 # 80203000 <TIMECLOCK>
    802001b0:	0007b783          	ld	a5,0(a5)
    802001b4:	00f707b3          	add	a5,a4,a5
    802001b8:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    802001bc:	fe843503          	ld	a0,-24(s0)
    802001c0:	0fc000ef          	jal	802002bc <sbi_set_timer>
    802001c4:	00000013          	nop
    802001c8:	01813083          	ld	ra,24(sp)
    802001cc:	01013403          	ld	s0,16(sp)
    802001d0:	02010113          	addi	sp,sp,32
    802001d4:	00008067          	ret

00000000802001d8 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001d8:	f7010113          	addi	sp,sp,-144
    802001dc:	08813423          	sd	s0,136(sp)
    802001e0:	08913023          	sd	s1,128(sp)
    802001e4:	07213c23          	sd	s2,120(sp)
    802001e8:	07313823          	sd	s3,112(sp)
    802001ec:	09010413          	addi	s0,sp,144
    802001f0:	faa43423          	sd	a0,-88(s0)
    802001f4:	fab43023          	sd	a1,-96(s0)
    802001f8:	f8c43c23          	sd	a2,-104(s0)
    802001fc:	f8d43823          	sd	a3,-112(s0)
    80200200:	f8e43423          	sd	a4,-120(s0)
    80200204:	f8f43023          	sd	a5,-128(s0)
    80200208:	f7043c23          	sd	a6,-136(s0)
    8020020c:	f7143823          	sd	a7,-144(s0)
    struct sbiret ret;
    uint64_t error_reg, value_reg;
    
    asm volatile(
    80200210:	fa843e03          	ld	t3,-88(s0)
    80200214:	fa043e83          	ld	t4,-96(s0)
    80200218:	f9843f03          	ld	t5,-104(s0)
    8020021c:	f9043f83          	ld	t6,-112(s0)
    80200220:	f8843283          	ld	t0,-120(s0)
    80200224:	f8043483          	ld	s1,-128(s0)
    80200228:	f7843903          	ld	s2,-136(s0)
    8020022c:	f7043983          	ld	s3,-144(s0)
    80200230:	000e0893          	mv	a7,t3
    80200234:	000e8813          	mv	a6,t4
    80200238:	000f0513          	mv	a0,t5
    8020023c:	000f8593          	mv	a1,t6
    80200240:	00028613          	mv	a2,t0
    80200244:	00048693          	mv	a3,s1
    80200248:	00090713          	mv	a4,s2
    8020024c:	00098793          	mv	a5,s3
    80200250:	00000073          	ecall
    80200254:	00050e93          	mv	t4,a0
    80200258:	00058e13          	mv	t3,a1
    8020025c:	fdd43c23          	sd	t4,-40(s0)
    80200260:	fdc43823          	sd	t3,-48(s0)
          "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
          
    );

    // 返回结果
    ret.error = error_reg;
    80200264:	fd843783          	ld	a5,-40(s0)
    80200268:	faf43823          	sd	a5,-80(s0)
    ret.value = value_reg;
    8020026c:	fd043783          	ld	a5,-48(s0)
    80200270:	faf43c23          	sd	a5,-72(s0)
    return ret;
    80200274:	fb043783          	ld	a5,-80(s0)
    80200278:	fcf43023          	sd	a5,-64(s0)
    8020027c:	fb843783          	ld	a5,-72(s0)
    80200280:	fcf43423          	sd	a5,-56(s0)
    80200284:	fc043703          	ld	a4,-64(s0)
    80200288:	fc843783          	ld	a5,-56(s0)
    8020028c:	00070313          	mv	t1,a4
    80200290:	00078393          	mv	t2,a5
    80200294:	00030713          	mv	a4,t1
    80200298:	00038793          	mv	a5,t2
}
    8020029c:	00070513          	mv	a0,a4
    802002a0:	00078593          	mv	a1,a5
    802002a4:	08813403          	ld	s0,136(sp)
    802002a8:	08013483          	ld	s1,128(sp)
    802002ac:	07813903          	ld	s2,120(sp)
    802002b0:	07013983          	ld	s3,112(sp)
    802002b4:	09010113          	addi	sp,sp,144
    802002b8:	00008067          	ret

00000000802002bc <sbi_set_timer>:

// 设置时钟相关寄存器
struct sbiret sbi_set_timer(uint64_t stime_value) {
    802002bc:	fc010113          	addi	sp,sp,-64
    802002c0:	02113c23          	sd	ra,56(sp)
    802002c4:	02813823          	sd	s0,48(sp)
    802002c8:	03213423          	sd	s2,40(sp)
    802002cc:	03313023          	sd	s3,32(sp)
    802002d0:	04010413          	addi	s0,sp,64
    802002d4:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
    802002d8:	00000893          	li	a7,0
    802002dc:	00000813          	li	a6,0
    802002e0:	00000793          	li	a5,0
    802002e4:	00000713          	li	a4,0
    802002e8:	00000693          	li	a3,0
    802002ec:	fc843603          	ld	a2,-56(s0)
    802002f0:	00000593          	li	a1,0
    802002f4:	54495537          	lui	a0,0x54495
    802002f8:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    802002fc:	eddff0ef          	jal	802001d8 <sbi_ecall>
    80200300:	00050713          	mv	a4,a0
    80200304:	00058793          	mv	a5,a1
    80200308:	fce43823          	sd	a4,-48(s0)
    8020030c:	fcf43c23          	sd	a5,-40(s0)
    80200310:	fd043703          	ld	a4,-48(s0)
    80200314:	fd843783          	ld	a5,-40(s0)
    80200318:	00070913          	mv	s2,a4
    8020031c:	00078993          	mv	s3,a5
    80200320:	00090713          	mv	a4,s2
    80200324:	00098793          	mv	a5,s3
}
    80200328:	00070513          	mv	a0,a4
    8020032c:	00078593          	mv	a1,a5
    80200330:	03813083          	ld	ra,56(sp)
    80200334:	03013403          	ld	s0,48(sp)
    80200338:	02813903          	ld	s2,40(sp)
    8020033c:	02013983          	ld	s3,32(sp)
    80200340:	04010113          	addi	sp,sp,64
    80200344:	00008067          	ret

0000000080200348 <sbi_debug_console_write_byte>:
// 从终端读取数据
// struct sbiret sbi_debug_console_read() {
    
// }
// 向终端写入单个字符
struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200348:	fc010113          	addi	sp,sp,-64
    8020034c:	02113c23          	sd	ra,56(sp)
    80200350:	02813823          	sd	s0,48(sp)
    80200354:	03213423          	sd	s2,40(sp)
    80200358:	03313023          	sd	s3,32(sp)
    8020035c:	04010413          	addi	s0,sp,64
    80200360:	00050793          	mv	a5,a0
    80200364:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e, 0x2, byte, 0, 0, 0, 0, 0);
    80200368:	fcf44603          	lbu	a2,-49(s0)
    8020036c:	00000893          	li	a7,0
    80200370:	00000813          	li	a6,0
    80200374:	00000793          	li	a5,0
    80200378:	00000713          	li	a4,0
    8020037c:	00000693          	li	a3,0
    80200380:	00200593          	li	a1,2
    80200384:	44424537          	lui	a0,0x44424
    80200388:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    8020038c:	e4dff0ef          	jal	802001d8 <sbi_ecall>
    80200390:	00050713          	mv	a4,a0
    80200394:	00058793          	mv	a5,a1
    80200398:	fce43823          	sd	a4,-48(s0)
    8020039c:	fcf43c23          	sd	a5,-40(s0)
    802003a0:	fd043703          	ld	a4,-48(s0)
    802003a4:	fd843783          	ld	a5,-40(s0)
    802003a8:	00070913          	mv	s2,a4
    802003ac:	00078993          	mv	s3,a5
    802003b0:	00090713          	mv	a4,s2
    802003b4:	00098793          	mv	a5,s3
}
    802003b8:	00070513          	mv	a0,a4
    802003bc:	00078593          	mv	a1,a5
    802003c0:	03813083          	ld	ra,56(sp)
    802003c4:	03013403          	ld	s0,48(sp)
    802003c8:	02813903          	ld	s2,40(sp)
    802003cc:	02013983          	ld	s3,32(sp)
    802003d0:	04010113          	addi	sp,sp,64
    802003d4:	00008067          	ret

00000000802003d8 <sbi_system_reset>:
// 重置系统（关机或重启）
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    802003d8:	fc010113          	addi	sp,sp,-64
    802003dc:	02113c23          	sd	ra,56(sp)
    802003e0:	02813823          	sd	s0,48(sp)
    802003e4:	03213423          	sd	s2,40(sp)
    802003e8:	03313023          	sd	s3,32(sp)
    802003ec:	04010413          	addi	s0,sp,64
    802003f0:	00050793          	mv	a5,a0
    802003f4:	00058713          	mv	a4,a1
    802003f8:	fcf42623          	sw	a5,-52(s0)
    802003fc:	00070793          	mv	a5,a4
    80200400:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
    80200404:	fcc46603          	lwu	a2,-52(s0)
    80200408:	fc846683          	lwu	a3,-56(s0)
    8020040c:	00000893          	li	a7,0
    80200410:	00000813          	li	a6,0
    80200414:	00000793          	li	a5,0
    80200418:	00000713          	li	a4,0
    8020041c:	00000593          	li	a1,0
    80200420:	53525537          	lui	a0,0x53525
    80200424:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200428:	db1ff0ef          	jal	802001d8 <sbi_ecall>
    8020042c:	00050713          	mv	a4,a0
    80200430:	00058793          	mv	a5,a1
    80200434:	fce43823          	sd	a4,-48(s0)
    80200438:	fcf43c23          	sd	a5,-40(s0)
    8020043c:	fd043703          	ld	a4,-48(s0)
    80200440:	fd843783          	ld	a5,-40(s0)
    80200444:	00070913          	mv	s2,a4
    80200448:	00078993          	mv	s3,a5
    8020044c:	00090713          	mv	a4,s2
    80200450:	00098793          	mv	a5,s3
    80200454:	00070513          	mv	a0,a4
    80200458:	00078593          	mv	a1,a5
    8020045c:	03813083          	ld	ra,56(sp)
    80200460:	03013403          	ld	s0,48(sp)
    80200464:	02813903          	ld	s2,40(sp)
    80200468:	02013983          	ld	s3,32(sp)
    8020046c:	04010113          	addi	sp,sp,64
    80200470:	00008067          	ret

0000000080200474 <trap_handler>:
#include "stdint.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
    80200474:	fd010113          	addi	sp,sp,-48
    80200478:	02113423          	sd	ra,40(sp)
    8020047c:	02813023          	sd	s0,32(sp)
    80200480:	03010413          	addi	s0,sp,48
    80200484:	fca43c23          	sd	a0,-40(s0)
    80200488:	fcb43823          	sd	a1,-48(s0)
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    // 参考: 63为interrupt, 0~62为code
    uint64_t code = scause & 0x7FFFFFFFFFFFFFFF;
    8020048c:	fd843703          	ld	a4,-40(s0)
    80200490:	fff00793          	li	a5,-1
    80200494:	0017d793          	srli	a5,a5,0x1
    80200498:	00f777b3          	and	a5,a4,a5
    8020049c:	fef43423          	sd	a5,-24(s0)
    if (scause & 1ULL << 63) { // interrupt
    802004a0:	fd843783          	ld	a5,-40(s0)
    802004a4:	0807da63          	bgez	a5,80200538 <trap_handler+0xc4>
        // 打印调试信息
        if (code == 1) {
    802004a8:	fe843703          	ld	a4,-24(s0)
    802004ac:	00100793          	li	a5,1
    802004b0:	00f71a63          	bne	a4,a5,802004c4 <trap_handler+0x50>
            printk("[S] Supervisor Software Interrupt\n");
    802004b4:	00002517          	auipc	a0,0x2
    802004b8:	b4c50513          	addi	a0,a0,-1204 # 80202000 <_srodata>
    802004bc:	7c5000ef          	jal	80201480 <printk>
    802004c0:	0640006f          	j	80200524 <trap_handler+0xb0>
        }
        else if (code == 5) {
    802004c4:	fe843703          	ld	a4,-24(s0)
    802004c8:	00500793          	li	a5,5
    802004cc:	00f71a63          	bne	a4,a5,802004e0 <trap_handler+0x6c>
            printk("[S] Supervisor Timer Interrupt\n");
    802004d0:	00002517          	auipc	a0,0x2
    802004d4:	b5850513          	addi	a0,a0,-1192 # 80202028 <_srodata+0x28>
    802004d8:	7a9000ef          	jal	80201480 <printk>
    802004dc:	0480006f          	j	80200524 <trap_handler+0xb0>
        }
        else if (code == 9) {
    802004e0:	fe843703          	ld	a4,-24(s0)
    802004e4:	00900793          	li	a5,9
    802004e8:	00f71a63          	bne	a4,a5,802004fc <trap_handler+0x88>
            printk("[S] Supervisor External Interrupt\n");
    802004ec:	00002517          	auipc	a0,0x2
    802004f0:	b5c50513          	addi	a0,a0,-1188 # 80202048 <_srodata+0x48>
    802004f4:	78d000ef          	jal	80201480 <printk>
    802004f8:	02c0006f          	j	80200524 <trap_handler+0xb0>
        }
        else if (code == 13) {
    802004fc:	fe843703          	ld	a4,-24(s0)
    80200500:	00d00793          	li	a5,13
    80200504:	00f71a63          	bne	a4,a5,80200518 <trap_handler+0xa4>
            printk("Counter-overflow Interrupt\n");
    80200508:	00002517          	auipc	a0,0x2
    8020050c:	b6850513          	addi	a0,a0,-1176 # 80202070 <_srodata+0x70>
    80200510:	771000ef          	jal	80201480 <printk>
    80200514:	0100006f          	j	80200524 <trap_handler+0xb0>
        }
        else {
            printk("Reserved or Designed for Platform Use\n");
    80200518:	00002517          	auipc	a0,0x2
    8020051c:	b7850513          	addi	a0,a0,-1160 # 80202090 <_srodata+0x90>
    80200520:	761000ef          	jal	80201480 <printk>
        }

        // 设置下一次时钟中断
        if (code == 5) { // timer interrupt
    80200524:	fe843703          	ld	a4,-24(s0)
    80200528:	00500793          	li	a5,5
    8020052c:	00f71c63          	bne	a4,a5,80200544 <trap_handler+0xd0>
            clock_set_next_event();
    80200530:	c61ff0ef          	jal	80200190 <clock_set_next_event>
        }
    }
    else {  // exception
        printk("Exception\n");
    }
    80200534:	0100006f          	j	80200544 <trap_handler+0xd0>
        printk("Exception\n");
    80200538:	00002517          	auipc	a0,0x2
    8020053c:	b8050513          	addi	a0,a0,-1152 # 802020b8 <_srodata+0xb8>
    80200540:	741000ef          	jal	80201480 <printk>
    80200544:	00000013          	nop
    80200548:	02813083          	ld	ra,40(sp)
    8020054c:	02013403          	ld	s0,32(sp)
    80200550:	03010113          	addi	sp,sp,48
    80200554:	00008067          	ret

0000000080200558 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel() {
    80200558:	ff010113          	addi	sp,sp,-16
    8020055c:	00113423          	sd	ra,8(sp)
    80200560:	00813023          	sd	s0,0(sp)
    80200564:	01010413          	addi	s0,sp,16
    printk("2024");
    80200568:	00002517          	auipc	a0,0x2
    8020056c:	b6050513          	addi	a0,a0,-1184 # 802020c8 <_srodata+0xc8>
    80200570:	711000ef          	jal	80201480 <printk>
    printk(" ZJU Operating System\n");
    80200574:	00002517          	auipc	a0,0x2
    80200578:	b5c50513          	addi	a0,a0,-1188 # 802020d0 <_srodata+0xd0>
    8020057c:	705000ef          	jal	80201480 <printk>

    test();
    80200580:	01c000ef          	jal	8020059c <test>
    return 0;
    80200584:	00000793          	li	a5,0
}
    80200588:	00078513          	mv	a0,a5
    8020058c:	00813083          	ld	ra,8(sp)
    80200590:	00013403          	ld	s0,0(sp)
    80200594:	01010113          	addi	sp,sp,16
    80200598:	00008067          	ret

000000008020059c <test>:
//     sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
//     __builtin_unreachable();
// }

#include "printk.h"
void test() {
    8020059c:	fe010113          	addi	sp,sp,-32
    802005a0:	00113c23          	sd	ra,24(sp)
    802005a4:	00813823          	sd	s0,16(sp)
    802005a8:	02010413          	addi	s0,sp,32
    int i = 0;
    802005ac:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    802005b0:	fec42783          	lw	a5,-20(s0)
    802005b4:	0017879b          	addiw	a5,a5,1
    802005b8:	fef42623          	sw	a5,-20(s0)
    802005bc:	fec42783          	lw	a5,-20(s0)
    802005c0:	00078713          	mv	a4,a5
    802005c4:	05f5e7b7          	lui	a5,0x5f5e
    802005c8:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    802005cc:	02f767bb          	remw	a5,a4,a5
    802005d0:	0007879b          	sext.w	a5,a5
    802005d4:	fc079ee3          	bnez	a5,802005b0 <test+0x14>
            printk("kernel is running!\n");
    802005d8:	00002517          	auipc	a0,0x2
    802005dc:	b1050513          	addi	a0,a0,-1264 # 802020e8 <_srodata+0xe8>
    802005e0:	6a1000ef          	jal	80201480 <printk>
            i = 0;
    802005e4:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    802005e8:	fc9ff06f          	j	802005b0 <test+0x14>

00000000802005ec <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    802005ec:	fe010113          	addi	sp,sp,-32
    802005f0:	00113c23          	sd	ra,24(sp)
    802005f4:	00813823          	sd	s0,16(sp)
    802005f8:	02010413          	addi	s0,sp,32
    802005fc:	00050793          	mv	a5,a0
    80200600:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200604:	fec42783          	lw	a5,-20(s0)
    80200608:	0ff7f793          	zext.b	a5,a5
    8020060c:	00078513          	mv	a0,a5
    80200610:	d39ff0ef          	jal	80200348 <sbi_debug_console_write_byte>
    return (char)c;
    80200614:	fec42783          	lw	a5,-20(s0)
    80200618:	0ff7f793          	zext.b	a5,a5
    8020061c:	0007879b          	sext.w	a5,a5
}
    80200620:	00078513          	mv	a0,a5
    80200624:	01813083          	ld	ra,24(sp)
    80200628:	01013403          	ld	s0,16(sp)
    8020062c:	02010113          	addi	sp,sp,32
    80200630:	00008067          	ret

0000000080200634 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200634:	fe010113          	addi	sp,sp,-32
    80200638:	00813c23          	sd	s0,24(sp)
    8020063c:	02010413          	addi	s0,sp,32
    80200640:	00050793          	mv	a5,a0
    80200644:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200648:	fec42783          	lw	a5,-20(s0)
    8020064c:	0007871b          	sext.w	a4,a5
    80200650:	02000793          	li	a5,32
    80200654:	02f70263          	beq	a4,a5,80200678 <isspace+0x44>
    80200658:	fec42783          	lw	a5,-20(s0)
    8020065c:	0007871b          	sext.w	a4,a5
    80200660:	00800793          	li	a5,8
    80200664:	00e7de63          	bge	a5,a4,80200680 <isspace+0x4c>
    80200668:	fec42783          	lw	a5,-20(s0)
    8020066c:	0007871b          	sext.w	a4,a5
    80200670:	00d00793          	li	a5,13
    80200674:	00e7c663          	blt	a5,a4,80200680 <isspace+0x4c>
    80200678:	00100793          	li	a5,1
    8020067c:	0080006f          	j	80200684 <isspace+0x50>
    80200680:	00000793          	li	a5,0
}
    80200684:	00078513          	mv	a0,a5
    80200688:	01813403          	ld	s0,24(sp)
    8020068c:	02010113          	addi	sp,sp,32
    80200690:	00008067          	ret

0000000080200694 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200694:	fb010113          	addi	sp,sp,-80
    80200698:	04113423          	sd	ra,72(sp)
    8020069c:	04813023          	sd	s0,64(sp)
    802006a0:	05010413          	addi	s0,sp,80
    802006a4:	fca43423          	sd	a0,-56(s0)
    802006a8:	fcb43023          	sd	a1,-64(s0)
    802006ac:	00060793          	mv	a5,a2
    802006b0:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    802006b4:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    802006b8:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    802006bc:	fc843783          	ld	a5,-56(s0)
    802006c0:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    802006c4:	0100006f          	j	802006d4 <strtol+0x40>
        p++;
    802006c8:	fd843783          	ld	a5,-40(s0)
    802006cc:	00178793          	addi	a5,a5,1
    802006d0:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    802006d4:	fd843783          	ld	a5,-40(s0)
    802006d8:	0007c783          	lbu	a5,0(a5)
    802006dc:	0007879b          	sext.w	a5,a5
    802006e0:	00078513          	mv	a0,a5
    802006e4:	f51ff0ef          	jal	80200634 <isspace>
    802006e8:	00050793          	mv	a5,a0
    802006ec:	fc079ee3          	bnez	a5,802006c8 <strtol+0x34>
    }

    if (*p == '-') {
    802006f0:	fd843783          	ld	a5,-40(s0)
    802006f4:	0007c783          	lbu	a5,0(a5)
    802006f8:	00078713          	mv	a4,a5
    802006fc:	02d00793          	li	a5,45
    80200700:	00f71e63          	bne	a4,a5,8020071c <strtol+0x88>
        neg = true;
    80200704:	00100793          	li	a5,1
    80200708:	fef403a3          	sb	a5,-25(s0)
        p++;
    8020070c:	fd843783          	ld	a5,-40(s0)
    80200710:	00178793          	addi	a5,a5,1
    80200714:	fcf43c23          	sd	a5,-40(s0)
    80200718:	0240006f          	j	8020073c <strtol+0xa8>
    } else if (*p == '+') {
    8020071c:	fd843783          	ld	a5,-40(s0)
    80200720:	0007c783          	lbu	a5,0(a5)
    80200724:	00078713          	mv	a4,a5
    80200728:	02b00793          	li	a5,43
    8020072c:	00f71863          	bne	a4,a5,8020073c <strtol+0xa8>
        p++;
    80200730:	fd843783          	ld	a5,-40(s0)
    80200734:	00178793          	addi	a5,a5,1
    80200738:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    8020073c:	fbc42783          	lw	a5,-68(s0)
    80200740:	0007879b          	sext.w	a5,a5
    80200744:	06079c63          	bnez	a5,802007bc <strtol+0x128>
        if (*p == '0') {
    80200748:	fd843783          	ld	a5,-40(s0)
    8020074c:	0007c783          	lbu	a5,0(a5)
    80200750:	00078713          	mv	a4,a5
    80200754:	03000793          	li	a5,48
    80200758:	04f71e63          	bne	a4,a5,802007b4 <strtol+0x120>
            p++;
    8020075c:	fd843783          	ld	a5,-40(s0)
    80200760:	00178793          	addi	a5,a5,1
    80200764:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200768:	fd843783          	ld	a5,-40(s0)
    8020076c:	0007c783          	lbu	a5,0(a5)
    80200770:	00078713          	mv	a4,a5
    80200774:	07800793          	li	a5,120
    80200778:	00f70c63          	beq	a4,a5,80200790 <strtol+0xfc>
    8020077c:	fd843783          	ld	a5,-40(s0)
    80200780:	0007c783          	lbu	a5,0(a5)
    80200784:	00078713          	mv	a4,a5
    80200788:	05800793          	li	a5,88
    8020078c:	00f71e63          	bne	a4,a5,802007a8 <strtol+0x114>
                base = 16;
    80200790:	01000793          	li	a5,16
    80200794:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200798:	fd843783          	ld	a5,-40(s0)
    8020079c:	00178793          	addi	a5,a5,1
    802007a0:	fcf43c23          	sd	a5,-40(s0)
    802007a4:	0180006f          	j	802007bc <strtol+0x128>
            } else {
                base = 8;
    802007a8:	00800793          	li	a5,8
    802007ac:	faf42e23          	sw	a5,-68(s0)
    802007b0:	00c0006f          	j	802007bc <strtol+0x128>
            }
        } else {
            base = 10;
    802007b4:	00a00793          	li	a5,10
    802007b8:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802007bc:	fd843783          	ld	a5,-40(s0)
    802007c0:	0007c783          	lbu	a5,0(a5)
    802007c4:	00078713          	mv	a4,a5
    802007c8:	02f00793          	li	a5,47
    802007cc:	02e7f863          	bgeu	a5,a4,802007fc <strtol+0x168>
    802007d0:	fd843783          	ld	a5,-40(s0)
    802007d4:	0007c783          	lbu	a5,0(a5)
    802007d8:	00078713          	mv	a4,a5
    802007dc:	03900793          	li	a5,57
    802007e0:	00e7ee63          	bltu	a5,a4,802007fc <strtol+0x168>
            digit = *p - '0';
    802007e4:	fd843783          	ld	a5,-40(s0)
    802007e8:	0007c783          	lbu	a5,0(a5)
    802007ec:	0007879b          	sext.w	a5,a5
    802007f0:	fd07879b          	addiw	a5,a5,-48
    802007f4:	fcf42a23          	sw	a5,-44(s0)
    802007f8:	0800006f          	j	80200878 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    802007fc:	fd843783          	ld	a5,-40(s0)
    80200800:	0007c783          	lbu	a5,0(a5)
    80200804:	00078713          	mv	a4,a5
    80200808:	06000793          	li	a5,96
    8020080c:	02e7f863          	bgeu	a5,a4,8020083c <strtol+0x1a8>
    80200810:	fd843783          	ld	a5,-40(s0)
    80200814:	0007c783          	lbu	a5,0(a5)
    80200818:	00078713          	mv	a4,a5
    8020081c:	07a00793          	li	a5,122
    80200820:	00e7ee63          	bltu	a5,a4,8020083c <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80200824:	fd843783          	ld	a5,-40(s0)
    80200828:	0007c783          	lbu	a5,0(a5)
    8020082c:	0007879b          	sext.w	a5,a5
    80200830:	fa97879b          	addiw	a5,a5,-87
    80200834:	fcf42a23          	sw	a5,-44(s0)
    80200838:	0400006f          	j	80200878 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    8020083c:	fd843783          	ld	a5,-40(s0)
    80200840:	0007c783          	lbu	a5,0(a5)
    80200844:	00078713          	mv	a4,a5
    80200848:	04000793          	li	a5,64
    8020084c:	06e7f863          	bgeu	a5,a4,802008bc <strtol+0x228>
    80200850:	fd843783          	ld	a5,-40(s0)
    80200854:	0007c783          	lbu	a5,0(a5)
    80200858:	00078713          	mv	a4,a5
    8020085c:	05a00793          	li	a5,90
    80200860:	04e7ee63          	bltu	a5,a4,802008bc <strtol+0x228>
            digit = *p - ('A' - 10);
    80200864:	fd843783          	ld	a5,-40(s0)
    80200868:	0007c783          	lbu	a5,0(a5)
    8020086c:	0007879b          	sext.w	a5,a5
    80200870:	fc97879b          	addiw	a5,a5,-55
    80200874:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200878:	fd442783          	lw	a5,-44(s0)
    8020087c:	00078713          	mv	a4,a5
    80200880:	fbc42783          	lw	a5,-68(s0)
    80200884:	0007071b          	sext.w	a4,a4
    80200888:	0007879b          	sext.w	a5,a5
    8020088c:	02f75663          	bge	a4,a5,802008b8 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    80200890:	fbc42703          	lw	a4,-68(s0)
    80200894:	fe843783          	ld	a5,-24(s0)
    80200898:	02f70733          	mul	a4,a4,a5
    8020089c:	fd442783          	lw	a5,-44(s0)
    802008a0:	00f707b3          	add	a5,a4,a5
    802008a4:	fef43423          	sd	a5,-24(s0)
        p++;
    802008a8:	fd843783          	ld	a5,-40(s0)
    802008ac:	00178793          	addi	a5,a5,1
    802008b0:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802008b4:	f09ff06f          	j	802007bc <strtol+0x128>
            break;
    802008b8:	00000013          	nop
    }

    if (endptr) {
    802008bc:	fc043783          	ld	a5,-64(s0)
    802008c0:	00078863          	beqz	a5,802008d0 <strtol+0x23c>
        *endptr = (char *)p;
    802008c4:	fc043783          	ld	a5,-64(s0)
    802008c8:	fd843703          	ld	a4,-40(s0)
    802008cc:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    802008d0:	fe744783          	lbu	a5,-25(s0)
    802008d4:	0ff7f793          	zext.b	a5,a5
    802008d8:	00078863          	beqz	a5,802008e8 <strtol+0x254>
    802008dc:	fe843783          	ld	a5,-24(s0)
    802008e0:	40f007b3          	neg	a5,a5
    802008e4:	0080006f          	j	802008ec <strtol+0x258>
    802008e8:	fe843783          	ld	a5,-24(s0)
}
    802008ec:	00078513          	mv	a0,a5
    802008f0:	04813083          	ld	ra,72(sp)
    802008f4:	04013403          	ld	s0,64(sp)
    802008f8:	05010113          	addi	sp,sp,80
    802008fc:	00008067          	ret

0000000080200900 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200900:	fd010113          	addi	sp,sp,-48
    80200904:	02113423          	sd	ra,40(sp)
    80200908:	02813023          	sd	s0,32(sp)
    8020090c:	03010413          	addi	s0,sp,48
    80200910:	fca43c23          	sd	a0,-40(s0)
    80200914:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200918:	fd043783          	ld	a5,-48(s0)
    8020091c:	00079863          	bnez	a5,8020092c <puts_wo_nl+0x2c>
        s = "(null)";
    80200920:	00001797          	auipc	a5,0x1
    80200924:	7e078793          	addi	a5,a5,2016 # 80202100 <_srodata+0x100>
    80200928:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    8020092c:	fd043783          	ld	a5,-48(s0)
    80200930:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80200934:	0240006f          	j	80200958 <puts_wo_nl+0x58>
        putch(*p++);
    80200938:	fe843783          	ld	a5,-24(s0)
    8020093c:	00178713          	addi	a4,a5,1
    80200940:	fee43423          	sd	a4,-24(s0)
    80200944:	0007c783          	lbu	a5,0(a5)
    80200948:	0007871b          	sext.w	a4,a5
    8020094c:	fd843783          	ld	a5,-40(s0)
    80200950:	00070513          	mv	a0,a4
    80200954:	000780e7          	jalr	a5
    while (*p) {
    80200958:	fe843783          	ld	a5,-24(s0)
    8020095c:	0007c783          	lbu	a5,0(a5)
    80200960:	fc079ce3          	bnez	a5,80200938 <puts_wo_nl+0x38>
    }
    return p - s;
    80200964:	fe843703          	ld	a4,-24(s0)
    80200968:	fd043783          	ld	a5,-48(s0)
    8020096c:	40f707b3          	sub	a5,a4,a5
    80200970:	0007879b          	sext.w	a5,a5
}
    80200974:	00078513          	mv	a0,a5
    80200978:	02813083          	ld	ra,40(sp)
    8020097c:	02013403          	ld	s0,32(sp)
    80200980:	03010113          	addi	sp,sp,48
    80200984:	00008067          	ret

0000000080200988 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200988:	f9010113          	addi	sp,sp,-112
    8020098c:	06113423          	sd	ra,104(sp)
    80200990:	06813023          	sd	s0,96(sp)
    80200994:	07010413          	addi	s0,sp,112
    80200998:	faa43423          	sd	a0,-88(s0)
    8020099c:	fab43023          	sd	a1,-96(s0)
    802009a0:	00060793          	mv	a5,a2
    802009a4:	f8d43823          	sd	a3,-112(s0)
    802009a8:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    802009ac:	f9f44783          	lbu	a5,-97(s0)
    802009b0:	0ff7f793          	zext.b	a5,a5
    802009b4:	02078663          	beqz	a5,802009e0 <print_dec_int+0x58>
    802009b8:	fa043703          	ld	a4,-96(s0)
    802009bc:	fff00793          	li	a5,-1
    802009c0:	03f79793          	slli	a5,a5,0x3f
    802009c4:	00f71e63          	bne	a4,a5,802009e0 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    802009c8:	00001597          	auipc	a1,0x1
    802009cc:	74058593          	addi	a1,a1,1856 # 80202108 <_srodata+0x108>
    802009d0:	fa843503          	ld	a0,-88(s0)
    802009d4:	f2dff0ef          	jal	80200900 <puts_wo_nl>
    802009d8:	00050793          	mv	a5,a0
    802009dc:	2a00006f          	j	80200c7c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    802009e0:	f9043783          	ld	a5,-112(s0)
    802009e4:	00c7a783          	lw	a5,12(a5)
    802009e8:	00079a63          	bnez	a5,802009fc <print_dec_int+0x74>
    802009ec:	fa043783          	ld	a5,-96(s0)
    802009f0:	00079663          	bnez	a5,802009fc <print_dec_int+0x74>
        return 0;
    802009f4:	00000793          	li	a5,0
    802009f8:	2840006f          	j	80200c7c <print_dec_int+0x2f4>
    }

    bool neg = false;
    802009fc:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200a00:	f9f44783          	lbu	a5,-97(s0)
    80200a04:	0ff7f793          	zext.b	a5,a5
    80200a08:	02078063          	beqz	a5,80200a28 <print_dec_int+0xa0>
    80200a0c:	fa043783          	ld	a5,-96(s0)
    80200a10:	0007dc63          	bgez	a5,80200a28 <print_dec_int+0xa0>
        neg = true;
    80200a14:	00100793          	li	a5,1
    80200a18:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200a1c:	fa043783          	ld	a5,-96(s0)
    80200a20:	40f007b3          	neg	a5,a5
    80200a24:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200a28:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200a2c:	f9f44783          	lbu	a5,-97(s0)
    80200a30:	0ff7f793          	zext.b	a5,a5
    80200a34:	02078863          	beqz	a5,80200a64 <print_dec_int+0xdc>
    80200a38:	fef44783          	lbu	a5,-17(s0)
    80200a3c:	0ff7f793          	zext.b	a5,a5
    80200a40:	00079e63          	bnez	a5,80200a5c <print_dec_int+0xd4>
    80200a44:	f9043783          	ld	a5,-112(s0)
    80200a48:	0057c783          	lbu	a5,5(a5)
    80200a4c:	00079863          	bnez	a5,80200a5c <print_dec_int+0xd4>
    80200a50:	f9043783          	ld	a5,-112(s0)
    80200a54:	0047c783          	lbu	a5,4(a5)
    80200a58:	00078663          	beqz	a5,80200a64 <print_dec_int+0xdc>
    80200a5c:	00100793          	li	a5,1
    80200a60:	0080006f          	j	80200a68 <print_dec_int+0xe0>
    80200a64:	00000793          	li	a5,0
    80200a68:	fcf40ba3          	sb	a5,-41(s0)
    80200a6c:	fd744783          	lbu	a5,-41(s0)
    80200a70:	0017f793          	andi	a5,a5,1
    80200a74:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200a78:	fa043703          	ld	a4,-96(s0)
    80200a7c:	00a00793          	li	a5,10
    80200a80:	02f777b3          	remu	a5,a4,a5
    80200a84:	0ff7f713          	zext.b	a4,a5
    80200a88:	fe842783          	lw	a5,-24(s0)
    80200a8c:	0017869b          	addiw	a3,a5,1
    80200a90:	fed42423          	sw	a3,-24(s0)
    80200a94:	0307071b          	addiw	a4,a4,48
    80200a98:	0ff77713          	zext.b	a4,a4
    80200a9c:	ff078793          	addi	a5,a5,-16
    80200aa0:	008787b3          	add	a5,a5,s0
    80200aa4:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200aa8:	fa043703          	ld	a4,-96(s0)
    80200aac:	00a00793          	li	a5,10
    80200ab0:	02f757b3          	divu	a5,a4,a5
    80200ab4:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200ab8:	fa043783          	ld	a5,-96(s0)
    80200abc:	fa079ee3          	bnez	a5,80200a78 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200ac0:	f9043783          	ld	a5,-112(s0)
    80200ac4:	00c7a783          	lw	a5,12(a5)
    80200ac8:	00078713          	mv	a4,a5
    80200acc:	fff00793          	li	a5,-1
    80200ad0:	02f71063          	bne	a4,a5,80200af0 <print_dec_int+0x168>
    80200ad4:	f9043783          	ld	a5,-112(s0)
    80200ad8:	0037c783          	lbu	a5,3(a5)
    80200adc:	00078a63          	beqz	a5,80200af0 <print_dec_int+0x168>
        flags->prec = flags->width;
    80200ae0:	f9043783          	ld	a5,-112(s0)
    80200ae4:	0087a703          	lw	a4,8(a5)
    80200ae8:	f9043783          	ld	a5,-112(s0)
    80200aec:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200af0:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200af4:	f9043783          	ld	a5,-112(s0)
    80200af8:	0087a703          	lw	a4,8(a5)
    80200afc:	fe842783          	lw	a5,-24(s0)
    80200b00:	fcf42823          	sw	a5,-48(s0)
    80200b04:	f9043783          	ld	a5,-112(s0)
    80200b08:	00c7a783          	lw	a5,12(a5)
    80200b0c:	fcf42623          	sw	a5,-52(s0)
    80200b10:	fd042783          	lw	a5,-48(s0)
    80200b14:	00078593          	mv	a1,a5
    80200b18:	fcc42783          	lw	a5,-52(s0)
    80200b1c:	00078613          	mv	a2,a5
    80200b20:	0006069b          	sext.w	a3,a2
    80200b24:	0005879b          	sext.w	a5,a1
    80200b28:	00f6d463          	bge	a3,a5,80200b30 <print_dec_int+0x1a8>
    80200b2c:	00058613          	mv	a2,a1
    80200b30:	0006079b          	sext.w	a5,a2
    80200b34:	40f707bb          	subw	a5,a4,a5
    80200b38:	0007871b          	sext.w	a4,a5
    80200b3c:	fd744783          	lbu	a5,-41(s0)
    80200b40:	0007879b          	sext.w	a5,a5
    80200b44:	40f707bb          	subw	a5,a4,a5
    80200b48:	fef42023          	sw	a5,-32(s0)
    80200b4c:	0280006f          	j	80200b74 <print_dec_int+0x1ec>
        putch(' ');
    80200b50:	fa843783          	ld	a5,-88(s0)
    80200b54:	02000513          	li	a0,32
    80200b58:	000780e7          	jalr	a5
        ++written;
    80200b5c:	fe442783          	lw	a5,-28(s0)
    80200b60:	0017879b          	addiw	a5,a5,1
    80200b64:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b68:	fe042783          	lw	a5,-32(s0)
    80200b6c:	fff7879b          	addiw	a5,a5,-1
    80200b70:	fef42023          	sw	a5,-32(s0)
    80200b74:	fe042783          	lw	a5,-32(s0)
    80200b78:	0007879b          	sext.w	a5,a5
    80200b7c:	fcf04ae3          	bgtz	a5,80200b50 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200b80:	fd744783          	lbu	a5,-41(s0)
    80200b84:	0ff7f793          	zext.b	a5,a5
    80200b88:	04078463          	beqz	a5,80200bd0 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200b8c:	fef44783          	lbu	a5,-17(s0)
    80200b90:	0ff7f793          	zext.b	a5,a5
    80200b94:	00078663          	beqz	a5,80200ba0 <print_dec_int+0x218>
    80200b98:	02d00793          	li	a5,45
    80200b9c:	01c0006f          	j	80200bb8 <print_dec_int+0x230>
    80200ba0:	f9043783          	ld	a5,-112(s0)
    80200ba4:	0057c783          	lbu	a5,5(a5)
    80200ba8:	00078663          	beqz	a5,80200bb4 <print_dec_int+0x22c>
    80200bac:	02b00793          	li	a5,43
    80200bb0:	0080006f          	j	80200bb8 <print_dec_int+0x230>
    80200bb4:	02000793          	li	a5,32
    80200bb8:	fa843703          	ld	a4,-88(s0)
    80200bbc:	00078513          	mv	a0,a5
    80200bc0:	000700e7          	jalr	a4
        ++written;
    80200bc4:	fe442783          	lw	a5,-28(s0)
    80200bc8:	0017879b          	addiw	a5,a5,1
    80200bcc:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200bd0:	fe842783          	lw	a5,-24(s0)
    80200bd4:	fcf42e23          	sw	a5,-36(s0)
    80200bd8:	0280006f          	j	80200c00 <print_dec_int+0x278>
        putch('0');
    80200bdc:	fa843783          	ld	a5,-88(s0)
    80200be0:	03000513          	li	a0,48
    80200be4:	000780e7          	jalr	a5
        ++written;
    80200be8:	fe442783          	lw	a5,-28(s0)
    80200bec:	0017879b          	addiw	a5,a5,1
    80200bf0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200bf4:	fdc42783          	lw	a5,-36(s0)
    80200bf8:	0017879b          	addiw	a5,a5,1
    80200bfc:	fcf42e23          	sw	a5,-36(s0)
    80200c00:	f9043783          	ld	a5,-112(s0)
    80200c04:	00c7a703          	lw	a4,12(a5)
    80200c08:	fd744783          	lbu	a5,-41(s0)
    80200c0c:	0007879b          	sext.w	a5,a5
    80200c10:	40f707bb          	subw	a5,a4,a5
    80200c14:	0007871b          	sext.w	a4,a5
    80200c18:	fdc42783          	lw	a5,-36(s0)
    80200c1c:	0007879b          	sext.w	a5,a5
    80200c20:	fae7cee3          	blt	a5,a4,80200bdc <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200c24:	fe842783          	lw	a5,-24(s0)
    80200c28:	fff7879b          	addiw	a5,a5,-1
    80200c2c:	fcf42c23          	sw	a5,-40(s0)
    80200c30:	03c0006f          	j	80200c6c <print_dec_int+0x2e4>
        putch(buf[i]);
    80200c34:	fd842783          	lw	a5,-40(s0)
    80200c38:	ff078793          	addi	a5,a5,-16
    80200c3c:	008787b3          	add	a5,a5,s0
    80200c40:	fc87c783          	lbu	a5,-56(a5)
    80200c44:	0007871b          	sext.w	a4,a5
    80200c48:	fa843783          	ld	a5,-88(s0)
    80200c4c:	00070513          	mv	a0,a4
    80200c50:	000780e7          	jalr	a5
        ++written;
    80200c54:	fe442783          	lw	a5,-28(s0)
    80200c58:	0017879b          	addiw	a5,a5,1
    80200c5c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200c60:	fd842783          	lw	a5,-40(s0)
    80200c64:	fff7879b          	addiw	a5,a5,-1
    80200c68:	fcf42c23          	sw	a5,-40(s0)
    80200c6c:	fd842783          	lw	a5,-40(s0)
    80200c70:	0007879b          	sext.w	a5,a5
    80200c74:	fc07d0e3          	bgez	a5,80200c34 <print_dec_int+0x2ac>
    }

    return written;
    80200c78:	fe442783          	lw	a5,-28(s0)
}
    80200c7c:	00078513          	mv	a0,a5
    80200c80:	06813083          	ld	ra,104(sp)
    80200c84:	06013403          	ld	s0,96(sp)
    80200c88:	07010113          	addi	sp,sp,112
    80200c8c:	00008067          	ret

0000000080200c90 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200c90:	f4010113          	addi	sp,sp,-192
    80200c94:	0a113c23          	sd	ra,184(sp)
    80200c98:	0a813823          	sd	s0,176(sp)
    80200c9c:	0c010413          	addi	s0,sp,192
    80200ca0:	f4a43c23          	sd	a0,-168(s0)
    80200ca4:	f4b43823          	sd	a1,-176(s0)
    80200ca8:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200cac:	f8043023          	sd	zero,-128(s0)
    80200cb0:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200cb4:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200cb8:	7a40006f          	j	8020145c <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200cbc:	f8044783          	lbu	a5,-128(s0)
    80200cc0:	72078e63          	beqz	a5,802013fc <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200cc4:	f5043783          	ld	a5,-176(s0)
    80200cc8:	0007c783          	lbu	a5,0(a5)
    80200ccc:	00078713          	mv	a4,a5
    80200cd0:	02300793          	li	a5,35
    80200cd4:	00f71863          	bne	a4,a5,80200ce4 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200cd8:	00100793          	li	a5,1
    80200cdc:	f8f40123          	sb	a5,-126(s0)
    80200ce0:	7700006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200ce4:	f5043783          	ld	a5,-176(s0)
    80200ce8:	0007c783          	lbu	a5,0(a5)
    80200cec:	00078713          	mv	a4,a5
    80200cf0:	03000793          	li	a5,48
    80200cf4:	00f71863          	bne	a4,a5,80200d04 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200cf8:	00100793          	li	a5,1
    80200cfc:	f8f401a3          	sb	a5,-125(s0)
    80200d00:	7500006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200d04:	f5043783          	ld	a5,-176(s0)
    80200d08:	0007c783          	lbu	a5,0(a5)
    80200d0c:	00078713          	mv	a4,a5
    80200d10:	06c00793          	li	a5,108
    80200d14:	04f70063          	beq	a4,a5,80200d54 <vprintfmt+0xc4>
    80200d18:	f5043783          	ld	a5,-176(s0)
    80200d1c:	0007c783          	lbu	a5,0(a5)
    80200d20:	00078713          	mv	a4,a5
    80200d24:	07a00793          	li	a5,122
    80200d28:	02f70663          	beq	a4,a5,80200d54 <vprintfmt+0xc4>
    80200d2c:	f5043783          	ld	a5,-176(s0)
    80200d30:	0007c783          	lbu	a5,0(a5)
    80200d34:	00078713          	mv	a4,a5
    80200d38:	07400793          	li	a5,116
    80200d3c:	00f70c63          	beq	a4,a5,80200d54 <vprintfmt+0xc4>
    80200d40:	f5043783          	ld	a5,-176(s0)
    80200d44:	0007c783          	lbu	a5,0(a5)
    80200d48:	00078713          	mv	a4,a5
    80200d4c:	06a00793          	li	a5,106
    80200d50:	00f71863          	bne	a4,a5,80200d60 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200d54:	00100793          	li	a5,1
    80200d58:	f8f400a3          	sb	a5,-127(s0)
    80200d5c:	6f40006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200d60:	f5043783          	ld	a5,-176(s0)
    80200d64:	0007c783          	lbu	a5,0(a5)
    80200d68:	00078713          	mv	a4,a5
    80200d6c:	02b00793          	li	a5,43
    80200d70:	00f71863          	bne	a4,a5,80200d80 <vprintfmt+0xf0>
                flags.sign = true;
    80200d74:	00100793          	li	a5,1
    80200d78:	f8f402a3          	sb	a5,-123(s0)
    80200d7c:	6d40006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200d80:	f5043783          	ld	a5,-176(s0)
    80200d84:	0007c783          	lbu	a5,0(a5)
    80200d88:	00078713          	mv	a4,a5
    80200d8c:	02000793          	li	a5,32
    80200d90:	00f71863          	bne	a4,a5,80200da0 <vprintfmt+0x110>
                flags.spaceflag = true;
    80200d94:	00100793          	li	a5,1
    80200d98:	f8f40223          	sb	a5,-124(s0)
    80200d9c:	6b40006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200da0:	f5043783          	ld	a5,-176(s0)
    80200da4:	0007c783          	lbu	a5,0(a5)
    80200da8:	00078713          	mv	a4,a5
    80200dac:	02a00793          	li	a5,42
    80200db0:	00f71e63          	bne	a4,a5,80200dcc <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200db4:	f4843783          	ld	a5,-184(s0)
    80200db8:	00878713          	addi	a4,a5,8
    80200dbc:	f4e43423          	sd	a4,-184(s0)
    80200dc0:	0007a783          	lw	a5,0(a5)
    80200dc4:	f8f42423          	sw	a5,-120(s0)
    80200dc8:	6880006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200dcc:	f5043783          	ld	a5,-176(s0)
    80200dd0:	0007c783          	lbu	a5,0(a5)
    80200dd4:	00078713          	mv	a4,a5
    80200dd8:	03000793          	li	a5,48
    80200ddc:	04e7f663          	bgeu	a5,a4,80200e28 <vprintfmt+0x198>
    80200de0:	f5043783          	ld	a5,-176(s0)
    80200de4:	0007c783          	lbu	a5,0(a5)
    80200de8:	00078713          	mv	a4,a5
    80200dec:	03900793          	li	a5,57
    80200df0:	02e7ec63          	bltu	a5,a4,80200e28 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200df4:	f5043783          	ld	a5,-176(s0)
    80200df8:	f5040713          	addi	a4,s0,-176
    80200dfc:	00a00613          	li	a2,10
    80200e00:	00070593          	mv	a1,a4
    80200e04:	00078513          	mv	a0,a5
    80200e08:	88dff0ef          	jal	80200694 <strtol>
    80200e0c:	00050793          	mv	a5,a0
    80200e10:	0007879b          	sext.w	a5,a5
    80200e14:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200e18:	f5043783          	ld	a5,-176(s0)
    80200e1c:	fff78793          	addi	a5,a5,-1
    80200e20:	f4f43823          	sd	a5,-176(s0)
    80200e24:	62c0006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200e28:	f5043783          	ld	a5,-176(s0)
    80200e2c:	0007c783          	lbu	a5,0(a5)
    80200e30:	00078713          	mv	a4,a5
    80200e34:	02e00793          	li	a5,46
    80200e38:	06f71863          	bne	a4,a5,80200ea8 <vprintfmt+0x218>
                fmt++;
    80200e3c:	f5043783          	ld	a5,-176(s0)
    80200e40:	00178793          	addi	a5,a5,1
    80200e44:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200e48:	f5043783          	ld	a5,-176(s0)
    80200e4c:	0007c783          	lbu	a5,0(a5)
    80200e50:	00078713          	mv	a4,a5
    80200e54:	02a00793          	li	a5,42
    80200e58:	00f71e63          	bne	a4,a5,80200e74 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200e5c:	f4843783          	ld	a5,-184(s0)
    80200e60:	00878713          	addi	a4,a5,8
    80200e64:	f4e43423          	sd	a4,-184(s0)
    80200e68:	0007a783          	lw	a5,0(a5)
    80200e6c:	f8f42623          	sw	a5,-116(s0)
    80200e70:	5e00006f          	j	80201450 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200e74:	f5043783          	ld	a5,-176(s0)
    80200e78:	f5040713          	addi	a4,s0,-176
    80200e7c:	00a00613          	li	a2,10
    80200e80:	00070593          	mv	a1,a4
    80200e84:	00078513          	mv	a0,a5
    80200e88:	80dff0ef          	jal	80200694 <strtol>
    80200e8c:	00050793          	mv	a5,a0
    80200e90:	0007879b          	sext.w	a5,a5
    80200e94:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200e98:	f5043783          	ld	a5,-176(s0)
    80200e9c:	fff78793          	addi	a5,a5,-1
    80200ea0:	f4f43823          	sd	a5,-176(s0)
    80200ea4:	5ac0006f          	j	80201450 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200ea8:	f5043783          	ld	a5,-176(s0)
    80200eac:	0007c783          	lbu	a5,0(a5)
    80200eb0:	00078713          	mv	a4,a5
    80200eb4:	07800793          	li	a5,120
    80200eb8:	02f70663          	beq	a4,a5,80200ee4 <vprintfmt+0x254>
    80200ebc:	f5043783          	ld	a5,-176(s0)
    80200ec0:	0007c783          	lbu	a5,0(a5)
    80200ec4:	00078713          	mv	a4,a5
    80200ec8:	05800793          	li	a5,88
    80200ecc:	00f70c63          	beq	a4,a5,80200ee4 <vprintfmt+0x254>
    80200ed0:	f5043783          	ld	a5,-176(s0)
    80200ed4:	0007c783          	lbu	a5,0(a5)
    80200ed8:	00078713          	mv	a4,a5
    80200edc:	07000793          	li	a5,112
    80200ee0:	30f71263          	bne	a4,a5,802011e4 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200ee4:	f5043783          	ld	a5,-176(s0)
    80200ee8:	0007c783          	lbu	a5,0(a5)
    80200eec:	00078713          	mv	a4,a5
    80200ef0:	07000793          	li	a5,112
    80200ef4:	00f70663          	beq	a4,a5,80200f00 <vprintfmt+0x270>
    80200ef8:	f8144783          	lbu	a5,-127(s0)
    80200efc:	00078663          	beqz	a5,80200f08 <vprintfmt+0x278>
    80200f00:	00100793          	li	a5,1
    80200f04:	0080006f          	j	80200f0c <vprintfmt+0x27c>
    80200f08:	00000793          	li	a5,0
    80200f0c:	faf403a3          	sb	a5,-89(s0)
    80200f10:	fa744783          	lbu	a5,-89(s0)
    80200f14:	0017f793          	andi	a5,a5,1
    80200f18:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200f1c:	fa744783          	lbu	a5,-89(s0)
    80200f20:	0ff7f793          	zext.b	a5,a5
    80200f24:	00078c63          	beqz	a5,80200f3c <vprintfmt+0x2ac>
    80200f28:	f4843783          	ld	a5,-184(s0)
    80200f2c:	00878713          	addi	a4,a5,8
    80200f30:	f4e43423          	sd	a4,-184(s0)
    80200f34:	0007b783          	ld	a5,0(a5)
    80200f38:	01c0006f          	j	80200f54 <vprintfmt+0x2c4>
    80200f3c:	f4843783          	ld	a5,-184(s0)
    80200f40:	00878713          	addi	a4,a5,8
    80200f44:	f4e43423          	sd	a4,-184(s0)
    80200f48:	0007a783          	lw	a5,0(a5)
    80200f4c:	02079793          	slli	a5,a5,0x20
    80200f50:	0207d793          	srli	a5,a5,0x20
    80200f54:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200f58:	f8c42783          	lw	a5,-116(s0)
    80200f5c:	02079463          	bnez	a5,80200f84 <vprintfmt+0x2f4>
    80200f60:	fe043783          	ld	a5,-32(s0)
    80200f64:	02079063          	bnez	a5,80200f84 <vprintfmt+0x2f4>
    80200f68:	f5043783          	ld	a5,-176(s0)
    80200f6c:	0007c783          	lbu	a5,0(a5)
    80200f70:	00078713          	mv	a4,a5
    80200f74:	07000793          	li	a5,112
    80200f78:	00f70663          	beq	a4,a5,80200f84 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200f7c:	f8040023          	sb	zero,-128(s0)
    80200f80:	4d00006f          	j	80201450 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200f84:	f5043783          	ld	a5,-176(s0)
    80200f88:	0007c783          	lbu	a5,0(a5)
    80200f8c:	00078713          	mv	a4,a5
    80200f90:	07000793          	li	a5,112
    80200f94:	00f70a63          	beq	a4,a5,80200fa8 <vprintfmt+0x318>
    80200f98:	f8244783          	lbu	a5,-126(s0)
    80200f9c:	00078a63          	beqz	a5,80200fb0 <vprintfmt+0x320>
    80200fa0:	fe043783          	ld	a5,-32(s0)
    80200fa4:	00078663          	beqz	a5,80200fb0 <vprintfmt+0x320>
    80200fa8:	00100793          	li	a5,1
    80200fac:	0080006f          	j	80200fb4 <vprintfmt+0x324>
    80200fb0:	00000793          	li	a5,0
    80200fb4:	faf40323          	sb	a5,-90(s0)
    80200fb8:	fa644783          	lbu	a5,-90(s0)
    80200fbc:	0017f793          	andi	a5,a5,1
    80200fc0:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80200fc4:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80200fc8:	f5043783          	ld	a5,-176(s0)
    80200fcc:	0007c783          	lbu	a5,0(a5)
    80200fd0:	00078713          	mv	a4,a5
    80200fd4:	05800793          	li	a5,88
    80200fd8:	00f71863          	bne	a4,a5,80200fe8 <vprintfmt+0x358>
    80200fdc:	00001797          	auipc	a5,0x1
    80200fe0:	14478793          	addi	a5,a5,324 # 80202120 <upperxdigits.1>
    80200fe4:	00c0006f          	j	80200ff0 <vprintfmt+0x360>
    80200fe8:	00001797          	auipc	a5,0x1
    80200fec:	15078793          	addi	a5,a5,336 # 80202138 <lowerxdigits.0>
    80200ff0:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80200ff4:	fe043783          	ld	a5,-32(s0)
    80200ff8:	00f7f793          	andi	a5,a5,15
    80200ffc:	f9843703          	ld	a4,-104(s0)
    80201000:	00f70733          	add	a4,a4,a5
    80201004:	fdc42783          	lw	a5,-36(s0)
    80201008:	0017869b          	addiw	a3,a5,1
    8020100c:	fcd42e23          	sw	a3,-36(s0)
    80201010:	00074703          	lbu	a4,0(a4)
    80201014:	ff078793          	addi	a5,a5,-16
    80201018:	008787b3          	add	a5,a5,s0
    8020101c:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80201020:	fe043783          	ld	a5,-32(s0)
    80201024:	0047d793          	srli	a5,a5,0x4
    80201028:	fef43023          	sd	a5,-32(s0)
                } while (num);
    8020102c:	fe043783          	ld	a5,-32(s0)
    80201030:	fc0792e3          	bnez	a5,80200ff4 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201034:	f8c42783          	lw	a5,-116(s0)
    80201038:	00078713          	mv	a4,a5
    8020103c:	fff00793          	li	a5,-1
    80201040:	02f71663          	bne	a4,a5,8020106c <vprintfmt+0x3dc>
    80201044:	f8344783          	lbu	a5,-125(s0)
    80201048:	02078263          	beqz	a5,8020106c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    8020104c:	f8842703          	lw	a4,-120(s0)
    80201050:	fa644783          	lbu	a5,-90(s0)
    80201054:	0007879b          	sext.w	a5,a5
    80201058:	0017979b          	slliw	a5,a5,0x1
    8020105c:	0007879b          	sext.w	a5,a5
    80201060:	40f707bb          	subw	a5,a4,a5
    80201064:	0007879b          	sext.w	a5,a5
    80201068:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    8020106c:	f8842703          	lw	a4,-120(s0)
    80201070:	fa644783          	lbu	a5,-90(s0)
    80201074:	0007879b          	sext.w	a5,a5
    80201078:	0017979b          	slliw	a5,a5,0x1
    8020107c:	0007879b          	sext.w	a5,a5
    80201080:	40f707bb          	subw	a5,a4,a5
    80201084:	0007871b          	sext.w	a4,a5
    80201088:	fdc42783          	lw	a5,-36(s0)
    8020108c:	f8f42a23          	sw	a5,-108(s0)
    80201090:	f8c42783          	lw	a5,-116(s0)
    80201094:	f8f42823          	sw	a5,-112(s0)
    80201098:	f9442783          	lw	a5,-108(s0)
    8020109c:	00078593          	mv	a1,a5
    802010a0:	f9042783          	lw	a5,-112(s0)
    802010a4:	00078613          	mv	a2,a5
    802010a8:	0006069b          	sext.w	a3,a2
    802010ac:	0005879b          	sext.w	a5,a1
    802010b0:	00f6d463          	bge	a3,a5,802010b8 <vprintfmt+0x428>
    802010b4:	00058613          	mv	a2,a1
    802010b8:	0006079b          	sext.w	a5,a2
    802010bc:	40f707bb          	subw	a5,a4,a5
    802010c0:	fcf42c23          	sw	a5,-40(s0)
    802010c4:	0280006f          	j	802010ec <vprintfmt+0x45c>
                    putch(' ');
    802010c8:	f5843783          	ld	a5,-168(s0)
    802010cc:	02000513          	li	a0,32
    802010d0:	000780e7          	jalr	a5
                    ++written;
    802010d4:	fec42783          	lw	a5,-20(s0)
    802010d8:	0017879b          	addiw	a5,a5,1
    802010dc:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802010e0:	fd842783          	lw	a5,-40(s0)
    802010e4:	fff7879b          	addiw	a5,a5,-1
    802010e8:	fcf42c23          	sw	a5,-40(s0)
    802010ec:	fd842783          	lw	a5,-40(s0)
    802010f0:	0007879b          	sext.w	a5,a5
    802010f4:	fcf04ae3          	bgtz	a5,802010c8 <vprintfmt+0x438>
                }

                if (prefix) {
    802010f8:	fa644783          	lbu	a5,-90(s0)
    802010fc:	0ff7f793          	zext.b	a5,a5
    80201100:	04078463          	beqz	a5,80201148 <vprintfmt+0x4b8>
                    putch('0');
    80201104:	f5843783          	ld	a5,-168(s0)
    80201108:	03000513          	li	a0,48
    8020110c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201110:	f5043783          	ld	a5,-176(s0)
    80201114:	0007c783          	lbu	a5,0(a5)
    80201118:	00078713          	mv	a4,a5
    8020111c:	05800793          	li	a5,88
    80201120:	00f71663          	bne	a4,a5,8020112c <vprintfmt+0x49c>
    80201124:	05800793          	li	a5,88
    80201128:	0080006f          	j	80201130 <vprintfmt+0x4a0>
    8020112c:	07800793          	li	a5,120
    80201130:	f5843703          	ld	a4,-168(s0)
    80201134:	00078513          	mv	a0,a5
    80201138:	000700e7          	jalr	a4
                    written += 2;
    8020113c:	fec42783          	lw	a5,-20(s0)
    80201140:	0027879b          	addiw	a5,a5,2
    80201144:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201148:	fdc42783          	lw	a5,-36(s0)
    8020114c:	fcf42a23          	sw	a5,-44(s0)
    80201150:	0280006f          	j	80201178 <vprintfmt+0x4e8>
                    putch('0');
    80201154:	f5843783          	ld	a5,-168(s0)
    80201158:	03000513          	li	a0,48
    8020115c:	000780e7          	jalr	a5
                    ++written;
    80201160:	fec42783          	lw	a5,-20(s0)
    80201164:	0017879b          	addiw	a5,a5,1
    80201168:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    8020116c:	fd442783          	lw	a5,-44(s0)
    80201170:	0017879b          	addiw	a5,a5,1
    80201174:	fcf42a23          	sw	a5,-44(s0)
    80201178:	f8c42703          	lw	a4,-116(s0)
    8020117c:	fd442783          	lw	a5,-44(s0)
    80201180:	0007879b          	sext.w	a5,a5
    80201184:	fce7c8e3          	blt	a5,a4,80201154 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201188:	fdc42783          	lw	a5,-36(s0)
    8020118c:	fff7879b          	addiw	a5,a5,-1
    80201190:	fcf42823          	sw	a5,-48(s0)
    80201194:	03c0006f          	j	802011d0 <vprintfmt+0x540>
                    putch(buf[i]);
    80201198:	fd042783          	lw	a5,-48(s0)
    8020119c:	ff078793          	addi	a5,a5,-16
    802011a0:	008787b3          	add	a5,a5,s0
    802011a4:	f807c783          	lbu	a5,-128(a5)
    802011a8:	0007871b          	sext.w	a4,a5
    802011ac:	f5843783          	ld	a5,-168(s0)
    802011b0:	00070513          	mv	a0,a4
    802011b4:	000780e7          	jalr	a5
                    ++written;
    802011b8:	fec42783          	lw	a5,-20(s0)
    802011bc:	0017879b          	addiw	a5,a5,1
    802011c0:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    802011c4:	fd042783          	lw	a5,-48(s0)
    802011c8:	fff7879b          	addiw	a5,a5,-1
    802011cc:	fcf42823          	sw	a5,-48(s0)
    802011d0:	fd042783          	lw	a5,-48(s0)
    802011d4:	0007879b          	sext.w	a5,a5
    802011d8:	fc07d0e3          	bgez	a5,80201198 <vprintfmt+0x508>
                }

                flags.in_format = false;
    802011dc:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802011e0:	2700006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802011e4:	f5043783          	ld	a5,-176(s0)
    802011e8:	0007c783          	lbu	a5,0(a5)
    802011ec:	00078713          	mv	a4,a5
    802011f0:	06400793          	li	a5,100
    802011f4:	02f70663          	beq	a4,a5,80201220 <vprintfmt+0x590>
    802011f8:	f5043783          	ld	a5,-176(s0)
    802011fc:	0007c783          	lbu	a5,0(a5)
    80201200:	00078713          	mv	a4,a5
    80201204:	06900793          	li	a5,105
    80201208:	00f70c63          	beq	a4,a5,80201220 <vprintfmt+0x590>
    8020120c:	f5043783          	ld	a5,-176(s0)
    80201210:	0007c783          	lbu	a5,0(a5)
    80201214:	00078713          	mv	a4,a5
    80201218:	07500793          	li	a5,117
    8020121c:	08f71063          	bne	a4,a5,8020129c <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201220:	f8144783          	lbu	a5,-127(s0)
    80201224:	00078c63          	beqz	a5,8020123c <vprintfmt+0x5ac>
    80201228:	f4843783          	ld	a5,-184(s0)
    8020122c:	00878713          	addi	a4,a5,8
    80201230:	f4e43423          	sd	a4,-184(s0)
    80201234:	0007b783          	ld	a5,0(a5)
    80201238:	0140006f          	j	8020124c <vprintfmt+0x5bc>
    8020123c:	f4843783          	ld	a5,-184(s0)
    80201240:	00878713          	addi	a4,a5,8
    80201244:	f4e43423          	sd	a4,-184(s0)
    80201248:	0007a783          	lw	a5,0(a5)
    8020124c:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201250:	fa843583          	ld	a1,-88(s0)
    80201254:	f5043783          	ld	a5,-176(s0)
    80201258:	0007c783          	lbu	a5,0(a5)
    8020125c:	0007871b          	sext.w	a4,a5
    80201260:	07500793          	li	a5,117
    80201264:	40f707b3          	sub	a5,a4,a5
    80201268:	00f037b3          	snez	a5,a5
    8020126c:	0ff7f793          	zext.b	a5,a5
    80201270:	f8040713          	addi	a4,s0,-128
    80201274:	00070693          	mv	a3,a4
    80201278:	00078613          	mv	a2,a5
    8020127c:	f5843503          	ld	a0,-168(s0)
    80201280:	f08ff0ef          	jal	80200988 <print_dec_int>
    80201284:	00050793          	mv	a5,a0
    80201288:	fec42703          	lw	a4,-20(s0)
    8020128c:	00f707bb          	addw	a5,a4,a5
    80201290:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201294:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201298:	1b80006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    8020129c:	f5043783          	ld	a5,-176(s0)
    802012a0:	0007c783          	lbu	a5,0(a5)
    802012a4:	00078713          	mv	a4,a5
    802012a8:	06e00793          	li	a5,110
    802012ac:	04f71c63          	bne	a4,a5,80201304 <vprintfmt+0x674>
                if (flags.longflag) {
    802012b0:	f8144783          	lbu	a5,-127(s0)
    802012b4:	02078463          	beqz	a5,802012dc <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    802012b8:	f4843783          	ld	a5,-184(s0)
    802012bc:	00878713          	addi	a4,a5,8
    802012c0:	f4e43423          	sd	a4,-184(s0)
    802012c4:	0007b783          	ld	a5,0(a5)
    802012c8:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    802012cc:	fec42703          	lw	a4,-20(s0)
    802012d0:	fb043783          	ld	a5,-80(s0)
    802012d4:	00e7b023          	sd	a4,0(a5)
    802012d8:	0240006f          	j	802012fc <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    802012dc:	f4843783          	ld	a5,-184(s0)
    802012e0:	00878713          	addi	a4,a5,8
    802012e4:	f4e43423          	sd	a4,-184(s0)
    802012e8:	0007b783          	ld	a5,0(a5)
    802012ec:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    802012f0:	fb843783          	ld	a5,-72(s0)
    802012f4:	fec42703          	lw	a4,-20(s0)
    802012f8:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    802012fc:	f8040023          	sb	zero,-128(s0)
    80201300:	1500006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201304:	f5043783          	ld	a5,-176(s0)
    80201308:	0007c783          	lbu	a5,0(a5)
    8020130c:	00078713          	mv	a4,a5
    80201310:	07300793          	li	a5,115
    80201314:	02f71e63          	bne	a4,a5,80201350 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201318:	f4843783          	ld	a5,-184(s0)
    8020131c:	00878713          	addi	a4,a5,8
    80201320:	f4e43423          	sd	a4,-184(s0)
    80201324:	0007b783          	ld	a5,0(a5)
    80201328:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    8020132c:	fc043583          	ld	a1,-64(s0)
    80201330:	f5843503          	ld	a0,-168(s0)
    80201334:	dccff0ef          	jal	80200900 <puts_wo_nl>
    80201338:	00050793          	mv	a5,a0
    8020133c:	fec42703          	lw	a4,-20(s0)
    80201340:	00f707bb          	addw	a5,a4,a5
    80201344:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201348:	f8040023          	sb	zero,-128(s0)
    8020134c:	1040006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201350:	f5043783          	ld	a5,-176(s0)
    80201354:	0007c783          	lbu	a5,0(a5)
    80201358:	00078713          	mv	a4,a5
    8020135c:	06300793          	li	a5,99
    80201360:	02f71e63          	bne	a4,a5,8020139c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201364:	f4843783          	ld	a5,-184(s0)
    80201368:	00878713          	addi	a4,a5,8
    8020136c:	f4e43423          	sd	a4,-184(s0)
    80201370:	0007a783          	lw	a5,0(a5)
    80201374:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201378:	fcc42703          	lw	a4,-52(s0)
    8020137c:	f5843783          	ld	a5,-168(s0)
    80201380:	00070513          	mv	a0,a4
    80201384:	000780e7          	jalr	a5
                ++written;
    80201388:	fec42783          	lw	a5,-20(s0)
    8020138c:	0017879b          	addiw	a5,a5,1
    80201390:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201394:	f8040023          	sb	zero,-128(s0)
    80201398:	0b80006f          	j	80201450 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    8020139c:	f5043783          	ld	a5,-176(s0)
    802013a0:	0007c783          	lbu	a5,0(a5)
    802013a4:	00078713          	mv	a4,a5
    802013a8:	02500793          	li	a5,37
    802013ac:	02f71263          	bne	a4,a5,802013d0 <vprintfmt+0x740>
                putch('%');
    802013b0:	f5843783          	ld	a5,-168(s0)
    802013b4:	02500513          	li	a0,37
    802013b8:	000780e7          	jalr	a5
                ++written;
    802013bc:	fec42783          	lw	a5,-20(s0)
    802013c0:	0017879b          	addiw	a5,a5,1
    802013c4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013c8:	f8040023          	sb	zero,-128(s0)
    802013cc:	0840006f          	j	80201450 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    802013d0:	f5043783          	ld	a5,-176(s0)
    802013d4:	0007c783          	lbu	a5,0(a5)
    802013d8:	0007871b          	sext.w	a4,a5
    802013dc:	f5843783          	ld	a5,-168(s0)
    802013e0:	00070513          	mv	a0,a4
    802013e4:	000780e7          	jalr	a5
                ++written;
    802013e8:	fec42783          	lw	a5,-20(s0)
    802013ec:	0017879b          	addiw	a5,a5,1
    802013f0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013f4:	f8040023          	sb	zero,-128(s0)
    802013f8:	0580006f          	j	80201450 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    802013fc:	f5043783          	ld	a5,-176(s0)
    80201400:	0007c783          	lbu	a5,0(a5)
    80201404:	00078713          	mv	a4,a5
    80201408:	02500793          	li	a5,37
    8020140c:	02f71063          	bne	a4,a5,8020142c <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201410:	f8043023          	sd	zero,-128(s0)
    80201414:	f8043423          	sd	zero,-120(s0)
    80201418:	00100793          	li	a5,1
    8020141c:	f8f40023          	sb	a5,-128(s0)
    80201420:	fff00793          	li	a5,-1
    80201424:	f8f42623          	sw	a5,-116(s0)
    80201428:	0280006f          	j	80201450 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    8020142c:	f5043783          	ld	a5,-176(s0)
    80201430:	0007c783          	lbu	a5,0(a5)
    80201434:	0007871b          	sext.w	a4,a5
    80201438:	f5843783          	ld	a5,-168(s0)
    8020143c:	00070513          	mv	a0,a4
    80201440:	000780e7          	jalr	a5
            ++written;
    80201444:	fec42783          	lw	a5,-20(s0)
    80201448:	0017879b          	addiw	a5,a5,1
    8020144c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201450:	f5043783          	ld	a5,-176(s0)
    80201454:	00178793          	addi	a5,a5,1
    80201458:	f4f43823          	sd	a5,-176(s0)
    8020145c:	f5043783          	ld	a5,-176(s0)
    80201460:	0007c783          	lbu	a5,0(a5)
    80201464:	84079ce3          	bnez	a5,80200cbc <vprintfmt+0x2c>
        }
    }

    return written;
    80201468:	fec42783          	lw	a5,-20(s0)
}
    8020146c:	00078513          	mv	a0,a5
    80201470:	0b813083          	ld	ra,184(sp)
    80201474:	0b013403          	ld	s0,176(sp)
    80201478:	0c010113          	addi	sp,sp,192
    8020147c:	00008067          	ret

0000000080201480 <printk>:

int printk(const char* s, ...) {
    80201480:	f9010113          	addi	sp,sp,-112
    80201484:	02113423          	sd	ra,40(sp)
    80201488:	02813023          	sd	s0,32(sp)
    8020148c:	03010413          	addi	s0,sp,48
    80201490:	fca43c23          	sd	a0,-40(s0)
    80201494:	00b43423          	sd	a1,8(s0)
    80201498:	00c43823          	sd	a2,16(s0)
    8020149c:	00d43c23          	sd	a3,24(s0)
    802014a0:	02e43023          	sd	a4,32(s0)
    802014a4:	02f43423          	sd	a5,40(s0)
    802014a8:	03043823          	sd	a6,48(s0)
    802014ac:	03143c23          	sd	a7,56(s0)
    int res = 0;
    802014b0:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    802014b4:	04040793          	addi	a5,s0,64
    802014b8:	fcf43823          	sd	a5,-48(s0)
    802014bc:	fd043783          	ld	a5,-48(s0)
    802014c0:	fc878793          	addi	a5,a5,-56
    802014c4:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    802014c8:	fe043783          	ld	a5,-32(s0)
    802014cc:	00078613          	mv	a2,a5
    802014d0:	fd843583          	ld	a1,-40(s0)
    802014d4:	fffff517          	auipc	a0,0xfffff
    802014d8:	11850513          	addi	a0,a0,280 # 802005ec <putc>
    802014dc:	fb4ff0ef          	jal	80200c90 <vprintfmt>
    802014e0:	00050793          	mv	a5,a0
    802014e4:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    802014e8:	fec42783          	lw	a5,-20(s0)
}
    802014ec:	00078513          	mv	a0,a5
    802014f0:	02813083          	ld	ra,40(sp)
    802014f4:	02013403          	ld	s0,32(sp)
    802014f8:	07010113          	addi	sp,sp,112
    802014fc:	00008067          	ret
