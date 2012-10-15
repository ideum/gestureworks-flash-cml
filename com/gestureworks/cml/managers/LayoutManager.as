package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.interfaces.IContainer;
	import com.gestureworks.cml.interfaces.ILayout;
	import flash.utils.Dictionary;
	
	/**
	 * The LayoutManager manages global layout definitions.
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.element.Container
	 */	
	public class LayoutManager
	{			
		/**
		 * Constructor
		 * @param	enforcer
		 */
		public function LayoutManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:LayoutManager;
		/**
		 * Returns an instance of the LayoutManager class
		 */
		public static function get instance():LayoutManager 
		{ 
			if (_instance == null)
				_instance = new LayoutManager(new SingletonEnforcer());			
			return _instance; 
		}		
		
		private var _layoutList:Dictionary = new Dictionary(false);
		/**
		 * Returns a dictionary of layouts
		 */
		public function get layoutList():Dictionary{return _layoutList;}
		public function set layoutList(value:Dictionary):void 
		{
			_layoutList = value;
		}
		
        /**
         * Adds the layout to the layout list
         * @param	id layout's id
         * @param	layout must implement ILayout
         */
		public function addLayout(id:String, layout:ILayout):void
		{
			_layoutList[id] = layout;
		}		
				
		/**
		 * Adds the layout to the layoutList
		 * @param	type
		 * @param	container
		 */
		public function layout(id:String, container:IContainer):void
		{	
			_layoutList[id].layout(container);
		}				

	}
}

class SingletonEnforcer{}