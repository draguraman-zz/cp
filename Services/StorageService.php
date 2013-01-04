<?php
require_once('GiftService.php');
class StorageService {

    public function nukeGameState($token, $uid) {
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace("1:","",$uid);
	$key="GameState_".$uid;
	if(removeFromStore($key) != false)
		return "ok";
	return "not ok";
    }

    public function persistGameState($token, $uid, $state) {
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace("1:","",$uid);
	$key="GameState_".$uid;
	if(setToStore($key,$state) != false)
	{
		/*
		 * Set expiry to 1 hour 60*60 sec
		 */
		$val = getFromStore($key);
		if($val->strikes == 1)
		{
			$expKey = $key."_EXPIRY_";
			setToStore($expKey,"3600");
			setExpiry($expKey,3600);
		}
		return "ok";
	}
	
	return "not ok";
    }
	
    public function loadGameState($token, $uid) {
	$giftedStrikes = 0;
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace("1:","",$uid);
	$key="GameState_".$uid;
	$val = getFromStore($key);
	$expKey = $key."_EXPIRY_";
	if(getKeyTTL($expKey) == -1 && $val->strikes == 1)
	{
	    $val->strikes = 60;
	}
	$val->strikes += GiftService::giftedStrikes($uid);
	
	return $val;
    }
    
    public function persistPlayerState($uid, $playerStuff)
    {
	if(!$uid || $uid == "")
	{
	    return "not ok";
	}
	$uid = str_replace("1:","",$uid);
	$key = "playerState_".$uid;
	if(setToStore($key, $playerStuff) != false)
	{
	    return "ok";
	}
	return "not ok";
    }
    
    public function loadPlayerState($uid)
    {
	if(!$uid || $uid == "")
	{
	    return "not ok";
	}
	$uid = str_replace("1:","",$uid);
	$key = "playerState_".$uid;
	return getFromStore($key);
    }
}
?>
