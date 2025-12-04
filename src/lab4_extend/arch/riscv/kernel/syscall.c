#include "syscall.h"
#include "printk.h"
#include "proc.h"

extern struct task_struct* current;
void syscall(struct pt_regs *regs) {
    // 从a0 ~ a7寄存器中取参数
    // a7 系统调用号
    if (regs->regs_32[17] == (uint64_t)64) {
        // 调用sys_write，输出字符，返回打印的字符数
        if (regs->regs_32[10] == 1) {
            char* buf = (char*)regs->regs_32[11];
            for (int i = 0; i < regs->regs_32[12]; i++) {
                printk("%c", buf[i]);
            }
            regs->regs_32[10] = regs->regs_32[12];
        } else {
            printk("not support fd = %d\n", regs->regs_32[10]);
            regs->regs_32[10] = -1;
        }
    } else if (regs->regs_32[17] == (uint64_t)172) {
        // 调用sys_getpid()，获取当前线程pid
        regs->regs_32[10] = current->pid;
    } else {
        printk("not support syscall id = %d\n", regs->regs_32[17]);
    }
    // 手动返回地址+4
    regs->sepc += (uint64_t)4;
}