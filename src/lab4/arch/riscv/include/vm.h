#include "stdint.h"
#include "defs.h"
#include "printk.h"
#include "mm.h"
#include "string.h"


void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm);