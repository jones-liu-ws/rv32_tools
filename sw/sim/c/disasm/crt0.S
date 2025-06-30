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
  
  lui x1, 0x1234
  auipc x2, 0x5678
  jal x1, label
  jalr x1, x2, 100
  beq x1, x2, label
  bne x1, x2, label
  blt x1, x2, label
  bge x1, x2, label
  bltu x1, x2, label
  bgeu x1, x2, label
  lb x1, 4(x2)
  lh x1, 4(x2)
  lw x1, 4(x2)
  lbu x1, 4(x2)
  lhu x1, 4(x2)
  sb x1, 4(x2)
  sh x1, 4(x2)
  sw x1, 4(x2)
  addi x1, x2, 10
  slti x1, x2, 10
  sltiu x1, x2, 10
  xori x1, x2, 0xFF
  ori x1, x2, 0xFF
  andi x1, x2, 0xFF
  slli x1, x2, 5
  srli x1, x2, 5
  srai x1, x2, 5
  add x1, x2, x3
  sub x1, x2, x3
  sll x1, x2, x3
  slt x1, x2, x3
  sltu x1, x2, x3
  xor x1, x2, x3
  srl x1, x2, x3
  sra x1, x2, x3
  or x1, x2, x3
  and x1, x2, x3
  fence iorw, iorw
  mret
  wfi
  ecall
  ebreak
  csrrw x5, mstatus, x6
  csrrs x5, mstatus, x6
  csrrc x5, mstatus, x6
  csrrwi x5, mstatus, 4
  csrrsi x5, mstatus, 4
  csrrci x5, mstatus, 4
  mul x5, x6, x7
  mulh x5, x6, x7
  mulhsu x5, x6, x7
  mulhu x5, x6, x7
  div x5, x6, x7
  divu x5, x6, x7
  rem x5, x6, x7
  remu x5, x6, x7
  .option rvc;
  addi	s0,sp,32 //c.addi4spn x8, 4
  c.lw x8, 4(x9)
  c.sw x8, 4(x9)
  c.nop
  c.addi x5, 4
  c.jal label
  c.li x5, 4
  addi	sp,sp,32 //c.addi16sp 16
  c.lui x5, 0x10
  c.srli x8, 4
  c.srai x8, 4
  c.andi x8, 4
  c.sub x8, x9
  c.xor x8, x9
  c.or x8, x9
  c.and x8, x9
  c.j label
  c.beqz x8, label
  c.bnez x8, label
  c.slli x5, 4
  lw	s0,28(sp) //c.lwsp x5, 8
  c.jr x5
  c.mv x5, x6
  c.ebreak
  c.jalr x5
  c.add x5, x6
  sw	s0,28(sp) //c.swsp x5, 8
label:
