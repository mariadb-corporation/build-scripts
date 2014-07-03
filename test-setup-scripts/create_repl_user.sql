create user repl@'%' identified by 'repl'; 
grant replication slave on *.* to repl@'%'; 

FLUSH PRIVILEGES;
