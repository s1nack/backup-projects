#include <unistd.h>
#include <stdio.h>
#include <malloc.h>

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
        printf("[%p] -> %u bytes demandés depuis: %p\n", result,(unsigned int) size, caller);
        __malloc_hook = my_malloc_hook;
	int got = getGOTwrapper();
        return result;
}

int getGOTwrapper() 
{
	static int firstrun=1, secondrun=1;
	if(firstrun) {
		int g = getGot();
		firstrun = 0;
		return 1;
	}
	if(secondrun) {
		int g = getGot();
		secondrun = 0;
		return 1;
	}	
	return 2;
}

int getGot() 
{
//	printf("1er getGot \n");
	int* add_malloc = (int*)&malloc;
	printf("add_malloc = %x\n",add_malloc);
	return 1;
}
