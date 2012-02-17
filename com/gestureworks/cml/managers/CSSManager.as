package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.loaders.CSS;
	import com.gestureworks.cml.core.CMLObjectList;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.StyleSheet;
	
	/**
	 * ... 
	 * @authors Charles Veasey & Matthew Valverde
	 */
	
	public class CSSManager extends EventDispatcher
	{
		
		public function CSSManager(stylePath:String)
		{
			CSS.getInstance("style").loadStyle(stylePath);
			CSS.getInstance("style").addEventListener(CSS.INIT, onStyleLoad);
		}
		
		private function onStyleLoad(e:Event):void
		{
			e.target.removeEventListener(CSS.INIT, onStyleLoad);
			
			// add styles to objects --------------------------------------			
			var styleData:StyleSheet = CSS.getInstance("style").data;
			
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
			
			//parse class selectors first
			for (i=0; i<ClassSelectors.length; i++)
			{
				targetClass = ClassSelectors[i].substring(1, ClassSelectors[i].length);
				for (j=0; j<CMLObjectList.instance.length; j++)
				{
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
			
			//parse id selectors last, so they overwrite class selectors
			for (i=0; i<IdSelectors.length; i++)
			{
				targetId = IdSelectors[i].substring(1, IdSelectors[i].length);				
				if (CMLObjectList.instance.hasKey(targetId))
				{					
					properties = styleData.getStyle(IdSelectors[i]);				
					
					for (property in properties)
					{									
						if (CMLObjectList.instance.getKey(targetId).hasOwnProperty(property))
							CMLObjectList.instance.getKey(targetId)[property] = properties[property];
					}					
				}
			}
			
		}
	}
}