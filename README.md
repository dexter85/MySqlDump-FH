MySqlDump-FunctionAndAllDb
==========================

Simple script to backup first the function then all database using mysqldump. 

I had problems making backup a MySQL database, which used the functions in views. 

Mysqldump backup the function and procedure at the end of file, when restore database functions are not found, and and this generates errors which used the functions in views. 

==========================

For use this simple script:
<pre>
./mysqldump-fh.sh -u userName -p password -d databaseName -h host -o /output/path.sql
</pre>

Cooming Soon
