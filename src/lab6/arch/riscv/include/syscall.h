#include "proc.h"

struct pt_regs {
    // 用于保存和提取寄存器值的结构体
    // 32个寄存器
    uint64_t regs_32[32];
    // sepc
    uint64_t sepc;
};

void syscall(struct pt_regs *regs);