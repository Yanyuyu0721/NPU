#pragma once
#include <stdint.h>
#include <stddef.h>
/* The simulation external-memory bus exposes a CPU alias at 0xA0000000.
 * NPU DMA sees the same 176KiB BRAM at zero. Convert explicitly at the
 * instruction encoder and DMA command boundary, never through a CPU oracle. */
static inline uint32_t vex_dma_addr(uintptr_t cpu_address) {
    if (cpu_address >= 0xA0000000U && cpu_address < 0xA002C000U)
        return (uint32_t)(cpu_address - 0xA0000000U);
    return (uint32_t)cpu_address;
}
static inline uint64_t vex_cycles(void) {
    uint32_t hi,lo,again;
    do {
        __asm__ volatile(".option push\n.option arch,+zicsr\ncsrr %0,mcycleh\ncsrr %1,mcycle\ncsrr %2,mcycleh\n.option pop"
                         : "=r"(hi),"=r"(lo),"=r"(again) :: "memory");
    } while (hi != again);
    return ((uint64_t)hi << 32) | lo;
}
static inline void vex_fence(void) { __asm__ volatile("fence iorw,iorw" ::: "memory"); }
