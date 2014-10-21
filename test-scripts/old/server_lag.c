// libssl-dev libmariadbclient-dev
// gcc server_lag.c  mariadb_interaction.o get_com_select_insert.o sql_t1.o -o server_lag -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <pthread.h>
#include "mariadb_interaction.h"
#include "get_com_select_insert.h"
#include "sql_t1.h"


MYSQL *nodes[256];
int NodesNum;
int selects[256];
int inserts[256];
int new_selects[256];
int new_inserts[256];
int silent = 0;
int tolerance;

char ip[15];
char ip1[15];
char sql[1000000];


pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
int exit_flag = 0;
void *sql_thread( void *ptr );
void *checks_thread( void *ptr);



int main(int argc, char *argv[])
{
  MYSQL *conn_rwsplit;

  int i;
  int global_result = 0;

  int IP_end;

  if (argc != 3) { printf("Usage: ./rw_select_insert Last_digits_of_IP number_of_VM\n"); exit(2); }

  sscanf(argv[1], "%d", &IP_end);
  if ( (IP_end < 0) || (IP_end > 255) ) { printf("Wrong last digits of IP\n"); exit(2); }
  sprintf(ip, "192.168.122.%d", IP_end);
  
  sscanf(argv[2], "%d", &NodesNum);
  if ( (NodesNum < 3) || (NodesNum > 255) ) { printf("Wrong number of nodes\n"); exit(2); }
   NodesNum--;

  tolerance=0;
  // Connecting to all nodes
  if (connect_all_nodes(nodes, IP_end, NodesNum) != 0) {exit(2);}

  // connect to the MaxScale server (rwsplit)
  conn_rwsplit = open_conn(4006, ip);
  if (conn_rwsplit == NULL ) {
    printf("Can't connect to MaxScale\n");
    exit(1);
  } else {
 
//    global_result += execute_query(conn_rwsplit, "DROP TABLE IF EXISTS t1;");
//    global_result += execute_query(conn_rwsplit, "create table t1 (x1 int);");
    create_t1(conn_rwsplit);

    create_insert_string(sql, 50000, 1);
    printf("sql_len=%lu\n", strlen(sql));
    global_result += execute_query(conn_rwsplit, sql);

    get_global_status_allnodes(&selects[0], &inserts[0], nodes, NodesNum, silent);

    pthread_t threads[1000];
    pthread_t check_thread;
    int  iret[1000];
    int check_iret;
    int j;
    exit_flag=0;
    /* Create independent threads each of which will execute function */
     for (j=0; j<10; j++) {
        iret[j] = pthread_create( &threads[j], NULL, sql_thread, NULL);
     }
     check_iret = pthread_create( &check_thread, NULL, checks_thread, NULL);   

     for (j=0; j<10; j++) {
        pthread_join( threads[j], NULL);
     }
     pthread_join(check_thread, NULL);


    get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
    print_delta(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum); 

  // close connections
    mysql_close(conn_rwsplit);
  }
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}


void *sql_thread( void *ptr )
{
   MYSQL *conn;
   MYSQL_RES *res;
   MYSQL_ROW row;

  conn = open_conn(4006, ip);
  while (exit_flag == 0) {
      execute_query(conn, sql);	
  }

  mysql_close(conn);
  return NULL;
}

void *checks_thread( void *ptr )
{
    int i;
    int j;
    for (i=0; i<1000000; i++) {
        printf("i=%u\t ", i);
        for (j=0; j < NodesNum; j++) {printf("SBM=%u\t", get_Seconds_Behind_Master(nodes[j]));}
        printf("\n");
    }
    exit_flag=1;
    return NULL;
}

