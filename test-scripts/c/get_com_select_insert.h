#ifndef GET_COM_SELECT_INSERT_H
#define GET_COM_SELECT_INSERT_H

#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
#include "mariadb_interaction.h"

/**
Reads COM_SELECT and COM_INSERT variables from all nodes and stores into 'selects' and 'inserts'
*/
int get_global_status_allnodes(int *selects, int *inserts, MYSQL *nodes[256], int NodesNum, int silent);

/**
Prints difference in COM_SELECT and COM_INSERT 
*/
int print_delta(int *new_selects, int *new_inserts, int *selects, int *inserts, int NodesNum);


#endif // GET_COM_SELECT_INSERT_H
