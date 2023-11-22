i2c_param:
    dw 0xc028 ; General Purpose IO Control register high
    dw 0xc024 ; General Purpose IO Data register high
    ; dw 0x0001 ; GPIO16 (SDA)
    ; dw 0x0002 ; GPIO17 (SCL)
    dw 0x8000 ; GPIO31 (SDA)
    dw 0x4000 ; GPIO30 (SCL)
    db 0xa0   ; signature byte
    db 14     ; number of bits for address

send_i2c_params:
    push   r2
    push   r0
    mov    r0, 2        ; 2=set param
    mov    r1,i2c_param ; new_parameter
    int    LI2C_INT     ; call I2C
    pop    r2
    pop    r0
    ret

read_i2c_byte: ; r1 has the address
    push   r2
    mov    r0,0       ;0=read
    int    LI2C_INT   ; call I2C
    pop    r2
    ret    	      ;return byte in R0

write_i2c_byte: ; r1 has the address, r2 has the value
    push   r0
    mov    r0,1       ;0=read
    int    LI2C_INT   ; call I2C
    pop    r0
    ret    	      

;*****************************************************************************
;; Load physical LBA block from I2C
;*****************************************************************************
load_physical_lba_block_from_i2c:
    call   send_i2c_params

    mov    r3, 0x0100
    mov    r9, send_buffer
    mov    r1, w[physical_lba_lw] ;; assume w[physical_lba_uw] is 0
    ; r1 should be 0..31
    ; real address is LBA * 512
    shl    r1, 8
    clc
    shl    r1, 1
@@:
    call   read_i2c_byte ; read byte from r1 to r0
    ; inc    r1  -- in call already increments r1

    and    r0, 0x00FF
    mov    r2, r0

    call   read_i2c_byte ; read byte from r1 to r0
    ; inc    r1  -- in call already increments r1

    and    r0, 0x00FF
    shl    r0, 8

    or     r2, r0

    mov    w[r9++], r2
    dec    r3
    jnz    @b

    ret

;*****************************************************************************
;; Save physical LBA block to I2C
;*****************************************************************************
save_physical_lba_block_i2c:
    call   send_i2c_params

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
    call   write_i2c_byte ; write byte r2 to r1
    ; inc    r1  -- in call already increments r1

    mov    r2, r0
    shr    r2, 8
    and    r2, 0x00FF
    call   write_i2c_byte ; write byte r2 to r1
    ; inc    r1  -- in call already increments r1
    
    dec    r3
    jnz    @b
    ret
