<?php
$id=$_REQUEST['id'];
if(!$id)
	die();
$url = "https://graph.facebook.com/".$id."/picture?type=large";
header("Content-Type: image/jpeg");
echo file_get_contents($url);
