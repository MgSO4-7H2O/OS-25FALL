    .extern start_kernel
    .extern _traps
    .extern _sbi_set_timer
    .extern mm_init
    .extern task_init
    .section .text.init
    .globl _start
_start:
    # ------------------
    # - your code here -
    # ------------------

    # load the stack top address into the stack pointer
    la sp, boot_stack_top

    # 开启trap处理新增指令，使用一个临时寄存器t0来存储_traps的地址
    la t0, _traps
    csrw stvec, t0

    # 初始化物理内存管理系统
    call mm_init

    # 初始化线程
    call task_init

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
    li t0, (1 << 1)
    csrs sstatus, t0
    
    # call the function
    call start_kernel

    .section .bss.stack
    .globl boot_stack
boot_stack:
    # the size of stack is 4kiB
    .space 4194304 # <-- change to your stack size
    .globl boot_stack_top
boot_stack_top: