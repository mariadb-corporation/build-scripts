// libssl-dev libmariadbclient-dev
// gcc rw_select_insert.c  mariadb_interaction.o get_com_select_insert.o -o rw_select_insert -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

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

/**
Checks if COM_SELECT increase takes place only on one slave node and there is no COM_INSERT increase
*/
int check_com_select(int *new_selects, int *new_inserts, int *selects, int *inserts, int NodesNum)
{
  int i;
  int result = 0;
  int sum_selects = 0;
  if (new_selects[0]-selects[0] !=0) {result = 1; printf("SELECT query executed, but COM_INSERT increased on master\n"); }
  for (i=0; i<NodesNum; i++) { 
    if (new_inserts[i]-inserts[i] != 0) {result = 1; printf("SELECT query executed, but COM_INSERT increased\n"); }
    if (!((new_selects[i]-selects[i] == 0) || (new_selects[i]-selects[i] == 1))) {
      printf("SELECT query executed, but COM_SELECT change is %d\n", new_selects[i]-selects[i]); 
      if (tolerance > 0) {
        tolerance--;
      } else { 
         result=1;
      }
    }
    sum_selects += new_selects[i]-selects[i];
    selects[i] = new_selects[i]; inserts[i] = new_inserts[i];
  }
  if (sum_selects != 1) {
    printf("SELECT query executed, but COM_SELECT increased more then on one node\n"); 
    if ((sum_selects == 2) && (tolerance > 0)) {
       tolerance--;
    } else {
       result = 1;
    }
  }
  
  if (result == 0) {
    if (silent == 0) {printf("COM_SELECT increase PASS\n");}
  } else {
    printf("COM_SELECT increase FAIL\n");
  }
  return(result);
}


/**
Checks if COM_INSERT increase takes places on all nodes and there is no COM_SELECT increase
*/
int check_com_insert(int *new_selects, int *new_inserts, int *selects, int *inserts, int NodesNum)
{
  int i;
  int result = 0;
  for (i=0; i<NodesNum; i++) { 
    if (new_inserts[i]-inserts[i] != 1) {
	sleep(1);
	get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
    }
    if (new_inserts[i]-inserts[i] != 1) {result = 1; printf("INSERT query executed, but COM_INSERT increase is %d\n", new_inserts[i]-inserts[i]); }
    if (new_selects[i]-selects[i] != 0) {
      printf("INSERT query executed, but COM_SELECT increase is %d\n", new_selects[i]-selects[i]); 
      if (tolerance > 0) {
        tolerance--;
      } else {
         result=1;
      }
    }
    selects[i] = new_selects[i]; inserts[i] = new_inserts[i];
  }
  if (result == 0) {
    if (silent == 0) {printf("COM_INSERT increase PASS\n");}
  } else {
    printf("COM_INSERT increase FAIL\n");
  }
  return(result);
}


int main(int argc, char *argv[])
{
  MYSQL *conn_rwsplit;

  int i;
  int global_result = 0;

  char ip[15];
  char ip1[15];
  char maxscaleIP[15];

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
  get_global_status_allnodes(&selects[0], &inserts[0], nodes, NodesNum, silent);
   
  global_result += execute_query(conn_rwsplit, "DROP TABLE IF EXISTS t1;");
  global_result += execute_query(conn_rwsplit, "create table t1 (x1 int);");

  global_result += execute_query(conn_rwsplit, "select * from t1;"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
  global_result += check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);

  global_result += execute_query(conn_rwsplit, "insert into t1 values(1);"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
  global_result += check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum); 

  execute_query(conn_rwsplit, "select * from t1;"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
  global_result += check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);

  execute_query(conn_rwsplit, "insert into t1 values(1);"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
  global_result += check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);

  int selects_before_100[255];
  int inserts_before_100[255];
  silent = 1;
  get_global_status_allnodes(&selects_before_100[0], &inserts_before_100[0], nodes, NodesNum, silent);
  printf("Doing 100 selects\n");
  tolerance=2*NodesNum;
  for (i=0; i<100; i++) {
    global_result += execute_query(conn_rwsplit, "select * from t1;"); 
    get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
    global_result += check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);
  }
  print_delta(&new_selects[0], &new_inserts[0], &selects_before_100[0], &inserts_before_100[0], NodesNum); 

  get_global_status_allnodes(&selects_before_100[0], &inserts_before_100[0], nodes, NodesNum, silent);
  printf("Doing 100 inserts\n");
  tolerance=2*NodesNum;
  for (i=0; i<100; i++) {
    global_result += execute_query(conn_rwsplit, "insert into t1 values(1);"); 
    get_global_status_allnodes(&new_selects[0], &new_inserts[0], nodes, NodesNum, silent);
    global_result += check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);
  }
  print_delta(&new_selects[0], &new_inserts[0], &selects_before_100[0], &inserts_before_100[0], NodesNum); 

  // close connections
  mysql_close(conn_rwsplit);
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}
