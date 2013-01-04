package social
{
	
	import game.GameEvent;
	
	import user.FacebookUser;
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	import flash.system.Security;
	
	public class Facebook extends SocialNetwork
	{
		public static var SN_FACEBOOK:String = "1";
		public static var SN_PREFIX:String = SN_FACEBOOK+":"; 
		protected static var FACEBOOK_APP_ID:String = "292316880795142";
		protected static var FACEBOOK_APP_SECRET:String = "c6720deb3911443e996a9aa738b00f21";
		protected static var FACEBOOK_PERMISSIONS:String = "user_likes,user_photos,user_videos,publish_stream";
		protected static var FACEBOOK_PERMISSIONS_ARRAY:Array = ["user_likes","user_photos","user_videos","publish_stream"];
		protected static var n_user:SocialUser = null;
		protected static var usertoken:String;
		
		public function Facebook():void
		{
		}
		
		public override function login():void
		{
			var parameters:* = ConfigurationUtil.getParameters();
			if(parameters) {
				var userid:String = null;
				if(parameters.user)
					userid = parameters.user;
				var username:String = null;
				if(parameters.username)
					username = parameters.username;
				var usertoken:String = getCurrentToken();
				onLoggedIn(userid, username, usertoken, true);
			} else {
				var errorMsg:String = "No Parameters!";
			}
		}
		
		public override function logout():void
		{
			onLoggedOut();
		}
		
		protected function onLoggedIn(userid:String,username:String,usertoken:String = null,playing:Boolean = false):void
		{
			if(n_user != null)
				return;
			if(usertoken == null)
				usertoken = getCurrentToken();
			if(usertoken != null && userid != null && username != null) {
				n_user = createUser(userid, username, usertoken, true);
				// also get the user details from the game
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_LOGGED_IN));
			} else {
				var errorMsg:String = "Unknown Error!";
				if(usertoken == null)
					errorMsg = "No User Token!";
				else if(username == null) 
					errorMsg = "No User Name!";
				else if(userid == null)
					errorMsg = "No User ID!";
			}
		}
		
		protected function onLoggedOut():void
		{
			n_user = null;
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_LOGGED_OUT));
		}
		
		public override function createUser(... arguments:Array):SocialUser{
			var userid:String = null;
			var usertoken:String = null;
			var username:String = null;
			var playing:Boolean = false;
			if(arguments.length >= 1) {
				userid = arguments[0];
				if(userid.indexOf(SN_PREFIX) == -1)
					userid = SN_PREFIX + userid;
				if(arguments.length >= 2) {
					username = arguments[1];
					if(arguments.length >= 3) {
						if(arguments[2] is Boolean) {
							playing = arguments[2];
						} else {
							usertoken = arguments[2];
						}
						if(arguments.length >= 4) {
							if(arguments[3] is Boolean) {
								playing = arguments[3];
							} else {
								usertoken = arguments[3];
							}
						}
					}
				}
			}
			if(userid == null)
				return null;
			if(usertoken == null)
				usertoken = getCurrentToken();
			return new FacebookUser(userid, username, usertoken, playing);
		}
		
		public override function getCurrentUser():SocialUser{
			return n_user;
		}
		
		public static function getCurrentToken():String
		{
			if(usertoken)
				return usertoken;
			var parameters:* = ConfigurationUtil.getParameters();
			if(parameters && parameters.usertoken)
				usertoken = parameters.usertoken;
			return usertoken;
		}
		
		public override function getSocialNetworkId(id:String = null):String
		{
			var sn:String = SN_FACEBOOK;
			if(id == null)
				return sn;
			sn=id.slice(0,id.indexOf(':'));
			return sn;
		}
		
	}
}
