OUTPUT_ARCH( "riscv" )
ENTRY( _start )
SECTIONS
{
  RAM_START = DEFINED(RAM_START) ? RAM_START : 0x80000000;
  STACK_SIZE = DEFINED(STACK_SIZE) ? STACK_SIZE : 0x1000;

  /* text: test code section */
  . = DEFINED(ROM_START) ? ROM_START : RAM_START;
  .text : { *(.text) }
  /* data: Initialized data segment */
  .rodata : { *(.rodata) }
  /* build-id: Store after readonly data */
  build_id = .;
  .gnu_build_id : { *(.note.gnu.build-id) }
  . = DEFINED(ROM_START) ? RAM_START : .;
  .data : { *(.data) }
  .sdata : { *(.sdata) }
  .debug : { *(.debug) }
  . += STACK_SIZE;
  stack_top = .;

  /* End of uninitalized data segement */
  _end = .;
}
