#!/bin/sh

DEBUG=false

if [ $DEBUG = 'true' ];then
    _ECHO=echo
else	
    _ECHO=
fi
	
#Parametre SMTP
BIN_MAIL="/usr/bin/sendEmail"
FROM="krolanta@krolanta.fr"
TO="krolanta@yahoogroupes.fr"
#TO="stanislas.draunet@gmail.com"
SMTP_SERVER="smtp.gmail.com"

USER="krolanta@krolanta.fr"
PSWD="wazawaza"

MAIL_RESUME_HTML=/home/transmission/script/liste_torrent_html_ok


echo "</ul>
</font>
</html>" >> $MAIL_RESUME_HTML

$_ECHO $BIN_MAIL \
    -f $FROM \
    -t $TO \
    -u "[TORRENT]Résume de la semaine" \
    -o tls=yes message-file=$MAIL_RESUME_HTML \
    -s $SMTP_SERVER \
    -xu $USER \
    -xp $PSWD

$_ECHO rm -f $MAIL_RESUME_HTML