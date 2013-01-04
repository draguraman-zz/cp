package gameentity
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import game.Game;
	
	public class Stick extends Sprite		
	{
		private var table_width:Number;
		public var st:*;
		public var child:*;
		public function Stick(width:Number)
		{
			table_width=width;
			init();
		}
		
		public function init():void {
			addChild(new EmbeddedAssets.Stick);
			st=new EmbeddedAssets.StickGr;
			addChild(st);
			
			//Add Separator Lines
			child= new Shape();
			child.graphics.lineStyle(5, 0xFFFFFF);
			child.graphics.moveTo(0, 0);
			//child.graphics.lineTo(table_width*0.72,0);
			child.alpha=0.3;
			addChild(child);
		}
		
		public function onUpdate(mX:Number,mY:Number,targetX:Number,targetY:Number):void
		{
			var angle:Number;
			angle=Math.atan2(targetY-mY,targetX-mX);
			x=targetX-Game.cueRadius*Math.cos(angle);
			y=targetY-Game.cueRadius*Math.sin(angle);
			angle*=180/Math.PI;
			rotation=angle;
		}
	}
}