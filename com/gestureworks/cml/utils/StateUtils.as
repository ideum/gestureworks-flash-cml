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
		public static function saveState(obj:Object, state:Number, recursion:Boolean=false):void 
		{	
			if (!obj.propertyStates[state])
				obj.propertyStates[state] = new Dictionary(false);
	
			CloneUtils.copyData(obj, obj.propertyStates[state]); 
				
			if (obj is DisplayObjectContainer && recursion)
			{
				for (var i:int = 0; i < obj.numChildren; i++)
				{
					StateUtils.saveState(obj.getChildAt(i), state, recursion);		
				}					
			}
				
		}
		
		
		/**
		 * Loades current property values to a provided slot of the object's state array.
		 * @param	obj 
		 * @param	state
		 */
		public static function loadState(obj:Object, state:Number, recursion:Boolean=false):void 
		{		
			if (obj.hasOwnProperty("propertyStates") && obj["propertyStates"] && obj["propertyStates"][state])
				obj.updateProperties(state);
			
			if (obj is DisplayObjectContainer && recursion) {
				for (var i:int = 0; i < obj.numChildren; i++) {
					StateUtils.loadState(obj.getChildAt(i), state, recursion);		
				}					
			}				
		}
		
		
		
		public static function tweenState(obj:*, state:Number, tweenTime:Number=1):void
		{			
			var propertyValue:String;
			var objType:String;
			var newValue:*;			
			var tweenArray:Array = new Array();
			var noTweenDict:Dictionary = new Dictionary(true);
			var rgb:Array;			
			
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
							TweenLite.to(obj, tweenTime, {(propertyName.valueOf):(Number(newValue)) } ));
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