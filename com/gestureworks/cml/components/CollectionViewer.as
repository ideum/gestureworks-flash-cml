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
		
		private function onBoundsTimer(event:GWGestureEvent):void
		{				
			var onscreen:Boolean = CollisionDetection.isColliding(DisplayObject(event.target), cover, this, true, 0);								
			trace(onscreen);
			if (!onscreen)
			{					
				removeComponent(DisplayObject(event.target));
				
				if (this.numChildren-1 < amountToShow)
					addNextComponent();
			}				
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
						
			
			if (target.parent is TouchContainer){
				if (contains(target.parent))
				{	
					removeChild(target.parent);
					addChild(target.parent);
				}
			}
		}

		override protected function onStateEvent(event:StateEvent):void
		{			
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
			if (!gateway) return;
			hideAll();
			connect();
			
			entry = new Text();
			entry.width = 200;
			entry.height = 25;
			entry.type = "input";
			entry.visible = true;
			entry.background = true;
			entry.addEventListener(KeyboardEvent.KEY_DOWN, query);
			addChild(entry);
		}
		
		private function query(e:KeyboardEvent):void
		{
			if (e.keyCode == 13)
			{
				hideAll();				
				connection.call("./SetTest.set_search", responder, entry.text);
			}
		}
		
		private function connect():void
		{
			connection = new NetConnection;
			connection.connect(gateway);				
			responder = new Responder(onResult, onFault);	
		}
		
		private function onResult(result:Object):void
		{		
			var index:int = 1;
			for each(var i:* in result)
			{
				for (var type:* in i)
				{
					if (type == "set_meta_data")
					{
						for (var metaDataItems:* in i[type])
							trace(metaDataItems);
					}
					else if (type == "set_items")
					{
						for (var setItem:* in i[type])
						{
							for (var collectionItem:* in i[type][setItem])
							{
								if (!(getChildAt(index) is ImageViewer)) return;
								
								var iv:ImageViewer = ImageViewer(getChildAt(index));
								if (collectionItem is Number)
								{
									for (var objectData:* in i[type][setItem][collectionItem])
									{
										var val:* = i[type][setItem][collectionItem][objectData];
										//trace(objectData, i[type][setItem][collectionItem][objectData]);
										switch(objectData)
										{
											case "name":
												var back:TouchContainer = TouchContainer(iv.back);
												var title:Text = Text(back.getChildByName("title"));
												title.text = val;
												break;
											case "work_description":
												var back:TouchContainer = TouchContainer(iv.back);
												var description:Text = Text(back.getChildByName("description"));
												description.text = val;												
												break;
											case "image":
												var tc:TouchContainer = TouchContainer(iv.image.parent);
												tc.removeChild(iv.image);					
												
												var img:Image = new Image();												
												img.open(val);
												img.init();
												//img.resample = true;												
												tc.addChild(img);
												
												iv.width = 0;
												iv.height = 0;
												iv.image = img;
												iv.init();
												iv.visible = true;
												break;
											default:
												break;
										}
									}
								}
								else
									trace(collectionItem, i[type][setItem][collectionItem]);
									
								index++;
							}
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
				if(getChildAt(i) is ImageViewer)
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