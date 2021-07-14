/***************************************************************************
 *   Copyright (C) 2008 by Marc Impini   *
 *   m.impini@gmail.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

//void makeMenu(int nb_entries, struct menu_item* entries);
void makeMenu(int nb_entries, void *list);
struct menu_item createList(int nb_entries, void *list);
int menu_reactor(int nb_entries, struct menu_item *entries);

//void makeMenu(int nb_entries, struct menu_item* entries)
void makeMenu(int nb_entries, void *list)
{
	//prend comme params une table de hash [label]=>[action] (list pointe sur la 1ère entrée de la table de hash)
	//et crée une liste chainée de nb_entries structures menu_item à partir de cette liste

	current_entry = createList(int nb_entries, void *list); //current_entry = 1er élément de la liste

	WINDOW *menu_win;
	int highlight = 1;
	int c, choice, act = 0;
	startx = (80 - WIDTH) / 2;	
	starty = (24 - HEIGHT) / 2;

	clear();
	noecho();
	cbreak();

	menu_win = newwin(HEIGHT, WIDTH, starty, startx);
	keypad(menu_win, TRUE);
	refresh();
	print_menu(menu_win, highlight);

	while(1)
	{
		c = wgetch(menu_win);
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
					++hightlight;
				break;
			case 10:
				choice = highlight;
				break;
			default:
				refresh();
				break;
		}	
		if(choice != 0) 
			act = menu_reactor(nb_entries, entries);
		// LIRE g_hash_table_lookup()
		
	}			
}

struct menu_item createList(int nb_entries, void *list)
{
	//crée une liste chainée à partir de list contenant nb_entries éléments
	//retourne un ptr sur la 1ère entrée de la liste chainée
//	struct menu_item entry = (menu_item*)malloc(sizeof(struct menu_item));
	struct menu_item * entry;
	struct menu_item * head;
	struct menu_item * current_entry;
	head = NULL;

	entry = (menu_item*)malloc(sizeof(struct menu_item));	
	entry.label = [1er label de list]
	entry.action = [action associée]
	entry->next = head;
	head = entry;

	if(head != NULL) {
		current_entry = head;
		while(current_entry->next != NULL)
			current_entry = current_entry->next;
	}

	current_entry = entry;

	for(i=1;i<nb_entries;i++)
	{
		current_entry = (menu_item*)malloc(sizeof(struct menu_item));
		current_entry.label = [label];
		current_entry.action = [action];
		current_entry->next = NULL;
		current_entry->prev = 
	}
}

int menu_reactor(int nb_entries, void *list)
{
	//parse les entrées de la liste chainée et exécute l'action associée au label matché
	//retourne 1 en cas de match, 0 si rien
	int i=0;

	while(i<nb_entries)
	{
		if(choice==current_entry.label) {
			current_entry.action();
			return 1;
		}
		else
			current_entry = current_entry.next;
		i++;
	}
	return 0;
}