package game {
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import gameentity.GameState;
	import gameentity.MultiGameState;
	
	import services.GenericWebSocket;
	
	import ui.UiLayout;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	import util.ShardUtil;
	
	public class MultiPlayerGame extends Game {
		
		private var websocket_multi:GenericWebSocket;
		private var gameId:String;
		private var messagequeue:Array = new Array();
		private var suser:SocialUser;
		private var disttimer:int = 0;
		private var curtimer:int = 0;
		private var data:Object;
		public static var myScore:int=0;
		public static var oppScore:int=0;
		public static var invitecreator:Boolean=false;
		public static var gameSessionId:String;
		public static var isSelfTurn:Boolean;
		
		public function MultiPlayerGame() {
			suser=ConfigurationUtil.getSocialNetwork().getCurrentUser();

			ConfigurationUtil.addEventListener(GameEvent.OPEN_WEBSOCKET_FOR_MULTIPLAY,connect_webSocket);
			ConfigurationUtil.addEventListener(GameEvent.JOIN_GAME_INVITE,sendInvite);
			ConfigurationUtil.addEventListener(GameEvent.ACCEPT_GAME_INVITE,acceptInviteandConfirm);
			state = makeGameState(Billiards.STAGE_WIDTH, Billiards.STAGE_HEIGHT);
			ConfigurationUtil.addEventListener(GameEvent.PERSIST_MP_DATA,persistData);
			ConfigurationUtil.addEventListener(GameEvent.CLOSE_GAME_SOCKET,closeGameSocket);
			
			state.load();
			state.reset();
		}
		
		public override function makeGameState(w:Number, h:Number):GameState {
			return new MultiGameState(w, h);
		}
		
		public function connect_webSocket(e:GameEvent):void
		{			
			data=e.getData();
			var channel:String = data["channel"];
			trace("Got the channel:" + channel);
			var sServer:String = ShardUtil.getServer(channel);
			websocket_multi = new GenericWebSocket(sServer, handleCommand, handleWebSocketOpen, handleWebSocketClose);
		}
		
		private function add_Message_To_Queue(message:Object): void{
			messagequeue.push(message);
		}
		
		private function dequeMessages(): void{
			if(!websocket_multi)
				return;
			var oldmq:Array = messagequeue;
			if(!oldmq)
				return;
			if(oldmq.length <= 0)
				return;
			messagequeue = new Array();
			for(var i:int = 0; i < oldmq.length; ++i) {
				var message:Object = oldmq[i];	
				var command:String = message["command"];
				var data:Object = message["data"];
				sendMessage(command, data);
			}
		}
		
		public function sendMessage(command:String, data:Object): void{
			var message:Object = new Object();
			if(websocket_multi) {
				try {
					websocket_multi.sendCommand(command, data);
					return;
				} catch (e: Error) {
					message["command"] = command;
					message["data"] = data;
					add_Message_To_Queue(message);					
				}
			} else {
				message["command"] = command;
				message["data"] = data;
				add_Message_To_Queue(message);
			}
		}
		
		private function acceptInviteandConfirm(event:GameEvent):void
		{
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var myId:String=suser.getId();
			var data:Object = event.getData();
			var channel:String=data["channel"];
			var neighborId:Array=new Array();
			var neighborid:String;
			var oneColon:String="1:";
			var curTurn:Boolean = false;
			
			var socialId:Array=new Array();
			socialId[1]=oneColon;
			socialId[0]=oneColon;
			
			if(channel == null)
				return;
			neighborId=channel.split("_");
			
			socialId[0]=socialId[0].concat(neighborId[0]);
			socialId[1]=socialId[1].concat(neighborId[1]);
			if(socialId[0]==myId)
			{
				neighborid=socialId[1]
				curTurn = true;
			}
			else if(socialId[1]==myId)
			{
				neighborid=socialId[0]
			} else {
				trace('Bad Game ID: '+channel);
			}
			sendMessage("joingame", { "channel":channel,"self":myId,"invite":[neighborid]});
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ADD_OTHERUSER_INFO,neighborid));
			Billiards.gameSessionId=channel;

			isSelfTurn = curTurn;
			moveDoneActual();

			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.BEGIN));
			
			
		}
		
		
		private function switchTurn(selfTurn:Boolean):void {
			isSelfTurn=selfTurn;
			if(isSelfTurn)
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.SET_MY_TURN));
			else
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.SET_OPPO_TURN));
		}

		public function moveDoneActual():void
		{
			sendGameCommand({"EventAction":"TurnDone", "self":suser.getId()});
			switchTurn(false);
		}
		
		private function sendInvite(event:GameEvent):void
		{	trace("Sending Invite");
			var data:Object=event.getData();
			trace("GameId is "+data[1]);
			trace("NeighborId is "+data[0]);
			sendMessage("joingame", { "channel": data[1], "self":suser.getId(), "invite": [data[0]] });
			trace("Sent Invite!");
			invitecreator=true;
		}
		
		private function handleWebSocketOpen():void {
			if(Billiards.invited)
			{
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.ACCEPT_GAME_INVITE,data)); //here data is the channel
			}
			else if(!Billiards.invited)
			{
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.JOIN_GAME_INVITE,data));
			}
			dequeMessages();
		}
		
		private function handleWebSocketClose():void {
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.GAME_SOCKET_CLOSED));								
		}
		
		private function closeGameSocket(event:GameEvent):void
		{   
			if(	websocket_multi) {
				websocket_multi.close();			
			}
		}
				
		public function persistData(variables:Object):void{
			sendGameCommand({"EventAction":"State", "data":variables});
		}
		
		public function handleAction(response:Object):void {
			var uId:String = response["from"];
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			if(uId == suser.getId()) {
				return;
			}
			var timestamp:String = response["timestamp"];
			var data:Object = response["data"];
			var eventAction:String = data["EventAction"];
			if(eventAction == "mouseUp" || eventAction == "mouseDown" || eventAction == "mouseDrag" || eventAction == "mouseMove") {
				var mX : Number = Number(data["mouseX"]);
				var mY : Number = Number(data["mouseY"]);
				var r:Rectangle = state.getBounds();
				mX *= r.width;
				mY *= r.height;
				mX += r.left;
				mY += r.top;
				if(eventAction == "mouseDown")
				{
					onMouseDown(mX, mY);
				} else if(eventAction == "mouseUp")
				{
					onMouseUp(mX, mY);
				} else if(eventAction == "mouseMove")
				{
					onMouseMove(mX, mY);
				} else if(eventAction == "mouseDrag")
				{
					onMouseDrag(mX, mY);
				}
			} else if(eventAction == "hitCueBall") {
				var vX:Number = Number(data["vX"]);
				var vY:Number = Number(data["vY"]);
				onHitCueBall(vX, vY);
			} else if(eventAction == "State") {
				state.loadExternal(data["data"]);
			} else if(eventAction == "TurnDone") {
				uId = data["self"];
				if(uId == suser.getId()) {
					trace('Message from Myself');
				} else {
					switchTurn(true);
				}
			}
		}
		
		public function handleCommand(command:String, data:Object):void {
			if(command != null && command == "game") {
				var gameId:String = data["channel"];
				if(!data["actions"])
					return;
				var actions:Array = data["actions"];
				var i:int=0;
				for(;i<actions.length;++i) {
					handleAction(actions[i]);
				}
			}
		}
		
		public function sendGameCommand(data:Object): void{
			var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var d:Date=new Date();
			var actions:Array = [{"timestamp": d.getTime(), "from":suser.getId(), "data": data}];
			sendMessage("game", {"channel": Billiards.gameSessionId.toString(), "actions":actions});
		}
		
		public function sendMouseCommand(mX:Number,mY:Number,evtAction:String): void{
			var r:Rectangle = state.getBounds();
			mX -= r.left;
			mY -= r.top;
			mX /= r.width;
			mY /= r.height;
			sendGameCommand({"EventAction":evtAction, "mouseX":mX,"mouseY":mY});
		}
		
		
		public override function onHitCueBall(vx:Number, vy:Number): void{
			super.onHitCueBall(vx, vy);
		}
		
		public override function hitCueBall(vx:Number, vy:Number): void{
			if(!isSelfTurn)
				return;
			sendGameCommand({"EventAction":"hitCueBall", "vX":vx, "vY":vy});
			super.hitCueBall(vx, vy);
			moveDoneActual();
		}
		
		public override function mouseDown(evt:MouseEvent):void {
			if(!isSelfTurn)
				return;
			sendMouseCommand(mouseX, mouseY, "mouseDown");
			super.mouseDown(evt);
		}
		
		public override function mouseUp(evt:MouseEvent):void {
			if(!isSelfTurn)
				return;
			sendMouseCommand(mouseX, mouseY, "mouseUp");
			super.mouseUp(evt);
		}
		
		public override function mouseMove():void{
			if(!isSelfTurn)
				return;
			sendMouseCommand(mouseX, mouseY, "mouseMove");
			super.mouseMove();
		}
		
		public override function mouseDrag():void{
			if(!isSelfTurn)
				return;
			sendMouseCommand(mouseX, mouseY, "mouseDrag");
			super.mouseDrag();
		}
		
		protected override function createPopupForStrikesOver():void{
		}
		
		protected override function canPlay():Boolean {
			return true;
		}
		
		public override function updateScore(num:int, obj:*):void{
			animateStars(obj);
			//update score in my ui
			if(isSelfTurn)
			{
				myScore=Number(UiLayout.myScoreText.text);
				myScore+=num;
				UiLayout.myScoreText.text=String(myScore);	
				UiLayout.myScoreText.setTextFormat(UiLayout.tFormat);
			}
			else
			{
				oppScore=Number(UiLayout.oppScoreText.text);
				oppScore+=num;
				UiLayout.oppScoreText.text=String(oppScore);	
				UiLayout.oppScoreText.setTextFormat(UiLayout.tFormat);
			}
				
			
		}
	}
}
