<?php
class GiftService {

    public function sendGift($token, $from, $to, $item, $count, $nonce) {
	if(!$from || $from == "")
		return array();
	if(!$to || $to == "")
		return array();
	if(!$item || $item == "")
		$item = "strikes";
	$from = str_replace("1:","",$from);
	$to = str_replace("1:","",$to);	
	$key="Viral_".$to;
	$obj = getFromStore($key);
	if($obj == false) {
		$obj = array();
	}
	if(!isset($obj[$from])) {
		$obj[$from]=array();
    }
    if(!isset($obj[$from][$item])) {
		$obj[$from][$item]=0;
    }
	$obj[$from][$item]+=$count;
	
	if(setToStore($key,$obj) == false)
	{
		return "not ok";
	}
	return "ok";
    }
	
	public function getGifts($token, $uid) {
		if(!$uid || $uid == "")
		return array();
		$uid = str_replace("1:","",$uid);
		$key="Viral_".$uid;
		$obj = getFromStore($key);
		if($remove == true)
		{
			removeFromStore($key);
		}
		return $obj;
	}
	
	public function nukeGifts($token, $uid) {
		if(!$uid || $uid == "")
		return array();
		$uid = str_replace("1:","",$uid);
		$key="Viral_".$uid;
		if(removeFromStore($key) == false){
			return "not ok";
		}
		return "ok";
	}
	
	public function giftedStrikes($uid) {
		$gifts = GiftService::getGifts(null,$uid);
		$res  = 0;
		if($gifts != false)
		{
			foreach($gifts as $uid=>$value)
			{
				$strikes = $value["strikes"];
				$res += $value["strikes"];
			}
		}
		return $res;
	}
	 
}
?>
