package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ElementFactory;
	
	/**
	 * The GestureList class allows you to create a group of 
	 * gestures in CML.
	 * 
	 * <p>It is not intended to be used outside of CML. Use native 
	 * methods of the TouchSprite or TouchContainer to assign 
	 * gestures in AS3.</p>
	 * 
	 * <p>When using this class as a CML tag, a child 
	 * <code>Gesture</code> tag is required.</p>
	 * 
	 * @author Ideum
	 * @see Gesture
	 * @see TouchContainer
	 */
	public class GestureList extends ElementFactory
	{
		/**
		 * Constructor
		 */
		public function GestureList() 
		{
			super();			
		}
		
		private var _gestureList:XMLList;
		/**
		 * sets the gesture list
		 */
		public function get gestureList():XMLList{return _gestureList;}
		public function set gestureList(value:XMLList):void
		{
			if (gestureList === value.Gesture) 
				return;
			
			_gestureList = value.Gesture;
			
			var object:Object = new Object();
			
			for (var i:int; i < gestureList.length(); i++)
			{				
				object[(gestureList[i].@ref).toString()] = gestureList[i].@gestureOn;
			}
			
			var p:* = parent;
			if(p) p.gestureList = object;
		}
			
		/**
		 * parses cml file
		 * @param	cml
		 * @return
		 */
		override public function parseCML(cml:XMLList):XMLList 
		{
			this.gestureList = cml;			
			return new XMLList;
		}	
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			gestureList = null;
		}
	}
}