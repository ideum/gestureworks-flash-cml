package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.loaders.CSSLoader;
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.utils.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.StyleSheet;
	import com.gestureworks.cml.events.FileEvent;
	import com.gestureworks.cml.loaders.CSSLoader;
	
	/**
	 * Singleton 
	 * @authors Charles Veasey
	 */
	
	public class CSSManager extends EventDispatcher
	{
		public var file:String;
		public var debug:Boolean = false;

		private static var _instance:CSSManager;
		public static function get instance():CSSManager 
		{ 
			if (_instance == null)
				_instance = new CSSManager(new SingletonEnforcer());			
			return _instance; 
		}
		
		
		public function CSSManager(enforcer:SingletonEnforcer){}
				
		
		public function loadCSS(filePath:String):void
		{
			trace("Filepath: ", filePath);
			file = filePath;
			CSSLoader.getInstance(file).loadStyle(file);
			CSSLoader.getInstance(file).addEventListener(FileEvent.CSS_LOADED, onCSSLoad);			
		}
		
		private function onCSSLoad(event:Event):void
		{			
			event.target.removeEventListener(FileEvent.CSS_LOADED, onCSSLoad);
			dispatchEvent(new FileEvent(FileEvent.CSS_LOADED, "css", file));
		}
		
		public function parseCSS():void
		{
			if (debug)
			{
				trace(StringUtils.printf("\n%4sBegin CSS parsing\n", ""));
				trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s", "", "cmlIndex", "target", "property", "value"));						
				trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s", "", "--------", "------", "--------", "-----"));						
			}
			
			// add styles to objects --------------------------------------			
			var styleData:StyleSheet = CSSLoader.getInstance(file).data;
			
			var IdSelectors:Array = [];
			var ClassSelectors:Array = [];
			var i:int=0;
			var j:int=0;
			var selector:String;
			
			//seperate id and class selectors
			for (i=0; i<styleData.styleNames.length; i++)
			{	
				selector = styleData.styleNames[i]
					
				if (selector.charAt(0) == "#")
					IdSelectors.push(selector);
				else if (selector.charAt(0) == ".")
					ClassSelectors.push(selector);
			}
			
			var properties:Object;
			var property:String;
			var targetClass:String

			for (j=0; j<CMLObjectList.instance.length; j++)
			{
				if (CMLObjectList.instance.getIndex(j).hasOwnProperty("class_"))
				{
					//parse class selectors first
					for (i=0; i<ClassSelectors.length; i++)
					{
						targetClass = ClassSelectors[i].substring(1, ClassSelectors[i].length);

						if (CMLObjectList.instance.getIndex(j).hasOwnProperty("class_"))
						{						
							if (CMLObjectList.instance.getIndex(j).class_ == targetClass)
							{						
								properties = styleData.getStyle(ClassSelectors[i]);				
								for (property in properties)
								{									
									if (CMLObjectList.instance.getIndex(j).hasOwnProperty(property))
									{
										if (debug)
											trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s", "", j, ClassSelectors[i], property,  properties[property]));						
										
										if (properties[property] == "false")
											properties[property] = false;
										else if (properties[property] == "true")
											properties[property] = true;
											
										CMLObjectList.instance.getIndex(j)[property] = properties[property];
									}	
								}
							}
						}	
					}	
				}			
		
				var targetId:String;
				
				if (CMLObjectList.instance.getIndex(j).hasOwnProperty("id"))
				{
					//parse id selectors last, so they overwrite class selectors
					for (i=0; i<IdSelectors.length; i++)
					{
						targetId = IdSelectors[i].substring(1, IdSelectors[i].length);
						
						if (CMLObjectList.instance.getIndex(j).id == targetId)
						{					
							properties = styleData.getStyle(IdSelectors[i]);				
							
							for (property in properties)
							{									
								if (CMLObjectList.instance.getIndex(j).hasOwnProperty(property))
								{
									if (debug)
										trace(StringUtils.printf("%8s %-10s %-20s %-20s %-20s", "", j, IdSelectors[i], property,  properties[property]));									
									
									if (properties[property] == "false")
										properties[property] = false;
									else if (properties[property] == "true")
										properties[property] = true;										
										
									CMLObjectList.instance.getIndex(j)[property] = properties[property];
								}	
							}					
						}
					}
				}	
			}
			
			
		}
	}
}

class SingletonEnforcer{}