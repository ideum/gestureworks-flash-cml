package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.utils.document;
	
	/**
	 * The CloneManager parses data from Clone tags declared in CML and generates clones at initialization.
	 * @author Ideum
	 */	
	public class CloneManager
	{					
		private static var _instance:CloneManager;
		private var cloneArgs:Vector.<Object> = new Vector.<Object>();
		
		/**
		 * Singleton constructor
		 */
		public function CloneManager() {
			if(_instance){
				throw new Error("Error: Instantiation failed: Use CloneManager.instance() instead of new.");
			}
		}
		
		/**
		 * Returns the CloneManager instance
		 */
		public static function get instance():CloneManager { 
			if (!_instance) {
				_instance = new CloneManager();
			}
			return _instance; 
		}
		
		/**
		 * Process CML declared Clone tags
		 */
		public function loadCMLClones():void {
			var obj:TouchContainer;
			for each(var args:Object in cloneArgs) {
				obj = document.getElementById(args["ref"]);
				if (obj) {
					cloneObject(obj, args["instances"], args["parent"], args["index"], args["properties"]);
				}
			}
			cloneArgs = null; 
		}
		
		/**
		 * Parse and store CML clone data 
		 * @param	item  Clone tag
		 * @param	parent  Display parent to add the clone to
		 */
		public function parseCMLClone(item:XML, parent:TouchContainer):void {	

			var args:Object = { ref:item.@ref, parent:parent, index:item.childIndex()};	
			delete item.@ref; 
			delete item.@parent; 
			
			args["instances"] = item.@instances == undefined ? 1 : item.@instances;			
			delete item.@instances; 
			
			args["properties"] = new Object();		
			for each(var prop:XML in item.@ * ) {
				args["properties"][String(prop.name())] = prop;
			}			
			
			cloneArgs.push(args);
		}
		
		/**
		 * Generate and optionally reconfigure cloned instances of the provided object
		 * @param	obj  The source object to clone
		 * @param	instances  The number of clones to generate 
		 * @param	parent  The display parent to add the object to
		 * @param   index  The child index of the clone
		 * @param	properties  Custom property settings to apply to the resulting clone(s)
		 */
		public function cloneObject(obj:TouchContainer, instances:int = 1, parent:*= null, index:int = NaN, properties:Object = null):void {
			
			//abort cloning
			if (!obj) {
				return; 
			}
			
			//default to object parent
			if (!parent) {
				parent = obj.parent; 
			}
			
			//generate clones
			var clone:TouchContainer;
			for (var i:int = 0; i < instances; i++) {				
				
				//invoke native cloning
				clone = obj.clone(parent);	
				
				//set clone display index
				if (parent && !isNaN(index)) {
					parent.addChildAt(clone, index < parent.numChildren ? index : parent.numChildren-1);
				}
				
				//overwrite properties
				for (var property:String in properties) {					
					if(property in clone){
						clone[property] = properties[property];
					}					
				}
			}
		}
	}
}