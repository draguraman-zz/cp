package user
{
	import flash.events.Event;
	
	import social.AnonNetwork;
	public class AnonUser extends SocialUser
	{
		protected var usertoken:String;
		protected var userid:String;
		protected var username:String;
		protected var playing:Boolean;
		
		public function AnonUser(userid:String, username:String = null, usertoken:String = null, playing:Boolean = true)
		{
			this.userid = userid;
			this.username = username;
			this.usertoken = userid;
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
	
	
			
		protected function getSNData():void
		{
			if(this.username == null) {
				this.username = ("Guest_"+Math.floor(Math.random()*188));
			}
			if(this.usertoken == null) {
				this.usertoken = AnonNetwork.getCurrentToken();
			}
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