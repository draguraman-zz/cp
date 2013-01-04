package util
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	public class DisplayUtil
	{
		public static var ANGLE_NORMAL:int = 0;
		public static var ANGLE_ROTATED:int = 90;
		public static var ANGLE_INVERTED:int = 180;
		public static var ANGLE_ROTATED_INVERTED:int = 270;
		
		public static var SCALEMODE_FIT_MIN:int = 0;
		public static var SCALEMODE_FIT_COVER:int = 1;
		public static var SCALEMODE_FIT_WIDTH_PROPORTIONAL:int = 2;
		public static var SCALEMODE_FIT_HEIGHT_PROPORTIONAL:int = 3;
		public static var SCALEMODE_FIT_WIDTH:int = 4;
		public static var SCALEMODE_FIT_HEIGHT:int = 5;
		
		public static function isLandScape(displayobject: DisplayObject): Boolean {
			var width:int = displayobject.width;
			var height:int = displayobject.height;
			if(width > height)
				return true;
			return false;
		}
		
		//Flip a Movie
		public static function flipped(displayobject: DisplayObject, hflip:Boolean = false, vflip:Boolean = false): DisplayObject {
			if(displayobject == null)
				return null;
			if(!hflip && !vflip)
				return displayobject;
			if(hflip) {
				displayobject.scaleX = -displayobject.scaleX;
			}
			if(vflip) {
				displayobject.scaleY = -displayobject.scaleY;
			}
			return displayobject;
		}
		
		//Angle is Counterclockwise Angle
		public static function rotated(displayobject:DisplayObject, angleCounterClock:Number = 0): DisplayObject {
			if(displayobject == null)
				return null;
			while(angleCounterClock < 0) {
				angleCounterClock += 360;
			}
			angleCounterClock %= 360;
			if(angleCounterClock == ANGLE_NORMAL)
				return displayobject;
			angleCounterClock = 360 - angleCounterClock;
			displayobject.rotation += angleCounterClock;
			return displayobject;
		}
		
		private static function scaled_Fit_Min(displayobject: DisplayObject, maxwidth: Number = -1, maxheight: Number = -1): DisplayObject
		{
			if(displayobject == null)
				return null;
			var nwidth:Number;
			var nheight:Number;
			var owidth:Number = displayobject.width;
			var oheight:Number = displayobject.height;
			if(maxwidth < 0)
				maxwidth = owidth;
			if(maxheight < 0)
				maxheight = oheight;
			var mindim:Number = Math.min(maxwidth, maxheight);
			if(owidth >= oheight) { //Landscape Picture.
				nwidth = mindim;
				nheight = (nwidth*oheight)/owidth;
			} else { //Portrait
				nheight = mindim;
				nwidth = (nheight*owidth)/oheight;
			}
			var nwscale:Number = Number(nwidth * displayobject.scaleX) / Number(owidth);
			var nhscale:Number = Number(nheight * displayobject.scaleY) / Number(oheight);
			displayobject.scaleX = nwscale;
			displayobject.scaleY = nhscale;			
			if(displayobject is Bitmap) {
				(displayobject as Bitmap).smoothing = true;
			}
			return displayobject;			
		}
		
		private static function scaled_Fit_Cover(displayobject: DisplayObject, maxwidth: Number = -1, maxheight: Number = -1): DisplayObject
		{
			if(displayobject == null)
				return null;
			var nwidth:Number;
			var nheight:Number;
			var owidth:Number = displayobject.width;
			var oheight:Number = displayobject.height;
			if(maxwidth < 0)
				maxwidth = owidth;
			if(maxheight < 0)
				maxheight = oheight;
			var maxdim:Number = Math.max(maxwidth, maxheight);
			if(maxwidth >= maxheight) { //Landscape Picture.
				if(owidth >= oheight) {					
					nheight = maxdim;
					nwidth = (nheight*owidth)/oheight;
				} else {
					nwidth = maxdim;
					nheight = (nwidth*oheight)/owidth;					
				}					
			} else { //Portrait
				if(owidth >= oheight) {
					nwidth = maxdim;
					nheight = (nwidth*oheight)/owidth;										
				} else {
					nheight = maxdim;
					nwidth = (nheight*owidth)/oheight;					
				}
			}
			var nwscale:Number = Number(nwidth * displayobject.scaleX) / Number(owidth);
			var nhscale:Number = Number(nheight * displayobject.scaleY) / Number(oheight);
			displayobject.scaleX = nwscale;
			displayobject.scaleY = nhscale;	
			if(displayobject is Bitmap) {
				(displayobject as Bitmap).smoothing = true;
			}
			return displayobject;
		}
		
		
		private static function scaled_Fit_Height(displayobject: DisplayObject, maxheight: Number = -1): DisplayObject
		{
			if(displayobject == null)
				return null;
			var nheight:Number;
			var oheight:Number = displayobject.height;
			if(maxheight < 0)
				maxheight = oheight;
			nheight = maxheight;
			var nhscale:Number = Number(nheight * displayobject.scaleY) / Number(oheight);
			displayobject.scaleY = nhscale;			
			if(displayobject is Bitmap) {
				(displayobject as Bitmap).smoothing = true;
			}
			return displayobject;
		}
		
		private static function scaled_Fit_Height_Proportional(displayobject: DisplayObject, maxheight: Number = -1): DisplayObject
		{
			if(displayobject == null)
				return null;
			var nheight:Number;
			var oheight:Number = displayobject.height;
			if(maxheight < 0)
				maxheight = oheight;
			nheight = maxheight;
			var nhscale:Number = Number(nheight * displayobject.scaleY) / Number(oheight);
			var nwscale:Number = nhscale;
			displayobject.scaleX = nwscale;			
			displayobject.scaleY = nhscale;			
			if(displayobject is Bitmap) {
				(displayobject as Bitmap).smoothing = true;
			}
			return displayobject;
		}
		
		private static function scaled_Fit_Width(displayobject: DisplayObject, maxwidth: Number = -1): DisplayObject
		{
			if(displayobject == null)
				return null;
			var nwidth:Number;
			var owidth:Number = displayobject.width;
			if(maxwidth < 0)
				maxwidth = owidth;
			nwidth = maxwidth;
			var nwscale:Number = Number(nwidth * displayobject.scaleX) / Number(owidth);
			displayobject.scaleX = nwscale;			
			if(displayobject is Bitmap) {
				(displayobject as Bitmap).smoothing = true;
			}
			return displayobject;
		}
		
		private static function scaled_Fit_Width_Proportional(displayobject: DisplayObject, maxwidth: Number = -1): DisplayObject
		{
			if(displayobject == null)
				return null;
			var nwidth:Number;
			var owidth:Number = displayobject.width;
			if(maxwidth < 0)
				maxwidth = owidth;
			nwidth = maxwidth;
			var nwscale:Number = Number(nwidth * displayobject.scaleX) / Number(owidth);
			var nhscale:Number = nwscale;
			displayobject.scaleX = nwscale;		
			displayobject.scaleY = nhscale;
			if(displayobject is Bitmap) {
				(displayobject as Bitmap).smoothing = true;
			}
			return displayobject;
		}
		
		public static function scaled(displayobject: DisplayObject, maxwidth: Number = -1, maxheight: Number = -1, scalemode:int = -1): DisplayObject {
			if(scalemode < 0)
				scalemode = SCALEMODE_FIT_MIN;
			if(scalemode == SCALEMODE_FIT_MIN) 
			{
				return scaled_Fit_Min(displayobject, maxwidth, maxheight)
			} else if(scalemode == SCALEMODE_FIT_WIDTH_PROPORTIONAL) {
				return scaled_Fit_Width_Proportional(displayobject, maxwidth);					
			} else if(scalemode == SCALEMODE_FIT_HEIGHT_PROPORTIONAL) {
				return scaled_Fit_Height_Proportional(displayobject, maxheight);					
			} else if(scalemode == SCALEMODE_FIT_WIDTH) {
				return scaled_Fit_Width(displayobject, maxwidth);					
			} else if(scalemode == SCALEMODE_FIT_HEIGHT) {
				return scaled_Fit_Height(displayobject, maxheight);					
			} else if(scalemode == SCALEMODE_FIT_COVER) {
				return scaled_Fit_Cover(displayobject, maxwidth, maxheight)
			}
			return displayobject;
		}
		
		public static function scaledInchesPos(pixdim:Number = 0): Number {			
			return pixdim * ConfigurationUtil.getHorizontalDPI();
		}
		
		public static function scaledInches(displayobject: DisplayObject, maxwidth: Number = -1, maxheight: Number = -1, scalemode:int = -1): DisplayObject {
			var pmaxwidth:Number = maxwidth;
			var pmaxheight:Number = maxheight;
			pmaxwidth = maxwidth * ConfigurationUtil.getHorizontalDPI();
			pmaxheight = maxheight * ConfigurationUtil.getVerticalDPI();
			return scaled(displayobject, pmaxwidth, pmaxheight, scalemode);
		}
		
		public static function scaledCmPos(pixdim:Number = 0): Number {			
			return scaledInchesPos(pixdim*0.3937);
		}
		
		public static function scaledCm(displayobject: DisplayObject, maxwidth: Number = -1, maxheight: Number = -1, scalemode:int = -1): DisplayObject {
			return scaledInches(displayobject, maxwidth*0.3937, maxheight*0.3937, scalemode);
		}
		
		public static function scaledFactor(factor:Number,scale:Number):Number {
			return factor * scale;
		}
		
	}
}