<?php
define( 'LIBPATH', dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'Lib' );
define( 'CONFIG', LIBPATH  . DIRECTORY_SEPARATOR . 'Config' . DIRECTORY_SEPARATOR . 'config.php');
define( 'SERVICESPATH', dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'Services' );
require_once(CONFIG);
require_once(SERVICESPATH . DIRECTORY_SEPARATOR . 'NeighborService.php');
?>
<?php
	$token = 'AAAEJ3FPXdgYBAC9QXGmoNq9yV0pQ9L2gBaz9r1kdmTP4nfu2ppW9FfG49oxleFxqvt9EBrE0ZAurUjUuZBQsB2rxeRJklxEvthazCi1gZDZD';
	$user = '1:100001155508359';
	$ns = new NeighborService();
	print_r($ns->getNeighbors($token, $user));
?>
