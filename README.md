MySqlDump-FunctionAndAllDb
==========================

Simple script to backup first the function then all database using mysqldump. 

I had problems making backup of MySQL database, which used the functions in views. 

Mysqldump backup the function at the end of file, when restore database functions are not found, and and this generates
errors which used the functions in views. 
