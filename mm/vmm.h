#ifndef __MM__VMM_H__
#define __MM__VMM_H__

#include <stdint.h>
#include <stddef.h>
#include <kstdlib.h>
#include <kstdio.h>
#include <mm/mem.h>
#include <mm/pmm.h>
#include <kstring.h>

typedef struct {
	size_t pml1off;
	size_t pml2off;
	size_t pml3off;
	size_t pml4off;
} offset_t;

uint64_t* get_pml4();
void set_pml4(uint64_t pml4);
void invlpg(uint64_t* vaddr);
void tlbflush();

uint64_t* getpaddr(void* vaddr);
void vtoof(offset_t* offset, uint64_t* vaddr); // virtual address to offset

void vmap(uint64_t* vaddr, uint64_t* paddr, uint64_t* pml4ptr, uint64_t permission);
void vfree(uint64_t* vaddr, size_t pages);

void test();

#endif