while(True):
    high = int(input("High: "),16) & 0xFFFFFFFF
    low = int(input("Low: "),16) & 0xFFFFFFFF

    flags = (high & 0x00F00000) >> 20
    acb = (high & 0x0000FF00) >> 8

    limit = (low & 0xFFFF) | (high & 0x000F0000)
    base = ((low & 0xFFFF0000) >> 16) | ((high & 0xFF) << 16) | (high & 0xFF000000) 

    print("Base:        ",hex(base))
    print("Limit:       ",hex(limit))
    print("Flags:       ",bin(flags))
    print("Access Byte: ",bin(acb))