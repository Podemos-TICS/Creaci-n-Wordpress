#!/bin/bash

for i in $(ls /var/www/ | grep -v rss | grep -v nombrecirculo | grep -v pruebas)
do
	if [ -d /var/www/$i ]; then
		echo $i
		wget -O /var/www/rss/$i.entradas  http://$i.circulospodemos.info/?feed=rss2
	fi

done
