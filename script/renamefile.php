#!/usr/bin/php
<?php
if ($argc <= 1) exit;

$rep = dirname($argv[1]);
$rep = ($rep != '.')?$rep.'/':'';
$name = basename($argv[1]);
//echo $name."\r\n";
//$result = preg_replace("/(www.CpasBien.cm)|(www.CpasBien.pe)|(www.CpasBien.pw)|(www.CpasBien.me)|(Torrent9.ws)|[: ,()\\[\\]-]+/", ".", $name);
/*

*/
$result = preg_replace("/(www.CpasBien.cm)|(www.CpasBien.pe)|(www.CpasBien.pw)|(www.CpasBien.me)|(Torrent9.ws)|[: ,()\[\]-]+/i", ".", $name);
//echo $result."\r\n";
$result = preg_replace("/^([.])+/", "", $result,1);
//echo $result."\r\n";
//$result = preg_replace("/^./", "", $result,1);

echo $rep.$result;

?>
