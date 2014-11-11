package  com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.components.CollectionViewer;
	import com.gestureworks.cml.elements.Album;
	import com.gestureworks.cml.elements.Dock;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Ideum
	 */
	public class MenuAlbum extends Album
	{
		
		private var _initialAlpha:Number = 1;
		private var _selectedAlpha:Number = .4;
		private var _selectedItem:*;
		
		private var dragClones:Dictionary = new Dictionary();
		private var collectionViewer:CollectionViewer;
		private var dock:Dock;
		private var inAlbumBounds:Boolean = true;
		
		private var _selectedString:String = "ON STAGE";
		
		public function MenuAlbum() 
		{
			super();
			clusterBubbling = true;
			mouseChildren = true;
		}
		
		/**
		 * Prevent disabling of clusterBubbling
		 */
		override public function set clusterBubbling(value:Boolean):void 
		{
			super.clusterBubbling = true;
		}
		
		/**
		 * The initial alpha value of the album content
		 */
		public function get initialAlpha():Number { return _initialAlpha; }
		public function set initialAlpha(a:Number):void 
		{
			_initialAlpha = a;
		}
		
		/**
		 * The alpha value to indicate a selected item
		 */
		public function get selectedAlpha():Number { return _selectedAlpha; }
		public function set selectedAlpha(a:Number):void 
		{
			_selectedAlpha = a;
		}	
		
		private var _forwardButton:*;
		/**
		 * The display object for the forward button.
		 */
		public function get forwardButton():* { return _forwardButton; }
		public function set forwardButton(value:*):void {
			if (!value) return;
			
			_forwardButton = value;
		}
		
		private var _backButton:*;
		private var targetIndex:int;
		/**
		 * The display object for the forward button.
		 */
		public function get backButton():* { return _backButton; }
		public function set backButton(value:*):void {
			if (!value) return;
			
			_backButton = value;
		}
		
		/**
		 * The selected display object
		 */
		public function get selectedItem():* { return _selectedItem; }
		
		/**
		 * Determines if the object is within the dock's boundaries
		 */
		public function inDockBounds(obj:*):Boolean 
		{ 
			var inBounds:Boolean = false;
			if (dock)
			{				
				switch(dock.position)
				{
					case "bottom":
						inBounds = obj.y > (dock.y + dock.handleHeight);
						break;
					case "top":
						inBounds = obj.y < (dock.y - dock.handleHeight);
						break;
					default:
						break;
				}
			}
			return inBounds; 			
		}
				
		/**
		 * Initialization function
		 */
		override public function init():void 
		{
			super.init();
			configureItems();
			collectionViewer = DisplayUtils.getParentType(CollectionViewer,this);
			dock = DisplayUtils.getParentType(Dock, this);
			belt.mouseChildren = true; 
		}
		
		/**
		 * 
		 */
		private function configureItems():void
		{
			//if (_selectedString != "")
			
			for (var i:int = 1; i < belt.numChildren; i++)
			{
				var ts:TouchSprite = TouchSprite(belt.getChildAt(i));
				ts.alpha = initialAlpha;
				ts.nativeTransform = false;
				ts.gestureList = { "n-tap":true, "n-drag":true};
				ts.addEventListener(GWGestureEvent.TAP, selection);	
				ts.addEventListener(GWGestureEvent.DRAG, dragItem);
				ts.addEventListener(GWGestureEvent.RELEASE, dropItem);
				
				if (forwardButton && ts.contains(forwardButton))
					continue;
				else if (backButton && ts.contains(backButton))
					continue;
				
				var selectedText:Text = new Text();
				selectedText.id = "sText";
				selectedText.autoSize = "left";
				selectedText.text = _selectedString;
				selectedText.color = 0xffffff;
				selectedText.font = "OpenSansBold";
				selectedText.visible = false;
				selectedText.fontSize = 24;
				ts.addChild(selectedText);
				selectedText.x = (ts.width / 2) - (selectedText.textWidth / 2);
				selectedText.y = (ts.height / 2) - (selectedText.textHeight);
			}
		}
		
		
		public var selections:List = new List;
		
		/**
		 * Update selected item
		 * @param	e state event
		 */
		private function selection(e:GWGestureEvent):void
		{			
			_selectedItem = e.target;	
			select(_selectedItem);
			if (forwardButton && _selectedItem.contains(forwardButton)) {
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedItem", _selectedItem, true));
				return;
			}
			else if (backButton && _selectedItem.contains(backButton)) {
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedItem", _selectedItem, true));
				return;
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedItem", _selectedItem, true));			
		}
		
		public function select(obj:*):void
		{
			if (selections.search(obj) != -1)
				return;
							
			obj.alpha = selectedAlpha;
			selections.append(obj);		
			obj.searchChildren("sText").visible = true;
		}
				
		public function unSelect(obj:*):void
		{	
			var index:int = selections.search(obj);
			
			if (index >= 0) {
				obj.alpha = initialAlpha;
				obj.searchChildren("sText").visible = false;
				selections.remove(index);
			}
		}
		
		/**
		 * Applies drag to the drag clone of the targeted Album item. If the item does not yet have a drag clone, 
		 * one is generated and mapped to the item.
		 * @param	e
		 */
		protected function dragItem(e:GWGestureEvent):void 
		{
			//prevent drag if item is already selected
			if (selections.search(e.target) != -1) return;
			
			//Only create drag item when percentage of vertical drag is greater than .5
			var yPercentage:Number = (Math.abs(e.value.drag_dx) / Math.abs(e.value.drag_dy));
			if (inAlbumBounds && (yPercentage >= 1 || yPercentage < .7))
				return;
				
			targetIndex = belt.getChildIndex(DisplayObject(e.target));
				
			var dragClone:*;
			if (dragClones[e.target])
				dragClone = dragClones[e.target];
			else
			{
				var img:Image = e.target.searchChildren(Image);
				dragClone = img.clone();
				
				//temporary kluge to resolve clone resizing issue
				dragClone.bitmap.height = 750;
				dragClone.width = 0;
				dragClone.resize();
				
				if (collectionViewer)
				{
					var globalPoint:Point = e.target.transform.pixelBounds.topLeft;	
					dragClone.x = globalPoint.x;
					dragClone.y = globalPoint.y;
					DisplayUtils.rotateAroundCenter(dragClone, dock.rotation);
					dragClone.alpha = .5;
					collectionViewer.addChild(dragClone);					
				}
				dragClones[e.target] = dragClone;
			}
			
			dragClone.x += e.value.drag_dx;
			dragClone.y += e.value.drag_dy;
			
			if(!inDockBounds(dragClone))
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "draggedItem", dragClone, true));
		}
		
		/**
		 * Destroys the corresponding drag clone
		 * @param	e
		 */
		protected function dropItem(e:GWGestureEvent):void 
		{
			var dragClone:* = dragClones[e.target];
			
			if (dragClone)
			{
				if (!inDockBounds(dragClone)) {
					dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "droppedItem", e.target, true));			
				}
				
				delete dragClones[e.target];
				dragClone.dispose();
				dragClone.parent.removeChild(dragClone);
			}
		}
		
		/**
		 * Sets inAlbumBounds flag to false
		 * @param	e
		 */
		override protected function outOfBounds(e:*):void 
		{
			super.outOfBounds(e);
			inAlbumBounds = false;
		}
		
		/**
		 * Sets inAlbumBounds flag to true
		 * @param	e
		 */
		override protected function inBounds(e:*):void 
		{
			super.inBounds(e);
			inAlbumBounds = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			_selectedItem = null;
			dragClones = null;
			collectionViewer = null;
			dock = null;
			_forwardButton = null;
			_backButton = null;
			selections = null;
		}
				
	}

}