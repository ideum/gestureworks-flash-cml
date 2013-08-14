package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.display.DisplayObjectContainer;

	TweenPlugin.activate([ColorTransformPlugin]);
	
	public class StateUtils 
	{		
		/**
		 * Writes cml state to object state
		 * @param	obj 
		 * @param	state
		 */		
		public static function parseCML(obj:Object, cml:XMLList):void
		{
			if (!("state" in obj)) return;
		
			var name:String;
			var val:*;
			var i:int;			
			
			for each (var node:XML in cml.*) {
				if (node.name() == "State") {
					obj.state.push(new Dictionary); 
					for each (val in node.@*) {
						name = val.name();	
						if (val == "true") val = true;
						if (val == "false") val = false;	
						obj.state[obj.state.length - 1][name]  = val;
					}	
					
				}	
			}
		}
		
		
		/**
		 * Stores current property values to a provided slot of the object's state array.
		 * @param	obj 
		 * @param	state
		 */
		public static function saveState(obj:Object, stateIndex:Number, recursion:Boolean=false):void 
		{	
			if (!stateIndex) stateIndex = 0;
			
			if (!obj.state[stateIndex])
				obj.state[stateIndex] = new Dictionary(false);
		
			for (var item:String in obj.state[stateIndex]) {					
				if (item != "stateId")
					obj.state[stateIndex][item] = obj[item];	
			}	
			
			if (obj is DisplayObjectContainer && recursion) {
				for (var i:int = 0; i < obj.numChildren; i++)
					StateUtils.saveState(obj.getChildAt(i), stateIndex, recursion);		
			}
				
		}

		
		/**
		 * Stores current property values to a provided slot of the object's state array.
		 * @param	obj 
		 * @param	state
		 */
		public static function saveStateById(obj:Object, stateId:String, recursion:Boolean=false):void 
		{
			var i:int;
			for (i = 0; i < obj.state.length; i++) {
				if ("stateId" in obj.state[i]) {
					if (obj.state[i]["stateId"] == stateId) {
						for (var item:String in obj.state[i]) {			
							if (item != "stateId")
								obj.state[i][item] = obj[item];		
						}
						break;
					}	
				}	
			}			
			
			if (obj is DisplayObjectContainer && recursion) {
				for (i=0; i < obj.numChildren; i++)
					StateUtils.saveStateById(obj.getChildAt(i), stateId, recursion);		
			}
		}		
		
		/**
		 * Loads current property values to a provided slot of the object's state array.
		 * @param	obj 
		 * @param	state
		 */
		public static function loadState(obj:Object, stateIndex:Number, recursion:Boolean=false):Boolean
		{		
			var success:Boolean = false;
			
			if (!stateIndex) stateIndex = 0;
			
			if (obj.state[stateIndex]){
				obj.updateProperties(stateIndex);
				success = true;
			}
			
			if (obj is DisplayObjectContainer && recursion) {
				for (var i:int = 0; i < obj.numChildren; i++) {
					if (!StateUtils.loadState(obj.getChildAt(i), stateIndex, recursion)) {
						success = false;
						break;
					}
				}					
			}				
			
			return success;
		}
		
		
		/**
		 * Loads current property values to a provided slot of the object's state array.
		 * @param	obj 
		 * @param	state
		 */
		public static function loadStateById(obj:Object, stateId:String, recursion:Boolean=false):Boolean 
		{
			return loadState(obj, getStateById(obj,stateId), recursion);				
		}		
		
		/**
		 * Tween state by state number from current to given state index. 
		 * @param sIndex State index to tween.
		 * @param tweenTime Duration of tween
		 */		
		public static function tweenState(obj:*, state:Number, tweenTime:Number=1):void
		{			
			var propertyValue:String;
			var objType:String;
			var newValue:*;			
			var tweenArray:Array = new Array();
			var noTweenDict:Dictionary = new Dictionary(true);
			var rgb:Array;			
			
			if (!state) state = 0;
			
			for (var propertyName:String in obj.propertyStates[state])
			{
				newValue = obj.propertyStates[state][propertyName];
				if (obj[propertyName] != newValue) {
					
					if (propertyName != "$x" && propertyName != "$y" && propertyName != "_x" && propertyName != "_y") {				
						
						if (propertyName.toLowerCase().search("color") > -1) {
							rgb = ColorUtils.rgbSubtract(newValue, obj[propertyName]);							
							tweenArray.push(TweenLite.to(obj, 1, {colorTransform:{redOffset:rgb[0], greenOffset:rgb[1], blueOffset:rgb[2]}, onComplete:function():void { obj.color = newValue }}));							
						}
						else tweenArray.push(
							TweenLite.to(obj, tweenTime, {(propertyName.valueOf()):(Number(newValue)) } ));
						}
					
					else noTweenDict[propertyName] = newValue;
				}
			}
			
			var tweens:TimelineLite = new TimelineLite({onComplete:function():void { 
				for (var p:String in noTweenDict) {
					obj[p] = noTweenDict[p];
			}}});
			tweens.appendMultiple(tweenArray);
			tweens.play();
				
			dispatchEvent(new StateEvent(StateEvent.CHANGE, null, null, "tweenComplete"));
		}
			
		/**
		 * Tween state by state number from current to given state index. 
		 * @param	obj The object to tween
		 * @param	stateId The id of the state to tween to
		 * @param	tweenTime Duration of tween
		 */
		public static function tweenStateById(obj:*, stateId:String, tweenTime:Number = 1):void
		{
			tweenState(obj, getStateById(obj,stateId), tweenTime);
		}
			
		/**
		 * Return state index by id
		 * @param	obj
		 * @param	stateId
		 * @return
		 */
		public static function getStateById(obj:*, stateId:String):int
		{
			var i:int;
			
			for (i = 0; i < obj.state.length; i++) {
				if ("stateId" in obj.state[i]) {
					if (obj.state[i]["stateId"] == stateId) {
						return i;
					}	
				}	
			}			
			
			return 0;			
		}
	
		// IEventDispatcher
        private static var _dispatcher:EventDispatcher = new EventDispatcher();
        public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
            _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public static function dispatchEvent(event:Event):Boolean {
            return _dispatcher.dispatchEvent(event);
        }
        public static function hasEventListener(type:String):Boolean {
            return _dispatcher.hasEventListener(type);
        }
        public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            _dispatcher.removeEventListener(type, listener, useCapture);
        }
        public static function willTrigger(type:String):Boolean {
            return _dispatcher.willTrigger(type);
        }			
	}
	
}