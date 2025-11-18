
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    # ------------------
    # - your code here -
    # ------------------

    # load the stack top address into the stack pointer
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	02013103          	ld	sp,32(sp) # 80203020 <_GLOBAL_OFFSET_TABLE_+0x18>

    # 开启trap处理新增指令，使用一个临时寄存器t0来存储_traps的地址
    la t0, _traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0282b283          	ld	t0,40(t0) # 80203030 <_GLOBAL_OFFSET_TABLE_+0x28>
    csrw stvec, t0
    80200010:	10529073          	csrw	stvec,t0

    # 初始化物理内存管理系统
    call mm_init
    80200014:	3b0000ef          	jal	802003c4 <mm_init>

    # 初始化线程
    call task_init
    80200018:	3f0000ef          	jal	80200408 <task_init>

    # 开启时钟中断，sie[STIE] 置 1
    li t0, (1 << 5)
    8020001c:	02000293          	li	t0,32
    csrs sie, t0
    80200020:	1042a073          	csrs	sie,t0

    # 设置第一次时钟中断
    rdtime t0
    80200024:	c01022f3          	rdtime	t0
    li t1, 10000000 # TIMECLOCK为10000000
    80200028:	00989337          	lui	t1,0x989
    8020002c:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    add t0, t0, t1
    80200030:	006282b3          	add	t0,t0,t1
    # 参数传递
    mv a0, t0
    80200034:	00028513          	mv	a0,t0

    call sbi_set_timer
    80200038:	2b9000ef          	jal	80200af0 <sbi_set_timer>

    #开启全局中断，sstatus[SIE] 置 1
    li t0, (1 << 1)
    8020003c:	00200293          	li	t0,2
    csrs sstatus, t0
    80200040:	1002a073          	csrs	sstatus,t0
    
    # call the function
    call start_kernel
    80200044:	665000ef          	jal	80200ea8 <start_kernel>

0000000080200048 <__dummy>:
    .extern dummy
    .globl __dummy
    .globl __switch_to
__dummy:
    # 将sepc设置为dummy()的地址
    la t0, dummy
    80200048:	00003297          	auipc	t0,0x3
    8020004c:	fe02b283          	ld	t0,-32(t0) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    csrw sepc, t0
    80200050:	14129073          	csrw	sepc,t0

    # 从S模式返回
    sret
    80200054:	10200073          	sret

0000000080200058 <__switch_to>:

__switch_to:
    
    # uint64_t变量为8字节对齐
    addi t0, a0, 32 # t0: prev->thread
    80200058:	02050293          	addi	t0,a0,32
    addi t1, a1, 32 # t1: next->thread
    8020005c:	02058313          	addi	t1,a1,32

    # save state to prev process
    sd ra, 0(t0)
    80200060:	0012b023          	sd	ra,0(t0)
    sd sp, 8(t0)
    80200064:	0022b423          	sd	sp,8(t0)
    sd s0, 16(t0)
    80200068:	0082b823          	sd	s0,16(t0)
    sd s1, 24(t0)
    8020006c:	0092bc23          	sd	s1,24(t0)
    sd s2, 32(t0)
    80200070:	0322b023          	sd	s2,32(t0)
    sd s3, 40(t0)
    80200074:	0332b423          	sd	s3,40(t0)
    sd s4, 48(t0)
    80200078:	0342b823          	sd	s4,48(t0)
    sd s5, 56(t0)
    8020007c:	0352bc23          	sd	s5,56(t0)
    sd s6, 64(t0)
    80200080:	0562b023          	sd	s6,64(t0)
    sd s7, 72(t0)
    80200084:	0572b423          	sd	s7,72(t0)
    sd s8, 80(t0)
    80200088:	0582b823          	sd	s8,80(t0)
    sd s9, 88(t0)
    8020008c:	0592bc23          	sd	s9,88(t0)
    sd s10, 96(t0)
    80200090:	07a2b023          	sd	s10,96(t0)
    sd s11, 104(t0)
    80200094:	07b2b423          	sd	s11,104(t0)

    # restore state from next process
    ld ra, 0(t1)
    80200098:	00033083          	ld	ra,0(t1)
    ld sp, 8(t1)
    8020009c:	00833103          	ld	sp,8(t1)
    ld s0, 16(t1)
    802000a0:	01033403          	ld	s0,16(t1)
    ld s1, 24(t1)
    802000a4:	01833483          	ld	s1,24(t1)
    ld s2, 32(t1)
    802000a8:	02033903          	ld	s2,32(t1)
    ld s3, 40(t1)
    802000ac:	02833983          	ld	s3,40(t1)
    ld s4, 48(t1)
    802000b0:	03033a03          	ld	s4,48(t1)
    ld s5, 56(t1)
    802000b4:	03833a83          	ld	s5,56(t1)
    ld s6, 64(t1)
    802000b8:	04033b03          	ld	s6,64(t1)
    ld s7, 72(t1)
    802000bc:	04833b83          	ld	s7,72(t1)
    ld s8, 80(t1)
    802000c0:	05033c03          	ld	s8,80(t1)
    ld s9, 88(t1)
    802000c4:	05833c83          	ld	s9,88(t1)
    ld s10, 96(t1)
    802000c8:	06033d03          	ld	s10,96(t1)
    ld s11, 104(t1)
    802000cc:	06833d83          	ld	s11,104(t1)
    

    ret
    802000d0:	00008067          	ret

00000000802000d4 <_traps>:
_traps:
    # 1. save 32 registers and sepc to stack
    # 2. call trap_handler
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    # 4. return from trap
    addi sp, sp, -272
    802000d4:	ef010113          	addi	sp,sp,-272
    # 保存寄存器
    sd zero, 0(sp)
    802000d8:	00013023          	sd	zero,0(sp)
    sd ra, 8(sp)
    802000dc:	00113423          	sd	ra,8(sp)
    sd gp, 16(sp)
    802000e0:	00313823          	sd	gp,16(sp)
    sd tp, 24(sp)
    802000e4:	00413c23          	sd	tp,24(sp)
    sd t0, 32(sp)
    802000e8:	02513023          	sd	t0,32(sp)
    sd t1, 40(sp)
    802000ec:	02613423          	sd	t1,40(sp)
    sd t2, 48(sp)
    802000f0:	02713823          	sd	t2,48(sp)
    sd s0, 56(sp)
    802000f4:	02813c23          	sd	s0,56(sp)
    sd s1, 64(sp)
    802000f8:	04913023          	sd	s1,64(sp)
    sd a0, 72(sp)
    802000fc:	04a13423          	sd	a0,72(sp)
    sd a1, 80(sp)
    80200100:	04b13823          	sd	a1,80(sp)
    sd a2, 88(sp)
    80200104:	04c13c23          	sd	a2,88(sp)
    sd a3, 96(sp)
    80200108:	06d13023          	sd	a3,96(sp)
    sd a4, 104(sp)
    8020010c:	06e13423          	sd	a4,104(sp)
    sd a5, 112(sp)
    80200110:	06f13823          	sd	a5,112(sp)
    sd a6, 120(sp)
    80200114:	07013c23          	sd	a6,120(sp)
    sd a7, 128(sp)
    80200118:	09113023          	sd	a7,128(sp)
    sd s2, 136(sp)
    8020011c:	09213423          	sd	s2,136(sp)
    sd s3, 144(sp)
    80200120:	09313823          	sd	s3,144(sp)
    sd s4, 152(sp)
    80200124:	09413c23          	sd	s4,152(sp)
    sd s5, 160(sp)
    80200128:	0b513023          	sd	s5,160(sp)
    sd s6, 168(sp)
    8020012c:	0b613423          	sd	s6,168(sp)
    sd s7, 176(sp)
    80200130:	0b713823          	sd	s7,176(sp)
    sd s8, 184(sp)
    80200134:	0b813c23          	sd	s8,184(sp)
    sd s9, 192(sp)
    80200138:	0d913023          	sd	s9,192(sp)
    sd s10, 200(sp)
    8020013c:	0da13423          	sd	s10,200(sp)
    sd s11, 208(sp)
    80200140:	0db13823          	sd	s11,208(sp)
    sd t3, 216(sp)
    80200144:	0dc13c23          	sd	t3,216(sp)
    sd t4, 224(sp)
    80200148:	0fd13023          	sd	t4,224(sp)
    sd t5, 232(sp)
    8020014c:	0fe13423          	sd	t5,232(sp)
    sd t6, 240(sp)
    80200150:	0ff13823          	sd	t6,240(sp)
    
    # 保存 scause 和 sepc
    csrr t0, scause
    80200154:	142022f3          	csrr	t0,scause
    sd t0, 248(sp)
    80200158:	0e513c23          	sd	t0,248(sp)
    csrr t0, sepc
    8020015c:	141022f3          	csrr	t0,sepc
    sd t0, 256(sp)
    80200160:	10513023          	sd	t0,256(sp)

    # 传递参数
    ld a0, 248(sp)
    80200164:	0f813503          	ld	a0,248(sp)
    ld a1, 256(sp)
    80200168:	10013583          	ld	a1,256(sp)

    call trap_handler
    8020016c:	33d000ef          	jal	80200ca8 <trap_handler>

    # 恢复寄存器
    ld t0, 256(sp)
    80200170:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
    80200174:	14129073          	csrw	sepc,t0
    # ld t0, 248(sp)
    # csrw scause, t0

    ld t6, 240(sp)
    80200178:	0f013f83          	ld	t6,240(sp)
    ld t5, 232(sp)
    8020017c:	0e813f03          	ld	t5,232(sp)
    ld t4, 224(sp)
    80200180:	0e013e83          	ld	t4,224(sp)
    ld t3, 216(sp)
    80200184:	0d813e03          	ld	t3,216(sp)
    ld s11, 208(sp)
    80200188:	0d013d83          	ld	s11,208(sp)
    ld s10, 200(sp)
    8020018c:	0c813d03          	ld	s10,200(sp)
    ld s9, 192(sp)
    80200190:	0c013c83          	ld	s9,192(sp)
    ld s8, 184(sp)
    80200194:	0b813c03          	ld	s8,184(sp)
    ld s7, 176(sp)
    80200198:	0b013b83          	ld	s7,176(sp)
    ld s6, 168(sp)
    8020019c:	0a813b03          	ld	s6,168(sp)
    ld s5, 160(sp)
    802001a0:	0a013a83          	ld	s5,160(sp)
    ld s4, 152(sp)
    802001a4:	09813a03          	ld	s4,152(sp)
    ld s3, 144(sp)
    802001a8:	09013983          	ld	s3,144(sp)
    ld s2, 136(sp)
    802001ac:	08813903          	ld	s2,136(sp)
    ld a7, 128(sp)
    802001b0:	08013883          	ld	a7,128(sp)
    ld a6, 120(sp)
    802001b4:	07813803          	ld	a6,120(sp)
    ld a5, 112(sp)
    802001b8:	07013783          	ld	a5,112(sp)
    ld a4, 104(sp)
    802001bc:	06813703          	ld	a4,104(sp)
    ld a3, 96(sp)
    802001c0:	06013683          	ld	a3,96(sp)
    ld a2, 88(sp)
    802001c4:	05813603          	ld	a2,88(sp)
    ld a1, 80(sp)
    802001c8:	05013583          	ld	a1,80(sp)
    ld a0, 72(sp)
    802001cc:	04813503          	ld	a0,72(sp)
    ld s1, 64(sp)
    802001d0:	04013483          	ld	s1,64(sp)
    ld s0, 56(sp)
    802001d4:	03813403          	ld	s0,56(sp)
    ld t2, 48(sp)
    802001d8:	03013383          	ld	t2,48(sp)
    ld t1, 40(sp)
    802001dc:	02813303          	ld	t1,40(sp)
    ld t0, 32(sp)
    802001e0:	02013283          	ld	t0,32(sp)
    ld tp, 24(sp)
    802001e4:	01813203          	ld	tp,24(sp)
    ld gp, 16(sp)
    802001e8:	01013183          	ld	gp,16(sp)
    ld ra, 8(sp)
    802001ec:	00813083          	ld	ra,8(sp)
    ld zero, 0(sp)
    802001f0:	00013003          	ld	zero,0(sp)

    # 恢复栈顶
    addi sp, sp, 272
    802001f4:	11010113          	addi	sp,sp,272

    # 返回
    802001f8:	10200073          	sret

00000000802001fc <get_cycles>:
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 20000000;

uint64_t get_cycles() {
    802001fc:	fe010113          	addi	sp,sp,-32
    80200200:	00813c23          	sd	s0,24(sp)
    80200204:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t time;
    asm volatile(
    80200208:	c01027f3          	rdtime	a5
    8020020c:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r"(time)
    );
    return time;
    80200210:	fe843783          	ld	a5,-24(s0)
}
    80200214:	00078513          	mv	a0,a5
    80200218:	01813403          	ld	s0,24(sp)
    8020021c:	02010113          	addi	sp,sp,32
    80200220:	00008067          	ret

0000000080200224 <clock_set_next_event>:

void clock_set_next_event() {
    80200224:	fe010113          	addi	sp,sp,-32
    80200228:	00113c23          	sd	ra,24(sp)
    8020022c:	00813823          	sd	s0,16(sp)
    80200230:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200234:	fc9ff0ef          	jal	802001fc <get_cycles>
    80200238:	00050713          	mv	a4,a0
    8020023c:	00003797          	auipc	a5,0x3
    80200240:	dc478793          	addi	a5,a5,-572 # 80203000 <TIMECLOCK>
    80200244:	0007b783          	ld	a5,0(a5)
    80200248:	00f707b3          	add	a5,a4,a5
    8020024c:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    80200250:	fe843503          	ld	a0,-24(s0)
    80200254:	09d000ef          	jal	80200af0 <sbi_set_timer>
    80200258:	00000013          	nop
    8020025c:	01813083          	ld	ra,24(sp)
    80200260:	01013403          	ld	s0,16(sp)
    80200264:	02010113          	addi	sp,sp,32
    80200268:	00008067          	ret

000000008020026c <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    8020026c:	fe010113          	addi	sp,sp,-32
    80200270:	00113c23          	sd	ra,24(sp)
    80200274:	00813823          	sd	s0,16(sp)
    80200278:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    8020027c:	00404797          	auipc	a5,0x404
    80200280:	d8478793          	addi	a5,a5,-636 # 80604000 <kmem>
    80200284:	0007b783          	ld	a5,0(a5)
    80200288:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    8020028c:	fe843783          	ld	a5,-24(s0)
    80200290:	0007b703          	ld	a4,0(a5)
    80200294:	00404797          	auipc	a5,0x404
    80200298:	d6c78793          	addi	a5,a5,-660 # 80604000 <kmem>
    8020029c:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    802002a0:	00001637          	lui	a2,0x1
    802002a4:	00000593          	li	a1,0
    802002a8:	fe843503          	ld	a0,-24(s0)
    802002ac:	435010ef          	jal	80201ee0 <memset>
    return (void *)r;
    802002b0:	fe843783          	ld	a5,-24(s0)
}
    802002b4:	00078513          	mv	a0,a5
    802002b8:	01813083          	ld	ra,24(sp)
    802002bc:	01013403          	ld	s0,16(sp)
    802002c0:	02010113          	addi	sp,sp,32
    802002c4:	00008067          	ret

00000000802002c8 <kfree>:

void kfree(void *addr) {
    802002c8:	fd010113          	addi	sp,sp,-48
    802002cc:	02113423          	sd	ra,40(sp)
    802002d0:	02813023          	sd	s0,32(sp)
    802002d4:	03010413          	addi	s0,sp,48
    802002d8:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    802002dc:	fd843783          	ld	a5,-40(s0)
    802002e0:	00078693          	mv	a3,a5
    802002e4:	fd840793          	addi	a5,s0,-40
    802002e8:	fffff737          	lui	a4,0xfffff
    802002ec:	00e6f733          	and	a4,a3,a4
    802002f0:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    802002f4:	fd843783          	ld	a5,-40(s0)
    802002f8:	00001637          	lui	a2,0x1
    802002fc:	00000593          	li	a1,0
    80200300:	00078513          	mv	a0,a5
    80200304:	3dd010ef          	jal	80201ee0 <memset>

    r = (struct run *)addr;
    80200308:	fd843783          	ld	a5,-40(s0)
    8020030c:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    80200310:	00404797          	auipc	a5,0x404
    80200314:	cf078793          	addi	a5,a5,-784 # 80604000 <kmem>
    80200318:	0007b703          	ld	a4,0(a5)
    8020031c:	fe843783          	ld	a5,-24(s0)
    80200320:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    80200324:	00404797          	auipc	a5,0x404
    80200328:	cdc78793          	addi	a5,a5,-804 # 80604000 <kmem>
    8020032c:	fe843703          	ld	a4,-24(s0)
    80200330:	00e7b023          	sd	a4,0(a5)

    return;
    80200334:	00000013          	nop
}
    80200338:	02813083          	ld	ra,40(sp)
    8020033c:	02013403          	ld	s0,32(sp)
    80200340:	03010113          	addi	sp,sp,48
    80200344:	00008067          	ret

