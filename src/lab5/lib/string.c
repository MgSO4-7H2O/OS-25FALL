#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    char *s = (char *)dest;
    for (uint64_t i = 0; i < n; ++i) {
        s[i] = c;
    }
    return dest;
}

void *memcpy(void *dst, void *src, uint64_t n) {
    char *cdst = (char *)dst;
    char *csrc = (char *)src;
    for (uint64_t i = 0; i < n; ++i)
        cdst[i] = csrc[i];
    return dst;
}
