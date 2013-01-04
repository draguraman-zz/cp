package ui
{
	import data.LocalJSON;
	import data.Neighbors;
	
	import flash.display.Bitmap;
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
	import flash.sampler.getInvocationCount;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	
	import game.Game;
	import game.GameEvent;
	
	import social.SocialNetwork;
	
	import user.SocialUser;
	
	import util.ConfigurationUtil;
	import util.DisplayUtil;
	import util.SocialNetworkUtil;
	
	
	public class LeaderBoard extends Sprite
	{	
		public static var neighbors:Array;
		private var sp:Sprite;
		public static var app_friends:Array;
		private var tFormat:TextFormat;
		private var tFormat2:TextFormat;
		private var tFormat_normal:TextFormat;
		
		
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
			for(var i:int=0;i<neighbors['game_data_uid'].length;i++)
			{
				neighbors['presence_status'][i]="offline";
			}
			
			ConfigurationUtil.addEventListener(GameEvent.SORT_FRIEND_LIST,setStatusandSortNeighbors);
			Neighbors.getInstance().getNeighbors(this.onData);	
			
		}
		private function setStatusandSortNeighbors(e:GameEvent):void
		{
			sortNeighbors(neighbors);
			
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
		
		private function sortNeighbors(array:Array):void{
			//idea is to sort the neighbor list according to presence data
			var unsortedneighbors:Array=array;
			neighbors=unsortedneighbors.sortOn("presence_status");
			
		}
		
		public function fillNeighborCard(FItemBg:DisplayObjectContainer,URL:String,userFirstName:String,buttonText:String,status:String):void {
			//Neighbor pic
			var pic:DisplayObjectContainer=new EmbeddedAssets.pic_symbol;
			pic.width=FItemBg.width*7/15;
			pic.height=pic.width;				
			pic.x=FItemBg.width/7;
			pic.y=FItemBg.height/4;
			var neighborStatus:String=status;
			
			//Invoke the image loader 
			if(URL != null && URL.length > 0) {
				var imgLoadAgent:Loader = new Loader();
				var fileRequest:URLRequest = new URLRequest(URL);
				imgLoadAgent.load(fileRequest);
				imgLoadAgent.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadingNeighborImage);  
				pic.addChild(imgLoadAgent);
			}
			
			FItemBg.addChild(pic);
			
			// Get the neighbor name
			var Uname:TextField=new TextField();
			Uname.type="dynamic";
			Uname.x=FItemBg.height/5;
			Uname.y=FItemBg.height/12;
			Uname.width=FItemBg.width*7/8;
			Uname.height=FItemBg.height/3;
			Uname.selectable=false;				
			Uname.text=String(userFirstName);
			tFormat_normal.size=Billiards.inchesToPixels(0.08)//pic.width/3;
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
			invitebtn.addEventListener(MouseEvent.CLICK, sendGameRequest);
			
			// Add Online status symbol
			var statusButton:DisplayObject
			statusButton=new EmbeddedAssets.greyStatusLight;
			if (neighborStatus=="online"){
				statusButton=new EmbeddedAssets.greenStatusLight;
				}
				else if(neighborStatus=="busy"){
						statusButton=new EmbeddedAssets.orangeStatusLight;
						}
						else if(neighborStatus=="offline"){
								statusButton=new EmbeddedAssets.greyStatusLight;
								}
								else if(neighborStatus=="hide"){
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
		
		public function createNeighborCard(URL:String,userFirstName:String,buttonText:String,status:String):DisplayObjectContainer {
			//initialize number of cards
			numCards = 5;
			var neighborStatus:String=status;
			//Create the Background of the card
			var FItemBg:DisplayObjectContainer=new EmbeddedAssets.neighborScrollFrame;
			FItemBg.width=maskWidth/numCards;
			FItemBg.height=barHeight;
			
			fillNeighborCard(FItemBg,URL,userFirstName,buttonText,neighborStatus);
			
			return FItemBg;
		}
		
		public function onLoadingNeighborImage(event:Event):void {
			var picLoader:Loader = event.currentTarget.loader;
			var pic:DisplayObjectContainer=picLoader.parent;
			picLoader.content.width = pic.width;
			picLoader.content.height = pic.height;
			picLoader.content.x=0;
			picLoader.content.y=0;
		}
		public function refreshNeighborCards():void{
			for(var i:int=0;i<numCards;++i) {
				var nbrCardView:NeighborCardView = neighborCards[i];
				var neighborCard:DisplayObjectContainer = nbrCardView.neighborCard;
				sp.removeChild(neighborCard);
			}
			
			
			
		}

		
	/*	public function refreshNeighborCards(toLeft:Boolean):void {
			// remove the neighborCards from the sprite
			for(var i:int=0;i<numCards;++i) {
				var nbrCardView:NeighborCardView = neighborCards[i];
				var neighborCard:DisplayObjectContainer = nbrCardView.neighborCard;
				sp.removeChild(neighborCard);
			}
			
			var nbrCardView0:NeighborCardView; // object to re-use
			
			if(toLeft) {
				nbrCardView0 = neighborCards[0];
				for(i=0;i<numCards-1;++i) {
					nbrCardView = neighborCards[i+1];
					neighborCard = nbrCardView.neighborCard;
					neighborCard.x=neighborBarOffset+i*neighborCard.width;
					neighborCard.y=maskY;
					neighborCards[i] = nbrCardView;
				}
			}
			else {
				nbrCardView0 = neighborCards[numCards-1];
				for(i=numCards-1;i>0;--i) {
					neighborCard = neighborCards[i-1];
					neighborCard.x=neighborBarOffset+i*neighborCard.width;
					neighborCard.y=maskY;
					neighborCards[i] = neighborCard;
				}
			}
			
			//refresh the card and add it to the parent sprite 
			var neighborCard0:DisplayObjectContainer = createNeighborCard("","","","offline");
			neighborCard0.x=neighborBarOffset+i*neighborCard0.width;
			neighborCard0.y=maskY;
			neighborCards[i] = nbrCardView0;
			nbrCardView0.neighborCard = neighborCard0;
			
			//add the neighborCards to sprite
			for(i=0;i<numCards;++i) {
				nbrCardView = neighborCards[i];
				neighborCard = nbrCardView.neighborCard;
				sp.addChild(neighborCard);
			}
		}
		*/
		
		private function displayNeighbourBar():void{

				
			sp=new Sprite();
			addChild(sp);
			
			maskWidth = Billiards.STAGE_WIDTH*0.55;
			barHeight= Billiards.STAGE_HEIGHT/8;
			neighborBarOffset= UiLayout.TABLE_X+2.5*barHeight;
			maskY= UiLayout.TABLE_Y+UiLayout.TABLE_HEIGHT;
			
			for(var i:int=0;i<neighbors['game_data_uid'].length;++i) {
				var key:String = neighbors['game_data_uid'][i];
				var URL:String = SocialNetworkUtil.getPictureURL(key);
				var status:String=neighbors['presence_status'][i];
				var userFirstName:String = neighbors['game_data_username'][i];
				var buttonText:String=String(neighbors['game_data_uid'][i]).split(":")[1];
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
			var anonNeighborCard:DisplayObjectContainer = createNeighborCard("","Anonymous","ADD","hide");
			anonNeighborCard.width=maskWidth/5;
			anonNeighborCard.height=barHeight;
			anonNeighborCard.x=leftArrow.x - anonNeighborCard.width;
			anonNeighborCard.y=maskY;
			addChild(anonNeighborCard);
			
			// Set the MASK
			sp.mask=maskSp;			
		}
		
		private function sendGameRequest(e:MouseEvent):void{
			//trace(e.target.name);
			if(Billiards.is_Multi_Game)
			{
				var gameId:String=prepareInvite(e.target.name);
				var neighborId:String="1:"+e.target.name;
				trace("The neighbor id is "+neighborId);
				var data:Array=[neighborId,gameId];
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
			++m_index;
			var neighborlist:Array=neighbors['game_data_uid']
			if(m_index>(neighborlist.length-numCards-1)){m_index=neighborlist.length-numCards-1;}
			refreshNeighborCards();
		
		}
		
		private function moveLeft(e:MouseEvent):void{
			--m_index;
		if(m_index<0){m_index=0;}
		refreshNeighborCards();
		
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
