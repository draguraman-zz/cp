
package social
{
	import com.hurlant.crypto.hash.SHA1; 
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.*;
	
	import com.adobe.nativeExtensions.Networkinfo.InterfaceAddress;
	import com.adobe.nativeExtensions.Networkinfo.NetworkInfo;
	import com.adobe.nativeExtensions.Networkinfo.NetworkInterface;
	
	import game.GameEvent;
	
	import user.AnonUser;
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	
	public class AnonNetwork extends SocialNetwork
	{	public static var hardware_id:*;
		public static var SN_ANONNETWORK:String = "24";
		public static var SN_PREFIX:String = SN_ANONNETWORK+":"; 
		/*	protected static var ANON_APP_ID:String = "292316880795142";
		protected static var ANON_APP_SECRET:String = "c6720deb3911443e996a9aa738b00f21";
		protected static var ANON_PERMISSIONS:String = "user_likes,user_photos,user_videos,publish_stream";
		protected static var ANON_PERMISSIONS_ARRAY:Array = ["user_likes","user_photos","user_videos","publish_stream"]; */
		protected static var n_user:SocialUser = null;
		protected static var usertoken:String;
		
		
		public function AnonNetwork():void
		{
			
		}
		public override function login():void
		{
			hardware_id=getUniqueDeviceIdentifier();
//			var sha1id:*=SHA1(String(hardware_id));
			var userid:* = SHA1(String(hardware_id) );
			
			trace(userid);
			onLoggedIn(userid,"Guest", userid, true);
			
		}
		protected function getUniqueDeviceIdentifier():*
		{
			
			
			/*	if (NetworkInfo.isSupported) {
			
			trace("network information is supported");
			
			}
			
			var network:NetworkInfo = NetworkInfo.networkInfo;
			
			for each (var object:NetworkInterface in network.findInterfaces()) {
			
			if (object.hardwareAddress) {
			
			var id:*=object.hardwareAddress;
			} */
			
			
			var vNetworkInterfaces:Object;
			if (flash.net.NetworkInfo.isSupported) // This check could be improved, as maybe there are OSes other than iOS that don't support native NetworkInfo
			{
				trace('Getting MAC from NetworkInfo (AIR)');
				vNetworkInterfaces = getDefinitionByName('flash.net.NetworkInfo')['networkInfo']['findInterfaces']();
			}
				
			else
			{
				trace('Getting MAC from NetworkInfo (ANE)');
				vNetworkInterfaces = getDefinitionByName('com.adobe.nativeExtensions.Networkinfo.NetworkInfo')['networkInfo']['findInterfaces']();
			}
			
			
			for each (var networkInterface:Object in vNetworkInterfaces)
			
			if ( networkInterface.hardwareAddress) {
				
				var id:*=networkInterface.hardwareAddress;
			}
			return id;	
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
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_LOGGED_IN_ANON));
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
		var playing:Boolean =true;
		
		
		userid = String(SHA1(hardware_id) );
		username="John Doe";
		usertoken=userid;
		return new AnonUser(userid, username, userid, playing);
	}
	
	
	public override function getCurrentUser():SocialUser{
		return n_user;
	}
	
	public static function getCurrentToken():String
	{
		usertoken=String(SHA1(hardware_id) );
		return usertoken;
	}
	
	public override function getSocialNetworkId(id:String = null):String
	{
		var sn:String = SN_ANONNETWORK;
		
		return sn;
	}
	
}
}