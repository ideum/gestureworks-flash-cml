package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.easing.*;
	import org.tuio.*;
	
	/**
	 * The CollectionViewer component manages the display of components and elements. 
	 * 
	 * <p>It can load more objects than will display at any one time. The objects not displayed are put 
	 * into queue and the CollectionViwer cycles through the queue whenever a user closes an object or 
	 * moves it offscreen.</p>
	 *  
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 */	
	public class CollectionViewer extends Component
	{
		public var amountToShow:int = -1;
		public var animateIn:Boolean = true;
		
		private var queue:List;
		private var currentTween:*;
		
		private var _gateway:String;
		private var connection:NetConnection;
		private var responder:Responder;
		private var entry:Text;
		private var data:Object;
		private var index:int = 0;
		
		//private var boundsTimer:Timer;
		
		/**
		 * collection viewer Constructor
		 */
		public function CollectionViewer() 
		{
			super();
			queue = new List;
			this.mouseChildren = true;
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void 
		{
			cover = new Sprite;
		
			cover.graphics.beginFill(0x000000, 1);
			cover.graphics.drawRect(30, 30, stage.stageWidth - 60, stage.stageHeight - 60);
			cover.graphics.endFill();
			cover.cacheAsBitmap = true;
			cover.visible = false;
			this.addChildAt(cover, 0);		
			
			if (amountToShow >= childList.length || amountToShow == -1)
				amountToShow = childList.length;
					
				
			var i:int = 0;	
			for (i = 0; i < childList.length; i++) 
			{	
				if (autoShuffle) 
				{
					if (GestureWorks.activeTUIO)
						childList.getIndex(i).addEventListener(TuioTouchEvent.TOUCH_DOWN, updateLayout);
					else if (GestureWorks.supportsTouch)
						childList.getIndex(i).addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
					else 
						childList.getIndex(i).addEventListener(MouseEvent.MOUSE_DOWN, updateLayout);	
				}
				
				childList.getIndex(i).addEventListener(StateEvent.CHANGE, onStateEvent, false, -1);
				childList.getIndex(i).addEventListener(GWGestureEvent.COMPLETE, onBoundsTimer);
				
				if (i < amountToShow)
				{					
					addChild(childList.getIndex(i));
				}
				else
				{					
					if (contains(childList.getIndex(i)))
						removeChild(childList.getIndex(i));
											
					queue.append(childList.getIndex(i));
				}	
			}
			
				dbInit();
		}
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}	
		
		private var cover:Sprite;
		
		private function onBoundsTimer(event:GWGestureEvent=null):void
		{
			var onscreen:Boolean = CollisionDetection.isColliding(DisplayObject(event.target), cover, this, true, 0);								
			if (!onscreen)
				removeComponent(DisplayObject(event.target));			
				
			if (this.numChildren-1 < amountToShow)
				addNextComponent();			
		}
			

		   
		private var tweens:Dictionary = new Dictionary(true)
		override protected function updateLayout(event:* = null):void 
		{
			var target:*;
			
			if (GestureWorks.activeTUIO && event.target.parent.hasOwnProperty("mouseChildren") && !event.target.parent.mouseChildren)
				target = event.target.parent;
			else
				target = event.target;
						
			if (tweens[target.parent])
			{
				tweens[target.parent].stop();
				tweens[target.parent] = null;
				delete tweens[target.parent];
			}
			
			moveToTop(target);
		}
		
		private function moveToTop(obj:*):void
		{
			if (obj.parent && obj.parent != this )
				moveToTop(obj.parent);
			else
				addChild(obj);
		}

		override protected function onStateEvent(event:StateEvent):void
		{
			trace("hi");
			
			if (event.value == "close") 
			{				
				removeComponent(event.currentTarget);				
				if (numChildren-1 < amountToShow)
					addNextComponent();
			}	
		}	
		
		private function removeComponent(component:*):void
		{
			queue.append(component);
			if (contains(component as DisplayObject))
				removeChild(component as DisplayObject);
		}
		
		private function addNextComponent():void
		{
			var newComponent:*;							
			newComponent = queue.getIndex(0);
			queue.remove(0);
			
			trace(queue);
			
			if (newComponent)
			{
				newComponent.x = -500;
				newComponent.y = -500;
				addChild(newComponent);
				newComponent.visible = true;
				
				
				if (animateIn)
				{
					tweens[newComponent] = BetweenAS3.tween(newComponent, { x:stage.stageWidth/2, y:stage.stageHeight/2 }, null, 4, Exponential.easeOut)
					tweens[newComponent].onComplete = onTweenEnd;
					tweens[newComponent].play();
				}
			}
			
			function onTweenEnd():void
			{			
				tweens[newComponent] = null;
			}
						
		}
		
		
		public function get gateway():String { return _gateway; }
		public function set gateway(g:String):void
		{
			_gateway = g;
		}
		
		private function dbInit():void
		{
			// TODO: cache original cml objects and expression attributes			
			
			if (!gateway) return;
			hideAll();
			connect();
						
			entry = new Text();
			entry.width = 200;
			entry.height = 25;
			entry.type = "input";
			entry.visible = true;
			entry.background = true;
			entry.border = true;
			entry.addEventListener(KeyboardEvent.KEY_DOWN, query);
			addChild(entry);
		}
		
		private function query(e:KeyboardEvent):void
		{
			if (e.keyCode == 13)
			{
				hideAll();	
				connection.call("./AMFTest.getalldata", responder, entry.text);
				//connection.call("./SetTest.set_search", responder, entry.text);
			}
		}
		
		private function connect():void
		{
			connection = new NetConnection;
			connection.connect(gateway);				
			responder = new Responder(onResult, onFault);	
		}
		
		private function getNextComponent(c:*):*
		{
			var components:Array = searchChildren(c, Array);
			var component:*;
			var found:Boolean = false;
			
			for each(var comp:* in components)
			{
				if (!comp.visible)
				{
					component = comp;
					found = true;
				}
			}
			
			if (!found && components.length > 0)
				component = components[0];
				
							
			return component;
		}
				
		
		private function onResult(result:Object):void
		{								
			updateObjects(result);
		}
		
		private function updateObjects(result:Object):void
		{
			// get current objects available
			var objs:Array = searchChildren(ImageViewer, Array);
			
			
			var dict:Dictionary = new Dictionary(true);
			dict["ImageViewer"] = [];
			
			
					
			
			
			//dict[ImageViewer][0] = [0, 1, "src"];
			//dict[ImageViewer][1] = [1, 2, "text"];
			//dict[ImageViewer][2] = [1, 3, "text"];
			
			

			
			var cnt:int = 2;
			
			
			// TODO: get number of required objects from results (custom tag name, specifying display object)
			for each(var obj:* in result)
			{
				//cnt++;		
			}
			
			
			
		
			//objs[0].visible = true;
			objs[1] = objs[0].clone();
			objs[1].image.close();
			objs[1].image.width = 0;
			objs[1].image.height = 0;
			objs[1].image.open("http://www.sifxtreme.com/collectiveaccess-providence-1.2/media/my_first_collectiveaccess_system/images/0/11883_ca_object_representations_media_30_original.png");
			objs[1].image.addEventListener(Event.COMPLETE, function(e:Event):void { objs[1].init(); } );	
			objs[1].visible = true;
			
			var index:int = 0;
			
			/*
			for each(var obj:* in result)
			{
				if (!(objs[index] is ImageViewer)) return;
				var iv:ImageViewer = ImageViewer(objs[index]);
				iv.visible = true;
				var metaTag:String = iv.image.propertyStates[0]["src"];	
				
				iv.image.close();
				iv.image.open("http://www.sifxtreme.com/collectiveaccess-providence-1.2/media/my_first_collectiveaccess_system/images/0/11883_ca_object_representations_media_30_original.png");
			
				
				trace(obj[metaTag.substring(1, metaTag.length - 1)]);
				
				//iv.image.addEventListener(Event.COMPLETE, function(e:Event):void { iv.init(); } );
				index++;
				
				if (index == 3) break;
			}
			*/

		}
		
		private function updateSets(result:Object):void
		{
			for each(var setObject:* in result)
			{
				for (var setProperty:* in setObject)
				{
					if (setProperty == "set_items")
					{
						for (var collection:* in setObject[setProperty])
						{
							var collectionType:* = setObject[setProperty][collection]["collection_display"];
							var component:* = collectionType == "slideshow" ? getNextComponent(AlbumViewer): getNextComponent(AlbumViewer);														
							var front:* = component.front;
							var back:* = component.back;
							
							component.clear();
							front.clear();
							back.clear();
							
							for (var object:* in setObject[setProperty][collection])
							{
								for (var property:* in setObject[setProperty][collection][object])
								{
									var val:* = setObject[setProperty][collection][object][property];
									switch(property)
									{
										case "name":											
											break;
										case "work_description":
											break;
										case "image":
											var img:Image = new Image();
											img.open(val);
											img.width = 400;
											img.height = 400;
											img.resample = true;
											
											front.addChild(img);											
											break;
										default:
											break;
									}
								}
							}
							
							front.init();
							component.init();
							component.visible = true;
						}
					}
				}
			}			
		}
		
		private function onFault(fault:Object):void
		{
			trace(fault.description);
		}
		
		private function hideAll():void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				if(getChildAt(i) is TouchContainer)
					getChildAt(i).visible = false;
			}
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			queue = null;			
			currentTween = null;			
			cover = null;			
			tweens = null;
			
			if (childList)
			{
				for (var i:int = 0; i < childList.length; i++) 
				{	
					childList.getIndex(i).removeEventListener(TuioTouchEvent.TOUCH_DOWN, updateLayout);
					childList.getIndex(i).removeEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
					childList.getIndex(i).removeEventListener(MouseEvent.MOUSE_DOWN, updateLayout);
					childList.getIndex(i).removeEventListener(StateEvent.CHANGE, onStateEvent);
				}
			}
		}
	}
}