#!/bin/bash

BACKUP_DIR='/home/backups'
DATE=$(date +%d.%m.%y_%H.%M.%S)
WWW_DIR='/var/www'
CURRENT_BACKUP_DIR="$BACKUP_DIR/$DATE"
DDBBS_BACKUP_DIR="$CURRENT_BACKUP_DIR/databases"
CONF_BACKUP_DIR="$CURRENT_BACKUP_DIR/system"

mkdir $CURRENT_BACKUP_DIR
mkdir $DDBBS_BACKUP_DIR
mkdir $CONF_BACKUP_DIR

echo "Copiando CMSs..."
for i in $(ls $WWW_DIR)
do
	cp $WWW_DIR/$i $CURRENT_BACKUP_DIR -Rp
done

echo "Copiando bases de datos..."
for i in $(mysql -pcongresistaslumpenes -e "show databases;" | egrep -i "wp_|mwiki|mysql")
do
	mysqldump -pcongresistaslumpenes $i > $DDBBS_BACKUP_DIR/$i.sql
done

echo "Copiando configuración del sistema..."
cp /etc /var/scripts $CONF_BACKUP_DIR -Rp

echo "Comprimiendo..."
tar -cf $CURRENT_BACKUP_DIR.tar $CURRENT_BACKUP_DIR 2> /dev/null
pigz $CURRENT_BACKUP_DIR.tar

CURRENT_GZ=$CURRENT_BACKUP_DIR.tar.gz

rm $BACKUP_DIR/last
ln -s $CURRENT_GZ $BACKUP_DIR/last

echo "Limpiando..."
rm $CURRENT_BACKUP_DIR -R

echo "Configurando permisos..."
echo "https://xx.xxx.xx.xxx:x000/$DATE.tar.gz" > $BACKUP_DIR/last.link
chmod 0440 $BACKUP_DIR -R
chmod 0750 $BACKUP_DIR
chown root:www-data $BACKUP_DIR -R

############################################

