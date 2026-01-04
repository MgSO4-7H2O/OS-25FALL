#include "fat32.h"
#include "printk.h"
#include "virtio.h"
#include "string.h"
#include "mbr.h"
#include "mm.h"

struct fat32_bpb fat32_header;
struct fat32_volume fat32_volume;

uint8_t fat32_buf[VIRTIO_BLK_SECTOR_SIZE];
uint8_t fat32_table_buf[VIRTIO_BLK_SECTOR_SIZE];

uint64_t cluster_to_sector(uint64_t cluster) {
    return (cluster - 2) * fat32_volume.sec_per_cluster + fat32_volume.first_data_sec;
}

uint32_t next_cluster(uint64_t cluster) {
    uint64_t fat_offset = cluster * 4;
    uint64_t fat_sector = fat32_volume.first_fat_sec + fat_offset / VIRTIO_BLK_SECTOR_SIZE;
    virtio_blk_read_sector(fat_sector, fat32_table_buf);
    int index_in_sector = fat_offset % (VIRTIO_BLK_SECTOR_SIZE / sizeof(uint32_t));
    return *(uint32_t*)(fat32_table_buf + index_in_sector);
}

void fat32_init(uint64_t lba, uint64_t size) {
    // 根据fat32_bpb的数据，计算并初始化fat32_volume元数据
    // 将磁盘上lba扇区的内容读到内存中，获得header内的信息
    virtio_blk_read_sector(lba, (void*)&fat32_header);
    // 第一个FAT表所在的扇区号：FAT分区起点扇区号+FAT头的总扇区数
    fat32_volume.first_fat_sec = lba + fat32_header.rsvd_sec_cnt;
    // 每个簇的扇区数
    fat32_volume.sec_per_cluster = fat32_header.sec_per_clus;
    // FAT数据区的起始扇区号：FAT起始扇区号 + FAT头扇区数 + FAT表数 * 每个表的扇区数
    fat32_volume.first_data_sec = lba + fat32_header.rsvd_sec_cnt + fat32_header.num_fats * fat32_header.fat_sz32;
    // 每个FAT表所占的扇区数
    fat32_volume.fat_sz = fat32_header.fat_sz32;
}

int is_fat32(uint64_t lba) {
    virtio_blk_read_sector(lba, (void*)&fat32_header);
    if (fat32_header.boot_sector_signature != 0xaa55) {
        return 0;
    }
    return 1;
}

int next_slash(const char* path) {  // util function to be used in fat32_open_file
    int i = 0;
    while (path[i] != '\0' && path[i] != '/') {
        i++;
    }
    if (path[i] == '\0') {
        return -1;
    }
    return i;
}

void to_upper_case(char *str) {     // util function to be used in fat32_open_file
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] >= 'a' && str[i] <= 'z') {
            str[i] -= 32;
        }
    }
}

struct fat32_file fat32_open_file(const char *path) {
    // 获取fat32_file和fat32_dir
    struct fat32_file file;
    // 跳过前缀 /fat32/，获取name
    const char *name = path + 7;
    // fat32文件名格式：8字节文件名+3字节扩展名
    // 截取前8字节中的文件名，不足8字节时，用空格填充
    char target[8];
    for (int i = 0; i < 8; i++) target[i] = ' ';
    int len = 0;
    while (name[len] && len < 8 && name[len] != '/') {
        target[len] = name[len];
        len++;
    }
    // 不区分大小写，统一转换为大写
    to_upper_case(target);
    
    // 文件保存在根目录下
    uint64_t dir_cluster = fat32_header.root_clus;
    uint64_t sector = cluster_to_sector(dir_cluster);
    // 读取扇区
    virtio_blk_read_sector(sector, fat32_buf);
    struct fat32_dir_entry *entries = (struct fat32_dir_entry*)fat32_buf;

    for (int i = 0; i < FAT32_ENTRY_PER_SECTOR; i++) {
        // 遍历根目录扇区内的所有文件
        if (entries[i].name[0] == 0x00) {
            // 列表结束
            break;
        }
        if (entries[i].attr == 0x0F) {
            // 长文件名
            continue;
        }
        if (entries[i].name[0] == 0xE5) {
            // 目录已删除
            continue;
        }
        // 提取文件名
        char entry_name[8];
        memcpy(entry_name, entries[i].name, 8);
        to_upper_case(entry_name);

        // 匹配目标文件名和目录文件名
        if (memcmp(entry_name, target, 8) == 0) {
            file.cluster = (entries[i].starthi << 16) | entries[i].startlow;
            file.dir.cluster = dir_cluster;
            file.dir.index = i;
            return file;
        }
    }
    // 找不到对应的文件，返回无效簇号
    file.cluster = 0;
    return file;
}

