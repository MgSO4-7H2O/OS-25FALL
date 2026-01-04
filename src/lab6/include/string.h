#ifndef __STRING_H__
#define __STRING_H__

#include "stdint.h"

void *memset(void *, int, uint64_t);
void *memcpy(void *dst, void *src, uint64_t n);
int memcmp(const void *s1, const void *s2, uint64_t n);
int strlen(const char *str);
#endif
