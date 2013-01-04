package gameentity
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import game.Game;
	import game.GameEvent;
	
	import services.RemoteCall;
	
	import social.SocialNetwork;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;

	public class GameState
	{
		protected var m_balls:Array;
		protected var m_pockets:Array;
		protected var m_cueBall:CueBall;
		protected var m_stick:Stick;
		protected var m_tableBounds:Rectangle;		
		protected var m_Hit:Boolean;
		
		protected static var rectPos:Point;
		protected static var width:Number;
		protected static var height:Number;
		
		public var scores:Number=0;
		public var strikes:Number=60;
		public var dataLoaded:Boolean=false;
		public var pRect:Rectangle;
		
		public function GameState(boardwidth:Number,boardheight:Number)
		{
			width=boardwidth*0.88; //these are the parameter sizes of the green portion
			height=boardheight*0.83;
			rectPos = new Point(boardheight/12, boardheight/11);
			reset();
		}		
		
		public function getPoint():Point{
			return rectPos;
		}

		public function getBounds():Rectangle{
			return m_tableBounds;
		}
		
		public function set_score(num:Number, str:Number):void{
			if(num > 0)
			{
				scores=num;
			}
			strikes = str;
		}
		
		public function reset():void {						
			make_table();			
			make_stick();
			make_balls();
			make_pockets();
		}

		private function make_table():void {			
			m_tableBounds = new Rectangle(rectPos.x, rectPos.y, width, height);
		}
		
		private function make_stick():void{
			m_stick = new Stick(width);
			m_Hit = false;
		}
		
		public function make_balls():void {
			// check if m_balls exist, if so, clear them out
			if (m_balls != null) {
				for(var i:int = 0; i < m_balls.length; i++) {
					m_balls.splice(i, 1);
					
				}
			}
			
			// create array for m_balls
			m_balls = new Array();
			pRect=new Rectangle(0, 0, 1, 1);
			
			// create Drawing regular m_balls
			var centerX:Number = 0.5;
			var centerY:Number = 0.5;
			
			// create cue ball, add to ball array
			m_cueBall = new CueBall(m_stick, getPoint(), getBounds());
			m_cueBall.addChild(new EmbeddedAssets.CueBall);
			m_cueBall.resetPosition();
			m_balls.push(m_cueBall);			
			
			var remapAdd:Array = new Array();
			remapAdd[0]=12;		
			remapAdd[1]=9;
			remapAdd[2]=2;
			remapAdd[3]=1;
			remapAdd[4]=11;
			remapAdd[5]=14;
			remapAdd[6]=8;
			remapAdd[7]=10;
			remapAdd[8]=0;
			remapAdd[9]=13;
			remapAdd[10]=4;
			remapAdd[11]=3;
			remapAdd[12]=6;
			remapAdd[13]=7;
			remapAdd[14]=5;
			
			centerX += 5 * m_cueBall.pradius;
			
			var ballNo:Number = 0;
			for(var col:Number = 0; col < 5; ++col) {
				for (var row:Number = 0; row < col + 1; ++row) {
					var ball:Ball = new Ball(remapAdd[ballNo++], getPoint(), getBounds());
					ball.px = centerX + (col * 2 *ball.pradius);//1.5
					ball.py = centerY + (row * 3 *ball.pradius) - (col * ball.pradius);//2.5
					m_balls.push(ball);
				}
			}
		}
				
		private function make_pockets():void {
			// create m_pockets
			m_pockets = new Array();
			var topLeftPocket:Pocket = new Pocket(getPoint(), getBounds());
			topLeftPocket.px = -m_cueBall.pradius*0.15;
			topLeftPocket.py = m_cueBall.pradius*0.15;			
			m_pockets.push(topLeftPocket);
			
			var topMiddlePocket:Pocket = new Pocket(getPoint(), getBounds());
			topMiddlePocket.px = 0.5 - m_cueBall.pradius*0.2;
			topMiddlePocket.py = -m_cueBall.pradius ;			
			m_pockets.push(topMiddlePocket);
			
			var topRightPocket:Pocket = new Pocket(getPoint(), getBounds());
			topRightPocket.px = 1.0 - m_cueBall.pradius*0.5;
			topRightPocket.py = m_cueBall.pradius*0.15;			
			m_pockets.push(topRightPocket);
			
			var bottomLeftPocket:Pocket = new Pocket(getPoint(), getBounds());
			bottomLeftPocket.px = -m_cueBall.pradius*0.15;
			bottomLeftPocket.py = 1.0 - m_cueBall.pradius*0.15;
			m_pockets.push(bottomLeftPocket);
			
			var bottomMiddlePocket:Pocket = new Pocket(getPoint(), getBounds());
			bottomMiddlePocket.px = 0.5 - m_cueBall.pradius*0.2;
			bottomMiddlePocket.py = 1.0 + m_cueBall.pradius;
			m_pockets.push(bottomMiddlePocket);
			
			var bottomRightPocket:Pocket = new Pocket(getPoint(), getBounds());
			bottomRightPocket.px = 1.0 - m_cueBall.pradius*0.5;
			bottomRightPocket.py = 1.0 - m_cueBall.pradius*0.15;
			m_pockets.push(bottomRightPocket);
			
		}
		
		public function get cueBall():Object
		{
			return m_cueBall;	
		}
		
		public function get balls():Array
		{
			return m_balls;	
		}
		
		public function get pockets():Array
		{
			return m_pockets;	
		}
		
		public function get stick():Object
		{
			return m_stick;	
		}
		
		
		public function persist(isReset:Boolean = false):void
		{

			if(isReset)
			{
				persistPlayerImpl();
			}			
			
			else
			{	
				var variables:Object = new Object();
				var i:int;
				for(i = 0; i < m_balls.length; i++)
				{
					var ball:Ball = m_balls[i] as Ball;
					if(ball.visible) {
						variables["ball_"+i+"_x"] = ball.px;
						variables["ball_"+i+"_y"] = ball.py;
						variables["ball_"+i+"_vx"] = ball.vx;
						variables["ball_"+i+"_vy"] = ball.vy;
					}
				}
				variables["strikes"] = strikes;
				variables["scores"] = scores;
				persistImpl(variables);
			}
			
		}
		
		protected function persistPlayerImpl():void {
			var points:Number;
			points = scores + ConfigurationUtil.points;
			var snetwork:SocialNetwork = ConfigurationUtil.getSocialNetwork();
			var suser:SocialUser = snetwork.getCurrentUser();
			var remote:RemoteCall = new RemoteCall(this.onPersisted);
			remote.call("StorageService.persistPlayerState",suser.getId(), points);			
		}
		
		protected function persistImpl(variables:Object):void {
			var snetwork:SocialNetwork = ConfigurationUtil.getSocialNetwork();
			var suser:SocialUser = snetwork.getCurrentUser();
			var remote:RemoteCall = new RemoteCall(this.onPersisted);
			remote.call("StorageService.persistGameState", suser.getSocialToken(), suser.getId(), variables);			
		}

		
		private function onPersisted(result:Object):void
		{
			var text:String = result as String;
			if(text == "ok") {
				//Okay, We've Persisted
			} 		
		}
		
		public function load():void
		{
			
			var snetwork:SocialNetwork = ConfigurationUtil.getSocialNetwork();
			var suser:SocialUser = snetwork.getCurrentUser();
			
			var remote:RemoteCall = new RemoteCall(this.onLoaded); 
			var social_token:String = null;
			remote.call("StorageService.loadGameState", suser.getSocialToken(), suser.getId());
			
			var remo:RemoteCall=new RemoteCall(this.playerLoaded);
			remo.call("StorageService.loadPlayerState",suser.getId());
		}
		
		public function loadExternal(variables:Object):void {
			onLoaded(variables);
		}
		
		private function playerLoaded(result:Object):void
		{
			if(result == "false" || result == false) {
				result = 100;
				persist();
				ConfigurationUtil.points=Number(result);
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_GAME_START));
			} else {
				ConfigurationUtil.points=Number(result);
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_GAME_START));
			}
			
		}
		
		protected function onLoaded(result:Object):void
		{
			if(result == "false" || result == false) {
				persist();
			} else {
					if(result.strikes) { strikes=Number(result.strikes); }
					else{strikes=60;}
					if(result.scores) { scores=Number(result.scores); }
					else{ scores=0; }
					//GOD Mode XXX PleaseFix
					strikes=60;

					var seen:int = 0;
					for(var l:Number=0;l<=15;l++)
					{
						var key:String = "ball_"+l;
						var xkey:String = key+"_x";
						var ykey:String = key+"_y";
						var vxkey:String = key+"_vx";
						var vykey:String = key+"_vy";
						if(result[xkey]) {
							m_balls[l].px = result[xkey];
							m_balls[l].py = result[ykey];
							m_balls[l].vx = result[vxkey];
							m_balls[l].vy = result[vykey];
							if(m_balls[l] != cueBall)
								++seen;
						}
					}
					if(seen == 0) {
						reset();
						dataLoaded=true;
						return;
					} else {
						for(l=0;l<=15;l++)
						{
							key = "ball_"+l;
							xkey = key+"_x";
							if(!result[xkey]) {
								if(m_balls[l] != cueBall)
									m_balls[l].visible = false;
							}							
						}
					}
					
					var bc: int = m_balls.length;					
					for(l=0;l<bc;l++)
					{
						if((m_balls[l].px+m_balls[i].pradius)>1.0)
							m_balls[l].px=1.0-m_balls[i].pradius;
						if(m_balls[l].px<0.0)
							m_balls[l].px=0.0;
						if((m_balls[l].py+m_balls[i].pradius)>1.0)
							m_balls[l].py=1.0-m_balls[i].pradius;
						if(m_balls[l].py<0.0)
							m_balls[l].py=0.0;
					}
					
					for(var i:int=0; i < bc; ++i) {
						var ball:Ball = m_balls[i];
						if(ball!=cueBall && !ball.visible) {
							//Remove child.
							ball.parent.removeChild(ball);
							balls.splice(i, 1);
							--i;
							--bc;
						}
					}
					cueBall.visible = true;
					
			}
			dataLoaded=true;
		}
				
		public function onUpdateMouse(mX:int, mY:int):void
		{
			m_stick.onUpdate(mX, mY, m_cueBall.x, m_cueBall.y);			
		}
		
		public function onUpdate(th:Game):void
		{
			
			if((m_cueBall.vx==0 && m_cueBall.vy ==0)){
				if(m_Hit) {
					m_Hit = false;
					persist();
				}
				m_stick.visible=true;
				th.activate();
			} else {
					m_Hit = true;
			}
			
			Collision.checkPocketCollisions(m_balls, m_cueBall, m_pockets, th);
			
			// From AS3 book
			for( var k:int=0;k<5;k++){
			for(var i:int = 0; i < m_balls.length; i++)
			{
				var ball:Ball = m_balls[i];
				ball.px += (ball.vx * Collision.timeStep);
				ball.py += (ball.vy * Collision.timeStep);
				ball.vx *= (1 - Collision.friction * Collision.timeStep);
				ball.vy *= (1 - Collision.friction * Collision.timeStep);
				// check velocity for approaching zero
				var magnitudeVelocity:Number = Math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy);
				if (magnitudeVelocity < (ball.pradius*0.05)) {
					ball.vx = 0;
					ball.vy = 0;
				}
				Collision.checkWalls(ball);
			}
			
			for(i = 0; i < m_balls.length - 1; i++)
			{
				var ballA:Ball = m_balls[i];
				for(var j:Number = i + 1; j < m_balls.length; j++)
				{
					var ballB:Ball = m_balls[j];
					Collision.BallCollision(ballA, ballB);
				}
			}
			}
		}
	}
}