// libssl-dev libmariadbclient-dev
// gcc get_com_select_insert.c  -c -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

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

/**
Reads COM_SELECT and COM_INSERT variables from all nodes and stores into 'selects' and 'inserts'
*/
int get_global_status_allnodes(int *selects, int *inserts, MYSQL *nodes[256], int NodesNum, int silent)
{
    int i;
    MYSQL_RES *res;
    MYSQL_ROW row;

    for (i=0; i<NodesNum; i++) {    
    
      if(mysql_query(nodes[i], "show global status like 'COM_SELECT';") != 0)
         printf("Error: can't execute SQL-query\n");

      res = mysql_store_result(nodes[i]);
      if(res == NULL) printf("Error: can't get the result description\n");

      if(mysql_num_rows(res) > 0)
      {
        while((row = mysql_fetch_row(res)) != NULL)
        {
          if (silent == 0) {printf("Node %d COM_SELECT=%s\n", i, row[1]);}
          sscanf(row[1], "%d", &selects[i]);
        }
      }

      mysql_free_result(res); 

      if(mysql_query(nodes[i], "show global status like 'COM_INSERT';") != 0)
         printf("Error: can't execute SQL-query\n");

      res = mysql_store_result(nodes[i]);
      if(res == NULL) printf("Error: can't get the result description\n");

      if(mysql_num_rows(res) > 0)
      {
        while((row = mysql_fetch_row(res)) != NULL)
        {
          if (silent == 0) {printf("Node %d COM_INSERT=%s\n", i, row[1]);}
          sscanf(row[1], "%d", &inserts[i]);
        }
      }

      mysql_free_result(res); 

  }
  return(0);

}

/**
Prints difference in COM_SELECT and COM_INSERT 
*/
int print_delta(int *new_selects, int *new_inserts, int *selects, int *inserts, int NodesNum)
{
  int i;
  for (i=0; i<NodesNum; i++) { 
    printf("COM_SELECT increase on node %d is %d\n", i, new_selects[i]-selects[i]); 
    printf("COM_INSERT increase on node %d is %d\n", i, new_inserts[i]-inserts[i]); 
  }
  return(0);
}


