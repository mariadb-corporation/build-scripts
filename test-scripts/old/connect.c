// libssl-dev libmariadbclient-dev
// gcc connect.c -o connect -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
//#include <pthread.h>

int main(int argc, char *argv[])
{
  // connection descriptor 
  MYSQL *conn;
  // result table descriptor
  MYSQL_RES *res;
  MYSQL_ROW row;

  char *ip;
  ip=argv[1];

  printf("Connecting to %s\n", ip);

  conn = mysql_init(NULL);
  if(conn == NULL)
  {
    fprintf(stderr, "Error: can't create MySQL-descriptor\n");
    exit(1);
  }
  // connect to the server
  if(!mysql_real_connect(conn,
                        ip,
                        "skysql",
                        "skysql",
                        "test",
                        4008,
                        NULL,
                        0
                        ))
  {
    printf("Error: can't connect to database %s\n", mysql_error(conn));
  }
  else
  {
    fprintf(stdout, "Success!\n");
    // some request
/*    if(mysql_query(conn, "SELECT * FROM catalogs") != 0)
       printf("Error: can't execute SQL-query\n");

    res = mysql_store_result(conn);
    if(res == NULL) printf("Error: can't get the result description\n");

    if(mysql_num_rows(res) > 0)
    {
      while((row = mysql_fetch_row(res)) != NULL)
      {
        printf("%s\n", row[1]);
      }
    }

    mysql_free_result(res); */
  } 

  sleep(20);
  // close connection 
  mysql_close(conn);
}
