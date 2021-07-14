#include <stdio.h>
#include <ncurses.h>
#include <form.h>

#define WIDTH 30
#define HEIGHT 10

typedef struct MenuItem {
        char* label;
        void (*action)();
	struct MenuItem *next;
	struct MenuItem *prev;
} MenuItem;

MenuItem * createMenuList(char** labels, void **actions, int nb_items);
int makeMenu(MenuItem* menu_item, MenuItem* item_list, char** labels);
MenuItem * printList(MenuItem* element);
void readList(MenuItem* element);

//temp submenu
MenuItem* subMenu = NULL;
void (*subactions[3])();
char* sublabels[] = {
		"sub 1",
		"sub 2", 
		"sub 3",
};
void sub() { mvprintw(20, 20, "sub1 called\n"); }
void sub1() { mvprintw(21,21, "sub2 called\n"); }
void sub2() { mvprintw(22, 22, "sub3 called\n"); }
//end submenu

MenuItem * createMenuList(char** labels, void **actions, int nb_items)
{
	int i = 0;
	int item_size = sizeof(MenuItem);
	MenuItem *current_item = NULL;
	MenuItem *item_list = NULL;
	MenuItem *base = NULL;

	//tmp submenu
	subactions[0] = sub;
	subactions[1] = sub1;
	subactions[2] = sub2;
	//end submenu
	
	i=0;	

	while(i<nb_items)
	{
		printf("begin Loop\n");
		MenuItem *current_item = malloc(item_size);

		current_item->label = labels[i];
		current_item->action = actions[i];
		current_item->prev = item_list;

		item_list = current_item;

		i++;
	}

	base = printList(item_list);

//	readList(base);
	
	return base;
}

int makeMenu(MenuItem* menu_item, MenuItem* item_list, char** labels)
{
	int i = 0;
	int n_labels = 3;
	WINDOW *menu_win = NULL;
	int highlight = 1;
	int c = 0;
	int choice = 0;
	int startx = 0;
	int starty = 0;

	startx = (80 - WIDTH) / 2;
	starty = (24 - HEIGHT) / 2;

	initscr();
	clear();
	noecho();
	cbreak();

	menu_win = newwin(HEIGHT, WIDTH, starty, startx);
	keypad(menu_win, TRUE);
	refresh();

	print_menu(menu_win, highlight, labels);
	while(1)
	{
		c = wgetch(menu_win);
		switch(c)
		{
			case KEY_UP:
				if(highlight == 1)
					highlight = n_labels;
				else
					--highlight;
				break;
			case KEY_DOWN:
				if(highlight == n_labels) 
					highlight = 1;
				else 
					++highlight;
				break;
			case 10:
				choice = highlight;
				break;
			default:
				refresh();
				break;
		}
		print_menu(menu_win, highlight, labels);
		if(choice != 0)
		{
			mvprintw(23,0,"choice = %i\n", choice);
			refresh();
			while(menu_item->label != labels[choice-1])
			{
				menu_item = menu_item->next;
			}			
//			mvprintw(23,0,"label %i: %s = %s\n", choice, menu_item->label, labels[choice-1]);
			(menu_item->action)();
//			refresh();
			menu_item = item_list;
		}
		choice = 0;
		print_menu(menu_win, highlight, labels);
	}	

	clrtoeol();
	refresh();
	endwin();
	return 0;
}

MenuItem* printList(MenuItem* element)
{
	int i=3;
	while(i != 0)
	{
//		printf("element %i : label=%s\n", i, element->label);
//		(element->action)();
		if(i==3)
			element->next = NULL;
		if(element->prev != NULL)
			element->prev->next = element;
		if(i!=1)
			element = element->prev;
		i--;
	}

	return element;
}

void readList(MenuItem* element)
{
	int i=0;
	MenuItem* mList = NULL;

	mList = element;
	while(i<3)
	{
		printf("readList\t element %i : label=%s\n", i, mList->label);
		(mList->action)();
		mList = mList->next;
		i++;
	}
}

void print_menu(WINDOW *menu_win, int highlight, char** labels)
{
	int x, y, i;

	x=2;
	y=2;
	box(menu_win, 0, 0);
	for(i=0;i<3;i++)
	{
		if(highlight == i+1)
		{
			wattron(menu_win, A_REVERSE);
			mvwprintw(menu_win, y, x, "%s", labels[i]);
			wattroff(menu_win, A_REVERSE);
		}
		else
		{
			mvwprintw(menu_win, y, x, "%s", labels[i]);
		}
		++y;
	}
	wrefresh(menu_win);
}
