//gcc mariadb_interaction.c -c -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`
#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>

#include "mariadb_interaction.h"

MYSQL * open_conn(int port, char * ip)
{

 MYSQL * conn = mysql_init(NULL);

  if(conn == NULL)
  {
    fprintf(stdout, "Error: can't create MySQL-descriptor\n");
    return(NULL);
  }
 if(!mysql_real_connect(conn,
                        ip,
                        "skysql",
                        "skysql",
                        "test",
                        port,
                        NULL,
                        0
                        ))
  {
    printf("Error: can't connect to database %s\n", mysql_error(conn));
    return(NULL);
  }

  return(conn);
}


int connect_all_nodes(MYSQL *nodes[], unsigned int IP_end, unsigned int NodesNum)
{
  unsigned int i;
  char ip1[15];
  // Connecting to all nodes
  for (i=0; i<NodesNum; i++) {
    nodes[i] = mysql_init(NULL);
    if(nodes[i] == NULL)
    {
      fprintf(stdout, "Error: can't create MySQL-descriptor\n");
      exit(2);
    }

    sprintf(ip1, "192.168.122.%d", i+IP_end+1);
    //printf("ip=%s\n", ip1);
    if(!mysql_real_connect(nodes[i],
                        ip1,
                        "skysql",
                        "skysql",
                        "test",
                        3306,
                        NULL,
                        0
                        ) ) {
      printf("Error: can't connect to database %s\n", mysql_error(nodes[i]));
      return(2);
   }
  }
  return(0);
}


/**
Executes SQL query 'sql' using 'conn' connection
*/
int execute_query(MYSQL *conn, char *sql)
{
      MYSQL_RES *res;
      if(mysql_query(conn, sql) != 0) {
         printf("Error: can't execute SQL-query: %s\n", mysql_error(conn));
         return(1);
      } else {
         res = mysql_store_result(conn);
//       if(res == NULL) printf("Error: can't get the result description\n");
         mysql_free_result(res); 
         return(0);
      }
}

unsigned int get_conn_num(MYSQL *conn, char * ip, char * db)
{
    MYSQL_RES *res;
    MYSQL_ROW row;
    unsigned long long int num_fields;
    unsigned long long int row_i=0;
    unsigned long long int i;
    unsigned int conn_num=0;

    if(mysql_query(conn, "show processlist;") != 0)
         printf("Error: can't execute SQL-query: %s\n", mysql_error(conn));
    res = mysql_store_result(conn);
    if(res == NULL) printf("Error: can't get the result description\n");

//    printf("rows=%llu\n", mysql_num_rows(res));
    num_fields = mysql_num_fields(res);


    if(mysql_num_rows(res) > 0)
    {
      while((row = mysql_fetch_row(res)) != NULL) { 
//        for (i = 0; i < num_fields; i++) {
//          printf("%s\t", row[2]);
//          printf("%s\t", row[3]);
          if ( (row[2] != NULL ) && (row[3] != NULL) ) {
//            printf("%s\t", strstr(row[2], ip));
//            printf("%s\t", strstr(row[3], db));
            if ((strstr(row[2], ip) != NULL) && (strstr(row[3], db) != NULL)) {conn_num++;}
          }
//          sscanf(row[i], "%llu", &int_res); 
//        }
//        printf("\n"); 
        row_i++;
      }
    }

   return(conn_num);

}
