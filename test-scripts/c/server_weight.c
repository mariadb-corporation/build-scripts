// libssl-dev libmariadbclient-dev
// gcc server_weight.c mariadb_interaction.o -o server_weight -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`



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
  int maxscale_conn_num=60;
  MYSQL *conn_read[maxscale_conn_num];

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
 
  for (i=0; i<maxscale_conn_num; i++) {
    conn_read[i] = open_conn(4008, ip);
  }
  // Connecting to all nodes
  if (connect_all_nodes(nodes, IP_end, NodesNum) != 0) {exit(2);}

  global_result=0;
  unsigned int conn_num;
  unsigned int all_conn=0;
  unsigned int current_slave;
  unsigned int old_slave;
  int Nc[4];
  Nc[0] = maxscale_conn_num / 6;
  Nc[1] = maxscale_conn_num / 3;
  Nc[2] = maxscale_conn_num / 2;
  Nc[3] = 0;

  for (i=0; i<NodesNum; i++) {
      conn_num = get_conn_num(nodes[i], ip, "test");
      printf("connections to node %d: %u\n", i, conn_num);
      if ((i<4) && (Nc[i] != conn_num)) {
		global_result++;
		printf("FAILED! Expected number of connections to node %d is %d\n", i, Nc[i]);
      }
  }
 // if (all_conn != 2) {printf("total number of connections is not 2, it is %d\n", all_conn); global_result=1;}


  for (i=0; i<maxscale_conn_num; i++) {
    mysql_close(conn_read[i]);
  }
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}
