%define FREE_SPACE 0x9000
 
ORG 0x7C00
BITS 16
 
; Main entry point where BIOS leaves us.
 
Main:
    jmp 0x0:.FlushCS               ; Some BIOS' may load us at 0x0000:0x7C00 while other may load us at 0x07C0:0x0000.
                                      ; Do a far jump to fix this issue, and reload CS to 0x0000.
 
.FlushCS:   
    xor ax, ax
 
    ; Set up segment registers.
    mov ss, ax
    ; Set up stack so that it starts below Main.
    mov sp, Main
 
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    cld

    ; Point edi to a free space bracket.
    mov edi, FREE_SPACE
    ; Switch to Long Mode.
    jmp SwitchToLongMode
 
 
BITS 64
.Long:
    hlt
    jmp .Long
 
 
BITS 16
 
.NoLongMode:
 
.Die:
    hlt
    jmp .Die
 
 
%include "src/arch/x86_64/64bit.asm"
BITS 16

; Pad out file.
times 510 - ($-$$) db 0
dw 0xAA55