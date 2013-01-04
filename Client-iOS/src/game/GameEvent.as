package game
{
	import flash.events.Event;
	
	public class GameEvent extends Event
	{
		//On Application Initialization
		public static const ON_INITIALIZED:String = "onInitialized";
		
		public static const BEGIN:String = "onBegin";
		//On Logging onto Network
		public static const ON_LOGGED_IN:String = "onLoggedIn";
		public static const ON_LOGGED_IN_ANON:String = "onLoggedInAnon";
		
		public static const ON_BALLS_OVER:String="onBallsOver"
		//On Logging off Network
		public static const ON_LOGGED_OUT:String = "onLoggedOut";
		
		//On Start Game
		public static const ON_GAME_START:String = "onGameStart";
		
		//On Start Single Game
		public static const ON_GAME_SINGLE_START:String = "onGameSingleStart";
		
		//On Start Multi Game
		public static const ON_GAME_MULTIFB_START:String = "onGameMultiFBStart";
		
		public static const ON_GAME_MULTIGUEST_START:String = "onGameMultiGuestStart";
		
		public static const ON_SELF_MOVE_COMPLETE:String = "onSelfMoveComplete";
		
		public static const ON_OPPONENT_MOVE_COMPLETE:String = "onOpponentMoveComplete";
		
		public static const ON_WEBSOCKET_OPENED_SINGLE:String = "onWebSocketOpenedSingle";
		public static const PRESENCE_SOCKET_OPENED:String = "presenceSocketOpened";
		
		public static const SEND_FRIEND_LIST:String="sendFriendList";
		
		public static const JOIN_GAME_INVITE:String="joinGameInvite" ;
		public static const ACCEPT_GAME_INVITE:String="acceptGameInvite" ;
		public static const ACCEPT_AND_START:String="acceptAndStart" ;
		public static const PERSIST_MP_DATA:String="persistMPData" ;
		public static const ON_NEIGHBOR_DATA_FETCHED:String="onNeighborDataFetched" ;
		public static const OPEN_WEBSOCKET_FOR_MULTIPLAY:String="openWebSocketForMultiPlay" ;
		public static const SORT_FRIEND_LIST:String="sortFriendList" ;
		public static const  EXIT_GAME:String="exitGame" ;
		public static const  CLOSE_GAME_SOCKET:String="closeGameSocket" ;
		public static const  	GAME_SOCKET_CLOSED:String="gameSocketClosed" ;
		public static const  ADD_OTHERUSER_INFO:String="addOtherUserInfo" ;
		public static const  SET_MY_TURN:String="setMyTurn" ;
		public static const  SET_OPPO_TURN:String="setOppoTurn" ;
		
		private var data:Object;
		
		public function GameEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
			setData(data);
		}
		
		public function getData():Object
		{
			return data;
		}
		
		public function setData(data:Object):void
		{
			this.data = data;
		}
		
	}
}
