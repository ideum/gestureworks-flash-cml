package com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.utils.List;
	import flash.events.Event;
	import com.gestureworks.cml.managers.FileManager;
	
	/**
	 * ImageList
	 * Set of images, array with iterator and toggle
	 * @author Charles Veasey
	 */	
	
	public class ImageList extends ElementFactory
	{
		private var image:ImageElement;		
		private var list:List;
		private var imageCount:int = 0;
		private var imagesLoaded:int = 0;
		
		public var preload:Boolean = true;
			
		public function ImageList() 
		{
			list = new List;
		}
		
		override public function dispose():void
		{
			super.dispose();
			image = null;
			list = null;
						
		}
		
		/**
		 * This is called by the CML parser. Do not override this method.
		 */		
		override public function postparseCML(cml:XMLList):void 
		{
			if (this.propertyStates[0]["src"]) {
				
				if (preload)
				{
					var value:String = this.propertyStates[0]["src"];
					var rex:RegExp = /[\s\r\n]*/gim;
					_src = value.replace(rex,'');			
					var arr:Array = _src.split(",");
				
					for (var i:int = 0; i < arr.length; i++) 
					{			
						var img:ImageElement = new ImageElement;
						//img.addEventListener(Event.COMPLETE, onImgComplete);
						imageCount++;
						img.preloadFile(arr[i]);
						list.append(img);
						if (_autoShow)
							addChild(img);	
						FileManager.instance.addToQueue(arr[i], "img");
					
					}
				}
			}
		}
		
		private var _currentIndex:int=0;
		public function get currentIndex():int { return list.currentIndex }
		public function set currentIndex(value:int):void { list.currentIndex = value; }
		
		private var _currentValue:*;
		public function get currentValue():* { return list.currentValue; }	
		
		private var _length:int=0;
		public function get length():int { return list.length }		
		
		private var _autoShow:Boolean=false;
		public function get autoShow():Boolean { return _autoShow; }
		public function set autoShow(value:Boolean):void 
		{ 
			_autoShow = value; 	
		}
		
		private var _src:String;
		public function get src():String { return _src; }
		public function set src(value:String):void 
		{
			if (preload) return;
			
			var rex:RegExp = /[\s\r\n]*/gim;
			_src = value.replace(rex,'');			
			var arr:Array = _src.split(",");
			
			for (var i:int = 0; i < arr.length; i++) 
			{
				append(arr[i]);				
			}			
		}		

		public function getIndex(index:int):*
		
		{
			return list.getIndex(index);
		}			
		
		public function selectIndex(index:int):*
		{
			return list.selectIndex(index);
		}		
		
		public function search(value:*):*
		{	
			return list.search(value);			
		}
		
		public function append(file:String):void 
		{	
			var img:ImageElement = new ImageElement;
			img.addEventListener(Event.COMPLETE, onImgComplete);
			imageCount++;
			img.open(file);
			list.append(img);
			if (_autoShow)
				addChild(img);	
		}
		
		public function prepend(file:String):void 
		{
			var img:ImageElement = new ImageElement;
			img.addEventListener(Event.COMPLETE, onImgComplete);
			imageCount++;			
			img.open(file);
			list.prepend(img);
			if (_autoShow)
				addChild(img);			
		}
		
		public function insert(index:int, file:String):void 
		{
			var img:ImageElement = new ImageElement;
			img.addEventListener(Event.COMPLETE, onImgComplete);
			imageCount++;			
			img.open(file);
			list.insert(index, img);
			if (_autoShow)
				addChild(img);		
		}		
		
		public function loadComplete():void 
		{ 
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onImgComplete(event:Event):void
		{
			imagesLoaded++;
			
			if (imagesLoaded == imageCount)
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		public function removeIndex(index:int):void
		{	
			list.remove(index);	
		}		
		
		public function reset():void
		{
			list.currentIndex = 0;		
		}
		
		public function hasNext():Boolean
		{
			return list.hasNext();
		}
		
		public function hasPrev():Boolean
		{
			return list.hasPrev();
		}		
		
		public function next():*
		{
			return list.next();
		}
		
		public function prev():*
		{
			return list.prev();
		}
		
		public function hasIndex(index:int):Boolean
		{
			return list.hasIndex(index);
		}
		
		public function show(index:int):void
		{			
			addChild(list.selectIndex(index));
		}
		
		public function hide(index:int):void
		{
			if (contains(list.getIndex(index)))			
				removeChild(list.getIndex(index));
		}
		
		public function toggle(index1:int, index2:int):void
		{	
			if (contains(list.getIndex(index1)))
			{	
				removeChild(list.getIndex(index1));
				addChild(list.selectIndex(index2));
			}
			else if (contains(list.getIndex(index2)))
			{	
				removeChild(list.getIndex(index2));
				addChild(list.selectIndex(index1));			
			}
		}
		
	}
}