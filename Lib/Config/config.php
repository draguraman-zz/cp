<?php

//Initialize Variables So We can Send it to Client.
$clientProfile="release";

//Server Protocol.
$serverProto = (@$_SERVER["HTTPS"] == "on") ? "https" : "http";
$serverProto = ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?: "http");

try {
    $serverURL = $serverProto;
    $serverURL .= "://".$_SERVER["SERVER_NAME"];
    if ($_SERVER["SERVER_PORT"] != "80" && $_SERVER["SERVER_PORT"] != "443")
    {    
        $serverURL .= ":.".$_SERVER["SERVER_PORT"];
    }
} catch (Exception $e) {
    $serverURL = "";
}

if("true" == $_REQUEST['debug']) {
	$clientProfile="debug";
}

//Provide access to FB.
$imagesURL=$serverURL."/Content/images/";
$scriptsURL=$serverURL."/Content/scripts/";
$clientURL=$serverURL."/Client/bin-".$clientProfile."/Billiards.swf";
$expressclientURL=$serverURL."/Client/bin-".$clientProfile."/expressInstall.swf";
$assetsURL=$serverURL."/Client/assets/";
$styleURL=$serverURL."/Content/stylesheets/";
$gatewayURL=$serverURL."/Gateway/";
$picproxyURL=$serverURL."/picture.php";

// Provides access to Facebook.
define( 'FB_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'sdk'. DIRECTORY_SEPARATOR . 'src'. DIRECTORY_SEPARATOR);
define( 'FB_AUXPATH', LIBPATH . DIRECTORY_SEPARATOR . 'FB'. DIRECTORY_SEPARATOR);
require_once(FB_ROOTPATH .'facebook.php');
require_once(FB_AUXPATH .'AppInfo.php');
require_once(FB_AUXPATH .'utils.php');
require_once(FB_AUXPATH .'FBUtils.php');

// Provides Access to Redis to Go.
define( 'PREDIS_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . 'Predis'. DIRECTORY_SEPARATOR);
require_once(PREDIS_ROOTPATH .'Predis.php');

// Provides Access to Our API.
define( 'API_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . 'API'. DIRECTORY_SEPARATOR);
require_once(API_ROOTPATH .'API.php'); 
?>
