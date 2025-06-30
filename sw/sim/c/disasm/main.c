// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdbool.h>
#include <string.h>
#include <stdint.h>

#define MMIO(addr) *(volatile uint32_t*)addr

void test_uart_irq_handler(void)
{
  uint32_t data = MMIO(0x108000) ;  //read
  MMIO(0x108000) = data+1; //write
};

int main(void) {
  while(1);
  return 0;
};
