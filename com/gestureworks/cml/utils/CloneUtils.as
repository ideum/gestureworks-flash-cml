package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.components.ImageViewer;
	import com.gestureworks.cml.element.Button;
	import com.gestureworks.cml.element.GestureList;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.ByteArray;
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
			
			//trace(pExclusions);
			
			var cloneObj:*;
			var childClone:DisplayObject;
							
			
			if (source) {
				cloneObj = newInstance(source);
				
				if (cloneObj)
				{
					copyData(source, cloneObj, pExclusions);
				}
			}
			
			
			// add to clone's parent if cloning nested objects
			if (!cloneObj.parent && parent)
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
		 * Copies childlist from input source to destination.
		 * Works from destination's display list, so children must be added to display to copy.
		 * @param	source
		 * @param	destination
		 */
		public static function copyChildList(source:*, destination:*):void 
		{
			
			var arr:Array = source.childList.getKeyArray();
			
			for (var i:int = 0; i < arr.length; i++) 
			{	
				for (var j:int = 0; j < destination.numChildren; j++) 
				{
					if (destination.getChildAt(j)["id"] == arr[i])
						destination.childList.replaceKey(String(arr[i]), destination.getChildAt(j));
				}				
			}			
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
											
						if (!pExclusions || (pExclusions && (pExclusions.indexOf(pName) == -1))) {
														
							if (destination[pName] != source[pName])
								destination[pName] = source[pName];
						}
					}
						
					for each(prop in sourceInfo.accessor) {
						
						pName = String(prop.@name);
						
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
		
		
		public static function deepCopyObject(source:Object):Object
		{			
			var myBA:ByteArray = new ByteArray(); 
			myBA.writeObject(source); 
			myBA.position = 0; 
			return(myBA.readObject()); 	
		}
		
	}
}