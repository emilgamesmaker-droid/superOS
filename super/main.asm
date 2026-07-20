; =============================================================================
; SUPER OS — CLICKABLE BUTTONS (INT 33h mouse driver)
; =============================================================================

[org 0x7c00]

; =============================================================================
; PART 1: BOOTLOADER
; =============================================================================
boot_start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov [boot_drive], dl

    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov bx, 0x7e00
    int 0x13
    jc .disk_error

    jmp 0x7e00

.disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

boot_drive db 0
times 510-($-$$) db 0
dw 0xaa55

; =============================================================================
; PART 2: KERNEL
; =============================================================================
section .kernel start=0x7e00

kernel_start:
    call load_files_from_disk
    call show_splash_screen
    call cls
    call init_mouse
    call draw_desk

main_loop:
    ; Check keyboard (non-blocking)
    mov ah, 0x01
    int 0x16
    jnz .key_pressed
    
    ; Poll mouse: update position and check buttons
    call poll_mouse
    jmp main_loop

.key_pressed:
    mov ah, 0x00
    int 0x16

    cmp al, 'm'
    je open_menu
    cmp al, 'M'
    je open_menu
    cmp al, 'f'
    je open_explorer
    cmp al, 'F'
    je open_explorer
    cmp al, 0x0D
    je handle_enter

    mov ah, 0x0E
    mov bl, 15
    int 0x10
    jmp main_loop

handle_enter:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    jmp main_loop

; =============================================================================
; MOUSE — INT 33h DRIVER
; =============================================================================

mouse_x:        dw 160
mouse_y:        dw 100
mouse_buttons:  db 0
mouse_was_down: db 0

init_mouse:
    pusha
    xor ax, ax
    int 0x33
    cmp ax, 0xFFFF
    jne .no_mouse
    
    mov ax, 0x0001
    int 0x33
    popa
    ret
    
.no_mouse:
    popa
    ret

; -----------------------------------------------------------------------------
; POLL MOUSE — read position and button state, handle clicks
; -----------------------------------------------------------------------------
poll_mouse:
    pusha
    
    mov ax, 0x0003
    int 0x33
    
    shr cx, 1
    cmp cx, 319
    jle .x_ok
    mov cx, 319
.x_ok:
    cmp dx, 199
    jle .y_ok
    mov dx, 199
.y_ok:
    mov [mouse_x], cx
    mov [mouse_y], dx
    mov [mouse_buttons], bl
    
    test bl, 1
    jnz .button_down
    
    mov al, [mouse_was_down]
    cmp al, 1
    jne .no_click
    mov byte [mouse_was_down], 0
    call handle_desktop_click
    
.no_click:
    popa
    ret

.button_down:
    mov byte [mouse_was_down], 1
    popa
    ret

; -----------------------------------------------------------------------------
; HANDLE DESKTOP CLICK
; -----------------------------------------------------------------------------
handle_desktop_click:
    pusha
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    
    ; MENU button: x=0..79, y=0..15
    cmp cx, 79
    ja .check_explorer
    cmp dx, 15
    ja .check_explorer
    call click_effect
    popa
    jmp open_menu
    
.check_explorer:
    cmp cx, 79
    ja .done
    cmp dx, 16
    jb .done
    cmp dx, 31
    ja .done
    call click_effect
    popa
    jmp open_explorer
    
.done:
    popa
    ret

click_effect:
    pusha
    mov ax, 0x0E07
    int 0x10
    popa
    ret

; =============================================================================
; SPLASH SCREEN
; =============================================================================
show_splash_screen:
    pusha
    push es
    mov ax, 0x0013
    int 0x10

    mov ax, 0xA000
    mov es, ax
    xor di, di
    mov cx, 32000
    mov ax, 0x0101
    rep stosw

    mov cx, 320
    xor si, si
.top_line:
    mov byte [es:si], 9
    inc si
    loop .top_line

    mov cx, 320
    mov si, 320*199
.bot_line:
    mov byte [es:si], 9
    inc si
    loop .bot_line

    mov cx, 200
    xor si, si
.side_lines:
    mov byte [es:si], 9
    mov byte [es:si+319], 9
    add si, 320
    loop .side_lines

    mov dh, 9
    mov si, msg_splash_title
    call print_at

