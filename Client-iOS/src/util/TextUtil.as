package util
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TextUtil
	{
		
		public static function getTextFormat(size:int = 18, font:String = "arial"): TextFormat {
			var textformat:TextFormat = new TextFormat();
			textformat.font = font;
			textformat.size = size;	
			return textformat;
		}
		
		public static function getTextField(text:String, textformat:TextFormat = null): TextField {
			var textField:TextField = new TextField();
			textField.text = text;
			textField.textColor = ColorUtil.makeColor(255, 255, 255);
			textField.selectable = false;
			textField.autoSize=TextFieldAutoSize.LEFT;
			try {
				if(textformat == null) {
					textformat = getTextFormat();
				}
				textField.setTextFormat(textformat);
			} catch (e: Error) {
				
			}
			return textField;
		}		
	}
}