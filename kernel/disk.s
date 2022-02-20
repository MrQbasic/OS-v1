;--HIGH_Level--
;read                   eax = startl / ebx = starth / ecx = count / edx = HBA_PORT
;write

;--LOW_Level--
;disk_find_cmdslot
;disk_start_cmd         eqx = p HBA_PORT
;disk_stop_cmd          eax = p HBA_PORT 
;disk_probe_port        eax = p HBA_MEM
;disk_check_type        eax = p HBA_PORT                                   -->  dx
;disk_port_rebase       eax = p HBA_PORT / ebx = p HBA_MEM / cx = portno
;disk_probe_port

;--PCI--
;pci_ConfigReadWord     ax = bus / bx = slot / cx = func / dx = offset     -->  dx
;pci_checkAllBuses                                                         --> edx
;-------------------------------------------------------------------------------------------
[bits 32]



;-------------------------------------------------------------------------------------------
disk_port_rebase:
    pushad

    mov [ebx+HBA_MEM_ghc], (1 << 31)
    mov [ebx+HBA_MEM_ghc], (1 <<  0)
    mov [ebx+HBA_MEM_ghc], (1 << 31)
    mov [ebx+HBA_MEM_ghc], (1 <<  1)

    call disk_stop_cmd


    popad
    ret

disk_start_cmd:
    pushad
    .loop1:
        mov ebx, [eax+HBA_PORT_cmd]
        and ebx, HBA_PxCMD_CR
        test ebx, ebx
        jne .loop1
    or dword [eax+HBA_PORT_cmd], HBA_PxCMD_FRE
    or dword [eax+HBA_PORT_cmd], HBA_PxCMD_ST
    popad
    ret

disk_stop_cmd:
    pushad
    and dword [eax+HBA_PORT_cmd], HBA_PxCMD_ST
    and dword [eax+HBA_PORT_cmd], HBA_PxCMD_FR
    .loop1:
        test dword [eax+HBA_PORT_cmd], HBA_PxCMD_FR
        jnz .loop1
        test dword [eax+HBA_PORT_cmd], HBA_PxCMD_ST
        jnz .loop1 
    popad
    ret

disk_probe_port:
    pusha
    mov ebx, [eax+HBA_MEM_pi]           ;get pi val from HBA_MEM (ebx)
    xor ecx, ecx                        ;clear counter
    .loop:
        cmp ecx, 32                     ;compare counter, 32
        jg .exit                        ;if >= then goto .exit
        ;------------------------------------------------
        test ebx, 1                     ;test if the first bit is = 1
        jz .skipp1                      ;if not then skipp
        ;------------------------------------------------
        push eax
        push ecx
        inc ecx                         ;counter += 1    to get the offset of the table to point to the 0th port
        shr ecx, 8                      ;get counter to start at bit 8 
        add eax, ecx                    ;add counter to HBA_MEM pointer to get HBA_PORT start addr      
        call disk_check_type            ;check type (dx) = dt
        pop ecx
        pop eax
        ;------------------------------------------------
        cmp dx, AHCI_DEV_SATA           ;compare dt, AHCI_DEV_SATA
        je .SATA                        ;if == then goto .SATA
        cmp dx, AHCI_DEV_SATAPI         ;compare dt, AHCI_DEV_SATAPI
        je .SATAPI                      ;if == then goto .SATAPI
        cmp dx, AHCI_DEV_SEMB           ;compare dt, AHCI_DEV_SEMB
        je .SEMB                        ;if == then goto .SEMB
        cmp dx, AHCI_DEV_PM             ;compare dt, AHCI_DEV_PM
        je .PM                          ;if == then goot .PM
        .NO:    
        push ebx
        mov ebx, T_FOUND_NO             ;setup pointer to string
        call screen_print_string        ;print string
        mov edx, ecx
        call screen_print_hex_b         ;print counter
        pop ebx
        jmp .skipp1                     ;goto skipp
        .SATA:    
        push ebx
        mov ebx, T_FOUND_NO             ;setup pointer to string
        call screen_print_string        ;print string
        mov edx, ecx
        call screen_print_hex_b         ;print counter
        pop ebx
        jmp .skipp1                     ;goto skipp
        .SATAPI:    
        push ebx
        mov ebx, T_FOUND_SATAPI         ;setup pointer to string
        call screen_print_string        ;print string
        mov edx, ecx
        call screen_print_hex_b         ;print counter
        pop ebx
        jmp .skipp1                     ;goto skipp
        .SEMB:    
        push ebx
        mov ebx, T_FOUND_SEMB           ;setup pointer to string
        call screen_print_string        ;print string
        mov edx, ecx
        call screen_print_hex_b         ;print counter
        pop ebx
        jmp .skipp1                     ;goto skipp
        .PM:
        push ebx
        mov ebx, T_FOUND_PM             ;setup pointer to string
        call screen_print_string        ;print string
        mov edx, ecx
        call screen_print_hex_b         ;print counter
        pop ebx
        ;------------------------------------------------
    .skipp1:
        shr edx, 1                      ;pi = pi >> 1
        inc ecx                         ;counter = counter + 1
        jmp .loop                       ;loop back to start
        ;------------------------------------------------
    .exit:
        popa
        ret

