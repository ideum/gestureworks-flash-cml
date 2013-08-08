package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.element.Image;
	import flash.utils.Dictionary;
	/**
	 * Manages the storage and loading of object states through the RenderKit. Passing a state to the StateManager, is done by assigning a stateId to 
	 * a RenderData object. To load the object state, pass the stateId to the StateManager through the loadState function (StateManager.loadState("first state")).
		<RenderKit>

			<Renderer max="1" dataRootNode="Item">
				<Container id="c1" x="{x}" y="{y}">
					<Graphic id="g" color="{color}" shape="{shape}" radius="{r}" width="{width}" height="{height}"/>
				</Container>
			</Renderer>

			<RendererData>
				<Item stateId="circle_1">
					<x>500</x>
					<y>0</y>
					<shape>circle</shape>			
					<color>0x000000</color>
					<r>100</r>
				</Item>
				<Item stateId="rectangle_1"> 
					<x>500</x>
					<y>200</y>
					<shape>rectangle</shape>
					<color>0xFF0000</color>			
					<width>200</width>					
					<height>100</height>
				</Item>
				<Item stateId="rectangle_2"> 
					<x>500</x>
					<y>400</y>
					<shape>rectangle</shape>
					<color>0x00FF00</color>			
					<width>200</width>					
					<height>400</height>
				</Item>
				<Item stateId="circle_2"> 
					<x>500</x>
					<y>600</y>
					<shape>circle</shape>		
					<r>150</r>
				</Item>
			</RendererData>	

		</RenderKit>
	 * @author shaun
	 */
	public class StateManager 
	{		
		private static var _states:Dictionary;
		private static var _loadedObjects:Array;		
		private static var attributes:Array;
		private static var placeholder:int = -1;
		
		/**
		 * Dictionary of object states in the following nested structure: state id-->object-->property-->value.
		 */
		public static function get states():Dictionary { return _states; }
		
		/**
		 * Latest updated objects
		 */
		public static function get loadedObjects():Array { return _loadedObjects;}
				
		/**
		 * Generates a nested dictionary of state data with the following structure: state id-->object placeholder-->property-->value.
		 * The placeholder will be replaced by the resulting CML object after instantiaton.
		 * @param	stateData
		 * @param	objects
		 */
		public static function saveState(stateData:XML, cmlObjects:XMLList):void {
			var stateAttr:XML;
			var attr:*;
			var stateId:String = stateData.@stateId;
						
			if (!attributes) {
				attributes = new Array();
				storeAttributes(cmlObjects);
			}
			
			if (!_states)
				_states = new Dictionary();	
			if(!_states[stateId])
				_states[stateId] = new Dictionary();
			
			for each(stateAttr in stateData.*){

				for each(attr in attributes) {
					
					//populate states with state attributes matching renderer object attributes
					if (stateAttr.name() == attr.value) {
						
						if (!_states[stateId][attr.placeholder])
							_states[stateId][attr.placeholder] = new Dictionary();
						if (!_states[stateId][attr.placeholder][attr.property])
							_states[stateId][attr.placeholder][attr.property] = new Dictionary();
							
						_states[stateId][attr.placeholder][attr.property] = stateAttr.toString();
					}
				}
			}
			
		}
		
		/**
		 * Parse renderer objects to identify which attributes to to update when loading states. These attributes
		 * are indicated with values between two curly braces (e.g "{x}"). Also flag the renderer object node with
		 * saveState attribute to later (after instantiation) identify the AS3 object for placeholder replacement.
		 * @param	objects
		 */
		private static function storeAttributes(objects:XMLList):void {
			var str:String;
			var regExp:RegExp = /[\s\r\n{}]*/gim;
			
			for each(var obj:* in objects) {
				placeholder++;
				for each(var attr:* in obj.@ * ) {
					str = attr.toString();
					if (str.charAt(0) == "{" && str.charAt(str.length -1) == "}") {
						obj.@saveState = "true";
						attributes.push({placeholder:placeholder, property:attr.name().toString(), value:str.replace(regExp, '')});
					}
				}
				storeAttributes(obj.*);				
			}
		}
		
		/**
		 * Sequentially replace the placeholder integers with objects. Intended for post CML object
		 * instantiation.
		 * @param	object
		 */
		public static function saveObject(object:*): void {
			placeholder = -1;
			attributes = null;
			var phId:Number;
			
			for (var stateId:* in _states) {
				for (var p:* in _states[stateId]) {
					
					//placeholder change
					if (!isNaN(phId) && p != phId)
						continue;
					
					//current placeholder
					if (p is int) {
						phId = p;						
					}
					
					//assign placeholder dictionary to object
					_states[stateId][object] = _states[stateId][phId];
					
					//delete placeholder dictionary
					delete _states[stateId][phId];
				}
			}
		}
		
		/**
		 * Loads applicable objects with provided states.
		 * @param	stateId
		 */
		public static function loadState(stateId:*): void {
			if(_states[stateId])
				_loadedObjects = new Array();
			for (var obj:* in _states[stateId]) {
				_loadedObjects.push(obj);
				for (var prop:* in _states[stateId][obj]){
					obj[prop] = _states[stateId][obj][prop];
				}
			}
		}
	}

}