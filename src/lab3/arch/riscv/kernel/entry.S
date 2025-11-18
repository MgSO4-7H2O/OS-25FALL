    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
    .extern dummy
    .globl __dummy
    .globl __switch_to
__dummy:
    # 将sepc设置为dummy()的地址
    la t0, dummy
    csrw sepc, t0

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
    

    ret
_traps:
    # 1. save 32 registers and sepc to stack
    # 2. call trap_handler
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    # 4. return from trap
    addi sp, sp, -272
    # 保存寄存器
    sd zero, 0(sp)
    sd ra, 8(sp)
    sd gp, 16(sp)
    sd tp, 24(sp)
    sd t0, 32(sp)
    sd t1, 40(sp)
    sd t2, 48(sp)
    sd s0, 56(sp)
    sd s1, 64(sp)
    sd a0, 72(sp)
    sd a1, 80(sp)
    sd a2, 88(sp)
    sd a3, 96(sp)
    sd a4, 104(sp)
    sd a5, 112(sp)
    sd a6, 120(sp)
    sd a7, 128(sp)
    sd s2, 136(sp)
    sd s3, 144(sp)
    sd s4, 152(sp)
    sd s5, 160(sp)
    sd s6, 168(sp)
    sd s7, 176(sp)
    sd s8, 184(sp)
    sd s9, 192(sp)
    sd s10, 200(sp)
    sd s11, 208(sp)
    sd t3, 216(sp)
    sd t4, 224(sp)
    sd t5, 232(sp)
    sd t6, 240(sp)
    
    # 保存 scause 和 sepc
    csrr t0, scause
    sd t0, 248(sp)
    csrr t0, sepc
    sd t0, 256(sp)

    # 传递参数
    ld a0, 248(sp)
    ld a1, 256(sp)

    call trap_handler

    # 恢复寄存器
    ld t0, 256(sp)
    csrw sepc, t0
    # ld t0, 248(sp)
    # csrw scause, t0

    ld t6, 240(sp)
    ld t5, 232(sp)
    ld t4, 224(sp)
    ld t3, 216(sp)
    ld s11, 208(sp)
    ld s10, 200(sp)
    ld s9, 192(sp)
    ld s8, 184(sp)
    ld s7, 176(sp)
    ld s6, 168(sp)
    ld s5, 160(sp)
    ld s4, 152(sp)
    ld s3, 144(sp)
    ld s2, 136(sp)
    ld a7, 128(sp)
    ld a6, 120(sp)
    ld a5, 112(sp)
    ld a4, 104(sp)
    ld a3, 96(sp)
    ld a2, 88(sp)
    ld a1, 80(sp)
    ld a0, 72(sp)
    ld s1, 64(sp)
    ld s0, 56(sp)
    ld t2, 48(sp)
    ld t1, 40(sp)
    ld t0, 32(sp)
    ld tp, 24(sp)
    ld gp, 16(sp)
    ld ra, 8(sp)
    ld zero, 0(sp)

    # 恢复栈顶
    addi sp, sp, 272

    # 返回
    sret