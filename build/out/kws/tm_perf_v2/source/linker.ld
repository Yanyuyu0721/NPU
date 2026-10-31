OUTPUT_ARCH(riscv)
ENTRY(_start)
MEMORY {
  itcm (rwx) : ORIGIN = 0x80000000, LENGTH = 96K
  dtcm (rw) : ORIGIN = 0xA0000000, LENGTH = 48K
}
SECTIONS {
 /DISCARD/ : { *(.note.gnu.build-id) *(.comment) }
 .text : { KEEP(*(.text.boot)) *(.text .text.*) } >itcm
 .rodata : { *(.rodata .rodata.* .srodata .srodata.*) } >itcm
 .data : { __global_pointer$ = .; *(.sdata .sdata.* .data .data.*) } >itcm
 .bss (NOLOAD) : { . = ALIGN(4); _bss_start = .; *(.sbss .sbss.* .bss .bss.*) *(COMMON) . = ALIGN(4); _bss_end = .; } >dtcm
 _stack_top = ORIGIN(dtcm)+LENGTH(dtcm)-16;
 ASSERT(_bss_end < _stack_top-8192, "Vex data RAM overlaps stack")
}
