package util
{
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	
	import social.AnonNetwork;
	import social.Facebook;
	import social.FacebookMobileWeb;
	import social.SocialNetwork;
	
	
	public class ConfigurationUtil
	{
		private static var instance: ConfigurationUtil;	
		private var dispatcher:IEventDispatcher;
		private var stage: Stage;
		private var parameters:Object;
		private var platform:String;
		private var socialnetwork:SocialNetwork;
		private var w:Number;
		private var h:Number;
		public static var playerpoints:Number;
		public static var PLATFORM_LINUX:String = "LINUX";
		public static var PLATFORM_WINDOWS:String = "WINDOWS";
		public static var PLATFORM_MAC:String = "MAC";
		public static var PLATFORM_ANDROID:String = "ANDROID";
		public static var PLATFORM_WINPHONE:String = "WINPHONE";
		public static var PLATFORM_IOS:String = "iOS";
		public static var DEFAULT_APP_URL:String = "http://crazypool1.herokuapp.com"; 
		public static var DEFAULT_PICPROXY_URL:String = DEFAULT_APP_URL + "/picture.php";
		public static var DEFAULT_GATEWAY_PATH:String = DEFAULT_APP_URL+"/Gateway/";
		public static var DEFAULT_IMAGE_PATH:String = DEFAULT_APP_URL+"/Content/Images";		
		private static var FORCE_MOBILE_LOGIN:Boolean = true;
		private static var FORCE_DPI:Number = -1;
		
		private static var user_id:String;
		private static var token:String;
		
		function ConfigurationUtil(obj: Object) {
			platform = null;
			try {
				if(obj)
					dispatcher = obj as IEventDispatcher;
				if(obj && obj.stage) {
					stage = obj.stage;
				}
				if(obj && obj.root && obj.root.loaderInfo) {
					var original_parameters:Object = (obj.root.loaderInfo as LoaderInfo).parameters;
					parameters = original_parameters;
					try {
						if(ExternalInterface.available)
							parameters = ExternalInterface.call("get_flashvars");
					} catch (e: Error) {
						parameters = original_parameters;
					}
				}
			} catch (e: Error) {
				stage = null;
				parameters = null;
			}
			trace('Application Configuration Initialized');
		}
		
		public static function initializeConfiguration(obj: Object): ConfigurationUtil {
			instance = new ConfigurationUtil(obj);	
			return instance;
		}
		
		public static function getStage(): Stage {
			if(instance && instance.stage)
				return instance.stage;			
			return null;
		}
		
		public static function getWidth(): Number {
			if(instance && instance.w > 0) {
				return instance.w;
			}
			instance.w = 0;
			if(instance && instance.stage) {
				var platform:String = getPlatform();
				if(platform == PLATFORM_IOS) {
					var iosFSW:int = instance.stage.fullScreenWidth;
					var iosW:int = instance.stage.stageWidth;
				/*	if(iosFSW < iosW)
						instance.w = iosFSW;
					else
						 instance.w = iosW; */
					instance.w = instance.stage.fullScreenWidth;
				}
				else if(platform == PLATFORM_ANDROID) {
					instance.w = instance.stage.fullScreenWidth;
				} else {
					var parameters:* = getParameters();
					if(parameters && parameters.user) {
						instance.w = instance.stage.stageWidth;
					} else {
						if(FORCE_MOBILE_LOGIN)
							instance.w = instance.stage.fullScreenWidth;
						else
							instance.w = instance.stage.stageWidth;
					}
				}
			}
			return instance.w;
		}
		
		public static function getHeight(): Number {
			if(instance && instance.h > 0) {
				return instance.h;
			}
			instance.h = 0;
			if(instance && instance.stage) {
				var platform:String = getPlatform();
				if(platform == PLATFORM_IOS) {
					var iosFSH:int = instance.stage.fullScreenHeight;
					var iosH:int = instance.stage.stageHeight;
				/*	if(iosFSH < iosH)
						instance.h = iosFSH;
					else
						instance.h = iosH; */
					instance.h =instance.stage.fullScreenHeight;
				} else if(platform == PLATFORM_ANDROID) {
					instance.h = instance.stage.fullScreenHeight;
				} else {
					var parameters:* = getParameters();
					if(parameters && parameters.user) {
						instance.h = instance.stage.stageHeight;
					} else {
						if(FORCE_MOBILE_LOGIN)
							instance.h = instance.stage.fullScreenHeight;
						else
							instance.h = instance.stage.stageHeight;
					}
				}
			}
			return instance.h;
		}
		
		public static function getHorizontalDPI(): Number {
			if(FORCE_DPI >= 0)
				return FORCE_DPI;
			return Capabilities.screenDPI;
		}
		
		public static function getVerticalDPI(): Number {
			if(FORCE_DPI >= 0)
				return FORCE_DPI;
			return Capabilities.screenDPI;
		}
		
		public static function getMetricWidth(): Number {
			return getWidth()/getHorizontalDPI();
		}
		
		public static function getMetricHeight(): Number {
			return getHeight()/getVerticalDPI();
		}
		
		public static function getPlatform(): String {
			var os:String = Capabilities.os;
			var version:String = Capabilities.version;
			
			os = os.toLowerCase();
			version = version.toLowerCase();
			
			if(instance && instance.platform != null)
				return instance.platform;
			
			var platform:String = null;
			var  anonflag:Boolean= true;
			if(os.indexOf("linux") >= 0) {
				platform = PLATFORM_LINUX;
				anonflag=false; 
				if(version.indexOf("and") >= 0){
					platform = PLATFORM_ANDROID;
					anonflag=true;
				}
			} else if(os.indexOf("windows") >= 0) {
				platform = PLATFORM_WINDOWS;
				anonflag=false;
			
				if(os.indexOf("smartphone") >= 0 ||
					os.indexOf("pocketpc") >= 0 ||
					os.indexOf("cepc") >= 0 ||
					os.indexOf("mobile") >= 0 ||
					os.indexOf("ce") >= 0
				)
					platform = PLATFORM_WINPHONE;	
			} 
			else if(os.indexOf("mac") >= 0) {
				platform = PLATFORM_MAC;
				anonflag=false;
			} else if(os.indexOf("iphone") >= 0) {
				platform = PLATFORM_IOS;
			}
			
			if(instance && instance.platform)
				instance.platform = platform;
			return platform;
		}
		
		public static function getParameters():*
		{
			if(instance && instance.parameters)
				return instance.parameters;
			return null;
		}
		

		public static function getPictureProxy():String
		{
			var picproxy:String = DEFAULT_PICPROXY_URL;
			var parameters:* = getParameters();
			if(parameters && parameters.picproxy) {
				picproxy = parameters.picproxy;
			}
			return picproxy;
		}

		public static function getGateway():String
		{
			var gateway:String = DEFAULT_GATEWAY_PATH;
			var parameters:* = getParameters();
			if(parameters && parameters.gateway) {
				gateway = parameters.gateway;
			}
			return gateway;
		}
		
		public static function set points(pt:Number):void
		{playerpoints=0;
			playerpoints=pt;
		}
		
		public static function useWebWebSocket():Boolean
		{
			var platform:String = ConfigurationUtil.getPlatform();
			if(platform == ConfigurationUtil.PLATFORM_IOS || platform == ConfigurationUtil.PLATFORM_ANDROID) 
				return false;
			var parameters:* = getParameters();
			if(!parameters) {
				return false;
			}
			if(!parameters["user"]) {
				return false;
			}
			if(parameters && parameters["usenativesocket"] != null) {
				return false;
			}
			return true;
		}
	
		public static function get points():Number
		{
			return playerpoints;
		}		
		
		public static function addEventListener(eventtype: String, callback:Function):void
		{
			if(instance && instance.dispatcher) {
				instance.dispatcher.addEventListener(eventtype, callback);
			}
		}
		
		public static function removeEventListener(eventtype: String, callback:Function):void
		{
			if(instance && instance.dispatcher) {
				instance.dispatcher.removeEventListener(eventtype, callback);
			}
		}
		
		public static function dispatchEvent(event: Event):void
		{
			if(event) {
				trace('Dispatching '+event.type);
				if(instance && instance.dispatcher) {
					instance.dispatcher.dispatchEvent(event);
				}
			}			
		}
		public static function getSocialNetworkAnon(cached:Boolean =false):SocialNetwork
		{	
		
				instance.socialnetwork = new AnonNetwork();
				return instance.socialnetwork;
		}
		public static function getSocialNetwork(cached:Boolean =false):SocialNetwork
		{	cached=false;
			
			if(!instance)
				return null;
			if(cached && instance.socialnetwork) {
				return instance.socialnetwork;
			}
			
			else
			{
				var parameters:* = getParameters();
				if(parameters && parameters.user ) {
					instance.socialnetwork = new Facebook();
				} else {
					var platform:String = getPlatform();
					if(platform == PLATFORM_MAC || platform == PLATFORM_WINDOWS || platform == PLATFORM_LINUX) {
						if(FORCE_MOBILE_LOGIN)
							instance.socialnetwork = new FacebookMobileWeb();						
						else
							instance.socialnetwork = new Facebook();						
					} else if(platform == PLATFORM_ANDROID || platform == PLATFORM_IOS || FORCE_MOBILE_LOGIN) {
						instance.socialnetwork = new FacebookMobileWeb();
					}
				}
			}
			return instance.socialnetwork;
		}	
	}
}