disk_check_type:
    push eax
    push ebx
    push ecx
    mov ebx, [eax+HBA_PORT_ssts]        ;get ssts from HBA_PORT (ebx) 
    mov ecx, ebx                        ;ipm = ssts (ecx)
    shr ecx, 8                          ;ipm = ipm >> 8
    and ecx, 0xF                        ;ipm = ipm & 0xF
    mov edx, ebx                        ;det = ssts (edx)
    and edx, 0xF                        ;det = det & 0xF 
    cmp edx, HBA_PORT_DET_PRESENT       ;compare det, HBA_PORT_DET_PRESENT
    jne .NULL                           ;if != then goto .NULL
    cmp ecx, HAB_PORT_IPM_ACTIVE        ;compare ipm, HAB_PORT_IPM_ACTIVE
    jne .NULL                           ;if != then goto .NULL
    mov ebx, [eax+HBA_PORT_sig]         ;get sig from HBA_PORT (ebx)
    cmp ebx, SATA_SIG_ATAPI             ;compare sig, SATA_SIG_ATAPI
    je .ATAPI                           ;if == then goto .ATAPI
    cmp ebx, SATA_SIG_SEMB              ;compare sig, SATA_SIG_SEMB
    je .SEMB                            ;if == then goto .SEMB
    cmp ebx, SATA_SIG_PM                ;compare sig, SATA_SIG_PM
    je .PM                              ;if == then goto .PM
    jmp .SATA                           ;if nothing else then goto .SATA
    .NULL:
        mov dx, AHCI_DEV_NULL
        jmp .exit
    .ATAPI:
        mov dx, AHCI_DEV_SATAPI
        jmp .exit
    .SEMB:
        mov dx, AHCI_DEV_SEMB
        jmp .exit
    .PM:
        mov dx, AHCI_DEV_PM
        jmp .exit
    .SATA:
        mov dx, AHCI_DEV_SATAPI
        jmp .exit
    .exit:
        pop ecx
        pop ebx
        pop eax
        ret
;-------------------------------------------------------------------------------------------

pci_ConfigReadWord:
    pusha                   ;save all reg 
    and eax, 0xFFFF         ;get low part of eax    (bus)
    and ebx, 0xFFFF         ;get low part of ebx    (slot)
    and ecx, 0xFFFF         ;get low part of ecx    (func)
    push edx                ;save edx
    ;eax = (eax << 16) | (ebx << 11) | (ecx << 8) | (edx & 0xFC) | 0x80000000
    shr eax, 16
    shr ebx, 11
    shr ecx, 8
    and edx, 0xFC
    or eax, ebx
    or ecx, edx
    or eax, ecx
    or eax, 0x80000000
    ;out eax to 0xCF8
    mov dx, 0x0CF8
    out dx, eax
    in eax, 0xCFC           ;in 0xCFC to eax 

    pop eax                 ;restore offset
    and eax, 0x02
    mov edx, 8              ;u_s mul offset * 8
    mul edx
    and eax, 0xFFFF         ;get low part
    mov ecx, eax

    in eax, 0xCFC
    shl eax, cl

    mov [V_BUFFER], eax     ;store end res in buffer

    popa                    ;restore all reg
    mov edx, [V_BUFFER]     ;get val from buffer
    ret

pci_checkAllBuses:
    push ebx        ;Save reg 
    push ecx
    push edx
    call screen_nl
    ;mov dx, V_CURSOR
    ;add dx, 0
    ;call screen_cursor_set
    xor edx, edx
    call screen_print_hex_b
    mov dword [V_BUS], 0          ;reset counter1
