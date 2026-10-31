.section .text.boot
.global _start
_start:
  j crt_init
  # Generated Vex CsrPlugin fixes mtvec at 0x80000020 (mtvecAccess=NONE).
  .org 0x20
  j trap_entry
  .org 0x40
crt_init:
  .option push
  .option norelax
  la gp,__global_pointer$
  .option pop
  la sp,_stack_top
  .option push
  .option arch,+zicsr
  csrw mie,zero
  csrw mstatus,zero
  .option pop
  la t0,_bss_start
  la t1,_bss_end
1:
  bgeu t0,t1,2f
  sw zero,0(t0)
  addi t0,t0,4
  j 1b
2:
  call main
  li t0,0xC00003FC
  sw a0,0(t0)
3:
  j 3b
.align 2
trap_entry:
  .option push
  .option arch,+zicsr
  csrr t1,mcause
  csrr t2,mepc
  csrr t3,mtval
  .option pop
  li t0,0xA002B004
  sw t1,0(t0)
  sw t2,4(t0)
  sw t3,8(t0)
  li t0,0xC00003FC
  li t1,99
  sw t1,0(t0)
  j 3b
