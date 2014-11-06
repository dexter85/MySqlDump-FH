#!/bin/bash

#EDIT
LOCAL_USER="root"	#Restore UserName for mySql
LOCAL_PWD="root" 	#Restore Password for mySql
LOCAL_DATABASE="a"	#Restore Database for mySql


REMOTE_USER="root"	#Remote UserName for mySql
REMOTE_PWD="root"	#Remote Password for mySql
REMOTE_DATABASE="b"	#Remote Database for mySql
REMOTE_USER_SSH="root"			#Remote UserName for ssh
REMOTE_HOST="123.456.789.963"	#Remote IP for ssh
#END EDIT

NOW="$(date +%Y%m%d)";


echo "[DUMP ROUTINES]";

ssh $REMOTE_USER_SSH@$REMOTE_HOST "mysqldump -u $REMOTE_USER -p$REMOTE_PWD $REMOTE_DATABASE --routines --no-create-info --no-data --no-create-db --skip-triggers  > /tmp/no-portable-routines-$REMOTE_DATABASE-$NOW.sql";

echo "[DUMP DATABASE DATA]";

ssh $REMOTE_USER_SSH@$REMOTE_HOST "mysqldump -u $REMOTE_USER -p$REMOTE_PWD $REMOTE_DATABASE  > /tmp/no-portable-main-$REMOTE_DATABASE-$NOW.sql";


echo "[CREATE ARCHIVIE]";

ssh $REMOTE_USER_SSH@$REMOTE_HOST "7za a -t7z /tmp/backup-$REMOTE_DATABASE-$NOW.7z /tmp/no-portable-routines-$REMOTE_DATABASE-$NOW.sql /tmp/no-portable-main-$REMOTE_DATABASE-$NOW.sql";
#ssh $REMOTE_USER_SSH@$REMOTE_HOST "7za a -t7z /tmp/backup-$REMOTE_DATABASE-$NOW.7z /tmp/no-portable-routines-$REMOTE_DATABASE-$NOW.sql";

echo "[CREATE FOLDER FOR DECOMRESS]";
rm -R /tmp/ssh-sync-remote
mkdir -p /tmp/ssh-sync-remote

echo "[DOWNLOAD ARCHIVE]";
scp $REMOTE_USER_SSH@$REMOTE_HOST:/tmp/backup-$REMOTE_DATABASE-$NOW.7z /tmp/ssh-sync-remote


echo "[DECOMPRESS ARCHIVE]";
7z -o/tmp/ssh-sync-remote/ e /tmp/ssh-sync-remote/backup-$REMOTE_DATABASE-$NOW.7z -y

echo "[CLEAR SQL FILE FOR PORTABLE]";
sed -E 's/DEFINER=`[^`]+`@`[^`]+`/ /g' /tmp/ssh-sync-remote/no-portable-routines-$REMOTE_DATABASE-$NOW.sql > /tmp/ssh-sync-remote/routines-$REMOTE_DATABASE-$NOW.sql
sed -E 's/DEFINER=`[^`]+`@`[^`]+`/ /g' /tmp/ssh-sync-remote/no-portable-main-$REMOTE_DATABASE-$NOW.sql > /tmp/ssh-sync-remote/main-$REMOTE_DATABASE-$NOW.sql



echo "[DROP OLD DATABASE]";
eval "mysql -u $LOCAL_USER -p$LOCAL_PWD -e 'SET FOREIGN_KEY_CHECKS=0;DROP DATABASE IF EXISTS $LOCAL_DATABASE;SET FOREIGN_KEY_CHECKS=1;'"
eval "mysql -u $LOCAL_USER -p$LOCAL_PWD -e 'CREATE DATABASE $LOCAL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci'"

echo "[RESTORE ROUTINES]";
mysql -u $LOCAL_USER -p$LOCAL_PWD $LOCAL_DATABASE < /tmp/ssh-sync-remote/routines-$REMOTE_DATABASE-$NOW.sql

echo "[RESTORE DATABASE]";
mysql -u $LOCAL_USER -p$LOCAL_PWD $LOCAL_DATABASE < /tmp/ssh-sync-remote/main-$REMOTE_DATABASE-$NOW.sql

echo "[CLEEN GARBAGE]";
rm -R /tmp/ssh-sync-remote/

ssh $REMOTE_USER_SSH@$REMOTE_HOST "rm /tmp/no-portable-main-$REMOTE_DATABASE-$NOW.sql"
ssh $REMOTE_USER_SSH@$REMOTE_HOST "rm /tmp/no-portable-routines-$REMOTE_DATABASE-$NOW.sql"
ssh $REMOTE_USER_SSH@$REMOTE_HOST "rm /tmp/backup-$REMOTE_DATABASE-$NOW.7z"