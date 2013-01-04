
package manager
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class ImageCacheManager
	{
		
		
		private static var instance:ImageCacheManager;
		private var pendingDictionaryByLoader:Dictionary = new Dictionary();
		private var pendingDictionaryByURL:Dictionary = new Dictionary();
		private var imageCache:Dictionary = new Dictionary();
		private var callbackMap:Dictionary = new Dictionary();
		private var rectCache:Dictionary = new Dictionary();
		
		public function ImageCacheManager()
		{
		}
		
		public static function getInstance():ImageCacheManager
		{
			if (instance == null)
			{
				instance = new ImageCacheManager();
			}
			
			return instance;
		}
		
		public function getImageLoader(url:String,width:int,height:int,callback:Function): void {
			
			if(imageCache[url] != null){
				callback(url,imageCache[url]);
			} else {
				//return dummy image 
				//callback(imageCache[url])
				addImageToCache(url,width, height, callback);
			}
			
		}
		private  function addImageToCache(url:String,width:int,height:int,callbackFunc:Function): void{
			if(!pendingDictionaryByURL[url]){
				var req:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoadComplete);
				
				loader.load(req);
				
				var lInfo:LoaderData = new LoaderData();
				lInfo.url = url;
				lInfo.callback = callbackFunc as Function;
				lInfo.width = width;
				lInfo.height = height;
				
				pendingDictionaryByLoader[loader] = lInfo;
				pendingDictionaryByURL[url] = true;
				
				//rectCache[url] = new Rectangle(0,0,width,height);
				
				
			}
		}
		private function imageLoadComplete(event:Event):void{
			var loader:Loader = event.currentTarget.loader;
			
			var loaderData:LoaderData = pendingDictionaryByLoader[loader];
			
			var imageInfo:ImageInfo = new ImageInfo();			
			imageInfo.imageData = Bitmap(event.target.content).bitmapData;
			imageInfo.width = loaderData.width;
			imageInfo.height = loaderData.height;
			
			imageCache[loaderData.url] = imageInfo;
			
			loaderData.callback(loaderData.url,imageInfo);
			
			//	var cacheFile:File = new File(imageDir.nativePath +File.separator+ cleanURLString(url));
			//	var stream:FileStream = new FileStream();
			//	stream.open(cacheFile,FileMode.WRITE);
			//stream.writeBytes(loader.data);
			//stream.close();
			delete pendingDictionaryByLoader[loader];
			delete pendingDictionaryByURL[loaderData.url];
			
			
		}
		
		
		/*
		public function getImageLoader(url:String,rect:Rectangle):Loader{
		
		if(imageCache[url] != null){
		return imageCache[url];
		} else {
		//return dummy image 
		//callback(imageCache[url])
		return addImageToCache(url,rect);
		}
		
		}
		private  function addImageToCache(url:String,rect:Rectangle): Loader{
		if(pendingDictionaryByURL[url] == null){
		var req:URLRequest = new URLRequest(url);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoadComplete);
		
		loader.load(req);
		
		pendingDictionaryByLoader[loader] = url;
		pendingDictionaryByURL[url] = loader;
		rectCache[url] = rect;
		
		return loader;
		}else
		{
		return pendingDictionaryByURL[url];
		}
		}
		private function imageLoadComplete(event:Event):void{
		var loader:Loader = event.currentTarget.loader;
		
		var url:String = pendingDictionaryByLoader[loader];
		
		imageCache[url] = loader;
		
		
		loader.content.width = rectCache[url].width;
		loader.content.height = rectCache[url].height;
		loader.content.x=rectCache[url].x;
		loader.content.y=rectCache[url].y;
		
		
		//	var cacheFile:File = new File(imageDir.nativePath +File.separator+ cleanURLString(url));
		//	var stream:FileStream = new FileStream();
		//	stream.open(cacheFile,FileMode.WRITE);
		//stream.writeBytes(loader.data);
		//stream.close();
		delete pendingDictionaryByLoader[loader];
		pendingDictionaryByURL[url] = null;
		delete rectCache[url];
		
		}*/
	}
}
