MySqlDump-FH
==========================

Simple script to backup first the function then all database using mysqldump. 

I had problems making backup a MySQL database, which used the functions in views. 

Mysqldump backup the function and procedure at the end of file, when restore database functions are not found, and and this generates errors which used the functions in views. 

Mysqldump backup clear DEFINER cause these errors in the import between 2 different servers.

==========================

For use, you need to configure ssh for connect to remote server without password, and install 7zip. Then edit the file and insert your configuration.
