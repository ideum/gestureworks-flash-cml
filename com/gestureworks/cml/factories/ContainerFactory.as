package com.gestureworks.cml.factories
{
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import com.gestureworks.events.DisplayEvent;
	
	/**
	 * ContainerFactory create display hierarchies. It keeps track of children through the childlist property.
	 * base class for container 
	 */
	public class ContainerFactory extends ElementFactory
	{
		/**
		 * constructor
		 */
		public function ContainerFactory()
		{
			_childList = new LinkedMap;
		}	
		
		/**
		 * dispose method to nullify child
		 */
		override public function dispose():void
		{
			super.dispose();
			_childList = null;
		}
				
		
		private var _childList:LinkedMap;
		/**
		 * store the child list
		 */
		public function get childList():LinkedMap {return _childList;}	
		
		
		private var _dimensionsTo:String;
		/**
		 * sets the dimensions of the container
		 */
		public function get dimensionsTo():String { return _dimensionsTo ; }
		public function set dimensionsTo(value:String):void
		{
			_dimensionsTo = value;	
		}
		
		/**
		 * This method searches the childlist and add the children
		 */
		public function addAllChildren():void
		{			
			for (var i:int = 0; i < _childList.length; i++) 
			{
				if(childList.getIndex(i) is DisplayObject)
				addChild(_childList.getIndex(i));
			}
		}
		
		private var _infoSource:String = "";
		/**
		 * sets info source
		 */
		public function get infoSource():String{return _infoSource;}
		public function set infoSource(value:String):void{_infoSource = value;}
				
		/**
		 * this method append to the childlist
		 * @param	id
		 * @param	child
		 */
		public function childToList(id:String, child:*):void
		{		
			childList.append(id, child);
		}
		
        /**
         * This method sets the dimensions of childlist
         */
		// called in layoutCML() method of DisplayManager
		public function setDimensionsToChild():void
		{			
			// we can use the keyword dimensionsTo, which specifies from which object to pull the dims
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i).id == dimensionsTo)
				{
					this.width = childList.getIndex(i).width;
					this.height = childList.getIndex(i).height;
				}
			}
			
		}		
		
	}
}