#include <stdio.h>
#include <ncurses.h>
#include <form.h>

#define WIDTH 30
#define HEIGHT 10 

int startx = 0;
int starty = 0;

char *choices[] = { 
			"CONNEXION SUPPORT REDACTED",
			"ACCES LIGNE DE COMMANDES ",
			"DIAGNOSTIC ET RESOLUTION",
		  };

char *subchoices[] = {
			"RECHARGER",
			"LISTE",
		};

char **submenus;

struct infos_ssh
{
   char ip[16];
   int port;
   char password[15];
} ssh;

int n_choices = sizeof(choices) / sizeof(char *);
int n_subchoices = sizeof(choices) / sizeof(char *);
void print_menu(WINDOW *menu_win, int highlight);
void print_sub_menu(WINDOW *menu_win, int highlight);
int sub_support(WINDOW *menu_win, int highlight);

int main()
{	WINDOW *menu_win;
	int highlight = 1;
	int marc2, ss, c, choice, ret_ssh = 0;

	initscr();
	clear();
	noecho();
	cbreak();	
	startx = (80 - WIDTH) / 2;
	starty = (24 - HEIGHT) / 2;
		
	menu_win = newwin(HEIGHT, WIDTH, starty, startx);
	keypad(menu_win, TRUE);
	refresh();
	print_menu(menu_win, highlight);
//	print_sub_menu(menu_win, highlight);
	while(1)
	{	c = wgetch(menu_win);
		switch(c)
		{	case KEY_UP:
				if(highlight == 1)
					highlight = n_choices;
				else
					--highlight;
				break;
			case KEY_DOWN:
				if(highlight == n_choices)
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
//		print_sub_menu(menu_win, highlight); //modif print
		print_menu(menu_win, highlight);
		if(choice != 0)	{ /* choice=index du menu */
			switch(choice) {
				case 1:
					marc2 = marc();
					if(marc2 == 0)	//case F1
						break;
					else { 		//case OK
						mvprintw(23,0,"marc() a retourne %i\n", ssh.port);
						refresh();
					}
					ret_ssh = connect_SSH(ssh);
					break;
				case 2:
					clrtoeol();
					refresh();
					endwin();
					return 0;
				case 3:
					clrtoeol();
					refresh();
//					endwin();
					refresh();
					//print_sub_menu(menu_win, highlight);
					ss = sub_support(menu_win, highlight);
					//print_menu(menu_win, highlight);
					break;
				default:
					break;
			}
		}
		choice = 0;
//		print_sub_menu(menu_win, highlight); // modif 
		print_menu(menu_win, highlight);
	}	
	clrtoeol();
	refresh();
	endwin();
	return 0;
}

int marc()
{
	FIELD *field[2];
        FORM  *my_form;
        int ch;
	char my_port[5];
	int i = 0;

	field[0] = new_field(1, 10, 30, 30, 0, 0);
	field[1] = NULL;

	set_field_back(field[0], A_UNDERLINE);
	field_opts_off(field[0], O_AUTOSKIP);
	set_field_type(field[0], TYPE_INTEGER, 5, 3, 4);

	my_form = new_form(field);
	post_form(my_form);
	refresh();
		
	mvprintw(30, 25, "Port:");
	mvprintw(60,25, "F1 pour revenir au menu");
	refresh();

	while((ch = getch()) != KEY_F(1))
	{	switch(ch)
		{
				break;
			case KEY_UP:
				form_driver(my_form, REQ_PREV_FIELD);
				form_driver(my_form, REQ_END_LINE);
				break;
			case 10:
				mvprintw(23, 0, "Port choisi: %s", my_port);
				ssh.port = atoi(my_port);
				refresh();
				unpost_form(my_form);
				free_form(my_form);
				free_field(field[0]);
				endwin();
				return 1;
			default:
				form_driver(my_form, ch);
				my_port[i] = ch;
				i++;
				break;
		}
	}

	unpost_form(my_form);
	free_form(my_form);
	free_field(field[0]);
	endwin();
	return 0;
}

int connect_SSH(struct infos_ssh test) 
{
	return 1;
}

// coder un wrapper sur le while(1) [..] getch etc. params: tableau des cases + action associée (index commun)

int sub_support(WINDOW *menu_win, int highlight)
{
	int c, choice;

	clear();
	print_sub_menu(menu_win, highlight);
	refresh();	
	while(1)
	 {       c = wgetch(menu_win);
                switch(c)
                {       case KEY_UP:
                                if(highlight == 1)
                                        highlight = n_choices;
                                else
                                        --highlight;
                                break;
                        case KEY_DOWN:
                                if(highlight == n_choices)
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
		print_sub_menu(menu_win, highlight);
		if(choice != 0) {
			switch(choice) {
                                case 1:
                                        break;
                                case 2:
                                        return 0;
				default:
        	                                break;
                	}
		}
	        choice = 0;
                print_sub_menu(menu_win, highlight);
        }
        clrtoeol();
        refresh();
        endwin();
        return 0;
}

void print_menu(WINDOW *menu_win, int highlight)
{
	int x, y, i;	

	x = 2;
	y = 2;
	box(menu_win, 0, 0);
	for(i = 0; i < n_choices; ++i)
//	for(i = 0; i < 3; i++)
	{	if(highlight == i + 1) 
		{	wattron(menu_win, A_REVERSE); 
			mvwprintw(menu_win, y, x, "%s", choices[i]);
			wattroff(menu_win, A_REVERSE);
		}
		else
			mvwprintw(menu_win, y, x, "%s", choices[i]);
		++y;
	}
	wrefresh(menu_win);
}

void print_sub_menu(WINDOW *menu_win, int highlight)
{
	int x, y, i;

	x = 2;
	y = 2;
	box(menu_win, 0, 0);
	for(i = 0; i < n_subchoices; i++)
	{
		if(highlight == i + 1)
		{
			wattron(menu_win, A_REVERSE);
			mvwprintw(menu_win, y, x, "%s", subchoices[i]);
			wattroff(menu_win, A_REVERSE);
		}
		else
			mvwprintw(menu_win, y, x, "%s", subchoices[i]);
		++y;
	}
	wrefresh(menu_win);
}

// FAIRE UN .H OU .SO RAPIDEMENT..
void sendMail()
{
	// envoie un fichier par mail en appelant un script
}

































