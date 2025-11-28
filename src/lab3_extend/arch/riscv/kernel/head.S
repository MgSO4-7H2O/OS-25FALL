    .extern start_kernel
    .extern _traps
    .extern _sbi_set_timer
    .extern mm_init
    .extern task_init
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

relocate:
    /* Relocate return address and sp (same as before) */
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    li t0, 0xffffffdf80000000
    add ra, ra, t0
    add sp, sp, t0

    /* We will set stvec to the *virtual* address of label 1 (the instruction after the satp write).
     * If the CPU cannot fetch the next instruction after satp (because VA!=PA), it will trap to stvec,
     * which is our safe virtual address and lets us continue execution in virtual space.
     *
     * Compute virtual address of 1f, add PA2VA offset (t0 above), and write to stvec.
     */
    la t1, 1f            # t1 = address of label 1 (assembly-time VA)
    add t1, t1, t0       # t1 = virtual address where label 1 will be after relocation
    csrw stvec, t1

    /* Ensure any PTEs we just wrote are visible before loading satp */
    sfence.vma zero, zero

    /* Now load the initial page table (use early_pgtbl as trampoline pgdir).
     * We load a satp formed from early_pgtbl's physical PPN - this is the same trick
     * Linux uses: load a small trampoline page table so execution can continue
     * even if VA != PA for the rest of memory.
     */
    la t0, early_pgtbl
    srli t0, t0, 12        # PPN = physical page >> 12 if la gave a physical-mapped symbol; if la gives VA, this still gives PPN of VA
    li t2, 8
    slli t2, t2, 60        # MODE = 8 (SV39)
    or t0, t0, t2          # t0 = satp value (MODE | PPN)
    csrw satp, t0

    /* The instruction stream continues at label 1: */
.align 2
1:
    /* After we've switched to the initial trampoline page table,
     * restore stvec to something sane (e.g. trap handler) and return.
     * The rest of kernel will set up final page tables and do final satp write.
     */
    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    # the size of stack is 4kiB
    .space 4194304 # <-- change to your stack size
    .globl boot_stack_top
boot_stack_top: