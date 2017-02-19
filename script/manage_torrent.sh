#!/bin/sh
# Manage_torrent
# Created by STANISLAS DRAUNET
#
# Script permettant de deplacer un torrent fini vers un autre repertoire,
# de le supprimer de la liste, et de faire demarrer le torrent suivant dans
# la file d'attente




DEBUG=false


if [ $DEBUG = 'true' ]; then
    #_ECHO=echo -n `date +%Y-%m-%d" "%H:%M:%S` " | "; echo
    #_VIEW=$(echo -n `date +%Y-%m-%d" "%H:%M:%S` " | ")  ; echo
    _ECHO=echo
    _VIEW=echo
else	
    _ECHO=
    _VIEW=echo
fi

#Fichier de résumé des torrents de la journée
#creation du bon format de la date

#MAIL_RESUME=/home/transmission/script/liste_torrent_ok
MAIL_RESUME_HTML=/home/transmission/script/liste_torrent_html_ok
#####
# La liste des torrents telechargé dans la journée est stocké dans un fichier pour etre envoyé le soir à 20 sur le group
# On test si le fichier existe ou pas
#if [ ! -e $MAIL_RESUME   ]; then
#    $_ECHO touch $MAIL_RESUME
#fi
if [ ! -e $MAIL_RESUME_HTML   ]; then
    $_ECHO touch $MAIL_RESUME_HTML
    echo "<html>
    <h1> KROLANTA - pirate ! </h1><br/>
    <font size=\"-1\">
    <ul>
    " >> $MAIL_RESUME_HTML
fi

#Chemin d'acces à transmission-remonte
BIN="/usr/bin/transmission-remote"
BIN_SCREENCAPT="/home/transmission/script/screencapt.php"
BIN_RENAME="/home/transmission/script/renamefile.php"
#repertoire cible
REP_SOURCE="/home/transmission/Downloads"
REP_CIBLE="/home/krolanta.fr/files/TORRENT"

#Parametre SMTP
#BIN_MAIL="/usr/bin/sendEmail"
#FROM="admin@krolanta.fr"
#TO_KROLANTA="krolanta@yahoogroupes.fr"
#TO_STAN="stanislas.draunet@gmail.com"
#SMTP_SERVER="auth.smtp.1and1.fr"
#USER="admin@krolanta.fr"
#PSWD="wazawaza"

#Nombre max de dl en parallele
MAXACTIVE="30"
LIMIT_DL="12000"
LIMIT_UP="200"


unrarTorrent()
{
    for RAR in $(find $1 -name *.rar); do
	#echo $(dirname $RAR)
        $_ECHO LIST=$(unrar e $RAR $(dirname $RAR)  | grep 'Extracting from ' | cut -d' ' -f3) 
		 
	$_ECHO rm -f $LIST
    done
}

deleteTorrentQueue(){
	#Suppression du torrent dans la liste des fichier torrent et suppression du fichier dans Downloads
    #On l'arrete
    $_VIEW "Suppression du torrent de la queue :: "$1
	$_ECHO $BIN -t $1 --stop
    #On le supprime lui et son local data	
	$_ECHO $BIN -t $1 --remove-and-delete	
}
		

#ON FIXE le taux de DL et d'UP max
$BIN -d $LIMIT_DL > /dev/null
$BIN -u $LIMIT_UP > /dev/null


#Recuperation de la liste des torrents etant à 100% de dl
#Deplacement du fichier dans le repertoire cible
#Suppression du fichier dans le repertoire de dl
#Envoi d'un mail pour informer d'un nouveau fichier dispo

#LIST="$($BIN -l | tail --lines=+2 | grep 100% | grep -v Stopped | awk '{ print $1; }' | sed 's/\*/\ /g')"

ID="$($BIN -l | grep 100% | grep -v Stopped | head -n1 | awk '{ print $1; }' | sed 's/\*/\ /g')"

