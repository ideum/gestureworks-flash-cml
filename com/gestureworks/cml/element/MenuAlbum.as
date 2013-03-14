package  com.gestureworks.cml.element 
{
	import com.gestureworks.cml.components.CollectionViewer;
	import com.gestureworks.cml.element.Album;
	import com.gestureworks.cml.element.Dock;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author 
	 */
	public class MenuAlbum extends Album
	{
		
		private var _initialAlpha:Number = .4;
		private var _selectedAlpha:Number = 1;
		private var _selectedItem:*;
		
		private var dragClones:Dictionary = new Dictionary();
		private var collectionViewer:CollectionViewer;
		private var dock:Dock;
		private var inAlbumBounds:Boolean = true;
		
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
		 * Prevent disabling of mouseChildren
		 */
		override public function set mouseChildren(value:Boolean):void 
		{
			super.mouseChildren = true;
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
			dock = DisplayUtils.getParentType(Dock,this);
		}
		
		/**
		 * 
		 */
		private function configureItems():void
		{
			for (var i:int = 1; i < belt.numChildren; i++)
			{
				var ts:TouchSprite = TouchSprite(belt.getChildAt(i));
				ts.alpha = initialAlpha;
				ts.disableNativeTransform = true;
				ts.gestureList = { "n-tap":true, "n-drag":true};
				ts.addEventListener(GWGestureEvent.TAP, selection);	
				ts.addEventListener(GWGestureEvent.DRAG, dragItem);
				ts.addEventListener(GWGestureEvent.RELEASE, dropItem);				
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
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "selectedItem", _selectedItem, true));			
		}
		
		public function select(obj:*):void
		{
			if (selections.search(obj) != -1)
				return;
							
			obj.alpha = selectedAlpha;
			selections.append(obj);			
		}
				
		public function unSelect(obj:*):void
		{	
			var index:int = selections.search(obj);
			
			if (index >= 0) {
				selections.getIndex(index).alpha = initialAlpha;			
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
				
			var dragClone:*;
			if (dragClones[e.target])
				dragClone = dragClones[e.target];
			else
			{
				dragClone = e.target.clone();
				if (collectionViewer)
				{
					var globalPoint:Point = dragClone.transform.pixelBounds.topLeft;	
					collectionViewer.addChild(dragClone);
					dragClone.x = globalPoint.x;
					dragClone.y = globalPoint.y;
					DisplayUtils.rotateAroundCenter(dragClone, dock.rotation);
					dragClone.alpha = .5;
				}
				dragClones[e.target] = dragClone;
			}
			
			dragClone.x += e.value.drag_dx;
			dragClone.y += e.value.drag_dy;
			
			if(!inDockBounds(dragClone))
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "draggedItem", dragClone, true));
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
				if(!inDockBounds(dragClone))
					dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "droppedItem", e.target, true));			
				
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
		
		override public function dispose():void 
		{
			super.dispose();
			_selectedItem = null;
			dragClones = null;
			collectionViewer = null;
			dock = null;
		}
				
	}

}