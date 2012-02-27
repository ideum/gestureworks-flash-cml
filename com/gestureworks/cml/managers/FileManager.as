package com.gestureworks.cml.managers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.cml.loaders.*
	import com.gestureworks.cml.events.*
	
	
	/**
	 * FileManager, Singleton
	 * Manages the loading of external files
	 * @author Charles Veasey
	 */
	public class FileManager extends EventDispatcher
	{
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
			
		public var fileCount:int = 0;
		private var fileQueue:LinkedMap = new LinkedMap;
		public var fileList:LinkedMap = new LinkedMap;
		
		public var cmlCount:int = 0;
		public var cmlQueue:LinkedMap = new LinkedMap;
		private var cmlLoaded:Boolean = false;
		
		public var stopped:Boolean = false;
		
		// supported file types
		private var imageTypes:RegExp = /^.*\.(png|gif|jpg)$/i;  
		private var	videoTypes:RegExp = /^.*\.(mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;			
		private var	swfType:RegExp = /^.*\.(swf)$/i;
		private var	cmlType:RegExp = /^.*\.(cml)$/i;
		
		
		
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
		
		
		
		public function startCMLQueue():void
		{
			trace("START CML");
			stopped = false;						
			if (cmlLoaded < cmlCount)
				processCMLQueue();
		}
		
		
		public function resumeCMLQueue():void
		{
			trace("RESUME CML");
			stopped = false;

			cmlQueue.currentIndex += 1;			
			startCMLQueue();
		}		
		
		
		
		public function startFileQueue():void
		{
			trace("START FILE");
			stopped = false;

			processFileQueue();
		}		
		
		public function stopQueue():void
		{
			stopped = true;
		}
		
		
		public function processCMLQueue():void
		{
			trace("PROCESS CML");
		
						
			if (!stopped)
			{
				var file:String = cmlQueue.currentKey;		
				var type:String = cmlQueue.currentValue;
				trace(file, type);
								
				if (file)
				{
					if (type == "cml" && type&& file.search(cmlType) >= 0)
					{
						CML.getInstance(file).loadCML(file);
						CML.getInstance(file).addEventListener(Event.INIT, onCMLLoaded);
						fileList.append(file, CML.getInstance(file));	
					}
					else if (type == "cmlRenderKit" && type&& file.search(cmlType) >= 0)
					{
						CML.getInstance(file).loadCML(file);
						CML.getInstance(file).addEventListener(Event.INIT, onCMLLoaded);
						fileList.append(file, CML.getInstance(file));	
					}					
				}
			}			
			
		}
		
		
		private function processFileQueue():void
		{
			trace("PROCESS FILE");
			
			if (!stopped)
			{
				var file:String = fileQueue.currentKey;		
				var type:String = fileQueue.currentValue;
				trace(file, type);				
				
				var loader:* = null;
				
				if (file)
				{
					if (type == "swf" && file.search(swfType) >= 0)
					{
						trace(file);
						
						loader = new SWF;
						loader.addEventListener(SWF.FILE_LOADED, onFileLoaded);	
						loader.load(file);
						fileList.append(file, loader);	
					}
					
					else if (type == "img" && file.search(imageTypes) >= 0)
					{
						loader = new IMG;
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
			trace(event.target, cmlQueue.currentKey,  "has finished loading");
			var file:String = cmlQueue.currentKey;				
			var type:String = cmlQueue.currentValue;				

			stopped = true;
			cmlLoaded = true;
			
			dispatchEvent(new FileEvent(FileEvent.CML_LOADED, type, file, true, true));			
		}		
		
		
		

		
		
		private function onFileLoaded(event:Event):void
		{
			trace(event.target, fileQueue.currentKey,  "has finished loading");
			var file:String = fileQueue.currentKey;	
			var type:String = fileQueue.currentValue;	
			
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