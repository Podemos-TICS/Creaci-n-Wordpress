# -*- coding: utf-8 -*-

import sys
import math
import Constants
import datetime 

#####################################################################

def addSubdomain(subdomain):
    
    current_year, current_month, current_day = datetime.datetime.now().strftime('%Y %m %d').split()
    
    zone_file_fd = open('{0}'.format(Constants.zone_file), 'r')                 # Abro en lectura
    zone_file = zone_file_fd.readlines()                                        # Leo
    zone_file_fd.close()                                                        # Cierro
    zone_file_fd = open('{0}'.format(Constants.zone_file), 'w')                 # Abro en escritura

    for line in zone_file:
        
        if 'Serial' in line:
            serial_line = line.split()
            year = serial_line[0][0:4]                  # año
            month = serial_line[0][4:6]                 # mes
            day = serial_line[0][6:8]                   # día
            version = int(serial_line[0][8:10])         # versión

	    if (day != current_day) or (month != current_month) or (year != current_year):
	        current_version = 1
	    else:
                current_version = version + 1               # incremento
            
            zone_file_fd.write('           {0}{1}{2}{3}      ; Serial\n'.format(
                current_year,
                current_month,
                current_day,
                str(current_version).zfill(2)           #relleno con ceros por la izda
                )
            )
        else:
            zone_file_fd.write(line)
            
    zone_file_fd.write('\n;###########{0}###########\n'.format(subdomain))
    
    if len(subdomain) < 32:                             # este lio calcula el número de tabuladores a añadir.
        num_tabs = int(math.ceil((32.0 - float(len(subdomain))) / 8))
        tab = '\t'
        zone_file_fd.write('{0}{1}IN              CNAME           circulospodemos.info.\n'.format(subdomain,num_tabs * tab))
    else:
        zone_file_fd.write('{0}\tIN              CNAME           circulospodemos.info.\n'.format(subdomain))
        
    zone_file_fd.close()                        # Cierro

#####################################################################

if len(sys.argv) != 2:
    print "Error: Invoke me with one argument. The subdomain to create"
else:
    addSubdomain(sys.argv[1])
