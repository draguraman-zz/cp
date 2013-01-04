package user
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import social.Facebook;
	
	public class FacebookUser extends SocialUser
	{
		protected var usertoken:String;
		protected var userid:String;
		protected var username:String;
		protected var playing:Boolean;
		
		public function FacebookUser(userid:String, username:String = null, usertoken:String = null, playing:Boolean = true)
		{
			this.userid = userid;
			this.username = username;
			this.usertoken = usertoken;
			this.playing = playing;
			
			super(userid);
			
			getSNData();
		}
		
		public override function isPlaying(id:String = null):Boolean{
			return playing;
		}
		
		public override function getId(id:String = null):String
		{
			if(id == null)
				return userid;
			return id;
		}
		
		public override function getIdWithoutPrefix(id:String = null):String
		{
			if(id == null)
				return getSocialNetworkUserId(userid);
			return getSocialNetworkUserId(id);
		}
		
		public override function getUserName(id:String = null):String
		{
			return username;
		}
		
		private function getSocialNetworkUserId(id:String):String
		{
			if(id == null)
				return null;
			var uid:String=id.slice(id.indexOf(':')+1);
			return uid;
		}
		
		public override function getSocialToken():String
		{
			return usertoken;
		}
		
		private function getStatusURLRequest(id:String, msg:String, description:String, icon:String, link:String, name:String):URLRequest
		{
			var urlR:URLRequest=null;
			var uid:String = getSocialNetworkUserId(id);
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
				name="http://apps.facebook.com/";
			}
			if(link != null && link != "") {
				vars.link=link;
				vars.name=name;
			}
			
			vars.access_token=usertoken;
			urlR.method = URLRequestMethod.POST;
			urlR.data = vars;
			return urlR;
		}
		
		public override function postStatus(msg:String, icon:String, link:String, to:String = null):void
		{
			if(to == null)
				to = getId();
			if(!to)
				return;
			var urlR:URLRequest = getStatusURLRequest(to, msg, null, icon, link, null);
			var urlLoader:URLLoader=new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onStatusPosted);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError );
			urlLoader.load(urlR);
		}
		
		private function getSNDataURLRequest(id:String ):URLRequest
		{
			var urlR:URLRequest=null;
			var uid:String = getSocialNetworkUserId(id);
			
			var url:String="https://graph.facebook.com/"+uid+"";
			urlR=new URLRequest(url);
			var vars:URLVariables = new URLVariables();
			
			vars.access_token=usertoken;
			return urlR;
		}
		
		protected function getSNData():void
		{
			if(this.username == null) {
				this.username = "User";
			}
			if(this.usertoken == null) {
				this.usertoken = Facebook.getCurrentToken();
			}
			if(this.username == "User") {
				var urlR:URLRequest = getSNDataURLRequest(this.userid);
				var urlLoader:URLLoader=new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onDataLoaded);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError );
				urlLoader.load(urlR);	
			}
		}
		
		private function onError(e:Event):void
		{
			trace('Error happened in Call.');
		}
		
		private function onStatusPosted(e:Event):void
		{
			trace("Feed Posted: "+e.target.data);
		}
		
		private function onDataLoaded(e:Event):void
		{
			var newdata:Object = JSON.parse(e.target.data);
			this.username = newdata.first_name;
		}
		
		public override function toString():String
		{
			var retStr:String = super.toString();
			retStr += "Token: "+usertoken+"\n";
			return retStr;
		}
		
	}
}