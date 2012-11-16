package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.element.GestureList;
	import com.gestureworks.cml.element.TouchContainer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.events.Event;
	
	/**
	 * The CloneUtils utility creates and returns a copy of an object.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
		var g1:Graphic = new Graphic();
		g1.x = 0;
		g1.shape = "circle";
		g1.radius = "100:
		
		var g2:Graphic = CloneUtils.clone(g1) as Graphic;
		g2.x = 200:
		
		addChild(g1);
		addChild(g2);
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 */
	public class CloneUtils 
	{
		/**
		 * Constructor
		 */
		public function CloneUtils():void { }
		
		
		/**
		 * Returns a clone from the source parameter
		 * @param	source
		 * @return 
		 */
		public static function clone(source:*, parent:DisplayObjectContainer=null, pExclusions:Vector.<String>=null):* 
		{
			
			var cloneObj:*;
			var childClone:DisplayObject;
							
			
			if (source) {
				cloneObj = newInstance(source);
				
				if (cloneObj)
				{
					copyData(source, cloneObj, pExclusions);
				}
			}
			
			if (parent)
				parent.addChild(cloneObj);
			
				
			if (source is DisplayObjectContainer) {
				if (DisplayObjectContainer(source).numChildren > 0){
					for (var i:int = 0; i < DisplayObjectContainer(source).numChildren; i++) {
						
						if (DisplayObjectContainer(source).getChildAt(i).hasOwnProperty("clone"))
							childClone = DisplayObject(DisplayObjectContainer(source).getChildAt(i)["clone"]());
						else
							childClone = clone(DisplayObjectContainer(source).getChildAt(i));
					
						DisplayObjectContainer(cloneObj).addChild(childClone);
											
					}
				}
			}
			
			
			return cloneObj;
		}
		
		

		
		/**
		 * Returns a new object from the source paramter
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
		 * Copies source object data to destination object using the 
		 * AS3 describeType method
		 * @param	source
		 * @param	destination
		 */
		public static function copyData(source:*, destination:*, pExclusions:Vector.<String>=null):void 
		{	
			if (source && destination) {
				
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					var pName:String;
					
					
					for each(prop in sourceInfo.variable) {
						
						pName = String(prop.@name);
						
						if (source is TouchContainer && pExclusions)
							trace(source, pName, (pExclusions.indexOf(pName) == -1));
						else if (source is TouchContainer)
							trace(source, pName);
											
						if (!pExclusions || (pExclusions && (pExclusions.indexOf(pName) == -1))) {
							
							if (destination[pName] != source[pName])
								destination[pName] = source[pName];
						}
					}
						
					for each(prop in sourceInfo.accessor) {
						
						pName = String(prop.@name);
						
						if (source is TouchContainer && pExclusions)
							trace(source, pName, (pExclusions.indexOf(pName) == -1));
						else if (source is TouchContainer)
							trace(source, pName);
						
						
						if (prop.@access == "readwrite") {
							if (!pExclusions || (pExclusions && (pExclusions.indexOf(pName) == -1))) {
								if (destination[pName] != source[pName])
									destination[pName] = source[pName];
							}
						}
					}
				}
				
				catch (err:*) { throw new Error(err); }
			}
		}	
	}
}