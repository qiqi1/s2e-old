;This is the lower part of the bios, at 0xe0000
;It runs in protected mode

[bits 32]

%define OSDATA32_SEL  0x08
%define OSCODE32_SEL  0x10

org 0xe0000

jmp start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interrupt descriptor table
%define IDT_START   0
pm_idtr:
                dw 0x8*256
                dd IDT_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%define IA32_IDT_TYPE_32BITS 0x0800
%define IA32_IDT_PRESENT 0x8000

;eax: interrupt number
;edi: handler
msg_add_idt: db "Adding interrupt vector ", 0
add_idt_desc:
    push edi
    shl eax, 3
    add eax, IDT_START

    mov [eax], di
    mov word [eax+2], OSCODE32_SEL
    mov word [eax+4], IA32_IDT_PRESENT | IA32_IDT_TYPE_32BITS | 0x0600
    shr edi, 16
    mov [eax+6], di
    pop edi
    ret

start:

    ;Initialize interrupt tables here
    push msg_init_int_table
    call s2e_print_message
    add esp, 4

    xor ecx, ecx
    mov edi, int_default

start_0:
    cmp ecx, 256
    jae start_1

    ;push ecx
    ;push msg_add_idt
    ;push ecx
    ;call s2e_print_expression
    ;add esp, 8
    ;pop ecx

    push ecx
    mov eax, ecx
    call add_idt_desc
    pop ecx
    inc ecx
    jmp start_0

start_1:
    lidt [pm_idtr]

    ; Test an interrupt call
    ;int 0x80

    ;cli
    ;hlt

    ; Go to the testing routines
    jmp s2e_test

%include "s2e-inst.asm"
%include "s2e-test.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interrupt handlers
msg_init_int_table: db "Initializing interrupt table", 0
int_msg_default: db "Called default interrupt handler", 0
int_msg: db "Called interrupt", 0

; Default interrupt handler
int_default:
    push int_msg_default
    call s2e_print_message
    add esp, 4
    iret

int80:
    push int_msg
    push 0x80
    call s2e_print_expression
    add esp, 8

iret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


times 0x10000 - ($-$$) db 0
