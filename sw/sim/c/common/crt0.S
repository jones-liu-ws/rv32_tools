# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#include "demo_system_regs.h"

.extern test_uart_irq_handler

#define portWORD_SIZE 4
#define portCONTEXT_SIZE ( 31 * portWORD_SIZE )

.macro portcontextSAVE_CONTEXT_INTERNAL
    addi sp, sp, -portCONTEXT_SIZE
    sw x1, 1 * portWORD_SIZE( sp )
    sw x5, 2 * portWORD_SIZE( sp )
    sw x6, 3 * portWORD_SIZE( sp )
    sw x7, 4 * portWORD_SIZE( sp )
    sw x8, 5 * portWORD_SIZE( sp )
    sw x9, 6 * portWORD_SIZE( sp )
    sw x10, 7 * portWORD_SIZE( sp )
    sw x11, 8 * portWORD_SIZE( sp )
    sw x12, 9 * portWORD_SIZE( sp )
    sw x13, 10 * portWORD_SIZE( sp )
    sw x14, 11 * portWORD_SIZE( sp )
    sw x15, 12 * portWORD_SIZE( sp )
    sw x16, 13 * portWORD_SIZE( sp )
    sw x17, 14 * portWORD_SIZE( sp )
    sw x18, 15 * portWORD_SIZE( sp )
    sw x19, 16 * portWORD_SIZE( sp )
    sw x20, 17 * portWORD_SIZE( sp )
    sw x21, 18 * portWORD_SIZE( sp )
    sw x22, 19 * portWORD_SIZE( sp )
    sw x23, 20 * portWORD_SIZE( sp )
    sw x24, 21 * portWORD_SIZE( sp )
    sw x25, 22 * portWORD_SIZE( sp )
    sw x26, 23 * portWORD_SIZE( sp )
    sw x27, 24 * portWORD_SIZE( sp )
    sw x28, 25 * portWORD_SIZE( sp )
    sw x29, 26 * portWORD_SIZE( sp )
    sw x30, 27 * portWORD_SIZE( sp )
    sw x31, 28 * portWORD_SIZE( sp )
    .endm

.macro portcontextRESTORE_CONTEXT
    lw  x1, 1 * portWORD_SIZE( sp )
    lw  x5, 2 * portWORD_SIZE( sp )
    lw  x6, 3 * portWORD_SIZE( sp )
    lw  x7, 4 * portWORD_SIZE( sp )
    lw  x8, 5 * portWORD_SIZE( sp )
    lw  x9, 6 * portWORD_SIZE( sp )
    lw  x10, 7 * portWORD_SIZE( sp )
    lw  x11, 8 * portWORD_SIZE( sp )
    lw  x12, 9 * portWORD_SIZE( sp )
    lw  x13, 10 * portWORD_SIZE( sp )
    lw  x14, 11 * portWORD_SIZE( sp )
    lw  x15, 12 * portWORD_SIZE( sp )
    lw  x16, 13 * portWORD_SIZE( sp )
    lw  x17, 14 * portWORD_SIZE( sp )
    lw  x18, 15 * portWORD_SIZE( sp )
    lw  x19, 16 * portWORD_SIZE( sp )
    lw  x20, 17 * portWORD_SIZE( sp )
    lw  x21, 18 * portWORD_SIZE( sp )
    lw  x22, 19 * portWORD_SIZE( sp )
    lw  x23, 20 * portWORD_SIZE( sp )
    lw  x24, 21 * portWORD_SIZE( sp )
    lw  x25, 22 * portWORD_SIZE( sp )
    lw  x26, 23 * portWORD_SIZE( sp )
    lw  x27, 24 * portWORD_SIZE( sp )
    lw  x28, 25 * portWORD_SIZE( sp )
    lw  x29, 26 * portWORD_SIZE( sp )
    lw  x30, 27 * portWORD_SIZE( sp )
    lw  x31, 28 * portWORD_SIZE( sp )
    addi sp, sp, portCONTEXT_SIZE
    mret
    .endm
.section .text

default_exc_handler:
  portcontextSAVE_CONTEXT_INTERNAL
  call test_uart_irq_handler
  portcontextRESTORE_CONTEXT

