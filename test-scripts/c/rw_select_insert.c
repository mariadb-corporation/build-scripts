// libssl-dev libmariadbclient-dev
// gcc rw_select_insert.c -o rw_select_insert -I/usr/include/mysql/ -L/lib/x86_64-linux-gnu/ -lmariadbclient -lz -lcrypt -lnsl -lm -lpthread -lssl -lcrypto -ldl `mysql_config --cflags --libs`

#include <my_global.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
//#include <pthread.h>

MYSQL *nodes[256];
int selects[256];
int inserts[256];
int new_selects[256];
int new_inserts[256];
int silent = 0;

/**
Reads COM_SELECT and COM_INSERT variables from all nodes and stores into 'selects' and 'inserts'
*/
int get_global_status_allnodes(int *selects, int *inserts, int NodesNum)
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
Executes SQL query 'sql' using 'conn' connection
*/
int execute_query(MYSQL *conn, char *sql)
{
      MYSQL_RES *res;
      if(mysql_query(conn, sql) != 0)
         printf("Error: can't execute SQL-query: %s\n", mysql_error(conn));

      res = mysql_store_result(conn);
//      if(res == NULL) printf("Error: can't get the result description\n");
      mysql_free_result(res); 
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
    if (!((new_selects[i]-selects[i] == 0) || (new_selects[i]-selects[i] == 1))) {result = 1; printf("SELECT query executed, but COM_SELECT change is %d\n", new_selects[i]-selects[i]); }
    sum_selects += new_selects[i]-selects[i];
    selects[i] = new_selects[i]; inserts[i] = new_inserts[i];
  }
  if (sum_selects != 1) {result = 1; printf("SELECT query executed, but COM_SELECT increased more then on one node\n"); }
  
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
    if (new_inserts[i]-inserts[i] != 1) {result = 1; printf("INSERT query executed, but COM_INSERT increase is %d\n", new_inserts[i]-inserts[i]); }
    if (new_selects[i]-selects[i] != 0) {result = 1; printf("INSERT query executed, but COM_SELECT increase is %d\n", new_selects[i]-selects[i]); }
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
  MYSQL *conn;

  int i;
  int global_result = 0;

  char ip[15];
  char ip1[15];

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

  conn = mysql_init(NULL);
  if(conn == NULL)
  {
    fprintf(stdout, "Error: can't create MySQL-descriptor\n");
    exit(2);
  }
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
      printf("Error: can't connect to database %s\n", mysql_error(conn));
      exit(2);
   }


  }
  // connect to the MaxScale server
  if(!mysql_real_connect(conn,
                        ip,
                        "skysql",
                        "skysql",
                        "test",
                        4006,
                        NULL,
                        0
                        ))
  {
    printf("Error: can't connect to database %s\n", mysql_error(conn));
    exit(2);
  }
  else
  {
    //fprintf(stdout, "Success!\n");
    get_global_status_allnodes(&selects[0], &inserts[0], NodesNum);
  }
   
  execute_query(conn, "create table t1 (x1 int);");

  execute_query(conn, "select * from t1;"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], NodesNum);
  global_result += check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);

  execute_query(conn, "insert into t1 values(1);"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], NodesNum);
  global_result += check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum); 

  execute_query(conn, "select * from t1;"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], NodesNum);
  global_result += check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);

  execute_query(conn, "insert into t1 values(1);"); 
  get_global_status_allnodes(&new_selects[0], &new_inserts[0], NodesNum);
  global_result += check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);


  int selects_before_100[255];
  int inserts_before_100[255];
  silent = 1;
  get_global_status_allnodes(&selects_before_100[0], &inserts_before_100[0], NodesNum);
  printf("Doing 100 selects\n");
  for (i=0; i<100; i++) {
    execute_query(conn, "select * from t1;"); 
    get_global_status_allnodes(&new_selects[0], &new_inserts[0], NodesNum);
    //global_result += check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);
    check_com_select(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);
  }
  print_delta(&new_selects[0], &new_inserts[0], &selects_before_100[0], &inserts_before_100[0], NodesNum); 

  get_global_status_allnodes(&selects_before_100[0], &inserts_before_100[0], NodesNum);
  printf("Doing 100 inserts\n");
  for (i=0; i<100; i++) {
    execute_query(conn, "insert into t1 values(1);"); 
    get_global_status_allnodes(&new_selects[0], &new_inserts[0], NodesNum);
    //global_result += check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);
    check_com_insert(&new_selects[0], &new_inserts[0], &selects[0], &inserts[0], NodesNum);
  }
  print_delta(&new_selects[0], &new_inserts[0], &selects_before_100[0], &inserts_before_100[0], NodesNum); 

  // close connections
  mysql_close(conn);
  for (i=0; i<NodesNum; i++) { mysql_close(nodes[i]); }

  exit(global_result);
}
