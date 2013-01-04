package ui
{
	import data.Neighbors;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import game.GameEvent;
	
	import manager.ImageCacheManager;
	import manager.ImageInfo;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	import util.DisplayUtil;
	import util.SocialNetworkUtil;
	
	
	public class LeaderBoard extends Sprite
	{	
		public static var neighbors:Array;
		public static var all_friends:Array;
		public static var app_friends:Array;
		public static var neighbor_list:Array;
		private var sp:Sprite;
		public static var selfUserSpliced:Boolean =false;
		private var tFormat:TextFormat;
		private var tFormat2:TextFormat;
		private var tFormat_normal:TextFormat;
		public static var c:int=0;
		
		public static const OFFLINE:int=2;
		public static const ONLINE:int=0;
		public static const BUSY:int=1;
		public static const HIDE:int=3;
		
		public var container:Sprite=new Sprite();
		
		private var maskmc:Sprite=new Sprite();
		private var scrollLine:Sprite=new Sprite();
		private var dragger:Sprite=new Sprite();
		private var LboardBg:DisplayObjectContainer;
		private var LBItem:DisplayObjectContainer;
		private var WIDTH:Number;
		private var HEIGHT:Number;
		private var X:Number;
		private var Y:Number;
		public static var Myrank:TextField;
		public static var list:Array;
		public var maskWidth:int;
		public var barHeight:int;
		public var neighborBarOffset:int;
		public var maskY:int;
		public var numCards:int;
		public var m_index:int=0;
		public var neighborCards:Array;
		public static var urlToBmp:Dictionary = new Dictionary();

		public function LeaderBoard()
		{
			WIDTH=Billiards.STAGE_WIDTH/4.5;
			HEIGHT=UiLayout.TABLE_HEIGHT*0.85;
			X=UiLayout.TABLE_X+UiLayout.TABLE_WIDTH;
			Y=UiLayout.TABLE_Y;
			
			
			tFormat=new TextFormat();
			tFormat.font="Arial";
			tFormat.size=Billiards.inchesToPixels(0.06);
			tFormat.bold=true;
			tFormat.color=0x000000;
			
			tFormat2=new TextFormat();
			tFormat2.font="Arial";
			tFormat2.size=Billiards.inchesToPixels(0.06);
			tFormat2.align="center";
			tFormat2.bold=true;
			tFormat2.color=0x000000;
			
			tFormat_normal=new TextFormat();
			tFormat_normal.font="Arial";
			tFormat_normal.color=0xFFFFFF;
			
			
			neighbors = new Array();
			neighbors['first_name'] = new Array();
			neighbors['uid'] = new Array();
			neighbors['game_data_uid'] = new Array();
			neighbors['game_data_username'] = new Array();
			neighbors['game_data_points'] = new Array();
			neighbors['friends_who_gifted'] = new Array();
			neighbors['friends_gifted_what'] = new Array();
			neighbors['presence_status']=new Array();
			
			all_friends=new Array();
			app_friends=new Array();
			neighbor_list=new Array();
			
			for(var i:int=0;i<app_friends.length;i++)
			{
				app_friends[i]['presence_status']=OFFLINE;
				neighbor_list[i]['presence_status']=OFFLINE;
			}

			sortNeighbors();			
			ConfigurationUtil.addEventListener(GameEvent.SORT_FRIEND_LIST,setStatusandSortNeighbors);
			Neighbors.getInstance().getNeighbors(this.onData);	
		}
		
		private function setStatusandSortNeighbors(e:GameEvent):void
		{
			sortNeighbors();
			displayNeighbourBar();
			Billiards.has_Neighborlist_Changed=true;
		}
		
		private function getp(e:Event):void{
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stopdrag);
		}
		
		private function startdrag(e:MouseEvent):void{
			e.currentTarget.startDrag(false, new Rectangle(0,0,0,HEIGHT-WIDTH/2.5));
			addEventListener(Event.ENTER_FRAME, moveContent);
			
		}
		
		private function moveContent(e:Event):void{
			var ratio:Number=UiLayout.TABLE_HEIGHT/HEIGHT;
			container.y=-(dragger.y*ratio);
		}
		
		private function stopdrag(e:MouseEvent):void{
			dragger.stopDrag();
		}
		
		private function onData(result:Object):void
		{				
			if(result is String)
			{
				neighbors.push(result);
				trace(result);
			}
			
			else if (result is Object)
			{
				trace(JSON.stringify(result));
				
				//Populating All Friends
				for (var arr_key1:String in result){
					if(arr_key1 == 'uid')
					{
						var keyLength_temp1:int = result[arr_key1].length;
						for(var c:int=0;c<keyLength_temp1;c++)
						{
								var friend_uid_temp:String=result['uid'][c];
								var friend_name_temp:String=result['first_name'][c];
							
								all_friends[c]={uid:friend_uid_temp,first_name:friend_name_temp,presence_status:OFFLINE};		
						}
					}
				}
				
				
				//Populating App Friends
				for (var arr_key2:String in result)
				{		
						if(arr_key2 =='game_data_uid'){
						var keyLength_temp2:int = result[arr_key2].length;
						for(var d:int=0;d<keyLength_temp2;d++)
							{
							var appfriend_uid_temp:String=result['game_data_uid'][d];
							var appfriend_name_temp:String=result['game_data_username'][d];
							var points_temp:String=result['game_data_points'][d];
						
							app_friends[d]={uid:appfriend_uid_temp,first_name:appfriend_name_temp,presence_status:OFFLINE,points:points_temp};	
						
							}
						}
				}
				neighbor_list=app_friends;
				var suser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			
				if(!selfUserSpliced)
				{
					var selfIndex:int=-1;
					for(var selffinder:int=0;selffinder<LeaderBoard.neighbor_list.length;selffinder++)
					{
						if (LeaderBoard.neighbor_list[selffinder]['uid']==suser.getId()){
							selfIndex=selffinder;
							}
							if(selfIndex !=-1)
							{
								trace("BEFORE SPLICING  ########  " + JSON.stringify(neighbor_list));
								neighbor_list.splice(selfIndex,1);		
								selfUserSpliced=true;
								trace("AFTER SPLICING   @@@@@@@@ " + JSON.stringify(neighbor_list));
								selfIndex=-1;
							}
							}
				}
		
				
				
				for (var key:String in result)
				{
					var keyLength:int = result[key].length;
					
					for(var indx:int = 0; indx < keyLength; indx++)
					{
						if(key == 'uid')
						{
							neighbors['uid'][indx] = result[key][indx];
							
						}
						else if(key == 'first_name')
						{
							neighbors['first_name'][indx] = result[key][indx];
						}
							//neighbors.push(result[key][uid]);
						else if(key == 'game_data_uid')
						{
							neighbors['game_data_uid'][indx] = result[key][indx];
							
						}
						else if(key == 'game_data_points')
						{
							neighbors['game_data_points'][indx] = result[key][indx];	
						}
						else if(key == 'game_data_username')
						{
							neighbors['game_data_username'][indx] = result[key][indx];	
						}
						else if(key == 'friends_gifted_what')
						{
							neighbors['friends_gifted_what'][indx] = result[key][indx];	
						}
						else if(key == 'friends_who_gifted')
						{
							neighbors['friends_who_gifted'][indx] = result[key][indx];	
						}
					}
					
				}
			}		
			ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.SEND_FRIEND_LIST));
		
			displayNeighbourBar();
			
		}
		
		private function sortNeighbors():void{
				neighbor_list=neighbor_list.sortOn('presence_status');
		}
		
		public function fillNeighborCard(FItemBg:DisplayObjectContainer,URL:String,userFirstName:String,buttonText:String,status:int):void {
			//Neighbor pic
			var pic:DisplayObjectContainer=new EmbeddedAssets.pic_symbol;
			pic.width=FItemBg.width*7/15;
			pic.height=pic.width;				
			pic.x=FItemBg.width/7;
			pic.y=FItemBg.height/3.5;
			var neighborStatus:int=status;
		
			//Invoke the image loader 
			if(URL != null && URL.length > 0) {
				var b:Bitmap = new Bitmap();
				b.width = pic.width;
				b.height = pic.width;
				urlToBmp[URL] = b;
				pic.addChild(b);
				ImageCacheManager.getInstance().getImageLoader(URL,pic.width,pic.height,onImageLoaded);
			}

			
			FItemBg.addChild(pic);
			
			// Get the neighbor name
			var Uname:TextField=new TextField();
			Uname.type="dynamic";
			Uname.x=FItemBg.width/5;
			Uname.y=FItemBg.height/12;
			Uname.width=FItemBg.width*7/8;
			Uname.height=FItemBg.height/3;
			Uname.selectable=false;				
			Uname.text=String(userFirstName);
			
			var platform:String = ConfigurationUtil.getPlatform();
			if(platform == ConfigurationUtil.PLATFORM_IOS || platform == ConfigurationUtil.PLATFORM_ANDROID)//|| ConfigurationUtil.PLATFORM_MAC)
			{
				tFormat_normal.size=12;
			}
			else
			{
				tFormat_normal.size=Billiards.inchesToPixels(0.2);
			}
			Uname.setTextFormat(tFormat_normal);
			FItemBg.addChild(Uname);
			
			// Add button
			var invitebtn:DisplayObject=new EmbeddedAssets.inviteBtnText;
			invitebtn.width=FItemBg.width/2.5;
			invitebtn.height=FItemBg.height/4.5;
			invitebtn.x=2*pic.x;
			invitebtn.y=pic.y+pic.height + (FItemBg.height - pic.y+pic.height)/12;
			FItemBg.addChild(invitebtn);
			invitebtn.name= buttonText;
			// add event listener 
			FItemBg.name= buttonText;
			FItemBg.addEventListener(MouseEvent.CLICK, sendGameRequest);
			
			// Add Online status symbol
			var statusButton:DisplayObject
			statusButton=new EmbeddedAssets.greyStatusLight;
			if (neighborStatus==ONLINE){
				statusButton=new EmbeddedAssets.greenStatusLight;
				}
				else if(neighborStatus==BUSY){
						statusButton=new EmbeddedAssets.orangeStatusLight;
						}
						else if(neighborStatus==OFFLINE){
								statusButton=new EmbeddedAssets.greyStatusLight;
								}
								else if(neighborStatus==HIDE){
										statusButton=new EmbeddedAssets.greyStatusLight;
										statusButton.visible=false;
										}
			statusButton.width=FItemBg.width/10;
			statusButton.height=statusButton.width;
			statusButton.x=1.1*pic.x;
			statusButton.y=pic.y+pic.height + (FItemBg.height - pic.y+pic.height)/10;
			FItemBg.addChild(statusButton);
			//statusButton.name= buttonText;			
		}
		
		public static function onImageLoaded(url:String, iInfo:ImageInfo) : void
		{
			urlToBmp[url].bitmapData = iInfo.imageData;
			urlToBmp[url].x=0;
			urlToBmp[url].y=0;
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
		
		public function createNeighborCard(URL:String,userFirstName:String,buttonText:String,status:int):DisplayObjectContainer {
			//initialize number of cards
			numCards = 5;
			var neighborStatus:int=status;
			var FItemBg:DisplayObjectContainer;
			//Create the Background of the card
			if (neighborStatus==ONLINE)
			{
				FItemBg=new EmbeddedAssets.highlight_greenbg;
			}
			else if (neighborStatus==BUSY)
			{
				FItemBg=new EmbeddedAssets.highlight_orangebg;
			} 
			else
			{
				FItemBg=new EmbeddedAssets.neighborScrollFrame;
			}
			
			FItemBg.width=maskWidth/numCards;
			FItemBg.height=barHeight;
			
			fillNeighborCard(FItemBg,URL,userFirstName,buttonText,neighborStatus);
			
			return FItemBg;
		}
		
		private function displayNeighbourBar():void{
			if(sp)
			{
			while (sp.numChildren) {
				sp.removeChildAt(0);
			}
			}	
			sp=new Sprite();
			addChild(sp);
			
			maskWidth = Billiards.STAGE_WIDTH*0.55;
			barHeight= Billiards.STAGE_HEIGHT/8;
			neighborBarOffset= UiLayout.TABLE_X+2.5*barHeight;
			maskY= UiLayout.TABLE_Y+UiLayout.TABLE_HEIGHT;
			
			for(var i:int=0;i<neighbor_list.length;++i) {
				var key:String = neighbor_list[i]['uid'];
				var URL:String = SocialNetworkUtil.getPictureURL(key);
				var status:int=neighbor_list[i]['presence_status'];
				var userFirstName:String = neighbor_list[i]['first_name'];
				var buttonText:String=String(key).split(":")[1];
				var neighborCard:DisplayObjectContainer = createNeighborCard(URL,userFirstName,buttonText,status);
				neighborCard.width=maskWidth/5;
				neighborCard.height=barHeight;
				neighborCard.x=neighborBarOffset+i*neighborCard.width;
				neighborCard.y=maskY;
				sp.addChild(neighborCard);
			}
			
			// Mask the neighbors who are beyond the bounds of the bar
			var maskSp:Shape=new Shape();			
			addChild(maskSp);
			maskSp.graphics.lineStyle(1,0x00ff00);
			maskSp.graphics.beginFill(0x0000FF);
			maskSp.graphics.drawRect(neighborBarOffset,maskY,maskWidth,barHeight);
			maskSp.graphics.endFill();
			
			// place an arrow on the left side of the neighbor bar
			var leftArrow:DisplayObject=new EmbeddedAssets.neighborScrollLeft;
			leftArrow.height=barHeight;
			leftArrow.width=leftArrow.height/4;
			leftArrow.x=neighborBarOffset-leftArrow.width;
			leftArrow.y=maskY;
			// add event listener
			leftArrow.addEventListener(MouseEvent.CLICK, moveRight);
			addChild(leftArrow);
			
			// place an arrow on the right side of the neighbor bar
			var rightArrow:DisplayObject=new EmbeddedAssets.neighborScrollRight;
			rightArrow.height=leftArrow.height;
			rightArrow.width=leftArrow.width;
			rightArrow.x=neighborBarOffset+maskWidth;
			rightArrow.y=leftArrow.y;
			//rightArrow.scaleX=-0.7;
			addChild(rightArrow);
			// add event listener
			rightArrow.addEventListener(MouseEvent.CLICK, moveLeft);
			
			//add non-app neighbor card
			//var anonNeighborCard:DisplayObjectContainer = createNeighborCard("","Anonymous","ADD",HIDE);
			/*
			anonNeighborCard.width=maskWidth/5;
			anonNeighborCard.height=barHeight;
			anonNeighborCard.x=leftArrow.x - anonNeighborCard.width;
			anonNeighborCard.y=maskY;
			addChild(anonNeighborCard);
			*/
			
			// Set the MASK
			sp.mask=maskSp;			
		}
		
		private function sendGameRequest(e:MouseEvent):void{
			//trace(e.target.name);
			if(!Billiards.is_Single_Game)
			{
				var gameId:String=prepareInvite(e.target.name);
				var neighborId:String="1:"+e.target.name;
				trace("The neighbor id is "+neighborId);
				var data:Array=[neighborId,gameId];
				
				//PUT A CONDITION HERE TO CHECK WHETHER THE PERSON IS ONLINE....ONLY IF ONLINE DISPATCH THE JOIN_GAME_INVITE
				//ELSE SEND A PUSH NOTIFICATION
				ConfigurationUtil.dispatchEvent(new GameEvent(GameEvent.OPEN_WEBSOCKET_FOR_MULTIPLAY,data));
			}
		}
		
		private function prepareInvite(neighborId:String):String //returns the gameId
		{
			var myUser:SocialUser=ConfigurationUtil.getSocialNetwork().getCurrentUser();
			var myId:String=myUser.getId();
			var myUid:String=myId.substr(2,myId.length);
			var id1:int,id2:int;
			id1=Number(myUid);
			id2=Number(neighborId);			
			var gameSessionId:String=((id1<id2)?(myUid.concat("_"+neighborId)):(neighborId.concat("_"+myUid)));
			return gameSessionId
		}
		
		private function moveRight(e:MouseEvent):void{
			if(sp.x<0){
				sp.x+=Billiards.STAGE_WIDTH*0.11;
			}else{
				sp.x=0;
			}
		}
		
		private function moveLeft(e:MouseEvent):void{
			if(sp.x>-(sp.width-Billiards.STAGE_WIDTH*9/16)){
				sp.x-=Billiards.STAGE_WIDTH*0.11;
			}else{
				sp.x=-(sp.width-Billiards.STAGE_WIDTH*9/16);
			}
		}
		
		private function displayPictures():void{
			var rankPos:Number=0;
			for(var pp:int=0; pp<neighbors['game_data_uid'].length; pp++)  
			{
				if(String(neighbors['game_data_username'][pp])!="You"){
					var LBItem:DisplayObjectContainer=new EmbeddedAssets.LeaderBoardItem;
					var pic_symbol:DisplayObjectContainer=new EmbeddedAssets.pic_symbol;
					LBItem.width=WIDTH*0.9;
					LBItem.height=LBItem.width/4;
					LBItem.x=X+WIDTH/30;
					LBItem.y=(LBItem.height*1.4*rankPos+Y*2.5);
					container.addChild(LBItem);
					
					pic_symbol.width=LBItem.height;  
					pic_symbol.height=pic_symbol.width;
					pic_symbol.y=-(pic_symbol.width/3);
					pic_symbol.x=pic_symbol.width/5;
					
					var keyj:String = neighbors['game_data_uid'][pp];
					var URLj:String = SocialNetworkUtil.getPictureURL(keyj);
					var imgLoadAgentj:Loader = new Loader();
					var fileRequestj:URLRequest;
					fileRequestj = new URLRequest(URLj);
					imgLoadAgentj.load(fileRequestj);
					imgLoadAgentj.x=pic_symbol.x;
					imgLoadAgentj.y=pic_symbol.y;
					imgLoadAgentj.height=-(pic_symbol.height);
					imgLoadAgentj.width=-(pic_symbol.width);
					LBItem.addChild(imgLoadAgentj);
					
					var Unamej:TextField=new TextField();
					Unamej.type="dynamic";
					Unamej.x=pic_symbol.x+pic_symbol.width*1.3;
					Unamej.y=LBItem.height/7;
					Unamej.width=100;
					Unamej.selectable=false;
					
					var star:DisplayObjectContainer=new EmbeddedAssets.star_symbol;
					DisplayUtil.scaledCm(star,0.5,0.5,DisplayUtil.SCALEMODE_FIT_COVER);
					//star.width=LBItem.height/1.5//pic_symbol.width/1.2;
					//star.height=star.width//pic_symbol.width/1.2;
					star.x=Unamej.x+Unamej.width;
					star.y=-(LBItem.height/4);
					LBItem.addChild(star);
				
					if((neighbors['game_data_points'][pp] == undefined) || (neighbors['game_data_points'][pp] == false)){
						neighbors['game_data_points'][pp]=0;
					}
					
					if(neighbors['game_data_username'][pp] == undefined){
						neighbors['game_data_username'][pp] = "Invite Friends";
					}
					Unamej.text = String(neighbors['game_data_username'][pp]+"\nPoints: "+neighbors['game_data_points'][pp]);
					tFormat_normal.size=14;
					Unamej.setTextFormat(tFormat_normal);
					LBItem.addChild(Unamej);
					
					var Urank:TextField=new TextField();
					Urank.type="dynamic";
					Urank.x=star.width/2.5;
					Urank.y=star.height/2;
					Urank.width=20;
					Urank.selectable=false;
					Urank.text = String(pp+1);
					Urank.setTextFormat(tFormat2);
					star.addChild(Urank);
					rankPos++;
					
					var gift:DisplayObject=new EmbeddedAssets.Gift;
					gift.width=LBItem.height/4;
					gift.height=LBItem.height/4;
					gift.x=star.x+star.width/2;
					gift.y=LBItem.height/2.8;
					LBItem.addChild(gift);
					gift.name=String(neighbors['game_data_uid'][rankPos]).split(":")[1];
					gift.addEventListener(MouseEvent.CLICK, sendGift);
					
				}
				else{
					var Myrank:TextField=new TextField();
					Myrank.type="dynamic";
					Myrank.width=100;
					Myrank.selectable=false;
					Myrank.text = String(pp+1);
					Myrank.setTextFormat(tFormat);
					
				}
			}
		}
		private function set_my_rank(e:Event):void
		{
			if(UiLayout.star && Myrank){
				UiLayout.star.addChild(Myrank);
				ConfigurationUtil.removeEventListener(Event.ENTER_FRAME, set_my_rank);
			}
		}
		private function sendGift(e:MouseEvent):void{
			animateSendGift();
			SocialNetworkUtil.sendGift(String(e.target.name), "sent gift strikes on crazypool, play to claim!");
		}
		
		private function displayReceivedGifts():void{
			var tff:TextField=new TextField();
			//tff.x=;
			tff.y=tff.height/3;
			tff.width=230;
			tff.height=100;
			tff.selectable=false;
			UiLayout.giftBox.addChild(tff);
			for(var p:Number=0; p < neighbors['friends_who_gifted'].length; p++){
				var uid:String = neighbors['friends_who_gifted'][p];
				var quant:String = neighbors['friends_gifted_what'][p];
				tff.appendText(uid + " gifted "+quant+" strikes!\n");
			}
			//tff.text="Test text display!";
			tff.setTextFormat(tFormat);
		}
		
		private function animateSendGift():void{
			
			var sentGiftAnim:DisplayObject=new EmbeddedAssets.GiftAnim();
			sentGiftAnim.x=mouseX;
			sentGiftAnim.y=mouseY;
			addChild(sentGiftAnim);
			sentGiftAnim.addEventListener(Event.ENTER_FRAME, moveItUp);
			
		}
		
		private function moveItUp(e:Event):void{
			e.target.alpha-=0.05;
			e.target.y-=2;
			
			if(e.target.alpha==0){
				this.removeChild(MovieClip(e.target));
			}
		}			
	}		
}
