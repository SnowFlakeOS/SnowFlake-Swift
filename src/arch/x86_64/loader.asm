[bits 64]

extern kmain
global _start

_start:
  call kmain     ; Call our kernel's main() function
  hlt
