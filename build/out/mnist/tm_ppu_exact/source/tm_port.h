#ifndef __TM_PORT_H
#define __TM_PORT_H
#include "vex_platform.h"
#define TM_ARCH 0
#define TM_OPT_LEVEL 0
#define TM_MDL_TYPE TM_MDL_INT8
#define TM_FASTSCALE 1
#define TM_LOCAL_MATH 1
#define TM_MAX_CSIZE 64
#define TM_MAX_KSIZE 25
#define TM_MAX_KCSIZE 4096
#define TM_INLINE __attribute__((always_inline)) static inline
#define TM_WEAK __attribute__((weak))
void *bench_malloc(size_t);
void bench_free(void *);
#define tm_malloc(x) bench_malloc(x)
#define tm_free(x) bench_free(x)
#define TM_PRINTF(...) ((void)0)
#define TM_ENABLE_LOGGING 0
#define TM_ENABLE_DIAGNOSTICS 0
#define TM_DBGT_INIT() ((void)0)
#define TM_DBGT_START() ((void)0)
#define TM_DBGT(x) ((void)0)
#define TM_PERF_REG(x)
#define TM_COUNTS_PER_SECOND 50000000U
#define TM_GET_TICK(x) do { (x)=vex_cycles(); } while(0)
#endif
