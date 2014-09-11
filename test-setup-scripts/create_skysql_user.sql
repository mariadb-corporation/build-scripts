create user skysql@'%' identified by 'skysql';
create user skysql@'localhost' identified by 'skysql';
GRANT ALL PRIVILEGES ON *.* TO skysql@'%'; 
GRANT ALL PRIVILEGES ON *.* TO skysql@'localhost';

create user maxuser@'%' identified by 'maxpwd';
create user maxuser@'localhost' identified by 'maxpwd';
GRANT ALL PRIVILEGES ON *.* TO maxuser@'%';
GRANT ALL PRIVILEGES ON *.* TO maxuser@'localhost';


FLUSH PRIVILEGES;
