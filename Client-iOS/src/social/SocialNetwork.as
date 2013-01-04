package social
{
	import user.SocialUser;

	public class SocialNetwork
	{
		public static var SN_FACEBOOK:int = 1; 
		public static var ANON_FACEBOOK:int = 24; 
		
		public function SocialNetwork():void
		{
			
		}		
		
		public function login():void
		{
			return;	
		}
		
		public function logout():void
		{
			return;	
		}
		
		public function createUser(... arguments:Array):SocialUser{
			return null;
		}
		
		public function getCurrentUser():SocialUser{
			return null;
		}
		
		public function getSocialNetworkId(id:String = null):String
		{
			return null;
		}
	}
}                                       