package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.interfaces.IContainer;
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.cml.interfaces.ILayout;	

	import flash.utils.Dictionary;

	
	/**
	 * LayoutManager, Singleton
	 * Manages layout routines
	 * 
	 * @authors Charles Veasey and Paul Lacey
	 */	
	public class LayoutManager
	{				
		public function LayoutManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:LayoutManager;
		public static function get instance():LayoutManager 
		{ 
			if (_instance == null)
				_instance = new LayoutManager(new SingletonEnforcer());			
			return _instance; 
		}		
		
		
		private var _layoutList:Dictionary = new Dictionary(false);
		public function get layoutList():Dictionary{return _layoutList;}
		public function set layoutList(value:Dictionary):void 
		{
			_layoutList = value;
		}
		
		

		public function addLayout(id:String, layout:ILayout):void
		{
			_layoutList[id] = layout;
		}		
		
		
		
		/**
		 * 
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