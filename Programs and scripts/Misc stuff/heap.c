#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
/*
static void my_init_hook(void);
static void *my_malloc_hook(size_t, const void *);

static void *(*old_malloc_hook)(size_t, const void *);

void (*__malloc_initialize_hook) (void) = my_init_hook;

static void my_init_hook(void) 
{
	old_malloc_hook = __malloc_hook;
	__malloc_hook = my_malloc_hook;
}

static void *my_malloc_hook(size_t size, const void *caller)
{
	void *result;
	__malloc_hook = old_malloc_hook;
	result = malloc(size);
	old_malloc_hook = __malloc_hook;
	printf("malloc(%u) called from %p returns %p\n", (unsigned int) size, caller, result);
	__malloc_hook = my_malloc_hook;
	return result;
}
*/
int main (void) 
{
        char *ptr  = malloc(16);
        char *ptr2 = malloc(16);

        printf("adresse ptr -> %p\r\n", &ptr);
	printf("ptr = %p\n", ptr);

	memset(ptr, 'A', 8);
	printf("ptr = %p\n", ptr);
	printf("char* ptr = %s\n", ptr);

	char* foo = malloc(10);
	memcpy(foo, ptr, 4);
	printf("foo contient %s\n", foo);

        free(ptr);
        free(ptr2);
        return(0);
}
