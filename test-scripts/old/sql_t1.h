#ifndef SQL_T1_H
#define SQL_T1_H

#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>

/**
Executes SQL query 'sql' using 'conn' connection and print results
*/
int execute_select_query_and_check(MYSQL *conn, char *sql, unsigned long long int rows);
int create_t1(MYSQL * conn);
int create_insert_string(char *sql, int N, int fl);
int insert_into_t1(MYSQL *conn, int N);
int select_from_t1(MYSQL *conn, int N);

#endif // SQL_TÂ1_H