.wait_key:
    mov ah, 0x01
    int 0x16
    jz .wait_key
    mov ah, 0x00
    int 0x16

    mov ax, 0x0003
    int 0x10
    pop es
    popa
    ret

msg_splash_title db "SUPER OS", 0

; =============================================================================
; FILE EXPLORER
; =============================================================================
open_explorer:
    call cls
    mov dh, 1
    mov si, msg_exp_title
    call print_at

    mov dh, 3
    cmp byte [disk_buf_f1], 0
    jne .show_f1
    mov si, msg_empty1
    call print_at
    jmp .check_f2
.show_f1:
    mov si, msg_f1_name
    call print_at

.check_f2:
    mov dh, 4
    cmp byte [disk_buf_f2], 0
    jne .show_f2
    mov si, msg_empty2
    call print_at
    jmp .check_f3
.show_f2:
    mov si, msg_f2_name
    call print_at

.check_f3:
    mov dh, 5
    cmp byte [disk_buf_f3], 0
    jne .show_f3
    mov si, msg_empty3
    call print_at
    jmp .exp_help
.show_f3:
    mov si, msg_f3_name
    call print_at

.exp_help:
    mov dh, 7
    mov si, msg_exp_hint
    call print_at
    mov dh, 8
    mov si, msg_exp_create
    call print_at
    mov dh, 9
    mov si, msg_exp_delete
    call print_at

explorer_wait:
    call poll_mouse_explorer
    
    mov ah, 0x01
    int 0x16
    jz explorer_wait
    
    mov ah, 0x00
    int 0x16

    cmp al, '1'
    je try_file1
    cmp al, '2'
    je try_file2
    cmp al, '3'
    je try_file3
    cmp al, 'c'
    je create_file_wizard
    cmp al, 'C'
    je create_file_wizard
    cmp al, 'd'
    je delete_file_wizard
    cmp al, 'D'
    je delete_file_wizard
    cmp al, 'x'
    je exit_explorer
    cmp al, 'X'
    je exit_explorer
    jmp explorer_wait

; -----------------------------------------------------------------------------
; POLL MOUSE IN EXPLORER
; -----------------------------------------------------------------------------
poll_mouse_explorer:
    pusha
    
    mov ax, 0x0003
    int 0x33
    shr cx, 3
    shr dx, 3
    
    test bl, 1
    jnz .button_down
    
    mov al, [mouse_was_down]
    cmp al, 1
    jne .no_click
    mov byte [mouse_was_down], 0
    
    cmp dx, 3
    jne .check_f2
    cmp cx, 2
    jb .no_click
    call click_effect
    popa
    jmp try_file1
    
.check_f2:
    cmp dx, 4
    jne .check_f3
    cmp cx, 2
    jb .no_click
    call click_effect
    popa
    jmp try_file2
    
.check_f3:
    cmp dx, 5
    jne .check_create
    cmp cx, 2
    jb .no_click
    call click_effect
    popa
    jmp try_file3
    
.check_create:
    cmp dx, 8
    jne .check_delete
    cmp cx, 2
    jb .no_click
    call click_effect
    popa
    jmp create_file_wizard
    
.check_delete:
    cmp dx, 9
    jne .check_exit
    cmp cx, 2
    jb .no_click
    call click_effect
    popa
    jmp delete_file_wizard
    
.check_exit:
    cmp dx, 7
    jne .no_click
    cmp cx, 2
    jb .no_click
    call click_effect
    popa
    jmp exit_explorer
    
.no_click:
    popa
    ret
    
.button_down:
    mov byte [mouse_was_down], 1
    popa
    ret

try_file1:
    cmp byte [disk_buf_f1], 0
    je explorer_wait
    mov si, disk_buf_f1
    jmp show_file_content

try_file2:
    cmp byte [disk_buf_f2], 0
    je explorer_wait
    mov si, disk_buf_f2
    jmp show_file_content

try_file3:
    cmp byte [disk_buf_f3], 0
    je explorer_wait
    mov si, disk_buf_f3

; =============================================================================
; FILE VIEWER
; =============================================================================
show_file_content:
    call cls
    push si
    mov dh, 1
    mov si, msg_view_header
    call print_at
    mov dh, 2
    mov si, msg_view_sep
    call print_at
    pop si
    mov dh, 4
    mov dl, 2
    call print_file_content
    mov dh, 24
    mov si, msg_back_hint
    call print_at

