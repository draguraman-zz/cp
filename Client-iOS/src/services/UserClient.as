package services
{
	public class UserClient
	{
		
		public static function getUser(uid:String, callback:Function = null):void
		{
			var remote:RemoteCall = new RemoteCall(callback, onError);
			remote.call("UserService.getUser", uid);	
		}
		private static function onError(object:Object):void
		{
			trace('Error UserClient call');
		}
		
	}			
}
