// libssl-dev libmariadbclient-dev
// gcc slave_failover.c mariadb_interaction.o -o slave_failover -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`



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

int main(int argc, char *argv[])
{
  MYSQL *conn_rwsplit;

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

  // Connecting to all nodes
  if (connect_all_nodes(nodes, IP_end, NodesNum) != 0) {exit(2);}

  global_result=0;
  unsigned int conn_num;
  unsigned int all_conn=0;
  unsigned int current_slave;
  unsigned int old_slave;
  for (i=0; i<NodesNum; i++) {
      conn_num = get_conn_num(nodes[i], ip, "test");
      printf("connections: %u\n", conn_num);
     if ((i == 0) && (conn_num != 1)) {printf("There is no connection to master\n"); global_result=1;}
     all_conn += conn_num;
     if ((i != 0) && (conn_num != 0)) {current_slave = i;}
  }
  if (all_conn != 2) {printf("total number of connections is not 2, it is %d\n", all_conn); global_result=1;}

  printf("current slave node is %u\n", current_slave);
  old_slave=current_slave;
 for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  char sys1[100];
  sprintf(&sys1[0], "/home/ec2-user/vm-scripts/stop_one_VM.sh %d", current_slave+IP_end+1);
  system(sys1);
  sleep(60); 
connect_all_nodes(nodes, IP_end, NodesNum);
all_conn=0;
  for (i=0; i<NodesNum; i++) {
      conn_num = get_conn_num(nodes[i], ip, "test");
      printf("connections to %d: %u\n", i, conn_num);
     if ((i == 0) && (conn_num != 1)) {printf("There is no connection to master\n"); global_result=1;}
     all_conn += conn_num;
     if ((i != 0) && (conn_num != 0)) {current_slave = i;}
  }
  if (all_conn != 2) {printf("total number of connections is not 2, it is %d\n", all_conn); global_result=1;}

  printf("current slave node is %u\n", current_slave);

  //execute_query(conn_rwsplit, "DROP TABLE IF EXISTS t1;");  
  //execute_query(conn_rwsplit, "CREATE TABLE t1 (x1 int, fl int);");  

  if (current_slave == old_slave) {printf("no failover happened\n"); global_result=1;}
  mysql_close(conn_rwsplit);
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}
