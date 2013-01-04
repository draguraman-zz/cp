package gameentity{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Collision {
		public static const bounce:Number = -0.9; // used in wall collision
		public static const timeStep:Number = 0.1//0.15 ;
		public static const friction:Number = 0.1;//0.12;

		// handles collisions between balls
		// taken from AS3 textbook
		public static function BallCollision(ball0:Ball, ball1:Ball):void
		{
			
			var pdx:Number = ball1.px - ball0.px;
			var pdy:Number = ball1.py - ball0.py;
			
			var dist:Number = Math.sqrt(pdx*pdx + pdy*pdy);
			var contact:Vector2d=new Vector2d(0,0);
			var normal:Vector2d=new Vector2d(0,0);
			
			var pvel0:Vector2d=new Vector2d(0,0);
			var pvel1:Vector2d=new Vector2d(0,0);
			
			var position0:Vector2d=new Vector2d(0,0);
			var position1:Vector2d=new Vector2d(0,0);
			var relNVelocity:Number;
			var remove:Number;
			var impulse: Number;
			var newImpulse:Number;
			var con_impulse:Number=0;
			var change:Number;
			
			if(dist <= (ball0.pradius + ball1.pradius))
			{
				pvel0.setX(ball0.vx);//p suffix is for actual coordinates
				pvel0.setY(ball0.vy);
				pvel1.setX(ball1.vx);
				pvel1.setY(ball1.vy);
				
				contact.setX(pdx/2);
				contact.setY(pdy/2);
				normal.setX(pdx/dist);
				normal.setY(pdy/dist);
				relNVelocity=Vector2d.dot(normal,Vector2d.subtract(pvel1,pvel0));
				remove=relNVelocity +(dist-2*ball0.pradius)/timeStep;
				
				if(remove < 0)// && (dist-ball0.radius) < 0 )
				{
					var channelhit:SoundChannel= new SoundChannel();
					var someTransformHit:SoundTransform = new SoundTransform(0.5);
					var hitSound:Sound=new EmbeddedAssets.HitSound as Sound;
					channelhit = hitSound.play(0, 0, someTransformHit);
					
					impulse=remove/(1/ball0.mass+1/ball1.mass);
					
					newImpulse=Math.min(impulse-con_impulse,0);
					change=newImpulse+con_impulse;
					con_impulse=newImpulse;
					
					//pvel0 = Vector2d.add(pvel0,Vector2d.multiply(normal,(impulse/ball0.mass)));
					//pvel1 = Vector2d.subtract(pvel1,Vector2d.multiply(normal,(impulse/ball1.mass)));
					pvel0 = Vector2d.add(pvel0,Vector2d.multiply(normal,(change/ball0.mass)));
					pvel1 = Vector2d.subtract(pvel1,Vector2d.multiply(normal,(change/ball1.mass)));
					ball0.vx=pvel0.getX();
					ball0.vy=pvel0.getY();
					ball1.vx=pvel1.getX();
					ball1.vy=pvel1.getY();
					
					
				}
			}
		}
		
		// handles wall collisions
		// taken from AS3 textbook
		public static function checkWalls(ball:Ball):void
		{	
			var pRect:Rectangle=new Rectangle(0, 0, 1, 1);
			if(ball.px + ball.pradius > pRect.right)
			{
				
				ball.px = pRect.right - ball.pradius;
				ball.vx *= bounce;
			}
			else if(ball.px - ball.pradius < pRect.left)
			{
				ball.px = pRect.left + ball.pradius;
				ball.vx *= bounce;
			}
			if(ball.py + ball.pradius >pRect.bottom)
			{
				ball.py = pRect.bottom - ball.pradius;
				ball.vy *= bounce;
			}
			else if(ball.py - ball.pradius <pRect.top)
			{
				ball.py = pRect.top + ball.pradius;
				ball.vy *= bounce;
			}
		}

		
		public static function checkPocketCollisions(balls:Array, cueBall:CueBall, pockets:Array, t:*):void {
			for(var ballNum:int = 0; ballNum < balls.length; ++ballNum) {
				for (var pocketNum:int = 0; pocketNum < pockets.length; ++pocketNum) {
					var ball:Ball = balls[ballNum];
					var pocket:Pocket = pockets[pocketNum];
					
					var pdx:Number = pocket.px - ball.px;
					var pdy:Number = pocket.py - ball.py;					
					var pdistance:Number = Math.sqrt(pdx *pdx +pdy *pdy);
					var parent:MovieClip;
					
					if (pdistance < (ball.pradius + pocket.pradius)) {
						var channelPocket:SoundChannel= new SoundChannel();
						var someTransformPocket:SoundTransform = new SoundTransform(0.5);
						var pocketSound:Sound=new EmbeddedAssets.Pot as Sound;
						channelPocket = pocketSound.play(0, 0, someTransformPocket);
						if (ball == cueBall) {
							cueBall.disappear();							
							cueBall.reappear();
						}
						else {
							t.updateScore(ball.mapNum, pockets[pocketNum]);
							ball.parent.removeChild(ball);
							balls.splice(ballNum, 1); // delete ball from array
							--ballNum; // move index back to account for lost element
						}
					}
				}
			}
		}	
	}
}