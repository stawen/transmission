#!/usr/bin/php
<?php
if ($argc <= 1){
	echo "::EXIT:: -- Specify input file -- ::\n";
	exit;
} 

$simu 	= false;
$trace 	= false;

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


# Paths to stuff.
$path_mplayer   = '/usr/bin/mplayer -really-quiet';
$path_gm	   	= '/usr/bin/gm';
$path_mencoder  = '/usr/bin/mencoder -really-quiet';
$path_ffmpeg	= '/usr/bin/ffmpeg';

$tmp_dir = '/tmp';

# Read command line options.
$file = $argv[1];
$rows = isset($argv[2])?$argv[2]:3;
$cols = isset($argv[3])?$argv[3]:3;

$geom = '310:176';
print("::-- SCREENCAPT\n");
print("::-- Fichier traité : $file \n");

$number_thumb = $rows * $cols;

# Create temporary directory.
$tmp_dir .='/thumb-'.rand(10000,20000);

run("mkdir $tmp_dir");

/*
* Creation du screenCapt pour preview en Mosaic dans un jpg
*/

# determine the length of the video
$videoLen = run("$path_mplayer -identify '$file' -nosound -vc dummy -vo null | grep 'ID_LENGTH=' | cut -d'=' -f2");

if($videoLen==''){
	echo "::EXIT:: -- Unable to read video length -- ::\n";
	exit;
}

$num_img = $number_thumb;

$video_pos_step = (($videoLen - 15) / ($number_thumb - 1));
$video_pos_current = 3;

while ($num_img >= 1){
    
    run("$path_mplayer -vo jpeg::outdir=$tmp_dir -ss $video_pos_current -frames 1 '$file' -vf scale=$geom -nosound ");
    
    $video_pos_current = $video_pos_current + $video_pos_step;
    $i = $number_thumb - $num_img + 1;
 
    run("mv $tmp_dir/'00000001.jpg' $tmp_dir/img_$i.jpg");
	$num_img--;
}

run("$path_gm montage -mode concatenate -tile 3X3 $tmp_dir/*.jpg  '$file'.jpg");
run("$path_gm convert -fill white -pointsize 15 -draw 'text 10,20 www.krolanta.fr' '$file'.jpg '$file'.jpg");



/*
* Creation de l'extrait video en MP4
*/

#Maintenant on fait l'extrait du fichier
#On prend la longueur du fichier on coupe en 2 moins 15 et on prend 30 secondes
$video_start_extract = ($videoLen / 2) - 15;
run("$path_ffmpeg -ss $video_start_extract -i '$file' -t 30 -c:v libx264 -s hd480 -movflags faststart -strict -2  '$file'.mp4 -loglevel panic");

run("rm -drf $tmp_dir");

?>