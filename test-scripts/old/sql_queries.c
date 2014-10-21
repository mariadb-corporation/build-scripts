// libssl-dev libmariadbclient-dev
// gcc sql_queries.c mariadb_interaction.o sql_t1.o -o sql_queries -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

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
#include "sql_t1.h"

MYSQL *nodes[256];
int selects[256];
int inserts[256];
int new_selects[256];
int new_inserts[256];
int silent = 0;

int main(int argc, char *argv[])
{
  MYSQL *conn_rwsplit;
  MYSQL *conn_master;
  MYSQL *conn_slave; 

  int N=4;
  char sql[N][1000000];
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



  create_t1(conn_rwsplit);
  insert_into_t1(conn_rwsplit, N);

  printf("SELECT: rwsplitter\n");
  global_result += select_from_t1(conn_rwsplit, N);
//  printf("SELECT: rwsplitter\n");
//  global_result += select_from_t1(conn_rwsplit, N);
    
//  sleep(20);
//  printf("SELECT: rwsplitter\n");
//  global_result += select_from_t1(conn_rwsplit, N);

  printf("SELECT: master\n");
  global_result += select_from_t1(conn_master, N);
  printf("SELECT: slave\n");
  global_result += select_from_t1(conn_slave, N);



  for (i=0; i<NodesNum; i++) {
    printf("SELECT: directly from node %d\n", i);
    global_result += select_from_t1(nodes[i], N);
  }
  printf("SELECT: rwsplitter\n");
  global_result += select_from_t1(conn_rwsplit, N);

  printf("Creating database test1\n");
  global_result += execute_query(conn_rwsplit, "DROP TABLE t1");
  global_result += execute_query(conn_rwsplit, "DROP  DATABASE IF EXISTS test1;");
  global_result += execute_query(conn_rwsplit, "CREATE DATABASE test1;");
  sleep(5);

  printf("selecting DB test1 for rwsplit\n"); 
  global_result += execute_query(conn_rwsplit, "USE test1;");
  printf("selecting DB test1 for readconn master\n"); 
  global_result += execute_query(conn_slave, "USE test1;");
  printf("selecting DB test1 for readconn slave\n"); 
  global_result += execute_query(conn_master, "USE test1;");
  for (i=0; i<NodesNum; i++) {
    printf("selecting DB test1 for direct connection to node %d\n", i);
    global_result += execute_query(nodes[i], "USE test1;");
  }

  printf("Testing with database 'test1'\n");
  create_t1(conn_rwsplit);
  insert_into_t1(conn_rwsplit, N);

  printf("SELECT: rwsplitter\n");
  global_result += select_from_t1(conn_rwsplit, N);
  printf("SELECT: master\n");
  global_result += select_from_t1(conn_master, N);
  printf("SELECT: slave\n");
  global_result += select_from_t1(conn_slave, N);

  for (i=0; i<NodesNum; i++) {
    printf("SELECT: directly from node %d\n", i);
    global_result += select_from_t1(nodes[i], N);
  }


  global_result += execute_query(conn_rwsplit, "USE test;");
  global_result += execute_query(conn_slave, "USE test;");
  global_result += execute_query(conn_master, "USE test;");
  for (i=0; i<NodesNum; i++) {
    global_result += execute_query(nodes[i], "USE test;");
  }

  printf("Checking: table 't1' should NOT be found in 'test' database\n");
  if (check_if_t1_exists(conn_rwsplit) != 0) {global_result++; printf("Table t1 is found in 'test' database using RWSplit\n"); }
  if (check_if_t1_exists(conn_master)  != 0) {global_result++; printf("Table t1 is found in 'test' database using Readconnrouter with router option master\n"); }
  if (check_if_t1_exists(conn_slave)   != 0) {global_result++; printf("Table t1 is found in 'test' database using Readconnrouter with router option slave\n"); }
  for (i=0; i<NodesNum; i++) {
    if (check_if_t1_exists(nodes[i])    != 0) {global_result++; printf("Table t1 is found in 'test' database using direct connect to node %d\n", i); }
  }

  global_result += execute_query(conn_rwsplit, "USE test1;");
  global_result += execute_query(conn_slave, "USE test1;");
  global_result += execute_query(conn_master, "USE test1;");
  for (i=0; i<NodesNum; i++) {
    global_result += execute_query(nodes[i], "USE test1;");
  }

printf("Checking: table 't1' should be found in 'test1' database\n");
  if (check_if_t1_exists(conn_rwsplit) == 0) {global_result++; printf("Table t1 is NOT found in 'test1' database using RWSplit\n"); }
  if (check_if_t1_exists(conn_master)  == 0) {global_result++; printf("Table t1 is NOT found in 'test1' database using Readconnrouter with router option master\n"); }
  if (check_if_t1_exists(conn_slave)   == 0) {global_result++; printf("Table t1 is NOT found in 'test1' database using Readconnrouter with router option slave\n"); }
  for (i=0; i<NodesNum; i++) {
    if (check_if_t1_exists(nodes[i])    == 0) {global_result++; printf("Table t1 is NOT found in 'test1' database using direct connect to node %d\n", i); }
  }

  // close connections
  mysql_close(conn_rwsplit);
  mysql_close(conn_master);
  mysql_close(conn_slave);
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  if (global_result == 0) {printf("PASSED!!\n");} else {printf("FAILED!!\n");}
  exit(global_result);
}
