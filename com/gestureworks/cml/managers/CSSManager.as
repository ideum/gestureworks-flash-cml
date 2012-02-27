package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.loaders.CSS;
	import com.gestureworks.cml.core.CMLObjectList;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.StyleSheet;
	import com.gestureworks.cml.events.FileEvent;
	
	/**
	 * CSSManager, Singleton 
	 * @authors Charles Veasey
	 */
	
	public class CSSManager extends EventDispatcher
	{
		
		public var file:String;
		

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
			file = filePath;
			CSS.getInstance(file).loadStyle(file);
			CSS.getInstance(file).addEventListener(FileEvent.CSS_LOADED, onCSSLoad);			
		}
		
		private function onCSSLoad(event:Event):void
		{
			trace("_______________________________________");
			
			event.target.removeEventListener(FileEvent.CSS_LOADED, onCSSLoad);
			dispatchEvent(new FileEvent(FileEvent.CSS_LOADED, "css", file));

		}
		
		public function parseCSS():void
		{
			// add styles to objects --------------------------------------			
			var styleData:StyleSheet = CSS.getInstance(file).data;
			
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
										CMLObjectList.instance.getIndex(j)[property] = properties[property];
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
									CMLObjectList.instance.getIndex(j)[property] = properties[property];
							}					
						}
					}
				}	
			}
			
			
		}
	}
}

class SingletonEnforcer{}