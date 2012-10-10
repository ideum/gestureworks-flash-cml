package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.element.TextElement;
	import flash.display.DisplayObjectContainer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * TODo
	 * @author 
	 */
	public class CloneUtils 
	{
		/**
		 * constructor
		 */
		public function CloneUtils():void
		{						
			
		}
		
		/**
		 * TODO
		 * @param	source
		 * @return
		 */
		public static function clone(source:*):* 
		{
				
				var cloneObj:*;
				if (source) {
					cloneObj = newInstance(source);
					
					if (cloneObj)
					{
						copyData(source, cloneObj);
					}
				}
				
				if (source is DisplayObjectContainer) {
					if (DisplayObjectContainer(source).numChildren > 0){
						for (var i:int = 0; i < DisplayObjectContainer(source).numChildren; i++) {
							var childClone:* = clone(DisplayObjectContainer(source).getChildAt(i));
							
							if (childClone.hasOwnProperty("displayComplete")) {
								childClone["displayComplete"]();
							}
							
							DisplayObjectContainer(cloneObj).addChild(childClone);
						}
					}
				}
				
				return cloneObj;
		}
		
		/**
		 * TODO
		 * @param	source
		 * @return
		 */
		public static function newInstance(source:*):*
		{
			if (source)
			{
				var instance:*;
				try {
					var sourceClass:Class = getDefinitionByName(getQualifiedClassName(source)) as Class;
					instance = new sourceClass;
				}					
				catch (err:*) { throw new Error(err); }
				
				return instance;
			}
			return null;
		}
		
		/**
		 * TODO
		 * @param	source
		 * @param	destination
		 */
		public static function copyData(source:*, destination:*):void {
			
			if (source && destination)
			{
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					
					for each(prop in sourceInfo.variable)
						destination[prop.@name] = source[prop.@name];							
					
					for each(prop in sourceInfo.accessor)
					{
						if (prop.@access == "readwrite")							
							destination[prop.@name] = source[prop.@name];
					}
				
				}
				catch (err:*) { throw new Error(err); }
			}
		}
		
	}

}