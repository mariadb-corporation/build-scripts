change master to MASTER_HOST='192.168.122.107';
change master to MASTER_USER='repl';
change master to MASTER_PASSWORD='repl';
change master to MASTER_LOG_FILE='node2-bin.000001';
change master to MASTER_LOG_POS=537;
start slave;
