dosseg

newline macro
    mov ah, 2
    mov dl, 13
    int 21h
    
    mov dl, 10
    int 21h
endm

err macro s 
    mov dx, offset s 
    mov ah, 9
    int 21h
    
    ; Print the error code in AX as a character (decimal).
    mov dl, al      ; Get the low byte of AX.
    add dl, '0'     ; Convert to ASCII
    mov ah, 2       ; Print character
    int 21h
endm

string macro s
    mov dx, offset s 
    mov ah, 9
    int 21h
endm

getchar macro c
    mov ah, 1       ; Read input
    int 21h
endm

.model small
.stack 100h
.data
f1          db 128 dup(0)     ; Null-terminated filename 1.
f2          db 128 dup(0)     ; Filename 2.
h1          dw ?              ; File handle returned from DOS.
h2          dw ?              ; File handle 2.
prompt1     db 'Enter the first filename: $'
prompt2     db 'Enter the second filename: $'
oerr_msg    db 'Error: Failed to open file. Error code: $'
rerr_msg    db 'Error: Failed to read file. Error code: $'
eq_msg      db 'The files are equal.$'
neq_msg     db 'The files are unequal.$'
buf1        db 1              ; Buffer 1 to hold one byte of data.
buf2        db 1              ; Buffer 2 to hold one byte of data.
eof1        db 0              ; To denote if file 1 has reached EOF.
eof2        db 0              ; To denote if file 2 has reached EOF.
.code
main proc
    mov ax, @data
    mov ds, ax

    string prompt1
    mov si, offset f1
    ; --- Input the filenames. ---
read:
    getchar
    cmp al, 13              ; EOL?
    je  next 
    mov [si], al            ; Store the byte.
    inc si
    jmp read

next:
    string prompt2
    mov si, offset f2
    
read2:
    getchar
    cmp al, 13
    je open
    mov [si], al
    inc si
    jmp read2 

open:
    ; --- Open the files using INT 21h ----
    mov ah, 3dh         ; Open file.
    mov al, 0           ; Read-only mode.
    mov dx, offset f1 
    int 21h
    jc open_error
    mov h1, ax      ; File handle returned in AX.

    mov ah, 3dh
    mov al, 0
    mov dx, offset f2 
    int 21h
    jc open_error
    mov h2, ax 
    jmp read_files

open_error:
    err oerr_msg 
    jmp done

    ; --- Read both files whilst doing a byte-by-byte comparison ---
read_files:
    mov ah, 3fh             ; Read file.
    mov bx, h1              ; First file's handle.
    mov dx, offset buf1     ; Pointer to the buffer where the byte will be stored.
    mov cx, 1               ; Read 1 byte at a time.
    int 21h
    jc read_error
    cmp ax, cx              ; EOF reached?
    jne set_eof1
    jmp read_file2

set_eof1:
    mov eof1, 1             ; Set eof1 to true.

read_file2:
    ; --- Read from the second file ---
    mov ah, 3fh             ; Read file.
    mov bx, h2              ; First file's handle.
    mov dx, offset buf2     ; Pointer to the buffer where the byte will be stored.
    mov cx, 1               ; Read 1 byte at a time.
    int 21h
    jc read_error
    cmp ax, cx              ; EOF reached?
    jne set_eof2
    jmp compare_files

set_eof2:
    mov eof2, 1

compare_files:
    ; If eof1 is set:
    ;     If eof2 is set:
    ;         Cleanup and exit. The files were equal.
    ;     Else:
    ;         Cleanup and exit. The files were not equal. We reached EOF for one file.
    ; Else if eof2 is set:
    ;     Cleanup and exit. The files were not equal. We reached EOF for one file.
    ; Continue comparing characters.
    
    ; Check if EOF is set for file 1.
    mov dl, eof1
    cmp dl, 1
    je eof1_set

    ; Check if EOF if set for file 2
    mov dl, eof2
    cmp dl, 1
    ; The second file has ended, so files are not equal.
    je files_not_equal 
    
    ; Continue comparing characters.
    mov dl, buf1
    cmp dl, buf2
    je  read_files

    ; Bytes are not equal. Bail out.
    jmp files_not_equal 

eof1_set:
    ; If EOF for file 1 is set, check if EOF for file 2 is also set.
    mov dl, eof2
    cmp dl, 1
    je files_equal
    
    ; Else, one file has ended, so files are not equal.
    jmp files_not_equal

files_equal:
    string eq_msg
    jmp cleanup

files_not_equal:
    string neq_msg
    jmp cleanup

read_error:
    err rerr_msg 
    jmp done

cleanup:
    ; --- Close files ----
    mov ah, 3eh
    mov bx, h1
    int 21h

    mov ah, 3eh
    mov bx, h2
    int 21h

done:
    newline
    mov ah, 4ch
    int 21h
main endp
end main