0000000080200348 <kfreerange>:

void kfreerange(char *start, char *end) {
    80200348:	fd010113          	addi	sp,sp,-48
    8020034c:	02113423          	sd	ra,40(sp)
    80200350:	02813023          	sd	s0,32(sp)
    80200354:	03010413          	addi	s0,sp,48
    80200358:	fca43c23          	sd	a0,-40(s0)
    8020035c:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    80200360:	fd843703          	ld	a4,-40(s0)
    80200364:	000017b7          	lui	a5,0x1
    80200368:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    8020036c:	00f70733          	add	a4,a4,a5
    80200370:	fffff7b7          	lui	a5,0xfffff
    80200374:	00f777b3          	and	a5,a4,a5
    80200378:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    8020037c:	01c0006f          	j	80200398 <kfreerange+0x50>
        kfree((void *)addr);
    80200380:	fe843503          	ld	a0,-24(s0)
    80200384:	f45ff0ef          	jal	802002c8 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200388:	fe843703          	ld	a4,-24(s0)
    8020038c:	000017b7          	lui	a5,0x1
    80200390:	00f707b3          	add	a5,a4,a5
    80200394:	fef43423          	sd	a5,-24(s0)
    80200398:	fe843703          	ld	a4,-24(s0)
    8020039c:	000017b7          	lui	a5,0x1
    802003a0:	00f70733          	add	a4,a4,a5
    802003a4:	fd043783          	ld	a5,-48(s0)
    802003a8:	fce7fce3          	bgeu	a5,a4,80200380 <kfreerange+0x38>
    }
}
    802003ac:	00000013          	nop
    802003b0:	00000013          	nop
    802003b4:	02813083          	ld	ra,40(sp)
    802003b8:	02013403          	ld	s0,32(sp)
    802003bc:	03010113          	addi	sp,sp,48
    802003c0:	00008067          	ret

00000000802003c4 <mm_init>:

void mm_init(void) {
    802003c4:	ff010113          	addi	sp,sp,-16
    802003c8:	00113423          	sd	ra,8(sp)
    802003cc:	00813023          	sd	s0,0(sp)
    802003d0:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    802003d4:	01100793          	li	a5,17
    802003d8:	01b79593          	slli	a1,a5,0x1b
    802003dc:	00003517          	auipc	a0,0x3
    802003e0:	c3453503          	ld	a0,-972(a0) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    802003e4:	f65ff0ef          	jal	80200348 <kfreerange>
    printk("...mm_init done!\n");
    802003e8:	00002517          	auipc	a0,0x2
    802003ec:	c1850513          	addi	a0,a0,-1000 # 80202000 <_srodata>
    802003f0:	1d1010ef          	jal	80201dc0 <printk>
}
    802003f4:	00000013          	nop
    802003f8:	00813083          	ld	ra,8(sp)
    802003fc:	00013403          	ld	s0,0(sp)
    80200400:	01010113          	addi	sp,sp,16
    80200404:	00008067          	ret

