#include <stdio.h>
#include </home/marc/temp/foo.h>

void foo(), foo1(), foo2();
void (*actions[3])(); // void est le type retourné par ces fonctions, pas d'arguments

int main()
{
	int b = 0;
	MenuItem *menu_list;

	char* labels[] = {
		"label 1",
		"label 2",
		"label 3",
	};

	actions[0] = foo;
	actions[1] = foo1;
	actions[2] = foo2;

	menu_list = createMenuList(labels, actions, 3);
	b = makeMenu(menu_list, menu_list, labels);

	printf("DEBUG\n");
	free(menu_list);

	return 0;
}

void foo()
{
	int nsub = 0;	
	subMenu = createMenuList(sublabels, subactions, 3);
	nsub = makeMenu(subMenu, subMenu, sublabels);
	free(subMenu);
}

void foo1()
{
	printf("foo1 called\n");
}

void foo2()
{
	printf("foo2 called\n");
}
