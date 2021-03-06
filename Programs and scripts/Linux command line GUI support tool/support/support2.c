/***************************************************************************
 *
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


#include <stdio.h>
#include <stdlib.h>
#include </home/marc/support/support2.h>
#include <ncurses.h>
#include <form.h>

void foo(), foo1(), foo2();
void (*action)();
int n_labels = sizeof(labels) / sizeof(char *);

int main(int argc, char *argv[])
{
	void **actions;
	int men, nb_entries;
	char *labels[] = { 
			"LABEL 1",
			"LABEL 2",
			"LABEL 3",
		  };
	action = foo;
	actions[0] = action;
	//printf("actions[0] = %p\n", (void *)actions[0]);
	action = foo1;
	actions[1] = action;
	action = foo2;
	actions[2] = action;
	
	printf("DEBUG\n");
	men = makeMenu(nb_labels, labels, actions);
	return 0;
}

void foo()
{
	mvprintw(23,0,"marc");
}

void foo1()
{
	mvprintw(23,0,"marc1");
}

void foo2()
{
	mvprintw(23,0,"marc2");
}
