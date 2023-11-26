;*****************************************************************************
;; Load physical LBA block from CY16
;*****************************************************************************
load_physical_lba_block_from_icap:

    ; set [our] special address recognized by fpga as icap
    ; w[physical_lba_lw]
    ; w[physical_lba_uw]
    mov w[physical_lba_lw], 0x0000
    mov w[physical_lba_uw], 0x0800

    ; push the block
    call load_physical_lba_block
    ret

    mov    r3, 0x0100
    mov    r9, send_buffer
    mov    r1, w[physical_lba_lw] ;; assume w[physical_lba_uw] is 0
    ; r1 should be 0..31
    ; real address is LBA * 512
    shl    r1, 8
    clc
    shl    r1, 1
    mov    r2, 0xbb
@@:

    mov    w[r9++], r2
    dec    r3
    jnz    @b

    ret

;*****************************************************************************
;; Save physical LBA block to ICAP
;*****************************************************************************
save_physical_lba_block_icap:

    ; set [our] special address recognized by fpga as icap
    ; w[physical_lba_lw]
    ; w[physical_lba_uw]
    mov w[physical_lba_lw], 0
    mov w[physical_lba_uw], 0x0800

    ; push the block
    call save_physical_lba_block
    ret

    mov    r3, 0x0100  ; 256*word (512 block)
    mov    r9, block_receive_buffer
    mov    r1, w[physical_lba_lw] ;; assume w[physical_lba_uw] is 0
    ; r1 should be 0..31
    ; real address is LBA * 512
    shl    r1, 8
    clc
    shl    r1, 1
@@:
    mov    r0, w[r9++]
    mov    r2, r0
    and    r2, 0x00FF

    ; save r2
    ; inc r1

    mov    r2, r0
    shr    r2, 8
    and    r2, 0x00FF

    ; save r2
    ; inc r1
    
    dec    r3
    jnz    @b
    ret
