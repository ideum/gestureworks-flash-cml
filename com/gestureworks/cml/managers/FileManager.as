package com.gestureworks.cml.managers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.cml.loaders.*
	
	
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
		
		
		public static const CML_LOAD_COMPLETE:String = "CML_LOAD_COMPLETE";						
		public static const LOAD_COMPLETE:String = "LOAD_COMPLETE";				
		
		public var fileCount:int = 0;
		private var fileQueue:LinkedMap = new LinkedMap;
		public var fileList:LinkedMap = new LinkedMap;
		
		public var cmlCount:int = 0;
		private var cmlQueue:LinkedMap = new LinkedMap;
		private var cmlLoaded:Boolean = false;
		
		private var stopped:Boolean = false;
		
		// supported file types
		private var imageTypes:RegExp = /^.*\.(png|gif|jpg)$/i;  
		private var	videoTypes:RegExp = /^.*\.(mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;			
		private var	swfType:RegExp = /^.*\.(swf)$/i;
		private var	cmlType:RegExp = /^.*\.(cml)$/i;
		
		
		
		public function addToQueue(file:String, type:String=null):void
		{
			if (type == "cml" && file.search(cmlType) >= 0 && !cmlQueue.hasKey(file))
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
		
		
		
		
		public function startQueue():void
		{
			trace("START");
			stopped = false;
			
			if (!cmlLoaded && cmlCount > 0)
				processCMLQueue();
			else 
				processFileQueue();
		}
		
		
		
		public function stopQueue():void
		{
			stopped = true;
		}
		
		
		
		private function processCMLQueue():void
		{
			trace("PROCESS CML");
		
			trace(cmlCount);
			
			if (!stopped)
			{
				var file:String = cmlQueue.currentKey;		
				var type:String = cmlQueue.currentValue;
				
				trace(file, type);
								
				if (file)
				{
					if (type == "cml" && file.search(cmlType) >= 0)
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
						
			if (cmlQueue.hasNext())
			{
				cmlQueue.currentIndex += 1;				
				processCMLQueue();
			}
			else
			{
				cmlLoaded = true;
				dispatchEvent(new Event(FileManager.CML_LOAD_COMPLETE, true, true));
			}
		}		
		
		
		

		
		
		private function onFileLoaded(event:Event):void
		{
			trace(event.target, fileQueue.currentKey,  "has finished loading");
			
			if (fileQueue.hasNext())
			{
				fileQueue.currentIndex += 1;				
				processFileQueue();
			}
			else
				dispatchEvent(new Event(FileManager.LOAD_COMPLETE, true, true));
			
		}
		
		
		
		
		
		
	}
	
}

class SingletonEnforcer{}