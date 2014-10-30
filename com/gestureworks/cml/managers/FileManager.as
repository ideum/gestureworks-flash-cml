package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.greensock.events.TweenEvent;
	import com.greensock.loading.core.LoaderCore;
	import com.greensock.loading.data.SWFLoaderVars;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.CSSLoader;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.VideoLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	/**
	 * The FileManager handles the loading of all external files.
	 * 
	 * <p>The FileManager is used by the CMLParser to preload 
	 * external files. It supports the following file types:
	 * <ul>
	 * 	<li>png</li>
	 * 	<li>gif</li>
	 * 	<li>jpg</li>
	 * 	<li>mpeg-4</li>
	 * 	<li>mp4</li>
	 * 	<li>m4v</li>
	 * 	<li>3gpp</li>
	 * 	<li>mov</li>
	 * 	<li>flv</li>
	 *  <li>f4v</li>
	 * 	<li>swf</li>
	 * 	<li>cml</li>
	 * 	<li>svg</li>
	 * </ul></p> 
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.loaders.CSSManager
	 */
	public class FileManager
	{
		// supported file types
		public static var audioType:RegExp = /^.*\.(mp3|wav|)$/i;		
		public static var imageType:RegExp = /^.*\.(png|gif|jpg)$/i;  
		public static var videoType:RegExp = /^.*\.(mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;			
		public static var swfType:RegExp = /^.*\.(swf)$/i;
		public static var swcType:RegExp = /^.*\.(swc)$/i;
		public static var cmlType:RegExp = /^.*\.(cml)$/i;
		public static var cssType:RegExp = /^.*\.(css)$/i;
		public static var mp3Type:RegExp = /^.*\.(mp3)$/i;
		public static var fileTypes:RegExp = /^.*\.(xml|css|cml|swf|mp3|wav|png|gif|jpg|mpeg-4|mp4|m4v|3gpp|mov|flv|f4v|svg)$/i;
		public static var mediaTypes:RegExp = /^.*\.(mp3|wav|png|gif|jpg|mpeg-4|m4v|3gpp|mov|flv|f4v)$/i;
		public static var mediaPreloadTypes:RegExp = /^.*\.(png|gif|jpg|mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;
		public static var libraryTypes:RegExp = /^.*\.(swf|swc)$/i;
		
		public static var cml:LoaderMax = new LoaderMax({name:"cml", onProgress:onProgress, onComplete:onComplete, onError:onError});
		public static var css:LoaderMax = new LoaderMax( { name:"css", onProgress:onProgress, onComplete:onComplete, onError:onError } );
		public static var swf:LoaderMax = new LoaderMax({name:"swf", onProgress:onProgress, onComplete:onComplete, onError:onError});		
		public static var media:LoaderMax = new LoaderMax({name:"media", onProgress:onProgress, onComplete:onComplete, onError:onError});
		
		public static var fileList:LinkedMap = new LinkedMap;
		public static function get fileCount():Number { return fileList.length; }
		public static function hasFile(file:String):Boolean { return fileList.hasKey(file) }
		
		private static var swfLoaderContext:LoaderContext;
		private static var swfLoaderVars:SWFLoaderVars;
		
		/**
		 * Turns on the debug information
		 */
		public static var debug:Boolean = false;
		
		/**
		 * 
		 */		
		public static function init():void 
		{
			swfLoaderContext = new LoaderContext(false);
			swfLoaderContext.allowCodeImport = true;
			swfLoaderContext.applicationDomain = ApplicationDomain.currentDomain;	
			
			LoaderMax.registerFileType("cml", XMLLoader);
			LoaderMax.activate([ImageLoader, SWFLoader, XMLLoader, MP3Loader, CSSLoader, DataLoader, BinaryDataLoader, VideoLoader]);
		}
		
		/**
		 * Returns true if the given file path is a media type
		 */
		public static function isMedia(file:String):Boolean
		{
			return file.search(mediaTypes) != -1;
		}		

		/**
		 * Returns true if the given file path is a preloaded media type
		 */		
		public static function isPreloadMedia(file:String):Boolean
		{
			return file.search(mediaPreloadTypes) != -1;
		}	
		
		/**
		 * Returns true if the given file path is a cml type
		 */
		public static function isCML(file:String):Boolean
		{
			return file.search(cmlType) != -1;
		}
		
		/**
		 * Returns true if the given file path is a cml type
		 */
		public static function isCSS(file:String):Boolean
		{
			return file.search(cssType) != -1;
		}		
				
		/**
		 * Returns true if the given file path is a library type
		 */
		public static function isLibrary(file:String):Boolean
		{
			return file.search(libraryTypes) != -1;
		}		
		
		/**
		 * Appends to file queue
		 * @param	file - file name
		 */
		public static function append(file:String):LoaderCore
		{
			var loader:LoaderCore = LoaderMax.parse(file, { autoPlay:false });
			loader.name = file;
			if (isCML(file))
				cml.append(loader);
			else if (isCSS(file))
				css.append(loader);
			else if (isLibrary(file)) {
				SWFLoader(loader).vars = { context:swfLoaderContext };
				swf.append(loader);
			}
			else if (isPreloadMedia(file))
				media.append(loader);
			
			fileList.append(file, loader);	
			return loader;
		}
		
		private static function onProgress(e:LoaderEvent):void
		{
			dispatchEvent(e);
		}
		
		private static function onComplete(e:LoaderEvent):void
		{
			dispatchEvent(e);
		}
		
		private static function onError(e:LoaderEvent):void
		{
			dispatchEvent(e);
		}
				
		
		// IEventDispatcher
        private static var _dispatcher:EventDispatcher = new EventDispatcher();
        public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
            _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public static function dispatchEvent(event:Event):Boolean {
            return _dispatcher.dispatchEvent(event);
        }
        public static function hasEventListener(type:String):Boolean {
            return _dispatcher.hasEventListener(type);
        }
        public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            _dispatcher.removeEventListener(type, listener, useCapture);
        }
        public static function willTrigger(type:String):Boolean {
            return _dispatcher.willTrigger(type);
        }			
	}
}
