;pci_ReadWord           ax = bus / bx = slot / cx = func / dx = offset     --> edx 
[bits 32]

pci_ReadWord:
    push eax
    push ebx
    push ecx
    and eax, 0xFFFF         ;get low part of eax    (bus)
    and ebx, 0xFFFF         ;get low part of ebx    (slot)
    and ecx, 0xFFFF         ;get low part of ecx    (func)
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
    in eax, 0xCFC            ;in 0xCFC to eax 
    mov edx, eax
    pop ecx
    pop ebx
    pop eax
    ret