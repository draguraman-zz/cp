package 
{
	import services.UserClient;
	public class User
	{
		protected var initialized:Boolean = false;
		protected var user:String;
		protected var token:String;
		public function User(userid:String)
		{
			if(userid)
			{
				if(isPlaying()) {
					var createdUser:Function = function(data:Object = null):void {
						UserClient.getUser(userid, doUnserialize);         
					}
					//UserClient.createUser(userid, createdUser);
				}
			}
		}
		
		public function isPlaying(id:String = null): Boolean
		{
			return false;			
		}
		
		public function getId(id:String = null):String
		{
			return null;
		}
		
		private function doUnserialize(newdata:Object = null):void
		{
			if(newdata == null)
				return;
			if(newdata is String)
				return;
			if(newdata is Boolean)
				return;
			
			var i:String;
			initialized = true;
		}
		
		public function isInitialized():Boolean
		{
			return initialized;
		}
		
	}
}
