add_executable(main main.c sha256.c)
target_link_libraries(main common)

add_custom_command(
  TARGET main POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:main>" "$<TARGET_FILE:main>.bin"
  COMMAND srec_cat "$<TARGET_FILE:main>.bin" -binary -offset 0x0000 -byte-swap 4 -o "$<TARGET_FILE:main>.vmem" -vmem
  VERBATIM)