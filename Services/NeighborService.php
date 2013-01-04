<?php

require_once('StorageService.php');
require_once('GiftService.php');

class NeighborService {
    public function getNeighbors($token, $uid) {
	$result=array();

	if(!$uid || $uid == "")
		return $result;

        $facebook = new Facebook(array(
         'appId'  => AppInfo::appID(),
         'secret' => AppInfo::appSecret(),
         'cookie' => false
        ));
  
        $facebook->setAccessToken($token);
         
        $fparams = array(
		'method' => 'fql.query',
		'query' => "SELECT uid, first_name, is_app_user FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me())",
        );
	error_log($facebook->getUser());

	try {	
		$friends = $facebook->api($fparams);		
 	} catch(FacebookApiException $e) {
		error_log($e->getType());
        	error_log($e->getMessage());
		return $result;
	}

	$paramUid = $uid;
	$uid = str_replace("1:","",$uid);
	$me = $uid;

	$result['uid']=array();
	$result['first_name']=array();
	$result['game_data_points']=array();
	$result['game_data_uid']=array();
	$result['game_data_username']=array();
	$result['friends_who_gifted'] = array();
	$result['friends_gifted_what'] = array();
	

	$name_lookup = array();	
	$points_lookup = array();	
	foreach ($friends as $friend) {
		$uid = assertNumeric(idx($friend, 'uid'));
		$key = '1:'.$uid;
		$name = idx($friend,'first_name');
		if(!$name || $name == "") {
			$name="Anonymous";
		}
		$is_user = idx($friend, 'is_app_user');
		$name_lookup[$key]=$name;
		if($is_user == "1") {
			try {
				$points = StorageService::loadPlayerState("1:".$uid);
			} catch (Exception $e) {
				$points = 0;
			}
			if($points == false)
			{
				$points = 0;
			}
			$points_lookup[$key]=$points;
		}
		$result['uid'][]=$key;
	    	$result['first_name'][] = $name;
	}

	{
		//uid is local
		$uid = $me;
		$key = '1:'.$uid;
		$name_lookup['1:'.$uid] = 'You';
		try {
			$points = StorageService::loadPlayerState("1:".$uid);
		} catch (Exception $e) {
			$points = 0;
		}
		if($points == false)
		{
			$points = 0;
		}
		$points_lookup[$key]=$points;
	}
	
	arsort($points_lookup);
	foreach ($points_lookup as $uid => $points) {
		$result['game_data_uid'][] = $uid;
		$result['game_data_points'][] = $points;
		$result['game_data_username'][] = $name_lookup[$uid];
	}
	
	$gifts = GiftService::getGifts($token,$paramUid);
	GiftService::nukeGifts(null,$paramUid);
	if($gifts != false)
	{
		foreach($gifts as $uid=>$value)
		{
			$result['friends_who_gifted'][] = $uid;
			$result['friends_gifted_what'][] = $value["strikes"];
		}
	}

	return $result;
    }
}
?>
