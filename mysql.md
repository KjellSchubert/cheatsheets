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

Create database from scratch:
```
create database testdb;
show databases;
use testdb;
show tables; # starts empty
CREATE TABLE department
(
DepartmentID INT,
DepartmentName VARCHAR(20)
);
CREATE TABLE employee
(
LastName VARCHAR(20),
DepartmentID INT
);
INSERT INTO department VALUES(31, 'Sales');
INSERT INTO department VALUES(33, 'Engineering');
INSERT INTO department VALUES(34, 'Clerical');
INSERT INTO department VALUES(35, 'Marketing');
INSERT INTO employee VALUES('Rafferty', 31);
INSERT INTO employee VALUES('Jones', 33);
INSERT INTO employee VALUES('Heisenberg', 33);
INSERT INTO employee VALUES('Robinson', 34);
INSERT INTO employee VALUES('Smith', 34);
INSERT INTO employee VALUES('Williams', NULL);
select * from department;

# cross join: catesian product of 2 tables
# 'Normal uses are for checking the server's performance'
SELECT * FROM employee CROSS JOIN department;
# => | Rafferty   |           31 |           31 | Sales          |

# natural join: set of all combinations of tuples in R and S that are equal
# on their common attribute name.
# Natural join considered dangerous (risk adding columns), use explicit
# inner join instead.
SELECT * FROM employee NATURAL JOIN department;
# => |           31 | Rafferty   | Sales          |

# inner join: cartesian product filtered by predicate
# a) explicit syntax (with INNER being optional)
SELECT *
FROM employee
INNER JOIN department ON employee.DepartmentID = department.DepartmentID;

# b) implicit syntax (which I like better atm), so cross join with filter in
# WHERE clause:
SELECT *
FROM employee, department
WHERE employee.DepartmentID = department.DepartmentID;

# b) variant with table aliases specified, and projection in SELECT
SELECT e.LastName, d.DepartmentId, d.DepartmentName
FROM employee e, department d
WHERE e.DepartmentID = d.DepartmentID;

# outer join: cannot simply replace INNER with OUTER in explicit INNER join
# syntax, gotta replace INNER with LEFT|RIGHT|FULL OUTER.
# Result is same as for inner join but plus potential extra rows with NULLs.
# The LEFT outer join will return all rows from the left table, including the
# ones that don't match the predicate (in this cases filling non-matched cols
# with nulls)
SELECT *
FROM employee
LEFT OUTER JOIN department ON employee.DepartmentID = department.DepartmentID;
# => plus Williams   |         NULL |         NULL | NULL

SELECT *
FROM employee
RIGHT OUTER JOIN department ON employee.DepartmentID = department.DepartmentID;
# => plus NULL       |         NULL |           35 | Marketing
# (but not with Williams)

SELECT *
FROM employee
FULL OUTER JOIN department ON employee.DepartmentID = department.DepartmentID;
# not supported in mysql, would include both the extra lines from left and
# right outer join, so Williams plus Marketing.
# Simulate via UNION ALL of left and right join, see
# http://stackoverflow.com/questions/4796872/full-outer-join-in-mysql
```

Union:
```
# I'm surprised this worked in mysql: rows are simply concatenated, columns
# are not reshuffled to match up Department ID.
SELECT * FROM employee UNION SELECT * FROM department;
SELECT * FROM department UNION SELECT * FROM employee;

# So UNION removes dups, but UNION ALL does not?
```