file_view_loop:
    call poll_mouse_viewer
    
    mov ah, 0x01
    int 0x16
    jz file_view_loop
    
    mov ah, 0x00
    int 0x16
    cmp al, 'b'
    je .go_back
    cmp al, 'B'
    je .go_back
    jmp file_view_loop
.go_back:
    jmp open_explorer

; -----------------------------------------------------------------------------
; POLL MOUSE IN FILE VIEWER
; -----------------------------------------------------------------------------
poll_mouse_viewer:
    pusha
    mov ax, 0x0003
    int 0x33
    shr cx, 3
    shr dx, 3
    
    test bl, 1
    jnz .down
    mov al, [mouse_was_down]
    cmp al, 1
    jne .done
    mov byte [mouse_was_down], 0
    cmp dx, 24
    jne .done
    cmp cx, 2
    jb .done
    call click_effect
    popa
    jmp open_explorer
.down:
    mov byte [mouse_was_down], 1
.done:
    popa
    ret

; =============================================================================
; PRINT FILE CONTENT
; =============================================================================
print_file_content:
    pusha
    mov ah, 0x02
    xor bx, bx
    int 0x10
    mov bp, 512
    mov cx, 0
.content_loop:
    cmp bp, 0
    je .done
    dec bp
    lodsb
    cmp al, 0
    je .done
    cmp al, 0x0D
    je .content_loop
    cmp al, 0x0A
    je .newline
    push ax
    mov ah, 0x0E
    mov bl, 15
    int 0x10
    pop ax
    inc cx
    cmp cx, 76
    jge .newline
    jmp .content_loop
.newline:
    mov cx, 0
    push si
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    pop si
    jmp .content_loop
.done:
    popa
    ret

msg_view_header db "=== FILE CONTENT ===", 0
msg_view_sep    db "--------------------", 0

; =============================================================================
; CREATE FILE
; =============================================================================
create_file_wizard:
    call cls
    mov dh, 2
    mov si, msg_select_slot
    call print_at

.wait_slot_create:
    mov ah, 0x01
    int 0x16
    jz .wait_slot_create
    
    mov ah, 0x00
    int 0x16
    cmp al, '1'
    je prep_slot_1
    cmp al, '2'
    je prep_slot_2
    cmp al, '3'
    je prep_slot_3
    cmp al, 'x'
    je exit_explorer
    cmp al, 'X'
    je exit_explorer
    jmp .wait_slot_create

prep_slot_1:
    mov byte [target_sector], 6
    mov di, disk_buf_f1
    jmp clear_and_write
prep_slot_2:
    mov byte [target_sector], 7
    mov di, disk_buf_f2
    jmp clear_and_write
prep_slot_3:
    mov byte [target_sector], 8
    mov di, disk_buf_f3

clear_and_write:
    push di
    mov cx, 512
    xor al, al
    rep stosb
    pop di
    jmp start_writing_process

start_writing_process:
    call cls
    mov dh, 2
    mov si, msg_writing_mode
    call print_at
    mov dh, 4
    mov cx, 0

.write_loop:
    cmp cx, 510
    jge .force_save
    mov ah, 0x01
    int 0x16
    jz .write_loop
    
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je save_to_disk_proc
    cmp al, 0x08
    je .handle_backspace
    cmp al, 0
    je .write_loop
    mov ah, 0x0E
    mov bl, 15
    int 0x10
    stosb
    inc cx
    jmp .write_loop

.handle_backspace:
    cmp cx, 0
    je .write_loop
    dec cx
    dec di
    mov byte [di], 0
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .write_loop

.force_save:
    jmp save_to_disk_proc

save_to_disk_proc:
    mov al, 0
    stosb
    call write_current_buffer_to_disk
    jmp open_explorer

; =============================================================================
; DELETE FILE
; =============================================================================
delete_file_wizard:
    call cls
    mov dh, 2
    mov si, msg_select_slot_del
    call print_at

.wait_slot_del:
    mov ah, 0x01
    int 0x16
    jz .wait_slot_del
    
    mov ah, 0x00
    int 0x16
    cmp al, '1'
    je del_prep_1
    cmp al, '2'
    je del_prep_2
    cmp al, '3'
    je del_prep_3
    cmp al, 'x'
    je exit_explorer
    cmp al, 'X'
    je exit_explorer
    jmp .wait_slot_del