0000000080200408 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
    80200408:	fe010113          	addi	sp,sp,-32
    8020040c:	00113c23          	sd	ra,24(sp)
    80200410:	00813823          	sd	s0,16(sp)
    80200414:	02010413          	addi	s0,sp,32
    srand(2024);
    80200418:	7e800513          	li	a0,2024
    8020041c:	225010ef          	jal	80201e40 <srand>
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle
    idle = (struct task_struct *)kalloc();
    80200420:	e4dff0ef          	jal	8020026c <kalloc>
    80200424:	00050713          	mv	a4,a0
    80200428:	00404797          	auipc	a5,0x404
    8020042c:	be078793          	addi	a5,a5,-1056 # 80604008 <idle>
    80200430:	00e7b023          	sd	a4,0(a5)
    idle->state = TASK_RUNNING;
    80200434:	00404797          	auipc	a5,0x404
    80200438:	bd478793          	addi	a5,a5,-1068 # 80604008 <idle>
    8020043c:	0007b783          	ld	a5,0(a5)
    80200440:	0007b023          	sd	zero,0(a5)
    idle->counter = 0;
    80200444:	00404797          	auipc	a5,0x404
    80200448:	bc478793          	addi	a5,a5,-1084 # 80604008 <idle>
    8020044c:	0007b783          	ld	a5,0(a5)
    80200450:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
    80200454:	00404797          	auipc	a5,0x404
    80200458:	bb478793          	addi	a5,a5,-1100 # 80604008 <idle>
    8020045c:	0007b783          	ld	a5,0(a5)
    80200460:	0007b823          	sd	zero,16(a5)
    idle->pid = 0;
    80200464:	00404797          	auipc	a5,0x404
    80200468:	ba478793          	addi	a5,a5,-1116 # 80604008 <idle>
    8020046c:	0007b783          	ld	a5,0(a5)
    80200470:	0007bc23          	sd	zero,24(a5)
    idle->thread.ra = (uint64_t)__dummy;
    80200474:	00404797          	auipc	a5,0x404
    80200478:	b9478793          	addi	a5,a5,-1132 # 80604008 <idle>
    8020047c:	0007b783          	ld	a5,0(a5)
    80200480:	00003717          	auipc	a4,0x3
    80200484:	b9873703          	ld	a4,-1128(a4) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    80200488:	02e7b023          	sd	a4,32(a5)
    idle->thread.sp = (uint64_t)idle + PGSIZE;
    8020048c:	00404797          	auipc	a5,0x404
    80200490:	b7c78793          	addi	a5,a5,-1156 # 80604008 <idle>
    80200494:	0007b783          	ld	a5,0(a5)
    80200498:	00078693          	mv	a3,a5
    8020049c:	00404797          	auipc	a5,0x404
    802004a0:	b6c78793          	addi	a5,a5,-1172 # 80604008 <idle>
    802004a4:	0007b783          	ld	a5,0(a5)
    802004a8:	00001737          	lui	a4,0x1
    802004ac:	00e68733          	add	a4,a3,a4
    802004b0:	02e7b423          	sd	a4,40(a5)
    current = idle;
    802004b4:	00404797          	auipc	a5,0x404
    802004b8:	b5478793          	addi	a5,a5,-1196 # 80604008 <idle>
    802004bc:	0007b703          	ld	a4,0(a5)
    802004c0:	00404797          	auipc	a5,0x404
    802004c4:	b5078793          	addi	a5,a5,-1200 # 80604010 <current>
    802004c8:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
    802004cc:	00404797          	auipc	a5,0x404
    802004d0:	b3c78793          	addi	a5,a5,-1220 # 80604008 <idle>
    802004d4:	0007b703          	ld	a4,0(a5)
    802004d8:	00404797          	auipc	a5,0x404
    802004dc:	b4078793          	addi	a5,a5,-1216 # 80604018 <task>
    802004e0:	00e7b023          	sd	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    for (int i = 1; i < NR_TASKS; ++i) {
    802004e4:	00100793          	li	a5,1
    802004e8:	fef42623          	sw	a5,-20(s0)
    802004ec:	12c0006f          	j	80200618 <task_init+0x210>
        task[i] = (struct task_struct *)kalloc();
    802004f0:	d7dff0ef          	jal	8020026c <kalloc>
    802004f4:	00050693          	mv	a3,a0
    802004f8:	00404717          	auipc	a4,0x404
    802004fc:	b2070713          	addi	a4,a4,-1248 # 80604018 <task>
    80200500:	fec42783          	lw	a5,-20(s0)
    80200504:	00379793          	slli	a5,a5,0x3
    80200508:	00f707b3          	add	a5,a4,a5
    8020050c:	00d7b023          	sd	a3,0(a5)
        task[i]->state = TASK_RUNNING;
    80200510:	00404717          	auipc	a4,0x404
    80200514:	b0870713          	addi	a4,a4,-1272 # 80604018 <task>
    80200518:	fec42783          	lw	a5,-20(s0)
    8020051c:	00379793          	slli	a5,a5,0x3
    80200520:	00f707b3          	add	a5,a4,a5
    80200524:	0007b783          	ld	a5,0(a5)
    80200528:	0007b023          	sd	zero,0(a5)
        task[i]->counter = 0;
    8020052c:	00404717          	auipc	a4,0x404
    80200530:	aec70713          	addi	a4,a4,-1300 # 80604018 <task>
    80200534:	fec42783          	lw	a5,-20(s0)
    80200538:	00379793          	slli	a5,a5,0x3
    8020053c:	00f707b3          	add	a5,a4,a5
    80200540:	0007b783          	ld	a5,0(a5)
    80200544:	0007b423          	sd	zero,8(a5)
        task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
    80200548:	13d010ef          	jal	80201e84 <rand>
    8020054c:	00050793          	mv	a5,a0
    80200550:	00078713          	mv	a4,a5
    80200554:	00a00793          	li	a5,10
    80200558:	02f767bb          	remw	a5,a4,a5
    8020055c:	0007879b          	sext.w	a5,a5
    80200560:	0017879b          	addiw	a5,a5,1
    80200564:	0007869b          	sext.w	a3,a5
    80200568:	00404717          	auipc	a4,0x404
    8020056c:	ab070713          	addi	a4,a4,-1360 # 80604018 <task>
    80200570:	fec42783          	lw	a5,-20(s0)
    80200574:	00379793          	slli	a5,a5,0x3
    80200578:	00f707b3          	add	a5,a4,a5
    8020057c:	0007b783          	ld	a5,0(a5)
    80200580:	00068713          	mv	a4,a3
    80200584:	00e7b823          	sd	a4,16(a5)
        task[i]->pid = i;
    80200588:	00404717          	auipc	a4,0x404
    8020058c:	a9070713          	addi	a4,a4,-1392 # 80604018 <task>
    80200590:	fec42783          	lw	a5,-20(s0)
    80200594:	00379793          	slli	a5,a5,0x3
    80200598:	00f707b3          	add	a5,a4,a5
    8020059c:	0007b783          	ld	a5,0(a5)
    802005a0:	fec42703          	lw	a4,-20(s0)
    802005a4:	00e7bc23          	sd	a4,24(a5)

        // 设置ra和sp
        task[i]->thread.ra = (uint64_t)__dummy;
    802005a8:	00404717          	auipc	a4,0x404
    802005ac:	a7070713          	addi	a4,a4,-1424 # 80604018 <task>
    802005b0:	fec42783          	lw	a5,-20(s0)
    802005b4:	00379793          	slli	a5,a5,0x3
    802005b8:	00f707b3          	add	a5,a4,a5
    802005bc:	0007b783          	ld	a5,0(a5)
    802005c0:	00003717          	auipc	a4,0x3
    802005c4:	a5873703          	ld	a4,-1448(a4) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    802005c8:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
    802005cc:	00404717          	auipc	a4,0x404
    802005d0:	a4c70713          	addi	a4,a4,-1460 # 80604018 <task>
    802005d4:	fec42783          	lw	a5,-20(s0)
    802005d8:	00379793          	slli	a5,a5,0x3
    802005dc:	00f707b3          	add	a5,a4,a5
    802005e0:	0007b783          	ld	a5,0(a5)
    802005e4:	00078693          	mv	a3,a5
    802005e8:	00404717          	auipc	a4,0x404
    802005ec:	a3070713          	addi	a4,a4,-1488 # 80604018 <task>
    802005f0:	fec42783          	lw	a5,-20(s0)
    802005f4:	00379793          	slli	a5,a5,0x3
    802005f8:	00f707b3          	add	a5,a4,a5
    802005fc:	0007b783          	ld	a5,0(a5)
    80200600:	00001737          	lui	a4,0x1
    80200604:	00e68733          	add	a4,a3,a4
    80200608:	02e7b423          	sd	a4,40(a5)
    for (int i = 1; i < NR_TASKS; ++i) {
    8020060c:	fec42783          	lw	a5,-20(s0)
    80200610:	0017879b          	addiw	a5,a5,1
    80200614:	fef42623          	sw	a5,-20(s0)
    80200618:	fec42783          	lw	a5,-20(s0)
    8020061c:	0007871b          	sext.w	a4,a5
    80200620:	01f00793          	li	a5,31
    80200624:	ece7d6e3          	bge	a5,a4,802004f0 <task_init+0xe8>
        #if TEST_SCHED
            printk("INITIALIZE [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
        #endif    
    }
    printk("...task_init done!\n");
    80200628:	00002517          	auipc	a0,0x2
    8020062c:	9f050513          	addi	a0,a0,-1552 # 80202018 <_srodata+0x18>
    80200630:	790010ef          	jal	80201dc0 <printk>
}
    80200634:	00000013          	nop
    80200638:	01813083          	ld	ra,24(sp)
    8020063c:	01013403          	ld	s0,16(sp)
    80200640:	02010113          	addi	sp,sp,32
    80200644:	00008067          	ret

0000000080200648 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    80200648:	fd010113          	addi	sp,sp,-48
    8020064c:	02113423          	sd	ra,40(sp)
    80200650:	02813023          	sd	s0,32(sp)
    80200654:	03010413          	addi	s0,sp,48
    printk("call dummy for current PID %d\n", current->pid);
    80200658:	00404797          	auipc	a5,0x404
    8020065c:	9b878793          	addi	a5,a5,-1608 # 80604010 <current>
    80200660:	0007b783          	ld	a5,0(a5)
    80200664:	0187b783          	ld	a5,24(a5)
    80200668:	00078593          	mv	a1,a5
    8020066c:	00002517          	auipc	a0,0x2
    80200670:	9c450513          	addi	a0,a0,-1596 # 80202030 <_srodata+0x30>
    80200674:	74c010ef          	jal	80201dc0 <printk>
    uint64_t MOD = 1000000007;
    80200678:	3b9ad7b7          	lui	a5,0x3b9ad
    8020067c:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    80200680:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    80200684:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    80200688:	fff00793          	li	a5,-1
    8020068c:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200690:	fe442783          	lw	a5,-28(s0)
    80200694:	0007871b          	sext.w	a4,a5
    80200698:	fff00793          	li	a5,-1
    8020069c:	00f70e63          	beq	a4,a5,802006b8 <dummy+0x70>
    802006a0:	00404797          	auipc	a5,0x404
    802006a4:	97078793          	addi	a5,a5,-1680 # 80604010 <current>
    802006a8:	0007b783          	ld	a5,0(a5)
    802006ac:	0087b703          	ld	a4,8(a5)
    802006b0:	fe442783          	lw	a5,-28(s0)
    802006b4:	fcf70ee3          	beq	a4,a5,80200690 <dummy+0x48>
    802006b8:	00404797          	auipc	a5,0x404
    802006bc:	95878793          	addi	a5,a5,-1704 # 80604010 <current>
    802006c0:	0007b783          	ld	a5,0(a5)
    802006c4:	0087b783          	ld	a5,8(a5)
    802006c8:	fc0784e3          	beqz	a5,80200690 <dummy+0x48>
            if (current->counter == 1) {
    802006cc:	00404797          	auipc	a5,0x404
    802006d0:	94478793          	addi	a5,a5,-1724 # 80604010 <current>
    802006d4:	0007b783          	ld	a5,0(a5)
    802006d8:	0087b703          	ld	a4,8(a5)
    802006dc:	00100793          	li	a5,1
    802006e0:	00f71e63          	bne	a4,a5,802006fc <dummy+0xb4>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    802006e4:	00404797          	auipc	a5,0x404
    802006e8:	92c78793          	addi	a5,a5,-1748 # 80604010 <current>
    802006ec:	0007b783          	ld	a5,0(a5)
    802006f0:	0087b703          	ld	a4,8(a5)
    802006f4:	fff70713          	addi	a4,a4,-1 # fff <_skernel-0x801ff001>
    802006f8:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    802006fc:	00404797          	auipc	a5,0x404
    80200700:	91478793          	addi	a5,a5,-1772 # 80604010 <current>
    80200704:	0007b783          	ld	a5,0(a5)
    80200708:	0087b783          	ld	a5,8(a5)
    8020070c:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    80200710:	fe843783          	ld	a5,-24(s0)
    80200714:	00178713          	addi	a4,a5,1
    80200718:	fd843783          	ld	a5,-40(s0)
    8020071c:	02f777b3          	remu	a5,a4,a5
    80200720:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    80200724:	00404797          	auipc	a5,0x404
    80200728:	8ec78793          	addi	a5,a5,-1812 # 80604010 <current>
    8020072c:	0007b783          	ld	a5,0(a5)
    80200730:	0187b783          	ld	a5,24(a5)
    80200734:	fe843603          	ld	a2,-24(s0)
    80200738:	00078593          	mv	a1,a5
    8020073c:	00002517          	auipc	a0,0x2
    80200740:	91450513          	addi	a0,a0,-1772 # 80202050 <_srodata+0x50>
    80200744:	67c010ef          	jal	80201dc0 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200748:	f49ff06f          	j	80200690 <dummy+0x48>

000000008020074c <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev, struct task_struct *next);

void switch_to(struct task_struct *next) {
    8020074c:	fd010113          	addi	sp,sp,-48
    80200750:	02113423          	sd	ra,40(sp)
    80200754:	02813023          	sd	s0,32(sp)
    80200758:	03010413          	addi	s0,sp,48
    8020075c:	fca43c23          	sd	a0,-40(s0)
    // 如果下一个线程是同一个线程，无需处理
    if (next == current) {
    80200760:	00404797          	auipc	a5,0x404
    80200764:	8b078793          	addi	a5,a5,-1872 # 80604010 <current>
    80200768:	0007b783          	ld	a5,0(a5)
    8020076c:	fd843703          	ld	a4,-40(s0)
    80200770:	06f70263          	beq	a4,a5,802007d4 <switch_to+0x88>
        return;
    }
    // 线程切换
    struct task_struct *prev = current;
    80200774:	00404797          	auipc	a5,0x404
    80200778:	89c78793          	addi	a5,a5,-1892 # 80604010 <current>
    8020077c:	0007b783          	ld	a5,0(a5)
    80200780:	fef43423          	sd	a5,-24(s0)
    current = next;
    80200784:	00404797          	auipc	a5,0x404
    80200788:	88c78793          	addi	a5,a5,-1908 # 80604010 <current>
    8020078c:	fd843703          	ld	a4,-40(s0)
    80200790:	00e7b023          	sd	a4,0(a5)
    printk("Switch to [PID = %d PRIORITY = %d COUNTER = %d] from [PID = %d]\n", next->pid, next->priority, next->counter, prev->pid);
    80200794:	fd843783          	ld	a5,-40(s0)
    80200798:	0187b583          	ld	a1,24(a5)
    8020079c:	fd843783          	ld	a5,-40(s0)
    802007a0:	0107b603          	ld	a2,16(a5)
    802007a4:	fd843783          	ld	a5,-40(s0)
    802007a8:	0087b683          	ld	a3,8(a5)
    802007ac:	fe843783          	ld	a5,-24(s0)
    802007b0:	0187b783          	ld	a5,24(a5)
    802007b4:	00078713          	mv	a4,a5
    802007b8:	00002517          	auipc	a0,0x2
    802007bc:	8c850513          	addi	a0,a0,-1848 # 80202080 <_srodata+0x80>
    802007c0:	600010ef          	jal	80201dc0 <printk>
    __switch_to(prev, next);
    802007c4:	fd843583          	ld	a1,-40(s0)
    802007c8:	fe843503          	ld	a0,-24(s0)
    802007cc:	88dff0ef          	jal	80200058 <__switch_to>
    return;
    802007d0:	0080006f          	j	802007d8 <switch_to+0x8c>
        return;
    802007d4:	00000013          	nop
}
    802007d8:	02813083          	ld	ra,40(sp)
    802007dc:	02013403          	ld	s0,32(sp)
    802007e0:	03010113          	addi	sp,sp,48
    802007e4:	00008067          	ret

00000000802007e8 <do_timer>:

void do_timer() {
    802007e8:	ff010113          	addi	sp,sp,-16
    802007ec:	00113423          	sd	ra,8(sp)
    802007f0:	00813023          	sd	s0,0(sp)
    802007f4:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    if (current == idle || current->counter <= 0) {
    802007f8:	00404797          	auipc	a5,0x404
    802007fc:	81878793          	addi	a5,a5,-2024 # 80604010 <current>
    80200800:	0007b703          	ld	a4,0(a5)
    80200804:	00404797          	auipc	a5,0x404
    80200808:	80478793          	addi	a5,a5,-2044 # 80604008 <idle>
    8020080c:	0007b783          	ld	a5,0(a5)
    80200810:	00f70c63          	beq	a4,a5,80200828 <do_timer+0x40>
    80200814:	00403797          	auipc	a5,0x403
    80200818:	7fc78793          	addi	a5,a5,2044 # 80604010 <current>
    8020081c:	0007b783          	ld	a5,0(a5)
    80200820:	0087b783          	ld	a5,8(a5)
    80200824:	00079663          	bnez	a5,80200830 <do_timer+0x48>
        schedule();
    80200828:	050000ef          	jal	80200878 <schedule>
            return;
        } else {
            schedule();
        }
    }
    return;
    8020082c:	03c0006f          	j	80200868 <do_timer+0x80>
        --(current->counter);
    80200830:	00403797          	auipc	a5,0x403
    80200834:	7e078793          	addi	a5,a5,2016 # 80604010 <current>
    80200838:	0007b783          	ld	a5,0(a5)
    8020083c:	0087b703          	ld	a4,8(a5)
    80200840:	fff70713          	addi	a4,a4,-1
    80200844:	00e7b423          	sd	a4,8(a5)
        if (current->counter > 0) {
    80200848:	00403797          	auipc	a5,0x403
    8020084c:	7c878793          	addi	a5,a5,1992 # 80604010 <current>
    80200850:	0007b783          	ld	a5,0(a5)
    80200854:	0087b783          	ld	a5,8(a5)
    80200858:	00079663          	bnez	a5,80200864 <do_timer+0x7c>
            schedule();
    8020085c:	01c000ef          	jal	80200878 <schedule>
    return;
    80200860:	0080006f          	j	80200868 <do_timer+0x80>
            return;
    80200864:	00000013          	nop
}
    80200868:	00813083          	ld	ra,8(sp)
    8020086c:	00013403          	ld	s0,0(sp)
    80200870:	01010113          	addi	sp,sp,16
    80200874:	00008067          	ret

0000000080200878 <schedule>:

void schedule() {
    80200878:	fd010113          	addi	sp,sp,-48
    8020087c:	02113423          	sd	ra,40(sp)
    80200880:	02813023          	sd	s0,32(sp)
    80200884:	03010413          	addi	s0,sp,48
    int max_counter;
    int next_id;
    int i;
    struct task_struct **p;
	while (1) {
		max_counter = -1;
    80200888:	fff00793          	li	a5,-1
    8020088c:	fef42623          	sw	a5,-20(s0)
		next_id = 0;
    80200890:	fe042423          	sw	zero,-24(s0)
		i = 0;
    80200894:	fe042223          	sw	zero,-28(s0)
		p = &task[0];
    80200898:	00403797          	auipc	a5,0x403
    8020089c:	78078793          	addi	a5,a5,1920 # 80604018 <task>
    802008a0:	fcf43c23          	sd	a5,-40(s0)
        // 找到最大剩余时间的线程运行
		while (++i < NR_TASKS) {
    802008a4:	0680006f          	j	8020090c <schedule+0x94>
			if (!*++p)
    802008a8:	fd843783          	ld	a5,-40(s0)
    802008ac:	00878793          	addi	a5,a5,8
    802008b0:	fcf43c23          	sd	a5,-40(s0)
    802008b4:	fd843783          	ld	a5,-40(s0)
    802008b8:	0007b783          	ld	a5,0(a5)
    802008bc:	04078663          	beqz	a5,80200908 <schedule+0x90>
				continue;
			if ((*p)->state == TASK_RUNNING && (int)(*p)->counter > max_counter) {
    802008c0:	fd843783          	ld	a5,-40(s0)
    802008c4:	0007b783          	ld	a5,0(a5)
    802008c8:	0007b783          	ld	a5,0(a5)
    802008cc:	04079063          	bnez	a5,8020090c <schedule+0x94>
    802008d0:	fd843783          	ld	a5,-40(s0)
    802008d4:	0007b783          	ld	a5,0(a5)
    802008d8:	0087b783          	ld	a5,8(a5)
    802008dc:	0007871b          	sext.w	a4,a5
    802008e0:	fec42783          	lw	a5,-20(s0)
    802008e4:	0007879b          	sext.w	a5,a5
    802008e8:	02e7d263          	bge	a5,a4,8020090c <schedule+0x94>
                max_counter = (int)(*p)->counter;
    802008ec:	fd843783          	ld	a5,-40(s0)
    802008f0:	0007b783          	ld	a5,0(a5)
    802008f4:	0087b783          	ld	a5,8(a5)
    802008f8:	fef42623          	sw	a5,-20(s0)
                next_id = i;
    802008fc:	fe442783          	lw	a5,-28(s0)
    80200900:	fef42423          	sw	a5,-24(s0)
    80200904:	0080006f          	j	8020090c <schedule+0x94>
				continue;
    80200908:	00000013          	nop
		while (++i < NR_TASKS) {
    8020090c:	fe442783          	lw	a5,-28(s0)
    80200910:	0017879b          	addiw	a5,a5,1
    80200914:	fef42223          	sw	a5,-28(s0)
    80200918:	fe442783          	lw	a5,-28(s0)
    8020091c:	0007871b          	sext.w	a4,a5
    80200920:	01f00793          	li	a5,31
    80200924:	f8e7d2e3          	bge	a5,a4,802008a8 <schedule+0x30>
            }
		}
		if (max_counter) break;
    80200928:	fec42783          	lw	a5,-20(s0)
    8020092c:	0007879b          	sext.w	a5,a5
    80200930:	0a079263          	bnez	a5,802009d4 <schedule+0x15c>
        // 所有线程counter都为0，令counter = priority
		for(p = &task[1] ; p < &task[NR_TASKS] ; ++p) {
    80200934:	00403797          	auipc	a5,0x403
    80200938:	6ec78793          	addi	a5,a5,1772 # 80604020 <task+0x8>
    8020093c:	fcf43c23          	sd	a5,-40(s0)
    80200940:	0800006f          	j	802009c0 <schedule+0x148>
            if (*p) {
    80200944:	fd843783          	ld	a5,-40(s0)
    80200948:	0007b783          	ld	a5,0(a5)
    8020094c:	06078463          	beqz	a5,802009b4 <schedule+0x13c>
                (*p)->counter = ((*p)->counter >> 1) + (*p)->priority;
    80200950:	fd843783          	ld	a5,-40(s0)
    80200954:	0007b783          	ld	a5,0(a5)
    80200958:	0087b783          	ld	a5,8(a5)
    8020095c:	0017d693          	srli	a3,a5,0x1
    80200960:	fd843783          	ld	a5,-40(s0)
    80200964:	0007b783          	ld	a5,0(a5)
    80200968:	0107b703          	ld	a4,16(a5)
    8020096c:	fd843783          	ld	a5,-40(s0)
    80200970:	0007b783          	ld	a5,0(a5)
    80200974:	00e68733          	add	a4,a3,a4
    80200978:	00e7b423          	sd	a4,8(a5)
                printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", (*p)->pid, (*p)->priority, (*p)->counter);
    8020097c:	fd843783          	ld	a5,-40(s0)
    80200980:	0007b783          	ld	a5,0(a5)
    80200984:	0187b703          	ld	a4,24(a5)
    80200988:	fd843783          	ld	a5,-40(s0)
    8020098c:	0007b783          	ld	a5,0(a5)
    80200990:	0107b603          	ld	a2,16(a5)
    80200994:	fd843783          	ld	a5,-40(s0)
    80200998:	0007b783          	ld	a5,0(a5)
    8020099c:	0087b783          	ld	a5,8(a5)
    802009a0:	00078693          	mv	a3,a5
    802009a4:	00070593          	mv	a1,a4
    802009a8:	00001517          	auipc	a0,0x1
    802009ac:	72050513          	addi	a0,a0,1824 # 802020c8 <_srodata+0xc8>
    802009b0:	410010ef          	jal	80201dc0 <printk>
		for(p = &task[1] ; p < &task[NR_TASKS] ; ++p) {
    802009b4:	fd843783          	ld	a5,-40(s0)
    802009b8:	00878793          	addi	a5,a5,8
    802009bc:	fcf43c23          	sd	a5,-40(s0)
    802009c0:	fd843703          	ld	a4,-40(s0)
    802009c4:	00403797          	auipc	a5,0x403
    802009c8:	75478793          	addi	a5,a5,1876 # 80604118 <seed>
    802009cc:	f6f76ce3          	bltu	a4,a5,80200944 <schedule+0xcc>
		max_counter = -1;
    802009d0:	eb9ff06f          	j	80200888 <schedule+0x10>
		if (max_counter) break;
    802009d4:	00000013          	nop
            }
        }
    }	
	switch_to(task[next_id]);
    802009d8:	00403717          	auipc	a4,0x403
    802009dc:	64070713          	addi	a4,a4,1600 # 80604018 <task>
    802009e0:	fe842783          	lw	a5,-24(s0)
    802009e4:	00379793          	slli	a5,a5,0x3
    802009e8:	00f707b3          	add	a5,a4,a5
    802009ec:	0007b783          	ld	a5,0(a5)
    802009f0:	00078513          	mv	a0,a5
    802009f4:	d59ff0ef          	jal	8020074c <switch_to>
    802009f8:	00000013          	nop
    802009fc:	02813083          	ld	ra,40(sp)
    80200a00:	02013403          	ld	s0,32(sp)
    80200a04:	03010113          	addi	sp,sp,48
    80200a08:	00008067          	ret

0000000080200a0c <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    80200a0c:	f7010113          	addi	sp,sp,-144
    80200a10:	08813423          	sd	s0,136(sp)
    80200a14:	08913023          	sd	s1,128(sp)
    80200a18:	07213c23          	sd	s2,120(sp)
    80200a1c:	07313823          	sd	s3,112(sp)
    80200a20:	09010413          	addi	s0,sp,144
    80200a24:	faa43423          	sd	a0,-88(s0)
    80200a28:	fab43023          	sd	a1,-96(s0)
    80200a2c:	f8c43c23          	sd	a2,-104(s0)
    80200a30:	f8d43823          	sd	a3,-112(s0)
    80200a34:	f8e43423          	sd	a4,-120(s0)
    80200a38:	f8f43023          	sd	a5,-128(s0)
    80200a3c:	f7043c23          	sd	a6,-136(s0)
    80200a40:	f7143823          	sd	a7,-144(s0)
    struct sbiret ret;
    uint64_t error_reg, value_reg;
    
    asm volatile(
    80200a44:	fa843e03          	ld	t3,-88(s0)
    80200a48:	fa043e83          	ld	t4,-96(s0)
    80200a4c:	f9843f03          	ld	t5,-104(s0)
    80200a50:	f9043f83          	ld	t6,-112(s0)
    80200a54:	f8843283          	ld	t0,-120(s0)
    80200a58:	f8043483          	ld	s1,-128(s0)
    80200a5c:	f7843903          	ld	s2,-136(s0)
    80200a60:	f7043983          	ld	s3,-144(s0)
    80200a64:	000e0893          	mv	a7,t3
    80200a68:	000e8813          	mv	a6,t4
    80200a6c:	000f0513          	mv	a0,t5
    80200a70:	000f8593          	mv	a1,t6
    80200a74:	00028613          	mv	a2,t0
    80200a78:	00048693          	mv	a3,s1
    80200a7c:	00090713          	mv	a4,s2
    80200a80:	00098793          	mv	a5,s3
    80200a84:	00000073          	ecall
    80200a88:	00050e93          	mv	t4,a0
    80200a8c:	00058e13          	mv	t3,a1
    80200a90:	fdd43c23          	sd	t4,-40(s0)
    80200a94:	fdc43823          	sd	t3,-48(s0)
          "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
          
    );

    // 返回结果
    ret.error = error_reg;
    80200a98:	fd843783          	ld	a5,-40(s0)
    80200a9c:	faf43823          	sd	a5,-80(s0)
    ret.value = value_reg;
    80200aa0:	fd043783          	ld	a5,-48(s0)
    80200aa4:	faf43c23          	sd	a5,-72(s0)
    return ret;
    80200aa8:	fb043783          	ld	a5,-80(s0)
    80200aac:	fcf43023          	sd	a5,-64(s0)
    80200ab0:	fb843783          	ld	a5,-72(s0)
    80200ab4:	fcf43423          	sd	a5,-56(s0)
    80200ab8:	fc043703          	ld	a4,-64(s0)
    80200abc:	fc843783          	ld	a5,-56(s0)
    80200ac0:	00070313          	mv	t1,a4
    80200ac4:	00078393          	mv	t2,a5
    80200ac8:	00030713          	mv	a4,t1
    80200acc:	00038793          	mv	a5,t2
}
    80200ad0:	00070513          	mv	a0,a4
    80200ad4:	00078593          	mv	a1,a5
    80200ad8:	08813403          	ld	s0,136(sp)
    80200adc:	08013483          	ld	s1,128(sp)
    80200ae0:	07813903          	ld	s2,120(sp)
    80200ae4:	07013983          	ld	s3,112(sp)
    80200ae8:	09010113          	addi	sp,sp,144
    80200aec:	00008067          	ret

0000000080200af0 <sbi_set_timer>:

// 设置时钟相关寄存器
struct sbiret sbi_set_timer(uint64_t stime_value) {
    80200af0:	fc010113          	addi	sp,sp,-64
    80200af4:	02113c23          	sd	ra,56(sp)
    80200af8:	02813823          	sd	s0,48(sp)
    80200afc:	03213423          	sd	s2,40(sp)
    80200b00:	03313023          	sd	s3,32(sp)
    80200b04:	04010413          	addi	s0,sp,64
    80200b08:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
    80200b0c:	00000893          	li	a7,0
    80200b10:	00000813          	li	a6,0
    80200b14:	00000793          	li	a5,0
    80200b18:	00000713          	li	a4,0
    80200b1c:	00000693          	li	a3,0
    80200b20:	fc843603          	ld	a2,-56(s0)
    80200b24:	00000593          	li	a1,0
    80200b28:	54495537          	lui	a0,0x54495
    80200b2c:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200b30:	eddff0ef          	jal	80200a0c <sbi_ecall>
    80200b34:	00050713          	mv	a4,a0
    80200b38:	00058793          	mv	a5,a1
    80200b3c:	fce43823          	sd	a4,-48(s0)
    80200b40:	fcf43c23          	sd	a5,-40(s0)
    80200b44:	fd043703          	ld	a4,-48(s0)
    80200b48:	fd843783          	ld	a5,-40(s0)
    80200b4c:	00070913          	mv	s2,a4
    80200b50:	00078993          	mv	s3,a5
    80200b54:	00090713          	mv	a4,s2
    80200b58:	00098793          	mv	a5,s3
}
    80200b5c:	00070513          	mv	a0,a4
    80200b60:	00078593          	mv	a1,a5
    80200b64:	03813083          	ld	ra,56(sp)
    80200b68:	03013403          	ld	s0,48(sp)
    80200b6c:	02813903          	ld	s2,40(sp)
    80200b70:	02013983          	ld	s3,32(sp)
    80200b74:	04010113          	addi	sp,sp,64
    80200b78:	00008067          	ret

0000000080200b7c <sbi_debug_console_write_byte>:
// 从终端读取数据
// struct sbiret sbi_debug_console_read() {
    
// }
// 向终端写入单个字符
struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200b7c:	fc010113          	addi	sp,sp,-64
    80200b80:	02113c23          	sd	ra,56(sp)
    80200b84:	02813823          	sd	s0,48(sp)
    80200b88:	03213423          	sd	s2,40(sp)
    80200b8c:	03313023          	sd	s3,32(sp)
    80200b90:	04010413          	addi	s0,sp,64
    80200b94:	00050793          	mv	a5,a0
    80200b98:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e, 0x2, byte, 0, 0, 0, 0, 0);
    80200b9c:	fcf44603          	lbu	a2,-49(s0)
    80200ba0:	00000893          	li	a7,0
    80200ba4:	00000813          	li	a6,0
    80200ba8:	00000793          	li	a5,0
    80200bac:	00000713          	li	a4,0
    80200bb0:	00000693          	li	a3,0
    80200bb4:	00200593          	li	a1,2
    80200bb8:	44424537          	lui	a0,0x44424
    80200bbc:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200bc0:	e4dff0ef          	jal	80200a0c <sbi_ecall>
    80200bc4:	00050713          	mv	a4,a0
    80200bc8:	00058793          	mv	a5,a1
    80200bcc:	fce43823          	sd	a4,-48(s0)
    80200bd0:	fcf43c23          	sd	a5,-40(s0)
    80200bd4:	fd043703          	ld	a4,-48(s0)
    80200bd8:	fd843783          	ld	a5,-40(s0)
    80200bdc:	00070913          	mv	s2,a4
    80200be0:	00078993          	mv	s3,a5
    80200be4:	00090713          	mv	a4,s2
    80200be8:	00098793          	mv	a5,s3
}
    80200bec:	00070513          	mv	a0,a4
    80200bf0:	00078593          	mv	a1,a5
    80200bf4:	03813083          	ld	ra,56(sp)
    80200bf8:	03013403          	ld	s0,48(sp)
    80200bfc:	02813903          	ld	s2,40(sp)
    80200c00:	02013983          	ld	s3,32(sp)
    80200c04:	04010113          	addi	sp,sp,64
    80200c08:	00008067          	ret

0000000080200c0c <sbi_system_reset>:
// 重置系统（关机或重启）
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200c0c:	fc010113          	addi	sp,sp,-64
    80200c10:	02113c23          	sd	ra,56(sp)
    80200c14:	02813823          	sd	s0,48(sp)
    80200c18:	03213423          	sd	s2,40(sp)
    80200c1c:	03313023          	sd	s3,32(sp)
    80200c20:	04010413          	addi	s0,sp,64
    80200c24:	00050793          	mv	a5,a0
    80200c28:	00058713          	mv	a4,a1
    80200c2c:	fcf42623          	sw	a5,-52(s0)
    80200c30:	00070793          	mv	a5,a4
    80200c34:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
    80200c38:	fcc46603          	lwu	a2,-52(s0)
    80200c3c:	fc846683          	lwu	a3,-56(s0)
    80200c40:	00000893          	li	a7,0
    80200c44:	00000813          	li	a6,0
    80200c48:	00000793          	li	a5,0
    80200c4c:	00000713          	li	a4,0
    80200c50:	00000593          	li	a1,0
    80200c54:	53525537          	lui	a0,0x53525
    80200c58:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200c5c:	db1ff0ef          	jal	80200a0c <sbi_ecall>
    80200c60:	00050713          	mv	a4,a0
    80200c64:	00058793          	mv	a5,a1
    80200c68:	fce43823          	sd	a4,-48(s0)
    80200c6c:	fcf43c23          	sd	a5,-40(s0)
    80200c70:	fd043703          	ld	a4,-48(s0)
    80200c74:	fd843783          	ld	a5,-40(s0)
    80200c78:	00070913          	mv	s2,a4
    80200c7c:	00078993          	mv	s3,a5
    80200c80:	00090713          	mv	a4,s2
    80200c84:	00098793          	mv	a5,s3
    80200c88:	00070513          	mv	a0,a4
    80200c8c:	00078593          	mv	a1,a5
    80200c90:	03813083          	ld	ra,56(sp)
    80200c94:	03013403          	ld	s0,48(sp)
    80200c98:	02813903          	ld	s2,40(sp)
    80200c9c:	02013983          	ld	s3,32(sp)
    80200ca0:	04010113          	addi	sp,sp,64
    80200ca4:	00008067          	ret

0000000080200ca8 <trap_handler>:
#include "stdint.h"
#include "proc.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
    80200ca8:	fd010113          	addi	sp,sp,-48
    80200cac:	02113423          	sd	ra,40(sp)
    80200cb0:	02813023          	sd	s0,32(sp)
    80200cb4:	03010413          	addi	s0,sp,48
    80200cb8:	fca43c23          	sd	a0,-40(s0)
    80200cbc:	fcb43823          	sd	a1,-48(s0)
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    // 参考: 63为interrupt, 0~62为code
    uint64_t code = scause & 0x7FFFFFFFFFFFFFFF;
    80200cc0:	fd843703          	ld	a4,-40(s0)
    80200cc4:	fff00793          	li	a5,-1
    80200cc8:	0017d793          	srli	a5,a5,0x1
    80200ccc:	00f777b3          	and	a5,a4,a5
    80200cd0:	fef43423          	sd	a5,-24(s0)
    if (scause & 1ULL << 63) { // interrupt
    80200cd4:	fd843783          	ld	a5,-40(s0)
    80200cd8:	0807d463          	bgez	a5,80200d60 <trap_handler+0xb8>
        // 打印调试信息
        if (code == 1) {
    80200cdc:	fe843703          	ld	a4,-24(s0)
    80200ce0:	00100793          	li	a5,1
    80200ce4:	00f71a63          	bne	a4,a5,80200cf8 <trap_handler+0x50>
            printk("[S] Supervisor Software Interrupt\n");
    80200ce8:	00001517          	auipc	a0,0x1
    80200cec:	41050513          	addi	a0,a0,1040 # 802020f8 <_srodata+0xf8>
    80200cf0:	0d0010ef          	jal	80201dc0 <printk>
    80200cf4:	0540006f          	j	80200d48 <trap_handler+0xa0>
        }
        else if (code == 5) {
    80200cf8:	fe843703          	ld	a4,-24(s0)
    80200cfc:	00500793          	li	a5,5
    80200d00:	04f70463          	beq	a4,a5,80200d48 <trap_handler+0xa0>
            // printk("[S] Supervisor Timer Interrupt\n");
        }
        else if (code == 9) {
    80200d04:	fe843703          	ld	a4,-24(s0)
    80200d08:	00900793          	li	a5,9
    80200d0c:	00f71a63          	bne	a4,a5,80200d20 <trap_handler+0x78>
            printk("[S] Supervisor External Interrupt\n");
    80200d10:	00001517          	auipc	a0,0x1
    80200d14:	41050513          	addi	a0,a0,1040 # 80202120 <_srodata+0x120>
    80200d18:	0a8010ef          	jal	80201dc0 <printk>
    80200d1c:	02c0006f          	j	80200d48 <trap_handler+0xa0>
        }
        else if (code == 13) {
    80200d20:	fe843703          	ld	a4,-24(s0)
    80200d24:	00d00793          	li	a5,13
    80200d28:	00f71a63          	bne	a4,a5,80200d3c <trap_handler+0x94>
            printk("Counter-overflow Interrupt\n");
    80200d2c:	00001517          	auipc	a0,0x1
    80200d30:	41c50513          	addi	a0,a0,1052 # 80202148 <_srodata+0x148>
    80200d34:	08c010ef          	jal	80201dc0 <printk>
    80200d38:	0100006f          	j	80200d48 <trap_handler+0xa0>
        }
        else {
            printk("Reserved or Designed for Platform Use\n");
    80200d3c:	00001517          	auipc	a0,0x1
    80200d40:	42c50513          	addi	a0,a0,1068 # 80202168 <_srodata+0x168>
    80200d44:	07c010ef          	jal	80201dc0 <printk>
        }

        // 设置下一次时钟中断
        if (code == 5) { // timer interrupt
    80200d48:	fe843703          	ld	a4,-24(s0)
    80200d4c:	00500793          	li	a5,5
    80200d50:	14f71263          	bne	a4,a5,80200e94 <trap_handler+0x1ec>
            clock_set_next_event();
    80200d54:	cd0ff0ef          	jal	80200224 <clock_set_next_event>
            do_timer();
    80200d58:	a91ff0ef          	jal	802007e8 <do_timer>
            case 13: printk("Load page fault\n"); break;
            case 15: printk("Store/AMO page fault\n"); break;
            default: printk("Unknown exception\n"); break;
        }
    }
    80200d5c:	1380006f          	j	80200e94 <trap_handler+0x1ec>
        printk("Exception\n");
    80200d60:	00001517          	auipc	a0,0x1
    80200d64:	43050513          	addi	a0,a0,1072 # 80202190 <_srodata+0x190>
    80200d68:	058010ef          	jal	80201dc0 <printk>
        switch(code) {
    80200d6c:	fe843703          	ld	a4,-24(s0)
    80200d70:	00f00793          	li	a5,15
    80200d74:	10e7e863          	bltu	a5,a4,80200e84 <trap_handler+0x1dc>
    80200d78:	fe843783          	ld	a5,-24(s0)
    80200d7c:	00279713          	slli	a4,a5,0x2
    80200d80:	00001797          	auipc	a5,0x1
    80200d84:	5b478793          	addi	a5,a5,1460 # 80202334 <_srodata+0x334>
    80200d88:	00f707b3          	add	a5,a4,a5
    80200d8c:	0007a783          	lw	a5,0(a5)
    80200d90:	0007871b          	sext.w	a4,a5
    80200d94:	00001797          	auipc	a5,0x1
    80200d98:	5a078793          	addi	a5,a5,1440 # 80202334 <_srodata+0x334>
    80200d9c:	00f707b3          	add	a5,a4,a5
    80200da0:	00078067          	jr	a5
            case 0: printk("Instruction address misaligned\n"); break;
    80200da4:	00001517          	auipc	a0,0x1
    80200da8:	3fc50513          	addi	a0,a0,1020 # 802021a0 <_srodata+0x1a0>
    80200dac:	014010ef          	jal	80201dc0 <printk>
    80200db0:	0e40006f          	j	80200e94 <trap_handler+0x1ec>
            case 1: printk("Instruction access fault\n"); break;
    80200db4:	00001517          	auipc	a0,0x1
    80200db8:	40c50513          	addi	a0,a0,1036 # 802021c0 <_srodata+0x1c0>
    80200dbc:	004010ef          	jal	80201dc0 <printk>
    80200dc0:	0d40006f          	j	80200e94 <trap_handler+0x1ec>
            case 2: printk("Illegal instruction\n"); break;
    80200dc4:	00001517          	auipc	a0,0x1
    80200dc8:	41c50513          	addi	a0,a0,1052 # 802021e0 <_srodata+0x1e0>
    80200dcc:	7f5000ef          	jal	80201dc0 <printk>
    80200dd0:	0c40006f          	j	80200e94 <trap_handler+0x1ec>
            case 3: printk("Breakpoint\n"); break;
    80200dd4:	00001517          	auipc	a0,0x1
    80200dd8:	42450513          	addi	a0,a0,1060 # 802021f8 <_srodata+0x1f8>
    80200ddc:	7e5000ef          	jal	80201dc0 <printk>
    80200de0:	0b40006f          	j	80200e94 <trap_handler+0x1ec>
            case 4: printk("Load address misaligned\n"); break;
    80200de4:	00001517          	auipc	a0,0x1
    80200de8:	42450513          	addi	a0,a0,1060 # 80202208 <_srodata+0x208>
    80200dec:	7d5000ef          	jal	80201dc0 <printk>
    80200df0:	0a40006f          	j	80200e94 <trap_handler+0x1ec>
            case 5: printk("Load access fault\n"); break;
    80200df4:	00001517          	auipc	a0,0x1
    80200df8:	43450513          	addi	a0,a0,1076 # 80202228 <_srodata+0x228>
    80200dfc:	7c5000ef          	jal	80201dc0 <printk>
    80200e00:	0940006f          	j	80200e94 <trap_handler+0x1ec>
            case 6: printk("Store/AMO address misaligned\n"); break;
    80200e04:	00001517          	auipc	a0,0x1
    80200e08:	43c50513          	addi	a0,a0,1084 # 80202240 <_srodata+0x240>
    80200e0c:	7b5000ef          	jal	80201dc0 <printk>
    80200e10:	0840006f          	j	80200e94 <trap_handler+0x1ec>
            case 7: printk("Store/AMO access fault\n"); break;
    80200e14:	00001517          	auipc	a0,0x1
    80200e18:	44c50513          	addi	a0,a0,1100 # 80202260 <_srodata+0x260>
    80200e1c:	7a5000ef          	jal	80201dc0 <printk>
    80200e20:	0740006f          	j	80200e94 <trap_handler+0x1ec>
            case 8: printk("Environment call from U-mode\n"); break;
    80200e24:	00001517          	auipc	a0,0x1
    80200e28:	45450513          	addi	a0,a0,1108 # 80202278 <_srodata+0x278>
    80200e2c:	795000ef          	jal	80201dc0 <printk>
    80200e30:	0640006f          	j	80200e94 <trap_handler+0x1ec>
            case 9: printk("Environment call from S-mode\n"); break;
    80200e34:	00001517          	auipc	a0,0x1
    80200e38:	46450513          	addi	a0,a0,1124 # 80202298 <_srodata+0x298>
    80200e3c:	785000ef          	jal	80201dc0 <printk>
    80200e40:	0540006f          	j	80200e94 <trap_handler+0x1ec>
            case 11: printk("Environment call from M-mode\n"); break;
    80200e44:	00001517          	auipc	a0,0x1
    80200e48:	47450513          	addi	a0,a0,1140 # 802022b8 <_srodata+0x2b8>
    80200e4c:	775000ef          	jal	80201dc0 <printk>
    80200e50:	0440006f          	j	80200e94 <trap_handler+0x1ec>
            case 12: printk("Instruction page fault\n"); break;
    80200e54:	00001517          	auipc	a0,0x1
    80200e58:	48450513          	addi	a0,a0,1156 # 802022d8 <_srodata+0x2d8>
    80200e5c:	765000ef          	jal	80201dc0 <printk>
    80200e60:	0340006f          	j	80200e94 <trap_handler+0x1ec>
            case 13: printk("Load page fault\n"); break;
    80200e64:	00001517          	auipc	a0,0x1
    80200e68:	48c50513          	addi	a0,a0,1164 # 802022f0 <_srodata+0x2f0>
    80200e6c:	755000ef          	jal	80201dc0 <printk>
    80200e70:	0240006f          	j	80200e94 <trap_handler+0x1ec>
            case 15: printk("Store/AMO page fault\n"); break;
    80200e74:	00001517          	auipc	a0,0x1
    80200e78:	49450513          	addi	a0,a0,1172 # 80202308 <_srodata+0x308>
    80200e7c:	745000ef          	jal	80201dc0 <printk>
    80200e80:	0140006f          	j	80200e94 <trap_handler+0x1ec>
            default: printk("Unknown exception\n"); break;
    80200e84:	00001517          	auipc	a0,0x1
    80200e88:	49c50513          	addi	a0,a0,1180 # 80202320 <_srodata+0x320>
    80200e8c:	735000ef          	jal	80201dc0 <printk>
    80200e90:	00000013          	nop
    80200e94:	00000013          	nop
    80200e98:	02813083          	ld	ra,40(sp)
    80200e9c:	02013403          	ld	s0,32(sp)
    80200ea0:	03010113          	addi	sp,sp,48
    80200ea4:	00008067          	ret

0000000080200ea8 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel() {
    80200ea8:	ff010113          	addi	sp,sp,-16
    80200eac:	00113423          	sd	ra,8(sp)
    80200eb0:	00813023          	sd	s0,0(sp)
    80200eb4:	01010413          	addi	s0,sp,16
    printk("2024");
    80200eb8:	00001517          	auipc	a0,0x1
    80200ebc:	4c050513          	addi	a0,a0,1216 # 80202378 <_srodata+0x378>
    80200ec0:	701000ef          	jal	80201dc0 <printk>
    printk(" ZJU Operating System\n");
    80200ec4:	00001517          	auipc	a0,0x1
    80200ec8:	4bc50513          	addi	a0,a0,1212 # 80202380 <_srodata+0x380>
    80200ecc:	6f5000ef          	jal	80201dc0 <printk>

    test();
    80200ed0:	01c000ef          	jal	80200eec <test>
    return 0;
    80200ed4:	00000793          	li	a5,0
}
    80200ed8:	00078513          	mv	a0,a5
    80200edc:	00813083          	ld	ra,8(sp)
    80200ee0:	00013403          	ld	s0,0(sp)
    80200ee4:	01010113          	addi	sp,sp,16
    80200ee8:	00008067          	ret

0000000080200eec <test>:
//     sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
//     __builtin_unreachable();
// }

#include "printk.h"
void test() {
    80200eec:	fe010113          	addi	sp,sp,-32
    80200ef0:	00813c23          	sd	s0,24(sp)
    80200ef4:	02010413          	addi	s0,sp,32
    int i = 0;
    80200ef8:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200efc:	fec42783          	lw	a5,-20(s0)
    80200f00:	0017879b          	addiw	a5,a5,1
    80200f04:	fef42623          	sw	a5,-20(s0)
    80200f08:	fec42783          	lw	a5,-20(s0)
    80200f0c:	00078713          	mv	a4,a5
    80200f10:	05f5e7b7          	lui	a5,0x5f5e
    80200f14:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    80200f18:	02f767bb          	remw	a5,a4,a5
    80200f1c:	0007879b          	sext.w	a5,a5
    80200f20:	fc079ee3          	bnez	a5,80200efc <test+0x10>
            // printk("kernel is running!\n");
            i = 0;
    80200f24:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200f28:	fd5ff06f          	j	80200efc <test+0x10>

0000000080200f2c <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200f2c:	fe010113          	addi	sp,sp,-32
    80200f30:	00113c23          	sd	ra,24(sp)
    80200f34:	00813823          	sd	s0,16(sp)
    80200f38:	02010413          	addi	s0,sp,32
    80200f3c:	00050793          	mv	a5,a0
    80200f40:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200f44:	fec42783          	lw	a5,-20(s0)
    80200f48:	0ff7f793          	zext.b	a5,a5
    80200f4c:	00078513          	mv	a0,a5
    80200f50:	c2dff0ef          	jal	80200b7c <sbi_debug_console_write_byte>
    return (char)c;
    80200f54:	fec42783          	lw	a5,-20(s0)
    80200f58:	0ff7f793          	zext.b	a5,a5
    80200f5c:	0007879b          	sext.w	a5,a5
}
    80200f60:	00078513          	mv	a0,a5
    80200f64:	01813083          	ld	ra,24(sp)
    80200f68:	01013403          	ld	s0,16(sp)
    80200f6c:	02010113          	addi	sp,sp,32
    80200f70:	00008067          	ret

0000000080200f74 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200f74:	fe010113          	addi	sp,sp,-32
    80200f78:	00813c23          	sd	s0,24(sp)
    80200f7c:	02010413          	addi	s0,sp,32
    80200f80:	00050793          	mv	a5,a0
    80200f84:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200f88:	fec42783          	lw	a5,-20(s0)
    80200f8c:	0007871b          	sext.w	a4,a5
    80200f90:	02000793          	li	a5,32
    80200f94:	02f70263          	beq	a4,a5,80200fb8 <isspace+0x44>
    80200f98:	fec42783          	lw	a5,-20(s0)
    80200f9c:	0007871b          	sext.w	a4,a5
    80200fa0:	00800793          	li	a5,8
    80200fa4:	00e7de63          	bge	a5,a4,80200fc0 <isspace+0x4c>
    80200fa8:	fec42783          	lw	a5,-20(s0)
    80200fac:	0007871b          	sext.w	a4,a5
    80200fb0:	00d00793          	li	a5,13
    80200fb4:	00e7c663          	blt	a5,a4,80200fc0 <isspace+0x4c>
    80200fb8:	00100793          	li	a5,1
    80200fbc:	0080006f          	j	80200fc4 <isspace+0x50>
    80200fc0:	00000793          	li	a5,0
}
    80200fc4:	00078513          	mv	a0,a5
    80200fc8:	01813403          	ld	s0,24(sp)
    80200fcc:	02010113          	addi	sp,sp,32
    80200fd0:	00008067          	ret

0000000080200fd4 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200fd4:	fb010113          	addi	sp,sp,-80
    80200fd8:	04113423          	sd	ra,72(sp)
    80200fdc:	04813023          	sd	s0,64(sp)
    80200fe0:	05010413          	addi	s0,sp,80
    80200fe4:	fca43423          	sd	a0,-56(s0)
    80200fe8:	fcb43023          	sd	a1,-64(s0)
    80200fec:	00060793          	mv	a5,a2
    80200ff0:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200ff4:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200ff8:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200ffc:	fc843783          	ld	a5,-56(s0)
    80201000:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80201004:	0100006f          	j	80201014 <strtol+0x40>
        p++;
    80201008:	fd843783          	ld	a5,-40(s0)
    8020100c:	00178793          	addi	a5,a5,1
    80201010:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80201014:	fd843783          	ld	a5,-40(s0)
    80201018:	0007c783          	lbu	a5,0(a5)
    8020101c:	0007879b          	sext.w	a5,a5
    80201020:	00078513          	mv	a0,a5
    80201024:	f51ff0ef          	jal	80200f74 <isspace>
    80201028:	00050793          	mv	a5,a0
    8020102c:	fc079ee3          	bnez	a5,80201008 <strtol+0x34>
    }

    if (*p == '-') {
    80201030:	fd843783          	ld	a5,-40(s0)
    80201034:	0007c783          	lbu	a5,0(a5)
    80201038:	00078713          	mv	a4,a5
    8020103c:	02d00793          	li	a5,45
    80201040:	00f71e63          	bne	a4,a5,8020105c <strtol+0x88>
        neg = true;
    80201044:	00100793          	li	a5,1
    80201048:	fef403a3          	sb	a5,-25(s0)
        p++;
    8020104c:	fd843783          	ld	a5,-40(s0)
    80201050:	00178793          	addi	a5,a5,1
    80201054:	fcf43c23          	sd	a5,-40(s0)
    80201058:	0240006f          	j	8020107c <strtol+0xa8>
    } else if (*p == '+') {
    8020105c:	fd843783          	ld	a5,-40(s0)
    80201060:	0007c783          	lbu	a5,0(a5)
    80201064:	00078713          	mv	a4,a5
    80201068:	02b00793          	li	a5,43
    8020106c:	00f71863          	bne	a4,a5,8020107c <strtol+0xa8>
        p++;
    80201070:	fd843783          	ld	a5,-40(s0)
    80201074:	00178793          	addi	a5,a5,1
    80201078:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    8020107c:	fbc42783          	lw	a5,-68(s0)
    80201080:	0007879b          	sext.w	a5,a5
    80201084:	06079c63          	bnez	a5,802010fc <strtol+0x128>
        if (*p == '0') {
    80201088:	fd843783          	ld	a5,-40(s0)
    8020108c:	0007c783          	lbu	a5,0(a5)
    80201090:	00078713          	mv	a4,a5
    80201094:	03000793          	li	a5,48
    80201098:	04f71e63          	bne	a4,a5,802010f4 <strtol+0x120>
            p++;
    8020109c:	fd843783          	ld	a5,-40(s0)
    802010a0:	00178793          	addi	a5,a5,1
    802010a4:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    802010a8:	fd843783          	ld	a5,-40(s0)
    802010ac:	0007c783          	lbu	a5,0(a5)
    802010b0:	00078713          	mv	a4,a5
    802010b4:	07800793          	li	a5,120
    802010b8:	00f70c63          	beq	a4,a5,802010d0 <strtol+0xfc>
    802010bc:	fd843783          	ld	a5,-40(s0)
    802010c0:	0007c783          	lbu	a5,0(a5)
    802010c4:	00078713          	mv	a4,a5
    802010c8:	05800793          	li	a5,88
    802010cc:	00f71e63          	bne	a4,a5,802010e8 <strtol+0x114>
                base = 16;
    802010d0:	01000793          	li	a5,16
    802010d4:	faf42e23          	sw	a5,-68(s0)
                p++;
    802010d8:	fd843783          	ld	a5,-40(s0)
    802010dc:	00178793          	addi	a5,a5,1
    802010e0:	fcf43c23          	sd	a5,-40(s0)
    802010e4:	0180006f          	j	802010fc <strtol+0x128>
            } else {
                base = 8;
    802010e8:	00800793          	li	a5,8
    802010ec:	faf42e23          	sw	a5,-68(s0)
    802010f0:	00c0006f          	j	802010fc <strtol+0x128>
            }
        } else {
            base = 10;
    802010f4:	00a00793          	li	a5,10
    802010f8:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802010fc:	fd843783          	ld	a5,-40(s0)
    80201100:	0007c783          	lbu	a5,0(a5)
    80201104:	00078713          	mv	a4,a5
    80201108:	02f00793          	li	a5,47
    8020110c:	02e7f863          	bgeu	a5,a4,8020113c <strtol+0x168>
    80201110:	fd843783          	ld	a5,-40(s0)
    80201114:	0007c783          	lbu	a5,0(a5)
    80201118:	00078713          	mv	a4,a5
    8020111c:	03900793          	li	a5,57
    80201120:	00e7ee63          	bltu	a5,a4,8020113c <strtol+0x168>
            digit = *p - '0';
    80201124:	fd843783          	ld	a5,-40(s0)
    80201128:	0007c783          	lbu	a5,0(a5)
    8020112c:	0007879b          	sext.w	a5,a5
    80201130:	fd07879b          	addiw	a5,a5,-48
    80201134:	fcf42a23          	sw	a5,-44(s0)
    80201138:	0800006f          	j	802011b8 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    8020113c:	fd843783          	ld	a5,-40(s0)
    80201140:	0007c783          	lbu	a5,0(a5)
    80201144:	00078713          	mv	a4,a5
    80201148:	06000793          	li	a5,96
    8020114c:	02e7f863          	bgeu	a5,a4,8020117c <strtol+0x1a8>
    80201150:	fd843783          	ld	a5,-40(s0)
    80201154:	0007c783          	lbu	a5,0(a5)
    80201158:	00078713          	mv	a4,a5
    8020115c:	07a00793          	li	a5,122
    80201160:	00e7ee63          	bltu	a5,a4,8020117c <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80201164:	fd843783          	ld	a5,-40(s0)
    80201168:	0007c783          	lbu	a5,0(a5)
    8020116c:	0007879b          	sext.w	a5,a5
    80201170:	fa97879b          	addiw	a5,a5,-87
    80201174:	fcf42a23          	sw	a5,-44(s0)
    80201178:	0400006f          	j	802011b8 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    8020117c:	fd843783          	ld	a5,-40(s0)
    80201180:	0007c783          	lbu	a5,0(a5)
    80201184:	00078713          	mv	a4,a5
    80201188:	04000793          	li	a5,64
    8020118c:	06e7f863          	bgeu	a5,a4,802011fc <strtol+0x228>
    80201190:	fd843783          	ld	a5,-40(s0)
    80201194:	0007c783          	lbu	a5,0(a5)
    80201198:	00078713          	mv	a4,a5
    8020119c:	05a00793          	li	a5,90
    802011a0:	04e7ee63          	bltu	a5,a4,802011fc <strtol+0x228>
            digit = *p - ('A' - 10);
    802011a4:	fd843783          	ld	a5,-40(s0)
    802011a8:	0007c783          	lbu	a5,0(a5)
    802011ac:	0007879b          	sext.w	a5,a5
    802011b0:	fc97879b          	addiw	a5,a5,-55
    802011b4:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    802011b8:	fd442783          	lw	a5,-44(s0)
    802011bc:	00078713          	mv	a4,a5
    802011c0:	fbc42783          	lw	a5,-68(s0)
    802011c4:	0007071b          	sext.w	a4,a4
    802011c8:	0007879b          	sext.w	a5,a5
    802011cc:	02f75663          	bge	a4,a5,802011f8 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    802011d0:	fbc42703          	lw	a4,-68(s0)
    802011d4:	fe843783          	ld	a5,-24(s0)
    802011d8:	02f70733          	mul	a4,a4,a5
    802011dc:	fd442783          	lw	a5,-44(s0)
    802011e0:	00f707b3          	add	a5,a4,a5
    802011e4:	fef43423          	sd	a5,-24(s0)
        p++;
    802011e8:	fd843783          	ld	a5,-40(s0)
    802011ec:	00178793          	addi	a5,a5,1
    802011f0:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802011f4:	f09ff06f          	j	802010fc <strtol+0x128>
            break;
    802011f8:	00000013          	nop
    }

    if (endptr) {
    802011fc:	fc043783          	ld	a5,-64(s0)
    80201200:	00078863          	beqz	a5,80201210 <strtol+0x23c>
        *endptr = (char *)p;
    80201204:	fc043783          	ld	a5,-64(s0)
    80201208:	fd843703          	ld	a4,-40(s0)
    8020120c:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80201210:	fe744783          	lbu	a5,-25(s0)
    80201214:	0ff7f793          	zext.b	a5,a5
    80201218:	00078863          	beqz	a5,80201228 <strtol+0x254>
    8020121c:	fe843783          	ld	a5,-24(s0)
    80201220:	40f007b3          	neg	a5,a5
    80201224:	0080006f          	j	8020122c <strtol+0x258>
    80201228:	fe843783          	ld	a5,-24(s0)
}
    8020122c:	00078513          	mv	a0,a5
    80201230:	04813083          	ld	ra,72(sp)
    80201234:	04013403          	ld	s0,64(sp)
    80201238:	05010113          	addi	sp,sp,80
    8020123c:	00008067          	ret

