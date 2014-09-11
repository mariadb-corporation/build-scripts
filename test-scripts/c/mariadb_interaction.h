#ifndef MARIADB_INTERACTION_H
#define MARIADB_INTERACTION_H


#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>

MYSQL * open_conn(int port, char * ip);
int connect_all_nodes(MYSQL *nodes[], unsigned int IP_end, unsigned int NodesNum);

/**
Executes SQL query 'sql' using 'conn' connection
*/
int execute_query(MYSQL *conn, char *sql);
unsigned int get_conn_num(MYSQL *conn, char * ip, char * db);

#endif // MARIADB_INTERACTION_H

