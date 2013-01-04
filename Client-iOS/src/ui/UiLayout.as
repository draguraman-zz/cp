package ui
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.accessibility.TextAccImpl;
	
	import game.Game;
	import game.GameEvent;
	
	import gameentity.CueBall;
	
	import manager.ImageCacheManager;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	import util.DisplayUtil;
	import util.SocialNetworkUtil;
	public class UiLayout extends MovieClip
	{
		private var imageHandle1:Loader;
		private var imageHandle2:Loader;
		private var board:DisplayObjectContainer;
		private var userInfoBg:DisplayObjectContainer;
		public static var scoreBg1:DisplayObjectContainer;
		public static var scoreBg2:DisplayObjectContainer;
		private var menu:DisplayObject;
		private var reset:DisplayObject;
		private var m_cueBall:CueBall;
		private var cBall:DisplayObject;
		public static var playbtn:DisplayObject;
		private var leaderboard:LeaderBoard;
		private var LboardBg:DisplayObject;
		private var FriendsBg:DisplayObject;
		private var sideBar_exist:Boolean=false;
		private var mySqExist:Boolean=false;
		public static var pointsTxt:TextField;
		public static var tFormat:TextFormat;
		public static var tFormatBig:TextFormat;
		public static var Uname:TextField
		public static var myScoreText:TextField;
		public static var oppScoreText:TextField;
		private var balls:Array;
		private var mySquirrel:DisplayObject;
		private var otherSquirrel:DisplayObject;
		
		public static var TABLE_WIDTH:Number;
		public static var TABLE_HEIGHT:Number;
		public static var TABLE_X:Number;
		public static var TABLE_Y:Number;
		public static var giftBox:DisplayObjectContainer;
		public static var star:DisplayObjectContainer;
		public static var scoreDisplay:TextField;
		public static var numOfStrikes:TextField;
		
		public function UiLayout(init:Boolean=false,multi:Boolean=false)
		{
			tFormat=new TextFormat();
			tFormat.font="Arial";
			//tFormat.size=14;
			tFormat.bold=true;
			tFormat.color=0x000000;
			
			tFormatBig=new TextFormat();
			tFormatBig.font="Arial";
			tFormatBig.size=18;
			tFormatBig.bold=true;
			tFormatBig.color=0x000000;
			tFormatBig.align="center";
			
			var platform:String = ConfigurationUtil.getPlatform();
			if(platform == ConfigurationUtil.PLATFORM_IOS || platform == ConfigurationUtil.PLATFORM_ANDROID)// || ConfigurationUtil.PLATFORM_MAC)
			{
				tFormat.size=12;//Billiards.inchesToPixels(0.08);
			}
			else
			{
				tFormat.size=Billiards.inchesToPixels(0.15);
			}
			
			if(!init)
				initialize();
			//if(!multi)
				leaderboard=new LeaderBoard();
			ConfigurationUtil.addEventListener(GameEvent.ON_BALLS_OVER,createNewBalls);
			ConfigurationUtil.addEventListener(GameEvent.ADD_OTHERUSER_INFO,user2Info);
			ConfigurationUtil.addEventListener(GameEvent.SET_MY_TURN,setMyTurn);
			ConfigurationUtil.addEventListener(GameEvent.SET_OPPO_TURN,setOppoTurn);
			
			
		}
		
		private function setMyTurn(evt:GameEvent):void
		{
			if(!mySqExist) {
				if(otherSquirrel.parent == this)
				removeChild(otherSquirrel);
			}
			addChild(mySquirrel);
			mySqExist=true;
		}
		
		private function setOppoTurn(evt:GameEvent):void
		{
			if(mySqExist) {
				if(mySquirrel.parent == this)
				removeChild(mySquirrel);				
			}
			addChild(otherSquirrel);
			mySqExist=false;
		}
		
		private function user2Info(evt:GameEvent):void
		{
			scoreBg2=new EmbeddedAssets.ScoreBoardBg;
			scoreBg2.width=board.height/3;
			scoreBg2.height=board.height/12;
			scoreBg2.x=board.width-(scoreBg1.x+scoreBg2.width);//imageHandle.x+board.height/10;//board.height/5 + board.height/8;
			addChild(scoreBg2);	
			
			var scoreText:TextField=new TextField();
			scoreText.type="dynamic";
			scoreText.selectable=false;
			scoreText.text="Score:";
			scoreText.setTextFormat(tFormat);
			scoreBg2.addChild(scoreText);
			
			oppScoreText=new TextField();
			oppScoreText.type="dynamic";
			oppScoreText.selectable=false;
			oppScoreText.text="0";
			oppScoreText.x=scoreText.x+scoreText.textWidth*1.3;
			oppScoreText.setTextFormat(tFormat);
			scoreBg2.addChild(oppScoreText);
			
			otherSquirrel.width=mySquirrel.width;
			otherSquirrel.height=mySquirrel.height;
			otherSquirrel.x=scoreBg2.x-otherSquirrel.width;
			loadHandle2(evt);
		}
		private function loadHandle2(evt:GameEvent):void
		{
			var URL:String = SocialNetworkUtil.getPictureURL(evt.getData().toString());
			var pic:DisplayObjectContainer=new EmbeddedAssets.pic_symbol;
			pic.width=scoreBg1.width/5;
			pic.height=scoreBg1.width/5;
			if(URL != null && URL.length>0) {
				var b:Bitmap=new Bitmap();
				b.width=pic.width;
				b.height=pic.height;
				LeaderBoard.urlToBmp[URL]=b;
				pic.addChild(b);
				ImageCacheManager.getInstance().getImageLoader(URL,pic.width,pic.height,LeaderBoard.onImageLoaded);
			}
			pic.x=scoreBg2.x+scoreBg2.width*0.9;
			addChild(pic);
		}
		
		private function createNewBalls(event:GameEvent):void{
			for(var j:Number=0; j<balls.length; j++){
				removeChild(balls[j]);
			}
			Game.state.make_balls();
			makeBalls();
		}
		
		private function checkDataLoad(e:Event = null):void{
			if(Game.state.dataLoaded){
				//Add Score Board
				UiLayout.generateScoreBoard();
				Game.state.dataLoaded=false;
				if(e != null)
					removeEventListener(Event.ENTER_FRAME, checkDataLoad);
			}
		}
		
		private function initialize():void
		{
			for(var c:int = 0; c<numChildren; ++c) {
				removeChildAt(0);
			}
			addEventListener(Event.ENTER_FRAME, checkDataLoad);
			var bg:DisplayObject = new EmbeddedAssets.Background;
			bg.width=Billiards.STAGE_WIDTH;
			bg.height=Billiards.STAGE_HEIGHT;	
			addChild(bg);
			
			//Draw Board
			//board=new EmbeddedAssets.Board;
			board=new EmbeddedAssets.board_ipad;
			board.width=Billiards.STAGE_WIDTH;
			board.height=Billiards.STAGE_HEIGHT;
			DisplayUtil.scaled(board,board.width,board.height,DisplayUtil.SCALEMODE_FIT_WIDTH);
			addChild(board);
			
			TABLE_WIDTH=Billiards.STAGE_WIDTH*0.75;
			TABLE_HEIGHT=Billiards.STAGE_HEIGHT*0.75;
			TABLE_X=Billiards.STAGE_WIDTH/40;
			TABLE_Y=Billiards.STAGE_HEIGHT/20;
			
			
			
			scoreBg1=new EmbeddedAssets.ScoreBoardBg;
			scoreBg1.width=board.height/3;
			scoreBg1.height=board.height/12;
			trace("Height of scoreBg1 is "+scoreBg1.height +"height of board is "+board.height);
			mySquirrel=new EmbeddedAssets.Squerrel_new;
			otherSquirrel=new EmbeddedAssets.Flipped_Squirrel;
			
			mySquirrel.height=scoreBg1.width/3;
			mySquirrel.width=scoreBg1.height*0.9;
			mySquirrel.x=scoreBg1.x+scoreBg1.width+mySquirrel.width;
			
			
			
			
			//imageHandle1.contentLoaderInfo.addEventListener(Event.COMPLETE, load1);
			load1();
				
			
			menu=new EmbeddedAssets.menuBtn;
			menu.width=Billiards.STAGE_HEIGHT/8;//scoreBg1.height*2;
			menu.height=Billiards.STAGE_HEIGHT/8;//scoreBg1.height*2;
			menu.x=board.width-menu.width;//Billiards.STAGE_WIDTH-menu.width;
			menu.y=board.height-menu.height;//Billiards.STAGE_HEIGHT-menu.height;
			menu.addEventListener(MouseEvent.CLICK, sideBars);
			//Add Pockets
			var pockets:Array=Game.state.pockets;
			for(var p:int = 0; p<pockets.length; ++p)
			{
				addChild(pockets[p]);
			}
			
			makeBalls();
			
			//Add Cue Balls
			cBall=Game.state.cueBall as DisplayObject;
			addChild(cBall);
			
			//Add Button to Play
			if(Billiards.is_Single_Game)
			{
				playbtn=new EmbeddedAssets.playBtn;
				playbtn.width=TABLE_WIDTH/8;
				playbtn.height=playbtn.width/3;
				playbtn.x=board.width/2;
				playbtn.y=board.height/2;
				playbtn.addEventListener(MouseEvent.CLICK, startGame);
				addChild(playbtn);
			}
			addChild(menu);
			
		}
		private function load1( ) : void
		{
			var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var URL:String=SocialNetworkUtil.getPictureURL(suser.getId());
			var pic:DisplayObjectContainer=new EmbeddedAssets.pic_symbol;
			var platform:String = ConfigurationUtil.getPlatform();
			if(platform == ConfigurationUtil.PLATFORM_IOS || platform == ConfigurationUtil.PLATFORM_ANDROID)//|| ConfigurationUtil.PLATFORM_MAC)
			{
				pic.width=scoreBg1.width/5;
				pic.height=scoreBg1.width/5;
			}
			else
			{
				pic.width=scoreBg1.width/4.4;
				pic.height=scoreBg1.width/4.4;	
			}
			
			if(URL != null && URL.length>0) {
				var b:Bitmap=new Bitmap();
				b.width=pic.width;
				b.height=pic.height;
				LeaderBoard.urlToBmp[URL]=b;
				pic.addChild(b);
				ImageCacheManager.getInstance().getImageLoader(URL,pic.width,pic.height,LeaderBoard.onImageLoaded);
			}
			pic.x=board.width/DisplayUtil.scaledFactor(11,board.scaleX);
			addChild(pic);
			
			scoreBg1.x=pic.x+pic.width;
			
			addChild(scoreBg1);
			if(!Billiards.is_Single_Game)
			{
				var scoreText:TextField=new TextField();
				scoreText.type="dynamic";
				//PscoreText.height=scoreBg1.height;
				scoreText.selectable=false;
				scoreText.text="Score:";
				scoreText.setTextFormat(tFormat);
				scoreBg1.addChild(scoreText);
				trace("Height of scorebg1 in load1 is "+scoreBg1.height);
				myScoreText=new TextField();
				myScoreText.type="dynamic";
				myScoreText.selectable=false;
				myScoreText.text="0";
				myScoreText.x=scoreText.x+scoreText.textWidth*1.3;
				myScoreText.setTextFormat(tFormat);
				scoreBg1.addChild(myScoreText);
			}
			trace("Height of scorebg1 in load1 is "+scoreBg1.height);
		}
		
		private function resetGameBoard(event:MouseEvent):void
		{
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.EXIT_GAME));
		}
		
		private function startGame(e:MouseEvent):void
		{
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.BEGIN));  //ITS FOR SINGLE PLAY ONLY
		}
		
		private function makeBalls():void{
			//Add Balls
			balls=Game.state.balls;
			for(var b:int = 0; b<balls.length; ++b)
			{
				var ball:DisplayObject=balls[b];
			//	ball.width=scoreBg1.height*0.4;
			//	ball.height=ball.width;
				addChild(ball);
			}
			//Add Stick
			var stick:DisplayObject=Game.state.stick as DisplayObject;
			addChild(stick);
		}
	
	
		private function sideBars(e:MouseEvent):void
		{
			if(sideBar_exist == false){
				sideBar_exist=true;
				//TweenLite.to(menu,1.5,{x:menu.x-menu.width});
				LboardBg=new EmbeddedAssets.LeaderBoardBg;
				LboardBg.width=Billiards.STAGE_WIDTH/4.4;
				LboardBg.height=UiLayout.TABLE_HEIGHT*0.85;
				LboardBg.x=Billiards.STAGE_WIDTH;
				LboardBg.y=UiLayout.TABLE_Y;

				giftBox=new EmbeddedAssets.Giftbox;
				giftBox.width=Billiards.STAGE_WIDTH/4.5;
				giftBox.height=UiLayout.TABLE_HEIGHT/4
				giftBox.x=UiLayout.TABLE_X+UiLayout.TABLE_WIDTH
				giftBox.y=UiLayout.TABLE_Y+LboardBg.height;
			
				var maskWidth:int = Billiards.STAGE_WIDTH*0.55;
				var barHeight:int = Billiards.STAGE_HEIGHT/8;
				var neighborBarOffset:int = UiLayout.TABLE_X+2.5*barHeight;
				FriendsBg=new EmbeddedAssets.FriendsBg;
				FriendsBg.width=maskWidth;
				FriendsBg.height=UiLayout.TABLE_HEIGHT/6;
				FriendsBg.x=Billiards.STAGE_WIDTH;
				FriendsBg.y=Billiards.STAGE_HEIGHT-FriendsBg.height*1.5;
				addChild(FriendsBg);
				addChild(leaderboard);
				TweenLite.to(FriendsBg,1.5,{x:neighborBarOffset});
				setTimeout (appear, 1500);
				
			}
			else
			{
				leaderboard.visible=false;
				//TweenLite.to(menu,1.5,{x:menu.x+menu.width});	
				TweenLite.to(FriendsBg,1.5,{x:UiLayout.TABLE_WIDTH+UiLayout.TABLE_X+FriendsBg.width});
				sideBar_exist=false;
			}
		}
		
		private function appear():void
		{
			leaderboard.visible=true;
		}
		
		public static function generateScoreBoard():void
		{
			trace("Height of scoreBg1 in SP before adding is "+scoreBg1.height);
			numOfStrikes=new TextField();
			
			var m_tstf:TextField=new TextField();
			m_tstf.type="dynamic";
			m_tstf.selectable=false;
			m_tstf.text="Strikes:";
			m_tstf.setTextFormat(tFormat);
			//DisplayUtil.scaledCm(m_tstf,1.3,1.3,DisplayUtil.SCALEMODE_FIT_COVER);
			scoreBg1.addChild(m_tstf);
			//trace("Height of scoreBg1 in SP after adding is "+scoreBg1.height);
			numOfStrikes.x=m_tstf.textWidth*1.1;
			numOfStrikes.selectable=false;
			numOfStrikes.text=String(Game.state.strikes);
			numOfStrikes.setTextFormat(tFormat);
			//DisplayUtil.scaledCm(numOfStrikes,1.3,1.3,DisplayUtil.SCALEMODE_FIT_COVER);
			scoreBg1.addChild(numOfStrikes);
			
			var m_stf:TextField=new TextField();
			m_stf.type="dynamic";
			m_stf.x=(numOfStrikes.x+numOfStrikes.textWidth)*1.2;
			m_stf.selectable=false; 
			m_stf.text="Score:";
			m_stf.setTextFormat(tFormat);
			//DisplayUtil.scaledCm(m_stf,1.3,1.3,DisplayUtil.SCALEMODE_FIT_COVER);
			scoreBg1.addChild(m_stf);
			
			scoreDisplay=new TextField();
			scoreDisplay.type="dynamic";
			scoreDisplay.x=(m_stf.x+m_stf.textWidth)*1.03;
			scoreDisplay.selectable=false;
			scoreDisplay.text=String(Game.state.scores);
			scoreDisplay.setTextFormat(tFormat);
			//DisplayUtil.scaledCm(scoreDisplay,1.3,1.3,DisplayUtil.SCALEMODE_FIT_COVER);
			scoreBg1.addChild(scoreDisplay);
		}
		
		private function setUserInfo():void
		{
			Uname=new TextField();
			Uname.type="dynamic";
			Uname.x=userInfoBg.width*0.8;
			Uname.y=userInfoBg.height/6;
			Uname.width=300;
			Uname.selectable=false;
			
			var suser:SocialUser = ConfigurationUtil.getSocialNetwork().getCurrentUser();
			
			Uname.text=suser.getUserName();
			Uname.setTextFormat(tFormat);
			
			var star:DisplayObjectContainer=new EmbeddedAssets.star_symbol;
			star.width=userInfoBg.height/1.2;
			star.height=star.width*0.9;
			star.x=Uname.x+Uname.textWidth*1.5;
			
			star.y=-(userInfoBg.height/4);
			userInfoBg.addChild(star);
			userInfoBg.addChild(Uname);
			
		}
		
	}
}
