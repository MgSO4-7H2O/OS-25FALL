#include "mm.h"
#include "defs.h"
#include "proc.h"
#include "stdlib.h"
#include "printk.h"
#include "string.h"
#include "vm.h"
#include "elf.h"

extern void __dummy();
// user内存开始和结尾
extern char _sramdisk[];
extern char _eramdisk[];
extern uint64_t swapper_pg_dir[];


struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void load_program(struct task_struct *task) {
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    // uint64_t *pg = task->pgd;
    struct mm_struct *mm = task->mm;
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // alloc space and copy content
            uint64_t va = phdr->p_vaddr;
            uint64_t offset = phdr->p_offset;
            uint64_t filesz = phdr->p_filesz;
            uint64_t memsz = phdr->p_memsz;

            if (memsz == 0) continue;
            // 对齐
            // uint64_t va_start = va & ~(PGSIZE - 1);                     // 向下对齐
            // uint64_t va_end   = (va + memsz + PGSIZE - 1) & ~(PGSIZE - 1); // 向上对齐
            // uint64_t map_sz   = va_end - va_start;
            // uint64_t map_off  = va - va_start;  // 段内容在第一个页中的偏移            

            // // 计算页数，分配物理页
            // uint64_t pages = map_sz / PGSIZE;
            // uint64_t alloc_va = (uint64_t)alloc_pages(pages);
            // uint64_t pa = alloc_va - PA2VA_OFFSET;

            // memset((void *)alloc_va, 0, map_sz);

            // // copy content
            // memcpy((void *)(alloc_va + map_off), (void *)(_sramdisk + offset), filesz);

            // // do mapping
            // create_mapping(pg, va, pa, memsz, PTE_V | PTE_U | ((phdr->p_flags & PF_R) ? PTE_R : 0) |
            // ((phdr->p_flags & PF_W) ? PTE_W : 0) |
            // ((phdr->p_flags & PF_X) ? PTE_X : 0));
            uint64_t vm_flags = 0;
            if (phdr->p_flags & PF_R) vm_flags |= VM_READ;
            if (phdr->p_flags & PF_W) vm_flags |= VM_WRITE;
            if (phdr->p_flags & PF_X) vm_flags |= VM_EXEC;
            
            // 对齐
            uint64_t page_off = va & (PGSIZE - 1);  // 段在第一页的偏移
            uint64_t map_start = PGROUNDDOWN(va);   // VMA起点
            uint64_t map_len = PGROUNDUP(page_off + memsz);
            // 文件偏移
            uint64_t map_pgoff = offset - page_off;
            uint64_t map_filesz = filesz + map_pgoff;
            do_mmap(mm, map_start, map_len, map_pgoff, map_filesz, vm_flags);
        }
    }
    task->thread.sepc = ehdr->e_entry;
}
void task_init() {
    srand(2024);

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle
    idle = (struct task_struct *)kalloc();
    idle->state = TASK_RUNNING;
    idle->counter = 0;
    idle->priority = 0;
    idle->pid = 0;
    idle->thread.ra = (uint64_t)__dummy;
    idle->thread.sp = (uint64_t)idle + PGSIZE;
    idle->pgd = swapper_pg_dir;
    current = idle;
    task[0] = idle;
    

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
    //     - counter  = 0;
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    uint64_t uapp_size = (uint64_t)_eramdisk - (uint64_t)_sramdisk;
    uint64_t uapp_pages = (uapp_size + PGSIZE - 1) / PGSIZE;


    for (int i = 1; i < NR_TASKS; ++i) {
        task[i] = (struct task_struct *)kalloc();
        task[i]->state = TASK_RUNNING;
        task[i]->counter = 0;
        task[i]->priority = rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
        task[i]->pid = i;

        // 设置ra和sp
        task[i]->thread.ra = (uint64_t)__dummy;
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE;

        // 分配独立页表
        uint64_t *pg = (uint64_t *)kalloc();
        memcpy(pg, swapper_pg_dir, PGSIZE);
        task[i]->pgd = pg;

        // 载入ELF
        // load_program(task[i]);

        // 内核栈分配物理页
        // uint64_t ustack_va = (uint64_t)alloc_page();
        // uint64_t ustack_pa = ustack_va - (uint64_t)PA2VA_OFFSET;

        // 在虚拟页结尾映射
        // create_mapping(pg, USER_END - PGSIZE, ustack_pa, PGSIZE, PTE_V | PTE_R | PTE_W | PTE_U);

        // demand paging
        task[i]->mm = (struct mm_struct *)kalloc();
        task[i]->mm->mmap = NULL;
        
        // 载入ELF并建立VMA
        load_program(task[i]);
        // 栈
        do_mmap(task[i]->mm, USER_END - PGSIZE, PGSIZE, 0, 0, VM_READ | VM_WRITE | VM_ANON);

        // 设置用户态有关寄存器
        task[i]->thread.sstatus = csr_read(sstatus);
        task[i]->thread.sstatus &= ~(1<<8);
        task[i]->thread.sstatus |=  0x00040020;//(1 << 5) | (1 << 18);
        task[i]->thread.sscratch = USER_END;
        #if TEST_SCHED
            printk("INITIALIZE [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
        #endif    
    }
    printk("...task_init done!\n");
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

/*
* @mm       : current thread's mm_struct
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
    struct vm_area_struct *vma = mm->mmap;
    while (vma != NULL) {
        if (addr >= vma->vm_start && addr < vma->vm_end) {
            // 匹配到符合地址的VMA
            return vma;
        }
        vma = vma->vm_next;
    }
    return NULL;
}

/*
* @mm       : current thread's mm_struct
* @addr     : the va to map
* @len      : memory size to map
* @vm_pgoff : phdr->p_offset
* @vm_filesz: phdr->p_filesz  
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
    // 地址对齐
    uint64_t start = PGROUNDDOWN(addr);
    uint64_t end = PGROUNDUP(addr + len);
    struct vm_area_struct *vma = (struct vm_area_struct *)kalloc();
    vma->vm_mm = mm;
    vma->vm_flags = flags;
    vma->vm_filesz = vm_filesz;
    vma->vm_pgoff = vm_pgoff;
    // 如果VMA链表为空，直接添加
    if (mm->mmap == NULL) {
        mm->mmap = vma;
        vma->vm_next = NULL;
        vma->vm_prev = NULL;
        vma->vm_start = start;
        vma->vm_end = end;
        printk(GREEN"do_mmap:" CLEAR);
        printk("vma [%lx, %lx)\n", start, end);
        return start;
    }

    // 寻找合适的不重叠地址进行映射
    for (uint64_t addr = start; addr < end; addr += PGSIZE) {
        struct vm_area_struct *tmp = find_vma(mm, addr);
        if (tmp != NULL) {
            // 出现地址重叠，需要重新分配虚拟地址
            start = get_unmapped_area(mm, len);
            end = PGROUNDUP(start + len);
            break;
        }
    }
    vma->vm_start = start;
    vma->vm_end = end;
    // 插入到链表头部
    vma->vm_next = mm->mmap;
    vma->vm_prev = NULL;
    if (mm->mmap != NULL) {
        mm->mmap->vm_prev = vma;
    }
    mm->mmap = vma;
    printk(GREEN"do_mmap:" CLEAR);
    printk("vma [%lx, %lx)\n", start, end);
    return start;
}

uint64_t get_unmapped_area(struct mm_struct *mm, uint64_t len) {
    // 在用户地址空间内寻找一块不重叠的虚拟地址区域
    uint64_t start = USER_START;
    uint64_t end = USER_END;
    uint64_t aligned_len = PGROUNDUP(len);
    uint64_t page_num = aligned_len / PGSIZE;
    for (; start < end; start += PGSIZE) {
        uint64_t i;
        for (i = 0; i < page_num; ++i) {
            if (find_vma(mm, start + i * PGSIZE) != NULL) {
                // len范围内有重叠
                start = start + i * PGSIZE;
                break;
            }
        }
        if (i == page_num) {
            return start;
        }
    }
    // 没有找到合适的区域
    if (start >= end) {
        Err("get_unmapped_area failed!\n");
        return 0;
    }
}

void dummy() {
    printk("call dummy for current PID %d\n", current->pid);
    uint64_t MOD = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter = -1;
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
            #endif
        }
    }
}

extern void __switch_to(struct task_struct *prev, struct task_struct *next);

void switch_to(struct task_struct *next) {
    // 如果下一个线程是同一个线程，无需处理
    if (next == current) {
        return;
    }
    // 线程切换
    struct task_struct *prev = current;
    current = next;
    printk("Switch to [PID = %d PRIORITY = %d COUNTER = %d] from [PID = %d]\n", next->pid, next->priority, next->counter, prev->pid);
    __switch_to(prev, next);
    return;
}

void do_timer() {
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    if (current == idle || current->counter <= 0) {
        schedule();
    } else {
        --(current->counter);
        if (current->counter > 0) {
            return;
        } else {
            schedule();
        }
    }
    return;
}

void schedule() {
    // 参考Linux v0.11 调度算法代码
    int max_counter;
    int next_id;
    int i;
    struct task_struct **p;
	while (1) {
		max_counter = -1;
		next_id = 0;
		i = 0;
		p = &task[0];
        // 找到最大剩余时间的线程运行
		while (++i < NR_TASKS) {
			if (!*++p)
				continue;
			if ((*p)->state == TASK_RUNNING && (int)(*p)->counter > max_counter) {
                max_counter = (int)(*p)->counter;
                next_id = i;
            }
		}
		if (max_counter) break;
        // 所有线程counter都为0，令counter = priority
		for(p = &task[1] ; p < &task[NR_TASKS] ; ++p) {
            if (*p) {
                (*p)->counter = ((*p)->counter >> 1) + (*p)->priority;
                printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", (*p)->pid, (*p)->priority, (*p)->counter);
            }
        }
    }	
	switch_to(task[next_id]);
}

// 缺页异常处理函数
void do_page_fault(struct pt_regs *regs) {
    // 获得 bad addr
    uint64_t stval = csr_read(stval);
    // 获得scause
    uint64_t scause = csr_read(scause);
    // 检查是否在vma中
    struct vm_area_struct *vma = find_vma(current->mm, stval);
    if (vma == NULL) {
        // 非预期错误
        Err("Unexpected page fault at 0x%lx : not in vma", stval);
    }
    else {
        // 判断page fault是否合法
        // 12: instruction page fault, EXEC
        // 13: load page fault, READ
        // 15: store/AMO page fault, WRITE
        if ((scause == 12 && !(vma->vm_flags & VM_EXEC))
         || (scause == 13 && !(vma->vm_flags & VM_READ))
         || (scause == 15 && !(vma->vm_flags & VM_WRITE))) {
            Err("[PID = %d], Page fault at 0x%lx : illegal access for scause = %d\n", current->pid, stval, scause);
            return;
        }
        // 合法缺页，创建映射
        uint64_t va = PGROUNDDOWN(stval);

        // 分配一页
        uint64_t kva = (uint64_t)alloc_page();
        uint64_t pa = kva - PA2VA_OFFSET;

        // 如果是匿名空间，直接映射
        if (vma->vm_flags & VM_ANON) {
            // 清零
            memset((void *)kva, 0, PGSIZE);
        } else {
            // 根据 vma->vm_pgoff 等信息从 ELF 中读取数据，填充后映射到用户空间
            uint64_t page_offset = va - vma->vm_start;
            if (page_offset >= vma->vm_filesz) {
                // bss清零
                memset((void *)kva, 0, PGSIZE);
            } else {
                uint64_t file_offset = vma->vm_pgoff + page_offset;
                uint64_t bytes_left = vma->vm_filesz - page_offset;
                uint64_t copy_size = (bytes_left >= PGSIZE) ? PGSIZE : bytes_left;
                memcpy((void *)kva, (void *)(_sramdisk + file_offset), copy_size);
                // 不满一页，补零
                if (copy_size < PGSIZE) {
                    memset((void *)(kva + copy_size), 0, PGSIZE - copy_size);
                }
            }
        }

        // 权限
        uint64_t perm = PTE_V | PTE_U;
        if (vma->vm_flags & VM_READ)  perm |= PTE_R;
        if (vma->vm_flags & VM_WRITE) perm |= PTE_W;
        if (vma->vm_flags & VM_EXEC)  perm |= PTE_X;
        
        // 映射
        create_mapping(current->pgd, va, pa, PGSIZE, perm);
    }
}