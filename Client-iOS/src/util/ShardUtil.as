package util
{
	


	public class ShardUtil
	{
		private static var servers:Array = [
			"ws://ttable001.jit.su/websocket"
		];
		
		private static var cdservers:Array = [
			"http://ttable001.jit.su/crossdomain.xml"
		];

		
		private static function getHash(id:String = null):int {
			var hash:int = 0;
			if(id == null)
				return hash;
			if(!servers || servers.length <= 0)
				return hash;
			hash = new CRC32().crc32(id);
			if(hash < 0)
				hash = -hash;
			hash = hash % servers.length;
			return hash;
		}
		
		public static function getServer(id:String=null):String {
				return servers[getHash(id)];
		}
		
		public static function getCrossdomain(id:String=null):String {
			return cdservers[getHash(id)];
		}

	}
	

}