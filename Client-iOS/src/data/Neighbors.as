package data
{
	import services.RemoteCall;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;

	public class Neighbors
	{
		private static var instance:Neighbors;
		private static var neighborcache:Object = null;

		function Neighbors()
		{	
		}
		
		public static function getInstance():Neighbors
		{
			if(instance == null)
				instance = new Neighbors();
			return instance;
		}
		
		public function getNeighbors(callback:Function):void{
			if(neighborcache)
				if(callback != null) {
					callback(neighborcache);
					return;
				}			
			var remote:RemoteCall = new RemoteCall(
				function(data:Object): void {
					neighborcache = data;
					if(callback != null)
						callback(neighborcache);
				}
			);
			var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();			
			remote.call("NeighborService.getNeighbors",suser.getSocialToken(), suser.getId());
		}
						
	}
}