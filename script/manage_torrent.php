#!/usr/bin/php
<?php

$simu 	= false;
$trace 	= true;

//$output = '';

function run($cmd){
	global $trace, $simu,$output;
	//unset($output);
	
	($trace||$simu)?print("::---- ".$cmd."\n"):'';
	
	if(!$simu){
		return exec($cmd);
	}else{
		return 'SIMU';
	}
}

/*
* Liste des binaires
*/
$TRANSMISSION="/usr/bin/transmission-remote";
$SCREENCAPT="/home/transmission/script/screencapt.php";
$RENAME="/home/transmission/script/renamefile.php";
#repertoire cible;
$REP_SOURCE="/home/transmission/Downloads";
$REP_CIBLE="/home/krolanta.fr/files/TORRENT";

/*
* Constantes
*/
#Nombre max de dl en parallele
$MAXACTIVE="30";
$LIMIT_DL="12000";
$LIMIT_UP="200";

//https://github.com/brycied00d/PHP-Transmission-Class
// Include RPC class
require_once( dirname( __FILE__ ) . '/_includes/TransmissionRPC.class.php' );

// create new transmission communication class
  $rpc = new TransmissionRPC();
  //var_dump($rpc->get());
  //var_dump($rpc->sstats());
  var_dump($rpc->set('',['uploadLimit'=> 2]));

?>