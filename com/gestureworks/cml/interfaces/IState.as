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
		 * Returns the current state id.
		 * @return State id.
		 */
		function get stateId():*;
		
		/**
		 * Sets the state id. Does not load state: use loadState().
		 */
		function set stateId(sId:*):void;
		
		/**
		 * Loads state by index number. If the first parameter is NaN, the current state will be saved.
		 * @param sIndex State index to be loaded.
		 * @param recursion If true the state will load recursively through the display list starting at current display ojbect.
		 */
		function loadState(sId:*=null, recursion:Boolean=false):void;
		
		/**
		 * Save state by index number. If the first parameter is NaN, the current state will be saved.
		 * @param sIndex State index to save.
		 * @param recursion If true the state will save recursively through the display list starting at current display ojbect.
		 */
		function saveState(sId:*=null, recursion:Boolean=false):void;		
		
		/**
		 * Tween state by stateIndex from current to given state index. If the first parameter is null, the current state will be saved.
		 * @param sIndex State index to tween.
		 * @param tweenTime Duration of tween
		 */
		function tweenState(sId:*=null, tweenTime:Number = 1):void;		
				
	}
}