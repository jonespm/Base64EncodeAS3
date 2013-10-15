package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Loader;
	import mx.events.FlexEvent;
	import flash.external.ExternalInterface;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.system.Security;
	import flash.utils.getTimer;
	//Uses http://www.sociodox.com/base64.html for performance
	import com.sociodox.utils.Base64;
	
	/**
	 * ...
	 * @author Matthew Jones
	 * This class essentially is a replacement for canvas/base64 image conversion for flash
	 *
	 */
	public class Main extends Sprite
	{
		private var loader:Loader;
		//File size limit, a 10 MB file takes about 15 seconds
		private var fileLimit:int = 10 * 1024 * 1024;
		public function Main():void
		{
			trace("Main()");
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			// entry point
			trace("init()");
			//For FireFox
			Security.allowDomain("*");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			ExternalInterface.addCallback("readImage", readImage)
			
		}
		
		protected function readImage(url:String):void
		{
			trace("readImage()");
			//Set up a new loader
			loader = new Loader();
			//When it's complete do this
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			if (url)
			{
				loader.load(new URLRequest(url));
			}
		}
		
		public function loadComplete(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
			var fileSize:int = e.target.bytesTotal;
			trace("File size is " + e.target.bytesTotal);
			if (fileSize > fileLimit) {
				ExternalInterface.call("flashError", "limitExceeded");
				return;
			}
			
			//Might want to verify it actually is a bitmap
			var bmd:BitmapData = Bitmap(e.target.content).bitmapData;
			trace("A" + getTimer());
			var ba:ByteArray = bmd.getPixels(new Rectangle(0, 0, bmd.width, bmd.height));
			trace("B" + getTimer());
			var encoded:String = Base64.encode(ba);
			trace("C" + getTimer());
			//Update the Url in the javascript
			ExternalInterface.call("updateUrl", encoded);
		}
	
	}

}