0000000080201240 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80201240:	fd010113          	addi	sp,sp,-48
    80201244:	02113423          	sd	ra,40(sp)
    80201248:	02813023          	sd	s0,32(sp)
    8020124c:	03010413          	addi	s0,sp,48
    80201250:	fca43c23          	sd	a0,-40(s0)
    80201254:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80201258:	fd043783          	ld	a5,-48(s0)
    8020125c:	00079863          	bnez	a5,8020126c <puts_wo_nl+0x2c>
        s = "(null)";
    80201260:	00001797          	auipc	a5,0x1
    80201264:	13878793          	addi	a5,a5,312 # 80202398 <_srodata+0x398>
    80201268:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    8020126c:	fd043783          	ld	a5,-48(s0)
    80201270:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80201274:	0240006f          	j	80201298 <puts_wo_nl+0x58>
        putch(*p++);
    80201278:	fe843783          	ld	a5,-24(s0)
    8020127c:	00178713          	addi	a4,a5,1
    80201280:	fee43423          	sd	a4,-24(s0)
    80201284:	0007c783          	lbu	a5,0(a5)
    80201288:	0007871b          	sext.w	a4,a5
    8020128c:	fd843783          	ld	a5,-40(s0)
    80201290:	00070513          	mv	a0,a4
    80201294:	000780e7          	jalr	a5
    while (*p) {
    80201298:	fe843783          	ld	a5,-24(s0)
    8020129c:	0007c783          	lbu	a5,0(a5)
    802012a0:	fc079ce3          	bnez	a5,80201278 <puts_wo_nl+0x38>
    }
    return p - s;
    802012a4:	fe843703          	ld	a4,-24(s0)
    802012a8:	fd043783          	ld	a5,-48(s0)
    802012ac:	40f707b3          	sub	a5,a4,a5
    802012b0:	0007879b          	sext.w	a5,a5
}
    802012b4:	00078513          	mv	a0,a5
    802012b8:	02813083          	ld	ra,40(sp)
    802012bc:	02013403          	ld	s0,32(sp)
    802012c0:	03010113          	addi	sp,sp,48
    802012c4:	00008067          	ret

