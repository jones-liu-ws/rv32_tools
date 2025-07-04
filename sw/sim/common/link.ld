/* Copyright lowRISC contributors.
   Licensed under the Apache License, Version 2.0, see LICENSE for details.
   SPDX-License-Identifier: Apache-2.0 */

OUTPUT_ARCH(riscv)

MEMORY
{
    /* 60 KiB should be enough for anybody... */
    irom  : ORIGIN = 0x00000000, LENGTH = 0x20000 /* 128 KiB */
    dram  : ORIGIN = 0x00020000, LENGTH = 0x20000 /* 128 KiB */
}

/* Stack information variables */
_min_stack     = 0x1000;   /* 4K - minimum stack space to reserve */
_stack_len     = _min_stack;
_stack_start   = ORIGIN(dram) + LENGTH(dram);

_entry_point = _vectors_start + 0x80;
ENTRY(_entry_point)

_entry_point = ORIGIN(irom) + 0x80;
ENTRY(_entry_point)

/* Rust dependency */
PROVIDE(_stext = ORIGIN(irom));
PROVIDE(_stack_start = ORIGIN(dram) + LENGTH(dram));
PROVIDE(_max_hart_id = 0);
PROVIDE(_hart_stack_size = _min_stack);
PROVIDE(_heap_size = 0);
PROVIDE(UserSoft = DefaultHandler);
PROVIDE(SupervisorSoft = DefaultHandler);
PROVIDE(MachineSoft = DefaultHandler);
PROVIDE(UserTimer = DefaultHandler);
PROVIDE(SupervisorTimer = DefaultHandler);
PROVIDE(MachineTimer = DefaultHandler);
PROVIDE(UserExternal = DefaultHandler);
PROVIDE(SupervisorExternal = DefaultHandler);
PROVIDE(MachineExternal = DefaultHandler);
PROVIDE(DefaultHandler = DefaultInterruptHandler);
PROVIDE(ExceptionHandler = DefaultExceptionHandler);
PROVIDE(__pre_init = default_pre_init);
PROVIDE(_mp_hook = default_mp_hook);
PROVIDE(_start_trap = default_start_trap);
PROVIDE(_setup_interrupts = default_setup_interrupts);


PROVIDE(InstructionMisaligned = ExceptionHandler);
PROVIDE(InstructionFault = ExceptionHandler);
PROVIDE(IllegalInstruction = ExceptionHandler);
PROVIDE(Breakpoint = ExceptionHandler);
PROVIDE(LoadMisaligned = ExceptionHandler);
PROVIDE(LoadFault = ExceptionHandler);
PROVIDE(StoreMisaligned = ExceptionHandler);
PROVIDE(StoreFault = ExceptionHandler);
PROVIDE(UserEnvCall = ExceptionHandler);
PROVIDE(SupervisorEnvCall = ExceptionHandler);
PROVIDE(MachineEnvCall = ExceptionHandler);
PROVIDE(InstructionPageFault = ExceptionHandler);
PROVIDE(LoadPageFault = ExceptionHandler);
PROVIDE(StorePageFault = ExceptionHandler);

SECTIONS
{
    .text : {
        . = ALIGN(4);

		_vectors_start = .;
        KEEP(*(.vectors))
		_vectors_end = .;
        
        /* Rust dependency */
        KEEP(*(.init));
        KEEP(*(.init.rust));

        *(.text)
        *(.text.*)
        . = ALIGN(4);
    }  > irom

    .rodata : {
        . = ALIGN(4);
        /* Small RO data before large RO data */
        *(.srodata)
        *(.srodata.*)
        *(.rodata);
        *(.rodata.*)
        . = ALIGN(4);
    } > irom
    end_of_iram = LOADADDR(.rodata) + SIZEOF(.rodata);

    .data : AT(end_of_iram) {
        . = ALIGN(4);
        _sidata = LOADADDR(.data);
        _sdata = .;

        /* Small data before large data */
        *(.sdata)
        *(.sdata.*)
        *(.data);
        *(.data.*)
        . = ALIGN(4);
        _edata = .;
    } > dram
    _pma_data_start = LOADADDR(.data);
    _pma_data_end   = LOADADDR(.data) + SIZEOF(.data);
    _vma_data_start = _sdata;

    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        /* Small BSS before large BSS */
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _bss_end = .;
        . = ALIGN(4);
    } > dram
    /* Rust dependency */
    _sbss = _bss_start;
    _ebss = _bss_end;

    /* ensure there is enough room for stack */
    .stack (NOLOAD): {
        . = ALIGN(4);
        . = . + _min_stack ;
        . = ALIGN(4);
        stack = . ;
        _stack = . ;
    } > dram
}

