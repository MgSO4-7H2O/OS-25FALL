#include "stdint.h"
#include "defs.h"
#include "printk.h"
#include "mm.h"
#include "string.h"



void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);
/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    // 初始化页表
    printk("...setup_vm init early_pgtbl\n");
    for (int i = 0; i < 512; i++) {
        early_pgtbl[i] = 0x0;
    }

    // 获取起始虚拟页号
    uint64_t vpn2 = (VM_START >> 30) & 0x1FF; // VPN[2]为30~38位
    // 获取起始物理页号
    uint64_t ppn2 = PGROUNDDOWN(PHY_START) >> 30 & 0x1FF;
    // 构造RISC-V Sv39页表项，最低位放置在28位
    uint64_t pte = (ppn2 << 28) | 0xF; // V R W X 位均为1


    // 映射到direct mapping area
    early_pgtbl[vpn2] = pte;

    printk("return\n");
}

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */

uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
    memset(swapper_pg_dir, 0x0, PGSIZE);

    // mapping kernel text X|-|R|V
    uint64_t text_va_start = (uint64_t)_stext;               // 虚拟地址空间中 .text 段起点
    uint64_t text_pa_start = VA2PA(text_va_start);           // 转换为物理地址起点
    uint64_t text_sz = PGROUNDUP((uint64_t)_etext - text_va_start); // 对齐后保障整页映射
    if (text_sz) {
        create_mapping(swapper_pg_dir, text_va_start, text_pa_start, text_sz, PTE_X | PTE_R);
    }

    // mapping kernel rodata -|-|R|V
    uint64_t rodata_va_start = (uint64_t)_srodata;           // 只读数据段起点
    uint64_t rodata_pa_start = VA2PA(rodata_va_start);
    uint64_t rodata_sz = PGROUNDUP((uint64_t)_erodata - rodata_va_start);
    if (rodata_sz) {
        create_mapping(swapper_pg_dir, rodata_va_start, rodata_pa_start, rodata_sz, PTE_R);
    }

    // mapping other memory -|W|R|V
    uint64_t writable_va_start = (uint64_t)_sdata;               // 其他区域（从 sdata 开始）
    uint64_t writable_pa_start = VA2PA(writable_va_start);
    uint64_t writable_sz = PGROUNDUP(((uint64_t)PHY_END) - writable_pa_start);
    if (writable_sz) {
        create_mapping(swapper_pg_dir, writable_va_start, writable_pa_start, writable_sz, PTE_W | PTE_R);
    }

    // set satp with swapper_pg_dir
    uint64_t pgdir_pa = VA2PA((uint64_t)swapper_pg_dir);     // 获取物理页号
    uint64_t satp_val = SATP_MODE_SV39 | PPN_OF(pgdir_pa);   // MODE = 8 | PPN
    csr_write(satp, satp_val);

    // flush TLB
    asm volatile("sfence.vma zero, zero");
    return;
}

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    uint64_t va_start = PGROUNDDOWN(va);
    uint64_t va_end = PGROUNDUP(va + sz);
    uint64_t pa_start = PGROUNDDOWN(pa);

    // 建立映射，遍历每一页
    for (uint64_t cur_va = va_start, cur_pa = pa_start; cur_va < va_end; cur_va += PGSIZE, cur_pa += PGSIZE) {
        // 取各级VPN
        uint64_t vpn2 = VPN2(cur_va);
        uint64_t vpn1 = VPN1(cur_va);
        uint64_t vpn0 = VPN0(cur_va);

        uint64_t *l2_table_va = pgtbl;                      // 根页表的虚拟地址
        uint64_t *pte_l2 = &l2_table_va[vpn2];

        // L2
        // 取页表项，并获取下一级页表地址
        // 如果页表项无效，分配新页表
        if (!(*pte_l2 & PTE_V)) {
            uint64_t *new_l1 = (uint64_t *)kalloc();
            if (new_l1 == 0) {
                printk("create_mapping: kalloc failed (L1)\n");
                return;
            }
            memset(new_l1, 0, PGSIZE);
            uint64_t new_l1_pa = VA2PA((uint64_t)new_l1);
            *pte_l2 = PTE_FROM_PPN(PPN_OF(new_l1_pa)) | PTE_V;
        }
        // 解析 L1 的虚拟地址以便访问
        uint64_t l1_pa = PA_FROM_PPN(PPN_FROM_PTE(*pte_l2));
        uint64_t *l1_table_va = (uint64_t *)PA2VA(l1_pa);

        // L1，原理同上
        uint64_t *pte_l1 = &l1_table_va[vpn1];
        if (!(*pte_l1 & PTE_V)) {
            uint64_t *new_l0 = (uint64_t *)kalloc();
            if (new_l0 == 0) {
                printk("create_mapping: kalloc failed (L0)\n");
                return;
            }
            memset(new_l0, 0, PGSIZE);
            uint64_t new_l0_pa = VA2PA((uint64_t)new_l0);
            *pte_l1 = PTE_FROM_PPN(PPN_OF(new_l0_pa)) | PTE_V;
        }
        uint64_t l0_pa = PA_FROM_PPN(PPN_FROM_PTE(*pte_l1));
        uint64_t *l0_table_va = (uint64_t *)PA2VA(l0_pa);

        // 叶子页表，直接映射
        uint64_t *pte_l0 = &l0_table_va[vpn0];
        *pte_l0 = PTE_FROM_PPN(PPN_OF(cur_pa)) | perm | PTE_V;
    }

    asm volatile("sfence.vma zero, zero");
    return;
}