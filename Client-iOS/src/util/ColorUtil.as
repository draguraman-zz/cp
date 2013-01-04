package util
{
	public class ColorUtil
	{
		public static function makeColor(r:int=0, g:int=0, b:int=0, a:int=255): int
		{
			var value: int;
			value = (r*65536) + (g*256) + b;
			return value;			
		}
	}
}