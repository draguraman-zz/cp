package util
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.sampler.getInvocationCount;
	
	import services.RemoteCall;
	
	import social.Facebook;
	
	import user.SocialUser;
	
	public class SocialNetworkUtil
	{
		private  static var uid:String = "";
		private  static var msg:String = "";
		
		private static function getSocialNetworkUserId(id:String):String
		{
			var uid:String="";
			if(id == null) {
				return uid;
			}
			uid=id.slice(id.indexOf(':')+1);
			return uid;
		}
		
		public static function getSocialNetwork(id:String):int
		{
			var sn:int = Number(Facebook.SN_FACEBOOK);
			if(id == null)
				return sn;
			sn=parseInt(id.slice(0,id.indexOf(':')));
			return sn;
		}
		
		public static function getPictureURL(id:String):String{
			var platform:String = ConfigurationUtil.getPlatform();
			if(platform != ConfigurationUtil.PLATFORM_ANDROID && platform != ConfigurationUtil.PLATFORM_IOS) {
				var picproxy:String = ConfigurationUtil.getPictureProxy();
				if(picproxy != null)
				{					
					picproxy += "?id=" + getSocialNetworkUserId(id);
					trace('Proxied Image: '+picproxy);
					return picproxy;
				}
			}
			var url:String="https://graph.facebook.com/"+getSocialNetworkUserId(id)+"/picture?type=large";	
			trace('Image: '+url);
			return url;
		}			
	
		private static function getStatusURL(id:String, msg:String, description:String, icon:String, link:String, name:String):URLRequest
		{
			var urlR:URLRequest=null;
			var uid:String = getSocialNetworkUserId(id);
			var sn:int = getSocialNetwork(id);
			if(sn == Number(Facebook.SN_FACEBOOK)) {
				if(msg == null)
					msg="";
				
				var url:String="https://graph.facebook.com/"+uid+"/feed";
				urlR=new URLRequest(url);
				var vars:URLVariables = new URLVariables();
				vars.message=msg;
				
				if(icon != null && icon != "")
					vars.picture=icon;
				
				if(description != null && description != "")
					vars.description=description;
				
				if(name==null || name == "")
				{
					name="http://apps.facebook.com/crazypool";
				}
				if(link != null && link != "") {
					vars.link=link;
					vars.name="http://apps.facebook.com/crazypool";
				}

				var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
				var usertoken:String = suser.getSocialToken();
				vars.access_token=usertoken;
				urlR.method = URLRequestMethod.POST;
				urlR.data = vars;
			}
			return urlR;
		}
		
		public static function postStatus(msg:String, icon:String, link:String):void
		{
			var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var urlR:URLRequest = getStatusURL(suser.getId(), msg, null, icon, link, null);
			var urlLoader:URLLoader=new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onStatusPosted);
			urlLoader.load(urlR);
		}
		
		private static function onStatusPosted(e:Event):void
		{
			trace("Feed Posted: "+e.target.data);
		}
		
		public static function sendGift(uid:String, msg:String):void{
			uid = uid;
			msg = msg;
			var remote:RemoteCall = new RemoteCall(onGiftSent);
			var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var usertoken:String = suser.getSocialToken();
			remote.call("GiftService.sendGift", usertoken, suser.getId(), "1:"+uid, "strikes", 5, "");
		}
		
		private static function onGiftSent(result:Object):void
		{
			if(result == "ok")
			{
				var url1:String=String("https://graph.facebook.com/"+uid+"/feed");
				var urlR:URLRequest=new URLRequest(url1);
				
				var vars:URLVariables = new URLVariables();
				vars.message=msg;
				
				var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
				var usertoken:String = suser.getSocialToken();
				vars.access_token=usertoken;
				urlR.method = URLRequestMethod.POST;
				urlR.data = vars;
				
				var urll:URLLoader=new URLLoader();
				urll.load(urlR);
			}
		}
		
		public static function sendGameRequest(uid:String, msg:String):void{
			Billiards.sync_play=true;
		}
		
		public static function askForStrikes(msg:String):void{
			var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var userid:String = suser.getId();
			var url1:String=String("https://graph.facebook.com/"+userid.split(":")[1]+"/feed");
			var urlR:URLRequest=new URLRequest(url1);
			
			var vars:URLVariables = new URLVariables();
			vars.message=msg;
			var usertoken:String = suser.getSocialToken();
			vars.access_token=usertoken;
			urlR.method = URLRequestMethod.POST;
			urlR.data = vars;
			
			var urll:URLLoader=new URLLoader();
			urll.load(urlR);
		}
	}
}