reset_handler:
  /* set all registers to zero */
  mv  x1, x0
  mv  x2, x1
  mv  x3, x1
  mv  x4, x1
  mv  x5, x1
  mv  x6, x1
  mv  x7, x1
  mv  x8, x1
  mv  x9, x1
  mv x10, x1
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
  mv x16, x1
  mv x17, x1
  mv x18, x1
  mv x19, x1
  mv x20, x1
  mv x21, x1
  mv x22, x1
  mv x23, x1
  mv x24, x1
  mv x25, x1
  mv x26, x1
  mv x27, x1
  mv x28, x1
  mv x29, x1
  mv x30, x1
  mv x31, x1

  /* stack initilization */
  la   x2, _stack_start

_start:
  .global _start

  /* clear BSS */
  la x26, _bss_start
  la x27, _bss_end

  bge x26, x27, zero_loop_end

zero_loop:
  sw x0, 0(x26)
  addi x26, x26, 4
  ble x26, x27, zero_loop
zero_loop_end:

/* copy data to dram */
  la x26, _pma_data_start
  la x27, _pma_data_end
  la x10, _vma_data_start

  bge x26, x27, cp_loop_end

cp_loop:
  lw x11, 0(x26)
  sw x11, 0(x10)

  addi x26, x26, 4
  addi x10, x10, 4
  blt x26, x27, cp_loop
cp_loop_end:

main_entry:
  /* jump to main program entry point (argc = argv = 0) */
  addi x10, x0, 0
  addi x11, x0, 0
  jal x1, main

  /* Halt simulation */
  li x5, SIM_CTRL_BASE + SIM_CTRL_CTRL
  li x6, 1
  sw x6, 0(x5)

  /* If execution ends up here just put the core to sleep */
sleep_loop:
  wfi
  j sleep_loop

/* =================================================== [ exceptions ] === */
/* This section has to be down here, since we have to disable rvc for it  */

  .section .vectors, "ax"
  .option norvc;

  // All unimplemented interrupts/exceptions go to the default_exc_handler.
  .org 0x00
  //.rept 32
  jal x0, default_exc_handler // 0x00
  jal x0, default_exc_handler // 0x04
  jal x0, default_exc_handler // 0x08
  jal x0, default_exc_handler // 0x0C, ibex_software_irq
  jal x0, default_exc_handler // 0x10
  jal x0, default_exc_handler // 0x14
  jal x0, default_exc_handler // 0x18
  jal x0, default_exc_handler // 0x1C, ibex_timer_irq
  jal x0, default_exc_handler // 0x20
  jal x0, default_exc_handler // 0x24
  jal x0, default_exc_handler // 0x28
  jal x0, default_exc_handler // 0x2C, ibex_external_irq
  jal x0, default_exc_handler // 0x30
  jal x0, default_exc_handler // 0x34
  jal x0, default_exc_handler // 0x38
  jal x0, default_exc_handler // 0x3C
  jal x0, default_exc_handler // 0x40, ibex_fast_irq0
  jal x0, default_exc_handler // 0x44, ibex_fast_irq1
  jal x0, default_exc_handler // 0x48, ibex_fast_irq2
  jal x0, default_exc_handler // 0x4C, ibex_fast_irq3
  jal x0, default_exc_handler // 0x50, ibex_fast_irq4
  jal x0, default_exc_handler // 0x54, ibex_fast_irq5
  jal x0, default_exc_handler // 0x58, ibex_fast_irq6
  jal x0, default_exc_handler // 0x5C, ibex_fast_irq7
  jal x0, default_exc_handler // 0x60, ibex_fast_irq8
  jal x0, default_exc_handler // 0x64, ibex_fast_irq9
  jal x0, default_exc_handler // 0x68, ibex_fast_irq10
  jal x0, default_exc_handler // 0x6C, ibex_fast_irq11
  jal x0, default_exc_handler // 0x70, ibex_fast_irq12
  jal x0, default_exc_handler // 0x74, ibex_fast_irq13
  jal x0, default_exc_handler // 0x78, ibex_fast_irq14
  jal x0, default_exc_handler // 0x7C, ibex_nonmask_irq


  // reset vector
  .org 0x80
  jal x0, reset_handler
