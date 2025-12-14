#define PHY_START 0x0000000080000000
#define PHY_SIZE 128 * 1024 * 1024 // 128 MiB，QEMU 默认内存大小
#define PHY_END (PHY_START + PHY_SIZE)

#define PGSIZE 0x1000 // 4 KiB
#define PGROUNDUP(addr) ((addr + PGSIZE - 1) & (~(PGSIZE - 1)))
#define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1)))
#ifndef __DEFS_H__
#define __DEFS_H__

#define OPENSBI_SIZE (0x200000)

#define VM_START (0xffffffe000000000)
#define VM_END (0xffffffff00000000)
#define VM_SIZE (VM_END - VM_START)

#define PA2VA_OFFSET (VM_START - PHY_START)

// 提取虚拟地址的各级页号
#define VPN2(va) (((va) >> 30) & 0x1FF) // 9 bits
#define VPN1(va) (((va) >> 21) & 0x1FF) // 9 bits
#define VPN0(va) (((va) >> 12) & 0x1FF) // 9 bits

// 从物理地址获取 PPN  物理地址的前x位为物理页号
#define PPN_OF(pa) ((uint64_t)(pa) >> 12)
// 从 PPN 构造 PTE 的 PPN 部分
#define PTE_FROM_PPN(ppn) ((uint64_t)(ppn) << 10)
// 从 PTE 获取 PPN 只要44位PPN 用与上44位1来获取
#define PPN_FROM_PTE(pte) (((pte) >> 10) & 0xFFFFFFFFFFF)
// 从 PPN 获取物理地址 复原
#define PA_FROM_PPN(ppn) ((uint64_t)(ppn) << 12)

// PTE 标志位
#define PTE_V (1L << 0)
#define PTE_R (1L << 1)
#define PTE_W (1L << 2)
#define PTE_X (1L << 3)
#define PTE_U (1L << 4)

#define SATP_MODE_SV39 (8UL << 60)

#define PA2VA_OFFSET_VAL ((uint64_t)PA2VA_OFFSET)
#define VA2PA(va) ((uint64_t)(va) - PA2VA_OFFSET_VAL)
#define PA2VA(pa) ((uint64_t)(pa) + PA2VA_OFFSET_VAL)

#include "stdint.h"

extern char _stext[];
extern char _etext[];
extern char _srodata[];
extern char _erodata[];
extern char _sdata[];
extern char _edata[];
extern char _end[];

// VMA flags
#define VM_ANON 0x1
#define VM_READ 0x2
#define VM_WRITE 0x4
#define VM_EXEC 0x8

// 读取寄存器并返回值
#define csr_read(csr)                   \
  ({                                    \
    uint64_t __v;                       \
    asm volatile("csrr %0, " #csr : "=r"(__v) :: "memory"); \
    __v;                                \
  })

#define csr_write(csr, val)                                    \
  ({                                                           \
    uint64_t __v = (uint64_t)(val);                            \
    asm volatile("csrw " #csr ", %0" : : "r"(__v) : "memory"); \
  })

#define USER_START (0x0000000000000000) // user space start virtual address
#define USER_END (0x0000004000000000) // user space end virtual address

#endif