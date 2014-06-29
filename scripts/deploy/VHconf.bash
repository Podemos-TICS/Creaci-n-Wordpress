#!/bin/bash

# sudo bash VHconf.bash $1 $2 [$3]
# Ejemplo: sudo bash VHconf.bash alcaladeguadaira "Alcalá de Guadaíra" alcaladeguadair

# $1: nombre del dominio y del directorio donde se instalará el blog.
# $2: nombre del círculo tal y como deberá de mostrarse en el blog, es decir, estético.
# $3: Campo opcional. Nombre de usuario de la base de datos.

# CONSTANTS
SITES_AVAILABLE='/etc/apache2/sites-available'
SITES_ENABLED='/etc/apache2/sites-enabled'
VH_TEMPLATE='/var/scripts/deploy/nombrecirculo.conf'
WORDPRESS_TEMPLATE='/var/www/nombrecirculo/'
PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
DDBB=wp_$1
DB_USER=u$1
MAIL='admins@localhost'
SCRIPT_DIR='/var/scripts/deploy'
NEW_WORDPRESS="/var/www/$1/wordpress"
ZONES_BACKUP='/var/scripts/zones'

##############################################

UNAME=$1
LEN=$(echo ${#UNAME})

if [ $LEN -gt 15 ]; then
	string=$3

	LEN2=$(echo ${#string})

	if [ $LEN2 -lt 1 ]; then
	        echo "Error: El nombre de usuario no debe exceder los 15 caracteres. Especifique un nombre de usuario adecuado como tercer argumento."
		exit 1
	fi

	if [ $LEN2 -gt 15 ]; then
		echo "Error: El nombre de usuario no debe exceder los 15 caracteres. Especifique un nombre de usuario adecuado como tercer argumento."
		exit 1
	fi

	DB_USER=u$3

fi

##############################################

cp /etc/bind/zones/db.circulospodemos.info $ZONES_BACKUP/db.circulospodemos.info.$(date +%d.%m.%y_%H.%M.%S).$1

echo "Creando subdominio $1.circulospodemos.info"
python /var/scripts/deploy/newSubdomain.py $1
echo "Reiniciando bind9"
/etc/init.d/bind9 restart

##############################################

echo "Despliegue de Wordpress"
# Copiando desde el template
cp $WORDPRESS_TEMPLATE /var/www/$1 -Rp

##############################################

# Creando la base de datos
echo "Creando la base de datos"
mysql -e "
CREATE DATABASE \`$DDBB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT USAGE ON *.* TO \`$DB_USER\`@localhost IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON \`$DDBB\`.* TO \`$DB_USER\` IDENTIFIED BY '$PASSWORD';
FLUSH PRIVILEGES;
SHOW DATABASES;"

echo "Volcando base de datos template"
mysqldump wp_nombrecirculo > $SCRIPT_DIR/wp_nombrecirculo.sql

echo "Poblando la base de datos"
cat $SCRIPT_DIR/wp_nombrecirculo.sql | sed s"/nombrecirculo/$1/g" > $SCRIPT_DIR/DDBBS/wp_$1_temp.sql
cat $SCRIPT_DIR/DDBBS/wp_$1_temp.sql | sed s"/nombre_circulo/$2/g" > $SCRIPT_DIR/DDBBS/wp_$1.sql
rm $SCRIPT_DIR/DDBBS/wp_$1_temp.sql

mysql $DDBB < $SCRIPT_DIR/DDBBS/wp_$1.sql

# Notificación con los datos de la base de datos
TEXT="Database $DDBB with user $DB_USER and password $PASSWORD was created" 
echo $TEXT
date | mail -s "$TEXT" $MAIL

############################################################

echo "Configurando Wordpress"
cat $SCRIPT_DIR/header.txt > $NEW_WORDPRESS/wp-config.php

# DDBB name
echo "// ** Ajustes de MySQL. Solicita estos datos a tu proveedor de alojamiento web. ** //" >> $NEW_WORDPRESS/wp-config.php
echo "/** El nombre de tu base de datos de WordPress */" >> $NEW_WORDPRESS/wp-config.php
echo "define('DB_NAME', '$DDBB');" >> $NEW_WORDPRESS/wp-config.php

# DB_USER
echo "/** Tu nombre de usuario de MySQL */" >> $NEW_WORDPRESS/wp-config.php
echo "define('DB_USER', '$DB_USER');" >> $NEW_WORDPRESS/wp-config.php

# DB PASSWORD
echo "/** Tu contraseña de MySQL */" >> $NEW_WORDPRESS/wp-config.php
echo "define('DB_PASSWORD', '$PASSWORD');" >> $NEW_WORDPRESS/wp-config.php

# REST OF THE CONFIG FILE
cat $SCRIPT_DIR/body.txt >> $NEW_WORDPRESS/wp-config.php

##############################################

echo "Configurando estadísticas"

chmod 0644 /var/log/apache2/*
cat /etc/awstats/awstats.nombrecirculo.circulospodemos.info.conf | sed s"/nombrecirculo/$1/g" > /etc/awstats/awstats.$1.circulospodemos.info.conf
echo /usr/lib/cgi-bin/awstats.pl -config=$1.circulospodemos.info  -update >> /var/scripts/awstats/awstats-update.bash

##############################################

echo "Configuración de apache2"
#Creando el VH $1.circulospodemos.info
cp /etc/apache2/sites-available/nombrecirculo.conf $VH_TEMPLATE
cat $VH_TEMPLATE | sed s"/nombrecirculo/$1/" > $SITES_AVAILABLE/$1.conf
ln -s $SITES_AVAILABLE/$1.conf $SITES_ENABLED

echo "Reiniciando apache2"
apache2ctl restart

##############################################
