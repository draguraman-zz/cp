package {
	
	import data.Neighbors;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import game.Game;
	import game.GameEvent;
	import game.MultiPlayerGame;
	
	import manager.ImageCacheManager;
	import manager.ImageInfo;
	
	import services.GenericWebSocket;
	
	import social.SocialNetwork;
	
	import ui.LeaderBoard;
	import ui.UiLayout;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	import util.DisplayUtil;
	import util.ShardUtil;
	import util.SocialNetworkUtil;
	
	
	[SWF( frameRate="30", backgroundColor="0x000000" )]
	
	public class Billiards extends MovieClip{
		public static var initiatorTurn:Boolean
		public static var invitedTurn:Boolean;
		public static var  neighborId:String;
		public static var STAGE_WIDTH:Number;
		public static var STAGE_HEIGHT:Number;
		public static var is_Single_Game:Boolean=true;
		public static var just_Pushed_Neighbor:Boolean=false;
		public static var game_socket_open:Boolean=false;
		public static var loggedIn:Boolean=false;
		public static var gameSessionId:String;
		public var subscriptionList:Array;
		public var sortdelay:Timer;
		public var pingThere:Timer;
		public static var canStartMultiGame:Boolean=true;
		public static var multiGameStarted:Boolean=false;
		public static var sync_play:Boolean=false;
		public static var invited:Boolean =false; 
		
		private var websocket:GenericWebSocket; 
		private var log:String = "";
		private var freezingSprite:Sprite;
		private var singlePlayerGame:Game;
		private var multiPlayerGame:MultiPlayerGame;
		private static var hpage:DisplayObjectContainer;
		private static var PlayerFrame:DisplayObjectContainer;
		private static var PlayerPic:DisplayObject;
		private static var defaulthselectorpage:DisplayObject;
		private var message_channel:Object;
		private var fbloginbtn:DisplayObject;
		private var guestloginbtn:DisplayObject;
		public static var has_Neighborlist_Changed:Boolean=true;
		
		private var chooseplayer1:DisplayObjectContainer;
		private var chooseplayer2:DisplayObjectContainer;
		private var inviteButton:DisplayObject;
		private var plusbutton:DisplayObject;		
		
		private var player1image:DisplayObjectContainer;
		private var player2image:DisplayObjectContainer;
		private var player1text:TextField;
		private var player2text:TextField;
		
		private var invitedPopup:DisplayObjectContainer;
		
		private var inviteOk:DisplayObject;
		private var inviteCancel:DisplayObject;
		private static var defaultboard:DisplayObject;
		
		private var spbtn:DisplayObject;
		private var mpbtn:DisplayObject;
		private var urlToBmp:Dictionary = new Dictionary();
		
		
		public function Billiards() {
		
		
			ConfigurationUtil.initializeConfiguration(this);
			var stage:Stage = ConfigurationUtil.getStage();
			stage.align = StageAlign.TOP_LEFT; 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.BEST;
			STAGE_WIDTH=ConfigurationUtil.getWidth(); 
			STAGE_HEIGHT=ConfigurationUtil.getHeight();
			trace("STAGE_WIDTH IS "+STAGE_WIDTH);
			trace("STAGE_HEIGHT IS "+STAGE_HEIGHT);
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_INITIALIZED));
			hpage=new EmbeddedAssets.Homepage;
			hpage.width=STAGE_WIDTH;
			hpage.height=STAGE_HEIGHT;
			DisplayUtil.scaled(hpage,hpage.width,hpage.height,DisplayUtil.SCALEMODE_FIT_WIDTH);
			
			spbtn=new EmbeddedAssets.SPlayerBtn;
			spbtn.width=hpage.height/5;
			spbtn.height=spbtn.width/3;
			spbtn.x=hpage.width/DisplayUtil.scaledFactor(2.5,hpage.scaleX);
			spbtn.y=hpage.height/DisplayUtil.scaledFactor(2.8,hpage.scaleY);
			spbtn.addEventListener(MouseEvent.CLICK, startsingleplay);
			
			mpbtn=new EmbeddedAssets.MPlayerBtn;
			mpbtn.width=hpage.height/5;
			mpbtn.height=mpbtn.width/3;
			mpbtn.x=hpage.width/DisplayUtil.scaledFactor(2.5,hpage.scaleX);
			mpbtn.y=hpage.height/DisplayUtil.scaledFactor(2.2,hpage.scaleY);
			mpbtn.addEventListener(MouseEvent.CLICK,startMultiplayerFB);
				
			/*fbloginbtn=new EmbeddedAssets.fbLoginBtn;
			fbloginbtn.x=(hpage.width)/5+(mpbtn.width)/5 -(mpbtn.width/2);
			fbloginbtn.y=mpbtn.y+(mpbtn.height*1.5); 
			fbloginbtn.height=mpbtn.height*0.7;
			fbloginbtn.width=mpbtn.width*0.7;
			fbloginbtn.addEventListener(MouseEvent.CLICK, startMultiplayerFB);
			
			guestloginbtn=new EmbeddedAssets.guestLoginBtn;
			guestloginbtn.x= hpage.width/5 + (mpbtn.width/2)+(mpbtn.width/5);
			guestloginbtn.y=mpbtn.y+(mpbtn.height*1.5); 
			guestloginbtn.height=mpbtn.height*0.7;
			guestloginbtn.width=mpbtn.width*0.7;
			guestloginbtn.addEventListener(MouseEvent.CLICK, startMultiplayerGuest);*/
			
			hpage.addChild(spbtn);
			hpage.addChild(mpbtn);
			
			addChild(hpage);
		}
		
		
		protected function openwebsocketformultiplay(event :Event):void{
			ConfigurationUtil.addEventListener(GameEvent.PRESENCE_SOCKET_OPENED,prepareMultiplayerGame);
			connect_webSocket();
		}
		
		
		public function fetchNeighborData(event :GameEvent):void{				
			loggedIn=true;
			ConfigurationUtil.addEventListener(GameEvent.ON_NEIGHBOR_DATA_FETCHED,openwebsocketformultiplay);
			Neighbors.getInstance().getNeighbors(this.processNeighbors);	
		}
		
		
		public function processNeighbors(result:Object):void{
			subscriptionList = new Array();
			if(result != null && result is Object){
				if(result["game_data_uid"]) {
					var i:int = 0;
					var neighborList:Array = result["game_data_uid"];
					for(i=0;i<neighborList.length;++i) {
						subscriptionList.push(neighborList[i]);
					}
				}
			}
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_NEIGHBOR_DATA_FETCHED));
		}
	
		
		protected function initLogin(): void
		{
			ConfigurationUtil.addEventListener(GameEvent.ON_LOGGED_IN,prepareSinglePlayerGame);
			var socialnetwork:SocialNetwork = ConfigurationUtil.getSocialNetwork(false);
			socialnetwork.login();
		}
		
		protected function initLoginMulti(): void
		{	
			ConfigurationUtil.addEventListener(GameEvent.ON_LOGGED_IN,fetchNeighborData);
			var socialnetwork:SocialNetwork = ConfigurationUtil.getSocialNetwork(false);
			socialnetwork.login();
		}
		
		protected function initLoginAnon(): void
		{
			ConfigurationUtil.addEventListener(GameEvent.ON_LOGGED_IN_ANON,fetchNeighborData);
			var socialnetwork:SocialNetwork = ConfigurationUtil.getSocialNetworkAnon(false);
			socialnetwork.login();
		}		
		
		protected function initLogout(event: Event): void
		{
			var socialnetwork:SocialNetwork = ConfigurationUtil.getSocialNetwork(false);
			socialnetwork.logout();
		}
		
		private function prepareSinglePlayerGame(e:GameEvent): void
		{
			is_Single_Game=true;
			singlePlayerGame=new Game();
			var uil:UiLayout=new UiLayout(false);
			
			singlePlayerGame.addChild(uil);
			this.addChild(singlePlayerGame);
			
			ConfigurationUtil.removeEventListener(GameEvent.BEGIN,startMultiPlayerGame);
			ConfigurationUtil.addEventListener(GameEvent.BEGIN, startGame);
		}
		
		
		
		private function prepareMultiplayerGame(e: GameEvent): void
		{
			//trace("Initiating Game: "+gameId);
			ConfigurationUtil.addEventListener(GameEvent.EXIT_GAME,Restart)
			is_Single_Game=false;
			multiPlayerGame=new MultiPlayerGame();
			var uilmulti:UiLayout=new UiLayout(false, true);
			multiPlayerGame.addChild(uilmulti);
			
			this.addChild(multiPlayerGame);
			canStartMultiGame=true;
			ConfigurationUtil.removeEventListener(GameEvent.BEGIN,startGame);
			ConfigurationUtil.addEventListener(GameEvent.BEGIN,startMultiPlayerGame);
			sortdelay=new Timer(5000,1);
			sortdelay.addEventListener(TimerEvent.TIMER_COMPLETE,timerSort);
			sortdelay.start();	
			
		}
		
		
		private function startsingleplay(e:MouseEvent):void
		{
			//defaultboard=new EmbeddedAssets.Board;
			defaultboard=new EmbeddedAssets.board_ipad;
			defaultboard.width=STAGE_WIDTH;
			defaultboard.height=STAGE_HEIGHT;
			addChild(defaultboard);
			initLogin();
			//ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_GAME_SINGLE_START));
		}
		
		private function multiplayoptions(e:MouseEvent):void
		{
			hpage.addChild(fbloginbtn);
			hpage.addChild(guestloginbtn);
		}
		
		
		private function showAnonFriendSelectorPage(event:Event):void
		{
		}
		
		private function startMultiplayerFB(e:MouseEvent):void
			
		{	//TODO When the player quits and goes back to main screen.That flow still needs to be integrated:QUIT GAME FLOW
			canStartMultiGame=true;
			defaulthselectorpage=new EmbeddedAssets.mPlayerChoiceScreen;
			defaulthselectorpage.height=STAGE_HEIGHT;
			defaulthselectorpage.width=STAGE_WIDTH;
			addChild(defaulthselectorpage);
			if(!loggedIn){initLoginMulti();}
			else{
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_LOGGED_IN));
			}
		}
		
		private function startMultiplayerGuest(e:MouseEvent):void
		{
			defaulthselectorpage=new EmbeddedAssets.mPlayerChoiceScreen;
			defaulthselectorpage.height=STAGE_HEIGHT;
			defaulthselectorpage.width=STAGE_WIDTH;
			addChild(defaulthselectorpage);
			initLoginAnon();
		}
		
		private function startGame(e:GameEvent):void
		{
			singlePlayerGame.startGame();
		}
		
		private function startMultiPlayerGame(e:GameEvent):void
		{
			multiPlayerGame.startGame();
			multiGameStarted=true;
		}
		
		
		public static function inchesToPixels(inches:Number):uint
		{
			return Math.round(Capabilities.screenDPI * inches);
		}
		
		
		private function connect_webSocket():void
		{
			ConfigurationUtil.removeEventListener(Event.ENTER_FRAME,connect_webSocket);
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var sServer:String = ShardUtil.getServer(suser.getId());
			websocket = new GenericWebSocket(sServer, handleCommand, handleWebSocketOpen);
		}
		
		private function handleWebSocketOpen():void
		{
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.PRESENCE_SOCKET_OPENED));
		}
		
		private function Restart(event:GameEvent):void
		
		{
			ConfigurationUtil.addEventListener(GameEvent.GAME_SOCKET_CLOSED,goToStartPage)			
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.CLOSE_GAME_SOCKET));	
		}
		private function goToStartPage(event:GameEvent):void
		{		
			while (this.numChildren) {
				this.removeChildAt(0);
			}
			hpage.addChild(spbtn);
			hpage.addChild(mpbtn);		
			addChild(hpage);
			if(websocket)
			{
				websocket.close();
			}
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ON_INITIALIZED));
			
		}
				
		private function handleIdYou(command:String, data:Object):void {
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			websocket.sendCommand("idme", suser.getId());
			websocket.sendCommand("whothere", {});
		}
		
		private function handleThere(command:String, data:Object): void{
			var thereList:Array=data as Array;
			appendToSubscribe(thereList);
		}
		
		private function handleUserChange(command:String, data:Object): void{
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			
			if(is_Single_Game) 
				return;
			
			for (var key:String in data){
					if(key == suser.getId())
						continue;
					var neighborId:String=key;
					var myobject:Object=new Object();				
					var status:String= data[neighborId];
					trace(" " + neighborId +": is " + status);
					var STATUS:int;					
					if(status=="online"|| status=="Online"|| status=="Unbound" || status=="unbound"){
						STATUS=LeaderBoard.ONLINE;					
					}
					 if(status=="offline" || status=="Offline"){
						STATUS=LeaderBoard.OFFLINE;
					}
					 if(status=="bound" || status=="Bound"|| status=="Busy"|| status=="busy"){
						STATUS=LeaderBoard.BUSY;
					}
					var indexOfNeighbor:int=-1;
					for(var looper:int=0;looper<LeaderBoard.neighbor_list.length;looper++)
					{
						if (LeaderBoard.neighbor_list[looper]['uid']==neighborId){
							indexOfNeighbor=looper;
						}
					}
					
					if(indexOfNeighbor>0)
					{
						LeaderBoard.neighbor_list[indexOfNeighbor]['presence_status']=STATUS;
					}
					
					if(indexOfNeighbor==-1){
						LeaderBoard.neighbor_list.push({uid:neighborId,first_name:("Guest_"+Math.floor(Math.random()*188)),presence_status:STATUS,points:"0"});
						just_Pushed_Neighbor=true;
					}
					if((has_Neighborlist_Changed && !sortdelay.running)||(just_Pushed_Neighbor))
					{
						dispatchSort();
						just_Pushed_Neighbor=false;
					}
			}
		}
		
		private function handleUserBind(command:String, data:Object): void{
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			
			if(is_Single_Game) 
				return;
			for (var key:String in data){
				if(key == suser.getId())
					continue;
				var neighborId:String=key;
				var myobject:Object=new Object();				
				var status:String= data[neighborId];
				trace(" " + neighborId +": is " + status);
				var STATUS:int=LeaderBoard.BUSY;					
				if(status=="online"|| status=="Online"|| status=="Unbound" || status=="unbound"){
					STATUS=LeaderBoard.ONLINE;					
				}
			
				 if(status=="bound" || status=="Bound"|| status=="Busy"|| status=="busy"){
					STATUS=LeaderBoard.BUSY;
				}
				var indexOfNeighbor:int=-1;
				for(var looper:int=0;looper<LeaderBoard.neighbor_list.length;looper++)
				{
					if (LeaderBoard.neighbor_list[looper]['uid']==neighborId){
						indexOfNeighbor=looper;
					}
				}
				
				if(indexOfNeighbor>0)
				{
					LeaderBoard.neighbor_list[indexOfNeighbor]['presence_status']=STATUS;
				}
				
				if(indexOfNeighbor==-1){
					LeaderBoard.neighbor_list.push({uid:neighborId,first_name:("Guest_"+Math.floor(Math.random()*188)),presence_status:STATUS,points:"0"});
					just_Pushed_Neighbor=true;
				}
				if((has_Neighborlist_Changed && !sortdelay.running)||(just_Pushed_Neighbor))
				{
					dispatchSort();
					just_Pushed_Neighbor=false;
				}
			}
		}
		
		private function handleInvite(command:String, data:Object): void{
			trace("@@@ Successfully got an Invite on the Channel:" + data["channel"] + "@@@");
			
			message_channel = data;
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var myId:String=suser.getId();
			var neighborId:Array=new Array();
			var neighborid:String;
			var oneColon:String="1:";
			var socialId:Array=new Array();
			socialId[1]=oneColon;
			socialId[0]=oneColon;
			trace(message_channel["channel"])
			neighborId=message_channel["channel"].split("_");
			
			socialId[0]=socialId[0].concat(neighborId[0]);
			socialId[1]=socialId[1].concat(neighborId[1]);
			if(socialId[0]==myId)
			{
				neighborid=socialId[1]
			}
			else if(socialId[1]==myId)
			{
				neighborid=socialId[0]
			}	
			
			if(MultiPlayerGame.invitecreator && !multiGameStarted /*&& inviteExpiry.running*/) {
				gameSessionId=data["channel"];
				initiatorTurn=true;
				invitedTurn=false;
				MultiPlayerGame.isSelfTurn=true;
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ADD_OTHERUSER_INFO,neighborid));
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.BEGIN));  //when the sender gets confirmations that the invitee is joining the game, then he starts the game
				return;
			}
			
			//here popup that you got an invite :D
			//getting info for the popup
			else
			{
				MultiPlayerGame.invitecreator=false;
			}
			
			invited=true;
			invitedPopup=new EmbeddedAssets.invitedPopup;
			invitedPopup.width=hpage.width/4;
			invitedPopup.height=hpage.width/6;
			invitedPopup.x=hpage.width/DisplayUtil.scaledFactor(2,hpage.scaleX);//(STAGE_WIDTH-invitedPopup.width)/2 ;
			invitedPopup.y=hpage.width/DisplayUtil.scaledFactor(2,hpage.scaleX);//(STAGE_HEIGHT-invitedPopup.height)/2;
			
			PlayerFrame=new EmbeddedAssets.choosePlayerFrame;
			PlayerFrame.height=invitedPopup.height*0.6;
			PlayerFrame.width=invitedPopup.height*0.6;
				
			var b:Bitmap = new Bitmap();
			b.width=PlayerFrame.width;
			b.height=PlayerFrame.height;
			b.x=invitedPopup.width*0.1;
			b.y=invitedPopup.width*0.07;
			
			var url:String  =SocialNetworkUtil.getPictureURL(neighborid);
			if(url != null) {
				urlToBmp[url] = b;
				//PlayerFrame.addChild(b);
				
				ImageCacheManager.getInstance().getImageLoader(url,PlayerFrame.width,PlayerFrame.height,onLoadingNeighborImage);
			}
			invitedPopup.addChild(b);
			
				
			
			inviteOk=new EmbeddedAssets.invitedOk;
			inviteOk.width=mpbtn.height/1.2;
			inviteOk.height=inviteOk.width;
			
			inviteOk.addEventListener(MouseEvent.CLICK,acceptInvite);
			inviteOk.x=	invitedPopup.width/DisplayUtil.scaledFactor(4,invitedPopup.scaleX);//invitedPopup.width*0.5;
			inviteOk.y=	invitedPopup.height/DisplayUtil.scaledFactor(1.5,invitedPopup.scaleY);//invitedPopup.height*0.3;
				
			inviteCancel=new EmbeddedAssets.invitedClose;
			inviteCancel.width=inviteOk.width;
			inviteCancel.height=inviteCancel.width;
			inviteCancel.x=invitedPopup.width/DisplayUtil.scaledFactor(1.75,invitedPopup.scaleX);
			inviteCancel.y=inviteOk.y;
			inviteCancel.addEventListener(MouseEvent.CLICK,rejectInvite);
		
			//invitedPopup.addChild(imgLoadAgent);	
			invitedPopup.addChild(inviteOk);
			invitedPopup.addChild(inviteCancel);
				
			addChild(invitedPopup);  //CHECK WHERE ITS ADDING
			
		}
		
		public function onLoadingNeighborImage(url:String, iInfo:ImageInfo):void {
			
			urlToBmp[url].bitmapData = iInfo.imageData;
			
			urlToBmp[url].x=invitedPopup.width*0.1;
			urlToBmp[url].y=invitedPopup.width*0.07;
			urlToBmp[url].width=invitedPopup.height*0.4;
			urlToBmp[url].height=invitedPopup.height*0.4;
			
			if(urlToBmp[url].parent)
			{
				urlToBmp[url].width = urlToBmp[url].parent.width;
			}
			
			if(urlToBmp[url].parent)
			{
				urlToBmp[url].height = urlToBmp[url].parent.height;
			}
			
			//delete our entry .. one entry is added as child of parent UI
			delete urlToBmp[url];
		}
		
		private function handleCommand(command:String, data:Object):void {
				if(command === "idyou") {
					handleIdYou(command, data);
				} else if(command === "there") {
					handleThere(command, data);
				} else if(command === "userchange") {
					handleUserChange(command, data);
				} else if(command === "invite") {
					handleInvite(command, data);
				}
				else if(command === "userbind") {
					handleInvite(command, data);
				}
		
		}
		
		private function appendToSubscribe(list:Array):void
		{
			for(var appendor:int=0;appendor<list.length;appendor++)
			{
				subscriptionList.push(list[appendor]);
				removeDuplicates(subscriptionList);
				for (var nullfinder:int;nullfinder<subscriptionList.length;nullfinder++)
				{
					if (subscriptionList[nullfinder]==null)
					{
						subscriptionList.splice(nullfinder,1);
					}
				}
				trace("Subscribing to: "+subscriptionList);
				websocket.sendCommand("subscribe", subscriptionList);
			}
			
		}
		
		private function removeDuplicates(arr:Array) : void{
			   var i:int;
			   var j: int;
			   for (i = 0; i < arr.length - 1; i++){
				       for (j = i + 1; j < arr.length; j++){
					           if (arr[i] === arr[j]){
						               arr.splice(j, 1);
					           }
				       }
			   }
		}
		
		public function dispatchSort():void
			
		{
			has_Neighborlist_Changed=false;
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.SORT_FRIEND_LIST));
		}
		public function timerSort(e:TimerEvent):void
			
		{
			has_Neighborlist_Changed=false;
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.SORT_FRIEND_LIST));
		}
		
		
		private function rejectInvite(e:MouseEvent):void
		{
			removeChild(invitedPopup);
		}
		
		
		private function acceptInvite(e:MouseEvent):void
		{
			removeChild(invitedPopup);
	
			if(!multiGameStarted)
			{
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.OPEN_WEBSOCKET_FOR_MULTIPLAY,message_channel));
			}
		}
	
}
}