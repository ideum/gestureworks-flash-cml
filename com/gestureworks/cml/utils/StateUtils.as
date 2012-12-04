package com.gestureworks.cml.utils 
{
	import flash.utils.Dictionary;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	import flash.utils.describeType;
	import flash.display.DisplayObjectContainer;
		
	public class StateUtils 
	{
		/**
		 * Constructor
		 */
		public function StateUtils():void {}	
		
		
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
			if (obj.hasOwnProperty("propertyStates") && obj["propertyStates"][state])
				obj.updateProperties(state);
			
			if (obj is DisplayObjectContainer && recursion)
			{
				for (var i:int = 0; i < obj.numChildren; i++)
				{
					StateUtils.loadState(obj.getChildAt(i), state, recursion);		
				}					
			}				
		}
		
		
		
		public static function tweenState(obj:*, state:Number, tweenTime:Number=250):void
		{			
			var propertyValue:String;
			var objType:String;
			var newValue:*;			
			var tweenArray:Array = new Array();
			var noTweenDict:Dictionary = new Dictionary(true);
			var rgb:Array;
			tweenTime = tweenTime / 1000;
			
			
			for (var propertyName:String in obj.propertyStates[state])
			{
				newValue = obj.propertyStates[state][propertyName];			
			
				
				if (obj[propertyName] != newValue) {
					
					if (newValue is Number && propertyName != "$x" && propertyName != "$y" && propertyName != "_x" && propertyName != "_y") {		
						
						//trace(propertyName, newValue);	
						
						if (propertyName.toLowerCase().search("color") > -1) {								
							
							rgb = ColorUtils.rgbSubtract(newValue, obj[propertyName]);
														
							tweenArray.push(BetweenAS3.tween(obj, { transform: { 
								colorTransform: {
									redOffset: rgb[0],
									greenOffset: rgb[1],
									blueOffset: rgb[2]
								}
							}}, null, 1));
							
							tweenArray[tweenArray.length - 1].onComplete = function():void { obj.color = newValue };
						}
						else
							tweenArray.push(BetweenAS3.tween(obj, { (propertyName.valueOf()):(newValue.valueOf()) }, null, tweenTime));
					}
					
					else {
						noTweenDict[propertyName] = newValue;
					}
				}

			}
			
			var tweens:ITweenGroup = BetweenAS3.parallel.apply(null, tweenArray);
			tweens.play();
			tweens.onComplete = function():void { 
				for (var p:String in noTweenDict) {
					obj[p] = noTweenDict[p];
				}
			}
	
			
			
			
		}
	}
}