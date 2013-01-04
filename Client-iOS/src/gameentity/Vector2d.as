package gameentity
{
	public class Vector2d
	{
		private var x:Number;
		private var y:Number;
		
		public function Vector2d(x:Number,y:Number)
		{
			this.x=x;
			this.y=y;
		}
		
		public function getX():Number
		{
			return x; 
		}
		
		public function setX(x:Number):void
		{
			this.x=x;
		}
		public function getY():Number
		{
			return y; 
		}
		
		public function setY(y:Number):void
		{
			this.y=y;
		}
		public static function dot(v1:Vector2d, v2:Vector2d):Number
		{
			var result:Number=0;
			result=v1.x*v2.x + v1.y*v2.y;
			return result;
		}
		
		public static function getLength(v:Vector2d):Number
		{
			return(Math.sqrt(v.x*v.x + v.y*v.y));
		}
		
		public static function getDistance(v1:Vector2d,v2:Vector2d):Number
		{
			return(Math.sqrt((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y)));
		}
		
		public static function add(v1:Vector2d,v2:Vector2d):Vector2d
		{
			var result:Vector2d=new Vector2d(0,0);
			result.x=v1.x+v2.x;
			result.y=v1.y+v2.y;
			return result;
		}
		
		public static function subtract(v1:Vector2d,v2:Vector2d):Vector2d
		{
			var result:Vector2d=new Vector2d(0,0);
			result.x=v1.x-v2.x;
			result.y=v1.y-v2.y;
			return result;
		}
		
		public static function multiply(v:Vector2d,scalar:Number):Vector2d
		{
			var result:Vector2d=new Vector2d(0,0);
			result.x=v.x*scalar;
			result.y=v.y*scalar;
			return result;
		}
		
		public static function normalize(v:Vector2d):Vector2d
		{
			var len:Number=getLength(v);
			if(len != 0)
			{
				v.x=v.x/len;
				v.y=v.y/len;
			}
			else
			{
				v.x=0;
				v.y=0;
			}
			return v;
		}
	}
}