00000000802012c8 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    802012c8:	f9010113          	addi	sp,sp,-112
    802012cc:	06113423          	sd	ra,104(sp)
    802012d0:	06813023          	sd	s0,96(sp)
    802012d4:	07010413          	addi	s0,sp,112
    802012d8:	faa43423          	sd	a0,-88(s0)
    802012dc:	fab43023          	sd	a1,-96(s0)
    802012e0:	00060793          	mv	a5,a2
    802012e4:	f8d43823          	sd	a3,-112(s0)
    802012e8:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    802012ec:	f9f44783          	lbu	a5,-97(s0)
    802012f0:	0ff7f793          	zext.b	a5,a5
    802012f4:	02078663          	beqz	a5,80201320 <print_dec_int+0x58>
    802012f8:	fa043703          	ld	a4,-96(s0)
    802012fc:	fff00793          	li	a5,-1
    80201300:	03f79793          	slli	a5,a5,0x3f
    80201304:	00f71e63          	bne	a4,a5,80201320 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80201308:	00001597          	auipc	a1,0x1
    8020130c:	09858593          	addi	a1,a1,152 # 802023a0 <_srodata+0x3a0>
    80201310:	fa843503          	ld	a0,-88(s0)
    80201314:	f2dff0ef          	jal	80201240 <puts_wo_nl>
    80201318:	00050793          	mv	a5,a0
    8020131c:	2a00006f          	j	802015bc <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    80201320:	f9043783          	ld	a5,-112(s0)
    80201324:	00c7a783          	lw	a5,12(a5)
    80201328:	00079a63          	bnez	a5,8020133c <print_dec_int+0x74>
    8020132c:	fa043783          	ld	a5,-96(s0)
    80201330:	00079663          	bnez	a5,8020133c <print_dec_int+0x74>
        return 0;
    80201334:	00000793          	li	a5,0
    80201338:	2840006f          	j	802015bc <print_dec_int+0x2f4>
    }

    bool neg = false;
    8020133c:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80201340:	f9f44783          	lbu	a5,-97(s0)
    80201344:	0ff7f793          	zext.b	a5,a5
    80201348:	02078063          	beqz	a5,80201368 <print_dec_int+0xa0>
    8020134c:	fa043783          	ld	a5,-96(s0)
    80201350:	0007dc63          	bgez	a5,80201368 <print_dec_int+0xa0>
        neg = true;
    80201354:	00100793          	li	a5,1
    80201358:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    8020135c:	fa043783          	ld	a5,-96(s0)
    80201360:	40f007b3          	neg	a5,a5
    80201364:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80201368:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    8020136c:	f9f44783          	lbu	a5,-97(s0)
    80201370:	0ff7f793          	zext.b	a5,a5
    80201374:	02078863          	beqz	a5,802013a4 <print_dec_int+0xdc>
    80201378:	fef44783          	lbu	a5,-17(s0)
    8020137c:	0ff7f793          	zext.b	a5,a5
    80201380:	00079e63          	bnez	a5,8020139c <print_dec_int+0xd4>
    80201384:	f9043783          	ld	a5,-112(s0)
    80201388:	0057c783          	lbu	a5,5(a5)
    8020138c:	00079863          	bnez	a5,8020139c <print_dec_int+0xd4>
    80201390:	f9043783          	ld	a5,-112(s0)
    80201394:	0047c783          	lbu	a5,4(a5)
    80201398:	00078663          	beqz	a5,802013a4 <print_dec_int+0xdc>
    8020139c:	00100793          	li	a5,1
    802013a0:	0080006f          	j	802013a8 <print_dec_int+0xe0>
    802013a4:	00000793          	li	a5,0
    802013a8:	fcf40ba3          	sb	a5,-41(s0)
    802013ac:	fd744783          	lbu	a5,-41(s0)
    802013b0:	0017f793          	andi	a5,a5,1
    802013b4:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    802013b8:	fa043703          	ld	a4,-96(s0)
    802013bc:	00a00793          	li	a5,10
    802013c0:	02f777b3          	remu	a5,a4,a5
    802013c4:	0ff7f713          	zext.b	a4,a5
    802013c8:	fe842783          	lw	a5,-24(s0)
    802013cc:	0017869b          	addiw	a3,a5,1
    802013d0:	fed42423          	sw	a3,-24(s0)
    802013d4:	0307071b          	addiw	a4,a4,48
    802013d8:	0ff77713          	zext.b	a4,a4
    802013dc:	ff078793          	addi	a5,a5,-16
    802013e0:	008787b3          	add	a5,a5,s0
    802013e4:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    802013e8:	fa043703          	ld	a4,-96(s0)
    802013ec:	00a00793          	li	a5,10
    802013f0:	02f757b3          	divu	a5,a4,a5
    802013f4:	faf43023          	sd	a5,-96(s0)
    } while (num);
    802013f8:	fa043783          	ld	a5,-96(s0)
    802013fc:	fa079ee3          	bnez	a5,802013b8 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80201400:	f9043783          	ld	a5,-112(s0)
    80201404:	00c7a783          	lw	a5,12(a5)
    80201408:	00078713          	mv	a4,a5
    8020140c:	fff00793          	li	a5,-1
    80201410:	02f71063          	bne	a4,a5,80201430 <print_dec_int+0x168>
    80201414:	f9043783          	ld	a5,-112(s0)
    80201418:	0037c783          	lbu	a5,3(a5)
    8020141c:	00078a63          	beqz	a5,80201430 <print_dec_int+0x168>
        flags->prec = flags->width;
    80201420:	f9043783          	ld	a5,-112(s0)
    80201424:	0087a703          	lw	a4,8(a5)
    80201428:	f9043783          	ld	a5,-112(s0)
    8020142c:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80201430:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201434:	f9043783          	ld	a5,-112(s0)
    80201438:	0087a703          	lw	a4,8(a5)
    8020143c:	fe842783          	lw	a5,-24(s0)
    80201440:	fcf42823          	sw	a5,-48(s0)
    80201444:	f9043783          	ld	a5,-112(s0)
    80201448:	00c7a783          	lw	a5,12(a5)
    8020144c:	fcf42623          	sw	a5,-52(s0)
    80201450:	fd042783          	lw	a5,-48(s0)
    80201454:	00078593          	mv	a1,a5
    80201458:	fcc42783          	lw	a5,-52(s0)
    8020145c:	00078613          	mv	a2,a5
    80201460:	0006069b          	sext.w	a3,a2
    80201464:	0005879b          	sext.w	a5,a1
    80201468:	00f6d463          	bge	a3,a5,80201470 <print_dec_int+0x1a8>
    8020146c:	00058613          	mv	a2,a1
    80201470:	0006079b          	sext.w	a5,a2
    80201474:	40f707bb          	subw	a5,a4,a5
    80201478:	0007871b          	sext.w	a4,a5
    8020147c:	fd744783          	lbu	a5,-41(s0)
    80201480:	0007879b          	sext.w	a5,a5
    80201484:	40f707bb          	subw	a5,a4,a5
    80201488:	fef42023          	sw	a5,-32(s0)
    8020148c:	0280006f          	j	802014b4 <print_dec_int+0x1ec>
        putch(' ');
    80201490:	fa843783          	ld	a5,-88(s0)
    80201494:	02000513          	li	a0,32
    80201498:	000780e7          	jalr	a5
        ++written;
    8020149c:	fe442783          	lw	a5,-28(s0)
    802014a0:	0017879b          	addiw	a5,a5,1
    802014a4:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    802014a8:	fe042783          	lw	a5,-32(s0)
    802014ac:	fff7879b          	addiw	a5,a5,-1
    802014b0:	fef42023          	sw	a5,-32(s0)
    802014b4:	fe042783          	lw	a5,-32(s0)
    802014b8:	0007879b          	sext.w	a5,a5
    802014bc:	fcf04ae3          	bgtz	a5,80201490 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    802014c0:	fd744783          	lbu	a5,-41(s0)
    802014c4:	0ff7f793          	zext.b	a5,a5
    802014c8:	04078463          	beqz	a5,80201510 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    802014cc:	fef44783          	lbu	a5,-17(s0)
    802014d0:	0ff7f793          	zext.b	a5,a5
    802014d4:	00078663          	beqz	a5,802014e0 <print_dec_int+0x218>
    802014d8:	02d00793          	li	a5,45
    802014dc:	01c0006f          	j	802014f8 <print_dec_int+0x230>
    802014e0:	f9043783          	ld	a5,-112(s0)
    802014e4:	0057c783          	lbu	a5,5(a5)
    802014e8:	00078663          	beqz	a5,802014f4 <print_dec_int+0x22c>
    802014ec:	02b00793          	li	a5,43
    802014f0:	0080006f          	j	802014f8 <print_dec_int+0x230>
    802014f4:	02000793          	li	a5,32
    802014f8:	fa843703          	ld	a4,-88(s0)
    802014fc:	00078513          	mv	a0,a5
    80201500:	000700e7          	jalr	a4
        ++written;
    80201504:	fe442783          	lw	a5,-28(s0)
    80201508:	0017879b          	addiw	a5,a5,1
    8020150c:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80201510:	fe842783          	lw	a5,-24(s0)
    80201514:	fcf42e23          	sw	a5,-36(s0)
    80201518:	0280006f          	j	80201540 <print_dec_int+0x278>
        putch('0');
    8020151c:	fa843783          	ld	a5,-88(s0)
    80201520:	03000513          	li	a0,48
    80201524:	000780e7          	jalr	a5
        ++written;
    80201528:	fe442783          	lw	a5,-28(s0)
    8020152c:	0017879b          	addiw	a5,a5,1
    80201530:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80201534:	fdc42783          	lw	a5,-36(s0)
    80201538:	0017879b          	addiw	a5,a5,1
    8020153c:	fcf42e23          	sw	a5,-36(s0)
    80201540:	f9043783          	ld	a5,-112(s0)
    80201544:	00c7a703          	lw	a4,12(a5)
    80201548:	fd744783          	lbu	a5,-41(s0)
    8020154c:	0007879b          	sext.w	a5,a5
    80201550:	40f707bb          	subw	a5,a4,a5
    80201554:	0007871b          	sext.w	a4,a5
    80201558:	fdc42783          	lw	a5,-36(s0)
    8020155c:	0007879b          	sext.w	a5,a5
    80201560:	fae7cee3          	blt	a5,a4,8020151c <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80201564:	fe842783          	lw	a5,-24(s0)
    80201568:	fff7879b          	addiw	a5,a5,-1
    8020156c:	fcf42c23          	sw	a5,-40(s0)
    80201570:	03c0006f          	j	802015ac <print_dec_int+0x2e4>
        putch(buf[i]);
    80201574:	fd842783          	lw	a5,-40(s0)
    80201578:	ff078793          	addi	a5,a5,-16
    8020157c:	008787b3          	add	a5,a5,s0
    80201580:	fc87c783          	lbu	a5,-56(a5)
    80201584:	0007871b          	sext.w	a4,a5
    80201588:	fa843783          	ld	a5,-88(s0)
    8020158c:	00070513          	mv	a0,a4
    80201590:	000780e7          	jalr	a5
        ++written;
    80201594:	fe442783          	lw	a5,-28(s0)
    80201598:	0017879b          	addiw	a5,a5,1
    8020159c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    802015a0:	fd842783          	lw	a5,-40(s0)
    802015a4:	fff7879b          	addiw	a5,a5,-1
    802015a8:	fcf42c23          	sw	a5,-40(s0)
    802015ac:	fd842783          	lw	a5,-40(s0)
    802015b0:	0007879b          	sext.w	a5,a5
    802015b4:	fc07d0e3          	bgez	a5,80201574 <print_dec_int+0x2ac>
    }

    return written;
    802015b8:	fe442783          	lw	a5,-28(s0)
}
    802015bc:	00078513          	mv	a0,a5
    802015c0:	06813083          	ld	ra,104(sp)
    802015c4:	06013403          	ld	s0,96(sp)
    802015c8:	07010113          	addi	sp,sp,112
    802015cc:	00008067          	ret

