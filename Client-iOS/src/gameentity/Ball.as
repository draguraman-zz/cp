package gameentity{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	public class Ball extends Sprite {
		public var ballNo:Number;
		protected var color:uint;
		public var mass:Number = 1;
		public var team:Number = 0;
		public var mapNum : Number;
		public var pointX:Number;
		public var pointY:Number;
		public var vx:Number = 0;
		public var vy:Number = 0;
		public var pradius:Number = 0.016;
		public static var defaultcolor:uint = 0xFFFFCC;		
		public var scaleRect:Rectangle;
		public var offsetPoint:Point;		
		
		public function Ball(ballNo:int, offset:Point, scale:Rectangle) {	
			offsetPoint = offset;
			scaleRect = scale;
			if(ballNo >= 8) {
				team = 1;
			}			
			init(ballNo);
			if(ballNo >= 8) {
				ballNo -= 8;
			}
			this.ballNo = ballNo;
		}
		
		public function calculatePosition():void {
			this.x = px*scaleRect.width + offsetPoint.x;
			this.y = py*scaleRect.height + offsetPoint.y;
		}
		
		public function set px(value:Number):void {
			pointX = value;
			calculatePosition();
		}
		
		public function set py(value:Number):void {
			pointY = value;
			calculatePosition();
		}
		
		public function get px():Number {
			return pointX;
		}

		public function get py():Number {
			return pointY;
		}
		
		public function init(num:Number):void {
			var child:DisplayObject;
			if(num == -1)
				pradius = 0.017;
			if(false)
			{
				var radius = pradius*scaleRect.width;
				var color:uint=0xFF0000; //666666;
				graphics.lineStyle(1);
				graphics.beginFill(color);
				graphics.drawCircle(0, 0, radius);
				graphics.endFill();
			}
			if(num == -1) {
				child=new EmbeddedAssets.CueBall;
				addChild(child);
			} else {
				mapNum = num+1;
				var classObj: Class = getDefinitionByName("EmbeddedAssets_ball"+mapNum) as Class;
				child = new classObj;
				addChild(child);
			} 
		}

	}
}