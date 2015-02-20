```
# from http://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/
# and https://ariejan.net/2007/12/12/how-to-install-mysql-on-ubuntudebian/
sudo apt-get install mysql-server
sudo service mysql status
sudo service mysql stop
sudo service mysql start
#sudo apt-get install libmysqlclient18
#sudo apt-get install mysql-connector-python-py3
```
MySQL has it’s own user accounts, which are not related to the user accounts on
your Linux machine. If you didn't provide a pwd during apt-get install then
provide one post-install like this:
```
#sudo mysqladmin -u root -h localhost password ...
```
Otherwise you'll have a mysql user 'root' with the pwd provided at install time.
To inspect & manipulate the DB:
```
mysql -u root -p
# type pwd
help
help contents
status
select user,host from mysql.user; # shows users
show grants for root@localhost;
help Administration
show DATABASES; # e.g. prints 'mysql' as a db
use mysql;
show tables;
select User,Password from user;
select User,Password from mysql.user;
```
To import a sample DB:
```
# e.g. get sample sql db from http://www.mysqltutorial.org/mysql-sample-database.aspx
mysql -uusername -ppassword < mysqlsampledatabase.sql
# alternatively from within mysql prompt:
source mysqlsampledatabase.sql
show databases;
use classicmodels;
show tables;
select city,phone from offices where state='CA' or territory='Japan';
```
Now accessing mysql db from random-language, e.g. python using MySQLdb: see
http://stackoverflow.com/questions/372885/how-do-i-connect-to-a-mysql-database-in-python
(which also has sample code and ORM recommendations)
```
#sudo pip3 install MySQL-python # fails: still not supporting python3
#sudo pip install MySQL-python # fails: mysql_config: not found
sudo apt-get install libmysqlclient-dev
sudo pip install MySQL-python
```

Worked nicely. Accessing the db with mysql user 'root' is frowned upon, so
creating other users:
```
mysql -u root -p
# from http://dev.mysql.com/doc/refman/4.1/en/adding-users.html
GRANT ALL PRIVILEGES ON *.* TO 'foo'@'localhost' IDENTIFIED BY 'foopass' WITH GRANT OPTION;
# thats still an admin user?
select User,Password from mysql.user; # shows new user 'foo'
```
