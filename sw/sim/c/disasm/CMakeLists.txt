add_executable(disasm main.c crt0.S)

add_custom_command(
  TARGET disasm POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:disasm>" "$<TARGET_FILE:disasm>.bin"
  COMMAND srec_cat "$<TARGET_FILE:disasm>.bin" -binary -offset 0x0000 -byte-swap 4 -o "$<TARGET_FILE:disasm>.vmem" -vmem
  VERBATIM)