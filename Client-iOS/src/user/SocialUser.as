package user
{
	public class SocialUser extends User
	{
		public var neighbors:Array = new Array();
		public function SocialUser(userid:String)
		{
			super(userid);
		}
		
		public override function getId(id:String = null):String
		{
			return null;
		}
		
		public function getIdWithoutPrefix(id:String = null):String
		{
			return getId(id);
		}
		
		public function getUserName(id:String = null):String
		{
			return null;
		}
		
		public function getSocialToken():String
		{
			return null;
		}
		
		public function postStatus(msg:String, icon:String, link:String, to:String = null):void
		{
			return;
		}
		
		public function getNeighbors(id: String = null, callback:Function = null):void
		{
			return;
		}
		
		public function toString():String {
			var retStr:String = "";
			retStr += "ID: "+getId()+"\n";
			retStr += "Name: "+getUserName()+"\n";
			return retStr;
		}
		
	}
}