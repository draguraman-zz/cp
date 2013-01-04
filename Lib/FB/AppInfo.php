<?php

/**
 * This class provides static methods that return pieces of data specific to
 * your app
 */
class AppInfo {

  /*****************************************************************************
   *
   * These functions provide the unique identifiers that your app users.  These
   * have been pre-populated for you, but you may need to change them at some
   * point.  They are currently being stored in 'Environment envariables'.  To
   * learn more about these, visit
   *   'http://php.net/manual/en/function.getenv.php'
   *
   ****************************************************************************/

  /**
   * @return the appID for this app
   */
  public static function appID() {
	$envar = getenv('FACEBOOK_APP_ID');
	if(!$envar) 
		$envar = '292316880795142';
    return $envar;
  }

  /**
   * @return the appSecret for this app
   */
  public static function appSecret() {
    $envar = getenv('FACEBOOK_SECRET');
	if(!$envar)
		$envar = 'c6720deb3911443e996a9aa738b00f21';
	return $envar;
  }
  /**
   * @return the home URL for this site
   */
  public static function getHome () {
	$envar = getenv('FACEBOOK_APP_URL');
	if(!$envar)
		$envar = 'apps.facebook.com/crazypool';
    return ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?: "http") . "://" . $envar.'/';
  }

}
