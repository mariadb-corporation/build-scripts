change master to MASTER_HOST='192.168.122.106';
change master to MASTER_USER='repl';
change master to MASTER_PASSWORD='repl';
change master to MASTER_LOG_FILE='node1-bin.000001';
change master to MASTER_LOG_POS=1625;
start slave;
