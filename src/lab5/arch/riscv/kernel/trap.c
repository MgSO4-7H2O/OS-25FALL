#include "stdint.h"
#include "proc.h"
#include "syscall.h"
#include "printk.h"

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
            case 0: Err("Instruction address misaligned\n"); break;
            case 1: Err("Instruction access fault\n"); break;
            case 2: Err("Illegal instruction\n"); break;
            case 3: Err("Breakpoint\n"); break;
            case 4: Err("Load address misaligned\n"); break;
            case 5: Err("Load access fault\n"); break;
            case 6: Err("Store/AMO address misaligned\n"); break;
            case 7: Err("Store/AMO access fault\n"); break;
            // 用户态触发
            case 8: {
                // printk("Environment call from U-mode\n");
                syscall(regs);
                break;
            } 
            case 9: Err("Environment call from S-mode\n"); break;
            case 11: Err("Environment call from M-mode\n"); break;
            case 12: {
                Log(GREEN "Instruction page fault at PC %lx" CLEAR, regs->sepc);
                do_page_fault(regs);
                break;
            }
            case 13: {
                Log(GREEN "Load page fault at PC %lx" CLEAR, regs->sepc); 
                do_page_fault(regs);
                break;
            }
            case 15: {
                Log(GREEN "Store/AMO page fault at PC %lx" CLEAR, regs->sepc); 
                do_page_fault(regs);
                break;
            }
            default: Err("Unknown exception\n"); break;
        }
    }
}