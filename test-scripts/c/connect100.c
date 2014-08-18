// libssl-dev libmariadbclient-dev
// gcc connect100.c -o connect100 -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

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
  MYSQL *conn[100];
  int i;
  // result table descriptor
  MYSQL_RES *res;
  MYSQL_ROW row;

  char *ip;
  ip=argv[1];

  printf("Connecting to %s 100 times\n", ip);

  for (i=0; i<100; i++){
  	conn[i] = mysql_init(NULL);
	if(conn[i] == NULL)  	{
    		fprintf(stderr, "Error: can't create MySQL-descriptor\n");
	    	exit(1);
  	}
	  // connect to the server
	  if(!mysql_real_connect(conn[i],
                        ip,
                        "skysql",
                        "skysql",
                        "test",
                        4009,
                        NULL,
                        0
                        ))
  	{
    		printf("Error: can't connect to database %s\n", mysql_error(conn[i]));
  	}
	else
  	{
    		fprintf(stdout, "Success!\n");
  	} 
  }
  
  sleep(60);
  // close connection 
  for (i=0; i<100; i++) { mysql_close(conn[i]); }
}
