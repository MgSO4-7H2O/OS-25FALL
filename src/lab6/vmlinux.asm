
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    # ------------------
    # - your code here -
    # ------------------

    # load the stack top address into the stack pointer
    la sp, boot_stack_top
ffffffe000200000:	0040d117          	auipc	sp,0x40d
ffffffe000200004:	00010113          	mv	sp,sp

    # 启动虚拟内存
    call setup_vm
ffffffe000200008:	0c4030ef          	jal	ffffffe0002030cc <setup_vm>
    call relocate
ffffffe00020000c:	048000ef          	jal	ffffffe000200054 <relocate>

    # 开启trap处理新增指令，使用一个临时寄存器t0来存储_traps的地址
    la t0, _traps
ffffffe000200010:	00000297          	auipc	t0,0x0
ffffffe000200014:	15c28293          	addi	t0,t0,348 # ffffffe00020016c <_traps>
    csrw stvec, t0
ffffffe000200018:	10529073          	csrw	stvec,t0
    
    # 初始化物理内存管理系统
    call mm_init
ffffffe00020001c:	505000ef          	jal	ffffffe000200d20 <mm_init>

    call setup_vm_final
ffffffe000200020:	17c030ef          	jal	ffffffe00020319c <setup_vm_final>

    # 初始化线程
    call task_init
ffffffe000200024:	725000ef          	jal	ffffffe000200f48 <task_init>

    call virtio_dev_init
ffffffe000200028:	554060ef          	jal	ffffffe00020657c <virtio_dev_init>
    call mbr_init
ffffffe00020002c:	7b8050ef          	jal	ffffffe0002057e4 <mbr_init>

    # 开启时钟中断，sie[STIE] 置 1
    li t0, (1 << 5)
ffffffe000200030:	02000293          	li	t0,32
    csrs sie, t0
ffffffe000200034:	1042a073          	csrs	sie,t0

    # 设置第一次时钟中断
    rdtime t0
ffffffe000200038:	c01022f3          	rdtime	t0
    li t1, 10000000 # TIMECLOCK为10000000
ffffffe00020003c:	00989337          	lui	t1,0x989
ffffffe000200040:	6803031b          	addiw	t1,t1,1664 # 989680 <OPENSBI_SIZE+0x789680>
    add t0, t0, t1
ffffffe000200044:	006282b3          	add	t0,t0,t1
    # 参数传递
    mv a0, t0
ffffffe000200048:	00028513          	mv	a0,t0

    call sbi_set_timer
ffffffe00020004c:	564020ef          	jal	ffffffe0002025b0 <sbi_set_timer>
    #开启全局中断，sstatus[SIE] 置 1
    # li t0, (1 << 1)
    # csrs sstatus, t0
    
    # call the function
    call start_kernel
ffffffe000200050:	5f0030ef          	jal	ffffffe000203640 <start_kernel>

ffffffe000200054 <relocate>:

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li t0, 0xffffffdf80000000
ffffffe000200054:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200058:	01f29293          	slli	t0,t0,0x1f
    add ra, ra, t0
ffffffe00020005c:	005080b3          	add	ra,ra,t0
    add sp, sp, t0
ffffffe000200060:	00510133          	add	sp,sp,t0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
ffffffe000200064:	12000073          	sfence.vma

    # set satp with early_pgtbl
    la t0, early_pgtbl
ffffffe000200068:	0040e297          	auipc	t0,0x40e
ffffffe00020006c:	f9828293          	addi	t0,t0,-104 # ffffffe00060e000 <early_pgtbl>

    # PA >> 12 == PPN
    srli t0, t0, 12
ffffffe000200070:	00c2d293          	srli	t0,t0,0xc

    # 构造satp
    # MODE = 8
    li t1, 8
ffffffe000200074:	00800313          	li	t1,8
    slli t1, t1, 60
ffffffe000200078:	03c31313          	slli	t1,t1,0x3c
    or t1, t1, t0
ffffffe00020007c:	00536333          	or	t1,t1,t0

    csrw satp, t1
ffffffe000200080:	18031073          	csrw	satp,t1

    ret
ffffffe000200084:	00008067          	ret

ffffffe000200088 <__dummy>:
    .extern dummy
    .globl __dummy
    .globl __switch_to
__dummy:
    # 切换栈
    csrr t0, sscratch
ffffffe000200088:	140022f3          	csrr	t0,sscratch
    csrw sscratch, sp
ffffffe00020008c:	14011073          	csrw	sscratch,sp
    addi sp, t0, 0
ffffffe000200090:	00028113          	mv	sp,t0

    # 设置进入User mode的地址为代码段起始地址0
    # csrw sepc, x0

    # 从S模式返回
    sret
ffffffe000200094:	10200073          	sret

ffffffe000200098 <__switch_to>:

__switch_to:
    
    # uint64_t变量为8字节对齐
    addi t0, a0, 32 # t0: prev->thread
ffffffe000200098:	02050293          	addi	t0,a0,32
    addi t1, a1, 32 # t1: next->thread
ffffffe00020009c:	02058313          	addi	t1,a1,32

    # save state to prev process
    sd ra, 0(t0)
ffffffe0002000a0:	0012b023          	sd	ra,0(t0)
    sd sp, 8(t0)
ffffffe0002000a4:	0022b423          	sd	sp,8(t0)
    sd s0, 16(t0)
ffffffe0002000a8:	0082b823          	sd	s0,16(t0)
    sd s1, 24(t0)
ffffffe0002000ac:	0092bc23          	sd	s1,24(t0)
    sd s2, 32(t0)
ffffffe0002000b0:	0322b023          	sd	s2,32(t0)
    sd s3, 40(t0)
ffffffe0002000b4:	0332b423          	sd	s3,40(t0)
    sd s4, 48(t0)
ffffffe0002000b8:	0342b823          	sd	s4,48(t0)
    sd s5, 56(t0)
ffffffe0002000bc:	0352bc23          	sd	s5,56(t0)
    sd s6, 64(t0)
ffffffe0002000c0:	0562b023          	sd	s6,64(t0)
    sd s7, 72(t0)
ffffffe0002000c4:	0572b423          	sd	s7,72(t0)
    sd s8, 80(t0)
ffffffe0002000c8:	0582b823          	sd	s8,80(t0)
    sd s9, 88(t0)
ffffffe0002000cc:	0592bc23          	sd	s9,88(t0)
    sd s10, 96(t0)
ffffffe0002000d0:	07a2b023          	sd	s10,96(t0)
    sd s11, 104(t0)
ffffffe0002000d4:	07b2b423          	sd	s11,104(t0)

    csrr t2, sepc
ffffffe0002000d8:	141023f3          	csrr	t2,sepc
    sd t2, 112(t0)
ffffffe0002000dc:	0672b823          	sd	t2,112(t0)
    csrr t2, sstatus
ffffffe0002000e0:	100023f3          	csrr	t2,sstatus
    sd t2, 120(t0)
ffffffe0002000e4:	0672bc23          	sd	t2,120(t0)
    csrr t2, sscratch
ffffffe0002000e8:	140023f3          	csrr	t2,sscratch
    sd t2, 128(t0)
ffffffe0002000ec:	0872b023          	sd	t2,128(t0)

    # restore state from next process
    ld ra, 0(t1)
ffffffe0002000f0:	00033083          	ld	ra,0(t1)
    ld sp, 8(t1)
ffffffe0002000f4:	00833103          	ld	sp,8(t1)
    ld s0, 16(t1)
ffffffe0002000f8:	01033403          	ld	s0,16(t1)
    ld s1, 24(t1)
ffffffe0002000fc:	01833483          	ld	s1,24(t1)
    ld s2, 32(t1)
ffffffe000200100:	02033903          	ld	s2,32(t1)
    ld s3, 40(t1)
ffffffe000200104:	02833983          	ld	s3,40(t1)
    ld s4, 48(t1)
ffffffe000200108:	03033a03          	ld	s4,48(t1)
    ld s5, 56(t1)
ffffffe00020010c:	03833a83          	ld	s5,56(t1)
    ld s6, 64(t1)
ffffffe000200110:	04033b03          	ld	s6,64(t1)
    ld s7, 72(t1)
ffffffe000200114:	04833b83          	ld	s7,72(t1)
    ld s8, 80(t1)
ffffffe000200118:	05033c03          	ld	s8,80(t1)
    ld s9, 88(t1)
ffffffe00020011c:	05833c83          	ld	s9,88(t1)
    ld s10, 96(t1)
ffffffe000200120:	06033d03          	ld	s10,96(t1)
    ld s11, 104(t1)
ffffffe000200124:	06833d83          	ld	s11,104(t1)

    ld t2, 112(t1)
ffffffe000200128:	07033383          	ld	t2,112(t1)
    csrw sepc, t2
ffffffe00020012c:	14139073          	csrw	sepc,t2
    ld t2, 120(t1)
ffffffe000200130:	07833383          	ld	t2,120(t1)
    csrw sstatus, t2
ffffffe000200134:	10039073          	csrw	sstatus,t2
    ld t2, 128(t1)
ffffffe000200138:	08033383          	ld	t2,128(t1)
    csrw sscratch, t2
ffffffe00020013c:	14039073          	csrw	sscratch,t2

    # get pgd, calculate satp
    ld t2, 136(t1)
ffffffe000200140:	08833383          	ld	t2,136(t1)
    li t3, PA2VA_OFFSET
ffffffe000200144:	fbf00e1b          	addiw	t3,zero,-65
ffffffe000200148:	01fe1e13          	slli	t3,t3,0x1f
    sub t2, t2, t3
ffffffe00020014c:	41c383b3          	sub	t2,t2,t3
    srli t2, t2, 12
ffffffe000200150:	00c3d393          	srli	t2,t2,0xc
    li t3, SATP_MODE_SV39
ffffffe000200154:	fff00e1b          	addiw	t3,zero,-1
ffffffe000200158:	03fe1e13          	slli	t3,t3,0x3f
    or t2, t2, t3
ffffffe00020015c:	01c3e3b3          	or	t2,t2,t3

    csrw satp, t2
ffffffe000200160:	18039073          	csrw	satp,t2
    
    sfence.vma
ffffffe000200164:	12000073          	sfence.vma
    

    ret
ffffffe000200168:	00008067          	ret

ffffffe00020016c <_traps>:
_traps:
    # 用户态触发trap需要进入内核态
    # 内核态触发trap，不需要切换
    # 内核态检查条件：sscratch == 0
    csrrw sp, sscratch, sp
ffffffe00020016c:	14011173          	csrrw	sp,sscratch,sp
    bnez sp, smode_no_switch
ffffffe000200170:	00011463          	bnez	sp,ffffffe000200178 <smode_no_switch>
    csrrw sp, sscratch, sp
ffffffe000200174:	14011173          	csrrw	sp,sscratch,sp

ffffffe000200178 <smode_no_switch>:
    # 1. save 32 registers and sepc to stack
    # 2. call trap_handler
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    # 4. return from trap
smode_no_switch:
    addi sp, sp, -264
ffffffe000200178:	ef810113          	addi	sp,sp,-264 # ffffffe00060cef8 <_sbss+0x3ffef8>
    # 保存寄存器
    sd zero, 0(sp)
ffffffe00020017c:	00013023          	sd	zero,0(sp)
    sd ra, 8(sp)
ffffffe000200180:	00113423          	sd	ra,8(sp)
    sd sp, 16(sp)
ffffffe000200184:	00213823          	sd	sp,16(sp)
    sd gp, 24(sp)
ffffffe000200188:	00313c23          	sd	gp,24(sp)
    sd tp, 32(sp)
ffffffe00020018c:	02413023          	sd	tp,32(sp)
    sd t0, 40(sp)
ffffffe000200190:	02513423          	sd	t0,40(sp)
    sd t1, 48(sp)
ffffffe000200194:	02613823          	sd	t1,48(sp)
    sd t2, 56(sp)
ffffffe000200198:	02713c23          	sd	t2,56(sp)
    sd s0, 64(sp)
ffffffe00020019c:	04813023          	sd	s0,64(sp)
    sd s1, 72(sp)
ffffffe0002001a0:	04913423          	sd	s1,72(sp)
    sd a0, 80(sp)
ffffffe0002001a4:	04a13823          	sd	a0,80(sp)
    sd a1, 88(sp)
ffffffe0002001a8:	04b13c23          	sd	a1,88(sp)
    sd a2, 96(sp)
ffffffe0002001ac:	06c13023          	sd	a2,96(sp)
    sd a3, 104(sp)
ffffffe0002001b0:	06d13423          	sd	a3,104(sp)
    sd a4, 112(sp)
ffffffe0002001b4:	06e13823          	sd	a4,112(sp)
    sd a5, 120(sp)
ffffffe0002001b8:	06f13c23          	sd	a5,120(sp)
    sd a6, 128(sp)
ffffffe0002001bc:	09013023          	sd	a6,128(sp)
    sd a7, 136(sp)
ffffffe0002001c0:	09113423          	sd	a7,136(sp)
    sd s2, 144(sp)
ffffffe0002001c4:	09213823          	sd	s2,144(sp)
    sd s3, 152(sp)
ffffffe0002001c8:	09313c23          	sd	s3,152(sp)
    sd s4, 160(sp)
ffffffe0002001cc:	0b413023          	sd	s4,160(sp)
    sd s5, 168(sp)
ffffffe0002001d0:	0b513423          	sd	s5,168(sp)
    sd s6, 176(sp)
ffffffe0002001d4:	0b613823          	sd	s6,176(sp)
    sd s7, 184(sp)
ffffffe0002001d8:	0b713c23          	sd	s7,184(sp)
    sd s8, 192(sp)
ffffffe0002001dc:	0d813023          	sd	s8,192(sp)
    sd s9, 200(sp)
ffffffe0002001e0:	0d913423          	sd	s9,200(sp)
    sd s10, 208(sp)
ffffffe0002001e4:	0da13823          	sd	s10,208(sp)
    sd s11, 216(sp)
ffffffe0002001e8:	0db13c23          	sd	s11,216(sp)
    sd t3, 224(sp)
ffffffe0002001ec:	0fc13023          	sd	t3,224(sp)
    sd t4, 232(sp)
ffffffe0002001f0:	0fd13423          	sd	t4,232(sp)
    sd t5, 240(sp)
ffffffe0002001f4:	0fe13823          	sd	t5,240(sp)
    sd t6, 248(sp)
ffffffe0002001f8:	0ff13c23          	sd	t6,248(sp)
    
    # 保存 sepc
    
    csrr t0, sepc
ffffffe0002001fc:	141022f3          	csrr	t0,sepc
    sd t0, 256(sp)
ffffffe000200200:	10513023          	sd	t0,256(sp)

    # 传递参数
    # a0 = scause a1 = sepc a2 = sp
    csrr a0, scause
ffffffe000200204:	14202573          	csrr	a0,scause
    ld a1, 256(sp)
ffffffe000200208:	10013583          	ld	a1,256(sp)
    mv a2, sp
ffffffe00020020c:	00010613          	mv	a2,sp

    call trap_handler
ffffffe000200210:	39d020ef          	jal	ffffffe000202dac <trap_handler>

ffffffe000200214 <__ret_from_fork>:

    .global __ret_from_fork
__ret_from_fork:
    # 恢复寄存器
    ld t0, 256(sp)
ffffffe000200214:	10013283          	ld	t0,256(sp)
    csrw sepc, t0
ffffffe000200218:	14129073          	csrw	sepc,t0
    ld t6, 248(sp)
ffffffe00020021c:	0f813f83          	ld	t6,248(sp)
    ld t5, 240(sp)
ffffffe000200220:	0f013f03          	ld	t5,240(sp)
    ld t4, 232(sp)
ffffffe000200224:	0e813e83          	ld	t4,232(sp)
    ld t3, 224(sp)
ffffffe000200228:	0e013e03          	ld	t3,224(sp)
    ld s11, 216(sp)
ffffffe00020022c:	0d813d83          	ld	s11,216(sp)
    ld s10, 208(sp)
ffffffe000200230:	0d013d03          	ld	s10,208(sp)
    ld s9, 200(sp)
ffffffe000200234:	0c813c83          	ld	s9,200(sp)
    ld s8, 192(sp)
ffffffe000200238:	0c013c03          	ld	s8,192(sp)
    ld s7, 184(sp)
ffffffe00020023c:	0b813b83          	ld	s7,184(sp)
    ld s6, 176(sp)
ffffffe000200240:	0b013b03          	ld	s6,176(sp)
    ld s5, 168(sp)
ffffffe000200244:	0a813a83          	ld	s5,168(sp)
    ld s4, 160(sp)
ffffffe000200248:	0a013a03          	ld	s4,160(sp)
    ld s3, 152(sp)
ffffffe00020024c:	09813983          	ld	s3,152(sp)
    ld s2, 144(sp)
ffffffe000200250:	09013903          	ld	s2,144(sp)
    ld a7, 136(sp)
ffffffe000200254:	08813883          	ld	a7,136(sp)
    ld a6, 128(sp)
ffffffe000200258:	08013803          	ld	a6,128(sp)
    ld a5, 120(sp)
ffffffe00020025c:	07813783          	ld	a5,120(sp)
    ld a4, 112(sp)
ffffffe000200260:	07013703          	ld	a4,112(sp)
    ld a3, 104(sp)
ffffffe000200264:	06813683          	ld	a3,104(sp)
    ld a2, 96(sp)
ffffffe000200268:	06013603          	ld	a2,96(sp)
    ld a1, 88(sp)
ffffffe00020026c:	05813583          	ld	a1,88(sp)
    ld a0, 80(sp)
ffffffe000200270:	05013503          	ld	a0,80(sp)
    ld s1, 72(sp)
ffffffe000200274:	04813483          	ld	s1,72(sp)
    ld s0, 64(sp)
ffffffe000200278:	04013403          	ld	s0,64(sp)
    ld t2, 56(sp)
ffffffe00020027c:	03813383          	ld	t2,56(sp)
    ld t1, 48(sp)
ffffffe000200280:	03013303          	ld	t1,48(sp)
    ld t0, 40(sp)
ffffffe000200284:	02813283          	ld	t0,40(sp)
    ld tp, 32(sp)
ffffffe000200288:	02013203          	ld	tp,32(sp)
    ld gp, 24(sp)
ffffffe00020028c:	01813183          	ld	gp,24(sp)
    ld sp, 16(sp)
ffffffe000200290:	01013103          	ld	sp,16(sp)
    ld ra, 8(sp)
ffffffe000200294:	00813083          	ld	ra,8(sp)
    ld zero, 0(sp)
ffffffe000200298:	00013003          	ld	zero,0(sp)

    # 恢复栈顶
    addi sp, sp, 264
ffffffe00020029c:	10810113          	addi	sp,sp,264

    # 用户态切换
    csrrw sp, sscratch, sp
ffffffe0002002a0:	14011173          	csrrw	sp,sscratch,sp
    bnez sp, smode_return
ffffffe0002002a4:	00011463          	bnez	sp,ffffffe0002002ac <smode_return>
    csrrw sp, sscratch, t0
ffffffe0002002a8:	14029173          	csrrw	sp,sscratch,t0

ffffffe0002002ac <smode_return>:

smode_return:
    # 返回
ffffffe0002002ac:	10200073          	sret

ffffffe0002002b0 <get_cycles>:
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 20000000;

uint64_t get_cycles() {
ffffffe0002002b0:	fe010113          	addi	sp,sp,-32
ffffffe0002002b4:	00813c23          	sd	s0,24(sp)
ffffffe0002002b8:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t time;
    asm volatile(
ffffffe0002002bc:	c01027f3          	rdtime	a5
ffffffe0002002c0:	fef43423          	sd	a5,-24(s0)
        "rdtime %[time]"
        : [time] "=r"(time)
    );
    return time;
ffffffe0002002c4:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002c8:	00078513          	mv	a0,a5
ffffffe0002002cc:	01813403          	ld	s0,24(sp)
ffffffe0002002d0:	02010113          	addi	sp,sp,32
ffffffe0002002d4:	00008067          	ret

ffffffe0002002d8 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe0002002d8:	fe010113          	addi	sp,sp,-32
ffffffe0002002dc:	00113c23          	sd	ra,24(sp)
ffffffe0002002e0:	00813823          	sd	s0,16(sp)
ffffffe0002002e4:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe0002002e8:	fc9ff0ef          	jal	ffffffe0002002b0 <get_cycles>
ffffffe0002002ec:	00050713          	mv	a4,a0
ffffffe0002002f0:	00009797          	auipc	a5,0x9
ffffffe0002002f4:	d1078793          	addi	a5,a5,-752 # ffffffe000209000 <TIMECLOCK>
ffffffe0002002f8:	0007b783          	ld	a5,0(a5)
ffffffe0002002fc:	00f707b3          	add	a5,a4,a5
ffffffe000200300:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe000200304:	fe843503          	ld	a0,-24(s0)
ffffffe000200308:	2a8020ef          	jal	ffffffe0002025b0 <sbi_set_timer>
ffffffe00020030c:	00000013          	nop
ffffffe000200310:	01813083          	ld	ra,24(sp)
ffffffe000200314:	01013403          	ld	s0,16(sp)
ffffffe000200318:	02010113          	addi	sp,sp,32
ffffffe00020031c:	00008067          	ret

ffffffe000200320 <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe000200320:	fe010113          	addi	sp,sp,-32
ffffffe000200324:	00813c23          	sd	s0,24(sp)
ffffffe000200328:	02010413          	addi	s0,sp,32
ffffffe00020032c:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe000200330:	fe843783          	ld	a5,-24(s0)
ffffffe000200334:	fff78793          	addi	a5,a5,-1
ffffffe000200338:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe00020033c:	fe843783          	ld	a5,-24(s0)
ffffffe000200340:	0017d793          	srli	a5,a5,0x1
ffffffe000200344:	fe843703          	ld	a4,-24(s0)
ffffffe000200348:	00f767b3          	or	a5,a4,a5
ffffffe00020034c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe000200350:	fe843783          	ld	a5,-24(s0)
ffffffe000200354:	0027d793          	srli	a5,a5,0x2
ffffffe000200358:	fe843703          	ld	a4,-24(s0)
ffffffe00020035c:	00f767b3          	or	a5,a4,a5
ffffffe000200360:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe000200364:	fe843783          	ld	a5,-24(s0)
ffffffe000200368:	0047d793          	srli	a5,a5,0x4
ffffffe00020036c:	fe843703          	ld	a4,-24(s0)
ffffffe000200370:	00f767b3          	or	a5,a4,a5
ffffffe000200374:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe000200378:	fe843783          	ld	a5,-24(s0)
ffffffe00020037c:	0087d793          	srli	a5,a5,0x8
ffffffe000200380:	fe843703          	ld	a4,-24(s0)
ffffffe000200384:	00f767b3          	or	a5,a4,a5
ffffffe000200388:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe00020038c:	fe843783          	ld	a5,-24(s0)
ffffffe000200390:	0107d793          	srli	a5,a5,0x10
ffffffe000200394:	fe843703          	ld	a4,-24(s0)
ffffffe000200398:	00f767b3          	or	a5,a4,a5
ffffffe00020039c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe0002003a0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003a4:	0207d793          	srli	a5,a5,0x20
ffffffe0002003a8:	fe843703          	ld	a4,-24(s0)
ffffffe0002003ac:	00f767b3          	or	a5,a4,a5
ffffffe0002003b0:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe0002003b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003b8:	00178793          	addi	a5,a5,1
}
ffffffe0002003bc:	00078513          	mv	a0,a5
ffffffe0002003c0:	01813403          	ld	s0,24(sp)
ffffffe0002003c4:	02010113          	addi	sp,sp,32
ffffffe0002003c8:	00008067          	ret

ffffffe0002003cc <buddy_init>:

void buddy_init() {
ffffffe0002003cc:	fd010113          	addi	sp,sp,-48
ffffffe0002003d0:	02113423          	sd	ra,40(sp)
ffffffe0002003d4:	02813023          	sd	s0,32(sp)
ffffffe0002003d8:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe0002003dc:	000087b7          	lui	a5,0x8
ffffffe0002003e0:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe0002003e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002003e8:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe0002003ec:	fe843783          	ld	a5,-24(s0)
ffffffe0002003f0:	00f777b3          	and	a5,a4,a5
ffffffe0002003f4:	00078863          	beqz	a5,ffffffe000200404 <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe0002003f8:	fe843503          	ld	a0,-24(s0)
ffffffe0002003fc:	f25ff0ef          	jal	ffffffe000200320 <fixsize>
ffffffe000200400:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe000200404:	0040d797          	auipc	a5,0x40d
ffffffe000200408:	c3c78793          	addi	a5,a5,-964 # ffffffe00060d040 <buddy>
ffffffe00020040c:	fe843703          	ld	a4,-24(s0)
ffffffe000200410:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe000200414:	00009797          	auipc	a5,0x9
ffffffe000200418:	bf478793          	addi	a5,a5,-1036 # ffffffe000209008 <free_page_start>
ffffffe00020041c:	0007b703          	ld	a4,0(a5)
ffffffe000200420:	0040d797          	auipc	a5,0x40d
ffffffe000200424:	c2078793          	addi	a5,a5,-992 # ffffffe00060d040 <buddy>
ffffffe000200428:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe00020042c:	00009797          	auipc	a5,0x9
ffffffe000200430:	bdc78793          	addi	a5,a5,-1060 # ffffffe000209008 <free_page_start>
ffffffe000200434:	0007b703          	ld	a4,0(a5)
ffffffe000200438:	0040d797          	auipc	a5,0x40d
ffffffe00020043c:	c0878793          	addi	a5,a5,-1016 # ffffffe00060d040 <buddy>
ffffffe000200440:	0007b783          	ld	a5,0(a5)
ffffffe000200444:	00479793          	slli	a5,a5,0x4
ffffffe000200448:	00f70733          	add	a4,a4,a5
ffffffe00020044c:	00009797          	auipc	a5,0x9
ffffffe000200450:	bbc78793          	addi	a5,a5,-1092 # ffffffe000209008 <free_page_start>
ffffffe000200454:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe000200458:	0040d797          	auipc	a5,0x40d
ffffffe00020045c:	be878793          	addi	a5,a5,-1048 # ffffffe00060d040 <buddy>
ffffffe000200460:	0087b703          	ld	a4,8(a5)
ffffffe000200464:	0040d797          	auipc	a5,0x40d
ffffffe000200468:	bdc78793          	addi	a5,a5,-1060 # ffffffe00060d040 <buddy>
ffffffe00020046c:	0007b783          	ld	a5,0(a5)
ffffffe000200470:	00479793          	slli	a5,a5,0x4
ffffffe000200474:	00078613          	mv	a2,a5
ffffffe000200478:	00000593          	li	a1,0
ffffffe00020047c:	00070513          	mv	a0,a4
ffffffe000200480:	1fc040ef          	jal	ffffffe00020467c <memset>

    buddy.ref_cnt = free_page_start;
ffffffe000200484:	00009797          	auipc	a5,0x9
ffffffe000200488:	b8478793          	addi	a5,a5,-1148 # ffffffe000209008 <free_page_start>
ffffffe00020048c:	0007b703          	ld	a4,0(a5)
ffffffe000200490:	0040d797          	auipc	a5,0x40d
ffffffe000200494:	bb078793          	addi	a5,a5,-1104 # ffffffe00060d040 <buddy>
ffffffe000200498:	00e7b823          	sd	a4,16(a5)
    free_page_start += buddy.size * sizeof(*buddy.ref_cnt);
ffffffe00020049c:	00009797          	auipc	a5,0x9
ffffffe0002004a0:	b6c78793          	addi	a5,a5,-1172 # ffffffe000209008 <free_page_start>
ffffffe0002004a4:	0007b703          	ld	a4,0(a5)
ffffffe0002004a8:	0040d797          	auipc	a5,0x40d
ffffffe0002004ac:	b9878793          	addi	a5,a5,-1128 # ffffffe00060d040 <buddy>
ffffffe0002004b0:	0007b783          	ld	a5,0(a5)
ffffffe0002004b4:	00379793          	slli	a5,a5,0x3
ffffffe0002004b8:	00f70733          	add	a4,a4,a5
ffffffe0002004bc:	00009797          	auipc	a5,0x9
ffffffe0002004c0:	b4c78793          	addi	a5,a5,-1204 # ffffffe000209008 <free_page_start>
ffffffe0002004c4:	00e7b023          	sd	a4,0(a5)
    memset(buddy.ref_cnt, 0, buddy.size * sizeof(*buddy.ref_cnt));
ffffffe0002004c8:	0040d797          	auipc	a5,0x40d
ffffffe0002004cc:	b7878793          	addi	a5,a5,-1160 # ffffffe00060d040 <buddy>
ffffffe0002004d0:	0107b703          	ld	a4,16(a5)
ffffffe0002004d4:	0040d797          	auipc	a5,0x40d
ffffffe0002004d8:	b6c78793          	addi	a5,a5,-1172 # ffffffe00060d040 <buddy>
ffffffe0002004dc:	0007b783          	ld	a5,0(a5)
ffffffe0002004e0:	00379793          	slli	a5,a5,0x3
ffffffe0002004e4:	00078613          	mv	a2,a5
ffffffe0002004e8:	00000593          	li	a1,0
ffffffe0002004ec:	00070513          	mv	a0,a4
ffffffe0002004f0:	18c040ef          	jal	ffffffe00020467c <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe0002004f4:	0040d797          	auipc	a5,0x40d
ffffffe0002004f8:	b4c78793          	addi	a5,a5,-1204 # ffffffe00060d040 <buddy>
ffffffe0002004fc:	0007b783          	ld	a5,0(a5)
ffffffe000200500:	00179793          	slli	a5,a5,0x1
ffffffe000200504:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200508:	fc043c23          	sd	zero,-40(s0)
ffffffe00020050c:	0500006f          	j	ffffffe00020055c <buddy_init+0x190>
        if (IS_POWER_OF_2(i + 1))
ffffffe000200510:	fd843783          	ld	a5,-40(s0)
ffffffe000200514:	00178713          	addi	a4,a5,1
ffffffe000200518:	fd843783          	ld	a5,-40(s0)
ffffffe00020051c:	00f777b3          	and	a5,a4,a5
ffffffe000200520:	00079863          	bnez	a5,ffffffe000200530 <buddy_init+0x164>
            node_size /= 2;
ffffffe000200524:	fe043783          	ld	a5,-32(s0)
ffffffe000200528:	0017d793          	srli	a5,a5,0x1
ffffffe00020052c:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe000200530:	0040d797          	auipc	a5,0x40d
ffffffe000200534:	b1078793          	addi	a5,a5,-1264 # ffffffe00060d040 <buddy>
ffffffe000200538:	0087b703          	ld	a4,8(a5)
ffffffe00020053c:	fd843783          	ld	a5,-40(s0)
ffffffe000200540:	00379793          	slli	a5,a5,0x3
ffffffe000200544:	00f707b3          	add	a5,a4,a5
ffffffe000200548:	fe043703          	ld	a4,-32(s0)
ffffffe00020054c:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200550:	fd843783          	ld	a5,-40(s0)
ffffffe000200554:	00178793          	addi	a5,a5,1
ffffffe000200558:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020055c:	0040d797          	auipc	a5,0x40d
ffffffe000200560:	ae478793          	addi	a5,a5,-1308 # ffffffe00060d040 <buddy>
ffffffe000200564:	0007b783          	ld	a5,0(a5)
ffffffe000200568:	00179793          	slli	a5,a5,0x1
ffffffe00020056c:	fff78793          	addi	a5,a5,-1
ffffffe000200570:	fd843703          	ld	a4,-40(s0)
ffffffe000200574:	f8f76ee3          	bltu	a4,a5,ffffffe000200510 <buddy_init+0x144>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200578:	fc043823          	sd	zero,-48(s0)
ffffffe00020057c:	0180006f          	j	ffffffe000200594 <buddy_init+0x1c8>
        buddy_alloc(1);
ffffffe000200580:	00100513          	li	a0,1
ffffffe000200584:	2f4000ef          	jal	ffffffe000200878 <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200588:	fd043783          	ld	a5,-48(s0)
ffffffe00020058c:	00178793          	addi	a5,a5,1
ffffffe000200590:	fcf43823          	sd	a5,-48(s0)
ffffffe000200594:	fd043783          	ld	a5,-48(s0)
ffffffe000200598:	00c79713          	slli	a4,a5,0xc
ffffffe00020059c:	00100793          	li	a5,1
ffffffe0002005a0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005a4:	00f70733          	add	a4,a4,a5
ffffffe0002005a8:	00009797          	auipc	a5,0x9
ffffffe0002005ac:	a6078793          	addi	a5,a5,-1440 # ffffffe000209008 <free_page_start>
ffffffe0002005b0:	0007b783          	ld	a5,0(a5)
ffffffe0002005b4:	00078693          	mv	a3,a5
ffffffe0002005b8:	04100793          	li	a5,65
ffffffe0002005bc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005c0:	00f687b3          	add	a5,a3,a5
ffffffe0002005c4:	faf76ee3          	bltu	a4,a5,ffffffe000200580 <buddy_init+0x1b4>
    }

    printk("...buddy_init done!\n");
ffffffe0002005c8:	00007517          	auipc	a0,0x7
ffffffe0002005cc:	a4050513          	addi	a0,a0,-1472 # ffffffe000207008 <__func__.0+0x8>
ffffffe0002005d0:	78d030ef          	jal	ffffffe00020455c <printk>
    return;
ffffffe0002005d4:	00000013          	nop
}
ffffffe0002005d8:	02813083          	ld	ra,40(sp)
ffffffe0002005dc:	02013403          	ld	s0,32(sp)
ffffffe0002005e0:	03010113          	addi	sp,sp,48
ffffffe0002005e4:	00008067          	ret

ffffffe0002005e8 <page_ref_inc>:

void page_ref_inc(uint64_t pfn) {
ffffffe0002005e8:	fe010113          	addi	sp,sp,-32
ffffffe0002005ec:	00813c23          	sd	s0,24(sp)
ffffffe0002005f0:	02010413          	addi	s0,sp,32
ffffffe0002005f4:	fea43423          	sd	a0,-24(s0)
    buddy.ref_cnt[pfn]++;
ffffffe0002005f8:	0040d797          	auipc	a5,0x40d
ffffffe0002005fc:	a4878793          	addi	a5,a5,-1464 # ffffffe00060d040 <buddy>
ffffffe000200600:	0107b703          	ld	a4,16(a5)
ffffffe000200604:	fe843783          	ld	a5,-24(s0)
ffffffe000200608:	00379793          	slli	a5,a5,0x3
ffffffe00020060c:	00f707b3          	add	a5,a4,a5
ffffffe000200610:	0007b703          	ld	a4,0(a5)
ffffffe000200614:	00170713          	addi	a4,a4,1
ffffffe000200618:	00e7b023          	sd	a4,0(a5)
}
ffffffe00020061c:	00000013          	nop
ffffffe000200620:	01813403          	ld	s0,24(sp)
ffffffe000200624:	02010113          	addi	sp,sp,32
ffffffe000200628:	00008067          	ret

ffffffe00020062c <page_ref_dec>:

void page_ref_dec(uint64_t pfn) {
ffffffe00020062c:	fe010113          	addi	sp,sp,-32
ffffffe000200630:	00113c23          	sd	ra,24(sp)
ffffffe000200634:	00813823          	sd	s0,16(sp)
ffffffe000200638:	02010413          	addi	s0,sp,32
ffffffe00020063c:	fea43423          	sd	a0,-24(s0)
    if (buddy.ref_cnt[pfn] > 0) {
ffffffe000200640:	0040d797          	auipc	a5,0x40d
ffffffe000200644:	a0078793          	addi	a5,a5,-1536 # ffffffe00060d040 <buddy>
ffffffe000200648:	0107b703          	ld	a4,16(a5)
ffffffe00020064c:	fe843783          	ld	a5,-24(s0)
ffffffe000200650:	00379793          	slli	a5,a5,0x3
ffffffe000200654:	00f707b3          	add	a5,a4,a5
ffffffe000200658:	0007b783          	ld	a5,0(a5)
ffffffe00020065c:	02078463          	beqz	a5,ffffffe000200684 <page_ref_dec+0x58>
        buddy.ref_cnt[pfn]--;
ffffffe000200660:	0040d797          	auipc	a5,0x40d
ffffffe000200664:	9e078793          	addi	a5,a5,-1568 # ffffffe00060d040 <buddy>
ffffffe000200668:	0107b703          	ld	a4,16(a5)
ffffffe00020066c:	fe843783          	ld	a5,-24(s0)
ffffffe000200670:	00379793          	slli	a5,a5,0x3
ffffffe000200674:	00f707b3          	add	a5,a4,a5
ffffffe000200678:	0007b703          	ld	a4,0(a5)
ffffffe00020067c:	fff70713          	addi	a4,a4,-1
ffffffe000200680:	00e7b023          	sd	a4,0(a5)
    }
    if (buddy.ref_cnt[pfn] == 0) {
ffffffe000200684:	0040d797          	auipc	a5,0x40d
ffffffe000200688:	9bc78793          	addi	a5,a5,-1604 # ffffffe00060d040 <buddy>
ffffffe00020068c:	0107b703          	ld	a4,16(a5)
ffffffe000200690:	fe843783          	ld	a5,-24(s0)
ffffffe000200694:	00379793          	slli	a5,a5,0x3
ffffffe000200698:	00f707b3          	add	a5,a4,a5
ffffffe00020069c:	0007b783          	ld	a5,0(a5)
ffffffe0002006a0:	00079663          	bnez	a5,ffffffe0002006ac <page_ref_dec+0x80>
        Log("free page: %p", PFN2PHYS(pfn));
        buddy_free(pfn);
ffffffe0002006a4:	fe843503          	ld	a0,-24(s0)
ffffffe0002006a8:	018000ef          	jal	ffffffe0002006c0 <buddy_free>
    }
}
ffffffe0002006ac:	00000013          	nop
ffffffe0002006b0:	01813083          	ld	ra,24(sp)
ffffffe0002006b4:	01013403          	ld	s0,16(sp)
ffffffe0002006b8:	02010113          	addi	sp,sp,32
ffffffe0002006bc:	00008067          	ret

ffffffe0002006c0 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe0002006c0:	fc010113          	addi	sp,sp,-64
ffffffe0002006c4:	02813c23          	sd	s0,56(sp)
ffffffe0002006c8:	04010413          	addi	s0,sp,64
ffffffe0002006cc:	fca43423          	sd	a0,-56(s0)
    // if ref_cnt is not zero, do nothing
    if (buddy.ref_cnt[pfn]) {
ffffffe0002006d0:	0040d797          	auipc	a5,0x40d
ffffffe0002006d4:	97078793          	addi	a5,a5,-1680 # ffffffe00060d040 <buddy>
ffffffe0002006d8:	0107b703          	ld	a4,16(a5)
ffffffe0002006dc:	fc843783          	ld	a5,-56(s0)
ffffffe0002006e0:	00379793          	slli	a5,a5,0x3
ffffffe0002006e4:	00f707b3          	add	a5,a4,a5
ffffffe0002006e8:	0007b783          	ld	a5,0(a5)
ffffffe0002006ec:	16079e63          	bnez	a5,ffffffe000200868 <buddy_free+0x1a8>
        return;
    }
    uint64_t node_size, index = 0;
ffffffe0002006f0:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe0002006f4:	00100793          	li	a5,1
ffffffe0002006f8:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe0002006fc:	0040d797          	auipc	a5,0x40d
ffffffe000200700:	94478793          	addi	a5,a5,-1724 # ffffffe00060d040 <buddy>
ffffffe000200704:	0007b703          	ld	a4,0(a5)
ffffffe000200708:	fc843783          	ld	a5,-56(s0)
ffffffe00020070c:	00f707b3          	add	a5,a4,a5
ffffffe000200710:	fff78793          	addi	a5,a5,-1
ffffffe000200714:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200718:	02c0006f          	j	ffffffe000200744 <buddy_free+0x84>
        node_size *= 2;
ffffffe00020071c:	fe843783          	ld	a5,-24(s0)
ffffffe000200720:	00179793          	slli	a5,a5,0x1
ffffffe000200724:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe000200728:	fe043783          	ld	a5,-32(s0)
ffffffe00020072c:	02078e63          	beqz	a5,ffffffe000200768 <buddy_free+0xa8>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200730:	fe043783          	ld	a5,-32(s0)
ffffffe000200734:	00178793          	addi	a5,a5,1
ffffffe000200738:	0017d793          	srli	a5,a5,0x1
ffffffe00020073c:	fff78793          	addi	a5,a5,-1
ffffffe000200740:	fef43023          	sd	a5,-32(s0)
ffffffe000200744:	0040d797          	auipc	a5,0x40d
ffffffe000200748:	8fc78793          	addi	a5,a5,-1796 # ffffffe00060d040 <buddy>
ffffffe00020074c:	0087b703          	ld	a4,8(a5)
ffffffe000200750:	fe043783          	ld	a5,-32(s0)
ffffffe000200754:	00379793          	slli	a5,a5,0x3
ffffffe000200758:	00f707b3          	add	a5,a4,a5
ffffffe00020075c:	0007b783          	ld	a5,0(a5)
ffffffe000200760:	fa079ee3          	bnez	a5,ffffffe00020071c <buddy_free+0x5c>
ffffffe000200764:	0080006f          	j	ffffffe00020076c <buddy_free+0xac>
            break;
ffffffe000200768:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe00020076c:	0040d797          	auipc	a5,0x40d
ffffffe000200770:	8d478793          	addi	a5,a5,-1836 # ffffffe00060d040 <buddy>
ffffffe000200774:	0087b703          	ld	a4,8(a5)
ffffffe000200778:	fe043783          	ld	a5,-32(s0)
ffffffe00020077c:	00379793          	slli	a5,a5,0x3
ffffffe000200780:	00f707b3          	add	a5,a4,a5
ffffffe000200784:	fe843703          	ld	a4,-24(s0)
ffffffe000200788:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe00020078c:	0d00006f          	j	ffffffe00020085c <buddy_free+0x19c>
        index = PARENT(index);
ffffffe000200790:	fe043783          	ld	a5,-32(s0)
ffffffe000200794:	00178793          	addi	a5,a5,1
ffffffe000200798:	0017d793          	srli	a5,a5,0x1
ffffffe00020079c:	fff78793          	addi	a5,a5,-1
ffffffe0002007a0:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe0002007a4:	fe843783          	ld	a5,-24(s0)
ffffffe0002007a8:	00179793          	slli	a5,a5,0x1
ffffffe0002007ac:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe0002007b0:	0040d797          	auipc	a5,0x40d
ffffffe0002007b4:	89078793          	addi	a5,a5,-1904 # ffffffe00060d040 <buddy>
ffffffe0002007b8:	0087b703          	ld	a4,8(a5)
ffffffe0002007bc:	fe043783          	ld	a5,-32(s0)
ffffffe0002007c0:	00479793          	slli	a5,a5,0x4
ffffffe0002007c4:	00878793          	addi	a5,a5,8
ffffffe0002007c8:	00f707b3          	add	a5,a4,a5
ffffffe0002007cc:	0007b783          	ld	a5,0(a5)
ffffffe0002007d0:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe0002007d4:	0040d797          	auipc	a5,0x40d
ffffffe0002007d8:	86c78793          	addi	a5,a5,-1940 # ffffffe00060d040 <buddy>
ffffffe0002007dc:	0087b703          	ld	a4,8(a5)
ffffffe0002007e0:	fe043783          	ld	a5,-32(s0)
ffffffe0002007e4:	00178793          	addi	a5,a5,1
ffffffe0002007e8:	00479793          	slli	a5,a5,0x4
ffffffe0002007ec:	00f707b3          	add	a5,a4,a5
ffffffe0002007f0:	0007b783          	ld	a5,0(a5)
ffffffe0002007f4:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe0002007f8:	fd843703          	ld	a4,-40(s0)
ffffffe0002007fc:	fd043783          	ld	a5,-48(s0)
ffffffe000200800:	00f707b3          	add	a5,a4,a5
ffffffe000200804:	fe843703          	ld	a4,-24(s0)
ffffffe000200808:	02f71463          	bne	a4,a5,ffffffe000200830 <buddy_free+0x170>
            buddy.bitmap[index] = node_size;
ffffffe00020080c:	0040d797          	auipc	a5,0x40d
ffffffe000200810:	83478793          	addi	a5,a5,-1996 # ffffffe00060d040 <buddy>
ffffffe000200814:	0087b703          	ld	a4,8(a5)
ffffffe000200818:	fe043783          	ld	a5,-32(s0)
ffffffe00020081c:	00379793          	slli	a5,a5,0x3
ffffffe000200820:	00f707b3          	add	a5,a4,a5
ffffffe000200824:	fe843703          	ld	a4,-24(s0)
ffffffe000200828:	00e7b023          	sd	a4,0(a5)
ffffffe00020082c:	0300006f          	j	ffffffe00020085c <buddy_free+0x19c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe000200830:	0040d797          	auipc	a5,0x40d
ffffffe000200834:	81078793          	addi	a5,a5,-2032 # ffffffe00060d040 <buddy>
ffffffe000200838:	0087b703          	ld	a4,8(a5)
ffffffe00020083c:	fe043783          	ld	a5,-32(s0)
ffffffe000200840:	00379793          	slli	a5,a5,0x3
ffffffe000200844:	00f706b3          	add	a3,a4,a5
ffffffe000200848:	fd843703          	ld	a4,-40(s0)
ffffffe00020084c:	fd043783          	ld	a5,-48(s0)
ffffffe000200850:	00e7f463          	bgeu	a5,a4,ffffffe000200858 <buddy_free+0x198>
ffffffe000200854:	00070793          	mv	a5,a4
ffffffe000200858:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe00020085c:	fe043783          	ld	a5,-32(s0)
ffffffe000200860:	f20798e3          	bnez	a5,ffffffe000200790 <buddy_free+0xd0>
ffffffe000200864:	0080006f          	j	ffffffe00020086c <buddy_free+0x1ac>
        return;
ffffffe000200868:	00000013          	nop
    }
}
ffffffe00020086c:	03813403          	ld	s0,56(sp)
ffffffe000200870:	04010113          	addi	sp,sp,64
ffffffe000200874:	00008067          	ret

ffffffe000200878 <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe000200878:	fc010113          	addi	sp,sp,-64
ffffffe00020087c:	02113c23          	sd	ra,56(sp)
ffffffe000200880:	02813823          	sd	s0,48(sp)
ffffffe000200884:	04010413          	addi	s0,sp,64
ffffffe000200888:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe00020088c:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe000200890:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe000200894:	fc843783          	ld	a5,-56(s0)
ffffffe000200898:	00079863          	bnez	a5,ffffffe0002008a8 <buddy_alloc+0x30>
        nrpages = 1;
ffffffe00020089c:	00100793          	li	a5,1
ffffffe0002008a0:	fcf43423          	sd	a5,-56(s0)
ffffffe0002008a4:	0240006f          	j	ffffffe0002008c8 <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe0002008a8:	fc843783          	ld	a5,-56(s0)
ffffffe0002008ac:	fff78713          	addi	a4,a5,-1
ffffffe0002008b0:	fc843783          	ld	a5,-56(s0)
ffffffe0002008b4:	00f777b3          	and	a5,a4,a5
ffffffe0002008b8:	00078863          	beqz	a5,ffffffe0002008c8 <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe0002008bc:	fc843503          	ld	a0,-56(s0)
ffffffe0002008c0:	a61ff0ef          	jal	ffffffe000200320 <fixsize>
ffffffe0002008c4:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe0002008c8:	0040c797          	auipc	a5,0x40c
ffffffe0002008cc:	77878793          	addi	a5,a5,1912 # ffffffe00060d040 <buddy>
ffffffe0002008d0:	0087b703          	ld	a4,8(a5)
ffffffe0002008d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002008d8:	00379793          	slli	a5,a5,0x3
ffffffe0002008dc:	00f707b3          	add	a5,a4,a5
ffffffe0002008e0:	0007b783          	ld	a5,0(a5)
ffffffe0002008e4:	fc843703          	ld	a4,-56(s0)
ffffffe0002008e8:	00e7f663          	bgeu	a5,a4,ffffffe0002008f4 <buddy_alloc+0x7c>
        return 0;
ffffffe0002008ec:	00000793          	li	a5,0
ffffffe0002008f0:	1680006f          	j	ffffffe000200a58 <buddy_alloc+0x1e0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002008f4:	0040c797          	auipc	a5,0x40c
ffffffe0002008f8:	74c78793          	addi	a5,a5,1868 # ffffffe00060d040 <buddy>
ffffffe0002008fc:	0007b783          	ld	a5,0(a5)
ffffffe000200900:	fef43023          	sd	a5,-32(s0)
ffffffe000200904:	05c0006f          	j	ffffffe000200960 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe000200908:	0040c797          	auipc	a5,0x40c
ffffffe00020090c:	73878793          	addi	a5,a5,1848 # ffffffe00060d040 <buddy>
ffffffe000200910:	0087b703          	ld	a4,8(a5)
ffffffe000200914:	fe843783          	ld	a5,-24(s0)
ffffffe000200918:	00479793          	slli	a5,a5,0x4
ffffffe00020091c:	00878793          	addi	a5,a5,8
ffffffe000200920:	00f707b3          	add	a5,a4,a5
ffffffe000200924:	0007b783          	ld	a5,0(a5)
ffffffe000200928:	fc843703          	ld	a4,-56(s0)
ffffffe00020092c:	00e7ec63          	bltu	a5,a4,ffffffe000200944 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe000200930:	fe843783          	ld	a5,-24(s0)
ffffffe000200934:	00179793          	slli	a5,a5,0x1
ffffffe000200938:	00178793          	addi	a5,a5,1
ffffffe00020093c:	fef43423          	sd	a5,-24(s0)
ffffffe000200940:	0140006f          	j	ffffffe000200954 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe000200944:	fe843783          	ld	a5,-24(s0)
ffffffe000200948:	00178793          	addi	a5,a5,1
ffffffe00020094c:	00179793          	slli	a5,a5,0x1
ffffffe000200950:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200954:	fe043783          	ld	a5,-32(s0)
ffffffe000200958:	0017d793          	srli	a5,a5,0x1
ffffffe00020095c:	fef43023          	sd	a5,-32(s0)
ffffffe000200960:	fe043703          	ld	a4,-32(s0)
ffffffe000200964:	fc843783          	ld	a5,-56(s0)
ffffffe000200968:	faf710e3          	bne	a4,a5,ffffffe000200908 <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe00020096c:	0040c797          	auipc	a5,0x40c
ffffffe000200970:	6d478793          	addi	a5,a5,1748 # ffffffe00060d040 <buddy>
ffffffe000200974:	0087b703          	ld	a4,8(a5)
ffffffe000200978:	fe843783          	ld	a5,-24(s0)
ffffffe00020097c:	00379793          	slli	a5,a5,0x3
ffffffe000200980:	00f707b3          	add	a5,a4,a5
ffffffe000200984:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe000200988:	fe843783          	ld	a5,-24(s0)
ffffffe00020098c:	00178713          	addi	a4,a5,1
ffffffe000200990:	fe043783          	ld	a5,-32(s0)
ffffffe000200994:	02f70733          	mul	a4,a4,a5
ffffffe000200998:	0040c797          	auipc	a5,0x40c
ffffffe00020099c:	6a878793          	addi	a5,a5,1704 # ffffffe00060d040 <buddy>
ffffffe0002009a0:	0007b783          	ld	a5,0(a5)
ffffffe0002009a4:	40f707b3          	sub	a5,a4,a5
ffffffe0002009a8:	fcf43c23          	sd	a5,-40(s0)
    buddy.ref_cnt[pfn] = 1;
ffffffe0002009ac:	0040c797          	auipc	a5,0x40c
ffffffe0002009b0:	69478793          	addi	a5,a5,1684 # ffffffe00060d040 <buddy>
ffffffe0002009b4:	0107b703          	ld	a4,16(a5)
ffffffe0002009b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002009bc:	00379793          	slli	a5,a5,0x3
ffffffe0002009c0:	00f707b3          	add	a5,a4,a5
ffffffe0002009c4:	00100713          	li	a4,1
ffffffe0002009c8:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe0002009cc:	0800006f          	j	ffffffe000200a4c <buddy_alloc+0x1d4>
        index = PARENT(index);
ffffffe0002009d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002009d4:	00178793          	addi	a5,a5,1
ffffffe0002009d8:	0017d793          	srli	a5,a5,0x1
ffffffe0002009dc:	fff78793          	addi	a5,a5,-1
ffffffe0002009e0:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002009e4:	0040c797          	auipc	a5,0x40c
ffffffe0002009e8:	65c78793          	addi	a5,a5,1628 # ffffffe00060d040 <buddy>
ffffffe0002009ec:	0087b703          	ld	a4,8(a5)
ffffffe0002009f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002009f4:	00178793          	addi	a5,a5,1
ffffffe0002009f8:	00479793          	slli	a5,a5,0x4
ffffffe0002009fc:	00f707b3          	add	a5,a4,a5
ffffffe000200a00:	0007b603          	ld	a2,0(a5)
ffffffe000200a04:	0040c797          	auipc	a5,0x40c
ffffffe000200a08:	63c78793          	addi	a5,a5,1596 # ffffffe00060d040 <buddy>
ffffffe000200a0c:	0087b703          	ld	a4,8(a5)
ffffffe000200a10:	fe843783          	ld	a5,-24(s0)
ffffffe000200a14:	00479793          	slli	a5,a5,0x4
ffffffe000200a18:	00878793          	addi	a5,a5,8
ffffffe000200a1c:	00f707b3          	add	a5,a4,a5
ffffffe000200a20:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe000200a24:	0040c797          	auipc	a5,0x40c
ffffffe000200a28:	61c78793          	addi	a5,a5,1564 # ffffffe00060d040 <buddy>
ffffffe000200a2c:	0087b683          	ld	a3,8(a5)
ffffffe000200a30:	fe843783          	ld	a5,-24(s0)
ffffffe000200a34:	00379793          	slli	a5,a5,0x3
ffffffe000200a38:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200a3c:	00060793          	mv	a5,a2
ffffffe000200a40:	00e7f463          	bgeu	a5,a4,ffffffe000200a48 <buddy_alloc+0x1d0>
ffffffe000200a44:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe000200a48:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200a4c:	fe843783          	ld	a5,-24(s0)
ffffffe000200a50:	f80790e3          	bnez	a5,ffffffe0002009d0 <buddy_alloc+0x158>
    }
    
    return pfn;
ffffffe000200a54:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200a58:	00078513          	mv	a0,a5
ffffffe000200a5c:	03813083          	ld	ra,56(sp)
ffffffe000200a60:	03013403          	ld	s0,48(sp)
ffffffe000200a64:	04010113          	addi	sp,sp,64
ffffffe000200a68:	00008067          	ret

ffffffe000200a6c <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe000200a6c:	fd010113          	addi	sp,sp,-48
ffffffe000200a70:	02113423          	sd	ra,40(sp)
ffffffe000200a74:	02813023          	sd	s0,32(sp)
ffffffe000200a78:	03010413          	addi	s0,sp,48
ffffffe000200a7c:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200a80:	fd843503          	ld	a0,-40(s0)
ffffffe000200a84:	df5ff0ef          	jal	ffffffe000200878 <buddy_alloc>
ffffffe000200a88:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe000200a8c:	fe843783          	ld	a5,-24(s0)
ffffffe000200a90:	00079663          	bnez	a5,ffffffe000200a9c <alloc_pages+0x30>
        return 0;
ffffffe000200a94:	00000793          	li	a5,0
ffffffe000200a98:	0180006f          	j	ffffffe000200ab0 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe000200a9c:	fe843783          	ld	a5,-24(s0)
ffffffe000200aa0:	00c79713          	slli	a4,a5,0xc
ffffffe000200aa4:	fff00793          	li	a5,-1
ffffffe000200aa8:	02579793          	slli	a5,a5,0x25
ffffffe000200aac:	00f707b3          	add	a5,a4,a5
}
ffffffe000200ab0:	00078513          	mv	a0,a5
ffffffe000200ab4:	02813083          	ld	ra,40(sp)
ffffffe000200ab8:	02013403          	ld	s0,32(sp)
ffffffe000200abc:	03010113          	addi	sp,sp,48
ffffffe000200ac0:	00008067          	ret

ffffffe000200ac4 <get_page>:

uint64_t get_page(void *va) {
ffffffe000200ac4:	fd010113          	addi	sp,sp,-48
ffffffe000200ac8:	02113423          	sd	ra,40(sp)
ffffffe000200acc:	02813023          	sd	s0,32(sp)
ffffffe000200ad0:	03010413          	addi	s0,sp,48
ffffffe000200ad4:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = PHYS2PFN(VA2PA((uint64_t)va));
ffffffe000200ad8:	fd843703          	ld	a4,-40(s0)
ffffffe000200adc:	00100793          	li	a5,1
ffffffe000200ae0:	02579793          	slli	a5,a5,0x25
ffffffe000200ae4:	00f707b3          	add	a5,a4,a5
ffffffe000200ae8:	00c7d793          	srli	a5,a5,0xc
ffffffe000200aec:	fef43423          	sd	a5,-24(s0)
    // check if the page is already allocated
    if (buddy.ref_cnt[pfn] == 0) {
ffffffe000200af0:	0040c797          	auipc	a5,0x40c
ffffffe000200af4:	55078793          	addi	a5,a5,1360 # ffffffe00060d040 <buddy>
ffffffe000200af8:	0107b703          	ld	a4,16(a5)
ffffffe000200afc:	fe843783          	ld	a5,-24(s0)
ffffffe000200b00:	00379793          	slli	a5,a5,0x3
ffffffe000200b04:	00f707b3          	add	a5,a4,a5
ffffffe000200b08:	0007b783          	ld	a5,0(a5)
ffffffe000200b0c:	00079663          	bnez	a5,ffffffe000200b18 <get_page+0x54>
        return 1;
ffffffe000200b10:	00100793          	li	a5,1
ffffffe000200b14:	0100006f          	j	ffffffe000200b24 <get_page+0x60>
    }
    page_ref_inc(pfn);
ffffffe000200b18:	fe843503          	ld	a0,-24(s0)
ffffffe000200b1c:	acdff0ef          	jal	ffffffe0002005e8 <page_ref_inc>
    return 0;
ffffffe000200b20:	00000793          	li	a5,0
}
ffffffe000200b24:	00078513          	mv	a0,a5
ffffffe000200b28:	02813083          	ld	ra,40(sp)
ffffffe000200b2c:	02013403          	ld	s0,32(sp)
ffffffe000200b30:	03010113          	addi	sp,sp,48
ffffffe000200b34:	00008067          	ret

ffffffe000200b38 <get_page_refcnt>:

uint64_t get_page_refcnt(void *va) {
ffffffe000200b38:	fd010113          	addi	sp,sp,-48
ffffffe000200b3c:	02813423          	sd	s0,40(sp)
ffffffe000200b40:	03010413          	addi	s0,sp,48
ffffffe000200b44:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = PHYS2PFN(VA2PA((uint64_t)va));
ffffffe000200b48:	fd843703          	ld	a4,-40(s0)
ffffffe000200b4c:	00100793          	li	a5,1
ffffffe000200b50:	02579793          	slli	a5,a5,0x25
ffffffe000200b54:	00f707b3          	add	a5,a4,a5
ffffffe000200b58:	00c7d793          	srli	a5,a5,0xc
ffffffe000200b5c:	fef43423          	sd	a5,-24(s0)
    return buddy.ref_cnt[pfn];
ffffffe000200b60:	0040c797          	auipc	a5,0x40c
ffffffe000200b64:	4e078793          	addi	a5,a5,1248 # ffffffe00060d040 <buddy>
ffffffe000200b68:	0107b703          	ld	a4,16(a5)
ffffffe000200b6c:	fe843783          	ld	a5,-24(s0)
ffffffe000200b70:	00379793          	slli	a5,a5,0x3
ffffffe000200b74:	00f707b3          	add	a5,a4,a5
ffffffe000200b78:	0007b783          	ld	a5,0(a5)
}
ffffffe000200b7c:	00078513          	mv	a0,a5
ffffffe000200b80:	02813403          	ld	s0,40(sp)
ffffffe000200b84:	03010113          	addi	sp,sp,48
ffffffe000200b88:	00008067          	ret

ffffffe000200b8c <put_page>:

void put_page(void *va) {
ffffffe000200b8c:	fd010113          	addi	sp,sp,-48
ffffffe000200b90:	02113423          	sd	ra,40(sp)
ffffffe000200b94:	02813023          	sd	s0,32(sp)
ffffffe000200b98:	03010413          	addi	s0,sp,48
ffffffe000200b9c:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = PHYS2PFN(VA2PA((uint64_t)va));
ffffffe000200ba0:	fd843703          	ld	a4,-40(s0)
ffffffe000200ba4:	00100793          	li	a5,1
ffffffe000200ba8:	02579793          	slli	a5,a5,0x25
ffffffe000200bac:	00f707b3          	add	a5,a4,a5
ffffffe000200bb0:	00c7d793          	srli	a5,a5,0xc
ffffffe000200bb4:	fef43423          	sd	a5,-24(s0)
    page_ref_dec(pfn);
ffffffe000200bb8:	fe843503          	ld	a0,-24(s0)
ffffffe000200bbc:	a71ff0ef          	jal	ffffffe00020062c <page_ref_dec>
}
ffffffe000200bc0:	00000013          	nop
ffffffe000200bc4:	02813083          	ld	ra,40(sp)
ffffffe000200bc8:	02013403          	ld	s0,32(sp)
ffffffe000200bcc:	03010113          	addi	sp,sp,48
ffffffe000200bd0:	00008067          	ret

ffffffe000200bd4 <alloc_page>:

void *alloc_page() {
ffffffe000200bd4:	ff010113          	addi	sp,sp,-16
ffffffe000200bd8:	00113423          	sd	ra,8(sp)
ffffffe000200bdc:	00813023          	sd	s0,0(sp)
ffffffe000200be0:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe000200be4:	00100513          	li	a0,1
ffffffe000200be8:	e85ff0ef          	jal	ffffffe000200a6c <alloc_pages>
ffffffe000200bec:	00050793          	mv	a5,a0
}
ffffffe000200bf0:	00078513          	mv	a0,a5
ffffffe000200bf4:	00813083          	ld	ra,8(sp)
ffffffe000200bf8:	00013403          	ld	s0,0(sp)
ffffffe000200bfc:	01010113          	addi	sp,sp,16
ffffffe000200c00:	00008067          	ret

ffffffe000200c04 <free_pages>:

void free_pages(void *va) {
ffffffe000200c04:	fe010113          	addi	sp,sp,-32
ffffffe000200c08:	00113c23          	sd	ra,24(sp)
ffffffe000200c0c:	00813823          	sd	s0,16(sp)
ffffffe000200c10:	02010413          	addi	s0,sp,32
ffffffe000200c14:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe000200c18:	fe843703          	ld	a4,-24(s0)
ffffffe000200c1c:	00100793          	li	a5,1
ffffffe000200c20:	02579793          	slli	a5,a5,0x25
ffffffe000200c24:	00f707b3          	add	a5,a4,a5
ffffffe000200c28:	00c7d793          	srli	a5,a5,0xc
ffffffe000200c2c:	00078513          	mv	a0,a5
ffffffe000200c30:	a91ff0ef          	jal	ffffffe0002006c0 <buddy_free>
}
ffffffe000200c34:	00000013          	nop
ffffffe000200c38:	01813083          	ld	ra,24(sp)
ffffffe000200c3c:	01013403          	ld	s0,16(sp)
ffffffe000200c40:	02010113          	addi	sp,sp,32
ffffffe000200c44:	00008067          	ret

ffffffe000200c48 <kalloc>:

void *kalloc() {
ffffffe000200c48:	ff010113          	addi	sp,sp,-16
ffffffe000200c4c:	00113423          	sd	ra,8(sp)
ffffffe000200c50:	00813023          	sd	s0,0(sp)
ffffffe000200c54:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe000200c58:	f7dff0ef          	jal	ffffffe000200bd4 <alloc_page>
ffffffe000200c5c:	00050793          	mv	a5,a0
}
ffffffe000200c60:	00078513          	mv	a0,a5
ffffffe000200c64:	00813083          	ld	ra,8(sp)
ffffffe000200c68:	00013403          	ld	s0,0(sp)
ffffffe000200c6c:	01010113          	addi	sp,sp,16
ffffffe000200c70:	00008067          	ret

ffffffe000200c74 <kfree>:

void kfree(void *addr) {
ffffffe000200c74:	fe010113          	addi	sp,sp,-32
ffffffe000200c78:	00113c23          	sd	ra,24(sp)
ffffffe000200c7c:	00813823          	sd	s0,16(sp)
ffffffe000200c80:	02010413          	addi	s0,sp,32
ffffffe000200c84:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200c88:	fe843503          	ld	a0,-24(s0)
ffffffe000200c8c:	f79ff0ef          	jal	ffffffe000200c04 <free_pages>

    return;
ffffffe000200c90:	00000013          	nop
}
ffffffe000200c94:	01813083          	ld	ra,24(sp)
ffffffe000200c98:	01013403          	ld	s0,16(sp)
ffffffe000200c9c:	02010113          	addi	sp,sp,32
ffffffe000200ca0:	00008067          	ret

ffffffe000200ca4 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200ca4:	fd010113          	addi	sp,sp,-48
ffffffe000200ca8:	02113423          	sd	ra,40(sp)
ffffffe000200cac:	02813023          	sd	s0,32(sp)
ffffffe000200cb0:	03010413          	addi	s0,sp,48
ffffffe000200cb4:	fca43c23          	sd	a0,-40(s0)
ffffffe000200cb8:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200cbc:	fd843703          	ld	a4,-40(s0)
ffffffe000200cc0:	000017b7          	lui	a5,0x1
ffffffe000200cc4:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200cc8:	00f70733          	add	a4,a4,a5
ffffffe000200ccc:	fffff7b7          	lui	a5,0xfffff
ffffffe000200cd0:	00f777b3          	and	a5,a4,a5
ffffffe000200cd4:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200cd8:	01c0006f          	j	ffffffe000200cf4 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200cdc:	fe843503          	ld	a0,-24(s0)
ffffffe000200ce0:	f95ff0ef          	jal	ffffffe000200c74 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200ce4:	fe843703          	ld	a4,-24(s0)
ffffffe000200ce8:	000017b7          	lui	a5,0x1
ffffffe000200cec:	00f707b3          	add	a5,a4,a5
ffffffe000200cf0:	fef43423          	sd	a5,-24(s0)
ffffffe000200cf4:	fe843703          	ld	a4,-24(s0)
ffffffe000200cf8:	000017b7          	lui	a5,0x1
ffffffe000200cfc:	00f70733          	add	a4,a4,a5
ffffffe000200d00:	fd043783          	ld	a5,-48(s0)
ffffffe000200d04:	fce7fce3          	bgeu	a5,a4,ffffffe000200cdc <kfreerange+0x38>
    }
}
ffffffe000200d08:	00000013          	nop
ffffffe000200d0c:	00000013          	nop
ffffffe000200d10:	02813083          	ld	ra,40(sp)
ffffffe000200d14:	02013403          	ld	s0,32(sp)
ffffffe000200d18:	03010113          	addi	sp,sp,48
ffffffe000200d1c:	00008067          	ret

ffffffe000200d20 <mm_init>:

void mm_init(void) {
ffffffe000200d20:	ff010113          	addi	sp,sp,-16
ffffffe000200d24:	00113423          	sd	ra,8(sp)
ffffffe000200d28:	00813023          	sd	s0,0(sp)
ffffffe000200d2c:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200d30:	e9cff0ef          	jal	ffffffe0002003cc <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200d34:	00006517          	auipc	a0,0x6
ffffffe000200d38:	2ec50513          	addi	a0,a0,748 # ffffffe000207020 <__func__.0+0x20>
ffffffe000200d3c:	021030ef          	jal	ffffffe00020455c <printk>
}
ffffffe000200d40:	00000013          	nop
ffffffe000200d44:	00813083          	ld	ra,8(sp)
ffffffe000200d48:	00013403          	ld	s0,0(sp)
ffffffe000200d4c:	01010113          	addi	sp,sp,16
ffffffe000200d50:	00008067          	ret

ffffffe000200d54 <load_program>:
struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
int nr_tasks = 0;                   // 当前线程数量

void load_program(struct task_struct *task) {
ffffffe000200d54:	f6010113          	addi	sp,sp,-160
ffffffe000200d58:	08113c23          	sd	ra,152(sp)
ffffffe000200d5c:	08813823          	sd	s0,144(sp)
ffffffe000200d60:	0a010413          	addi	s0,sp,160
ffffffe000200d64:	f6a43423          	sd	a0,-152(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe000200d68:	00009797          	auipc	a5,0x9
ffffffe000200d6c:	29878793          	addi	a5,a5,664 # ffffffe00020a000 <_sramdisk>
ffffffe000200d70:	fcf43c23          	sd	a5,-40(s0)
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe000200d74:	fd843783          	ld	a5,-40(s0)
ffffffe000200d78:	0207b703          	ld	a4,32(a5)
ffffffe000200d7c:	00009797          	auipc	a5,0x9
ffffffe000200d80:	28478793          	addi	a5,a5,644 # ffffffe00020a000 <_sramdisk>
ffffffe000200d84:	00f707b3          	add	a5,a4,a5
ffffffe000200d88:	fcf43823          	sd	a5,-48(s0)
    // uint64_t *pg = task->pgd;
    struct mm_struct *mm = task->mm;
ffffffe000200d8c:	f6843783          	ld	a5,-152(s0)
ffffffe000200d90:	0b07b783          	ld	a5,176(a5)
ffffffe000200d94:	fcf43423          	sd	a5,-56(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000200d98:	fe042623          	sw	zero,-20(s0)
ffffffe000200d9c:	1700006f          	j	ffffffe000200f0c <load_program+0x1b8>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe000200da0:	fec42703          	lw	a4,-20(s0)
ffffffe000200da4:	00070793          	mv	a5,a4
ffffffe000200da8:	00379793          	slli	a5,a5,0x3
ffffffe000200dac:	40e787b3          	sub	a5,a5,a4
ffffffe000200db0:	00379793          	slli	a5,a5,0x3
ffffffe000200db4:	00078713          	mv	a4,a5
ffffffe000200db8:	fd043783          	ld	a5,-48(s0)
ffffffe000200dbc:	00e787b3          	add	a5,a5,a4
ffffffe000200dc0:	fcf43023          	sd	a5,-64(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe000200dc4:	fc043783          	ld	a5,-64(s0)
ffffffe000200dc8:	0007a783          	lw	a5,0(a5)
ffffffe000200dcc:	00078713          	mv	a4,a5
ffffffe000200dd0:	00100793          	li	a5,1
ffffffe000200dd4:	12f71663          	bne	a4,a5,ffffffe000200f00 <load_program+0x1ac>
            // alloc space and copy content
            uint64_t va = phdr->p_vaddr;
ffffffe000200dd8:	fc043783          	ld	a5,-64(s0)
ffffffe000200ddc:	0107b783          	ld	a5,16(a5)
ffffffe000200de0:	faf43c23          	sd	a5,-72(s0)
            uint64_t offset = phdr->p_offset;
ffffffe000200de4:	fc043783          	ld	a5,-64(s0)
ffffffe000200de8:	0087b783          	ld	a5,8(a5)
ffffffe000200dec:	faf43823          	sd	a5,-80(s0)
            uint64_t filesz = phdr->p_filesz;
ffffffe000200df0:	fc043783          	ld	a5,-64(s0)
ffffffe000200df4:	0207b783          	ld	a5,32(a5)
ffffffe000200df8:	faf43423          	sd	a5,-88(s0)
            uint64_t memsz = phdr->p_memsz;
ffffffe000200dfc:	fc043783          	ld	a5,-64(s0)
ffffffe000200e00:	0287b783          	ld	a5,40(a5)
ffffffe000200e04:	faf43023          	sd	a5,-96(s0)

            if (memsz == 0) continue;
ffffffe000200e08:	fa043783          	ld	a5,-96(s0)
ffffffe000200e0c:	0e078863          	beqz	a5,ffffffe000200efc <load_program+0x1a8>

            // // do mapping
            // create_mapping(pg, va, pa, memsz, PTE_V | PTE_U | ((phdr->p_flags & PF_R) ? PTE_R : 0) |
            // ((phdr->p_flags & PF_W) ? PTE_W : 0) |
            // ((phdr->p_flags & PF_X) ? PTE_X : 0));
            uint64_t vm_flags = 0;
ffffffe000200e10:	fe043023          	sd	zero,-32(s0)
            if (phdr->p_flags & PF_R) vm_flags |= VM_READ;
ffffffe000200e14:	fc043783          	ld	a5,-64(s0)
ffffffe000200e18:	0047a783          	lw	a5,4(a5)
ffffffe000200e1c:	0047f793          	andi	a5,a5,4
ffffffe000200e20:	0007879b          	sext.w	a5,a5
ffffffe000200e24:	00078863          	beqz	a5,ffffffe000200e34 <load_program+0xe0>
ffffffe000200e28:	fe043783          	ld	a5,-32(s0)
ffffffe000200e2c:	0027e793          	ori	a5,a5,2
ffffffe000200e30:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_W) vm_flags |= VM_WRITE;
ffffffe000200e34:	fc043783          	ld	a5,-64(s0)
ffffffe000200e38:	0047a783          	lw	a5,4(a5)
ffffffe000200e3c:	0027f793          	andi	a5,a5,2
ffffffe000200e40:	0007879b          	sext.w	a5,a5
ffffffe000200e44:	00078863          	beqz	a5,ffffffe000200e54 <load_program+0x100>
ffffffe000200e48:	fe043783          	ld	a5,-32(s0)
ffffffe000200e4c:	0047e793          	ori	a5,a5,4
ffffffe000200e50:	fef43023          	sd	a5,-32(s0)
            if (phdr->p_flags & PF_X) vm_flags |= VM_EXEC;
ffffffe000200e54:	fc043783          	ld	a5,-64(s0)
ffffffe000200e58:	0047a783          	lw	a5,4(a5)
ffffffe000200e5c:	0017f793          	andi	a5,a5,1
ffffffe000200e60:	0007879b          	sext.w	a5,a5
ffffffe000200e64:	00078863          	beqz	a5,ffffffe000200e74 <load_program+0x120>
ffffffe000200e68:	fe043783          	ld	a5,-32(s0)
ffffffe000200e6c:	0087e793          	ori	a5,a5,8
ffffffe000200e70:	fef43023          	sd	a5,-32(s0)
            
            // 对齐
            uint64_t page_off = va & (PGSIZE - 1);  // 段在第一页的偏移
ffffffe000200e74:	fb843703          	ld	a4,-72(s0)
ffffffe000200e78:	000017b7          	lui	a5,0x1
ffffffe000200e7c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200e80:	00f777b3          	and	a5,a4,a5
ffffffe000200e84:	f8f43c23          	sd	a5,-104(s0)
            uint64_t map_start = PGROUNDDOWN(va);   // VMA起点
ffffffe000200e88:	fb843703          	ld	a4,-72(s0)
ffffffe000200e8c:	fffff7b7          	lui	a5,0xfffff
ffffffe000200e90:	00f777b3          	and	a5,a4,a5
ffffffe000200e94:	f8f43823          	sd	a5,-112(s0)
            uint64_t map_len = PGROUNDUP(page_off + memsz);
ffffffe000200e98:	f9843703          	ld	a4,-104(s0)
ffffffe000200e9c:	fa043783          	ld	a5,-96(s0)
ffffffe000200ea0:	00f70733          	add	a4,a4,a5
ffffffe000200ea4:	000017b7          	lui	a5,0x1
ffffffe000200ea8:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200eac:	00f70733          	add	a4,a4,a5
ffffffe000200eb0:	fffff7b7          	lui	a5,0xfffff
ffffffe000200eb4:	00f777b3          	and	a5,a4,a5
ffffffe000200eb8:	f8f43423          	sd	a5,-120(s0)
            // 文件偏移
            uint64_t map_pgoff = offset - page_off;
ffffffe000200ebc:	fb043703          	ld	a4,-80(s0)
ffffffe000200ec0:	f9843783          	ld	a5,-104(s0)
ffffffe000200ec4:	40f707b3          	sub	a5,a4,a5
ffffffe000200ec8:	f8f43023          	sd	a5,-128(s0)
            uint64_t map_filesz = filesz + map_pgoff;
ffffffe000200ecc:	fa843703          	ld	a4,-88(s0)
ffffffe000200ed0:	f8043783          	ld	a5,-128(s0)
ffffffe000200ed4:	00f707b3          	add	a5,a4,a5
ffffffe000200ed8:	f6f43c23          	sd	a5,-136(s0)
            do_mmap(mm, map_start, map_len, map_pgoff, map_filesz, vm_flags);
ffffffe000200edc:	fe043783          	ld	a5,-32(s0)
ffffffe000200ee0:	f7843703          	ld	a4,-136(s0)
ffffffe000200ee4:	f8043683          	ld	a3,-128(s0)
ffffffe000200ee8:	f8843603          	ld	a2,-120(s0)
ffffffe000200eec:	f9043583          	ld	a1,-112(s0)
ffffffe000200ef0:	fc843503          	ld	a0,-56(s0)
ffffffe000200ef4:	560000ef          	jal	ffffffe000201454 <do_mmap>
ffffffe000200ef8:	0080006f          	j	ffffffe000200f00 <load_program+0x1ac>
            if (memsz == 0) continue;
ffffffe000200efc:	00000013          	nop
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000200f00:	fec42783          	lw	a5,-20(s0)
ffffffe000200f04:	0017879b          	addiw	a5,a5,1 # fffffffffffff001 <VM_END+0xfffff001>
ffffffe000200f08:	fef42623          	sw	a5,-20(s0)
ffffffe000200f0c:	fd843783          	ld	a5,-40(s0)
ffffffe000200f10:	0387d783          	lhu	a5,56(a5)
ffffffe000200f14:	0007871b          	sext.w	a4,a5
ffffffe000200f18:	fec42783          	lw	a5,-20(s0)
ffffffe000200f1c:	0007879b          	sext.w	a5,a5
ffffffe000200f20:	e8e7c0e3          	blt	a5,a4,ffffffe000200da0 <load_program+0x4c>
        }
    }
    task->thread.sepc = ehdr->e_entry;
ffffffe000200f24:	fd843783          	ld	a5,-40(s0)
ffffffe000200f28:	0187b703          	ld	a4,24(a5)
ffffffe000200f2c:	f6843783          	ld	a5,-152(s0)
ffffffe000200f30:	08e7b823          	sd	a4,144(a5)
}
ffffffe000200f34:	00000013          	nop
ffffffe000200f38:	09813083          	ld	ra,152(sp)
ffffffe000200f3c:	09013403          	ld	s0,144(sp)
ffffffe000200f40:	0a010113          	addi	sp,sp,160
ffffffe000200f44:	00008067          	ret

ffffffe000200f48 <task_init>:
void task_init() {
ffffffe000200f48:	fb010113          	addi	sp,sp,-80
ffffffe000200f4c:	04113423          	sd	ra,72(sp)
ffffffe000200f50:	04813023          	sd	s0,64(sp)
ffffffe000200f54:	02913c23          	sd	s1,56(sp)
ffffffe000200f58:	05010413          	addi	s0,sp,80
    srand(2024);
ffffffe000200f5c:	7e800513          	li	a0,2024
ffffffe000200f60:	67c030ef          	jal	ffffffe0002045dc <srand>
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle
    idle = (struct task_struct *)kalloc();
ffffffe000200f64:	ce5ff0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000200f68:	00050713          	mv	a4,a0
ffffffe000200f6c:	0040c797          	auipc	a5,0x40c
ffffffe000200f70:	09c78793          	addi	a5,a5,156 # ffffffe00060d008 <idle>
ffffffe000200f74:	00e7b023          	sd	a4,0(a5)
    memset(idle, 0, PGSIZE);
ffffffe000200f78:	0040c797          	auipc	a5,0x40c
ffffffe000200f7c:	09078793          	addi	a5,a5,144 # ffffffe00060d008 <idle>
ffffffe000200f80:	0007b783          	ld	a5,0(a5)
ffffffe000200f84:	00001637          	lui	a2,0x1
ffffffe000200f88:	00000593          	li	a1,0
ffffffe000200f8c:	00078513          	mv	a0,a5
ffffffe000200f90:	6ec030ef          	jal	ffffffe00020467c <memset>
    idle->state = TASK_RUNNING;
ffffffe000200f94:	0040c797          	auipc	a5,0x40c
ffffffe000200f98:	07478793          	addi	a5,a5,116 # ffffffe00060d008 <idle>
ffffffe000200f9c:	0007b783          	ld	a5,0(a5)
ffffffe000200fa0:	0007b023          	sd	zero,0(a5)
    idle->counter = 0;
ffffffe000200fa4:	0040c797          	auipc	a5,0x40c
ffffffe000200fa8:	06478793          	addi	a5,a5,100 # ffffffe00060d008 <idle>
ffffffe000200fac:	0007b783          	ld	a5,0(a5)
ffffffe000200fb0:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe000200fb4:	0040c797          	auipc	a5,0x40c
ffffffe000200fb8:	05478793          	addi	a5,a5,84 # ffffffe00060d008 <idle>
ffffffe000200fbc:	0007b783          	ld	a5,0(a5)
ffffffe000200fc0:	0007b823          	sd	zero,16(a5)
    idle->pid = 0;
ffffffe000200fc4:	0040c797          	auipc	a5,0x40c
ffffffe000200fc8:	04478793          	addi	a5,a5,68 # ffffffe00060d008 <idle>
ffffffe000200fcc:	0007b783          	ld	a5,0(a5)
ffffffe000200fd0:	0007bc23          	sd	zero,24(a5)
    idle->thread.ra = (uint64_t)__dummy;
ffffffe000200fd4:	0040c797          	auipc	a5,0x40c
ffffffe000200fd8:	03478793          	addi	a5,a5,52 # ffffffe00060d008 <idle>
ffffffe000200fdc:	0007b783          	ld	a5,0(a5)
ffffffe000200fe0:	fffff717          	auipc	a4,0xfffff
ffffffe000200fe4:	0a870713          	addi	a4,a4,168 # ffffffe000200088 <__dummy>
ffffffe000200fe8:	02e7b023          	sd	a4,32(a5)
    idle->thread.sp = (uint64_t)idle + PGSIZE;
ffffffe000200fec:	0040c797          	auipc	a5,0x40c
ffffffe000200ff0:	01c78793          	addi	a5,a5,28 # ffffffe00060d008 <idle>
ffffffe000200ff4:	0007b783          	ld	a5,0(a5)
ffffffe000200ff8:	00078693          	mv	a3,a5
ffffffe000200ffc:	0040c797          	auipc	a5,0x40c
ffffffe000201000:	00c78793          	addi	a5,a5,12 # ffffffe00060d008 <idle>
ffffffe000201004:	0007b783          	ld	a5,0(a5)
ffffffe000201008:	00001737          	lui	a4,0x1
ffffffe00020100c:	00e68733          	add	a4,a3,a4
ffffffe000201010:	02e7b423          	sd	a4,40(a5)
    idle->pgd = swapper_pg_dir;
ffffffe000201014:	0040c797          	auipc	a5,0x40c
ffffffe000201018:	ff478793          	addi	a5,a5,-12 # ffffffe00060d008 <idle>
ffffffe00020101c:	0007b783          	ld	a5,0(a5)
ffffffe000201020:	0040e717          	auipc	a4,0x40e
ffffffe000201024:	fe070713          	addi	a4,a4,-32 # ffffffe00060f000 <swapper_pg_dir>
ffffffe000201028:	0ae7b423          	sd	a4,168(a5)
    current = idle;
ffffffe00020102c:	0040c797          	auipc	a5,0x40c
ffffffe000201030:	fdc78793          	addi	a5,a5,-36 # ffffffe00060d008 <idle>
ffffffe000201034:	0007b703          	ld	a4,0(a5)
ffffffe000201038:	0040c797          	auipc	a5,0x40c
ffffffe00020103c:	fd878793          	addi	a5,a5,-40 # ffffffe00060d010 <current>
ffffffe000201040:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000201044:	0040c797          	auipc	a5,0x40c
ffffffe000201048:	fc478793          	addi	a5,a5,-60 # ffffffe00060d008 <idle>
ffffffe00020104c:	0007b703          	ld	a4,0(a5)
ffffffe000201050:	0040c797          	auipc	a5,0x40c
ffffffe000201054:	00878793          	addi	a5,a5,8 # ffffffe00060d058 <task>
ffffffe000201058:	00e7b023          	sd	a4,0(a5)
    nr_tasks = 1;
ffffffe00020105c:	0040c797          	auipc	a5,0x40c
ffffffe000201060:	fbc78793          	addi	a5,a5,-68 # ffffffe00060d018 <nr_tasks>
ffffffe000201064:	00100713          	li	a4,1
ffffffe000201068:	00e7a023          	sw	a4,0(a5)
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    uint64_t uapp_size = (uint64_t)_eramdisk - (uint64_t)_sramdisk;
ffffffe00020106c:	0000c717          	auipc	a4,0xc
ffffffe000201070:	d3c70713          	addi	a4,a4,-708 # ffffffe00020cda8 <_eramdisk>
ffffffe000201074:	00009797          	auipc	a5,0x9
ffffffe000201078:	f8c78793          	addi	a5,a5,-116 # ffffffe00020a000 <_sramdisk>
ffffffe00020107c:	40f707b3          	sub	a5,a4,a5
ffffffe000201080:	fcf43823          	sd	a5,-48(s0)
    uint64_t uapp_pages = (uapp_size + PGSIZE - 1) / PGSIZE;
ffffffe000201084:	fd043703          	ld	a4,-48(s0)
ffffffe000201088:	000017b7          	lui	a5,0x1
ffffffe00020108c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201090:	00f707b3          	add	a5,a4,a5
ffffffe000201094:	00c7d793          	srli	a5,a5,0xc
ffffffe000201098:	fcf43423          	sd	a5,-56(s0)

    // fork: 只创建一个用户进程，其他的fork
    for (int i = 1; i < 2; ++i) {
ffffffe00020109c:	00100793          	li	a5,1
ffffffe0002010a0:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002010a4:	2f80006f          	j	ffffffe00020139c <task_init+0x454>
        task[i] = (struct task_struct *)kalloc();
ffffffe0002010a8:	ba1ff0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe0002010ac:	00050693          	mv	a3,a0
ffffffe0002010b0:	0040c717          	auipc	a4,0x40c
ffffffe0002010b4:	fa870713          	addi	a4,a4,-88 # ffffffe00060d058 <task>
ffffffe0002010b8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002010bc:	00379793          	slli	a5,a5,0x3
ffffffe0002010c0:	00f707b3          	add	a5,a4,a5
ffffffe0002010c4:	00d7b023          	sd	a3,0(a5)
        task[i]->state = TASK_RUNNING;
ffffffe0002010c8:	0040c717          	auipc	a4,0x40c
ffffffe0002010cc:	f9070713          	addi	a4,a4,-112 # ffffffe00060d058 <task>
ffffffe0002010d0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002010d4:	00379793          	slli	a5,a5,0x3
ffffffe0002010d8:	00f707b3          	add	a5,a4,a5
ffffffe0002010dc:	0007b783          	ld	a5,0(a5)
ffffffe0002010e0:	0007b023          	sd	zero,0(a5)
        task[i]->counter = 0;
ffffffe0002010e4:	0040c717          	auipc	a4,0x40c
ffffffe0002010e8:	f7470713          	addi	a4,a4,-140 # ffffffe00060d058 <task>
ffffffe0002010ec:	fdc42783          	lw	a5,-36(s0)
ffffffe0002010f0:	00379793          	slli	a5,a5,0x3
ffffffe0002010f4:	00f707b3          	add	a5,a4,a5
ffffffe0002010f8:	0007b783          	ld	a5,0(a5)
ffffffe0002010fc:	0007b423          	sd	zero,8(a5)
        task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000201100:	520030ef          	jal	ffffffe000204620 <rand>
ffffffe000201104:	00050793          	mv	a5,a0
ffffffe000201108:	00078713          	mv	a4,a5
ffffffe00020110c:	00a00793          	li	a5,10
ffffffe000201110:	02f767bb          	remw	a5,a4,a5
ffffffe000201114:	0007879b          	sext.w	a5,a5
ffffffe000201118:	0017879b          	addiw	a5,a5,1
ffffffe00020111c:	0007869b          	sext.w	a3,a5
ffffffe000201120:	0040c717          	auipc	a4,0x40c
ffffffe000201124:	f3870713          	addi	a4,a4,-200 # ffffffe00060d058 <task>
ffffffe000201128:	fdc42783          	lw	a5,-36(s0)
ffffffe00020112c:	00379793          	slli	a5,a5,0x3
ffffffe000201130:	00f707b3          	add	a5,a4,a5
ffffffe000201134:	0007b783          	ld	a5,0(a5)
ffffffe000201138:	00068713          	mv	a4,a3
ffffffe00020113c:	00e7b823          	sd	a4,16(a5)
        task[i]->pid = i;
ffffffe000201140:	0040c717          	auipc	a4,0x40c
ffffffe000201144:	f1870713          	addi	a4,a4,-232 # ffffffe00060d058 <task>
ffffffe000201148:	fdc42783          	lw	a5,-36(s0)
ffffffe00020114c:	00379793          	slli	a5,a5,0x3
ffffffe000201150:	00f707b3          	add	a5,a4,a5
ffffffe000201154:	0007b783          	ld	a5,0(a5)
ffffffe000201158:	fdc42703          	lw	a4,-36(s0)
ffffffe00020115c:	00e7bc23          	sd	a4,24(a5)
        // 创建文件表并保存
        task[i]->files = file_init();
ffffffe000201160:	0040c717          	auipc	a4,0x40c
ffffffe000201164:	ef870713          	addi	a4,a4,-264 # ffffffe00060d058 <task>
ffffffe000201168:	fdc42783          	lw	a5,-36(s0)
ffffffe00020116c:	00379793          	slli	a5,a5,0x3
ffffffe000201170:	00f707b3          	add	a5,a4,a5
ffffffe000201174:	0007b483          	ld	s1,0(a5)
ffffffe000201178:	324040ef          	jal	ffffffe00020549c <file_init>
ffffffe00020117c:	00050793          	mv	a5,a0
ffffffe000201180:	0af4bc23          	sd	a5,184(s1)

        // 设置ra和sp
        task[i]->thread.ra = (uint64_t)__dummy;
ffffffe000201184:	0040c717          	auipc	a4,0x40c
ffffffe000201188:	ed470713          	addi	a4,a4,-300 # ffffffe00060d058 <task>
ffffffe00020118c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201190:	00379793          	slli	a5,a5,0x3
ffffffe000201194:	00f707b3          	add	a5,a4,a5
ffffffe000201198:	0007b783          	ld	a5,0(a5)
ffffffe00020119c:	fffff717          	auipc	a4,0xfffff
ffffffe0002011a0:	eec70713          	addi	a4,a4,-276 # ffffffe000200088 <__dummy>
ffffffe0002011a4:	02e7b023          	sd	a4,32(a5)
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;
ffffffe0002011a8:	0040c717          	auipc	a4,0x40c
ffffffe0002011ac:	eb070713          	addi	a4,a4,-336 # ffffffe00060d058 <task>
ffffffe0002011b0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002011b4:	00379793          	slli	a5,a5,0x3
ffffffe0002011b8:	00f707b3          	add	a5,a4,a5
ffffffe0002011bc:	0007b783          	ld	a5,0(a5)
ffffffe0002011c0:	00078693          	mv	a3,a5
ffffffe0002011c4:	0040c717          	auipc	a4,0x40c
ffffffe0002011c8:	e9470713          	addi	a4,a4,-364 # ffffffe00060d058 <task>
ffffffe0002011cc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002011d0:	00379793          	slli	a5,a5,0x3
ffffffe0002011d4:	00f707b3          	add	a5,a4,a5
ffffffe0002011d8:	0007b783          	ld	a5,0(a5)
ffffffe0002011dc:	00001737          	lui	a4,0x1
ffffffe0002011e0:	00e68733          	add	a4,a3,a4
ffffffe0002011e4:	02e7b423          	sd	a4,40(a5)

        // 分配独立页表
        uint64_t *pg = (uint64_t *)kalloc();
ffffffe0002011e8:	a61ff0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe0002011ec:	fca43023          	sd	a0,-64(s0)
        memcpy(pg, swapper_pg_dir, PGSIZE);
ffffffe0002011f0:	00001637          	lui	a2,0x1
ffffffe0002011f4:	0040e597          	auipc	a1,0x40e
ffffffe0002011f8:	e0c58593          	addi	a1,a1,-500 # ffffffe00060f000 <swapper_pg_dir>
ffffffe0002011fc:	fc043503          	ld	a0,-64(s0)
ffffffe000201200:	4ec030ef          	jal	ffffffe0002046ec <memcpy>
        task[i]->pgd = pg;
ffffffe000201204:	0040c717          	auipc	a4,0x40c
ffffffe000201208:	e5470713          	addi	a4,a4,-428 # ffffffe00060d058 <task>
ffffffe00020120c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201210:	00379793          	slli	a5,a5,0x3
ffffffe000201214:	00f707b3          	add	a5,a4,a5
ffffffe000201218:	0007b783          	ld	a5,0(a5)
ffffffe00020121c:	fc043703          	ld	a4,-64(s0)
ffffffe000201220:	0ae7b423          	sd	a4,168(a5)

        // 在虚拟页结尾映射
        // create_mapping(pg, USER_END - PGSIZE, ustack_pa, PGSIZE, PTE_V | PTE_R | PTE_W | PTE_U);

        // demand paging
        task[i]->mm = (struct mm_struct *)kalloc();
ffffffe000201224:	0040c717          	auipc	a4,0x40c
ffffffe000201228:	e3470713          	addi	a4,a4,-460 # ffffffe00060d058 <task>
ffffffe00020122c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201230:	00379793          	slli	a5,a5,0x3
ffffffe000201234:	00f707b3          	add	a5,a4,a5
ffffffe000201238:	0007b483          	ld	s1,0(a5)
ffffffe00020123c:	a0dff0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000201240:	00050793          	mv	a5,a0
ffffffe000201244:	0af4b823          	sd	a5,176(s1)
        task[i]->mm->mmap = NULL;
ffffffe000201248:	0040c717          	auipc	a4,0x40c
ffffffe00020124c:	e1070713          	addi	a4,a4,-496 # ffffffe00060d058 <task>
ffffffe000201250:	fdc42783          	lw	a5,-36(s0)
ffffffe000201254:	00379793          	slli	a5,a5,0x3
ffffffe000201258:	00f707b3          	add	a5,a4,a5
ffffffe00020125c:	0007b783          	ld	a5,0(a5)
ffffffe000201260:	0b07b783          	ld	a5,176(a5)
ffffffe000201264:	0007b023          	sd	zero,0(a5)
        
        // 载入ELF并建立VMA
        load_program(task[i]);
ffffffe000201268:	0040c717          	auipc	a4,0x40c
ffffffe00020126c:	df070713          	addi	a4,a4,-528 # ffffffe00060d058 <task>
ffffffe000201270:	fdc42783          	lw	a5,-36(s0)
ffffffe000201274:	00379793          	slli	a5,a5,0x3
ffffffe000201278:	00f707b3          	add	a5,a4,a5
ffffffe00020127c:	0007b783          	ld	a5,0(a5)
ffffffe000201280:	00078513          	mv	a0,a5
ffffffe000201284:	ad1ff0ef          	jal	ffffffe000200d54 <load_program>
        // 栈
        do_mmap(task[i]->mm, USER_END - PGSIZE, PGSIZE, 0, 0, VM_READ | VM_WRITE | VM_ANON);
ffffffe000201288:	0040c717          	auipc	a4,0x40c
ffffffe00020128c:	dd070713          	addi	a4,a4,-560 # ffffffe00060d058 <task>
ffffffe000201290:	fdc42783          	lw	a5,-36(s0)
ffffffe000201294:	00379793          	slli	a5,a5,0x3
ffffffe000201298:	00f707b3          	add	a5,a4,a5
ffffffe00020129c:	0007b783          	ld	a5,0(a5)
ffffffe0002012a0:	0b07b503          	ld	a0,176(a5)
ffffffe0002012a4:	00700793          	li	a5,7
ffffffe0002012a8:	00000713          	li	a4,0
ffffffe0002012ac:	00000693          	li	a3,0
ffffffe0002012b0:	00001637          	lui	a2,0x1
ffffffe0002012b4:	040005b7          	lui	a1,0x4000
ffffffe0002012b8:	fff58593          	addi	a1,a1,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe0002012bc:	00c59593          	slli	a1,a1,0xc
ffffffe0002012c0:	194000ef          	jal	ffffffe000201454 <do_mmap>

        // 设置用户态有关寄存器
        task[i]->thread.sstatus = csr_read(sstatus);
ffffffe0002012c4:	100027f3          	csrr	a5,sstatus
ffffffe0002012c8:	faf43c23          	sd	a5,-72(s0)
ffffffe0002012cc:	fb843703          	ld	a4,-72(s0)
ffffffe0002012d0:	0040c697          	auipc	a3,0x40c
ffffffe0002012d4:	d8868693          	addi	a3,a3,-632 # ffffffe00060d058 <task>
ffffffe0002012d8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002012dc:	00379793          	slli	a5,a5,0x3
ffffffe0002012e0:	00f687b3          	add	a5,a3,a5
ffffffe0002012e4:	0007b783          	ld	a5,0(a5)
ffffffe0002012e8:	08e7bc23          	sd	a4,152(a5)
        task[i]->thread.sstatus &= ~(1<<8);
ffffffe0002012ec:	0040c717          	auipc	a4,0x40c
ffffffe0002012f0:	d6c70713          	addi	a4,a4,-660 # ffffffe00060d058 <task>
ffffffe0002012f4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002012f8:	00379793          	slli	a5,a5,0x3
ffffffe0002012fc:	00f707b3          	add	a5,a4,a5
ffffffe000201300:	0007b783          	ld	a5,0(a5)
ffffffe000201304:	0987b703          	ld	a4,152(a5)
ffffffe000201308:	0040c697          	auipc	a3,0x40c
ffffffe00020130c:	d5068693          	addi	a3,a3,-688 # ffffffe00060d058 <task>
ffffffe000201310:	fdc42783          	lw	a5,-36(s0)
ffffffe000201314:	00379793          	slli	a5,a5,0x3
ffffffe000201318:	00f687b3          	add	a5,a3,a5
ffffffe00020131c:	0007b783          	ld	a5,0(a5)
ffffffe000201320:	eff77713          	andi	a4,a4,-257
ffffffe000201324:	08e7bc23          	sd	a4,152(a5)
        task[i]->thread.sstatus |=  0x00040020;//(1 << 5) | (1 << 18);
ffffffe000201328:	0040c717          	auipc	a4,0x40c
ffffffe00020132c:	d3070713          	addi	a4,a4,-720 # ffffffe00060d058 <task>
ffffffe000201330:	fdc42783          	lw	a5,-36(s0)
ffffffe000201334:	00379793          	slli	a5,a5,0x3
ffffffe000201338:	00f707b3          	add	a5,a4,a5
ffffffe00020133c:	0007b783          	ld	a5,0(a5)
ffffffe000201340:	0987b683          	ld	a3,152(a5)
ffffffe000201344:	0040c717          	auipc	a4,0x40c
ffffffe000201348:	d1470713          	addi	a4,a4,-748 # ffffffe00060d058 <task>
ffffffe00020134c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201350:	00379793          	slli	a5,a5,0x3
ffffffe000201354:	00f707b3          	add	a5,a4,a5
ffffffe000201358:	0007b783          	ld	a5,0(a5)
ffffffe00020135c:	00040737          	lui	a4,0x40
ffffffe000201360:	02070713          	addi	a4,a4,32 # 40020 <PGSIZE+0x3f020>
ffffffe000201364:	00e6e733          	or	a4,a3,a4
ffffffe000201368:	08e7bc23          	sd	a4,152(a5)
        task[i]->thread.sscratch = USER_END;
ffffffe00020136c:	0040c717          	auipc	a4,0x40c
ffffffe000201370:	cec70713          	addi	a4,a4,-788 # ffffffe00060d058 <task>
ffffffe000201374:	fdc42783          	lw	a5,-36(s0)
ffffffe000201378:	00379793          	slli	a5,a5,0x3
ffffffe00020137c:	00f707b3          	add	a5,a4,a5
ffffffe000201380:	0007b783          	ld	a5,0(a5)
ffffffe000201384:	00100713          	li	a4,1
ffffffe000201388:	02671713          	slli	a4,a4,0x26
ffffffe00020138c:	0ae7b023          	sd	a4,160(a5)
    for (int i = 1; i < 2; ++i) {
ffffffe000201390:	fdc42783          	lw	a5,-36(s0)
ffffffe000201394:	0017879b          	addiw	a5,a5,1
ffffffe000201398:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020139c:	fdc42783          	lw	a5,-36(s0)
ffffffe0002013a0:	0007871b          	sext.w	a4,a5
ffffffe0002013a4:	00100793          	li	a5,1
ffffffe0002013a8:	d0e7d0e3          	bge	a5,a4,ffffffe0002010a8 <task_init+0x160>
        #if TEST_SCHED
            printk("INITIALIZE [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
        #endif    
    }
    nr_tasks = 2;
ffffffe0002013ac:	0040c797          	auipc	a5,0x40c
ffffffe0002013b0:	c6c78793          	addi	a5,a5,-916 # ffffffe00060d018 <nr_tasks>
ffffffe0002013b4:	00200713          	li	a4,2
ffffffe0002013b8:	00e7a023          	sw	a4,0(a5)
    printk("...task_init done!\n");
ffffffe0002013bc:	00006517          	auipc	a0,0x6
ffffffe0002013c0:	c7c50513          	addi	a0,a0,-900 # ffffffe000207038 <__func__.0+0x38>
ffffffe0002013c4:	198030ef          	jal	ffffffe00020455c <printk>
}
ffffffe0002013c8:	00000013          	nop
ffffffe0002013cc:	04813083          	ld	ra,72(sp)
ffffffe0002013d0:	04013403          	ld	s0,64(sp)
ffffffe0002013d4:	03813483          	ld	s1,56(sp)
ffffffe0002013d8:	05010113          	addi	sp,sp,80
ffffffe0002013dc:	00008067          	ret

ffffffe0002013e0 <find_vma>:
* @mm       : current thread's mm_struct
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
ffffffe0002013e0:	fd010113          	addi	sp,sp,-48
ffffffe0002013e4:	02813423          	sd	s0,40(sp)
ffffffe0002013e8:	03010413          	addi	s0,sp,48
ffffffe0002013ec:	fca43c23          	sd	a0,-40(s0)
ffffffe0002013f0:	fcb43823          	sd	a1,-48(s0)
    struct vm_area_struct *vma = mm->mmap;
ffffffe0002013f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002013f8:	0007b783          	ld	a5,0(a5)
ffffffe0002013fc:	fef43423          	sd	a5,-24(s0)
    while (vma != NULL) {
ffffffe000201400:	0380006f          	j	ffffffe000201438 <find_vma+0x58>
        if (addr >= vma->vm_start && addr < vma->vm_end) {
ffffffe000201404:	fe843783          	ld	a5,-24(s0)
ffffffe000201408:	0087b783          	ld	a5,8(a5)
ffffffe00020140c:	fd043703          	ld	a4,-48(s0)
ffffffe000201410:	00f76e63          	bltu	a4,a5,ffffffe00020142c <find_vma+0x4c>
ffffffe000201414:	fe843783          	ld	a5,-24(s0)
ffffffe000201418:	0107b783          	ld	a5,16(a5)
ffffffe00020141c:	fd043703          	ld	a4,-48(s0)
ffffffe000201420:	00f77663          	bgeu	a4,a5,ffffffe00020142c <find_vma+0x4c>
            // 匹配到符合地址的VMA
            return vma;
ffffffe000201424:	fe843783          	ld	a5,-24(s0)
ffffffe000201428:	01c0006f          	j	ffffffe000201444 <find_vma+0x64>
        }
        vma = vma->vm_next;
ffffffe00020142c:	fe843783          	ld	a5,-24(s0)
ffffffe000201430:	0187b783          	ld	a5,24(a5)
ffffffe000201434:	fef43423          	sd	a5,-24(s0)
    while (vma != NULL) {
ffffffe000201438:	fe843783          	ld	a5,-24(s0)
ffffffe00020143c:	fc0794e3          	bnez	a5,ffffffe000201404 <find_vma+0x24>
    }
    return NULL;
ffffffe000201440:	00000793          	li	a5,0
}
ffffffe000201444:	00078513          	mv	a0,a5
ffffffe000201448:	02813403          	ld	s0,40(sp)
ffffffe00020144c:	03010113          	addi	sp,sp,48
ffffffe000201450:	00008067          	ret

ffffffe000201454 <do_mmap>:
* @vm_filesz: phdr->p_filesz  
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
ffffffe000201454:	f9010113          	addi	sp,sp,-112
ffffffe000201458:	06113423          	sd	ra,104(sp)
ffffffe00020145c:	06813023          	sd	s0,96(sp)
ffffffe000201460:	07010413          	addi	s0,sp,112
ffffffe000201464:	faa43c23          	sd	a0,-72(s0)
ffffffe000201468:	fab43823          	sd	a1,-80(s0)
ffffffe00020146c:	fac43423          	sd	a2,-88(s0)
ffffffe000201470:	fad43023          	sd	a3,-96(s0)
ffffffe000201474:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201478:	f8f43823          	sd	a5,-112(s0)
    // 地址对齐
    uint64_t start = PGROUNDDOWN(addr);
ffffffe00020147c:	fb043703          	ld	a4,-80(s0)
ffffffe000201480:	fffff7b7          	lui	a5,0xfffff
ffffffe000201484:	00f777b3          	and	a5,a4,a5
ffffffe000201488:	fef43423          	sd	a5,-24(s0)
    uint64_t end = PGROUNDUP(addr + len);
ffffffe00020148c:	fb043703          	ld	a4,-80(s0)
ffffffe000201490:	fa843783          	ld	a5,-88(s0)
ffffffe000201494:	00f70733          	add	a4,a4,a5
ffffffe000201498:	000017b7          	lui	a5,0x1
ffffffe00020149c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002014a0:	00f70733          	add	a4,a4,a5
ffffffe0002014a4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002014a8:	00f777b3          	and	a5,a4,a5
ffffffe0002014ac:	fef43023          	sd	a5,-32(s0)
    struct vm_area_struct *vma = (struct vm_area_struct *)kalloc();
ffffffe0002014b0:	f98ff0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe0002014b4:	fca43823          	sd	a0,-48(s0)
    vma->vm_mm = mm;
ffffffe0002014b8:	fd043783          	ld	a5,-48(s0)
ffffffe0002014bc:	fb843703          	ld	a4,-72(s0)
ffffffe0002014c0:	00e7b023          	sd	a4,0(a5) # fffffffffffff000 <VM_END+0xfffff000>
    vma->vm_flags = flags;
ffffffe0002014c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002014c8:	f9043703          	ld	a4,-112(s0)
ffffffe0002014cc:	02e7b423          	sd	a4,40(a5)
    vma->vm_filesz = vm_filesz;
ffffffe0002014d0:	fd043783          	ld	a5,-48(s0)
ffffffe0002014d4:	f9843703          	ld	a4,-104(s0)
ffffffe0002014d8:	02e7bc23          	sd	a4,56(a5)
    vma->vm_pgoff = vm_pgoff;
ffffffe0002014dc:	fd043783          	ld	a5,-48(s0)
ffffffe0002014e0:	fa043703          	ld	a4,-96(s0)
ffffffe0002014e4:	02e7b823          	sd	a4,48(a5)
    // 如果VMA链表为空，直接添加
    if (mm->mmap == NULL) {
ffffffe0002014e8:	fb843783          	ld	a5,-72(s0)
ffffffe0002014ec:	0007b783          	ld	a5,0(a5)
ffffffe0002014f0:	04079063          	bnez	a5,ffffffe000201530 <do_mmap+0xdc>
        mm->mmap = vma;
ffffffe0002014f4:	fb843783          	ld	a5,-72(s0)
ffffffe0002014f8:	fd043703          	ld	a4,-48(s0)
ffffffe0002014fc:	00e7b023          	sd	a4,0(a5)
        vma->vm_next = NULL;
ffffffe000201500:	fd043783          	ld	a5,-48(s0)
ffffffe000201504:	0007bc23          	sd	zero,24(a5)
        vma->vm_prev = NULL;
ffffffe000201508:	fd043783          	ld	a5,-48(s0)
ffffffe00020150c:	0207b023          	sd	zero,32(a5)
        vma->vm_start = start;
ffffffe000201510:	fd043783          	ld	a5,-48(s0)
ffffffe000201514:	fe843703          	ld	a4,-24(s0)
ffffffe000201518:	00e7b423          	sd	a4,8(a5)
        vma->vm_end = end;
ffffffe00020151c:	fd043783          	ld	a5,-48(s0)
ffffffe000201520:	fe043703          	ld	a4,-32(s0)
ffffffe000201524:	00e7b823          	sd	a4,16(a5)
        // printk(GREEN"do_mmap:" CLEAR);
        // printk("vma [%lx, %lx)\n", start, end);
        return start;
ffffffe000201528:	fe843783          	ld	a5,-24(s0)
ffffffe00020152c:	0d80006f          	j	ffffffe000201604 <do_mmap+0x1b0>
    }

    // 寻找合适的不重叠地址进行映射
    for (uint64_t addr = start; addr < end; addr += PGSIZE) {
ffffffe000201530:	fe843783          	ld	a5,-24(s0)
ffffffe000201534:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201538:	0640006f          	j	ffffffe00020159c <do_mmap+0x148>
        struct vm_area_struct *tmp = find_vma(mm, addr);
ffffffe00020153c:	fd843583          	ld	a1,-40(s0)
ffffffe000201540:	fb843503          	ld	a0,-72(s0)
ffffffe000201544:	e9dff0ef          	jal	ffffffe0002013e0 <find_vma>
ffffffe000201548:	fca43423          	sd	a0,-56(s0)
        if (tmp != NULL) {
ffffffe00020154c:	fc843783          	ld	a5,-56(s0)
ffffffe000201550:	02078e63          	beqz	a5,ffffffe00020158c <do_mmap+0x138>
            // 出现地址重叠，需要重新分配虚拟地址
            start = get_unmapped_area(mm, len);
ffffffe000201554:	fa843583          	ld	a1,-88(s0)
ffffffe000201558:	fb843503          	ld	a0,-72(s0)
ffffffe00020155c:	0bc000ef          	jal	ffffffe000201618 <get_unmapped_area>
ffffffe000201560:	fea43423          	sd	a0,-24(s0)
            end = PGROUNDUP(start + len);
ffffffe000201564:	fe843703          	ld	a4,-24(s0)
ffffffe000201568:	fa843783          	ld	a5,-88(s0)
ffffffe00020156c:	00f70733          	add	a4,a4,a5
ffffffe000201570:	000017b7          	lui	a5,0x1
ffffffe000201574:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201578:	00f70733          	add	a4,a4,a5
ffffffe00020157c:	fffff7b7          	lui	a5,0xfffff
ffffffe000201580:	00f777b3          	and	a5,a4,a5
ffffffe000201584:	fef43023          	sd	a5,-32(s0)
            break;
ffffffe000201588:	0200006f          	j	ffffffe0002015a8 <do_mmap+0x154>
    for (uint64_t addr = start; addr < end; addr += PGSIZE) {
ffffffe00020158c:	fd843703          	ld	a4,-40(s0)
ffffffe000201590:	000017b7          	lui	a5,0x1
ffffffe000201594:	00f707b3          	add	a5,a4,a5
ffffffe000201598:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020159c:	fd843703          	ld	a4,-40(s0)
ffffffe0002015a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002015a4:	f8f76ce3          	bltu	a4,a5,ffffffe00020153c <do_mmap+0xe8>
        }
    }
    vma->vm_start = start;
ffffffe0002015a8:	fd043783          	ld	a5,-48(s0)
ffffffe0002015ac:	fe843703          	ld	a4,-24(s0)
ffffffe0002015b0:	00e7b423          	sd	a4,8(a5) # 1008 <PGSIZE+0x8>
    vma->vm_end = end;
ffffffe0002015b4:	fd043783          	ld	a5,-48(s0)
ffffffe0002015b8:	fe043703          	ld	a4,-32(s0)
ffffffe0002015bc:	00e7b823          	sd	a4,16(a5)
    // 插入到链表头部
    vma->vm_next = mm->mmap;
ffffffe0002015c0:	fb843783          	ld	a5,-72(s0)
ffffffe0002015c4:	0007b703          	ld	a4,0(a5)
ffffffe0002015c8:	fd043783          	ld	a5,-48(s0)
ffffffe0002015cc:	00e7bc23          	sd	a4,24(a5)
    vma->vm_prev = NULL;
ffffffe0002015d0:	fd043783          	ld	a5,-48(s0)
ffffffe0002015d4:	0207b023          	sd	zero,32(a5)
    if (mm->mmap != NULL) {
ffffffe0002015d8:	fb843783          	ld	a5,-72(s0)
ffffffe0002015dc:	0007b783          	ld	a5,0(a5)
ffffffe0002015e0:	00078a63          	beqz	a5,ffffffe0002015f4 <do_mmap+0x1a0>
        mm->mmap->vm_prev = vma;
ffffffe0002015e4:	fb843783          	ld	a5,-72(s0)
ffffffe0002015e8:	0007b783          	ld	a5,0(a5)
ffffffe0002015ec:	fd043703          	ld	a4,-48(s0)
ffffffe0002015f0:	02e7b023          	sd	a4,32(a5)
    }
    mm->mmap = vma;
ffffffe0002015f4:	fb843783          	ld	a5,-72(s0)
ffffffe0002015f8:	fd043703          	ld	a4,-48(s0)
ffffffe0002015fc:	00e7b023          	sd	a4,0(a5)
    // printk(GREEN"do_mmap:" CLEAR);
    // printk("vma [%lx, %lx)\n", start, end);
    return start;
ffffffe000201600:	fe843783          	ld	a5,-24(s0)
}
ffffffe000201604:	00078513          	mv	a0,a5
ffffffe000201608:	06813083          	ld	ra,104(sp)
ffffffe00020160c:	06013403          	ld	s0,96(sp)
ffffffe000201610:	07010113          	addi	sp,sp,112
ffffffe000201614:	00008067          	ret

ffffffe000201618 <get_unmapped_area>:

uint64_t get_unmapped_area(struct mm_struct *mm, uint64_t len) {
ffffffe000201618:	fb010113          	addi	sp,sp,-80
ffffffe00020161c:	04113423          	sd	ra,72(sp)
ffffffe000201620:	04813023          	sd	s0,64(sp)
ffffffe000201624:	05010413          	addi	s0,sp,80
ffffffe000201628:	faa43c23          	sd	a0,-72(s0)
ffffffe00020162c:	fab43823          	sd	a1,-80(s0)
    // 在用户地址空间内寻找一块不重叠的虚拟地址区域
    uint64_t start = USER_START;
ffffffe000201630:	fe043423          	sd	zero,-24(s0)
    uint64_t end = USER_END;
ffffffe000201634:	00100793          	li	a5,1
ffffffe000201638:	02679793          	slli	a5,a5,0x26
ffffffe00020163c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t aligned_len = PGROUNDUP(len);
ffffffe000201640:	fb043703          	ld	a4,-80(s0)
ffffffe000201644:	000017b7          	lui	a5,0x1
ffffffe000201648:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe00020164c:	00f70733          	add	a4,a4,a5
ffffffe000201650:	fffff7b7          	lui	a5,0xfffff
ffffffe000201654:	00f777b3          	and	a5,a4,a5
ffffffe000201658:	fcf43823          	sd	a5,-48(s0)
    uint64_t page_num = aligned_len / PGSIZE;
ffffffe00020165c:	fd043783          	ld	a5,-48(s0)
ffffffe000201660:	00c7d793          	srli	a5,a5,0xc
ffffffe000201664:	fcf43423          	sd	a5,-56(s0)
    for (; start < end; start += PGSIZE) {
ffffffe000201668:	0840006f          	j	ffffffe0002016ec <get_unmapped_area+0xd4>
        uint64_t i;
        for (i = 0; i < page_num; ++i) {
ffffffe00020166c:	fe043023          	sd	zero,-32(s0)
ffffffe000201670:	04c0006f          	j	ffffffe0002016bc <get_unmapped_area+0xa4>
            if (find_vma(mm, start + i * PGSIZE) != NULL) {
ffffffe000201674:	fe043783          	ld	a5,-32(s0)
ffffffe000201678:	00c79713          	slli	a4,a5,0xc
ffffffe00020167c:	fe843783          	ld	a5,-24(s0)
ffffffe000201680:	00f707b3          	add	a5,a4,a5
ffffffe000201684:	00078593          	mv	a1,a5
ffffffe000201688:	fb843503          	ld	a0,-72(s0)
ffffffe00020168c:	d55ff0ef          	jal	ffffffe0002013e0 <find_vma>
ffffffe000201690:	00050793          	mv	a5,a0
ffffffe000201694:	00078e63          	beqz	a5,ffffffe0002016b0 <get_unmapped_area+0x98>
                // len范围内有重叠
                start = start + i * PGSIZE;
ffffffe000201698:	fe043783          	ld	a5,-32(s0)
ffffffe00020169c:	00c79793          	slli	a5,a5,0xc
ffffffe0002016a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002016a4:	00f707b3          	add	a5,a4,a5
ffffffe0002016a8:	fef43423          	sd	a5,-24(s0)
                break;
ffffffe0002016ac:	01c0006f          	j	ffffffe0002016c8 <get_unmapped_area+0xb0>
        for (i = 0; i < page_num; ++i) {
ffffffe0002016b0:	fe043783          	ld	a5,-32(s0)
ffffffe0002016b4:	00178793          	addi	a5,a5,1 # fffffffffffff001 <VM_END+0xfffff001>
ffffffe0002016b8:	fef43023          	sd	a5,-32(s0)
ffffffe0002016bc:	fe043703          	ld	a4,-32(s0)
ffffffe0002016c0:	fc843783          	ld	a5,-56(s0)
ffffffe0002016c4:	faf768e3          	bltu	a4,a5,ffffffe000201674 <get_unmapped_area+0x5c>
            }
        }
        if (i == page_num) {
ffffffe0002016c8:	fe043703          	ld	a4,-32(s0)
ffffffe0002016cc:	fc843783          	ld	a5,-56(s0)
ffffffe0002016d0:	00f71663          	bne	a4,a5,ffffffe0002016dc <get_unmapped_area+0xc4>
            return start;
ffffffe0002016d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002016d8:	0540006f          	j	ffffffe00020172c <get_unmapped_area+0x114>
    for (; start < end; start += PGSIZE) {
ffffffe0002016dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002016e0:	000017b7          	lui	a5,0x1
ffffffe0002016e4:	00f707b3          	add	a5,a4,a5
ffffffe0002016e8:	fef43423          	sd	a5,-24(s0)
ffffffe0002016ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002016f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002016f4:	f6f76ce3          	bltu	a4,a5,ffffffe00020166c <get_unmapped_area+0x54>
        }
    }
    // 没有找到合适的区域
    if (start >= end) {
ffffffe0002016f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002016fc:	fd843783          	ld	a5,-40(s0)
ffffffe000201700:	02f76663          	bltu	a4,a5,ffffffe00020172c <get_unmapped_area+0x114>
        Err("get_unmapped_area failed!\n");
ffffffe000201704:	00006697          	auipc	a3,0x6
ffffffe000201708:	b3c68693          	addi	a3,a3,-1220 # ffffffe000207240 <__func__.2>
ffffffe00020170c:	10500613          	li	a2,261
ffffffe000201710:	00006597          	auipc	a1,0x6
ffffffe000201714:	94058593          	addi	a1,a1,-1728 # ffffffe000207050 <__func__.0+0x50>
ffffffe000201718:	00006517          	auipc	a0,0x6
ffffffe00020171c:	94050513          	addi	a0,a0,-1728 # ffffffe000207058 <__func__.0+0x58>
ffffffe000201720:	63d020ef          	jal	ffffffe00020455c <printk>
ffffffe000201724:	00000013          	nop
ffffffe000201728:	ffdff06f          	j	ffffffe000201724 <get_unmapped_area+0x10c>
        return 0;
    }
}
ffffffe00020172c:	00078513          	mv	a0,a5
ffffffe000201730:	04813083          	ld	ra,72(sp)
ffffffe000201734:	04013403          	ld	s0,64(sp)
ffffffe000201738:	05010113          	addi	sp,sp,80
ffffffe00020173c:	00008067          	ret

ffffffe000201740 <dummy>:

void dummy() {
ffffffe000201740:	fd010113          	addi	sp,sp,-48
ffffffe000201744:	02113423          	sd	ra,40(sp)
ffffffe000201748:	02813023          	sd	s0,32(sp)
ffffffe00020174c:	03010413          	addi	s0,sp,48
    printk("call dummy for current PID %d\n", current->pid);
ffffffe000201750:	0040c797          	auipc	a5,0x40c
ffffffe000201754:	8c078793          	addi	a5,a5,-1856 # ffffffe00060d010 <current>
ffffffe000201758:	0007b783          	ld	a5,0(a5)
ffffffe00020175c:	0187b783          	ld	a5,24(a5)
ffffffe000201760:	00078593          	mv	a1,a5
ffffffe000201764:	00006517          	auipc	a0,0x6
ffffffe000201768:	92c50513          	addi	a0,a0,-1748 # ffffffe000207090 <__func__.0+0x90>
ffffffe00020176c:	5f1020ef          	jal	ffffffe00020455c <printk>
    uint64_t MOD = 1000000007;
ffffffe000201770:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000201774:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000201778:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe00020177c:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000201780:	fff00793          	li	a5,-1
ffffffe000201784:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000201788:	fe442783          	lw	a5,-28(s0)
ffffffe00020178c:	0007871b          	sext.w	a4,a5
ffffffe000201790:	fff00793          	li	a5,-1
ffffffe000201794:	00f70e63          	beq	a4,a5,ffffffe0002017b0 <dummy+0x70>
ffffffe000201798:	0040c797          	auipc	a5,0x40c
ffffffe00020179c:	87878793          	addi	a5,a5,-1928 # ffffffe00060d010 <current>
ffffffe0002017a0:	0007b783          	ld	a5,0(a5)
ffffffe0002017a4:	0087b703          	ld	a4,8(a5)
ffffffe0002017a8:	fe442783          	lw	a5,-28(s0)
ffffffe0002017ac:	fcf70ee3          	beq	a4,a5,ffffffe000201788 <dummy+0x48>
ffffffe0002017b0:	0040c797          	auipc	a5,0x40c
ffffffe0002017b4:	86078793          	addi	a5,a5,-1952 # ffffffe00060d010 <current>
ffffffe0002017b8:	0007b783          	ld	a5,0(a5)
ffffffe0002017bc:	0087b783          	ld	a5,8(a5)
ffffffe0002017c0:	fc0784e3          	beqz	a5,ffffffe000201788 <dummy+0x48>
            if (current->counter == 1) {
ffffffe0002017c4:	0040c797          	auipc	a5,0x40c
ffffffe0002017c8:	84c78793          	addi	a5,a5,-1972 # ffffffe00060d010 <current>
ffffffe0002017cc:	0007b783          	ld	a5,0(a5)
ffffffe0002017d0:	0087b703          	ld	a4,8(a5)
ffffffe0002017d4:	00100793          	li	a5,1
ffffffe0002017d8:	00f71e63          	bne	a4,a5,ffffffe0002017f4 <dummy+0xb4>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe0002017dc:	0040c797          	auipc	a5,0x40c
ffffffe0002017e0:	83478793          	addi	a5,a5,-1996 # ffffffe00060d010 <current>
ffffffe0002017e4:	0007b783          	ld	a5,0(a5)
ffffffe0002017e8:	0087b703          	ld	a4,8(a5)
ffffffe0002017ec:	fff70713          	addi	a4,a4,-1
ffffffe0002017f0:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe0002017f4:	0040c797          	auipc	a5,0x40c
ffffffe0002017f8:	81c78793          	addi	a5,a5,-2020 # ffffffe00060d010 <current>
ffffffe0002017fc:	0007b783          	ld	a5,0(a5)
ffffffe000201800:	0087b783          	ld	a5,8(a5)
ffffffe000201804:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000201808:	fe843783          	ld	a5,-24(s0)
ffffffe00020180c:	00178713          	addi	a4,a5,1
ffffffe000201810:	fd843783          	ld	a5,-40(s0)
ffffffe000201814:	02f777b3          	remu	a5,a4,a5
ffffffe000201818:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe00020181c:	0040b797          	auipc	a5,0x40b
ffffffe000201820:	7f478793          	addi	a5,a5,2036 # ffffffe00060d010 <current>
ffffffe000201824:	0007b783          	ld	a5,0(a5)
ffffffe000201828:	0187b783          	ld	a5,24(a5)
ffffffe00020182c:	fe843603          	ld	a2,-24(s0)
ffffffe000201830:	00078593          	mv	a1,a5
ffffffe000201834:	00006517          	auipc	a0,0x6
ffffffe000201838:	87c50513          	addi	a0,a0,-1924 # ffffffe0002070b0 <__func__.0+0xb0>
ffffffe00020183c:	521020ef          	jal	ffffffe00020455c <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000201840:	f49ff06f          	j	ffffffe000201788 <dummy+0x48>

ffffffe000201844 <switch_to>:
    }
}

extern void __switch_to(struct task_struct *prev, struct task_struct *next);

void switch_to(struct task_struct *next) {
ffffffe000201844:	fd010113          	addi	sp,sp,-48
ffffffe000201848:	02113423          	sd	ra,40(sp)
ffffffe00020184c:	02813023          	sd	s0,32(sp)
ffffffe000201850:	03010413          	addi	s0,sp,48
ffffffe000201854:	fca43c23          	sd	a0,-40(s0)
    // 如果下一个线程是同一个线程，无需处理
    if (next == current) {
ffffffe000201858:	0040b797          	auipc	a5,0x40b
ffffffe00020185c:	7b878793          	addi	a5,a5,1976 # ffffffe00060d010 <current>
ffffffe000201860:	0007b783          	ld	a5,0(a5)
ffffffe000201864:	fd843703          	ld	a4,-40(s0)
ffffffe000201868:	02f70a63          	beq	a4,a5,ffffffe00020189c <switch_to+0x58>
        return;
    }
    // 线程切换
    struct task_struct *prev = current;
ffffffe00020186c:	0040b797          	auipc	a5,0x40b
ffffffe000201870:	7a478793          	addi	a5,a5,1956 # ffffffe00060d010 <current>
ffffffe000201874:	0007b783          	ld	a5,0(a5)
ffffffe000201878:	fef43423          	sd	a5,-24(s0)
    current = next;
ffffffe00020187c:	0040b797          	auipc	a5,0x40b
ffffffe000201880:	79478793          	addi	a5,a5,1940 # ffffffe00060d010 <current>
ffffffe000201884:	fd843703          	ld	a4,-40(s0)
ffffffe000201888:	00e7b023          	sd	a4,0(a5)
    // printk(GREEN "Switch to [PID = %d PRIORITY = %d COUNTER = %d] from [PID = %d]\n" CLEAR, next->pid, next->priority, next->counter, prev->pid);
    __switch_to(prev, next);
ffffffe00020188c:	fd843583          	ld	a1,-40(s0)
ffffffe000201890:	fe843503          	ld	a0,-24(s0)
ffffffe000201894:	805fe0ef          	jal	ffffffe000200098 <__switch_to>
    return;
ffffffe000201898:	0080006f          	j	ffffffe0002018a0 <switch_to+0x5c>
        return;
ffffffe00020189c:	00000013          	nop
}
ffffffe0002018a0:	02813083          	ld	ra,40(sp)
ffffffe0002018a4:	02013403          	ld	s0,32(sp)
ffffffe0002018a8:	03010113          	addi	sp,sp,48
ffffffe0002018ac:	00008067          	ret

ffffffe0002018b0 <do_timer>:

void do_timer() {
ffffffe0002018b0:	ff010113          	addi	sp,sp,-16
ffffffe0002018b4:	00113423          	sd	ra,8(sp)
ffffffe0002018b8:	00813023          	sd	s0,0(sp)
ffffffe0002018bc:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    if (current == idle || current->counter <= 0) {
ffffffe0002018c0:	0040b797          	auipc	a5,0x40b
ffffffe0002018c4:	75078793          	addi	a5,a5,1872 # ffffffe00060d010 <current>
ffffffe0002018c8:	0007b703          	ld	a4,0(a5)
ffffffe0002018cc:	0040b797          	auipc	a5,0x40b
ffffffe0002018d0:	73c78793          	addi	a5,a5,1852 # ffffffe00060d008 <idle>
ffffffe0002018d4:	0007b783          	ld	a5,0(a5)
ffffffe0002018d8:	00f70c63          	beq	a4,a5,ffffffe0002018f0 <do_timer+0x40>
ffffffe0002018dc:	0040b797          	auipc	a5,0x40b
ffffffe0002018e0:	73478793          	addi	a5,a5,1844 # ffffffe00060d010 <current>
ffffffe0002018e4:	0007b783          	ld	a5,0(a5)
ffffffe0002018e8:	0087b783          	ld	a5,8(a5)
ffffffe0002018ec:	00079663          	bnez	a5,ffffffe0002018f8 <do_timer+0x48>
        schedule();
ffffffe0002018f0:	050000ef          	jal	ffffffe000201940 <schedule>
            return;
        } else {
            schedule();
        }
    }
    return;
ffffffe0002018f4:	03c0006f          	j	ffffffe000201930 <do_timer+0x80>
        --(current->counter);
ffffffe0002018f8:	0040b797          	auipc	a5,0x40b
ffffffe0002018fc:	71878793          	addi	a5,a5,1816 # ffffffe00060d010 <current>
ffffffe000201900:	0007b783          	ld	a5,0(a5)
ffffffe000201904:	0087b703          	ld	a4,8(a5)
ffffffe000201908:	fff70713          	addi	a4,a4,-1
ffffffe00020190c:	00e7b423          	sd	a4,8(a5)
        if (current->counter > 0) {
ffffffe000201910:	0040b797          	auipc	a5,0x40b
ffffffe000201914:	70078793          	addi	a5,a5,1792 # ffffffe00060d010 <current>
ffffffe000201918:	0007b783          	ld	a5,0(a5)
ffffffe00020191c:	0087b783          	ld	a5,8(a5)
ffffffe000201920:	00079663          	bnez	a5,ffffffe00020192c <do_timer+0x7c>
            schedule();
ffffffe000201924:	01c000ef          	jal	ffffffe000201940 <schedule>
    return;
ffffffe000201928:	0080006f          	j	ffffffe000201930 <do_timer+0x80>
            return;
ffffffe00020192c:	00000013          	nop
}
ffffffe000201930:	00813083          	ld	ra,8(sp)
ffffffe000201934:	00013403          	ld	s0,0(sp)
ffffffe000201938:	01010113          	addi	sp,sp,16
ffffffe00020193c:	00008067          	ret

ffffffe000201940 <schedule>:

void schedule() {
ffffffe000201940:	fd010113          	addi	sp,sp,-48
ffffffe000201944:	02113423          	sd	ra,40(sp)
ffffffe000201948:	02813023          	sd	s0,32(sp)
ffffffe00020194c:	03010413          	addi	s0,sp,48
    int max_counter;
    int next_id;
    int i;
    struct task_struct **p;
	while (1) {
		max_counter = -1;
ffffffe000201950:	fff00793          	li	a5,-1
ffffffe000201954:	fef42623          	sw	a5,-20(s0)
		next_id = 0;
ffffffe000201958:	fe042423          	sw	zero,-24(s0)
		i = 0;
ffffffe00020195c:	fe042223          	sw	zero,-28(s0)
		p = &task[0];
ffffffe000201960:	0040b797          	auipc	a5,0x40b
ffffffe000201964:	6f878793          	addi	a5,a5,1784 # ffffffe00060d058 <task>
ffffffe000201968:	fcf43c23          	sd	a5,-40(s0)
        // 找到最大剩余时间的线程运行
		while (++i < nr_tasks) {
ffffffe00020196c:	0680006f          	j	ffffffe0002019d4 <schedule+0x94>
			if (!*++p)
ffffffe000201970:	fd843783          	ld	a5,-40(s0)
ffffffe000201974:	00878793          	addi	a5,a5,8
ffffffe000201978:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020197c:	fd843783          	ld	a5,-40(s0)
ffffffe000201980:	0007b783          	ld	a5,0(a5)
ffffffe000201984:	04078663          	beqz	a5,ffffffe0002019d0 <schedule+0x90>
				continue;
			if ((*p)->state == TASK_RUNNING && (int)(*p)->counter > max_counter) {
ffffffe000201988:	fd843783          	ld	a5,-40(s0)
ffffffe00020198c:	0007b783          	ld	a5,0(a5)
ffffffe000201990:	0007b783          	ld	a5,0(a5)
ffffffe000201994:	04079063          	bnez	a5,ffffffe0002019d4 <schedule+0x94>
ffffffe000201998:	fd843783          	ld	a5,-40(s0)
ffffffe00020199c:	0007b783          	ld	a5,0(a5)
ffffffe0002019a0:	0087b783          	ld	a5,8(a5)
ffffffe0002019a4:	0007871b          	sext.w	a4,a5
ffffffe0002019a8:	fec42783          	lw	a5,-20(s0)
ffffffe0002019ac:	0007879b          	sext.w	a5,a5
ffffffe0002019b0:	02e7d263          	bge	a5,a4,ffffffe0002019d4 <schedule+0x94>
                max_counter = (int)(*p)->counter;
ffffffe0002019b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002019b8:	0007b783          	ld	a5,0(a5)
ffffffe0002019bc:	0087b783          	ld	a5,8(a5)
ffffffe0002019c0:	fef42623          	sw	a5,-20(s0)
                next_id = i;
ffffffe0002019c4:	fe442783          	lw	a5,-28(s0)
ffffffe0002019c8:	fef42423          	sw	a5,-24(s0)
ffffffe0002019cc:	0080006f          	j	ffffffe0002019d4 <schedule+0x94>
				continue;
ffffffe0002019d0:	00000013          	nop
		while (++i < nr_tasks) {
ffffffe0002019d4:	fe442783          	lw	a5,-28(s0)
ffffffe0002019d8:	0017879b          	addiw	a5,a5,1
ffffffe0002019dc:	fef42223          	sw	a5,-28(s0)
ffffffe0002019e0:	0040b797          	auipc	a5,0x40b
ffffffe0002019e4:	63878793          	addi	a5,a5,1592 # ffffffe00060d018 <nr_tasks>
ffffffe0002019e8:	0007a703          	lw	a4,0(a5)
ffffffe0002019ec:	fe442783          	lw	a5,-28(s0)
ffffffe0002019f0:	0007879b          	sext.w	a5,a5
ffffffe0002019f4:	f6e7cee3          	blt	a5,a4,ffffffe000201970 <schedule+0x30>
            }
		}
		if (max_counter) break;
ffffffe0002019f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002019fc:	0007879b          	sext.w	a5,a5
ffffffe000201a00:	08079063          	bnez	a5,ffffffe000201a80 <schedule+0x140>
        // 所有线程counter都为0，令counter = priority
		for(p = &task[1] ; p < &task[nr_tasks] ; ++p) {
ffffffe000201a04:	0040b797          	auipc	a5,0x40b
ffffffe000201a08:	65c78793          	addi	a5,a5,1628 # ffffffe00060d060 <task+0x8>
ffffffe000201a0c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201a10:	0480006f          	j	ffffffe000201a58 <schedule+0x118>
            if (*p) {
ffffffe000201a14:	fd843783          	ld	a5,-40(s0)
ffffffe000201a18:	0007b783          	ld	a5,0(a5)
ffffffe000201a1c:	02078863          	beqz	a5,ffffffe000201a4c <schedule+0x10c>
                (*p)->counter = ((*p)->counter >> 1) + (*p)->priority;
ffffffe000201a20:	fd843783          	ld	a5,-40(s0)
ffffffe000201a24:	0007b783          	ld	a5,0(a5)
ffffffe000201a28:	0087b783          	ld	a5,8(a5)
ffffffe000201a2c:	0017d693          	srli	a3,a5,0x1
ffffffe000201a30:	fd843783          	ld	a5,-40(s0)
ffffffe000201a34:	0007b783          	ld	a5,0(a5)
ffffffe000201a38:	0107b703          	ld	a4,16(a5)
ffffffe000201a3c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a40:	0007b783          	ld	a5,0(a5)
ffffffe000201a44:	00e68733          	add	a4,a3,a4
ffffffe000201a48:	00e7b423          	sd	a4,8(a5)
		for(p = &task[1] ; p < &task[nr_tasks] ; ++p) {
ffffffe000201a4c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a50:	00878793          	addi	a5,a5,8
ffffffe000201a54:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201a58:	0040b797          	auipc	a5,0x40b
ffffffe000201a5c:	5c078793          	addi	a5,a5,1472 # ffffffe00060d018 <nr_tasks>
ffffffe000201a60:	0007a783          	lw	a5,0(a5)
ffffffe000201a64:	00379713          	slli	a4,a5,0x3
ffffffe000201a68:	0040b797          	auipc	a5,0x40b
ffffffe000201a6c:	5f078793          	addi	a5,a5,1520 # ffffffe00060d058 <task>
ffffffe000201a70:	00f707b3          	add	a5,a4,a5
ffffffe000201a74:	fd843703          	ld	a4,-40(s0)
ffffffe000201a78:	f8f76ee3          	bltu	a4,a5,ffffffe000201a14 <schedule+0xd4>
		max_counter = -1;
ffffffe000201a7c:	ed5ff06f          	j	ffffffe000201950 <schedule+0x10>
		if (max_counter) break;
ffffffe000201a80:	00000013          	nop
                // printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", (*p)->pid, (*p)->priority, (*p)->counter);
            }
        }
    }	
	switch_to(task[next_id]);
ffffffe000201a84:	0040b717          	auipc	a4,0x40b
ffffffe000201a88:	5d470713          	addi	a4,a4,1492 # ffffffe00060d058 <task>
ffffffe000201a8c:	fe842783          	lw	a5,-24(s0)
ffffffe000201a90:	00379793          	slli	a5,a5,0x3
ffffffe000201a94:	00f707b3          	add	a5,a4,a5
ffffffe000201a98:	0007b783          	ld	a5,0(a5)
ffffffe000201a9c:	00078513          	mv	a0,a5
ffffffe000201aa0:	da5ff0ef          	jal	ffffffe000201844 <switch_to>
}
ffffffe000201aa4:	00000013          	nop
ffffffe000201aa8:	02813083          	ld	ra,40(sp)
ffffffe000201aac:	02013403          	ld	s0,32(sp)
ffffffe000201ab0:	03010113          	addi	sp,sp,48
ffffffe000201ab4:	00008067          	ret

ffffffe000201ab8 <do_page_fault>:

// 缺页异常处理函数
void do_page_fault(struct pt_regs *regs) {
ffffffe000201ab8:	f4010113          	addi	sp,sp,-192
ffffffe000201abc:	0a113c23          	sd	ra,184(sp)
ffffffe000201ac0:	0a813823          	sd	s0,176(sp)
ffffffe000201ac4:	0c010413          	addi	s0,sp,192
ffffffe000201ac8:	f4a43423          	sd	a0,-184(s0)
    // 获得 bad addr
    uint64_t stval = csr_read(stval);
ffffffe000201acc:	143027f3          	csrr	a5,stval
ffffffe000201ad0:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201ad4:	fd843783          	ld	a5,-40(s0)
ffffffe000201ad8:	fcf43823          	sd	a5,-48(s0)
    // 获得scause
    uint64_t scause = csr_read(scause);
ffffffe000201adc:	142027f3          	csrr	a5,scause
ffffffe000201ae0:	fcf43423          	sd	a5,-56(s0)
ffffffe000201ae4:	fc843783          	ld	a5,-56(s0)
ffffffe000201ae8:	fcf43023          	sd	a5,-64(s0)
    // 检查是否在vma中
    struct vm_area_struct *vma = find_vma(current->mm, stval);
ffffffe000201aec:	0040b797          	auipc	a5,0x40b
ffffffe000201af0:	52478793          	addi	a5,a5,1316 # ffffffe00060d010 <current>
ffffffe000201af4:	0007b783          	ld	a5,0(a5)
ffffffe000201af8:	0b07b783          	ld	a5,176(a5)
ffffffe000201afc:	fd043583          	ld	a1,-48(s0)
ffffffe000201b00:	00078513          	mv	a0,a5
ffffffe000201b04:	8ddff0ef          	jal	ffffffe0002013e0 <find_vma>
ffffffe000201b08:	faa43c23          	sd	a0,-72(s0)
    if (vma == NULL) {
ffffffe000201b0c:	fb843783          	ld	a5,-72(s0)
ffffffe000201b10:	02079863          	bnez	a5,ffffffe000201b40 <do_page_fault+0x88>
        // 非预期错误
        Err("Unexpected page fault at 0x%lx : not in vma", stval);
ffffffe000201b14:	fd043703          	ld	a4,-48(s0)
ffffffe000201b18:	00005697          	auipc	a3,0x5
ffffffe000201b1c:	74068693          	addi	a3,a3,1856 # ffffffe000207258 <__func__.1>
ffffffe000201b20:	17400613          	li	a2,372
ffffffe000201b24:	00005597          	auipc	a1,0x5
ffffffe000201b28:	52c58593          	addi	a1,a1,1324 # ffffffe000207050 <__func__.0+0x50>
ffffffe000201b2c:	00005517          	auipc	a0,0x5
ffffffe000201b30:	5b450513          	addi	a0,a0,1460 # ffffffe0002070e0 <__func__.0+0xe0>
ffffffe000201b34:	229020ef          	jal	ffffffe00020455c <printk>
ffffffe000201b38:	00000013          	nop
ffffffe000201b3c:	ffdff06f          	j	ffffffe000201b38 <do_page_fault+0x80>
    else {
        // 判断page fault是否合法
        // 12: instruction page fault, EXEC
        // 13: load page fault, READ
        // 15: store/AMO page fault, WRITE
        if ((scause == 12 && !(vma->vm_flags & VM_EXEC))
ffffffe000201b40:	fc043703          	ld	a4,-64(s0)
ffffffe000201b44:	00c00793          	li	a5,12
ffffffe000201b48:	00f71a63          	bne	a4,a5,ffffffe000201b5c <do_page_fault+0xa4>
ffffffe000201b4c:	fb843783          	ld	a5,-72(s0)
ffffffe000201b50:	0287b783          	ld	a5,40(a5)
ffffffe000201b54:	0087f793          	andi	a5,a5,8
ffffffe000201b58:	02078e63          	beqz	a5,ffffffe000201b94 <do_page_fault+0xdc>
         || (scause == 13 && !(vma->vm_flags & VM_READ))
ffffffe000201b5c:	fc043703          	ld	a4,-64(s0)
ffffffe000201b60:	00d00793          	li	a5,13
ffffffe000201b64:	00f71a63          	bne	a4,a5,ffffffe000201b78 <do_page_fault+0xc0>
ffffffe000201b68:	fb843783          	ld	a5,-72(s0)
ffffffe000201b6c:	0287b783          	ld	a5,40(a5)
ffffffe000201b70:	0027f793          	andi	a5,a5,2
ffffffe000201b74:	02078063          	beqz	a5,ffffffe000201b94 <do_page_fault+0xdc>
         || (scause == 15 && !(vma->vm_flags & VM_WRITE))) {
ffffffe000201b78:	fc043703          	ld	a4,-64(s0)
ffffffe000201b7c:	00f00793          	li	a5,15
ffffffe000201b80:	04f71a63          	bne	a4,a5,ffffffe000201bd4 <do_page_fault+0x11c>
ffffffe000201b84:	fb843783          	ld	a5,-72(s0)
ffffffe000201b88:	0287b783          	ld	a5,40(a5)
ffffffe000201b8c:	0047f793          	andi	a5,a5,4
ffffffe000201b90:	04079263          	bnez	a5,ffffffe000201bd4 <do_page_fault+0x11c>
            Err("[PID = %d], Page fault at 0x%lx : illegal access for scause = %d\n", current->pid, stval, scause);
ffffffe000201b94:	0040b797          	auipc	a5,0x40b
ffffffe000201b98:	47c78793          	addi	a5,a5,1148 # ffffffe00060d010 <current>
ffffffe000201b9c:	0007b783          	ld	a5,0(a5)
ffffffe000201ba0:	0187b703          	ld	a4,24(a5)
ffffffe000201ba4:	fc043803          	ld	a6,-64(s0)
ffffffe000201ba8:	fd043783          	ld	a5,-48(s0)
ffffffe000201bac:	00005697          	auipc	a3,0x5
ffffffe000201bb0:	6ac68693          	addi	a3,a3,1708 # ffffffe000207258 <__func__.1>
ffffffe000201bb4:	17e00613          	li	a2,382
ffffffe000201bb8:	00005597          	auipc	a1,0x5
ffffffe000201bbc:	49858593          	addi	a1,a1,1176 # ffffffe000207050 <__func__.0+0x50>
ffffffe000201bc0:	00005517          	auipc	a0,0x5
ffffffe000201bc4:	56850513          	addi	a0,a0,1384 # ffffffe000207128 <__func__.0+0x128>
ffffffe000201bc8:	195020ef          	jal	ffffffe00020455c <printk>
ffffffe000201bcc:	00000013          	nop
ffffffe000201bd0:	ffdff06f          	j	ffffffe000201bcc <do_page_fault+0x114>
            return;
        }

        // 合法缺页，创建映射
        uint64_t va = PGROUNDDOWN(stval);
ffffffe000201bd4:	fd043703          	ld	a4,-48(s0)
ffffffe000201bd8:	fffff7b7          	lui	a5,0xfffff
ffffffe000201bdc:	00f777b3          	and	a5,a4,a5
ffffffe000201be0:	faf43823          	sd	a5,-80(s0)

        // COW
        if (scause == 15 && (vma->vm_flags & VM_WRITE)) {
ffffffe000201be4:	fc043703          	ld	a4,-64(s0)
ffffffe000201be8:	00f00793          	li	a5,15
ffffffe000201bec:	18f71463          	bne	a4,a5,ffffffe000201d74 <do_page_fault+0x2bc>
ffffffe000201bf0:	fb843783          	ld	a5,-72(s0)
ffffffe000201bf4:	0287b783          	ld	a5,40(a5) # fffffffffffff028 <VM_END+0xfffff028>
ffffffe000201bf8:	0047f793          	andi	a5,a5,4
ffffffe000201bfc:	16078c63          	beqz	a5,ffffffe000201d74 <do_page_fault+0x2bc>
            uint64_t *pte_ptr = walk_page_table(current->pgd, va, 0);
ffffffe000201c00:	0040b797          	auipc	a5,0x40b
ffffffe000201c04:	41078793          	addi	a5,a5,1040 # ffffffe00060d010 <current>
ffffffe000201c08:	0007b783          	ld	a5,0(a5)
ffffffe000201c0c:	0a87b783          	ld	a5,168(a5)
ffffffe000201c10:	00000613          	li	a2,0
ffffffe000201c14:	fb043583          	ld	a1,-80(s0)
ffffffe000201c18:	00078513          	mv	a0,a5
ffffffe000201c1c:	728000ef          	jal	ffffffe000202344 <walk_page_table>
ffffffe000201c20:	faa43423          	sd	a0,-88(s0)
            if (pte_ptr && (*pte_ptr & PTE_V) && !(*pte_ptr & PTE_W)) {
ffffffe000201c24:	fa843783          	ld	a5,-88(s0)
ffffffe000201c28:	14078663          	beqz	a5,ffffffe000201d74 <do_page_fault+0x2bc>
ffffffe000201c2c:	fa843783          	ld	a5,-88(s0)
ffffffe000201c30:	0007b783          	ld	a5,0(a5)
ffffffe000201c34:	0017f793          	andi	a5,a5,1
ffffffe000201c38:	12078e63          	beqz	a5,ffffffe000201d74 <do_page_fault+0x2bc>
ffffffe000201c3c:	fa843783          	ld	a5,-88(s0)
ffffffe000201c40:	0007b783          	ld	a5,0(a5)
ffffffe000201c44:	0047f793          	andi	a5,a5,4
ffffffe000201c48:	12079663          	bnez	a5,ffffffe000201d74 <do_page_fault+0x2bc>
                uint64_t pa = PTE2PA(*pte_ptr);
ffffffe000201c4c:	fa843783          	ld	a5,-88(s0)
ffffffe000201c50:	0007b783          	ld	a5,0(a5)
ffffffe000201c54:	00a7d793          	srli	a5,a5,0xa
ffffffe000201c58:	00c79713          	slli	a4,a5,0xc
ffffffe000201c5c:	fff007b7          	lui	a5,0xfff00
ffffffe000201c60:	0087d793          	srli	a5,a5,0x8
ffffffe000201c64:	00f777b3          	and	a5,a4,a5
ffffffe000201c68:	faf43023          	sd	a5,-96(s0)
                void *old_kva = (void *)PA2VA(pa);
ffffffe000201c6c:	fa043703          	ld	a4,-96(s0)
ffffffe000201c70:	fbf00793          	li	a5,-65
ffffffe000201c74:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c78:	00f707b3          	add	a5,a4,a5
ffffffe000201c7c:	f8f43c23          	sd	a5,-104(s0)
                if (get_page_refcnt(old_kva) > 1) {
ffffffe000201c80:	f9843503          	ld	a0,-104(s0)
ffffffe000201c84:	eb5fe0ef          	jal	ffffffe000200b38 <get_page_refcnt>
ffffffe000201c88:	00050713          	mv	a4,a0
ffffffe000201c8c:	00100793          	li	a5,1
ffffffe000201c90:	0ce7f263          	bgeu	a5,a4,ffffffe000201d54 <do_page_fault+0x29c>
                    // 多引用，分配新页，拷贝内容
                    uint64_t new_kva = (uint64_t)alloc_page();
ffffffe000201c94:	f41fe0ef          	jal	ffffffe000200bd4 <alloc_page>
ffffffe000201c98:	00050793          	mv	a5,a0
ffffffe000201c9c:	f8f43823          	sd	a5,-112(s0)
                    uint64_t new_pa = new_kva - PA2VA_OFFSET;
ffffffe000201ca0:	f9043703          	ld	a4,-112(s0)
ffffffe000201ca4:	04100793          	li	a5,65
ffffffe000201ca8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201cac:	00f707b3          	add	a5,a4,a5
ffffffe000201cb0:	f8f43423          	sd	a5,-120(s0)
                    memcpy((void *)new_kva, old_kva, PGSIZE);
ffffffe000201cb4:	f9043783          	ld	a5,-112(s0)
ffffffe000201cb8:	00001637          	lui	a2,0x1
ffffffe000201cbc:	f9843583          	ld	a1,-104(s0)
ffffffe000201cc0:	00078513          	mv	a0,a5
ffffffe000201cc4:	229020ef          	jal	ffffffe0002046ec <memcpy>
                    // 创建页表项
                    uint64_t perm = PTE_V | PTE_U;
ffffffe000201cc8:	01100793          	li	a5,17
ffffffe000201ccc:	fef43423          	sd	a5,-24(s0)
                    if (vma->vm_flags & VM_READ)  perm |= PTE_R;
ffffffe000201cd0:	fb843783          	ld	a5,-72(s0)
ffffffe000201cd4:	0287b783          	ld	a5,40(a5) # fffffffffff00028 <VM_END+0xfff00028>
ffffffe000201cd8:	0027f793          	andi	a5,a5,2
ffffffe000201cdc:	00078863          	beqz	a5,ffffffe000201cec <do_page_fault+0x234>
ffffffe000201ce0:	fe843783          	ld	a5,-24(s0)
ffffffe000201ce4:	0027e793          	ori	a5,a5,2
ffffffe000201ce8:	fef43423          	sd	a5,-24(s0)
                    if (vma->vm_flags & VM_WRITE) perm |= PTE_W;
ffffffe000201cec:	fb843783          	ld	a5,-72(s0)
ffffffe000201cf0:	0287b783          	ld	a5,40(a5)
ffffffe000201cf4:	0047f793          	andi	a5,a5,4
ffffffe000201cf8:	00078863          	beqz	a5,ffffffe000201d08 <do_page_fault+0x250>
ffffffe000201cfc:	fe843783          	ld	a5,-24(s0)
ffffffe000201d00:	0047e793          	ori	a5,a5,4
ffffffe000201d04:	fef43423          	sd	a5,-24(s0)
                    if (vma->vm_flags & VM_EXEC)  perm |= PTE_X;
ffffffe000201d08:	fb843783          	ld	a5,-72(s0)
ffffffe000201d0c:	0287b783          	ld	a5,40(a5)
ffffffe000201d10:	0087f793          	andi	a5,a5,8
ffffffe000201d14:	00078863          	beqz	a5,ffffffe000201d24 <do_page_fault+0x26c>
ffffffe000201d18:	fe843783          	ld	a5,-24(s0)
ffffffe000201d1c:	0087e793          	ori	a5,a5,8
ffffffe000201d20:	fef43423          	sd	a5,-24(s0)
                    *pte_ptr = PTE_FROM_PPN(PPN_OF(new_pa)) | perm;
ffffffe000201d24:	f8843783          	ld	a5,-120(s0)
ffffffe000201d28:	00c7d793          	srli	a5,a5,0xc
ffffffe000201d2c:	00a79713          	slli	a4,a5,0xa
ffffffe000201d30:	fe843783          	ld	a5,-24(s0)
ffffffe000201d34:	00f76733          	or	a4,a4,a5
ffffffe000201d38:	fa843783          	ld	a5,-88(s0)
ffffffe000201d3c:	00e7b023          	sd	a4,0(a5)
                    // 引用数-1
                    put_page(old_kva);
ffffffe000201d40:	f9843503          	ld	a0,-104(s0)
ffffffe000201d44:	e49fe0ef          	jal	ffffffe000200b8c <put_page>
                    asm volatile("sfence.vma %0, zero" :: "r"(va) : "memory");
ffffffe000201d48:	fb043783          	ld	a5,-80(s0)
ffffffe000201d4c:	12078073          	sfence.vma	a5
                    Log("[PID = %d] COW at 0x%lx\n", current->pid, va);
                    return;
ffffffe000201d50:	2100006f          	j	ffffffe000201f60 <do_page_fault+0x4a8>
                } else {
                    // 只有一个引用，恢复写权限
                    *pte_ptr |= PTE_W;
ffffffe000201d54:	fa843783          	ld	a5,-88(s0)
ffffffe000201d58:	0007b783          	ld	a5,0(a5)
ffffffe000201d5c:	0047e713          	ori	a4,a5,4
ffffffe000201d60:	fa843783          	ld	a5,-88(s0)
ffffffe000201d64:	00e7b023          	sd	a4,0(a5)
                    asm volatile("sfence.vma %0, zero" :: "r"(va) : "memory");
ffffffe000201d68:	fb043783          	ld	a5,-80(s0)
ffffffe000201d6c:	12078073          	sfence.vma	a5
                    return;
ffffffe000201d70:	1f00006f          	j	ffffffe000201f60 <do_page_fault+0x4a8>
                }
            }
        }
        // 分配一页
        uint64_t kva = (uint64_t)alloc_page();
ffffffe000201d74:	e61fe0ef          	jal	ffffffe000200bd4 <alloc_page>
ffffffe000201d78:	00050793          	mv	a5,a0
ffffffe000201d7c:	f8f43023          	sd	a5,-128(s0)
        uint64_t pa = kva - PA2VA_OFFSET;
ffffffe000201d80:	f8043703          	ld	a4,-128(s0)
ffffffe000201d84:	04100793          	li	a5,65
ffffffe000201d88:	01f79793          	slli	a5,a5,0x1f
ffffffe000201d8c:	00f707b3          	add	a5,a4,a5
ffffffe000201d90:	f6f43c23          	sd	a5,-136(s0)

        // 如果是匿名空间，直接映射
        if (vma->vm_flags & VM_ANON) {
ffffffe000201d94:	fb843783          	ld	a5,-72(s0)
ffffffe000201d98:	0287b783          	ld	a5,40(a5)
ffffffe000201d9c:	0017f793          	andi	a5,a5,1
ffffffe000201da0:	00078e63          	beqz	a5,ffffffe000201dbc <do_page_fault+0x304>
            // 清零
            memset((void *)kva, 0, PGSIZE);
ffffffe000201da4:	f8043783          	ld	a5,-128(s0)
ffffffe000201da8:	00001637          	lui	a2,0x1
ffffffe000201dac:	00000593          	li	a1,0
ffffffe000201db0:	00078513          	mv	a0,a5
ffffffe000201db4:	0c9020ef          	jal	ffffffe00020467c <memset>
ffffffe000201db8:	1240006f          	j	ffffffe000201edc <do_page_fault+0x424>
        } else {
            // 根据 vma->vm_pgoff 等信息从 ELF 中读取数据，填充后映射到用户空间
            if (va < vma->vm_start || va >= vma->vm_end) {
ffffffe000201dbc:	fb843783          	ld	a5,-72(s0)
ffffffe000201dc0:	0087b783          	ld	a5,8(a5)
ffffffe000201dc4:	fb043703          	ld	a4,-80(s0)
ffffffe000201dc8:	00f76a63          	bltu	a4,a5,ffffffe000201ddc <do_page_fault+0x324>
ffffffe000201dcc:	fb843783          	ld	a5,-72(s0)
ffffffe000201dd0:	0107b783          	ld	a5,16(a5)
ffffffe000201dd4:	fb043703          	ld	a4,-80(s0)
ffffffe000201dd8:	02f76863          	bltu	a4,a5,ffffffe000201e08 <do_page_fault+0x350>
                // 不在VMA范围内
                Err("Unexpected page fault at 0x%lx : not in vma range", stval);
ffffffe000201ddc:	fd043703          	ld	a4,-48(s0)
ffffffe000201de0:	00005697          	auipc	a3,0x5
ffffffe000201de4:	47868693          	addi	a3,a3,1144 # ffffffe000207258 <__func__.1>
ffffffe000201de8:	1af00613          	li	a2,431
ffffffe000201dec:	00005597          	auipc	a1,0x5
ffffffe000201df0:	26458593          	addi	a1,a1,612 # ffffffe000207050 <__func__.0+0x50>
ffffffe000201df4:	00005517          	auipc	a0,0x5
ffffffe000201df8:	39450513          	addi	a0,a0,916 # ffffffe000207188 <__func__.0+0x188>
ffffffe000201dfc:	760020ef          	jal	ffffffe00020455c <printk>
ffffffe000201e00:	00000013          	nop
ffffffe000201e04:	ffdff06f          	j	ffffffe000201e00 <do_page_fault+0x348>
                return;
            }
            uint64_t page_offset = va - vma->vm_start;
ffffffe000201e08:	fb843783          	ld	a5,-72(s0)
ffffffe000201e0c:	0087b783          	ld	a5,8(a5)
ffffffe000201e10:	fb043703          	ld	a4,-80(s0)
ffffffe000201e14:	40f707b3          	sub	a5,a4,a5
ffffffe000201e18:	f6f43823          	sd	a5,-144(s0)
            if (page_offset >= vma->vm_filesz) {
ffffffe000201e1c:	fb843783          	ld	a5,-72(s0)
ffffffe000201e20:	0387b783          	ld	a5,56(a5)
ffffffe000201e24:	f7043703          	ld	a4,-144(s0)
ffffffe000201e28:	00f76e63          	bltu	a4,a5,ffffffe000201e44 <do_page_fault+0x38c>
                // bss清零
                memset((void *)kva, 0, PGSIZE);
ffffffe000201e2c:	f8043783          	ld	a5,-128(s0)
ffffffe000201e30:	00001637          	lui	a2,0x1
ffffffe000201e34:	00000593          	li	a1,0
ffffffe000201e38:	00078513          	mv	a0,a5
ffffffe000201e3c:	041020ef          	jal	ffffffe00020467c <memset>
ffffffe000201e40:	09c0006f          	j	ffffffe000201edc <do_page_fault+0x424>
            } else {
                uint64_t file_offset = vma->vm_pgoff + page_offset;
ffffffe000201e44:	fb843783          	ld	a5,-72(s0)
ffffffe000201e48:	0307b783          	ld	a5,48(a5)
ffffffe000201e4c:	f7043703          	ld	a4,-144(s0)
ffffffe000201e50:	00f707b3          	add	a5,a4,a5
ffffffe000201e54:	f6f43423          	sd	a5,-152(s0)
                uint64_t bytes_left = vma->vm_filesz - page_offset;
ffffffe000201e58:	fb843783          	ld	a5,-72(s0)
ffffffe000201e5c:	0387b703          	ld	a4,56(a5)
ffffffe000201e60:	f7043783          	ld	a5,-144(s0)
ffffffe000201e64:	40f707b3          	sub	a5,a4,a5
ffffffe000201e68:	f6f43023          	sd	a5,-160(s0)
                uint64_t copy_size = (bytes_left >= PGSIZE) ? PGSIZE : bytes_left;
ffffffe000201e6c:	f6043783          	ld	a5,-160(s0)
ffffffe000201e70:	00001737          	lui	a4,0x1
ffffffe000201e74:	00f77463          	bgeu	a4,a5,ffffffe000201e7c <do_page_fault+0x3c4>
ffffffe000201e78:	000017b7          	lui	a5,0x1
ffffffe000201e7c:	f4f43c23          	sd	a5,-168(s0)
                memcpy((void *)kva, (void *)(_sramdisk + file_offset), copy_size);
ffffffe000201e80:	f8043683          	ld	a3,-128(s0)
ffffffe000201e84:	f6843703          	ld	a4,-152(s0)
ffffffe000201e88:	00008797          	auipc	a5,0x8
ffffffe000201e8c:	17878793          	addi	a5,a5,376 # ffffffe00020a000 <_sramdisk>
ffffffe000201e90:	00f707b3          	add	a5,a4,a5
ffffffe000201e94:	f5843603          	ld	a2,-168(s0)
ffffffe000201e98:	00078593          	mv	a1,a5
ffffffe000201e9c:	00068513          	mv	a0,a3
ffffffe000201ea0:	04d020ef          	jal	ffffffe0002046ec <memcpy>
                // 不满一页，补零
                if (copy_size < PGSIZE) {
ffffffe000201ea4:	f5843703          	ld	a4,-168(s0)
ffffffe000201ea8:	000017b7          	lui	a5,0x1
ffffffe000201eac:	02f77863          	bgeu	a4,a5,ffffffe000201edc <do_page_fault+0x424>
                    memset((void *)(kva + copy_size), 0, PGSIZE - copy_size);
ffffffe000201eb0:	f8043703          	ld	a4,-128(s0)
ffffffe000201eb4:	f5843783          	ld	a5,-168(s0)
ffffffe000201eb8:	00f707b3          	add	a5,a4,a5
ffffffe000201ebc:	00078693          	mv	a3,a5
ffffffe000201ec0:	00001737          	lui	a4,0x1
ffffffe000201ec4:	f5843783          	ld	a5,-168(s0)
ffffffe000201ec8:	40f707b3          	sub	a5,a4,a5
ffffffe000201ecc:	00078613          	mv	a2,a5
ffffffe000201ed0:	00000593          	li	a1,0
ffffffe000201ed4:	00068513          	mv	a0,a3
ffffffe000201ed8:	7a4020ef          	jal	ffffffe00020467c <memset>
                }
            }
        }

        // 权限
        uint64_t perm = PTE_V | PTE_U;
ffffffe000201edc:	01100793          	li	a5,17
ffffffe000201ee0:	fef43023          	sd	a5,-32(s0)
        if (vma->vm_flags & VM_READ)  perm |= PTE_R;
ffffffe000201ee4:	fb843783          	ld	a5,-72(s0)
ffffffe000201ee8:	0287b783          	ld	a5,40(a5) # 1028 <PGSIZE+0x28>
ffffffe000201eec:	0027f793          	andi	a5,a5,2
ffffffe000201ef0:	00078863          	beqz	a5,ffffffe000201f00 <do_page_fault+0x448>
ffffffe000201ef4:	fe043783          	ld	a5,-32(s0)
ffffffe000201ef8:	0027e793          	ori	a5,a5,2
ffffffe000201efc:	fef43023          	sd	a5,-32(s0)
        if (vma->vm_flags & VM_WRITE) perm |= PTE_W;
ffffffe000201f00:	fb843783          	ld	a5,-72(s0)
ffffffe000201f04:	0287b783          	ld	a5,40(a5)
ffffffe000201f08:	0047f793          	andi	a5,a5,4
ffffffe000201f0c:	00078863          	beqz	a5,ffffffe000201f1c <do_page_fault+0x464>
ffffffe000201f10:	fe043783          	ld	a5,-32(s0)
ffffffe000201f14:	0047e793          	ori	a5,a5,4
ffffffe000201f18:	fef43023          	sd	a5,-32(s0)
        if (vma->vm_flags & VM_EXEC)  perm |= PTE_X;
ffffffe000201f1c:	fb843783          	ld	a5,-72(s0)
ffffffe000201f20:	0287b783          	ld	a5,40(a5)
ffffffe000201f24:	0087f793          	andi	a5,a5,8
ffffffe000201f28:	00078863          	beqz	a5,ffffffe000201f38 <do_page_fault+0x480>
ffffffe000201f2c:	fe043783          	ld	a5,-32(s0)
ffffffe000201f30:	0087e793          	ori	a5,a5,8
ffffffe000201f34:	fef43023          	sd	a5,-32(s0)
        
        // 映射
        create_mapping(current->pgd, va, pa, PGSIZE, perm);
ffffffe000201f38:	0040b797          	auipc	a5,0x40b
ffffffe000201f3c:	0d878793          	addi	a5,a5,216 # ffffffe00060d010 <current>
ffffffe000201f40:	0007b783          	ld	a5,0(a5)
ffffffe000201f44:	0a87b783          	ld	a5,168(a5)
ffffffe000201f48:	fe043703          	ld	a4,-32(s0)
ffffffe000201f4c:	000016b7          	lui	a3,0x1
ffffffe000201f50:	f7843603          	ld	a2,-136(s0)
ffffffe000201f54:	fb043583          	ld	a1,-80(s0)
ffffffe000201f58:	00078513          	mv	a0,a5
ffffffe000201f5c:	420010ef          	jal	ffffffe00020337c <create_mapping>
    }
}
ffffffe000201f60:	0b813083          	ld	ra,184(sp)
ffffffe000201f64:	0b013403          	ld	s0,176(sp)
ffffffe000201f68:	0c010113          	addi	sp,sp,192
ffffffe000201f6c:	00008067          	ret

ffffffe000201f70 <do_fork>:

// 线程fork
uint64_t do_fork(struct pt_regs *regs) {
ffffffe000201f70:	f7010113          	addi	sp,sp,-144
ffffffe000201f74:	08113423          	sd	ra,136(sp)
ffffffe000201f78:	08813023          	sd	s0,128(sp)
ffffffe000201f7c:	09010413          	addi	s0,sp,144
ffffffe000201f80:	f6a43c23          	sd	a0,-136(s0)
    // 拷贝内核栈
    struct task_struct *new_task = (struct task_struct *)kalloc();
ffffffe000201f84:	cc5fe0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000201f88:	fca43823          	sd	a0,-48(s0)
    memcpy(new_task, current, PGSIZE);
ffffffe000201f8c:	0040b797          	auipc	a5,0x40b
ffffffe000201f90:	08478793          	addi	a5,a5,132 # ffffffe00060d010 <current>
ffffffe000201f94:	0007b783          	ld	a5,0(a5)
ffffffe000201f98:	00001637          	lui	a2,0x1
ffffffe000201f9c:	00078593          	mv	a1,a5
ffffffe000201fa0:	fd043503          	ld	a0,-48(s0)
ffffffe000201fa4:	748020ef          	jal	ffffffe0002046ec <memcpy>
    task[nr_tasks] = new_task;
ffffffe000201fa8:	0040b797          	auipc	a5,0x40b
ffffffe000201fac:	07078793          	addi	a5,a5,112 # ffffffe00060d018 <nr_tasks>
ffffffe000201fb0:	0007a783          	lw	a5,0(a5)
ffffffe000201fb4:	0040b717          	auipc	a4,0x40b
ffffffe000201fb8:	0a470713          	addi	a4,a4,164 # ffffffe00060d058 <task>
ffffffe000201fbc:	00379793          	slli	a5,a5,0x3
ffffffe000201fc0:	00f707b3          	add	a5,a4,a5
ffffffe000201fc4:	fd043703          	ld	a4,-48(s0)
ffffffe000201fc8:	00e7b023          	sd	a4,0(a5)
    new_task->pid = nr_tasks;
ffffffe000201fcc:	0040b797          	auipc	a5,0x40b
ffffffe000201fd0:	04c78793          	addi	a5,a5,76 # ffffffe00060d018 <nr_tasks>
ffffffe000201fd4:	0007a783          	lw	a5,0(a5)
ffffffe000201fd8:	00078713          	mv	a4,a5
ffffffe000201fdc:	fd043783          	ld	a5,-48(s0)
ffffffe000201fe0:	00e7bc23          	sd	a4,24(a5)
    nr_tasks++;
ffffffe000201fe4:	0040b797          	auipc	a5,0x40b
ffffffe000201fe8:	03478793          	addi	a5,a5,52 # ffffffe00060d018 <nr_tasks>
ffffffe000201fec:	0007a783          	lw	a5,0(a5)
ffffffe000201ff0:	0017879b          	addiw	a5,a5,1
ffffffe000201ff4:	0007871b          	sext.w	a4,a5
ffffffe000201ff8:	0040b797          	auipc	a5,0x40b
ffffffe000201ffc:	02078793          	addi	a5,a5,32 # ffffffe00060d018 <nr_tasks>
ffffffe000202000:	00e7a023          	sw	a4,0(a5)

    // 新建vma
    struct mm_struct *mm = (struct mm_struct *)kalloc();
ffffffe000202004:	c45fe0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000202008:	fca43423          	sd	a0,-56(s0)
    memcpy(mm, current->mm, sizeof(struct mm_struct));
ffffffe00020200c:	0040b797          	auipc	a5,0x40b
ffffffe000202010:	00478793          	addi	a5,a5,4 # ffffffe00060d010 <current>
ffffffe000202014:	0007b783          	ld	a5,0(a5)
ffffffe000202018:	0b07b783          	ld	a5,176(a5)
ffffffe00020201c:	00800613          	li	a2,8
ffffffe000202020:	00078593          	mv	a1,a5
ffffffe000202024:	fc843503          	ld	a0,-56(s0)
ffffffe000202028:	6c4020ef          	jal	ffffffe0002046ec <memcpy>
    mm->mmap = NULL;
ffffffe00020202c:	fc843783          	ld	a5,-56(s0)
ffffffe000202030:	0007b023          	sd	zero,0(a5)
    new_task->mm = mm;
ffffffe000202034:	fd043783          	ld	a5,-48(s0)
ffffffe000202038:	fc843703          	ld	a4,-56(s0)
ffffffe00020203c:	0ae7b823          	sd	a4,176(a5)

    // 拷贝内核页表
    uint64_t *pg = (uint64_t *)kalloc();
ffffffe000202040:	c09fe0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000202044:	fca43023          	sd	a0,-64(s0)
    memcpy(pg, swapper_pg_dir, PGSIZE);
ffffffe000202048:	00001637          	lui	a2,0x1
ffffffe00020204c:	0040d597          	auipc	a1,0x40d
ffffffe000202050:	fb458593          	addi	a1,a1,-76 # ffffffe00060f000 <swapper_pg_dir>
ffffffe000202054:	fc043503          	ld	a0,-64(s0)
ffffffe000202058:	694020ef          	jal	ffffffe0002046ec <memcpy>
    new_task->pgd = pg;
ffffffe00020205c:	fd043783          	ld	a5,-48(s0)
ffffffe000202060:	fc043703          	ld	a4,-64(s0)
ffffffe000202064:	0ae7b423          	sd	a4,168(a5)
    // 遍历父进程vma链表，建立子进程vma链表
    struct vm_area_struct *vma = current->mm->mmap;
ffffffe000202068:	0040b797          	auipc	a5,0x40b
ffffffe00020206c:	fa878793          	addi	a5,a5,-88 # ffffffe00060d010 <current>
ffffffe000202070:	0007b783          	ld	a5,0(a5)
ffffffe000202074:	0b07b783          	ld	a5,176(a5)
ffffffe000202078:	0007b783          	ld	a5,0(a5)
ffffffe00020207c:	fef43423          	sd	a5,-24(s0)
    while(vma) {
ffffffe000202080:	1f00006f          	j	ffffffe000202270 <do_fork+0x300>
        struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
ffffffe000202084:	bc5fe0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000202088:	faa43023          	sd	a0,-96(s0)
        memset(new_vma, 0, sizeof(struct vm_area_struct));
ffffffe00020208c:	04000613          	li	a2,64
ffffffe000202090:	00000593          	li	a1,0
ffffffe000202094:	fa043503          	ld	a0,-96(s0)
ffffffe000202098:	5e4020ef          	jal	ffffffe00020467c <memset>
        new_vma->vm_mm = mm;
ffffffe00020209c:	fa043783          	ld	a5,-96(s0)
ffffffe0002020a0:	fc843703          	ld	a4,-56(s0)
ffffffe0002020a4:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_start = vma->vm_start;
ffffffe0002020a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002020ac:	0087b703          	ld	a4,8(a5)
ffffffe0002020b0:	fa043783          	ld	a5,-96(s0)
ffffffe0002020b4:	00e7b423          	sd	a4,8(a5)
        new_vma->vm_end = vma->vm_end;
ffffffe0002020b8:	fe843783          	ld	a5,-24(s0)
ffffffe0002020bc:	0107b703          	ld	a4,16(a5)
ffffffe0002020c0:	fa043783          	ld	a5,-96(s0)
ffffffe0002020c4:	00e7b823          	sd	a4,16(a5)
        new_vma->vm_flags = vma->vm_flags;
ffffffe0002020c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002020cc:	0287b703          	ld	a4,40(a5)
ffffffe0002020d0:	fa043783          	ld	a5,-96(s0)
ffffffe0002020d4:	02e7b423          	sd	a4,40(a5)
        new_vma->vm_pgoff = vma->vm_pgoff;
ffffffe0002020d8:	fe843783          	ld	a5,-24(s0)
ffffffe0002020dc:	0307b703          	ld	a4,48(a5)
ffffffe0002020e0:	fa043783          	ld	a5,-96(s0)
ffffffe0002020e4:	02e7b823          	sd	a4,48(a5)
        new_vma->vm_filesz = vma->vm_filesz;
ffffffe0002020e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002020ec:	0387b703          	ld	a4,56(a5)
ffffffe0002020f0:	fa043783          	ld	a5,-96(s0)
ffffffe0002020f4:	02e7bc23          	sd	a4,56(a5)
        new_vma->vm_prev = NULL;
ffffffe0002020f8:	fa043783          	ld	a5,-96(s0)
ffffffe0002020fc:	0207b023          	sd	zero,32(a5)
        new_vma->vm_next = mm->mmap;
ffffffe000202100:	fc843783          	ld	a5,-56(s0)
ffffffe000202104:	0007b703          	ld	a4,0(a5)
ffffffe000202108:	fa043783          	ld	a5,-96(s0)
ffffffe00020210c:	00e7bc23          	sd	a4,24(a5)
        if (mm->mmap != NULL) {
ffffffe000202110:	fc843783          	ld	a5,-56(s0)
ffffffe000202114:	0007b783          	ld	a5,0(a5)
ffffffe000202118:	00078a63          	beqz	a5,ffffffe00020212c <do_fork+0x1bc>
            mm->mmap->vm_prev = new_vma;
ffffffe00020211c:	fc843783          	ld	a5,-56(s0)
ffffffe000202120:	0007b783          	ld	a5,0(a5)
ffffffe000202124:	fa043703          	ld	a4,-96(s0)
ffffffe000202128:	02e7b023          	sd	a4,32(a5)
        }
        mm->mmap = new_vma;
ffffffe00020212c:	fc843783          	ld	a5,-56(s0)
ffffffe000202130:	fa043703          	ld	a4,-96(s0)
ffffffe000202134:	00e7b023          	sd	a4,0(a5)

        // 遍历vma页，如果有对应的页表项存在，refcnt++
        for (uint64_t va = vma->vm_start; va < vma->vm_end; va += PGSIZE) {
ffffffe000202138:	fe843783          	ld	a5,-24(s0)
ffffffe00020213c:	0087b783          	ld	a5,8(a5)
ffffffe000202140:	fef43023          	sd	a5,-32(s0)
ffffffe000202144:	1100006f          	j	ffffffe000202254 <do_fork+0x2e4>
            uint64_t *pte_ptr = walk_page_table(current->pgd, va, 0);
ffffffe000202148:	0040b797          	auipc	a5,0x40b
ffffffe00020214c:	ec878793          	addi	a5,a5,-312 # ffffffe00060d010 <current>
ffffffe000202150:	0007b783          	ld	a5,0(a5)
ffffffe000202154:	0a87b783          	ld	a5,168(a5)
ffffffe000202158:	00000613          	li	a2,0
ffffffe00020215c:	fe043583          	ld	a1,-32(s0)
ffffffe000202160:	00078513          	mv	a0,a5
ffffffe000202164:	1e0000ef          	jal	ffffffe000202344 <walk_page_table>
ffffffe000202168:	f8a43c23          	sd	a0,-104(s0)
            if (pte_ptr && (*pte_ptr & PTE_V)) {
ffffffe00020216c:	f9843783          	ld	a5,-104(s0)
ffffffe000202170:	0c078a63          	beqz	a5,ffffffe000202244 <do_fork+0x2d4>
ffffffe000202174:	f9843783          	ld	a5,-104(s0)
ffffffe000202178:	0007b783          	ld	a5,0(a5)
ffffffe00020217c:	0017f793          	andi	a5,a5,1
ffffffe000202180:	0c078263          	beqz	a5,ffffffe000202244 <do_fork+0x2d4>
                // if (vma->vm_flags & VM_WRITE) perm |= PTE_W;
                // if (vma->vm_flags & VM_EXEC)  perm |= PTE_X;
                // create_mapping(new_task->pgd, va, pa, PGSIZE, perm);

                // 对应页表项存在且有效，引用数+1
                uint64_t pa = PTE2PA(*pte_ptr);
ffffffe000202184:	f9843783          	ld	a5,-104(s0)
ffffffe000202188:	0007b783          	ld	a5,0(a5)
ffffffe00020218c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202190:	00c79713          	slli	a4,a5,0xc
ffffffe000202194:	fff007b7          	lui	a5,0xfff00
ffffffe000202198:	0087d793          	srli	a5,a5,0x8
ffffffe00020219c:	00f777b3          	and	a5,a4,a5
ffffffe0002021a0:	f8f43823          	sd	a5,-112(s0)
                void *old_kva = (void *)PA2VA(pa);
ffffffe0002021a4:	f9043703          	ld	a4,-112(s0)
ffffffe0002021a8:	fbf00793          	li	a5,-65
ffffffe0002021ac:	01f79793          	slli	a5,a5,0x1f
ffffffe0002021b0:	00f707b3          	add	a5,a4,a5
ffffffe0002021b4:	f8f43423          	sd	a5,-120(s0)
                get_page(old_kva);
ffffffe0002021b8:	f8843503          	ld	a0,-120(s0)
ffffffe0002021bc:	909fe0ef          	jal	ffffffe000200ac4 <get_page>

                // 映射权限
                uint64_t perm = PTE_V | PTE_U;
ffffffe0002021c0:	01100793          	li	a5,17
ffffffe0002021c4:	fcf43c23          	sd	a5,-40(s0)
                if (vma->vm_flags & VM_READ)  perm |= PTE_R;
ffffffe0002021c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002021cc:	0287b783          	ld	a5,40(a5) # fffffffffff00028 <VM_END+0xfff00028>
ffffffe0002021d0:	0027f793          	andi	a5,a5,2
ffffffe0002021d4:	00078863          	beqz	a5,ffffffe0002021e4 <do_fork+0x274>
ffffffe0002021d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002021dc:	0027e793          	ori	a5,a5,2
ffffffe0002021e0:	fcf43c23          	sd	a5,-40(s0)
                if (vma->vm_flags & VM_EXEC)  perm |= PTE_X;
ffffffe0002021e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002021e8:	0287b783          	ld	a5,40(a5)
ffffffe0002021ec:	0087f793          	andi	a5,a5,8
ffffffe0002021f0:	00078863          	beqz	a5,ffffffe000202200 <do_fork+0x290>
ffffffe0002021f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002021f8:	0087e793          	ori	a5,a5,8
ffffffe0002021fc:	fcf43c23          	sd	a5,-40(s0)

                if (vma->vm_flags & VM_WRITE) {
ffffffe000202200:	fe843783          	ld	a5,-24(s0)
ffffffe000202204:	0287b783          	ld	a5,40(a5)
ffffffe000202208:	0047f793          	andi	a5,a5,4
ffffffe00020220c:	00078c63          	beqz	a5,ffffffe000202224 <do_fork+0x2b4>
                    // 清除可写权限
                    *pte_ptr &= ~PTE_W;
ffffffe000202210:	f9843783          	ld	a5,-104(s0)
ffffffe000202214:	0007b783          	ld	a5,0(a5)
ffffffe000202218:	ffb7f713          	andi	a4,a5,-5
ffffffe00020221c:	f9843783          	ld	a5,-104(s0)
ffffffe000202220:	00e7b023          	sd	a4,0(a5)
                }

                create_mapping(new_task->pgd, va, pa, PGSIZE, perm);
ffffffe000202224:	fd043783          	ld	a5,-48(s0)
ffffffe000202228:	0a87b783          	ld	a5,168(a5)
ffffffe00020222c:	fd843703          	ld	a4,-40(s0)
ffffffe000202230:	000016b7          	lui	a3,0x1
ffffffe000202234:	f9043603          	ld	a2,-112(s0)
ffffffe000202238:	fe043583          	ld	a1,-32(s0)
ffffffe00020223c:	00078513          	mv	a0,a5
ffffffe000202240:	13c010ef          	jal	ffffffe00020337c <create_mapping>
        for (uint64_t va = vma->vm_start; va < vma->vm_end; va += PGSIZE) {
ffffffe000202244:	fe043703          	ld	a4,-32(s0)
ffffffe000202248:	000017b7          	lui	a5,0x1
ffffffe00020224c:	00f707b3          	add	a5,a4,a5
ffffffe000202250:	fef43023          	sd	a5,-32(s0)
ffffffe000202254:	fe843783          	ld	a5,-24(s0)
ffffffe000202258:	0107b783          	ld	a5,16(a5) # 1010 <PGSIZE+0x10>
ffffffe00020225c:	fe043703          	ld	a4,-32(s0)
ffffffe000202260:	eef764e3          	bltu	a4,a5,ffffffe000202148 <do_fork+0x1d8>
            }
        }
        vma = vma->vm_next;
ffffffe000202264:	fe843783          	ld	a5,-24(s0)
ffffffe000202268:	0187b783          	ld	a5,24(a5)
ffffffe00020226c:	fef43423          	sd	a5,-24(s0)
    while(vma) {
ffffffe000202270:	fe843783          	ld	a5,-24(s0)
ffffffe000202274:	e00798e3          	bnez	a5,ffffffe000202084 <do_fork+0x114>
    }
    // 刷新TLB
    asm volatile("sfence.vma zero, zero" ::: "memory");
ffffffe000202278:	12000073          	sfence.vma

    // 设置ra为__ret_from_fork
    new_task->thread.ra = (uint64_t)__ret_from_fork;
ffffffe00020227c:	ffffe717          	auipc	a4,0xffffe
ffffffe000202280:	f9870713          	addi	a4,a4,-104 # ffffffe000200214 <__ret_from_fork>
ffffffe000202284:	fd043783          	ld	a5,-48(s0)
ffffffe000202288:	02e7b023          	sd	a4,32(a5)
    // 设置ptregs
    uint64_t offset = (uint64_t)regs - (uint64_t)current;
ffffffe00020228c:	f7843783          	ld	a5,-136(s0)
ffffffe000202290:	0040b717          	auipc	a4,0x40b
ffffffe000202294:	d8070713          	addi	a4,a4,-640 # ffffffe00060d010 <current>
ffffffe000202298:	00073703          	ld	a4,0(a4)
ffffffe00020229c:	40e787b3          	sub	a5,a5,a4
ffffffe0002022a0:	faf43c23          	sd	a5,-72(s0)
    struct pt_regs *child_regs = (struct pt_regs *)((uint64_t)new_task + offset);
ffffffe0002022a4:	fd043703          	ld	a4,-48(s0)
ffffffe0002022a8:	fb843783          	ld	a5,-72(s0)
ffffffe0002022ac:	00f707b3          	add	a5,a4,a5
ffffffe0002022b0:	faf43823          	sd	a5,-80(s0)
    // 设置sp
    new_task->thread.sp = (uint64_t)child_regs;
ffffffe0002022b4:	fb043703          	ld	a4,-80(s0)
ffffffe0002022b8:	fd043783          	ld	a5,-48(s0)
ffffffe0002022bc:	02e7b423          	sd	a4,40(a5)
    child_regs->regs_32[2] = (uint64_t)child_regs;
ffffffe0002022c0:	fb043703          	ld	a4,-80(s0)
ffffffe0002022c4:	fb043783          	ld	a5,-80(s0)
ffffffe0002022c8:	00e7b823          	sd	a4,16(a5)

    // 设置sscratch
    new_task->thread.sscratch = csr_read(sscratch);
ffffffe0002022cc:	140027f3          	csrr	a5,sscratch
ffffffe0002022d0:	faf43423          	sd	a5,-88(s0)
ffffffe0002022d4:	fa843703          	ld	a4,-88(s0)
ffffffe0002022d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002022dc:	0ae7b023          	sd	a4,160(a5)
    
    // 子进程fork返回值 = 0
    child_regs->regs_32[10] = 0;
ffffffe0002022e0:	fb043783          	ld	a5,-80(s0)
ffffffe0002022e4:	0407b823          	sd	zero,80(a5)
    // sepc手动+4
    child_regs->sepc = regs->sepc + 4;
ffffffe0002022e8:	f7843783          	ld	a5,-136(s0)
ffffffe0002022ec:	1007b783          	ld	a5,256(a5)
ffffffe0002022f0:	00478713          	addi	a4,a5,4
ffffffe0002022f4:	fb043783          	ld	a5,-80(s0)
ffffffe0002022f8:	10e7b023          	sd	a4,256(a5)

    printk(GREEN "[PID = %d] forked from [PID = %d] \n" CLEAR, new_task->pid, current->pid);
ffffffe0002022fc:	fd043783          	ld	a5,-48(s0)
ffffffe000202300:	0187b703          	ld	a4,24(a5)
ffffffe000202304:	0040b797          	auipc	a5,0x40b
ffffffe000202308:	d0c78793          	addi	a5,a5,-756 # ffffffe00060d010 <current>
ffffffe00020230c:	0007b783          	ld	a5,0(a5)
ffffffe000202310:	0187b783          	ld	a5,24(a5)
ffffffe000202314:	00078613          	mv	a2,a5
ffffffe000202318:	00070593          	mv	a1,a4
ffffffe00020231c:	00005517          	auipc	a0,0x5
ffffffe000202320:	ebc50513          	addi	a0,a0,-324 # ffffffe0002071d8 <__func__.0+0x1d8>
ffffffe000202324:	238020ef          	jal	ffffffe00020455c <printk>
    // 返回子进程pid
    return new_task->pid;
ffffffe000202328:	fd043783          	ld	a5,-48(s0)
ffffffe00020232c:	0187b783          	ld	a5,24(a5)
}
ffffffe000202330:	00078513          	mv	a0,a5
ffffffe000202334:	08813083          	ld	ra,136(sp)
ffffffe000202338:	08013403          	ld	s0,128(sp)
ffffffe00020233c:	09010113          	addi	sp,sp,144
ffffffe000202340:	00008067          	ret

ffffffe000202344 <walk_page_table>:

uint64_t *walk_page_table(uint64_t *pgtbl, uint64_t va, int alloc) {
ffffffe000202344:	f9010113          	addi	sp,sp,-112
ffffffe000202348:	06113423          	sd	ra,104(sp)
ffffffe00020234c:	06813023          	sd	s0,96(sp)
ffffffe000202350:	07010413          	addi	s0,sp,112
ffffffe000202354:	faa43423          	sd	a0,-88(s0)
ffffffe000202358:	fab43023          	sd	a1,-96(s0)
ffffffe00020235c:	00060793          	mv	a5,a2
ffffffe000202360:	f8f42e23          	sw	a5,-100(s0)
    // 获取VPN
    uint64_t vpn[3];
    vpn[0] = (va >> 12) & 0x1FF;
ffffffe000202364:	fa043783          	ld	a5,-96(s0)
ffffffe000202368:	00c7d793          	srli	a5,a5,0xc
ffffffe00020236c:	1ff7f793          	andi	a5,a5,511
ffffffe000202370:	faf43c23          	sd	a5,-72(s0)
    vpn[1] = (va >> 21) & 0x1FF;
ffffffe000202374:	fa043783          	ld	a5,-96(s0)
ffffffe000202378:	0157d793          	srli	a5,a5,0x15
ffffffe00020237c:	1ff7f793          	andi	a5,a5,511
ffffffe000202380:	fcf43023          	sd	a5,-64(s0)
    vpn[2] = (va >> 30) & 0x1FF;
ffffffe000202384:	fa043783          	ld	a5,-96(s0)
ffffffe000202388:	01e7d793          	srli	a5,a5,0x1e
ffffffe00020238c:	1ff7f793          	andi	a5,a5,511
ffffffe000202390:	fcf43423          	sd	a5,-56(s0)

    uint64_t *pte = &pgtbl[vpn[2]];
ffffffe000202394:	fc843783          	ld	a5,-56(s0)
ffffffe000202398:	00379793          	slli	a5,a5,0x3
ffffffe00020239c:	fa843703          	ld	a4,-88(s0)
ffffffe0002023a0:	00f707b3          	add	a5,a4,a5
ffffffe0002023a4:	fef43423          	sd	a5,-24(s0)
    for (int level = 2; level > 0; --level) {
ffffffe0002023a8:	00200793          	li	a5,2
ffffffe0002023ac:	fef42223          	sw	a5,-28(s0)
ffffffe0002023b0:	0f80006f          	j	ffffffe0002024a8 <walk_page_table+0x164>
        if (!(*pte & PTE_V)) {
ffffffe0002023b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002023b8:	0007b783          	ld	a5,0(a5)
ffffffe0002023bc:	0017f793          	andi	a5,a5,1
ffffffe0002023c0:	08079263          	bnez	a5,ffffffe000202444 <walk_page_table+0x100>
            if (alloc == 0) {
ffffffe0002023c4:	f9c42783          	lw	a5,-100(s0)
ffffffe0002023c8:	0007879b          	sext.w	a5,a5
ffffffe0002023cc:	00079663          	bnez	a5,ffffffe0002023d8 <walk_page_table+0x94>
                return 0;
ffffffe0002023d0:	00000793          	li	a5,0
ffffffe0002023d4:	0e40006f          	j	ffffffe0002024b8 <walk_page_table+0x174>
            }
            uint64_t *new_page = (uint64_t *)kalloc();
ffffffe0002023d8:	871fe0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe0002023dc:	fca43c23          	sd	a0,-40(s0)
            if (new_page == 0) {
ffffffe0002023e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002023e4:	02079663          	bnez	a5,ffffffe000202410 <walk_page_table+0xcc>
                Err("walk_page_table: kalloc failed\n");
ffffffe0002023e8:	00005697          	auipc	a3,0x5
ffffffe0002023ec:	e8068693          	addi	a3,a3,-384 # ffffffe000207268 <__func__.0>
ffffffe0002023f0:	23d00613          	li	a2,573
ffffffe0002023f4:	00005597          	auipc	a1,0x5
ffffffe0002023f8:	c5c58593          	addi	a1,a1,-932 # ffffffe000207050 <__func__.0+0x50>
ffffffe0002023fc:	00005517          	auipc	a0,0x5
ffffffe000202400:	e0c50513          	addi	a0,a0,-500 # ffffffe000207208 <__func__.0+0x208>
ffffffe000202404:	158020ef          	jal	ffffffe00020455c <printk>
ffffffe000202408:	00000013          	nop
ffffffe00020240c:	ffdff06f          	j	ffffffe000202408 <walk_page_table+0xc4>
                return 0;
            }
            memset(new_page, 0, PGSIZE);
ffffffe000202410:	00001637          	lui	a2,0x1
ffffffe000202414:	00000593          	li	a1,0
ffffffe000202418:	fd843503          	ld	a0,-40(s0)
ffffffe00020241c:	260020ef          	jal	ffffffe00020467c <memset>
            *pte = PTE_FROM_PPN(PPN_OF((uint64_t)new_page - PA2VA_OFFSET)) | PTE_V;
ffffffe000202420:	fd843703          	ld	a4,-40(s0)
ffffffe000202424:	04100793          	li	a5,65
ffffffe000202428:	01f79793          	slli	a5,a5,0x1f
ffffffe00020242c:	00f707b3          	add	a5,a4,a5
ffffffe000202430:	00c7d793          	srli	a5,a5,0xc
ffffffe000202434:	00a79793          	slli	a5,a5,0xa
ffffffe000202438:	0017e713          	ori	a4,a5,1
ffffffe00020243c:	fe843783          	ld	a5,-24(s0)
ffffffe000202440:	00e7b023          	sd	a4,0(a5)
        }
        uint64_t *next_table = (uint64_t *)PA2VA(PTE2PA(*pte));
ffffffe000202444:	fe843783          	ld	a5,-24(s0)
ffffffe000202448:	0007b783          	ld	a5,0(a5)
ffffffe00020244c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202450:	00c79713          	slli	a4,a5,0xc
ffffffe000202454:	fff007b7          	lui	a5,0xfff00
ffffffe000202458:	0087d793          	srli	a5,a5,0x8
ffffffe00020245c:	00f77733          	and	a4,a4,a5
ffffffe000202460:	fbf00793          	li	a5,-65
ffffffe000202464:	01f79793          	slli	a5,a5,0x1f
ffffffe000202468:	00f707b3          	add	a5,a4,a5
ffffffe00020246c:	fcf43823          	sd	a5,-48(s0)
        pte = &next_table[vpn[level - 1]];
ffffffe000202470:	fe442783          	lw	a5,-28(s0)
ffffffe000202474:	fff7879b          	addiw	a5,a5,-1 # ffffffffffefffff <VM_END+0xffefffff>
ffffffe000202478:	0007879b          	sext.w	a5,a5
ffffffe00020247c:	00379793          	slli	a5,a5,0x3
ffffffe000202480:	ff078793          	addi	a5,a5,-16
ffffffe000202484:	008787b3          	add	a5,a5,s0
ffffffe000202488:	fc87b783          	ld	a5,-56(a5)
ffffffe00020248c:	00379793          	slli	a5,a5,0x3
ffffffe000202490:	fd043703          	ld	a4,-48(s0)
ffffffe000202494:	00f707b3          	add	a5,a4,a5
ffffffe000202498:	fef43423          	sd	a5,-24(s0)
    for (int level = 2; level > 0; --level) {
ffffffe00020249c:	fe442783          	lw	a5,-28(s0)
ffffffe0002024a0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002024a4:	fef42223          	sw	a5,-28(s0)
ffffffe0002024a8:	fe442783          	lw	a5,-28(s0)
ffffffe0002024ac:	0007879b          	sext.w	a5,a5
ffffffe0002024b0:	f0f042e3          	bgtz	a5,ffffffe0002023b4 <walk_page_table+0x70>
    }
    return pte;
ffffffe0002024b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002024b8:	00078513          	mv	a0,a5
ffffffe0002024bc:	06813083          	ld	ra,104(sp)
ffffffe0002024c0:	06013403          	ld	s0,96(sp)
ffffffe0002024c4:	07010113          	addi	sp,sp,112
ffffffe0002024c8:	00008067          	ret

ffffffe0002024cc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe0002024cc:	f7010113          	addi	sp,sp,-144
ffffffe0002024d0:	08813423          	sd	s0,136(sp)
ffffffe0002024d4:	08913023          	sd	s1,128(sp)
ffffffe0002024d8:	07213c23          	sd	s2,120(sp)
ffffffe0002024dc:	07313823          	sd	s3,112(sp)
ffffffe0002024e0:	09010413          	addi	s0,sp,144
ffffffe0002024e4:	faa43423          	sd	a0,-88(s0)
ffffffe0002024e8:	fab43023          	sd	a1,-96(s0)
ffffffe0002024ec:	f8c43c23          	sd	a2,-104(s0)
ffffffe0002024f0:	f8d43823          	sd	a3,-112(s0)
ffffffe0002024f4:	f8e43423          	sd	a4,-120(s0)
ffffffe0002024f8:	f8f43023          	sd	a5,-128(s0)
ffffffe0002024fc:	f7043c23          	sd	a6,-136(s0)
ffffffe000202500:	f7143823          	sd	a7,-144(s0)
    struct sbiret ret;
    uint64_t error_reg, value_reg;
    
    asm volatile(
ffffffe000202504:	fa843e03          	ld	t3,-88(s0)
ffffffe000202508:	fa043e83          	ld	t4,-96(s0)
ffffffe00020250c:	f9843f03          	ld	t5,-104(s0)
ffffffe000202510:	f9043f83          	ld	t6,-112(s0)
ffffffe000202514:	f8843283          	ld	t0,-120(s0)
ffffffe000202518:	f8043483          	ld	s1,-128(s0)
ffffffe00020251c:	f7843903          	ld	s2,-136(s0)
ffffffe000202520:	f7043983          	ld	s3,-144(s0)
ffffffe000202524:	000e0893          	mv	a7,t3
ffffffe000202528:	000e8813          	mv	a6,t4
ffffffe00020252c:	000f0513          	mv	a0,t5
ffffffe000202530:	000f8593          	mv	a1,t6
ffffffe000202534:	00028613          	mv	a2,t0
ffffffe000202538:	00048693          	mv	a3,s1
ffffffe00020253c:	00090713          	mv	a4,s2
ffffffe000202540:	00098793          	mv	a5,s3
ffffffe000202544:	00000073          	ecall
ffffffe000202548:	00050e93          	mv	t4,a0
ffffffe00020254c:	00058e13          	mv	t3,a1
ffffffe000202550:	fdd43c23          	sd	t4,-40(s0)
ffffffe000202554:	fdc43823          	sd	t3,-48(s0)
          "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
          
    );

    // 返回结果
    ret.error = error_reg;
ffffffe000202558:	fd843783          	ld	a5,-40(s0)
ffffffe00020255c:	faf43823          	sd	a5,-80(s0)
    ret.value = value_reg;
ffffffe000202560:	fd043783          	ld	a5,-48(s0)
ffffffe000202564:	faf43c23          	sd	a5,-72(s0)
    return ret;
ffffffe000202568:	fb043783          	ld	a5,-80(s0)
ffffffe00020256c:	fcf43023          	sd	a5,-64(s0)
ffffffe000202570:	fb843783          	ld	a5,-72(s0)
ffffffe000202574:	fcf43423          	sd	a5,-56(s0)
ffffffe000202578:	fc043703          	ld	a4,-64(s0)
ffffffe00020257c:	fc843783          	ld	a5,-56(s0)
ffffffe000202580:	00070313          	mv	t1,a4
ffffffe000202584:	00078393          	mv	t2,a5
ffffffe000202588:	00030713          	mv	a4,t1
ffffffe00020258c:	00038793          	mv	a5,t2
}
ffffffe000202590:	00070513          	mv	a0,a4
ffffffe000202594:	00078593          	mv	a1,a5
ffffffe000202598:	08813403          	ld	s0,136(sp)
ffffffe00020259c:	08013483          	ld	s1,128(sp)
ffffffe0002025a0:	07813903          	ld	s2,120(sp)
ffffffe0002025a4:	07013983          	ld	s3,112(sp)
ffffffe0002025a8:	09010113          	addi	sp,sp,144
ffffffe0002025ac:	00008067          	ret

ffffffe0002025b0 <sbi_set_timer>:

// 设置时钟相关寄存器
struct sbiret sbi_set_timer(uint64_t stime_value) {
ffffffe0002025b0:	fc010113          	addi	sp,sp,-64
ffffffe0002025b4:	02113c23          	sd	ra,56(sp)
ffffffe0002025b8:	02813823          	sd	s0,48(sp)
ffffffe0002025bc:	03213423          	sd	s2,40(sp)
ffffffe0002025c0:	03313023          	sd	s3,32(sp)
ffffffe0002025c4:	04010413          	addi	s0,sp,64
ffffffe0002025c8:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe0002025cc:	00000893          	li	a7,0
ffffffe0002025d0:	00000813          	li	a6,0
ffffffe0002025d4:	00000793          	li	a5,0
ffffffe0002025d8:	00000713          	li	a4,0
ffffffe0002025dc:	00000693          	li	a3,0
ffffffe0002025e0:	fc843603          	ld	a2,-56(s0)
ffffffe0002025e4:	00000593          	li	a1,0
ffffffe0002025e8:	54495537          	lui	a0,0x54495
ffffffe0002025ec:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe0002025f0:	eddff0ef          	jal	ffffffe0002024cc <sbi_ecall>
ffffffe0002025f4:	00050713          	mv	a4,a0
ffffffe0002025f8:	00058793          	mv	a5,a1
ffffffe0002025fc:	fce43823          	sd	a4,-48(s0)
ffffffe000202600:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202604:	fd043703          	ld	a4,-48(s0)
ffffffe000202608:	fd843783          	ld	a5,-40(s0)
ffffffe00020260c:	00070913          	mv	s2,a4
ffffffe000202610:	00078993          	mv	s3,a5
ffffffe000202614:	00090713          	mv	a4,s2
ffffffe000202618:	00098793          	mv	a5,s3
}
ffffffe00020261c:	00070513          	mv	a0,a4
ffffffe000202620:	00078593          	mv	a1,a5
ffffffe000202624:	03813083          	ld	ra,56(sp)
ffffffe000202628:	03013403          	ld	s0,48(sp)
ffffffe00020262c:	02813903          	ld	s2,40(sp)
ffffffe000202630:	02013983          	ld	s3,32(sp)
ffffffe000202634:	04010113          	addi	sp,sp,64
ffffffe000202638:	00008067          	ret

ffffffe00020263c <sbi_debug_console_write_byte>:
// 从终端读取数据
// struct sbiret sbi_debug_console_read() {
    
// }
// 向终端写入单个字符
struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe00020263c:	fc010113          	addi	sp,sp,-64
ffffffe000202640:	02113c23          	sd	ra,56(sp)
ffffffe000202644:	02813823          	sd	s0,48(sp)
ffffffe000202648:	03213423          	sd	s2,40(sp)
ffffffe00020264c:	03313023          	sd	s3,32(sp)
ffffffe000202650:	04010413          	addi	s0,sp,64
ffffffe000202654:	00050793          	mv	a5,a0
ffffffe000202658:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434e, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe00020265c:	fcf44603          	lbu	a2,-49(s0)
ffffffe000202660:	00000893          	li	a7,0
ffffffe000202664:	00000813          	li	a6,0
ffffffe000202668:	00000793          	li	a5,0
ffffffe00020266c:	00000713          	li	a4,0
ffffffe000202670:	00000693          	li	a3,0
ffffffe000202674:	00200593          	li	a1,2
ffffffe000202678:	44424537          	lui	a0,0x44424
ffffffe00020267c:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000202680:	e4dff0ef          	jal	ffffffe0002024cc <sbi_ecall>
ffffffe000202684:	00050713          	mv	a4,a0
ffffffe000202688:	00058793          	mv	a5,a1
ffffffe00020268c:	fce43823          	sd	a4,-48(s0)
ffffffe000202690:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202694:	fd043703          	ld	a4,-48(s0)
ffffffe000202698:	fd843783          	ld	a5,-40(s0)
ffffffe00020269c:	00070913          	mv	s2,a4
ffffffe0002026a0:	00078993          	mv	s3,a5
ffffffe0002026a4:	00090713          	mv	a4,s2
ffffffe0002026a8:	00098793          	mv	a5,s3
}
ffffffe0002026ac:	00070513          	mv	a0,a4
ffffffe0002026b0:	00078593          	mv	a1,a5
ffffffe0002026b4:	03813083          	ld	ra,56(sp)
ffffffe0002026b8:	03013403          	ld	s0,48(sp)
ffffffe0002026bc:	02813903          	ld	s2,40(sp)
ffffffe0002026c0:	02013983          	ld	s3,32(sp)
ffffffe0002026c4:	04010113          	addi	sp,sp,64
ffffffe0002026c8:	00008067          	ret

ffffffe0002026cc <sbi_debug_console_read>:

// 从终端读入字符
struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
ffffffe0002026cc:	fb010113          	addi	sp,sp,-80
ffffffe0002026d0:	04113423          	sd	ra,72(sp)
ffffffe0002026d4:	04813023          	sd	s0,64(sp)
ffffffe0002026d8:	03213c23          	sd	s2,56(sp)
ffffffe0002026dc:	03313823          	sd	s3,48(sp)
ffffffe0002026e0:	05010413          	addi	s0,sp,80
ffffffe0002026e4:	fca43423          	sd	a0,-56(s0)
ffffffe0002026e8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002026ec:	fac43c23          	sd	a2,-72(s0)
    return sbi_ecall(0x4442434e, 0x1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
ffffffe0002026f0:	00000893          	li	a7,0
ffffffe0002026f4:	00000813          	li	a6,0
ffffffe0002026f8:	00000793          	li	a5,0
ffffffe0002026fc:	fb843703          	ld	a4,-72(s0)
ffffffe000202700:	fc043683          	ld	a3,-64(s0)
ffffffe000202704:	fc843603          	ld	a2,-56(s0)
ffffffe000202708:	00100593          	li	a1,1
ffffffe00020270c:	44424537          	lui	a0,0x44424
ffffffe000202710:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000202714:	db9ff0ef          	jal	ffffffe0002024cc <sbi_ecall>
ffffffe000202718:	00050713          	mv	a4,a0
ffffffe00020271c:	00058793          	mv	a5,a1
ffffffe000202720:	fce43823          	sd	a4,-48(s0)
ffffffe000202724:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202728:	fd043703          	ld	a4,-48(s0)
ffffffe00020272c:	fd843783          	ld	a5,-40(s0)
ffffffe000202730:	00070913          	mv	s2,a4
ffffffe000202734:	00078993          	mv	s3,a5
ffffffe000202738:	00090713          	mv	a4,s2
ffffffe00020273c:	00098793          	mv	a5,s3
}
ffffffe000202740:	00070513          	mv	a0,a4
ffffffe000202744:	00078593          	mv	a1,a5
ffffffe000202748:	04813083          	ld	ra,72(sp)
ffffffe00020274c:	04013403          	ld	s0,64(sp)
ffffffe000202750:	03813903          	ld	s2,56(sp)
ffffffe000202754:	03013983          	ld	s3,48(sp)
ffffffe000202758:	05010113          	addi	sp,sp,80
ffffffe00020275c:	00008067          	ret

ffffffe000202760 <sbi_system_reset>:
// 重置系统（关机或重启）
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000202760:	fc010113          	addi	sp,sp,-64
ffffffe000202764:	02113c23          	sd	ra,56(sp)
ffffffe000202768:	02813823          	sd	s0,48(sp)
ffffffe00020276c:	03213423          	sd	s2,40(sp)
ffffffe000202770:	03313023          	sd	s3,32(sp)
ffffffe000202774:	04010413          	addi	s0,sp,64
ffffffe000202778:	00050793          	mv	a5,a0
ffffffe00020277c:	00058713          	mv	a4,a1
ffffffe000202780:	fcf42623          	sw	a5,-52(s0)
ffffffe000202784:	00070793          	mv	a5,a4
ffffffe000202788:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe00020278c:	fcc46603          	lwu	a2,-52(s0)
ffffffe000202790:	fc846683          	lwu	a3,-56(s0)
ffffffe000202794:	00000893          	li	a7,0
ffffffe000202798:	00000813          	li	a6,0
ffffffe00020279c:	00000793          	li	a5,0
ffffffe0002027a0:	00000713          	li	a4,0
ffffffe0002027a4:	00000593          	li	a1,0
ffffffe0002027a8:	53525537          	lui	a0,0x53525
ffffffe0002027ac:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe0002027b0:	d1dff0ef          	jal	ffffffe0002024cc <sbi_ecall>
ffffffe0002027b4:	00050713          	mv	a4,a0
ffffffe0002027b8:	00058793          	mv	a5,a1
ffffffe0002027bc:	fce43823          	sd	a4,-48(s0)
ffffffe0002027c0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002027c4:	fd043703          	ld	a4,-48(s0)
ffffffe0002027c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002027cc:	00070913          	mv	s2,a4
ffffffe0002027d0:	00078993          	mv	s3,a5
ffffffe0002027d4:	00090713          	mv	a4,s2
ffffffe0002027d8:	00098793          	mv	a5,s3
ffffffe0002027dc:	00070513          	mv	a0,a4
ffffffe0002027e0:	00078593          	mv	a1,a5
ffffffe0002027e4:	03813083          	ld	ra,56(sp)
ffffffe0002027e8:	03013403          	ld	s0,48(sp)
ffffffe0002027ec:	02813903          	ld	s2,40(sp)
ffffffe0002027f0:	02013983          	ld	s3,32(sp)
ffffffe0002027f4:	04010113          	addi	sp,sp,64
ffffffe0002027f8:	00008067          	ret

ffffffe0002027fc <sys_write>:
#define SYS_READ    63
#define SYS_WRITE   64
#define SYS_GETPID  172
#define SYS_CLONE   220

static int64_t sys_write(uint64_t fd, const char *buf, uint64_t len) {
ffffffe0002027fc:	fc010113          	addi	sp,sp,-64
ffffffe000202800:	02113c23          	sd	ra,56(sp)
ffffffe000202804:	02813823          	sd	s0,48(sp)
ffffffe000202808:	04010413          	addi	s0,sp,64
ffffffe00020280c:	fca43c23          	sd	a0,-40(s0)
ffffffe000202810:	fcb43823          	sd	a1,-48(s0)
ffffffe000202814:	fcc43423          	sd	a2,-56(s0)
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
ffffffe000202818:	0040a797          	auipc	a5,0x40a
ffffffe00020281c:	7f878793          	addi	a5,a5,2040 # ffffffe00060d010 <current>
ffffffe000202820:	0007b783          	ld	a5,0(a5)
ffffffe000202824:	0b87b683          	ld	a3,184(a5)
ffffffe000202828:	fd843703          	ld	a4,-40(s0)
ffffffe00020282c:	00070793          	mv	a5,a4
ffffffe000202830:	00479793          	slli	a5,a5,0x4
ffffffe000202834:	00e787b3          	add	a5,a5,a4
ffffffe000202838:	00379793          	slli	a5,a5,0x3
ffffffe00020283c:	00f687b3          	add	a5,a3,a5
ffffffe000202840:	fef43423          	sd	a5,-24(s0)
    if (file->opened == 0) {
ffffffe000202844:	fe843783          	ld	a5,-24(s0)
ffffffe000202848:	0007a783          	lw	a5,0(a5)
ffffffe00020284c:	00079c63          	bnez	a5,ffffffe000202864 <sys_write+0x68>
        printk("file not opened\n");
ffffffe000202850:	00005517          	auipc	a0,0x5
ffffffe000202854:	a2850513          	addi	a0,a0,-1496 # ffffffe000207278 <__func__.0+0x10>
ffffffe000202858:	505010ef          	jal	ffffffe00020455c <printk>
        return ERROR_FILE_NOT_OPEN;
ffffffe00020285c:	0ff00793          	li	a5,255
ffffffe000202860:	0580006f          	j	ffffffe0002028b8 <sys_write+0xbc>
    } else {
        // check perm
        if(!(file->perms & FILE_WRITABLE) || !file->write) {
ffffffe000202864:	fe843783          	ld	a5,-24(s0)
ffffffe000202868:	0047a783          	lw	a5,4(a5)
ffffffe00020286c:	0027f793          	andi	a5,a5,2
ffffffe000202870:	0007879b          	sext.w	a5,a5
ffffffe000202874:	00078863          	beqz	a5,ffffffe000202884 <sys_write+0x88>
ffffffe000202878:	fe843783          	ld	a5,-24(s0)
ffffffe00020287c:	0287b783          	ld	a5,40(a5)
ffffffe000202880:	00079c63          	bnez	a5,ffffffe000202898 <sys_write+0x9c>
            printk("file not writable\n");
ffffffe000202884:	00005517          	auipc	a0,0x5
ffffffe000202888:	a0c50513          	addi	a0,a0,-1524 # ffffffe000207290 <__func__.0+0x28>
ffffffe00020288c:	4d1010ef          	jal	ffffffe00020455c <printk>
            return -1;
ffffffe000202890:	fff00793          	li	a5,-1
ffffffe000202894:	0240006f          	j	ffffffe0002028b8 <sys_write+0xbc>
        }
        // call write function
        ret = file->write(file, buf, len);
ffffffe000202898:	fe843783          	ld	a5,-24(s0)
ffffffe00020289c:	0287b783          	ld	a5,40(a5)
ffffffe0002028a0:	fc843603          	ld	a2,-56(s0)
ffffffe0002028a4:	fd043583          	ld	a1,-48(s0)
ffffffe0002028a8:	fe843503          	ld	a0,-24(s0)
ffffffe0002028ac:	000780e7          	jalr	a5
ffffffe0002028b0:	fea43023          	sd	a0,-32(s0)
    }
    return ret;
ffffffe0002028b4:	fe043783          	ld	a5,-32(s0)
}
ffffffe0002028b8:	00078513          	mv	a0,a5
ffffffe0002028bc:	03813083          	ld	ra,56(sp)
ffffffe0002028c0:	03013403          	ld	s0,48(sp)
ffffffe0002028c4:	04010113          	addi	sp,sp,64
ffffffe0002028c8:	00008067          	ret

ffffffe0002028cc <sys_read>:

static int64_t sys_read(uint64_t fd, char *buf, uint64_t len) {
ffffffe0002028cc:	fc010113          	addi	sp,sp,-64
ffffffe0002028d0:	02113c23          	sd	ra,56(sp)
ffffffe0002028d4:	02813823          	sd	s0,48(sp)
ffffffe0002028d8:	04010413          	addi	s0,sp,64
ffffffe0002028dc:	fca43c23          	sd	a0,-40(s0)
ffffffe0002028e0:	fcb43823          	sd	a1,-48(s0)
ffffffe0002028e4:	fcc43423          	sd	a2,-56(s0)
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
ffffffe0002028e8:	0040a797          	auipc	a5,0x40a
ffffffe0002028ec:	72878793          	addi	a5,a5,1832 # ffffffe00060d010 <current>
ffffffe0002028f0:	0007b783          	ld	a5,0(a5)
ffffffe0002028f4:	0b87b683          	ld	a3,184(a5)
ffffffe0002028f8:	fd843703          	ld	a4,-40(s0)
ffffffe0002028fc:	00070793          	mv	a5,a4
ffffffe000202900:	00479793          	slli	a5,a5,0x4
ffffffe000202904:	00e787b3          	add	a5,a5,a4
ffffffe000202908:	00379793          	slli	a5,a5,0x3
ffffffe00020290c:	00f687b3          	add	a5,a3,a5
ffffffe000202910:	fef43423          	sd	a5,-24(s0)
    // 检查open和perm
    if (file->opened == 0) {
ffffffe000202914:	fe843783          	ld	a5,-24(s0)
ffffffe000202918:	0007a783          	lw	a5,0(a5)
ffffffe00020291c:	00079c63          	bnez	a5,ffffffe000202934 <sys_read+0x68>
        printk("file not opened\n");
ffffffe000202920:	00005517          	auipc	a0,0x5
ffffffe000202924:	95850513          	addi	a0,a0,-1704 # ffffffe000207278 <__func__.0+0x10>
ffffffe000202928:	435010ef          	jal	ffffffe00020455c <printk>
        return ERROR_FILE_NOT_OPEN;
ffffffe00020292c:	0ff00793          	li	a5,255
ffffffe000202930:	0580006f          	j	ffffffe000202988 <sys_read+0xbc>
    } else {
        // check perm
        if(!(file->perms & FILE_READABLE) || !file->read) {
ffffffe000202934:	fe843783          	ld	a5,-24(s0)
ffffffe000202938:	0047a783          	lw	a5,4(a5)
ffffffe00020293c:	0017f793          	andi	a5,a5,1
ffffffe000202940:	0007879b          	sext.w	a5,a5
ffffffe000202944:	00078863          	beqz	a5,ffffffe000202954 <sys_read+0x88>
ffffffe000202948:	fe843783          	ld	a5,-24(s0)
ffffffe00020294c:	0307b783          	ld	a5,48(a5)
ffffffe000202950:	00079c63          	bnez	a5,ffffffe000202968 <sys_read+0x9c>
            printk("file not readable\n");
ffffffe000202954:	00005517          	auipc	a0,0x5
ffffffe000202958:	95450513          	addi	a0,a0,-1708 # ffffffe0002072a8 <__func__.0+0x40>
ffffffe00020295c:	401010ef          	jal	ffffffe00020455c <printk>
            return -1;
ffffffe000202960:	fff00793          	li	a5,-1
ffffffe000202964:	0240006f          	j	ffffffe000202988 <sys_read+0xbc>
        }
        // call read function
        ret = file->read(file, buf, len);
ffffffe000202968:	fe843783          	ld	a5,-24(s0)
ffffffe00020296c:	0307b783          	ld	a5,48(a5)
ffffffe000202970:	fc843603          	ld	a2,-56(s0)
ffffffe000202974:	fd043583          	ld	a1,-48(s0)
ffffffe000202978:	fe843503          	ld	a0,-24(s0)
ffffffe00020297c:	000780e7          	jalr	a5
ffffffe000202980:	fea43023          	sd	a0,-32(s0)
    }
    return ret;
ffffffe000202984:	fe043783          	ld	a5,-32(s0)
}
ffffffe000202988:	00078513          	mv	a0,a5
ffffffe00020298c:	03813083          	ld	ra,56(sp)
ffffffe000202990:	03013403          	ld	s0,48(sp)
ffffffe000202994:	04010113          	addi	sp,sp,64
ffffffe000202998:	00008067          	ret

ffffffe00020299c <sys_lseek>:

static int64_t sys_lseek(uint64_t fd, uint64_t offset, uint64_t whence) {
ffffffe00020299c:	fc010113          	addi	sp,sp,-64
ffffffe0002029a0:	02113c23          	sd	ra,56(sp)
ffffffe0002029a4:	02813823          	sd	s0,48(sp)
ffffffe0002029a8:	04010413          	addi	s0,sp,64
ffffffe0002029ac:	fca43c23          	sd	a0,-40(s0)
ffffffe0002029b0:	fcb43823          	sd	a1,-48(s0)
ffffffe0002029b4:	fcc43423          	sd	a2,-56(s0)
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
ffffffe0002029b8:	0040a797          	auipc	a5,0x40a
ffffffe0002029bc:	65878793          	addi	a5,a5,1624 # ffffffe00060d010 <current>
ffffffe0002029c0:	0007b783          	ld	a5,0(a5)
ffffffe0002029c4:	0b87b683          	ld	a3,184(a5)
ffffffe0002029c8:	fd843703          	ld	a4,-40(s0)
ffffffe0002029cc:	00070793          	mv	a5,a4
ffffffe0002029d0:	00479793          	slli	a5,a5,0x4
ffffffe0002029d4:	00e787b3          	add	a5,a5,a4
ffffffe0002029d8:	00379793          	slli	a5,a5,0x3
ffffffe0002029dc:	00f687b3          	add	a5,a3,a5
ffffffe0002029e0:	fef43423          	sd	a5,-24(s0)
    // 检查open和perm
    if (file->opened == 0) {
ffffffe0002029e4:	fe843783          	ld	a5,-24(s0)
ffffffe0002029e8:	0007a783          	lw	a5,0(a5)
ffffffe0002029ec:	00079c63          	bnez	a5,ffffffe000202a04 <sys_lseek+0x68>
        printk("file not opened\n");
ffffffe0002029f0:	00005517          	auipc	a0,0x5
ffffffe0002029f4:	88850513          	addi	a0,a0,-1912 # ffffffe000207278 <__func__.0+0x10>
ffffffe0002029f8:	365010ef          	jal	ffffffe00020455c <printk>
        return ERROR_FILE_NOT_OPEN;
ffffffe0002029fc:	0ff00793          	li	a5,255
ffffffe000202a00:	0480006f          	j	ffffffe000202a48 <sys_lseek+0xac>
    } else {
        // check perm
        if(!file->lseek) {
ffffffe000202a04:	fe843783          	ld	a5,-24(s0)
ffffffe000202a08:	0207b783          	ld	a5,32(a5)
ffffffe000202a0c:	00079c63          	bnez	a5,ffffffe000202a24 <sys_lseek+0x88>
            printk("file not readable\n");
ffffffe000202a10:	00005517          	auipc	a0,0x5
ffffffe000202a14:	89850513          	addi	a0,a0,-1896 # ffffffe0002072a8 <__func__.0+0x40>
ffffffe000202a18:	345010ef          	jal	ffffffe00020455c <printk>
            return -1;
ffffffe000202a1c:	fff00793          	li	a5,-1
ffffffe000202a20:	0280006f          	j	ffffffe000202a48 <sys_lseek+0xac>
        }
        ret = file->lseek(file, offset, whence);
ffffffe000202a24:	fe843783          	ld	a5,-24(s0)
ffffffe000202a28:	0207b783          	ld	a5,32(a5)
ffffffe000202a2c:	fd043703          	ld	a4,-48(s0)
ffffffe000202a30:	fc843603          	ld	a2,-56(s0)
ffffffe000202a34:	00070593          	mv	a1,a4
ffffffe000202a38:	fe843503          	ld	a0,-24(s0)
ffffffe000202a3c:	000780e7          	jalr	a5
ffffffe000202a40:	fea43023          	sd	a0,-32(s0)
    }
    return ret;
ffffffe000202a44:	fe043783          	ld	a5,-32(s0)
}
ffffffe000202a48:	00078513          	mv	a0,a5
ffffffe000202a4c:	03813083          	ld	ra,56(sp)
ffffffe000202a50:	03013403          	ld	s0,48(sp)
ffffffe000202a54:	04010113          	addi	sp,sp,64
ffffffe000202a58:	00008067          	ret

ffffffe000202a5c <sys_close>:

static int64_t sys_close(uint64_t fd) {
ffffffe000202a5c:	fe010113          	addi	sp,sp,-32
ffffffe000202a60:	00813c23          	sd	s0,24(sp)
ffffffe000202a64:	02010413          	addi	s0,sp,32
ffffffe000202a68:	fea43423          	sd	a0,-24(s0)
    // 关闭对应文件
    current->files->fd_array[fd].opened = 0;
ffffffe000202a6c:	0040a797          	auipc	a5,0x40a
ffffffe000202a70:	5a478793          	addi	a5,a5,1444 # ffffffe00060d010 <current>
ffffffe000202a74:	0007b783          	ld	a5,0(a5)
ffffffe000202a78:	0b87b683          	ld	a3,184(a5)
ffffffe000202a7c:	fe843703          	ld	a4,-24(s0)
ffffffe000202a80:	00070793          	mv	a5,a4
ffffffe000202a84:	00479793          	slli	a5,a5,0x4
ffffffe000202a88:	00e787b3          	add	a5,a5,a4
ffffffe000202a8c:	00379793          	slli	a5,a5,0x3
ffffffe000202a90:	00f687b3          	add	a5,a3,a5
ffffffe000202a94:	0007a023          	sw	zero,0(a5)
    return 0;
ffffffe000202a98:	00000793          	li	a5,0
}
ffffffe000202a9c:	00078513          	mv	a0,a5
ffffffe000202aa0:	01813403          	ld	s0,24(sp)
ffffffe000202aa4:	02010113          	addi	sp,sp,32
ffffffe000202aa8:	00008067          	ret

ffffffe000202aac <sys_openat>:

static int64_t sys_openat(const char *path, int flags) {
ffffffe000202aac:	fd010113          	addi	sp,sp,-48
ffffffe000202ab0:	02113423          	sd	ra,40(sp)
ffffffe000202ab4:	02813023          	sd	s0,32(sp)
ffffffe000202ab8:	03010413          	addi	s0,sp,48
ffffffe000202abc:	fca43c23          	sd	a0,-40(s0)
ffffffe000202ac0:	00058793          	mv	a5,a1
ffffffe000202ac4:	fcf42a23          	sw	a5,-44(s0)
    // 打开对应地址的文件
    // 寻找第一个空闲的文件描述符
    for (int i = 0; i < MAX_FILE_NUMBER; i++) {
ffffffe000202ac8:	fe042623          	sw	zero,-20(s0)
ffffffe000202acc:	0940006f          	j	ffffffe000202b60 <sys_openat+0xb4>
        if (!current->files->fd_array[i].opened) {
ffffffe000202ad0:	0040a797          	auipc	a5,0x40a
ffffffe000202ad4:	54078793          	addi	a5,a5,1344 # ffffffe00060d010 <current>
ffffffe000202ad8:	0007b783          	ld	a5,0(a5)
ffffffe000202adc:	0b87b683          	ld	a3,184(a5)
ffffffe000202ae0:	fec42703          	lw	a4,-20(s0)
ffffffe000202ae4:	00070793          	mv	a5,a4
ffffffe000202ae8:	00479793          	slli	a5,a5,0x4
ffffffe000202aec:	00e787b3          	add	a5,a5,a4
ffffffe000202af0:	00379793          	slli	a5,a5,0x3
ffffffe000202af4:	00f687b3          	add	a5,a3,a5
ffffffe000202af8:	0007a783          	lw	a5,0(a5)
ffffffe000202afc:	04079c63          	bnez	a5,ffffffe000202b54 <sys_openat+0xa8>
            return file_open(&(current->files->fd_array[i]), path, flags) == 0 ? i : -1;
ffffffe000202b00:	0040a797          	auipc	a5,0x40a
ffffffe000202b04:	51078793          	addi	a5,a5,1296 # ffffffe00060d010 <current>
ffffffe000202b08:	0007b783          	ld	a5,0(a5)
ffffffe000202b0c:	0b87b683          	ld	a3,184(a5)
ffffffe000202b10:	fec42703          	lw	a4,-20(s0)
ffffffe000202b14:	00070793          	mv	a5,a4
ffffffe000202b18:	00479793          	slli	a5,a5,0x4
ffffffe000202b1c:	00e787b3          	add	a5,a5,a4
ffffffe000202b20:	00379793          	slli	a5,a5,0x3
ffffffe000202b24:	00f687b3          	add	a5,a3,a5
ffffffe000202b28:	fd442703          	lw	a4,-44(s0)
ffffffe000202b2c:	00070613          	mv	a2,a4
ffffffe000202b30:	fd843583          	ld	a1,-40(s0)
ffffffe000202b34:	00078513          	mv	a0,a5
ffffffe000202b38:	34d020ef          	jal	ffffffe000205684 <file_open>
ffffffe000202b3c:	00050793          	mv	a5,a0
ffffffe000202b40:	00079663          	bnez	a5,ffffffe000202b4c <sys_openat+0xa0>
ffffffe000202b44:	fec42783          	lw	a5,-20(s0)
ffffffe000202b48:	02c0006f          	j	ffffffe000202b74 <sys_openat+0xc8>
ffffffe000202b4c:	fff00793          	li	a5,-1
ffffffe000202b50:	0240006f          	j	ffffffe000202b74 <sys_openat+0xc8>
    for (int i = 0; i < MAX_FILE_NUMBER; i++) {
ffffffe000202b54:	fec42783          	lw	a5,-20(s0)
ffffffe000202b58:	0017879b          	addiw	a5,a5,1
ffffffe000202b5c:	fef42623          	sw	a5,-20(s0)
ffffffe000202b60:	fec42783          	lw	a5,-20(s0)
ffffffe000202b64:	0007871b          	sext.w	a4,a5
ffffffe000202b68:	00f00793          	li	a5,15
ffffffe000202b6c:	f6e7d2e3          	bge	a5,a4,ffffffe000202ad0 <sys_openat+0x24>
        }
    }
    // 无可用的描述符，返回-1表示打开失败
    return -1;
ffffffe000202b70:	fff00793          	li	a5,-1
}
ffffffe000202b74:	00078513          	mv	a0,a5
ffffffe000202b78:	02813083          	ld	ra,40(sp)
ffffffe000202b7c:	02013403          	ld	s0,32(sp)
ffffffe000202b80:	03010113          	addi	sp,sp,48
ffffffe000202b84:	00008067          	ret

ffffffe000202b88 <syscall>:

void syscall(struct pt_regs *regs) {
ffffffe000202b88:	fe010113          	addi	sp,sp,-32
ffffffe000202b8c:	00113c23          	sd	ra,24(sp)
ffffffe000202b90:	00813823          	sd	s0,16(sp)
ffffffe000202b94:	02010413          	addi	s0,sp,32
ffffffe000202b98:	fea43423          	sd	a0,-24(s0)
    //     // fork
    //     regs->regs_32[10] = do_fork(regs);
    // } else {
    //     Err("not support syscall id = %d\n", regs->regs_32[17]);
    // }
    switch (regs->regs_32[17]) {
ffffffe000202b9c:	fe843783          	ld	a5,-24(s0)
ffffffe000202ba0:	0887b783          	ld	a5,136(a5)
ffffffe000202ba4:	0dc00713          	li	a4,220
ffffffe000202ba8:	18e78863          	beq	a5,a4,ffffffe000202d38 <syscall+0x1b0>
ffffffe000202bac:	0dc00713          	li	a4,220
ffffffe000202bb0:	1af76063          	bltu	a4,a5,ffffffe000202d50 <syscall+0x1c8>
ffffffe000202bb4:	04000713          	li	a4,64
ffffffe000202bb8:	04f76063          	bltu	a4,a5,ffffffe000202bf8 <syscall+0x70>
ffffffe000202bbc:	03800713          	li	a4,56
ffffffe000202bc0:	18e7e863          	bltu	a5,a4,ffffffe000202d50 <syscall+0x1c8>
ffffffe000202bc4:	fc878793          	addi	a5,a5,-56
ffffffe000202bc8:	00800713          	li	a4,8
ffffffe000202bcc:	18f76263          	bltu	a4,a5,ffffffe000202d50 <syscall+0x1c8>
ffffffe000202bd0:	00279713          	slli	a4,a5,0x2
ffffffe000202bd4:	00004797          	auipc	a5,0x4
ffffffe000202bd8:	73078793          	addi	a5,a5,1840 # ffffffe000207304 <__func__.0+0x9c>
ffffffe000202bdc:	00f707b3          	add	a5,a4,a5
ffffffe000202be0:	0007a783          	lw	a5,0(a5)
ffffffe000202be4:	0007871b          	sext.w	a4,a5
ffffffe000202be8:	00004797          	auipc	a5,0x4
ffffffe000202bec:	71c78793          	addi	a5,a5,1820 # ffffffe000207304 <__func__.0+0x9c>
ffffffe000202bf0:	00f707b3          	add	a5,a4,a5
ffffffe000202bf4:	00078067          	jr	a5
ffffffe000202bf8:	0ac00713          	li	a4,172
ffffffe000202bfc:	12e78063          	beq	a5,a4,ffffffe000202d1c <syscall+0x194>
ffffffe000202c00:	1500006f          	j	ffffffe000202d50 <syscall+0x1c8>
        case SYS_WRITE:
            regs->regs_32[10] = sys_write(regs->regs_32[10], (char*)regs->regs_32[11], regs->regs_32[12]);
ffffffe000202c04:	fe843783          	ld	a5,-24(s0)
ffffffe000202c08:	0507b703          	ld	a4,80(a5)
ffffffe000202c0c:	fe843783          	ld	a5,-24(s0)
ffffffe000202c10:	0587b783          	ld	a5,88(a5)
ffffffe000202c14:	00078693          	mv	a3,a5
ffffffe000202c18:	fe843783          	ld	a5,-24(s0)
ffffffe000202c1c:	0607b783          	ld	a5,96(a5)
ffffffe000202c20:	00078613          	mv	a2,a5
ffffffe000202c24:	00068593          	mv	a1,a3
ffffffe000202c28:	00070513          	mv	a0,a4
ffffffe000202c2c:	bd1ff0ef          	jal	ffffffe0002027fc <sys_write>
ffffffe000202c30:	00050793          	mv	a5,a0
ffffffe000202c34:	00078713          	mv	a4,a5
ffffffe000202c38:	fe843783          	ld	a5,-24(s0)
ffffffe000202c3c:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202c40:	1440006f          	j	ffffffe000202d84 <syscall+0x1fc>
        case SYS_READ:
            regs->regs_32[10] = sys_read(regs->regs_32[10], (char*)regs->regs_32[11], regs->regs_32[12]);
ffffffe000202c44:	fe843783          	ld	a5,-24(s0)
ffffffe000202c48:	0507b703          	ld	a4,80(a5)
ffffffe000202c4c:	fe843783          	ld	a5,-24(s0)
ffffffe000202c50:	0587b783          	ld	a5,88(a5)
ffffffe000202c54:	00078693          	mv	a3,a5
ffffffe000202c58:	fe843783          	ld	a5,-24(s0)
ffffffe000202c5c:	0607b783          	ld	a5,96(a5)
ffffffe000202c60:	00078613          	mv	a2,a5
ffffffe000202c64:	00068593          	mv	a1,a3
ffffffe000202c68:	00070513          	mv	a0,a4
ffffffe000202c6c:	c61ff0ef          	jal	ffffffe0002028cc <sys_read>
ffffffe000202c70:	00050793          	mv	a5,a0
ffffffe000202c74:	00078713          	mv	a4,a5
ffffffe000202c78:	fe843783          	ld	a5,-24(s0)
ffffffe000202c7c:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202c80:	1040006f          	j	ffffffe000202d84 <syscall+0x1fc>
        case SYS_LSEEK:
            regs->regs_32[10] = sys_lseek(regs->regs_32[10], regs->regs_32[11], regs->regs_32[12]);
ffffffe000202c84:	fe843783          	ld	a5,-24(s0)
ffffffe000202c88:	0507b703          	ld	a4,80(a5)
ffffffe000202c8c:	fe843783          	ld	a5,-24(s0)
ffffffe000202c90:	0587b683          	ld	a3,88(a5)
ffffffe000202c94:	fe843783          	ld	a5,-24(s0)
ffffffe000202c98:	0607b783          	ld	a5,96(a5)
ffffffe000202c9c:	00078613          	mv	a2,a5
ffffffe000202ca0:	00068593          	mv	a1,a3
ffffffe000202ca4:	00070513          	mv	a0,a4
ffffffe000202ca8:	cf5ff0ef          	jal	ffffffe00020299c <sys_lseek>
ffffffe000202cac:	00050793          	mv	a5,a0
ffffffe000202cb0:	00078713          	mv	a4,a5
ffffffe000202cb4:	fe843783          	ld	a5,-24(s0)
ffffffe000202cb8:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202cbc:	0c80006f          	j	ffffffe000202d84 <syscall+0x1fc>
        case SYS_CLOSE:
            regs->regs_32[10] = sys_close(regs->regs_32[10]);
ffffffe000202cc0:	fe843783          	ld	a5,-24(s0)
ffffffe000202cc4:	0507b783          	ld	a5,80(a5)
ffffffe000202cc8:	00078513          	mv	a0,a5
ffffffe000202ccc:	d91ff0ef          	jal	ffffffe000202a5c <sys_close>
ffffffe000202cd0:	00050793          	mv	a5,a0
ffffffe000202cd4:	00078713          	mv	a4,a5
ffffffe000202cd8:	fe843783          	ld	a5,-24(s0)
ffffffe000202cdc:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202ce0:	0a40006f          	j	ffffffe000202d84 <syscall+0x1fc>
        case SYS_OPENAT:
            regs->regs_32[10] = sys_openat((char*)regs->regs_32[11], regs->regs_32[12]);
ffffffe000202ce4:	fe843783          	ld	a5,-24(s0)
ffffffe000202ce8:	0587b783          	ld	a5,88(a5)
ffffffe000202cec:	00078713          	mv	a4,a5
ffffffe000202cf0:	fe843783          	ld	a5,-24(s0)
ffffffe000202cf4:	0607b783          	ld	a5,96(a5)
ffffffe000202cf8:	0007879b          	sext.w	a5,a5
ffffffe000202cfc:	00078593          	mv	a1,a5
ffffffe000202d00:	00070513          	mv	a0,a4
ffffffe000202d04:	da9ff0ef          	jal	ffffffe000202aac <sys_openat>
ffffffe000202d08:	00050793          	mv	a5,a0
ffffffe000202d0c:	00078713          	mv	a4,a5
ffffffe000202d10:	fe843783          	ld	a5,-24(s0)
ffffffe000202d14:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202d18:	06c0006f          	j	ffffffe000202d84 <syscall+0x1fc>
        case SYS_GETPID:
            regs->regs_32[10] = current->pid;
ffffffe000202d1c:	0040a797          	auipc	a5,0x40a
ffffffe000202d20:	2f478793          	addi	a5,a5,756 # ffffffe00060d010 <current>
ffffffe000202d24:	0007b783          	ld	a5,0(a5)
ffffffe000202d28:	0187b703          	ld	a4,24(a5)
ffffffe000202d2c:	fe843783          	ld	a5,-24(s0)
ffffffe000202d30:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202d34:	0500006f          	j	ffffffe000202d84 <syscall+0x1fc>
        case SYS_CLONE:
            regs->regs_32[10] = do_fork(regs);
ffffffe000202d38:	fe843503          	ld	a0,-24(s0)
ffffffe000202d3c:	a34ff0ef          	jal	ffffffe000201f70 <do_fork>
ffffffe000202d40:	00050713          	mv	a4,a0
ffffffe000202d44:	fe843783          	ld	a5,-24(s0)
ffffffe000202d48:	04e7b823          	sd	a4,80(a5)
            break;
ffffffe000202d4c:	0380006f          	j	ffffffe000202d84 <syscall+0x1fc>
        default:
            Err("not support syscall id = %d\n", regs->regs_32[17]);
ffffffe000202d50:	fe843783          	ld	a5,-24(s0)
ffffffe000202d54:	0887b783          	ld	a5,136(a5)
ffffffe000202d58:	00078713          	mv	a4,a5
ffffffe000202d5c:	00004697          	auipc	a3,0x4
ffffffe000202d60:	2a468693          	addi	a3,a3,676 # ffffffe000207000 <__func__.0>
ffffffe000202d64:	08800613          	li	a2,136
ffffffe000202d68:	00004597          	auipc	a1,0x4
ffffffe000202d6c:	55858593          	addi	a1,a1,1368 # ffffffe0002072c0 <__func__.0+0x58>
ffffffe000202d70:	00004517          	auipc	a0,0x4
ffffffe000202d74:	56050513          	addi	a0,a0,1376 # ffffffe0002072d0 <__func__.0+0x68>
ffffffe000202d78:	7e4010ef          	jal	ffffffe00020455c <printk>
ffffffe000202d7c:	00000013          	nop
ffffffe000202d80:	ffdff06f          	j	ffffffe000202d7c <syscall+0x1f4>
    }
    // 手动返回地址+4
    regs->sepc += (uint64_t)4;
ffffffe000202d84:	fe843783          	ld	a5,-24(s0)
ffffffe000202d88:	1007b783          	ld	a5,256(a5)
ffffffe000202d8c:	00478713          	addi	a4,a5,4
ffffffe000202d90:	fe843783          	ld	a5,-24(s0)
ffffffe000202d94:	10e7b023          	sd	a4,256(a5)
ffffffe000202d98:	00000013          	nop
ffffffe000202d9c:	01813083          	ld	ra,24(sp)
ffffffe000202da0:	01013403          	ld	s0,16(sp)
ffffffe000202da4:	02010113          	addi	sp,sp,32
ffffffe000202da8:	00008067          	ret

ffffffe000202dac <trap_handler>:
#include "printk.h"

extern struct task_struct* current;


void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
ffffffe000202dac:	fc010113          	addi	sp,sp,-64
ffffffe000202db0:	02113c23          	sd	ra,56(sp)
ffffffe000202db4:	02813823          	sd	s0,48(sp)
ffffffe000202db8:	04010413          	addi	s0,sp,64
ffffffe000202dbc:	fca43c23          	sd	a0,-40(s0)
ffffffe000202dc0:	fcb43823          	sd	a1,-48(s0)
ffffffe000202dc4:	fcc43423          	sd	a2,-56(s0)
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    // 参考: 63为interrupt, 0~62为code
    uint64_t code = scause & 0x7FFFFFFFFFFFFFFF;
ffffffe000202dc8:	fd843703          	ld	a4,-40(s0)
ffffffe000202dcc:	fff00793          	li	a5,-1
ffffffe000202dd0:	0017d793          	srli	a5,a5,0x1
ffffffe000202dd4:	00f777b3          	and	a5,a4,a5
ffffffe000202dd8:	fef43423          	sd	a5,-24(s0)
    if (scause & 1ULL << 63) { // interrupt
ffffffe000202ddc:	fd843783          	ld	a5,-40(s0)
ffffffe000202de0:	0807d463          	bgez	a5,ffffffe000202e68 <trap_handler+0xbc>
        // 打印调试信息
        if (code == 1) {
ffffffe000202de4:	fe843703          	ld	a4,-24(s0)
ffffffe000202de8:	00100793          	li	a5,1
ffffffe000202dec:	00f71a63          	bne	a4,a5,ffffffe000202e00 <trap_handler+0x54>
            printk("[S] Supervisor Software Interrupt\n");
ffffffe000202df0:	00004517          	auipc	a0,0x4
ffffffe000202df4:	53850513          	addi	a0,a0,1336 # ffffffe000207328 <__func__.0+0xc0>
ffffffe000202df8:	764010ef          	jal	ffffffe00020455c <printk>
ffffffe000202dfc:	0540006f          	j	ffffffe000202e50 <trap_handler+0xa4>
        }
        else if (code == 5) {
ffffffe000202e00:	fe843703          	ld	a4,-24(s0)
ffffffe000202e04:	00500793          	li	a5,5
ffffffe000202e08:	04f70463          	beq	a4,a5,ffffffe000202e50 <trap_handler+0xa4>
            // printk("[S] Supervisor Timer Interrupt\n");
        }
        else if (code == 9) {
ffffffe000202e0c:	fe843703          	ld	a4,-24(s0)
ffffffe000202e10:	00900793          	li	a5,9
ffffffe000202e14:	00f71a63          	bne	a4,a5,ffffffe000202e28 <trap_handler+0x7c>
            printk("[S] Supervisor External Interrupt\n");
ffffffe000202e18:	00004517          	auipc	a0,0x4
ffffffe000202e1c:	53850513          	addi	a0,a0,1336 # ffffffe000207350 <__func__.0+0xe8>
ffffffe000202e20:	73c010ef          	jal	ffffffe00020455c <printk>
ffffffe000202e24:	02c0006f          	j	ffffffe000202e50 <trap_handler+0xa4>
        }
        else if (code == 13) {
ffffffe000202e28:	fe843703          	ld	a4,-24(s0)
ffffffe000202e2c:	00d00793          	li	a5,13
ffffffe000202e30:	00f71a63          	bne	a4,a5,ffffffe000202e44 <trap_handler+0x98>
            printk("Counter-overflow Interrupt\n");
ffffffe000202e34:	00004517          	auipc	a0,0x4
ffffffe000202e38:	54450513          	addi	a0,a0,1348 # ffffffe000207378 <__func__.0+0x110>
ffffffe000202e3c:	720010ef          	jal	ffffffe00020455c <printk>
ffffffe000202e40:	0100006f          	j	ffffffe000202e50 <trap_handler+0xa4>
        }
        else {
            printk("Reserved or Designed for Platform Use\n");
ffffffe000202e44:	00004517          	auipc	a0,0x4
ffffffe000202e48:	55450513          	addi	a0,a0,1364 # ffffffe000207398 <__func__.0+0x130>
ffffffe000202e4c:	710010ef          	jal	ffffffe00020455c <printk>
        }

        // 设置下一次时钟中断
        if (code == 5) { // timer interrupt
ffffffe000202e50:	fe843703          	ld	a4,-24(s0)
ffffffe000202e54:	00500793          	li	a5,5
ffffffe000202e58:	22f71863          	bne	a4,a5,ffffffe000203088 <trap_handler+0x2dc>
            clock_set_next_event();
ffffffe000202e5c:	c7cfd0ef          	jal	ffffffe0002002d8 <clock_set_next_event>
            do_timer();
ffffffe000202e60:	a51fe0ef          	jal	ffffffe0002018b0 <do_timer>
                break;
            }
            default: Err("Unknown exception\n"); break;
        }
    }
ffffffe000202e64:	2240006f          	j	ffffffe000203088 <trap_handler+0x2dc>
        switch(code) {
ffffffe000202e68:	fe843703          	ld	a4,-24(s0)
ffffffe000202e6c:	00f00793          	li	a5,15
ffffffe000202e70:	1ee7e863          	bltu	a5,a4,ffffffe000203060 <trap_handler+0x2b4>
ffffffe000202e74:	fe843783          	ld	a5,-24(s0)
ffffffe000202e78:	00279713          	slli	a4,a5,0x2
ffffffe000202e7c:	00004797          	auipc	a5,0x4
ffffffe000202e80:	77878793          	addi	a5,a5,1912 # ffffffe0002075f4 <__func__.0+0x38c>
ffffffe000202e84:	00f707b3          	add	a5,a4,a5
ffffffe000202e88:	0007a783          	lw	a5,0(a5)
ffffffe000202e8c:	0007871b          	sext.w	a4,a5
ffffffe000202e90:	00004797          	auipc	a5,0x4
ffffffe000202e94:	76478793          	addi	a5,a5,1892 # ffffffe0002075f4 <__func__.0+0x38c>
ffffffe000202e98:	00f707b3          	add	a5,a4,a5
ffffffe000202e9c:	00078067          	jr	a5
            case 0: Err("Instruction address misaligned\n"); break;
ffffffe000202ea0:	00004697          	auipc	a3,0x4
ffffffe000202ea4:	79868693          	addi	a3,a3,1944 # ffffffe000207638 <__func__.0>
ffffffe000202ea8:	02d00613          	li	a2,45
ffffffe000202eac:	00004597          	auipc	a1,0x4
ffffffe000202eb0:	51458593          	addi	a1,a1,1300 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202eb4:	00004517          	auipc	a0,0x4
ffffffe000202eb8:	51450513          	addi	a0,a0,1300 # ffffffe0002073c8 <__func__.0+0x160>
ffffffe000202ebc:	6a0010ef          	jal	ffffffe00020455c <printk>
ffffffe000202ec0:	00000013          	nop
ffffffe000202ec4:	ffdff06f          	j	ffffffe000202ec0 <trap_handler+0x114>
            case 1: Err("Instruction access fault\n"); break;
ffffffe000202ec8:	00004697          	auipc	a3,0x4
ffffffe000202ecc:	77068693          	addi	a3,a3,1904 # ffffffe000207638 <__func__.0>
ffffffe000202ed0:	02e00613          	li	a2,46
ffffffe000202ed4:	00004597          	auipc	a1,0x4
ffffffe000202ed8:	4ec58593          	addi	a1,a1,1260 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202edc:	00004517          	auipc	a0,0x4
ffffffe000202ee0:	52450513          	addi	a0,a0,1316 # ffffffe000207400 <__func__.0+0x198>
ffffffe000202ee4:	678010ef          	jal	ffffffe00020455c <printk>
ffffffe000202ee8:	00000013          	nop
ffffffe000202eec:	ffdff06f          	j	ffffffe000202ee8 <trap_handler+0x13c>
            case 2: Err("Illegal instruction\n"); break;
ffffffe000202ef0:	00004697          	auipc	a3,0x4
ffffffe000202ef4:	74868693          	addi	a3,a3,1864 # ffffffe000207638 <__func__.0>
ffffffe000202ef8:	02f00613          	li	a2,47
ffffffe000202efc:	00004597          	auipc	a1,0x4
ffffffe000202f00:	4c458593          	addi	a1,a1,1220 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202f04:	00004517          	auipc	a0,0x4
ffffffe000202f08:	53450513          	addi	a0,a0,1332 # ffffffe000207438 <__func__.0+0x1d0>
ffffffe000202f0c:	650010ef          	jal	ffffffe00020455c <printk>
ffffffe000202f10:	00000013          	nop
ffffffe000202f14:	ffdff06f          	j	ffffffe000202f10 <trap_handler+0x164>
            case 3: Err("Breakpoint\n"); break;
ffffffe000202f18:	00004697          	auipc	a3,0x4
ffffffe000202f1c:	72068693          	addi	a3,a3,1824 # ffffffe000207638 <__func__.0>
ffffffe000202f20:	03000613          	li	a2,48
ffffffe000202f24:	00004597          	auipc	a1,0x4
ffffffe000202f28:	49c58593          	addi	a1,a1,1180 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202f2c:	00004517          	auipc	a0,0x4
ffffffe000202f30:	53c50513          	addi	a0,a0,1340 # ffffffe000207468 <__func__.0+0x200>
ffffffe000202f34:	628010ef          	jal	ffffffe00020455c <printk>
ffffffe000202f38:	00000013          	nop
ffffffe000202f3c:	ffdff06f          	j	ffffffe000202f38 <trap_handler+0x18c>
            case 4: Err("Load address misaligned\n"); break;
ffffffe000202f40:	00004697          	auipc	a3,0x4
ffffffe000202f44:	6f868693          	addi	a3,a3,1784 # ffffffe000207638 <__func__.0>
ffffffe000202f48:	03100613          	li	a2,49
ffffffe000202f4c:	00004597          	auipc	a1,0x4
ffffffe000202f50:	47458593          	addi	a1,a1,1140 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202f54:	00004517          	auipc	a0,0x4
ffffffe000202f58:	53c50513          	addi	a0,a0,1340 # ffffffe000207490 <__func__.0+0x228>
ffffffe000202f5c:	600010ef          	jal	ffffffe00020455c <printk>
ffffffe000202f60:	00000013          	nop
ffffffe000202f64:	ffdff06f          	j	ffffffe000202f60 <trap_handler+0x1b4>
            case 5: Err("Load access fault\n"); break;
ffffffe000202f68:	00004697          	auipc	a3,0x4
ffffffe000202f6c:	6d068693          	addi	a3,a3,1744 # ffffffe000207638 <__func__.0>
ffffffe000202f70:	03200613          	li	a2,50
ffffffe000202f74:	00004597          	auipc	a1,0x4
ffffffe000202f78:	44c58593          	addi	a1,a1,1100 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202f7c:	00004517          	auipc	a0,0x4
ffffffe000202f80:	54450513          	addi	a0,a0,1348 # ffffffe0002074c0 <__func__.0+0x258>
ffffffe000202f84:	5d8010ef          	jal	ffffffe00020455c <printk>
ffffffe000202f88:	00000013          	nop
ffffffe000202f8c:	ffdff06f          	j	ffffffe000202f88 <trap_handler+0x1dc>
            case 6: Err("Store/AMO address misaligned\n"); break;
ffffffe000202f90:	00004697          	auipc	a3,0x4
ffffffe000202f94:	6a868693          	addi	a3,a3,1704 # ffffffe000207638 <__func__.0>
ffffffe000202f98:	03300613          	li	a2,51
ffffffe000202f9c:	00004597          	auipc	a1,0x4
ffffffe000202fa0:	42458593          	addi	a1,a1,1060 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202fa4:	00004517          	auipc	a0,0x4
ffffffe000202fa8:	54c50513          	addi	a0,a0,1356 # ffffffe0002074f0 <__func__.0+0x288>
ffffffe000202fac:	5b0010ef          	jal	ffffffe00020455c <printk>
ffffffe000202fb0:	00000013          	nop
ffffffe000202fb4:	ffdff06f          	j	ffffffe000202fb0 <trap_handler+0x204>
            case 7: Err("Store/AMO access fault\n"); break;
ffffffe000202fb8:	00004697          	auipc	a3,0x4
ffffffe000202fbc:	68068693          	addi	a3,a3,1664 # ffffffe000207638 <__func__.0>
ffffffe000202fc0:	03400613          	li	a2,52
ffffffe000202fc4:	00004597          	auipc	a1,0x4
ffffffe000202fc8:	3fc58593          	addi	a1,a1,1020 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000202fcc:	00004517          	auipc	a0,0x4
ffffffe000202fd0:	55c50513          	addi	a0,a0,1372 # ffffffe000207528 <__func__.0+0x2c0>
ffffffe000202fd4:	588010ef          	jal	ffffffe00020455c <printk>
ffffffe000202fd8:	00000013          	nop
ffffffe000202fdc:	ffdff06f          	j	ffffffe000202fd8 <trap_handler+0x22c>
                syscall(regs);
ffffffe000202fe0:	fc843503          	ld	a0,-56(s0)
ffffffe000202fe4:	ba5ff0ef          	jal	ffffffe000202b88 <syscall>
                break;
ffffffe000202fe8:	0a00006f          	j	ffffffe000203088 <trap_handler+0x2dc>
            case 9: Err("Environment call from S-mode\n"); break;
ffffffe000202fec:	00004697          	auipc	a3,0x4
ffffffe000202ff0:	64c68693          	addi	a3,a3,1612 # ffffffe000207638 <__func__.0>
ffffffe000202ff4:	03b00613          	li	a2,59
ffffffe000202ff8:	00004597          	auipc	a1,0x4
ffffffe000202ffc:	3c858593          	addi	a1,a1,968 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000203000:	00004517          	auipc	a0,0x4
ffffffe000203004:	55850513          	addi	a0,a0,1368 # ffffffe000207558 <__func__.0+0x2f0>
ffffffe000203008:	554010ef          	jal	ffffffe00020455c <printk>
ffffffe00020300c:	00000013          	nop
ffffffe000203010:	ffdff06f          	j	ffffffe00020300c <trap_handler+0x260>
            case 11: Err("Environment call from M-mode\n"); break;
ffffffe000203014:	00004697          	auipc	a3,0x4
ffffffe000203018:	62468693          	addi	a3,a3,1572 # ffffffe000207638 <__func__.0>
ffffffe00020301c:	03c00613          	li	a2,60
ffffffe000203020:	00004597          	auipc	a1,0x4
ffffffe000203024:	3a058593          	addi	a1,a1,928 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000203028:	00004517          	auipc	a0,0x4
ffffffe00020302c:	56850513          	addi	a0,a0,1384 # ffffffe000207590 <__func__.0+0x328>
ffffffe000203030:	52c010ef          	jal	ffffffe00020455c <printk>
ffffffe000203034:	00000013          	nop
ffffffe000203038:	ffdff06f          	j	ffffffe000203034 <trap_handler+0x288>
                do_page_fault(regs);
ffffffe00020303c:	fc843503          	ld	a0,-56(s0)
ffffffe000203040:	a79fe0ef          	jal	ffffffe000201ab8 <do_page_fault>
                break;
ffffffe000203044:	0440006f          	j	ffffffe000203088 <trap_handler+0x2dc>
                do_page_fault(regs);
ffffffe000203048:	fc843503          	ld	a0,-56(s0)
ffffffe00020304c:	a6dfe0ef          	jal	ffffffe000201ab8 <do_page_fault>
                break;
ffffffe000203050:	0380006f          	j	ffffffe000203088 <trap_handler+0x2dc>
                do_page_fault(regs);
ffffffe000203054:	fc843503          	ld	a0,-56(s0)
ffffffe000203058:	a61fe0ef          	jal	ffffffe000201ab8 <do_page_fault>
                break;
ffffffe00020305c:	02c0006f          	j	ffffffe000203088 <trap_handler+0x2dc>
            default: Err("Unknown exception\n"); break;
ffffffe000203060:	00004697          	auipc	a3,0x4
ffffffe000203064:	5d868693          	addi	a3,a3,1496 # ffffffe000207638 <__func__.0>
ffffffe000203068:	04c00613          	li	a2,76
ffffffe00020306c:	00004597          	auipc	a1,0x4
ffffffe000203070:	35458593          	addi	a1,a1,852 # ffffffe0002073c0 <__func__.0+0x158>
ffffffe000203074:	00004517          	auipc	a0,0x4
ffffffe000203078:	55450513          	addi	a0,a0,1364 # ffffffe0002075c8 <__func__.0+0x360>
ffffffe00020307c:	4e0010ef          	jal	ffffffe00020455c <printk>
ffffffe000203080:	00000013          	nop
ffffffe000203084:	ffdff06f          	j	ffffffe000203080 <trap_handler+0x2d4>
ffffffe000203088:	00000013          	nop
ffffffe00020308c:	03813083          	ld	ra,56(sp)
ffffffe000203090:	03013403          	ld	s0,48(sp)
ffffffe000203094:	04010113          	addi	sp,sp,64
ffffffe000203098:	00008067          	ret

ffffffe00020309c <io_to_virt>:
ffffffe00020309c:	fe010113          	addi	sp,sp,-32
ffffffe0002030a0:	00813c23          	sd	s0,24(sp)
ffffffe0002030a4:	02010413          	addi	s0,sp,32
ffffffe0002030a8:	fea43423          	sd	a0,-24(s0)
ffffffe0002030ac:	fe843703          	ld	a4,-24(s0)
ffffffe0002030b0:	ff900793          	li	a5,-7
ffffffe0002030b4:	02379793          	slli	a5,a5,0x23
ffffffe0002030b8:	00f707b3          	add	a5,a4,a5
ffffffe0002030bc:	00078513          	mv	a0,a5
ffffffe0002030c0:	01813403          	ld	s0,24(sp)
ffffffe0002030c4:	02010113          	addi	sp,sp,32
ffffffe0002030c8:	00008067          	ret

ffffffe0002030cc <setup_vm>:
void setup_vm() {
ffffffe0002030cc:	fd010113          	addi	sp,sp,-48
ffffffe0002030d0:	02113423          	sd	ra,40(sp)
ffffffe0002030d4:	02813023          	sd	s0,32(sp)
ffffffe0002030d8:	03010413          	addi	s0,sp,48
    printk("...setup_vm init early_pgtbl\n");
ffffffe0002030dc:	00004517          	auipc	a0,0x4
ffffffe0002030e0:	56c50513          	addi	a0,a0,1388 # ffffffe000207648 <__func__.0+0x10>
ffffffe0002030e4:	478010ef          	jal	ffffffe00020455c <printk>
    for (int i = 0; i < 512; i++) {
ffffffe0002030e8:	fe042623          	sw	zero,-20(s0)
ffffffe0002030ec:	0280006f          	j	ffffffe000203114 <setup_vm+0x48>
        early_pgtbl[i] = 0x0;
ffffffe0002030f0:	0040b717          	auipc	a4,0x40b
ffffffe0002030f4:	f1070713          	addi	a4,a4,-240 # ffffffe00060e000 <early_pgtbl>
ffffffe0002030f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002030fc:	00379793          	slli	a5,a5,0x3
ffffffe000203100:	00f707b3          	add	a5,a4,a5
ffffffe000203104:	0007b023          	sd	zero,0(a5)
    for (int i = 0; i < 512; i++) {
ffffffe000203108:	fec42783          	lw	a5,-20(s0)
ffffffe00020310c:	0017879b          	addiw	a5,a5,1
ffffffe000203110:	fef42623          	sw	a5,-20(s0)
ffffffe000203114:	fec42783          	lw	a5,-20(s0)
ffffffe000203118:	0007871b          	sext.w	a4,a5
ffffffe00020311c:	1ff00793          	li	a5,511
ffffffe000203120:	fce7d8e3          	bge	a5,a4,ffffffe0002030f0 <setup_vm+0x24>
    uint64_t vpn2 = (VM_START >> 30) & 0x1FF; // VPN[2]为30~38位
ffffffe000203124:	18000793          	li	a5,384
ffffffe000203128:	fef43023          	sd	a5,-32(s0)
    uint64_t ppn2 = PGROUNDDOWN(PHY_START) >> 30 & 0x1FF;
ffffffe00020312c:	00200793          	li	a5,2
ffffffe000203130:	fcf43c23          	sd	a5,-40(s0)
    uint64_t pte = (ppn2 << 28) | 0xF; // V R W X 位均为1
ffffffe000203134:	fd843783          	ld	a5,-40(s0)
ffffffe000203138:	01c79793          	slli	a5,a5,0x1c
ffffffe00020313c:	00f7e793          	ori	a5,a5,15
ffffffe000203140:	fcf43823          	sd	a5,-48(s0)
    early_pgtbl[ppn2] = pte;
ffffffe000203144:	0040b717          	auipc	a4,0x40b
ffffffe000203148:	ebc70713          	addi	a4,a4,-324 # ffffffe00060e000 <early_pgtbl>
ffffffe00020314c:	fd843783          	ld	a5,-40(s0)
ffffffe000203150:	00379793          	slli	a5,a5,0x3
ffffffe000203154:	00f707b3          	add	a5,a4,a5
ffffffe000203158:	fd043703          	ld	a4,-48(s0)
ffffffe00020315c:	00e7b023          	sd	a4,0(a5)
    early_pgtbl[vpn2] = pte;
ffffffe000203160:	0040b717          	auipc	a4,0x40b
ffffffe000203164:	ea070713          	addi	a4,a4,-352 # ffffffe00060e000 <early_pgtbl>
ffffffe000203168:	fe043783          	ld	a5,-32(s0)
ffffffe00020316c:	00379793          	slli	a5,a5,0x3
ffffffe000203170:	00f707b3          	add	a5,a4,a5
ffffffe000203174:	fd043703          	ld	a4,-48(s0)
ffffffe000203178:	00e7b023          	sd	a4,0(a5)
    printk("return\n");
ffffffe00020317c:	00004517          	auipc	a0,0x4
ffffffe000203180:	4ec50513          	addi	a0,a0,1260 # ffffffe000207668 <__func__.0+0x30>
ffffffe000203184:	3d8010ef          	jal	ffffffe00020455c <printk>
}
ffffffe000203188:	00000013          	nop
ffffffe00020318c:	02813083          	ld	ra,40(sp)
ffffffe000203190:	02013403          	ld	s0,32(sp)
ffffffe000203194:	03010113          	addi	sp,sp,48
ffffffe000203198:	00008067          	ret

ffffffe00020319c <setup_vm_final>:
void setup_vm_final() {
ffffffe00020319c:	f9010113          	addi	sp,sp,-112
ffffffe0002031a0:	06113423          	sd	ra,104(sp)
ffffffe0002031a4:	06813023          	sd	s0,96(sp)
ffffffe0002031a8:	07010413          	addi	s0,sp,112
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe0002031ac:	00001637          	lui	a2,0x1
ffffffe0002031b0:	00000593          	li	a1,0
ffffffe0002031b4:	0040c517          	auipc	a0,0x40c
ffffffe0002031b8:	e4c50513          	addi	a0,a0,-436 # ffffffe00060f000 <swapper_pg_dir>
ffffffe0002031bc:	4c0010ef          	jal	ffffffe00020467c <memset>
    uint64_t text_va_start = (uint64_t)_stext;               // 虚拟地址空间中 .text 段起点
ffffffe0002031c0:	ffffd797          	auipc	a5,0xffffd
ffffffe0002031c4:	e4078793          	addi	a5,a5,-448 # ffffffe000200000 <_skernel>
ffffffe0002031c8:	fef43423          	sd	a5,-24(s0)
    uint64_t text_pa_start = VA2PA(text_va_start);           // 转换为物理地址起点
ffffffe0002031cc:	fe843703          	ld	a4,-24(s0)
ffffffe0002031d0:	04100793          	li	a5,65
ffffffe0002031d4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002031d8:	00f707b3          	add	a5,a4,a5
ffffffe0002031dc:	fef43023          	sd	a5,-32(s0)
    uint64_t text_sz = PGROUNDUP((uint64_t)_etext - text_va_start); // 对齐后保障整页映射
ffffffe0002031e0:	00003717          	auipc	a4,0x3
ffffffe0002031e4:	43070713          	addi	a4,a4,1072 # ffffffe000206610 <_etext>
ffffffe0002031e8:	000017b7          	lui	a5,0x1
ffffffe0002031ec:	00f707b3          	add	a5,a4,a5
ffffffe0002031f0:	fff78713          	addi	a4,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002031f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002031f8:	40f70733          	sub	a4,a4,a5
ffffffe0002031fc:	fffff7b7          	lui	a5,0xfffff
ffffffe000203200:	00f777b3          	and	a5,a4,a5
ffffffe000203204:	fcf43c23          	sd	a5,-40(s0)
    if (text_sz) {
ffffffe000203208:	fd843783          	ld	a5,-40(s0)
ffffffe00020320c:	02078063          	beqz	a5,ffffffe00020322c <setup_vm_final+0x90>
        create_mapping(swapper_pg_dir, text_va_start, text_pa_start, text_sz, PTE_X | PTE_R);
ffffffe000203210:	00a00713          	li	a4,10
ffffffe000203214:	fd843683          	ld	a3,-40(s0)
ffffffe000203218:	fe043603          	ld	a2,-32(s0)
ffffffe00020321c:	fe843583          	ld	a1,-24(s0)
ffffffe000203220:	0040c517          	auipc	a0,0x40c
ffffffe000203224:	de050513          	addi	a0,a0,-544 # ffffffe00060f000 <swapper_pg_dir>
ffffffe000203228:	154000ef          	jal	ffffffe00020337c <create_mapping>
    uint64_t rodata_va_start = (uint64_t)_srodata;           // 只读数据段起点
ffffffe00020322c:	00004797          	auipc	a5,0x4
ffffffe000203230:	dd478793          	addi	a5,a5,-556 # ffffffe000207000 <__func__.0>
ffffffe000203234:	fcf43823          	sd	a5,-48(s0)
    uint64_t rodata_pa_start = VA2PA(rodata_va_start);
ffffffe000203238:	fd043703          	ld	a4,-48(s0)
ffffffe00020323c:	04100793          	li	a5,65
ffffffe000203240:	01f79793          	slli	a5,a5,0x1f
ffffffe000203244:	00f707b3          	add	a5,a4,a5
ffffffe000203248:	fcf43423          	sd	a5,-56(s0)
    uint64_t rodata_sz = PGROUNDUP((uint64_t)_erodata - rodata_va_start);
ffffffe00020324c:	00004717          	auipc	a4,0x4
ffffffe000203250:	65c70713          	addi	a4,a4,1628 # ffffffe0002078a8 <_erodata>
ffffffe000203254:	000017b7          	lui	a5,0x1
ffffffe000203258:	00f707b3          	add	a5,a4,a5
ffffffe00020325c:	fff78713          	addi	a4,a5,-1 # fff <PGSIZE-0x1>
ffffffe000203260:	fd043783          	ld	a5,-48(s0)
ffffffe000203264:	40f70733          	sub	a4,a4,a5
ffffffe000203268:	fffff7b7          	lui	a5,0xfffff
ffffffe00020326c:	00f777b3          	and	a5,a4,a5
ffffffe000203270:	fcf43023          	sd	a5,-64(s0)
    if (rodata_sz) {
ffffffe000203274:	fc043783          	ld	a5,-64(s0)
ffffffe000203278:	02078063          	beqz	a5,ffffffe000203298 <setup_vm_final+0xfc>
        create_mapping(swapper_pg_dir, rodata_va_start, rodata_pa_start, rodata_sz, PTE_R);
ffffffe00020327c:	00200713          	li	a4,2
ffffffe000203280:	fc043683          	ld	a3,-64(s0)
ffffffe000203284:	fc843603          	ld	a2,-56(s0)
ffffffe000203288:	fd043583          	ld	a1,-48(s0)
ffffffe00020328c:	0040c517          	auipc	a0,0x40c
ffffffe000203290:	d7450513          	addi	a0,a0,-652 # ffffffe00060f000 <swapper_pg_dir>
ffffffe000203294:	0e8000ef          	jal	ffffffe00020337c <create_mapping>
    uint64_t writable_va_start = (uint64_t)_sdata;               // 其他区域（从 sdata 开始）
ffffffe000203298:	00006797          	auipc	a5,0x6
ffffffe00020329c:	d6878793          	addi	a5,a5,-664 # ffffffe000209000 <TIMECLOCK>
ffffffe0002032a0:	faf43c23          	sd	a5,-72(s0)
    uint64_t writable_pa_start = VA2PA(writable_va_start);
ffffffe0002032a4:	fb843703          	ld	a4,-72(s0)
ffffffe0002032a8:	04100793          	li	a5,65
ffffffe0002032ac:	01f79793          	slli	a5,a5,0x1f
ffffffe0002032b0:	00f707b3          	add	a5,a4,a5
ffffffe0002032b4:	faf43823          	sd	a5,-80(s0)
    uint64_t writable_sz = PGROUNDUP(((uint64_t)PHY_END) - writable_pa_start);
ffffffe0002032b8:	00004797          	auipc	a5,0x4
ffffffe0002032bc:	44078793          	addi	a5,a5,1088 # ffffffe0002076f8 <__func__.0+0xc0>
ffffffe0002032c0:	0007b703          	ld	a4,0(a5)
ffffffe0002032c4:	fb043783          	ld	a5,-80(s0)
ffffffe0002032c8:	40f70733          	sub	a4,a4,a5
ffffffe0002032cc:	fffff7b7          	lui	a5,0xfffff
ffffffe0002032d0:	00f777b3          	and	a5,a4,a5
ffffffe0002032d4:	faf43423          	sd	a5,-88(s0)
    if (writable_sz) {
ffffffe0002032d8:	fa843783          	ld	a5,-88(s0)
ffffffe0002032dc:	02078063          	beqz	a5,ffffffe0002032fc <setup_vm_final+0x160>
        create_mapping(swapper_pg_dir, writable_va_start, writable_pa_start, writable_sz, PTE_W | PTE_R);
ffffffe0002032e0:	00600713          	li	a4,6
ffffffe0002032e4:	fa843683          	ld	a3,-88(s0)
ffffffe0002032e8:	fb043603          	ld	a2,-80(s0)
ffffffe0002032ec:	fb843583          	ld	a1,-72(s0)
ffffffe0002032f0:	0040c517          	auipc	a0,0x40c
ffffffe0002032f4:	d1050513          	addi	a0,a0,-752 # ffffffe00060f000 <swapper_pg_dir>
ffffffe0002032f8:	084000ef          	jal	ffffffe00020337c <create_mapping>
    create_mapping(swapper_pg_dir, io_to_virt(VIRTIO_START), VIRTIO_START, VIRTIO_SIZE * VIRTIO_COUNT, PTE_W | PTE_R | PTE_V);
ffffffe0002032fc:	10001537          	lui	a0,0x10001
ffffffe000203300:	d9dff0ef          	jal	ffffffe00020309c <io_to_virt>
ffffffe000203304:	00050793          	mv	a5,a0
ffffffe000203308:	00700713          	li	a4,7
ffffffe00020330c:	000086b7          	lui	a3,0x8
ffffffe000203310:	10001637          	lui	a2,0x10001
ffffffe000203314:	00078593          	mv	a1,a5
ffffffe000203318:	0040c517          	auipc	a0,0x40c
ffffffe00020331c:	ce850513          	addi	a0,a0,-792 # ffffffe00060f000 <swapper_pg_dir>
ffffffe000203320:	05c000ef          	jal	ffffffe00020337c <create_mapping>
    uint64_t pgdir_pa = VA2PA((uint64_t)swapper_pg_dir);     // 获取物理页号
ffffffe000203324:	0040c717          	auipc	a4,0x40c
ffffffe000203328:	cdc70713          	addi	a4,a4,-804 # ffffffe00060f000 <swapper_pg_dir>
ffffffe00020332c:	04100793          	li	a5,65
ffffffe000203330:	01f79793          	slli	a5,a5,0x1f
ffffffe000203334:	00f707b3          	add	a5,a4,a5
ffffffe000203338:	faf43023          	sd	a5,-96(s0)
    uint64_t satp_val = SATP_MODE_SV39 | PPN_OF(pgdir_pa);   // MODE = 8 | PPN
ffffffe00020333c:	fa043783          	ld	a5,-96(s0)
ffffffe000203340:	00c7d713          	srli	a4,a5,0xc
ffffffe000203344:	fff00793          	li	a5,-1
ffffffe000203348:	03f79793          	slli	a5,a5,0x3f
ffffffe00020334c:	00f767b3          	or	a5,a4,a5
ffffffe000203350:	f8f43c23          	sd	a5,-104(s0)
    csr_write(satp, satp_val);
ffffffe000203354:	f9843783          	ld	a5,-104(s0)
ffffffe000203358:	f8f43823          	sd	a5,-112(s0)
ffffffe00020335c:	f9043783          	ld	a5,-112(s0)
ffffffe000203360:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
ffffffe000203364:	12000073          	sfence.vma
    return;
ffffffe000203368:	00000013          	nop
}
ffffffe00020336c:	06813083          	ld	ra,104(sp)
ffffffe000203370:	06013403          	ld	s0,96(sp)
ffffffe000203374:	07010113          	addi	sp,sp,112
ffffffe000203378:	00008067          	ret

ffffffe00020337c <create_mapping>:
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe00020337c:	f2010113          	addi	sp,sp,-224
ffffffe000203380:	0c113c23          	sd	ra,216(sp)
ffffffe000203384:	0c813823          	sd	s0,208(sp)
ffffffe000203388:	0e010413          	addi	s0,sp,224
ffffffe00020338c:	f4a43423          	sd	a0,-184(s0)
ffffffe000203390:	f4b43023          	sd	a1,-192(s0)
ffffffe000203394:	f2c43c23          	sd	a2,-200(s0)
ffffffe000203398:	f2d43823          	sd	a3,-208(s0)
ffffffe00020339c:	f2e43423          	sd	a4,-216(s0)
    uint64_t va_start = PGROUNDDOWN(va);
ffffffe0002033a0:	f4043703          	ld	a4,-192(s0)
ffffffe0002033a4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002033a8:	00f777b3          	and	a5,a4,a5
ffffffe0002033ac:	fcf43c23          	sd	a5,-40(s0)
    uint64_t va_end = PGROUNDUP(va + sz);
ffffffe0002033b0:	f4043703          	ld	a4,-192(s0)
ffffffe0002033b4:	f3043783          	ld	a5,-208(s0)
ffffffe0002033b8:	00f70733          	add	a4,a4,a5
ffffffe0002033bc:	000017b7          	lui	a5,0x1
ffffffe0002033c0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002033c4:	00f70733          	add	a4,a4,a5
ffffffe0002033c8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002033cc:	00f777b3          	and	a5,a4,a5
ffffffe0002033d0:	fcf43823          	sd	a5,-48(s0)
    uint64_t pa_start = PGROUNDDOWN(pa);
ffffffe0002033d4:	f3843703          	ld	a4,-200(s0)
ffffffe0002033d8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002033dc:	00f777b3          	and	a5,a4,a5
ffffffe0002033e0:	fcf43423          	sd	a5,-56(s0)
    for (uint64_t cur_va = va_start, cur_pa = pa_start; cur_va < va_end; cur_va += PGSIZE, cur_pa += PGSIZE) {
ffffffe0002033e4:	fd843783          	ld	a5,-40(s0)
ffffffe0002033e8:	fef43423          	sd	a5,-24(s0)
ffffffe0002033ec:	fc843783          	ld	a5,-56(s0)
ffffffe0002033f0:	fef43023          	sd	a5,-32(s0)
ffffffe0002033f4:	2280006f          	j	ffffffe00020361c <create_mapping+0x2a0>
        uint64_t vpn2 = VPN2(cur_va);
ffffffe0002033f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002033fc:	01e7d793          	srli	a5,a5,0x1e
ffffffe000203400:	1ff7f793          	andi	a5,a5,511
ffffffe000203404:	fcf43023          	sd	a5,-64(s0)
        uint64_t vpn1 = VPN1(cur_va);
ffffffe000203408:	fe843783          	ld	a5,-24(s0)
ffffffe00020340c:	0157d793          	srli	a5,a5,0x15
ffffffe000203410:	1ff7f793          	andi	a5,a5,511
ffffffe000203414:	faf43c23          	sd	a5,-72(s0)
        uint64_t vpn0 = VPN0(cur_va);
ffffffe000203418:	fe843783          	ld	a5,-24(s0)
ffffffe00020341c:	00c7d793          	srli	a5,a5,0xc
ffffffe000203420:	1ff7f793          	andi	a5,a5,511
ffffffe000203424:	faf43823          	sd	a5,-80(s0)
        uint64_t *l2_table_va = pgtbl;                      // 根页表的虚拟地址
ffffffe000203428:	f4843783          	ld	a5,-184(s0)
ffffffe00020342c:	faf43423          	sd	a5,-88(s0)
        uint64_t *pte_l2 = &l2_table_va[vpn2];
ffffffe000203430:	fc043783          	ld	a5,-64(s0)
ffffffe000203434:	00379793          	slli	a5,a5,0x3
ffffffe000203438:	fa843703          	ld	a4,-88(s0)
ffffffe00020343c:	00f707b3          	add	a5,a4,a5
ffffffe000203440:	faf43023          	sd	a5,-96(s0)
        if (!(*pte_l2 & PTE_V)) {
ffffffe000203444:	fa043783          	ld	a5,-96(s0)
ffffffe000203448:	0007b783          	ld	a5,0(a5) # fffffffffffff000 <VM_END+0xfffff000>
ffffffe00020344c:	0017f793          	andi	a5,a5,1
ffffffe000203450:	06079c63          	bnez	a5,ffffffe0002034c8 <create_mapping+0x14c>
            uint64_t *new_l1 = (uint64_t *)kalloc();
ffffffe000203454:	ff4fd0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000203458:	f8a43c23          	sd	a0,-104(s0)
            if (new_l1 == 0) {
ffffffe00020345c:	f9843783          	ld	a5,-104(s0)
ffffffe000203460:	02079663          	bnez	a5,ffffffe00020348c <create_mapping+0x110>
                Err("create_mapping: kalloc failed (L1)\n");
ffffffe000203464:	00004697          	auipc	a3,0x4
ffffffe000203468:	29c68693          	addi	a3,a3,668 # ffffffe000207700 <__func__.0>
ffffffe00020346c:	07900613          	li	a2,121
ffffffe000203470:	00004597          	auipc	a1,0x4
ffffffe000203474:	20058593          	addi	a1,a1,512 # ffffffe000207670 <__func__.0+0x38>
ffffffe000203478:	00004517          	auipc	a0,0x4
ffffffe00020347c:	20050513          	addi	a0,a0,512 # ffffffe000207678 <__func__.0+0x40>
ffffffe000203480:	0dc010ef          	jal	ffffffe00020455c <printk>
ffffffe000203484:	00000013          	nop
ffffffe000203488:	ffdff06f          	j	ffffffe000203484 <create_mapping+0x108>
            memset(new_l1, 0, PGSIZE);
ffffffe00020348c:	00001637          	lui	a2,0x1
ffffffe000203490:	00000593          	li	a1,0
ffffffe000203494:	f9843503          	ld	a0,-104(s0)
ffffffe000203498:	1e4010ef          	jal	ffffffe00020467c <memset>
            uint64_t new_l1_pa = VA2PA((uint64_t)new_l1);
ffffffe00020349c:	f9843703          	ld	a4,-104(s0)
ffffffe0002034a0:	04100793          	li	a5,65
ffffffe0002034a4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002034a8:	00f707b3          	add	a5,a4,a5
ffffffe0002034ac:	f8f43823          	sd	a5,-112(s0)
            *pte_l2 = PTE_FROM_PPN(PPN_OF(new_l1_pa)) | PTE_V;
ffffffe0002034b0:	f9043783          	ld	a5,-112(s0)
ffffffe0002034b4:	00c7d793          	srli	a5,a5,0xc
ffffffe0002034b8:	00a79793          	slli	a5,a5,0xa
ffffffe0002034bc:	0017e713          	ori	a4,a5,1
ffffffe0002034c0:	fa043783          	ld	a5,-96(s0)
ffffffe0002034c4:	00e7b023          	sd	a4,0(a5)
        uint64_t l1_pa = PA_FROM_PPN(PPN_FROM_PTE(*pte_l2));
ffffffe0002034c8:	fa043783          	ld	a5,-96(s0)
ffffffe0002034cc:	0007b783          	ld	a5,0(a5)
ffffffe0002034d0:	00a7d793          	srli	a5,a5,0xa
ffffffe0002034d4:	00c79713          	slli	a4,a5,0xc
ffffffe0002034d8:	fff007b7          	lui	a5,0xfff00
ffffffe0002034dc:	0087d793          	srli	a5,a5,0x8
ffffffe0002034e0:	00f777b3          	and	a5,a4,a5
ffffffe0002034e4:	f8f43423          	sd	a5,-120(s0)
        uint64_t *l1_table_va = (uint64_t *)PA2VA(l1_pa);
ffffffe0002034e8:	f8843703          	ld	a4,-120(s0)
ffffffe0002034ec:	fbf00793          	li	a5,-65
ffffffe0002034f0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002034f4:	00f707b3          	add	a5,a4,a5
ffffffe0002034f8:	f8f43023          	sd	a5,-128(s0)
        uint64_t *pte_l1 = &l1_table_va[vpn1];
ffffffe0002034fc:	fb843783          	ld	a5,-72(s0)
ffffffe000203500:	00379793          	slli	a5,a5,0x3
ffffffe000203504:	f8043703          	ld	a4,-128(s0)
ffffffe000203508:	00f707b3          	add	a5,a4,a5
ffffffe00020350c:	f6f43c23          	sd	a5,-136(s0)
        if (!(*pte_l1 & PTE_V)) {
ffffffe000203510:	f7843783          	ld	a5,-136(s0)
ffffffe000203514:	0007b783          	ld	a5,0(a5) # fffffffffff00000 <VM_END+0xfff00000>
ffffffe000203518:	0017f793          	andi	a5,a5,1
ffffffe00020351c:	06079c63          	bnez	a5,ffffffe000203594 <create_mapping+0x218>
            uint64_t *new_l0 = (uint64_t *)kalloc();
ffffffe000203520:	f28fd0ef          	jal	ffffffe000200c48 <kalloc>
ffffffe000203524:	f6a43823          	sd	a0,-144(s0)
            if (new_l0 == 0) {
ffffffe000203528:	f7043783          	ld	a5,-144(s0)
ffffffe00020352c:	02079663          	bnez	a5,ffffffe000203558 <create_mapping+0x1dc>
                Err("create_mapping: kalloc failed (L0)\n");
ffffffe000203530:	00004697          	auipc	a3,0x4
ffffffe000203534:	1d068693          	addi	a3,a3,464 # ffffffe000207700 <__func__.0>
ffffffe000203538:	08900613          	li	a2,137
ffffffe00020353c:	00004597          	auipc	a1,0x4
ffffffe000203540:	13458593          	addi	a1,a1,308 # ffffffe000207670 <__func__.0+0x38>
ffffffe000203544:	00004517          	auipc	a0,0x4
ffffffe000203548:	17450513          	addi	a0,a0,372 # ffffffe0002076b8 <__func__.0+0x80>
ffffffe00020354c:	010010ef          	jal	ffffffe00020455c <printk>
ffffffe000203550:	00000013          	nop
ffffffe000203554:	ffdff06f          	j	ffffffe000203550 <create_mapping+0x1d4>
            memset(new_l0, 0, PGSIZE);
ffffffe000203558:	00001637          	lui	a2,0x1
ffffffe00020355c:	00000593          	li	a1,0
ffffffe000203560:	f7043503          	ld	a0,-144(s0)
ffffffe000203564:	118010ef          	jal	ffffffe00020467c <memset>
            uint64_t new_l0_pa = VA2PA((uint64_t)new_l0);
ffffffe000203568:	f7043703          	ld	a4,-144(s0)
ffffffe00020356c:	04100793          	li	a5,65
ffffffe000203570:	01f79793          	slli	a5,a5,0x1f
ffffffe000203574:	00f707b3          	add	a5,a4,a5
ffffffe000203578:	f6f43423          	sd	a5,-152(s0)
            *pte_l1 = PTE_FROM_PPN(PPN_OF(new_l0_pa)) | PTE_V;
ffffffe00020357c:	f6843783          	ld	a5,-152(s0)
ffffffe000203580:	00c7d793          	srli	a5,a5,0xc
ffffffe000203584:	00a79793          	slli	a5,a5,0xa
ffffffe000203588:	0017e713          	ori	a4,a5,1
ffffffe00020358c:	f7843783          	ld	a5,-136(s0)
ffffffe000203590:	00e7b023          	sd	a4,0(a5)
        uint64_t l0_pa = PA_FROM_PPN(PPN_FROM_PTE(*pte_l1));
ffffffe000203594:	f7843783          	ld	a5,-136(s0)
ffffffe000203598:	0007b783          	ld	a5,0(a5)
ffffffe00020359c:	00a7d793          	srli	a5,a5,0xa
ffffffe0002035a0:	00c79713          	slli	a4,a5,0xc
ffffffe0002035a4:	fff007b7          	lui	a5,0xfff00
ffffffe0002035a8:	0087d793          	srli	a5,a5,0x8
ffffffe0002035ac:	00f777b3          	and	a5,a4,a5
ffffffe0002035b0:	f6f43023          	sd	a5,-160(s0)
        uint64_t *l0_table_va = (uint64_t *)PA2VA(l0_pa);
ffffffe0002035b4:	f6043703          	ld	a4,-160(s0)
ffffffe0002035b8:	fbf00793          	li	a5,-65
ffffffe0002035bc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002035c0:	00f707b3          	add	a5,a4,a5
ffffffe0002035c4:	f4f43c23          	sd	a5,-168(s0)
        uint64_t *pte_l0 = &l0_table_va[vpn0];
ffffffe0002035c8:	fb043783          	ld	a5,-80(s0)
ffffffe0002035cc:	00379793          	slli	a5,a5,0x3
ffffffe0002035d0:	f5843703          	ld	a4,-168(s0)
ffffffe0002035d4:	00f707b3          	add	a5,a4,a5
ffffffe0002035d8:	f4f43823          	sd	a5,-176(s0)
        *pte_l0 = PTE_FROM_PPN(PPN_OF(cur_pa)) | perm | PTE_V;
ffffffe0002035dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002035e0:	00c7d793          	srli	a5,a5,0xc
ffffffe0002035e4:	00a79713          	slli	a4,a5,0xa
ffffffe0002035e8:	f2843783          	ld	a5,-216(s0)
ffffffe0002035ec:	00f767b3          	or	a5,a4,a5
ffffffe0002035f0:	0017e713          	ori	a4,a5,1
ffffffe0002035f4:	f5043783          	ld	a5,-176(s0)
ffffffe0002035f8:	00e7b023          	sd	a4,0(a5) # fffffffffff00000 <VM_END+0xfff00000>
    for (uint64_t cur_va = va_start, cur_pa = pa_start; cur_va < va_end; cur_va += PGSIZE, cur_pa += PGSIZE) {
ffffffe0002035fc:	fe843703          	ld	a4,-24(s0)
ffffffe000203600:	000017b7          	lui	a5,0x1
ffffffe000203604:	00f707b3          	add	a5,a4,a5
ffffffe000203608:	fef43423          	sd	a5,-24(s0)
ffffffe00020360c:	fe043703          	ld	a4,-32(s0)
ffffffe000203610:	000017b7          	lui	a5,0x1
ffffffe000203614:	00f707b3          	add	a5,a4,a5
ffffffe000203618:	fef43023          	sd	a5,-32(s0)
ffffffe00020361c:	fe843703          	ld	a4,-24(s0)
ffffffe000203620:	fd043783          	ld	a5,-48(s0)
ffffffe000203624:	dcf76ae3          	bltu	a4,a5,ffffffe0002033f8 <create_mapping+0x7c>
    asm volatile("sfence.vma zero, zero");
ffffffe000203628:	12000073          	sfence.vma
    return;
ffffffe00020362c:	00000013          	nop
ffffffe000203630:	0d813083          	ld	ra,216(sp)
ffffffe000203634:	0d013403          	ld	s0,208(sp)
ffffffe000203638:	0e010113          	addi	sp,sp,224
ffffffe00020363c:	00008067          	ret

ffffffe000203640 <start_kernel>:
#include "printk.h"
#include "proc.h"

extern void test();

int start_kernel() {
ffffffe000203640:	ff010113          	addi	sp,sp,-16
ffffffe000203644:	00113423          	sd	ra,8(sp)
ffffffe000203648:	00813023          	sd	s0,0(sp)
ffffffe00020364c:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000203650:	00004517          	auipc	a0,0x4
ffffffe000203654:	0c050513          	addi	a0,a0,192 # ffffffe000207710 <__func__.0+0x10>
ffffffe000203658:	705000ef          	jal	ffffffe00020455c <printk>
    printk(" ZJU Operating System\n");
ffffffe00020365c:	00004517          	auipc	a0,0x4
ffffffe000203660:	0bc50513          	addi	a0,a0,188 # ffffffe000207718 <__func__.0+0x18>
ffffffe000203664:	6f9000ef          	jal	ffffffe00020455c <printk>

    schedule();
ffffffe000203668:	ad8fe0ef          	jal	ffffffe000201940 <schedule>
    test();
ffffffe00020366c:	01c000ef          	jal	ffffffe000203688 <test>
    return 0;
ffffffe000203670:	00000793          	li	a5,0
}
ffffffe000203674:	00078513          	mv	a0,a5
ffffffe000203678:	00813083          	ld	ra,8(sp)
ffffffe00020367c:	00013403          	ld	s0,0(sp)
ffffffe000203680:	01010113          	addi	sp,sp,16
ffffffe000203684:	00008067          	ret

ffffffe000203688 <test>:
//     sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
//     __builtin_unreachable();
// }

#include "printk.h"
void test() {
ffffffe000203688:	fe010113          	addi	sp,sp,-32
ffffffe00020368c:	00813c23          	sd	s0,24(sp)
ffffffe000203690:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe000203694:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000203698:	fec42783          	lw	a5,-20(s0)
ffffffe00020369c:	0017879b          	addiw	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe0002036a0:	fef42623          	sw	a5,-20(s0)
ffffffe0002036a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002036a8:	00078713          	mv	a4,a5
ffffffe0002036ac:	05f5e7b7          	lui	a5,0x5f5e
ffffffe0002036b0:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe0002036b4:	02f767bb          	remw	a5,a4,a5
ffffffe0002036b8:	0007879b          	sext.w	a5,a5
ffffffe0002036bc:	fc079ee3          	bnez	a5,ffffffe000203698 <test+0x10>
            // printk("kernel is running!\n");
            i = 0;
ffffffe0002036c0:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe0002036c4:	fd5ff06f          	j	ffffffe000203698 <test+0x10>

ffffffe0002036c8 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe0002036c8:	fe010113          	addi	sp,sp,-32
ffffffe0002036cc:	00113c23          	sd	ra,24(sp)
ffffffe0002036d0:	00813823          	sd	s0,16(sp)
ffffffe0002036d4:	02010413          	addi	s0,sp,32
ffffffe0002036d8:	00050793          	mv	a5,a0
ffffffe0002036dc:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe0002036e0:	fec42783          	lw	a5,-20(s0)
ffffffe0002036e4:	0ff7f793          	zext.b	a5,a5
ffffffe0002036e8:	00078513          	mv	a0,a5
ffffffe0002036ec:	f51fe0ef          	jal	ffffffe00020263c <sbi_debug_console_write_byte>
    return (char)c;
ffffffe0002036f0:	fec42783          	lw	a5,-20(s0)
ffffffe0002036f4:	0ff7f793          	zext.b	a5,a5
ffffffe0002036f8:	0007879b          	sext.w	a5,a5
}
ffffffe0002036fc:	00078513          	mv	a0,a5
ffffffe000203700:	01813083          	ld	ra,24(sp)
ffffffe000203704:	01013403          	ld	s0,16(sp)
ffffffe000203708:	02010113          	addi	sp,sp,32
ffffffe00020370c:	00008067          	ret

ffffffe000203710 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000203710:	fe010113          	addi	sp,sp,-32
ffffffe000203714:	00813c23          	sd	s0,24(sp)
ffffffe000203718:	02010413          	addi	s0,sp,32
ffffffe00020371c:	00050793          	mv	a5,a0
ffffffe000203720:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000203724:	fec42783          	lw	a5,-20(s0)
ffffffe000203728:	0007871b          	sext.w	a4,a5
ffffffe00020372c:	02000793          	li	a5,32
ffffffe000203730:	02f70263          	beq	a4,a5,ffffffe000203754 <isspace+0x44>
ffffffe000203734:	fec42783          	lw	a5,-20(s0)
ffffffe000203738:	0007871b          	sext.w	a4,a5
ffffffe00020373c:	00800793          	li	a5,8
ffffffe000203740:	00e7de63          	bge	a5,a4,ffffffe00020375c <isspace+0x4c>
ffffffe000203744:	fec42783          	lw	a5,-20(s0)
ffffffe000203748:	0007871b          	sext.w	a4,a5
ffffffe00020374c:	00d00793          	li	a5,13
ffffffe000203750:	00e7c663          	blt	a5,a4,ffffffe00020375c <isspace+0x4c>
ffffffe000203754:	00100793          	li	a5,1
ffffffe000203758:	0080006f          	j	ffffffe000203760 <isspace+0x50>
ffffffe00020375c:	00000793          	li	a5,0
}
ffffffe000203760:	00078513          	mv	a0,a5
ffffffe000203764:	01813403          	ld	s0,24(sp)
ffffffe000203768:	02010113          	addi	sp,sp,32
ffffffe00020376c:	00008067          	ret

ffffffe000203770 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000203770:	fb010113          	addi	sp,sp,-80
ffffffe000203774:	04113423          	sd	ra,72(sp)
ffffffe000203778:	04813023          	sd	s0,64(sp)
ffffffe00020377c:	05010413          	addi	s0,sp,80
ffffffe000203780:	fca43423          	sd	a0,-56(s0)
ffffffe000203784:	fcb43023          	sd	a1,-64(s0)
ffffffe000203788:	00060793          	mv	a5,a2
ffffffe00020378c:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000203790:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000203794:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000203798:	fc843783          	ld	a5,-56(s0)
ffffffe00020379c:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe0002037a0:	0100006f          	j	ffffffe0002037b0 <strtol+0x40>
        p++;
ffffffe0002037a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002037a8:	00178793          	addi	a5,a5,1
ffffffe0002037ac:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe0002037b0:	fd843783          	ld	a5,-40(s0)
ffffffe0002037b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002037b8:	0007879b          	sext.w	a5,a5
ffffffe0002037bc:	00078513          	mv	a0,a5
ffffffe0002037c0:	f51ff0ef          	jal	ffffffe000203710 <isspace>
ffffffe0002037c4:	00050793          	mv	a5,a0
ffffffe0002037c8:	fc079ee3          	bnez	a5,ffffffe0002037a4 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe0002037cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002037d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002037d4:	00078713          	mv	a4,a5
ffffffe0002037d8:	02d00793          	li	a5,45
ffffffe0002037dc:	00f71e63          	bne	a4,a5,ffffffe0002037f8 <strtol+0x88>
        neg = true;
ffffffe0002037e0:	00100793          	li	a5,1
ffffffe0002037e4:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe0002037e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002037ec:	00178793          	addi	a5,a5,1
ffffffe0002037f0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002037f4:	0240006f          	j	ffffffe000203818 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe0002037f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002037fc:	0007c783          	lbu	a5,0(a5)
ffffffe000203800:	00078713          	mv	a4,a5
ffffffe000203804:	02b00793          	li	a5,43
ffffffe000203808:	00f71863          	bne	a4,a5,ffffffe000203818 <strtol+0xa8>
        p++;
ffffffe00020380c:	fd843783          	ld	a5,-40(s0)
ffffffe000203810:	00178793          	addi	a5,a5,1
ffffffe000203814:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000203818:	fbc42783          	lw	a5,-68(s0)
ffffffe00020381c:	0007879b          	sext.w	a5,a5
ffffffe000203820:	06079c63          	bnez	a5,ffffffe000203898 <strtol+0x128>
        if (*p == '0') {
ffffffe000203824:	fd843783          	ld	a5,-40(s0)
ffffffe000203828:	0007c783          	lbu	a5,0(a5)
ffffffe00020382c:	00078713          	mv	a4,a5
ffffffe000203830:	03000793          	li	a5,48
ffffffe000203834:	04f71e63          	bne	a4,a5,ffffffe000203890 <strtol+0x120>
            p++;
ffffffe000203838:	fd843783          	ld	a5,-40(s0)
ffffffe00020383c:	00178793          	addi	a5,a5,1
ffffffe000203840:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000203844:	fd843783          	ld	a5,-40(s0)
ffffffe000203848:	0007c783          	lbu	a5,0(a5)
ffffffe00020384c:	00078713          	mv	a4,a5
ffffffe000203850:	07800793          	li	a5,120
ffffffe000203854:	00f70c63          	beq	a4,a5,ffffffe00020386c <strtol+0xfc>
ffffffe000203858:	fd843783          	ld	a5,-40(s0)
ffffffe00020385c:	0007c783          	lbu	a5,0(a5)
ffffffe000203860:	00078713          	mv	a4,a5
ffffffe000203864:	05800793          	li	a5,88
ffffffe000203868:	00f71e63          	bne	a4,a5,ffffffe000203884 <strtol+0x114>
                base = 16;
ffffffe00020386c:	01000793          	li	a5,16
ffffffe000203870:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000203874:	fd843783          	ld	a5,-40(s0)
ffffffe000203878:	00178793          	addi	a5,a5,1
ffffffe00020387c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000203880:	0180006f          	j	ffffffe000203898 <strtol+0x128>
            } else {
                base = 8;
ffffffe000203884:	00800793          	li	a5,8
ffffffe000203888:	faf42e23          	sw	a5,-68(s0)
ffffffe00020388c:	00c0006f          	j	ffffffe000203898 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000203890:	00a00793          	li	a5,10
ffffffe000203894:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000203898:	fd843783          	ld	a5,-40(s0)
ffffffe00020389c:	0007c783          	lbu	a5,0(a5)
ffffffe0002038a0:	00078713          	mv	a4,a5
ffffffe0002038a4:	02f00793          	li	a5,47
ffffffe0002038a8:	02e7f863          	bgeu	a5,a4,ffffffe0002038d8 <strtol+0x168>
ffffffe0002038ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002038b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002038b4:	00078713          	mv	a4,a5
ffffffe0002038b8:	03900793          	li	a5,57
ffffffe0002038bc:	00e7ee63          	bltu	a5,a4,ffffffe0002038d8 <strtol+0x168>
            digit = *p - '0';
ffffffe0002038c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002038c4:	0007c783          	lbu	a5,0(a5)
ffffffe0002038c8:	0007879b          	sext.w	a5,a5
ffffffe0002038cc:	fd07879b          	addiw	a5,a5,-48
ffffffe0002038d0:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002038d4:	0800006f          	j	ffffffe000203954 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe0002038d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002038dc:	0007c783          	lbu	a5,0(a5)
ffffffe0002038e0:	00078713          	mv	a4,a5
ffffffe0002038e4:	06000793          	li	a5,96
ffffffe0002038e8:	02e7f863          	bgeu	a5,a4,ffffffe000203918 <strtol+0x1a8>
ffffffe0002038ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002038f0:	0007c783          	lbu	a5,0(a5)
ffffffe0002038f4:	00078713          	mv	a4,a5
ffffffe0002038f8:	07a00793          	li	a5,122
ffffffe0002038fc:	00e7ee63          	bltu	a5,a4,ffffffe000203918 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000203900:	fd843783          	ld	a5,-40(s0)
ffffffe000203904:	0007c783          	lbu	a5,0(a5)
ffffffe000203908:	0007879b          	sext.w	a5,a5
ffffffe00020390c:	fa97879b          	addiw	a5,a5,-87
ffffffe000203910:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203914:	0400006f          	j	ffffffe000203954 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000203918:	fd843783          	ld	a5,-40(s0)
ffffffe00020391c:	0007c783          	lbu	a5,0(a5)
ffffffe000203920:	00078713          	mv	a4,a5
ffffffe000203924:	04000793          	li	a5,64
ffffffe000203928:	06e7f863          	bgeu	a5,a4,ffffffe000203998 <strtol+0x228>
ffffffe00020392c:	fd843783          	ld	a5,-40(s0)
ffffffe000203930:	0007c783          	lbu	a5,0(a5)
ffffffe000203934:	00078713          	mv	a4,a5
ffffffe000203938:	05a00793          	li	a5,90
ffffffe00020393c:	04e7ee63          	bltu	a5,a4,ffffffe000203998 <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000203940:	fd843783          	ld	a5,-40(s0)
ffffffe000203944:	0007c783          	lbu	a5,0(a5)
ffffffe000203948:	0007879b          	sext.w	a5,a5
ffffffe00020394c:	fc97879b          	addiw	a5,a5,-55
ffffffe000203950:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000203954:	fd442783          	lw	a5,-44(s0)
ffffffe000203958:	00078713          	mv	a4,a5
ffffffe00020395c:	fbc42783          	lw	a5,-68(s0)
ffffffe000203960:	0007071b          	sext.w	a4,a4
ffffffe000203964:	0007879b          	sext.w	a5,a5
ffffffe000203968:	02f75663          	bge	a4,a5,ffffffe000203994 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe00020396c:	fbc42703          	lw	a4,-68(s0)
ffffffe000203970:	fe843783          	ld	a5,-24(s0)
ffffffe000203974:	02f70733          	mul	a4,a4,a5
ffffffe000203978:	fd442783          	lw	a5,-44(s0)
ffffffe00020397c:	00f707b3          	add	a5,a4,a5
ffffffe000203980:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000203984:	fd843783          	ld	a5,-40(s0)
ffffffe000203988:	00178793          	addi	a5,a5,1
ffffffe00020398c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000203990:	f09ff06f          	j	ffffffe000203898 <strtol+0x128>
            break;
ffffffe000203994:	00000013          	nop
    }

    if (endptr) {
ffffffe000203998:	fc043783          	ld	a5,-64(s0)
ffffffe00020399c:	00078863          	beqz	a5,ffffffe0002039ac <strtol+0x23c>
        *endptr = (char *)p;
ffffffe0002039a0:	fc043783          	ld	a5,-64(s0)
ffffffe0002039a4:	fd843703          	ld	a4,-40(s0)
ffffffe0002039a8:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe0002039ac:	fe744783          	lbu	a5,-25(s0)
ffffffe0002039b0:	0ff7f793          	zext.b	a5,a5
ffffffe0002039b4:	00078863          	beqz	a5,ffffffe0002039c4 <strtol+0x254>
ffffffe0002039b8:	fe843783          	ld	a5,-24(s0)
ffffffe0002039bc:	40f007b3          	neg	a5,a5
ffffffe0002039c0:	0080006f          	j	ffffffe0002039c8 <strtol+0x258>
ffffffe0002039c4:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002039c8:	00078513          	mv	a0,a5
ffffffe0002039cc:	04813083          	ld	ra,72(sp)
ffffffe0002039d0:	04013403          	ld	s0,64(sp)
ffffffe0002039d4:	05010113          	addi	sp,sp,80
ffffffe0002039d8:	00008067          	ret

ffffffe0002039dc <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe0002039dc:	fd010113          	addi	sp,sp,-48
ffffffe0002039e0:	02113423          	sd	ra,40(sp)
ffffffe0002039e4:	02813023          	sd	s0,32(sp)
ffffffe0002039e8:	03010413          	addi	s0,sp,48
ffffffe0002039ec:	fca43c23          	sd	a0,-40(s0)
ffffffe0002039f0:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe0002039f4:	fd043783          	ld	a5,-48(s0)
ffffffe0002039f8:	00079863          	bnez	a5,ffffffe000203a08 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe0002039fc:	00004797          	auipc	a5,0x4
ffffffe000203a00:	d3478793          	addi	a5,a5,-716 # ffffffe000207730 <__func__.0+0x30>
ffffffe000203a04:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000203a08:	fd043783          	ld	a5,-48(s0)
ffffffe000203a0c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000203a10:	0240006f          	j	ffffffe000203a34 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000203a14:	fe843783          	ld	a5,-24(s0)
ffffffe000203a18:	00178713          	addi	a4,a5,1
ffffffe000203a1c:	fee43423          	sd	a4,-24(s0)
ffffffe000203a20:	0007c783          	lbu	a5,0(a5)
ffffffe000203a24:	0007871b          	sext.w	a4,a5
ffffffe000203a28:	fd843783          	ld	a5,-40(s0)
ffffffe000203a2c:	00070513          	mv	a0,a4
ffffffe000203a30:	000780e7          	jalr	a5
    while (*p) {
ffffffe000203a34:	fe843783          	ld	a5,-24(s0)
ffffffe000203a38:	0007c783          	lbu	a5,0(a5)
ffffffe000203a3c:	fc079ce3          	bnez	a5,ffffffe000203a14 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000203a40:	fe843703          	ld	a4,-24(s0)
ffffffe000203a44:	fd043783          	ld	a5,-48(s0)
ffffffe000203a48:	40f707b3          	sub	a5,a4,a5
ffffffe000203a4c:	0007879b          	sext.w	a5,a5
}
ffffffe000203a50:	00078513          	mv	a0,a5
ffffffe000203a54:	02813083          	ld	ra,40(sp)
ffffffe000203a58:	02013403          	ld	s0,32(sp)
ffffffe000203a5c:	03010113          	addi	sp,sp,48
ffffffe000203a60:	00008067          	ret

ffffffe000203a64 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000203a64:	f9010113          	addi	sp,sp,-112
ffffffe000203a68:	06113423          	sd	ra,104(sp)
ffffffe000203a6c:	06813023          	sd	s0,96(sp)
ffffffe000203a70:	07010413          	addi	s0,sp,112
ffffffe000203a74:	faa43423          	sd	a0,-88(s0)
ffffffe000203a78:	fab43023          	sd	a1,-96(s0)
ffffffe000203a7c:	00060793          	mv	a5,a2
ffffffe000203a80:	f8d43823          	sd	a3,-112(s0)
ffffffe000203a84:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000203a88:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203a8c:	0ff7f793          	zext.b	a5,a5
ffffffe000203a90:	02078663          	beqz	a5,ffffffe000203abc <print_dec_int+0x58>
ffffffe000203a94:	fa043703          	ld	a4,-96(s0)
ffffffe000203a98:	fff00793          	li	a5,-1
ffffffe000203a9c:	03f79793          	slli	a5,a5,0x3f
ffffffe000203aa0:	00f71e63          	bne	a4,a5,ffffffe000203abc <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000203aa4:	00004597          	auipc	a1,0x4
ffffffe000203aa8:	c9458593          	addi	a1,a1,-876 # ffffffe000207738 <__func__.0+0x38>
ffffffe000203aac:	fa843503          	ld	a0,-88(s0)
ffffffe000203ab0:	f2dff0ef          	jal	ffffffe0002039dc <puts_wo_nl>
ffffffe000203ab4:	00050793          	mv	a5,a0
ffffffe000203ab8:	2a00006f          	j	ffffffe000203d58 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000203abc:	f9043783          	ld	a5,-112(s0)
ffffffe000203ac0:	00c7a783          	lw	a5,12(a5)
ffffffe000203ac4:	00079a63          	bnez	a5,ffffffe000203ad8 <print_dec_int+0x74>
ffffffe000203ac8:	fa043783          	ld	a5,-96(s0)
ffffffe000203acc:	00079663          	bnez	a5,ffffffe000203ad8 <print_dec_int+0x74>
        return 0;
ffffffe000203ad0:	00000793          	li	a5,0
ffffffe000203ad4:	2840006f          	j	ffffffe000203d58 <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000203ad8:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000203adc:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203ae0:	0ff7f793          	zext.b	a5,a5
ffffffe000203ae4:	02078063          	beqz	a5,ffffffe000203b04 <print_dec_int+0xa0>
ffffffe000203ae8:	fa043783          	ld	a5,-96(s0)
ffffffe000203aec:	0007dc63          	bgez	a5,ffffffe000203b04 <print_dec_int+0xa0>
        neg = true;
ffffffe000203af0:	00100793          	li	a5,1
ffffffe000203af4:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000203af8:	fa043783          	ld	a5,-96(s0)
ffffffe000203afc:	40f007b3          	neg	a5,a5
ffffffe000203b00:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000203b04:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000203b08:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203b0c:	0ff7f793          	zext.b	a5,a5
ffffffe000203b10:	02078863          	beqz	a5,ffffffe000203b40 <print_dec_int+0xdc>
ffffffe000203b14:	fef44783          	lbu	a5,-17(s0)
ffffffe000203b18:	0ff7f793          	zext.b	a5,a5
ffffffe000203b1c:	00079e63          	bnez	a5,ffffffe000203b38 <print_dec_int+0xd4>
ffffffe000203b20:	f9043783          	ld	a5,-112(s0)
ffffffe000203b24:	0057c783          	lbu	a5,5(a5)
ffffffe000203b28:	00079863          	bnez	a5,ffffffe000203b38 <print_dec_int+0xd4>
ffffffe000203b2c:	f9043783          	ld	a5,-112(s0)
ffffffe000203b30:	0047c783          	lbu	a5,4(a5)
ffffffe000203b34:	00078663          	beqz	a5,ffffffe000203b40 <print_dec_int+0xdc>
ffffffe000203b38:	00100793          	li	a5,1
ffffffe000203b3c:	0080006f          	j	ffffffe000203b44 <print_dec_int+0xe0>
ffffffe000203b40:	00000793          	li	a5,0
ffffffe000203b44:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000203b48:	fd744783          	lbu	a5,-41(s0)
ffffffe000203b4c:	0017f793          	andi	a5,a5,1
ffffffe000203b50:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000203b54:	fa043703          	ld	a4,-96(s0)
ffffffe000203b58:	00a00793          	li	a5,10
ffffffe000203b5c:	02f777b3          	remu	a5,a4,a5
ffffffe000203b60:	0ff7f713          	zext.b	a4,a5
ffffffe000203b64:	fe842783          	lw	a5,-24(s0)
ffffffe000203b68:	0017869b          	addiw	a3,a5,1
ffffffe000203b6c:	fed42423          	sw	a3,-24(s0)
ffffffe000203b70:	0307071b          	addiw	a4,a4,48
ffffffe000203b74:	0ff77713          	zext.b	a4,a4
ffffffe000203b78:	ff078793          	addi	a5,a5,-16
ffffffe000203b7c:	008787b3          	add	a5,a5,s0
ffffffe000203b80:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000203b84:	fa043703          	ld	a4,-96(s0)
ffffffe000203b88:	00a00793          	li	a5,10
ffffffe000203b8c:	02f757b3          	divu	a5,a4,a5
ffffffe000203b90:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000203b94:	fa043783          	ld	a5,-96(s0)
ffffffe000203b98:	fa079ee3          	bnez	a5,ffffffe000203b54 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000203b9c:	f9043783          	ld	a5,-112(s0)
ffffffe000203ba0:	00c7a783          	lw	a5,12(a5)
ffffffe000203ba4:	00078713          	mv	a4,a5
ffffffe000203ba8:	fff00793          	li	a5,-1
ffffffe000203bac:	02f71063          	bne	a4,a5,ffffffe000203bcc <print_dec_int+0x168>
ffffffe000203bb0:	f9043783          	ld	a5,-112(s0)
ffffffe000203bb4:	0037c783          	lbu	a5,3(a5)
ffffffe000203bb8:	00078a63          	beqz	a5,ffffffe000203bcc <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000203bbc:	f9043783          	ld	a5,-112(s0)
ffffffe000203bc0:	0087a703          	lw	a4,8(a5)
ffffffe000203bc4:	f9043783          	ld	a5,-112(s0)
ffffffe000203bc8:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000203bcc:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203bd0:	f9043783          	ld	a5,-112(s0)
ffffffe000203bd4:	0087a703          	lw	a4,8(a5)
ffffffe000203bd8:	fe842783          	lw	a5,-24(s0)
ffffffe000203bdc:	fcf42823          	sw	a5,-48(s0)
ffffffe000203be0:	f9043783          	ld	a5,-112(s0)
ffffffe000203be4:	00c7a783          	lw	a5,12(a5)
ffffffe000203be8:	fcf42623          	sw	a5,-52(s0)
ffffffe000203bec:	fd042783          	lw	a5,-48(s0)
ffffffe000203bf0:	00078593          	mv	a1,a5
ffffffe000203bf4:	fcc42783          	lw	a5,-52(s0)
ffffffe000203bf8:	00078613          	mv	a2,a5
ffffffe000203bfc:	0006069b          	sext.w	a3,a2
ffffffe000203c00:	0005879b          	sext.w	a5,a1
ffffffe000203c04:	00f6d463          	bge	a3,a5,ffffffe000203c0c <print_dec_int+0x1a8>
ffffffe000203c08:	00058613          	mv	a2,a1
ffffffe000203c0c:	0006079b          	sext.w	a5,a2
ffffffe000203c10:	40f707bb          	subw	a5,a4,a5
ffffffe000203c14:	0007871b          	sext.w	a4,a5
ffffffe000203c18:	fd744783          	lbu	a5,-41(s0)
ffffffe000203c1c:	0007879b          	sext.w	a5,a5
ffffffe000203c20:	40f707bb          	subw	a5,a4,a5
ffffffe000203c24:	fef42023          	sw	a5,-32(s0)
ffffffe000203c28:	0280006f          	j	ffffffe000203c50 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000203c2c:	fa843783          	ld	a5,-88(s0)
ffffffe000203c30:	02000513          	li	a0,32
ffffffe000203c34:	000780e7          	jalr	a5
        ++written;
ffffffe000203c38:	fe442783          	lw	a5,-28(s0)
ffffffe000203c3c:	0017879b          	addiw	a5,a5,1
ffffffe000203c40:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203c44:	fe042783          	lw	a5,-32(s0)
ffffffe000203c48:	fff7879b          	addiw	a5,a5,-1
ffffffe000203c4c:	fef42023          	sw	a5,-32(s0)
ffffffe000203c50:	fe042783          	lw	a5,-32(s0)
ffffffe000203c54:	0007879b          	sext.w	a5,a5
ffffffe000203c58:	fcf04ae3          	bgtz	a5,ffffffe000203c2c <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000203c5c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203c60:	0ff7f793          	zext.b	a5,a5
ffffffe000203c64:	04078463          	beqz	a5,ffffffe000203cac <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000203c68:	fef44783          	lbu	a5,-17(s0)
ffffffe000203c6c:	0ff7f793          	zext.b	a5,a5
ffffffe000203c70:	00078663          	beqz	a5,ffffffe000203c7c <print_dec_int+0x218>
ffffffe000203c74:	02d00793          	li	a5,45
ffffffe000203c78:	01c0006f          	j	ffffffe000203c94 <print_dec_int+0x230>
ffffffe000203c7c:	f9043783          	ld	a5,-112(s0)
ffffffe000203c80:	0057c783          	lbu	a5,5(a5)
ffffffe000203c84:	00078663          	beqz	a5,ffffffe000203c90 <print_dec_int+0x22c>
ffffffe000203c88:	02b00793          	li	a5,43
ffffffe000203c8c:	0080006f          	j	ffffffe000203c94 <print_dec_int+0x230>
ffffffe000203c90:	02000793          	li	a5,32
ffffffe000203c94:	fa843703          	ld	a4,-88(s0)
ffffffe000203c98:	00078513          	mv	a0,a5
ffffffe000203c9c:	000700e7          	jalr	a4
        ++written;
ffffffe000203ca0:	fe442783          	lw	a5,-28(s0)
ffffffe000203ca4:	0017879b          	addiw	a5,a5,1
ffffffe000203ca8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203cac:	fe842783          	lw	a5,-24(s0)
ffffffe000203cb0:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203cb4:	0280006f          	j	ffffffe000203cdc <print_dec_int+0x278>
        putch('0');
ffffffe000203cb8:	fa843783          	ld	a5,-88(s0)
ffffffe000203cbc:	03000513          	li	a0,48
ffffffe000203cc0:	000780e7          	jalr	a5
        ++written;
ffffffe000203cc4:	fe442783          	lw	a5,-28(s0)
ffffffe000203cc8:	0017879b          	addiw	a5,a5,1
ffffffe000203ccc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203cd0:	fdc42783          	lw	a5,-36(s0)
ffffffe000203cd4:	0017879b          	addiw	a5,a5,1
ffffffe000203cd8:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203cdc:	f9043783          	ld	a5,-112(s0)
ffffffe000203ce0:	00c7a703          	lw	a4,12(a5)
ffffffe000203ce4:	fd744783          	lbu	a5,-41(s0)
ffffffe000203ce8:	0007879b          	sext.w	a5,a5
ffffffe000203cec:	40f707bb          	subw	a5,a4,a5
ffffffe000203cf0:	0007871b          	sext.w	a4,a5
ffffffe000203cf4:	fdc42783          	lw	a5,-36(s0)
ffffffe000203cf8:	0007879b          	sext.w	a5,a5
ffffffe000203cfc:	fae7cee3          	blt	a5,a4,ffffffe000203cb8 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203d00:	fe842783          	lw	a5,-24(s0)
ffffffe000203d04:	fff7879b          	addiw	a5,a5,-1
ffffffe000203d08:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203d0c:	03c0006f          	j	ffffffe000203d48 <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000203d10:	fd842783          	lw	a5,-40(s0)
ffffffe000203d14:	ff078793          	addi	a5,a5,-16
ffffffe000203d18:	008787b3          	add	a5,a5,s0
ffffffe000203d1c:	fc87c783          	lbu	a5,-56(a5)
ffffffe000203d20:	0007871b          	sext.w	a4,a5
ffffffe000203d24:	fa843783          	ld	a5,-88(s0)
ffffffe000203d28:	00070513          	mv	a0,a4
ffffffe000203d2c:	000780e7          	jalr	a5
        ++written;
ffffffe000203d30:	fe442783          	lw	a5,-28(s0)
ffffffe000203d34:	0017879b          	addiw	a5,a5,1
ffffffe000203d38:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203d3c:	fd842783          	lw	a5,-40(s0)
ffffffe000203d40:	fff7879b          	addiw	a5,a5,-1
ffffffe000203d44:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203d48:	fd842783          	lw	a5,-40(s0)
ffffffe000203d4c:	0007879b          	sext.w	a5,a5
ffffffe000203d50:	fc07d0e3          	bgez	a5,ffffffe000203d10 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000203d54:	fe442783          	lw	a5,-28(s0)
}
ffffffe000203d58:	00078513          	mv	a0,a5
ffffffe000203d5c:	06813083          	ld	ra,104(sp)
ffffffe000203d60:	06013403          	ld	s0,96(sp)
ffffffe000203d64:	07010113          	addi	sp,sp,112
ffffffe000203d68:	00008067          	ret

ffffffe000203d6c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000203d6c:	f4010113          	addi	sp,sp,-192
ffffffe000203d70:	0a113c23          	sd	ra,184(sp)
ffffffe000203d74:	0a813823          	sd	s0,176(sp)
ffffffe000203d78:	0c010413          	addi	s0,sp,192
ffffffe000203d7c:	f4a43c23          	sd	a0,-168(s0)
ffffffe000203d80:	f4b43823          	sd	a1,-176(s0)
ffffffe000203d84:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000203d88:	f8043023          	sd	zero,-128(s0)
ffffffe000203d8c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000203d90:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000203d94:	7a40006f          	j	ffffffe000204538 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000203d98:	f8044783          	lbu	a5,-128(s0)
ffffffe000203d9c:	72078e63          	beqz	a5,ffffffe0002044d8 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000203da0:	f5043783          	ld	a5,-176(s0)
ffffffe000203da4:	0007c783          	lbu	a5,0(a5)
ffffffe000203da8:	00078713          	mv	a4,a5
ffffffe000203dac:	02300793          	li	a5,35
ffffffe000203db0:	00f71863          	bne	a4,a5,ffffffe000203dc0 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000203db4:	00100793          	li	a5,1
ffffffe000203db8:	f8f40123          	sb	a5,-126(s0)
ffffffe000203dbc:	7700006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000203dc0:	f5043783          	ld	a5,-176(s0)
ffffffe000203dc4:	0007c783          	lbu	a5,0(a5)
ffffffe000203dc8:	00078713          	mv	a4,a5
ffffffe000203dcc:	03000793          	li	a5,48
ffffffe000203dd0:	00f71863          	bne	a4,a5,ffffffe000203de0 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000203dd4:	00100793          	li	a5,1
ffffffe000203dd8:	f8f401a3          	sb	a5,-125(s0)
ffffffe000203ddc:	7500006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000203de0:	f5043783          	ld	a5,-176(s0)
ffffffe000203de4:	0007c783          	lbu	a5,0(a5)
ffffffe000203de8:	00078713          	mv	a4,a5
ffffffe000203dec:	06c00793          	li	a5,108
ffffffe000203df0:	04f70063          	beq	a4,a5,ffffffe000203e30 <vprintfmt+0xc4>
ffffffe000203df4:	f5043783          	ld	a5,-176(s0)
ffffffe000203df8:	0007c783          	lbu	a5,0(a5)
ffffffe000203dfc:	00078713          	mv	a4,a5
ffffffe000203e00:	07a00793          	li	a5,122
ffffffe000203e04:	02f70663          	beq	a4,a5,ffffffe000203e30 <vprintfmt+0xc4>
ffffffe000203e08:	f5043783          	ld	a5,-176(s0)
ffffffe000203e0c:	0007c783          	lbu	a5,0(a5)
ffffffe000203e10:	00078713          	mv	a4,a5
ffffffe000203e14:	07400793          	li	a5,116
ffffffe000203e18:	00f70c63          	beq	a4,a5,ffffffe000203e30 <vprintfmt+0xc4>
ffffffe000203e1c:	f5043783          	ld	a5,-176(s0)
ffffffe000203e20:	0007c783          	lbu	a5,0(a5)
ffffffe000203e24:	00078713          	mv	a4,a5
ffffffe000203e28:	06a00793          	li	a5,106
ffffffe000203e2c:	00f71863          	bne	a4,a5,ffffffe000203e3c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000203e30:	00100793          	li	a5,1
ffffffe000203e34:	f8f400a3          	sb	a5,-127(s0)
ffffffe000203e38:	6f40006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000203e3c:	f5043783          	ld	a5,-176(s0)
ffffffe000203e40:	0007c783          	lbu	a5,0(a5)
ffffffe000203e44:	00078713          	mv	a4,a5
ffffffe000203e48:	02b00793          	li	a5,43
ffffffe000203e4c:	00f71863          	bne	a4,a5,ffffffe000203e5c <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000203e50:	00100793          	li	a5,1
ffffffe000203e54:	f8f402a3          	sb	a5,-123(s0)
ffffffe000203e58:	6d40006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000203e5c:	f5043783          	ld	a5,-176(s0)
ffffffe000203e60:	0007c783          	lbu	a5,0(a5)
ffffffe000203e64:	00078713          	mv	a4,a5
ffffffe000203e68:	02000793          	li	a5,32
ffffffe000203e6c:	00f71863          	bne	a4,a5,ffffffe000203e7c <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000203e70:	00100793          	li	a5,1
ffffffe000203e74:	f8f40223          	sb	a5,-124(s0)
ffffffe000203e78:	6b40006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000203e7c:	f5043783          	ld	a5,-176(s0)
ffffffe000203e80:	0007c783          	lbu	a5,0(a5)
ffffffe000203e84:	00078713          	mv	a4,a5
ffffffe000203e88:	02a00793          	li	a5,42
ffffffe000203e8c:	00f71e63          	bne	a4,a5,ffffffe000203ea8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000203e90:	f4843783          	ld	a5,-184(s0)
ffffffe000203e94:	00878713          	addi	a4,a5,8
ffffffe000203e98:	f4e43423          	sd	a4,-184(s0)
ffffffe000203e9c:	0007a783          	lw	a5,0(a5)
ffffffe000203ea0:	f8f42423          	sw	a5,-120(s0)
ffffffe000203ea4:	6880006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000203ea8:	f5043783          	ld	a5,-176(s0)
ffffffe000203eac:	0007c783          	lbu	a5,0(a5)
ffffffe000203eb0:	00078713          	mv	a4,a5
ffffffe000203eb4:	03000793          	li	a5,48
ffffffe000203eb8:	04e7f663          	bgeu	a5,a4,ffffffe000203f04 <vprintfmt+0x198>
ffffffe000203ebc:	f5043783          	ld	a5,-176(s0)
ffffffe000203ec0:	0007c783          	lbu	a5,0(a5)
ffffffe000203ec4:	00078713          	mv	a4,a5
ffffffe000203ec8:	03900793          	li	a5,57
ffffffe000203ecc:	02e7ec63          	bltu	a5,a4,ffffffe000203f04 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000203ed0:	f5043783          	ld	a5,-176(s0)
ffffffe000203ed4:	f5040713          	addi	a4,s0,-176
ffffffe000203ed8:	00a00613          	li	a2,10
ffffffe000203edc:	00070593          	mv	a1,a4
ffffffe000203ee0:	00078513          	mv	a0,a5
ffffffe000203ee4:	88dff0ef          	jal	ffffffe000203770 <strtol>
ffffffe000203ee8:	00050793          	mv	a5,a0
ffffffe000203eec:	0007879b          	sext.w	a5,a5
ffffffe000203ef0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000203ef4:	f5043783          	ld	a5,-176(s0)
ffffffe000203ef8:	fff78793          	addi	a5,a5,-1
ffffffe000203efc:	f4f43823          	sd	a5,-176(s0)
ffffffe000203f00:	62c0006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000203f04:	f5043783          	ld	a5,-176(s0)
ffffffe000203f08:	0007c783          	lbu	a5,0(a5)
ffffffe000203f0c:	00078713          	mv	a4,a5
ffffffe000203f10:	02e00793          	li	a5,46
ffffffe000203f14:	06f71863          	bne	a4,a5,ffffffe000203f84 <vprintfmt+0x218>
                fmt++;
ffffffe000203f18:	f5043783          	ld	a5,-176(s0)
ffffffe000203f1c:	00178793          	addi	a5,a5,1
ffffffe000203f20:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000203f24:	f5043783          	ld	a5,-176(s0)
ffffffe000203f28:	0007c783          	lbu	a5,0(a5)
ffffffe000203f2c:	00078713          	mv	a4,a5
ffffffe000203f30:	02a00793          	li	a5,42
ffffffe000203f34:	00f71e63          	bne	a4,a5,ffffffe000203f50 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000203f38:	f4843783          	ld	a5,-184(s0)
ffffffe000203f3c:	00878713          	addi	a4,a5,8
ffffffe000203f40:	f4e43423          	sd	a4,-184(s0)
ffffffe000203f44:	0007a783          	lw	a5,0(a5)
ffffffe000203f48:	f8f42623          	sw	a5,-116(s0)
ffffffe000203f4c:	5e00006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000203f50:	f5043783          	ld	a5,-176(s0)
ffffffe000203f54:	f5040713          	addi	a4,s0,-176
ffffffe000203f58:	00a00613          	li	a2,10
ffffffe000203f5c:	00070593          	mv	a1,a4
ffffffe000203f60:	00078513          	mv	a0,a5
ffffffe000203f64:	80dff0ef          	jal	ffffffe000203770 <strtol>
ffffffe000203f68:	00050793          	mv	a5,a0
ffffffe000203f6c:	0007879b          	sext.w	a5,a5
ffffffe000203f70:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000203f74:	f5043783          	ld	a5,-176(s0)
ffffffe000203f78:	fff78793          	addi	a5,a5,-1
ffffffe000203f7c:	f4f43823          	sd	a5,-176(s0)
ffffffe000203f80:	5ac0006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000203f84:	f5043783          	ld	a5,-176(s0)
ffffffe000203f88:	0007c783          	lbu	a5,0(a5)
ffffffe000203f8c:	00078713          	mv	a4,a5
ffffffe000203f90:	07800793          	li	a5,120
ffffffe000203f94:	02f70663          	beq	a4,a5,ffffffe000203fc0 <vprintfmt+0x254>
ffffffe000203f98:	f5043783          	ld	a5,-176(s0)
ffffffe000203f9c:	0007c783          	lbu	a5,0(a5)
ffffffe000203fa0:	00078713          	mv	a4,a5
ffffffe000203fa4:	05800793          	li	a5,88
ffffffe000203fa8:	00f70c63          	beq	a4,a5,ffffffe000203fc0 <vprintfmt+0x254>
ffffffe000203fac:	f5043783          	ld	a5,-176(s0)
ffffffe000203fb0:	0007c783          	lbu	a5,0(a5)
ffffffe000203fb4:	00078713          	mv	a4,a5
ffffffe000203fb8:	07000793          	li	a5,112
ffffffe000203fbc:	30f71263          	bne	a4,a5,ffffffe0002042c0 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000203fc0:	f5043783          	ld	a5,-176(s0)
ffffffe000203fc4:	0007c783          	lbu	a5,0(a5)
ffffffe000203fc8:	00078713          	mv	a4,a5
ffffffe000203fcc:	07000793          	li	a5,112
ffffffe000203fd0:	00f70663          	beq	a4,a5,ffffffe000203fdc <vprintfmt+0x270>
ffffffe000203fd4:	f8144783          	lbu	a5,-127(s0)
ffffffe000203fd8:	00078663          	beqz	a5,ffffffe000203fe4 <vprintfmt+0x278>
ffffffe000203fdc:	00100793          	li	a5,1
ffffffe000203fe0:	0080006f          	j	ffffffe000203fe8 <vprintfmt+0x27c>
ffffffe000203fe4:	00000793          	li	a5,0
ffffffe000203fe8:	faf403a3          	sb	a5,-89(s0)
ffffffe000203fec:	fa744783          	lbu	a5,-89(s0)
ffffffe000203ff0:	0017f793          	andi	a5,a5,1
ffffffe000203ff4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000203ff8:	fa744783          	lbu	a5,-89(s0)
ffffffe000203ffc:	0ff7f793          	zext.b	a5,a5
ffffffe000204000:	00078c63          	beqz	a5,ffffffe000204018 <vprintfmt+0x2ac>
ffffffe000204004:	f4843783          	ld	a5,-184(s0)
ffffffe000204008:	00878713          	addi	a4,a5,8
ffffffe00020400c:	f4e43423          	sd	a4,-184(s0)
ffffffe000204010:	0007b783          	ld	a5,0(a5)
ffffffe000204014:	01c0006f          	j	ffffffe000204030 <vprintfmt+0x2c4>
ffffffe000204018:	f4843783          	ld	a5,-184(s0)
ffffffe00020401c:	00878713          	addi	a4,a5,8
ffffffe000204020:	f4e43423          	sd	a4,-184(s0)
ffffffe000204024:	0007a783          	lw	a5,0(a5)
ffffffe000204028:	02079793          	slli	a5,a5,0x20
ffffffe00020402c:	0207d793          	srli	a5,a5,0x20
ffffffe000204030:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000204034:	f8c42783          	lw	a5,-116(s0)
ffffffe000204038:	02079463          	bnez	a5,ffffffe000204060 <vprintfmt+0x2f4>
ffffffe00020403c:	fe043783          	ld	a5,-32(s0)
ffffffe000204040:	02079063          	bnez	a5,ffffffe000204060 <vprintfmt+0x2f4>
ffffffe000204044:	f5043783          	ld	a5,-176(s0)
ffffffe000204048:	0007c783          	lbu	a5,0(a5)
ffffffe00020404c:	00078713          	mv	a4,a5
ffffffe000204050:	07000793          	li	a5,112
ffffffe000204054:	00f70663          	beq	a4,a5,ffffffe000204060 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000204058:	f8040023          	sb	zero,-128(s0)
ffffffe00020405c:	4d00006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000204060:	f5043783          	ld	a5,-176(s0)
ffffffe000204064:	0007c783          	lbu	a5,0(a5)
ffffffe000204068:	00078713          	mv	a4,a5
ffffffe00020406c:	07000793          	li	a5,112
ffffffe000204070:	00f70a63          	beq	a4,a5,ffffffe000204084 <vprintfmt+0x318>
ffffffe000204074:	f8244783          	lbu	a5,-126(s0)
ffffffe000204078:	00078a63          	beqz	a5,ffffffe00020408c <vprintfmt+0x320>
ffffffe00020407c:	fe043783          	ld	a5,-32(s0)
ffffffe000204080:	00078663          	beqz	a5,ffffffe00020408c <vprintfmt+0x320>
ffffffe000204084:	00100793          	li	a5,1
ffffffe000204088:	0080006f          	j	ffffffe000204090 <vprintfmt+0x324>
ffffffe00020408c:	00000793          	li	a5,0
ffffffe000204090:	faf40323          	sb	a5,-90(s0)
ffffffe000204094:	fa644783          	lbu	a5,-90(s0)
ffffffe000204098:	0017f793          	andi	a5,a5,1
ffffffe00020409c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe0002040a0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe0002040a4:	f5043783          	ld	a5,-176(s0)
ffffffe0002040a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002040ac:	00078713          	mv	a4,a5
ffffffe0002040b0:	05800793          	li	a5,88
ffffffe0002040b4:	00f71863          	bne	a4,a5,ffffffe0002040c4 <vprintfmt+0x358>
ffffffe0002040b8:	00003797          	auipc	a5,0x3
ffffffe0002040bc:	69878793          	addi	a5,a5,1688 # ffffffe000207750 <upperxdigits.1>
ffffffe0002040c0:	00c0006f          	j	ffffffe0002040cc <vprintfmt+0x360>
ffffffe0002040c4:	00003797          	auipc	a5,0x3
ffffffe0002040c8:	6a478793          	addi	a5,a5,1700 # ffffffe000207768 <lowerxdigits.0>
ffffffe0002040cc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe0002040d0:	fe043783          	ld	a5,-32(s0)
ffffffe0002040d4:	00f7f793          	andi	a5,a5,15
ffffffe0002040d8:	f9843703          	ld	a4,-104(s0)
ffffffe0002040dc:	00f70733          	add	a4,a4,a5
ffffffe0002040e0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002040e4:	0017869b          	addiw	a3,a5,1
ffffffe0002040e8:	fcd42e23          	sw	a3,-36(s0)
ffffffe0002040ec:	00074703          	lbu	a4,0(a4)
ffffffe0002040f0:	ff078793          	addi	a5,a5,-16
ffffffe0002040f4:	008787b3          	add	a5,a5,s0
ffffffe0002040f8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe0002040fc:	fe043783          	ld	a5,-32(s0)
ffffffe000204100:	0047d793          	srli	a5,a5,0x4
ffffffe000204104:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000204108:	fe043783          	ld	a5,-32(s0)
ffffffe00020410c:	fc0792e3          	bnez	a5,ffffffe0002040d0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000204110:	f8c42783          	lw	a5,-116(s0)
ffffffe000204114:	00078713          	mv	a4,a5
ffffffe000204118:	fff00793          	li	a5,-1
ffffffe00020411c:	02f71663          	bne	a4,a5,ffffffe000204148 <vprintfmt+0x3dc>
ffffffe000204120:	f8344783          	lbu	a5,-125(s0)
ffffffe000204124:	02078263          	beqz	a5,ffffffe000204148 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000204128:	f8842703          	lw	a4,-120(s0)
ffffffe00020412c:	fa644783          	lbu	a5,-90(s0)
ffffffe000204130:	0007879b          	sext.w	a5,a5
ffffffe000204134:	0017979b          	slliw	a5,a5,0x1
ffffffe000204138:	0007879b          	sext.w	a5,a5
ffffffe00020413c:	40f707bb          	subw	a5,a4,a5
ffffffe000204140:	0007879b          	sext.w	a5,a5
ffffffe000204144:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000204148:	f8842703          	lw	a4,-120(s0)
ffffffe00020414c:	fa644783          	lbu	a5,-90(s0)
ffffffe000204150:	0007879b          	sext.w	a5,a5
ffffffe000204154:	0017979b          	slliw	a5,a5,0x1
ffffffe000204158:	0007879b          	sext.w	a5,a5
ffffffe00020415c:	40f707bb          	subw	a5,a4,a5
ffffffe000204160:	0007871b          	sext.w	a4,a5
ffffffe000204164:	fdc42783          	lw	a5,-36(s0)
ffffffe000204168:	f8f42a23          	sw	a5,-108(s0)
ffffffe00020416c:	f8c42783          	lw	a5,-116(s0)
ffffffe000204170:	f8f42823          	sw	a5,-112(s0)
ffffffe000204174:	f9442783          	lw	a5,-108(s0)
ffffffe000204178:	00078593          	mv	a1,a5
ffffffe00020417c:	f9042783          	lw	a5,-112(s0)
ffffffe000204180:	00078613          	mv	a2,a5
ffffffe000204184:	0006069b          	sext.w	a3,a2
ffffffe000204188:	0005879b          	sext.w	a5,a1
ffffffe00020418c:	00f6d463          	bge	a3,a5,ffffffe000204194 <vprintfmt+0x428>
ffffffe000204190:	00058613          	mv	a2,a1
ffffffe000204194:	0006079b          	sext.w	a5,a2
ffffffe000204198:	40f707bb          	subw	a5,a4,a5
ffffffe00020419c:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002041a0:	0280006f          	j	ffffffe0002041c8 <vprintfmt+0x45c>
                    putch(' ');
ffffffe0002041a4:	f5843783          	ld	a5,-168(s0)
ffffffe0002041a8:	02000513          	li	a0,32
ffffffe0002041ac:	000780e7          	jalr	a5
                    ++written;
ffffffe0002041b0:	fec42783          	lw	a5,-20(s0)
ffffffe0002041b4:	0017879b          	addiw	a5,a5,1
ffffffe0002041b8:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002041bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002041c0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002041c4:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002041c8:	fd842783          	lw	a5,-40(s0)
ffffffe0002041cc:	0007879b          	sext.w	a5,a5
ffffffe0002041d0:	fcf04ae3          	bgtz	a5,ffffffe0002041a4 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe0002041d4:	fa644783          	lbu	a5,-90(s0)
ffffffe0002041d8:	0ff7f793          	zext.b	a5,a5
ffffffe0002041dc:	04078463          	beqz	a5,ffffffe000204224 <vprintfmt+0x4b8>
                    putch('0');
ffffffe0002041e0:	f5843783          	ld	a5,-168(s0)
ffffffe0002041e4:	03000513          	li	a0,48
ffffffe0002041e8:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe0002041ec:	f5043783          	ld	a5,-176(s0)
ffffffe0002041f0:	0007c783          	lbu	a5,0(a5)
ffffffe0002041f4:	00078713          	mv	a4,a5
ffffffe0002041f8:	05800793          	li	a5,88
ffffffe0002041fc:	00f71663          	bne	a4,a5,ffffffe000204208 <vprintfmt+0x49c>
ffffffe000204200:	05800793          	li	a5,88
ffffffe000204204:	0080006f          	j	ffffffe00020420c <vprintfmt+0x4a0>
ffffffe000204208:	07800793          	li	a5,120
ffffffe00020420c:	f5843703          	ld	a4,-168(s0)
ffffffe000204210:	00078513          	mv	a0,a5
ffffffe000204214:	000700e7          	jalr	a4
                    written += 2;
ffffffe000204218:	fec42783          	lw	a5,-20(s0)
ffffffe00020421c:	0027879b          	addiw	a5,a5,2
ffffffe000204220:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000204224:	fdc42783          	lw	a5,-36(s0)
ffffffe000204228:	fcf42a23          	sw	a5,-44(s0)
ffffffe00020422c:	0280006f          	j	ffffffe000204254 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000204230:	f5843783          	ld	a5,-168(s0)
ffffffe000204234:	03000513          	li	a0,48
ffffffe000204238:	000780e7          	jalr	a5
                    ++written;
ffffffe00020423c:	fec42783          	lw	a5,-20(s0)
ffffffe000204240:	0017879b          	addiw	a5,a5,1
ffffffe000204244:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000204248:	fd442783          	lw	a5,-44(s0)
ffffffe00020424c:	0017879b          	addiw	a5,a5,1
ffffffe000204250:	fcf42a23          	sw	a5,-44(s0)
ffffffe000204254:	f8c42703          	lw	a4,-116(s0)
ffffffe000204258:	fd442783          	lw	a5,-44(s0)
ffffffe00020425c:	0007879b          	sext.w	a5,a5
ffffffe000204260:	fce7c8e3          	blt	a5,a4,ffffffe000204230 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000204264:	fdc42783          	lw	a5,-36(s0)
ffffffe000204268:	fff7879b          	addiw	a5,a5,-1
ffffffe00020426c:	fcf42823          	sw	a5,-48(s0)
ffffffe000204270:	03c0006f          	j	ffffffe0002042ac <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000204274:	fd042783          	lw	a5,-48(s0)
ffffffe000204278:	ff078793          	addi	a5,a5,-16
ffffffe00020427c:	008787b3          	add	a5,a5,s0
ffffffe000204280:	f807c783          	lbu	a5,-128(a5)
ffffffe000204284:	0007871b          	sext.w	a4,a5
ffffffe000204288:	f5843783          	ld	a5,-168(s0)
ffffffe00020428c:	00070513          	mv	a0,a4
ffffffe000204290:	000780e7          	jalr	a5
                    ++written;
ffffffe000204294:	fec42783          	lw	a5,-20(s0)
ffffffe000204298:	0017879b          	addiw	a5,a5,1
ffffffe00020429c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002042a0:	fd042783          	lw	a5,-48(s0)
ffffffe0002042a4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002042a8:	fcf42823          	sw	a5,-48(s0)
ffffffe0002042ac:	fd042783          	lw	a5,-48(s0)
ffffffe0002042b0:	0007879b          	sext.w	a5,a5
ffffffe0002042b4:	fc07d0e3          	bgez	a5,ffffffe000204274 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe0002042b8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002042bc:	2700006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002042c0:	f5043783          	ld	a5,-176(s0)
ffffffe0002042c4:	0007c783          	lbu	a5,0(a5)
ffffffe0002042c8:	00078713          	mv	a4,a5
ffffffe0002042cc:	06400793          	li	a5,100
ffffffe0002042d0:	02f70663          	beq	a4,a5,ffffffe0002042fc <vprintfmt+0x590>
ffffffe0002042d4:	f5043783          	ld	a5,-176(s0)
ffffffe0002042d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002042dc:	00078713          	mv	a4,a5
ffffffe0002042e0:	06900793          	li	a5,105
ffffffe0002042e4:	00f70c63          	beq	a4,a5,ffffffe0002042fc <vprintfmt+0x590>
ffffffe0002042e8:	f5043783          	ld	a5,-176(s0)
ffffffe0002042ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002042f0:	00078713          	mv	a4,a5
ffffffe0002042f4:	07500793          	li	a5,117
ffffffe0002042f8:	08f71063          	bne	a4,a5,ffffffe000204378 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe0002042fc:	f8144783          	lbu	a5,-127(s0)
ffffffe000204300:	00078c63          	beqz	a5,ffffffe000204318 <vprintfmt+0x5ac>
ffffffe000204304:	f4843783          	ld	a5,-184(s0)
ffffffe000204308:	00878713          	addi	a4,a5,8
ffffffe00020430c:	f4e43423          	sd	a4,-184(s0)
ffffffe000204310:	0007b783          	ld	a5,0(a5)
ffffffe000204314:	0140006f          	j	ffffffe000204328 <vprintfmt+0x5bc>
ffffffe000204318:	f4843783          	ld	a5,-184(s0)
ffffffe00020431c:	00878713          	addi	a4,a5,8
ffffffe000204320:	f4e43423          	sd	a4,-184(s0)
ffffffe000204324:	0007a783          	lw	a5,0(a5)
ffffffe000204328:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe00020432c:	fa843583          	ld	a1,-88(s0)
ffffffe000204330:	f5043783          	ld	a5,-176(s0)
ffffffe000204334:	0007c783          	lbu	a5,0(a5)
ffffffe000204338:	0007871b          	sext.w	a4,a5
ffffffe00020433c:	07500793          	li	a5,117
ffffffe000204340:	40f707b3          	sub	a5,a4,a5
ffffffe000204344:	00f037b3          	snez	a5,a5
ffffffe000204348:	0ff7f793          	zext.b	a5,a5
ffffffe00020434c:	f8040713          	addi	a4,s0,-128
ffffffe000204350:	00070693          	mv	a3,a4
ffffffe000204354:	00078613          	mv	a2,a5
ffffffe000204358:	f5843503          	ld	a0,-168(s0)
ffffffe00020435c:	f08ff0ef          	jal	ffffffe000203a64 <print_dec_int>
ffffffe000204360:	00050793          	mv	a5,a0
ffffffe000204364:	fec42703          	lw	a4,-20(s0)
ffffffe000204368:	00f707bb          	addw	a5,a4,a5
ffffffe00020436c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204370:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000204374:	1b80006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000204378:	f5043783          	ld	a5,-176(s0)
ffffffe00020437c:	0007c783          	lbu	a5,0(a5)
ffffffe000204380:	00078713          	mv	a4,a5
ffffffe000204384:	06e00793          	li	a5,110
ffffffe000204388:	04f71c63          	bne	a4,a5,ffffffe0002043e0 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe00020438c:	f8144783          	lbu	a5,-127(s0)
ffffffe000204390:	02078463          	beqz	a5,ffffffe0002043b8 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000204394:	f4843783          	ld	a5,-184(s0)
ffffffe000204398:	00878713          	addi	a4,a5,8
ffffffe00020439c:	f4e43423          	sd	a4,-184(s0)
ffffffe0002043a0:	0007b783          	ld	a5,0(a5)
ffffffe0002043a4:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe0002043a8:	fec42703          	lw	a4,-20(s0)
ffffffe0002043ac:	fb043783          	ld	a5,-80(s0)
ffffffe0002043b0:	00e7b023          	sd	a4,0(a5)
ffffffe0002043b4:	0240006f          	j	ffffffe0002043d8 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe0002043b8:	f4843783          	ld	a5,-184(s0)
ffffffe0002043bc:	00878713          	addi	a4,a5,8
ffffffe0002043c0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002043c4:	0007b783          	ld	a5,0(a5)
ffffffe0002043c8:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe0002043cc:	fb843783          	ld	a5,-72(s0)
ffffffe0002043d0:	fec42703          	lw	a4,-20(s0)
ffffffe0002043d4:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe0002043d8:	f8040023          	sb	zero,-128(s0)
ffffffe0002043dc:	1500006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe0002043e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002043e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002043e8:	00078713          	mv	a4,a5
ffffffe0002043ec:	07300793          	li	a5,115
ffffffe0002043f0:	02f71e63          	bne	a4,a5,ffffffe00020442c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe0002043f4:	f4843783          	ld	a5,-184(s0)
ffffffe0002043f8:	00878713          	addi	a4,a5,8
ffffffe0002043fc:	f4e43423          	sd	a4,-184(s0)
ffffffe000204400:	0007b783          	ld	a5,0(a5)
ffffffe000204404:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000204408:	fc043583          	ld	a1,-64(s0)
ffffffe00020440c:	f5843503          	ld	a0,-168(s0)
ffffffe000204410:	dccff0ef          	jal	ffffffe0002039dc <puts_wo_nl>
ffffffe000204414:	00050793          	mv	a5,a0
ffffffe000204418:	fec42703          	lw	a4,-20(s0)
ffffffe00020441c:	00f707bb          	addw	a5,a4,a5
ffffffe000204420:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204424:	f8040023          	sb	zero,-128(s0)
ffffffe000204428:	1040006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe00020442c:	f5043783          	ld	a5,-176(s0)
ffffffe000204430:	0007c783          	lbu	a5,0(a5)
ffffffe000204434:	00078713          	mv	a4,a5
ffffffe000204438:	06300793          	li	a5,99
ffffffe00020443c:	02f71e63          	bne	a4,a5,ffffffe000204478 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000204440:	f4843783          	ld	a5,-184(s0)
ffffffe000204444:	00878713          	addi	a4,a5,8
ffffffe000204448:	f4e43423          	sd	a4,-184(s0)
ffffffe00020444c:	0007a783          	lw	a5,0(a5)
ffffffe000204450:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000204454:	fcc42703          	lw	a4,-52(s0)
ffffffe000204458:	f5843783          	ld	a5,-168(s0)
ffffffe00020445c:	00070513          	mv	a0,a4
ffffffe000204460:	000780e7          	jalr	a5
                ++written;
ffffffe000204464:	fec42783          	lw	a5,-20(s0)
ffffffe000204468:	0017879b          	addiw	a5,a5,1
ffffffe00020446c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204470:	f8040023          	sb	zero,-128(s0)
ffffffe000204474:	0b80006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000204478:	f5043783          	ld	a5,-176(s0)
ffffffe00020447c:	0007c783          	lbu	a5,0(a5)
ffffffe000204480:	00078713          	mv	a4,a5
ffffffe000204484:	02500793          	li	a5,37
ffffffe000204488:	02f71263          	bne	a4,a5,ffffffe0002044ac <vprintfmt+0x740>
                putch('%');
ffffffe00020448c:	f5843783          	ld	a5,-168(s0)
ffffffe000204490:	02500513          	li	a0,37
ffffffe000204494:	000780e7          	jalr	a5
                ++written;
ffffffe000204498:	fec42783          	lw	a5,-20(s0)
ffffffe00020449c:	0017879b          	addiw	a5,a5,1
ffffffe0002044a0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002044a4:	f8040023          	sb	zero,-128(s0)
ffffffe0002044a8:	0840006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe0002044ac:	f5043783          	ld	a5,-176(s0)
ffffffe0002044b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002044b4:	0007871b          	sext.w	a4,a5
ffffffe0002044b8:	f5843783          	ld	a5,-168(s0)
ffffffe0002044bc:	00070513          	mv	a0,a4
ffffffe0002044c0:	000780e7          	jalr	a5
                ++written;
ffffffe0002044c4:	fec42783          	lw	a5,-20(s0)
ffffffe0002044c8:	0017879b          	addiw	a5,a5,1
ffffffe0002044cc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002044d0:	f8040023          	sb	zero,-128(s0)
ffffffe0002044d4:	0580006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe0002044d8:	f5043783          	ld	a5,-176(s0)
ffffffe0002044dc:	0007c783          	lbu	a5,0(a5)
ffffffe0002044e0:	00078713          	mv	a4,a5
ffffffe0002044e4:	02500793          	li	a5,37
ffffffe0002044e8:	02f71063          	bne	a4,a5,ffffffe000204508 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe0002044ec:	f8043023          	sd	zero,-128(s0)
ffffffe0002044f0:	f8043423          	sd	zero,-120(s0)
ffffffe0002044f4:	00100793          	li	a5,1
ffffffe0002044f8:	f8f40023          	sb	a5,-128(s0)
ffffffe0002044fc:	fff00793          	li	a5,-1
ffffffe000204500:	f8f42623          	sw	a5,-116(s0)
ffffffe000204504:	0280006f          	j	ffffffe00020452c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000204508:	f5043783          	ld	a5,-176(s0)
ffffffe00020450c:	0007c783          	lbu	a5,0(a5)
ffffffe000204510:	0007871b          	sext.w	a4,a5
ffffffe000204514:	f5843783          	ld	a5,-168(s0)
ffffffe000204518:	00070513          	mv	a0,a4
ffffffe00020451c:	000780e7          	jalr	a5
            ++written;
ffffffe000204520:	fec42783          	lw	a5,-20(s0)
ffffffe000204524:	0017879b          	addiw	a5,a5,1
ffffffe000204528:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe00020452c:	f5043783          	ld	a5,-176(s0)
ffffffe000204530:	00178793          	addi	a5,a5,1
ffffffe000204534:	f4f43823          	sd	a5,-176(s0)
ffffffe000204538:	f5043783          	ld	a5,-176(s0)
ffffffe00020453c:	0007c783          	lbu	a5,0(a5)
ffffffe000204540:	84079ce3          	bnez	a5,ffffffe000203d98 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000204544:	fec42783          	lw	a5,-20(s0)
}
ffffffe000204548:	00078513          	mv	a0,a5
ffffffe00020454c:	0b813083          	ld	ra,184(sp)
ffffffe000204550:	0b013403          	ld	s0,176(sp)
ffffffe000204554:	0c010113          	addi	sp,sp,192
ffffffe000204558:	00008067          	ret

ffffffe00020455c <printk>:

int printk(const char* s, ...) {
ffffffe00020455c:	f9010113          	addi	sp,sp,-112
ffffffe000204560:	02113423          	sd	ra,40(sp)
ffffffe000204564:	02813023          	sd	s0,32(sp)
ffffffe000204568:	03010413          	addi	s0,sp,48
ffffffe00020456c:	fca43c23          	sd	a0,-40(s0)
ffffffe000204570:	00b43423          	sd	a1,8(s0)
ffffffe000204574:	00c43823          	sd	a2,16(s0)
ffffffe000204578:	00d43c23          	sd	a3,24(s0)
ffffffe00020457c:	02e43023          	sd	a4,32(s0)
ffffffe000204580:	02f43423          	sd	a5,40(s0)
ffffffe000204584:	03043823          	sd	a6,48(s0)
ffffffe000204588:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe00020458c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000204590:	04040793          	addi	a5,s0,64
ffffffe000204594:	fcf43823          	sd	a5,-48(s0)
ffffffe000204598:	fd043783          	ld	a5,-48(s0)
ffffffe00020459c:	fc878793          	addi	a5,a5,-56
ffffffe0002045a0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002045a4:	fe043783          	ld	a5,-32(s0)
ffffffe0002045a8:	00078613          	mv	a2,a5
ffffffe0002045ac:	fd843583          	ld	a1,-40(s0)
ffffffe0002045b0:	fffff517          	auipc	a0,0xfffff
ffffffe0002045b4:	11850513          	addi	a0,a0,280 # ffffffe0002036c8 <putc>
ffffffe0002045b8:	fb4ff0ef          	jal	ffffffe000203d6c <vprintfmt>
ffffffe0002045bc:	00050793          	mv	a5,a0
ffffffe0002045c0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe0002045c4:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002045c8:	00078513          	mv	a0,a5
ffffffe0002045cc:	02813083          	ld	ra,40(sp)
ffffffe0002045d0:	02013403          	ld	s0,32(sp)
ffffffe0002045d4:	07010113          	addi	sp,sp,112
ffffffe0002045d8:	00008067          	ret

ffffffe0002045dc <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe0002045dc:	fe010113          	addi	sp,sp,-32
ffffffe0002045e0:	00813c23          	sd	s0,24(sp)
ffffffe0002045e4:	02010413          	addi	s0,sp,32
ffffffe0002045e8:	00050793          	mv	a5,a0
ffffffe0002045ec:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe0002045f0:	fec42783          	lw	a5,-20(s0)
ffffffe0002045f4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002045f8:	0007879b          	sext.w	a5,a5
ffffffe0002045fc:	02079713          	slli	a4,a5,0x20
ffffffe000204600:	02075713          	srli	a4,a4,0x20
ffffffe000204604:	00409797          	auipc	a5,0x409
ffffffe000204608:	a1c78793          	addi	a5,a5,-1508 # ffffffe00060d020 <seed>
ffffffe00020460c:	00e7b023          	sd	a4,0(a5)
}
ffffffe000204610:	00000013          	nop
ffffffe000204614:	01813403          	ld	s0,24(sp)
ffffffe000204618:	02010113          	addi	sp,sp,32
ffffffe00020461c:	00008067          	ret

ffffffe000204620 <rand>:

int rand(void) {
ffffffe000204620:	ff010113          	addi	sp,sp,-16
ffffffe000204624:	00813423          	sd	s0,8(sp)
ffffffe000204628:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe00020462c:	00409797          	auipc	a5,0x409
ffffffe000204630:	9f478793          	addi	a5,a5,-1548 # ffffffe00060d020 <seed>
ffffffe000204634:	0007b703          	ld	a4,0(a5)
ffffffe000204638:	00003797          	auipc	a5,0x3
ffffffe00020463c:	14878793          	addi	a5,a5,328 # ffffffe000207780 <lowerxdigits.0+0x18>
ffffffe000204640:	0007b783          	ld	a5,0(a5)
ffffffe000204644:	02f707b3          	mul	a5,a4,a5
ffffffe000204648:	00178713          	addi	a4,a5,1
ffffffe00020464c:	00409797          	auipc	a5,0x409
ffffffe000204650:	9d478793          	addi	a5,a5,-1580 # ffffffe00060d020 <seed>
ffffffe000204654:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000204658:	00409797          	auipc	a5,0x409
ffffffe00020465c:	9c878793          	addi	a5,a5,-1592 # ffffffe00060d020 <seed>
ffffffe000204660:	0007b783          	ld	a5,0(a5)
ffffffe000204664:	0217d793          	srli	a5,a5,0x21
ffffffe000204668:	0007879b          	sext.w	a5,a5
}
ffffffe00020466c:	00078513          	mv	a0,a5
ffffffe000204670:	00813403          	ld	s0,8(sp)
ffffffe000204674:	01010113          	addi	sp,sp,16
ffffffe000204678:	00008067          	ret

ffffffe00020467c <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe00020467c:	fc010113          	addi	sp,sp,-64
ffffffe000204680:	02813c23          	sd	s0,56(sp)
ffffffe000204684:	04010413          	addi	s0,sp,64
ffffffe000204688:	fca43c23          	sd	a0,-40(s0)
ffffffe00020468c:	00058793          	mv	a5,a1
ffffffe000204690:	fcc43423          	sd	a2,-56(s0)
ffffffe000204694:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000204698:	fd843783          	ld	a5,-40(s0)
ffffffe00020469c:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002046a0:	fe043423          	sd	zero,-24(s0)
ffffffe0002046a4:	0280006f          	j	ffffffe0002046cc <memset+0x50>
        s[i] = c;
ffffffe0002046a8:	fe043703          	ld	a4,-32(s0)
ffffffe0002046ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002046b0:	00f707b3          	add	a5,a4,a5
ffffffe0002046b4:	fd442703          	lw	a4,-44(s0)
ffffffe0002046b8:	0ff77713          	zext.b	a4,a4
ffffffe0002046bc:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002046c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002046c4:	00178793          	addi	a5,a5,1
ffffffe0002046c8:	fef43423          	sd	a5,-24(s0)
ffffffe0002046cc:	fe843703          	ld	a4,-24(s0)
ffffffe0002046d0:	fc843783          	ld	a5,-56(s0)
ffffffe0002046d4:	fcf76ae3          	bltu	a4,a5,ffffffe0002046a8 <memset+0x2c>
    }
    return dest;
ffffffe0002046d8:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002046dc:	00078513          	mv	a0,a5
ffffffe0002046e0:	03813403          	ld	s0,56(sp)
ffffffe0002046e4:	04010113          	addi	sp,sp,64
ffffffe0002046e8:	00008067          	ret

ffffffe0002046ec <memcpy>:

void *memcpy(void *dst, void *src, uint64_t n) {
ffffffe0002046ec:	fb010113          	addi	sp,sp,-80
ffffffe0002046f0:	04813423          	sd	s0,72(sp)
ffffffe0002046f4:	05010413          	addi	s0,sp,80
ffffffe0002046f8:	fca43423          	sd	a0,-56(s0)
ffffffe0002046fc:	fcb43023          	sd	a1,-64(s0)
ffffffe000204700:	fac43c23          	sd	a2,-72(s0)
    char *cdst = (char *)dst;
ffffffe000204704:	fc843783          	ld	a5,-56(s0)
ffffffe000204708:	fef43023          	sd	a5,-32(s0)
    char *csrc = (char *)src;
ffffffe00020470c:	fc043783          	ld	a5,-64(s0)
ffffffe000204710:	fcf43c23          	sd	a5,-40(s0)
    for (uint64_t i = 0; i < n; ++i)
ffffffe000204714:	fe043423          	sd	zero,-24(s0)
ffffffe000204718:	0300006f          	j	ffffffe000204748 <memcpy+0x5c>
        cdst[i] = csrc[i];
ffffffe00020471c:	fd843703          	ld	a4,-40(s0)
ffffffe000204720:	fe843783          	ld	a5,-24(s0)
ffffffe000204724:	00f70733          	add	a4,a4,a5
ffffffe000204728:	fe043683          	ld	a3,-32(s0)
ffffffe00020472c:	fe843783          	ld	a5,-24(s0)
ffffffe000204730:	00f687b3          	add	a5,a3,a5
ffffffe000204734:	00074703          	lbu	a4,0(a4)
ffffffe000204738:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i)
ffffffe00020473c:	fe843783          	ld	a5,-24(s0)
ffffffe000204740:	00178793          	addi	a5,a5,1
ffffffe000204744:	fef43423          	sd	a5,-24(s0)
ffffffe000204748:	fe843703          	ld	a4,-24(s0)
ffffffe00020474c:	fb843783          	ld	a5,-72(s0)
ffffffe000204750:	fcf766e3          	bltu	a4,a5,ffffffe00020471c <memcpy+0x30>
    return dst;
ffffffe000204754:	fc843783          	ld	a5,-56(s0)
}
ffffffe000204758:	00078513          	mv	a0,a5
ffffffe00020475c:	04813403          	ld	s0,72(sp)
ffffffe000204760:	05010113          	addi	sp,sp,80
ffffffe000204764:	00008067          	ret

ffffffe000204768 <memcmp>:
int memcmp(const void *s1, const void *s2, uint64_t n) {
ffffffe000204768:	fb010113          	addi	sp,sp,-80
ffffffe00020476c:	04813423          	sd	s0,72(sp)
ffffffe000204770:	05010413          	addi	s0,sp,80
ffffffe000204774:	fca43423          	sd	a0,-56(s0)
ffffffe000204778:	fcb43023          	sd	a1,-64(s0)
ffffffe00020477c:	fac43c23          	sd	a2,-72(s0)
    const unsigned char *a = (unsigned char *)s1;
ffffffe000204780:	fc843783          	ld	a5,-56(s0)
ffffffe000204784:	fef43023          	sd	a5,-32(s0)
    const unsigned char *b = (unsigned char *)s2;
ffffffe000204788:	fc043783          	ld	a5,-64(s0)
ffffffe00020478c:	fcf43c23          	sd	a5,-40(s0)
    for (uint64_t i = 0; i < n; i++) {
ffffffe000204790:	fe043423          	sd	zero,-24(s0)
ffffffe000204794:	06c0006f          	j	ffffffe000204800 <memcmp+0x98>
        if (a[i] != b[i]) return a[i] - b[i];
ffffffe000204798:	fe043703          	ld	a4,-32(s0)
ffffffe00020479c:	fe843783          	ld	a5,-24(s0)
ffffffe0002047a0:	00f707b3          	add	a5,a4,a5
ffffffe0002047a4:	0007c683          	lbu	a3,0(a5)
ffffffe0002047a8:	fd843703          	ld	a4,-40(s0)
ffffffe0002047ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002047b0:	00f707b3          	add	a5,a4,a5
ffffffe0002047b4:	0007c783          	lbu	a5,0(a5)
ffffffe0002047b8:	00068713          	mv	a4,a3
ffffffe0002047bc:	02f70c63          	beq	a4,a5,ffffffe0002047f4 <memcmp+0x8c>
ffffffe0002047c0:	fe043703          	ld	a4,-32(s0)
ffffffe0002047c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002047c8:	00f707b3          	add	a5,a4,a5
ffffffe0002047cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002047d0:	0007871b          	sext.w	a4,a5
ffffffe0002047d4:	fd843683          	ld	a3,-40(s0)
ffffffe0002047d8:	fe843783          	ld	a5,-24(s0)
ffffffe0002047dc:	00f687b3          	add	a5,a3,a5
ffffffe0002047e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002047e4:	0007879b          	sext.w	a5,a5
ffffffe0002047e8:	40f707bb          	subw	a5,a4,a5
ffffffe0002047ec:	0007879b          	sext.w	a5,a5
ffffffe0002047f0:	0200006f          	j	ffffffe000204810 <memcmp+0xa8>
    for (uint64_t i = 0; i < n; i++) {
ffffffe0002047f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002047f8:	00178793          	addi	a5,a5,1
ffffffe0002047fc:	fef43423          	sd	a5,-24(s0)
ffffffe000204800:	fe843703          	ld	a4,-24(s0)
ffffffe000204804:	fb843783          	ld	a5,-72(s0)
ffffffe000204808:	f8f768e3          	bltu	a4,a5,ffffffe000204798 <memcmp+0x30>
    }
    return 0;
ffffffe00020480c:	00000793          	li	a5,0
}
ffffffe000204810:	00078513          	mv	a0,a5
ffffffe000204814:	04813403          	ld	s0,72(sp)
ffffffe000204818:	05010113          	addi	sp,sp,80
ffffffe00020481c:	00008067          	ret

ffffffe000204820 <strlen>:

int strlen(const char *str) {
ffffffe000204820:	fd010113          	addi	sp,sp,-48
ffffffe000204824:	02813423          	sd	s0,40(sp)
ffffffe000204828:	03010413          	addi	s0,sp,48
ffffffe00020482c:	fca43c23          	sd	a0,-40(s0)
    int len = 0;
ffffffe000204830:	fe042623          	sw	zero,-20(s0)
    while (*str++)
ffffffe000204834:	0100006f          	j	ffffffe000204844 <strlen+0x24>
        len++;
ffffffe000204838:	fec42783          	lw	a5,-20(s0)
ffffffe00020483c:	0017879b          	addiw	a5,a5,1
ffffffe000204840:	fef42623          	sw	a5,-20(s0)
    while (*str++)
ffffffe000204844:	fd843783          	ld	a5,-40(s0)
ffffffe000204848:	00178713          	addi	a4,a5,1
ffffffe00020484c:	fce43c23          	sd	a4,-40(s0)
ffffffe000204850:	0007c783          	lbu	a5,0(a5)
ffffffe000204854:	fe0792e3          	bnez	a5,ffffffe000204838 <strlen+0x18>
    return len;
ffffffe000204858:	fec42783          	lw	a5,-20(s0)
ffffffe00020485c:	00078513          	mv	a0,a5
ffffffe000204860:	02813403          	ld	s0,40(sp)
ffffffe000204864:	03010113          	addi	sp,sp,48
ffffffe000204868:	00008067          	ret

ffffffe00020486c <cluster_to_sector>:
struct fat32_volume fat32_volume;

uint8_t fat32_buf[VIRTIO_BLK_SECTOR_SIZE];
uint8_t fat32_table_buf[VIRTIO_BLK_SECTOR_SIZE];

uint64_t cluster_to_sector(uint64_t cluster) {
ffffffe00020486c:	fe010113          	addi	sp,sp,-32
ffffffe000204870:	00813c23          	sd	s0,24(sp)
ffffffe000204874:	02010413          	addi	s0,sp,32
ffffffe000204878:	fea43423          	sd	a0,-24(s0)
    return (cluster - 2) * fat32_volume.sec_per_cluster + fat32_volume.first_data_sec;
ffffffe00020487c:	fe843783          	ld	a5,-24(s0)
ffffffe000204880:	ffe78713          	addi	a4,a5,-2
ffffffe000204884:	0040c797          	auipc	a5,0x40c
ffffffe000204888:	97c78793          	addi	a5,a5,-1668 # ffffffe000610200 <fat32_volume>
ffffffe00020488c:	0107b783          	ld	a5,16(a5)
ffffffe000204890:	02f70733          	mul	a4,a4,a5
ffffffe000204894:	0040c797          	auipc	a5,0x40c
ffffffe000204898:	96c78793          	addi	a5,a5,-1684 # ffffffe000610200 <fat32_volume>
ffffffe00020489c:	0007b783          	ld	a5,0(a5)
ffffffe0002048a0:	00f707b3          	add	a5,a4,a5
}
ffffffe0002048a4:	00078513          	mv	a0,a5
ffffffe0002048a8:	01813403          	ld	s0,24(sp)
ffffffe0002048ac:	02010113          	addi	sp,sp,32
ffffffe0002048b0:	00008067          	ret

ffffffe0002048b4 <next_cluster>:

uint32_t next_cluster(uint64_t cluster) {
ffffffe0002048b4:	fc010113          	addi	sp,sp,-64
ffffffe0002048b8:	02113c23          	sd	ra,56(sp)
ffffffe0002048bc:	02813823          	sd	s0,48(sp)
ffffffe0002048c0:	04010413          	addi	s0,sp,64
ffffffe0002048c4:	fca43423          	sd	a0,-56(s0)
    uint64_t fat_offset = cluster * 4;
ffffffe0002048c8:	fc843783          	ld	a5,-56(s0)
ffffffe0002048cc:	00279793          	slli	a5,a5,0x2
ffffffe0002048d0:	fef43423          	sd	a5,-24(s0)
    uint64_t fat_sector = fat32_volume.first_fat_sec + fat_offset / VIRTIO_BLK_SECTOR_SIZE;
ffffffe0002048d4:	0040c797          	auipc	a5,0x40c
ffffffe0002048d8:	92c78793          	addi	a5,a5,-1748 # ffffffe000610200 <fat32_volume>
ffffffe0002048dc:	0087b703          	ld	a4,8(a5)
ffffffe0002048e0:	fe843783          	ld	a5,-24(s0)
ffffffe0002048e4:	0097d793          	srli	a5,a5,0x9
ffffffe0002048e8:	00f707b3          	add	a5,a4,a5
ffffffe0002048ec:	fef43023          	sd	a5,-32(s0)
    virtio_blk_read_sector(fat_sector, fat32_table_buf);
ffffffe0002048f0:	0040c597          	auipc	a1,0x40c
ffffffe0002048f4:	b3058593          	addi	a1,a1,-1232 # ffffffe000610420 <fat32_table_buf>
ffffffe0002048f8:	fe043503          	ld	a0,-32(s0)
ffffffe0002048fc:	271010ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    int index_in_sector = fat_offset % (VIRTIO_BLK_SECTOR_SIZE / sizeof(uint32_t));
ffffffe000204900:	fe843783          	ld	a5,-24(s0)
ffffffe000204904:	0007879b          	sext.w	a5,a5
ffffffe000204908:	07f7f793          	andi	a5,a5,127
ffffffe00020490c:	fcf42e23          	sw	a5,-36(s0)
    return *(uint32_t*)(fat32_table_buf + index_in_sector);
ffffffe000204910:	fdc42703          	lw	a4,-36(s0)
ffffffe000204914:	0040c797          	auipc	a5,0x40c
ffffffe000204918:	b0c78793          	addi	a5,a5,-1268 # ffffffe000610420 <fat32_table_buf>
ffffffe00020491c:	00f707b3          	add	a5,a4,a5
ffffffe000204920:	0007a783          	lw	a5,0(a5)
}
ffffffe000204924:	00078513          	mv	a0,a5
ffffffe000204928:	03813083          	ld	ra,56(sp)
ffffffe00020492c:	03013403          	ld	s0,48(sp)
ffffffe000204930:	04010113          	addi	sp,sp,64
ffffffe000204934:	00008067          	ret

ffffffe000204938 <fat32_init>:

void fat32_init(uint64_t lba, uint64_t size) {
ffffffe000204938:	fe010113          	addi	sp,sp,-32
ffffffe00020493c:	00113c23          	sd	ra,24(sp)
ffffffe000204940:	00813823          	sd	s0,16(sp)
ffffffe000204944:	02010413          	addi	s0,sp,32
ffffffe000204948:	fea43423          	sd	a0,-24(s0)
ffffffe00020494c:	feb43023          	sd	a1,-32(s0)
    // 根据fat32_bpb的数据，计算并初始化fat32_volume元数据
    // 将磁盘上lba扇区的内容读到内存中，获得header内的信息
    virtio_blk_read_sector(lba, (void*)&fat32_header);
ffffffe000204950:	0040b597          	auipc	a1,0x40b
ffffffe000204954:	6b058593          	addi	a1,a1,1712 # ffffffe000610000 <fat32_header>
ffffffe000204958:	fe843503          	ld	a0,-24(s0)
ffffffe00020495c:	211010ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    // 第一个FAT表所在的扇区号：FAT分区起点扇区号+FAT头的总扇区数
    fat32_volume.first_fat_sec = lba + fat32_header.rsvd_sec_cnt;
ffffffe000204960:	0040b797          	auipc	a5,0x40b
ffffffe000204964:	6a078793          	addi	a5,a5,1696 # ffffffe000610000 <fat32_header>
ffffffe000204968:	00e7d783          	lhu	a5,14(a5)
ffffffe00020496c:	00078713          	mv	a4,a5
ffffffe000204970:	fe843783          	ld	a5,-24(s0)
ffffffe000204974:	00f70733          	add	a4,a4,a5
ffffffe000204978:	0040c797          	auipc	a5,0x40c
ffffffe00020497c:	88878793          	addi	a5,a5,-1912 # ffffffe000610200 <fat32_volume>
ffffffe000204980:	00e7b423          	sd	a4,8(a5)
    // 每个簇的扇区数
    fat32_volume.sec_per_cluster = fat32_header.sec_per_clus;
ffffffe000204984:	0040b797          	auipc	a5,0x40b
ffffffe000204988:	67c78793          	addi	a5,a5,1660 # ffffffe000610000 <fat32_header>
ffffffe00020498c:	00d7c783          	lbu	a5,13(a5)
ffffffe000204990:	00078713          	mv	a4,a5
ffffffe000204994:	0040c797          	auipc	a5,0x40c
ffffffe000204998:	86c78793          	addi	a5,a5,-1940 # ffffffe000610200 <fat32_volume>
ffffffe00020499c:	00e7b823          	sd	a4,16(a5)
    // FAT数据区的起始扇区号：FAT起始扇区号 + FAT头扇区数 + FAT表数 * 每个表的扇区数
    fat32_volume.first_data_sec = lba + fat32_header.rsvd_sec_cnt + fat32_header.num_fats * fat32_header.fat_sz32;
ffffffe0002049a0:	0040b797          	auipc	a5,0x40b
ffffffe0002049a4:	66078793          	addi	a5,a5,1632 # ffffffe000610000 <fat32_header>
ffffffe0002049a8:	00e7d783          	lhu	a5,14(a5)
ffffffe0002049ac:	00078713          	mv	a4,a5
ffffffe0002049b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002049b4:	00f70733          	add	a4,a4,a5
ffffffe0002049b8:	0040b797          	auipc	a5,0x40b
ffffffe0002049bc:	64878793          	addi	a5,a5,1608 # ffffffe000610000 <fat32_header>
ffffffe0002049c0:	0107c783          	lbu	a5,16(a5)
ffffffe0002049c4:	0007869b          	sext.w	a3,a5
ffffffe0002049c8:	0040b797          	auipc	a5,0x40b
ffffffe0002049cc:	63878793          	addi	a5,a5,1592 # ffffffe000610000 <fat32_header>
ffffffe0002049d0:	0247a783          	lw	a5,36(a5)
ffffffe0002049d4:	02f687bb          	mulw	a5,a3,a5
ffffffe0002049d8:	0007879b          	sext.w	a5,a5
ffffffe0002049dc:	02079793          	slli	a5,a5,0x20
ffffffe0002049e0:	0207d793          	srli	a5,a5,0x20
ffffffe0002049e4:	00f70733          	add	a4,a4,a5
ffffffe0002049e8:	0040c797          	auipc	a5,0x40c
ffffffe0002049ec:	81878793          	addi	a5,a5,-2024 # ffffffe000610200 <fat32_volume>
ffffffe0002049f0:	00e7b023          	sd	a4,0(a5)
    // 每个FAT表所占的扇区数
    fat32_volume.fat_sz = fat32_header.fat_sz32;
ffffffe0002049f4:	0040b797          	auipc	a5,0x40b
ffffffe0002049f8:	60c78793          	addi	a5,a5,1548 # ffffffe000610000 <fat32_header>
ffffffe0002049fc:	0247a783          	lw	a5,36(a5)
ffffffe000204a00:	02079713          	slli	a4,a5,0x20
ffffffe000204a04:	02075713          	srli	a4,a4,0x20
ffffffe000204a08:	0040b797          	auipc	a5,0x40b
ffffffe000204a0c:	7f878793          	addi	a5,a5,2040 # ffffffe000610200 <fat32_volume>
ffffffe000204a10:	00e7bc23          	sd	a4,24(a5)
}
ffffffe000204a14:	00000013          	nop
ffffffe000204a18:	01813083          	ld	ra,24(sp)
ffffffe000204a1c:	01013403          	ld	s0,16(sp)
ffffffe000204a20:	02010113          	addi	sp,sp,32
ffffffe000204a24:	00008067          	ret

ffffffe000204a28 <is_fat32>:

int is_fat32(uint64_t lba) {
ffffffe000204a28:	fe010113          	addi	sp,sp,-32
ffffffe000204a2c:	00113c23          	sd	ra,24(sp)
ffffffe000204a30:	00813823          	sd	s0,16(sp)
ffffffe000204a34:	02010413          	addi	s0,sp,32
ffffffe000204a38:	fea43423          	sd	a0,-24(s0)
    virtio_blk_read_sector(lba, (void*)&fat32_header);
ffffffe000204a3c:	0040b597          	auipc	a1,0x40b
ffffffe000204a40:	5c458593          	addi	a1,a1,1476 # ffffffe000610000 <fat32_header>
ffffffe000204a44:	fe843503          	ld	a0,-24(s0)
ffffffe000204a48:	125010ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    if (fat32_header.boot_sector_signature != 0xaa55) {
ffffffe000204a4c:	0040b797          	auipc	a5,0x40b
ffffffe000204a50:	5b478793          	addi	a5,a5,1460 # ffffffe000610000 <fat32_header>
ffffffe000204a54:	1fe7d783          	lhu	a5,510(a5)
ffffffe000204a58:	0007871b          	sext.w	a4,a5
ffffffe000204a5c:	0000b7b7          	lui	a5,0xb
ffffffe000204a60:	a5578793          	addi	a5,a5,-1451 # aa55 <PGSIZE+0x9a55>
ffffffe000204a64:	00f70663          	beq	a4,a5,ffffffe000204a70 <is_fat32+0x48>
        return 0;
ffffffe000204a68:	00000793          	li	a5,0
ffffffe000204a6c:	0080006f          	j	ffffffe000204a74 <is_fat32+0x4c>
    }
    return 1;
ffffffe000204a70:	00100793          	li	a5,1
}
ffffffe000204a74:	00078513          	mv	a0,a5
ffffffe000204a78:	01813083          	ld	ra,24(sp)
ffffffe000204a7c:	01013403          	ld	s0,16(sp)
ffffffe000204a80:	02010113          	addi	sp,sp,32
ffffffe000204a84:	00008067          	ret

ffffffe000204a88 <next_slash>:

int next_slash(const char* path) {  // util function to be used in fat32_open_file
ffffffe000204a88:	fd010113          	addi	sp,sp,-48
ffffffe000204a8c:	02813423          	sd	s0,40(sp)
ffffffe000204a90:	03010413          	addi	s0,sp,48
ffffffe000204a94:	fca43c23          	sd	a0,-40(s0)
    int i = 0;
ffffffe000204a98:	fe042623          	sw	zero,-20(s0)
    while (path[i] != '\0' && path[i] != '/') {
ffffffe000204a9c:	0100006f          	j	ffffffe000204aac <next_slash+0x24>
        i++;
ffffffe000204aa0:	fec42783          	lw	a5,-20(s0)
ffffffe000204aa4:	0017879b          	addiw	a5,a5,1
ffffffe000204aa8:	fef42623          	sw	a5,-20(s0)
    while (path[i] != '\0' && path[i] != '/') {
ffffffe000204aac:	fec42783          	lw	a5,-20(s0)
ffffffe000204ab0:	fd843703          	ld	a4,-40(s0)
ffffffe000204ab4:	00f707b3          	add	a5,a4,a5
ffffffe000204ab8:	0007c783          	lbu	a5,0(a5)
ffffffe000204abc:	02078063          	beqz	a5,ffffffe000204adc <next_slash+0x54>
ffffffe000204ac0:	fec42783          	lw	a5,-20(s0)
ffffffe000204ac4:	fd843703          	ld	a4,-40(s0)
ffffffe000204ac8:	00f707b3          	add	a5,a4,a5
ffffffe000204acc:	0007c783          	lbu	a5,0(a5)
ffffffe000204ad0:	00078713          	mv	a4,a5
ffffffe000204ad4:	02f00793          	li	a5,47
ffffffe000204ad8:	fcf714e3          	bne	a4,a5,ffffffe000204aa0 <next_slash+0x18>
    }
    if (path[i] == '\0') {
ffffffe000204adc:	fec42783          	lw	a5,-20(s0)
ffffffe000204ae0:	fd843703          	ld	a4,-40(s0)
ffffffe000204ae4:	00f707b3          	add	a5,a4,a5
ffffffe000204ae8:	0007c783          	lbu	a5,0(a5)
ffffffe000204aec:	00079663          	bnez	a5,ffffffe000204af8 <next_slash+0x70>
        return -1;
ffffffe000204af0:	fff00793          	li	a5,-1
ffffffe000204af4:	0080006f          	j	ffffffe000204afc <next_slash+0x74>
    }
    return i;
ffffffe000204af8:	fec42783          	lw	a5,-20(s0)
}
ffffffe000204afc:	00078513          	mv	a0,a5
ffffffe000204b00:	02813403          	ld	s0,40(sp)
ffffffe000204b04:	03010113          	addi	sp,sp,48
ffffffe000204b08:	00008067          	ret

ffffffe000204b0c <to_upper_case>:

void to_upper_case(char *str) {     // util function to be used in fat32_open_file
ffffffe000204b0c:	fd010113          	addi	sp,sp,-48
ffffffe000204b10:	02813423          	sd	s0,40(sp)
ffffffe000204b14:	03010413          	addi	s0,sp,48
ffffffe000204b18:	fca43c23          	sd	a0,-40(s0)
    for (int i = 0; str[i] != '\0'; i++) {
ffffffe000204b1c:	fe042623          	sw	zero,-20(s0)
ffffffe000204b20:	0700006f          	j	ffffffe000204b90 <to_upper_case+0x84>
        if (str[i] >= 'a' && str[i] <= 'z') {
ffffffe000204b24:	fec42783          	lw	a5,-20(s0)
ffffffe000204b28:	fd843703          	ld	a4,-40(s0)
ffffffe000204b2c:	00f707b3          	add	a5,a4,a5
ffffffe000204b30:	0007c783          	lbu	a5,0(a5)
ffffffe000204b34:	00078713          	mv	a4,a5
ffffffe000204b38:	06000793          	li	a5,96
ffffffe000204b3c:	04e7f463          	bgeu	a5,a4,ffffffe000204b84 <to_upper_case+0x78>
ffffffe000204b40:	fec42783          	lw	a5,-20(s0)
ffffffe000204b44:	fd843703          	ld	a4,-40(s0)
ffffffe000204b48:	00f707b3          	add	a5,a4,a5
ffffffe000204b4c:	0007c783          	lbu	a5,0(a5)
ffffffe000204b50:	00078713          	mv	a4,a5
ffffffe000204b54:	07a00793          	li	a5,122
ffffffe000204b58:	02e7e663          	bltu	a5,a4,ffffffe000204b84 <to_upper_case+0x78>
            str[i] -= 32;
ffffffe000204b5c:	fec42783          	lw	a5,-20(s0)
ffffffe000204b60:	fd843703          	ld	a4,-40(s0)
ffffffe000204b64:	00f707b3          	add	a5,a4,a5
ffffffe000204b68:	0007c703          	lbu	a4,0(a5)
ffffffe000204b6c:	fec42783          	lw	a5,-20(s0)
ffffffe000204b70:	fd843683          	ld	a3,-40(s0)
ffffffe000204b74:	00f687b3          	add	a5,a3,a5
ffffffe000204b78:	fe07071b          	addiw	a4,a4,-32
ffffffe000204b7c:	0ff77713          	zext.b	a4,a4
ffffffe000204b80:	00e78023          	sb	a4,0(a5)
    for (int i = 0; str[i] != '\0'; i++) {
ffffffe000204b84:	fec42783          	lw	a5,-20(s0)
ffffffe000204b88:	0017879b          	addiw	a5,a5,1
ffffffe000204b8c:	fef42623          	sw	a5,-20(s0)
ffffffe000204b90:	fec42783          	lw	a5,-20(s0)
ffffffe000204b94:	fd843703          	ld	a4,-40(s0)
ffffffe000204b98:	00f707b3          	add	a5,a4,a5
ffffffe000204b9c:	0007c783          	lbu	a5,0(a5)
ffffffe000204ba0:	f80792e3          	bnez	a5,ffffffe000204b24 <to_upper_case+0x18>
        }
    }
}
ffffffe000204ba4:	00000013          	nop
ffffffe000204ba8:	00000013          	nop
ffffffe000204bac:	02813403          	ld	s0,40(sp)
ffffffe000204bb0:	03010113          	addi	sp,sp,48
ffffffe000204bb4:	00008067          	ret

ffffffe000204bb8 <fat32_open_file>:

struct fat32_file fat32_open_file(const char *path) {
ffffffe000204bb8:	f7010113          	addi	sp,sp,-144
ffffffe000204bbc:	08113423          	sd	ra,136(sp)
ffffffe000204bc0:	08813023          	sd	s0,128(sp)
ffffffe000204bc4:	07213c23          	sd	s2,120(sp)
ffffffe000204bc8:	07313823          	sd	s3,112(sp)
ffffffe000204bcc:	09010413          	addi	s0,sp,144
ffffffe000204bd0:	f6a43c23          	sd	a0,-136(s0)
    // 获取fat32_file和fat32_dir
    struct fat32_file file;
    // 跳过前缀 /fat32/，获取name
    const char *name = path + 7;
ffffffe000204bd4:	f7843783          	ld	a5,-136(s0)
ffffffe000204bd8:	00778793          	addi	a5,a5,7
ffffffe000204bdc:	fcf43423          	sd	a5,-56(s0)
    // fat32文件名格式：8字节文件名+3字节扩展名
    // 截取前8字节中的文件名，不足8字节时，用空格填充
    char target[8];
    for (int i = 0; i < 8; i++) target[i] = ' ';
ffffffe000204be0:	fc042e23          	sw	zero,-36(s0)
ffffffe000204be4:	0240006f          	j	ffffffe000204c08 <fat32_open_file+0x50>
ffffffe000204be8:	fdc42783          	lw	a5,-36(s0)
ffffffe000204bec:	fe078793          	addi	a5,a5,-32
ffffffe000204bf0:	008787b3          	add	a5,a5,s0
ffffffe000204bf4:	02000713          	li	a4,32
ffffffe000204bf8:	fae78423          	sb	a4,-88(a5)
ffffffe000204bfc:	fdc42783          	lw	a5,-36(s0)
ffffffe000204c00:	0017879b          	addiw	a5,a5,1
ffffffe000204c04:	fcf42e23          	sw	a5,-36(s0)
ffffffe000204c08:	fdc42783          	lw	a5,-36(s0)
ffffffe000204c0c:	0007871b          	sext.w	a4,a5
ffffffe000204c10:	00700793          	li	a5,7
ffffffe000204c14:	fce7dae3          	bge	a5,a4,ffffffe000204be8 <fat32_open_file+0x30>
    int len = 0;
ffffffe000204c18:	fc042c23          	sw	zero,-40(s0)
    while (name[len] && len < 8 && name[len] != '/') {
ffffffe000204c1c:	0300006f          	j	ffffffe000204c4c <fat32_open_file+0x94>
        target[len] = name[len];
ffffffe000204c20:	fd842783          	lw	a5,-40(s0)
ffffffe000204c24:	fc843703          	ld	a4,-56(s0)
ffffffe000204c28:	00f707b3          	add	a5,a4,a5
ffffffe000204c2c:	0007c703          	lbu	a4,0(a5)
ffffffe000204c30:	fd842783          	lw	a5,-40(s0)
ffffffe000204c34:	fe078793          	addi	a5,a5,-32
ffffffe000204c38:	008787b3          	add	a5,a5,s0
ffffffe000204c3c:	fae78423          	sb	a4,-88(a5)
        len++;
ffffffe000204c40:	fd842783          	lw	a5,-40(s0)
ffffffe000204c44:	0017879b          	addiw	a5,a5,1
ffffffe000204c48:	fcf42c23          	sw	a5,-40(s0)
    while (name[len] && len < 8 && name[len] != '/') {
ffffffe000204c4c:	fd842783          	lw	a5,-40(s0)
ffffffe000204c50:	fc843703          	ld	a4,-56(s0)
ffffffe000204c54:	00f707b3          	add	a5,a4,a5
ffffffe000204c58:	0007c783          	lbu	a5,0(a5)
ffffffe000204c5c:	02078863          	beqz	a5,ffffffe000204c8c <fat32_open_file+0xd4>
ffffffe000204c60:	fd842783          	lw	a5,-40(s0)
ffffffe000204c64:	0007871b          	sext.w	a4,a5
ffffffe000204c68:	00700793          	li	a5,7
ffffffe000204c6c:	02e7c063          	blt	a5,a4,ffffffe000204c8c <fat32_open_file+0xd4>
ffffffe000204c70:	fd842783          	lw	a5,-40(s0)
ffffffe000204c74:	fc843703          	ld	a4,-56(s0)
ffffffe000204c78:	00f707b3          	add	a5,a4,a5
ffffffe000204c7c:	0007c783          	lbu	a5,0(a5)
ffffffe000204c80:	00078713          	mv	a4,a5
ffffffe000204c84:	02f00793          	li	a5,47
ffffffe000204c88:	f8f71ce3          	bne	a4,a5,ffffffe000204c20 <fat32_open_file+0x68>
    }
    // 不区分大小写，统一转换为大写
    to_upper_case(target);
ffffffe000204c8c:	f8840793          	addi	a5,s0,-120
ffffffe000204c90:	00078513          	mv	a0,a5
ffffffe000204c94:	e79ff0ef          	jal	ffffffe000204b0c <to_upper_case>
    
    // 文件保存在根目录下
    uint64_t dir_cluster = fat32_header.root_clus;
ffffffe000204c98:	0040b797          	auipc	a5,0x40b
ffffffe000204c9c:	36878793          	addi	a5,a5,872 # ffffffe000610000 <fat32_header>
ffffffe000204ca0:	02c7a783          	lw	a5,44(a5)
ffffffe000204ca4:	02079793          	slli	a5,a5,0x20
ffffffe000204ca8:	0207d793          	srli	a5,a5,0x20
ffffffe000204cac:	fcf43023          	sd	a5,-64(s0)
    uint64_t sector = cluster_to_sector(dir_cluster);
ffffffe000204cb0:	fc043503          	ld	a0,-64(s0)
ffffffe000204cb4:	bb9ff0ef          	jal	ffffffe00020486c <cluster_to_sector>
ffffffe000204cb8:	faa43c23          	sd	a0,-72(s0)
    // 读取扇区
    virtio_blk_read_sector(sector, fat32_buf);
ffffffe000204cbc:	0040b597          	auipc	a1,0x40b
ffffffe000204cc0:	56458593          	addi	a1,a1,1380 # ffffffe000610220 <fat32_buf>
ffffffe000204cc4:	fb843503          	ld	a0,-72(s0)
ffffffe000204cc8:	6a4010ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    struct fat32_dir_entry *entries = (struct fat32_dir_entry*)fat32_buf;
ffffffe000204ccc:	0040b797          	auipc	a5,0x40b
ffffffe000204cd0:	55478793          	addi	a5,a5,1364 # ffffffe000610220 <fat32_buf>
ffffffe000204cd4:	faf43823          	sd	a5,-80(s0)

    for (int i = 0; i < FAT32_ENTRY_PER_SECTOR; i++) {
ffffffe000204cd8:	fc042a23          	sw	zero,-44(s0)
ffffffe000204cdc:	1380006f          	j	ffffffe000204e14 <fat32_open_file+0x25c>
        // 遍历根目录扇区内的所有文件
        if (entries[i].name[0] == 0x00) {
ffffffe000204ce0:	fd442783          	lw	a5,-44(s0)
ffffffe000204ce4:	00579793          	slli	a5,a5,0x5
ffffffe000204ce8:	fb043703          	ld	a4,-80(s0)
ffffffe000204cec:	00f707b3          	add	a5,a4,a5
ffffffe000204cf0:	0007c783          	lbu	a5,0(a5)
ffffffe000204cf4:	12078a63          	beqz	a5,ffffffe000204e28 <fat32_open_file+0x270>
            // 列表结束
            break;
        }
        if (entries[i].attr == 0x0F) {
ffffffe000204cf8:	fd442783          	lw	a5,-44(s0)
ffffffe000204cfc:	00579793          	slli	a5,a5,0x5
ffffffe000204d00:	fb043703          	ld	a4,-80(s0)
ffffffe000204d04:	00f707b3          	add	a5,a4,a5
ffffffe000204d08:	00b7c783          	lbu	a5,11(a5)
ffffffe000204d0c:	00078713          	mv	a4,a5
ffffffe000204d10:	00f00793          	li	a5,15
ffffffe000204d14:	0ef70463          	beq	a4,a5,ffffffe000204dfc <fat32_open_file+0x244>
            // 长文件名
            continue;
        }
        if (entries[i].name[0] == 0xE5) {
ffffffe000204d18:	fd442783          	lw	a5,-44(s0)
ffffffe000204d1c:	00579793          	slli	a5,a5,0x5
ffffffe000204d20:	fb043703          	ld	a4,-80(s0)
ffffffe000204d24:	00f707b3          	add	a5,a4,a5
ffffffe000204d28:	0007c783          	lbu	a5,0(a5)
ffffffe000204d2c:	00078713          	mv	a4,a5
ffffffe000204d30:	0e500793          	li	a5,229
ffffffe000204d34:	0cf70863          	beq	a4,a5,ffffffe000204e04 <fat32_open_file+0x24c>
            // 目录已删除
            continue;
        }
        // 提取文件名
        char entry_name[8];
        memcpy(entry_name, entries[i].name, 8);
ffffffe000204d38:	fd442783          	lw	a5,-44(s0)
ffffffe000204d3c:	00579793          	slli	a5,a5,0x5
ffffffe000204d40:	fb043703          	ld	a4,-80(s0)
ffffffe000204d44:	00f707b3          	add	a5,a4,a5
ffffffe000204d48:	00078713          	mv	a4,a5
ffffffe000204d4c:	f8040793          	addi	a5,s0,-128
ffffffe000204d50:	00800613          	li	a2,8
ffffffe000204d54:	00070593          	mv	a1,a4
ffffffe000204d58:	00078513          	mv	a0,a5
ffffffe000204d5c:	991ff0ef          	jal	ffffffe0002046ec <memcpy>
        to_upper_case(entry_name);
ffffffe000204d60:	f8040793          	addi	a5,s0,-128
ffffffe000204d64:	00078513          	mv	a0,a5
ffffffe000204d68:	da5ff0ef          	jal	ffffffe000204b0c <to_upper_case>

        // 匹配目标文件名和目录文件名
        if (memcmp(entry_name, target, 8) == 0) {
ffffffe000204d6c:	f8840713          	addi	a4,s0,-120
ffffffe000204d70:	f8040793          	addi	a5,s0,-128
ffffffe000204d74:	00800613          	li	a2,8
ffffffe000204d78:	00070593          	mv	a1,a4
ffffffe000204d7c:	00078513          	mv	a0,a5
ffffffe000204d80:	9e9ff0ef          	jal	ffffffe000204768 <memcmp>
ffffffe000204d84:	00050793          	mv	a5,a0
ffffffe000204d88:	08079063          	bnez	a5,ffffffe000204e08 <fat32_open_file+0x250>
            file.cluster = (entries[i].starthi << 16) | entries[i].startlow;
ffffffe000204d8c:	fd442783          	lw	a5,-44(s0)
ffffffe000204d90:	00579793          	slli	a5,a5,0x5
ffffffe000204d94:	fb043703          	ld	a4,-80(s0)
ffffffe000204d98:	00f707b3          	add	a5,a4,a5
ffffffe000204d9c:	0147d783          	lhu	a5,20(a5)
ffffffe000204da0:	0007879b          	sext.w	a5,a5
ffffffe000204da4:	0107979b          	slliw	a5,a5,0x10
ffffffe000204da8:	0007871b          	sext.w	a4,a5
ffffffe000204dac:	fd442783          	lw	a5,-44(s0)
ffffffe000204db0:	00579793          	slli	a5,a5,0x5
ffffffe000204db4:	fb043683          	ld	a3,-80(s0)
ffffffe000204db8:	00f687b3          	add	a5,a3,a5
ffffffe000204dbc:	01a7d783          	lhu	a5,26(a5)
ffffffe000204dc0:	0007879b          	sext.w	a5,a5
ffffffe000204dc4:	00f767b3          	or	a5,a4,a5
ffffffe000204dc8:	0007879b          	sext.w	a5,a5
ffffffe000204dcc:	0007879b          	sext.w	a5,a5
ffffffe000204dd0:	f8f42823          	sw	a5,-112(s0)
            file.dir.cluster = dir_cluster;
ffffffe000204dd4:	fc043783          	ld	a5,-64(s0)
ffffffe000204dd8:	0007879b          	sext.w	a5,a5
ffffffe000204ddc:	f8f42a23          	sw	a5,-108(s0)
            file.dir.index = i;
ffffffe000204de0:	fd442783          	lw	a5,-44(s0)
ffffffe000204de4:	f8f42c23          	sw	a5,-104(s0)
            return file;
ffffffe000204de8:	f9043783          	ld	a5,-112(s0)
ffffffe000204dec:	faf43023          	sd	a5,-96(s0)
ffffffe000204df0:	f9842783          	lw	a5,-104(s0)
ffffffe000204df4:	faf42423          	sw	a5,-88(s0)
ffffffe000204df8:	0480006f          	j	ffffffe000204e40 <fat32_open_file+0x288>
            continue;
ffffffe000204dfc:	00000013          	nop
ffffffe000204e00:	0080006f          	j	ffffffe000204e08 <fat32_open_file+0x250>
            continue;
ffffffe000204e04:	00000013          	nop
    for (int i = 0; i < FAT32_ENTRY_PER_SECTOR; i++) {
ffffffe000204e08:	fd442783          	lw	a5,-44(s0)
ffffffe000204e0c:	0017879b          	addiw	a5,a5,1
ffffffe000204e10:	fcf42a23          	sw	a5,-44(s0)
ffffffe000204e14:	fd442783          	lw	a5,-44(s0)
ffffffe000204e18:	00078713          	mv	a4,a5
ffffffe000204e1c:	00f00793          	li	a5,15
ffffffe000204e20:	ece7f0e3          	bgeu	a5,a4,ffffffe000204ce0 <fat32_open_file+0x128>
ffffffe000204e24:	0080006f          	j	ffffffe000204e2c <fat32_open_file+0x274>
            break;
ffffffe000204e28:	00000013          	nop
        }
    }
    // 找不到对应的文件，返回无效簇号
    file.cluster = 0;
ffffffe000204e2c:	f8042823          	sw	zero,-112(s0)
    return file;
ffffffe000204e30:	f9043783          	ld	a5,-112(s0)
ffffffe000204e34:	faf43023          	sd	a5,-96(s0)
ffffffe000204e38:	f9842783          	lw	a5,-104(s0)
ffffffe000204e3c:	faf42423          	sw	a5,-88(s0)
}
ffffffe000204e40:	00000793          	li	a5,0
ffffffe000204e44:	fa046683          	lwu	a3,-96(s0)
ffffffe000204e48:	fff00713          	li	a4,-1
ffffffe000204e4c:	02075713          	srli	a4,a4,0x20
ffffffe000204e50:	00e6f733          	and	a4,a3,a4
ffffffe000204e54:	fff00693          	li	a3,-1
ffffffe000204e58:	02069693          	slli	a3,a3,0x20
ffffffe000204e5c:	00d7f7b3          	and	a5,a5,a3
ffffffe000204e60:	00e7e7b3          	or	a5,a5,a4
ffffffe000204e64:	fa446703          	lwu	a4,-92(s0)
ffffffe000204e68:	02071713          	slli	a4,a4,0x20
ffffffe000204e6c:	fff00693          	li	a3,-1
ffffffe000204e70:	0206d693          	srli	a3,a3,0x20
ffffffe000204e74:	00d7f7b3          	and	a5,a5,a3
ffffffe000204e78:	00e7e7b3          	or	a5,a5,a4
ffffffe000204e7c:	00000713          	li	a4,0
ffffffe000204e80:	fa846603          	lwu	a2,-88(s0)
ffffffe000204e84:	fff00693          	li	a3,-1
ffffffe000204e88:	0206d693          	srli	a3,a3,0x20
ffffffe000204e8c:	00d676b3          	and	a3,a2,a3
ffffffe000204e90:	fff00613          	li	a2,-1
ffffffe000204e94:	02061613          	slli	a2,a2,0x20
ffffffe000204e98:	00c77733          	and	a4,a4,a2
ffffffe000204e9c:	00d76733          	or	a4,a4,a3
ffffffe000204ea0:	00078913          	mv	s2,a5
ffffffe000204ea4:	00070993          	mv	s3,a4
ffffffe000204ea8:	00090713          	mv	a4,s2
ffffffe000204eac:	00098793          	mv	a5,s3
ffffffe000204eb0:	00070513          	mv	a0,a4
ffffffe000204eb4:	00078593          	mv	a1,a5
ffffffe000204eb8:	08813083          	ld	ra,136(sp)
ffffffe000204ebc:	08013403          	ld	s0,128(sp)
ffffffe000204ec0:	07813903          	ld	s2,120(sp)
ffffffe000204ec4:	07013983          	ld	s3,112(sp)
ffffffe000204ec8:	09010113          	addi	sp,sp,144
ffffffe000204ecc:	00008067          	ret

ffffffe000204ed0 <fat32_lseek>:

int64_t fat32_lseek(struct file* file, int64_t offset, uint64_t whence) {
ffffffe000204ed0:	fc010113          	addi	sp,sp,-64
ffffffe000204ed4:	02113c23          	sd	ra,56(sp)
ffffffe000204ed8:	02813823          	sd	s0,48(sp)
ffffffe000204edc:	04010413          	addi	s0,sp,64
ffffffe000204ee0:	fca43c23          	sd	a0,-40(s0)
ffffffe000204ee4:	fcb43823          	sd	a1,-48(s0)
ffffffe000204ee8:	fcc43423          	sd	a2,-56(s0)
    // whence为偏移起点
    uint32_t size = fat32_file_size(file);
ffffffe000204eec:	fd843503          	ld	a0,-40(s0)
ffffffe000204ef0:	52c000ef          	jal	ffffffe00020541c <fat32_file_size>
ffffffe000204ef4:	00050793          	mv	a5,a0
ffffffe000204ef8:	fef42223          	sw	a5,-28(s0)
    int64_t new_cfo = 0;
ffffffe000204efc:	fe043423          	sd	zero,-24(s0)
    if (whence == SEEK_SET) {
ffffffe000204f00:	fc843783          	ld	a5,-56(s0)
ffffffe000204f04:	00079863          	bnez	a5,ffffffe000204f14 <fat32_lseek+0x44>
        // 从文件开头算
        new_cfo = offset;
ffffffe000204f08:	fd043783          	ld	a5,-48(s0)
ffffffe000204f0c:	fef43423          	sd	a5,-24(s0)
ffffffe000204f10:	05c0006f          	j	ffffffe000204f6c <fat32_lseek+0x9c>
    } else if (whence == SEEK_CUR) {
ffffffe000204f14:	fc843703          	ld	a4,-56(s0)
ffffffe000204f18:	00100793          	li	a5,1
ffffffe000204f1c:	00f71e63          	bne	a4,a5,ffffffe000204f38 <fat32_lseek+0x68>
        // 从当前位置算
        new_cfo = offset + file->cfo;
ffffffe000204f20:	fd843783          	ld	a5,-40(s0)
ffffffe000204f24:	0087b783          	ld	a5,8(a5)
ffffffe000204f28:	fd043703          	ld	a4,-48(s0)
ffffffe000204f2c:	00f707b3          	add	a5,a4,a5
ffffffe000204f30:	fef43423          	sd	a5,-24(s0)
ffffffe000204f34:	0380006f          	j	ffffffe000204f6c <fat32_lseek+0x9c>
    } else if (whence == SEEK_END) {
ffffffe000204f38:	fc843703          	ld	a4,-56(s0)
ffffffe000204f3c:	00200793          	li	a5,2
ffffffe000204f40:	00f71c63          	bne	a4,a5,ffffffe000204f58 <fat32_lseek+0x88>
        // 从文件末尾算
        new_cfo = (int64_t)size + offset;
ffffffe000204f44:	fe446783          	lwu	a5,-28(s0)
ffffffe000204f48:	fd043703          	ld	a4,-48(s0)
ffffffe000204f4c:	00f707b3          	add	a5,a4,a5
ffffffe000204f50:	fef43423          	sd	a5,-24(s0)
ffffffe000204f54:	0180006f          	j	ffffffe000204f6c <fat32_lseek+0x9c>
    } else {
        printk("fat32_lseek: whence not implemented\n");
ffffffe000204f58:	00003517          	auipc	a0,0x3
ffffffe000204f5c:	83050513          	addi	a0,a0,-2000 # ffffffe000207788 <lowerxdigits.0+0x20>
ffffffe000204f60:	dfcff0ef          	jal	ffffffe00020455c <printk>
        while (1);
ffffffe000204f64:	00000013          	nop
ffffffe000204f68:	ffdff06f          	j	ffffffe000204f64 <fat32_lseek+0x94>
    }

    if (new_cfo < 0) new_cfo = 0;
ffffffe000204f6c:	fe843783          	ld	a5,-24(s0)
ffffffe000204f70:	0007d463          	bgez	a5,ffffffe000204f78 <fat32_lseek+0xa8>
ffffffe000204f74:	fe043423          	sd	zero,-24(s0)
    if (new_cfo > size) new_cfo = size;
ffffffe000204f78:	fe446783          	lwu	a5,-28(s0)
ffffffe000204f7c:	fe843703          	ld	a4,-24(s0)
ffffffe000204f80:	00e7d663          	bge	a5,a4,ffffffe000204f8c <fat32_lseek+0xbc>
ffffffe000204f84:	fe446783          	lwu	a5,-28(s0)
ffffffe000204f88:	fef43423          	sd	a5,-24(s0)
    file->cfo = new_cfo;
ffffffe000204f8c:	fd843783          	ld	a5,-40(s0)
ffffffe000204f90:	fe843703          	ld	a4,-24(s0)
ffffffe000204f94:	00e7b423          	sd	a4,8(a5)
    return file->cfo;
ffffffe000204f98:	fd843783          	ld	a5,-40(s0)
ffffffe000204f9c:	0087b783          	ld	a5,8(a5)
}
ffffffe000204fa0:	00078513          	mv	a0,a5
ffffffe000204fa4:	03813083          	ld	ra,56(sp)
ffffffe000204fa8:	03013403          	ld	s0,48(sp)
ffffffe000204fac:	04010113          	addi	sp,sp,64
ffffffe000204fb0:	00008067          	ret

ffffffe000204fb4 <fat32_table_sector_of_cluster>:

uint64_t fat32_table_sector_of_cluster(uint32_t cluster) {
ffffffe000204fb4:	fe010113          	addi	sp,sp,-32
ffffffe000204fb8:	00813c23          	sd	s0,24(sp)
ffffffe000204fbc:	02010413          	addi	s0,sp,32
ffffffe000204fc0:	00050793          	mv	a5,a0
ffffffe000204fc4:	fef42623          	sw	a5,-20(s0)
    return fat32_volume.first_fat_sec + cluster / (VIRTIO_BLK_SECTOR_SIZE / sizeof(uint32_t));
ffffffe000204fc8:	0040b797          	auipc	a5,0x40b
ffffffe000204fcc:	23878793          	addi	a5,a5,568 # ffffffe000610200 <fat32_volume>
ffffffe000204fd0:	0087b703          	ld	a4,8(a5)
ffffffe000204fd4:	fec42783          	lw	a5,-20(s0)
ffffffe000204fd8:	0077d79b          	srliw	a5,a5,0x7
ffffffe000204fdc:	0007879b          	sext.w	a5,a5
ffffffe000204fe0:	02079793          	slli	a5,a5,0x20
ffffffe000204fe4:	0207d793          	srli	a5,a5,0x20
ffffffe000204fe8:	00f707b3          	add	a5,a4,a5
}
ffffffe000204fec:	00078513          	mv	a0,a5
ffffffe000204ff0:	01813403          	ld	s0,24(sp)
ffffffe000204ff4:	02010113          	addi	sp,sp,32
ffffffe000204ff8:	00008067          	ret

ffffffe000204ffc <fat32_read>:

int64_t fat32_read(struct file* file, void* buf, uint64_t len) {
ffffffe000204ffc:	f8010113          	addi	sp,sp,-128
ffffffe000205000:	06113c23          	sd	ra,120(sp)
ffffffe000205004:	06813823          	sd	s0,112(sp)
ffffffe000205008:	08010413          	addi	s0,sp,128
ffffffe00020500c:	f8a43c23          	sd	a0,-104(s0)
ffffffe000205010:	f8b43823          	sd	a1,-112(s0)
ffffffe000205014:	f8c43423          	sd	a2,-120(s0)
    /* todo: read content to buf, and return read length */
    // 找到文件所在的簇，读取文件内容
    uint32_t size = fat32_file_size(file);
ffffffe000205018:	f9843503          	ld	a0,-104(s0)
ffffffe00020501c:	400000ef          	jal	ffffffe00020541c <fat32_file_size>
ffffffe000205020:	00050793          	mv	a5,a0
ffffffe000205024:	fcf42223          	sw	a5,-60(s0)
    if (file->cfo >= size) return 0;    // 指针超过文件内容
ffffffe000205028:	f9843783          	ld	a5,-104(s0)
ffffffe00020502c:	0087b703          	ld	a4,8(a5)
ffffffe000205030:	fc446783          	lwu	a5,-60(s0)
ffffffe000205034:	00f74663          	blt	a4,a5,ffffffe000205040 <fat32_read+0x44>
ffffffe000205038:	00000793          	li	a5,0
ffffffe00020503c:	1b40006f          	j	ffffffe0002051f0 <fat32_read+0x1f4>
    if (file->cfo + len > size) {
ffffffe000205040:	f9843783          	ld	a5,-104(s0)
ffffffe000205044:	0087b783          	ld	a5,8(a5)
ffffffe000205048:	00078713          	mv	a4,a5
ffffffe00020504c:	f8843783          	ld	a5,-120(s0)
ffffffe000205050:	00f70733          	add	a4,a4,a5
ffffffe000205054:	fc446783          	lwu	a5,-60(s0)
ffffffe000205058:	00e7fc63          	bgeu	a5,a4,ffffffe000205070 <fat32_read+0x74>
        len = size - file->cfo;     // 截取文件内的内容
ffffffe00020505c:	fc446703          	lwu	a4,-60(s0)
ffffffe000205060:	f9843783          	ld	a5,-104(s0)
ffffffe000205064:	0087b783          	ld	a5,8(a5)
ffffffe000205068:	40f707b3          	sub	a5,a4,a5
ffffffe00020506c:	f8f43423          	sd	a5,-120(s0)
    }

    uint64_t bytes_per_cluster = fat32_volume.sec_per_cluster * VIRTIO_BLK_SECTOR_SIZE;
ffffffe000205070:	0040b797          	auipc	a5,0x40b
ffffffe000205074:	19078793          	addi	a5,a5,400 # ffffffe000610200 <fat32_volume>
ffffffe000205078:	0107b783          	ld	a5,16(a5)
ffffffe00020507c:	00979793          	slli	a5,a5,0x9
ffffffe000205080:	faf43c23          	sd	a5,-72(s0)
    uint64_t cur_cluster = file->fat32_file.cluster;
ffffffe000205084:	f9843783          	ld	a5,-104(s0)
ffffffe000205088:	0147a783          	lw	a5,20(a5)
ffffffe00020508c:	02079793          	slli	a5,a5,0x20
ffffffe000205090:	0207d793          	srli	a5,a5,0x20
ffffffe000205094:	fef43423          	sd	a5,-24(s0)
    // 获取当前cfo的簇号
    uint64_t ptr = file->cfo;
ffffffe000205098:	f9843783          	ld	a5,-104(s0)
ffffffe00020509c:	0087b783          	ld	a5,8(a5)
ffffffe0002050a0:	fef43023          	sd	a5,-32(s0)
    while (ptr >= bytes_per_cluster) {
ffffffe0002050a4:	0300006f          	j	ffffffe0002050d4 <fat32_read+0xd8>
        cur_cluster = next_cluster(cur_cluster);
ffffffe0002050a8:	fe843503          	ld	a0,-24(s0)
ffffffe0002050ac:	809ff0ef          	jal	ffffffe0002048b4 <next_cluster>
ffffffe0002050b0:	00050793          	mv	a5,a0
ffffffe0002050b4:	0007879b          	sext.w	a5,a5
ffffffe0002050b8:	02079793          	slli	a5,a5,0x20
ffffffe0002050bc:	0207d793          	srli	a5,a5,0x20
ffffffe0002050c0:	fef43423          	sd	a5,-24(s0)
        ptr -= bytes_per_cluster;
ffffffe0002050c4:	fe043703          	ld	a4,-32(s0)
ffffffe0002050c8:	fb843783          	ld	a5,-72(s0)
ffffffe0002050cc:	40f707b3          	sub	a5,a4,a5
ffffffe0002050d0:	fef43023          	sd	a5,-32(s0)
    while (ptr >= bytes_per_cluster) {
ffffffe0002050d4:	fe043703          	ld	a4,-32(s0)
ffffffe0002050d8:	fb843783          	ld	a5,-72(s0)
ffffffe0002050dc:	fcf776e3          	bgeu	a4,a5,ffffffe0002050a8 <fat32_read+0xac>
    }
    // 获取簇内偏移
    uint64_t offset = ptr;
ffffffe0002050e0:	fe043783          	ld	a5,-32(s0)
ffffffe0002050e4:	fcf43c23          	sd	a5,-40(s0)
    uint8_t *out = (uint8_t *)buf;
ffffffe0002050e8:	f9043783          	ld	a5,-112(s0)
ffffffe0002050ec:	faf43823          	sd	a5,-80(s0)
    uint64_t copied = 0;
ffffffe0002050f0:	fc043823          	sd	zero,-48(s0)
    while (copied < len && cur_cluster < 0x0FFFFFF8) {
ffffffe0002050f4:	0bc0006f          	j	ffffffe0002051b0 <fat32_read+0x1b4>
        // 扫描文件所在的扇区并读
        uint64_t sector = cluster_to_sector(cur_cluster);
ffffffe0002050f8:	fe843503          	ld	a0,-24(s0)
ffffffe0002050fc:	f70ff0ef          	jal	ffffffe00020486c <cluster_to_sector>
ffffffe000205100:	faa43423          	sd	a0,-88(s0)
        // 读扇区
        virtio_blk_read_sector(sector, fat32_buf);
ffffffe000205104:	0040b597          	auipc	a1,0x40b
ffffffe000205108:	11c58593          	addi	a1,a1,284 # ffffffe000610220 <fat32_buf>
ffffffe00020510c:	fa843503          	ld	a0,-88(s0)
ffffffe000205110:	25c010ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
        uint64_t take = bytes_per_cluster - offset;
ffffffe000205114:	fb843703          	ld	a4,-72(s0)
ffffffe000205118:	fd843783          	ld	a5,-40(s0)
ffffffe00020511c:	40f707b3          	sub	a5,a4,a5
ffffffe000205120:	fcf43423          	sd	a5,-56(s0)
        if (take > len - copied) take = len - copied;
ffffffe000205124:	f8843703          	ld	a4,-120(s0)
ffffffe000205128:	fd043783          	ld	a5,-48(s0)
ffffffe00020512c:	40f707b3          	sub	a5,a4,a5
ffffffe000205130:	fc843703          	ld	a4,-56(s0)
ffffffe000205134:	00e7fa63          	bgeu	a5,a4,ffffffe000205148 <fat32_read+0x14c>
ffffffe000205138:	f8843703          	ld	a4,-120(s0)
ffffffe00020513c:	fd043783          	ld	a5,-48(s0)
ffffffe000205140:	40f707b3          	sub	a5,a4,a5
ffffffe000205144:	fcf43423          	sd	a5,-56(s0)
        memcpy(out + copied, fat32_buf + offset, take);
ffffffe000205148:	fb043703          	ld	a4,-80(s0)
ffffffe00020514c:	fd043783          	ld	a5,-48(s0)
ffffffe000205150:	00f706b3          	add	a3,a4,a5
ffffffe000205154:	fd843703          	ld	a4,-40(s0)
ffffffe000205158:	0040b797          	auipc	a5,0x40b
ffffffe00020515c:	0c878793          	addi	a5,a5,200 # ffffffe000610220 <fat32_buf>
ffffffe000205160:	00f707b3          	add	a5,a4,a5
ffffffe000205164:	fc843603          	ld	a2,-56(s0)
ffffffe000205168:	00078593          	mv	a1,a5
ffffffe00020516c:	00068513          	mv	a0,a3
ffffffe000205170:	d7cff0ef          	jal	ffffffe0002046ec <memcpy>
        copied += take;
ffffffe000205174:	fd043703          	ld	a4,-48(s0)
ffffffe000205178:	fc843783          	ld	a5,-56(s0)
ffffffe00020517c:	00f707b3          	add	a5,a4,a5
ffffffe000205180:	fcf43823          	sd	a5,-48(s0)
        offset = 0;
ffffffe000205184:	fc043c23          	sd	zero,-40(s0)
        if (copied < len) {
ffffffe000205188:	fd043703          	ld	a4,-48(s0)
ffffffe00020518c:	f8843783          	ld	a5,-120(s0)
ffffffe000205190:	02f77063          	bgeu	a4,a5,ffffffe0002051b0 <fat32_read+0x1b4>
            cur_cluster = next_cluster(cur_cluster);
ffffffe000205194:	fe843503          	ld	a0,-24(s0)
ffffffe000205198:	f1cff0ef          	jal	ffffffe0002048b4 <next_cluster>
ffffffe00020519c:	00050793          	mv	a5,a0
ffffffe0002051a0:	0007879b          	sext.w	a5,a5
ffffffe0002051a4:	02079793          	slli	a5,a5,0x20
ffffffe0002051a8:	0207d793          	srli	a5,a5,0x20
ffffffe0002051ac:	fef43423          	sd	a5,-24(s0)
    while (copied < len && cur_cluster < 0x0FFFFFF8) {
ffffffe0002051b0:	fd043703          	ld	a4,-48(s0)
ffffffe0002051b4:	f8843783          	ld	a5,-120(s0)
ffffffe0002051b8:	00f77a63          	bgeu	a4,a5,ffffffe0002051cc <fat32_read+0x1d0>
ffffffe0002051bc:	fe843703          	ld	a4,-24(s0)
ffffffe0002051c0:	100007b7          	lui	a5,0x10000
ffffffe0002051c4:	ff778793          	addi	a5,a5,-9 # ffffff7 <PHY_SIZE+0x7fffff7>
ffffffe0002051c8:	f2e7f8e3          	bgeu	a5,a4,ffffffe0002050f8 <fat32_read+0xfc>
        }
    }
    file->cfo += copied;
ffffffe0002051cc:	f9843783          	ld	a5,-104(s0)
ffffffe0002051d0:	0087b783          	ld	a5,8(a5)
ffffffe0002051d4:	00078713          	mv	a4,a5
ffffffe0002051d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002051dc:	00f707b3          	add	a5,a4,a5
ffffffe0002051e0:	00078713          	mv	a4,a5
ffffffe0002051e4:	f9843783          	ld	a5,-104(s0)
ffffffe0002051e8:	00e7b423          	sd	a4,8(a5)
    return copied;
ffffffe0002051ec:	fd043783          	ld	a5,-48(s0)
}
ffffffe0002051f0:	00078513          	mv	a0,a5
ffffffe0002051f4:	07813083          	ld	ra,120(sp)
ffffffe0002051f8:	07013403          	ld	s0,112(sp)
ffffffe0002051fc:	08010113          	addi	sp,sp,128
ffffffe000205200:	00008067          	ret

ffffffe000205204 <fat32_write>:

int64_t fat32_write(struct file* file, const void* buf, uint64_t len) {
ffffffe000205204:	f8010113          	addi	sp,sp,-128
ffffffe000205208:	06113c23          	sd	ra,120(sp)
ffffffe00020520c:	06813823          	sd	s0,112(sp)
ffffffe000205210:	08010413          	addi	s0,sp,128
ffffffe000205214:	f8a43c23          	sd	a0,-104(s0)
ffffffe000205218:	f8b43823          	sd	a1,-112(s0)
ffffffe00020521c:	f8c43423          	sd	a2,-120(s0)
    /* todo: fat32_write */
    uint32_t size = fat32_file_size(file);
ffffffe000205220:	f9843503          	ld	a0,-104(s0)
ffffffe000205224:	1f8000ef          	jal	ffffffe00020541c <fat32_file_size>
ffffffe000205228:	00050793          	mv	a5,a0
ffffffe00020522c:	fcf42223          	sw	a5,-60(s0)
    if (file->cfo >= size) return 0;
ffffffe000205230:	f9843783          	ld	a5,-104(s0)
ffffffe000205234:	0087b703          	ld	a4,8(a5)
ffffffe000205238:	fc446783          	lwu	a5,-60(s0)
ffffffe00020523c:	00f74663          	blt	a4,a5,ffffffe000205248 <fat32_write+0x44>
ffffffe000205240:	00000793          	li	a5,0
ffffffe000205244:	1c40006f          	j	ffffffe000205408 <fat32_write+0x204>
    if (file->cfo + len > size) len = size - file->cfo;
ffffffe000205248:	f9843783          	ld	a5,-104(s0)
ffffffe00020524c:	0087b783          	ld	a5,8(a5)
ffffffe000205250:	00078713          	mv	a4,a5
ffffffe000205254:	f8843783          	ld	a5,-120(s0)
ffffffe000205258:	00f70733          	add	a4,a4,a5
ffffffe00020525c:	fc446783          	lwu	a5,-60(s0)
ffffffe000205260:	00e7fc63          	bgeu	a5,a4,ffffffe000205278 <fat32_write+0x74>
ffffffe000205264:	fc446703          	lwu	a4,-60(s0)
ffffffe000205268:	f9843783          	ld	a5,-104(s0)
ffffffe00020526c:	0087b783          	ld	a5,8(a5)
ffffffe000205270:	40f707b3          	sub	a5,a4,a5
ffffffe000205274:	f8f43423          	sd	a5,-120(s0)

    uint64_t bytes_per_cluster = fat32_volume.sec_per_cluster * VIRTIO_BLK_SECTOR_SIZE;
ffffffe000205278:	0040b797          	auipc	a5,0x40b
ffffffe00020527c:	f8878793          	addi	a5,a5,-120 # ffffffe000610200 <fat32_volume>
ffffffe000205280:	0107b783          	ld	a5,16(a5)
ffffffe000205284:	00979793          	slli	a5,a5,0x9
ffffffe000205288:	faf43c23          	sd	a5,-72(s0)
    uint64_t cur_cluster = file->fat32_file.cluster;
ffffffe00020528c:	f9843783          	ld	a5,-104(s0)
ffffffe000205290:	0147a783          	lw	a5,20(a5)
ffffffe000205294:	02079793          	slli	a5,a5,0x20
ffffffe000205298:	0207d793          	srli	a5,a5,0x20
ffffffe00020529c:	fef43423          	sd	a5,-24(s0)
    // 获取当前cfo的簇号
    uint64_t ptr = file->cfo;
ffffffe0002052a0:	f9843783          	ld	a5,-104(s0)
ffffffe0002052a4:	0087b783          	ld	a5,8(a5)
ffffffe0002052a8:	fef43023          	sd	a5,-32(s0)
    while (ptr >= bytes_per_cluster) {
ffffffe0002052ac:	0300006f          	j	ffffffe0002052dc <fat32_write+0xd8>
        cur_cluster = next_cluster(cur_cluster);
ffffffe0002052b0:	fe843503          	ld	a0,-24(s0)
ffffffe0002052b4:	e00ff0ef          	jal	ffffffe0002048b4 <next_cluster>
ffffffe0002052b8:	00050793          	mv	a5,a0
ffffffe0002052bc:	0007879b          	sext.w	a5,a5
ffffffe0002052c0:	02079793          	slli	a5,a5,0x20
ffffffe0002052c4:	0207d793          	srli	a5,a5,0x20
ffffffe0002052c8:	fef43423          	sd	a5,-24(s0)
        ptr -= bytes_per_cluster;
ffffffe0002052cc:	fe043703          	ld	a4,-32(s0)
ffffffe0002052d0:	fb843783          	ld	a5,-72(s0)
ffffffe0002052d4:	40f707b3          	sub	a5,a4,a5
ffffffe0002052d8:	fef43023          	sd	a5,-32(s0)
    while (ptr >= bytes_per_cluster) {
ffffffe0002052dc:	fe043703          	ld	a4,-32(s0)
ffffffe0002052e0:	fb843783          	ld	a5,-72(s0)
ffffffe0002052e4:	fcf776e3          	bgeu	a4,a5,ffffffe0002052b0 <fat32_write+0xac>
    }
    // 获取簇内偏移
    uint64_t offset = ptr;
ffffffe0002052e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002052ec:	fcf43c23          	sd	a5,-40(s0)
    uint8_t *in = (uint8_t *)buf;
ffffffe0002052f0:	f9043783          	ld	a5,-112(s0)
ffffffe0002052f4:	faf43823          	sd	a5,-80(s0)
    uint64_t written = 0;
ffffffe0002052f8:	fc043823          	sd	zero,-48(s0)
    while (written < len && cur_cluster < 0x0FFFFFF8) {
ffffffe0002052fc:	0cc0006f          	j	ffffffe0002053c8 <fat32_write+0x1c4>
        // 扫描文件所在的扇区并写
        uint64_t sector = cluster_to_sector(cur_cluster);
ffffffe000205300:	fe843503          	ld	a0,-24(s0)
ffffffe000205304:	d68ff0ef          	jal	ffffffe00020486c <cluster_to_sector>
ffffffe000205308:	faa43423          	sd	a0,-88(s0)
        virtio_blk_read_sector(sector, fat32_buf);
ffffffe00020530c:	0040b597          	auipc	a1,0x40b
ffffffe000205310:	f1458593          	addi	a1,a1,-236 # ffffffe000610220 <fat32_buf>
ffffffe000205314:	fa843503          	ld	a0,-88(s0)
ffffffe000205318:	054010ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
        uint64_t take = bytes_per_cluster - offset;
ffffffe00020531c:	fb843703          	ld	a4,-72(s0)
ffffffe000205320:	fd843783          	ld	a5,-40(s0)
ffffffe000205324:	40f707b3          	sub	a5,a4,a5
ffffffe000205328:	fcf43423          	sd	a5,-56(s0)
        if (take > len - written) take = len - written;
ffffffe00020532c:	f8843703          	ld	a4,-120(s0)
ffffffe000205330:	fd043783          	ld	a5,-48(s0)
ffffffe000205334:	40f707b3          	sub	a5,a4,a5
ffffffe000205338:	fc843703          	ld	a4,-56(s0)
ffffffe00020533c:	00e7fa63          	bgeu	a5,a4,ffffffe000205350 <fat32_write+0x14c>
ffffffe000205340:	f8843703          	ld	a4,-120(s0)
ffffffe000205344:	fd043783          	ld	a5,-48(s0)
ffffffe000205348:	40f707b3          	sub	a5,a4,a5
ffffffe00020534c:	fcf43423          	sd	a5,-56(s0)
        memcpy(fat32_buf + offset, in + written, take);
ffffffe000205350:	fd843703          	ld	a4,-40(s0)
ffffffe000205354:	0040b797          	auipc	a5,0x40b
ffffffe000205358:	ecc78793          	addi	a5,a5,-308 # ffffffe000610220 <fat32_buf>
ffffffe00020535c:	00f706b3          	add	a3,a4,a5
ffffffe000205360:	fb043703          	ld	a4,-80(s0)
ffffffe000205364:	fd043783          	ld	a5,-48(s0)
ffffffe000205368:	00f707b3          	add	a5,a4,a5
ffffffe00020536c:	fc843603          	ld	a2,-56(s0)
ffffffe000205370:	00078593          	mv	a1,a5
ffffffe000205374:	00068513          	mv	a0,a3
ffffffe000205378:	b74ff0ef          	jal	ffffffe0002046ec <memcpy>
        written += take;
ffffffe00020537c:	fd043703          	ld	a4,-48(s0)
ffffffe000205380:	fc843783          	ld	a5,-56(s0)
ffffffe000205384:	00f707b3          	add	a5,a4,a5
ffffffe000205388:	fcf43823          	sd	a5,-48(s0)
        offset = 0;
ffffffe00020538c:	fc043c23          	sd	zero,-40(s0)
        // 写入磁盘
        virtio_blk_write_sector(sector, fat32_buf);
ffffffe000205390:	0040b597          	auipc	a1,0x40b
ffffffe000205394:	e9058593          	addi	a1,a1,-368 # ffffffe000610220 <fat32_buf>
ffffffe000205398:	fa843503          	ld	a0,-88(s0)
ffffffe00020539c:	04c010ef          	jal	ffffffe0002063e8 <virtio_blk_write_sector>
        if (written < len) {
ffffffe0002053a0:	fd043703          	ld	a4,-48(s0)
ffffffe0002053a4:	f8843783          	ld	a5,-120(s0)
ffffffe0002053a8:	02f77063          	bgeu	a4,a5,ffffffe0002053c8 <fat32_write+0x1c4>
            cur_cluster = next_cluster(cur_cluster);
ffffffe0002053ac:	fe843503          	ld	a0,-24(s0)
ffffffe0002053b0:	d04ff0ef          	jal	ffffffe0002048b4 <next_cluster>
ffffffe0002053b4:	00050793          	mv	a5,a0
ffffffe0002053b8:	0007879b          	sext.w	a5,a5
ffffffe0002053bc:	02079793          	slli	a5,a5,0x20
ffffffe0002053c0:	0207d793          	srli	a5,a5,0x20
ffffffe0002053c4:	fef43423          	sd	a5,-24(s0)
    while (written < len && cur_cluster < 0x0FFFFFF8) {
ffffffe0002053c8:	fd043703          	ld	a4,-48(s0)
ffffffe0002053cc:	f8843783          	ld	a5,-120(s0)
ffffffe0002053d0:	00f77a63          	bgeu	a4,a5,ffffffe0002053e4 <fat32_write+0x1e0>
ffffffe0002053d4:	fe843703          	ld	a4,-24(s0)
ffffffe0002053d8:	100007b7          	lui	a5,0x10000
ffffffe0002053dc:	ff778793          	addi	a5,a5,-9 # ffffff7 <PHY_SIZE+0x7fffff7>
ffffffe0002053e0:	f2e7f0e3          	bgeu	a5,a4,ffffffe000205300 <fat32_write+0xfc>
        }
    }
    file->cfo += written;
ffffffe0002053e4:	f9843783          	ld	a5,-104(s0)
ffffffe0002053e8:	0087b783          	ld	a5,8(a5)
ffffffe0002053ec:	00078713          	mv	a4,a5
ffffffe0002053f0:	fd043783          	ld	a5,-48(s0)
ffffffe0002053f4:	00f707b3          	add	a5,a4,a5
ffffffe0002053f8:	00078713          	mv	a4,a5
ffffffe0002053fc:	f9843783          	ld	a5,-104(s0)
ffffffe000205400:	00e7b423          	sd	a4,8(a5)
    return written;
ffffffe000205404:	fd043783          	ld	a5,-48(s0)
}
ffffffe000205408:	00078513          	mv	a0,a5
ffffffe00020540c:	07813083          	ld	ra,120(sp)
ffffffe000205410:	07013403          	ld	s0,112(sp)
ffffffe000205414:	08010113          	addi	sp,sp,128
ffffffe000205418:	00008067          	ret

ffffffe00020541c <fat32_file_size>:

uint32_t fat32_file_size(struct file *file) {
ffffffe00020541c:	fd010113          	addi	sp,sp,-48
ffffffe000205420:	02113423          	sd	ra,40(sp)
ffffffe000205424:	02813023          	sd	s0,32(sp)
ffffffe000205428:	03010413          	addi	s0,sp,48
ffffffe00020542c:	fca43c23          	sd	a0,-40(s0)
    // 读取file项，返回文件的大小
    uint64_t dir_sector = cluster_to_sector(file->fat32_file.dir.cluster);
ffffffe000205430:	fd843783          	ld	a5,-40(s0)
ffffffe000205434:	0187a783          	lw	a5,24(a5)
ffffffe000205438:	02079793          	slli	a5,a5,0x20
ffffffe00020543c:	0207d793          	srli	a5,a5,0x20
ffffffe000205440:	00078513          	mv	a0,a5
ffffffe000205444:	c28ff0ef          	jal	ffffffe00020486c <cluster_to_sector>
ffffffe000205448:	fea43423          	sd	a0,-24(s0)
    // 读取扇区内信息到内存
    virtio_blk_read_sector(dir_sector, fat32_buf);
ffffffe00020544c:	0040b597          	auipc	a1,0x40b
ffffffe000205450:	dd458593          	addi	a1,a1,-556 # ffffffe000610220 <fat32_buf>
ffffffe000205454:	fe843503          	ld	a0,-24(s0)
ffffffe000205458:	715000ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    struct fat32_dir_entry *entries = (struct fat32_dir_entry*)fat32_buf;
ffffffe00020545c:	0040b797          	auipc	a5,0x40b
ffffffe000205460:	dc478793          	addi	a5,a5,-572 # ffffffe000610220 <fat32_buf>
ffffffe000205464:	fef43023          	sd	a5,-32(s0)
    // 扇区内第index项为对应的文件项，读取size
    return entries[file->fat32_file.dir.index].size;
ffffffe000205468:	fd843783          	ld	a5,-40(s0)
ffffffe00020546c:	01c7a783          	lw	a5,28(a5)
ffffffe000205470:	02079793          	slli	a5,a5,0x20
ffffffe000205474:	0207d793          	srli	a5,a5,0x20
ffffffe000205478:	00579793          	slli	a5,a5,0x5
ffffffe00020547c:	fe043703          	ld	a4,-32(s0)
ffffffe000205480:	00f707b3          	add	a5,a4,a5
ffffffe000205484:	01c7a783          	lw	a5,28(a5)
ffffffe000205488:	00078513          	mv	a0,a5
ffffffe00020548c:	02813083          	ld	ra,40(sp)
ffffffe000205490:	02013403          	ld	s0,32(sp)
ffffffe000205494:	03010113          	addi	sp,sp,48
ffffffe000205498:	00008067          	ret

ffffffe00020549c <file_init>:
#include "mm.h"
#include "string.h"
#include "printk.h"
#include "fat32.h"

struct files_struct *file_init() {
ffffffe00020549c:	fe010113          	addi	sp,sp,-32
ffffffe0002054a0:	00113c23          	sd	ra,24(sp)
ffffffe0002054a4:	00813823          	sd	s0,16(sp)
ffffffe0002054a8:	02010413          	addi	s0,sp,32
    // todo: alloc pages for files_struct, and initialize stdin, stdout, stderr
    // 根据files_struct大小分配一个页
    struct files_struct *ret = (struct files_struct *)alloc_page();
ffffffe0002054ac:	f28fb0ef          	jal	ffffffe000200bd4 <alloc_page>
ffffffe0002054b0:	fea43023          	sd	a0,-32(s0)
    memset(ret, 0, sizeof(struct files_struct));
ffffffe0002054b4:	000017b7          	lui	a5,0x1
ffffffe0002054b8:	88078613          	addi	a2,a5,-1920 # 880 <PGSIZE-0x780>
ffffffe0002054bc:	00000593          	li	a1,0
ffffffe0002054c0:	fe043503          	ld	a0,-32(s0)
ffffffe0002054c4:	9b8ff0ef          	jal	ffffffe00020467c <memset>
    // 为stdin, stdout, stderr赋值
    // stdin, stdout, stderr对应的数组index分别是0, 1, 2
    ret->fd_array[0].opened = 1;
ffffffe0002054c8:	fe043783          	ld	a5,-32(s0)
ffffffe0002054cc:	00100713          	li	a4,1
ffffffe0002054d0:	00e7a023          	sw	a4,0(a5)
    ret->fd_array[0].perms = FILE_READABLE;
ffffffe0002054d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002054d8:	00100713          	li	a4,1
ffffffe0002054dc:	00e7a223          	sw	a4,4(a5)
    ret->fd_array[0].cfo = 0;
ffffffe0002054e0:	fe043783          	ld	a5,-32(s0)
ffffffe0002054e4:	0007b423          	sd	zero,8(a5)
    ret->fd_array[0].fs_type = 0;
ffffffe0002054e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002054ec:	0007a823          	sw	zero,16(a5)
    ret->fd_array[0].lseek = NULL;
ffffffe0002054f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002054f4:	0207b023          	sd	zero,32(a5)
    ret->fd_array[0].write = NULL;
ffffffe0002054f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002054fc:	0207b423          	sd	zero,40(a5)
    ret->fd_array[0].read = stdin_read;
ffffffe000205500:	fe043783          	ld	a5,-32(s0)
ffffffe000205504:	00000717          	auipc	a4,0x0
ffffffe000205508:	4dc70713          	addi	a4,a4,1244 # ffffffe0002059e0 <stdin_read>
ffffffe00020550c:	02e7b823          	sd	a4,48(a5)

    ret->fd_array[1].opened = 1;
ffffffe000205510:	fe043783          	ld	a5,-32(s0)
ffffffe000205514:	00100713          	li	a4,1
ffffffe000205518:	08e7a423          	sw	a4,136(a5)
    ret->fd_array[1].perms = FILE_WRITABLE;
ffffffe00020551c:	fe043783          	ld	a5,-32(s0)
ffffffe000205520:	00200713          	li	a4,2
ffffffe000205524:	08e7a623          	sw	a4,140(a5)
    ret->fd_array[1].cfo = 0;
ffffffe000205528:	fe043783          	ld	a5,-32(s0)
ffffffe00020552c:	0807b823          	sd	zero,144(a5)
    ret->fd_array[1].fs_type = 0;
ffffffe000205530:	fe043783          	ld	a5,-32(s0)
ffffffe000205534:	0807ac23          	sw	zero,152(a5)
    ret->fd_array[1].lseek = NULL;
ffffffe000205538:	fe043783          	ld	a5,-32(s0)
ffffffe00020553c:	0a07b423          	sd	zero,168(a5)
    ret->fd_array[1].write = stdout_write;
ffffffe000205540:	fe043783          	ld	a5,-32(s0)
ffffffe000205544:	00000717          	auipc	a4,0x0
ffffffe000205548:	51870713          	addi	a4,a4,1304 # ffffffe000205a5c <stdout_write>
ffffffe00020554c:	0ae7b823          	sd	a4,176(a5)
    ret->fd_array[1].read = NULL;
ffffffe000205550:	fe043783          	ld	a5,-32(s0)
ffffffe000205554:	0a07bc23          	sd	zero,184(a5)

    ret->fd_array[2].opened = 1;
ffffffe000205558:	fe043783          	ld	a5,-32(s0)
ffffffe00020555c:	00100713          	li	a4,1
ffffffe000205560:	10e7a823          	sw	a4,272(a5)
    ret->fd_array[2].perms = FILE_WRITABLE;
ffffffe000205564:	fe043783          	ld	a5,-32(s0)
ffffffe000205568:	00200713          	li	a4,2
ffffffe00020556c:	10e7aa23          	sw	a4,276(a5)
    ret->fd_array[2].cfo = 0;
ffffffe000205570:	fe043783          	ld	a5,-32(s0)
ffffffe000205574:	1007bc23          	sd	zero,280(a5)
    ret->fd_array[2].fs_type = 0;
ffffffe000205578:	fe043783          	ld	a5,-32(s0)
ffffffe00020557c:	1207a023          	sw	zero,288(a5)
    ret->fd_array[2].lseek = NULL;
ffffffe000205580:	fe043783          	ld	a5,-32(s0)
ffffffe000205584:	1207b823          	sd	zero,304(a5)
    ret->fd_array[2].write = stderr_write;
ffffffe000205588:	fe043783          	ld	a5,-32(s0)
ffffffe00020558c:	00000717          	auipc	a4,0x0
ffffffe000205590:	5d470713          	addi	a4,a4,1492 # ffffffe000205b60 <stderr_write>
ffffffe000205594:	12e7bc23          	sd	a4,312(a5)
    ret->fd_array[2].read = NULL;
ffffffe000205598:	fe043783          	ld	a5,-32(s0)
ffffffe00020559c:	1407b023          	sd	zero,320(a5)

    // 保证其他未使用的文件的opened字段为0
    for (int i = 3; i < MAX_FILE_NUMBER; i++) {
ffffffe0002055a0:	00300793          	li	a5,3
ffffffe0002055a4:	fef42623          	sw	a5,-20(s0)
ffffffe0002055a8:	0300006f          	j	ffffffe0002055d8 <file_init+0x13c>
        ret->fd_array[i].opened = 0;
ffffffe0002055ac:	fe043683          	ld	a3,-32(s0)
ffffffe0002055b0:	fec42703          	lw	a4,-20(s0)
ffffffe0002055b4:	00070793          	mv	a5,a4
ffffffe0002055b8:	00479793          	slli	a5,a5,0x4
ffffffe0002055bc:	00e787b3          	add	a5,a5,a4
ffffffe0002055c0:	00379793          	slli	a5,a5,0x3
ffffffe0002055c4:	00f687b3          	add	a5,a3,a5
ffffffe0002055c8:	0007a023          	sw	zero,0(a5)
    for (int i = 3; i < MAX_FILE_NUMBER; i++) {
ffffffe0002055cc:	fec42783          	lw	a5,-20(s0)
ffffffe0002055d0:	0017879b          	addiw	a5,a5,1
ffffffe0002055d4:	fef42623          	sw	a5,-20(s0)
ffffffe0002055d8:	fec42783          	lw	a5,-20(s0)
ffffffe0002055dc:	0007871b          	sext.w	a4,a5
ffffffe0002055e0:	00f00793          	li	a5,15
ffffffe0002055e4:	fce7d4e3          	bge	a5,a4,ffffffe0002055ac <file_init+0x110>
    }  
    return ret;
ffffffe0002055e8:	fe043783          	ld	a5,-32(s0)
}
ffffffe0002055ec:	00078513          	mv	a0,a5
ffffffe0002055f0:	01813083          	ld	ra,24(sp)
ffffffe0002055f4:	01013403          	ld	s0,16(sp)
ffffffe0002055f8:	02010113          	addi	sp,sp,32
ffffffe0002055fc:	00008067          	ret

ffffffe000205600 <get_fs_type>:

uint32_t get_fs_type(const char *filename) {
ffffffe000205600:	fd010113          	addi	sp,sp,-48
ffffffe000205604:	02113423          	sd	ra,40(sp)
ffffffe000205608:	02813023          	sd	s0,32(sp)
ffffffe00020560c:	03010413          	addi	s0,sp,48
ffffffe000205610:	fca43c23          	sd	a0,-40(s0)
    uint32_t ret;
    if (memcmp(filename, "/fat32/", 7) == 0) {
ffffffe000205614:	00700613          	li	a2,7
ffffffe000205618:	00002597          	auipc	a1,0x2
ffffffe00020561c:	19858593          	addi	a1,a1,408 # ffffffe0002077b0 <lowerxdigits.0+0x48>
ffffffe000205620:	fd843503          	ld	a0,-40(s0)
ffffffe000205624:	944ff0ef          	jal	ffffffe000204768 <memcmp>
ffffffe000205628:	00050793          	mv	a5,a0
ffffffe00020562c:	00079863          	bnez	a5,ffffffe00020563c <get_fs_type+0x3c>
        ret = FS_TYPE_FAT32;
ffffffe000205630:	00100793          	li	a5,1
ffffffe000205634:	fef42623          	sw	a5,-20(s0)
ffffffe000205638:	0340006f          	j	ffffffe00020566c <get_fs_type+0x6c>
    } else if (memcmp(filename, "/ext2/", 6) == 0) {
ffffffe00020563c:	00600613          	li	a2,6
ffffffe000205640:	00002597          	auipc	a1,0x2
ffffffe000205644:	17858593          	addi	a1,a1,376 # ffffffe0002077b8 <lowerxdigits.0+0x50>
ffffffe000205648:	fd843503          	ld	a0,-40(s0)
ffffffe00020564c:	91cff0ef          	jal	ffffffe000204768 <memcmp>
ffffffe000205650:	00050793          	mv	a5,a0
ffffffe000205654:	00079863          	bnez	a5,ffffffe000205664 <get_fs_type+0x64>
        ret = FS_TYPE_EXT2;
ffffffe000205658:	00200793          	li	a5,2
ffffffe00020565c:	fef42623          	sw	a5,-20(s0)
ffffffe000205660:	00c0006f          	j	ffffffe00020566c <get_fs_type+0x6c>
    } else {
        ret = -1;
ffffffe000205664:	fff00793          	li	a5,-1
ffffffe000205668:	fef42623          	sw	a5,-20(s0)
    }
    return ret;
ffffffe00020566c:	fec42783          	lw	a5,-20(s0)
}
ffffffe000205670:	00078513          	mv	a0,a5
ffffffe000205674:	02813083          	ld	ra,40(sp)
ffffffe000205678:	02013403          	ld	s0,32(sp)
ffffffe00020567c:	03010113          	addi	sp,sp,48
ffffffe000205680:	00008067          	ret

ffffffe000205684 <file_open>:

int32_t file_open(struct file* file, const char* path, int flags) {
ffffffe000205684:	fc010113          	addi	sp,sp,-64
ffffffe000205688:	02113c23          	sd	ra,56(sp)
ffffffe00020568c:	02813823          	sd	s0,48(sp)
ffffffe000205690:	02913423          	sd	s1,40(sp)
ffffffe000205694:	04010413          	addi	s0,sp,64
ffffffe000205698:	fca43c23          	sd	a0,-40(s0)
ffffffe00020569c:	fcb43823          	sd	a1,-48(s0)
ffffffe0002056a0:	00060793          	mv	a5,a2
ffffffe0002056a4:	fcf42623          	sw	a5,-52(s0)
    file->opened = 1;
ffffffe0002056a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002056ac:	00100713          	li	a4,1
ffffffe0002056b0:	00e7a023          	sw	a4,0(a5)
    file->perms = flags;
ffffffe0002056b4:	fcc42703          	lw	a4,-52(s0)
ffffffe0002056b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002056bc:	00e7a223          	sw	a4,4(a5)
    file->cfo = 0;
ffffffe0002056c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002056c4:	0007b423          	sd	zero,8(a5)
    file->fs_type = get_fs_type(path);
ffffffe0002056c8:	fd043503          	ld	a0,-48(s0)
ffffffe0002056cc:	f35ff0ef          	jal	ffffffe000205600 <get_fs_type>
ffffffe0002056d0:	00050793          	mv	a5,a0
ffffffe0002056d4:	0007871b          	sext.w	a4,a5
ffffffe0002056d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002056dc:	00e7a823          	sw	a4,16(a5)
    memcpy(file->path, path, strlen(path) + 1);
ffffffe0002056e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002056e4:	03878493          	addi	s1,a5,56
ffffffe0002056e8:	fd043503          	ld	a0,-48(s0)
ffffffe0002056ec:	934ff0ef          	jal	ffffffe000204820 <strlen>
ffffffe0002056f0:	00050793          	mv	a5,a0
ffffffe0002056f4:	0017879b          	addiw	a5,a5,1
ffffffe0002056f8:	0007879b          	sext.w	a5,a5
ffffffe0002056fc:	00078613          	mv	a2,a5
ffffffe000205700:	fd043583          	ld	a1,-48(s0)
ffffffe000205704:	00048513          	mv	a0,s1
ffffffe000205708:	fe5fe0ef          	jal	ffffffe0002046ec <memcpy>

    if (file->fs_type == FS_TYPE_FAT32) {
ffffffe00020570c:	fd843783          	ld	a5,-40(s0)
ffffffe000205710:	0107a783          	lw	a5,16(a5)
ffffffe000205714:	00078713          	mv	a4,a5
ffffffe000205718:	00100793          	li	a5,1
ffffffe00020571c:	06f71a63          	bne	a4,a5,ffffffe000205790 <file_open+0x10c>
        file->lseek = fat32_lseek;
ffffffe000205720:	fd843783          	ld	a5,-40(s0)
ffffffe000205724:	fffff717          	auipc	a4,0xfffff
ffffffe000205728:	7ac70713          	addi	a4,a4,1964 # ffffffe000204ed0 <fat32_lseek>
ffffffe00020572c:	02e7b023          	sd	a4,32(a5)
        file->write = fat32_write;
ffffffe000205730:	fd843783          	ld	a5,-40(s0)
ffffffe000205734:	00000717          	auipc	a4,0x0
ffffffe000205738:	ad070713          	addi	a4,a4,-1328 # ffffffe000205204 <fat32_write>
ffffffe00020573c:	02e7b423          	sd	a4,40(a5)
        file->read = fat32_read;
ffffffe000205740:	fd843783          	ld	a5,-40(s0)
ffffffe000205744:	00000717          	auipc	a4,0x0
ffffffe000205748:	8b870713          	addi	a4,a4,-1864 # ffffffe000204ffc <fat32_read>
ffffffe00020574c:	02e7b823          	sd	a4,48(a5)
        file->fat32_file = fat32_open_file(path);
ffffffe000205750:	fd843483          	ld	s1,-40(s0)
ffffffe000205754:	fd043503          	ld	a0,-48(s0)
ffffffe000205758:	c60ff0ef          	jal	ffffffe000204bb8 <fat32_open_file>
ffffffe00020575c:	00050713          	mv	a4,a0
ffffffe000205760:	00058793          	mv	a5,a1
ffffffe000205764:	00e4aa23          	sw	a4,20(s1)
ffffffe000205768:	02075693          	srli	a3,a4,0x20
ffffffe00020576c:	00d4ac23          	sw	a3,24(s1)
ffffffe000205770:	00f4ae23          	sw	a5,28(s1)
        // todo: check if fat32_file is valid (i.e. successfully opened) and return
        if (file->fat32_file.cluster == 0) {
ffffffe000205774:	fd843783          	ld	a5,-40(s0)
ffffffe000205778:	0147a783          	lw	a5,20(a5)
ffffffe00020577c:	00079663          	bnez	a5,ffffffe000205788 <file_open+0x104>
            // 无效
            return -1;
ffffffe000205780:	fff00793          	li	a5,-1
ffffffe000205784:	0480006f          	j	ffffffe0002057cc <file_open+0x148>
        } else {
            return 0;
ffffffe000205788:	00000793          	li	a5,0
ffffffe00020578c:	0400006f          	j	ffffffe0002057cc <file_open+0x148>
        }
    } else if (file->fs_type == FS_TYPE_EXT2) {
ffffffe000205790:	fd843783          	ld	a5,-40(s0)
ffffffe000205794:	0107a783          	lw	a5,16(a5)
ffffffe000205798:	00078713          	mv	a4,a5
ffffffe00020579c:	00200793          	li	a5,2
ffffffe0002057a0:	00f71c63          	bne	a4,a5,ffffffe0002057b8 <file_open+0x134>
        printk(RED "Unsupport ext2\n" CLEAR);
ffffffe0002057a4:	00002517          	auipc	a0,0x2
ffffffe0002057a8:	01c50513          	addi	a0,a0,28 # ffffffe0002077c0 <lowerxdigits.0+0x58>
ffffffe0002057ac:	db1fe0ef          	jal	ffffffe00020455c <printk>
        return -1;
ffffffe0002057b0:	fff00793          	li	a5,-1
ffffffe0002057b4:	0180006f          	j	ffffffe0002057cc <file_open+0x148>
    } else {
        printk(RED "Unknown fs type: %s\n" CLEAR, path);
ffffffe0002057b8:	fd043583          	ld	a1,-48(s0)
ffffffe0002057bc:	00002517          	auipc	a0,0x2
ffffffe0002057c0:	02450513          	addi	a0,a0,36 # ffffffe0002077e0 <lowerxdigits.0+0x78>
ffffffe0002057c4:	d99fe0ef          	jal	ffffffe00020455c <printk>
        return -1;
ffffffe0002057c8:	fff00793          	li	a5,-1
    }
ffffffe0002057cc:	00078513          	mv	a0,a5
ffffffe0002057d0:	03813083          	ld	ra,56(sp)
ffffffe0002057d4:	03013403          	ld	s0,48(sp)
ffffffe0002057d8:	02813483          	ld	s1,40(sp)
ffffffe0002057dc:	04010113          	addi	sp,sp,64
ffffffe0002057e0:	00008067          	ret

ffffffe0002057e4 <mbr_init>:
#include "fat32.h"

uint8_t mbr_buf[VIRTIO_BLK_SECTOR_SIZE];
struct partition_info partitions[MBR_MAX_PARTITIONS];

void mbr_init() {
ffffffe0002057e4:	fd010113          	addi	sp,sp,-48
ffffffe0002057e8:	02113423          	sd	ra,40(sp)
ffffffe0002057ec:	02813023          	sd	s0,32(sp)
ffffffe0002057f0:	03010413          	addi	s0,sp,48
    virtio_blk_read_sector(0, mbr_buf);
ffffffe0002057f4:	0040b597          	auipc	a1,0x40b
ffffffe0002057f8:	e2c58593          	addi	a1,a1,-468 # ffffffe000610620 <mbr_buf>
ffffffe0002057fc:	00000513          	li	a0,0
ffffffe000205800:	36d000ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    struct mbr_layout *mbr = (struct mbr_layout *)mbr_buf;
ffffffe000205804:	0040b797          	auipc	a5,0x40b
ffffffe000205808:	e1c78793          	addi	a5,a5,-484 # ffffffe000610620 <mbr_buf>
ffffffe00020580c:	fef43023          	sd	a5,-32(s0)
    for (int i = 0; i < 4; i++) {
ffffffe000205810:	fe042623          	sw	zero,-20(s0)
ffffffe000205814:	0d40006f          	j	ffffffe0002058e8 <mbr_init+0x104>
        if (mbr->partition_table[i].type == 0x83) {
ffffffe000205818:	fe043703          	ld	a4,-32(s0)
ffffffe00020581c:	fec42783          	lw	a5,-20(s0)
ffffffe000205820:	01b78793          	addi	a5,a5,27
ffffffe000205824:	00479793          	slli	a5,a5,0x4
ffffffe000205828:	00f707b3          	add	a5,a4,a5
ffffffe00020582c:	0127c783          	lbu	a5,18(a5)
ffffffe000205830:	00078713          	mv	a4,a5
ffffffe000205834:	08300793          	li	a5,131
ffffffe000205838:	0af71263          	bne	a4,a5,ffffffe0002058dc <mbr_init+0xf8>
            uint32_t lba = mbr->partition_table[i].lba_first_sector;
ffffffe00020583c:	fe043703          	ld	a4,-32(s0)
ffffffe000205840:	fec42783          	lw	a5,-20(s0)
ffffffe000205844:	01b78793          	addi	a5,a5,27
ffffffe000205848:	00479793          	slli	a5,a5,0x4
ffffffe00020584c:	00f707b3          	add	a5,a4,a5
ffffffe000205850:	0167c703          	lbu	a4,22(a5)
ffffffe000205854:	0177c683          	lbu	a3,23(a5)
ffffffe000205858:	00869693          	slli	a3,a3,0x8
ffffffe00020585c:	00e6e733          	or	a4,a3,a4
ffffffe000205860:	0187c683          	lbu	a3,24(a5)
ffffffe000205864:	01069693          	slli	a3,a3,0x10
ffffffe000205868:	00e6e733          	or	a4,a3,a4
ffffffe00020586c:	0197c783          	lbu	a5,25(a5)
ffffffe000205870:	01879793          	slli	a5,a5,0x18
ffffffe000205874:	00e7e7b3          	or	a5,a5,a4
ffffffe000205878:	fcf42e23          	sw	a5,-36(s0)
            partition_init(i + 1, lba, mbr->partition_table[i].sector_count);
ffffffe00020587c:	fec42783          	lw	a5,-20(s0)
ffffffe000205880:	0017879b          	addiw	a5,a5,1
ffffffe000205884:	0007851b          	sext.w	a0,a5
ffffffe000205888:	fdc46583          	lwu	a1,-36(s0)
ffffffe00020588c:	fe043703          	ld	a4,-32(s0)
ffffffe000205890:	fec42783          	lw	a5,-20(s0)
ffffffe000205894:	01b78793          	addi	a5,a5,27
ffffffe000205898:	00479793          	slli	a5,a5,0x4
ffffffe00020589c:	00f707b3          	add	a5,a4,a5
ffffffe0002058a0:	01a7c703          	lbu	a4,26(a5)
ffffffe0002058a4:	01b7c683          	lbu	a3,27(a5)
ffffffe0002058a8:	00869693          	slli	a3,a3,0x8
ffffffe0002058ac:	00e6e733          	or	a4,a3,a4
ffffffe0002058b0:	01c7c683          	lbu	a3,28(a5)
ffffffe0002058b4:	01069693          	slli	a3,a3,0x10
ffffffe0002058b8:	00e6e733          	or	a4,a3,a4
ffffffe0002058bc:	01d7c783          	lbu	a5,29(a5)
ffffffe0002058c0:	01879793          	slli	a5,a5,0x18
ffffffe0002058c4:	00e7e7b3          	or	a5,a5,a4
ffffffe0002058c8:	0007879b          	sext.w	a5,a5
ffffffe0002058cc:	02079793          	slli	a5,a5,0x20
ffffffe0002058d0:	0207d793          	srli	a5,a5,0x20
ffffffe0002058d4:	00078613          	mv	a2,a5
ffffffe0002058d8:	038000ef          	jal	ffffffe000205910 <partition_init>
    for (int i = 0; i < 4; i++) {
ffffffe0002058dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002058e0:	0017879b          	addiw	a5,a5,1
ffffffe0002058e4:	fef42623          	sw	a5,-20(s0)
ffffffe0002058e8:	fec42783          	lw	a5,-20(s0)
ffffffe0002058ec:	0007871b          	sext.w	a4,a5
ffffffe0002058f0:	00300793          	li	a5,3
ffffffe0002058f4:	f2e7d2e3          	bge	a5,a4,ffffffe000205818 <mbr_init+0x34>
        }
    }
}
ffffffe0002058f8:	00000013          	nop
ffffffe0002058fc:	00000013          	nop
ffffffe000205900:	02813083          	ld	ra,40(sp)
ffffffe000205904:	02013403          	ld	s0,32(sp)
ffffffe000205908:	03010113          	addi	sp,sp,48
ffffffe00020590c:	00008067          	ret

ffffffe000205910 <partition_init>:

void partition_init(int partion_number, uint64_t start_lba, uint64_t sector_count) {
ffffffe000205910:	fd010113          	addi	sp,sp,-48
ffffffe000205914:	02113423          	sd	ra,40(sp)
ffffffe000205918:	02813023          	sd	s0,32(sp)
ffffffe00020591c:	03010413          	addi	s0,sp,48
ffffffe000205920:	00050793          	mv	a5,a0
ffffffe000205924:	feb43023          	sd	a1,-32(s0)
ffffffe000205928:	fcc43c23          	sd	a2,-40(s0)
ffffffe00020592c:	fef42623          	sw	a5,-20(s0)
    if (is_fat32(start_lba)) {
ffffffe000205930:	fe043503          	ld	a0,-32(s0)
ffffffe000205934:	8f4ff0ef          	jal	ffffffe000204a28 <is_fat32>
ffffffe000205938:	00050793          	mv	a5,a0
ffffffe00020593c:	02078263          	beqz	a5,ffffffe000205960 <partition_init+0x50>
        fat32_init(start_lba, sector_count);
ffffffe000205940:	fd843583          	ld	a1,-40(s0)
ffffffe000205944:	fe043503          	ld	a0,-32(s0)
ffffffe000205948:	ff1fe0ef          	jal	ffffffe000204938 <fat32_init>
        printk("...fat32 partition #%d init done!\n", partion_number);
ffffffe00020594c:	fec42783          	lw	a5,-20(s0)
ffffffe000205950:	00078593          	mv	a1,a5
ffffffe000205954:	00002517          	auipc	a0,0x2
ffffffe000205958:	eac50513          	addi	a0,a0,-340 # ffffffe000207800 <lowerxdigits.0+0x98>
ffffffe00020595c:	c01fe0ef          	jal	ffffffe00020455c <printk>
    }
}
ffffffe000205960:	00000013          	nop
ffffffe000205964:	02813083          	ld	ra,40(sp)
ffffffe000205968:	02013403          	ld	s0,32(sp)
ffffffe00020596c:	03010113          	addi	sp,sp,48
ffffffe000205970:	00008067          	ret

ffffffe000205974 <uart_getchar>:
#include "vfs.h"
#include "sbi.h"
#include "defs.h"
#include "printk.h"

char uart_getchar() {
ffffffe000205974:	fd010113          	addi	sp,sp,-48
ffffffe000205978:	02113423          	sd	ra,40(sp)
ffffffe00020597c:	02813023          	sd	s0,32(sp)
ffffffe000205980:	03010413          	addi	s0,sp,48
    char ret;
    while (1) {
        struct sbiret sbi_result = sbi_debug_console_read(1, ((uint64_t)&ret - PA2VA_OFFSET), 0);
ffffffe000205984:	fef40713          	addi	a4,s0,-17
ffffffe000205988:	04100793          	li	a5,65
ffffffe00020598c:	01f79793          	slli	a5,a5,0x1f
ffffffe000205990:	00f707b3          	add	a5,a4,a5
ffffffe000205994:	00000613          	li	a2,0
ffffffe000205998:	00078593          	mv	a1,a5
ffffffe00020599c:	00100513          	li	a0,1
ffffffe0002059a0:	d2dfc0ef          	jal	ffffffe0002026cc <sbi_debug_console_read>
ffffffe0002059a4:	00050713          	mv	a4,a0
ffffffe0002059a8:	00058793          	mv	a5,a1
ffffffe0002059ac:	fce43c23          	sd	a4,-40(s0)
ffffffe0002059b0:	fef43023          	sd	a5,-32(s0)
        if (sbi_result.error == 0 && sbi_result.value == 1) {
ffffffe0002059b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002059b8:	fc0796e3          	bnez	a5,ffffffe000205984 <uart_getchar+0x10>
ffffffe0002059bc:	fe043703          	ld	a4,-32(s0)
ffffffe0002059c0:	00100793          	li	a5,1
ffffffe0002059c4:	fcf710e3          	bne	a4,a5,ffffffe000205984 <uart_getchar+0x10>
            break;
        }
    }
    return ret;
ffffffe0002059c8:	fef44783          	lbu	a5,-17(s0)
}
ffffffe0002059cc:	00078513          	mv	a0,a5
ffffffe0002059d0:	02813083          	ld	ra,40(sp)
ffffffe0002059d4:	02013403          	ld	s0,32(sp)
ffffffe0002059d8:	03010113          	addi	sp,sp,48
ffffffe0002059dc:	00008067          	ret

ffffffe0002059e0 <stdin_read>:

int64_t stdin_read(struct file *file, void *buf, uint64_t len) {
ffffffe0002059e0:	fb010113          	addi	sp,sp,-80
ffffffe0002059e4:	04113423          	sd	ra,72(sp)
ffffffe0002059e8:	04813023          	sd	s0,64(sp)
ffffffe0002059ec:	02913c23          	sd	s1,56(sp)
ffffffe0002059f0:	05010413          	addi	s0,sp,80
ffffffe0002059f4:	fca43423          	sd	a0,-56(s0)
ffffffe0002059f8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002059fc:	fac43c23          	sd	a2,-72(s0)
    // todo: use uart_getchar() to get `len` chars
    // 从stdin读入长度为len的字符，获取键盘键入的内容
    char *out = (char *)buf;
ffffffe000205a00:	fc043783          	ld	a5,-64(s0)
ffffffe000205a04:	fcf43823          	sd	a5,-48(s0)
    for (uint64_t i = 0; i < len; i++) {
ffffffe000205a08:	fc043c23          	sd	zero,-40(s0)
ffffffe000205a0c:	0280006f          	j	ffffffe000205a34 <stdin_read+0x54>
        out[i] = uart_getchar();
ffffffe000205a10:	fd043703          	ld	a4,-48(s0)
ffffffe000205a14:	fd843783          	ld	a5,-40(s0)
ffffffe000205a18:	00f704b3          	add	s1,a4,a5
ffffffe000205a1c:	f59ff0ef          	jal	ffffffe000205974 <uart_getchar>
ffffffe000205a20:	00050793          	mv	a5,a0
ffffffe000205a24:	00f48023          	sb	a5,0(s1)
    for (uint64_t i = 0; i < len; i++) {
ffffffe000205a28:	fd843783          	ld	a5,-40(s0)
ffffffe000205a2c:	00178793          	addi	a5,a5,1
ffffffe000205a30:	fcf43c23          	sd	a5,-40(s0)
ffffffe000205a34:	fd843703          	ld	a4,-40(s0)
ffffffe000205a38:	fb843783          	ld	a5,-72(s0)
ffffffe000205a3c:	fcf76ae3          	bltu	a4,a5,ffffffe000205a10 <stdin_read+0x30>
    }
    return len;
ffffffe000205a40:	fb843783          	ld	a5,-72(s0)
}
ffffffe000205a44:	00078513          	mv	a0,a5
ffffffe000205a48:	04813083          	ld	ra,72(sp)
ffffffe000205a4c:	04013403          	ld	s0,64(sp)
ffffffe000205a50:	03813483          	ld	s1,56(sp)
ffffffe000205a54:	05010113          	addi	sp,sp,80
ffffffe000205a58:	00008067          	ret

ffffffe000205a5c <stdout_write>:

int64_t stdout_write(struct file *file, const void *buf, uint64_t len) {
ffffffe000205a5c:	fa010113          	addi	sp,sp,-96
ffffffe000205a60:	04113c23          	sd	ra,88(sp)
ffffffe000205a64:	04813823          	sd	s0,80(sp)
ffffffe000205a68:	04913423          	sd	s1,72(sp)
ffffffe000205a6c:	06010413          	addi	s0,sp,96
ffffffe000205a70:	faa43c23          	sd	a0,-72(s0)
ffffffe000205a74:	fab43823          	sd	a1,-80(s0)
ffffffe000205a78:	fac43423          	sd	a2,-88(s0)
ffffffe000205a7c:	00010693          	mv	a3,sp
ffffffe000205a80:	00068493          	mv	s1,a3
    char to_print[len + 1];
ffffffe000205a84:	fa843683          	ld	a3,-88(s0)
ffffffe000205a88:	00168693          	addi	a3,a3,1
ffffffe000205a8c:	00068613          	mv	a2,a3
ffffffe000205a90:	fff60613          	addi	a2,a2,-1 # fff <PGSIZE-0x1>
ffffffe000205a94:	fcc43823          	sd	a2,-48(s0)
ffffffe000205a98:	00068e13          	mv	t3,a3
ffffffe000205a9c:	00000e93          	li	t4,0
ffffffe000205aa0:	03de5613          	srli	a2,t3,0x3d
ffffffe000205aa4:	003e9893          	slli	a7,t4,0x3
ffffffe000205aa8:	011668b3          	or	a7,a2,a7
ffffffe000205aac:	003e1813          	slli	a6,t3,0x3
ffffffe000205ab0:	00068313          	mv	t1,a3
ffffffe000205ab4:	00000393          	li	t2,0
ffffffe000205ab8:	03d35613          	srli	a2,t1,0x3d
ffffffe000205abc:	00339793          	slli	a5,t2,0x3
ffffffe000205ac0:	00f667b3          	or	a5,a2,a5
ffffffe000205ac4:	00331713          	slli	a4,t1,0x3
ffffffe000205ac8:	00f68793          	addi	a5,a3,15
ffffffe000205acc:	0047d793          	srli	a5,a5,0x4
ffffffe000205ad0:	00479793          	slli	a5,a5,0x4
ffffffe000205ad4:	40f10133          	sub	sp,sp,a5
ffffffe000205ad8:	00010793          	mv	a5,sp
ffffffe000205adc:	00078793          	mv	a5,a5
ffffffe000205ae0:	fcf43423          	sd	a5,-56(s0)
    for (int i = 0; i < len; i++) {
ffffffe000205ae4:	fc042e23          	sw	zero,-36(s0)
ffffffe000205ae8:	0300006f          	j	ffffffe000205b18 <stdout_write+0xbc>
        to_print[i] = ((const char *)buf)[i];
ffffffe000205aec:	fdc42783          	lw	a5,-36(s0)
ffffffe000205af0:	fb043703          	ld	a4,-80(s0)
ffffffe000205af4:	00f707b3          	add	a5,a4,a5
ffffffe000205af8:	0007c703          	lbu	a4,0(a5)
ffffffe000205afc:	fc843683          	ld	a3,-56(s0)
ffffffe000205b00:	fdc42783          	lw	a5,-36(s0)
ffffffe000205b04:	00f687b3          	add	a5,a3,a5
ffffffe000205b08:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < len; i++) {
ffffffe000205b0c:	fdc42783          	lw	a5,-36(s0)
ffffffe000205b10:	0017879b          	addiw	a5,a5,1
ffffffe000205b14:	fcf42e23          	sw	a5,-36(s0)
ffffffe000205b18:	fdc42783          	lw	a5,-36(s0)
ffffffe000205b1c:	fa843703          	ld	a4,-88(s0)
ffffffe000205b20:	fce7e6e3          	bltu	a5,a4,ffffffe000205aec <stdout_write+0x90>
    }
    to_print[len] = 0;
ffffffe000205b24:	fc843703          	ld	a4,-56(s0)
ffffffe000205b28:	fa843783          	ld	a5,-88(s0)
ffffffe000205b2c:	00f707b3          	add	a5,a4,a5
ffffffe000205b30:	00078023          	sb	zero,0(a5)
    return printk(buf);
ffffffe000205b34:	fb043503          	ld	a0,-80(s0)
ffffffe000205b38:	a25fe0ef          	jal	ffffffe00020455c <printk>
ffffffe000205b3c:	00050793          	mv	a5,a0
ffffffe000205b40:	00048113          	mv	sp,s1
}
ffffffe000205b44:	00078513          	mv	a0,a5
ffffffe000205b48:	fa040113          	addi	sp,s0,-96
ffffffe000205b4c:	05813083          	ld	ra,88(sp)
ffffffe000205b50:	05013403          	ld	s0,80(sp)
ffffffe000205b54:	04813483          	ld	s1,72(sp)
ffffffe000205b58:	06010113          	addi	sp,sp,96
ffffffe000205b5c:	00008067          	ret

ffffffe000205b60 <stderr_write>:

int64_t stderr_write(struct file *file, const void *buf, uint64_t len) {
ffffffe000205b60:	fa010113          	addi	sp,sp,-96
ffffffe000205b64:	04113c23          	sd	ra,88(sp)
ffffffe000205b68:	04813823          	sd	s0,80(sp)
ffffffe000205b6c:	04913423          	sd	s1,72(sp)
ffffffe000205b70:	06010413          	addi	s0,sp,96
ffffffe000205b74:	faa43c23          	sd	a0,-72(s0)
ffffffe000205b78:	fab43823          	sd	a1,-80(s0)
ffffffe000205b7c:	fac43423          	sd	a2,-88(s0)
ffffffe000205b80:	00010693          	mv	a3,sp
ffffffe000205b84:	00068493          	mv	s1,a3
    // todo
    // 通过printk进行串口输出
    char to_print[len + 1];
ffffffe000205b88:	fa843683          	ld	a3,-88(s0)
ffffffe000205b8c:	00168693          	addi	a3,a3,1
ffffffe000205b90:	00068613          	mv	a2,a3
ffffffe000205b94:	fff60613          	addi	a2,a2,-1
ffffffe000205b98:	fcc43823          	sd	a2,-48(s0)
ffffffe000205b9c:	00068e13          	mv	t3,a3
ffffffe000205ba0:	00000e93          	li	t4,0
ffffffe000205ba4:	03de5613          	srli	a2,t3,0x3d
ffffffe000205ba8:	003e9893          	slli	a7,t4,0x3
ffffffe000205bac:	011668b3          	or	a7,a2,a7
ffffffe000205bb0:	003e1813          	slli	a6,t3,0x3
ffffffe000205bb4:	00068313          	mv	t1,a3
ffffffe000205bb8:	00000393          	li	t2,0
ffffffe000205bbc:	03d35613          	srli	a2,t1,0x3d
ffffffe000205bc0:	00339793          	slli	a5,t2,0x3
ffffffe000205bc4:	00f667b3          	or	a5,a2,a5
ffffffe000205bc8:	00331713          	slli	a4,t1,0x3
ffffffe000205bcc:	00f68793          	addi	a5,a3,15
ffffffe000205bd0:	0047d793          	srli	a5,a5,0x4
ffffffe000205bd4:	00479793          	slli	a5,a5,0x4
ffffffe000205bd8:	40f10133          	sub	sp,sp,a5
ffffffe000205bdc:	00010793          	mv	a5,sp
ffffffe000205be0:	00078793          	mv	a5,a5
ffffffe000205be4:	fcf43423          	sd	a5,-56(s0)
    for (int i = 0; i < len; i++) {
ffffffe000205be8:	fc042e23          	sw	zero,-36(s0)
ffffffe000205bec:	0300006f          	j	ffffffe000205c1c <stderr_write+0xbc>
        to_print[i] = ((const char *)buf)[i];
ffffffe000205bf0:	fdc42783          	lw	a5,-36(s0)
ffffffe000205bf4:	fb043703          	ld	a4,-80(s0)
ffffffe000205bf8:	00f707b3          	add	a5,a4,a5
ffffffe000205bfc:	0007c703          	lbu	a4,0(a5)
ffffffe000205c00:	fc843683          	ld	a3,-56(s0)
ffffffe000205c04:	fdc42783          	lw	a5,-36(s0)
ffffffe000205c08:	00f687b3          	add	a5,a3,a5
ffffffe000205c0c:	00e78023          	sb	a4,0(a5)
    for (int i = 0; i < len; i++) {
ffffffe000205c10:	fdc42783          	lw	a5,-36(s0)
ffffffe000205c14:	0017879b          	addiw	a5,a5,1
ffffffe000205c18:	fcf42e23          	sw	a5,-36(s0)
ffffffe000205c1c:	fdc42783          	lw	a5,-36(s0)
ffffffe000205c20:	fa843703          	ld	a4,-88(s0)
ffffffe000205c24:	fce7e6e3          	bltu	a5,a4,ffffffe000205bf0 <stderr_write+0x90>
    }
    to_print[len] = 0;
ffffffe000205c28:	fc843703          	ld	a4,-56(s0)
ffffffe000205c2c:	fa843783          	ld	a5,-88(s0)
ffffffe000205c30:	00f707b3          	add	a5,a4,a5
ffffffe000205c34:	00078023          	sb	zero,0(a5)
    return printk(buf);
ffffffe000205c38:	fb043503          	ld	a0,-80(s0)
ffffffe000205c3c:	921fe0ef          	jal	ffffffe00020455c <printk>
ffffffe000205c40:	00050793          	mv	a5,a0
ffffffe000205c44:	00048113          	mv	sp,s1
}
ffffffe000205c48:	00078513          	mv	a0,a5
ffffffe000205c4c:	fa040113          	addi	sp,s0,-96
ffffffe000205c50:	05813083          	ld	ra,88(sp)
ffffffe000205c54:	05013403          	ld	s0,80(sp)
ffffffe000205c58:	04813483          	ld	s1,72(sp)
ffffffe000205c5c:	06010113          	addi	sp,sp,96
ffffffe000205c60:	00008067          	ret

ffffffe000205c64 <in32>:

void virtio_dev_init() {
    for (int i = 0; i < VIRTIO_COUNT; i++) {
        uint64_t addr = VIRTIO_START + i * VIRTIO_SIZE;
        virtio_dev_test(io_to_virt(addr));
    }
ffffffe000205c64:	fd010113          	addi	sp,sp,-48
ffffffe000205c68:	02813423          	sd	s0,40(sp)
ffffffe000205c6c:	03010413          	addi	s0,sp,48
ffffffe000205c70:	fca43c23          	sd	a0,-40(s0)

    if (virtio_blk_regs) {
ffffffe000205c74:	fd843783          	ld	a5,-40(s0)
ffffffe000205c78:	0007a783          	lw	a5,0(a5)
ffffffe000205c7c:	fef42623          	sw	a5,-20(s0)
        virtio_blk_init();
    }
ffffffe000205c80:	fec42783          	lw	a5,-20(s0)
ffffffe000205c84:	00078513          	mv	a0,a5
ffffffe000205c88:	02813403          	ld	s0,40(sp)
ffffffe000205c8c:	03010113          	addi	sp,sp,48
ffffffe000205c90:	00008067          	ret

ffffffe000205c94 <memory_barrier>:
ffffffe000205c94:	ff010113          	addi	sp,sp,-16
ffffffe000205c98:	00813423          	sd	s0,8(sp)
ffffffe000205c9c:	01010413          	addi	s0,sp,16
ffffffe000205ca0:	0330000f          	fence	rw,rw
ffffffe000205ca4:	00000013          	nop
ffffffe000205ca8:	00813403          	ld	s0,8(sp)
ffffffe000205cac:	01010113          	addi	sp,sp,16
ffffffe000205cb0:	00008067          	ret

ffffffe000205cb4 <io_to_virt>:
ffffffe000205cb4:	fe010113          	addi	sp,sp,-32
ffffffe000205cb8:	00813c23          	sd	s0,24(sp)
ffffffe000205cbc:	02010413          	addi	s0,sp,32
ffffffe000205cc0:	fea43423          	sd	a0,-24(s0)
ffffffe000205cc4:	fe843703          	ld	a4,-24(s0)
ffffffe000205cc8:	ff900793          	li	a5,-7
ffffffe000205ccc:	02379793          	slli	a5,a5,0x23
ffffffe000205cd0:	00f707b3          	add	a5,a4,a5
ffffffe000205cd4:	00078513          	mv	a0,a5
ffffffe000205cd8:	01813403          	ld	s0,24(sp)
ffffffe000205cdc:	02010113          	addi	sp,sp,32
ffffffe000205ce0:	00008067          	ret

ffffffe000205ce4 <virtio_blk_driver_init>:
void virtio_blk_driver_init() {
ffffffe000205ce4:	ff010113          	addi	sp,sp,-16
ffffffe000205ce8:	00113423          	sd	ra,8(sp)
ffffffe000205cec:	00813023          	sd	s0,0(sp)
ffffffe000205cf0:	01010413          	addi	s0,sp,16
    virtio_blk_regs->Status = 0;
ffffffe000205cf4:	00407797          	auipc	a5,0x407
ffffffe000205cf8:	33478793          	addi	a5,a5,820 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205cfc:	0007b783          	ld	a5,0(a5)
ffffffe000205d00:	0607a823          	sw	zero,112(a5)
    virtio_blk_regs->Status |= DEVICE_ACKNOWLEDGE;
ffffffe000205d04:	00407797          	auipc	a5,0x407
ffffffe000205d08:	32478793          	addi	a5,a5,804 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205d0c:	0007b783          	ld	a5,0(a5)
ffffffe000205d10:	0707a783          	lw	a5,112(a5)
ffffffe000205d14:	0007871b          	sext.w	a4,a5
ffffffe000205d18:	00407797          	auipc	a5,0x407
ffffffe000205d1c:	31078793          	addi	a5,a5,784 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205d20:	0007b783          	ld	a5,0(a5)
ffffffe000205d24:	00176713          	ori	a4,a4,1
ffffffe000205d28:	0007071b          	sext.w	a4,a4
ffffffe000205d2c:	06e7a823          	sw	a4,112(a5)
    virtio_blk_regs->Status |= DEVICE_DRIVER;
ffffffe000205d30:	00407797          	auipc	a5,0x407
ffffffe000205d34:	2f878793          	addi	a5,a5,760 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205d38:	0007b783          	ld	a5,0(a5)
ffffffe000205d3c:	0707a783          	lw	a5,112(a5)
ffffffe000205d40:	0007871b          	sext.w	a4,a5
ffffffe000205d44:	00407797          	auipc	a5,0x407
ffffffe000205d48:	2e478793          	addi	a5,a5,740 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205d4c:	0007b783          	ld	a5,0(a5)
ffffffe000205d50:	00276713          	ori	a4,a4,2
ffffffe000205d54:	0007071b          	sext.w	a4,a4
ffffffe000205d58:	06e7a823          	sw	a4,112(a5)
    memory_barrier();
ffffffe000205d5c:	f39ff0ef          	jal	ffffffe000205c94 <memory_barrier>
}
ffffffe000205d60:	00000013          	nop
ffffffe000205d64:	00813083          	ld	ra,8(sp)
ffffffe000205d68:	00013403          	ld	s0,0(sp)
ffffffe000205d6c:	01010113          	addi	sp,sp,16
ffffffe000205d70:	00008067          	ret

ffffffe000205d74 <virtio_blk_feature_init>:
void virtio_blk_feature_init() {
ffffffe000205d74:	ff010113          	addi	sp,sp,-16
ffffffe000205d78:	00113423          	sd	ra,8(sp)
ffffffe000205d7c:	00813023          	sd	s0,0(sp)
ffffffe000205d80:	01010413          	addi	s0,sp,16
    virtio_blk_regs->DeviceFeaturesSel = 0;
ffffffe000205d84:	00407797          	auipc	a5,0x407
ffffffe000205d88:	2a478793          	addi	a5,a5,676 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205d8c:	0007b783          	ld	a5,0(a5)
ffffffe000205d90:	0007aa23          	sw	zero,20(a5)
    virtio_blk_regs->DeviceFeaturesSel = 1;
ffffffe000205d94:	00407797          	auipc	a5,0x407
ffffffe000205d98:	29478793          	addi	a5,a5,660 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205d9c:	0007b783          	ld	a5,0(a5)
ffffffe000205da0:	00100713          	li	a4,1
ffffffe000205da4:	00e7aa23          	sw	a4,20(a5)
    virtio_blk_regs->DriverFeaturesSel = 0;
ffffffe000205da8:	00407797          	auipc	a5,0x407
ffffffe000205dac:	28078793          	addi	a5,a5,640 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205db0:	0007b783          	ld	a5,0(a5)
ffffffe000205db4:	0207a223          	sw	zero,36(a5)
    virtio_blk_regs->DriverFeatures = 0x30000200;
ffffffe000205db8:	00407797          	auipc	a5,0x407
ffffffe000205dbc:	27078793          	addi	a5,a5,624 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205dc0:	0007b783          	ld	a5,0(a5)
ffffffe000205dc4:	30000737          	lui	a4,0x30000
ffffffe000205dc8:	20070713          	addi	a4,a4,512 # 30000200 <PHY_SIZE+0x28000200>
ffffffe000205dcc:	02e7a023          	sw	a4,32(a5)
    virtio_blk_regs->DriverFeaturesSel = 1;
ffffffe000205dd0:	00407797          	auipc	a5,0x407
ffffffe000205dd4:	25878793          	addi	a5,a5,600 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205dd8:	0007b783          	ld	a5,0(a5)
ffffffe000205ddc:	00100713          	li	a4,1
ffffffe000205de0:	02e7a223          	sw	a4,36(a5)
    virtio_blk_regs->DriverFeatures = 0x0;
ffffffe000205de4:	00407797          	auipc	a5,0x407
ffffffe000205de8:	24478793          	addi	a5,a5,580 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205dec:	0007b783          	ld	a5,0(a5)
ffffffe000205df0:	0207a023          	sw	zero,32(a5)
    virtio_blk_regs->Status |= DEVICE_FEATURES_OK;
ffffffe000205df4:	00407797          	auipc	a5,0x407
ffffffe000205df8:	23478793          	addi	a5,a5,564 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205dfc:	0007b783          	ld	a5,0(a5)
ffffffe000205e00:	0707a783          	lw	a5,112(a5)
ffffffe000205e04:	0007871b          	sext.w	a4,a5
ffffffe000205e08:	00407797          	auipc	a5,0x407
ffffffe000205e0c:	22078793          	addi	a5,a5,544 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205e10:	0007b783          	ld	a5,0(a5)
ffffffe000205e14:	00876713          	ori	a4,a4,8
ffffffe000205e18:	0007071b          	sext.w	a4,a4
ffffffe000205e1c:	06e7a823          	sw	a4,112(a5)
    memory_barrier();
ffffffe000205e20:	e75ff0ef          	jal	ffffffe000205c94 <memory_barrier>
}
ffffffe000205e24:	00000013          	nop
ffffffe000205e28:	00813083          	ld	ra,8(sp)
ffffffe000205e2c:	00013403          	ld	s0,0(sp)
ffffffe000205e30:	01010113          	addi	sp,sp,16
ffffffe000205e34:	00008067          	ret

ffffffe000205e38 <virtio_blk_queue_init>:
void virtio_blk_queue_init() {
ffffffe000205e38:	fc010113          	addi	sp,sp,-64
ffffffe000205e3c:	02113c23          	sd	ra,56(sp)
ffffffe000205e40:	02813823          	sd	s0,48(sp)
ffffffe000205e44:	04010413          	addi	s0,sp,64
    virtio_blk_ring.num = VIRTIO_QUEUE_SIZE;
ffffffe000205e48:	0040b797          	auipc	a5,0x40b
ffffffe000205e4c:	a0878793          	addi	a5,a5,-1528 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205e50:	01000713          	li	a4,16
ffffffe000205e54:	00e79023          	sh	a4,0(a5)
    uint64_t size_of_descs = VIRTIO_QUEUE_SIZE * sizeof(struct virtio_desc);
ffffffe000205e58:	10000793          	li	a5,256
ffffffe000205e5c:	fef43023          	sd	a5,-32(s0)
    uint64_t size_of_avail = sizeof(struct virtio_avail);
ffffffe000205e60:	02600793          	li	a5,38
ffffffe000205e64:	fcf43c23          	sd	a5,-40(s0)
    uint64_t size_of_used = sizeof(struct virtio_used);
ffffffe000205e68:	08800793          	li	a5,136
ffffffe000205e6c:	fcf43823          	sd	a5,-48(s0)
    uint64_t pages = alloc_pages(3);
ffffffe000205e70:	00300513          	li	a0,3
ffffffe000205e74:	bf9fa0ef          	jal	ffffffe000200a6c <alloc_pages>
ffffffe000205e78:	00050793          	mv	a5,a0
ffffffe000205e7c:	fcf43423          	sd	a5,-56(s0)
    virtio_blk_ring.desc = (struct virtio_desc*)(pages);
ffffffe000205e80:	fc843703          	ld	a4,-56(s0)
ffffffe000205e84:	0040b797          	auipc	a5,0x40b
ffffffe000205e88:	9cc78793          	addi	a5,a5,-1588 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205e8c:	00e7b423          	sd	a4,8(a5)
    virtio_blk_ring.avail = (struct virtio_avail*)(pages + PGSIZE);
ffffffe000205e90:	fc843703          	ld	a4,-56(s0)
ffffffe000205e94:	000017b7          	lui	a5,0x1
ffffffe000205e98:	00f707b3          	add	a5,a4,a5
ffffffe000205e9c:	00078713          	mv	a4,a5
ffffffe000205ea0:	0040b797          	auipc	a5,0x40b
ffffffe000205ea4:	9b078793          	addi	a5,a5,-1616 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205ea8:	00e7b823          	sd	a4,16(a5)
    virtio_blk_ring.used = (struct virtio_used*)(pages + 2*PGSIZE);
ffffffe000205eac:	fc843703          	ld	a4,-56(s0)
ffffffe000205eb0:	000027b7          	lui	a5,0x2
ffffffe000205eb4:	00f707b3          	add	a5,a4,a5
ffffffe000205eb8:	00078713          	mv	a4,a5
ffffffe000205ebc:	0040b797          	auipc	a5,0x40b
ffffffe000205ec0:	99478793          	addi	a5,a5,-1644 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205ec4:	00e7bc23          	sd	a4,24(a5)
    virtio_blk_ring.avail->flags = VIRTQ_AVAIL_F_NO_INTERRUPT;
ffffffe000205ec8:	0040b797          	auipc	a5,0x40b
ffffffe000205ecc:	98878793          	addi	a5,a5,-1656 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205ed0:	0107b783          	ld	a5,16(a5)
ffffffe000205ed4:	00100713          	li	a4,1
ffffffe000205ed8:	00e79023          	sh	a4,0(a5)
    for (int i = 1; i < VIRTIO_QUEUE_SIZE; i++) {
ffffffe000205edc:	00100793          	li	a5,1
ffffffe000205ee0:	fef42623          	sw	a5,-20(s0)
ffffffe000205ee4:	03c0006f          	j	ffffffe000205f20 <virtio_blk_queue_init+0xe8>
        virtio_blk_ring.desc[i - 1].next = i;
ffffffe000205ee8:	0040b797          	auipc	a5,0x40b
ffffffe000205eec:	96878793          	addi	a5,a5,-1688 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205ef0:	0087b703          	ld	a4,8(a5)
ffffffe000205ef4:	fec42783          	lw	a5,-20(s0)
ffffffe000205ef8:	00479793          	slli	a5,a5,0x4
ffffffe000205efc:	ff078793          	addi	a5,a5,-16
ffffffe000205f00:	00f707b3          	add	a5,a4,a5
ffffffe000205f04:	fec42703          	lw	a4,-20(s0)
ffffffe000205f08:	03071713          	slli	a4,a4,0x30
ffffffe000205f0c:	03075713          	srli	a4,a4,0x30
ffffffe000205f10:	00e79723          	sh	a4,14(a5)
    for (int i = 1; i < VIRTIO_QUEUE_SIZE; i++) {
ffffffe000205f14:	fec42783          	lw	a5,-20(s0)
ffffffe000205f18:	0017879b          	addiw	a5,a5,1
ffffffe000205f1c:	fef42623          	sw	a5,-20(s0)
ffffffe000205f20:	fec42783          	lw	a5,-20(s0)
ffffffe000205f24:	0007871b          	sext.w	a4,a5
ffffffe000205f28:	00f00793          	li	a5,15
ffffffe000205f2c:	fae7dee3          	bge	a5,a4,ffffffe000205ee8 <virtio_blk_queue_init+0xb0>
    virtio_blk_regs->QueueSel = 0;
ffffffe000205f30:	00407797          	auipc	a5,0x407
ffffffe000205f34:	0f878793          	addi	a5,a5,248 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205f38:	0007b783          	ld	a5,0(a5)
ffffffe000205f3c:	0207a823          	sw	zero,48(a5)
    virtio_blk_regs->QueueNum = VIRTIO_QUEUE_SIZE;
ffffffe000205f40:	00407797          	auipc	a5,0x407
ffffffe000205f44:	0e878793          	addi	a5,a5,232 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205f48:	0007b783          	ld	a5,0(a5)
ffffffe000205f4c:	01000713          	li	a4,16
ffffffe000205f50:	02e7ac23          	sw	a4,56(a5)
    virtio_blk_regs->QueueAvailLow = 0xffffffff & virt_to_phys((uint64_t)virtio_blk_ring.avail);
ffffffe000205f54:	0040b797          	auipc	a5,0x40b
ffffffe000205f58:	8fc78793          	addi	a5,a5,-1796 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205f5c:	0107b783          	ld	a5,16(a5)
ffffffe000205f60:	0007869b          	sext.w	a3,a5
ffffffe000205f64:	00407797          	auipc	a5,0x407
ffffffe000205f68:	0c478793          	addi	a5,a5,196 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205f6c:	0007b783          	ld	a5,0(a5)
ffffffe000205f70:	80000737          	lui	a4,0x80000
ffffffe000205f74:	00e6873b          	addw	a4,a3,a4
ffffffe000205f78:	0007071b          	sext.w	a4,a4
ffffffe000205f7c:	08e7a823          	sw	a4,144(a5)
    virtio_blk_regs->QueueAvailHigh = virt_to_phys((uint64_t)virtio_blk_ring.avail) >> 32;
ffffffe000205f80:	0040b797          	auipc	a5,0x40b
ffffffe000205f84:	8d078793          	addi	a5,a5,-1840 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205f88:	0107b783          	ld	a5,16(a5)
ffffffe000205f8c:	00078713          	mv	a4,a5
ffffffe000205f90:	04100793          	li	a5,65
ffffffe000205f94:	01f79793          	slli	a5,a5,0x1f
ffffffe000205f98:	00f707b3          	add	a5,a4,a5
ffffffe000205f9c:	0207d713          	srli	a4,a5,0x20
ffffffe000205fa0:	00407797          	auipc	a5,0x407
ffffffe000205fa4:	08878793          	addi	a5,a5,136 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205fa8:	0007b783          	ld	a5,0(a5)
ffffffe000205fac:	0007071b          	sext.w	a4,a4
ffffffe000205fb0:	08e7aa23          	sw	a4,148(a5)
    virtio_blk_regs->QueueDescLow = 0xffffffff & virt_to_phys((uint64_t)virtio_blk_ring.desc);
ffffffe000205fb4:	0040b797          	auipc	a5,0x40b
ffffffe000205fb8:	89c78793          	addi	a5,a5,-1892 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205fbc:	0087b783          	ld	a5,8(a5)
ffffffe000205fc0:	0007869b          	sext.w	a3,a5
ffffffe000205fc4:	00407797          	auipc	a5,0x407
ffffffe000205fc8:	06478793          	addi	a5,a5,100 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000205fcc:	0007b783          	ld	a5,0(a5)
ffffffe000205fd0:	80000737          	lui	a4,0x80000
ffffffe000205fd4:	00e6873b          	addw	a4,a3,a4
ffffffe000205fd8:	0007071b          	sext.w	a4,a4
ffffffe000205fdc:	08e7a023          	sw	a4,128(a5)
    virtio_blk_regs->QueueDescHigh = virt_to_phys((uint64_t)virtio_blk_ring.desc) >> 32;
ffffffe000205fe0:	0040b797          	auipc	a5,0x40b
ffffffe000205fe4:	87078793          	addi	a5,a5,-1936 # ffffffe000610850 <virtio_blk_ring>
ffffffe000205fe8:	0087b783          	ld	a5,8(a5)
ffffffe000205fec:	00078713          	mv	a4,a5
ffffffe000205ff0:	04100793          	li	a5,65
ffffffe000205ff4:	01f79793          	slli	a5,a5,0x1f
ffffffe000205ff8:	00f707b3          	add	a5,a4,a5
ffffffe000205ffc:	0207d713          	srli	a4,a5,0x20
ffffffe000206000:	00407797          	auipc	a5,0x407
ffffffe000206004:	02878793          	addi	a5,a5,40 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000206008:	0007b783          	ld	a5,0(a5)
ffffffe00020600c:	0007071b          	sext.w	a4,a4
ffffffe000206010:	08e7a223          	sw	a4,132(a5)
    virtio_blk_regs->QueueUsedLow = 0xffffffff & virt_to_phys((uint64_t)virtio_blk_ring.used);
ffffffe000206014:	0040b797          	auipc	a5,0x40b
ffffffe000206018:	83c78793          	addi	a5,a5,-1988 # ffffffe000610850 <virtio_blk_ring>
ffffffe00020601c:	0187b783          	ld	a5,24(a5)
ffffffe000206020:	0007869b          	sext.w	a3,a5
ffffffe000206024:	00407797          	auipc	a5,0x407
ffffffe000206028:	00478793          	addi	a5,a5,4 # ffffffe00060d028 <virtio_blk_regs>
ffffffe00020602c:	0007b783          	ld	a5,0(a5)
ffffffe000206030:	80000737          	lui	a4,0x80000
ffffffe000206034:	00e6873b          	addw	a4,a3,a4
ffffffe000206038:	0007071b          	sext.w	a4,a4
ffffffe00020603c:	0ae7a023          	sw	a4,160(a5)
    virtio_blk_regs->QueueUsedHigh = virt_to_phys((uint64_t)virtio_blk_ring.used) >> 32;
ffffffe000206040:	0040b797          	auipc	a5,0x40b
ffffffe000206044:	81078793          	addi	a5,a5,-2032 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206048:	0187b783          	ld	a5,24(a5)
ffffffe00020604c:	00078713          	mv	a4,a5
ffffffe000206050:	04100793          	li	a5,65
ffffffe000206054:	01f79793          	slli	a5,a5,0x1f
ffffffe000206058:	00f707b3          	add	a5,a4,a5
ffffffe00020605c:	0207d713          	srli	a4,a5,0x20
ffffffe000206060:	00407797          	auipc	a5,0x407
ffffffe000206064:	fc878793          	addi	a5,a5,-56 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000206068:	0007b783          	ld	a5,0(a5)
ffffffe00020606c:	0007071b          	sext.w	a4,a4
ffffffe000206070:	0ae7a223          	sw	a4,164(a5)
    memory_barrier();
ffffffe000206074:	c21ff0ef          	jal	ffffffe000205c94 <memory_barrier>
    virtio_blk_regs->QueueReady = 1;
ffffffe000206078:	00407797          	auipc	a5,0x407
ffffffe00020607c:	fb078793          	addi	a5,a5,-80 # ffffffe00060d028 <virtio_blk_regs>
ffffffe000206080:	0007b783          	ld	a5,0(a5)
ffffffe000206084:	00100713          	li	a4,1
ffffffe000206088:	04e7a223          	sw	a4,68(a5)
    memory_barrier();
ffffffe00020608c:	c09ff0ef          	jal	ffffffe000205c94 <memory_barrier>
}
ffffffe000206090:	00000013          	nop
ffffffe000206094:	03813083          	ld	ra,56(sp)
ffffffe000206098:	03013403          	ld	s0,48(sp)
ffffffe00020609c:	04010113          	addi	sp,sp,64
ffffffe0002060a0:	00008067          	ret

ffffffe0002060a4 <virtio_blk_config_init>:
void virtio_blk_config_init() {
ffffffe0002060a4:	fe010113          	addi	sp,sp,-32
ffffffe0002060a8:	00813c23          	sd	s0,24(sp)
ffffffe0002060ac:	02010413          	addi	s0,sp,32
    volatile struct virtio_blk_config *config = (struct virtio_blk_config*)(&virtio_blk_regs->Config);
ffffffe0002060b0:	00407797          	auipc	a5,0x407
ffffffe0002060b4:	f7878793          	addi	a5,a5,-136 # ffffffe00060d028 <virtio_blk_regs>
ffffffe0002060b8:	0007b783          	ld	a5,0(a5)
ffffffe0002060bc:	10078793          	addi	a5,a5,256
ffffffe0002060c0:	fef43423          	sd	a5,-24(s0)
    uint64_t capacity = ((uint64_t)config->capacity_hi << 32) | config->capacity_lo;
ffffffe0002060c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002060c8:	0047a783          	lw	a5,4(a5)
ffffffe0002060cc:	0007879b          	sext.w	a5,a5
ffffffe0002060d0:	02079793          	slli	a5,a5,0x20
ffffffe0002060d4:	0207d793          	srli	a5,a5,0x20
ffffffe0002060d8:	02079713          	slli	a4,a5,0x20
ffffffe0002060dc:	fe843783          	ld	a5,-24(s0)
ffffffe0002060e0:	0007a783          	lw	a5,0(a5)
ffffffe0002060e4:	0007879b          	sext.w	a5,a5
ffffffe0002060e8:	02079793          	slli	a5,a5,0x20
ffffffe0002060ec:	0207d793          	srli	a5,a5,0x20
ffffffe0002060f0:	00f767b3          	or	a5,a4,a5
ffffffe0002060f4:	fef43023          	sd	a5,-32(s0)
}
ffffffe0002060f8:	00000013          	nop
ffffffe0002060fc:	01813403          	ld	s0,24(sp)
ffffffe000206100:	02010113          	addi	sp,sp,32
ffffffe000206104:	00008067          	ret

ffffffe000206108 <virtio_blk_cmd>:
void virtio_blk_cmd(uint32_t type, uint32_t sector, void* buf) {
ffffffe000206108:	fe010113          	addi	sp,sp,-32
ffffffe00020610c:	00113c23          	sd	ra,24(sp)
ffffffe000206110:	00813823          	sd	s0,16(sp)
ffffffe000206114:	02010413          	addi	s0,sp,32
ffffffe000206118:	00050793          	mv	a5,a0
ffffffe00020611c:	00058713          	mv	a4,a1
ffffffe000206120:	fec43023          	sd	a2,-32(s0)
ffffffe000206124:	fef42623          	sw	a5,-20(s0)
ffffffe000206128:	00070793          	mv	a5,a4
ffffffe00020612c:	fef42423          	sw	a5,-24(s0)
	virtio_blk_req.type = type;
ffffffe000206130:	0040a797          	auipc	a5,0x40a
ffffffe000206134:	74078793          	addi	a5,a5,1856 # ffffffe000610870 <virtio_blk_req>
ffffffe000206138:	fec42703          	lw	a4,-20(s0)
ffffffe00020613c:	00e7a023          	sw	a4,0(a5)
    virtio_blk_req.sector = sector;
ffffffe000206140:	fe846703          	lwu	a4,-24(s0)
ffffffe000206144:	0040a797          	auipc	a5,0x40a
ffffffe000206148:	72c78793          	addi	a5,a5,1836 # ffffffe000610870 <virtio_blk_req>
ffffffe00020614c:	00e7b423          	sd	a4,8(a5)
    virtio_blk_ring.desc[0].addr = virt_to_phys((uint64_t)&virtio_blk_req);
ffffffe000206150:	0040a697          	auipc	a3,0x40a
ffffffe000206154:	72068693          	addi	a3,a3,1824 # ffffffe000610870 <virtio_blk_req>
ffffffe000206158:	0040a797          	auipc	a5,0x40a
ffffffe00020615c:	6f878793          	addi	a5,a5,1784 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206160:	0087b783          	ld	a5,8(a5)
ffffffe000206164:	04100713          	li	a4,65
ffffffe000206168:	01f71713          	slli	a4,a4,0x1f
ffffffe00020616c:	00e68733          	add	a4,a3,a4
ffffffe000206170:	00e7b023          	sd	a4,0(a5)
    virtio_blk_ring.desc[0].len = sizeof(struct virtio_blk_req);
ffffffe000206174:	0040a797          	auipc	a5,0x40a
ffffffe000206178:	6dc78793          	addi	a5,a5,1756 # ffffffe000610850 <virtio_blk_ring>
ffffffe00020617c:	0087b783          	ld	a5,8(a5)
ffffffe000206180:	01000713          	li	a4,16
ffffffe000206184:	00e7a423          	sw	a4,8(a5)
    virtio_blk_ring.desc[0].flags = VIRTQ_DESC_F_NEXT;
ffffffe000206188:	0040a797          	auipc	a5,0x40a
ffffffe00020618c:	6c878793          	addi	a5,a5,1736 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206190:	0087b783          	ld	a5,8(a5)
ffffffe000206194:	00100713          	li	a4,1
ffffffe000206198:	00e79623          	sh	a4,12(a5)
    virtio_blk_ring.desc[0].next = 1;
ffffffe00020619c:	0040a797          	auipc	a5,0x40a
ffffffe0002061a0:	6b478793          	addi	a5,a5,1716 # ffffffe000610850 <virtio_blk_ring>
ffffffe0002061a4:	0087b783          	ld	a5,8(a5)
ffffffe0002061a8:	00100713          	li	a4,1
ffffffe0002061ac:	00e79723          	sh	a4,14(a5)
    virtio_blk_ring.desc[1].addr = virt_to_phys((uint64_t)buf);
ffffffe0002061b0:	fe043683          	ld	a3,-32(s0)
ffffffe0002061b4:	0040a797          	auipc	a5,0x40a
ffffffe0002061b8:	69c78793          	addi	a5,a5,1692 # ffffffe000610850 <virtio_blk_ring>
ffffffe0002061bc:	0087b783          	ld	a5,8(a5)
ffffffe0002061c0:	01078793          	addi	a5,a5,16
ffffffe0002061c4:	04100713          	li	a4,65
ffffffe0002061c8:	01f71713          	slli	a4,a4,0x1f
ffffffe0002061cc:	00e68733          	add	a4,a3,a4
ffffffe0002061d0:	00e7b023          	sd	a4,0(a5)
    virtio_blk_ring.desc[1].len = VIRTIO_BLK_SECTOR_SIZE;
ffffffe0002061d4:	0040a797          	auipc	a5,0x40a
ffffffe0002061d8:	67c78793          	addi	a5,a5,1660 # ffffffe000610850 <virtio_blk_ring>
ffffffe0002061dc:	0087b783          	ld	a5,8(a5)
ffffffe0002061e0:	01078793          	addi	a5,a5,16
ffffffe0002061e4:	20000713          	li	a4,512
ffffffe0002061e8:	00e7a423          	sw	a4,8(a5)
    if (type == VIRTIO_BLK_T_IN) {
ffffffe0002061ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002061f0:	0007879b          	sext.w	a5,a5
ffffffe0002061f4:	02079063          	bnez	a5,ffffffe000206214 <virtio_blk_cmd+0x10c>
        virtio_blk_ring.desc[1].flags = VIRTQ_DESC_F_WRITE | VIRTQ_DESC_F_NEXT; 
ffffffe0002061f8:	0040a797          	auipc	a5,0x40a
ffffffe0002061fc:	65878793          	addi	a5,a5,1624 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206200:	0087b783          	ld	a5,8(a5)
ffffffe000206204:	01078793          	addi	a5,a5,16
ffffffe000206208:	00300713          	li	a4,3
ffffffe00020620c:	00e79623          	sh	a4,12(a5)
ffffffe000206210:	01c0006f          	j	ffffffe00020622c <virtio_blk_cmd+0x124>
        virtio_blk_ring.desc[1].flags = VIRTQ_DESC_F_NEXT;
ffffffe000206214:	0040a797          	auipc	a5,0x40a
ffffffe000206218:	63c78793          	addi	a5,a5,1596 # ffffffe000610850 <virtio_blk_ring>
ffffffe00020621c:	0087b783          	ld	a5,8(a5)
ffffffe000206220:	01078793          	addi	a5,a5,16
ffffffe000206224:	00100713          	li	a4,1
ffffffe000206228:	00e79623          	sh	a4,12(a5)
    virtio_blk_ring.desc[1].next = 2;
ffffffe00020622c:	0040a797          	auipc	a5,0x40a
ffffffe000206230:	62478793          	addi	a5,a5,1572 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206234:	0087b783          	ld	a5,8(a5)
ffffffe000206238:	01078793          	addi	a5,a5,16
ffffffe00020623c:	00200713          	li	a4,2
ffffffe000206240:	00e79723          	sh	a4,14(a5)
    virtio_blk_ring.desc[2].addr = virt_to_phys((uint64_t)&virtio_blk_status);
ffffffe000206244:	00407697          	auipc	a3,0x407
ffffffe000206248:	df468693          	addi	a3,a3,-524 # ffffffe00060d038 <virtio_blk_status>
ffffffe00020624c:	0040a797          	auipc	a5,0x40a
ffffffe000206250:	60478793          	addi	a5,a5,1540 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206254:	0087b783          	ld	a5,8(a5)
ffffffe000206258:	02078793          	addi	a5,a5,32
ffffffe00020625c:	04100713          	li	a4,65
ffffffe000206260:	01f71713          	slli	a4,a4,0x1f
ffffffe000206264:	00e68733          	add	a4,a3,a4
ffffffe000206268:	00e7b023          	sd	a4,0(a5)
    virtio_blk_ring.desc[2].len = sizeof(virtio_blk_status);
ffffffe00020626c:	0040a797          	auipc	a5,0x40a
ffffffe000206270:	5e478793          	addi	a5,a5,1508 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206274:	0087b783          	ld	a5,8(a5)
ffffffe000206278:	02078793          	addi	a5,a5,32
ffffffe00020627c:	00100713          	li	a4,1
ffffffe000206280:	00e7a423          	sw	a4,8(a5)
    virtio_blk_ring.desc[2].flags = VIRTQ_DESC_F_WRITE;
ffffffe000206284:	0040a797          	auipc	a5,0x40a
ffffffe000206288:	5cc78793          	addi	a5,a5,1484 # ffffffe000610850 <virtio_blk_ring>
ffffffe00020628c:	0087b783          	ld	a5,8(a5)
ffffffe000206290:	02078793          	addi	a5,a5,32
ffffffe000206294:	00200713          	li	a4,2
ffffffe000206298:	00e79623          	sh	a4,12(a5)
    virtio_blk_regs->Status |= DEVICE_DRIVER_OK;
ffffffe00020629c:	00407797          	auipc	a5,0x407
ffffffe0002062a0:	d8c78793          	addi	a5,a5,-628 # ffffffe00060d028 <virtio_blk_regs>
ffffffe0002062a4:	0007b783          	ld	a5,0(a5)
ffffffe0002062a8:	0707a783          	lw	a5,112(a5)
ffffffe0002062ac:	0007871b          	sext.w	a4,a5
ffffffe0002062b0:	00407797          	auipc	a5,0x407
ffffffe0002062b4:	d7878793          	addi	a5,a5,-648 # ffffffe00060d028 <virtio_blk_regs>
ffffffe0002062b8:	0007b783          	ld	a5,0(a5)
ffffffe0002062bc:	00476713          	ori	a4,a4,4
ffffffe0002062c0:	0007071b          	sext.w	a4,a4
ffffffe0002062c4:	06e7a823          	sw	a4,112(a5)
    virtio_blk_ring.avail->ring[(virtio_blk_ring.avail->idx + 1) % VIRTIO_QUEUE_SIZE] = 0;
ffffffe0002062c8:	0040a797          	auipc	a5,0x40a
ffffffe0002062cc:	58878793          	addi	a5,a5,1416 # ffffffe000610850 <virtio_blk_ring>
ffffffe0002062d0:	0107b683          	ld	a3,16(a5)
ffffffe0002062d4:	0040a797          	auipc	a5,0x40a
ffffffe0002062d8:	57c78793          	addi	a5,a5,1404 # ffffffe000610850 <virtio_blk_ring>
ffffffe0002062dc:	0107b783          	ld	a5,16(a5)
ffffffe0002062e0:	0027d783          	lhu	a5,2(a5)
ffffffe0002062e4:	0007879b          	sext.w	a5,a5
ffffffe0002062e8:	0017879b          	addiw	a5,a5,1
ffffffe0002062ec:	0007879b          	sext.w	a5,a5
ffffffe0002062f0:	00078713          	mv	a4,a5
ffffffe0002062f4:	41f7579b          	sraiw	a5,a4,0x1f
ffffffe0002062f8:	01c7d79b          	srliw	a5,a5,0x1c
ffffffe0002062fc:	00f7073b          	addw	a4,a4,a5
ffffffe000206300:	00f77713          	andi	a4,a4,15
ffffffe000206304:	40f707bb          	subw	a5,a4,a5
ffffffe000206308:	0007879b          	sext.w	a5,a5
ffffffe00020630c:	00179793          	slli	a5,a5,0x1
ffffffe000206310:	00f687b3          	add	a5,a3,a5
ffffffe000206314:	00079223          	sh	zero,4(a5)
    virtio_blk_ring.avail->idx += 1;
ffffffe000206318:	0040a797          	auipc	a5,0x40a
ffffffe00020631c:	53878793          	addi	a5,a5,1336 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206320:	0107b783          	ld	a5,16(a5)
ffffffe000206324:	0027d703          	lhu	a4,2(a5)
ffffffe000206328:	0040a797          	auipc	a5,0x40a
ffffffe00020632c:	52878793          	addi	a5,a5,1320 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206330:	0107b783          	ld	a5,16(a5)
ffffffe000206334:	0017071b          	addiw	a4,a4,1 # ffffffff80000001 <VM_END+0x80000001>
ffffffe000206338:	03071713          	slli	a4,a4,0x30
ffffffe00020633c:	03075713          	srli	a4,a4,0x30
ffffffe000206340:	00e79123          	sh	a4,2(a5)
    virtio_blk_regs->QueueNotify = 0;
ffffffe000206344:	00407797          	auipc	a5,0x407
ffffffe000206348:	ce478793          	addi	a5,a5,-796 # ffffffe00060d028 <virtio_blk_regs>
ffffffe00020634c:	0007b783          	ld	a5,0(a5)
ffffffe000206350:	0407a823          	sw	zero,80(a5)
    memory_barrier();
ffffffe000206354:	941ff0ef          	jal	ffffffe000205c94 <memory_barrier>
}
ffffffe000206358:	00000013          	nop
ffffffe00020635c:	01813083          	ld	ra,24(sp)
ffffffe000206360:	01013403          	ld	s0,16(sp)
ffffffe000206364:	02010113          	addi	sp,sp,32
ffffffe000206368:	00008067          	ret

ffffffe00020636c <virtio_blk_read_sector>:
void virtio_blk_read_sector(uint64_t sector, void *buf) {
ffffffe00020636c:	fd010113          	addi	sp,sp,-48
ffffffe000206370:	02113423          	sd	ra,40(sp)
ffffffe000206374:	02813023          	sd	s0,32(sp)
ffffffe000206378:	03010413          	addi	s0,sp,48
ffffffe00020637c:	fca43c23          	sd	a0,-40(s0)
ffffffe000206380:	fcb43823          	sd	a1,-48(s0)
    uint64_t original_idx = virtio_blk_ring.used->idx;
ffffffe000206384:	0040a797          	auipc	a5,0x40a
ffffffe000206388:	4cc78793          	addi	a5,a5,1228 # ffffffe000610850 <virtio_blk_ring>
ffffffe00020638c:	0187b783          	ld	a5,24(a5)
ffffffe000206390:	0027d783          	lhu	a5,2(a5)
ffffffe000206394:	fef43423          	sd	a5,-24(s0)
    virtio_blk_cmd(VIRTIO_BLK_T_IN, sector, buf);
ffffffe000206398:	fd843783          	ld	a5,-40(s0)
ffffffe00020639c:	0007879b          	sext.w	a5,a5
ffffffe0002063a0:	fd043603          	ld	a2,-48(s0)
ffffffe0002063a4:	00078593          	mv	a1,a5
ffffffe0002063a8:	00000513          	li	a0,0
ffffffe0002063ac:	d5dff0ef          	jal	ffffffe000206108 <virtio_blk_cmd>
        if (virtio_blk_ring.used->idx != original_idx) {
ffffffe0002063b0:	0040a797          	auipc	a5,0x40a
ffffffe0002063b4:	4a078793          	addi	a5,a5,1184 # ffffffe000610850 <virtio_blk_ring>
ffffffe0002063b8:	0187b783          	ld	a5,24(a5)
ffffffe0002063bc:	0027d783          	lhu	a5,2(a5)
ffffffe0002063c0:	00078713          	mv	a4,a5
ffffffe0002063c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002063c8:	00e79463          	bne	a5,a4,ffffffe0002063d0 <virtio_blk_read_sector+0x64>
ffffffe0002063cc:	fe5ff06f          	j	ffffffe0002063b0 <virtio_blk_read_sector+0x44>
            break;
ffffffe0002063d0:	00000013          	nop
}
ffffffe0002063d4:	00000013          	nop
ffffffe0002063d8:	02813083          	ld	ra,40(sp)
ffffffe0002063dc:	02013403          	ld	s0,32(sp)
ffffffe0002063e0:	03010113          	addi	sp,sp,48
ffffffe0002063e4:	00008067          	ret

ffffffe0002063e8 <virtio_blk_write_sector>:
void virtio_blk_write_sector(uint64_t sector, const void *buf) {
ffffffe0002063e8:	fd010113          	addi	sp,sp,-48
ffffffe0002063ec:	02113423          	sd	ra,40(sp)
ffffffe0002063f0:	02813023          	sd	s0,32(sp)
ffffffe0002063f4:	03010413          	addi	s0,sp,48
ffffffe0002063f8:	fca43c23          	sd	a0,-40(s0)
ffffffe0002063fc:	fcb43823          	sd	a1,-48(s0)
    uint64_t original_idx = virtio_blk_ring.used->idx;
ffffffe000206400:	0040a797          	auipc	a5,0x40a
ffffffe000206404:	45078793          	addi	a5,a5,1104 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206408:	0187b783          	ld	a5,24(a5)
ffffffe00020640c:	0027d783          	lhu	a5,2(a5)
ffffffe000206410:	fef43423          	sd	a5,-24(s0)
    virtio_blk_cmd(VIRTIO_BLK_T_OUT, sector, (void*)buf);
ffffffe000206414:	fd843783          	ld	a5,-40(s0)
ffffffe000206418:	0007879b          	sext.w	a5,a5
ffffffe00020641c:	fd043603          	ld	a2,-48(s0)
ffffffe000206420:	00078593          	mv	a1,a5
ffffffe000206424:	00100513          	li	a0,1
ffffffe000206428:	ce1ff0ef          	jal	ffffffe000206108 <virtio_blk_cmd>
        if (virtio_blk_ring.used->idx != original_idx) {
ffffffe00020642c:	0040a797          	auipc	a5,0x40a
ffffffe000206430:	42478793          	addi	a5,a5,1060 # ffffffe000610850 <virtio_blk_ring>
ffffffe000206434:	0187b783          	ld	a5,24(a5)
ffffffe000206438:	0027d783          	lhu	a5,2(a5)
ffffffe00020643c:	00078713          	mv	a4,a5
ffffffe000206440:	fe843783          	ld	a5,-24(s0)
ffffffe000206444:	00e79463          	bne	a5,a4,ffffffe00020644c <virtio_blk_write_sector+0x64>
ffffffe000206448:	fe5ff06f          	j	ffffffe00020642c <virtio_blk_write_sector+0x44>
            break;
ffffffe00020644c:	00000013          	nop
}
ffffffe000206450:	00000013          	nop
ffffffe000206454:	02813083          	ld	ra,40(sp)
ffffffe000206458:	02013403          	ld	s0,32(sp)
ffffffe00020645c:	03010113          	addi	sp,sp,48
ffffffe000206460:	00008067          	ret

ffffffe000206464 <virtio_blk_init>:
void virtio_blk_init() {
ffffffe000206464:	de010113          	addi	sp,sp,-544
ffffffe000206468:	20113c23          	sd	ra,536(sp)
ffffffe00020646c:	20813823          	sd	s0,528(sp)
ffffffe000206470:	22010413          	addi	s0,sp,544
    virtio_blk_driver_init();
ffffffe000206474:	871ff0ef          	jal	ffffffe000205ce4 <virtio_blk_driver_init>
    virtio_blk_feature_init();
ffffffe000206478:	8fdff0ef          	jal	ffffffe000205d74 <virtio_blk_feature_init>
    virtio_blk_config_init();
ffffffe00020647c:	c29ff0ef          	jal	ffffffe0002060a4 <virtio_blk_config_init>
    virtio_blk_queue_init();
ffffffe000206480:	9b9ff0ef          	jal	ffffffe000205e38 <virtio_blk_queue_init>
    virtio_blk_read_sector(0, buf);
ffffffe000206484:	df040793          	addi	a5,s0,-528
ffffffe000206488:	00078593          	mv	a1,a5
ffffffe00020648c:	00000513          	li	a0,0
ffffffe000206490:	eddff0ef          	jal	ffffffe00020636c <virtio_blk_read_sector>
    boot_signature[0] = buf[510];
ffffffe000206494:	fee44783          	lbu	a5,-18(s0)
ffffffe000206498:	def40423          	sb	a5,-536(s0)
    boot_signature[1] = buf[511];
ffffffe00020649c:	fef44783          	lbu	a5,-17(s0)
ffffffe0002064a0:	def404a3          	sb	a5,-535(s0)
    if (boot_signature[0] != 0x55 || boot_signature[1] != 0xaa) {
ffffffe0002064a4:	de844783          	lbu	a5,-536(s0)
ffffffe0002064a8:	00078713          	mv	a4,a5
ffffffe0002064ac:	05500793          	li	a5,85
ffffffe0002064b0:	00f71a63          	bne	a4,a5,ffffffe0002064c4 <virtio_blk_init+0x60>
ffffffe0002064b4:	de944783          	lbu	a5,-535(s0)
ffffffe0002064b8:	00078713          	mv	a4,a5
ffffffe0002064bc:	0aa00793          	li	a5,170
ffffffe0002064c0:	02f70663          	beq	a4,a5,ffffffe0002064ec <virtio_blk_init+0x88>
        Err("[S] mbr boot signature not found!");
ffffffe0002064c4:	00001697          	auipc	a3,0x1
ffffffe0002064c8:	3d468693          	addi	a3,a3,980 # ffffffe000207898 <__func__.0>
ffffffe0002064cc:	08a00613          	li	a2,138
ffffffe0002064d0:	00001597          	auipc	a1,0x1
ffffffe0002064d4:	35858593          	addi	a1,a1,856 # ffffffe000207828 <lowerxdigits.0+0xc0>
ffffffe0002064d8:	00001517          	auipc	a0,0x1
ffffffe0002064dc:	36050513          	addi	a0,a0,864 # ffffffe000207838 <lowerxdigits.0+0xd0>
ffffffe0002064e0:	87cfe0ef          	jal	ffffffe00020455c <printk>
ffffffe0002064e4:	00000013          	nop
ffffffe0002064e8:	ffdff06f          	j	ffffffe0002064e4 <virtio_blk_init+0x80>
    printk("...virtio_blk_init done!\n");
ffffffe0002064ec:	00001517          	auipc	a0,0x1
ffffffe0002064f0:	38c50513          	addi	a0,a0,908 # ffffffe000207878 <lowerxdigits.0+0x110>
ffffffe0002064f4:	868fe0ef          	jal	ffffffe00020455c <printk>
}
ffffffe0002064f8:	00000013          	nop
ffffffe0002064fc:	21813083          	ld	ra,536(sp)
ffffffe000206500:	21013403          	ld	s0,528(sp)
ffffffe000206504:	22010113          	addi	sp,sp,544
ffffffe000206508:	00008067          	ret

ffffffe00020650c <virtio_dev_test>:
int virtio_dev_test(uint64_t virtio_addr) {
ffffffe00020650c:	fd010113          	addi	sp,sp,-48
ffffffe000206510:	02113423          	sd	ra,40(sp)
ffffffe000206514:	02813023          	sd	s0,32(sp)
ffffffe000206518:	03010413          	addi	s0,sp,48
ffffffe00020651c:	fca43c23          	sd	a0,-40(s0)
    void *virtio_space = (char*)(virtio_addr);
ffffffe000206520:	fd843783          	ld	a5,-40(s0)
ffffffe000206524:	fef43423          	sd	a5,-24(s0)
    struct virtio_regs *virtio_header = virtio_space;
ffffffe000206528:	fe843783          	ld	a5,-24(s0)
ffffffe00020652c:	fef43023          	sd	a5,-32(s0)
    if (in32(&virtio_header->DeviceID) == ID_VIRTIO_BLK) {
ffffffe000206530:	fe043783          	ld	a5,-32(s0)
ffffffe000206534:	00878793          	addi	a5,a5,8
ffffffe000206538:	00078513          	mv	a0,a5
ffffffe00020653c:	f28ff0ef          	jal	ffffffe000205c64 <in32>
ffffffe000206540:	00050793          	mv	a5,a0
ffffffe000206544:	0007879b          	sext.w	a5,a5
ffffffe000206548:	00078713          	mv	a4,a5
ffffffe00020654c:	00200793          	li	a5,2
ffffffe000206550:	00f71a63          	bne	a4,a5,ffffffe000206564 <virtio_dev_test+0x58>
        virtio_blk_regs = virtio_space;
ffffffe000206554:	00407797          	auipc	a5,0x407
ffffffe000206558:	ad478793          	addi	a5,a5,-1324 # ffffffe00060d028 <virtio_blk_regs>
ffffffe00020655c:	fe843703          	ld	a4,-24(s0)
ffffffe000206560:	00e7b023          	sd	a4,0(a5)
    return 0;
ffffffe000206564:	00000793          	li	a5,0
}
ffffffe000206568:	00078513          	mv	a0,a5
ffffffe00020656c:	02813083          	ld	ra,40(sp)
ffffffe000206570:	02013403          	ld	s0,32(sp)
ffffffe000206574:	03010113          	addi	sp,sp,48
ffffffe000206578:	00008067          	ret

ffffffe00020657c <virtio_dev_init>:
void virtio_dev_init() {
ffffffe00020657c:	fe010113          	addi	sp,sp,-32
ffffffe000206580:	00113c23          	sd	ra,24(sp)
ffffffe000206584:	00813823          	sd	s0,16(sp)
ffffffe000206588:	02010413          	addi	s0,sp,32
    for (int i = 0; i < VIRTIO_COUNT; i++) {
ffffffe00020658c:	fe042623          	sw	zero,-20(s0)
ffffffe000206590:	0480006f          	j	ffffffe0002065d8 <virtio_dev_init+0x5c>
        uint64_t addr = VIRTIO_START + i * VIRTIO_SIZE;
ffffffe000206594:	fec42783          	lw	a5,-20(s0)
ffffffe000206598:	00078713          	mv	a4,a5
ffffffe00020659c:	000107b7          	lui	a5,0x10
ffffffe0002065a0:	0017879b          	addiw	a5,a5,1 # 10001 <PGSIZE+0xf001>
ffffffe0002065a4:	00f707bb          	addw	a5,a4,a5
ffffffe0002065a8:	0007879b          	sext.w	a5,a5
ffffffe0002065ac:	00c7979b          	slliw	a5,a5,0xc
ffffffe0002065b0:	0007879b          	sext.w	a5,a5
ffffffe0002065b4:	fef43023          	sd	a5,-32(s0)
        virtio_dev_test(io_to_virt(addr));
ffffffe0002065b8:	fe043503          	ld	a0,-32(s0)
ffffffe0002065bc:	ef8ff0ef          	jal	ffffffe000205cb4 <io_to_virt>
ffffffe0002065c0:	00050793          	mv	a5,a0
ffffffe0002065c4:	00078513          	mv	a0,a5
ffffffe0002065c8:	f45ff0ef          	jal	ffffffe00020650c <virtio_dev_test>
    for (int i = 0; i < VIRTIO_COUNT; i++) {
ffffffe0002065cc:	fec42783          	lw	a5,-20(s0)
ffffffe0002065d0:	0017879b          	addiw	a5,a5,1
ffffffe0002065d4:	fef42623          	sw	a5,-20(s0)
ffffffe0002065d8:	fec42783          	lw	a5,-20(s0)
ffffffe0002065dc:	0007871b          	sext.w	a4,a5
ffffffe0002065e0:	00700793          	li	a5,7
ffffffe0002065e4:	fae7d8e3          	bge	a5,a4,ffffffe000206594 <virtio_dev_init+0x18>
    if (virtio_blk_regs) {
ffffffe0002065e8:	00407797          	auipc	a5,0x407
ffffffe0002065ec:	a4078793          	addi	a5,a5,-1472 # ffffffe00060d028 <virtio_blk_regs>
ffffffe0002065f0:	0007b783          	ld	a5,0(a5)
ffffffe0002065f4:	00078463          	beqz	a5,ffffffe0002065fc <virtio_dev_init+0x80>
        virtio_blk_init();
ffffffe0002065f8:	e6dff0ef          	jal	ffffffe000206464 <virtio_blk_init>
ffffffe0002065fc:	00000013          	nop
ffffffe000206600:	01813083          	ld	ra,24(sp)
ffffffe000206604:	01013403          	ld	s0,16(sp)
ffffffe000206608:	02010113          	addi	sp,sp,32
ffffffe00020660c:	00008067          	ret