00000000802015d0 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    802015d0:	f4010113          	addi	sp,sp,-192
    802015d4:	0a113c23          	sd	ra,184(sp)
    802015d8:	0a813823          	sd	s0,176(sp)
    802015dc:	0c010413          	addi	s0,sp,192
    802015e0:	f4a43c23          	sd	a0,-168(s0)
    802015e4:	f4b43823          	sd	a1,-176(s0)
    802015e8:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    802015ec:	f8043023          	sd	zero,-128(s0)
    802015f0:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    802015f4:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    802015f8:	7a40006f          	j	80201d9c <vprintfmt+0x7cc>
        if (flags.in_format) {
    802015fc:	f8044783          	lbu	a5,-128(s0)
    80201600:	72078e63          	beqz	a5,80201d3c <vprintfmt+0x76c>
            if (*fmt == '#') {
    80201604:	f5043783          	ld	a5,-176(s0)
    80201608:	0007c783          	lbu	a5,0(a5)
    8020160c:	00078713          	mv	a4,a5
    80201610:	02300793          	li	a5,35
    80201614:	00f71863          	bne	a4,a5,80201624 <vprintfmt+0x54>
                flags.sharpflag = true;
    80201618:	00100793          	li	a5,1
    8020161c:	f8f40123          	sb	a5,-126(s0)
    80201620:	7700006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80201624:	f5043783          	ld	a5,-176(s0)
    80201628:	0007c783          	lbu	a5,0(a5)
    8020162c:	00078713          	mv	a4,a5
    80201630:	03000793          	li	a5,48
    80201634:	00f71863          	bne	a4,a5,80201644 <vprintfmt+0x74>
                flags.zeroflag = true;
    80201638:	00100793          	li	a5,1
    8020163c:	f8f401a3          	sb	a5,-125(s0)
    80201640:	7500006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80201644:	f5043783          	ld	a5,-176(s0)
    80201648:	0007c783          	lbu	a5,0(a5)
    8020164c:	00078713          	mv	a4,a5
    80201650:	06c00793          	li	a5,108
    80201654:	04f70063          	beq	a4,a5,80201694 <vprintfmt+0xc4>
    80201658:	f5043783          	ld	a5,-176(s0)
    8020165c:	0007c783          	lbu	a5,0(a5)
    80201660:	00078713          	mv	a4,a5
    80201664:	07a00793          	li	a5,122
    80201668:	02f70663          	beq	a4,a5,80201694 <vprintfmt+0xc4>
    8020166c:	f5043783          	ld	a5,-176(s0)
    80201670:	0007c783          	lbu	a5,0(a5)
    80201674:	00078713          	mv	a4,a5
    80201678:	07400793          	li	a5,116
    8020167c:	00f70c63          	beq	a4,a5,80201694 <vprintfmt+0xc4>
    80201680:	f5043783          	ld	a5,-176(s0)
    80201684:	0007c783          	lbu	a5,0(a5)
    80201688:	00078713          	mv	a4,a5
    8020168c:	06a00793          	li	a5,106
    80201690:	00f71863          	bne	a4,a5,802016a0 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80201694:	00100793          	li	a5,1
    80201698:	f8f400a3          	sb	a5,-127(s0)
    8020169c:	6f40006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    802016a0:	f5043783          	ld	a5,-176(s0)
    802016a4:	0007c783          	lbu	a5,0(a5)
    802016a8:	00078713          	mv	a4,a5
    802016ac:	02b00793          	li	a5,43
    802016b0:	00f71863          	bne	a4,a5,802016c0 <vprintfmt+0xf0>
                flags.sign = true;
    802016b4:	00100793          	li	a5,1
    802016b8:	f8f402a3          	sb	a5,-123(s0)
    802016bc:	6d40006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    802016c0:	f5043783          	ld	a5,-176(s0)
    802016c4:	0007c783          	lbu	a5,0(a5)
    802016c8:	00078713          	mv	a4,a5
    802016cc:	02000793          	li	a5,32
    802016d0:	00f71863          	bne	a4,a5,802016e0 <vprintfmt+0x110>
                flags.spaceflag = true;
    802016d4:	00100793          	li	a5,1
    802016d8:	f8f40223          	sb	a5,-124(s0)
    802016dc:	6b40006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    802016e0:	f5043783          	ld	a5,-176(s0)
    802016e4:	0007c783          	lbu	a5,0(a5)
    802016e8:	00078713          	mv	a4,a5
    802016ec:	02a00793          	li	a5,42
    802016f0:	00f71e63          	bne	a4,a5,8020170c <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    802016f4:	f4843783          	ld	a5,-184(s0)
    802016f8:	00878713          	addi	a4,a5,8
    802016fc:	f4e43423          	sd	a4,-184(s0)
    80201700:	0007a783          	lw	a5,0(a5)
    80201704:	f8f42423          	sw	a5,-120(s0)
    80201708:	6880006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    8020170c:	f5043783          	ld	a5,-176(s0)
    80201710:	0007c783          	lbu	a5,0(a5)
    80201714:	00078713          	mv	a4,a5
    80201718:	03000793          	li	a5,48
    8020171c:	04e7f663          	bgeu	a5,a4,80201768 <vprintfmt+0x198>
    80201720:	f5043783          	ld	a5,-176(s0)
    80201724:	0007c783          	lbu	a5,0(a5)
    80201728:	00078713          	mv	a4,a5
    8020172c:	03900793          	li	a5,57
    80201730:	02e7ec63          	bltu	a5,a4,80201768 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80201734:	f5043783          	ld	a5,-176(s0)
    80201738:	f5040713          	addi	a4,s0,-176
    8020173c:	00a00613          	li	a2,10
    80201740:	00070593          	mv	a1,a4
    80201744:	00078513          	mv	a0,a5
    80201748:	88dff0ef          	jal	80200fd4 <strtol>
    8020174c:	00050793          	mv	a5,a0
    80201750:	0007879b          	sext.w	a5,a5
    80201754:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80201758:	f5043783          	ld	a5,-176(s0)
    8020175c:	fff78793          	addi	a5,a5,-1
    80201760:	f4f43823          	sd	a5,-176(s0)
    80201764:	62c0006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80201768:	f5043783          	ld	a5,-176(s0)
    8020176c:	0007c783          	lbu	a5,0(a5)
    80201770:	00078713          	mv	a4,a5
    80201774:	02e00793          	li	a5,46
    80201778:	06f71863          	bne	a4,a5,802017e8 <vprintfmt+0x218>
                fmt++;
    8020177c:	f5043783          	ld	a5,-176(s0)
    80201780:	00178793          	addi	a5,a5,1
    80201784:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80201788:	f5043783          	ld	a5,-176(s0)
    8020178c:	0007c783          	lbu	a5,0(a5)
    80201790:	00078713          	mv	a4,a5
    80201794:	02a00793          	li	a5,42
    80201798:	00f71e63          	bne	a4,a5,802017b4 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    8020179c:	f4843783          	ld	a5,-184(s0)
    802017a0:	00878713          	addi	a4,a5,8
    802017a4:	f4e43423          	sd	a4,-184(s0)
    802017a8:	0007a783          	lw	a5,0(a5)
    802017ac:	f8f42623          	sw	a5,-116(s0)
    802017b0:	5e00006f          	j	80201d90 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    802017b4:	f5043783          	ld	a5,-176(s0)
    802017b8:	f5040713          	addi	a4,s0,-176
    802017bc:	00a00613          	li	a2,10
    802017c0:	00070593          	mv	a1,a4
    802017c4:	00078513          	mv	a0,a5
    802017c8:	80dff0ef          	jal	80200fd4 <strtol>
    802017cc:	00050793          	mv	a5,a0
    802017d0:	0007879b          	sext.w	a5,a5
    802017d4:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    802017d8:	f5043783          	ld	a5,-176(s0)
    802017dc:	fff78793          	addi	a5,a5,-1
    802017e0:	f4f43823          	sd	a5,-176(s0)
    802017e4:	5ac0006f          	j	80201d90 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802017e8:	f5043783          	ld	a5,-176(s0)
    802017ec:	0007c783          	lbu	a5,0(a5)
    802017f0:	00078713          	mv	a4,a5
    802017f4:	07800793          	li	a5,120
    802017f8:	02f70663          	beq	a4,a5,80201824 <vprintfmt+0x254>
    802017fc:	f5043783          	ld	a5,-176(s0)
    80201800:	0007c783          	lbu	a5,0(a5)
    80201804:	00078713          	mv	a4,a5
    80201808:	05800793          	li	a5,88
    8020180c:	00f70c63          	beq	a4,a5,80201824 <vprintfmt+0x254>
    80201810:	f5043783          	ld	a5,-176(s0)
    80201814:	0007c783          	lbu	a5,0(a5)
    80201818:	00078713          	mv	a4,a5
    8020181c:	07000793          	li	a5,112
    80201820:	30f71263          	bne	a4,a5,80201b24 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80201824:	f5043783          	ld	a5,-176(s0)
    80201828:	0007c783          	lbu	a5,0(a5)
    8020182c:	00078713          	mv	a4,a5
    80201830:	07000793          	li	a5,112
    80201834:	00f70663          	beq	a4,a5,80201840 <vprintfmt+0x270>
    80201838:	f8144783          	lbu	a5,-127(s0)
    8020183c:	00078663          	beqz	a5,80201848 <vprintfmt+0x278>
    80201840:	00100793          	li	a5,1
    80201844:	0080006f          	j	8020184c <vprintfmt+0x27c>
    80201848:	00000793          	li	a5,0
    8020184c:	faf403a3          	sb	a5,-89(s0)
    80201850:	fa744783          	lbu	a5,-89(s0)
    80201854:	0017f793          	andi	a5,a5,1
    80201858:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    8020185c:	fa744783          	lbu	a5,-89(s0)
    80201860:	0ff7f793          	zext.b	a5,a5
    80201864:	00078c63          	beqz	a5,8020187c <vprintfmt+0x2ac>
    80201868:	f4843783          	ld	a5,-184(s0)
    8020186c:	00878713          	addi	a4,a5,8
    80201870:	f4e43423          	sd	a4,-184(s0)
    80201874:	0007b783          	ld	a5,0(a5)
    80201878:	01c0006f          	j	80201894 <vprintfmt+0x2c4>
    8020187c:	f4843783          	ld	a5,-184(s0)
    80201880:	00878713          	addi	a4,a5,8
    80201884:	f4e43423          	sd	a4,-184(s0)
    80201888:	0007a783          	lw	a5,0(a5)
    8020188c:	02079793          	slli	a5,a5,0x20
    80201890:	0207d793          	srli	a5,a5,0x20
    80201894:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201898:	f8c42783          	lw	a5,-116(s0)
    8020189c:	02079463          	bnez	a5,802018c4 <vprintfmt+0x2f4>
    802018a0:	fe043783          	ld	a5,-32(s0)
    802018a4:	02079063          	bnez	a5,802018c4 <vprintfmt+0x2f4>
    802018a8:	f5043783          	ld	a5,-176(s0)
    802018ac:	0007c783          	lbu	a5,0(a5)
    802018b0:	00078713          	mv	a4,a5
    802018b4:	07000793          	li	a5,112
    802018b8:	00f70663          	beq	a4,a5,802018c4 <vprintfmt+0x2f4>
                    flags.in_format = false;
    802018bc:	f8040023          	sb	zero,-128(s0)
    802018c0:	4d00006f          	j	80201d90 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    802018c4:	f5043783          	ld	a5,-176(s0)
    802018c8:	0007c783          	lbu	a5,0(a5)
    802018cc:	00078713          	mv	a4,a5
    802018d0:	07000793          	li	a5,112
    802018d4:	00f70a63          	beq	a4,a5,802018e8 <vprintfmt+0x318>
    802018d8:	f8244783          	lbu	a5,-126(s0)
    802018dc:	00078a63          	beqz	a5,802018f0 <vprintfmt+0x320>
    802018e0:	fe043783          	ld	a5,-32(s0)
    802018e4:	00078663          	beqz	a5,802018f0 <vprintfmt+0x320>
    802018e8:	00100793          	li	a5,1
    802018ec:	0080006f          	j	802018f4 <vprintfmt+0x324>
    802018f0:	00000793          	li	a5,0
    802018f4:	faf40323          	sb	a5,-90(s0)
    802018f8:	fa644783          	lbu	a5,-90(s0)
    802018fc:	0017f793          	andi	a5,a5,1
    80201900:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80201904:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80201908:	f5043783          	ld	a5,-176(s0)
    8020190c:	0007c783          	lbu	a5,0(a5)
    80201910:	00078713          	mv	a4,a5
    80201914:	05800793          	li	a5,88
    80201918:	00f71863          	bne	a4,a5,80201928 <vprintfmt+0x358>
    8020191c:	00001797          	auipc	a5,0x1
    80201920:	a9c78793          	addi	a5,a5,-1380 # 802023b8 <upperxdigits.1>
    80201924:	00c0006f          	j	80201930 <vprintfmt+0x360>
    80201928:	00001797          	auipc	a5,0x1
    8020192c:	aa878793          	addi	a5,a5,-1368 # 802023d0 <lowerxdigits.0>
    80201930:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201934:	fe043783          	ld	a5,-32(s0)
    80201938:	00f7f793          	andi	a5,a5,15
    8020193c:	f9843703          	ld	a4,-104(s0)
    80201940:	00f70733          	add	a4,a4,a5
    80201944:	fdc42783          	lw	a5,-36(s0)
    80201948:	0017869b          	addiw	a3,a5,1
    8020194c:	fcd42e23          	sw	a3,-36(s0)
    80201950:	00074703          	lbu	a4,0(a4)
    80201954:	ff078793          	addi	a5,a5,-16
    80201958:	008787b3          	add	a5,a5,s0
    8020195c:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80201960:	fe043783          	ld	a5,-32(s0)
    80201964:	0047d793          	srli	a5,a5,0x4
    80201968:	fef43023          	sd	a5,-32(s0)
                } while (num);
    8020196c:	fe043783          	ld	a5,-32(s0)
    80201970:	fc0792e3          	bnez	a5,80201934 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201974:	f8c42783          	lw	a5,-116(s0)
    80201978:	00078713          	mv	a4,a5
    8020197c:	fff00793          	li	a5,-1
    80201980:	02f71663          	bne	a4,a5,802019ac <vprintfmt+0x3dc>
    80201984:	f8344783          	lbu	a5,-125(s0)
    80201988:	02078263          	beqz	a5,802019ac <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    8020198c:	f8842703          	lw	a4,-120(s0)
    80201990:	fa644783          	lbu	a5,-90(s0)
    80201994:	0007879b          	sext.w	a5,a5
    80201998:	0017979b          	slliw	a5,a5,0x1
    8020199c:	0007879b          	sext.w	a5,a5
    802019a0:	40f707bb          	subw	a5,a4,a5
    802019a4:	0007879b          	sext.w	a5,a5
    802019a8:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802019ac:	f8842703          	lw	a4,-120(s0)
    802019b0:	fa644783          	lbu	a5,-90(s0)
    802019b4:	0007879b          	sext.w	a5,a5
    802019b8:	0017979b          	slliw	a5,a5,0x1
    802019bc:	0007879b          	sext.w	a5,a5
    802019c0:	40f707bb          	subw	a5,a4,a5
    802019c4:	0007871b          	sext.w	a4,a5
    802019c8:	fdc42783          	lw	a5,-36(s0)
    802019cc:	f8f42a23          	sw	a5,-108(s0)
    802019d0:	f8c42783          	lw	a5,-116(s0)
    802019d4:	f8f42823          	sw	a5,-112(s0)
    802019d8:	f9442783          	lw	a5,-108(s0)
    802019dc:	00078593          	mv	a1,a5
    802019e0:	f9042783          	lw	a5,-112(s0)
    802019e4:	00078613          	mv	a2,a5
    802019e8:	0006069b          	sext.w	a3,a2
    802019ec:	0005879b          	sext.w	a5,a1
    802019f0:	00f6d463          	bge	a3,a5,802019f8 <vprintfmt+0x428>
    802019f4:	00058613          	mv	a2,a1
    802019f8:	0006079b          	sext.w	a5,a2
    802019fc:	40f707bb          	subw	a5,a4,a5
    80201a00:	fcf42c23          	sw	a5,-40(s0)
    80201a04:	0280006f          	j	80201a2c <vprintfmt+0x45c>
                    putch(' ');
    80201a08:	f5843783          	ld	a5,-168(s0)
    80201a0c:	02000513          	li	a0,32
    80201a10:	000780e7          	jalr	a5
                    ++written;
    80201a14:	fec42783          	lw	a5,-20(s0)
    80201a18:	0017879b          	addiw	a5,a5,1
    80201a1c:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201a20:	fd842783          	lw	a5,-40(s0)
    80201a24:	fff7879b          	addiw	a5,a5,-1
    80201a28:	fcf42c23          	sw	a5,-40(s0)
    80201a2c:	fd842783          	lw	a5,-40(s0)
    80201a30:	0007879b          	sext.w	a5,a5
    80201a34:	fcf04ae3          	bgtz	a5,80201a08 <vprintfmt+0x438>
                }

                if (prefix) {
    80201a38:	fa644783          	lbu	a5,-90(s0)
    80201a3c:	0ff7f793          	zext.b	a5,a5
    80201a40:	04078463          	beqz	a5,80201a88 <vprintfmt+0x4b8>
                    putch('0');
    80201a44:	f5843783          	ld	a5,-168(s0)
    80201a48:	03000513          	li	a0,48
    80201a4c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201a50:	f5043783          	ld	a5,-176(s0)
    80201a54:	0007c783          	lbu	a5,0(a5)
    80201a58:	00078713          	mv	a4,a5
    80201a5c:	05800793          	li	a5,88
    80201a60:	00f71663          	bne	a4,a5,80201a6c <vprintfmt+0x49c>
    80201a64:	05800793          	li	a5,88
    80201a68:	0080006f          	j	80201a70 <vprintfmt+0x4a0>
    80201a6c:	07800793          	li	a5,120
    80201a70:	f5843703          	ld	a4,-168(s0)
    80201a74:	00078513          	mv	a0,a5
    80201a78:	000700e7          	jalr	a4
                    written += 2;
    80201a7c:	fec42783          	lw	a5,-20(s0)
    80201a80:	0027879b          	addiw	a5,a5,2
    80201a84:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201a88:	fdc42783          	lw	a5,-36(s0)
    80201a8c:	fcf42a23          	sw	a5,-44(s0)
    80201a90:	0280006f          	j	80201ab8 <vprintfmt+0x4e8>
                    putch('0');
    80201a94:	f5843783          	ld	a5,-168(s0)
    80201a98:	03000513          	li	a0,48
    80201a9c:	000780e7          	jalr	a5
                    ++written;
    80201aa0:	fec42783          	lw	a5,-20(s0)
    80201aa4:	0017879b          	addiw	a5,a5,1
    80201aa8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201aac:	fd442783          	lw	a5,-44(s0)
    80201ab0:	0017879b          	addiw	a5,a5,1
    80201ab4:	fcf42a23          	sw	a5,-44(s0)
    80201ab8:	f8c42703          	lw	a4,-116(s0)
    80201abc:	fd442783          	lw	a5,-44(s0)
    80201ac0:	0007879b          	sext.w	a5,a5
    80201ac4:	fce7c8e3          	blt	a5,a4,80201a94 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201ac8:	fdc42783          	lw	a5,-36(s0)
    80201acc:	fff7879b          	addiw	a5,a5,-1
    80201ad0:	fcf42823          	sw	a5,-48(s0)
    80201ad4:	03c0006f          	j	80201b10 <vprintfmt+0x540>
                    putch(buf[i]);
    80201ad8:	fd042783          	lw	a5,-48(s0)
    80201adc:	ff078793          	addi	a5,a5,-16
    80201ae0:	008787b3          	add	a5,a5,s0
    80201ae4:	f807c783          	lbu	a5,-128(a5)
    80201ae8:	0007871b          	sext.w	a4,a5
    80201aec:	f5843783          	ld	a5,-168(s0)
    80201af0:	00070513          	mv	a0,a4
    80201af4:	000780e7          	jalr	a5
                    ++written;
    80201af8:	fec42783          	lw	a5,-20(s0)
    80201afc:	0017879b          	addiw	a5,a5,1
    80201b00:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201b04:	fd042783          	lw	a5,-48(s0)
    80201b08:	fff7879b          	addiw	a5,a5,-1
    80201b0c:	fcf42823          	sw	a5,-48(s0)
    80201b10:	fd042783          	lw	a5,-48(s0)
    80201b14:	0007879b          	sext.w	a5,a5
    80201b18:	fc07d0e3          	bgez	a5,80201ad8 <vprintfmt+0x508>
                }

                flags.in_format = false;
    80201b1c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201b20:	2700006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201b24:	f5043783          	ld	a5,-176(s0)
    80201b28:	0007c783          	lbu	a5,0(a5)
    80201b2c:	00078713          	mv	a4,a5
    80201b30:	06400793          	li	a5,100
    80201b34:	02f70663          	beq	a4,a5,80201b60 <vprintfmt+0x590>
    80201b38:	f5043783          	ld	a5,-176(s0)
    80201b3c:	0007c783          	lbu	a5,0(a5)
    80201b40:	00078713          	mv	a4,a5
    80201b44:	06900793          	li	a5,105
    80201b48:	00f70c63          	beq	a4,a5,80201b60 <vprintfmt+0x590>
    80201b4c:	f5043783          	ld	a5,-176(s0)
    80201b50:	0007c783          	lbu	a5,0(a5)
    80201b54:	00078713          	mv	a4,a5
    80201b58:	07500793          	li	a5,117
    80201b5c:	08f71063          	bne	a4,a5,80201bdc <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201b60:	f8144783          	lbu	a5,-127(s0)
    80201b64:	00078c63          	beqz	a5,80201b7c <vprintfmt+0x5ac>
    80201b68:	f4843783          	ld	a5,-184(s0)
    80201b6c:	00878713          	addi	a4,a5,8
    80201b70:	f4e43423          	sd	a4,-184(s0)
    80201b74:	0007b783          	ld	a5,0(a5)
    80201b78:	0140006f          	j	80201b8c <vprintfmt+0x5bc>
    80201b7c:	f4843783          	ld	a5,-184(s0)
    80201b80:	00878713          	addi	a4,a5,8
    80201b84:	f4e43423          	sd	a4,-184(s0)
    80201b88:	0007a783          	lw	a5,0(a5)
    80201b8c:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201b90:	fa843583          	ld	a1,-88(s0)
    80201b94:	f5043783          	ld	a5,-176(s0)
    80201b98:	0007c783          	lbu	a5,0(a5)
    80201b9c:	0007871b          	sext.w	a4,a5
    80201ba0:	07500793          	li	a5,117
    80201ba4:	40f707b3          	sub	a5,a4,a5
    80201ba8:	00f037b3          	snez	a5,a5
    80201bac:	0ff7f793          	zext.b	a5,a5
    80201bb0:	f8040713          	addi	a4,s0,-128
    80201bb4:	00070693          	mv	a3,a4
    80201bb8:	00078613          	mv	a2,a5
    80201bbc:	f5843503          	ld	a0,-168(s0)
    80201bc0:	f08ff0ef          	jal	802012c8 <print_dec_int>
    80201bc4:	00050793          	mv	a5,a0
    80201bc8:	fec42703          	lw	a4,-20(s0)
    80201bcc:	00f707bb          	addw	a5,a4,a5
    80201bd0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201bd4:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201bd8:	1b80006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201bdc:	f5043783          	ld	a5,-176(s0)
    80201be0:	0007c783          	lbu	a5,0(a5)
    80201be4:	00078713          	mv	a4,a5
    80201be8:	06e00793          	li	a5,110
    80201bec:	04f71c63          	bne	a4,a5,80201c44 <vprintfmt+0x674>
                if (flags.longflag) {
    80201bf0:	f8144783          	lbu	a5,-127(s0)
    80201bf4:	02078463          	beqz	a5,80201c1c <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201bf8:	f4843783          	ld	a5,-184(s0)
    80201bfc:	00878713          	addi	a4,a5,8
    80201c00:	f4e43423          	sd	a4,-184(s0)
    80201c04:	0007b783          	ld	a5,0(a5)
    80201c08:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201c0c:	fec42703          	lw	a4,-20(s0)
    80201c10:	fb043783          	ld	a5,-80(s0)
    80201c14:	00e7b023          	sd	a4,0(a5)
    80201c18:	0240006f          	j	80201c3c <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    80201c1c:	f4843783          	ld	a5,-184(s0)
    80201c20:	00878713          	addi	a4,a5,8
    80201c24:	f4e43423          	sd	a4,-184(s0)
    80201c28:	0007b783          	ld	a5,0(a5)
    80201c2c:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201c30:	fb843783          	ld	a5,-72(s0)
    80201c34:	fec42703          	lw	a4,-20(s0)
    80201c38:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201c3c:	f8040023          	sb	zero,-128(s0)
    80201c40:	1500006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201c44:	f5043783          	ld	a5,-176(s0)
    80201c48:	0007c783          	lbu	a5,0(a5)
    80201c4c:	00078713          	mv	a4,a5
    80201c50:	07300793          	li	a5,115
    80201c54:	02f71e63          	bne	a4,a5,80201c90 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201c58:	f4843783          	ld	a5,-184(s0)
    80201c5c:	00878713          	addi	a4,a5,8
    80201c60:	f4e43423          	sd	a4,-184(s0)
    80201c64:	0007b783          	ld	a5,0(a5)
    80201c68:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201c6c:	fc043583          	ld	a1,-64(s0)
    80201c70:	f5843503          	ld	a0,-168(s0)
    80201c74:	dccff0ef          	jal	80201240 <puts_wo_nl>
    80201c78:	00050793          	mv	a5,a0
    80201c7c:	fec42703          	lw	a4,-20(s0)
    80201c80:	00f707bb          	addw	a5,a4,a5
    80201c84:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201c88:	f8040023          	sb	zero,-128(s0)
    80201c8c:	1040006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201c90:	f5043783          	ld	a5,-176(s0)
    80201c94:	0007c783          	lbu	a5,0(a5)
    80201c98:	00078713          	mv	a4,a5
    80201c9c:	06300793          	li	a5,99
    80201ca0:	02f71e63          	bne	a4,a5,80201cdc <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201ca4:	f4843783          	ld	a5,-184(s0)
    80201ca8:	00878713          	addi	a4,a5,8
    80201cac:	f4e43423          	sd	a4,-184(s0)
    80201cb0:	0007a783          	lw	a5,0(a5)
    80201cb4:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201cb8:	fcc42703          	lw	a4,-52(s0)
    80201cbc:	f5843783          	ld	a5,-168(s0)
    80201cc0:	00070513          	mv	a0,a4
    80201cc4:	000780e7          	jalr	a5
                ++written;
    80201cc8:	fec42783          	lw	a5,-20(s0)
    80201ccc:	0017879b          	addiw	a5,a5,1
    80201cd0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201cd4:	f8040023          	sb	zero,-128(s0)
    80201cd8:	0b80006f          	j	80201d90 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201cdc:	f5043783          	ld	a5,-176(s0)
    80201ce0:	0007c783          	lbu	a5,0(a5)
    80201ce4:	00078713          	mv	a4,a5
    80201ce8:	02500793          	li	a5,37
    80201cec:	02f71263          	bne	a4,a5,80201d10 <vprintfmt+0x740>
                putch('%');
    80201cf0:	f5843783          	ld	a5,-168(s0)
    80201cf4:	02500513          	li	a0,37
    80201cf8:	000780e7          	jalr	a5
                ++written;
    80201cfc:	fec42783          	lw	a5,-20(s0)
    80201d00:	0017879b          	addiw	a5,a5,1
    80201d04:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201d08:	f8040023          	sb	zero,-128(s0)
    80201d0c:	0840006f          	j	80201d90 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201d10:	f5043783          	ld	a5,-176(s0)
    80201d14:	0007c783          	lbu	a5,0(a5)
    80201d18:	0007871b          	sext.w	a4,a5
    80201d1c:	f5843783          	ld	a5,-168(s0)
    80201d20:	00070513          	mv	a0,a4
    80201d24:	000780e7          	jalr	a5
                ++written;
    80201d28:	fec42783          	lw	a5,-20(s0)
    80201d2c:	0017879b          	addiw	a5,a5,1
    80201d30:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201d34:	f8040023          	sb	zero,-128(s0)
    80201d38:	0580006f          	j	80201d90 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201d3c:	f5043783          	ld	a5,-176(s0)
    80201d40:	0007c783          	lbu	a5,0(a5)
    80201d44:	00078713          	mv	a4,a5
    80201d48:	02500793          	li	a5,37
    80201d4c:	02f71063          	bne	a4,a5,80201d6c <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201d50:	f8043023          	sd	zero,-128(s0)
    80201d54:	f8043423          	sd	zero,-120(s0)
    80201d58:	00100793          	li	a5,1
    80201d5c:	f8f40023          	sb	a5,-128(s0)
    80201d60:	fff00793          	li	a5,-1
    80201d64:	f8f42623          	sw	a5,-116(s0)
    80201d68:	0280006f          	j	80201d90 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201d6c:	f5043783          	ld	a5,-176(s0)
    80201d70:	0007c783          	lbu	a5,0(a5)
    80201d74:	0007871b          	sext.w	a4,a5
    80201d78:	f5843783          	ld	a5,-168(s0)
    80201d7c:	00070513          	mv	a0,a4
    80201d80:	000780e7          	jalr	a5
            ++written;
    80201d84:	fec42783          	lw	a5,-20(s0)
    80201d88:	0017879b          	addiw	a5,a5,1
    80201d8c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201d90:	f5043783          	ld	a5,-176(s0)
    80201d94:	00178793          	addi	a5,a5,1
    80201d98:	f4f43823          	sd	a5,-176(s0)
    80201d9c:	f5043783          	ld	a5,-176(s0)
    80201da0:	0007c783          	lbu	a5,0(a5)
    80201da4:	84079ce3          	bnez	a5,802015fc <vprintfmt+0x2c>
        }
    }

    return written;
    80201da8:	fec42783          	lw	a5,-20(s0)
}
    80201dac:	00078513          	mv	a0,a5
    80201db0:	0b813083          	ld	ra,184(sp)
    80201db4:	0b013403          	ld	s0,176(sp)
    80201db8:	0c010113          	addi	sp,sp,192
    80201dbc:	00008067          	ret

