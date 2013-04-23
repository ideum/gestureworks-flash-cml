package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.utils.*;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * The FileManager handles the loading of all external files with 
	 * exception of CSS files. 
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
	 * 	<li>swf</li>
	 * 	<li>cml</li>
	 * </ul></p> 
	 * 
	 * @author Charles
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
		public static var mp3Type:RegExp = /^.*\.(mp3)$/i;
		public static var fileTypes:RegExp = /^.*\.(xml|css|cml|swf|mp3|wav|png|gif|jpg|mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;
		public static var mediaTypes:RegExp = /^.*\.(mp3|wav|png|gif|jpg|mpeg-4|m4v|3gpp|mov|flv|f4v)$/i;
		public static var mediaPreloadTypes:RegExp = /^.*\.(png|gif|jpg|mp3)$/i;
		public static var libraryTypes:RegExp = /^.*\.(swf|swc)$/i;
		

		public function FileManager() { }
		
		// legacy support, when FileManager was a singleton
		private static var _instance:*;
		public static function get instance():* { 
			return FileManager;	
		}
		
		public static var fileList:LinkedMap = new LinkedMap;
		private static var first:Boolean = true;
		
		/**
		 * Turns on the debug information
		 */
		public static var debug:Boolean = false;
		
		/**
		 * The number of files in file list
		 */
		public static var fileCount:int;
		
		
		/**
		 * Indicates whther the file queue has stopped
		 */
		public static var stopped:Boolean = false;
		
		
		/**
		 *  
		 */
		public static function isMedia(file:String):Boolean
		{
			return file.search(mediaTypes) != -1;
		}		

		/**
		 *  
		 */		
		public static function isPreloadMedia(file:String):Boolean
		{
			return file.search(mediaPreloadTypes) != -1;
		}	
		
		/**
		 *  
		 */
		public static function isCML(file:String):Boolean
		{
			return file.search(fileTypes) != -1;
		}		
				
		
		

		/**
		 *  
		 */
		public static function isLibrary(file:String):Boolean
		{
			return file.search(libraryTypes) != -1;
		}	
		
				
		/**
		 * 
		 */
		public static function hasFile(file:String):Boolean
		{
			return fileList.hasKey(file);
		}		
		
		/**
		 * Appends to file queue
		 * @param	file - file name
		 */
		public static function addToQueue(file:String):void
		{
			fileList.append(file, null);
			fileCount++;			
		}
		
		/**
		 * Resets file queue
		 */
		public static function resetQueue():void
		{
			fileList.reset();
		}	
		
		/**
		 * Starts file queue
		 */
		public static function startQueue():void
		{
			stopped = false;
			processFileQueue();
		}		
		
		/**
		 * Stops file queue
		 */
		public static function stopQueue():void
		{
			stopped = true;
		}

		
		/**
		 * Processes file queue
		 */		
		private static function processFileQueue():void
		{
			if (stopped) 
				return;
			
			var file:String;
			
			if (first) 
				file = fileList.key;
			else if (fileList.hasNext()) {
				fileList.next();
				file = fileList.key;
			}
			else 
				return;
				
			var loader:* = null;
			
			if (file) {
				if (file.search(cmlType) >= 0) {
					CMLLoader.getInstance(file).load(file);
					CMLLoader.getInstance(file).addEventListener(CMLLoader.COMPLETE, onFileLoaded);
				}					
				
				else if (file.search(swfType) >= 0) {							
					loader = new SWFLoader;
					loader.addEventListener(SWFLoader.COMPLETE, onFileLoaded);	
					loader.load(file);
				}
				
				else if (file.search(mediaPreloadTypes) >= 0) {
					loader = new IMGLoader;
					loader.addEventListener(IMGLoader.COMPLETE, onFileLoaded);	
					loader.load(file);						
				}
				
				else if (file.search(mp3Type) >= 0) {
					loader = new MP3Loader;
					loader.addEventListener(MP3Loader.COMPLETE, onFileLoaded);	
					loader.load(file);						
				}
				else {
					dispatchEvent(new FileEvent(FileEvent.FILE_LOADED, null, null, false, false));						
				}				
				
			}
			first = false;
		}
		
			
		/**
		 * File load complete callback
		 * @param	event
		 */			
		private static function onFileLoaded(e:Event):void
		{
			var file:String = fileList.key;

			if (file.search(FileManager.cmlType) >= 0) {
				CMLLoader.getInstance(file).removeEventListener(CMLLoader.COMPLETE, onFileLoaded);
				fileList.replaceKey(file, CMLLoader.getInstance(file).data);
				dispatchEvent(new FileEvent(FileEvent.FILE_LOADED, fileList.key, fileList.value, false, false));					
			}		
			else {
				fileList.replaceKey(file, e.target.loader);
				dispatchEvent(new FileEvent(FileEvent.FILE_LOADED, fileList.key, fileList.value, false, false));
			}
			
			if (fileList.hasNext())				
				processFileQueue();
			else	
				dispatchEvent(new FileEvent(FileEvent.FILES_LOADED, null, null, false, false));
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
