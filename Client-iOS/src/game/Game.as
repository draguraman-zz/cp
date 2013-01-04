package game{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextField;
	
	import gameentity.GameState;
	
	import ui.UiLayout;
	
	import util.ConfigurationUtil;
	import util.SocialNetworkUtil;
	import util.TextUtil;

	public class Game extends MovieClip{
		
		public static var state:GameState;
		public static var startedDragging:Boolean=false;
		public static var cueRadius:Number;
		public var initX:Number;
		public var initY:Number;
		public var finalX:Number;
		public var finalY:Number;
		protected var balls:Array;
		protected var feedScore:Number;
		protected var gameStarted:Boolean=false;
		protected var popup:DisplayObject;
		protected var popup1:DisplayObjectContainer;
		protected var sendBtn:DisplayObject;
		protected var cancelBtn:DisplayObject;
		protected var askBtn:DisplayObject;
		protected var okBtn:DisplayObject;
		protected var story:TextField;
		protected var story1:TextField;
		
		public function Game()
		{
			state = makeGameState(Billiards.STAGE_WIDTH, Billiards.STAGE_HEIGHT);
			state.load();
			cueRadius=state.cueBall.width/2;
		}
		
		public function makeGameState(w:Number, h:Number):GameState {
			return new GameState(w, h);
		}
		
		
		public function startGame():void
		{	
			var stage:Stage=ConfigurationUtil.getStage();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			state.cueBall.vx=0;
			state.cueBall.vy=0;
			if(state.dataLoaded){	
				UiLayout.scoreDisplay.text=String(state.scores);
				UiLayout.scoreDisplay.setTextFormat(UiLayout.tFormat);
			}
			
			state.stick.visible=true;
			stage.addEventListener(Event.ENTER_FRAME,onGameFrame);
			if(Billiards.is_Single_Game)
				UiLayout.playbtn.visible=false;
			
			trace('Starting Game ... ');
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);		
			gameStarted=true;
		}
		
		public function stopGame():void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
			stage.removeEventListener(Event.ENTER_FRAME,onGameFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
		}
		
		public function gameOver():void{
			feedScore=state.scores;
			startedDragging=false;
			state.stick.x=state.cueBall.x;
			state.stick.y=state.cueBall.y;
			createPopupForFeed();
			state.scores=0;
			UiLayout.scoreDisplay.text=String(state.scores);
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_BALLS_OVER));
		}
		
		public function onMouseDown(mX:Number, mY:Number):void{
			if (state.cueBall.vx == 0 && state.cueBall.vy == 0) {
				startedDragging=true;
				// start dragging "cue stick" if ball at rest
				initX=mX;
				initY=mY;
				state.stick.visible=true;
				state.stick.st.x=0
			}		
		}
		
		
		public function mouseDown(evt:MouseEvent):void {
			trace("EVENT IS "+evt);
			onMouseDown(mouseX, mouseY);
		}
		
		public function onHitCueBall(vx:Number, vy:Number): void{
			state.cueBall.vx = vx;
			state.cueBall.vy = vy;						
		}
		
		public function hitCueBall(vx:Number, vy:Number): void{
			onHitCueBall(vx, vy);
		}
		
		public function onMouseMove(mX:Number, mY:Number): void{
			state.onUpdateMouse(mouseX, mouseY);			
		}
		
		public function mouseMove():void{
			onMouseMove(mouseX, mouseY);
		}
		
		public function onMouseUp(mX:Number, mY:Number, applyHit:Boolean = false): void {
			state.stick.visible=false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
			finalX=mX;
			finalY=mY;
			
			var X0:Number=state.cueBall.x;
			var Y0:Number=state.cueBall.y;
			
			var X1:Number=initX;
			var Y1:Number=initY;
			
			var X2:Number=finalX;
			var Y2:Number=finalY;
			
			var X3:Number;
			var Y3:Number;
			var m:Number;
			var m1:Number;
			var m2:Number;
			var alpha:Number;
			var beta:Number;
			var theta12:Number;
			var mu:Number;
			var d01:Number;
			var d02:Number;
			var d:Number;
			var phi:Number;
			var dx:Number;
			var dy:Number;
			var d01web:Number;
			var d03web:Number;
			
			d01=Math.sqrt((X0-X1)*(X0-X1)+(Y0-Y1)*(Y0-Y1));
			d02=Math.sqrt((X0-X2)*(X0-X2)+(Y0-Y2)*(Y0-Y2));
			if(d02>=d01)
				d=d02-d01;
			else
				d=0;
			
			if(Y0!=Y2)
			{
				m=(Y2-Y0)/(X2-X0);
				if(X0>X2)
					phi=Math.atan(m);
				else if(X0<X2)
					phi=Math.PI+Math.atan(m);
				else if(Y0<Y2)
					phi=-Math.PI/2;
				else 
					phi=Math.PI/2;
			}
			else
			{
				if(X0>=X1)
					phi=0;
				else 
					phi=Math.PI;
			}
			
			dx=d*Math.cos(phi);
			dy=d*Math.sin(phi);
			
			state.stick.st.x=0;
				
			var rectangle:Rectangle = state.getBounds();
			dx = dx / rectangle.width;
			dy = dy / rectangle.height;
			
			dx *= 0.5;
			dy *= 0.5;
			
			if(applyHit && d>0)//(d01>state.cueBall.width/2  || d01web>d03web ) )
				hitCueBall(dx, dy);
 			startedDragging=false;
			var hitSound:Sound=new EmbeddedAssets.HitSound as Sound;
			hitSound.play();
		}
		
		public function mouseUp(evt:MouseEvent):void {
			trace("MOUSEEVENT IS "+evt);
			onMouseUp(mouseX, mouseY, true);
		}
		
		public function onMouseDrag(mX:Number, mY:Number):void {
			finalX=mX;
			finalY=mY;
			
			var X0:Number=state.cueBall.x;
			var Y0:Number=state.cueBall.y;
			
			var X1:Number=initX;
			var Y1:Number=initY;
			
			var X2:Number=finalX;
			var Y2:Number=finalY;
			
			var X3:Number;
			var Y3:Number;
			var m:Number;
			var m1:Number;
			var m2:Number;
			var alpha:Number;
			var beta:Number;
			var theta12:Number;
			var mu:Number;
			var d01:Number;
			var d02:Number;
			var d:Number;
			var phi:Number;
			var dx:Number;
			var dy:Number;
			var d01web:Number;
			var d03web:Number;
			
			d01=Math.sqrt((X0-X1)*(X0-X1)+(Y0-Y1)*(Y0-Y1));
			d02=Math.sqrt((X0-X2)*(X0-X2)+(Y0-Y2)*(Y0-Y2));
			if(d02>=d01)
				d=d02-d01;
			else
				d=0;
				
			if(Y0!=Y2)
			{
				m=(Y2-Y0)/(X2-X0);
				if(X0>X2)
					phi=Math.atan(m);
				else if(X0<X2)
					phi=Math.PI+Math.atan(m);
				else if(Y0<Y2)
					phi=-Math.PI/2;
				else
					phi=Math.PI/2;
			}
			else
			{
				if(X0>=X1)
					phi=0;
				else 
					phi=Math.PI;
			}
				
			dx=d*Math.cos(phi);
			dy=d*Math.sin(phi);
			
			var distance:Number=Math.sqrt(dx*dx+dy*dy);
			if(distance <= Billiards.STAGE_HEIGHT/3)
				state.stick.st.x=-distance;
			
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
		}
		
		public function mouseDrag():void{
			onMouseDrag(mouseX, mouseY);
		}
		
		public function onMove(): void {
			state.onUpdate(this );
		}
		
		public function onGameFrame(evt:Event):void {
			balls=state.balls;
			if(balls.length==1){
				state.persist(true);
				stopGame();
				gameOver();
			}
			
			if(canPlay()){
				if(startedDragging)
					mouseDrag();
					mouseMove();
				onMove();
				if(!canPlay()) {
					state.persist(true);
					stopGame();
					createPopupForStrikesOver();
				}
			}
		}
		
		
		protected function canPlay():Boolean {
			var toPlay:Boolean = true;
			if(!UiLayout) 
				toPlay = false;
			else if(!UiLayout.numOfStrikes)
				toPlay = false;
			else if(Number(UiLayout.numOfStrikes.text) <= 0)
					toPlay = false;
			return toPlay;
		}
		
		public function updateScore(num:int, obj:*):void{
			animateStars(obj);
			Game.state.scores=Number(UiLayout.scoreDisplay.text);
			Game.state.scores+=num;
			UiLayout.scoreDisplay.text=String(Game.state.scores);			
			Game.state.set_score(Game.state.scores, Number(UiLayout.numOfStrikes.text));
			UiLayout.scoreDisplay.setTextFormat(UiLayout.tFormat);
		}
		
		public function activate():void{
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
		}
		
		protected function animateStars(o:*):void{
			var stars:DisplayObject=new EmbeddedAssets.Stars();
			stars.x=o.x;
			stars.y=o.y;
			addChild(stars);
			stars.addEventListener(Event.ENTER_FRAME, moveItUp);
		}
		
		private function moveItUp(e:Event):void{
			e.target.alpha-=0.05;
			if(e.target.alpha<=0.2){
				try{
					this.removeChild(MovieClip(e.target));
				}catch(e:Error){}
			}
		}
				
		private  function createPopupForFeed():void{
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
			stage.removeEventListener(Event.ENTER_FRAME,onGameFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUp);
			
			
			popup=new EmbeddedAssets.Popup;
			popup.x=stage.stageWidth/2-250;
			popup.y=stage.stageHeight/2-190;
			addChild(popup);
			
			
			sendBtn=new EmbeddedAssets.send;
			sendBtn.x=popup.x+80;
			sendBtn.y=popup.y+180;
			addChild(sendBtn);
			sendBtn.addEventListener(MouseEvent.CLICK, postStory);
			
			cancelBtn=new EmbeddedAssets.cancel;
			cancelBtn.x=popup.x+150;
			cancelBtn.y=popup.y+230;
			addChild(cancelBtn);
			cancelBtn.addEventListener(MouseEvent.CLICK, hidePopup);
			
			story=new TextField();
			story.type="dynamic";
			story.multiline=true;
			story.wordWrap=true;
			story.x=popup.x+50;
			story.y=popup.y+60;
			story.width=360;
			story.height=80;
			story.selectable=false;
			story.text="Awesome!\n\nYou have scored "+String(feedScore)+" points.\nChallenge your friends to beat your score!";
			story.setTextFormat(UiLayout.tFormatBig);
			addChild(story);
			
			
		}
		
		private function postStory(e:MouseEvent):void{	
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
			stage.addEventListener(Event.ENTER_FRAME,onGameFrame);
			var postString:String=UiLayout.Uname.text+" scored "+String(feedScore)+" points in Crazy Pool! Can you beat him?";
			removeChild(story);
			removeChild(popup);
			removeChild(sendBtn);
			removeChild(cancelBtn);
		}
		
		private function hidePopup(e:MouseEvent):void{
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown);
			stage.addEventListener(Event.ENTER_FRAME,onGameFrame);
			removeChild(story);
			removeChild(popup);
			removeChild(sendBtn);
			removeChild(cancelBtn);
		}
		
		private function hidePopupStrikesOver(e:MouseEvent):void{
			removeChild(story1);
			removeChild(popup1);
			removeChild(askBtn);
			removeChild(okBtn);
		}
		
		protected function createPopupForStrikesOver():void{
			var stage:Stage=ConfigurationUtil.getStage();
			
			popup1=new EmbeddedAssets.Popup;
			popup1.x=UiLayout.TABLE_WIDTH/3;
			popup1.y=UiLayout.TABLE_HEIGHT/3;
			addChild(popup1);
			
			
			askBtn=new EmbeddedAssets.Ask;
			askBtn.x=popup1.x*1.2;
			askBtn.y=popup1.y*2.5;
			addChild(askBtn);
			askBtn.addEventListener(MouseEvent.CLICK, askStrikes);
			
			okBtn=new EmbeddedAssets.Ok;
			okBtn.x=popup1.x*2;
			okBtn.y=popup1.y*2.5;
			addChild(okBtn);
			okBtn.addEventListener(MouseEvent.CLICK, hidePopupStrikesOver);
			
			story1=new TextField();
			story1.type="dynamic";
			story1.multiline=true;
			story1.wordWrap=true;
			story1.x=popup1.x+50;
			story1.y=popup1.y+50;
			story1.width=360;
			story1.height=120;
			story1.selectable=false;
			story1.text="Your out of strikes!!\n\nCome back after 1 hour \nor\nAsk for more strikes from your friends";
			story1.setTextFormat(UiLayout.tFormatBig);
			addChild(story1);
			
		}
		
		private function askStrikes(e:MouseEvent):void{
			SocialNetworkUtil.askForStrikes("I have ran out of strikes at Crazy Pool! Can you gift me some strikes? Thanks!");
			removeChild(story1);
			removeChild(popup1);
			removeChild(askBtn);
			removeChild(okBtn);
		}
		
	}
}