0000000080201dc0 <printk>:

int printk(const char* s, ...) {
    80201dc0:	f9010113          	addi	sp,sp,-112
    80201dc4:	02113423          	sd	ra,40(sp)
    80201dc8:	02813023          	sd	s0,32(sp)
    80201dcc:	03010413          	addi	s0,sp,48
    80201dd0:	fca43c23          	sd	a0,-40(s0)
    80201dd4:	00b43423          	sd	a1,8(s0)
    80201dd8:	00c43823          	sd	a2,16(s0)
    80201ddc:	00d43c23          	sd	a3,24(s0)
    80201de0:	02e43023          	sd	a4,32(s0)
    80201de4:	02f43423          	sd	a5,40(s0)
    80201de8:	03043823          	sd	a6,48(s0)
    80201dec:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201df0:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201df4:	04040793          	addi	a5,s0,64
    80201df8:	fcf43823          	sd	a5,-48(s0)
    80201dfc:	fd043783          	ld	a5,-48(s0)
    80201e00:	fc878793          	addi	a5,a5,-56
    80201e04:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201e08:	fe043783          	ld	a5,-32(s0)
    80201e0c:	00078613          	mv	a2,a5
    80201e10:	fd843583          	ld	a1,-40(s0)
    80201e14:	fffff517          	auipc	a0,0xfffff
    80201e18:	11850513          	addi	a0,a0,280 # 80200f2c <putc>
    80201e1c:	fb4ff0ef          	jal	802015d0 <vprintfmt>
    80201e20:	00050793          	mv	a5,a0
    80201e24:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201e28:	fec42783          	lw	a5,-20(s0)
}
    80201e2c:	00078513          	mv	a0,a5
    80201e30:	02813083          	ld	ra,40(sp)
    80201e34:	02013403          	ld	s0,32(sp)
    80201e38:	07010113          	addi	sp,sp,112
    80201e3c:	00008067          	ret

