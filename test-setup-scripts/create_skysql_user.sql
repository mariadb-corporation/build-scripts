create user skysql@'%' identified by 'skysql';
create user skysql@'localhost' identified by 'skysql';
GRANT ALL PRIVILEGES ON *.* TO skysql@'%'; 
GRANT ALL PRIVILEGES ON *.* TO skysql@'localhost';

FLUSH PRIVILEGES;
