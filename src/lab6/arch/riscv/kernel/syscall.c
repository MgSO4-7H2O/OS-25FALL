#include "syscall.h"
#include "printk.h"
#include "proc.h"
#include "fs.h"

extern struct task_struct* current;

#define SYS_OPENAT  56
#define SYS_CLOSE   57
#define SYS_LSEEK   62
#define SYS_READ    63
#define SYS_WRITE   64
#define SYS_GETPID  172
#define SYS_CLONE   220

static int64_t sys_write(uint64_t fd, const char *buf, uint64_t len) {
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        printk("file not opened\n");
        return ERROR_FILE_NOT_OPEN;
    } else {
        // check perm
        if(!(file->perms & FILE_WRITABLE) || !file->write) {
            printk("file not writable\n");
            return -1;
        }
        // call write function
        ret = file->write(file, buf, len);
    }
    return ret;
}

static int64_t sys_read(uint64_t fd, char *buf, uint64_t len) {
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
    // 检查open和perm
    if (file->opened == 0) {
        printk("file not opened\n");
        return ERROR_FILE_NOT_OPEN;
    } else {
        // check perm
        if(!(file->perms & FILE_READABLE) || !file->read) {
            printk("file not readable\n");
            return -1;
        }
        // call read function
        ret = file->read(file, buf, len);
    }
    return ret;
}

static int64_t sys_openat(const char *path, int flags) {
    // 打开对应地址的文件
    // 寻找第一个空闲的文件描述符
    for (int i = 0; i < MAX_FILE_NUMBER; i++) {
        if (!current->files->fd_array[i].opened) {
            return file_open(&(current->files->fd_array[i]), path, flags) == 0 ? i : -1;
        }
    }
    // 无可用的描述符，返回-1表示打开失败
    return -1;
}

static int64_t sys_close(uint64_t fd) {
    // 关闭对应文件
    current->files->fd_array[fd].opened = 0;
    return 0;
}

static int64_t sys_lseek(uint64_t fd, uint64_t offset, uint64_t whence) {
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
    // 检查open和perm
    if (file->opened == 0) {
        printk("file not opened\n");
        return ERROR_FILE_NOT_OPEN;
    } else {
        // check perm
        if(!file->lseek) {
            printk("file not readable\n");
            return -1;
        }
        ret = file->lseek(file, offset, whence);
    }
    return ret;
}

void syscall(struct pt_regs *regs) {
    // 从a0 ~ a7寄存器中取参数
    // a7 系统调用号
    // if (regs->regs_32[17] == (uint64_t)64) {
    //     // 调用sys_write，输出字符，返回打印的字符数
    //     if (regs->regs_32[10] == 1) {
    //         char* buf = (char*)regs->regs_32[11];
    //         for (int i = 0; i < regs->regs_32[12]; i++) {
    //             printk("%c", buf[i]);
    //         }
    //         regs->regs_32[10] = regs->regs_32[12];
    //     } else {
    //         Err("not support fd = %d\n", regs->regs_32[10]);
    //         regs->regs_32[10] = -1;
    //     }
    // } else if (regs->regs_32[17] == (uint64_t)172) {
    //     // 调用sys_getpid()，获取当前线程pid
    //     regs->regs_32[10] = current->pid;
    // } else if (regs->regs_32[17] == (uint64_t)220) {
    //     // fork
    //     regs->regs_32[10] = do_fork(regs);
    // } else {
    //     Err("not support syscall id = %d\n", regs->regs_32[17]);
    // }
    switch (regs->regs_32[17]) {
        case SYS_WRITE:
            regs->regs_32[10] = sys_write(regs->regs_32[10], (char*)regs->regs_32[11], regs->regs_32[12]);
            break;
        case SYS_READ:
            regs->regs_32[10] = sys_read(regs->regs_32[10], (char*)regs->regs_32[11], regs->regs_32[12]);
            break;
        case SYS_OPENAT:
            regs->regs_32[10] = sys_openat((char*)regs->regs_32[11], regs->regs_32[12]);
            break;
        case SYS_CLOSE:
            regs->regs_32[10] = sys_close(regs->regs_32[10]);
            break;
        case SYS_LSEEK:
            regs->regs_32[10] = sys_lseek(regs->regs_32[10], regs->regs_32[11], regs->regs_32[12]);
            break;
        case SYS_GETPID:
            regs->regs_32[10] = current->pid;
            break;
        case SYS_CLONE:
            regs->regs_32[10] = do_fork(regs);
            break;
        default:
            Err("not support syscall id = %d\n", regs->regs_32[17]);
    }
    // 手动返回地址+4
    regs->sepc += (uint64_t)4;
}