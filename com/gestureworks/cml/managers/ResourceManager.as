package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Maintains a priority queue driven by the interactivity and visible state of display objects. Pooling 
	 * and recylcing is the optimal alternative to dynamic construction and deconstruction of objects. 
	 * @author Ideum
	 */
	public class ResourceManager 
	{		
		private var _resources:Dictionary;
		private var type:Class; 
		
		/**
		 * Constructor
		 */
		public function ResourceManager() {
			_resources = new Dictionary();
		}				
		
		/**
		 * Register resource to a type specific queue 
		 * @param	resource The object to register
		 */
		public function add(resource:TouchContainer):void {
			
			type = definition(resource);
			
			//instantiate new queue type
			if (!(type in _resources)) {
				_resources[type] = new Vector.<TouchContainer>();
			}
			
			//queue and subscribe to resource
			if (queue(_resources[type], resource)) {
				resource.addEventListener(StateEvent.CHANGE, reorder);
			}
		}
		
		/**
		 * Unregister object from resource management
		 * @param	resource  The object to unregister
		 */
		public function remove(resource:TouchContainer):void {
			
			type = definition(resource);
			
			//dequeue object
			if (type in _resources && dequeue(_resources[type], resource)) {			
				
				//unsubscribe from resource
				resource.removeEventListener(StateEvent.CHANGE, reorder);
				
				//delete empty type queue
				if (!_resources[type].length) {
					delete _resources[type];
				}
			}
		}
		
		/**
		 * Returns the highest priority resource
		 * @param	type The class type specifying the queue to access
		 * @return
		 */
		public function resource(type:Class):TouchContainer {
			if (type in _resources) {
				return _resources[type][0];
			}
			return null;
		}
		
		/**
		 * Reorder queue based on visibility state and interactivity
		 * @param	event  The published visible or activity event
		 */
		private function reorder(event:StateEvent):void {
			var res:TouchContainer = event.target as TouchContainer;
			type = definition(res);
			
			//assign priority to latest invisible object
			if (event.property == "visible" && !event.value) {
				head(_resources[type], res);
			}
			//decrease priority to latest interacted object
			else if (event.property == "activity") {
				tail(_resources[type], res);
			}
		}
		
		/**
		 * Add resource to provided queue
		 * @param	queue  The queue to add the resource to
		 * @param	resource  The object to add
		 * @return  True if successfully added, false otherwise
		 */
		private function queue(queue:Vector.<TouchContainer>, resource:TouchContainer):Boolean {
			var queued:Boolean = queue.indexOf(resource) == -1;
			if (queued) {
				queue.push(resource);				
			}
			return queued; 
		}
		
		/**
		 * Remove resource from provided queue
		 * @param	queue  The queue to remove the resource from
		 * @param	resource  The object to remove
		 * @return  True if successfully removed, false otherwise
		 */
		private function dequeue(queue:Vector.<TouchContainer>, resource:TouchContainer):Boolean {
			var dequeued:Boolean = queue.indexOf(resource) != -1;
			if (dequeued) {
				queue.splice(queue.indexOf(resource), 1);
			}
			return dequeued;
		}
		
		/**
		 * Move the resource to the head of the provided queue
		 * @param	queue  The queue to reorder
		 * @param	resource  The resource to move
		 */
		private function head(queue:Vector.<TouchContainer>, resource:TouchContainer):void {
			dequeue(queue, resource);
			queue.unshift(resource);
		}
		
		/**
		 * Move the resource to the tail of the provided queue
		 * @param	queue  The queue to reorder
		 * @param	resource  The resource to move
		 */
		private function tail(queue:Vector.<TouchContainer>, resource:TouchContainer):void {
			dequeue(queue, resource);
			queue.push(resource);			
		}
		
		/**
		 * Returns the Class type of the provided resource
		 * @param	resource
		 * @return
		 */
		private function definition(resource:TouchContainer):Class {
			return getDefinitionByName(getQualifiedClassName(resource)) as Class;
		}		
	}

}