.loop1:
    mov eax, [V_BUS]              ;get counter1
    cmp eax, 0x01                 ;is counter1 > 0xFF ? 
    jg .skipp1                    ;if yes then skipp loop1
    mov dword [V_SLOT], 0x0       ;reset counter2    
.loop2:
    mov eax, [V_SLOT]             ;get counter2
    cmp eax, 0x1f                 ;is counter2 > 0x1F
    jg .skipp2                    ;if yes then skipp loop2

    mov eax, [V_BUS]              ;setup eax for call
    mov ebx, [V_SLOT]             ;setup ebx for call
    mov ecx, 0x00                 ;setup ecx for call
    mov edx, 0x00                 ;setup edx for call
    call pci_ConfigReadWord       ;call
    mov [V_VENDOR], edx           ;save output   
    mov edx, 0x02                 ;setup edx for call
    call pci_ConfigReadWord       ;call
    mov [V_DEVICE], edx           ;save output
    

    ;DEBUG PRINTS
    pusha
    call screen_nl
    mov ebx, T_BUS
    call screen_print_string
    mov edx, [V_BUS]
    call screen_print_hex_d
    call screen_space
    mov ebx, T_SLOT
    call screen_print_string
    mov edx, [V_SLOT]
    call screen_print_hex_b
    call screen_space
    mov ebx, T_VENDOR
    call screen_print_string
    mov edx, [V_VENDOR]
    call screen_print_hex_d
    call screen_space
    mov ebx, T_DEVICE
    call screen_print_string
    mov edx, [V_DEVICE]
    call screen_print_hex_d
    popa

    mov eax, [V_VENDOR]     ;get VENDOR
    cmp eax, 0x8086         ;is it = 0x8086
    jne .skipp3             ;if not then skipp
    mov eax, [V_DEVICE]     ;get DEVICE
    cmp eax, 0x2922         ;is it = 0x2922
    jne .skipp3             ;if not then skipp

    mov eax, [V_BUS]        ;set BUS
    mov ebx, [V_SLOT]       ;set SLOT
    mov ecx, 0              ;set func
    mov edx, 0x24           ;set offset
    call pci_ReadWord       ;call
    jmp .exit               ;goto exit
.skipp3:
    inc dword [V_SLOT]      ;counter2 + 1
    jmp .loop2              ;loop2 
.skipp2:
    inc dword [V_BUS]       ;counter1 + 1
    jmp .loop1              ;loop1
.skipp1:
    xor eax, eax    ;set eax to 0 for exit
    mov ebx, T_ERROR_1
    call screen_print_string
.exit:
    pop edx         ;Restore reg
    pop ecx
    pop ebx
    ret             ;return 

;-------------------------------------------------------------------------------------------
;Pointer
P_HBA_PORT:             dd 0
P_BUF:                  dd 0
;Var
V_STARTL:               dd 0
V_STARTH:               dd 0
V_COUNT:                dd 0

V_BUS:                  dd 0
V_SLOT:                 dd 0
V_VENDOR:               dd 0
V_DEVICE:               dd 0

V_BUFFER:               dd 0

;Const
SATA_SIG_ATA    equ 0x00000101
SATA_SIG_ATAPI  equ 0xEB140101
SATA_SIG_SEMB   equ 0xC33C0101
SATA_SIG_PM     equ 0x96690101

AHCI_DEV_NULL   equ 0
AHCI_DEV_SATA   equ 1
AHCI_DEV_SEMB   equ 2
AHCI_DEV_PM     equ 3
AHCI_DEV_SATAPI equ 4 

AHCI_BASE       equ 0x400000

HBA_PORT_DET_PRESENT equ 3
HAB_PORT_IPM_ACTIVE  equ 1
HBA_PxCMD_CR         equ 0x8000
HBA_PxCMD_FR         equ 0x4000
HBA_PxCMD_FRE        equ 0x0010
HBA_PxCMD_ST         equ 0x0001 


ATA_DEV_BUSY equ 0x80
ATA_DEV_DRQ equ 0x8
ATA_CMD_READ_DMA_EX equ 0x25
ATA_CMD_WRITE_DMA_EX equ 0x35

