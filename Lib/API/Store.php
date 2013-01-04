<?php

$redisServerPool = array(
 0 => "redis://redistogo:0cc29a58e4865ea4ce3700e53bb63fc1@viperfish.redistogo.com:9173/",
 1 => "redis://redistogo:cc93b5433219f448a42a876fbcd5c16a@viperfish.redistogo.com:9174/",
 2 => "redis://redistogo:d8d1c6ce8b029085a1c6c1271d1ed64e@viperfish.redistogo.com:9175/",
 3 => "redis://redistogo:a8468a615b9172a54dbf0b9fb9ab6c6c@viperfish.redistogo.com:9176/",
 4 => "redis://redistogo:9ce119087e37e3e4db4ab7dffddbdee1@viperfish.redistogo.com:9177/",
 5 => "redis://redistogo:ed3023f1159a049db0ae52183335145b@viperfish.redistogo.com:9178/",
 6 => "redis://redistogo:5de475fa26c7824a556fd06fd27625c2@viperfish.redistogo.com:9179/",
 7 => "redis://redistogo:61e8f26545e31418de2dfddb5e6547d5@viperfish.redistogo.com:9180/",
 8 => "redis://redistogo:66c96081e14359f5587bd67727ce7a9e@viperfish.redistogo.com:9181/",
 9 => "redis://redistogo:ec71e35a25ca89ca77ef167c666c79fa@viperfish.redistogo.com:9182/",
10 => "redis://redistogo:f850e509f01b0f39f0b0e8e4af68d7ea@viperfish.redistogo.com:9183/",
11 => "redis://redistogo:2951a77940faa0f828c45b2475eecf6f@viperfish.redistogo.com:9184/",
12 => "redis://redistogo:86d46199be7dd3e5ff7d90767cedaefa@viperfish.redistogo.com:9185/",
13 => "redis://redistogo:ec258230de09194c1e1059ba07d491f8@viperfish.redistogo.com:9186/",
14 => "redis://redistogo:da2a1db780fdd0bf9c5f8ff096584f19@viperfish.redistogo.com:9187/",
15 => "redis://redistogo:fcce677201445e847e5d379dead436ec@viperfish.redistogo.com:9188/",
16 => "redis://redistogo:44b058033a5259ad35f0bf6ce86ee52d@viperfish.redistogo.com:9189/",
17 => "redis://redistogo:68bd92a38fcb1408bf268bfef07b5c5c@viperfish.redistogo.com:9190/",
18 => "redis://redistogo:b1e7a1bb271e98edf0f607266873ba05@viperfish.redistogo.com:9191/",
19 => "redis://redistogo:f8f019bac01170fa48ba8e05e495f899@viperfish.redistogo.com:9192/",
);
/* 0 => $_SERVER['REDISTOGO_URL'] */

$redisStore = array();

function getServer($key)
{
	global $redisServerPool;
	$server = crc32 ($key) % count($redisServerPool);
	return $server;
}

function initializeStore($server)
{
	global $redisStore;
	global $redisServerPool;
	if($redisStore[$server] != null)
		return;
	try {
		$redisURL=$redisServerPool[$server];
		$redisURLParts=parse_url ( $redisURL );
		$redisServer='localhost';
		$redisPort=6379;
		$redisUser='redistogo';
		$redisPassword=null;
		if(!empty($redisURLParts['host']))
		{
			$redisServer=$redisURLParts['host'];
		}
		if(!empty($redisURLParts['port']))
		{
			$redisPort=$redisURLParts['port'];
		}
		if (!empty($redisURLParts['user']))
		{
			$redisUser=$redisURLParts['user'];
		}
		if (!empty($redisURLParts['pass']))
		{
			$redisPassword=$redisURLParts['pass'];
		}
		$redisStore[$server] = new Predis_Client(
		array(
			'host' => $redisServer,
			'port' => $redisPort,
			'user' => $redisUser,
			'password' => $redisPassword,
		)
		);
		return;
	} catch (Exception $e) {
		$redisStore[$server] = null;
		die("Unable to initialize Redis.");
	}
}

function getFromStore($key)
{
    global $redisStore;
	$server = getServer($key);
	initializeStore($server);
	$serializedValue = $redisStore[$server]->get($key);
	return unserialize($serializedValue);
}


function setExpiry($key, $value)
{
	global $redisStore;
	$server = getServer($key);
	initializeStore($server);
	$redisStore[$server]->expire($key,$value);
}

function getKeyTTL($key)
{
	global $redisStore;
	$server = getServer($key);
	initializeStore($server);
	return $redisStore[$server]->ttl($key);
}

function inStore($key)
{
    global $redisStore;
	$server = getServer($key);
	initializeStore($server);
	return $redisStore[$server]->exists($key);
}

function setToStore($key,$value)
{
    global $redisStore;
	$server = getServer($key);
	initializeStore($server);
	$serializedValue = serialize ($value);
	return $redisStore[$server]->set($key,$serializedValue);
}

function removeFromStore($key)
{
	global $redisStore;
	$server = getServer($key);
	initializeStore($server);
	return $redisStore[$server]->del($key);
}

?>