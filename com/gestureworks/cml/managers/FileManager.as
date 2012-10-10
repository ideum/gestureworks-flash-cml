package com.gestureworks.cml.managers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.gestureworks.cml.loaders.*
	import com.gestureworks.cml.events.*
	import com.gestureworks.cml.utils.*;	
	
	/**
	 * FileManager, Singleton
	 * Manages the loading of external files
	 * @author Charles Veasey
	 */
	public class FileManager extends EventDispatcher
	{
		/**
		 * constructor allow single instance for this Filemanger class
		 * @param	enforcer
		 */
		public function FileManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:FileManager;
		/*
		 * Returns singleton instance
		 */
		public static function get instance():FileManager 
		{ 
			if (_instance == null)
				_instance = new FileManager(new SingletonEnforcer());			
			return _instance; 
		}	
		
		/**
		 * turns on the debug information
		 */
		public var debug:Boolean = true;
		
		/**
		 * number of files in file list
		 */
		public var fileCount:int = 0;
		private var fileQueue:LinkedMap = new LinkedMap;
		/**
		 * list of files that file manager process
		 */
		public var fileList:LinkedMap = new LinkedMap;
		
		/**
		 * number of cml's in cml queue
		 */
		public var cmlCount:int = 0;
		
		/**
		 * list of cml in the queue
		 */
		public var cmlQueue:LinkedMap = new LinkedMap;
		private var cmlLoaded:Boolean = false;
		
		/**
		 * turns off stopped
		 */
		public var stopped:Boolean = false;
		
		// supported file types
		private var imageTypes:RegExp = /^.*\.(png|gif|jpg)$/i;  
		private var	videoTypes:RegExp = /^.*\.(mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;			
		private var	swfType:RegExp = /^.*\.(swf)$/i;
		private var	cmlType:RegExp = /^.*\.(cml)$/i;
		
		private var rendererDataCount:int;
		
		/**
		 * searches the type of file and append to the cml queue
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
		 * process the cml file
		 */
		public function startCMLQueue():void
		{					
			stopped = false;						
			if (cmlLoaded < cmlCount)
				processCMLQueue();
		}
	
		/**
		 * resumes the process
		 */
		public function resumeCMLQueue():void
		{
			stopped = false;

			cmlQueue.currentIndex += 1;			
			startCMLQueue();
		}		
		
		
		/**
		 * start processing the cml files
		 */
		public function startFileQueue():void
		{
			stopped = false;
			processFileQueue();
		}		
		
		/**
		 * stops processing
		 */
		public function stopQueue():void
		{
			stopped = true;
		}
		
		/**
		 * process the cml files in the queue depending on stopped information
		 */
		public function processCMLQueue():void
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

/**
 * class can only be access by the FileManager class only. 
 */
class SingletonEnforcer{}