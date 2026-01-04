    .extern start_kernel
    .extern _traps
    .extern _sbi_set_timer
    .extern mm_init
    .extern task_init
    .extern virtio_dev_init
    .extern mbr_init
    .extern early_pgtbl
    .extern setup_vm
    .extern setup_vm_final
    .section .text.init
    .globl _start
    .globl relocate
_start:
    # ------------------
    # - your code here -
    # ------------------

    # load the stack top address into the stack pointer
    la sp, boot_stack_top

    # 启动虚拟内存
    call setup_vm
    call relocate

    # 开启trap处理新增指令，使用一个临时寄存器t0来存储_traps的地址
    la t0, _traps
    csrw stvec, t0
    
    # 初始化物理内存管理系统
    call mm_init

    call setup_vm_final

    # 初始化线程
    call task_init

    call virtio_dev_init
    call mbr_init

    # 开启时钟中断，sie[STIE] 置 1
    li t0, (1 << 5)
    csrs sie, t0

    # 设置第一次时钟中断
    rdtime t0
    li t1, 10000000 # TIMECLOCK为10000000
    add t0, t0, t1
    # 参数传递
    mv a0, t0

    call sbi_set_timer

    #开启全局中断，sstatus[SIE] 置 1
    # li t0, (1 << 1)
    # csrs sstatus, t0
    
    # call the function
    call start_kernel

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li t0, 0xffffffdf80000000
    add ra, ra, t0
    add sp, sp, t0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl
    la t0, early_pgtbl

    # PA >> 12 == PPN
    srli t0, t0, 12

    # 构造satp
    # MODE = 8
    li t1, 8
    slli t1, t1, 60
    or t1, t1, t0

    csrw satp, t1

    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    # the size of stack is 4kiB
    .space 4194304 # <-- change to your stack size
    .globl boot_stack_top
boot_stack_top: