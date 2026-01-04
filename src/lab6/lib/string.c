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
int memcmp(const void *s1, const void *s2, uint64_t n) {
    const unsigned char *a = (unsigned char *)s1;
    const unsigned char *b = (unsigned char *)s2;
    for (uint64_t i = 0; i < n; i++) {
        if (a[i] != b[i]) return a[i] - b[i];
    }
    return 0;
}

int strlen(const char *str) {
    int len = 0;
    while (*str++)
        len++;
    return len;
}