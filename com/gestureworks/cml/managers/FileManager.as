package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.utils.*;
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
	public class FileManager extends EventDispatcher
	{
		// supported file types
		private var imageTypes:RegExp = /^.*\.(png|gif|jpg)$/i;  
		private var	videoTypes:RegExp = /^.*\.(mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;			
		private var	swfType:RegExp = /^.*\.(swf)$/i;
		private var	cmlType:RegExp = /^.*\.(cml)$/i;
		
		private var rendererDataCount:int;		
		/**
		 * Constructor
		 * @param	enforcer
		 */
		public function FileManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:FileManager;
		/**
		 * Returns an instance of the FileManager class
		 */
		public static function get instance():FileManager 
		{ 
			if (_instance == null)
				_instance = new FileManager(new SingletonEnforcer());			
			return _instance; 
		}	
		
		/**
		 * Turns on the debug information
		 */
		public var debug:Boolean = false;
		
		/**
		 * The number of files in file list
		 */
		public var fileCount:int = 0;
		private var fileQueue:LinkedMap = new LinkedMap;
		/**
		 * The list of files that FileManager processes
		 */
		public var fileList:LinkedMap = new LinkedMap;
		
		/**
		 * The number of CML files in the cml file queue
		 */
		public var cmlCount:int = 0;
		
		/**
		 * The list of CML files in the queue
		 */
		public var cmlQueue:LinkedMap = new LinkedMap;
		private var cmlLoaded:Boolean = false;
		
		/**
		 * Indicates whther the file queue has stopped
		 */
		public var stopped:Boolean = false;
		

		
		/**
		 * Validates the file type and appends to file queue
		 * @param	file - file name
		 * @param	type - type of file
		 */
		public function addToQueue(file:String, type:String=null):void
		{
			if (type == "cml" && file.search(cmlType) >= 0)
			{				
				cmlQueue.append(file, type);				
				cmlCount++;
			}
			
			else if (type == "cmlRenderKit" && file.search(cmlType) >= 0)
			{				
				cmlQueue.append(file, type);			
				cmlCount++;
			}
			
			else if (type == "cmlRendererData" && file.search(cmlType) >= 0)
			{				
				if (cmlQueue.currentIndex + 1 > cmlQueue.length-1)
					cmlQueue.append(file, type);
				else
					cmlQueue.insert(cmlQueue.currentIndex + 1, file, type);	
									
				cmlCount++;
			}				
			
			else if (type == "swf" && file.search(swfType) >= 0 && !fileQueue.hasKey(file))
			{				
				fileQueue.append(file, type);
				fileCount++;
			}
						
			else if (type == "img" && file.search(imageTypes) >= 0 && !fileQueue.hasKey(file))
			{
				fileQueue.append(file, type);
				fileCount++;
			}			
		}
		
		
		/**
		 * Starts processing of the CML file queue
		 */
		public function startCMLQueue():void
		{					
			stopped = false;						
			if (cmlLoaded < cmlCount)
				processCMLQueue();
		}
	
		/**
		 * Resumes processing of the CML file queue
		 */
		public function resumeCMLQueue():void
		{
			stopped = false;

			cmlQueue.currentIndex += 1;			
			startCMLQueue();
		}		
		
		
		/**
		 * Resumes processing of the non-CML file queue
		 */
		public function startFileQueue():void
		{
			stopped = false;
			processFileQueue();
		}		
		
		/**
		 * Stops processing of all file queues
		 */
		public function stopQueue():void
		{
			stopped = true;
		}
		
		/**
		 * Processes the CML files in the queue depending on stopped information
		 */
		private function processCMLQueue():void
		{						
			if (!stopped)
			{
				var file:String = cmlQueue.currentKey;		
				var type:String = cmlQueue.currentValue;
								
				if (file)
				{
					if (type == "cml" && file.search(cmlType) >= 0)
					{
						if (debug)
							trace(StringUtils.printf("\n%4s%s%s", "", "Load nested CML include file: ", file));	
				
						CMLLoader.getInstance(file).loadCML(file);
						CMLLoader.getInstance(file).addEventListener(Event.INIT, onCMLLoaded);
						fileList.append(file, CMLLoader.getInstance(file));	
					}
					else if (type == "cmlRenderKit" && file.search(cmlType) >= 0)
					{
						if (debug)
							trace(StringUtils.printf("\n%4s%s%s", "", "Load nested CML RenderKit file: ", file));							
						
						CMLLoader.getInstance(file).loadCML(file);
						CMLLoader.getInstance(file).addEventListener(Event.INIT, onCMLLoaded);
						fileList.append(file, CMLLoader.getInstance(file));	
					}
					else if (type == "cmlRendererData" && file.search(cmlType) >= 0)
					{	
						if (debug)
							trace(StringUtils.printf("\n%4s%s%s", "", "Load nested CML RendererData file: ", file));	
							
						CMLLoader.getInstance(file).loadCML(file);
						CMLLoader.getInstance(file).addEventListener(Event.INIT, onCMLLoaded);
						fileList.append(file, CMLLoader.getInstance(file));	
					}						
				}
			}			
			
		}
		
		/**
		 * Processes the non-CML files in the queue depending on stopped information
		 */		
		private function processFileQueue():void
		{			
			if (!stopped)
			{
				var file:String = fileQueue.currentKey;		
				var type:String = fileQueue.currentValue;				
				var loader:* = null;
				
				if (file)
				{
					if (type == "swf" && file.search(swfType) >= 0)
					{
						if (debug)
							trace(StringUtils.printf("\n%4s%s%s", "", "Load SWF file: ", file));	
							
						loader = new SWFLoader;
						loader.addEventListener(SWFLoader.FILE_LOADED, onFileLoaded);	
						loader.load(file);
						fileList.append(file, loader);	
					}
					
					else if (type == "img" && file.search(imageTypes) >= 0)
					{
						if (debug)
							trace(StringUtils.printf("\n%4s%s%s", "", "Load IMG file: ", file));						
						
						loader = new IMGLoader;
						loader.addEventListener(Event.COMPLETE, onFileLoaded);	
						loader.load(file);						
						fileList.append(file, loader);
					}	
				}
			}	
		}
		
		
		// TODO: IMPLEMENT UNLOADERS
		
		/**
		 * CML load complete handler
		 * @param	event
		 */	
		private function onCMLLoaded(event:Event):void
		{			
			var file:String = cmlQueue.currentKey;				
			var type:String = cmlQueue.currentValue;				
			
			if (debug)
				trace(StringUtils.printf("%4s%s%s", "", "CML file load complete: ", file));				
			
			stopped = true;
			cmlLoaded = true;
			
			dispatchEvent(new FileEvent(FileEvent.CML_LOADED, type, file, true, true));			
		}		
		
		/**
		 * Non-CML file load complete handler
		 * @param	event
		 */			
		private function onFileLoaded(event:Event):void
		{
			var file:String = fileQueue.currentKey;	
			var type:String = fileQueue.currentValue;	
			
			if (debug)
				trace(StringUtils.printf("%4s%s%s", "", "External file load complete: ", file));				
			
			if (fileQueue.hasNext())
			{
				fileQueue.currentIndex += 1;				
				processFileQueue();
			}
			else
				dispatchEvent(new FileEvent(FileEvent.FILES_LOADED, type, file, true, true));
			
		}
		
	}
}

class SingletonEnforcer{}