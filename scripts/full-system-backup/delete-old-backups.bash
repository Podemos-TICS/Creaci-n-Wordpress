#!/bin/bash

# Configura correctamente este path
BACKUPS_DIR='/home/backups'
# Peso máximo del directorio backups en la unidad MAX_POOL_SIZE_UNITY
MAX_POOL_SIZE=10240	# 10 Gigas
# MAX_POOL_SIZE_UNITY M = MiB; K = KiB; B = Bytes
MAX_POOL_SIZE_UNITY='M'
DATE=`date +%d.%m.%y_%H.%M.%S`
# Para la llamada recursiva
SCRIPT_PATH='/var/scripts/full-system-backup/delete-old-backups.bash'

#####################################################
#                       POOL
#####################################################

case $MAX_POOL_SIZE_UNITY in
    M )
        SIZE=`du -sm $BACKUPS_DIR | sed s'/\t.*//g'`
    ;;
    K )
        SIZE=`du -sk $BACKUPS_DIR | sed s'/\t.*//g'`
    ;;
    B )
        SIZE=`du -sb $BACKUPS_DIR | sed s'/\t.*//g'`
    ;;
    * )
        # Por defecto en megas
        SIZE=`du -sm $BACKUPS_DIR | sed s'/\t.*//g'`
esac

if [ $SIZE -gt $MAX_POOL_SIZE ]; then
    echo "El peso de la carpeta ..backups/ es superior al tamaño máximo fijado para ella, eliminando elementos antiguos"
    OLDEST_FILE=`ls -t $BACKUPS_DIR | tail -n 1`
    echo "Eliminando "$OLDEST_FILE
    rm $BACKUPS_DIR/$OLDEST_FILE
fi


case $MAX_POOL_SIZE_UNITY in
    M )
        SIZE=`du -sm $BACKUPS_DIR | sed s'/\t.*//g'`
    ;;
    K )
        SIZE=`du -sk $BACKUPS_DIR | sed s'/\t.*//g'`
    ;;
    B )
        SIZE=`du -sb $BACKUPS_DIR | sed s'/\t.*//g'`
    ;;
    * )
        # Por defecto en megas
        SIZE=`du -sm $BACKUPS_DIR | sed s'/\t.*//g'`
esac

if [ $SIZE -gt $MAX_POOL_SIZE ]; then
	echo "Aun demasiado grande la carpeta ..backups, volviendo a ejecutar..."
        /bin/bash $SCRIPT_PATH
fi
