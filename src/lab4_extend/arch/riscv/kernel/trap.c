#include "stdint.h"
#include "proc.h"
#include "syscall.h"

extern struct task_struct* current;


void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    // 通过 `scause` 判断 trap 类型
    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    // 参考: 63为interrupt, 0~62为code
    uint64_t code = scause & 0x7FFFFFFFFFFFFFFF;
    if (scause & 1ULL << 63) { // interrupt
        // 打印调试信息
        if (code == 1) {
            printk("[S] Supervisor Software Interrupt\n");
        }
        else if (code == 5) {
            // printk("[S] Supervisor Timer Interrupt\n");
        }
        else if (code == 9) {
            printk("[S] Supervisor External Interrupt\n");
        }
        else if (code == 13) {
            printk("Counter-overflow Interrupt\n");
        }
        else {
            printk("Reserved or Designed for Platform Use\n");
        }

        // 设置下一次时钟中断
        if (code == 5) { // timer interrupt
            clock_set_next_event();
            do_timer();
        }
    }
    else {  // exception
        // printk("Exception\n");
        switch(code) {
            case 0: printk("Instruction address misaligned\n"); break;
            case 1: printk("Instruction access fault\n"); break;
            case 2: printk("Illegal instruction\n"); break;
            case 3: printk("Breakpoint\n"); break;
            case 4: printk("Load address misaligned\n"); break;
            case 5: printk("Load access fault\n"); break;
            case 6: printk("Store/AMO address misaligned\n"); break;
            case 7: printk("Store/AMO access fault\n"); break;
            // 用户态触发
            case 8: {
                // printk("Environment call from U-mode\n");
                syscall(regs);
                break;
            } 
            case 9: printk("Environment call from S-mode\n"); break;
            case 11: printk("Environment call from M-mode\n"); break;
            case 12: printk("Instruction page fault\n"); break;
            case 13: printk("Load page fault\n"); break;
            case 15: printk("Store/AMO page fault\n"); break;
            default: printk("Unknown exception\n"); break;
        }
    }
}