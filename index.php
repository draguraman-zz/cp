<?php
define( 'LIBPATH', dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Lib' );
define( 'CONFIG', LIBPATH  . DIRECTORY_SEPARATOR . 'Config' . DIRECTORY_SEPARATOR . 'config.php');
define( 'SERVICESPATH', dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Services' );
require_once(CONFIG);
require_once(SERVICESPATH . DIRECTORY_SEPARATOR . 'StorageService.php');
?>
<?php
$facebook = new Facebook(array(
  'appId'  => AppInfo::appID(),
  'secret' => AppInfo::appSecret(),
));

$user_id = $facebook->getUser();
if(!$user_id) {
	FBUtils::login(AppInfo::getHome());
	exit();
} else {
  try {
    // Fetch the viewer's basic information
    $basic = $facebook->api('/me');
    $user_name = idx($basic, 'name', 'Anonymous');
  } catch (FacebookApiException $e) {
    FBUtils::login(AppInfo::getHome());
    exit();
  }
  $access_token = $facebook->getAccessToken();
}

// Fetch the basic info of the app that they are using
$app_info = $facebook->api('/'. AppInfo::appID());
$app_name = idx($app_info, 'name', '');
?>

<!-- This following code is responsible for rendering the HTML   -->
<!-- content on the page.  Here we use the information generated -->
<!-- in the above requests to display content that is personal   -->
<!-- to whomever views the page.  You would rewrite this content -->
<!-- with your own HTML content.  Be sure that you sanitize any  -->
<!-- content that you will be displaying to the user.  idx() by  -->
<!-- default will remove any html tags from the value being      -->
<!-- and echoEntity() will echo the sanitized content.  Both of  -->
<!-- these functions are located and documented in 'utils.php'.  -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">

    <!-- We get the name of the app out of the information fetched -->
    <title><?php echo($app_name); ?></title>
    <link rel="stylesheet" href="<?php echo($styleURL); ?>/screen.css" media="screen">

    <!-- These are Open Graph tags.  They add meta data to your  -->
    <!-- site that facebook uses when your content is shared     -->
    <!-- over facebook.  You should fill these tags in with      -->
    <!-- your data.  To learn more about Open Graph, visit       -->
    <!-- 'https://developers.facebook.com/docs/opengraph/'       -->
    <meta property="og:title" content=""/>
    <meta property="og:type" content=""/>
    <meta property="og:url" content=""/>
    <meta property="og:image" content=""/>
    <meta property="og:site_name" content=""/>
    <script type="text/javascript" src="<?php echo($scriptsURL); ?>/swfobject.min.js"></script>
    <script type="text/javascript" src="<?php echo($scriptsURL); ?>/flashvars_js.js"></script>
    <script type="text/javascript" src="<?php echo($scriptsURL); ?>/WebSocketClient.js"></script>
    <script type="text/javascript" src="<?php echo($scriptsURL); ?>/FlashWebSocketClient.js"></script>
    <?php echo('<meta property="fb:app_id" content="' . AppInfo::appID() . '" />'); ?>
    <script>
      <?php  $w = 640; $h= 480; ?>
      function popup(pageURL, title,w,h) {
        var left = (screen.width/2)-(w/2);
        var top = (screen.height/2)-(h/2);
        var targetWin = window.open(
          pageURL,
          title,
          'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left
          );
      }
      var flashvars = {};
		flashvars.gateway = "<?php echo($gatewayURL); ?>";
		flashvars.picproxy = "<?php echo($picproxyURL); ?>";
		flashvars.usertoken = "<?php echo($access_token); ?>";
		flashvars.user = "<?php echo("1:".$user_id); ?>";
		flashvars.username = "<?php echo($user_name); ?>";
		flashvars.imagepath = "<?php echo $imagesURL; ?>";
                flashvars.points = "<?php echo StorageService::loadPlayerState("1:".$my_id); ?>";
		
      var params = {};
		params.menu = "false";
		params.scale = "noscale";
		params.SCALE = params.scale;
        	params.allowFullScreen = "true",
        	params.allowScriptAccess = "always",
        	params.wmode = "direct";
		params.bgcolor = "#000000";

      var attributes = {};
		attributes.id = "flashcontent";
		attributes.name = "flashcontent";

      swfobject.embedSWF("<?php echo($clientURL); ?>?rand=<?php echo rand(); ?>", "content", "1080", "707", "10.0.0","<?php echo ($expressclientURL); ?>", flashvars, params, attributes);	  
      
    </script>
    <!--[if IE]>
      <script>
        var tags = ['header', 'section'];
        while(tags.length)
          document.createElement(tags.pop());
      </script>
    <![endif]-->
  </head>
  <body style="width:100%; height:100%; margin:0px; padding:0px; background-color:#000000; text-align:center; color: #ffffff; font-family:sans-serif; overflow:hidden; vertical-align:middle">
	<div id="fb-root"></div>
        <!-- <section id="game" class="clearfix"> -->
        <div id="content">
                 <span class="loadingGame">Loading Game...</span>
                 <br/>
                 <span class="upgradeFlash">
		You may need to install or upgrade <b>Flash</b>. &nbsp;&nbsp;&nbsp;&nbsp;
		 <a target="_new" href="http://www.adobe.com/support/flashplayer/downloads.html"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Install Adobe Flash Player!"/></a><br/>
		</span>
        </div>
        <!-- </section> -->
  </body>
</html>
