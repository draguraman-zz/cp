package social
{
	import com.facebook.graph.FacebookMobile;
	import com.facebook.graph.data.FacebookSession;
	
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import util.ConfigurationUtil;
	//import util.LogUtil;
	
	public class FacebookMobileWeb extends Facebook
	{
		
		public override function login():void
		{
			trace('Running MobileWebFBClient');
			FacebookMobile.init(FACEBOOK_APP_ID, onInitialized);
		}
		
		public override function logout():void
		{
			FacebookMobile.logout();
			
			super.logout();
			
		}
		
		
		protected function onInitialized(success:Object = null, fail:Object = null):void {
			if(!success) {
				var w:int = ConfigurationUtil.getWidth();
				var h:int = ConfigurationUtil.getHeight();
				var facebookView:StageWebView = new StageWebView();
				facebookView.viewPort = new Rectangle(0, 0, w, h);
				facebookView.stage = ConfigurationUtil.getStage();
				FacebookMobile.login(onInitialized, ConfigurationUtil.getStage(), FACEBOOK_PERMISSIONS_ARRAY, facebookView);
			} else {
				onLoggedInData(success, fail);
			}
		}
		
		protected function onLoggedInData(success:Object = null, fail:Object = null): void {
			if(success) {
				var fsuccess:FacebookSession = success as FacebookSession;
				var username:String = fsuccess.user.name;
				var userid:String =  SN_PREFIX+fsuccess.uid;
				usertoken = fsuccess.accessToken;
				onLoggedIn(userid, username, usertoken, true);
			} else {
				trace('Error Occured: '+fail.error);
			}
		}
		
	}
}
