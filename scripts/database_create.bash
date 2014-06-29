#!/bin/bash

# sudo bash database_create.bash nombre_DB nombre_usuario

PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)

mysql -p -e "
CREATE DATABASE \`$1\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT USAGE ON *.* TO \`$2\`@localhost IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$2\` IDENTIFIED BY '$PASSWORD';
FLUSH PRIVILEGES;
SHOW DATABASES;"

TEXT="Database $1 with user $2 and password $PASSWORD was created" 
echo $TEXT
date | mail -s "$TEXT" root@localhost