del_prep_1:
    mov byte [target_sector], 6
    mov di, disk_buf_f1
    jmp do_delete_action
del_prep_2:
    mov byte [target_sector], 7
    mov di, disk_buf_f2
    jmp do_delete_action
del_prep_3:
    mov byte [target_sector], 8
    mov di, disk_buf_f3

do_delete_action:
    push di
    mov cx, 512
    xor al, al
    rep stosb
    pop di
    call write_current_buffer_to_disk
    jmp open_explorer

exit_explorer:
    call cls
    call draw_desk
    jmp main_loop

; =============================================================================
; DISK WRITE
; =============================================================================
write_current_buffer_to_disk:
    pusha
    push es
    xor ax, ax
    mov es, ax
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov dh, 0
    mov cl, [target_sector]
    mov dl, [boot_drive]

    cmp byte [target_sector], 6
    je .w_f1
    cmp byte [target_sector], 7
    je .w_f2
    mov bx, disk_buf_f3
    jmp .do_write
.w_f1:
    mov bx, disk_buf_f1
    jmp .do_write
.w_f2:
    mov bx, disk_buf_f2
.do_write:
    int 0x13
    pop es
    popa
    ret

; =============================================================================
; DISK READ
; =============================================================================
load_files_from_disk:
    pusha
    push es
    xor ax, ax
    mov es, ax
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov dh, 0
    mov dl, [boot_drive]

    mov cl, 6
    mov bx, disk_buf_f1
    int 0x13

    mov cl, 7
    mov bx, disk_buf_f2
    int 0x13

    mov cl, 8
    mov bx, disk_buf_f3
    int 0x13
    pop es
    popa
    ret

; =============================================================================
; SYSTEM MENU
; =============================================================================
open_menu:
    call cls
    mov dh, 2
    mov si, m1
    call print_at
    mov dh, 4
    mov si, m2
    call print_at
    mov dh, 5
    mov si, m3
    call print_at
    mov dh, 6
    mov si, m4
    call print_at
    mov dh, 7
    mov si, m5
    call print_at
    mov dh, 8
    mov si, m6
    call print_at

menu_wait:
    call poll_mouse_menu
    
    mov ah, 0x01
    int 0x16
    jz menu_wait
    
    mov ah, 0x00
    int 0x16

    cmp al, 'x'
    je menu_close
    cmp al, 'X'
    je menu_close
    cmp al, 'r'
    je menu_reboot
    cmp al, 'R'
    je menu_reboot
    cmp al, 'p'
    je menu_power_off
    cmp al, 'P'
    je menu_power_off
    cmp al, 'f'
    je open_explorer
    cmp al, 'F'
    je open_explorer
    cmp al, 's'
    je menu_info
    cmp al, 'S'
    je menu_info
    jmp menu_wait

; -----------------------------------------------------------------------------
; POLL MOUSE IN MENU
; -----------------------------------------------------------------------------
poll_mouse_menu:
    pusha
    mov ax, 0x0003
    int 0x33
    shr cx, 3
    shr dx, 3
    
    test bl, 1
    jnz .down
    mov al, [mouse_was_down]
    cmp al, 1
    jne .done
    mov byte [mouse_was_down], 0
    
    cmp dx, 4
    je .sysinfo
    cmp dx, 5
    je .explorer
    cmp dx, 6
    je .reboot
    cmp dx, 7
    je .close
    cmp dx, 8
    je .poweroff
    jmp .done
    
.sysinfo:
    call click_effect
    popa
    jmp menu_info
    
.explorer:
    call click_effect
    popa
    jmp open_explorer
    
.reboot:
    call click_effect
    popa
    jmp menu_reboot
    
.close:
    call click_effect
    popa
    jmp menu_close
    
.poweroff:
    call click_effect
    popa
    jmp menu_power_off
    
.down:
    mov byte [mouse_was_down], 1
.done:
    popa
    ret

menu_close:
    call cls
    call draw_desk
    jmp main_loop

menu_reboot:
    jmp 0xFFFF:0x0000

menu_power_off:
    call cls
    mov dh, 10
    mov si, msg_power_off
    call print_at
    mov cx, 0x0FFF
    mov dx, 0xFFFF
    mov ah, 0x86
    int 0x15

    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

.halt:
    hlt
    jmp .halt

