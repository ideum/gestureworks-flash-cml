package com.gestureworks.cml.core
{
	import away3d.core.render.Renderer;
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.cml.managers.DisplayManager;
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.managers.FileManager;
	
	import com.gestureworks.cml.loaders.CML;
	import com.gestureworks.events.CMLEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * The ComponentKitDisplay class.
	 * 
	 * @see flash.display.Sprite
	 * 
	 * 
	 * @langversion 3.0
	 * @playerversion AIR 2.5
	 * @playerversion Flash 10.1
	 * @productversion GestureWorks 3.0
	 */
	
	public class ComponentKitDisplay extends Container
	{
		protected var renderKit:XML;		
		
		/**
		 *  ComponentKitDisplay Constructor.
		 *  
		 * @langversion 3.0
		 * @playerversion AIR 1.5
		 * @playerversion Flash 10
		 * @playerversion Flash Lite 4
		 * @productversion GestureWorks 1.5
		 */
		public function ComponentKitDisplay()
		{
			super();
		}
				
		
		private var _classRef:String;
		public function get classRef():String { return _classRef ; }
		public function set classRef(value:String):void
		{
			_classRef = value;
		}
		
		
		private var _rendererList:String;
		public function get rendererList():String{return _rendererList;}
		public function set rendererList(value:String):void
		{			
			if (_rendererList == value)
				return;
				
			_rendererList = value;
			FileManager.instance.addToQueue(_rendererList, "cml");
		}
		
		
		

		////////////////////////////////////////////////
		//  IObject  
		/////////////////////////////////////////		
	
		public var componentId:String;
				
		override public function parseCML(cml:XMLList):XMLList
		{
			var returnNode:XMLList = null;
			
			if (cml.@classRef != undefined)
			{
				classRef = cml.@classRef;						
				rendererList = cml.@rendererList;	
							
				var obj:Object;
				
				obj = CMLParser.instance.createObject(classRef);
				obj.id = cml.@id + "." + classRef;
				childToList(obj.id, obj);
				
				componentId = obj.id;
				
				
				CMLObjectList.instance.append(obj.id, obj);					
			}

			return CMLParser.instance.parseCML(this, cml);
		}
		
		
		override public function postparseCML(cml:XMLList):void {}
		
		
		override public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);
		}			
			

		
		
		//////////////////////////////////////////////////
		// Load Renderer
		///////////////////////////////////////////
		
		
		public function loadRenderer():void
		{	
			renderKit = XML(CML.getInstance(_rendererList).data);
			
			var rendererId:String = renderKit.Renderer.@id; 
			var rendererData:String = renderKit.Renderer.@data;
			
			var renderedItemId:String;
			
			for (var q:int; q < renderKit.Renderer.length(); q++)
			{								
				var renderList:XMLList = renderKit[rendererData].children();				
						
				for (var i:int=0; i<renderList.length(); i++)
				{
					var cmlRenderer:XMLList = new XMLList(renderKit.Renderer[q].*);
					
					for each (var node:XML in cmlRenderer) 
					{
						var properties:XMLList = XMLList(renderList[i]);						
						CMLParser.instance.loopCML(node, CMLObjectList.instance.getKey(componentId), properties);
					}
					
				}
				
			}
		
		}		
		
		
		
	}
}