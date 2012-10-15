package com.gestureworks.cml.utils 
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
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
		public function CloneUtils():void {}
		
		/**
		 * Returns a clone from the source parameter
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