menu_info:
    mov ah, 0x02
    xor bx, bx
    mov dh, 10
    mov dl, 2
    int 0x10
    int 0x12
    call print_hex
    mov si, m_kb
    call print_str
    jmp menu_wait

; =============================================================================
; SYSTEM FUNCTIONS
; =============================================================================
cls:
    mov ah, 0x00
    mov al, 0x13
    int 0x10
    ret

; =============================================================================
; DESKTOP
; =============================================================================
draw_desk:
    pusha
    
    ; MENU button (red)
    mov dx, 0
.y_loop:
    mov cx, 0
.x_loop:
    mov ah, 0x0C
    mov al, 4
    xor bh, bh
    int 0x10
    inc cx
    cmp cx, 80
    jle .x_loop
    inc dx
    cmp dx, 15
    jle .y_loop

    mov dh, 0
    mov si, msg_btn
    mov bl, 3
    call print_at_color
    
    ; FILES button (green)
    mov dx, 16
.y_loop2:
    mov cx, 0
.x_loop2:
    mov ah, 0x0C
    mov al, 2
    xor bh, bh
    int 0x10
    inc cx
    cmp cx, 80
    jle .x_loop2
    inc dx
    cmp dx, 31
    jle .y_loop2
    
    mov dh, 2
    mov si, msg_btn_explorer
    mov bl, 15
    call print_at_color

    mov dh, 4
    mov si, msg_desktop_ok
    call print_at
    
    popa
    ret

; =============================================================================
; PRINT_AT — white text
; =============================================================================
print_at:
    mov ah, 0x02
    xor bx, bx
    mov dl, 2
    int 0x10
print_str:
    mov ah, 0x0E
    mov bl, 15
.str_loop:
    lodsb
    cmp al, 0
    je .str_done
    int 0x10
    jmp .str_loop
.str_done:
    ret

; =============================================================================
; PRINT_AT_COLOR — custom color
; =============================================================================
print_at_color:
    mov ah, 0x02
    xor bh, bh
    mov dl, 2
    int 0x10
print_str_color:
    mov ah, 0x0E
.str_loop:
    lodsb
    cmp al, 0
    je .str_done
    int 0x10
    jmp .str_loop
.str_done:
    ret

; =============================================================================
; PRINT HEX
; =============================================================================
print_hex:
    pusha
    mov cx, 4
.hex_loop:
    rol ax, 4
    mov bx, ax
    and bx, 0x000F
    cmp bl, 10
    jl .hex_digit
    add bl, 7
.hex_digit:
    add bl, '0'
    push ax
    xor bh, bh
    mov ah, 0x0E
    mov al, bl
    mov bl, 15
    int 0x10
    pop ax
    loop .hex_loop
    popa
    ret

; =============================================================================
; DATA
; =============================================================================
msg_btn          db "MENU", 0
msg_btn_explorer db "FILES", 0
msg_desktop_ok   db "OS Desktop Ready! Click buttons or press keys", 0x0D, 0x0A, 0
m1               db "=== SYSTEM MENU ===", 0
m2               db "[S] System Information", 0
m3               db "[F] File Explorer", 0
m4               db "[R] Reboot Computer", 0
m5               db "[X] Close Menu", 0
m6               db "[P] Power Off", 0
m_kb             db " KB RAM Detected", 0

msg_exp_title    db "=== FILE EXPLORER ===", 0
msg_empty1       db "1. [Empty Slot]", 0
msg_empty2       db "2. [Empty Slot]", 0
msg_empty3       db "3. [Empty Slot]", 0
msg_f1_name      db "1. file1.txt", 0
msg_f2_name      db "2. file2.txt", 0
msg_f3_name      db "3. file3.txt", 0

msg_exp_hint     db "[X] Exit Explorer", 0
msg_exp_create   db "[C] Create New File", 0
msg_exp_delete   db "[D] Delete File", 0
msg_back_hint    db "[B] Back to Explorer", 0
msg_select_slot  db "SELECT SLOT (1-3):", 0
msg_select_slot_del db "SELECT SLOT TO DELETE (1-3):", 0
msg_writing_mode db "Type content and press ENTER to save:", 0x0D, 0x0A, 0
msg_power_off    db "Shutting down... Goodbye!", 0x0D, 0x0A, 0

target_sector    db 0

disk_buf_f1      times 512 db 0
disk_buf_f2      times 512 db 0
disk_buf_f3      times 512 db 0

kernel_end: