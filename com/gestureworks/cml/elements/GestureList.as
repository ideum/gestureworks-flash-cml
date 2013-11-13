package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLObject;
	
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
	public class GestureList extends TouchContainer
	{
		/**
		 * Constructor
		 */
		public function GestureList() 
		{
			super();			
		}
		
		private var _gestureList:Object;
		/**
		 * sets the gesture list
		 */
		override public function get gestureList():Object{return _gestureList;}
		override public function set gestureList(value:Object):void
		{
			if (value == null) {
				_gestureList = null;
				return;
			}
			
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
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_gestureList = null;
		}
	}
}