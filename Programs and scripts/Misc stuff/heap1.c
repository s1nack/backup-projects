#include <stdio.h>
#include <stdlib.h>

int main (void) {
        char *ptr  = malloc(1024);
        char *ptr2;
        int heap = (int)ptr & 0xFFF00000;
        _Bool found = 0;

        printf("ptr found at %p\n", ptr);

	// i == 2 because this is my second chunk to allocate
	for (int i = 2; i < 1024; i++) {
                if (!found && (((int)(ptr2 = malloc(1024)) & 0xFFF00000) == (heap + 0x100000))) {
                        printf("good heap allignment found on malloc() %i (%p)\n", i, ptr2);
                        found = 1;
                        break;
                }

        }
        malloc(1024);
        fread (ptr, 1024 * 1024, 1, stdin);
	
	printf("flag");

        free(ptr);
        free(ptr2);
        return(0);
}
