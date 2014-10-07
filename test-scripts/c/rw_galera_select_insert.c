// libssl-dev libmariadbclient-dev
// gcc rw_galera_select_insert.c  mariadb_interaction.o get_com_select_insert.o -o rw_galera_select_insert -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

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
#include "get_com_select_insert.h"

MYSQL *nodes[256];
int selects[256];
int inserts[256];
int new_selects[256];
int new_inserts[256];
int silent = 0;
int tolerance;

int main(int argc, char *argv[])
{
  MYSQL *conn_rwsplit;

  int i;
  int global_result = 0;

  char ip[15];
  char maxscaleIP[15];
  char ip1[15];

  int IP_end;
  int NodesNum;

  if (argc != 3) { printf("Usage: ./rw_select_insert Last_digits_of_IP number_of_VM\n"); exit(2); }

  sscanf(argv[1], "%d", &IP_end);
  if ( (IP_end < 0) || (IP_end > 255) ) { printf("Wrong last digits of IP\n"); exit(2); }
  sprintf(ip, "192.168.122.%d", IP_end);
  sprintf(maxscaleIP, "192.168.122.%s", getenv("maxscaleIP"));
  
  sscanf(argv[2], "%d", &NodesNum);
  if ( (NodesNum < 3) || (NodesNum > 255) ) { printf("Wrong number of nodes\n"); exit(2); }
   NodesNum--;

  tolerance=0;
  // Connecting to all nodes
  if (connect_all_nodes(nodes, IP_end, NodesNum) != 0) {exit(2);}

  // connect to the MaxScale server (rwsplit)
  conn_rwsplit = open_conn(4006, maxscaleIP);
  if (conn_rwsplit == NULL ) {
    printf("Can't connect to MaxScale\n");
    exit(1);
  } else {
 
    global_result += execute_query(conn_rwsplit, "DROP TABLE IF EXISTS t1;");
    global_result += execute_query(conn_rwsplit, "create table t1 (x1 int);");


    get_global_status_allnodes(&selects[0], &inserts[0], nodes, NodesNum, silent);
    global_result += execute_query(conn_rwsplit, "select * from t1;"); 
    get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
    print_delta(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);


    global_result += execute_query(conn_rwsplit, "insert into t1 values(1);"); 
    get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
    print_delta(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum); 

  // close connections
    mysql_close(conn_rwsplit);
  }
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}