0000000080201e40 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    80201e40:	fe010113          	addi	sp,sp,-32
    80201e44:	00813c23          	sd	s0,24(sp)
    80201e48:	02010413          	addi	s0,sp,32
    80201e4c:	00050793          	mv	a5,a0
    80201e50:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    80201e54:	fec42783          	lw	a5,-20(s0)
    80201e58:	fff7879b          	addiw	a5,a5,-1
    80201e5c:	0007879b          	sext.w	a5,a5
    80201e60:	02079713          	slli	a4,a5,0x20
    80201e64:	02075713          	srli	a4,a4,0x20
    80201e68:	00402797          	auipc	a5,0x402
    80201e6c:	2b078793          	addi	a5,a5,688 # 80604118 <seed>
    80201e70:	00e7b023          	sd	a4,0(a5)
}
    80201e74:	00000013          	nop
    80201e78:	01813403          	ld	s0,24(sp)
    80201e7c:	02010113          	addi	sp,sp,32
    80201e80:	00008067          	ret

0000000080201e84 <rand>:

int rand(void) {
    80201e84:	ff010113          	addi	sp,sp,-16
    80201e88:	00813423          	sd	s0,8(sp)
    80201e8c:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    80201e90:	00402797          	auipc	a5,0x402
    80201e94:	28878793          	addi	a5,a5,648 # 80604118 <seed>
    80201e98:	0007b703          	ld	a4,0(a5)
    80201e9c:	00000797          	auipc	a5,0x0
    80201ea0:	54c78793          	addi	a5,a5,1356 # 802023e8 <lowerxdigits.0+0x18>
    80201ea4:	0007b783          	ld	a5,0(a5)
    80201ea8:	02f707b3          	mul	a5,a4,a5
    80201eac:	00178713          	addi	a4,a5,1
    80201eb0:	00402797          	auipc	a5,0x402
    80201eb4:	26878793          	addi	a5,a5,616 # 80604118 <seed>
    80201eb8:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    80201ebc:	00402797          	auipc	a5,0x402
    80201ec0:	25c78793          	addi	a5,a5,604 # 80604118 <seed>
    80201ec4:	0007b783          	ld	a5,0(a5)
    80201ec8:	0217d793          	srli	a5,a5,0x21
    80201ecc:	0007879b          	sext.w	a5,a5
}
    80201ed0:	00078513          	mv	a0,a5
    80201ed4:	00813403          	ld	s0,8(sp)
    80201ed8:	01010113          	addi	sp,sp,16
    80201edc:	00008067          	ret

0000000080201ee0 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201ee0:	fc010113          	addi	sp,sp,-64
    80201ee4:	02813c23          	sd	s0,56(sp)
    80201ee8:	04010413          	addi	s0,sp,64
    80201eec:	fca43c23          	sd	a0,-40(s0)
    80201ef0:	00058793          	mv	a5,a1
    80201ef4:	fcc43423          	sd	a2,-56(s0)
    80201ef8:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201efc:	fd843783          	ld	a5,-40(s0)
    80201f00:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201f04:	fe043423          	sd	zero,-24(s0)
    80201f08:	0280006f          	j	80201f30 <memset+0x50>
        s[i] = c;
    80201f0c:	fe043703          	ld	a4,-32(s0)
    80201f10:	fe843783          	ld	a5,-24(s0)
    80201f14:	00f707b3          	add	a5,a4,a5
    80201f18:	fd442703          	lw	a4,-44(s0)
    80201f1c:	0ff77713          	zext.b	a4,a4
    80201f20:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201f24:	fe843783          	ld	a5,-24(s0)
    80201f28:	00178793          	addi	a5,a5,1
    80201f2c:	fef43423          	sd	a5,-24(s0)
    80201f30:	fe843703          	ld	a4,-24(s0)
    80201f34:	fc843783          	ld	a5,-56(s0)
    80201f38:	fcf76ae3          	bltu	a4,a5,80201f0c <memset+0x2c>
    }
    return dest;
    80201f3c:	fd843783          	ld	a5,-40(s0)
}
    80201f40:	00078513          	mv	a0,a5
    80201f44:	03813403          	ld	s0,56(sp)
    80201f48:	04010113          	addi	sp,sp,64
    80201f4c:	00008067          	ret
