// libssl-dev libmariadbclient-dev
// gcc sql_queries.c mariadb_interaction.o -o sql_queries -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
//#include <pthread.h>

#include "mariadb_interaction.h"

MYSQL *nodes[256];
int selects[256];
int inserts[256];
int new_selects[256];
int new_inserts[256];
int silent = 0;

/**
Executes SQL query 'sql' using 'conn' connection and print results
*/
int execute_select_query_and_check(MYSQL *conn, char *sql, unsigned long long int rows)
{
     MYSQL_RES *res;
     MYSQL_ROW row;
     unsigned long long int i;
     unsigned long long int num_fields;
     unsigned long long int int_res;
     unsigned long long int row_i=0;
     int test_result = 0;

     printf("Trying SELECT, num_of_rows=%llu\n", rows);
     if(mysql_query(conn, sql) != 0)
         printf("Error: can't execute SQL-query: %s\n", mysql_error(conn));

     res = mysql_store_result(conn);
     if(res == NULL) printf("Error: can't get the result description\n");
    printf("rows=%llu\n", mysql_num_rows(res));
    if (mysql_num_rows(res) != rows) {printf("SELECT returned %llu rows insted of %llu!", mysql_num_rows(res), rows); test_result=1; }
    num_fields = mysql_num_fields(res);
    if (num_fields != 2) { printf("SELECT returned %llu fileds insted of 2!", num_fields); test_result=1; }
    if(mysql_num_rows(res) > 0)
    {
      while((row = mysql_fetch_row(res)) != NULL) { 
        for (i = 0; i < num_fields; i++) {
//          printf("%s\t", row[i]);
	  sscanf(row[i], "%llu", &int_res); 
          if ((i == 0 ) && (int_res != row_i)) {printf("SELECT returned wrong result! %llu insted of expected %llu\n", int_res, row_i); test_result=1; }
        }
        printf("\n"); 
        row_i++;
      }
    }

      mysql_free_result(res); 
      return(test_result);
}


int create_insert_string(char *sql, int N, int fl)
{
  char *ins1 = "INSERT INTO t1 (x1, fl) VALUES ";
  char *ins_val="%s (%d, %d)%s";
  int i;

  sprintf(&sql[0], "%s", ins1);
  for (i = 0; i < N-1; i++) {
    sprintf(&sql[0], ins_val, sql, i, fl, ",");
  }
  sprintf(&sql[0], ins_val, sql, N-1, fl, ";");
}

int main(int argc, char *argv[])
{
  MYSQL *conn_rwsplit;
  MYSQL *conn_master;
  MYSQL *conn_slave; 

  int i;
  int global_result = 0;

  char ip[15];

  int IP_end;
  int NodesNum;

  if (argc != 3) { printf("Usage: ./rw_select_insert Last_digits_of_IP number_of_VM\n"); exit(2); }

  sscanf(argv[1], "%d", &IP_end);
  if ( (IP_end < 0) || (IP_end > 255) ) { printf("Wrong last digits of IP\n"); exit(2); }
  sprintf(ip, "192.168.122.%d", IP_end);
  
  sscanf(argv[2], "%d", &NodesNum);
  if ( (NodesNum < 3) || (NodesNum > 255) ) { printf("Wrong number of nodes\n"); exit(2); }
   NodesNum--;

  printf("Connecting to %s\n", ip);

  conn_rwsplit = open_conn(4006, ip);
  conn_master  = open_conn(4008, ip);
  conn_slave   = open_conn(4009, ip);


  // Connecting to all nodes
  if (connect_all_nodes(nodes, IP_end, NodesNum) != 0) {exit(2);}

  execute_query(conn_rwsplit, "DROP TABLE IF EXISTS t1;");  
  execute_query(conn_rwsplit, "CREATE TABLE t1 (x1 int, fl int);");  


  int n1 = 64;
  int n2 = 1024;
  int n3 = 16384;
  int n4 = 65536;
  int n5 = 65536*64;
  char sql1[n1];
  char sql2[n2];
  char sql3[n3];
  char sql4[n4];
  char sql5[n5];

  char *ins1 = "INSERT INTO t1 (x1, fl) VALUES ";
  char *ins_val="%s (%d, 1)%s";

  create_insert_string(&sql1[0], 4, 1);
  create_insert_string(&sql2[0], 64, 2);
  create_insert_string(&sql3[0], 1024, 3);
  create_insert_string(&sql4[0], 4096, 4);
  create_insert_string(&sql5[0], 4096*16, 5);
 
  printf("INSERT: rwsplitter\n");
  printf("Trying INSERT, len=%lu\n", strlen(sql1));
  execute_query(conn_rwsplit,  sql1);
  printf("Trying INSERT, len=%lu\n", strlen(sql2));
  execute_query(conn_rwsplit,  sql2);
  printf("Trying INSERT, len=%lu\n", strlen(sql3));
  execute_query(conn_rwsplit,  sql3);
  printf("Trying INSERT, len=%lu\n", strlen(sql4));
  execute_query(conn_rwsplit,  sql4);
  printf("Trying INSERT, len=%lu\n", strlen(sql5));
  execute_query(conn_rwsplit,  sql5);


  printf("SELECT: rwsplitter\n");

  global_result += execute_select_query_and_check(conn_rwsplit, "select * from t1 where fl=1;", 4);
  global_result += execute_select_query_and_check(conn_rwsplit, "select * from t1 where fl=2;", 64);
  global_result += execute_select_query_and_check(conn_rwsplit, "select * from t1 where fl=3;", 1024);
  global_result += execute_select_query_and_check(conn_rwsplit, "select * from t1 where fl=4;", 4096);
  global_result += execute_select_query_and_check(conn_rwsplit, "select * from t1 where fl=5;", 4096*16);

  printf("SELECT: master\n");

  global_result += execute_select_query_and_check(conn_master, "select * from t1 where fl=1;", 4);
  global_result += execute_select_query_and_check(conn_master, "select * from t1 where fl=2;", 64);
  global_result += execute_select_query_and_check(conn_master, "select * from t1 where fl=3;", 1024);
  global_result += execute_select_query_and_check(conn_master, "select * from t1 where fl=4;", 4096);
  global_result += execute_select_query_and_check(conn_master, "select * from t1 where fl=5;", 4096*16);

  printf("SELECT: slave\n");

  global_result += execute_select_query_and_check(conn_slave, "select * from t1 where fl=1;", 4);
  global_result += execute_select_query_and_check(conn_slave, "select * from t1 where fl=2;", 64);
  global_result += execute_select_query_and_check(conn_slave, "select * from t1 where fl=3;", 1024);
  global_result += execute_select_query_and_check(conn_slave, "select * from t1 where fl=4;", 4096);
  global_result += execute_select_query_and_check(conn_slave, "select * from t1 where fl=5;", 4096*16);

  // close connections
  mysql_close(conn_rwsplit);
  mysql_close(conn_master);
  mysql_close(conn_slave);
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}
