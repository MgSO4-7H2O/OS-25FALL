#define SATP_MODE_SV39 (8UL << 60)
#define VM_START (0xffffffe000000000)
#define PHY_START 0x0000000080000000
#define PA2VA_OFFSET (VM_START - PHY_START)

    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
    .extern dummy
    .globl __dummy
    .globl __switch_to
__dummy:
    # 切换栈
    csrr t0, sscratch
    csrw sscratch, sp
    addi sp, t0, 0

    # la t0, dummy
    # csrw sepc, t0

    # 设置进入User mode的地址为代码段起始地址0
    # csrw sepc, x0

    # 从S模式返回
    sret

__switch_to:
    
    # uint64_t变量为8字节对齐
    addi t0, a0, 32 # t0: prev->thread
    addi t1, a1, 32 # t1: next->thread

    # save state to prev process
    sd ra, 0(t0)
    sd sp, 8(t0)
    sd s0, 16(t0)
    sd s1, 24(t0)
    sd s2, 32(t0)
    sd s3, 40(t0)
    sd s4, 48(t0)
    sd s5, 56(t0)
    sd s6, 64(t0)
    sd s7, 72(t0)
    sd s8, 80(t0)
    sd s9, 88(t0)
    sd s10, 96(t0)
    sd s11, 104(t0)

    csrr t2, sepc
    sd t2, 112(t0)
    csrr t2, sstatus
    sd t2, 120(t0)
    csrr t2, sscratch
    sd t2, 128(t0)

    # restore state from next process
    ld ra, 0(t1)
    ld sp, 8(t1)
    ld s0, 16(t1)
    ld s1, 24(t1)
    ld s2, 32(t1)
    ld s3, 40(t1)
    ld s4, 48(t1)
    ld s5, 56(t1)
    ld s6, 64(t1)
    ld s7, 72(t1)
    ld s8, 80(t1)
    ld s9, 88(t1)
    ld s10, 96(t1)
    ld s11, 104(t1)

    ld t2, 112(t1)
    csrw sepc, t2
    ld t2, 120(t1)
    csrw sstatus, t2
    ld t2, 128(t1)
    csrw sscratch, t2

    # get pgd, calculate satp
    ld t2, 136(t1)
    li t3, PA2VA_OFFSET
    sub t2, t2, t3
    srli t2, t2, 12
    li t3, SATP_MODE_SV39
    or t2, t2, t3

    csrw satp, t2
    
    sfence.vma
    

    ret
_traps:
    # 用户态触发trap需要进入内核态
    # 内核态触发trap，不需要切换
    # 内核态检查条件：sscratch == 0
    csrrw sp, sscratch, sp
    bnez sp, smode_no_switch
    csrrw sp, sscratch, sp
    # 1. save 32 registers and sepc to stack
    # 2. call trap_handler
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    # 4. return from trap
smode_no_switch:
    addi sp, sp, -264
    # 保存寄存器
    sd zero, 0(sp)
    sd ra, 8(sp)
    sd sp, 16(sp)
    sd gp, 24(sp)
    sd tp, 32(sp)
    sd t0, 40(sp)
    sd t1, 48(sp)
    sd t2, 56(sp)
    sd s0, 64(sp)
    sd s1, 72(sp)
    sd a0, 80(sp)
    sd a1, 88(sp)
    sd a2, 96(sp)
    sd a3, 104(sp)
    sd a4, 112(sp)
    sd a5, 120(sp)
    sd a6, 128(sp)
    sd a7, 136(sp)
    sd s2, 144(sp)
    sd s3, 152(sp)
    sd s4, 160(sp)
    sd s5, 168(sp)
    sd s6, 176(sp)
    sd s7, 184(sp)
    sd s8, 192(sp)
    sd s9, 200(sp)
    sd s10, 208(sp)
    sd s11, 216(sp)
    sd t3, 224(sp)
    sd t4, 232(sp)
    sd t5, 240(sp)
    sd t6, 248(sp)
    
    # 保存 sepc
    
    csrr t0, sepc
    sd t0, 256(sp)

    # 传递参数
    # a0 = scause a1 = sepc a2 = sp
    csrr a0, scause
    ld a1, 256(sp)
    mv a2, sp

    call trap_handler

    # 恢复寄存器
    ld t0, 256(sp)
    csrw sepc, t0
    ld t6, 248(sp)
    ld t5, 240(sp)
    ld t4, 232(sp)
    ld t3, 224(sp)
    ld s11, 216(sp)
    ld s10, 208(sp)
    ld s9, 200(sp)
    ld s8, 192(sp)
    ld s7, 184(sp)
    ld s6, 176(sp)
    ld s5, 168(sp)
    ld s4, 160(sp)
    ld s3, 152(sp)
    ld s2, 144(sp)
    ld a7, 136(sp)
    ld a6, 128(sp)
    ld a5, 120(sp)
    ld a4, 112(sp)
    ld a3, 104(sp)
    ld a2, 96(sp)
    ld a1, 88(sp)
    ld a0, 80(sp)
    ld s1, 72(sp)
    ld s0, 64(sp)
    ld t2, 56(sp)
    ld t1, 48(sp)
    ld t0, 40(sp)
    ld tp, 32(sp)
    ld gp, 24(sp)
    ld sp, 16(sp)
    ld ra, 8(sp)
    ld zero, 0(sp)

    # 恢复栈顶
    addi sp, sp, 264

    # 用户态切换
    csrr t0, sscratch
    beqz t0, smode_return
    csrw sscratch, sp
    mv sp, t0

smode_return:
    # 返回
    sret