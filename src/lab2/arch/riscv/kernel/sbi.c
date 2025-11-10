#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    struct sbiret ret;
    uint64_t error_reg, value_reg;
    
    asm volatile(
        // 将参数传递到对应的寄存器中
        "mv a7, %[eid]\n"
        "mv a6, %[fid]\n"
        "mv a0, %[arg0]\n"
        "mv a1, %[arg1]\n"
        "mv a2, %[arg2]\n"
        "mv a3, %[arg3]\n"
        "mv a4, %[arg4]\n"
        "mv a5, %[arg5]\n"

        // trap进入M模式
        "ecall\n"

        // 将寄存器的输出结果传递到结构体中
        "mv %[error], a0\n"
        "mv %[value], a1\n"

        // 参数和变量映射
        // 输出
        : [error] "=r"(error_reg), 
          [value] "=r"(value_reg)
        // 输入
        : [eid] "r" (eid),
          [fid] "r" (fid),
          [arg0] "r" (arg0),
          [arg1] "r" (arg1),
          [arg2] "r" (arg2),
          [arg3] "r" (arg3),
          [arg4] "r" (arg4),
          [arg5] "r" (arg5) 
        // 告知可能修改内存
        : "memory",
        // 告知修改寄存器
          "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
          
    );

    // 返回结果
    ret.error = error_reg;
    ret.value = value_reg;
    return ret;
}

// 设置时钟相关寄存器
struct sbiret sbi_set_timer(uint64_t stime_value) {
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
}
// 向终端写入数据
// struct sbiret sbi_debug_console_write() {
    
// }
// 从终端读取数据
// struct sbiret sbi_debug_console_read() {
    
// }
// 向终端写入单个字符
struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    return sbi_ecall(0x4442434e, 0x2, byte, 0, 0, 0, 0, 0);
}
// 重置系统（关机或重启）
struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
}