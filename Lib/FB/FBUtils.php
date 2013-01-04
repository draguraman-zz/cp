<?php

/**
 * This class provides Facebook specfic utility functions that you may use
 * to build your app.
 */
class FBUtils {

  /*****************************************************************************
   *
   * The content below provides some helper functions that you may wish to use as
   * you develop your app.
   *
   ****************************************************************************/

  /**
   * Authenticates the current viewer of the app, prompting them to login and
   * grant permissions if necessary.  For more information, check the
   * 'https://developers.facebook.com/docs/authentication/'
   *
   * @return app access token if login is successful
   */
  public static function login($redirect) {
    $app_id = AppInfo::appID();
    $app_secret = AppInfo::appSecret();
    // Scope defines what permissions that we are asking the user to grant.
    // In this example, we are asking for the ability to publish stories
    // about using the app, access to what the user likes, and to be able
    // to use their pictures.  You should rewrite this scope with whatever
    // permissions your app needs.
    // See https://developers.facebook.com/docs/reference/api/permissions/
    // for a full list of permissions
    $scope = 'user_likes,user_photos,user_videos,publish_stream';
    session_start();
    $code = $_REQUEST["code"];
    // If we don't have a code returned from Facebook, the first step is to get
    // that code
    $verified_login = false;
    if ($_REQUEST['state']) {
	$verified_login = true; //Force... Cookie not being Set.
    }
    if ($verified_login) {
      $ch = curl_init("https://graph.facebook.com/oauth/access_token");
      curl_setopt($ch, CURLOPT_POSTFIELDS,
        "client_id=$app_id&redirect_uri=$redirect&client_secret=$app_secret" .
        "&code=$code&scope=$scope");
      curl_setopt($ch, CURLOPT_POST, 1);
      curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
      $response = curl_exec($ch);
      // Once we get a response, we then parse it to extract the access token
      parse_str($response, $params);
      $token = $params['access_token'];
      return $token;
    // In the event that the two states do not match, we return false to signify
    // that something has gone wrong during authentication		
    } else {
      // CSRF protection - for more information, look at 'Security Considerations'
      // at 'https://developers.facebook.com/docs/authentication/'
      $state = md5(uniqid(rand(), TRUE));
      // Now form the login URL that you will use to authorize your app
      $authorize_url = "https://graph.facebook.com/oauth/authorize?client_id=$app_id" ."&redirect_uri=".$redirect."&state=" . $state . "&scope=$scope";
      // Now we redirect the user to the login page
      echo("<script> top.location.href='" . $authorize_url . "'</script>");
      return false;
    // Once we have that code, we can now request an access-token.  We check to
    // ensure that the state has remained the same.
    } 
  }
}