;Text
T_ERROR_1:          dd "\nNothing found on PCI!\e"
T_BUS:              dd "BUS: \e"
T_SLOT:             dd "SLOT: \e"
T_VENDOR:           dd "VENDOR: \e"
T_DEVICE:           dd "DEVICE: \e"
T_FOUND_SATA:       dd "\nSATA   drive found at port: \e"
T_FOUND_SATAPI:     dd "\nSATAPI drive found at port: \e"
T_FOUND_SEMB:       dd "\nSEMB   drive found at port: \e"
T_FOUND_PM:         dd "\nPM     drive found at port: \e"
T_FOUND_NO:         dd "\nNO     drive found at port: \e"
;Struc-Pointer
;HBA_MEM    0x0-0x2000 0x20FF -> 1280 bytes
;HBA_PORT   0x0-0x07F  0x0080 ->  128 bytes
HBA_MEM_cap         equ 0x0000
HBA_MEM_ghc         equ 0x0004
HBA_MEM_is          equ 0x0008
HBA_MEM_pi          equ 0x000C
HBA_MEM_vs          equ 0x0010
HBA_MEM_ccc_ctl     equ 0x0014
HBA_MEM_ccc_pts     equ 0x0018
HBA_MEM_em_loc      equ 0x001C
HBA_MEM_em_ctl      equ 0x0020
HBA_MEM_cap2        equ 0x0024
HBA_MEM_bohc        equ 0x0028
HBA_MEM_vendor      equ 0x00A0
HBA_MEM_port_0      equ 0x0100
HBA_MEM_port_1      equ 0x0180
HBA_MEM_port_2      equ 0x0200
HBA_MEM_port_3      equ 0x0280
HBA_MEM_port_4      equ 0x0300
HBA_MEM_port_5      equ 0x0380
HBA_MEM_port_6      equ 0x0400
HBA_MEM_port_7      equ 0x0480
HBA_MEM_port_8      equ 0x0500
HBA_MEM_port_9      equ 0x0580
HBA_MEM_port_10     equ 0x0600
HBA_MEM_port_11     equ 0x0680
HBA_MEM_port_12     equ 0x0700
HBA_MEM_port_13     equ 0x0780
HBA_MEM_port_14     equ 0x0800
HBA_MEM_port_15     equ 0x0880
HBA_MEM_port_16     equ 0x0900
HBA_MEM_port_17     equ 0x0980
HBA_MEM_port_18     equ 0x0A00
HBA_MEM_port_19     equ 0x0A80
HBA_MEM_port_20     equ 0x0B00
HBA_MEM_port_21     equ 0x0B80
HBA_MEM_port_22     equ 0x0C00
HBA_MEM_port_23     equ 0x0C80
HBA_MEM_port_24     equ 0x0D00
HBA_MEM_port_25     equ 0x0D80
HBA_MEM_port_26     equ 0x0E00
HBA_MEM_port_27     equ 0x0E80
HBA_MEM_port_28     equ 0x0F00
HBA_MEM_port_29     equ 0x0F80
HBA_MEM_port_30     equ 0x1000
HBA_MEM_port_31     equ 0x1080

HBA_PORT_clb      equ 0x00
HBA_PORT_clbu     equ 0x04
HBA_PORT_fb       equ 0x08
HBA_PORT_fbu      equ 0x0C
HBA_PORT_is       equ 0x10
HBA_PORT_ie       equ 0x14
HBA_PORT_cmd      equ 0x18
HBA_PORT_tfd      equ 0x20
HBA_PORT_sig      equ 0x24
HBA_PORT_ssts     equ 0x28
HBA_PORT_sctl     equ 0x2C
HBA_PORT_serr     equ 0x30
HBA_PORT_sact     equ 0x34
HBA_PORT_ci       equ 0x38
HBA_PORT_sntf     equ 0x3C
HBA_PORT_fbs      equ 0x40
HBA_PORT_vendor   equ 0x70

HBA_CMD_HEADER_DW0    equ 0x000
HBA_CMD_HEADER_prdl   equ 0x002
HBA_CMD_HEADER_prdbc  equ 0x004
HBA_CMD_HEADER_ctba   equ 0x008
HBA_CMD_HEADER_ctbau  equ 0x00C

HBA_CMD_TBL_cfis      equ 0x000 ;-0x3F
HBA_CMD_TBL_acmd      equ 0x040 ;-0x4F
HBA_PRDT_ENTRY_dba    equ 0x080 
HBA_PRDT_ENTRY_dbau   equ 0x084
HBA_PRDT_ENTRY_DW3    equ 0x088