#for ID in $LIST; do
if [ -n "$ID" ]; then
    #Recuperation du nom du fichier grace à l'ID, et on retire le tag Name:
    NOM_TORRENT="$($BIN --torrent $ID --info | grep Name: | sed 's/Name://' | sed 's/^ *\(.*\) *$/\1/' )"
    $_VIEW "######################################"
    $_VIEW `date`
    $_VIEW "NOM TORRENT A TRAITER ::" $NOM_TORRENT
     
    #NOM_FINAL="$($BIN --torrent $ID --info | grep Name: | sed 's/Name://')"
    NOM_FINAL="$($BIN_RENAME "$NOM_TORRENT")"
     
    $_VIEW "NOM FINAL ::" $NOM_FINAL
    
    #test si c'est un rep
    IS_FILES=true
    
    #Copie du fichier vers le repertoire cible - dans le doute on ecrase si existant
	#Si c'est un fichier
	if [ -f "$REP_SOURCE/$NOM_TORRENT" ]; then
		$_VIEW "TORRENT EST UN FICHIER"
    	$_ECHO mv -f "$REP_SOURCE/$NOM_TORRENT" "$REP_CIBLE/$NOM_FINAL"
    	
    	deleteTorrentQueue $ID
    	
	    $_ECHO chown www-data:www-data "$REP_CIBLE/$NOM_FINAL"
	    $_VIEW `date`
	    $_ECHO $BIN_SCREENCAPT "$REP_CIBLE/$NOM_FINAL"
	    $_VIEW `date`
	    
	fi

	#Si c'est un repertoire
	if [ -d "$REP_SOURCE/$NOM_TORRENT"  ]; then
	    $_VIEW "TORRENT EST UN REPERTOIRE"
	    
	    if [ -n "$NOM_TORRENT"  ]; then
    		$_ECHO mv -f "$REP_SOURCE/$NOM_TORRENT" "$REP_CIBLE/$NOM_FINAL"
    		
    		deleteTorrentQueue $ID
    		
			#TRANSFORMATION DES FICHIERS ET SOUS REPERTOIRE POUR RETIRER LES ESPACE ET LES QUOTES
			#Action si le rep a bien été deplacé
		   
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type d -exec rename 's/\ /\./g' {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type d -exec rename "s/\'/\_/g" {} \; 
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type d -exec rename "s/\+/\_/g" {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type d -exec rename "s/\(/\./g" {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type d -exec rename "s/\)/\./g" {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type d -exec rename "s/\,/\./g" {} \;		    
		    
		    $_ECHO cd "$REP_CIBLE/$NOM_FINAL"; for i in .*; do `rename "s/^\.* *//" $i`; done ;cd -; 
		
		      
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -exec rename 's/\ /\./g' {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -exec rename "s/\'/\_/g" {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -exec rename "s/\+/\_/g" {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -exec rename "s/\(/\./g" {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -exec rename "s/\)/\./g" {} \;
            $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -exec rename "s/\,/\./g" {} \;		    

		    $_ECHO cd "$REP_CIBLE/$NOM_FINAL"; for i in .*; do `rename "s/^\.* *//" $i`; done ;cd -;
		    

		    $_ECHO chown -R www-data:www-data "$REP_CIBLE/$NOM_FINAL"
		
		    #$_ECHO unrarTorrent "$REP_CIBLE/$NOM_FINAL"		
		    #Creation du screencapt
		    $_VIEW `date`
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -name *.avi -exec $BIN_SCREENCAPT {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -name *.mp4 -exec $BIN_SCREENCAPT {} \;
		    $_ECHO find "$REP_CIBLE/$NOM_FINAL" -depth -type f -name *.mkv -exec $BIN_SCREENCAPT {} \;
		    $_VIEW `date`
		    #APRES LE DEPLACEMENT, on test si archive rar. Si oui, on decompresse et on supprime les .rar
		#else
		#    exit;
		#fi
		
	    else
		#$_ECHO	$IS_EMPTY=true
		echo "NOM TORRENT vide"
		continue;
	    fi
	    
	fi

    NOM_FOR_MAIL="<li>$NOM_FINAL</li>"

	#On ajoute le nom du fichier dans le mail de resumé
	#    echo '* '$NOM_FINAL >> $MAIL_RESUME
    echo $NOM_FOR_MAIL >> $MAIL_RESUME_HTML
fi
#done


#LANCEMENT du prochain torrent mis dans la file d'attente
# Pour cela,nous devons connaitre le nombre de torrent actif et le nombre maxi autirisé
# si le max n'est pas atteint, on sort du script
# Si le max est depassé, on recupere la liste des torents en cours de dl, les liste par % d'avancement
# Puis on ne garde que le nombre de torrent en trop ayant le % d'avancement le plus petit

#combien de torrent sont actif ?
# si le nombre actif est superieur au maxactif je prend ceux qui on le plus petit % et je les met en pause
ACTIVE="$($BIN -l | tail --lines=+2 | grep -v Stopped | grep -v Sum: | wc -l)"

#Test si ACTIVE est superieur (pas égal) à MAXACTIVE
if [ $ACTIVE -gt $MAXACTIVE ]; then
    #On recupere la liste de torrent a arrete en partant du moins avancé pour le stopper
    LIST=$($BIN  -l |  grep -v Stopped | grep -v 100% | grep -v Sum: | grep -v Done | tac | awk '{ print $1;  }' | head -n $(expr $ACTIVE - $MAXACTIVE) )
    #Pour chaque fichier recuperé, on l'arrete
    for ID in $LIST; do
	$_ECHO $BIN -t $ID --stop
    done
fi

#LANCEMENT des nouveaux torrents dans la files d'attente
#Cela se lance qui si ACTIVE n'est pas superieur à MAXACTIVE
LIST=$($BIN -l | grep -v 100% | grep -v ID | grep -v Sum: | awk '{ print $1;  }' | head -n $(expr $MAXACTIVE - $ACTIVE))

for ID in $LIST; do
    #On le lance
	$_ECHO $BIN -t $ID --start 
done
