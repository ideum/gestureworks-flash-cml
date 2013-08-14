package com.gestureworks.cml.interfaces 
{
	/**
	 * Implement state API
	 * Requires property state array: <code>private var state:Array;</code>
	 * @author Ideum
	 */
	public interface IState 
	{		
		/**
		 * Returns the current state index.
		 * @return State index.
		 */
		function get stateIndex():int;
		
		/**
		 * Returns the current state id.
		 * @return State id.
		 */
		function get stateId():String;
		
		/**
		 * Sets the state id. Does not load state: use loadState().
		 */
		function set stateId(sId:String):void;
		
		/**
		 * Loads state by index number. If the first parameter is NaN, the current state will be saved.
		 * @param sIndex State index to be loaded.
		 * @param recursion If true the state will load recursively through the display list starting at current display ojbect.
		 */
		function loadState(sIndex:int=NaN, recursion:Boolean=false):void;
		
		/**
		 * Load state by stateId. If the first parameter is null, the current state will be save.
		 * @param sId State id to load.
		 * @param recursion If true, the state will load recursively through the display list starting at current display ojbect.
		 */
		function loadStateById(sId:String=null, recursion:Boolean=false):void;	
		
		/**
		 * Save state by index number. If the first parameter is NaN, the current state will be saved.
		 * @param sIndex State index to save.
		 * @param recursion If true the state will save recursively through the display list starting at current display ojbect.
		 */
		function saveState(sIndex:int=NaN, recursion:Boolean=false):void;		
		
		/**
		 * Save state by stateId. If the first parameter is null, the current state will be saved.
		 * @param sIndex State index to be save.
		 * @param recursion If true the state will save recursively through the display list starting at current display ojbect.
		 */
		function saveStateById(sId:String, recursion:Boolean=false):void;
		
		/**
		 * Tween state by stateIndex from current to given state index. If the first parameter is null, the current state will be saved.
		 * @param sIndex State index to tween.
		 * @param tweenTime Duration of tween
		 */
		function tweenState(sIndex:int=NaN, tweenTime:Number = 1):void;		
		
		/**
		 * Tween state by stateId from current to given id. If the first parameter is null, the current state will be saved.
		 * @param sId State id to tween.
		 */
		function tweenStateById(sId:String, tweenTime:Number = 1):void;			
	}
}