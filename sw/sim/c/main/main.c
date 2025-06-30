// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdbool.h>
#include <string.h>

#include "demo_system.h"
#include "gpio.h"
#include "pwm.h"
#include "timer.h"
#include "sha256.h"

#define USE_GPIO_SHIFT_REG 0

#define MMIO(addr) *(volatile uint32_t*)addr

void test_uart_irq_handler(void)
{
  uint32_t data = MMIO(0x108000) ;  //read
  MMIO(0x108000) = data+1; //write
};

void platform_init(void) {
  install_exception_handler(UART_IRQ_NUM, &test_uart_irq_handler);
  uart_enable_rx_int();

  // This indicates how often the timer gets updated.
  timer_init();
  timer_enable(5000000);
}

#define dummy_instr_mask (7<<3)
#define dummy_instr_en (1<<2)

static char hex[SHA256_HEX_SIZE];

char* msg = "Compute the SHA-256 checksum of a memory region given a pointer and \
 the size of that memory region. \
 The output is a hexadecimal string of 65 characters. \
 The last character will be the null-character.";

volatile uint32_t array[16];

int main(void) {
  int data;
  uint32_t csr_cpuctrlsts;
  uint32_t csr_secureseed;
  uint32_t mstatus;

  //platform_init();

  MMIO(0x80001000) = 0xDEADBEEF;

  uint32_t tt = MMIO(0x80001000);

  if (tt != 0xDEADBEEF) {
    while(1);
  }
    //0x10_8000~0x10_8010

  __asm__ volatile("csrrw %0, 0x7C0, %0;" : "=r"(csr_cpuctrlsts));
  csr_cpuctrlsts |= (dummy_instr_mask|dummy_instr_en);
  __asm__ volatile("csrrw %0, 0x7C0, %0;" : "=r"(csr_cpuctrlsts));

  __asm__ volatile("csrrw %0, 0x7C1, %0;" : "=r"(csr_secureseed));
  
  __asm__ volatile( "csrs mtvec, %0" :: "r"(0x100000) );
    /**
     * Enable FIQ, mtime and external interrupts.  
     *   1<<3 for MSIE
     *   1<<7 for timer interrupt,
     *   1<<11 for external interrupt. 
     *   7FFF<<16 for FIQ
     */
  __asm__ volatile( "csrs mie, %0" :: "r"(0x7FFF0888) );
  // Global interrupt enable (MIE)
  mstatus = 0x08;
  __asm__ volatile("csrrw %0, mstatus, %0;" : "=r"(mstatus));

  for( int i=0;i<16;i++) {
    array[i] = i;
    array[i] = 0xFFFFFFFF^array[i];
  }


  while(1) {
    sha256_hex(msg, strlen(msg), hex);
    asm volatile("wfi");
//    data = MMIO(0x108000) ;  //read
//    MMIO(0x108000) = data+1; //write
  };

  return data;
};
