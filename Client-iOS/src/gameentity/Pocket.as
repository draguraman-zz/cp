package gameentity{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Pocket extends Sprite {
		public var pradius:Number=0.030;
		public var pointX:Number,pointY:Number;
		public var scaleRect:Rectangle;
		public var offsetPoint:Point;		

		//private var rad=Billiards_Mobile.STAGE_WIDTH/35;
		public function Pocket(offset:Point, scale:Rectangle) {
			offsetPoint = offset;
			scaleRect = scale;
			init();
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
		
		public function init():void {
			if(false)
			{
				var radius:Number = pradius*scaleRect.width;
				var color:uint=0xFFFFFF; //666666;
				var depthcolor:uint=0x333333;
				graphics.lineStyle(1);
				graphics.beginFill(color);
				graphics.drawCircle(0, 0, radius);
				graphics.beginFill(depthcolor);
				graphics.drawCircle(0, 0, (4*radius)/5);
				graphics.endFill();
			}
		}

	}
	
}
