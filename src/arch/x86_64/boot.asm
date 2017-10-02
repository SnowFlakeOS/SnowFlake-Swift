[org 0x7c00]

KERNEL_ADDRESS equ 0x100000

cli

lgdt [gdt_descriptor] 

;Switch to PM
mov eax, cr0 
or eax, 0x1 
mov cr0, eax 

jmp 0x8:init_pm 


[bits 32]

init_pm :
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax


call build_page_tables


;Enable PAE
mov eax, cr4                 
or eax, 1 << 5               
mov cr4, eax

;# Optional : Enable global-page mechanism by setting CR0.PGE bit to 1
mov eax, cr4                 
or eax, 1 << 7               
mov cr4, eax

;Load CR3 with PML4 base address
;NB: in some examples online, the address is not offseted as it seems to
;be in the proc datasheet (if you were wondering about this strange thing).
mov eax, 0x1000
mov cr3, eax

;Set LME bit in EFER register (address 0xC0000080)
mov ecx, 0xC0000080     ;operand of 'rdmsr' and 'wrmsr'
rdmsr                   ;read before pr ne pas écraser le contenu
or eax, 1 << 8          ;eax : operand de wrmsr
wrmsr

;Enable paging by setting CR0.PG bit to 1
mov eax, cr0
or eax, (1 << 31)
mov cr0, eax

;Load 64-bit GDT
lgdt [gdt64_descriptor]

;Jump to code segment in 64-bit GDT
jmp 0x8:init_lm


[bits 64]

init_lm:
    mov ax, 0x10
    mov fs, ax          ;other segments are ignored
    mov gs, ax

    mov rbp, 0x90000    ;set up stack
    mov rsp, rbp

    ;Load kernel from disk
    xor ebx, ebx        ;upper 2 bytes above bh in ebx is for cylinder = 0x0
    mov bl, 0x2         ;read from 2nd sectors
    mov bh, 0x0         ;head
    mov ch, 1           ;read 1 sector
    mov rdi, KERNEL_ADDRESS
    call ata_chs_read


    jmp KERNEL_ADDRESS

    jmp $



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;[bits 16]
;; http://wiki.osdev.org/ATA_in_x86_RealMode_%28BIOS%29


;load_loader:
    ;;!! il faut rester sur le meme segment, ie <0x10000 (=2**16)
    ;mov bx, LOADER_OFFSET  
    ;mov dh, 1          ;load 1 sector (max allowed by BIOS is 128)
    ;mov dl, 0x80       ;drive number

    ;mov ah, 0x02       ;read function
    ;mov al, dh
    ;mov ch, 0x00       ;cylinder
    ;mov dh, 0x00       ;head
    ;; !! Sector is 1-based, and not 0-based
    ;mov cl, 0x02       ;1st sector to read 
    ;int 0x13
    ;ret


[bits 32]
build_page_tables:
    ;PML4 starts at 0x1000
    ;il faut laisser la place pour tte la page PML4/PDP/PD ie. 0x1000

    ;PML4 @ 0x1000
    mov eax, 0x2000         ;PDP base address            
    or eax, 0b11            ;P and R/W bits
    mov ebx, 0x1000         ;MPL4 base address
    mov [ebx], eax

    ;PDP @ 0x2000; maps 64Go
    mov eax, 0x3000         ;PD base address
    mov ebx, 0x2000         ;PDP physical address   
    mov ecx, 64             ;64 PDP

    build_PDP:
        or eax, 0b11    
        mov [ebx], eax
        add ebx, 0x8
        add eax, 0x1000     ;next PD page base address
        loop build_PDP

    ;PD @ 0x3000 (ends at 0x4000, fits below 0x7c00)
    ; 1 entry maps a 2MB page, the 1st starts at 0x0
    mov eax, 0x0            ;1st page physical base address     
    mov ebx, 0x3000         ;PD physical base address
    mov ecx, 512                        

    build_PD:
        or eax, 0b10000011      ;P + R/W + PS (bit for 2MB page)
        mov [ebx], eax
        add ebx, 0x8
        add eax, 0x200000       ;next 2MB physical page
        loop build_PD

    ;(tables end at 0x4000 => fits before Bios boot sector at 0x7c00)
    ret



;=============================================================================
; ATA read sectors (CHS mode) 
; Max head index is 15, giving 16 possible heads
; Max cylinder index can be a very large number (up to 65535)
; Sector is usually always 1-63, sector 0 reserved, max 255 sectors/track
; If using 63 sectors/track, max disk size = 31.5GB
; If using 255 sectors/track, max disk size = 127.5GB
; See OSDev forum links in bottom of [http://wiki.osdev.org/ATA]
;
; @param EBX The CHS values; 2 bytes, 1 byte (BH), 1 byte (BL) accordingly
; @param CH The number of sectors to read
; @param RDI The address of buffer to put data obtained from disk               
;
; @return None
;=============================================================================
[bits 64]
ata_chs_read:   pushfq
                push rax
                push rbx
                push rcx
                push rdx
                push rdi

                mov rdx,1f6h            ;port to send drive & head numbers
                mov al,bh               ;head index in BH
                and al,00001111b        ;head is only 4 bits long
                or  al,10100000b        ;default 1010b in high nibble
                out dx,al

                mov rdx,1f2h            ;Sector count port
                mov al,ch               ;Read CH sectors
                out dx,al

                mov rdx,1f3h            ;Sector number port
                mov al,bl               ;BL is sector index
                out dx,al

                mov rdx,1f4h            ;Cylinder low port
                mov eax,ebx             ;byte 2 in ebx, just above BH
                mov cl,16
                shr eax,cl              ;shift down to AL
                out dx,al

                mov rdx,1f5h            ;Cylinder high port
                mov eax,ebx             ;byte 3 in ebx, just above byte 2
                mov cl,24
                shr eax,cl              ;shift down to AL
                out dx,al

                mov rdx,1f7h            ;Command port
                mov al,20h              ;Read with retry.
                out dx,al

.still_going:   in al,dx
                test al,8               ;the sector buffer requires servicing.
                jz .still_going         ;until the sector buffer is ready.

                mov rax,512/2           ;to read 256 words = 1 sector
                xor bx,bx
                mov bl,ch               ;read CH sectors
                mul bx
                mov rcx,rax             ;RCX is counter for INSW
                mov rdx,1f0h            ;Data port, in and out
                rep insw                ;in to [RDI]

                pop rdi
                pop rdx
                pop rcx
                pop rbx
                pop rax
                popfq
                ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[bits 16]

GDT:
;null : 
    dd 0x0 
    dd 0x0

;code : 
    dw 0xffff       ;Limit
    dw 0x0          ;Base
    db 0x0          ;Base
    db 10011010b    ;1st flag, Type flag
    db 11001111b    ;2nd flag, Limit
    db 0x0          ;Base

;data : 
    dw 0xffff       
    dw 0x0          
    db 0x0
    db 10010010b 
    db 11001111b 
    db 0x0

gdt_descriptor :
    dw $ - GDT - 1      ;16-bit size
    dd GDT              ;32-bit start address



[bits 32]
;see manual 2, §4.8: most fields are ignored in long mode
GDT64:
;null;
    dq 0x0

;code
    dd 0x0
    db 0x0
    db 0b10011000   
    db 0b00100000
    db 0x0

;data
    dd 0x0
    db 0x0
    db 0b10010000   
    db 0b00000000
    db 0x0

gdt64_descriptor :
    dw $ - GDT64 - 1        ;16-bit size
    dd GDT64                ;32-bit start address


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[bits 16]
times 510 -($-$$) db 0
dw 0xaa55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
