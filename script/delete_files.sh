#!/bin/sh

#################################################################
## suppression des fichiers en fonction d'un nb de jour max"   ##
#################################################################

DIR_CIBLE=/home/krolanta.fr/files/TORRENT/
NB_JOURS=45

USED=`df -h | grep /home -m 1 | awk  '{print $5}' |  tr -d '%'`
LIMITED=90

if [ $USED -ge $LIMITED ]; then
    echo ":::::::PURGE TORRENT ::::::::"
    find $DIR_CIBLE -mtime +$NB_JOURS -exec rm -rf {} \; 
fi
   