int64_t fat32_lseek(struct file* file, int64_t offset, uint64_t whence) {
    // whence为偏移起点
    uint32_t size = fat32_file_size(file);
    int64_t new_cfo = 0;
    if (whence == SEEK_SET) {
        // 从文件开头算
        new_cfo = offset;
    } else if (whence == SEEK_CUR) {
        // 从当前位置算
        new_cfo = offset + file->cfo;
    } else if (whence == SEEK_END) {
        // 从文件末尾算
        new_cfo = (int64_t)size + offset;
    } else {
        printk("fat32_lseek: whence not implemented\n");
        while (1);
    }

    if (new_cfo < 0) new_cfo = 0;
    if (new_cfo > size) new_cfo = size;
    file->cfo = new_cfo;
    return file->cfo;
}

uint64_t fat32_table_sector_of_cluster(uint32_t cluster) {
    return fat32_volume.first_fat_sec + cluster / (VIRTIO_BLK_SECTOR_SIZE / sizeof(uint32_t));
}

int64_t fat32_read(struct file* file, void* buf, uint64_t len) {
    /* todo: read content to buf, and return read length */
    // 找到文件所在的簇，读取文件内容
    uint32_t size = fat32_file_size(file);
    if (file->cfo >= size) return 0;    // 指针超过文件内容
    if (file->cfo + len > size) {
        len = size - file->cfo;     // 截取文件内的内容
    }

    uint64_t bytes_per_cluster = fat32_volume.sec_per_cluster * VIRTIO_BLK_SECTOR_SIZE;
    uint64_t cur_cluster = file->fat32_file.cluster;
    // 获取当前cfo的簇号
    uint64_t ptr = file->cfo;
    while (ptr >= bytes_per_cluster) {
        cur_cluster = next_cluster(cur_cluster);
        ptr -= bytes_per_cluster;
    }
    // 获取簇内偏移
    uint64_t offset = ptr;
    uint8_t *out = (uint8_t *)buf;
    uint64_t copied = 0;
    while (copied < len && cur_cluster < 0x0FFFFFF8) {
        // 扫描文件所在的扇区并读
        uint64_t sector = cluster_to_sector(cur_cluster);
        // 读扇区
        virtio_blk_read_sector(sector, fat32_buf);
        uint64_t take = bytes_per_cluster - offset;
        if (take > len - copied) take = len - copied;
        memcpy(out + copied, fat32_buf + offset, take);
        copied += take;
        offset = 0;
        if (copied < len) {
            cur_cluster = next_cluster(cur_cluster);
        }
    }
    file->cfo += copied;
    return copied;
}

int64_t fat32_write(struct file* file, const void* buf, uint64_t len) {
    /* todo: fat32_write */
    uint32_t size = fat32_file_size(file);
    if (file->cfo >= size) return 0;
    if (file->cfo + len > size) len = size - file->cfo;

    uint64_t bytes_per_cluster = fat32_volume.sec_per_cluster * VIRTIO_BLK_SECTOR_SIZE;
    uint64_t cur_cluster = file->fat32_file.cluster;
    // 获取当前cfo的簇号
    uint64_t ptr = file->cfo;
    while (ptr >= bytes_per_cluster) {
        cur_cluster = next_cluster(cur_cluster);
        ptr -= bytes_per_cluster;
    }
    // 获取簇内偏移
    uint64_t offset = ptr;
    uint8_t *in = (uint8_t *)buf;
    uint64_t written = 0;
    while (written < len && cur_cluster < 0x0FFFFFF8) {
        // 扫描文件所在的扇区并写
        uint64_t sector = cluster_to_sector(cur_cluster);
        virtio_blk_read_sector(sector, fat32_buf);
        uint64_t take = bytes_per_cluster - offset;
        if (take > len - written) take = len - written;
        memcpy(fat32_buf + offset, in + written, take);
        written += take;
        offset = 0;
        // 写入磁盘
        virtio_blk_write_sector(sector, fat32_buf);
        if (written < len) {
            cur_cluster = next_cluster(cur_cluster);
        }
    }
    file->cfo += written;
    return written;
}

uint32_t fat32_file_size(struct file *file) {
    // 读取file项，返回文件的大小
    uint64_t dir_sector = cluster_to_sector(file->fat32_file.dir.cluster);
    // 读取扇区内信息到内存
    virtio_blk_read_sector(dir_sector, fat32_buf);
    struct fat32_dir_entry *entries = (struct fat32_dir_entry*)fat32_buf;
    // 扇区内第index项为对应的文件项，读取size
    return entries[file->fat32_file.dir.index].size;
}